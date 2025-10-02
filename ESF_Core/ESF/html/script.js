let currentTab = 'active-calls';

window.addEventListener('message', function(event) {
    let data = event.data;
    if (data.action === 'openMDT') {
        document.getElementById('mdt-container').classList.remove('hidden');
        document.getElementById('boot-screen').classList.remove('hidden');
        setTimeout(() => {
            document.getElementById('boot-screen').classList.add('hidden');
            switchTab('active-calls');
            applyTheme(data.agency);
        }, 2000);
    } else if (data.action === 'closeMDT') {
        document.getElementById('mdt-container').classList.add('hidden');
    } else if (data.action === 'updateActiveCalls') {
        updateCallsList(data.data);
    } else if (data.action === 'updateUnitStatus') {
        updateUnitsList(data.data);
    } else if (data.action === 'showQueryResult') {
        document.getElementById('query-result').innerHTML = JSON.stringify(data.data);
    } else if (data.action === 'updateRadioLog') {
        addRadioMessage(data.data);
    } else if (data.action === 'showAlert') {
        showAlert(data.data);
    } else if (data.action === 'limitAccess') {
        // Disable
    } else if (data.action === 'fullAccess') {
        // Enable
    }
});

function switchTab(tab) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
    document.getElementById(tab).classList.remove('hidden');
    currentTab = tab;
}

function updateStatus(status) {
    fetch(`https://${GetParentResourceName()}/updateStatus`, {method: 'POST', body: JSON.stringify({status: status})});
}

function runQuery() {
    let type = document.getElementById('query-type').value;
    let input = document.getElementById('query-input').value;
    fetch(`https://${GetParentResourceName()}/runQuery`, {method: 'POST', body: JSON.stringify({type: type, input: input})});
}

function sendRadio() {
    let msg = document.getElementById('radio-input').value;
    fetch(`https://${GetParentResourceName()}/sendRadio`, {method: 'POST', body: JSON.stringify({message: msg})});
    document.getElementById('radio-input').value = '';
}

function updateCallsList(calls) {
    let list = document.getElementById('calls-list');
    list.innerHTML = '';
    calls.forEach(call => {
        let li = document.createElement('li');
        li.innerHTML = `${call.code}: ${call.desc} - Priority ${call.priority} - Loc: ${call.location}`;
        list.appendChild(li);
    });
}

function updateUnitsList(units) {
    let list = document.getElementById('units-list');
    list.innerHTML = '';
    Object.values(units).forEach(unit => {
        let li = document.createElement('li');
        li.innerHTML = `${unit.callsign}: ${unit.status} - Agency: ${unit.agency}`;
        list.appendChild(li);
    });
}

function addRadioMessage(msg) {
    let list = document.getElementById('radio-messages');
    let li = document.createElement('li');
    li.innerHTML = `[${msg.time}] ${msg.sender}: ${msg.msg}`;
    list.appendChild(li);
}

function showAlert(alert) {
    let popup = document.getElementById('alert-popup');
    popup.innerHTML = alert;
    popup.classList.remove('hidden');
    setTimeout(() => popup.classList.add('hidden'), 5000);
}

function applyTheme(agency) {
    document.body.classList.add(agency);
}

function searchCalls(query) {
    // Client-side filter
}