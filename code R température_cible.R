library(tidyverse)
library(lubridate)

##import dataset

data <- read.csv("chemin d'accès/document.csv", sep = ";")
names(data)

##Transformation et filtration des dates

data$datetime <- dmy_hm(data$datetime)
data <- data %>%
  filter(
    datetime >= dmy("14/11/2024"),
    datetime < dmy("11/06/2025")
  )

##Préparation des données à ggplot (lecture facilitée des dates/heures)

data_long <- data %>%
  pivot_longer(
    cols = c(T10m, P10m),
    names_to = "capteur",
    values_to = "temperature"
  )

##tracés de visualisation des plages de données en fonction du temps et des classes de température

ggplot(data_long, aes(x = datetime,
                      y = temperature,
                      color = capteur)) +
  
  geom_line() +
  
  labs(title = "Comparaison des deux capteurs",
       x = "Temps",
       y = "Température (°C)") +
  
  theme_minimal()


ggplot(
  data_long,
  aes(
    x = datetime,
    y = deltaT
  )
) +
  geom_point(alpha = 0.5) +
  geom_smooth(se = TRUE) +
  labs(
    title = expression(Delta*"T en fonction du temps"),
    x = "Temps",
    y = expression(Delta*"T (°C)")
  ) +
  theme_minimal()

ggplot(data,
       aes(x = factor(classe),
           y = deltaT)) +
  
  geom_boxplot() +
  
  labs(title = "Distribution de deltaT selon les classes de température",
       x = "Classe de température",
       y = "deltaT") +
  
  theme_minimal()


ggplot(data_long,
       aes(x = factor(classe),
           y = deltaT)) +
  
  geom_boxplot(outlier.shape = NA) +
  
  geom_jitter(width = 0.2,
              alpha = 0.3) +
  
  theme_minimal()

##Stats descriptives par classe

stats <- data %>%
  group_by(classe) %>%
  summarise(
    moyenne = mean(deltaT, na.rm = TRUE),
    mediane = median(deltaT, na.rm = TRUE),
    ecart_type = sd(deltaT, na.rm = TRUE),
    n = n()
  )

print(stats)

##Modélisation de deltaT en fonction de la classe de température
model <- lm(deltaT ~ classe, data = data)

summary(model)

ggplot(data,
       aes(x = classe,
           y = deltaT)) +
  
  geom_point(alpha = 0.4) +
  
  geom_smooth(method = "lm") +
  
  theme_minimal()

ggplot(data_long,
       aes(x = classe,
           y = deltaT)) +
  
  geom_point(alpha = 0.4) +
  
  geom_smooth() +
  
  theme_minimal()


##vérification de la normalité
qqnorm(data$deltaT)
qqline(data$deltaT)


##Méthode Bland-Altman pour comparer deux capteurs 

data$meanT <- (data$T10m + data$P10m)/2

bias <- mean(data$deltaT)

sd_delta <- sd(data$deltaT)

upper <- bias + 1.96 * sd_delta
lower <- bias - 1.96 * sd_delta

## Identification des points hors limites

data$outlier <- ifelse(
  data$deltaT > upper |
    data$deltaT < lower,
  "Hors limites",
  "Dans les limites"
)

##Tracé du graphique

ggplot(
  data,
  aes(
    x = meanT,
    y = deltaT
  )
) +
  
  annotate(
    "rect",
    xmin = -Inf,
    xmax = Inf,
    ymin = lower,
    ymax = upper,
    alpha = 0.10,
    fill = "grey70"
  ) +
  
  geom_point(
    aes(color = outlier),
    alpha = 0.6
  ) +
  
  geom_hline(
    yintercept = bias,
    color = "blue",
    linewidth = 1
  ) +
  
  geom_hline(
    yintercept = upper,
    color = "red",
    linetype = "dashed",
    linewidth = 1.2
  ) +
  
  geom_hline(
    yintercept = lower,
    color = "red",
    linetype = "dashed",
    linewidth = 1.2
  ) +
  
  annotate(
    "text",
    x = min(data_cible$meanT),
    y = bias,
    label = paste("Bias =", round(bias, 3)),
    hjust = 0,
    vjust = -0.5
  ) +
  
  annotate(
    "text",
    x = min(data_cible$meanT),
    y = upper,
    label = paste("Upper =", round(upper, 3)),
    hjust = 0,
    vjust = -0.5
  ) +
  
  annotate(
    "text",
    x = min(data_cible$meanT),
    y = lower,
    label = paste("Lower =", round(lower, 3)),
    hjust = 0,
    vjust = 1.5
  ) +
  
  labs(
    title = "Diagramme de Bland-Altman",
    x = "Température moyenne des deux capteurs (°C)",
    y = expression(Delta*"T (°C)")
  ) +
  
  theme_minimal()




