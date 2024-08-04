from pyspark import SparkConf
from pyspark.sql import SparkSession, SQLContext

URL = 'jdbc:oracle:thin:system/"123456"@localhost:1521/XE'
# USER: sys and system have more rights -> only with serivce name XE
SERVICE_NAME = "XE"
USER = "system"
PASSWORD = "123456"
DBTABLE = "system.test_table"
DRIVER = "oracle.jdbc.OracleDriver"
BUILD_PATH = "/workspaces/testing_pyspark/build/*"


def main():
    conf = SparkConf() \
        .setAppName("SarkTest") \
        .set("spark.driver.host", "127.0.0.1") \
        .set("spark.driver.extraClassPath", BUILD_PATH) \
        .set("spark.executor.extraClassPath", BUILD_PATH) \
        .set("spark.sql.session.timeZone", "UTC")

    spark = SparkSession.builder.config(conf=conf).getOrCreate()

    sc = spark.sparkContext
    sql_context = SQLContext(sparkContext=sc)
    sc.setLogLevel("WARN")
    jdbcDF = spark.read \
        .format("jdbc") \
        .option("url", URL) \
        .option("dbtable", DBTABLE) \
        .option("driver", DRIVER) \
        .option("preferTimestampNTZ", "true") \
        .option("oracle.jdbc.mapDateToTimestamp", "false") \
        .load()

    jdbcDF.show(truncate=False)
    jdbcDF.write.parquet("build/test.parquet", mode="overwrite")
    output_parquet = spark.read.parquet("build/test.parquet")
    output_parquet.show(truncate=False)


if __name__ == "__main__":
    main()
