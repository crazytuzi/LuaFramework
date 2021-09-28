local tong_monster={
[1]={1,125001,1.4,'屠世猎手','杀人如麻、横行云川大陆妖兽之一，其手段凶残毒辣、乖戾异常，是为强敌','魔魂噬体','在自身圆形范围内召唤魔魂，对区域内的目标造成伤害','心灵之光','发射一道心灵之光，对矩形区域内的目标造成持续伤害','','','','','',''},
[2]={2,125002,0.8,'梦萦蛊','世上五大邪蛊之一，一旦寄生在他人身体中就会立刻和寄生者精魂形成一种共生局面，令其陷入无休止睡眠之中','狂暴','给自身施加一个增益状态，在此状态下提升自身物理攻击，该状态持续一段时间','跳扑','跳向前方一段距离，对前方矩形区域内的目标造成伤害','','','','','',''},
[3]={3,125003,0.8,'蛮力鬼王','蛮鬼宗九婴一脉镇山至宝，九婴一脉掌门曾将蛮力鬼王交于柳鸣，让其在奇袭海族时助其一臂之力','喷火','向前方扇形区域内喷射大火，对扇形区域内的目标造成持续伤害','流星','在目标区域内召唤流星，对区域内的目标造成持续持续伤害','','','','','',''}
}
local ks={id=1,monster_id=2,model_scale_rate=3,name=4,desc=5,skill_name_1=6,skill_desc_1=7,skill_name_2=8,skill_desc_2=9,skill_name_3=10,skill_desc_3=11,skill_name_4=12,skill_desc_4=13,skill_name_5=14,skill_desc_5=15}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(tong_monster)do setmetatable(v,base)end base.__metatable=false
return tong_monster
