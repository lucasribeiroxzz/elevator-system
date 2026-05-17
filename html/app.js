(function(){
    var _0x=['\x43\x72\x69\x61\x64\x6f\x20\x70\x6f\x72\x20\x4c\x75\x63\x61\x73\x73\x78','\x73\x79\x73\x2d\x69\x64'];
    var _wm=function(){var e=document.getElementById(_0x[1]);if(e){e.textContent=_0x[0];}};

    const panel = document.getElementById('elevator-panel');
    const blurOverlay = document.getElementById('blur-overlay');
    const overlay = document.getElementById('transition-overlay');
    const floorsContainer = document.getElementById('floors-container');
    const elevatorLabel = document.getElementById('elevator-label');
    const headerFloorInfo = document.getElementById('header-floor-info');
    const closeBtn = document.getElementById('close-btn');
    const transitionChevron = document.getElementById('transition-chevron');
    const chevronPath = document.getElementById('chevron-path');
    const transitionText = document.getElementById('transition-text');
    const transitionFloor = document.getElementById('transition-floor');

    let enableSounds = true;
    let isOpen = false;

    function snd(freq, dur, vol) {
        if (!enableSounds) return;
        try {
            const c = new (window.AudioContext || window.webkitAudioContext)();
            const o = c.createOscillator();
            const g = c.createGain();
            o.type = 'sine';
            o.frequency.setValueAtTime(freq, c.currentTime);
            g.gain.setValueAtTime(vol || 0.03, c.currentTime);
            g.gain.exponentialRampToValueAtTime(0.0001, c.currentTime + dur);
            o.connect(g);
            g.connect(c.destination);
            o.start(c.currentTime);
            o.stop(c.currentTime + dur);
        } catch(e) {}
    }

    function clickSound() { snd(900, 0.06, 0.025); }
    function openSound() { snd(500, 0.12, 0.02); setTimeout(() => snd(700, 0.08, 0.015), 60); }
    function elevatorDing() { snd(587, 0.5, 0.03); setTimeout(() => snd(784, 0.4, 0.025), 250); }

    window.addEventListener('message', function(e) {
        switch(e.data.action) {
            case 'openElevator': openPanel(e.data); break;
            case 'closeElevator': closePanel(); break;
            case 'showTransition': showTransition(e.data); break;
            case 'hideTransition': hideTransition(); break;
        }
    });

    function openPanel(data) {
        const elev = data.elevator;
        enableSounds = data.enableSounds !== false;

        elevatorLabel.textContent = elev.label;

        const currentFloorData = elev.floors.find(f => f.isCurrent);
        headerFloorInfo.textContent = currentFloorData
            ? currentFloorData.label
            : 'Selecione o destino';

        floorsContainer.innerHTML = '';

        elev.floors.forEach(function(floor, idx) {
            const btn = document.createElement('div');
            btn.className = 'floor-btn';
            if (floor.isCurrent) btn.classList.add('current-floor');

            const num = document.createElement('div');
            num.className = 'floor-number';
            num.textContent = String(floor.index).padStart(2, '0');

            const info = document.createElement('div');
            info.className = 'floor-info';

            const label = document.createElement('span');
            label.className = 'floor-label';
            label.textContent = floor.label;
            info.appendChild(label);

            if (floor.isCurrent) {
                const tag = document.createElement('span');
                tag.className = 'current-tag';
                tag.textContent = 'Andar atual';
                info.appendChild(tag);
            }

            btn.appendChild(num);
            btn.appendChild(info);

            if (!floor.isCurrent) {
                const arrow = document.createElement('span');
                arrow.className = 'floor-arrow';
                arrow.innerHTML = '&#8250;';
                btn.appendChild(arrow);

                btn.addEventListener('click', function() {
                    clickSound();
                    fetch('https://elevator_system/selectFloor', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/json'},
                        body: JSON.stringify({floor: floor.index})
                    });
                });
            }

            btn.style.animationDelay = (idx * 0.04) + 's';
            floorsContainer.appendChild(btn);
        });

        blurOverlay.classList.remove('hidden');
        panel.classList.remove('hidden');
        isOpen = true;
        _wm();
        openSound();
    }

    function closePanel() {
        if (!isOpen) return;
        const frame = panel.querySelector('.panel-frame');
        frame.classList.add('panel-closing');
        blurOverlay.classList.add('blur-closing');

        setTimeout(function() {
            panel.classList.add('hidden');
            blurOverlay.classList.add('hidden');
            frame.classList.remove('panel-closing');
            blurOverlay.classList.remove('blur-closing');
            isOpen = false;
        }, 280);
    }

    function showTransition(data) {
        const dir = data.direction || 'up';

        if (dir === 'up') {
            chevronPath.setAttribute('d', 'M6 15L12 9L18 15');
            transitionChevron.classList.remove('going-down');
        } else {
            chevronPath.setAttribute('d', 'M6 9L12 15L18 9');
            transitionChevron.classList.add('going-down');
        }

        transitionText.textContent = dir === 'up' ? 'Subindo...' : 'Descendo...';
        transitionFloor.textContent = data.floorLabel || '';

        overlay.classList.remove('hidden');
        overlay.style.animation = 'transIn 0.5s ease-out';
        elevatorDing();
    }

    function hideTransition() {
        overlay.style.animation = 'transIn 0.4s ease-in reverse forwards';
        setTimeout(function() {
            overlay.classList.add('hidden');
            overlay.style.animation = '';
        }, 380);
    }

    closeBtn.addEventListener('click', function() {
        clickSound();
        fetch('https://elevator_system/closeElevator', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({})
        });
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isOpen) {
            clickSound();
            fetch('https://elevator_system/closeElevator', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({})
            });
        }
    });

    setInterval(function(){_wm();},5000);
})();
