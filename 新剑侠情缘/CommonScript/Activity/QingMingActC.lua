if not MODULE_GAMESERVER then
    Activity.QingMingAct = Activity.QingMingAct or {}
end
local tbAct = MODULE_GAMESERVER and Activity:GetClass("QingMingAct") or Activity.QingMingAct

tbAct.szFubenClass = "QingMingFubenBase"
tbAct.nSitSkill  = 1083 					-- 打坐动作
tbAct.nEffectId = 1086 						-- 修炼身上的特效

tbAct.nWorshipTimes = 10 					-- 祭拜一共加5次经验
tbAct.nWorshipDelayTime = 6 				-- 6秒加一次经验
tbAct.nWorshipAddExpRate = 3			-- 经验倍率

-- 领活跃奖励
tbAct.tbActiveAward = {[1] = {{"item", 4426, 1}}, [2] = {{"item", 4426, 1}}, [3] = {{"item", 4426, 1}}, [4] = {{"item", 4426, 1}}, [5] = {{"item", 4426, 1}}};
-- 合成地图需要几个线索
tbAct.nClueCompose = 5
-- 线索道具模板ID
tbAct.nClueItemTID = 4426
-- 地图道具模板ID
tbAct.nMapItemTID = 4425
-- 活动中所有用到的地图信息
tbAct.tbMapInfo = {
	{nMapTID = 1602, szName = "心魔幻境·忘忧岛",   --[[szTip = "",]] szIntrol = "无忧教当代教主，纳兰真及月眉儿的父亲，是个彻头彻尾的野心家，为了自己的目的而不择手段，罔顾亲情爱情，弑师害兄，最终独霸无忧教，其境界高深武功更是出神入化，一直觊觎《武道德经》。后与杨影枫决斗，落败身陨。\n"},
	{nMapTID = 1603, szName = "心魔幻境·凤凰山",   --[[szTip = "",]] szIntrol = "独孤剑的恋人，“飞剑客”张风之女，张如梦之妹。她从来未曾想到一见钟情的少年，竟与自己有血海深仇，徒自黯然神伤。当误会被解开后，就一心跟着独孤剑，以稚嫩的肩膀与他一起担负拯救家国、为父报仇的使命。\n"},
	{nMapTID = 1604, szName = "心魔幻境·凌绝峰",   --[[szTip = "",]] szIntrol = "月眉儿之父，飞龙堡前堡主，江湖人称「北上官，南熙烈」的武林两大使剑高手之一，为人成熟稳重，不喜争斗，剑法也是走的沉稳一路，招式环环相扣，使敌人不知不觉陷入绝地。在凌绝峰被迫接受杨熙烈的挑战，两人全力相斗，双双殒命。\n"},
	{nMapTID = 1605, szName = "心魔幻境·剑气峰",   --[[szTip = "",]] szIntrol = "藏剑山庄庄主，武林中新一辈青年俊杰，英俊潇洒，文武双全，江湖上人人敬仰。实则城府极深，为得到《武道德经》，不惜派遣侍妾紫轩勾引杨影枫，阴谋败露后更是将杨影枫打下剑气峰。但他没想到杨影枫坠落剑气峰不但未死还武功大进，最终在与杨比武时含恨殒命。\n"},
	{nMapTID = 1606, szName = "心魔幻境·凌绝峰",   --[[szTip = "",]] szIntrol = "杨影枫之父，江湖人称「北上官，南熙烈」的武林两大使剑高手之一，为人豪爽，重情义，但有时兴之所至，不顾他人感受，性格如同其剑招，咄咄逼人，不留余地。后在凌绝峰与上官飞龙比武，胜负难分，力竭殒命。\n"},
	{nMapTID = 1607, szName = "心魔幻境·落叶谷",   --[[szTip = "",]] szIntrol = "落叶谷主，也是武林中众人推举的盟主，蔷薇之父。武功极高，江湖上已少有人能与之比剑，为人沉稳，相信只要心怀大志，迟早能够名动天下。后纳兰潜凛血洗武林，孟知秋寡不敌众，英年早逝。\n"},
	{nMapTID = 1608, szName = "心魔幻境·临安郊外", --[[szTip = "",]] szIntrol = "江湖四大剑客「天心飞仙」之「飞剑客」，张如梦和张琳心之父，南宋临安都指挥使。与「仙剑客」独孤云一起前往金国意图救出徽钦二帝，后败露，为保护「山河社稷图」假装被「天剑客」南宫灭收买，亲手杀死受尽折磨、生不如死的至交好友「仙剑客」独孤云。忍辱偷生多年，后命丧南宫灭之手。\n"},
	{nMapTID = 1609, szName = "心魔幻境·武当山",   --[[szTip = "",]] szIntrol = "武当前代掌门人，与武林盟主孟知秋是至交。武林名宿，得道高人，传言其武功得玄天道人指点，深不可测，在江湖上声望极高，曾受邀见证杨影枫戳穿卓非凡阴谋的生死决斗。后来，杨影枫成功摧毁纳兰潜凛的惊天奇谋，也得到了他的极大帮助。\n"},
	{nMapTID = 1610, szName = "心魔幻境·风波亭",   --[[szTip = "",]] szIntrol = "南宋中兴四将之一，抗金名将，著名军事家、战略家、民族英雄，南宋最杰出的统帅，缔造“连结河朔”，主张民间抗金义军和宋军互相配合夹击金军以收复失地。岳飞治军赏罚分明，纪律严整，又能体恤部属，以身作则，其「岳家军」号称「冻死不拆屋，饿死不打掳」，金人流传「撼山易，撼岳家军难」\n"},
}
-- 玩家自己可能使用地图道具的次数，会根据这个次数提前随好所有地图ID
tbAct.nMaxUseMap = 6
-- 使用地图道具需达到的亲密度
tbAct.nUseMapImityLevel = 5
-- 双方距离
tbAct.MIN_DISTANCE = 1000
-- 协助次数刷新时间点
tbAct.nAssistRefreshTime = 4 * 60 * 60
-- 每天最多可协助次数
tbAct.nMaxAssistCount = 1
-- 参与等级
tbAct.nJoinLevel = 20
-- 协助奖励
tbAct.tbAssistAward = {{"Contrib", 200}}
-- 每天捐献可获得的线索奖励,刷新时间点为协助次数刷新时间点
tbAct.nMaxClueDonatePerDay = 5
-- 每五次捐献的奖励
tbAct.tbDonateAward = {{"item", 4426, 1}}
-- 缅怀奖励
tbAct.tbWorshipAward = {{"item", 4428, 1}}
-- 每天可领取的最大缅怀奖励
tbAct.nMaxWorshipPerDay = 6

assert(#tbAct.tbMapInfo > 0 and tbAct.nMaxUseMap > 0, "[QingMingAct] assert setting fail " ..tbAct.nMaxUseMap .. #tbAct.tbMapInfo)

local nMaxBubbleCount = 10

function tbAct:InitSetting()
	self.tbMapSetting  = {}
	for _, tbInfo in ipairs(self.tbMapInfo) do
		self.tbMapSetting[tbInfo.nMapTID] = tbInfo
	end
end

tbAct:InitSetting()

function tbAct:GetMapSetting(nMapTID)
	return self.tbMapSetting[nMapTID]
end

function tbAct:CheckLevel(pPlayer)
	return pPlayer.nLevel >= self.nJoinLevel
end

function tbAct:OnLeaveWorshipMap()
	Ui:CloseWindow("HomeScreenFuben")
	Ui:CloseWindow("ChuangGongPanel")
end