local boss_base={
[55]={55,55,128000,0.8,708000,-126,875,{'0_3_100','4_7_50','8_11_-100','12_15_-200','16_19_-300','20_23_-400','24_9999_-500'},{'500300_1','358006_1','506060_1','15_1'},'外族入侵，天地骤变，人族发源之地中天大陆遭遇数百万年以来最为残酷的的天地大劫，天地之间元气聚变……数百万年前古魔界入侵中天大陆被远古大能封印在无尽深渊之中的上古魔主一丝苏醒的元灵竟在聚变之中逃逸而出……螟族未灭，魔主苏醒，中天大陆岌岌可危，或将万劫不复！'}
}
local ks={world_lev=1,boss_lev=2,monster_id=3,model_rate=4,map_id=5,x=6,z=7,att_change=8,drop=9,desc=10}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(boss_base)do setmetatable(v,base)end base.__metatable=false
return boss_base
