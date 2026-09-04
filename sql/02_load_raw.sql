USE HR_Analytics;
GO

TRUNCATE TABLE RAW.employees;
GO

BULK INSERT RAW.employees 
FROM "C:\Full_stack\Portfolio\Hr_attrition\data\raw\HR-Employee-Attrition.csv"
WITH (
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '\n',
    TABLOCK
)