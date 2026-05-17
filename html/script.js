(function() {
    const panel = document.getElementById('elevator-panel');
    const overlay = document.getElementById('transition-overlay');
    const floorsContainer = document.getElementById('floors-container');
    const elevatorLabel = document.getElementById('elevator-label');
    const elevatorIcon = document.getElementById('elevator-icon');
    const closeBtn = document.getElementById('close-btn');
    const transitionArrow = document.getElementById('transition-arrow');
    const transitionText = document.getElementById('transition-text');
    const transitionFloor = document.getElementById('transition-floor');

    let enableSounds = true;
    let isOpen = false;

    function playClickSound() {
        if (!enableSounds) return;
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(800, ctx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(1200, ctx.currentTime + 0.05);
            gain.gain.setValueAtTime(0.08, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.1);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.1);
        } catch(e) {}
    }

    function playOpenSound() {
        if (!enableSounds) return;
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(400, ctx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(800, ctx.currentTime + 0.15);
            gain.gain.setValueAtTime(0.06, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.2);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.2);
        } catch(e) {}
    }

    function playElevatorSound() {
        if (!enableSounds) return;
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.type = 'sine';
            osc.frequency.setValueAtTime(523, ctx.currentTime);
            gain.gain.setValueAtTime(0.05, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.8);
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.8);

            setTimeout(() => {
                const osc2 = ctx.createOscillator();
                const gain2 = ctx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(659, ctx.currentTime);
                gain2.gain.setValueAtTime(0.05, ctx.currentTime);
                gain2.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + 0.6);
                osc2.connect(gain2);
                gain2.connect(ctx.destination);
                osc2.start(ctx.currentTime);
                osc2.stop(ctx.currentTime + 0.6);
            }, 300);
        } catch(e) {}
    }

    window.addEventListener('message', function(event) {
        const data = event.data;

        switch(data.action) {
            case 'openElevator':
                openPanel(data);
                break;
            case 'closeElevator':
                closePanel();
                break;
            case 'showTransition':
                showTransition(data);
                break;
            case 'hideTransition':
                hideTransition();
                break;
        }
    });

    function openPanel(data) {
        const elevator = data.elevator;
        enableSounds = data.enableSounds !== false;

        elevatorLabel.textContent = elevator.label;
        elevatorIcon.className = elevator.icon || 'fa-solid fa-elevator';

        floorsContainer.innerHTML = '';

        elevator.floors.forEach(function(floor, index) {
            const btn = document.createElement('div');
            btn.className = 'floor-btn';

            if (floor.isCurrent) {
                btn.classList.add('current-floor');
            }

            const num = document.createElement('div');
            num.className = 'floor-number';
            num.textContent = floor.index;

            const info = document.createElement('div');
            info.className = 'floor-info';

            const label = document.createElement('span');
            label.className = 'floor-label';
            label.textContent = floor.label;

            info.appendChild(label);

            btn.appendChild(num);
            btn.appendChild(info);

            if (!floor.isCurrent) {
                const arrow = document.createElement('i');
                arrow.className = 'fa-solid fa-chevron-right floor-arrow';
                btn.appendChild(arrow);

                btn.addEventListener('click', function() {
                    playClickSound();
                    selectFloor(floor.index);
                });
            }

            btn.style.animationDelay = (index * 0.05) + 's';
            btn.style.animation = 'panelSlideIn 0.3s cubic-bezier(0.16, 1, 0.3, 1) forwards';
            btn.style.opacity = '0';

            floorsContainer.appendChild(btn);
        });

        panel.classList.remove('hidden');
        isOpen = true;
        playOpenSound();
    }

    function closePanel() {
        if (!isOpen) return;
        const container = panel.querySelector('.panel-container');
        container.classList.add('panel-closing');
        setTimeout(function() {
            panel.classList.add('hidden');
            container.classList.remove('panel-closing');
            isOpen = false;
        }, 250);
    }

    function selectFloor(floorIndex) {
        fetch('https://elevator_system/selectFloor', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ floor: floorIndex })
        });
    }

    function showTransition(data) {
        const direction = data.direction || 'up';
        const floorLabel = data.floorLabel || '';

        transitionArrow.className = direction === 'up'
            ? 'fa-solid fa-arrow-up'
            : 'fa-solid fa-arrow-down';

        transitionText.textContent = direction === 'up' ? 'Subindo...' : 'Descendo...';
        transitionFloor.textContent = floorLabel;

        overlay.classList.remove('hidden');
        playElevatorSound();
    }

    function hideTransition() {
        overlay.style.animation = 'transitionIn 0.4s ease-in reverse';
        setTimeout(function() {
            overlay.classList.add('hidden');
            overlay.style.animation = '';
        }, 400);
    }

    closeBtn.addEventListener('click', function() {
        playClickSound();
        fetch('https://elevator_system/closeElevator', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    });

    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape' && isOpen) {
            playClickSound();
            fetch('https://elevator_system/closeElevator', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        }
    });
})();
