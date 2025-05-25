DECLARE @email_address VARCHAR(200)= 'dave-balslantyne@@abc.com.in'
--DECLARE @email_address VARCHAR(200)= 'hi@hello.co.in'

--SELECT LEN(SUBSTRING(@email_address, CHARINDEX('.',@email_address ,CHARINDEX('@',@email_address)) - CHARINDEX('@',@email_address ) + LEN(LEFT(@email_address, CHARINDEX('@', @email_address)+1)),LEN(@email_address)))
--		-LEN(REPLACE(SUBSTRING(@email_address, CHARINDEX('.',@email_address ,CHARINDEX('@',@email_address)) - CHARINDEX('@',@email_address ) + LEN(LEFT(@email_address, CHARINDEX('@', @email_address)+1)),LEN(@email_address)),'.',''))


----SELECT LEN('dave-balslantyne@dav')

--SELECT REPLACE('a.b.c','.','')

SELECT CASE WHEN  
     CHARINDEX(' ',LTRIM(RTRIM(@email_address))) = 0
AND  PATINDEX('%[~,`,!,#,$,%,^,&,*,(,),=,+,\,/,?,<,>,:,|,{,},'']%',@email_address) = 0    
AND  (LEN(SUBSTRING(@email_address,1,LEN(LEFT(@email_address, CHARINDEX('@', @email_address) -1)))) - LEN(REPLACE(SUBSTRING(@email_address,1,LEN(LEFT(@email_address, CHARINDEX('@', @email_address) -1))),'-',''))) < = 1
AND  (LEN(SUBSTRING(@email_address,1,LEN(LEFT(@email_address, CHARINDEX('@', @email_address) -1)))) - LEN(REPLACE(SUBSTRING(@email_address,1,LEN(LEFT(@email_address, CHARINDEX('@', @email_address) -1))),'_',''))) < = 1
AND  (LEN(SUBSTRING(@email_address,1,LEN(LEFT(@email_address, CHARINDEX('@', @email_address) -1)))) - LEN(REPLACE(SUBSTRING(@email_address,1,LEN(LEFT(@email_address, CHARINDEX('@', @email_address) -1))),'.',''))) < = 1
AND  LEFT(LTRIM(@email_address),1) <> '@' 
AND  RIGHT(RTRIM(@email_address),1) <> '.' 
AND  CHARINDEX('.',@email_address ,CHARINDEX('@',@email_address)) - CHARINDEX('@',@email_address ) > 1 
AND  LEN(LTRIM(RTRIM(@email_address ))) - LEN(REPLACE(LTRIM(RTRIM(@email_address)),'@','')) = 1 
AND  CHARINDEX('.',REVERSE(LTRIM(RTRIM(@email_address)))) >= 3 
AND  (
		CHARINDEX('.@',@email_address ) = 0 
	AND CHARINDEX('-@',@email_address ) = 0
	AND CHARINDEX('_@',@email_address ) = 0
	AND CHARINDEX('..',@email_address ) = 0
	 )
AND LEN(SUBSTRING(@email_address, CHARINDEX('.',@email_address ,CHARINDEX('@',@email_address)) - CHARINDEX('@',@email_address ) + LEN(LEFT(@email_address, CHARINDEX('@', @email_address)+1)),LEN(@email_address)))
		-LEN(REPLACE(SUBSTRING(@email_address, CHARINDEX('.',@email_address ,CHARINDEX('@',@email_address)) - CHARINDEX('@',@email_address ) + LEN(LEFT(@email_address, CHARINDEX('@', @email_address)+1)),LEN(@email_address)),'.','')) <=1
THEN 'valid email address'
ELSE
    'not valid'
       END
       
       
       --SELECT PATINDEX('%[~,`,!,#,$,%,^,&,*,(,),=,+,\,/,?,<,>,:,|,{,}]%','jacob-sebastian')

  