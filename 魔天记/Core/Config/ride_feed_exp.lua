local ride_feed_exp={
[358001]={358001,571,330001},
[358003]={358003,571,330003},
[358004]={358004,771,330004},
[358005]={358005,1000,330005},
[358006]={358006,1000,330006},
[358007]={358007,1000,330007},
[358009]={358009,771,330009},
[358010]={358010,11000,330010},
[358011]={358011,571,330011},
[358014]={358014,1000,330014},
[358015]={358015,1000,330015},
[358016]={358016,1000,330016},
[358019]={358019,1000,330019}
}
local ks={chip_id=1,feed_exp=2,ride_id=3}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(ride_feed_exp)do setmetatable(v,base)end base.__metatable=false
return ride_feed_exp
