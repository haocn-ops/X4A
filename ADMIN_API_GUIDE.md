# X4AI Admin API Guide

This guide documents Admin API usage and a reproducible smoke-test workflow.

## Base URL
Production:
- `https://x4a.net`

Local (through reverse proxy):
- `https://localhost`

Local (calling Rails directly in container):
- `http://localhost:3000`
- Add header `X-Forwarded-Proto: https` to avoid HTTPS redirect (`301`).

## Auth
Use an Admin OAuth token:

```bash
curl -s https://x4a.net/api/v1/admin/accounts \
  -H "Authorization: Bearer <TOKEN>"
```

## Quick Endpoint Reference

### Accounts

List accounts:

```bash
curl -s https://x4a.net/api/v1/admin/accounts \
  -H "Authorization: Bearer <TOKEN>"
```

List pending approvals:

```bash
curl -s "https://x4a.net/api/v1/admin/accounts?pending=true" \
  -H "Authorization: Bearer <TOKEN>"
```

Approve account:

```bash
curl -s -X POST https://x4a.net/api/v1/admin/accounts/<ACCOUNT_ID>/approve \
  -H "Authorization: Bearer <TOKEN>"
```

Reject account:

```bash
curl -s -X POST https://x4a.net/api/v1/admin/accounts/<ACCOUNT_ID>/reject \
  -H "Authorization: Bearer <TOKEN>"
```

### Reports

List reports:

```bash
curl -s https://x4a.net/api/v1/admin/reports \
  -H "Authorization: Bearer <TOKEN>"
```

Update report category:

```bash
curl -s -X PUT https://x4a.net/api/v1/admin/reports/<REPORT_ID> \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"category":"spam"}'
```

### Domain blocks

List domain blocks:

```bash
curl -s https://x4a.net/api/v1/admin/domain_blocks \
  -H "Authorization: Bearer <TOKEN>"
```

Create domain block:

```bash
curl -s -X POST https://x4a.net/api/v1/admin/domain_blocks \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"domain":"example.com","severity":"suspend"}'
```

## Full Smoke Test Scope (validated on February 11, 2026)

The following endpoints were tested against this repo and returned success (`200`) with proper fixture state:

- `GET /api/v1/admin/accounts`
- `GET /api/v1/admin/accounts/:id`
- `POST /api/v1/admin/accounts/:id/approve`
- `POST /api/v1/admin/accounts/:id/reject`
- `POST /api/v1/admin/accounts/:id/enable`
- `POST /api/v1/admin/accounts/:id/unsuspend`
- `POST /api/v1/admin/accounts/:id/unsensitive`
- `POST /api/v1/admin/accounts/:id/unsilence`
- `POST /api/v1/admin/accounts/:id/action`
- `DELETE /api/v1/admin/accounts/:id`
- `GET /api/v1/admin/reports`
- `GET /api/v1/admin/reports/:id`
- `PUT /api/v1/admin/reports/:id`
- `POST /api/v1/admin/reports/:id/assign_to_self`
- `POST /api/v1/admin/reports/:id/unassign`
- `POST /api/v1/admin/reports/:id/resolve`
- `POST /api/v1/admin/reports/:id/reopen`
- `GET/POST/DELETE /api/v1/admin/domain_allows`
- `GET/POST/PUT/DELETE /api/v1/admin/domain_blocks`
- `GET/POST/DELETE /api/v1/admin/email_domain_blocks`
- `GET/POST/PUT/DELETE /api/v1/admin/ip_blocks`
- `GET/POST/DELETE /api/v1/admin/canonical_email_blocks`
- `POST /api/v1/admin/canonical_email_blocks/test`
- `POST /api/v1/admin/dimensions`
- `POST /api/v1/admin/retention`
- `POST /api/v1/admin/measures`
- `GET /api/v1/admin/tags`
- `GET /api/v1/admin/tags/:id`
- `POST /api/v1/admin/trends/tags/:id/approve`
- `POST /api/v1/admin/trends/tags/:id/reject`
- `POST /api/v1/admin/trends/statuses/:id/approve`
- `POST /api/v1/admin/trends/statuses/:id/reject`
- `POST /api/v1/admin/trends/links/:id/approve`
- `POST /api/v1/admin/trends/links/:id/reject`
- `POST /api/v1/admin/trends/links/publishers/:id/approve`
- `POST /api/v1/admin/trends/links/publishers/:id/reject`
- `GET /api/v2/admin/accounts`

Expected auth guard behavior:

- no token -> `403` (`This action is not allowed`)

## Important State Requirements (to avoid false `403`)

Some admin actions are state-dependent by policy, not just token scope:

- `approve` and `reject`: target user must be pending (`approved=false`).
- `unsuspend`: target account must be locally suspended (`suspension_origin=local`).
- `DELETE /admin/accounts/:id`: target must be temporarily suspended (has `deletion_request`).

### Common fixture pitfall

`User` has `before_create :set_approved`, so creating user with `approved: false` may be overwritten.

Use this pattern for pending users:

```ruby
user = User.create!(...)
user.update!(approved: false)
```

Use this pattern for suspend/delete policy-compatible state:

```ruby
account.suspend!(origin: :local, block_email: false)
```

## Endpoint Note

`GET /api/v1/admin/me` is not available in this codebase (returns `404`). Do not rely on it for health checks.
