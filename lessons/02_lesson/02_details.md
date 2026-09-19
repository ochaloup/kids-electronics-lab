# Druhá hodina – měření, série/paralela a micro:bit

## Cíl hodiny

- zopakovat **napětí, proud a odpor**
- zopakovat zapojení **LED + rezistor**
- prakticky změřit **napětí** na součástkách
- prakticky změřit **proud** v zapojeném obvodu
- pochopit rozdíl mezi **sériovým a paralelním zapojením**
- zapojit LED k **micro:bitu**
- ukázat rozdíl mezi:
  - micro:bit **napájí** LED přímo
  - micro:bit pouze **spíná** jiný napájený obvod

---

# 1. Opakování

## Napětí

- značka: `U`
- jednotka: volt `V`
- napětí měříme **mezi dvěma body**
- voltmetr připojujeme **paralelně**

## Proud

- značka: `I`
- jednotka: ampér `A`
- proud měříme **uvnitř obvodu**
- obvod musíme rozpojit a multimetr vložit **do série**

## Odpor

- značka: `R`
- jednotka: ohm `Ω`

## Ohmův zákon

```text
U = R × I
I = U / R
R = U / I
```

---

# 2. Zopakování LED

Zapojit:

```text
+ baterie ── rezistor ── LED ── - baterie
```

Připomenout:

- LED má polaritu
- delší nožička = anoda = směrem k `+`
- kratší nožička = katoda = směrem k `-`
- rezistor omezuje proud
- LED má svůj úbytek napětí

---

# 3. Měření napětí v zapojeném obvodu

Na zapojené LED změřit:

1. napětí baterie
2. napětí na LED
3. napětí na rezistoru

Například:

```text
U baterie     ≈ 3,1 V
U LED         ≈ 1,9 V
U rezistoru   ≈ 1,2 V
```

Ověřit:

```text
U baterie ≈ U LED + U rezistoru
```

## Důležitá myšlenka

Na součástkách vzniká **úbytek napětí**.

Napětí zdroje se musí rovnat součtu úbytků napětí v celé smyčce.

Zkusit také změřit napětí na obyčejném vodiči:

```text
U vodiče ≈ 0 V
```

---

# 4. Měření proudu

Stejný obvod:

```text
+ baterie ── rezistor ── LED ── - baterie
```

Obvod rozpojit a vložit multimetr:

```text
+ baterie ── multimetr(A) ── rezistor ── LED ── - baterie
```

Změřit proud na několika místech:

```text
před rezistorem
mezi rezistorem a LED
za LED
```

Výsledek:

> V sériovém obvodu teče všemi součástkami stejný proud.

---

# 5. Sériové zapojení

Zapojit například dva rezistory:

```text
+ ── R1 ── R2 ── -
```

Změřit:

- proud před `R1`
- proud mezi `R1` a `R2`
- proud za `R2`

Proud by měl být všude přibližně stejný.

Potom změřit:

- napětí zdroje
- napětí na `R1`
- napětí na `R2`

Ověřit:

```text
U zdroje ≈ U R1 + U R2
```

## Zapamatovat

> **Série: stejný proud, úbytky napětí se sčítají.**

---

# 6. Paralelní zapojení

Zapojit dva rezistory paralelně:

```text
            ┌── R1 ──┐
+ ──────────┤        ├────────── -
            └── R2 ──┘
```

Změřit napětí:

- na zdroji
- na `R1`
- na `R2`

Ověřit:

```text
U zdroje ≈ U R1 ≈ U R2
```

Pokud bude čas, změřit proud:

```text
              I1
             ┌── R1 ──┐
I celkem ────┤        ├────
             └── R2 ──┘
              I2
```

Ověřit:

```text
I celkem ≈ I1 + I2
```

## Zapamatovat

> **Paralela: stejné napětí, proudy ve větvích se sčítají.**

---

# 7. LED připojená k micro:bitu

Micro:bit připojit přes USB k počítači.

Použít:

```text
P0
GND
```

Zapojení:

```text
P0 ── rezistor ── LED ── GND
```

Například rezistor:

```text
1 kΩ
```

## Co znamená P0

Piny:

```text
0   1   2
```

jsou programovatelné GPIO vývody.

Pro jednoduchý pokus je můžeme chápat jako **programem ovládané „+“**:

```text
P0 = 1  → přibližně 3 V
P0 = 0  → přibližně 0 V
```

`GND` použijeme jako `-`.

Vývod `3V` je naopak stálé napájení.

---

# 8. Změření micro:bitu multimetrem

Bez LED nejprve změřit:

```text
P0 ↔ GND
```

Při:

```text
P0 = 0
```

naměřit přibližně:

```text
0 V
```

Při:

```text
P0 = 1
```

naměřit přibližně:

```text
3 V
```

Důležitá myšlenka:

> Program změnil skutečné elektrické napětí na vývodu micro:bitu.

Potom připojit LED a programem ji zapínat a vypínat.

---

# 9. Micro:bit jako spínač

Druhý způsob:

micro:bit už zařízení **nenapájí**.

Zařízení má vlastní zdroj:

```text
baterie ── zařízení ── spínač ── baterie
```

Micro:bit pouze řídí spínač:

```text
micro:bit
    │
    │ zapnout / vypnout
    ▼
   relé
    │
    ▼
obvod napájený baterií
```

Ukázat například:

```text
baterie ── rezistor ── LED ── relé ── baterie
```

## Důležitá myšlenka

> Micro:bit nemusí zařízení napájet. Může pouze rozhodnout, zda se obvod zapne nebo vypne.

To později umožní ovládat například:

- silnější LED
- motor
- čerpadlo
- ventil

---

# Shrnutí hodiny

```text
Napětí měříme paralelně.
Proud měříme v sérii.

Série:
- stejný proud
- úbytky napětí se sčítají

Paralela:
- stejné napětí
- proudy ve větvích se sčítají

Micro:bit:
- P0/P1/P2 mohou být programované výstupy
- P0 = 1 → přibližně 3 V
- P0 = 0 → přibližně 0 V
- GND = společná zem
- micro:bit může zařízení napájet nebo pouze ovládat spínač
```

---

# Co připravit

- micro:bit
- USB kabel
- počítač
- breadboard
- multimetr
- baterie
- LED
- několik rezistorů
- vodiče / krokosvorky
- relé nebo reléový modul
