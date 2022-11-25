/* TASK 1 */

--Какие сотрудники получают заработную плату в размере большем, чем их
--непосредственные руководители.

--Отчет должен содержать следующие показатели:
--- Имя работника
--- Должность работника
--- ЗП работника
--- Имя непосредственного руководителя работника
--- Должность непосредственного руководителя работника
--- ЗП непосредственного руководителя работника


SELECT 
  e.FIRST_NAME, 
  j.JOB_TITLE, 
  e.salary,
  em.LAST_NAME, 
  jm.JOB_TITLE, 
  em.SALARY 
FROM 
  EMPLOYEES e 
  JOIN JOBS j ON e.JOB_ID = j.JOB_ID 
  JOIN EMPLOYEES em on e.MANAGER_ID = em.EMPLOYEE_ID  and e.SALARY > em.SALARY
  JOIN JOBS jm ON em.JOB_ID = jm.JOB_ID;




/* TASK2 */
--какие сотрудники получают максимальную в рамках своего отдела ЗП

--Отчет должен содержать следующие показатели:
--- Имя работника
--- Название отдела
--- Должность работника
--- ЗП работника (максимальная ЗП в отделе)

SELECT 
  * 
FROM 
  (
    SELECT 
      e.FIRST_NAME, 
      d.DEPARTMENT_NAME, 
      e.SALARY, 
      e.DEPARTMENT_ID, 
      j.JOB_TITLE, 
      first_value(e.SALARY) OVER(PARTITION BY d.DEPARTMENT_ID ORDER BY e.SALARY DESC) as MAX_SALARYO 
    FROM 
      EMPLOYEES e 
      JOIN DEPARTMENTS d ON e.DEPARTMENT_ID = d.DEPARTMENT_ID 
      JOIN JOBS j ON e.JOB_ID = j.JOB_ID
  ) 
WHERE 
  MAX_SALARYO = SALARY;

/*   TASK 3   */
--Требуется создать отчет, который будет максимально полно описывать состояние каждого из отделов.
--
--Отчет должен содержать следующие показатели (минимально необходимый перечень):
--- ID отдела
--- Название отдела
--- Рейтинг отдела по средней ЗП среди всех отделов организации
--- Имя руководителя отдела
--- Количество работников в отделе
--- Средняя ЗП по отделу
--- Медианная ЗП по отделу
--- Минимальная ЗП по отделу
--- Максимальная ЗП по отделу
--- Процент, на который минимальная ЗП по отделу отличается от средней ЗП отдела
--- Процент, на который максимальная ЗП по отделу отличается от средней ЗП отдела

SELECT 
    s.DEPARTMENT_ID, 
    s.DEPARTMENT_NAME, 
    s.DEP_BOSS,
    s.average_Salary,
    DENSE_RANK() OVER(ORDER BY s.average_Salary DESC) rating_by_sales,
    s.median_Salary,
    s.min_Salary, 
    s.max_Salary, 
    CONCAT(ROUND(1-s.min_Salary/s.average_Salary,2) * 100, '%') diff_min_avg,
    CONCAT(ROUND(s.max_Salary/s.average_Salary-1,2) * 100, '%') diff_max_avg
FROM(
    SELECT 
        d.DEPARTMENT_ID, 
        d.DEPARTMENT_NAME, 
        e.SALARY, 
        em.EMPLOYEE_ID DEP_BOSS,
        ROUND(AVG(e.SALARY) OVER(PARTITION BY d.DEPARTMENT_ID), 2) average_Salary,
        ROUND(MEDIAN(e.SALARY) OVER(PARTITION BY d.DEPARTMENT_ID), 2) median_Salary,
        MAX(e.SALARY) OVER(PARTITION BY d.DEPARTMENT_ID) max_Salary,
        MIN(e.SALARY) OVER(PARTITION BY d.DEPARTMENT_ID) min_Salary  
    FROM DEPARTMENTS d
    JOIN EMPLOYEES e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID
    LEFT JOIN EMPLOYEES em ON d.MANAGER_ID = em.EMPLOYEE_ID
) s;

/* TASK 4 */

--Отделу кадров необходимо создать отчет в котором будут отражены сотрудники, которые работают в организации дольше всех (в рамках
--своего департамента)

--Отчет должен содержать следующие показатели:
--- Название департамента
--- Имя/фамилия сотрудника, который работает дольше всех в
--департаменте
--- Срок работы сотрудника, который работает в департаменте дольше
--всех
--- Срок работы сотрудника, который работает в департаменте меньше
--всех


SELECT 
    DISTINCT d.DEPARTMENT_NAME,
    FIRST_VALUE(e.LAST_NAME)
        OVER(PARTITION BY d.DEPARTMENT_ID ORDER BY e.HIRE_DATE) oldest_person,
    FIRST_VALUE(ROUND((trunc(sysdate) - e.HIRE_DATE)/365, 2))
        OVER(PARTITION BY d.DEPARTMENT_ID ORDER BY e.HIRE_DATE) oldest_person_worktime,
    FIRST_VALUE(ROUND((trunc(sysdate) - e.HIRE_DATE)/365, 2))
        OVER(PARTITION BY d.DEPARTMENT_ID ORDER BY e.HIRE_DATE DESC) newest_person_worktime
FROM DEPARTMENTS d
JOIN EMPLOYEES e ON d.DEPARTMENT_ID = e.DEPARTMENT_ID;