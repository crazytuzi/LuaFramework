local festival_consume={
[1]={1,{'506010_5','506010_10','506010_15','506010_20','506010_25','506010_30','506010_35'},2,200,'no1'},
[2]={2,{'506010_5','506010_10','506010_15','506010_20','506010_25','506010_30','506010_35'},2,200,'no2'},
[3]={3,{'506011_5','506011_10','506011_15','506011_20','506011_25','506011_30','506011_35'},2,200,'no3'},
[4]={4,{'506011_5','506011_10','506011_15','506011_20','506011_25','506011_30','506011_35'},2,200,''},
[5]={5,{'506020_5','506020_10','506020_15','506020_20','506020_25','506020_30','506020_35'},2,200,''},
[6]={6,{'506020_5','506020_10','506020_15','506020_20','506020_25','506020_30','506020_35'},2,200,''},
[7]={7,{'506021_5','506021_10','506021_15','506021_20','506021_25','506021_30','506021_35'},2,200,''},
[8]={8,{'506021_5','506021_10','506021_15','506021_20','506021_25','506021_30','506021_35'},2,200,''},
[9]={9,{'506030_5','506030_10','506030_15','506030_20','506030_25','506030_30','506030_35'},2,200,''},
[10]={10,{'506030_5','506030_10','506030_15','506030_20','506030_25','506030_30','506030_35'},2,200,''}
}
local ks={rank=1,item_id=2,buy_type=3,minconsume=4,icon=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(festival_consume)do setmetatable(v,base)end base.__metatable=false
return festival_consume
