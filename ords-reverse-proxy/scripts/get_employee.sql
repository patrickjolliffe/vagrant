CREATE OR REPLACE FUNCTION get_employee (
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