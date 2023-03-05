select *
from rohandb.dbo.Housing

---------------------------------------------------------------------------------------------

--standardize date format
select SaleDateConverted, CONVERT(Date, SaleDate)
from rohandb.dbo.Housing

update rohandb.dbo.Housing
set SaleDate = CONVERT(Date, SaleDate)

alter table Housing
add SaleDateConverted Date;

update rohandb.dbo.Housing
set SaleDateConverted = CONVERT(Date, SaleDate)

----------------------------------------------------------------------------------------------------

--populate property address

select PropertyAddress
from rohandb.dbo.Housing

select *
from rohandb.dbo.Housing
where PropertyAddress is NULL

select *
from rohandb.dbo.Housing
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from rohandb.dbo.Housing a
join rohandb.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from rohandb.dbo.Housing a
join rohandb.dbo.Housing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-------------------------------------------------------------------------------------------------------------------------

--breaking out address into individual columns

select PropertyAddress
from rohandb.dbo.Housing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as City,
from rohandb.dbo.Housing

alter table Housing
add PropertySplitAddress Nvarchar(255);

update rohandb.dbo.Housing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

alter table Housing
add PropertySplitCity Nvarchar(255);

update rohandb.dbo.Housing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

select OwnerAddress
from [dbo].[Housing]

select 
PARSENAME(Replace(OwnerAddress, ',' , '.'),1)
,PARSENAME(Replace(OwnerAddress, ',' , '.'),2)
,PARSENAME(Replace(OwnerAddress, ',' , '.'),3)

from [dbo].[Housing]

alter table Housing
add OwnerSplitAddress Nvarchar(255);

update rohandb.dbo.Housing
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',' , '.'),3)

alter table Housing
add OwnerSplitCity Nvarchar(255);

update rohandb.dbo.Housing
set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',' , '.'),2)

alter table Housing
add OwnerSplitState Nvarchar(255);

update rohandb.dbo.Housing
set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',' , '.'),1)

select *
from rohandb.dbo.Housing

----------------------------------------------------------------------------------------------------------------------
--change y and n as yes and no in "Sold as Vacant"

select Distinct(SoldAsVacant), count(SoldASVacant)
from rohandb.dbo.Housing
group by SoldAsVacant

select SoldAsVacant
,case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end
from rohandb.dbo.Housing

update Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
      when SoldAsVacant = 'N' then 'No'
	  else SoldAsVacant
	  end

-------------------------------------------------------------------------------------------------------------

--Remove duplicates

with RowNumCTE as(

select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
				 ) row_num
from rohandb.dbo.Housing
)

select *   --select to check duplicates then use delete
from RowNumCTE
where row_num>1
order by PropertyAddress

-----------------------------------------------------------------------------------------------------------------
--delete unused columns

alter table rohandb.dbo.Housing
drop column OwnerAddress, TaxDistrict, PropertyAddress

select *
from rohandb.dbo.Housing