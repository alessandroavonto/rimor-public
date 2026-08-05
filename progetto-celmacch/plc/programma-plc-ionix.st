(* ================================================================
   IONIX(R) - Filtro ionizzante a 4 cartucce autopulenti
   Programma PLC - Delta Electronics
   ----------------------------------------------------------------
   Ambiente  : ISPSoft >= 3.x oppure DIADesigner (linguaggio ST)
   CPU       : Delta AS218TX-A (8 DI, 6 DO, 2 AI, 2 AO integrati)
   Espansione: AS04AD-A (4 ingressi analogici 4-20 mA)
   HMI       : Delta DOP-107BV / DOP-107EV (7", Modbus su COM)
   Inverter  : Delta MS300, 5,5 kW (rif. velocita' 0-10 V + RUN a morsetto)
   ----------------------------------------------------------------
   Il programma va inserito in un task ciclico da 100 ms.
   I nomi simbolici vanno dichiarati come variabili globali e
   mappati sui registri D/M indicati (mappa per l'HMI in fondo
   e nel LEGGIMI-plc.md).
   ================================================================ *)


(* ================================================================
   1) VARIABILI GLOBALI
   ================================================================ *)

VAR_GLOBAL
  (* ---- Ingressi digitali (morsettiera CPU) ---- *)
  diConsensoRemoto   AT %X0  : BOOL;   (* marcia da remoto, segnale mantenuto  *)
  diInverterFault    AT %X1  : BOOL;   (* contatto di guasto inverter MS300    *)

  (* ---- Uscite digitali ---- *)
  doInverterRun      AT %Y0  : BOOL;   (* comando RUN inverter                 *)
  doEV1              AT %Y1  : BOOL;   (* impulso elettrovalvola pulizia EV1   *)
  doAnomalia         AT %Y2  : BOOL;   (* contatto anomalia verso l'esterno    *)

  (* ---- Ingressi analogici AS04AD-A: 4-20 mA -> 0..32000 ---- *)
  aiDpCartucce_raw   : INT;            (* CH1: dP cartucce  0..300 mm H2O      *)
  aiDpFlMandata_raw  : INT;            (* CH2: dP flangia calibrata mandata    *)
  aiDpFlRipresa_raw  : INT;            (* CH3: dP flangia calibrata ripresa    *)
  aiPMandata_raw     : INT;            (* CH4: pressione mandata 0..1000 Pa    *)

  (* ---- Uscite analogiche CPU: 0..32000 -> 0-10 V ---- *)
  aoInverterRef_raw  : INT;            (* AO1: riferimento velocita' inverter  *)
  aoValvolaVA_raw    : INT;            (* AO2: comando valvola modulante VA    *)

  (* ---- Comandi da HMI (bit momentanei, mappa: M500..) ---- *)
  cmdStartHMI        : BOOL;           (* M500 - pulsante START a display      *)
  cmdStopHMI         : BOOL;           (* M501 - pulsante STOP a display       *)
  cmdResetAllarmi    : BOOL;           (* M502 - reset allarmi                 *)
  cmdPuliziaManuale  : BOOL;           (* M503 - ciclo di pulizia manuale      *)

  (* ---- Set-point impostabili da HMI (ritentivi, mappa: D500..) ---- *)
  spDpAvvioPulizia   : REAL := 70.0;   (* D500 - mm H2O, soglia avvio pulizia  *)
  spIntervPulizia    : REAL := 10.0;   (* D502 - min, intervallo sopra soglia  *)
  spNumCicliFermo    : INT  := 5;      (* D504 - n. cicli a filtro fermo       *)
  spIntervCicliFermo : REAL := 1.0;    (* D506 - min, intervallo cicli a fermo *)
  spQMandata         : REAL := 1500.0; (* D508 - m3/h, set portata mandata     *)
  spQRipresa         : REAL := 2500.0; (* D510 - m3/h, set portata ripresa     *)

  (* ---- Parametri di taratura (ritentivi, mappa: D530..) ---- *)
  cfgDpCartucceFS    : REAL := 300.0;  (* fondo scala trasmettitore dP cart.   *)
  cfgPMandataFS      : REAL := 1000.0; (* fondo scala trasmettitore P mandata  *)
  cfgQNomMandata     : REAL := 1500.0; (* portata alla dP nominale, flangia M  *)
  cfgDpNomMandata    : REAL := 150.0;  (* dP nominale flangia mandata, mm H2O  *)
  cfgQNomRipresa     : REAL := 2500.0; (* portata alla dP nominale, flangia R  *)
  cfgDpNomRipresa    : REAL := 150.0;  (* dP nominale flangia ripresa, mm H2O  *)
  cfgDpFlangiaFS     : REAL := 300.0;  (* fondo scala trasmettitori flange     *)
  cfgTImpulsoEV      : TIME := T#400MS;(* durata impulso EV1                   *)
  cfgDpAllarme       : REAL := 150.0;  (* mm H2O, allarme cartucce intasate    *)
  cfgKpMandata       : REAL := 0.08;   (* PID mandata: guadagno %/(m3/h)       *)
  cfgTiMandata       : REAL := 8.0;    (* PID mandata: tempo integrale, s      *)
  cfgKpRipresa       : REAL := 0.06;   (* PID ripresa: guadagno                *)
  cfgTiRipresa       : REAL := 6.0;    (* PID ripresa: tempo integrale, s      *)
  cfgVelMinima       : REAL := 20.0;   (* % velocita' minima inverter          *)

  (* ---- Misure per HMI (sola lettura, mappa: D560..) ---- *)
  mDpCartucce        : REAL;           (* D560 - mm H2O                        *)
  mQMandata          : REAL;           (* D562 - m3/h                          *)
  mQRipresa          : REAL;           (* D564 - m3/h                          *)
  mPMandata          : REAL;           (* D566 - Pa                            *)
  mVelInverter       : REAL;           (* D568 - % velocita' attuale           *)
  mAperturaVA        : REAL;           (* D570 - % apertura valvola            *)

  (* ---- Stati per HMI (mappa: M520.. / D580) ---- *)
  stRun              : BOOL;           (* M520 - impianto in marcia            *)
  stPuliziaInCorso   : BOOL;           (* M521 - impulso/ciclo pulizia attivo  *)
  stCicliFermo       : BOOL;           (* M522 - pulizia di fine ciclo in corso*)
  stAllarme          : BOOL;           (* M523 - allarme cumulativo            *)
  stCntCicliFermo    : INT;            (* D580 - cicli a fermo rimanenti       *)

  (* ---- Allarmi singoli (mappa: M530..) ---- *)
  alrInverter        : BOOL;           (* M530 *)
  alrCartucce        : BOOL;           (* M531 - dP oltre soglia di allarme    *)
  alrQMandata        : BOOL;           (* M532 - portata mandata non raggiunta *)
  alrQRipresa        : BOOL;           (* M533 - portata ripresa non raggiunta *)

  (* ---- Interne ---- *)
  wStepPulizia       : INT;            (* 0 riposo, 1 impulso, 2 attesa        *)
  wLocaleLatch       : BOOL;           (* marcia da comando locale             *)
  wDpAlto            : BOOL;
  wDpAltoOld         : BOOL;
  wRunOld            : BOOL;
  wIntegMandata      : REAL;           (* integratore PID mandata              *)
  wIntegRipresa      : REAL;           (* integratore PID ripresa              *)
  tImpulso           : TON;
  tIntervallo        : TON;
  tIntervalloFermo   : TON;
  tQMandataKo        : TON;
  tQRipresaKo        : TON;
END_VAR


(* ================================================================
   2) PROGRAMMA PRINCIPALE  (task ciclico 100 ms)
   ================================================================ *)

(* ---------- 2.1 Acquisizione e scalatura misure ---------------- *)
(* 4-20 mA -> 0..32000 (impostare cosi' i canali AS04AD in HWCONFIG) *)

mDpCartucce := INT_TO_REAL(aiDpCartucce_raw) / 32000.0 * cfgDpCartucceFS;
mPMandata   := INT_TO_REAL(aiPMandata_raw)   / 32000.0 * cfgPMandataFS;

(* Portata da flangia calibrata:  Q = Qnom * SQRT(dP / dPnom)      *)
mQMandata := cfgQNomMandata * SQRT(
               MAX(0.0, INT_TO_REAL(aiDpFlMandata_raw) / 32000.0 * cfgDpFlangiaFS)
               / cfgDpNomMandata);
mQRipresa := cfgQNomRipresa * SQRT(
               MAX(0.0, INT_TO_REAL(aiDpFlRipresa_raw) / 32000.0 * cfgDpFlangiaFS)
               / cfgDpNomRipresa);

(* ---------- 2.2 Marcia / arresto ------------------------------- *)
(* START/STOP locale a ritenuta; il consenso remoto e' un segnale
   mantenuto in parallelo al comando locale.                       *)

IF cmdStartHMI THEN
  wLocaleLatch := TRUE;
  cmdStartHMI  := FALSE;
END_IF;
IF cmdStopHMI THEN
  wLocaleLatch := FALSE;
  cmdStopHMI   := FALSE;
END_IF;

stRun := (wLocaleLatch OR diConsensoRemoto) AND NOT alrInverter;

(* Fronte di discesa della marcia -> avvia cicli di pulizia a fermo *)
IF wRunOld AND NOT stRun THEN
  stCicliFermo    := TRUE;
  stCntCicliFermo := spNumCicliFermo;
END_IF;
IF stRun THEN
  stCicliFermo := FALSE;               (* un riavvio annulla i cicli a fermo *)
END_IF;
wRunOld := stRun;

doInverterRun := stRun;

(* ---------- 2.3 Regolazione portata di MANDATA (inverter) ------ *)
(* PI posizionale con anti-windup. Uscita in % velocita'.          *)

IF stRun THEN
  wIntegMandata := LIMIT(0.0,
       wIntegMandata + (spQMandata - mQMandata) * cfgKpMandata / cfgTiMandata * 0.1,
       100.0);
  mVelInverter := LIMIT(cfgVelMinima,
       (spQMandata - mQMandata) * cfgKpMandata + wIntegMandata,
       100.0);
ELSE
  wIntegMandata := 0.0;
  mVelInverter  := 0.0;
END_IF;
aoInverterRef_raw := REAL_TO_INT(mVelInverter / 100.0 * 32000.0);

(* ---------- 2.4 Regolazione portata di RIPRESA (valvola VA) ---- *)
(* La valvola apre per scaricare l'eccesso: piu' apertura =
   piu' aria aspirata rispetto alla mandata.                       *)

IF stRun THEN
  wIntegRipresa := LIMIT(0.0,
       wIntegRipresa + (spQRipresa - mQRipresa) * cfgKpRipresa / cfgTiRipresa * 0.1,
       100.0);
  mAperturaVA := LIMIT(0.0,
       (spQRipresa - mQRipresa) * cfgKpRipresa + wIntegRipresa,
       100.0);
ELSE
  wIntegRipresa := 0.0;
  mAperturaVA   := 0.0;                (* valvola chiusa a impianto fermo *)
END_IF;
aoValvolaVA_raw := REAL_TO_INT(mAperturaVA / 100.0 * 32000.0);

(* ---------- 2.5 Pulizia cartucce ------------------------------- *)
(* Un impulso su EV1 scarica il serbatoio 1; i serbatoi 2-3-4
   partono in cascata pneumatica, senza altri comandi elettrici.
   - In marcia : dP >= soglia -> impulso subito, poi ogni
                 spIntervPulizia minuti finche' resta sopra soglia.
   - A fermo   : spNumCicliFermo impulsi ogni spIntervCicliFermo
                 minuti (ricarica serbatoi ~1 min).
   - Manuale   : cmdPuliziaManuale esegue un singolo impulso.      *)

wDpAlto := stRun AND (mDpCartucce >= spDpAvvioPulizia);

tIntervallo(IN := wDpAlto AND (wStepPulizia = 0),
            PT := REAL_TO_TIME(spIntervPulizia * 60000.0));
tIntervalloFermo(IN := stCicliFermo AND (wStepPulizia = 0),
            PT := REAL_TO_TIME(spIntervCicliFermo * 60000.0));

CASE wStepPulizia OF
  0: (* --- riposo: valuta le condizioni di avvio impulso --- *)
     IF (wDpAlto AND NOT wDpAltoOld)                    (* superamento soglia *)
        OR tIntervallo.Q                                (* ripetizione ciclica *)
        OR (stCicliFermo AND tIntervalloFermo.Q)        (* cicli a fermo      *)
        OR cmdPuliziaManuale THEN
       cmdPuliziaManuale := FALSE;
       doEV1        := TRUE;
       wStepPulizia := 1;
     END_IF;

  1: (* --- impulso EV1 --- *)
     tImpulso(IN := TRUE, PT := cfgTImpulsoEV);
     IF tImpulso.Q THEN
       doEV1 := FALSE;
       tImpulso(IN := FALSE);
       IF stCicliFermo THEN
         stCntCicliFermo := stCntCicliFermo - 1;
         IF stCntCicliFermo <= 0 THEN
           stCicliFermo := FALSE;
         END_IF;
       END_IF;
       wStepPulizia := 0;
     END_IF;
END_CASE;

wDpAltoOld       := wDpAlto;
stPuliziaInCorso := (wStepPulizia <> 0) OR stCicliFermo;

(* ---------- 2.6 Allarmi ---------------------------------------- *)

alrInverter := diInverterFault;

alrCartucce := mDpCartucce >= cfgDpAllarme;   (* cartucce da sostituire *)

(* portata non raggiunta per 60 s con regolatore a fondo corsa *)
tQMandataKo(IN := stRun AND (mVelInverter >= 99.0)
                 AND (mQMandata < spQMandata * 0.9), PT := T#60S);
alrQMandata := tQMandataKo.Q;

tQRipresaKo(IN := stRun AND (mAperturaVA >= 99.0)
                 AND (mQRipresa < spQRipresa * 0.9), PT := T#60S);
alrQRipresa := tQRipresaKo.Q;

IF cmdResetAllarmi THEN
  cmdResetAllarmi := FALSE;
  (* gli allarmi ricalcolano da soli; il reset serve per l'inverter
     dopo il ripristino del contatto di guasto *)
END_IF;

stAllarme  := alrInverter OR alrCartucce OR alrQMandata OR alrQRipresa;
doAnomalia := stAllarme;              (* contatto di anomalia verso l'esterno *)


(* ================================================================
   3) MAPPA REGISTRI PER HMI DOP-107 (Modbus / driver Delta AS)
   ----------------------------------------------------------------
   Comandi (bit momentanei):
     M500 cmdStartHMI      M501 cmdStopHMI
     M502 cmdResetAllarmi  M503 cmdPuliziaManuale
   Stati:
     M520 stRun            M521 stPuliziaInCorso
     M522 stCicliFermo     M523 stAllarme
     M530..M533 allarmi singoli
   Set-point (REAL = 2 word consecutive):
     D500 spDpAvvioPulizia   D502 spIntervPulizia
     D504 spNumCicliFermo(INT) D506 spIntervCicliFermo
     D508 spQMandata         D510 spQRipresa
   Misure:
     D560 mDpCartucce  D562 mQMandata  D564 mQRipresa
     D566 mPMandata    D568 mVelInverter  D570 mAperturaVA
     D580 stCntCicliFermo (INT)
   ================================================================ *)
