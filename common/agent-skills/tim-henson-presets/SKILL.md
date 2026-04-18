---
name: tim-henson-presets
description: Generate Archetype Tim Henson X preset files from AI-supplied parameter overrides using a template copy workflow.
argument-hint: "Natural-language tone request"
---

# Tim Henson Preset Generator

This skill separates responsibilities:

- AI decides the tone and exact parameter overrides.
- Script writes the binary preset file safely.

## Rules

1. Never edit existing source presets.
2. Always create a new file in `/Library/Audio/Presets/Neural DSP/Archetype Tim Henson X/AI generated/`.
3. Use `Default.xml` as fallback template when no template path is provided.
4. JSON overrides are read from `stdin`.
5. Unknown parameter keys are rejected.

## Commands

Generate from stdin JSON and optional template:

```bash
python3 "/Users/arjunmahishi/.config/opencode/skills/tim-henson-presets/tim_henson_skill.py" generate --name "my_preset" --template "/Library/Audio/Presets/Neural DSP/Archetype Tim Henson X/User/clean_fingerstyle.xml"
```

Generate from fallback `Default.xml`:

```bash
python3 "/Users/arjunmahishi/.config/opencode/skills/tim-henson-presets/tim_henson_skill.py" generate --name "my_preset"
```

Build index cache:

```bash
python3 "/Users/arjunmahishi/.config/opencode/skills/tim-henson-presets/tim_henson_skill.py" index
```

Print authoritative parameter names from a template:

```bash
python3 "/Users/arjunmahishi/.config/opencode/skills/tim-henson-presets/tim_henson_skill.py" params
```

## JSON Input Shape

The script reads a JSON object from stdin where keys are parameter names and values are booleans, numbers, or strings.

```json
{
  "reverbActive": true,
  "reverbMix": 0.42,
  "delayTime": 500,
  "leadGain": 0.73
}
```

## Parameter Names (Reference)

Use only real plugin parameter names. Common groups:

- Global: `inputGain`, `outputGain`, `transpose`, `gateActive`, `gateThreshold`, `doublerActive`, `doublerSpread`
- Pre FX: `boostActive`, `boostGain`, `boostBass`, `boostTreble`, `boostLevel`, `compActive`, `compCompression`, `compAttack`, `compLevel`, `overdriveActive`, `overdriveDrive`, `overdriveTone`, `overdriveLevel`
- Amp: `selectedAmp`, `leadGain`, `leadBass`, `leadMiddle`, `leadTreble`, `leadPresence`, `leadMaster`, `leadOutput`, `rhythmGain`, `rhythmBass`, `rhythmMiddle`, `rhythmTreble`, `rhythmPresence`, `rhythmOutput`, `rhythmChannel`, `acousticGain`, `acousticBlend`, `acousticBass`, `acousticMiddle`, `acousticTreble`, `acousticPresence`, `acousticOutput`
- EQ: `leadEQActive`, `leadEQBand1`..`leadEQBand9`, `leadEQHpf`, `leadEQLpf`, `rhythmEQActive`, `rhythmEQBand1`..`rhythmEQBand9`, `rhythmEQHpf`, `rhythmEQLpf`, `acousticEQActive`, `acousticEQBand1`..`acousticEQBand9`, `acousticEQHpf`, `acousticEQLpf`
- Cab: `cabStereo`, `leftCabActive`, `leftCab0MicType`, `leftCab1MicType`, `leftCabDistance`, `leftCabPosition`, `leftCabPhase`, `leftCabPan`, `leftCabMicLevel`, `leftRoomActive`, `leftRoomMicLevel`, `rightCabActive`, `rightCab0MicType`, `rightCab1MicType`, `rightCabDistance`, `rightCabPosition`, `rightCabPhase`, `rightCabPan`, `rightCabMicLevel`, `rightRoomActive`, `rightRoomMicLevel`, `leftCab0ChosenIRFilePath`, `leftCab1ChosenIRFilePath`, `rightCab0ChosenIRFilePath`, `rightCab1ChosenIRFilePath`
- Delay: `delayActive`, `delayTime`, `delayTempo`, `delaySync`, `delayNote`, `delayMode`, `delayType`, `delayFeedback`, `delayMix`, `delayAmount`, `delayHighCut`, `delayLowCut`
- Reverb: `reverbActive`, `reverbMix`, `reverbDecay`, `reverbHighCut`, `reverbLowCut`, `reverbShimmer`
- Chorus: `chorusActive`, `chorusMix`
- Multivoicer: `multivoicerMode`, `multivoicerRoot`, `multivoicerQuantize`, `multivoicerTuning`, `multivoicerTone`, `multivoicerWidth`, `multivoicerOutput`, `multivoicerMidiEnabled`, `multivoicerUnison`, `multivoicerVoice1Active`, `multivoicerVoice1Level`, `multivoicerVoice1Pan`, `multivoicerVoice1Delay`, `multivoicerVoice1Detune`, `multivoicerVoice1Interval`, `multivoicerVoice1Semitones`, `multivoicerVoice2Active`, `multivoicerVoice2Level`, `multivoicerVoice2Pan`, `multivoicerVoice2Delay`, `multivoicerVoice2Detune`, `multivoicerVoice2Interval`, `multivoicerVoice2Semitones`, `multivoicerVoice3Active`, `multivoicerVoice3Level`, `multivoicerVoice3Pan`, `multivoicerVoice3Delay`, `multivoicerVoice3Detune`, `multivoicerVoice3Interval`, `multivoicerVoice3Semitones`, `multivoicerVoice4Active`, `multivoicerVoice4Level`, `multivoicerVoice4Pan`, `multivoicerVoice4Delay`, `multivoicerVoice4Detune`, `multivoicerVoice4Interval`, `multivoicerVoice4Semitones`

For full authoritative keys from your installed version, run the `params` command.
