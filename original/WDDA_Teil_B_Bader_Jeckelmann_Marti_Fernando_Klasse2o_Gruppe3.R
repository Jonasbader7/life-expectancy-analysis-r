# Projekt WDDA Teil B, Datenanalyse

# Die Excel Dateien wurden dazu hochgeladen. Der Pfad zum einlesen muss angepasst werden, damit der Code funktioniert!

  # Schritt 1: Definition der Variablen (Klasse 2o, Gruppe 3)
        # Zielvariable: Q1 Life Expectancy at Age 40 (Race-Adjusted) Women
            #Zielvariable kommt aus health_ineq_local_rankings
        # Variable 2: BRFSS: Fraction Current Smokers in Q1
            #Variable 2 kommt aus health_ineq_online_tables, Online Data Table 10
        # Variable 3: 30-day Mortality Rate Index
            #Variable 3 kommt ebenfalls aus Online Data Table 10
        # Wirtschaftliche Variable: Mean Household Income
            #Wirtschaftliche Variable kommt ebenfalls aus Online Data Table 10
        # Analyseebene: Commuting Zone (CZ)

  # Schritt 2: Vorbereitung der health_ineq_local_rankings Excel-Datei
        # Nur das Blatt "CZ Rankings - Levels" wird verwendet
        # Nicht benötigte Spalten (z.B. männliche Daten) wurden entfernt
        # Überschriften aus Zeile 3 + 4 in Zeile 4 zusammengeführt
        # Alle Zeilen oberhalb Zeile 4 gelöscht
        # Datei neu abgespeichert als health_ineq_local_rankings.xlsx

  # Schritt 3: Vorbereitung der health_ineq_all_online_tables Excel-Datei
        # Nur Blatt "Online Data Table 10" wird benötigt (für Raucheranteil und Mortalitätsrate)
        # Nicht benötigte Blätter gelöscht
        # Überschriften aus Zeile 3 + 4 in Zeile 4 zusammengeführt
        # Alle Zeilen oberhalb Zeile 4 gelöscht
        # Datei neu abgespeichert als health_ineq_all_online_tables.xlsx

  
  # Schritt 4: Einlesen der Daten
        library(readxl)
        library(dplyr)
        library(car)
        library(tidyverse)
        library(rgl)
        # Wichtig beim einlesen: Eigenen Pfad verwenden + umbennen in local_rankings
        local_rankings <- read_excel("Projekt Datenanalyse/health_ineq_local_rankings.xlsx")
        View(local_rankings)
        # Wichtig beim einlesen: Eigenen Pfad verwenden + umbennen in table 10 + sheet auswählen!
        table10 <- read_excel("Projekt Datenanalyse/health_ineq_all_online_tables.xlsx", 
                              sheet = "Online Data Table 10")
        View(table10)        
  # Schritt 5: Zusammenführen der Tabellen (über Commuting Zone ID)
        data_model <- merge(table10, local_rankings, by = "Commuting Zone ID")
        # Um das ganze nun noch etwas übersichtlicher zu machen, werden kürzere Variablennamen vergeben:
        data_model <- rename(data_model,
           LE40W = `Q1 Life Expectancy at Age 40 (Race-Adjusted) Women`,
           SmokersQ1 = `Current Smokers in Q1`,
           MortRate30 = `30-day Mortality Rate Index`,
           HHIncome = `Mean Household Income`)  
        
  # Schritt 6: Streudiagramme erstellen zur ersten visuellen Kontrolle
        # Kurz lineares Modell erstellen um später mit coef die Analyse der Streudiagramme zu haben
            smoke_mod <- lm(LE40W ~ SmokersQ1, data = data_model)
            mort_mod <- lm(LE40W ~ MortRate30, data = data_model)
        
        # Streudiagramme erstellen
            plot(data_model$SmokersQ1, data_model$LE40W,
                main = "Lebenserwartung vs. Raucheranteil",
                 xlab = "Anteil Raucher in Q1 in %",
                 ylab = "Lebenserwartung (Frauen, Alter 40)")
            abline(smoke_mod, col = "red")
            
            plot(data_model$MortRate30, data_model$LE40W,
                 main = "Lebenserwartung vs. 30-Tage Mortalitätsrate",
                 xlab = "30-Tage Mortalitätsrate",
                 ylab = "Lebenserwartung (Frauen, Alter 40)")
            abline(mort_mod, col = "red")
        
        # Analyse der Streudiagramme
            coef(smoke_mod)
            coef(mort_mod)
            # Raucheranteil: Hat einen stark negativen Zusammenhang
                            # je höher, desto deutlich geringere Lebenserwartung
                            # -12.28 Jahre bei Anstieg um eine Einheit
            # Mortalitätsrate: Hat einen schwachen negativen Zusammenhang
                            # geringerer Einfluss auf die Lebenserwartung
                            # -0.21 Jahre bei Anstieg um eine Einheit
        # Analyse der Korrelationskoeffizienten
            cor(data_model$LE40W, data_model$SmokersQ1)
            cor(data_model$LE40W, data_model$MortRate30)
            # Die Korrelationskoeffizienten von -0.61 und -0.17 bestätigen die Einschätzung der Streudiagramme
            
        # Weitere Analyse der Verteilung der Variablen
            hist(data_model$LE40W, main = "Histogramm Lebenserwartung", xlab = "Lebenserwartung", col = "lightgray")
            hist(data_model$SmokersQ1, main = "Histogramm Raucheranteil Q1", xlab = "Raucheranteil", col = "lightgray")
            hist(data_model$MortRate30, main = "Histogramm Mortalitätsrate", xlab = "Mortalitätsrate", col = "lightgray")
        # 3D-Scatterplot der drei Variablen
            scatter3d(x = data_model$SmokersQ1,
                      y = data_model$LE40W,
                      z = data_model$MortRate30,
                      xlab = "Anteil Raucher in Q1 (%)",
                      ylab = "Lebenserwartung Frauen (Alter 40)",
                      zlab = "30-Tage Mortalitaetsrate",
                      surface = TRUE)  # zeigt Regressionsfläche     
            
  # Schritt 7: Modell 1 – Lebenserwartung ~ Raucheranteil + Mortalitätsrate
        model1 <- lm(LE40W ~ SmokersQ1 + MortRate30, data = data_model)
        summary(model1)
        confint(model1)
        # Analyse und Interpretation der Koeffizienten und des Konfidenzintervalls
            # Modell 1 zeigt, dass ein höherer Raucheranteil im Quartil 1 signifikant mit einer niedrigeren Lebenserwartung
            # bei Frauen ab 40 Jahren verbunden ist (ca. -12.28 Jahre pro Einheit Anstieg).
            # Auch die 30-Tage Mortalitätsrate hat einen signifikant negativen, aber schwächeren Einfluss.
            # Das Modell erklärt ca. 41,5 % der Varianz der Lebenserwartung (adjusted R² = 0,40) und ist insgesamt sehr signifikant.
          
  # Schritt 8: Modell 2 – + Wirtschaftliche Variable (Haushaltseinkommen)
        # Berechnung des durchschnittlichen Haushaltseinkommens
        durchschnitts_einkommen <- mean(data_model$HHIncome)
        # Erzeugung einer neuen Variable mit 1 = unter Durchschnitt, ansonsten 0
        data_model$unter_durchschnitt <- ifelse(data_model$HHIncome < durchschnitts_einkommen, 1, 0)
      
        model2 <- lm(LE40W ~ SmokersQ1 + MortRate30 + unter_durchschnitt, data = data_model)
        summary(model2)
        confint(model2)
        # Analyse und Interpretation Modell 2:
            # Raucheranteil (SmokersQ1) bleibt hochsignifikant negativ mit ca. -12.42 Jahren pro Einheit Anstieg.
            # Die 30-Tage Mortalitätsrate (MortRate30) ist weiterhin signifikant negativ, aber mit etwas geringerem Effekt (-0.24).
            # Die Variable 'unter_durchschnitt' (Haushaltseinkommen unter Durchschnitt) ist nicht signifikant (p = 0.73),
            # ihr Einfluss auf die Lebenserwartung ist statistisch nicht nachweisbar.
            # Das Modell erklärt knapp 41,6 % der Varianz der Lebenserwartung (adjusted R² = 0.40),
            # also nur minimal besser als Modell 1.
            # Das Konfidenzintervall von 'unter_durchschnitt' umfasst 0, was den nicht signifikanten Effekt bestätigt.
            # Insgesamt zeigt Modell 2, dass Rauchen und Mortalitätsrate die wichtigsten Prädiktoren bleiben,
            # während die einfache Einteilung des Einkommens in unter/über Durchschnitt keinen zusätzlichen Erklärungswert bringt.
        
  
  # Schritt 9: Multikollinearität prüfen (VIF)
        print(vif(model1))
        print(vif(model2))
        #Da die VIF Werte nahe 1 sind, kann man Multikollinearität ausschliessen in beiden Modellen.
        #Bedeutet die Variablen sind statistisch gut unabhängig voneinander.
  # Schritt 10: Regressionskoeffizienten anzeigen
        coef(model1)
        coef(model2)
        #Die Analyse der Koeffizienten erfolgte bereits in den Schritten davor.
  
  # Schritt 11: Modellgüte und Residuenanalyse
        # Histogramm der Residuen
          hist(resid(model1), main = "Residuen Modell 1", xlab = "Residuen")
          hist(resid(model2), main = "Residuen Modell 2", xlab = "Residuen")
          # Die Histogramme zeigen, dass die Residuen beider Modelle annähernd normalverteilt sind.
          # Das spricht für eine gute Modellanpassung und erfüllt eine wichtige Annahme der linearen Regression.
      
        # Residuen vs. Vorhersagewerte
          plot(resid(model1) ~ predict(model1), main = "Residuen vs. Vorhersage Modell 1")
          abline(h = 0, col = "red")
          
          plot(resid(model2) ~ predict(model2), main = "Residuen vs. Vorhersage Modell 2")
          abline(h = 0, col = "red")
          # Die Abweichungen (Residuen) verteilen sich zufällig um null.
          # Es gibt keine sichtbaren Muster, was gut für das Modell ist.
          
        # Kalibrierungsplots
          plot(data_model$LE40W ~ predict(model1), main = "Kalibrierungsplot Modell 1",
               xlab = "Vorhergesagte Lebenserwartung", ylab = "Beobachtete Lebenserwartung")
          abline(0, 1, col = "blue")
          
          plot(data_model$LE40W ~ predict(model2), main = "Kalibrierungsplot Modell 2",
               xlab = "Vorhergesagte Lebenserwartung", ylab = "Beobachtete Lebenserwartung")
          abline(0, 1, col = "blue")
          # Die Kalibrierungsplots zeigen, wie gut die vorhergesagten Werte mit den echten Werten übereinstimmen.
          # Je näher die Punkte an der blauen Linie (45-Grad-Linie) liegen, desto besser passt das Modell.
          # Beide Modelle zeigen eine gute Übereinstimmung zwischen Vorhersage und Beobachtung.
          
        # R² Werte
          model1_R2 <- summary(model1)$r.squared
          model2_R2 <- summary(model2)$r.squared
          # Modell 1 erklärt ca. 41,5 % der Varianz der Lebenserwartung.
          # Modell 2 verbessert die Erklärung minimal auf ca. 41,6 %.
          # Das zeigt, dass die zusätzliche Variable Einkommen kaum Mehrwert bringt
          # und beide Modelle eine ähnliche Vorhersagekraft haben.
      
        # Konfidenzintervalle der Koeffizienten
          confint(model1)
          confint(model2)
          # Die Konfidenzintervalle zeigen, dass die Effekte von Raucheranteil und Mortalitätsrate
          # in beiden Modellen sicher negativ sind (da die Intervalle keine Null enthalten).
          # Die Variable 'unter_durchschnitt' im Modell 2 ist nicht signifikant, 
          # da ihr Konfidenzintervall Null einschliesst.
      
        # Residuenplots (Diagnostik)
          # Residuen vs. Vorhersagewerte (Fitted) mit besserer Beschriftung
          plot(predict(model1), resid(model1),
               main = "Residuen vs. Vorhersage Modell 1",
               xlab = "Vorhergesagte Werte",
               ylab = "Residuen",
               pch = 16, col = "blue")
          abline(h = 0, col = "red", lty = 2)
          
          plot(predict(model2), resid(model2),
               main = "Residuen vs. Vorhersage Modell 2",
               xlab = "Vorhergesagte Werte",
               ylab = "Residuen",
               pch = 16, col = "darkgreen")
          abline(h = 0, col = "red", lty = 2)
          
          # Boxplots der Residuen für zusätzliche Verteilungsinfo
          boxplot(resid(model1),
                  main = "Boxplot der Residuen Modell 1",
                  ylab = "Residuen",
                  col = "lightblue")
          
          boxplot(resid(model2),
                  main = "Boxplot der Residuen Modell 2",
                  ylab = "Residuen",
                  col = "lightgreen")
          
          # Interpretation der Residuenplots und Boxplots:
          # Die Residuen verteilen sich zufällig um die Null-Linie, ohne erkennbare Muster,
          # was eine gute Modellanpassung und die Erfüllung der Homoskedastizitäts-Annahme unterstützt.
          # Die Punkte sind relativ gleichmäßig verteilt und zeigen keine systematischen Abweichungen.
          # Die Boxplots bestätigen, dass die Residuen überwiegend symmetrisch um Null liegen,
          # wenige Ausreißer vorhanden sind und die Verteilung der Fehler annähernd normal ist.
          # Beide Modelle erfüllen somit wichtige Voraussetzungen der linearen Regression,
          # was auf zuverlässige und valide Ergebnisse hinweist.
          
    # Schritt 11b: Wechselwirkung zwischen Rauchen und Einkommen testen
          model_interaction <- lm(LE40W ~ SmokersQ1 * unter_durchschnitt + MortRate30, data = data_model)
          summary(model_interaction)
          # Visualisierung der Wechselwirkungen
              plot(data_model$SmokersQ1, data_model$LE40W,
                   col = ifelse(data_model$unter_durchschnitt == 1, "red", "blue"),
                   pch = 16,
                   xlab = "Raucheranteil in Q1",
                   ylab = "Lebenserwartung Frauen (40+)",
                   main = "Interaktion: Raucheranteil x Einkommen")
              legend("topright", legend = c("Einkommen unter Durchschnitt", "Einkommen über Durchschnitt"),
                     col = c("red", "blue"), pch = 16)
              model_low <- lm(LE40W ~ SmokersQ1, data = data_model[data_model$unter_durchschnitt == 1, ])
              model_high <- lm(LE40W ~ SmokersQ1, data = data_model[data_model$unter_durchschnitt == 0, ])
              
              abline(model_low, col = "red", lwd = 2)
              abline(model_high, col = "blue", lwd = 2)
        # Analyse der Wechselwirkung
            # Der signifikante Interaktionseffekt zwischen Raucheranteil (SmokersQ1) und Einkommen (unter_durchschnitt) zeigt,
            # dass der negative Effekt von Rauchen auf die Lebenserwartung nicht überall gleich ist.
            # Konkret bedeutet das:
            # - In Regionen mit Haushaltseinkommen über dem Durchschnitt ist der negative Effekt des Rauchens auf die Lebenserwartung
            #   stärker ausgeprägt.
            # - In ärmeren Regionen (unter dem Durchschnitt) ist der negative Einfluss von Rauchen etwas geringer.
            #
            # Mögliche Gründe:
            # 1. In ärmeren Regionen sind bereits weitere negative Faktoren wie schlechtere Gesundheitsversorgung oder Umweltbelastungen vorhanden,
            #    die die Lebenserwartung drücken. Deshalb fällt der zusätzliche Effekt des Rauchens relativ geringer aus.
            # 2. Die Lebenserwartung in ärmeren Gebieten ist bereits niedriger, wodurch Rauchen nicht mehr so viel „zusätzlichen Schaden“ anrichtet.
            # 3. Es können auch unerfasste Faktoren oder Messungenauigkeiten eine Rolle spielen.
            #
            # Wichtig ist, dass diese Wechselwirkung zeigt, dass sozioökonomische Bedingungen die gesundheitlichen Auswirkungen von Risikofaktoren wie Rauchen modulieren.
              
  # Schritt 12: Interpretation
      # Die Analyse zeigt, dass Rauchen und schlechte medizinische Versorgung 
      # bei Frauen ab 40 Jahren deutlich mit einer niedrigeren Lebenserwartung 
      # verbunden sind. Haushaltseinkommen als einfache binäre Variable (unter/über Durchschnitt) 
      # hat in diesem Modell keinen signifikanten Einfluss auf die Lebenserwartung. 
      # Die Wechselwirkungsanalyse zeigt jedoch, dass der negative Effekt von Rauchen
      # durch das Einkommensniveau beeinflusst wird. In reicheren Regionen wirkt Rauchen stärker
      # lebensverkürzend als in ärmeren Regionen.

 