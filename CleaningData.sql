/*

Cleaning Data in SQL Querries

*/

SELECT *
FROM PortfolioProject..NashvileHousing

-- Standardize Date Format

/* First Option */

SELECT SaleDate
FROM PortfolioProject..NashvileHousing

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvileHousing

UPDATE NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate) 

/* Second Option */

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvileHousing

UPDATE NashvileHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvileHousing
ADD SaleDateConverted Date

UPDATE NashvileHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvileHousing

-- Populate Property Address data. - Where there are NULL values

SELECT PropertyAddress
FROM PortfolioProject..NashvileHousing

SELECT PropertyAddress
FROM PortfolioProject..NashvileHousing
WHERE PropertyAddress IS NULL /* There shouldnt be NULL values in address */

SELECT *
FROM PortfolioProject..NashvileHousing
WHERE PropertyAddress IS NULL /* There shouldnt be NULL values in address */

/* Look at a reference point for the address from the table as this cannot be NULL */

SELECT *
FROM PortfolioProject..NashvileHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..NashvileHousing
ORDER BY ParcelID  /* try get properties with same ParcelID */

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM PortfolioProject..NashvileHousing AS A
	JOIN PortfolioProject..NashvileHousing AS B  /* Join the table to itself where the ParcelID is the same and UniqueID is different */
	ON A.ParcelID = B.ParcelID 
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) /* checks if one part is null then populate with a particular value */
FROM PortfolioProject..NashvileHousing AS A
	JOIN PortfolioProject..NashvileHousing AS B  /* Join the table to itself where the ParcelID is the same and UniqueID is different */
	ON A.ParcelID = B.ParcelID 
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvileHousing A
JOIN PortfolioProject..NashvileHousing B
	ON A.ParcelID = B.ParcelID 
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject..NashvileHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address, /* Take the first value upto the comma */
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City /* Adds another value after the top one */
FROM PortfolioProject..NashvileHousing

/* Now add a column in the table for the 2 created values */

ALTER TABLE PortfolioProject..NashvileHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject..NashvileHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvileHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvileHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject..NashvileHousing


/* Another way to seperate the values in a column */


SELECT OwnerAddress
FROM PortfolioProject..NashvileHousing

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.') , 1),
PARSENAME (REPLACE(OwnerAddress, ',','.') , 2),
PARSENAME (REPLACE(OwnerAddress, ',','.') , 3) /* Arranges the values backwards */ 
FROM PortfolioProject.dbo.NashvileHousing

SELECT 
PARSENAME (REPLACE(OwnerAddress, ',','.') , 3),
PARSENAME (REPLACE(OwnerAddress, ',','.') , 2),
PARSENAME (REPLACE(OwnerAddress, ',','.') , 1) /* Arranges the values correctly */
FROM PortfolioProject.dbo.NashvileHousing


/* Now add a column in the table for the 2 created values */

ALTER TABLE PortfolioProject..NashvileHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject..NashvileHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE PortfolioProject..NashvileHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvileHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE PortfolioProject..NashvileHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..NashvileHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.') , 1)

SELECT *
FROM PortfolioProject..NashvileHousing

-- Change Y and N to Yes and No in 'SoldAsVacant' */

SELECT *
FROM PortfolioProject..NashvileHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvileHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvileHousing

UPDATE PortfolioProject..NashvileHousing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

SELECT *
FROM PortfolioProject..NashvileHousing

-- Removing the duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num 
FROM PortfolioProject..NashvileHousing
)
SELECT *  -- DELETE 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvileHousing

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvileHousing
DROP COLUMN SaleDate