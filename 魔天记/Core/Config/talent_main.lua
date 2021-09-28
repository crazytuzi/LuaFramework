local talent_main={
[10011]={10011,101000,'太罡真气',1,40,30,'提升法术穿透属性值','tqm_1'},
[10012]={10012,101000,'凝法真气',1,40,30,'提升法术攻击力百分比','tqm_2'},
[10013]={10013,101000,'护体真气',1,40,30,'提升法术吸血属性值','tqm_3'},
[10021]={10021,101000,'剑法诀',2,50,30,'太罡御剑术有概率提升自身法术强度；','tqm_4'},
[10022]={10022,101000,'雷法诀',2,50,30,'九天神雷对敌人追加电流，3层；','tqm_5'},
[10023]={10023,101000,'斩龙诀',2,50,30,'释放虚空斩技能，有几率对敌人造成眩晕；','tqm_6'},
[10031]={10031,101000,'辰星诀',3,60,30,'解锁辰星诀，替换飞剑诀','tqm_10'},
[10032]={10032,101000,'追风剑',3,60,30,'解锁追风剑，替换飞剑诀','tqm_11'},
[10033]={10033,101000,'强,元灵飞剑',3,60,30,'释放元灵飞剑时，恢复自身百分比的生命值；','tqm_12'},
[10041]={10041,101000,'太清之力',4,70,30,'目标生命值越低，造成伤害越高','tqm_7'},
[10042]={10042,101000,'剑神之力',4,70,30,'普通攻击有几率使太罡御剑术的技能CD重置；','tqm_8'},
[10043]={10043,101000,'嗜元之力',4,70,30,'被动：受到攻击生成吸收伤害的护盾，每1分钟触发一次；','tqm_9'},
[20011]={20011,102000,'龟甲功',1,40,30,'提升物理防御和法术防御','tyg_1'},
[20012]={20012,102000,'烈虎功',1,40,30,'提升物理攻击力','tyg_2'},
[20013]={20013,102000,'妖体功',1,40,30,'自身闪避增加','tyg_3'},
[20021]={20021,102000,'金刚诀',2,50,30,'大千震概率回复自身血量；','tyg_4'},
[20022]={20022,102000,'烈心诀',2,50,30,'猛要袭降低敌人攻击；','tyg_5'},
[20023]={20023,102000,'飞袭诀',2,50,30,'释放飞云袭，有几率对敌人造成眩晕；','tyg_6'},
[20031]={20031,102000,'混元妖力',3,60,30,'解锁混元妖力，替换破天棍','tyg_10'},
[20032]={20032,102000,'兽魂咆哮',3,60,30,'解锁兽魂咆哮，替换破天棍','tyg_11'},
[20033]={20033,102000,'强.兽甲诀',3,60,30,'强化兽甲诀，在兽甲决作用中时，反弹一定比例的伤害给攻击者。','tyg_12'},
[20041]={20041,102000,'圣斗之力',4,70,30,'普通攻击命中敌人可使得自身攻击临时提高，持续3秒，最多可叠加到6层。','tyg_8'},
[20042]={20042,102000,'战神之力',4,70,30,'获得损失生命值百分比的攻击力，生命值越低，攻击力越高；','tyg_9'},
[20043]={20043,102000,'不灭之力',4,70,30,'受到伤害有概率回复自身血量','tyg_7'},
[30011]={30011,103000,'厉鬼式',1,40,30,'提高自身破甲','mxz_1'},
[30012]={30012,103000,'葬魔式',1,40,30,'提高自身暴击率','mxz_2'},
[30013]={30013,103000,'幽冥式',1,40,30,'提高自身移动速度','mxz_3'},
[30021]={30021,103000,'九幽秘术',2,50,30,'疾风刺有概率提升攻击力百分之10；','mxz_4'},
[30022]={30022,103000,'魔切秘术',2,50,30,'舞魔切追加流血buff；','mxz_5'},
[30023]={30023,103000,'缠灵秘术',2,50,30,'疾风刺有概率眩晕敌人2s；','mxz_6'},
[30031]={30031,103000,'幻影飞轮',3,60,30,'解锁幻影飞轮，替换魔刹攻','mxz_10'},
[30032]={30032,103000,'分光化影',3,60,30,'解锁分光化影，替换魔刹攻','mxz_11'},
[30033]={30033,103000,'强.魔心决',3,60,30,'使用魔心决后，减少其他技能3秒的冷却时间；','mxz_12'},
[30041]={30041,103000,'逆流之力',4,60,30,'普通攻击有概率造成额外范围伤害；','mxz_7'},
[30042]={30042,103000,'憎意之力',4,60,30,'暴击伤害效果提升百分之20；','mxz_8'},
[30043]={30043,103000,'妖灵之力',4,60,30,'造成伤害的百分比将用于治疗自己；','mxz_9'},
[40011]={40011,104000,'奥术法诀',1,40,30,'增加法术强度','tgz_1'},
[40012]={40012,104000,'灵心法诀',1,40,30,'增加法力上限一定比例。','tgz_2'},
[40013]={40013,104000,'振奋法诀',1,40,30,'增加生命上限一定比例','tgz_3'},
[40021]={40021,104000,'智慧法典',2,50,30,'机关落有一定几率提高自身法术强度百分之10；','tgz_4'},
[40022]={40022,104000,'神圣法典',2,50,30,'狂风骤雨降低魔抗；','tgz_5'},
[40023]={40023,104000,'惩戒法典',2,50,30,'连珠流云弹有概率附带眩晕；','tgz_6'},
[40031]={40031,104000,'强狂风骤雨',3,60,30,'提升伤害','tgz_10'},
[40032]={40032,104000,'强荆棘之雨',3,60,30,'提升伤害','tgz_11'},
[40033]={40033,104000,'强.聚灵之术',3,60,30,'使用聚灵，提升目标双抗，持续10秒；','tgz_12'},
[40041]={40041,104000,'灵鹫之力',4,70,30,'普攻会给目标施加伤害加深的buff，可叠加；','tgz_7'},
[40042]={40042,104000,'回升之力',4,70,30,'聚灵之术将为目标附加持续回血的hot；','tgz_8'},
[40043]={40043,104000,'金鹏之力',4,70,30,'增加自身闪避和韧性；','tgz_9'}
}
local ks={id=1,career=2,name=3,phase=4,learn_lv=5,talent_maxlv=6,desc=7,icon=8}
local base={__index=function(t,k)if k=='cks' then return ks end local ind=ks[k] return ind and t[ind] or nil end}for k,v in pairs(talent_main)do setmetatable(v,base)end base.__metatable=false
return talent_main
