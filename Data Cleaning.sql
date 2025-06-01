-- Data Cleaning

Select *
From layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the Data
-- 3. Null Values or Blank Values
-- 4. Remove any Columns

-- Creating a new Table
Create table layoffs_staging
Like layoffs;

Select *
From layoffs_staging;

-- Inserting all the new data into the new table
Insert layoffs_staging
Select *
From layoffs;

Select *, 
Row_number() Over(
Partition By company,industry,total_laid_off, percentage_laid_off, `date`) As row_num
From layoffs_staging;

-- 1. Remove Duplicates
-- THE DATA ALREADY DID NOT HAVE ANY DUPLICATES BUT THIS IS HOW YOU SHOULD FIND THEM
-- Finding the Duplicates
With duplicate_cte As
(
Select *, 
Row_number() Over(
Partition By company,location,
industry,total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions) As row_num
From layoffs_staging
)
Select *
From duplicate_cte
Where row_num > 1;

-- USE THIS TO MAKE SURE THAT THERE ARE ACTUALLY DUPLICATES
-- JUST AN EXAMPLE
Select *
From layoffs_staging
Where row_num >1;

-- Right Click on Layoffs_staging
-- Create a Statement and add `row_num` INT
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select *
From layoffs_staging2
Where row_num >1 ;

-- Insert the Data Into the new table
Insert Into layoffs_staging2
Select *, 
Row_number() Over(
Partition By company,location,
industry,total_laid_off, percentage_laid_off, `date`,stage,country,funds_raised_millions) As row_num
From layoffs_staging;

Delete
From layoffs_staging2
Where row_num > 1;

Select *
From layoffs_staging2
;

-- 2. Standardize the Data

Select company, Trim(company)
From layoffs_staging2;

-- Get the blank space out of the data
Update layoffs_staging2
Set company = Trim(company);

-- Find if there are any errors
Select Distinct industry
From layoffs_staging2
Order by 1;

-- Look at the things that you need to update
Select *
From layoffs_staging2
Where industry Like 'Crypto%';

-- Update the table to clean up the data
Update layoffs_staging2
Set industry = 'Crypto' 
Where industry Like 'Crypto%';

Select distinct country
From layoffs_staging2
Order by 1;

-- Same thing except we look at the country
Select distinct country
From layoffs_staging2
Where country Like 'United States%';

Update layoffs_staging2
Set country = 'United States'
Where country like 'United States%';

-- Chaning date to date format
Select `date`,
str_to_date(`date`, '%m/%d/%Y')
From layoffs_staging2;

Update layoffs_staging2
Set `date` = str_to_date(`date`, '%m/%d/%Y');

Select `date`
From layoffs_staging2;

-- Changing From Text to Date
Alter Table layoffs_staging2
Modify Column `date` Date;

-- 3. Null Values and Blank Values

-- Setting Blanks into Nulls
Update layoffs_staging2
Set industry = null
Where industry = '';

Select *
From layoffs_staging2
Where industry is NUll
or industry = '';

-- How to fix blanks and nulls if you have another similar company with an industry already
Select *
From layoffs_staging2
Where company = 'Airbnb';

Select *
From layoffs_staging2 t1
Join layoffs_staging t2
	On t1.company = t2.company
Where (t1.industry is Null or t1.industry = '')
And t2.industry is not NUll;

Update layoffs_staging2 t1
Join layoffs_staging t2
	On t1.company = t2.company
Set t1.industry = t2.industry
Where (t1.industry is Null )
And t2.industry is not NUll;

-- 4. Remove Any Columns
-- Deleting Columns that "we don't need"
Select *
From layoffs_staging2
Where total_laid_off is NULL
And percentage_laid_off is NUll;

Delete
From layoffs_staging2
Where total_laid_off is NULL
And percentage_laid_off is NUll;

Select *
From layoffs_staging2;

Alter Table layoffs_staging2
Drop Column row_num;













