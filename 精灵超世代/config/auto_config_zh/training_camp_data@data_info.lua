-- this file is generated by program!
-- don't change it manaully.
-- source file: training_camp_data.xls

Config = Config or {} 
Config.TrainingCampData = Config.TrainingCampData or {}
Config.TrainingCampData.data_info_key_depth = 1
Config.TrainingCampData.data_info_length = 8
Config.TrainingCampData.data_info_lan = "zh"
Config.TrainingCampData.data_info = {
	[1] = {ban_pos={2,3,4,5},desc="元素之间相互克制，对应克制有伤害加成",flag=0,formation=1,id=1,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&例如：草元素的宝可梦对水元素的宝可梦造成的伤害有25%的加成，且有20%的命中加成",name="元素克制教学",partner_id={96011,96012,96013},required_partner={},reward={{3,50}},target_id=96010,tips="草系能克制水系",type=1,unlock={}},
	[2] = {ban_pos={2,3,5},desc="冰冻能限制敌方某单位一定回合的行动，让其被动挨打",flag=0,formation=1,id=2,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&所有的控制技能都能限制敌方某单位的行动，控制技能包括冰冻、眩晕、石化等；冰冻是成功率最高的控制技能，但被冰冻的目标在受击3次后，将解除冰冻状态\n \n特别注意：若解除冰冻时，该回合已错过该宝可梦的出手时间（出手时间详情请看出手顺序关卡），则该回合该宝可梦不会出手",name="控制教学",partner_id={96021,96022,96023},required_partner={{96029,4}},reward={{3,50}},target_id=96020,tips="盖欧卡能释放控制",type=1,unlock={1}},
	[3] = {ban_pos={2,3,5},desc="减益buff能一定回合内降低某单位一定属性",flag=0,formation=1,id=3,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&减益buff能对目标造成一定的影响，比如降低防御、降低输出、受到持续伤害等等\n \n破甲技能能使敌方某目标一定回合内防御力削减，能让我方输出打出更高的伤害",name="减益buff教学",partner_id={96031,96032,96033},required_partner={{96039,4}},reward={{3,50}},target_id=96030,tips="雷公能使对面防御降低",type=1,unlock={2}},
	[4] = {ban_pos={2,3,5},desc="角色的速度属性决定了其在战斗中的出手顺序",flag=0,formation=1,id=4,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&部分宝可梦的技能可以使对手降速，实现我方慢速的输出宝可梦能先手进攻。战斗每个回合开始时，将对双方全部宝可梦的速度进行排序，速度值越大，则排名越前；然后按照速度排名的先后双方宝可梦依次出手\n \n特别注意：若有多个宝可梦速度相同，则靠左边的宝可梦先出手；若靠左程度一样，则战力高的先出手",name="出手顺序教学",partner_id={96041,96042,96043},required_partner={{96049,4}},reward={{3,50}},target_id=96040,tips="急冻鸟能使对面减速",type=1,unlock={3}},
	[5] = {ban_pos={2,3,5},desc="增益buff能一定程度提升我方单位的属性",flag=0,formation=1,id=5,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&增益buff的对象往往是我方宝可梦，能够根据技能效果，提升我方单位一定的属性，也能做到让我方宝可梦造成更多的伤害",name="增益buff教学",partner_id={96051,96052,96053},required_partner={{96059,4}},reward={{3,50}},target_id=96050,tips="水君能提升己方属性",type=1,unlock={4}},
	[6] = {ban_pos={2,3},desc="合理的站位能规避敌方的重火力进攻",flag=0,formation=5,id=6,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&一般而言，我们需要保护我方输出宝可梦，避开对方的直接攻击，让我方有反击的机会",name="站位教学",partner_id={96065},required_partner={{96066,1}},reward={{3,50}},target_id=96060,tips="保护输出，避开敌人（请拖动宝可梦变更站位）",type=1,unlock={5}},
	[7] = {ban_pos={},desc="特定的阵法能满足整体站位需求",flag=1,formation=0,id=7,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&某些特定的站位需求需要配合特定的阵法才能实现。例如上图，只有天攻阵能让我方三个宝可梦站在中间一列；同理，只有地绝阵能让我方三个宝可梦站在最后一列",name="阵法教学",partner_id={},required_partner={{96075,3},{96076,2},{96077,1},{96078,4},{96079,5}},reward={{3,50}},target_id=96070,tips="地绝阵，能让己方三个输出站后排",type=1,unlock={6}},
	[8] = {ban_pos={},desc="了解每个宝可梦的定位，合理搭配阵容，做到最强输出",flag=0,formation=6,id=8,message="元素克制效果：<div fontcolor=289b14>伤害+25% 命中+20%</div>&&img1&&合理的阵容搭配要兼顾治疗和输出，考虑宝可梦之间的协同能力，两位看起来很弱的宝可梦组合起来产生的化学反应会让人意想不到\n \n水君在我方一速出手可有效提升我方战士的输出；裂空座和超梦第一回合压低对方血量，第二回合大招爆发造成敌方减员；梦幻提供了一定的回复能力\n \n那么你能补全这个阵容的最后一块拼图吗？提示，注意生存",name="阵容教学",partner_id={96081,96082,96083},required_partner={{96086,1},{96087,4},{96088,2},{96089,5}},reward={{3,100}},target_id=96080,tips="凤王能让己方暴击回血",type=2,unlock={1,2,3,4,5,6,7}},
}
