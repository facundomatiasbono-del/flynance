import { createClient } from '@supabase/supabase-js'

const defaultUrl = 'https://goxexrlovlechdxgsxbq.supabase.co'
const configuredUrl = import.meta.env.VITE_SUPABASE_URL
const key = import.meta.env.VITE_SUPABASE_ANON_KEY

function validSupabaseUrl(value:string|undefined) {
  if (!value) return false
  try {
    const parsed = new URL(value)
    return parsed.protocol === 'https:' && parsed.hostname.endsWith('.supabase.co')
  } catch {
    return false
  }
}

const url = validSupabaseUrl(configuredUrl) ? configuredUrl : defaultUrl
export const configured = Boolean(key)
const authStorage = {
  getItem(key:string) {
    return localStorage.getItem('remember_session')!=='false'
      ? localStorage.getItem(key)
      : sessionStorage.getItem(key)
  },
  setItem(key:string,value:string) {
    const remember=localStorage.getItem('remember_session')!=='false'
    const target=remember?localStorage:sessionStorage
    const other=remember?sessionStorage:localStorage
    target.setItem(key,value)
    other.removeItem(key)
  },
  removeItem(key:string) {
    localStorage.removeItem(key)
    sessionStorage.removeItem(key)
  },
}
export const supabase = createClient(
  url || 'https://example.supabase.co',
  key || 'demo-key',
  {auth:{storage:authStorage,persistSession:true,autoRefreshToken:true}},
)
