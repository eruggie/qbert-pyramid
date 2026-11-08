# Configurazione dei round — fase 3

`initial_rounds.tres` contiene dodici modalità iniziali e il ciclo successivo,
più i limiti di intervallo apparizioni, massimo avversari e velocità. Le
modalità sono 0 permanente, 1 due passaggi, 2 reversibile; il ciclo predefinito
è [0, 1, 2] per livello, quattro round per livello.

Valori predefiniti: intervallo successivo 2,0 s, riduzione 0,1 s per livello
e round, minimo 1,2 s; cap iniziale 6, +1 ogni due livelli, massimo 8;
fattore velocità minimo 0,6. Il caricamento valida l'intera configurazione;
valori invalidi non sostituiscono la partita corrente. La risorsa si modifica
nell'editor Godot; le regole non dipendono dal dispositivo di input.
