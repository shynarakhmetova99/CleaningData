/* Creating a new table NashvilleHousing */
DROP TABLE IF EXISTS NashvilleHousing;

CREATE TABLE NashvilleHousing (
UniqueID INT,
ParcelID VARCHAR(50),
LandUse VARCHAR(50),
PropertyAddress VARCHAR(200),
SaleDate VARCHAR(50),
SalePrice INT,
LegalReference VARCHAR(50),
SoldAsVacant VARCHAR(50),
OwnerName VARCHAR(200),
OwnerAddress VARCHAR(200),
Acreage FLOAT,
TaxDistrict VARCHAR(50),
LandValue INT,
BuildingValue INT,
TotalValue INT,
YearBuilt INT,
Bedrooms INT,
FullBath INT,
HalfBath INT
);

LOAD DATA LOCAL INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/NashvilleHousing.csv'
INTO TABLE NashvilleHousing
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

SELECT * FROM portfolioproject.nashvillehousing;

/* Cleaning Data in SQL queries */
-- Populating NULL property address lines
SELECT *
FROM portfolioproject.nashvillehousing
WHERE PropertyAddress='' OR PropertyAddress IS NULL;

UPDATE portfolioproject.nashvillehousing
SET PropertyAddress = NULLIF(PropertyAddress, '');

SELECT *
FROM portfolioproject.nashvillehousing
WHERE PropertyAddress IS NULL;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM portfolioproject.nashvillehousing a
INNER JOIN portfolioproject.nashvillehousing b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE portfolioproject.nashvillehousing a
JOIN portfolioproject.nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

-- Breaking down Property Address into individual columns (address, city)
SELECT SUBSTRING(PropertyAddress, 1, (LOCATE(',',PropertyAddress))-1) AS P_Address,
SUBSTRING(PropertyAddress, (LOCATE(',',PropertyAddress))+1) AS P_City
FROM portfolioproject.nashvillehousing;

ALTER TABLE portfolioproject.nashvillehousing
ADD P_Address VARCHAR(200);

ALTER TABLE portfolioproject.nashvillehousing
ADD P_City VARCHAR(50);

UPDATE portfolioproject.nashvillehousing
SET P_Address = SUBSTRING(PropertyAddress, 1, (LOCATE(',',PropertyAddress))-1);

UPDATE portfolioproject.nashvillehousing
SET P_City = SUBSTRING(PropertyAddress, (LOCATE(',',PropertyAddress))+1);

SELECT PropertyAddress, P_Address, P_City
FROM portfolioproject.nashvillehousing;

-- Breaking down Owner Address into individual columns (address, city, state)
SELECT SUBSTRING_INDEX(OwnerAddress,',',1)  AS O_Adress,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) AS O_City,
SUBSTRING_INDEX(OwnerAddress,',',-1) AS O_State
FROM portfolioproject.nashvillehousing;

ALTER TABLE portfolioproject.nashvillehousing
ADD O_Address VARCHAR(200);

ALTER TABLE portfolioproject.nashvillehousing
ADD O_City VARCHAR(50);

ALTER TABLE portfolioproject.nashvillehousing
ADD O_State VARCHAR(50);

UPDATE portfolioproject.nashvillehousing
SET O_Address = SUBSTRING_INDEX(OwnerAddress,',',1);

UPDATE portfolioproject.nashvillehousing
SET O_City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1);

UPDATE portfolioproject.nashvillehousing
SET O_State = SUBSTRING_INDEX(OwnerAddress,',',-1);

SELECT OwnerAddress, O_Address, O_City, O_State
FROM portfolioproject.nashvillehousing;

-- Changing Y & N to Yes and No in the SoldAsVacant;
SELECT DISTINCT(SoldAsVacant)
FROM portfolioproject.nashvillehousing;

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant END
FROM portfolioproject.nashvillehousing;

UPDATE portfolioproject.nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant END;

-- Removing duplicates
WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (
PARTITION BY ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference
ORDER BY UniqueID) AS RowNum
FROM portfolioproject.nashvillehousing
)

/*SELECT *
FROM RowNumCTE
WHERE RowNum >1;*/

DELETE FROM portfolioproject.nashvillehousing
WHERE UniqueID IN (
    SELECT UniqueID
    FROM RowNumCTE
    WHERE RowNum > 1
);

-- Deleting unused columns
ALTER TABLE portfolioproject.nashvillehousing
DROP PropertyAddress, 
DROP OwnerAddress,
DROP TaxDistrict;

SELECT * FROM portfolioproject.nashvillehousing;