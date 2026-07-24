import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const encoder = new TextEncoder()

function escapeXml(value: string) {
  return value.replace(/[<>&'\"]/g, char => ({ '<': '&lt;', '>': '&gt;', '&': '&amp;', "'": '&apos;', '"': '&quot;' }[char]!))
}

function response(message: string, status = 200) {
  return new Response(`<?xml version="1.0" encoding="UTF-8"?><Response><Message>${escapeXml(message)}</Message></Response>`, {
    status,
    headers: { 'content-type': 'text/xml; charset=utf-8' },
  })
}

function normalizePhone(from: string) {
  return from.replace(/^whatsapp:/, '').trim()
}

function parseExpense(text: string) {
  const normalized = text.trim().replace(/\s+/g, ' ')
  const match = normalized.match(/^\$?\s*([0-9]+(?:[.,][0-9]{1,2})?)\s+(.+)$/i)
  if (!match) return null
  const amount = Number(match[1].replace(',', '.'))
  if (!Number.isFinite(amount) || amount <= 0) return null
  const detail = match[2].trim()
  const first = detail.split(' ')[0]
  const known: Record<string, string> = {
    comida: 'Comida', transporte: 'Transporte', supermercado: 'Supermercado',
    servicios: 'Servicios', salud: 'Salud', ocio: 'Ocio', otros: 'Otros',
  }
  return { amount, category: known[first.toLowerCase()] || 'Otros', description: detail }
}

async function validTwilioSignature(req: Request, params: URLSearchParams) {
  const signature = req.headers.get('x-twilio-signature') || ''
  const token = Deno.env.get('TWILIO_AUTH_TOKEN') || ''
  const publicUrl = Deno.env.get('TWILIO_WEBHOOK_URL') || req.url
  if (!signature || !token) return false
  const sorted = [...params.entries()].sort(([a], [b]) => a.localeCompare(b))
  const payload = publicUrl + sorted.map(([key, value]) => key + value).join('')
  const key = await crypto.subtle.importKey('raw', encoder.encode(token), { name: 'HMAC', hash: 'SHA-1' }, false, ['sign'])
  const signed = await crypto.subtle.sign('HMAC', key, encoder.encode(payload))
  const expected = btoa(String.fromCharCode(...new Uint8Array(signed)))
  if (signature.length !== expected.length) return false
  let difference = 0
  for (let i = 0; i < signature.length; i++) difference |= signature.charCodeAt(i) ^ expected.charCodeAt(i)
  return difference === 0
}

Deno.serve(async req => {
  if (req.method !== 'POST') return new Response('Method not allowed', { status: 405 })
  const params = new URLSearchParams(await req.text())
  if (!(await validTwilioSignature(req, params))) return new Response('Invalid signature', { status: 403 })

  const from = normalizePhone(params.get('From') || '')
  const body = params.get('Body') || ''
  const messageSid = params.get('MessageSid') || ''
  const parsed = parseExpense(body)
  if (!parsed) return response('No pude interpretarlo. Probá, por ejemplo: 1200 comida')

  const db = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!)
  const { data: profile } = await db.from('profiles').select('id').eq('whatsapp_phone', from).maybeSingle()
  if (!profile) return response('Este número todavía no está vinculado. Ingresá a la app y vinculalo en tu perfil.')

  const { error } = await db.from('expenses').insert({
    user_id: profile.id, amount: parsed.amount, category: parsed.category,
    description: parsed.description, source: 'whatsapp', twilio_message_sid: messageSid || null,
  })
  if (error?.code === '23505') return response('Ese gasto ya estaba registrado.')
  if (error) return response('No pude guardar el gasto. Intentá nuevamente en unos minutos.', 500)
  const formatted = new Intl.NumberFormat('es-AR', { style: 'currency', currency: 'ARS' }).format(parsed.amount)
  return response(`✅ Guardado: ${formatted} — ${parsed.category}`)
})
