SCB api
=======

Get data from SCB api

[API documentation](http://www.scb.se/Grupp/OmSCB/API/API-beskrivning.pdf)

## Install

```{r}
library(devtools)
install_github("junkka/scbapi")
```

## Building query

```{r}
library(scbapi)
r <- scb_api("ssd")
r
```

```{r}
scb_api("ssd/BE")
```

```{r}
scb_api("ssd/BE/BE0101")
scb_api("ssd/BE/BE0101/BE0101A")
```

## Retrive data

```{r}
r <- scb_api("ssd/BE/BE0101/BE0101A/FolkmangdTatortH")
res <- r$get()
```

## Inspect

```{r}
head(res)
```

## Format output

```{r}
library(dplyr)
library(tidyr)
library(stringr)

dd <- res %>% 
  gather(year, pop, Population.1960:Population.1980) %>% 
  mutate(
    year = str_extract(year, "[0-9]{4}") %>% as.integer(),
    county = str_extract(region, "[\\(\\) A-ZÅÄÖa-zåäö\\*]*$") %>% str_replace_all("[\\(\\)]", ""),
    pop = as.integer(pop)
  ) %>% tbl_df()
dd

ddd <- dd %>% 
  group_by(county, year) %>% 
  summarise(pop = sum(pop, na.rm = TRUE))
```


## Visualise

```{r, fig.height = 6, fig.width=8}
library(ggplot2)

ids <- sample(unique(ddd$county[ddd$year == 1965]), 4)
d <- ddd %>% filter(county %in% ids)
ggplot(d, aes(year, pop, color = county, group = county)) + geom_line() + 
  theme(legend.position = "bottom") + 
  theme_bw()
```


