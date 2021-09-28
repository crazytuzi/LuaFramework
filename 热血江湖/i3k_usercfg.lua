-------------------------------------------
--module(..., package.seeall)

local require = require;

require("i3k_global");


-------------------------------------------
user_cfg =
{
	username	= "",
	muteTable	= { },
	usercontrol	= 3,--1：点击地面，2：摇杆，3：兼具
	isSelect = 1,--是否选择自动吃药默认0没有
	mark = 70,--自动吃药默认初始值1
	activityTransCoolTime = {cool = 0, thatTime = 0},
	bgVolume = 80, --背景音乐
	effectVolume = 80, --其它音效
	isTouchOperate = 0,  -- 1 为真  0为假
	cameraInter = 0.75,  -- [0, 1]
--	isShowHeadInfo = 1, -- [0, 1]
	isShowMyselfHeadInfo = 1,
	isShowOthersHeadInfo = 1,
	--filterTxLvl = 1, -- 特效等级
	autoAcceptMatchTeamRequest = 0, -- 自动接受组队邀请
	autoAcceptMatchTeamApply = 1,  -- 自动接受组队申请
	lastSelectRole = 1,	--上次选择的角色
	recentServerList = {},
	recentServerIp = "127.0.0.1:1106",
	recentServerName = "05服-神地",
	taskListOrder = {},
	funcOpenData = {},--功能开启
	isPrompt = 1, --神兵提示
	steedSkinPrompt = 1, --坐骑皮肤提示
	isPetCanUsePool = 1,
	banPushServices = {},
	channelName = "",
	dungeonWaitTip = {},
	matchTournament = 0,
	matchForceWar = 0,
	matchFightTeam = 0,
	globalMatchTeam = 0,
	lastSeclectFiveUnique = 1,
	curSelectFiveUniqueLevel = 1,
	filterPlayerNum = 10,
	isSpanTips = 1,
	isAutoSuperMode = 1, --是否自动变身
	isAreanDefendTips = 1,
	redEnvelope = 0, -- 0 默认不屏蔽红包
	notShowDay = 0, --点击活动补做中“不再提醒”按钮的时间
	fpsLimit = 2,  -- 限制帧率，-1表示不限制，有3个档位，30,45,60
	todayNotShow = {0, 0, 0, 0, 0, 0,},  --今日不再提示
	powerSave = {}, -- 省电模式
	autoPowerSave = 1, -- 自动开启省电模式
	autoSaleEquip = 0, -- 自动售卖蓝绿装备
	autoSaleDrug = 0, -- 自动售卖蓝绿药
	autoFightRadius = 1,-- 自动战斗托管范围
	isAgreement = 0, --是否同意用户协议
	isMeridianRed = 0,--经脉红点
	steedEquipRed = 0, -- 骑战装备红点
	manifesto = "",--帮派招募宣言
	isShowShootMsg = 1, -- 是否开启帮派弹幕
	isShowHegemonyShootMsg = 1, --是否开启五绝争霸弹幕
	isShowBaguaGuide = 1, -- 是否引导八卦
	isShowAnswerTips = 0, --是否开启答题提醒
	isShowAnswerResult = 0, --是否弹过答题结果
	isHideAllArmorEffect = 0, --是否隐藏所有人的内甲特效 默认是不隐藏0
	isHideCar = 0,--是否屏蔽镖车
	equipTempQianChuiProps = {}, --装备千锤临时属性
	equipTempBaiLianProps = {}, --装备百炼临时属性
	defaultTemperSelectEquip = 0, --装备锤炼选中的默认装备位置
	defaultBaiLianPartID = 0, --装备百炼的partID
	isShowKillTips = 0, --0表示显示，1表示不显示
	daibiTipsShowTimes = 0, --背包切到显示代币，前三次给提示tips
	cameraShake = 1,  -- 摄像机抖动
	fenjie_hide_can_sell = 1,--分解
	fenjie_hide_high_power = 1,
	fenjie_show_purple = 1,
	fenjie_show_orange = 1,
	steedAutoRefine = {},--坐骑自动洗练
	steedAutoRefineInitFlag = {0, 0},--坐骑自动洗练战力提升和锁住提升自动保存
	activityShowTimes = {}, -- 拍脸图显示次数
	catchSpiritPreview = {}, -- 鬼岛驭灵预览拍脸
	catchSpiritOpen = {}, -- 鬼岛驭灵开放拍脸
	specialAction = {}, -- 外传职业特殊动作
	biographyTaskProgress = {}, -- 外传职业进度
	springRollShowGuide = 1, -- 新春灯券是否显示指引
	springRollQuiz = {}, -- 新春灯券猜谜题号
	customSkillOrder = {}, --技能自定义序列 1-默认  2-槽位
};

i3k_usercfg = i3k_class("i3k_usercfg");
function i3k_usercfg:ctor()
end

function i3k_usercfg:restoreUserCfg()
	user_cfg.username	= ""
	user_cfg.lastSelectRole = 1
	self:sendProtocol()
	self:Save()
	g_i3k_game_context:getInitNeedBanServices() -- 初始化下cfg中类型冲突的问题
end

function i3k_usercfg:resetUserCfg()
	-- user_cfg.username	= ""
	-- user_cfg.muteTable	= { }
	user_cfg.usercontrol	= 3
	user_cfg.isSelect = 1
	user_cfg.mark = 70
	-- user_cfg.activityTransCoolTime = {cool = 0, thatTime = 0}
	user_cfg.bgVolume = 80
	user_cfg.effectVolume = 80
	user_cfg.isTouchOperate = 0
	user_cfg.cameraInter = 0.75
--	user_cfg.isShowHeadInfo = 1
	user_cfg.isShowMyselfHeadInfo = 1
	user_cfg.isShowOthersHeadInfo = 1
	user_cfg.filterTxLvl = 1
	user_cfg.autoAcceptMatchTeamRequest = 0
	user_cfg.autoAcceptMatchTeamApply = 1
	-- user_cfg.lastSelectRole = 1
	-- user_cfg.recentServerList = {}
	-- user_cfg.recentServerIp = "127.0.0.1:1106"
	-- user_cfg.recentServerName = "01服-天池"
	-- user_cfg.taskListOrder = {}
	user_cfg.isPetCanUsePool = 1
	user_cfg.banPushServices = {}
	user_cfg.filterPlayerNum = 10
	user_cfg.isAutoSuperMode = 1
	user_cfg.redEnvelope = 0
	user_cfg.notShowDay = 0
	user_cfg.todayNotShow = {0, 0, 0, 0, 0, 0,}
	user_cfg.powerSave = {}
	user_cfg.autoPowerSave = 1
	user_cfg.autoSaleEquip = 0
	user_cfg.autoSaleDrug = 0
	user_cfg.autoFightRadius = 1
	user_cfg.isShowAnswerTips = 0
	user_cfg.isShowAnswerResult = 0
	user_cfg.isHideAllArmorEffect = 0
	user_cfg.isHideCar = 0
	user_cfg.equipTempQianChuiProps = {}
	user_cfg.equipTempBaiLianProps = {}
	user_cfg.defaultTemperSelectEquip = 0
	user_cfg.defaultBaiLianPartID = 0
	user_cfg.isShowKillTips = 0
	user_cfg.daibiTipsShowTimes = 0
	user_cfg.cameraShake = 1
	user_cfg.fenjie_hide_can_sell = 1--分解
	user_cfg.fenjie_hide_high_power = 1
	user_cfg.fenjie_show_purple = 1
	user_cfg.fenjie_show_orange = 1
	user_cfg.steedAutoRefine = {}--坐骑自动洗练
	user_cfg.steedAutoRefineInitFlag = {0, 0}
	self:sendProtocol()
	self:Save()

end
-- send protocol to notify server
function i3k_usercfg:sendProtocol()
	i3k_sbean.syncPetCanUsePool(user_cfg.isPetCanUsePool)
	i3k_sbean.syncAutoSaleEquip(user_cfg.autoSaleEquip)
	i3k_sbean.syncAutoSaleDrug(user_cfg.autoSaleDrug)
end

function i3k_usercfg:setIsPetCanUsePool(bValue)
	user_cfg.isPetCanUsePool = bValue and 1 or 0
	self:Save()
end

---------------------------------------
function i3k_usercfg:GetUserName()
	return user_cfg.username;
end

function i3k_usercfg:GetChannelName()
	return user_cfg.channelName
end

function i3k_usercfg:GetMute(id)
	return user_cfg.muteTable[id] or 0;
end

function i3k_usercfg:GetUserControl()
	return user_cfg.usercontrol
end

function i3k_usercfg:GetActTransCoolTime()
	return user_cfg.activityTransCoolTime
end

function i3k_usercfg:SetActTransCoolTime(time)
	user_cfg.activityTransCoolTime.cool = time
	user_cfg.activityTransCoolTime.thatTime = g_i3k_get_GMTtime(i3k_game_get_time())
	self:Save()
end

function i3k_usercfg:SetMute(id, m)
	user_cfg.muteTable[id] = m;
	self:Save();
end

function i3k_usercfg:SetUserName(name)
	user_cfg.username = name;

	self:Save();
end

function i3k_usercfg:SetChannelName(name)
	user_cfg.channelName = name
	self:Save()
end

function i3k_usercfg:SetUserControl(value)
	user_cfg.usercontrol = value
	self:Save()
end

function i3k_usercfg:SetAutoTakeBloodData(is_ok,count)
	user_cfg.isSelect = is_ok
	user_cfg.mark = count
	self:Save()
end

function i3k_usercfg:GetAutoTakeBloodData()
	return user_cfg.isSelect,user_cfg.mark
end

function i3k_usercfg:GetAutoBlood()
	return user_cfg.mark
end


function i3k_usercfg:SetVolume(bgVol,effVol)
	user_cfg.bgVolume = math.max(0, math.min(100, bgVol));
	user_cfg.effectVolume = math.max(0, math.min(100, effVol));
	self:Save()
end

function i3k_usercfg:GetVolume()
	return user_cfg.bgVolume,user_cfg.effectVolume
end

function i3k_usercfg:GetIsTouchOperate()
	return (user_cfg.isTouchOperate == 1)
end

function i3k_usercfg:SetIsTouchOperate(bValue)
	user_cfg.isTouchOperate = bValue and 1 or 0
end

function i3k_usercfg:GetCameraInter()
	return user_cfg.cameraInter;
end

function i3k_usercfg:SetCameraInter(value)
	user_cfg.cameraInter = math.max(0, math.min(1, value));
end

--[[function i3k_usercfg:GetIsShowHeadInfo()
	return (user_cfg.isShowHeadInfo == 1)
end

function i3k_usercfg:SetIsShowHeadInfo(value)
	user_cfg.isShowHeadInfo = value and 1 or 0
end--]]

function i3k_usercfg:GetIsShowMyselfHeadInfo()
	return (user_cfg.isShowMyselfHeadInfo == 1)
end

function i3k_usercfg:SetIsShowMyselfHeadInfo(value)
	user_cfg.isShowMyselfHeadInfo = value and 1 or 0
end

function i3k_usercfg:GetIsShowOthersHeadInfo()
	return (user_cfg.isShowOthersHeadInfo == 1)
end

function i3k_usercfg:SetIsShowOthersHeadInfo(value)
	user_cfg.isShowOthersHeadInfo = value and 1 or 0
end

function i3k_usercfg:GetFilterTXLvl()
	return user_cfg.filterTxLvl
end

function i3k_usercfg:SetFilterTXLvl(value)
	user_cfg.filterTxLvl = value
	self:Save()
end

function i3k_usercfg:GetDungeonWaitTipStatus(roleID)
	if user_cfg.dungeonWaitTip[roleID] then
		return user_cfg.dungeonWaitTip[roleID] == 1
	else
		return true
	end
end
function i3k_usercfg:SetDungeonWaitTipStatus(roleID,value)
	user_cfg.dungeonWaitTip[roleID] = value and 1 or 0
	self:Save()
end

function i3k_usercfg:GetMatchTeamRequestStatus()
	return user_cfg.autoAcceptMatchTeamRequest == 1
end
function i3k_usercfg:SetMatchTeamRequestStatus(value)
	user_cfg.autoAcceptMatchTeamRequest = value and 1 or 0
	self:Save()
end

function i3k_usercfg:GetMatchTeamApplyStatus()
	return user_cfg.autoAcceptMatchTeamApply == 1
end

function i3k_usercfg:SetMatchTeamApplyStatus(value)
	user_cfg.autoAcceptMatchTeamApply = value and 1 or 0
	self:Save()
end

function i3k_usercfg:GetSelectRole()
	return user_cfg.lastSelectRole
end

function i3k_usercfg:SetSelectRole(value)
	user_cfg.lastSelectRole = value
	self:Save()
end

function i3k_usercfg:GetSelectFiveUnique()
	return user_cfg.lastSeclectFiveUnique
end

function i3k_usercfg:SetSelectFiveUnique(value)
	user_cfg.lastSeclectFiveUnique = value
	self:Save()
end

function i3k_usercfg:SetSelectFiveUniqueLevel(level)
	user_cfg.curSelectFiveUniqueLevel = level
	self:Save()
end

function i3k_usercfg:GetSelectFiveUniqueLevel()
	return user_cfg.curSelectFiveUniqueLevel
end

function i3k_usercfg:GetRecentServerList()
	return user_cfg.recentServerList
end

function i3k_usercfg:SetRecentServerList(data)
	user_cfg.recentServerList = data
	self:Save()
end

function i3k_usercfg:GetRecentServerIp()
	return user_cfg.recentServerIp
end

function i3k_usercfg:SetRecentServerIp(serverIp)
	user_cfg.recentServerIp = serverIp
	self:Save()
end

function i3k_usercfg:GetRecentServerName()
	return user_cfg.recentServerName
end

function i3k_usercfg:SetRecentServerName(serverName)
	user_cfg.recentServerName = serverName
	self:Save()
end

function i3k_usercfg:GetTaskListOrderDate()
	return user_cfg.taskListOrder
end

function i3k_usercfg:SetTaskListOrderData(orderData)
	user_cfg.taskListOrder = orderData or {}
	self:Save()
end

function i3k_usercfg:GetFuncOpenDate()
	return user_cfg.funcOpenData
end

function i3k_usercfg:SetFuncOpenData(data)
	user_cfg.funcOpenData = data or {}
	self:Save()
end


function i3k_usercfg:SetIsPrompt(isPrompt)
	user_cfg.isPrompt = isPrompt
	self:Save()
end

function i3k_usercfg:getIsPetCanUsePool()
	return user_cfg.isPetCanUsePool == 1
end

function i3k_usercfg:SetBanPushServices(t)
	user_cfg.banPushServices = t or {}
	self:Save()
end

function i3k_usercfg:GetBanPushServices()
	return user_cfg.banPushServices
end


function  i3k_usercfg:GetIsPrompt()
	return user_cfg.isPrompt
end

function i3k_usercfg:SetSteedSkinPrompt(prompt)
	user_cfg.steedSkinPrompt = prompt
	self:Save()
end

function i3k_usercfg:GetSteedSkinPrompt()
	return user_cfg.steedSkinPrompt
end

function i3k_usercfg:SetMatchNotShow(matchType)
	if matchType==g_TOURNAMENT_MATCH then
		user_cfg.matchTournament = 1
	elseif matchType==g_FORCE_WAR_MATCH then
		user_cfg.matchForceWar = 1
	elseif matchType == g_FIGHT_TEAM_MATCH then
		user_cfg.matchFightTeam = 1
	elseif g_GLOBAL_MATCH_TEAM[matchType] then
		user_cfg.globalMatchTeam = 1
	end
	self:Save()
end

function i3k_usercfg:GetMatchIsShow(matchType)
	if matchType==g_TOURNAMENT_MATCH then
		return user_cfg.matchTournament~=1
	elseif matchType==g_FORCE_WAR_MATCH then
		return user_cfg.matchForceWar~=1
	elseif matchType == g_FIGHT_TEAM_MATCH then
		return user_cfg.matchFightTeam ~= 1
	elseif g_GLOBAL_MATCH_TEAM[matchType] then
		return user_cfg.globalMatchTeam ~= 1
	end
end

function i3k_usercfg:GetFilterPlayerNum()
	return user_cfg.filterPlayerNum
end

function i3k_usercfg:SetFilterPlayerNum(value)
	user_cfg.filterPlayerNum = value
	self:Save()
end

function i3k_usercfg:GetIsAutoSuperMode()
	return user_cfg.isAutoSuperMode == 1
end

function i3k_usercfg:SetIsAutoSuperMode(value)
	user_cfg.isAutoSuperMode = value and 1 or 0
	self:Save()
end

function i3k_usercfg:GetIsAreanDefendTips()
	return user_cfg.isAreanDefendTips == 1
end

function i3k_usercfg:SetIsAreanDefendTips(value)
	user_cfg.isAreanDefendTips = value
	self:Save()
end


function i3k_usercfg:GetIsSpanTips()
	return user_cfg.isSpanTips
end

function i3k_usercfg:SetIsSpanTips(value)
	user_cfg.isSpanTips = value
	self:Save()
end

function i3k_usercfg:GetRedEnvelope() -- true 表示屏蔽
	return user_cfg.redEnvelope == 1
end
function i3k_usercfg:SetRedEnvelope(bValue)
	user_cfg.redEnvelope = bValue and 1 or 0
	self:Save()
end

function i3k_usercfg:GetNotShowDay()
	return user_cfg.notShowDay
end

function i3k_usercfg:SetNotShowDay(bValue)
	user_cfg.notShowDay = bValue
	self:Save()
end

function i3k_usercfg:GetFPSLimit()
	return user_cfg.fpsLimit
end

function i3k_usercfg:SetFPSLimit(iValue)
	user_cfg.fpsLimit = iValue
	self:Save()
end

function i3k_usercfg:GetAutoFightRadius()
	return user_cfg.autoFightRadius;
end

function i3k_usercfg:SetAutoFightRadius(iValue)
	user_cfg.autoFightRadius = iValue
	self:Save()
end

function i3k_usercfg:GetTipNotShowDay(tipType)
	return user_cfg.todayNotShow[tipType] and user_cfg.todayNotShow[tipType] or 0
end

function i3k_usercfg:SetTipNotShowDay(tipType, value)
	user_cfg.todayNotShow[tipType] = value
	self:Save()
end

function i3k_usercfg:SetPowerSave(data)
	user_cfg.powerSave = data or {}
	self:Save()
end
function i3k_usercfg:GetPowerSave()
	return user_cfg.powerSave or {}
end

function i3k_usercfg:SetAutoPowerSave(bValue)
	user_cfg.autoPowerSave = bValue and 1 or 0
	self:Save()
end
function i3k_usercfg:GetAutoPowerSave()
	return user_cfg.autoPowerSave == 1
end

function i3k_usercfg:SetAutoSaleEquip(bValue)
	user_cfg.autoSaleEquip = bValue and 1 or 0
	self:Save()
end
function i3k_usercfg:GetAutoSaleEquip()
	return user_cfg.autoSaleEquip == 1
end

function i3k_usercfg:SetAutoSaleDrug(bValue)
	user_cfg.autoSaleDrug = bValue and 1 or 0
	self:Save()
end
function i3k_usercfg:GetAutoSaleDrug()
	return user_cfg.autoSaleDrug == 1
end

function i3k_usercfg:GetIsAgreement()
	return true
end

function i3k_usercfg:SetIsAgreement(iValue)
	user_cfg.isAgreement = iValue;
	self:Save()
end

function i3k_usercfg:GetIsMeridianRed()
	return user_cfg.isMeridianRed;
end

function i3k_usercfg:SetIsMeridianRed(Value)
	user_cfg.isMeridianRed = Value;
	self:Save()
end
function i3k_usercfg:GetSteedEquipRed()
	return user_cfg.steedEquipRed;
end
function i3k_usercfg:SetSteedEquipRed(Value)
	user_cfg.steedEquipRed = Value;
	self:Save()
end

function i3k_usercfg:GetRecruitManifesto()
	return user_cfg.manifesto
end

function i3k_usercfg:SetRecruitManifesto(Value)
	user_cfg.manifesto = Value
	self:Save()
end

function i3k_usercfg:GetIsShowShootMsg()
	return user_cfg.isShowShootMsg == 1
end

function i3k_usercfg:SetIsShowShootMsg(Value)
	user_cfg.isShowShootMsg = Value and 1 or 0
	self:Save()
end
function i3k_usercfg:GetIsShowHegemonyShootMsg()
	return user_cfg.isShowHegemonyShootMsg == 1
end
function i3k_usercfg:SetIsShowHegemonyShootMsg(Value)
	user_cfg.isShowHegemonyShootMsg = Value and 1 or 0
	self:Save()
end

function i3k_usercfg:GetIsShowBaguaGuide()
	return (user_cfg.isShowBaguaGuide == 1)
end

function i3k_usercfg:SetIsShowBaguaGuide(bValue)
	user_cfg.isShowBaguaGuide = bValue and 1 or 0
	self:Save()
end

function i3k_usercfg:GetIsShowAnswerTips()
	return (user_cfg.isShowAnswerTips == 1)
end

function i3k_usercfg:SetIsShowAnswerTips(bValue)
	user_cfg.isShowAnswerTips = bValue and 1 or 0
	self:Save()
end

function i3k_usercfg:GetIsShowAnswerResult()
	return (user_cfg.isShowAnswerResult == 1)
end

function i3k_usercfg:SetIsShowAnswerResult(bValue)
	user_cfg.isShowAnswerResult = bValue and 1 or 0
	self:Save()
end

function i3k_usercfg:GetIsHideAllArmorEffect()
	return (user_cfg.isHideAllArmorEffect == 1)
end

function i3k_usercfg:SetIsHideAllArmorEffect(bValue)
	user_cfg.isHideAllArmorEffect = bValue and 1 or 0
	self:Save()
	return bValue
end

function i3k_usercfg:GetIsHideCar()
	return (user_cfg.isHideCar == 1)
end

function i3k_usercfg:SetIsHideCar(bValue)
	user_cfg.isHideCar = bValue and 1 or 0
	self:Save()
	return bValue
end

function i3k_usercfg:SetEquipTempQianChuiProps(props)
	user_cfg.equipTempQianChuiProps = props
	self:Save()
end

function i3k_usercfg:GetEquipTempQianChuiProps()
	return user_cfg.equipTempQianChuiProps
end

function i3k_usercfg:SetEquipTempBaiLianProps(props)
	user_cfg.equipTempBaiLianProps = props
	self:Save()
end

function i3k_usercfg:GetEquipTempBaiLianProps()
	return user_cfg.equipTempBaiLianProps
end

function i3k_usercfg:SetDefaultTemperSelectEquip(partID)
	user_cfg.defaultTemperSelectEquip = partID
	self:Save()
end

function i3k_usercfg:GetDefaultTemperSelectEquip()
	return user_cfg.defaultTemperSelectEquip
end

function i3k_usercfg:SetDefaultBaiLianPartID(partID)
	user_cfg.defaultBaiLianPartID = partID
	self:Save()
end
function i3k_usercfg:GetDefaultBaiLianPartID()
	return user_cfg.defaultBaiLianPartID
end
function i3k_usercfg:setIsShowKillTips(value)
	user_cfg.isShowKillTips = value
	self:Save()
end

function i3k_usercfg:getIsShowKillTips()
	return user_cfg.isShowKillTips
end

function i3k_usercfg:SetDaibiTipsShowTimes(showTimes)
	user_cfg.daibiTipsShowTimes = showTimes
	self:Save()
end

function i3k_usercfg:GetDaibiTipsShowTimes()
	return user_cfg.daibiTipsShowTimes
end
	
function i3k_usercfg:SetCameraShake(bValue)
	user_cfg.cameraShake = bValue and 1 or 0
	self:Save()
end
function i3k_usercfg:GetCameraShake()
	return user_cfg.cameraShake == 1
end

function i3k_usercfg:GetFenJie(arg)
	return user_cfg[arg] == 1
end

function i3k_usercfg:SetFenJie(arg, bValue)
	user_cfg[arg] = bValue and 1 or 0
	self:Save()
end
function i3k_usercfg:SetSteedAutoRefine(info)
	user_cfg.steedAutoRefine = info
	self:Save()
end
function i3k_usercfg:GetSteedAutoRefine()
	return user_cfg.steedAutoRefine
end
function i3k_usercfg:SetSteedAutoRefinePowerSave(info)
	user_cfg.steedAutoRefineInitFlag = info
	self:Save()
end
function i3k_usercfg:GetSteedAutoRefinePowerSave()
	return user_cfg.steedAutoRefineInitFlag
end
function i3k_usercfg:AddActivityShowTimes(roleId, id)
	if user_cfg.activityShowTimes[roleId] == nil then
		user_cfg.activityShowTimes[roleId] = {}
	end
	if user_cfg.activityShowTimes[roleId][id] == nil then
		user_cfg.activityShowTimes[roleId][id] = 0
	end
	user_cfg.activityShowTimes[roleId][id] = user_cfg.activityShowTimes[roleId][id] + 1
	self:Save()
end
function i3k_usercfg:GetActivityShowTimes(roleId, id)
	if user_cfg.activityShowTimes[roleId] == nil or user_cfg.activityShowTimes[roleId][id] == nil then
		return 0
	end
	return user_cfg.activityShowTimes[roleId][id]
end
function i3k_usercfg:UpdateSpringRollShowGuide()
	user_cfg.springRollShowGuide = 0
	self:Save()
end
function i3k_usercfg:GetSpringRollShowGuide()
	return user_cfg.springRollShowGuide == 1
end
function i3k_usercfg:SetSpringRollQuiz(npcID, quizID)
	user_cfg.springRollQuiz[npcID] = quizID
	self:Save()
end

function i3k_usercfg:GetSpringRollQuizByID(npcID)
	return user_cfg.springRollQuiz[npcID]
end
function i3k_usercfg:SetCatchSpiritPreview(roleId)
	table.insert(user_cfg.catchSpiritPreview, roleId)
	self:Save()
end
function i3k_usercfg:GetCatchSpiritPreview()
	return user_cfg.catchSpiritPreview
end
function i3k_usercfg:SetCatchSpiritOpen(roleId)
	table.insert(user_cfg.catchSpiritOpen, roleId)
	self:Save()
end
function i3k_usercfg:GetCatchSpiritOpen()
	return user_cfg.catchSpiritOpen
end
function i3k_usercfg:SetSpecialActionPlay(classType)
	if classType then
		if not table.indexof(user_cfg.specialAction, classType) then
			table.insert(user_cfg.specialAction, classType)
		end
	else
		user_cfg.specialAction = {}
	end
	self:Save()
end
function i3k_usercfg:GetSpecialActionPlay()
	return user_cfg.specialAction
end
function i3k_usercfg:SetBiographyTaskProgress(roleId, career, progress)
	if not user_cfg.biographyTaskProgress[roleId] then
		user_cfg.biographyTaskProgress[roleId] = {}
	end
	user_cfg.biographyTaskProgress[roleId][career] = progress
	self:Save()
end
function i3k_usercfg:GetBiographyTaskProgress()
	return user_cfg.biographyTaskProgress
end
---------------------------------------------------------------
function i3k_usercfg:Load()
	local fn = i3k_game_get_exe_path() .. "user.cfg";
	local f = io.open(fn, "r");
	if f == nil then
		return false;
	end
	local t = f:read("*all");
	if t ~= nil then
		local fc = loadstring(t);
		if fc ~= nil then
			fc();
		end
	end
	f:close();
	return true;
end

function i3k_usercfg:Save()
	local fn = i3k_game_get_exe_path() .. "user.cfg";
	local f = io.open(fn, "w");
	if f == nil then
		return false;
	end
	f:write(string.format("user_cfg.username=%q\n", user_cfg.username));
	f:write(string.format("user_cfg.channelName=%q\n", user_cfg.channelName));
	for k, v in pairs(user_cfg.muteTable) do
		f:write(string.format("user_cfg.muteTable[%d]=%d\n", k, v))
	end
	f:write(string.format("user_cfg.usercontrol=%d\n", user_cfg.usercontrol))
	f:write(string.format("user_cfg.isSelect=%d\n", user_cfg.isSelect))
	f:write(string.format("user_cfg.mark=%d\n", user_cfg.mark))
	f:write(string.format("user_cfg.bgVolume=%d\n",user_cfg.bgVolume))
	f:write(string.format("user_cfg.effectVolume=%d\n",user_cfg.effectVolume))
	f:write(string.format("user_cfg.isTouchOperate=%d\n",user_cfg.isTouchOperate))
	f:write(string.format("user_cfg.activityTransCoolTime.cool = %d\n", user_cfg.activityTransCoolTime.cool))
	f:write(string.format("user_cfg.activityTransCoolTime.thatTime = %d\n", user_cfg.activityTransCoolTime.thatTime))
	f:write(string.format("user_cfg.cameraInter = %f\n", user_cfg.cameraInter))
--	f:write(string.format("user_cfg.isShowHeadInfo =%d\n", user_cfg.isShowHeadInfo))
	f:write(string.format("user_cfg.isShowMyselfHeadInfo =%d\n", user_cfg.isShowMyselfHeadInfo))
	f:write(string.format("user_cfg.isShowOthersHeadInfo =%d\n", user_cfg.isShowOthersHeadInfo))
	if user_cfg.filterTxLvl then
		f:write(string.format("user_cfg.filterTxLvl =%d\n",user_cfg.filterTxLvl))
	end
	f:write(string.format("user_cfg.autoAcceptMatchTeamRequest =%d\n",user_cfg.autoAcceptMatchTeamRequest))
	f:write(string.format("user_cfg.autoAcceptMatchTeamApply =%d\n",user_cfg.autoAcceptMatchTeamApply))
	f:write(string.format("user_cfg.lastSelectRole =%d\n",user_cfg.lastSelectRole))
	for k, v in ipairs(user_cfg.recentServerList) do
		f:write(string.format("user_cfg.recentServerList[%d]=%d\n", k, v))
	end
	f:write(string.format("user_cfg.recentServerIp=%q\n", user_cfg.recentServerIp));
	f:write(string.format("user_cfg.recentServerName=%q\n", user_cfg.recentServerName));
	local str = ""
	for k, v in ipairs(user_cfg.taskListOrder) do
		str = string.format(str.."%d,",v)
	end
	f:write(string.format("user_cfg.taskListOrder={%s}\n",str))
	local str1 = ""
	for k, v in ipairs(user_cfg.funcOpenData) do
		str1 = string.format(str1.."%d,",v)
	end
	f:write(string.format("user_cfg.funcOpenData={%s}\n",str1))

	f:write(string.format("user_cfg.isPrompt=%d\n",user_cfg.isPrompt))
	f:write(string.format("user_cfg.steedSkinPrompt=%d\n",user_cfg.steedSkinPrompt))
	f:write(string.format("user_cfg.isPetCanUsePool=%d\n",user_cfg.isPetCanUsePool));

	local str2 = ""
	for k, v in ipairs(user_cfg.banPushServices) do
		str2 = str2 .. string.format("%d,",v)
	end
	f:write(string.format("user_cfg.banPushServices={%s}\n",str2))
	for k, v in pairs(user_cfg.dungeonWaitTip) do
		f:write(string.format("user_cfg.dungeonWaitTip[%d]=%d\n", k, v))
	end
	f:write(string.format("user_cfg.matchTournament=%d\n", user_cfg.matchTournament))
	f:write(string.format("user_cfg.matchForceWar=%d\n", user_cfg.matchForceWar))
	f:write(string.format("user_cfg.matchFightTeam=%d\n", user_cfg.matchFightTeam))
	f:write(string.format("user_cfg.globalMatchTeam=%d\n", user_cfg.globalMatchTeam))
	f:write(string.format("user_cfg.lastSeclectFiveUnique=%d\n",user_cfg.lastSeclectFiveUnique))
	f:write(string.format("user_cfg.curSelectFiveUniqueLevel=%d\n",user_cfg.curSelectFiveUniqueLevel))
	f:write(string.format("user_cfg.filterPlayerNum =%d\n",user_cfg.filterPlayerNum))
	f:write(string.format("user_cfg.isSpanTips =%d\n",user_cfg.isSpanTips))
	f:write(string.format("user_cfg.isAutoSuperMode =%d\n",user_cfg.isAutoSuperMode))
	f:write(string.format("user_cfg.isAreanDefendTips =%d\n",user_cfg.isAreanDefendTips))
	f:write(string.format("user_cfg.redEnvelope =%d\n", user_cfg.redEnvelope))
	f:write(string.format("user_cfg.notShowDay =%d\n", user_cfg.notShowDay))
	f:write(string.format("user_cfg.fpsLimit =%d\n", user_cfg.fpsLimit))

	local str3 = ""
	for _, v in ipairs(user_cfg.todayNotShow) do
		str3 = str3 .. string.format("%d,",v)
	end
	f:write(string.format("user_cfg.todayNotShow={%s}\n",str3))

	local str1 = ""
	for k, v in ipairs(user_cfg.powerSave) do
		str1 = string.format(str1.."["..k.."]".." = %d,",v)
	end
	f:write(string.format("user_cfg.powerSave={%s}\n",str1))
	f:write(string.format("user_cfg.autoPowerSave=%d\n", user_cfg.autoPowerSave))
	f:write(string.format("user_cfg.autoSaleEquip=%d\n", user_cfg.autoSaleEquip))
	f:write(string.format("user_cfg.autoSaleDrug=%d\n", user_cfg.autoSaleDrug))
	f:write(string.format("user_cfg.autoFightRadius=%d\n", user_cfg.autoFightRadius))
	f:write(string.format("user_cfg.isAgreement=%d\n", user_cfg.isAgreement))
	f:write(string.format("user_cfg.isMeridianRed=%d\n", user_cfg.isMeridianRed))
	f:write(string.format("user_cfg.steedEquipRed=%d\n", user_cfg.steedEquipRed))
	f:write(string.format("user_cfg.manifesto=%q\n", user_cfg.manifesto))
	f:write(string.format("user_cfg.isShowShootMsg=%d\n", user_cfg.isShowShootMsg))
	f:write(string.format("user_cfg.isShowHegemonyShootMsg=%d\n", user_cfg.isShowHegemonyShootMsg))
	f:write(string.format("user_cfg.isShowBaguaGuide=%d\n", user_cfg.isShowBaguaGuide))
	f:write(string.format("user_cfg.isShowAnswerTips=%d\n", user_cfg.isShowAnswerTips))
	f:write(string.format("user_cfg.isShowAnswerResult=%d\n", user_cfg.isShowAnswerResult))
	f:write(string.format("user_cfg.isHideAllArmorEffect=%d\n", user_cfg.isHideAllArmorEffect))
	f:write(string.format("user_cfg.isHideCar=%d\n", user_cfg.isHideCar))

	if user_cfg.equipTempQianChuiProps then
		f:write("user_cfg.equipTempQianChuiProps={}\n")
		for i, v in ipairs(user_cfg.equipTempQianChuiProps) do
			f:write(string.format("user_cfg.equipTempQianChuiProps[%d]={id = %d, value = %d}\n", i, v.id, v.value))
		end
	end
	if user_cfg.equipTempBaiLianProps then
		f:write("user_cfg.equipTempBaiLianProps={}\n")
		for i, v in ipairs(user_cfg.equipTempBaiLianProps) do
			f:write(string.format("user_cfg.equipTempBaiLianProps[%d]={id = %d, value = %d}\n", i, v.id, v.value))
		end
	end

	f:write(string.format("user_cfg.defaultTemperSelectEquip=%d\n", user_cfg.defaultTemperSelectEquip)) 
	f:write(string.format("user_cfg.defaultBaiLianPartID=%d\n",user_cfg.defaultBaiLianPartID))
	f:write(string.format("user_cfg.isShowKillTips=%d\n", user_cfg.isShowKillTips))
	
	f:write(string.format("user_cfg.daibiTipsShowTimes=%d\n", user_cfg.daibiTipsShowTimes))
	f:write(string.format("user_cfg.cameraShake=%d\n", user_cfg.cameraShake))

	f:write(string.format("user_cfg.fenjie_hide_can_sell=%d\n", user_cfg.fenjie_hide_can_sell))
	f:write(string.format("user_cfg.fenjie_hide_high_power=%d\n", user_cfg.fenjie_hide_high_power))
	f:write(string.format("user_cfg.fenjie_show_purple=%d\n", user_cfg.fenjie_show_purple))
	f:write(string.format("user_cfg.fenjie_show_orange=%d\n", user_cfg.fenjie_show_orange))
	--user_cfg.steedAutoRefine = {[1] = {"101234567", "101234567", "101234567", "101234567", "101234567"},[2] = {"10123456", "101234567", "101234567", "101234567", "101234567"},}
	--每个坐骑有5个属性条 每个属性条有相关配置个属性 有多少条属性就代表多少个字符的字符串 0 代表未勾选345代表品质 每一个前面都带上1 防止00005的情况出现。
	local str4 = ""
	local index = 0
	for i, v in pairs(user_cfg.steedAutoRefine) do
		local e = ""
		for _, j in ipairs(v) do
			e = e .. j .. ","
		end		
		str4 = str4 .. string.format("[%d] = {%s}", i, e) .. ","
		index = index + 1
		if index % 3 == 0 then
			index = 0
			str4 = str4 .."\n"
		end
	end
	f:write(string.format("user_cfg.steedAutoRefine={%s}\n", str4))
	local str5 = ""	
	for _, v in ipairs(user_cfg.steedAutoRefineInitFlag) do
		str5 = str5 .. string.format("%d,", v)
	end
	f:write(string.format("user_cfg.steedAutoRefineInitFlag={%s}\n", str5))
	local str6 = ""
	for k, v in pairs(user_cfg.activityShowTimes) do
		local str7 = ""
		for k2, v2 in pairs(v) do
			str7 = str7 .. string.format("[%s] = %s, ", k2, v2)
		end
		str6 = str6 .. string.format("[%s] = {%s}, ", k, str7)
	end
	f:write(string.format("user_cfg.activityShowTimes = {%s}\n", str6))
	local catchSpirit = ""
	for _, v in ipairs(user_cfg.catchSpiritPreview) do
		catchSpirit = catchSpirit .. string.format("%d,", v)
	end
	f:write(string.format("user_cfg.catchSpiritPreview={%s}\n", catchSpirit))
	local catchSpiritOpen = ""
	for _, v in ipairs(user_cfg.catchSpiritOpen) do
		catchSpiritOpen = catchSpiritOpen .. string.format("%d,", v)
	end
	f:write(string.format("user_cfg.catchSpiritOpen={%s}\n", catchSpiritOpen))
	local specialAction = ""
	for _, v in ipairs(user_cfg.specialAction) do
		specialAction = specialAction .. string.format("%d,", v)
	end
	f:write(string.format("user_cfg.specialAction={%s}\n", specialAction))
	local biographyTaskProgress = ""
	for k, v in pairs(user_cfg.biographyTaskProgress) do
		local str7 = ""
		for k2, v2 in pairs(v) do
			str7 = str7 .. string.format("[%s] = %s, ", k2, v2)
		end
		biographyTaskProgress = biographyTaskProgress .. string.format("[%s] = {%s}, ", k, str7)
	end
	f:write(string.format("user_cfg.biographyTaskProgress = {%s}\n", biographyTaskProgress))
	f:write(string.format("user_cfg.springRollShowGuide = %d\n", user_cfg.springRollShowGuide))
	f:write("user_cfg.springRollQuiz = {}\n")
	local customSkillOrder = ""
	for k, v in pairs(user_cfg.customSkillOrder) do
		customSkillOrder = customSkillOrder .. string.format("[%d] = %d,", k, v)
	end
	f:write(string.format("user_cfg.customSkillOrder={%s}\n", customSkillOrder))
	f:close();
	return true;
end
