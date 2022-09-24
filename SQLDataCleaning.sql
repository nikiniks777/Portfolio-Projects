--cleaning data
Select*
From dbo.NashvilleHousingData

--Convert Date format
SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM dbo.NashvilleHousingData

update dbo.NashvilleHousingData
Set SaleDate = CONVERT(Date, SaleDate)

ALTER Table dbo.NashvilleHousingData
Add SaleDateConverted Date;


update dbo.NashvilleHousingData
SET SaleDateConverted = CONVERT(Date, SaleDate)

--populate PropertyAddress data
SELECT*
FROM dbo.NashvilleHousingData
where PropertyAddress is NULL
Order by ParcelID

SELECT column1.ParcelID, column1.PropertyAddress, column2.ParcelID, 
	   column2.PropertyAddress, ISNULL(column1.PropertyAddress, column2.PropertyAddress)
FROM dbo.NashvilleHousingData column1
JOIN dbo.NashvilleHousingData column2
	ON column1.ParcelID = column2.ParcelID
	AND column1.[UniqueID ] <> column2.[UniqueID ]
WHERE column1.PropertyAddress is null

UPDATE column1
SET PropertyAddress = ISNULL(column1.PropertyAddress, column2.PropertyAddress)
FROM dbo.NashvilleHousingData column1
JOIN dbo.NashvilleHousingData column2
	ON column1.ParcelID = column2.ParcelID
	AND column1.[UniqueID ] <> column2.[UniqueID ]
WHERE column1.PropertyAddress is null


--Dividing Address to individual columns Address, City, State

SELECT PropertyAddress
FROM dbo.NashvilleHousingData
--Separating Address and state
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM dbo.NashvilleHousingData


ALTER Table dbo.NashvilleHousingData
Add PropertyWithAddress NVARCHAR(255);

update dbo.NashvilleHousingData
Set PropertyWithAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 

ALTER Table dbo.NashvilleHousingData
Add PropertyWithCity NVARCHAR(255);

update dbo.NashvilleHousingData
SET PropertyWithCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Dividing OwnerAddress to Address, City and State using ParseName
SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM dbo.NashvilleHousingData

ALTER Table dbo.NashvilleHousingData
Add OwnerAddressWithAddress NVARCHAR(255);

update dbo.NashvilleHousingData
Set OwnerAddressWithAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) 

ALTER Table dbo.NashvilleHousingData
Add OwnerAddressWithCity NVARCHAR(255);

update dbo.NashvilleHousingData
SET OwnerAddressWithCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER Table dbo.NashvilleHousingData
Add OwnerAddressWithState NVARCHAR(255);

update dbo.NashvilleHousingData
SET OwnerAddressWithState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
FROM dbo.NashvilleHousingData

--Converting Y to Yes and N to No in SoldAsVacant column

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant) as Count
FROM dbo.NashvilleHousingData
Group By SoldAsVacant
Order by 2

SELECT SoldAsVacant		
, CASE when SoldAsVacant = 'Y' THEN 'Yes' 
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM dbo.NashvilleHousingData

update dbo.NashvilleHousingData
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes' 
	   when SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Eliminating Duplicates
--Create a CTE
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
				  UniqueID
				  ) row_no
FROM dbo.NashvilleHousingData
)
DELETE 
FROM RowNumCTE
Where row_no > 1

--SELECT *
--FROM RowNumCTE
--Where row_no > 1
--Order By PropertyAddress