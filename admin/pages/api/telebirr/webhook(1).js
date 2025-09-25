
export default async function handler(req, res) {
  const payload = req.body || {};
  // Validate Telebirr signature; update payments by payload.tx_ref
  return res.status(200).json({ ok: true });
}
