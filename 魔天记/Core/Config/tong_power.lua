local tong_power={
[1]={1,'帮主',1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,10},
[2]={2,'副帮主',1,1,1,1,1,1,0,0,0,1,1,1,1,0,1,3,8},
[4]={4,'成员',0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,3,4},
[5]={5,'学徒',0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,3,2}
}
local ks={id=1,position=2,dismissal=3,quit=4,invitation=5,approve=6,open=7,notice=8,promotion=9,assignment=10,dissolve=11,tong_war=12,booking_battle=13,hostile=14,recruit=15,assign=16,research_skill=17,salary_type=18,salary_weight=19}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tong_power)do setmetatable(v,base)end base.__metatable=false
return tong_power
