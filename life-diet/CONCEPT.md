# Life Diet — il concept

## Il problema, detto bene

Le diete non falliscono per mancanza di volontà. Falliscono perché sono **piani rigidi applicati a
vite flessibili**. Ti danno la settimana scritta e presumono che tu la possa governare: che nessun
cliente ti inviti a cena, che l'hotel abbia lo yogurt magro, che la pizza del venerdì non esista.

Alla prima deviazione succede sempre la stessa cosa: il piano è rotto, non c'è modo di ripararlo,
e chi lo segue smette. Non perché ha mangiato il fritto misto, ma perché **dopo il fritto misto
la dieta non gli dice più niente**.

## L'idea

Un'app che non impone una settimana, ma **reagisce**. Tre verbi, in quest'ordine:

1. **Registra** — cosa mangi, quanto ti muovi, cosa hai in programma, come stanno i tuoi valori.
2. **Propone** — il passo successivo, adesso, tarato su quello che è appena successo.
3. **Compensa** — quello che è già successo non si cancella: si distribuisce.

Il salto concettuale è qui: **la giornata non è l'unità di misura**. Il conto si chiude sulla
settimana, come un conto corrente. Una cena di lavoro è un prelievo, non un fallimento.

## Come è fatto il motore

### La banca settimanale
Ogni giorno genera uno scarto rispetto al proprio budget. Sette giorni di scarti fanno un saldo.
Il saldo si restituisce nell'arco di giorni che scegli tu, con un tetto per giorno e un pavimento
calorico invalicabile. Da qui nasce il semaforo: verde, giallo, rosso — una parola sola al mattino,
che è tutto quello che serve sapere.

### La pre-compensazione
La compensazione dopo il fatto è metà del lavoro. L'altra metà è **prima**: se sai che stasera c'è
una cena, l'app sposta le calorie su quel pasto e alleggerisce colazione e pranzo, così arrivi al
ristorante con margine invece che con i sensi di colpa.

### L'aderenza parziale
Una proposta ha quattro risposte possibili — piena, variante, altra, saltata — e **nessuna di
queste è un errore**. Il registro non è una pagella: è l'ingresso dati del motore. Ogni risposta
ricalcola immediatamente il resto della giornata.

### Programmato contro fatto
Il movimento si dichiara prima e si consuntiva dopo. Un'ora di camminata programmata alza il budget
di oggi; mezz'ora fatta davvero significa che la differenza torna in banca e la ritrovi domani.
È la stessa disciplina di un cantiere: preventivo e consuntivo.

### Dalla bilancia ai valori
Il peso è un indicatore lento e rumoroso. Le leve vere sono altre: grassi saturi, fibra, zuccheri,
alcol, sodio, pesce grasso, movimento. L'app le misura ogni giorno e le lega al referto del sangue,
per rispondere a una domanda che nessun contacalorie pone: *quello che sto facendo sta funzionando
su quello che conta?*

---

## Cosa c'è nel prototipo

Tutto quanto sopra, funzionante, in un file HTML installabile su Android: motore adattivo, banca
settimanale, semaforo, agenda con pre-compensazione, aderenza parziale, ~130 alimenti italiani,
stima delle porzioni, peso con media mobile, circonferenze e massa grassa, referti del sangue con
proiezione di tendenza, backup dei dati.

## Cosa serve per farla diventare un prodotto

In ordine di valore, non di difficoltà.

**1. La foto del piatto, dovunque.**
Nel prototipo la lettura della foto funziona dove l'app gira dentro Claude. Per averla in un'app
pubblicata serve un piccolo backend che inoltri l'immagine a un modello con visione e restituisca
componenti e grammi. È la funzione che elimina l'attrito più grande — nessuno pesa il cibo al
ristorante — e va misurata sul serio: una raccolta di foto di piatti pesati davvero, per sapere
quanto sbaglia prima di fidarsene.

**2. Referti dal PDF.**
Oggi i valori si digitano. Un OCR sul referto del laboratorio toglie l'unico passaggio noioso
dell'onboarding, e i referti sono quasi tutti PDF strutturati in modo simile.

**3. Il movimento senza dichiararlo.**
Google Fit e Health Connect su Android, HealthKit su iPhone: passi, allenamenti e frequenza
cardiaca arrivano da soli. Sparisce metà della registrazione manuale, e il consuntivo diventa
automatico.

**4. Le notifiche al momento giusto.**
Un'app di questo tipo vive di tempismo: la proposta di colazione quando ti svegli, il promemoria
prima della cena in agenda, il bilancio la sera. Serve un service worker con notifiche push e —
questa è la parte delicata — una soglia bassissima di fastidio.

**5. Sincronizzazione e backup.**
Oggi i dati stanno solo sul telefono: è la scelta giusta per la privacy, è fragile per l'utente.
Un account opzionale con cifratura lato client dà il backup senza rinunciare al principio.

**6. La proiezione dei valori, validata.**
Il modello attuale usa relazioni note fra dieta, peso e valori ematici, con incertezze larghe e
dichiarate. Per andare oltre la stima di tendenza servirebbe un confronto sistematico fra proiezioni
e prelievi reali, e la revisione di un medico. Finché non c'è, la funzione deve restare quello che
è: una bussola, non un referto.

## I paletti

**Non è un dispositivo medico.** Nel momento in cui l'app dicesse "il tuo LDL sarà 142" come
affermazione clinica, cambierebbe categoria e con essa gli obblighi normativi. La formulazione
corretta — tendenza, incertezza, attendibilità — non è prudenza formale: è ciò che tiene l'app
dalla parte giusta della linea.

**Dati sanitari, quindi GDPR.** Peso, referti e abitudini alimentari sono categorie particolari
(art. 9). Un backend impone base giuridica, informativa, cifratura, cancellazione e minimizzazione.
Tenere tutto sul dispositivo, come fa il prototipo, è anche la scelta più semplice da difendere.

**Il disturbo alimentare è un rischio reale.** Un'app che conta e compensa può alimentare
comportamenti ossessivi. I pavimenti calorici, il messaggio quando mangi troppo poco e l'assenza
di qualunque tono colpevolizzante non sono gentilezze: sono presidi di sicurezza, e vanno tenuti
anche quando qualcuno chiederà di toglierli.

## Perché potrebbe funzionare

Il mercato è pieno di contacalorie. Sono tutti registri passivi: tu scrivi, loro sommano.
Life Diet fa la cosa che nessuno di loro fa — **prende una decisione al posto tuo, dopo che la vita
ha già deciso**. Il valore non è nel database degli alimenti, che ce l'hanno tutti: è nel motore
che, la mattina dopo il fritto misto, ti dice esattamente cosa fare oggi.
