local promote_rate={
[0]={0,0,0,100,0,0,0,0,0,'352004_1',10},
[1]={1,1,0,100,0,0,0,0,0,'352004_1',10},
[2]={2,2,0,90,1,0,0,1,0,'352004_2',10},
[3]={3,3,0,80,1,0,0,1,0,'352004_2',10},
[4]={4,4,0,70,1,0,0,1,0,'352004_3',10},
[5]={5,5,0,60,1,0,0,1,0,'352004_3',10},
[6]={6,6,0,50,1,0,0,1,0,'352004_4',10},
[7]={7,7,0,40,1,0,352008,2,8,'352004_4',10},
[8]={8,8,0,30,1,0,352009,6,20,'352004_5',10},
[9]={9,9,0,20,1,0,352010,15,50,'352004_5',10},
[10]={10,10,0,15,1,0,352011,30,120,'352004_6',10},
[11]={11,11,0,10,1,0,352012,80,300,'352004_6',10},
[12]={12,12,0,5,1,0,352013,250,800,'352004_7',10},
[13]={13,13,0,5,1,0,352014,600,2000,'352004_7',10},
[14]={14,14,0,5,1,0,352015,1200,5000,'352004_8',10},
[15]={15,15,0,0,0,0,0,0,0,'',10}
}
local ks={id=1,promote_lev=2,attribute_per=3,rate=4,down_nprotect=5,down_protect=6,protect_id=7,lucky_level=8,lucky_limit=9,promote_res=10,promote_price=11}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(promote_rate)do setmetatable(v,base)end base.__metatable=false
return promote_rate
