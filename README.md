# 🏢 Elevator System

<div align="center">

![FiveM](https://img.shields.io/badge/FiveM-Platform-orange?style=for-the-badge)
![Lua](https://img.shields.io/badge/Lua-5.4-blue?style=for-the-badge&logo=lua)
![vRP](https://img.shields.io/badge/vRP-Compatible-green?style=for-the-badge)
![Creative](https://img.shields.io/badge/Creative_Network-Compatible-green?style=for-the-badge)
![Version](https://img.shields.io/badge/Version-1.0.0-lightgrey?style=for-the-badge)

**Sistema de elevador moderno, configurável e performático para servidores FiveM.**

UI premium com design dark mode, animações fluidas e integração nativa com vRP e Creative Network.

---

[Instalação](#-instalação) · [Configuração](#-configuração) · [Recursos](#-recursos) · [Targets](#-target-systems)

</div>

---

## ✨ Recursos

- 🎨 **UI Premium** — Design dark mode com estética moderna e profissional
- ⚡ **Alta Performance** — Sleep dinâmico, sem loops pesados, zero impacto
- 🔧 **Fácil Configuração** — Adicione elevadores e andares ilimitados via `config.lua`
- 🔒 **Permissões por Job** — Restrinja elevadores por cargo (opcional)
- 🎯 **Multi-Target** — Compatível com ox_target, vrp_target e creative_target
- 🔔 **Notify Nativo** — Usa o sistema de notificação do servidor
- 🎵 **Sons** — Efeitos sonoros procedurais elegantes
- 🚀 **Detecção Automática** — Detecta o andar atual do jogador automaticamente
- 🌊 **Transições** — Fade, animação e loading com direção (Subindo/Descendo)
- 📍 **Marker Customizado** — Seta 3D limpa e bonita, sem marker feio do GTA

---

## 📋 Compatibilidade

| Framework / Sistema | Status |
|---------------------|--------|
| vRP | ✅ Compatível |
| Creative Network | ✅ Compatível |
| ox_target | ✅ Suportado |
| vrp_target | ✅ Suportado |
| creative_target | ✅ Suportado |

---

## 📦 Instalação

1. Baixe ou clone o repositório:
```bash
git clone https://github.com/lucasribeiroxzz/elevator_system.git
```

2. Coloque a pasta `elevator_system` dentro de `resources/`

3. Adicione ao `server.cfg`:
```
ensure elevator_system
```

4. Configure seus elevadores em `config.lua`

5. Reinicie o servidor

---

## ⚙️ Configuração

### Estrutura do Projeto

```
elevator_system/
├── client/
│   └── main.lua
├── server/
│   └── main.lua
├── shared/
│   └── utils.lua
├── html/
│   ├── index.html
│   ├── style.css
│   └── script.js
├── config.lua
├── fxmanifest.lua
└── README.md
```

### Configuração Global

```lua
Config.Framework = 'vrp'              -- 'vrp' ou 'creative'
Config.InteractionDistance = 2.0       -- Distância para interagir
Config.TransitionTime = 2000          -- Tempo de transição (ms)
Config.Cooldown = 3000                -- Cooldown anti-spam (ms)
Config.EnableSounds = true            -- Sons da interface
Config.EnableBlur = true              -- Blur no fundo
```

### Adicionando Elevadores

```lua
Config.Elevators = {
    ['meu_elevador'] = {
        label = 'Nome do Elevador',
        interaction = 'pickup',          -- 'pickup' (marker) ou 'target'
        icon = 'fa-solid fa-building',
        jobs = {},                       -- {} = todos, {'police'} = só police
        floors = {
            {
                label = 'Térreo',
                coords = vector4(x, y, z, heading)
            },
            {
                label = '1º Andar',
                coords = vector4(x, y, z, heading)
            }
        }
    }
}
```

---

## 🎯 Target Systems

```lua
Config.TargetSystem = 'ox_target'  -- ox_target, vrp_target ou creative_target
```

Elevadores com `interaction = 'target'` registram zonas automaticamente no target configurado.

Elevadores com `interaction = 'pickup'` usam marker 3D + tecla E.

---

## 🛠️ Comandos

| Comando | Descrição |
|---------|-----------|
| `/elevator_debug` | Printa coordenadas e heading atuais no console (F8) |

---

## 📄 Licença

Este projeto foi criado por **Lucassx**.

---

<div align="center">

**Desenvolvido por [Lucassx](https://github.com/lucasribeiroxzz)**

</div>
