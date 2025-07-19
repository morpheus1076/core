window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'ganghud') {
        const ganghud = document.getElementById('ganghud');
        //document.getElementById('gangname').textContent = data.gangname;
        //document.getElementById('gangrang').textContent = data.gangrang;
        //document.getElementById('playername').textContent = data.playername;
        //document.getElementById('kontostand').textContent = `Kontostand: $${data.kontostand}`;

        ganghud.style.display = 'block';
    }  else if (data.action === 'ganghudclose') {
        const ganghud = document.getElementById('ganghud');
        ganghud.style.display = 'none';
    }
});

function members() {
    fetch(`https://${GetParentResourceName()}/callmembers`, { method: 'POST' });
}

function fahrzeuge() {
    fetch(`https://${GetParentResourceName()}/callfahrzeuge`, { method: 'POST' });
}
