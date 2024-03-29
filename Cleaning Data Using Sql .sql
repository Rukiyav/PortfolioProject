SELECT *
  FROM [portfolio_project].[dbo].[Nashville Housing Data ]

/*

Cleaning Data using SQL Queries

*/

-- Standardize Date Format
SELECT SaleDate , CONVERT(date,SaleDate)
from [portfolio_project].[dbo].[Nashville Housing Data ]

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set SaleDate = CONVERT(date,SaleDate)

SELECT SaleDate
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
add SaleDateConverted Date

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set SaleDateConverted = CONVERT(date,SaleDate)

SELECT SaleDateConverted
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

--------------------------------------------------------------------------------------------------------------------------

--Populate Property address column

SELECT *
FROM [portfolio_project].[dbo].[Nashville Housing Data ]
--WHERE PropertyAddress is NULL
order by ParcelID

--we have duplicates in parcel id and those dulpicate parcel id have same address
--hence by using this we can fill nulls in property address
--self join 

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress
FROM [portfolio_project].[dbo].[Nashville Housing Data ] a
JOIN [portfolio_project].[dbo].[Nashville Housing Data ] b
on a.ParcelID = b.ParcelID
AND a.uniqueID < > b.uniqueID


SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [portfolio_project].[dbo].[Nashville Housing Data ] a
JOIN [portfolio_project].[dbo].[Nashville Housing Data ] b
on a.ParcelID = b.ParcelID
AND a.uniqueID < > b.uniqueID
WHERE a.PropertyAddress is NULL


UPDATE a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [portfolio_project].[dbo].[Nashville Housing Data ] a
JOIN [portfolio_project].[dbo].[Nashville Housing Data ] b
on a.ParcelID = b.ParcelID
AND a.uniqueID < > b.uniqueID
WHERE a.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

--Separating property address as city,state

SELECT PropertyAddress
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1) as address ,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as state
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
add PropertySplitAddress NVARCHAR(255)

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
add PropertySplitCity NVARCHAR(255)

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))

SELECT *
FROM [portfolio_project].[dbo].[Nashville Housing Data ]


------Separating Owner address into address,city,state

SELECT OwnerAddress
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as address, 
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as city ,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as state

FROM [portfolio_project].[dbo].[Nashville Housing Data ]

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
add OwnerSplitAddress NVARCHAR(255)

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
add OwnerSplitCity NVARCHAR(255)

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
add OwnerSplitState NVARCHAR(255)

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM [portfolio_project].[dbo].[Nashville Housing Data ]
GROUP by SoldAsVacant
ORDER by 2

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' then 'YES'
    When SoldAsVacant = 'N' then 'NO'
    Else SoldAsVacant
    END
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

UPDATE [portfolio_project].[dbo].[Nashville Housing Data ]
set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'YES'
                        When SoldAsVacant = 'N' then 'NO'
                        Else SoldAsVacant
                        END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [portfolio_project].[dbo].[Nashville Housing Data ]
order by ParcelID

WITH RowNumCTE AS(
    SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [portfolio_project].[dbo].[Nashville Housing Data ]
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

---- delete

WITH RowNumCTE AS(
    SELECT *,
ROW_NUMBER() OVER(
    PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM [portfolio_project].[dbo].[Nashville Housing Data ]
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM [portfolio_project].[dbo].[Nashville Housing Data ]

ALTER TABLE [portfolio_project].[dbo].[Nashville Housing Data ]
DROP COLUMN PropertyAddress,SaleDate,OwnerAddress,TaxDistrict
