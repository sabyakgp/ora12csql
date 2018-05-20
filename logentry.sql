BEGIN
  DBMS_ERRLOG.create_error_log (dml_table_name => 'T2EXCP');
END;