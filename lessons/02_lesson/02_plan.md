# Plán druhé hodiny

- zopakování: proud, napětí, odpor; měření multimetrem; zapojení diody, jako minule
- neměřili jsme napětí a proud přes multimetr, takže by bylo fajn ukázat, že napětí se na součástkách "ztrácí" a že proud se měří v zapojeném obvodu
  - Napětí se vlastně neztrácí. Říkáme, že na součástce nastane úbytek napětí. Když obejdeme celý obvod, všechny úbytky musí dohromady odpovídat tomu, co přidal zdroj.
- zapojení paralelní a sériové - v sériovém obvodu teče všemi součástkami stejný proud a zároveň musí platit, že součet všech úbytků napětí se rovná napětí zdroje; 
  - Série: stejný proud, úbytky napětí se sčítají.
  - Paralela: stejné napětí, proudy ve větvích se sčítají.
  - poznámka 2 kirchhoffovy zákony - Kolik proudu do uzlu přiteče, tolik z něj musí odtéct. (v uzklu, kde se vodiče rozdělují či spojují, např. při paralelním zapojení) + Součet zvýšení a poklesů napětí kolem celé smyčky je nula (Napětí zdroje se musí rovnat součtu úbytků napětí na součástkách); Ohmův zákon a Kirchhoffovy zákony spolupracují. Kirchhoff ti řekne, jak se musí chovat proudy a napětí v celém obvodu, a Ohmův zákon ti pro rezistor propojí konkrétní `U`, `I` a `R`.
- zapojení diody přes microbit - 2 způsoby ,jednou přivádí 3.5 voltu přímo microbit, podruhé přivádí proud baterie vedle a microbit pouze spíná okruh (měli bychom mít relé)
- zkusit programování luanti worldu