
-- TITANIC DATASET ANALYSIS PROJECT WITH SQL
-- Created by Elijah Aremu  on 22/04/2024
-- An SQL PROJECT (DA ANALYTICS)

-- Creating a backup of the table before beginning the analysis
 
SELECT * INTO titanic_data_backup
FROM titanic_data;

-- IDENTIFY MISSING VALUE

/*
here is the count of missing values for each column:

PassengerId: 0 missing values
Survived: 0 missing values
Pclass: 0 missing values
Name: 0 missing values
Sex: 0 missing values
Age: 177 missing values
SibSp: 0 missing values
Parch: 0 missing values
Ticket: 0 missing values
Fare: 0 missing values
Cabin: 687 missing values
Embarked: 2 missing values
*/

/*
Handling Missing Values for Age:
The methodology used is Imputation: 
The approach used here is to impute missing values with the mean, median, or mode of the age distribution. This ensures that we retain all records for analysis without significantly altering the overall distribution of ages. We can calculate the mean or median age and use that value to replace missing entries.
Using Median Age , the median age of passengers is 29.6991176470405
*/
(SELECT AVG(Age) FROM titanic_data WHERE Age IS NOT NULL)
 

-- Performing the update:
-- Handle missing values for Age by imputing with median age rounded to one decimal place
UPDATE titanic_data
SET Age = ROUND(
    (SELECT AVG(Age) FROM titanic_data WHERE Age IS NOT NULL),
    1
)
WHERE Age IS NULL;
 

-- There are ages like this with more than 1 decimal precision, Now let’s ensure precision.
-- Ensure consistent precision for all ages in the 'Age' column
UPDATE titanic_data
SET Age = ROUND(Age, 1);
 
/*
Handling Missing Values for Cabin:
Though there are significant number of missing values for Cabin column, it is not required in our analysis. 
The column can either  be dropped or we can create a new category for missing values (e.g., 'Unknown').
*/

-- Handle missing values for Cabin by assigning a new category 'Unknown'
UPDATE titanic_data
SET Cabin = 'Unknown'
WHERE Cabin IS NULL;
 
/*
Handling Missing Values for Embarked:
For the two missing values in the 'Embarked' column, we can impute them with the mode (most frequent value) of the 'Embarked' column since there are only two missing values. 
*/
-- Handle missing values for Embarked by imputing with the mode
UPDATE titanic_data
SET Embarked = (
    SELECT TOP 1 Embarked 
    FROM titanic_data 
    WHERE Embarked IS NOT NULL 
    GROUP BY Embarked 
    ORDER BY COUNT(*) DESC
)
WHERE Embarked IS NULL;



/* 
Looking closely at the Cabin column, some rows have more than 1 value, such as rows 28, 89, 98 etc
 

So after much thoughts and considerations, it appears that the Cabin column is not useful in the analysis. So we can either drop the column entirely or simply clean out the cabin records with multiple cabin values,leaving only the first value. And then treating "Unknown" as a separate category.
*/
-- Update the Cabin column to retain only the first value
UPDATE titanic_data
SET Cabin = SUBSTRING(Cabin, 1, CHARINDEX(' ', Cabin + ' ') - 1)
WHERE CHARINDEX(' ', Cabin) > 0;


-- Survival Analysis:
    -- A.	Calculate the overall survival rate of passengers.
    SELECT 
        CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate
    FROM 
        titanic_data;

    -- The survival rate of approximately 38.38% indicates that around 38.38% of the passengers in the dataset survived the Titanic disaster.   

    -- B.	Analyze survival rates based on factors such as gender, age, and passenger class by filtering and grouping your data accordingly.
            
        --Survival rate based on gender:
            
        SELECT 
            Sex,
            COUNT(*) AS TotalPassengers,
            SUM(Survived) AS SurvivedPassengers,
            CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate
        FROM 
            titanic_data
        GROUP BY 
            Sex;

        -- Survival rate based on age group:
        
        SELECT 
            CASE 
                WHEN Age < 18 THEN 'Child'
                WHEN Age >= 18 AND Age < 60 THEN 'Adult'
                ELSE 'Senior'
            END AS AgeGroup,
            COUNT(*) AS TotalPassengers,
            SUM(Survived) AS SurvivedPassengers,
            CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate
        FROM 
            titanic_data
        GROUP BY 
            CASE 
                WHEN Age < 18 THEN 'Child'
                WHEN Age >= 18 AND Age < 60 THEN 'Adult'
                ELSE 'Senior'
            END
        ORDER BY SurvivalRate DESC;

        -- Survival rate based on passenger class:
        
        SELECT 
            Pclass,
            COUNT(*) AS TotalPassengers,
            SUM(Survived) AS SurvivedPassengers,
            CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate
        FROM 
            titanic_data
        GROUP BY 
            Pclass
        ORDER BY SurvivalRate DESC;


-- Demographic Analysis
    -- A.	Explore passenger demographics using SQL queries.
        -- Age Distribution
        
        SELECT 
            Age,
            COUNT(*) AS PassengerCount
        FROM 
            titanic_data
        GROUP BY 
            Age
        ORDER BY 
            Age;

        -- Gender Distribution:
        
        SELECT 
            Sex,
            COUNT(*) AS PassengerCount
        FROM 
            titanic_data
        GROUP BY 
            Sex;
        
        -- Passenger Class Distribution:
        SELECT 
            Pclass,
            COUNT(*) AS PassengerCount
        FROM 
            titanic_data
        GROUP BY 
            Pclass;

        -- Survival Rates by Gender:
        SELECT 
            Sex,
                CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate
        FROM 
            titanic_data
        GROUP BY 
            Sex
        ORDER BY SurvivalRate DESC;

        --Survival Rates by Passenger Class:
        
        SELECT 
            Pclass,
            CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate
        FROM 
            titanic_data
        GROUP BY 
            Pclass
        ORDER BY SurvivalRate DESC;

        -- Age Distribution of Survivors:
        SELECT 
            Age,
            COUNT(*) AS SurvivorCount
        FROM 
            titanic_data
        WHERE 
            Survived = 1
        GROUP BY 
            Age
        ORDER BY 
            Age;

        --Passenger Gender Distribution:
        SELECT 
            Sex,
            COUNT(*) AS TotalPassengers,
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM titanic_data) * 100 AS Percentage
        FROM 
            titanic_data
        GROUP BY 
            Sex;

        --Passenger Age Distribution:
        SELECT 
            CASE 
                WHEN Age < 18 THEN 'Child'
                WHEN Age >= 18 AND Age < 60 THEN 'Adult'
                ELSE 'Senior'
            END AS AgeGroup,
            COUNT(*) AS TotalPassengers,
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM titanic_data) * 100 AS Percentage
        FROM 
            titanic_data
        GROUP BY 
            CASE 
                WHEN Age < 18 THEN 'Child'
                WHEN Age >= 18 AND Age < 60 THEN 'Adult'
                ELSE 'Senior'
            END;

        -- Passenger Class Distribution:
        SELECT 
            Pclass,
            COUNT(*) AS TotalPassengers,
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM titanic_data) * 100 AS Percentage
        FROM 
            titanic_data
        GROUP BY 
            Pclass;

        -- Embarkation Port Distribution: [not required but worth anaysing]
        SELECT 
            Embarked,
            COUNT(*) AS TotalPassengers,
            CAST(COUNT(*) AS FLOAT) / (SELECT COUNT(*) FROM titanic_data) * 100 AS Percentage
        FROM 
            titanic_data
        GROUP BY 
            Embarked;


B.	Analyze the distribution of age, gender, and passenger class among the passengers.

The scrips from 3 A for Passenger Age Distribution, Passenger Gender Distribution, Passenger Class Distribution are valid.


-- Family Size Analysis:
-- A.	Investigate the impact of family size (SibSp and Parch) on survival rates.
    
    -- Calculate family size by summing SibSp and Parch and add 1 for the passenger themselves
    SELECT 
        SibSp,
        Parch,
        SibSp + Parch + 1 AS FamilySize,
        COUNT(*) AS TotalPassengers,
        SUM(Survived) AS SurvivedPassengers,
        CAST(SUM(Survived) AS FLOAT) / COUNT(*) AS SurvivalRate,
        ROUND(CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100, 2) AS SurvivalRatePercentage
    FROM 
        titanic_data
    GROUP BY 
        SibSp, Parch
    ORDER BY 
        FamilySize;

--B. Calculate survival rates for passengers traveling alone versus those with family members.
    
    -- Calculate family size by summing SibSp and Parch
    SELECT 
        CASE 
            WHEN SibSp + Parch = 0 THEN 'Alone'
            ELSE 'With Family'
        END AS TravelStatus,
        COUNT(*) AS TotalPassengers,
        SUM(Survived) AS SurvivedPassengers,
        CAST(SUM(Survived) AS FLOAT) / COUNT(*) AS SurvivalRate,
        ROUND(CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100, 2) AS SurvivalRatePercentage
    FROM 
        titanic_data
    GROUP BY 
        CASE 
            WHEN SibSp + Parch = 0 THEN 'Alone'
            ELSE 'With Family'
        END;


-- Fare Analysis
-- A.	Explore fare distribution based on passenger class.

    SELECT 
        Pclass,
        MIN(Fare) AS MinFare,
        MAX(Fare) AS MaxFare,
        AVG(Fare) AS AvgFare,
        (MAX(Fare) + MIN(Fare)) / 2 AS MedianFare
    FROM 
        titanic_data
    GROUP BY 
        Pclass
    ORDER BY MedianFare desc;

-- B.	Analyze fare variations among different passenger classes



-- Embarked Port Analysis
-- A.	 Explore survival rates based on the port of embarkation (Embarked column).

    SELECT 
        Embarked,
        COUNT(*) AS TotalPassengers,
        SUM(Survived) AS SurvivedPassengers,
        CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate,
        ROUND(CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100, 2) AS SurvivalRatePercentage
    FROM 
        titanic_data
    GROUP BY 
        Embarked
    ORDER BY SurvivalRatePercentage DESC;

-- B.	Compare survival rates among different embarkation ports.

    SELECT 
        Embarked,
        CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100 AS SurvivalRate,
        ROUND(CAST(SUM(Survived) AS FLOAT) / COUNT(*) * 100, 2) AS SurvivalRatePercentage
    FROM 
        titanic_data
    GROUP BY 
        Embarked
    ORDER BY SurvivalRatePercentage DESC;


