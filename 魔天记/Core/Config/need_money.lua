local need_money={
[1]={1,'3',10},
[2]={2,'3',10},
[3]={3,'3',20},
[4]={4,'3',20},
[5]={5,'3',30},
[6]={6,'3',30},
[7]={7,'3',40},
[8]={8,'3',40},
[9]={9,'3',50},
[10]={10,'3',50},
[11]={11,'3',50},
[12]={12,'3',50},
[13]={13,'3',50},
[14]={14,'3',50},
[15]={15,'3',50},
[16]={16,'3',50},
[17]={17,'3',50},
[18]={18,'3',50},
[19]={19,'3',50},
[20]={20,'3',50}
}
local ks={count_id=1,money_type=2,need_money=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(need_money)do setmetatable(v,base)end base.__metatable=false
return need_money
