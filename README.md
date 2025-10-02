# ESF Framework v1.0 - Immersive Emergency Services Sim for FiveM

Pure simulation: Players/AI as cops/fire/EMS, PED citizens only. No RP/PvP—procedural calls, dynamic world.

## Features
- **Dispatch/MDT**: AI dispatching, NUI tablet with queries/radio.
- **Callouts**: 25 base (expandable JSON/Lua), variants, objectives.
- **Roles**: Police pursuits, EMS vitals, Fire spread sim.
- **AI**: Responder backups, PED reactions/crowds.
- **Sim Elements**: Weather/time impacts, fatigue, progression, escalation.

## Setup
1. Download & extract to resources/esf_framework.
2. Add to server.cfg: `ensure PolyZone`, `ensure mumble-voip`, `ensure esf_framework`.
3. Restart server. Join as ES unit (admin menu or script).
4. F10 for MDT; /deploySpike for police tools.

## Modding
- Add callouts: Drop JSON/Lua in /callouts/custom/.
- Config: Edit server/config.lua for density, rates.

## Testing
- /esf_test_callout [code] (e.g., "10-50") to spawn.
- Check console for errors.

## License
MIT - Free to mod/share.

Questions? Open issue or DM.
