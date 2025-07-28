let blinkInterval;
const progressbarContainer = document.getElementById('progressbar-container');
const progressbarText = document.getElementById('progressbar-text');
const progressbarInner = document.getElementById('progressbar-inner');
const idcardContainer = document.getElementById('idcard-container');
const idcardlastname = document.getElementById('idcard-lastname');
const idcardfirstname = document.getElementById('idcard-firstname');
const idcarddatebirth = document.getElementById('idcard-datebirth');
const idcardid = document.getElementById('idcard-id');

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'updateHUD') {
        document.getElementById('server-short').textContent = data.serverShort;
        document.getElementById('server-full').textContent = data.serverFull;
        document.getElementById('server-id').textContent = data.playerID;
        //document.getElementById('player-count').textContent = `@ : ${data.playerCount}`;
        document.getElementById('date').textContent = data.date;
        document.getElementById('time').textContent = data.time;
        document.getElementById('job-name').textContent = data.jobName;
        document.getElementById('job-grade').textContent = data.jobGrade;
    }
    if (data.action === 'updateHAS') {
        const healthContainer = document.getElementById('health-container');
        const healthBar = document.getElementById('health-bar');
        const healthLevel = (data.healthLevel / 200) * 100;
        const armourContainer = document.getElementById('armour-container');
        const armourBar = document.getElementById('armour-bar');
        const armourLevel = data.armourLevel;
        const staminaContainer = document.getElementById('stamina-container');
        const staminaBar = document.getElementById('stamina-bar');
        const staminaLevel = data.staminaLevel;

        healthContainer.style.display = 'flex';
        healthBar.style.width = `${healthLevel}%`;
        armourContainer.style.display = 'flex';
        armourBar.style.width = `${armourLevel}%`;
        //staminaContainer.style.display = 'flex';
        //staminaBar.style.height = `${staminaLevel}%`;
    }
    if (data.action === 'updateSpeed') {
        document.getElementById('speedmeter').textContent = data.speed;
    }
    if (data.action === 'updateFuel') {
        const fuelContainer = document.getElementById('fuel-container');
        const seatbeltContainer = document.getElementById('seatbelt-container');
        document.getElementById('plate-text').textContent = data.plate;
        const fuelBar = document.getElementById('fuel-bar');
        const seatBelticon = document.getElementById('seatbelt-icon');
        const fuelLevel = data.fuelLevel;
        const seatBelt = data.seatBelt;
        const kmH = document.getElementById('kmh');

        if (fuelLevel === -1) {
            // Blende das Fuel-Element aus, wenn der Wert -1 ist
            fuelContainer.style.display = 'none';
            seatbeltContainer.style.display = 'none';
            kmH.style.display = 'none';
            //plateText.style.display = 'none';
        }
        else {
            // Zeige das Fuel-Element an
            fuelContainer.style.display = 'flex';
            seatbeltContainer.style.display = 'flex';
            kmH.style.display = 'flex';
            //plateText.style.display = 'flex';

            // Aktualisiere den Kraftstoffbalken
            fuelBar.style.width = `${fuelLevel}%`;

            // Ändere die Farbe basierend auf dem Wert
            if (fuelLevel < 10) {
                fuelBar.style.backgroundColor = 'red';
                if (!blinkInterval) {
                    blinkInterval = setInterval(() => {
                        if (fuelBar.style.opacity === '0') {
                            fuelBar.style.opacity = '0.8';
                        } else {
                            fuelBar.style.opacity = '0';
                        }
                    }, 500); // Alle 500ms die Sichtbarkeit umschalten
                }
            } else {
                fuelBar.style.backgroundColor = 'green';

                if (blinkInterval) {
                    clearInterval(blinkInterval);
                    blinkInterval = null;
                    fuelBar.style.opacity = '0.8'; // Sichtbar lassen
                }
            }
            if (seatBelt == 1) {
                seatBelticon.style.backgroundColor = 'rgba(255, 0, 0, 0.4)';
            } else {
                seatBelticon.style.backgroundColor = 'rgba(0, 128, 0, 0.4)';
            }
        }
    }
    if (data.action === 'updateStatus') {
        const hungerContainer = document.getElementById('hunger-container');
        const hungerBar = document.getElementById('hunger-bar');
        const hungerLevel = data.hungerLevel;
        const thirstContainer = document.getElementById('thirst-container');
        const thirstBar = document.getElementById('thirst-bar');
        const thirstLevel = data.thirstLevel;

        hungerContainer.style.display = 'flex';
        hungerBar.style.width = `${hungerLevel}%`;
        thirstContainer.style.display = 'flex';
        thirstBar.style.width = `${thirstLevel}%`;

    }
    if (data.action === 'seitenmenu') {

        //const tabs = document.querySelectorAll('.tab');
        const contentContainer = document.getElementById('content');
        const menuContents = document.querySelectorAll('.menu-content');
        //const tab1Content = document.querySelector('.menu-content[data-tab="1"]');
        //const tab2Content = document.querySelector('.menu-content[data-tab="2"]');
        //const tab3Content = document.querySelector('.menu-content[data-tab="3"]');
        let menuOpen = false;
        const job = data.job;

        const tabs = document.querySelectorAll('.tab');
        const contents = document.querySelectorAll('.menu-content');
        const gangHud = document.getElementById('ganghud');

        tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                const targetTab = tab.getAttribute('data-tab');

                // Alle Inhalte ausblenden
                contents.forEach(content => {
                    content.style.display = 'none';
                });

                // Nur das Ziel-Tab anzeigen
                const activeContent = document.querySelector(`.menu-content[data-tab="${targetTab}"]`);
                if (activeContent) {
                    activeContent.style.display = 'block';
                }

                // Gang-HUD anzeigen, wenn "Job"-Tab angeklickt wird
                if (targetTab === "1") {
                    gangHud.style.display = 'block';
                } else {
                    gangHud.style.display = 'none';
                }
            });
        });


        /*if (job === "police") {
            tab1Content.innerHTML = `
                <h3>Police Menu</h3>
                <button onclick="arrestPlayer()">Arrest Player</button>
                <button onclick="issueTicket()">Issue Ticket</button>
            `;
        } else if (job === "vagos") {
            tab1Content.innerHTML = `
                <h3>Vagos Menu</h3>
                <button onclick="healPlayer()">Heal Player</button>
                <button onclick="revivePlayer()">Revive Player</button>
            `;
        } else {
            tab1Content.innerHTML = `
                <h3>Job Menu</h3>
                <p>Du hast keinen Job.</p>
                <button onclick="healPlayer()">Heal Player</button>
            `;
        }*/

        document.onkeyup = function(data) {
            {
                if (data.which == 27) //or (data.which == 117)
                menuOpen = !menuOpen;
                if (!menuOpen) {
                    contentContainer.style.display = 'none';
                    gangHud.style.display = 'none';
                    menuContents.forEach(content => content.style.display = 'none');
                    fetch(`https://mor_core/closeMenu`, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({})
                    });
                } else {
                    //contentContainer.style.display = 'block';
                }
            }
        };

        /*tabs.forEach(tab => {
            tab.addEventListener('click', () => {
                const tabId = tab.getAttribute('data-tab');
                menuContents.forEach(content => {
                    content.style.display = content.getAttribute('data-tab') === tabId ? 'block' : 'none';
                });
                contentContainer.style.display = 'block';
            });
        });*/

    }
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
    if (data.type === 'showIdCard') {
        idcardfirstname = data.firstname;
        idcardlastname = data.lastname;
        idcarddatebirth = data.datebirth;
        idcardid = data.id;
        idcardContainer.style.display = 'block';
    } else if (data.type === 'hideIdCard') {
        idcardContainer.style.display = 'none';
    }
});
// Progressbar
document.addEventListener('DOMContentLoaded', () => {
    fetch(`https://${GetParentResourceName()}/nuiReady`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8',
        },
        body: JSON.stringify({})
    });
});
// Funktion, um das Logo anzuzeigen
function showServerLogo() {
    const logo = document.getElementById("server-logo");
    logo.style.opacity = "1"; // Sichtbar machen

    // Nach 10 Sekunden wieder ausblenden
    setTimeout(() => {
        logo.style.opacity = "0"; // Unsichtbar machen
    }, 30000);
}

// Alle 20 Minuten das Logo anzeigen
setInterval(showServerLogo, 5 * 60 * 1000);

// Optional: Zeige das Logo beim ersten Laden
window.onload = () => {
    showServerLogo();
};

function arrestPlayer() {
    fetch(`https://${GetParentResourceName()}/arrestPlayer`, { method: 'POST' });
}

function issueTicket() {
    fetch(`https://${GetParentResourceName()}/issueTicket`, { method: 'POST' });
}

function healPlayer() {
    fetch(`https://${GetParentResourceName()}/healPlayer`, { method: 'POST' });
}

function revivePlayer() {
    fetch(`https://${GetParentResourceName()}/revivePlayer`, { method: 'POST' });
}