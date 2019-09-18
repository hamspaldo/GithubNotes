## Connect RStudio to Spark session
library(SparkR) # SparkR is contained in Databricks Runtime, but you must load it into RStudio. 
sparkR.session()
# use sparklyr # . Run the following code inside RStudio to initialize a sparklyr session.
library(sparklyr)
sc <- spark_connect(method = "databricks")
# spark_disconnect(sc)

## Importing Data
# works for df that is numbers...see str(iris)
iris_tbl <- copy_to(sc, iris)

# get some data into a df
library(readxl)
SHEM_IM_SftyCod <- read_excel("~/R/SHEM_IM_SftyCod.xlsx") %>% as.data.frame()
class(SHEM_IM_SftyCod) # is a df, tibble won't import to spark

SHEM_IM_SftyCod_tbl <- copy_to(sc, SHEM_IM_SftyCod)
names(SHEM_IM_SftyCod)
SHEM_IM_SftyCod <- SHEM_IM_SftyCod %>% select(1:5, "Kilometrage", "Organisational Unit ID", "Safety Coding")
str(SHEM_IM_SftyCod) 
SHEM_IM_SftyCod_tbl <- copy_to(sc, SHEM_IM_SftyCod) #copies successfully. overwrites automatically.


# queries on spark cluster
library(dplyr)
iris_summary <- iris_tbl %>% 
  mutate(Sepal_Width = ROUND(Sepal_Width * 2) / 2) %>% # Bucketizing Sepal_Width
  group_by(Species, Sepal_Width) %>% 
  summarize(count = n(), Sepal_Length = mean(Sepal_Length), stdev = sd(Sepal_Length)) %>% collect

## partition Training and Test 
partition_iris_tbl <- sdf_partition(
  iris_tbl,training=0.5, testing=0.5)
sdf_register(partition_iris_tbl,
             c("spark_iris_training","spark_iris_test")) # registers the hive metadata for the two tables

tidy_iris <- tbl(sc,"spark_iris_training") %>%
  select(Species, Petal_Length, Petal_Width)
tidy_iris %>% collect() 

model_iris <- tidy_iris %>%
  ml_decision_tree(response="Species",
                   features=c("Petal_Length","Petal_Width"))

test_iris <- tbl(sc,"spark_iris_test")
pred_iris <- ml_predict(
  model_iris, test_iris) %>%
  collect
library(ggplot2)
library(dplyr)
pred_iris %>%
  inner_join(data.frame(pred_iris$predicted_label)) %>%
  ggplot(aes(Petal_Length, Petal_Width, col=lab)) +
  geom_point()

data.frame(prediction=0:2,
           lab=model_iris$model.parameters$labels)


#SHEM_IM_SftyCod_tbl <- sdf_copy_to(sc, SHEM_IM_SftyCod) # doesn't work
#SHEM_IM_SftyCod_tbl <- copy_to(sc, SHEM_IM_SftyCod) # doesn't work
?sdf_copy_to()
spark_disconnect(sc)


str(iris)
str(SHEM_IM_SftyCod)
