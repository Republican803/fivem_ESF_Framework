// NUI Script

const departments = {
    Police: {
        LSPD: { description: "Urban patrol, high-crime response" },
        Sheriff: { description: "County-wide enforcement" },
        HighwayPatrol: { description: "Traffic and pursuit focus" }
    },
    EMS: {
        CentralEMS: { description: "City medical response" },
        RuralEMS: { description: "Outlying area support" }
    },
    Fire: {
        LSFD: { description: "Urban fire and rescue" },
        RuralFire: { description: "Wildland and remote ops" }
    }
};

let mode = 'creation';  // creation or switch

window.addEventListener('message', function(event) {
    if (event.data.action === 'open') {
        mode = event.data.mode;
        document.getElementById('container').style.display = 'block';
        document.getElementById('title').innerText = mode === 'creation' ? 'Create Character' : 'Switch Agency';
        document.getElementById('charName').style.display = mode === 'creation' ? 'block' : 'none';
        document.getElementById('submitBtn').innerText = mode === 'creation' ? 'Create' : 'Switch';
    }
});

document.getElementById('roleSelect').addEventListener('change', function() {
    const role = this.value;
    const agencySelect = document.getElementById('agencySelect');
    agencySelect.innerHTML = '<option value="">Select Agency</option>';
    agencySelect.disabled = false;
    
    if (role && departments[role]) {
        for (let agency in departments[role]) {
            const option = document.createElement('option');
            option.value = agency;
            option.textContent = agency;
            agencySelect.appendChild(option);
        }
    }
});

document.getElementById('agencySelect').addEventListener('change', function() {
    const role = document.getElementById('roleSelect').value;
    const agency = this.value;
    document.getElementById('agencyDesc').textContent = departments[role][agency]?.description || '';
});

document.getElementById('submitBtn').addEventListener('click', function() {
    const data = {
        name: document.getElementById('charName').value,
        role: document.getElementById('roleSelect').value,
        agency: document.getElementById('agencySelect').value
    };
    
    if (mode === 'creation' && data.name && data.role && data.agency) {
        fetch(`https://${GetParentResourceName()}/submitCreation`, { method: 'POST', body: JSON.stringify(data) });
    } else if (mode === 'switch' && data.role && data.agency) {
        fetch(`https://${GetParentResourceName()}/submitSwitch`, { method: 'POST', body: JSON.stringify(data) });
    }
});

document.getElementById('closeBtn').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeNUI`, { method: 'POST' });
    document.getElementById('container').style.display = 'none';
});