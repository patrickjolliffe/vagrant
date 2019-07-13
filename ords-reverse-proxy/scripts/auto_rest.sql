BEGIN
   ords.enable_object(
          p_schema => 'HR',
          p_object => 'EMPLOYEES'
       );
   COMMIT;
END;
/
