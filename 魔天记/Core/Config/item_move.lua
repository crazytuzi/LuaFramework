local item_move={
[1]={1,'backBag_main_bt','getProAndMoveToBt',{'505053','505153，505253','505353'}},
[2]={2,'skill1','getNewSkillAndMoveToBt',{'201150','202160','203220','204150'}},
[3]={3,'skill2','getNewSkillAndMoveToBt',{'201240','202210','203150','204230'}},
[4]={4,'skill3','getNewSkillAndMoveToBt',{'201230','202230','203170','204170'}},
[5]={5,'skill4','getNewSkillAndMoveToBt',{'201220','202240','203180','204210'}}
}
local ks={key_id=1,bd_name=2,interface_id=3,interface_param=4}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(item_move)do setmetatable(v,base)end base.__metatable=false
return item_move
