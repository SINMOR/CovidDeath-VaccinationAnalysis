--cleaning data in sql queries
SELECT *
FROM project_portfolio..NashvilleHousingData

--standardizing date format
SELECT SaleDate ,CONVERT(date SaleDate )
FROM project_portfolio..NashvilleHousingData

UPDATE NashvilleHousingData
SET SaleDate =CONVERT(date ,SaleDate )

ALTER TABLE NashvilleHousingData
ADD saledateconverted DATE;

UPDATE NashvilleHousingData
SET saledateconverted = CONVERT(date ,SaleDate )

SELECT saledateconverted
FROM NashvilleHousingData

--populate property address data
 
SELECT *
FROM NashvilleHousingData
--  WHERE PropertyAddress IS NULL
 ORDER BY ParcelID

 SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousingData a
 JOIN NashvilleHousingData b ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is NULL

 UPDATE a 
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM NashvilleHousingData a
 JOIN NashvilleHousingData b ON a.ParcelID = b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]

 --breaking address into individual  columns 
 SELECT PropertyAddress
FROM NashvilleHousingData
--  WHERE PropertyAddress IS NULL
 ORDER BY ParcelID

 SELECT SUBSTRING( PropertyAddress,1, CHARINDEX(',' ,PropertyAddress ) -1) AS Address,SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address
 FROM NashvilleHousingData

 ALTER TABLE NashvilleHousingData
ADD propertysplitaddress  NVARCHAR(255);

UPDATE NashvilleHousingData
SET propertysplitaddress =  SUBSTRING( PropertyAddress,1, CHARINDEX(',' ,PropertyAddress ) -1) 

ALTER TABLE NashvilleHousingData
ADD propertsplitcity NVARCHAR(255);

UPDATE NashvilleHousingData 
SET propertsplitcity = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

SELECT  PARSENAME(REPLACE(OwnerAddress, ',','.') , 3),PARSENAME(REPLACE(OwnerAddress, ',','.') , 2),PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)
FROM NashvilleHousingData
WHERE OwnerAddress IS NOT NULL

ALTER TABLE NashvilleHousingData
ADD ownerssplitaddress  NVARCHAR(255);
UPDATE NashvilleHousingData
SET ownerssplitaddress =  PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE NashvilleHousingData
ADD ownerssplitcity NVARCHAR(255);
UPDATE NashvilleHousingData 
SET ownerssplitcity= PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE NashvilleHousingData
ADD ownerssplitstate NVARCHAR(255);
UPDATE NashvilleHousingData 
SET ownerssplitstate = PARSENAME(REPLACE(OwnerAddress, ',','.') , 1)

SELECT *
FROM NashvilleHousingData

SELECT SoldAsVacant,
CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM NashvilleHousingData


UPDATE NashvilleHousingData 
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END

SELECT DISTINCT(SoldAsVacant) ,COUNT(SoldAsVacant)
FROM NashvilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

--REMOVING DUPLICATES
SELECT *,
ROW_NUMBER () OVER ( 
  PARTITION BY ParcelID,PropertyAddress,SaleDate,saleprice,legalreference ORDER BY uniqueID) ROW_NUM
FROM NashvilleHousingData

order BY ParcelID

