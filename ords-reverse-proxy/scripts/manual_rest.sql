CREATE OR REPLACE FUNCTION hr.get_employee (
    employee_id IN NUMBER
) RETURN SYS_REFCURSOR AS
    employee_record SYS_REFCURSOR;
BEGIN
    OPEN employee_record FOR SELECT
                                 *
                             FROM
                                 employees
                             WHERE
                                 employee_id = get_employee.employee_id;

    RETURN employee_record;
END;
/
BEGIN
   ords.define_module(   p_module_name      => 'demo',
                         p_base_path        => '/demo/');                  
END;
/

BEGIN       
   ords.define_template( p_module_name       => 'demo',
                         p_pattern           => 'get_employee/:employee_id');

   ords.define_handler(  p_module_name       => 'demo',
                         p_pattern           => 'get_employee/:employee_id',
                         p_method            => 'GET',
                         p_source_type       => ORDS.source_type_plsql,
                         p_source            => 
                            'BEGIN :record := get_employee(:employee_id); END;');

   ords.define_parameter( p_module_name        => 'demo',
                          p_pattern            => 'get_employee/:employee_id',
                          p_method             => 'GET',
                          p_name               => 'record',
                          p_bind_variable_name => 'record',
                          p_source_type        => 'RESPONSE',
                          p_param_type         => 'RESULTSET',
                          p_access_method      => 'OUT');
   COMMIT;
END;
/

BEGIN
   ords.define_template( p_module_name       => 'demo',
                         p_pattern           => 'get_employee');

   ords.define_handler(  p_module_name       => 'demo',
                         p_pattern           => 'get_employee',
                         p_method            => 'POST',
                         p_source_type       => ORDS.source_type_plsql,
                         p_source            =>
                            'BEGIN :record := get_employee(:employee_id); END;');

   ords.define_parameter( p_module_name        => 'demo',
                          p_pattern            => 'get_employee',
                          p_method             => 'POST',
                          p_name               => 'record',
                          p_bind_variable_name => 'record',
                          p_source_type        => 'RESPONSE',
                          p_param_type         => 'RESULTSET',
                          p_access_method      => 'OUT');
   COMMIT;
END;
/
EXIT;