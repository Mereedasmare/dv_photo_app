
export default async function handler(req, res) {
  // TODO: verify signature with Stripe SDK
  const event = req.body || {};
  // Update payments table by event.data.object.id
  return res.status(200).json({ ok: true });
}
