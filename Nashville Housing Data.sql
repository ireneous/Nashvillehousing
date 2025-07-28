/* 
Cleaning Data in SQL queries
*/

USE portfolioproject;

SELECT * FROM portfolioproject.nashvillehousing;

-- Standardize Date Format

SELECT SaleDateConverted, CONVERT(SaleDate, DATE) FROM portfolioproject.nashvillehousing;

UPDATE NashvilleHousing
SET SaleDate = CONVERT(SaleDate,DATE);

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(SaleDate,DATE);

-- Populate Property Address Data

SELECT * 
FROM Portfolioproject.nashvillehousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT 
  a.ParcelID, 
  a.PropertyAddress AS AddressBefore,
  b.PropertyAddress AS AddressToFill,
  IF(TRIM(a.PropertyAddress) = '', b.PropertyAddress, a.PropertyAddress) AS FilledAddress
FROM PortfolioProject.Nashvillehousing AS a
JOIN PortfolioProject.Nashvillehousing AS b
  ON a.ParcelID = b.ParcelID
WHERE TRIM(a.PropertyAddress) = '' 
  AND TRIM(b.PropertyAddress) <> '';

SET SQL_SAFE_UPDATES = 0;

UPDATE PortfolioProject.Nashvillehousing AS a
JOIN PortfolioProject.Nashvillehousing AS b
  ON a.ParcelID = b.ParcelID
SET a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE TRIM(a.PropertyAddress) = '' 
  AND TRIM(b.PropertyAddress) <> '';
  
  -- Breaking Out Address Into Individual Columns (Address,City,State)
  
SELECT 
  a.ParcelID, 
  a.PropertyAddress AS AddressBefore,
  b.PropertyAddress AS AddressToFill
FROM PortfolioProject.Nashvillehousing AS a
JOIN PortfolioProject.Nashvillehousing AS b
  ON a.ParcelID = b.ParcelID
WHERE (a.PropertyAddress IS NULL OR TRIM(a.PropertyAddress) = '')
  AND b.PropertyAddress IS NOT NULL
  AND TRIM(b.PropertyAddress) <> '';



SELECT
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM PortfolioProject.NashvilleHousing;

ALTER TABLE nashvillehousing
ADD COLUMN PropertySplitAddress VARCHAR(255);

SELECT
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1) AS City
FROM PortfolioProject.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE PortfolioProject.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

Select * From PortfolioProject.NashvilleHousing;

Select OwnerAddress
From PortfolioProject.NashvilleHousing;

SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS Address,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS City,
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS State
FROM PortfolioProject.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

SELECT
  SUBSTRING_INDEX(OwnerAddress, ',', 1) AS OwnerSplitAddress,
  TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1)) AS OwnerSplitCity,
  TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1)) AS OwnerSplitState
FROM PortfolioProject.NashvilleHousing;


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1));


ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1));

Select *
From PortfolioProject.NashvilleHousing;


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT SoldAsVacant, COUNT(*) AS Count
FROM PortfolioProject.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count;

SELECT 
  SoldAsVacant,
  CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
  END AS SoldAsVacant_Cleaned
FROM PortfolioProject.NashvilleHousing;


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       
       -- Remove Duplicates
       
WITH RowNumCTE AS (
  SELECT 
    *, 
    ROW_NUMBER() OVER (
      PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
      ORDER BY UniqueID
    ) AS row_num
  FROM PortfolioProject.NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT *
FROM PortfolioProject.NashvilleHousing;

-- Delete Unused Columns
SHOW COLUMNS FROM PortfolioProject.NashvilleHousing;

Select *
From PortfolioProject.NashvilleHousing;

ALTER TABLE PortfolioProject.NashvilleHousing
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
DROP COLUMN SaleDate;
