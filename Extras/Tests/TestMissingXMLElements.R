# Test for Missing XML Elements
library(xml2)
library(magrittr)
old_config <- read_xml('Extras/Tests/data/old_config.xml')
old_config_items = old_config %>%
  xml_find_all("Value") %>%
  xml_attr('name')

# Figure out a way to automate extraction of old and new config.
new_config <- read_xml('Extras/Tests/data/new_config.xml')
new_config_items <- new_config %>%
  xml_find_all("Value") %>%
  xml_attr('name')

missing_in_new <- setdiff(old_config_items, new_config_items)

missing_in_config <- setdiff(old_config_items, names(config))
