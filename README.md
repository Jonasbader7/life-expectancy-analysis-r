# Lebenserwartung und regionale Unterschiede in den USA

R-Analyse aus einer BFH-Gruppenarbeit im Modul Datenmanagement und Datenanalyse (WDDA), Klasse 2o, Gruppe 3.

**Team:** Bader, Jeckelmann, Marti, Fernando. **Beitrag von Jonas Bader laut Portfolio:** Analyseteil. Dieses Repository enthält die unveränderte eingereichte R-Datei und eine separat gekennzeichnete, reproduzierbare Portfolio-Fassung.

## Fragestellung

Wie hängen Lebenserwartung von Frauen im untersten Einkommensquartil, bedingt auf das Erreichen des Alters 40, regionaler Raucheranteil, 30-Tage-Mortalitätsindex und Haushaltseinkommen zusammen?

Untersucht werden 100 zusammengeführte US-Commuting-Zones. Die Daten sind regional aggregiert: Die Ergebnisse dürfen nicht als individuelle oder kausale Effekte interpretiert werden.

![Interaktion im multiplen Regressionsmodell](results/interaction.png)

## Nachgerechnete Ergebnisse

| Modell | Variablen | R² | Adjustiertes R² |
|---|---|---:|---:|
| M1 | Raucheranteil + Mortalitätsindex | 0,4155 | 0,4034 |
| M2 | M1 + Einkommen unter dem Stichprobenmittelwert | 0,4162 | 0,3980 |
| M3 | M2 + Interaktion Raucheranteil × Einkommensgruppe | 0,4636 | 0,4410 |

In M1 ist ein um zehn Prozentpunkte höherer Raucheranteil mit einer um rund 1,25 Jahre niedrigeren Zielvariable assoziiert, bei gleichem Mortalitätsindex. Der zusätzliche Einkommensgruppenkoeffizient in M2 ist nicht statistisch signifikant (p = 0,7254). In M3 unterscheidet sich die Steigung zwischen den Einkommensgruppen (Interaktion p = 0,00469). Das belegt weder einen kausalen Mechanismus noch individuelle gesundheitliche Wirkungen.

## Ausführen

Im Repository-Hauptverzeichnis:

```sh
Rscript scripts/analyse.R
```

Alternativ in RStudio das Arbeitsverzeichnis auf diesen Ordner setzen und `source('scripts/analyse.R')` ausführen. Die Portfolio-Fassung benötigt nur Base R. Geprüft mit R 4.4.2; Ergebnisse stehen in `results/`. Locale-Warnungen der lokalen R-Installation verhinderten die Berechnung nicht.

## Inhalt

- `original/`: unveränderte Abgabe und SHA-256-Prüfsummen der drei gelieferten Dateien.
- `data/`: gelieferte Excel-Dateien und daraus erzeugte CSV-Eingaben.
- `scripts/analyse.R`: portable Portfolio-Fassung mit Eingabeprüfungen und automatischem Ergebnisexport.
- `results/`: Modellzusammenfassungen, Modellgüte, Interaktionsgrafik und diagnostische Plots.

## Datenherkunft und Aufbereitung

Die gelieferten Dateien beziehen sich auf das Health Inequality Project. Die Originalabgabe beschreibt eine bereits erfolgte manuelle Excel-Aufbereitung; dies sind daher keine nachweislich unveränderten Rohdownloads. Verwendet werden `CZ Rankings - Levels` und `Online Data Table 10`. Für die CSV-Dateien wurden leere Spalten entfernt, Rand-Leerzeichen der Überschriften bereinigt und Zeilen ohne Regions-ID ausgelassen. Zahlen wurden nicht gerundet. Der Join erfolgt über `Commuting Zone ID`; doppelte IDs und fehlende Analysewerte werden geprüft. Die Einkommensschwelle ist der Mittelwert der 100 verbundenen Regionen (39 753,79 in der gelieferten Einkommenseinheit).

Die Veröffentlichungs- und Weiterverwendungsbedingungen der Quelldaten sind noch nicht unabhängig verifiziert. Es wird keine pauschale Open-Source-Lizenz für fremde Daten oder Gruppenbeiträge vergeben.

## Änderungen gegenüber der Abgabe

- Original unverändert erhalten; neue Fassung separat.
- CSV-Eingaben und relative Pfade statt Excel-Abhängigkeiten und interaktiver `View()`-Aufrufe.
- Drei zentrale Modelle unverändert nachgebildet; Ergebnisse automatisch exportiert.
- Interaktionslinien aus M3 bei konstantem mittlerem Mortalitätsindex statt zweier separater einfacher Regressionen.
- Raucheranteil in der Grafik korrekt in Prozent umgerechnet.
- Kausale Aussagen durch Aussagen über regionale Zusammenhänge ersetzt.

Ein Kommentar der Originalabgabe nennt für den Raucherkoeffizienten von M1 etwa -12,28; die gelieferten Daten ergeben -12,49092. Verbindlich für diese Portfolio-Fassung sind die neu berechneten Ergebnisse. VIF-Werte nahe eins wären kein Nachweis statistischer Unabhängigkeit. Diagnostische Plots allein belegen weder perfekte Modellannahmen noch externe Vorhersagequalität.

## Grenzen

Beobachtungsdaten, mögliche ausgelassene Einflussfaktoren, räumliche Abhängigkeit und Informationsverlust durch Dichotomisierung des Einkommens. Die ausgewiesene Modellgüte ist innerhalb der Stichprobe berechnet; keine externe Validierung. Der Mortalitätsindex ist kein direkter Nachweis einer bestimmten Versorgungsursache. Die automatische Portfolio-Fassung reproduziert die drei zentralen Modelle, nicht jede explorative Darstellung der ursprünglichen Abgabe.
