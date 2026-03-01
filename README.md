# Windows Server Hardening: Active Defense Engagement (RvB)

**Date:** 2026-02-28  
**Role:** Blue Team Lead / Security Analyst

## Mission Objective
Defend a dual-server Windows environment—**City Wok Domain Controller (DC)** and **City Sushi File Server (FS)**—against active Red Team activity while maintaining **100% uptime** for scored services (**WordPress** and **FTP**).

## Core Achievements
- **Identity lockdown:** Identified and disabled a rogue domain account (`butter`) and secured the built-in `Guest` account across the environment.
- **Network fortress:** Implemented a **default-deny** host firewall posture and explicitly allowed only required **Active Directory** and **web ports (80/443)** to reduce lateral movement risk.
- **Resilience / break-glass access:** Created a controlled “break-glass” admin account (`wsappx_svc`) to preserve recovery access if primary admin credentials were locked out.
- **Operational security:** Cleared **PowerShell PSReadLine** history to reduce the risk of exposing defensive actions, paths, and recovery artifacts to an attacker.

## Threat Hunting Highlights
- **Persistence audit:** Reviewed scheduled tasks (including `CreateExplorerShellUnelevatedTask`) and validated legitimacy against expected Windows behavior.
- **Live traffic analysis:** Used **TCPView** to distinguish normal **LDAP/AD** communications from suspicious outbound connections potentially indicative of C2.

## Repository Contents
- **`/Scripts`** — PowerShell hardening and audit scripts used during the engagement.
- **`/Documentation`** — After-Action Report (AAR), findings, timeline, and remediation notes.
- **`/Media`** — Screenshots and screen recordings supporting findings and actions.

## Notes / Scope
This repository documents a controlled defensive engagement for educational purposes. Credentials, internal IPs, and sensitive artifacts are intentionally excluded/redacted.
