
# DV Photo App — Part 3 (Live camera overlay, Print sheet, Ethiopia queue stubs)

This drop adds:
- **Live Camera Overlay** screen with framing guides and *auto-capture* when the face is likely compliant (simple heuristic).
- **Print Sheet Generator**: export a PDF with multiple 2×2 inch tiles (DV-ready 600×600) on A4 or Letter.
- **Ethiopia Flavor stubs**: a submit-order form, local queue storage, and status list (ready to swap for Supabase later).

> Note: Real-time ML landmarks on camera preview are device-intensive. This Part uses a pragmatic loop:
> it captures a preview frame periodically, checks compliance, and **auto-captures** when within bounds.

## New dependencies (merge into your pubspec)
```yaml
dependencies:
  camera: ^0.11.0+2
  pdf: ^3.10.7
  printing: ^5.12.0
  # (Existing: flutter_riverpod, go_router, image, image_picker, path_provider, google_mlkit_face_detection)
```

## New Routes
- `/capture` — live camera overlay with auto-capture and compliance hints
- `/print` — print sheet generator for last DV-ready image
- `/et/order` — Ethiopia: submit order form
- `/et/queue` — Ethiopia: queue list (local mock)

## Quick test
1. Open **Capture** → align face in guides → it will **auto-capture** when bounds hit.
2. Go to **Print Sheet** → choose A4 or Letter → save/print a PDF.
3. Switch to `APP_FLAVOR=ethiopia` → open **Submit Order** → fill fields → the order appears in **Queue**.

## Swap stubs to Supabase later
- Replace `LocalOrderService` with real repository calls.
- Keep `Order` model as-is; add your auth/user linkage.

