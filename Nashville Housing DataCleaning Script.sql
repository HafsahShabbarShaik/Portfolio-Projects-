
--X--Cleaning Data With SQL Queries--X--


--Selecting the Table--

Select *
from Nashville_housing..Nashville_housing_DataCleaning 

----------------------------------------------------------------------------------------------------------------------------------

--Altering the SaleDate--

Select saledate
from Nashville_housing_DataCleaning

Select saledate, CONVERT(DATE,SaleDate)
from Nashville_housing_DataCleaning

UPDATE [Nashville_housing_DataCleaning ] 
set SaleDate = CONVERT(DATE,SaleDate)

----------------

ALTER Table Nashville_housing_DataCleaning
add AlteredSaleDate Date;

UPDATE [Nashville_housing_DataCleaning ] 
set AlteredSaleDate = CONVERT(DATE,SaleDate)

Select AlteredSaleDate  
from Nashville_housing..Nashville_housing_DataCleaning 


--Droping the SaleDate column (Since its not necessary )

ALTER TABLE Nashville_housing_DataCleaning 
Drop column SaleDate

----------------------------------------------------------------------------------------------------------------------------------

--Populating Property Address-- 

--EDA

SELECT PropertyAddress
from [Nashville_housing_DataCleaning ]

SELECT *
from [Nashville_housing_DataCleaning ]
WHERE PropertyAddress is null 
order by ParcelID
------------
-- Joinig the same table to populate the 

SELECT  a.ParcelID,a.PropertyAddress,n.ParcelID,n.PropertyAddress, ISNULL(a.PropertyAddress,n.PropertyAddress)
FROM [Nashville_housing_DataCleaning ] a 
join [Nashville_housing_DataCleaning ] n 
on a.ParcelID = n.ParcelID 
AND a.[UniqueID ] <> n.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
set a.PropertyAddress = ISNULL(a.PropertyAddress,n.PropertyAddress)
FROM [Nashville_housing_DataCleaning ] a 
join [Nashville_housing_DataCleaning ] n 
on a.ParcelID = n.ParcelID 
AND a.[UniqueID ] <> n.[UniqueID ]

----------------------------------------------------------------------------------------------------------------------------------

--Breaking Down the Address into Specific Columns like (Address,City,State)--

-- Breaking Down PropertyAddress into (Address,City)

SELECT PropertyAddress
from [Nashville_housing_DataCleaning ]

SELECT SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as addsress,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(propertyaddress)) as addsress
from [Nashville_housing_DataCleaning ]

------------

--Adding the Updated Address

ALTER Table Nashville_housing_DataCleaning
add UpdatedPropertyAddress Varchar (225);

UPDATE [Nashville_housing_DataCleaning ] 
set UpdatedPropertyAddress = SUBSTRING (PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

SELECT UpdatedPropertyAddress
FROM [Nashville_housing_DataCleaning ]

------------

--Adding the Updated City Address

ALTER Table Nashville_housing_DataCleaning
add UpdatedPropertyAddress_City Varchar (225);

UPDATE [Nashville_housing_DataCleaning ] 
set UpdatedPropertyAddress_City = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1,LEN(propertyaddress))  

SELECT UpdatedPropertyAddress_City
FROM [Nashville_housing_DataCleaning ]

ALTER Table Nashville_housing_DataCleaning 
Drop Column PropertyAddress

------------------------------------

--Breaking down the OwnersAddress

SELECT OwnerAddress
FROM [Nashville_housing_DataCleaning ]

SELECT 
PARSENAME (REPLACE(OwnerAddress,',','.'),3),
PARSENAME (REPLACE(OwnerAddress,',','.'),2),
PARSENAME (REPLACE(OwnerAddress,',','.'),1)
from [Nashville_housing_DataCleaning ]

-----------

--Adding the new tables 

ALTER Table Nashville_housing_DataCleaning
add UpdatedOwnerAddress Varchar (225);

ALTER Table Nashville_housing_DataCleaning
add UpdatedOwnersCity Varchar (225);

ALTER Table Nashville_housing_DataCleaning
add UpdatedOwnersState Varchar (225);

-----------

--Updating the new tables 

UPDATE [Nashville_housing_DataCleaning ] 
set UpdatedOwnerAddress = PARSENAME (REPLACE(OwnerAddress,',','.'),3)

UPDATE [Nashville_housing_DataCleaning ] 
set UpdatedOwnersCity = PARSENAME (REPLACE(OwnerAddress,',','.'),2) 

UPDATE [Nashville_housing_DataCleaning ] 
set UpdatedOwnersState = PARSENAME (REPLACE(OwnerAddress,',','.'),1) 

Alter table  Nashville_housing_DataCleaning
Drop Column owneraddress

----------------------------------------------------------------------------------------------------------------------------------

--Changing the Y n N into Yes n NO in the "SoldAsVacant" Column--

--EDA

SELECT DISTINCT SoldAsVacant, Count(SoldAsVacant)
FROM [Nashville_housing_DataCleaning ]
GROUP BY SoldAsVacant
order by 2

--Chnage 

SELECT SoldAsVacant,
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM [Nashville_housing_DataCleaning ]

UPDATE [Nashville_housing_DataCleaning ]
SET SoldAsVacant = 
CASE 
When SoldAsVacant = 'Y' THEN 'Yes'
When SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END

----------------------------------------------------------------------------------------------------------------------------------

--Removing any existing Dublicates from the table--
-- Done By Creating a CTE

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY 
	ParcelID,
    SalePrice,
    AlteredSaleDate,
    LegalReference 
	ORDER BY UniqueID
	) as row_num
From [Nashville_housing_DataCleaning ]
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

----------------------------------------------------------------------------------------------------------------------------------

--Droping column that isnt important--

Select *
From [Nashville_housing_DataCleaning ]


ALTER TABLE [Nashville_housing_DataCleaning ]
DROP COLUMN TaxDistrict

----------------------------------------------------------------------------------------------------------------------------------