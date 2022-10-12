/*
SQL Data Cleaning 
*/

select * 
from NashvilleHousingData;

----------------------------------------------------------------------------------------------------------

-- Standarize Date Format

select SaleDate, CONVERT(date,SaleDate) 
from NashvilleHousingData;

/*
update NashvilleHousingData
set SaleDate= CONVERT(date,SaleDate);
*/

ALTER TABLE NashvilleHousingData
ADD SalesDateConverted Date;

Update NashvilleHousingData
SET SalesDateConverted= CONVERT(date,SaleDate);

----------------------------------------------------------------------------------------------------------

-- Populate Property Address Data

select *
from NashvilleHousingData
-- where PropertyAddress is null
order by ParcelId;

select a.ParcelID,a.PropertyAddress,b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID= b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b
on a.ParcelID= b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null;

----------------------------------------------------------------------------------------------------------

-- Breaking out columns into different columns (Address, City, State)
-- Breakdown of Property Address

select PropertyAddress
from NashvilleHousingData;

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) as address ,
	   SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1 ,len(PropertyAddress)) as city 
from NashvilleHousingData;

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress varchar(255);

Update NashvilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity varchar(255);

Update NashvilleHousingData
SET PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1 ,len(PropertyAddress));

Select PropertySplitAddress, PropertySplitCity
from NashvilleHousingData;

-- Breakdown of Owner Address

select PARSENAME(REPLACE  (OwnerAddress,',','.'), 3),
	   PARSENAME(REPLACE  (OwnerAddress,',','.'), 2),
	   PARSENAME(REPLACE  (OwnerAddress,',','.'), 1)
from NashvilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress varchar(255);

Update NashvilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE  (OwnerAddress,',','.'), 3);

ALTER TABLE NashvilleHousingData
ADD OwnerSplitCity varchar(255);

Update NashvilleHousingData
SET OwnerSplitCity= PARSENAME(REPLACE  (OwnerAddress,',','.'), 2);

ALTER TABLE NashvilleHousingData
ADD OwnerSplitState varchar(255);

Update NashvilleHousingData
SET OwnerSplitState= PARSENAME(REPLACE  (OwnerAddress,',','.'), 1);

select * 
from NashvilleHousingData;

----------------------------------------------------------------------------------------------------------

-- Change Y and N to Yess and No in "Sold as Vacant" filed

select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousingData
group by SoldAsVacant
order by 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end
from NashvilleHousingData;

update NashvilleHousingData
set SoldAsVacant= case when SoldAsVacant = 'Y' Then 'Yes'
	 when SoldAsVacant = 'N' Then 'No'
	 else SoldAsVacant
	 end

----------------------------------------------------------------------------------------------------------

-- Remove duplicattes 

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousingData
--order by ParcelID
)
Delete 
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress

----------------------------------------------------------------------------------------------------------

-- Delete Unuseable Columns 

alter table NashvilleHousingData 
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;
