require("scripts/game/zhanjiang/zhanjiang_data")
require("scripts/game/zhanjiang/zhanjiang_view")
require("scripts/game/zhanjiang/zhanjiang_zhanjiang")
require("scripts/game/zhanjiang/zhanjiang_ronghun")

--------------------------------------------------------------
--战将
--------------------------------------------------------------
-- 英雄状态
HERO_STATE = {
		REST = 0,          	--休息状态
		SHOW = 1,         	--放出状态
}

-- 英雄类型
HERO_TYPE = {
		ZC = 1,          	--战宠
		JL = 2,         	--精灵
}


ZhanjiangCtrl = ZhanjiangCtrl or BaseClass(BaseController)
ZhanjiangCtrl.CanWearEquipNumMax = 4			--战将装备可佩戴最大数
function ZhanjiangCtrl:__init()
	if ZhanjiangCtrl.Instance then
		ErrorLog("[ZhanjiangCtrl] Attemp to create a singleton twice !")
	end
	ZhanjiangCtrl.Instance = self

	self.zc_data = require("scripts/game/zhanjiang/zhangchong/data").New(HERO_TYPE.ZC)	--战宠数据
	self.jl_data = require("scripts/game/zhanjiang/zhangchong/data").New(HERO_TYPE.JL)	--精灵数据
	self.data = {[HERO_TYPE.ZC] = self.zc_data, [HERO_TYPE.JL] = self.jl_data}

	self.view = ZhanjiangView.New(ViewDef.ZhanjiangView)
	-- ViewManager.Instance:RegisterView(self.view, ViewDef.Zhanjiang)
	require("scripts/game/zhanjiang/zhangchong/view").New(ViewDef.ZhanjiangView.ZhangChongView, self.zc_data)
	require("scripts/game/zhanjiang/zhangchong_compose_view").New(ViewDef.ZhanjiangView.ZhangChongComposeView)
	-- require("scripts/game/zhanjiang/zhangchong/view").New(ViewDef.ZhanjiangView.JingLingView, self.jl_data)
	
	self:RegisterAllProtocols()
	-- RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetHeroRemindNum, self), RemindName.HeroUpgrade, true)

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, function (vo)
		if vo.key == OBJ_ATTR.ACTOR_COIN then
			RemindManager.Instance:DoRemindDelayTime(RemindName.ZhanChongUp)
		end
	end)
	RemindManager.Instance:RegisterCheckRemind(function ()
		return self.zc_data:GetIsRemind() and 1 or 0
	end, RemindName.ZhanChongUp)

	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, function ( ... )
		RemindManager.Instance:DoRemindDelayTime(RemindName.ZhanChongUp)
	end)
	
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetHeroRemindNum, self), RemindName.ZhanjiangCanEquip)
    EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, function (event)
		event.CheckAllItemDataByFunc(function (vo)
			if ItemData.GetIsHeroEquip(vo.data.item_id) then
				RemindManager.Instance:DoRemindDelayTime(RemindName.ZhanjiangCanEquip)
				self.data[HERO_TYPE.ZC]:DispatchEvent(self.data[HERO_TYPE.ZC].EQ_CHANGE)
			end
		end)	
	end)
end

function ZhanjiangCtrl:__delete()
	ZhanjiangCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.zc_data:DeleteMe()
	self.zc_data = nil

	self.jl_data:DeleteMe()
	self.jl_data = nil

	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
	end
end

function ZhanjiangCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCHeroAttrChange, "OnHeroAttrChange")
	self:RegisterProtocol(SCHeroSkill, "OnHeroSkill")
	-- self:RegisterProtocol(SCInformPlayerActivateHero, "OnInformPlayerActivateHero")
	self:RegisterProtocol(SCIssueActivateHeroMsg, "OnIssueActivateHeroMsg")
	self:RegisterProtocol(SCIssueOwnedEquipList, "OnIssueOwnedEquipList")
	-- self:RegisterProtocol(SCHeroNextLevAttr, "OnHeroNextLevAttr")
	-- self:RegisterProtocol(SCIssueHeroNextLiantiAttr, "OnIssueHeroNextLiantiAttr")
	self:RegisterProtocol(SCHeroPutOnEquip, "OnHeroPutOnEquip")
	self:RegisterProtocol(SCHeroPutOffEquip, "OnHeroPutOffEquip")
	-- self:RegisterProtocol(SCIssueHeroData, "OnIssueHeroData")
	self:RegisterProtocol(SCUpgardeHeroPostback, "OnUpgardeHeroPostback")
	-- self:RegisterProtocol(SCIssueUpgradeLiantiResult, "OnIssueUpgradeLiantiResult")
	self:RegisterProtocol(SCIssueHeroState, "OnIssueHeroState")
	-- self:RegisterProtocol(SCHeroHPChanged, "OnHeroHPChanged")

	-- GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function ZhanjiangCtrl:GetHeroRemindNum(remind_name)
	if remind_name == RemindName.HeroUpgrade then
		return self.data[HERO_TYPE.ZC]:GetHeroRemindNum() + self.data[HERO_TYPE.JL]:GetHeroRemindNum()
	elseif remind_name == RemindName.ZhanjiangCanEquip then
		return self.zc_data:GetCanEquip()
	end
end

-- function ZhanjiangCtrl:GetExerciseRemindNum(remind_name)
-- 	if remind_name == RemindName.HeroCanExercise then
-- 		return self.data:GetExerciseRemindNum()
-- 	end
-- end

function ZhanjiangCtrl:RoleDataChangeCallback(key, value)
	-- if key == OBJ_ATTR.ACTOR_MERCENA_LEVEL or 
	-- 	key == OBJ_ATTR.ACTOR_MERCENA_EXP then
	-- 	self.data:SetRonghunDataList()
	-- 	self.view:Flush(TabIndex.zhanjiang_ronghun)
	-- 	self.view:Flush(TabIndex.zhanjiang_zhanjiang, "zhanjiang")
	-- end
end

function ZhanjiangCtrl:OnRecvMainRoleInfo()
	-- self:GetHeroesList()
	-- self.data:SetRonghunDataList()
end

--=====================================下发Begin=========================================
-- 英雄属性改变(44 3)
function ZhanjiangCtrl:OnHeroAttrChange(protocol)
	self.data[protocol.hero_type]:SetHeroInfo(protocol)

	if protocol.hero_type == HERO_TYPE.ZC then
		RemindManager.Instance:DoRemindDelayTime(REMIND_ACT_LIST[ACT_ID.ZCJJ])
	end
end

function ZhanjiangCtrl:OnHeroSkill(protocol)
	self.data[protocol.hero_type]:SetHeroSkillData(protocol)
	-- self.view:Flush(self.view:GetShowIndex(), "zhanjiang")
end

-- 下发已有的装备的列表(44 15)
function ZhanjiangCtrl:OnIssueOwnedEquipList(protocol)
	self.zc_data:SetOwnedEquipList(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.ZhanjiangCanEquip)
end

-- -- 下发下一级英雄属性(44 27)
-- function ZhanjiangCtrl:OnHeroNextLevAttr(protocol)
-- 	self.data:SetHeroNextLevAttr(protocol)
-- 	self.view:Flush(self.view:GetShowIndex(), "hero_next_lv")
-- end

-- -- 下发下一级英雄练体属性(44 29)
-- function ZhanjiangCtrl:OnIssueHeroNextLiantiAttr(protocol)
-- 	self.data:SetHeroNextLiantiAttr(protocol)
-- 	self.view:Flush(self.view:GetShowIndex(), "lianti")
-- end

-- --通知玩家到达四十级, 可以激活英雄
-- function ZhanjiangCtrl:OnInformPlayerActivateHero(protocol)

-- end

-- 下发激活英雄信息(44 23)
function ZhanjiangCtrl:OnIssueActivateHeroMsg(protocol)
	self.data[protocol.hero_type]:DispatchEvent(self.zc_data.OPEAT_CALLBACK, {opeat_type = "activ_succes"})
	self.jl_data:DispatchEvent(self.jl_data.OPEAT_CALLBACK, {opeat_type = "activ_succes"})
end

-- 英雄穿上装备(44 13)
function ZhanjiangCtrl:OnHeroPutOnEquip(protocol)
	self.zc_data:PutOnEquipData(protocol)
end

-- 英雄脱下装备(44 14)
function ZhanjiangCtrl:OnHeroPutOffEquip(protocol)
	self.zc_data:PutOffEquipData(protocol)
end

-- -- 下发英雄数据(44 24)
-- function ZhanjiangCtrl:OnIssueHeroData(protocol)
-- 	-- self.data:SetHeroData(protocol)
-- 	-- self.view:Flush(self.view:GetShowIndex(), "money")
-- end

-- 升级英雄等级回发(44 26)
function ZhanjiangCtrl:OnUpgardeHeroPostback(protocol)
	if protocol.is_succeed == 1 then
		self.data[HERO_TYPE.ZC]:DispatchEvent(self.data[HERO_TYPE.ZC].OPEAT_CALLBACK, {opeat_type = "level_succes"})
		self.data[HERO_TYPE.JL]:DispatchEvent(self.data[HERO_TYPE.JL].OPEAT_CALLBACK, {opeat_type = "level_succes"})
	end
end

-- -- 下发提升练体结果(44 28)
-- function ZhanjiangCtrl:OnIssueUpgradeLiantiResult(protocol)
-- 	self.data:SetUpLiantiLvResult(protocol)
-- 	if protocol.is_succeed == 0 then
-- 		self.view:Flush(self.view:GetShowIndex(), "stop_exercise")
-- 	else
-- 		ZhanjiangCtrl.GetHeroExpReq()
-- 		self.view:Flush(self.view:GetShowIndex(), "lianti_succ")
-- 	end
-- end

-- 下发英雄状态(44 25)
function ZhanjiangCtrl:OnIssueHeroState(protocol)
	self.data[protocol.hero_type]:SetHeroState(protocol)
	-- local prev_state = self.data:GetHeroPreState()
	-- if protocol.hero_state == HERO_STATE.SHOW and prev_state == HERO_STATE.MERGE then
	-- 	self.view:Flush(self.view:GetShowIndex(), "dispossess_succ")
	-- elseif protocol.hero_state == HERO_STATE.MERGE then
	-- 	self.view:Flush(self.view:GetShowIndex(), "merge_succ")
	-- end 

	-- self.view:Flush(self.view:GetShowIndex(), "state_change")
end

-- -- 下发英雄改变了血量
-- function ZhanjiangCtrl:OnHeroHPChanged(protocol)
-- 	self.data:SetHPChanged(protocol)
-- end
--=====================================下发End=========================================

--=====================================请求Begin=========================================
-- 请求获取英雄的列表(返回 44 3, 44 27, 44 29, 44 15)
function ZhanjiangCtrl.GetHeroesList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetHeroesListReq)
	protocol:EncodeAndSend()
end

-- 请求激活英雄(返回 44 23)
function ZhanjiangCtrl.HeroActivateReq(hero_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroActivateReq)
	protocol.hero_type = hero_type
	protocol:EncodeAndSend()
end

-- 请求英雄穿上装备
function ZhanjiangCtrl.HeroPutOnEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroPutOnEquipReq)
	protocol.hero_id = ZhanjiangCtrl.Instance.zc_data:GetOtherInfoList().hero_id
	protocol.series = series
	protocol.equip_pos = 0
	protocol:EncodeAndSend()
end

-- 请求英雄脱下装备
function ZhanjiangCtrl.HeroPutOffEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroPutOffEquipReq)
	protocol.hero_id = ZhanjiangCtrl.Instance.zc_data:GetOtherInfoList().hero_id
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 请求升级英雄等级(返回 44 24)
function ZhanjiangCtrl.UpgradeHeroGradeReq(hero_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSHeroUpgradeReq)
	protocol.hero_id = hero_id
	protocol:EncodeAndSend()
end

-- 请求获取英雄经验(返回 44 24)
function ZhanjiangCtrl.GetHeroExpReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetHeroExpReq)
	protocol:EncodeAndSend()
end

-- 请求提升练体(返回 44 28)
function ZhanjiangCtrl.UpgradeExerEnergyReq(slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeExerciseEnergyReq)
	protocol.slot = slot
	protocol:EncodeAndSend()
end

function ZhanjiangCtrl:CanCallHero(type)
	return self.data[type]:IsActivatedSucc() and self.data[type]:GetHeroState() == HERO_STATE.REST
end

-- 请求设置英雄的状态，0:休息，1放出战斗状态 2合体状态
function ZhanjiangCtrl:SetHeroFightReq(type)
	self.data[type]:SetHeroStateReq(1)
end

function ZhanjiangCtrl.SetHeroStateReq(hero_id, hero_state)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetHeroStateReq)
	protocol.hero_id = hero_id
	protocol.hero_state = hero_state
	protocol:EncodeAndSend()
end

function ZhanjiangCtrl:GetEquipData(type)
	return self.zc_data:GetZhaongChongDataByType(type)
end

function ZhanjiangCtrl:GetData(type)
	return self.data[type]
end

function ZhanjiangCtrl.GetPetEquipIsOpen()
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local pet_data = ZhanjiangCtrl.Instance:GetData(HERO_TYPE.ZC)
	local hero_lv = pet_data:Getlevel() or 0

	local cfg = HeroConfig or {}
	local eq_open_lv = cfg.EqOpenLv or 9999
	local eq_open_cir = cfg.EqOpenCir or 999
	local eq_open_hero_lv = cfg.EqOpenHeroLv or 999

	local is_open = level >= eq_open_lv and circle >= eq_open_cir and hero_lv >= eq_open_hero_lv

	return is_open
end

--=====================================请求End=========================================