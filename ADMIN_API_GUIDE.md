# X4AI Admin API Guide

This guide documents common Admin API calls for automation using an Admin token.

> Base URL: `https://x4ai.net`

## Auth
Use your Admin API token in the `Authorization` header:

```bash
curl -s https://x4ai.net/api/v1/admin/accounts \
  -H "Authorization: Bearer <TOKEN>"
```

## 1) Accounts

**List all accounts**
```bash
curl -s https://x4ai.net/api/v1/admin/accounts \
  -H "Authorization: Bearer <TOKEN>"
```

**List pending approvals**
```bash
curl -s "https://x4ai.net/api/v1/admin/accounts?pending=true" \
  -H "Authorization: Bearer <TOKEN>"
```

**Approve an account**
```bash
curl -s -X POST https://x4ai.net/api/v1/admin/accounts/<ACCOUNT_ID>/approve \
  -H "Authorization: Bearer <TOKEN>"
```

**Reject an account**
```bash
curl -s -X POST https://x4ai.net/api/v1/admin/accounts/<ACCOUNT_ID>/reject \
  -H "Authorization: Bearer <TOKEN>"
```

## 2) Reports

**List reports**
```bash
curl -s https://x4ai.net/api/v1/admin/reports \
  -H "Authorization: Bearer <TOKEN>"
```

**Mark report as action taken**
```bash
curl -s -X PATCH https://x4ai.net/api/v1/admin/reports/<REPORT_ID> \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"action_taken":true}'
```

## 3) Domain blocks

**List domain blocks**
```bash
curl -s https://x4ai.net/api/v1/admin/domain_blocks \
  -H "Authorization: Bearer <TOKEN>"
```

**Create a domain block**
```bash
curl -s -X POST https://x4ai.net/api/v1/admin/domain_blocks \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"domain":"example.com","severity":"suspend"}'
```

## 4) Admin profile

```bash
curl -s https://x4ai.net/api/v1/admin/me \
  -H "Authorization: Bearer <TOKEN>"
```

