local strong_fight={
[1]={1,1,49,3300,'0_1800','1801_3000','3001_5000','5001_6600','6601_9900','9901_99999999'},
[2]={2,50,79,27700,'0_15200','15201_24900','24901_41600','41601_55400','55401_83100','83101_99999999'},
[3]={3,80,109,39200,'0_21600','21601_35300','35301_58800','58801_78400','78401_117600','117601_99999999'},
[4]={4,110,139,94200,'0_51800','51801_84800','84801_141300','141301_188400','188401_282600','282601_99999999'},
[5]={5,140,169,135600,'0_74600','74601_122000','122001_203400','203401_271200','271201_406800','406801_99999999'},
[6]={6,170,199,247200,'0_136000','136001_222500','222501_370800','370801_494400','494401_741600','741601_99999999'},
[7]={7,200,229,381800,'0_210000','210001_343600','343601_572700','572701_763600','763601_1145400','1145401_99999999'},
[8]={8,230,259,567300,'0_312000','312001_510600','510601_851000','851001_1134600','1134601_1701900','1701901_99999999'},
[9]={9,260,289,763000,'0_419700','419701_686700','686701_1144500','1144501_1526000','1526001_2289000','2289001_99999999'},
[10]={10,290,319,991224,'0_545200','545201_892100','892101_1486800','1486801_1982400','1982401_2973700','2973701_99999999'},
[11]={11,320,349,1688534,'0_928700','928701_1519700','1519701_2532800','2532801_3377100','3377101_5065600','5065601_99999999'},
[12]={12,350,379,2541180,'0_1397600','1397601_2287100','2287101_3811800','3811801_5082400','5082401_7623500','7623501_99999999'},
[13]={13,380,409,3508878,'0_1929900','1929901_3158000','3158001_5263300','5263301_7017800','7017801_10526600','10526601_99999999'},
[14]={14,410,439,5012672,'0_2757000','2757001_4511400','4511401_7519000','7519001_10025300','10025301_15038000','15038001_99999999'},
[15]={15,440,469,6576314,'0_3617000','3617001_5918700','5918701_9864500','9864501_13152600','13152601_19728900','19728901_99999999'},
[16]={16,470,499,8435368,'0_4639500','4639501_7591800','7591801_12653100','12653101_16870700','16870701_25306100','25306101_99999999'},
[17]={17,500,529,10122441,'0_5567300','5567301_9110200','9110201_15183700','15183701_20244900','20244901_30367300','30367301_99999999'}
}
local ks={id=1,min_lev=2,max_lev=3,rec_fighting=4,appraise_1=5,appraise_2=6,appraise_3=7,appraise_4=8,appraise_5=9,appraise_6=10}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(strong_fight)do setmetatable(v,base)end base.__metatable=false
return strong_fight
