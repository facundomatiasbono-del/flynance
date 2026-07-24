import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const key = import.meta.env.VITE_SUPABASE_ANON_KEY

export const configured = Boolean(url && key)
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
