
CREATE TABLE CAP_PYMT_BCKUP_HISTORY
(
CAP_PYMT_DT TIMESTAMP,
MBR_CK INTEGER
)
PARTITION BY RANGE(CAP_PYMT_DT)
INTERVAL(NUMTOYMINTERVAL(1, 'MONTH'))
(
PARTITION P0 VALUES LESS THAN
(TO_DATE('01-JAN-1990', 'DD-MON-YYYY'))
)
/
SELECT 
    A.TABLE_OWNER, 
    A.TABLE_NAME,
    A.PARTITION_NAME,
    A.PARTITION_POSITION,
    A.HIGH_VALUE,
    CASE 
        WHEN A.INTERVAL = 'YES' THEN
            B.INTERVAL
        ELSE
            NULL
    END AS INTERVAL
FROM
DBA_TAB_PARTITIONS A
INNER JOIN
DBA_PART_TABLES B
ON B.TABLE_NAME = A.TABLE_NAME AND
A.TABLE_NAME = 'CAP_PYMT_BCKUP_HISTORY'
/
INSERT INTO CAP_PYMT_BCKUP_HISTORY
VALUES(TO_TIMESTAMP('01-JAN-2018','DD-MON-YYYY'), 1000)
/
--To see the date range to go into this new partition
SELECT 
    TIMESTAMP' 2018-02-01 00:00:00' - NUMTOYMINTERVAL(1, 'MONTH') GRETEAR_THAN_EQ, /* This is the difference between High value and interval of the said partition */
    TIMESTAMP' 2018-02-01 00:00:00' LESS_THAN /* This would be the High Value of the partition */
FROM DUAL
/
INSERT INTO CAP_PYMT_BCKUP_HISTORY
VALUES(TO_TIMESTAMP('26-JAN-2018','DD-MON-YYYY'), 1000)
/
--Rename Table Partitions
DECLARE
    l_str varchar2(4000);
BEGIN
  FOR X IN ( SELECT A.PARTITION_NAME, A.TABLESPACE_NAME, A.HIGH_VALUE
             FROM USER_TAB_PARTITIONS A
             WHERE A.TABLE_NAME = 'CAP_PYMT_BCKUP_HISTORY'
             AND A.INTERVAL = 'YES'
             AND A.PARTITION_NAME LIKE 'SYS\_P%' ESCAPE '\' )
  LOOP
    EXECUTE IMMEDIATE
    'SELECT TO_CHAR( ' || X.HIGH_VALUE ||
    '-NUMTODSINTERVAL(1,''SECOND''), ''"PART_"YYYY_MM'' ) FROM DUAL'
    INTO l_str;
    EXECUTE IMMEDIATE
    'ALTER TABLE CAP_PYMT_BCKUP_HISTORY RENAME PARTITION "' ||
    X.PARTITION_NAME || '" TO "' || L_STR || '"';
  END LOOP;
END;
/