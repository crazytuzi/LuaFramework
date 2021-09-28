local scence_prop={
[900001]={900001,'测试场景物品测试',1,709999,252,55,-180,0,1,{'2000','3000'},'attack01','die','partner_19',1},
[900002]={900002,'火堆',2,706500,1063,0,188,0,0,{},'attack01','die','partner_19',1}
}
local ks={id=1,name=2,type=3,in_map_id=4,x=5,y=6,z=7,angle=8,click_fun_id=9,param=10,born_act_name=11,die_act_name=12,model_id=13,model_rate=14}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(scence_prop)do setmetatable(v,base)end base.__metatable=false
return scence_prop
