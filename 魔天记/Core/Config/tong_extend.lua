local tong_extend={
[3]={3,'仙盟首领',2,130,1,4,'XMSL',2,{},{'每周一、三、四、六晚21:00'},'每周一、三、四、六晚21:00',''},
[5]={5,'仙盟任务',1,155,1,1,'XMRW',1,{},{},'全天开放',''},
[8]={8,'气运战',3,45,1,5,'XMZ',1,{},{'每周二、五晚21:00'},'每周二、五晚21:00',''},
[9]={9,'仙盟聚会',1,45,1,6,'XMJH',2,{},{'20:30-20:45'},'每天20点30分开启','20:27'},
[50]={50,'功勋商店',1,120,2,1,'award_50',0,{},{},'',''},
[52]={52,'仙盟工资',1,45,2,2,'award_52',0,{},{},'',''},
[53]={53,'仙盟技能',2,45,2,3,'award_52',0,{},{},'',''}
}
local ks={id=1,name=2,level=3,req_lev=4,type=5,sort=6,icon=7,openType=8,weeks=9,openParam=10,openDesc=11,showtime=12}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tong_extend)do setmetatable(v,base)end base.__metatable=false
return tong_extend
