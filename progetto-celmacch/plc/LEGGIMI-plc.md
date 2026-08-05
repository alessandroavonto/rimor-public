# Programma PLC — Filtro IONIX (Delta Electronics)

Software di controllo del filtro ionizzante a 4 cartucce autopulenti, coerente con lo
schema di funzionamento in `../schema-funzionamento-filtro-ionix.pdf`.

| File | Cosa è |
|---|---|
| `programma-plc-ionix.st` | Programma completo in Structured Text (IEC 61131-3) per ISPSoft / DIADesigner |
| `LEGGIMI-plc.md` | Questo documento: hardware, I/O, mappa HMI, note di messa in servizio |

## Hardware di riferimento (tutto Delta)

| Componente | Modello | Note |
|---|---|---|
| CPU PLC | **AS218TX-A** | 8 DI, 6 DO, 2 AI, 2 AO integrati, Ethernet + RS485 |
| Modulo analogico | **AS04AD-A** | 4 ingressi 4–20 mA (i 4 trasmettitori di pressione) |
| Display | **DOP-107BV** (7") | Collegato in RS485/Ethernet al PLC |
| Inverter | **MS300**, 5,5 kW | Riferimento 0–10 V + RUN a morsetto, contatto di guasto verso il PLC |

Se si preferisce un'altra CPU (es. DVP-SE + DVP04AD) il programma resta identico:
cambia solo la mappatura hardware dei canali analogici.

## Lista I/O

### Digitali (morsettiera CPU)

| Ind. | Segnale | Direzione | Descrizione |
|---|---|---|---|
| X0 | `diConsensoRemoto` | IN | Marcia da remoto (segnale mantenuto, in parallelo allo start locale) |
| X1 | `diInverterFault` | IN | Contatto di guasto dell'inverter MS300 |
| Y0 | `doInverterRun` | OUT | Comando RUN inverter |
| Y1 | `doEV1` | OUT | Impulso elettrovalvola pulizia (serbatoio 1 → cascata pneumatica 2-3-4) |
| Y2 | `doAnomalia` | OUT | Contatto di anomalia cumulativa verso l'esterno |

### Analogici

| Canale | Segnale | Trasmettitore | Scala |
|---|---|---|---|
| AS04AD CH1 | `aiDpCartucce_raw` | ΔP cartucce | 4–20 mA = 0–300 mm H₂O |
| AS04AD CH2 | `aiDpFlMandata_raw` | ΔP flangia calibrata mandata | 4–20 mA = 0–300 mm H₂O |
| AS04AD CH3 | `aiDpFlRipresa_raw` | ΔP flangia calibrata ripresa | 4–20 mA = 0–300 mm H₂O |
| AS04AD CH4 | `aiPMandata_raw` | Pressione mandata | 4–20 mA = 0–1000 Pa |
| CPU AO1 | `aoInverterRef_raw` | → riferimento velocità MS300 | 0–10 V = 0–100 % |
| CPU AO2 | `aoValvolaVA_raw` | → attuatore valvola modulante VA | 0–10 V = 0–100 % |

In HWCONFIG impostare i canali AS04AD su **4–20 mA → 0..32000** (la scalatura
in unità ingegneristiche la fa il programma con i parametri `cfg*`).

## Logica implementata

1. **Marcia/arresto** — start/stop locale a ritenuta da HMI + consenso remoto mantenuto in parallelo; il guasto inverter blocca la marcia.
2. **Portata di mandata costante** — PI sull'inverter: la portata è ricavata dalla flangia calibrata con la legge Q = Qnom·√(ΔP/ΔPnom); l'inverter accelera man mano che le cartucce si intasano.
3. **Portata di ripresa regolabile** — PI sulla valvola VA che scarica l'eccesso d'aria: la ripresa può superare la mandata (es. 1500/2500 m³/h).
4. **Pulizia cartucce** — al superamento della soglia ΔP: impulso immediato su EV1, poi ripetizione all'intervallo impostato finché resta sopra soglia; allo stop dell'impianto N cicli a filtro fermo (default 5, ogni 1 min); pulsante di pulizia manuale.
5. **Allarmi** — guasto inverter, cartucce intasate (ΔP ≥ soglia allarme), portata mandata/ripresa non raggiunta con regolatore a fondo corsa per 60 s. Cumulativa sul contatto Y2.

## Pagine HMI consigliate (DOP-107, DOPSoft)

1. **Sinottico** — replica dello schema del foglio CELMACCH: cartucce, serbatoi, ventilatore, lama, con ΔP (D560), Q mandata (D562), Q ripresa (D564), P mandata (D566), % inverter (D568), % valvola (D570); pulsanti START (M500) / STOP (M501), spie marcia (M520), pulizia (M521), allarme (M523).
2. **Set-point** — ΔP avvio pulizia (D500), intervallo pulizia (D502), cicli a fermo (D504), intervallo cicli (D506), set Q mandata (D508), set Q ripresa (D510).
3. **Allarmi** — M530–M533 con storico, reset (M502).
4. **Servizio** (protetta da password) — parametri di taratura `cfg*` (D530..), pulizia manuale (M503).

I REAL occupano 2 word consecutive (formato float 32 bit, word swap secondo driver Delta AS in DOPSoft).

## Parametri principali inverter MS300 (indicativi)

- Sorgente comando RUN: morsetti (parametro 00-21 = 1)
- Sorgente frequenza: ingresso analogico AVI 0–10 V (00-20 = 2)
- Frequenza max 50 Hz, rampe acc/dec ≈ 15 s, curva V/F per ventilatore quadratica
- Relè di guasto cablato su X1 del PLC

## Messa in servizio

1. Verificare scala e zero dei 4 trasmettitori di pressione (canali AS04AD a 0..32000).
2. Inserire i dati reali di taratura delle flange (`cfgQNom*` / `cfgDpNom*`) dai dati costruttivi.
3. Tarare i PI (`cfgKp*`, `cfgTi*`) partendo dai valori di default: prima l'anello di mandata, poi quello di ripresa.
4. Verificare la durata dell'impulso EV1 (`cfgTImpulsoEV`, default 400 ms) sufficiente a far partire la cascata pneumatica.
5. Collaudare la sequenza a fermo impianto: stop → 5 impulsi distanziati 1 min.

> **Nota** — il codice è scritto e commentato ma non è stato compilato su hardware
> reale: alla prima importazione in ISPSoft/DIADesigner verificare la sintassi dei
> tipi TON/REAL_TO_TIME della versione in uso e simulare prima del collaudo.
