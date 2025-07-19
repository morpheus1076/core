const progressbarContainer = document.getElementById('progressbar-container');
const progressbarText = document.getElementById('progressbar-text');
const progressbarInner = document.getElementById('progressbar-inner');

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'showProgressbar') {
        progressbarText.textContent = data.text;
        progressbarInner.style.width = '0%';
        progressbarContainer.style.display = 'block';

        // Starte die Animation
        setTimeout(() => {
            progressbarInner.style.transitionDuration = `${data.duration / 1000}s`; // Dauer in Sekunden
            progressbarInner.style.width = '100%';
        }, 50); // Eine kleine Verzögerung, um die Transition zu gewährleisten

        // Sende Nachricht zurück, wenn die Animation abgeschlossen ist
        setTimeout(() => {
            progressbarContainer.style.display = 'none'; // Progressbar ausblenden
            fetch(`https://${GetParentResourceName()}/progressbarFinished`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json; charset=UTF-8',
                },
                body: JSON.stringify({ success: true })
            }).then(resp => resp.json()).then(resp => console.log(resp));
        }, data.duration);

    } else if (data.type === 'hideProgressbar') {
        progressbarContainer.style.display = 'none';
    }
});

// Dummy Fetch-Antwort für das FiveM NUI System, damit es keine Fehler gibt
// Wenn die Ressource gestartet wird, initialisiere die Verbindung.
document.addEventListener('DOMContentLoaded', () => {
    fetch(`https://${GetParentResourceName()}/nuiReady`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
});
