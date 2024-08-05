build_project:
	sh install_dependencies.sh

start_spark_time:
	spark-submit --driver-class-path build/ojdbc10.jar \
				--jars build/ojdbc10.jar \
				--conf "spark.driver.extraJavaOptions=-Duser.timezone=UTC" \
				--conf "spark.executor.extraJavaOptions=-Duser.timezone=UTC" \
				start_spark.py

start_spark_time_local:
	spark-submit --driver-class-path build/ojdbc10.jar \
				--jars build/ojdbc10.jar \
				--conf "spark.driver.extraJavaOptions=-Duser.timezone=Europe/Berlin" \
				--conf "spark.executor.extraJavaOptions=-Duser.timezone=Europe/Berlin" \
				start_spark.py

start_spark:
	spark-submit --driver-class-path build/ojdbc10.jar \
				--jars build/ojdbc10.jar \
				start_spark.py
