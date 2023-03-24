/*
-----Cleaning data in sql queries
*/

SELECT *
FROM Coba.dbo.NashvilleHousing

--Standardize Date Format tanggal /Mengubah

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM Coba.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------

--Populate Property Address data

SELECT *
FROM Coba..NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID 

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM Coba.dbo.NashvilleHousing a
JOIN Coba.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress,b.PropertyAddress)
FROM Coba.dbo.NashvilleHousing a
JOIN Coba.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null 
	

--------Breaking Out adress into induvisual columns/Memisah dan membuat table baru (Adress,City,State)

SELECT 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address, -- CHARINDEX(',', PropertyAddress) Mengitung Karakter pada int
SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS Address

FROM Coba..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


SELECT *
FROM Coba..NashvilleHousing



-----Membuat table baru dan memisahkan colom dengan koma
SELECT 
PARSENAME (REPLACE (OwnerAddress, ',','.'),3),
PARSENAME (REPLACE (OwnerAddress, ',','.'),2),
PARSENAME (REPLACE (OwnerAddress, ',','.'),1)

FROM Coba..NashvilleHousing 



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE (OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add PropertySPlitState Nvarchar(255);

Update NashvilleHousing
SET PropertySPlitState = PARSENAME (REPLACE (OwnerAddress, ',','.'),1)


SELECT *
FROM Coba..NashvilleHousing




-- Konversi Y and N to Yes and no on sold as vacant field
SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM Coba..NashvilleHousing 
GROUP BY SoldAsVacant
order BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SOldAsVacant 
	 END
	 FROM Coba..NashvilleHousing 

--- Metode 2
UPDATE NashvilleHousing
	 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SOldAsVacant 
	 END


--------Remove Duplicate
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

 FROM Coba..NashvilleHousing

 ------ORDER BY ParcelID
 )
 SELECT
 FROM RowNumCTE
 WHERE row_num >1
 ORDER BY PropertyAddress


 --Delete Unused Columns
 SELECT *
FROM Coba..NashvilleHousing

 ALTER TABLE Coba..NashvilleHousing
 DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress,SaleDate