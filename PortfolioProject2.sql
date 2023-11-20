/* Cleaning Data in SQL queries */

SELECT *
FROM PortfolioProject.dbo.NashvilleHousingData


--Standardize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
Add SaleDateConverted Date;

Update PortfolioProject..NashvilleHousingData
SET SaleDate = CONVERT(Date,SaleDate)


--Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousingData
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData A
JOIN PortfolioProject..NashvilleHousingData B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousingData A
JOIN PortfolioProject..NashvilleHousingData B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null

-- Breaking Down Addresses into Individual Columns (Address, City, State)

SELECT *
FROM PortfolioProject..NashvilleHousingData
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress)) AS Address
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousingData
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN (PropertyAddress))

SELECT *
FROM PortfolioProject..NashvilleHousingData

-- Alternative method of separating addresses

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
Add OwnerSplitCity Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousingData
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousingData
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..NashvilleHousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM PortfolioProject..NashvilleHousingData

-- Changing Y and N to 'Yes' and 'No' in 'Sold as Vacant' Field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousingData
Group By SoldAsVacant
Order By 2

SELECT 
REPLACE(SoldAsVacant, '%Y%', 'Yes')
FROM PortfolioProject..NashvilleHousingData

SELECT
REPLACE(SoldAsVacant, '%N%', 'No')
FROM PortfolioProject..NashvilleHousingData

--Alternative way to replace 'Y' and 'N' with 'Yes' and 'No' respectively

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject..NashvilleHousingData

UPDATE PortfolioProject..NashvilleHousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   ELSE SoldAsVacant
	   END


--Removing Duplicates

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

From PortfolioProject..NashvilleHousingData
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


-- Deleting unused columns

Select *
FROM PortfolioProject..NashvilleHousingData

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousingData
DROP COLUMN SaleDate