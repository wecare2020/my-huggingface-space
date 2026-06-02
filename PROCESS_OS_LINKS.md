# Phuoc Hung Process OS

Running public demo:

- https://raw.githack.com/wecare2020/my-huggingface-space/main/process-os.html

GitHub Pages candidate:

- https://wecare2020.github.io/my-huggingface-space/process-os.html

Note: the same file was also added to the `gh-pages` branch, but GitHub Pages is still returning 404 until Pages is enabled/configured in repository settings.

Supabase/Refine status:

- Refine + Supabase React app is implemented locally in `work/erp-refine`.
- Supabase CLI is installed (`supabase` 2.104.0).
- Supabase project/database creation is blocked until `supabase login` is completed or `SUPABASE_ACCESS_TOKEN` is provided.
- Schema is in `work/erp-refine/supabase/schema.sql` and includes light Google-Sheet-like process tables for Item Master, Product Development, CRM, nav/config, fields, and RLS policies.
