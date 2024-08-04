# PySpark Oracle Testing

Oracle Documentation: https://container-registry.oracle.com/ords/f?p=113:4:7985149474783:::4:P4_REPOSITORY,AI_REPOSITORY,AI_REPOSITORY_NAME,P4_REPOSITORY_NAME,P4_EULA_ID,P4_BUSINESS_AREA_ID:803,803,Oracle%20Database%20Express%20Edition,Oracle%20Database%20Express%20Edition,1,0&cs=3wGv7ZypOGpkNoobyJ8mO_s85vEj91tN3F8si2U8KvDnc4prXaxTFC2i-4cabvkSxWMm6hqnvb0AvZ-AqgJo7Fg

  $ docker exec -it <oracle-db> sqlplus / as sysdba
  $ docker exec -it <oracle-db> sqlplus sys/<your_password>@XE as sysdba
  $ docker exec -it <oracle-db> sqlplus system/<your_password>@XE
  $ docker exec -it <oracle-db> sqlplus pdbadmin/<your_password>@XEPDB1

If you want that the timezone is active you need to restart the database