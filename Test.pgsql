SELECT amt
    , translate
    ( substr(v, 1,1)||case when substr(v, 1,1) = '0' then '' else '천' end
   || substr(v, 2,1)||case when substr(v, 2,1) = '0' then '' else '백' end
   || substr(v, 3,1)||case when substr(v, 3,1) = '0' then '' else '십' end
   || substr(v, 4,1)||case when substr(v, 1,4) = '0000' then '' else '조' end
   || substr(v, 5,1)||case when substr(v, 5,1) = '0' then '' else '천' end
   || substr(v, 6,1)||case when substr(v, 6,1) = '0' then '' else '백' end
   || substr(v, 7,1)||case when substr(v, 7,1) = '0' then '' else '십' end
   || substr(v, 8,1)||case when substr(v, 5,4) = '0000' then '' else '억' end
   || substr(v, 9,1)||case when substr(v, 9,1) = '0' then '' else '천' end
   || substr(v,10,1)||case when substr(v,10,1) = '0' then '' else '백' end
   || substr(v,11,1)||case when substr(v,11,1) = '0' then '' else '십' end
   || substr(v,12,1)||case when substr(v, 9,4) = '0000' then '' else '만' end
   || substr(v,13,1)||case when substr(v,13,1) = '0' then '' else '천' end
   || substr(v,14,1)||case when substr(v,14,1) = '0' then '' else '백' end
   || substr(v,15,1)||case when substr(v,15,1) = '0' then '' else '십' end
   || substr(v,16,1)
    , '1234567890', '일이삼사오육칠팔구') v
FROM (SELECT amt, LPAD(amt,16,'0') v from hangeul) h
;