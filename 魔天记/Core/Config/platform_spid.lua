local platform_spid={
[11]={11,'kr_google',{1,2,3,4,5,6,7,8,9,10,11,12,13},{'ma_fix_11000','ma_shop_diamond_150','ma_shop_diamond_250','ma_shop_diamond_500','ma_shop_diamond_1500','ma_shop_diamond_2500','ma_shop_diamond_5000','ma_pack_limited_1100','ma_pack_limited_3300','ma_pack_limited_5500','ma_pack_limited_8800','ma_grow_22000','ma_special_5500'},{11000,3300,5500,11000,33000,55000,110000,1100,3300,5500,8800,22000,5500}},
[12]={12,'kr_onestore',{1,2,3,4,5,6,7,8,9,10,11,12,13},{'0910088867','0910088868','0910088869','0910088870','0910088871','0910088872','0910088873','0910088874','0910088875','0910088876','0910088877','0910088878','0910088866'},{11000,3300,5500,11000,33000,55000,110000,1100,3300,5500,8800,22000,5500}}
}
local ks={id=1,plat_id=2,cn_spid=3,spid=4,price=5}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(platform_spid)do setmetatable(v,base)end base.__metatable=false
return platform_spid
