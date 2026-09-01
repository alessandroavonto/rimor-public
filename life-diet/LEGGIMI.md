# Life Diet

**La dieta che si adatta alla tua vita, non il contrario.**

Le diete falliscono perché pretendono di governare la settimana: non prevedono il cliente
che ti invita a cena, l'hotel che ha solo lo yogurt intero, la pizza coi colleghi.
Life Diet parte dal presupposto opposto: la vita succede, e il piano si riscrive di conseguenza.

Prototipo funzionante, in italiano, pensato per il telefono. Un file HTML, nessun account,
nessun server: i dati restano sul dispositivo.

---

## Installarla su Android

L'app è una **PWA**: si installa dalla schermata home come una normale app e funziona offline.

1. Pubblica la cartella `life-diet/` su un indirizzo **https** (GitHub Pages va benissimo:
   Impostazioni del repository → Pages → sorgente il branch, cartella `/`).
2. Apri `https://<tuo-sito>/life-diet/` con **Chrome su Android**.
3. Menu ⋮ → **Installa app** (o *Aggiungi a schermata Home*).

Da quel momento parte a tutto schermo, senza barra del browser, e funziona anche senza rete:
il service worker tiene una copia locale.

**Per provarla subito**, senza pubblicare niente: apri `index.html` con un browser, anche da file.
Funziona tutto tranne l'installazione e la lettura automatica delle foto.

---

## Come ragiona

### Il budget di oggi non è un numero fisso

```
budget = obiettivo giornaliero + movimento in più − quota di rientro
```

* **obiettivo giornaliero**: Mifflin-St Jeor per il metabolismo basale, moltiplicato per il tuo
  livello di attività, meno il deficit necessario all'obiettivo. Il deficit è limitato a
  0,75 % del peso corporeo a settimana: se chiedi di dimagrire troppo in fretta, l'app te lo dice
  e allunga i tempi invece di affamarti.
* **movimento in più**: l'attività *programmata* per oggi, contata al 70 % (il resto è già dentro
  il tuo livello di attività abituale). Se poi cammini mezz'ora invece di un'ora, la differenza
  torna in banca.
* **quota di rientro**: vedi sotto.

Sotto le 1500 kcal (uomo) o 1200 (donna) il motore non scende mai, qualunque sia il debito.

### La banca settimanale

Ogni giorno registrato produce uno scarto rispetto al proprio budget. Gli scarti degli ultimi
7 giorni formano un **saldo**: un giorno sopra non è un fallimento, è un debito.
Il saldo si restituisce nell'arco di 1, 3 o 7 giorni — lo scegli tu nel profilo.

Il semaforo traduce il saldo in una parola sola:

| Saldo sulla settimana | Stato | Cosa cambia |
|---|---|---|
| entro ±3 % | **In linea** | proposte normali |
| oltre +3 % | **Recupero leggero** | porzioni un po' più contenute |
| oltre +9 % | **Giornata di rientro** | il motore preferisce i piatti compensativi: molto volume, poche calorie, proteine alte |
| sotto −9 % | **Stai mangiando poco** | ti spinge a mangiare il budget pieno: la fame è la prima causa di abbandono |

### Le calorie vanno dove sta la vita

I pasti non hanno grammature fisse. Il budget residuo si ridistribuisce sui pasti **ancora da fare**,
ogni volta che registri qualcosa. Se metti in agenda una cena di lavoro, quel pasto si prenota
la sua fetta **prima** che accada: colazione e pranzo si alleggeriscono da soli.

Ogni proposta ha un minimo e un massimo per ingrediente: il motore la scala sul budget del momento
e sceglie fra le candidate quella che centra meglio proteine e calorie, evitando quello che hai
già mangiato negli ultimi tre giorni.

### Aderenza parziale

Per ogni pasto proposto ci sono quattro risposte, e nessuna è un errore:

* **Mangio questo** — aderenza piena
* **Un'altra** — altra proposta a pari budget
* **Ho mangiato altro** — registri quello che hai mangiato davvero (variante), e il resto della
  giornata si ricalcola
* **Salto** — le calorie tornano agli altri pasti

### Quanto pesa quello che hai nel piatto

A casa pesi. Fuori no. Quindi:

* **la bilancia visiva** — quattro piatti piani da 27 cm disegnati con dentro quattro quantità
  diverse: mezza porzione, standard, abbondante, ristorante. Guardi quale somiglia a quello che hai
  davanti e lo tocchi: i grammi finiscono nel campo. Le aree non sono disegnate a occhio, sono
  calcolate (un mucchio di pasta cotta pesa circa 0,55 g/cm³ e sta alto 2 cm; una fetta di carne
  1,05 g/cm³ e 1,5 cm), e si apre da sola per pasta, riso, piatti, carne e pesce;
* **porzioni tipiche** per categoria (piccola / media / abbondante) e per pezzo;
* **riferimenti con le mani** — il palmo è 100–120 g di carne, il pugno chiuso 150–200 g
  di pasta cotta, il pollice 10 g di olio;
* **foto del piatto**: dove l'app gira dentro Claude, la foto viene letta davvero e restituisce
  i componenti con i grammi stimati, che finiscono nel diario con un tocco.
  La foto non viene salvata da nessuna parte.

### I valori del sangue

Inserisci il referto e diventa il punto di partenza. Da lì l'app stima **la tendenza** dei valori
sulla base di come hai mangiato (grassi saturi, fibra, zuccheri, alcol, sodio) e di quanto ti sei
mosso, più la variazione di peso.

È una stima di direzione, con un margine di incertezza dichiarato e un'attendibilità che cresce
con i giorni registrati. **Non è un referto e non sostituisce il medico**: serve a sapere se la
rotta è quella giusta prima del prossimo prelievo.

### Il corpo, non solo la bilancia

Peso con media mobile a 7 giorni (la bilancia da sola è rumore), circonferenze e stima della massa
grassa con il metodo U.S. Navy. Si può calare di grasso restando allo stesso peso: senza le misure
non te ne accorgi.

---

## I dati

Tutto in `localStorage`, sul dispositivo. Nessun account, nessuna trasmissione.
Backup ed esportazione in JSON dal profilo — se cancelli i dati del browser, senza backup i dati
se ne vanno con loro.

## I numeri degli alimenti

Circa 130 alimenti italiani con valori per 100 g presi dalle tabelle di composizione di uso comune
(CREA, USDA), arrotondati. Sono riferimenti, non pesate di laboratorio: due mele non hanno le
stesse calorie.

## Avvertenza

Life Diet è uno strumento di auto-osservazione, non un dispositivo medico. Non formula diagnosi
né terapie. Per patologie, farmaci, gravidanza o diete sotto le 1200 kcal, parlane con il tuo medico.

## File

| File | Cosa è |
|---|---|
| `index.html` | L'applicazione completa: interfaccia, motore, database alimenti |
| `manifest.webmanifest` | Identità dell'app installata su Android |
| `sw.js` | Service worker: fa funzionare l'app senza rete |
| `icone/` | Icone per la schermata home |
| `CONCEPT.md` | La visione e cosa serve per portarla sugli store |
