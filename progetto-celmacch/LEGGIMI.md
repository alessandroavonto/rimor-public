# Progetto CELMACCH — Filtro IONIX

Schema di funzionamento del filtro ionizzante a 4 cartucce autopulenti con lama soffiante ionizzante.
Foglio unico A4 orizzontale, pensato per essere inoltrato a CELMACCH e riutilizzato nella brochure.

| File | Cosa è | Uso |
|---|---|---|
| `schema-funzionamento-filtro-ionix.pdf` | Foglio unico definitivo (A4 orizzontale) | Da inoltrare a CELMACCH / brochure |
| `schema-funzionamento-filtro-ionix.html` | Sorgente grafico della pagina | Riferimento / modifiche |
| `preview.png` | Anteprima rapida della pagina | Controllo visivo |
| `logo-avonto.png` | Logo per l'intestazione | — |

## Contenuto del foglio

- **Display HMI touch 7″ al centro** con il sinottico d'impianto: 4 cartucce, 4 serbatoi (S1–S4) con elettrovalvola EV1 e cascata pneumatica, ingresso aria compressa, pressostato differenziale ΔP, ventilatore 5,5 kW (B5) con inverter, valvola automatica di sfioro VA, flange calibrate FT1/FT2 su mandata e ripresa DN200, trasmettitore di pressione PT, lama ionizzante L 2100 mm.
- **Barra parametri impostabili**: ΔP avvio pulizia (70 mm H₂O), intervallo pulizia (10 min), cicli a filtro fermo (5), intervallo cicli (1 min), set portata mandata (1500 m³/h), set portata ripresa (2500 m³/h), START/STOP locale.
- **6 blocchi funzionali** attorno al display: filtrazione, pulizia in cascata, quadro elettrico, controllo portata mandata (inverter), controllo portata ripresa (valvola VA), lama ionizzante.
- **Fascia "risparmio energetico by design"** in chiusura.

## Come rigenerare il PDF dopo una modifica al sorgente

```bash
chromium --headless --no-sandbox --print-to-pdf=schema-funzionamento-filtro-ionix.pdf \
  --no-pdf-header-footer schema-funzionamento-filtro-ionix.html
```

## Prima dell'invio

1. Verificare i valori di targa (portate, potenza ventilatore, soglie ΔP): quelli inseriti sono i valori di esempio indicati in fase di definizione.
2. Confermare la dicitura del destinatario ("CELMACCH") e l'eventuale marchio registrato IONIX®.
