/*

Cleaning Data in SQL Queries
*/

Select *
from PortfolioProject.dbo.Nashvillehousing

-- standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PortfolioProject.dbo.Nashvillehousing

Update Nashvillehousing
SET SaleDate = CONVERT(Date, SaleDate)

Alter Table NashvilleHousing
add SaleDateConverted Date;

Update Nashvillehousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- populate Property Address Data


Select *
from PortfolioProject.dbo.Nashvillehousing
--where PropertyAddress is Null
order by ParcelID

Select a.ParcelID , a.PropertyAddress , b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
     on a.ParcelID = b.ParcelID
     AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.Nashvillehousing a
JOIN PortfolioProject.dbo.Nashvillehousing b
     on a.ParcelID = b.ParcelID
     AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject.dbo.Nashvillehousing
--where PropertyAddress is Null
--order by ParcelID

Select 
SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address

from PortfolioProject.dbo.Nashvillehousing

Alter Table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHousing
add PropertySplitCity Nvarchar(255);

Update Nashvillehousing
SET PropertySplitCity = SUBSTRING(PropertyAddress ,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from PortfolioProject.dbo.Nashvillehousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

from PortfolioProject.dbo.Nashvillehousing

Alter Table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

Update Nashvillehousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
add OwnerSplitState Nvarchar(255);

Update Nashvillehousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select *
from PortfolioProject.dbo.Nashvillehousing


-- Change Y and N to Yes and No in "Sold as Vacent" field

Select Distinct(SoldASVacant), Count(SoldASVacant)
from PortfolioProject.dbo.Nashvillehousing
Group by SoldASVacant
order by 2

Select SoldASVacant
, CASE When SoldASVacant = 'Y' Then 'Yes'
       when SoldASVacant = 'N' Then 'No'
       Else SoldASVacant
       END
from PortfolioProject.dbo.Nashvillehousing

Update Nashvillehousing
SET SoldASVacant = CASE When SoldASVacant = 'Y' Then 'Yes'
       when SoldASVacant = 'N' Then 'No'
       Else SoldASVacant
       END

-- REMOVE DUPLICATES
WITH RownNumCTE AS(
Select *,
      ROW_NUMBER() OVER(
      PARTITION BY ParceLID,
      PropertyAddress,
      SalePrice,
      LegalReference
      ORDER by
      UniqueID
      )row_num
 
from PortfolioProject.dbo.Nashvillehousing
--Order bY ParceLID
)

Select *
FROM RownNumCTE
Where Row_Num >1
order by PropertyAddress

-- Delete Unused Coloums

Select *
from PortfolioProject.dbo.Nashvillehousing

Alter Table  PortfolioProject.dbo.Nashvillehousing
Drop column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table  PortfolioProject.dbo.Nashvillehousing
Drop column SaleDate