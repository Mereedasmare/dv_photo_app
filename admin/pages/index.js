
import { createClient } from '@supabase/supabase-js';
import { useEffect, useState } from 'react';

const supa = createClient(process.env.NEXT_PUBLIC_SUPABASE_URL, process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY);

export default function Home() {
  const [orders, setOrders] = useState([]);
  const [session, setSession] = useState(null);
  const [email, setEmail] = useState('');

  useEffect(() => {
    supa.auth.getSession().then(({ data }) => setSession(data.session));
  }, []);

  async function signIn(e) {
    e.preventDefault();
    const { error } = await supa.auth.signInWithOtp({ email });
    if (error) alert(error.message);
    else alert('Check your email for the login link');
  }

  async function loadOrders() {
    const { data, error } = await supa.from('orders').select('*').order('created_at', { ascending: false });
    if (error) alert(error.message);
    else setOrders(data);
  }

  return (
    <main style={{ padding: 24 }}>
      <h1>DV Admin</h1>
      {!session ? (
        <form onSubmit={signIn} style={{ marginTop: 16 }}>
          <input placeholder="Your admin email" value={email} onChange={e => setEmail(e.target.value)} />
          <button type="submit" style={{ marginLeft: 8 }}>Send Magic Link</button>
        </form>
      ) : (
        <>
          <button onClick={loadOrders}>Load Orders</button>
          <ul>
            {orders.map(o => (
              <li key={o.id}>
                <code>{o.status}</code> — <strong>{o.id}</strong> — {new Date(o.created_at).toLocaleString()}
              </li>
            ))}
          </ul>
        </>
      )}
    </main>
  );
}
