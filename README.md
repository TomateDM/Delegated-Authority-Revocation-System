# Delegated Authority Revocation System (DARS)

**TL;DR**: Users assign agents on-chain; a designated **Revocation Guardian** can **only revoke** those delegations (never assign), per domain (finance, voting, civic, defence, etc.). This preserves user autonomy with an audited emergency failsafe.

## Why
Typical on-chain delegation lets the user revoke-unless the user’s key is lost/compromised. DARS adds a constrained, auditable **revocation-only** key held by a trusted institution (“Guardian”), solving the “user can’t revoke” failure mode without letting any third party assign agents.

## Design (high level)
- **Ledger-stored state**: `principal -> domain -> agent -> status/limits`. Queryable and auditable. 
- **Separation of powers**:
  - User key: **assign/replace** agent.
  - Guardian key: **revoke** agent (optionally suspend). No capability to assign or act for the user.
- **Multi-domain**: separate guardians per domain (e.g., bank vs election board).
- **(Optional) Permission Packs & autonomy levels** for AI agents (scoped data/actions + expiry; advisory→proactive).

## Contracts
- `AgentRegistry.sol` - core mapping, events, `assignAgent`, `revokeAgent`, `isAuthorized`.
- `PermissionPacks.sol` (optional) - minimal pack registry (hashes + expiry + status).

## Quickstart
```bash
# with Foundry
forge init delegated-authority-revocation-system
cd delegated-authority-revocation-system
# add contracts/ below, then:
forge build
forge test
```

## License
This project is licensed under the [GNU Affero General Public License v3.0](LICENSE).  
© 2025 TomateDM. All rights reserved under this license.
