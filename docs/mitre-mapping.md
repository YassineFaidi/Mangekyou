# 👁️ Mangekyou — MITRE ATT&CK Mapping

## Framework Overview

All Mangekyou detection rules are mapped to the [MITRE ATT&CK Framework](https://attack.mitre.org/) — the industry standard for categorising adversary tactics and techniques.

## Tactic Coverage

| Tactic | ID | Rules |
|---|---|---|
| Credential Access | TA0006 | SSH Brute Force |
| Discovery | TA0007 | Port Scan |
| Privilege Escalation | TA0004 | Privilege Escalation |
| Persistence | TA0003 | New User Created |

## Detailed Rule Mapping

### Rule 1 — SSH Brute Force
| Field | Value |
|---|---|
| **Rule Name** | Mangekyou - SSH Brute Force Detection |
| **MITRE Tactic** | Credential Access (TA0006) |
| **MITRE Technique** | Brute Force (T1110) |
| **MITRE Sub-technique** | Password Guessing (T1110.001) |
| **Severity** | HIGH 🔴 |
| **Trigger** | 5 failed SSH logins within 1 minute |
| **Log Source** | /var/log/auth.log |
| **Detection Logic** | message contains "Failed password" OR "Invalid user" |

### Rule 2 — Port Scan Detection
| Field | Value |
|---|---|
| **Rule Name** | Mangekyou - Port Scan Detection |
| **MITRE Tactic** | Discovery (TA0007) |
| **MITRE Technique** | Network Service Discovery (T1046) |
| **Severity** | MEDIUM 🟠 |
| **Trigger** | 20 connection attempts within 1 minute |
| **Log Source** | /var/log/syslog |
| **Detection Logic** | message contains "Connection refused" OR "connect to" |

### Rule 3 — Privilege Escalation
| Field | Value |
|---|---|
| **Rule Name** | Mangekyou - Privilege Escalation Detection |
| **MITRE Tactic** | Privilege Escalation (TA0004) |
| **MITRE Technique** | Abuse Elevation Control Mechanism (T1548) |
| **Severity** | CRITICAL 🔴 |
| **Trigger** | 3 sudo/su attempts within 5 minutes |
| **Log Source** | /var/log/auth.log |
| **Detection Logic** | message contains "sudo" OR "su root" OR "NOPASSWD" |

### Rule 4 — New User Created
| Field | Value |
|---|---|
| **Rule Name** | Mangekyou - New User Account Created |
| **MITRE Tactic** | Persistence (TA0003) |
| **MITRE Technique** | Create Account (T1136) |
| **Severity** | HIGH 🟠 |
| **Trigger** | Any useradd/adduser event |
| **Log Source** | /var/log/auth.log |
| **Detection Logic** | message contains "new user" OR "useradd" OR "adduser" |

## ATT&CK Navigator Coverage

```
TA0003 Persistence      → T1136  Create Account
TA0004 Priv Escalation  → T1548  Abuse Elevation Control
TA0006 Credential Access→ T1110  Brute Force
                          T1110.001 Password Guessing
TA0007 Discovery        → T1046  Network Service Discovery
```
