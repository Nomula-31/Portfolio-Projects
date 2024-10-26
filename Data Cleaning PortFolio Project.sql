--Cleaning data in SQL


select * from NashvilleHousing

---------------------------------

--standardize sale date format

select SaleDate, convert(date,saledate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate= convert(date,saledate)

alter table NashvilleHousing
add SaleDateConverted Date


update NashvilleHousing
set SaleDateConverted= convert(date,saledate)

--------------------------------------------------------------

--Populate property address data

select PropertyAddress from NashvilleHousing
where PropertyAddress is null

select * from NashvilleHousing 
where PropertyAddress is null
order by ParcelID

--It mean We can find multiple parcelId with same property address but some places we can find that we have same parcelIds but we can see only one address is written
--so here we are populating the property address to the parcelId
--here we need to self join

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]
	 where a.PropertyAddress is null

update a
set propertyaddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]
	 where a.PropertyAddress is null


---------------------------------------------------------------

--Breaking out address into individual coloumns (Address,city,State)


select PropertyAddress from NashvilleHousing
--order by ParcelID
 


 --here charindex searches for specific values 
 --here we use -1 to remove , from the results
 select 
 SUBSTRING(propertyAddress, 1,CHARINDEX( ',', PropertyAddress) -1) as address
 from NashvilleHousing

 ---here we use +1 to remove coma fromfront and added city separatley
  select 
 SUBSTRING(propertyAddress, 1,CHARINDEX( ',', PropertyAddress) -1) as address
 ,SUBSTRING(propertyAddress,CHARINDEX( ',', PropertyAddress) +1,LEN(PropertyAddress)) as City
 from NashvilleHousing



 -- we cant separate two values from on coloumn without creating two other coloumns
 
 
 alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)


update NashvilleHousing
set PropertySplitAddress=  SUBSTRING(propertyAddress, 1,CHARINDEX( ',', PropertyAddress) -1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255)


--alter table NashvilleHousing
--drop column PropertySplitCity


update NashvilleHousing
set PropertySplitCity= SUBSTRING(propertyAddress,CHARINDEX( ',', PropertyAddress) +1,LEN(PropertyAddress))


-----------------------------------------------
--here we are doing owners address
select * from NashvilleHousing
where OwnerAddress is not null


--here we are using perse name instead of strings
--onlu use with periods 

select OwnerAddress from NashvilleHousing

select PARSENAME(replace(OwnerAddress, ',', '.'),3)
,PARSENAME(replace(OwnerAddress, ',', '.'),2)
,PARSENAME(replace(OwnerAddress, ',', '.'),1)
from NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)


update NashvilleHousing
set OwnerSplitAddress= PARSENAME(replace(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)


update NashvilleHousing
set OwnerSplitCity= PARSENAME(replace(OwnerAddress, ',', '.'),2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255)


update NashvilleHousing
set OwnerSplitState= PARSENAME(replace(OwnerAddress, ',', '.'),1)


select * from NashvilleHousing

--------------------------------------------------------------------------------

--change Y and N to Yes and No in 'sold as vaccant'  field

select distinct(SoldAsVacant),count(SoldAsVacant) from  NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'YES'
when SoldAsVacant='N' then 'NO'
else SoldAsVacant
End
from NashvilleHousing


update NashvilleHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'YES'
when SoldAsVacant='N' then 'NO'
else SoldAsVacant
End


---------------------------------------------------------------------

--Remove Duplicates

--write CTE and we are going to do some windows functon find where are the duplicate values
--Rank,Rownumber,denserank we use ths to find duplicates 


with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by parcelID,
propertyaddress,saleprice,saledate,legalReference
order by uniqueID ) row_num
from NashvilleHousing
)
select * from RowNumCTE
where row_num > 1
order by PropertyAddress

--Delete the duplicates from the table 

with RowNumCTE as(
select *,
ROW_NUMBER() over(
partition by parcelID,
propertyaddress,saleprice,saledate,legalReference
order by uniqueID ) row_num
from NashvilleHousing
)
Delete from RowNumCTE
where row_num > 1
--order by PropertyAddress

select * from NashvilleHousing


------------------------------------------------------
--Delete unused coloumn 
--It mainly happens in views but here dont use in raw data

select * from NashvilleHousing

alter table NashvilleHousing
drop column owneraddress,TaxDistrict,PropertyAddress



--whole purpose of this project is to clean the data into our usable way