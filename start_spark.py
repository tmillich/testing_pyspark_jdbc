from pyspark import SparkConf
from pyspark.sql import SparkSession, SQLContext
from pyspark.sql.dataframe import DataFrame

URL = 'jdbc:oracle:thin:system/"123456"@localhost:1521/XE'
# USER: sys and system have more rights -> only with serivce name XE
SERVICE_NAME = "XE"
USER = "system"
PASSWORD = "123456"
DBTABLE = "system.test_table"
DRIVER = "oracle.jdbc.OracleDriver"
BUILD_PATH = "/workspaces/testing_pyspark/build/*"


def setupSpark() -> SparkSession:
    conf = SparkConf() \
        .setAppName("SarkTest") \
        .set("spark.driver.host", "127.0.0.1") \
        .set("spark.driver.extraClassPath", BUILD_PATH) \
        .set("spark.executor.extraClassPath", BUILD_PATH) \
        .set("spark.sql.session.timeZone", "Europe/Berlin")

    spark = SparkSession.builder.config(conf=conf).getOrCreate()

    sc = spark.sparkContext
    sc.setLogLevel("WARN")

    return spark


def readData(spark: SparkSession) -> DataFrame:
    jdbcDF = spark.read \
        .format("jdbc") \
        .option("url", URL) \
        .option("dbtable", DBTABLE) \
        .option("driver", DRIVER) \
        .option("preferTimestampNTZ", "true") \
        .option("oracle.jdbc.mapDateToTimestamp", "false") \
        .load()

    jdbcDF.show(truncate=False)

    return jdbcDF


def writeParquet(spark: SparkSession, df: DataFrame, local=True) -> None:
    df.write.parquet("build/test.parquet", mode="append")

    output_parquet = spark.read.parquet("build/test.parquet")
    output_parquet.show(truncate=False)


def main():
    spark = setupSpark()
    df = readData(spark)
    writeParquet(spark, df, local=True)


if __name__ == "__main__":
    main()
