local star_expend={
[1]={1,1,503200,1,100},
[2]={2,2,503200,10,90}
}
local ks={id=1,type=2,req_item=3,req_num=4,item_price=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(star_expend)do setmetatable(v,base)end base.__metatable=false
return star_expend
