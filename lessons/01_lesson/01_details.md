# První hodina: Ohmův zákon, breadboard, LED a měření multimetrem

## Cíl hodiny

Hlavním cílem není, aby si děti odnesly jen vzoreček, ale aby si prakticky zažily tento postup:

> **Napětí změříme → odpor změříme → podle nich odhadneme proud → proud změříme → ověříme, že výsledek přibližně sedí.**

Základní vztah je:

\[
U = R \cdot I
\]

Z něj lze odvodit:

\[
I = \frac{U}{R}
\]

a

\[
R = \frac{U}{I}
\]

Pro praktické experimenty v této hodině bude nejčastěji používán vztah:

\[
I = \frac{U}{R}
\]

Smyslem je ukázat, že Ohmův zákon není jen školní vzoreček, ale nástroj, kterým lze **předpovědět skutečné chování elektrického obvodu**.

---

# Přibližný časový plán

Počítej přibližně s **60–75 minutami**.

Je lepší nechat dost času na skutečné přepojování, měření, chyby a pokusy než stihnout za každou cenu všechny body.

Pokud zbude čas, lze na konci přidat experiment se dvěma LED zapojenými **sériově a paralelně**.

---

# 1. Co vlastně umíme změřit

**Čas:** 5–10 minut

## Pomůcky

- baterie nebo držák baterií,
- digitální multimetr,
- breadboard,
- rezistory,
- LED.

Začni ideálně ještě bez breadboardu.

## Postup

Ukaž baterii a řekni například:

> „Máme baterii. Na obalu sice něco píšou, ale nevíme přesně, jaké napětí právě teď opravdu má. Pojďme se jí zeptat.“

Nastav multimetr na **stejnosměrné napětí – DC V**.

Červená sonda patří na **plus baterie**, černá na **minus baterie**.

Například můžeš naměřit:

\[
U = 2{,}45\,V
\]

nebo podle použitých článků jinou hodnotu.

## Co vysvětlit

Napětí je **rozdíl elektrických potenciálů mezi dvěma místy**.

Proto napětí měříme **mezi dvěma body**.

Důležitá věta:

> **Když měřím napětí, obvod nerozpojuji. Multimetr přikládám mezi dvě místa.**

To znamená, že voltmetr připojujeme **paralelně** k tomu, na čem chceme napětí změřit.

V tuto chvíli není nutné detailně vysvětlovat pojem paralelní zapojení. Stačí praktická myšlenka:

> „Při měření napětí obvod nechávám fungovat a sondami se jen dotknu dvou míst.“

---

# 2. Prozkoumání breadboardu

**Čas:** přibližně 5 minut

Nedávej dětem hned hotové schéma breadboardu.

Místo toho z něj udělej malý detektivní úkol.

## Otázka

> „Uvnitř breadboardu jsou některé dírky kovově propojené. Dokážeme zjistit které?“

Nastav multimetr na **test vodivosti / continuity / pípák**.

Děti mohou zkoušet různé otvory a zjistit:

- skupiny pěti propojených otvorů,
- že přes prostřední mezeru propojení nevede,
- jak fungují boční napájecí lišty,
- případně že některé dlouhé lišty mohou být uprostřed přerušené.

## Hlavní myšlenka

Breadboard není „kouzelná deska“.

Uvnitř jsou jen kovové kontakty, které některé dírky spojují dohromady.

Až po experimentu má smysl ukázat obrázek vnitřního propojení breadboardu.

---

# 3. Rezistor jako první objekt pro Ohmův zákon

**Čas:** přibližně 5 minut

Vezmi například rezistor **1 kΩ**, případně jinou vhodnou hodnotu.

## Postup

Řekni například:

> „Na rezistoru jsou barevné proužky, které nám říkají jeho hodnotu. Ale nebudeme jim zatím úplně věřit. Změříme si ho.“

Nastav multimetr na měření odporu.

Rezistor nesmí být při měření odporu připojený k baterii.

Například:

\[
R = 0{,}99\,k\Omega
\]

tedy přibližně:

\[
R = 990\,\Omega
\]

## Co vysvětlit

Dvě důležitá pravidla:

> **Napětí můžeme měřit v zapnutém obvodu.**

> **Odpor měříme bez připojeného napájení.**

Je také vhodné ukázat, že rezistor označený například jako 1 kΩ nemusí mít přesně 1000 Ω.

Jeho skutečná hodnota se může trochu lišit podle tolerance součástky.

---

# 4. Ohmův zákon

**Čas:** přibližně 10 minut

Zatím nepoužívej LED.

Zapoj jen baterii a rezistor.

```text
+ baterie
    |
 [rezistor]
    |
- baterie
```

## Vysvětlení

Řekni například:

> „Baterie vytváří napětí. Rezistor omezuje, jak velký proud může obvodem téct.“

Napětí, proud a odpor spolu souvisejí.

Zapiš:

\[
U = R \cdot I
\]

Pro praktickou práci je užitečné přepsat vztah jako:

\[
I = \frac{U}{R}
\]

A říct:

> „Když znám napětí baterie a odpor rezistoru, můžu předpovědět, jak velký proud bude obvodem téct.“

## Příklad

Máme například:

\[
U = 3\,V
\]

a

\[
R = 1000\,\Omega
\]

Pak:

\[
I = \frac{3\,V}{1000\,\Omega}
\]

\[
I = 0{,}003\,A
\]

tedy:

\[
I = 3\,mA
\]

## Jednotky

Je vhodné vysvětlit:

\[
1\,A = 1000\,mA
\]

V běžných malých elektronických obvodech budeme často používat právě miliampéry.

---

# 5. Ověření předpovědi měřením proudu

**Čas:** přibližně 10 minut

Toto je jeden z hlavních momentů hodiny.

Řekni například:

> „Podle výpočtu tvrdíme, že obvodem potečou asi 3 mA. Pojďme zjistit, jestli jsme měli pravdu.“

## Rozdíl mezi měřením napětí a proudu

Při měření napětí obvod **nerozpojujeme**.

Při měření proudu musíme proud přinutit, aby **prošel multimetrem**.

Proto obvod rozpojíme a multimetr vložíme do série.

Například:

```text
+ baterie
    |
 multimetr
    |
 rezistor
    |
- baterie
```

## Vysvětlení

> **Proud musí multimetrem protéct. Proto musí být multimetr při měření proudu součástí cesty proudu.**

Například:

Výpočet:

\[
I = 3{,}15\,mA
\]

Měření:

\[
I \approx 3{,}1\,mA
\]

## Hlavní „aha“ moment

> „Vzoreček není školní kouzlo. Pomocí něj jsme předpověděli, co se ve skutečném obvodu stane.“

## Důležité bezpečnostní pravidlo

Při měření proudu nikdy nepřipojuj multimetr přímo mezi plus a minus baterie.

To by bylo prakticky něco jako:

```text
+ baterie ---- téměř drát ---- - baterie
```

Vznikl by zkrat.

Proto opakuj:

> **Když je multimetr nastavený na měření proudu, nikdy ho nepřipojujeme přímo přes baterii.**

---

# 6. Experiment: co udělá jiný odpor

**Čas:** přibližně 10 minut

Připrav několik rezistorů, například:

- 2,2 kΩ,
- 1 kΩ,
- 470 Ω,
- případně 390 Ω.

Před každým měřením nechej děti nejprve odhadnout, co se stane.

## Příklad pro 3 V

| Odpor | Přibližný proud |
|---:|---:|
| 2,2 kΩ | 1,4 mA |
| 1 kΩ | 3 mA |
| 470 Ω | 6,4 mA |

Nemusí počítat všechno dokonale přesně.

Důležitější je pochopit směr změny.

## Otázky

> „Když zvětším odpor, co se stane s proudem?“

Ze vztahu:

\[
I = \frac{U}{R}
\]

plyne:

> **větší odpor → menší proud**

a naopak:

> **menší odpor → větší proud**

Můžeš také položit obrácenou otázku:

> „Když nechám odpor stejný a zvětším napětí, co se stane s proudem?“

Odpověď:

> **větší napětí → větší proud**

---

# 7. LED: kam se „podělo“ napětí

**Čas:** přibližně 15 minut

Teď přidej LED.

Zapoj například:

```text
+ baterie
    |
 rezistor
    |
   LED
    |
- baterie
```

LED musí být správně orientovaná:

- delší nožička = **anoda (+)**,
- kratší nožička = **katoda (-)**,
- zploštělá strana pouzdra obvykle označuje katodu.

Tedy:

```text
+ baterie → rezistor → delší nožička LED
kratší nožička LED → - baterie
```

## První otázka

> „Předtím bylo celé napětí baterie na rezistoru. Co se stane teď, když jsme přidali LED?“

## Jak měřit napětí

Při měření napětí **obvod nerozpojujeme**.

Obvod necháme zapojený a LED svítit.

Multimetr nastavíme na DC V a sondami se dotýkáme vždy dvou bodů.

Například:

```text
A ---- rezistor ---- B ---- LED ---- C
|                               |
+ baterie                   - baterie
```

Můžeme změřit:

### Napětí baterie

Sondy mezi plus a minus baterie.

Například:

\[
U_{bat} = 3{,}15\,V
\]

### Napětí na LED

Sondy přiložíme na obě nožičky LED.

Například:

\[
U_{LED} = 1{,}9\,V
\]

### Napětí na rezistoru

Sondy přiložíme na oba vývody rezistoru.

Například:

\[
U_R = 1{,}25\,V
\]

A zjistíme:

\[
3{,}15\,V \approx 1{,}9\,V + 1{,}25\,V
\]

## Co dětem říct

Lze intuitivně říct:

> „Na LED spadne asi 1,9 V a na rezistoru zbytek.“

Používá se pojem **úbytek napětí**.

Je ale dobré nezavést chybnou představu, že napětí je něco, co „teče“ obvodem a součástky ho spotřebují.

Přesnější formulace je:

> **Proud obvodem teče. Napětí je rozdíl potenciálů mezi dvěma místy.**

Když měříme napětí na LED, ptáme se:

> „Jaký je rozdíl elektrického potenciálu mezi jednou a druhou nožičkou LED?“

LED se chová jinak než obyčejný rezistor.

Když svítí, vzniká na ní přibližně určité napětí, kterému říkáme **forward voltage**, značené často \(V_f\).

Pro první hodinu není potřeba vysvětlovat polovodičovou fyziku LED.

---

# 8. Ohmův zákon znovu: proud vypočítáme z napětí na rezistoru

Toto je velmi pěkné propojení předchozích částí.

Předpokládejme:

- baterie: 3,15 V,
- LED: 1,90 V,
- rezistor: 1 kΩ.

Na rezistoru změříme:

\[
U_R = 1{,}25\,V
\]

Ohmův zákon použijeme na rezistor:

\[
I = \frac{U_R}{R}
\]

tedy:

\[
I = \frac{1{,}25\,V}{1000\,\Omega}
\]

\[
I = 0{,}00125\,A
\]

\[
I = 1{,}25\,mA
\]

## Důležitá myšlenka

Do Ohmova zákona pro rezistor nedáváme automaticky celé napětí baterie.

Použijeme **napětí, které je skutečně na rezistoru**.

To znamená, že umíme odhadnout proud i bez rozpojování obvodu:

1. změříme napětí na rezistoru,
2. známe jeho odpor,
3. vypočítáme proud.

Potom můžeme obvod rozpojit, vložit multimetr jako ampérmetr a ověřit, jestli vypočtená hodnota sedí.

To pěkně ukazuje rozdíl:

> **Napětí → obvod nechávám zapojený, měřím přes součástku.**

> **Proud → obvod rozpojím a multimetr vložím do cesty proudu.**

---

# 9. Rozsvítíme LED víc

**Čas:** 5–10 minut

Polož otázku:

> „Jak bychom mohli LED rozsvítit víc?“

Z předchozího experimentu by děti měly dojít k tomu:

> **menší odpor → větší proud → LED obvykle svítí více**

Například lze zkusit:

- 1 kΩ,
- 470 Ω,
- 390 Ω,
- případně 220 Ω, pokud je napětí zdroje a použitá LED vhodná.

U každého rezistoru lze:

1. změřit napětí na LED,
2. změřit napětí na rezistoru,
3. vypočítat proud podle
   \[
   I = \frac{U_R}{R}
   \]
4. případně proud skutečně změřit.

## Zajímavé pozorování

Napětí na LED se může měnit relativně málo, zatímco proud se mění výrazněji.

To je dobrá ochutnávka pro další lekce.

---

# 10. Pokud zbude čas: dvě LED v sérii a paralelně

Tato část je volitelná.

Není potřeba ji za každou cenu stihnout v první hodině.

## Dvě LED v sérii

Například:

```text
+ baterie
    |
 rezistor
    |
  LED 1
    |
  LED 2
    |
- baterie
```

Proud má jen jednu cestu.

Stejný proud prochází oběma LED.

### Otázky

> „Bude oběma LED téct stejný proud?“

Ano, protože jsou v jediné cestě.

> „Co se stane s napětím?“

Napětí zdroje se rozdělí mezi jednotlivé části obvodu.

Je možné změřit:

- napětí na první LED,
- napětí na druhé LED,
- napětí na rezistoru,
- napětí baterie.

Součet jednotlivých úbytků by měl přibližně odpovídat napětí zdroje.

### Praktické omezení

Pokud používáme pouze dvě 1,2V baterie, tedy přibližně 2,4–2,8 V, nemusí být napětí dostatečné pro dvě LED v sérii.

Například dvě červené LED mohou dohromady potřebovat kolem 3,6–4 V.

Modré nebo bílé LED potřebují obvykle ještě více.

Pokud tedy dvě LED v sérii nesvítí, nemusí být zapojení chybné. Zdroj pouze nemusí mít dostatečné napětí.

## Dvě LED paralelně

Zjednodušeně:

```text
            ┌── LED 1 ──┐
+ -- odpor --┤           ├-- -
            └── LED 2 ──┘
```

Proud má nyní více cest.

### Otázka

> „Co se stalo proti sériovému zapojení?“

Odpověď:

> Proud má dvě možné cesty a rozdělí se mezi jednotlivé větve.

### Důležitá poznámka

Pro LED není ideální dávat dvě LED jednoduše paralelně za jeden společný rezistor.

Kvůli rozdílům mezi LED se proud nemusí rozdělit rovnoměrně.

Jedna LED může mít trochu nižší forward voltage a „vzít si“ výrazně větší proud než druhá.

Lepší praktické zapojení je:

```text
             ┌── rezistor ── LED 1 ──┐
+ baterie ---┤                        ├--- - baterie
             └── rezistor ── LED 2 ──┘
```

Tedy **každá LED má vlastní sériový rezistor**.

To lze nechat jako otázku nebo experiment pro další hodinu.

---

# Co by si děti měly po první hodině pamatovat

Není nutné, aby uměly perfektně nazpaměť všechny transformace vzorců.

Důležitější jsou tyto myšlenky:

1. **Napětí \(U\)** měříme mezi dvěma místy a jeho jednotkou je volt.
2. **Proud \(I\)** říká, jaký elektrický proud obvodem prochází. Jednotkou je ampér, u malých obvodů často používáme mA.
3. **Odpor \(R\)** omezuje proud a měří se v ohmech.
4. Pro rezistor platí:
   \[
   U = R \cdot I
   \]
5. Prakticky často používáme:
   \[
   I = \frac{U}{R}
   \]
6. **Větší napětí → při stejném odporu větší proud.**
7. **Větší odpor → při stejném napětí menší proud.**
8. Napětí měříme **paralelně**, tedy přes dvě místa bez rozpojování obvodu.
9. Proud měříme **v sérii**, tedy obvod rozpojíme a multimetr vložíme do cesty.
10. Pokud je multimetr nastavený jako ampérmetr, **nikdy ho nepřipojujeme přímo mezi plus a minus baterie**.
11. Odpor měříme na nenapájené součástce.
12. LED vede proud pouze jedním směrem:
    - delší nožička = anoda (+),
    - kratší nožička = katoda (-).
13. LED má při svícení určitý úbytek napětí \(V_f\).
14. Rezistor u LED omezuje proud.
15. Napětí na jednotlivých součástkách v sériovém obvodu lze měřit a porovnat s napětím baterie.

---

# Hlavní pracovní návyk celé hodiny

Nejdůležitější princip celé lekce:

> **Nejdřív odhadnu, co se má stát. Potom to změřím.**

Děti by si měly postupně zvyknout:

1. něco předpovědět,
2. spočítat přibližný výsledek,
3. zapojit obvod,
4. změřit skutečné hodnoty,
5. porovnat teorii s realitou,
6. přemýšlet, proč se případně hodnoty trochu liší.

Tento způsob práce je důležitější než samotné zapamatování Ohmova zákona.

---

# Co zatím není potřeba probírat do hloubky

V první hodině není nutné detailně vysvětlovat:

- polovodičovou fyziku LED,
- Kirchhoffovy zákony jménem,
- výpočet paralelních odporů,
- vnitřní odpor baterie,
- výkon rezistoru,
- přesnou závislost proudu LED na napětí,
- sériové a paralelní zapojování baterií do detailu.

Pokud děti experimentují rychle a zbude čas, série a paralela LED jsou vhodný bonus.

Jinak je lepší první hodinu zakončit jednoduchým obvodem s jednou LED a opravdu dobře upevnit:

- co je napětí,
- co je proud,
- co je odpor,
- jak se jednotlivé veličiny měří,
- jak mezi nimi funguje Ohmův zákon.
