require("game/tianshenhuti/tianshenhuti_view")
require("game/tianshenhuti/tianshenhuti_data")
require("game/tianshenhuti/tianshenhuti_equip_tips")
require("game/tianshenhuti/tianshenhuti_box_show_view")
require("game/tianshenhuti/tianshenhuti_eqselect_view")
require("game/tianshenhuti/tianshenhuti_conversion_selectslot_view")
require("game/tianshenhuti/tianshenhuti_onekey_compose_view")
require("game/tianshenhuti/tianshenhuti_attr_view")
require("game/tianshenhuti/tianshenhuti_boss_rank_view")
require("game/tianshenhuti/tianshenhuti_bosscome_warning")
require("game/tianshenhuti/tianshenhuti_skill_tips_view")
local GET_BOSS_INFO_TIMER = nil
TianshenhutiCtrl = TianshenhutiCtrl or  BaseClass(BaseController)
local LAST_ROLL_TYPE = nil
function TianshenhutiCtrl:__init()
	if TianshenhutiCtrl.Instance ~= nil then
		ErrorLog("[TianshenhutiCtrl] attempt to create singleton twice!")
		return
	end
	TianshenhutiCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = TianshenhutiData.New()
	self.view = TianshenhutiView.New(ViewName.TianshenhutiView)
	self.tianshenhuti_equip_tips_view = TianshenhutiEquipTips.New(ViewName.TianshenhutiEquipTips)
	self.tianshenhuti_box_show_view = TipTianshenhutiBoxShowView.New(ViewName.TipTianshenhutiBoxShowView)
	self.select_view = TianshenhutiEqSelectView.New(ViewName.TianshenhutiEqSelectView)
	self.selectslot_view = TianshenhutiSelectSlotView.New(ViewName.TianshenhutiSelectSlotView)
	self.onekey_compose_view = TianshenhutiOnekeyComposeView.New(ViewName.TianshenhutiOnekeyComposeView)
	self.tianshenhuti_skilltips_view = TianShenHuTiSkillView.New(ViewName.TianShenHuTiSkillView)
	self.attr_view = TianshenhutiAttrView.New(ViewName.TianshenhutiAttrView)
	self.boss_come = TianshenhutiBossComeWarning.New()
end

function TianshenhutiCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.tianshenhuti_equip_tips_view ~= nil then
		self.tianshenhuti_equip_tips_view:DeleteMe()
		self.tianshenhuti_equip_tips_view = nil
	end
	if self.tianshenhuti_box_show_view ~= nil then
		self.tianshenhuti_box_show_view:DeleteMe()
		self.tianshenhuti_box_show_view = nil
	end
	if self.select_view ~= nil then
		self.select_view:DeleteMe()
		self.select_view = nil
	end
	if self.boss_come ~= nil then
		self.boss_come:DeleteMe()
		self.boss_come = nil
	end
	if self.selectslot_view ~= nil then
		self.selectslot_view:DeleteMe()
		self.selectslot_view = nil
	end
	if self.onekey_compose_view ~= nil then
		self.onekey_compose_view:DeleteMe()
		self.onekey_compose_view = nil
	end
	if self.attr_view ~= nil then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if GET_BOSS_INFO_TIMER then
		GlobalTimerQuest:CancelQuest(GET_BOSS_INFO_TIMER)
		GET_BOSS_INFO_TIMER = nil
	end
end

-- 协议注册
function TianshenhutiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTianshenhutiALlInfo, "OnTianshenhutiALlInfo")
	self:RegisterProtocol(SCTianshenhutiRollResult, "OnTianshenhutiRollResult")
	self:RegisterProtocol(SCTianshenhutiReqResult, "OnTianshenhutiReqResult")
	self:RegisterProtocol(SCTianshenhutiCombineOneKeyResult, "OnTianshenhutiCombineOneKeyResult")
	self:RegisterProtocol(SCTianshenhutiScoreChange, "OnTianshenhutiScoreChange")
	self:RegisterProtocol(SCWeekendBossInfo, "OnSCWeekendBossInfo")
	self:RegisterProtocol(SCWeekendBossPersonHurtRank, "OnWeekendBossPersonHurtRank")
	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
end

function TianshenhutiCtrl:MainuiOpenCreate()
	self:BindGlobalEvent(ObjectEventType.OBJ_CREATE, BindTool.Bind(self.OnObjCreate, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DEAD, BindTool.Bind(self.OnObjDead, self))
	self:BindGlobalEvent(ObjectEventType.OBJ_DELETE,
		BindTool.Bind(self.OnObjDelete, self))
	for k,v in pairs(Scene.Instance:GetMonsterList()) do
		self:OnObjCreate(v)
	end
end

--装备展示描述
function TianshenhutiCtrl:ShowEquipTips(data, from_view, close_callback)
	self.tianshenhuti_equip_tips_view:SetData(data, from_view, close_callback)
end

--周末装备装备信息
function TianshenhutiCtrl:OnTianshenhutiALlInfo(protocol)
	self.data:SetTianshenhutiALlInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Tianshenhuti)
	RemindManager.Instance:Fire(RemindName.TianshenhutiBox)
end

function TianshenhutiCtrl:OnSCWeekendBossInfo(protocol)
 	if protocol.boss_type == 0 then
 		local has_big_boss = self.data:HasWeekendBigBoss()
		self.data:SetWeekendBigBossInfo(protocol)
		if not has_big_boss and self.data:HasWeekendBigBoss() and OpenFunData.Instance:CheckIsHide("tianshenhutiview") then
			self.boss_come:Open()
		end
	else
		if OpenFunData.Instance:CheckIsHide("tianshenhutiview") then
			local boss_info = nil
			local old_refresh_time = self.data:GetBossRefreshTime()
			for k,v in pairs(protocol.boss_info) do
				boss_info = self.data:GetOneWeekendBossInfo(v.boss_id)
				if old_refresh_time ~= 0 and old_refresh_time ~= protocol.next_refresh_time and v.boss_status == 1 then
					TipsCtrl.Instance:ShowBossFocusTip(v.boss_id, BOSS_ENTER_TYPE.TIANSHENHUTI_BOSS, BindTool.Bind(self.RandMoveToBoss, self))
					break
				end
			end
		end
		self.data:SetWeekendBossInfo(protocol)
	end

	self.view:Flush()
end

--随机传送到一个boss旁边
function TianshenhutiCtrl:RandMoveToBoss()
	local boss_info = self.data:GetOneWeekendAliveBossInfo()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	MoveCache.end_type = MoveEndType.Auto
	GuajiCtrl.Instance:MoveToPos(boss_info.scene_id, boss_info.pos_x, boss_info.pos_y, 10, 10)
end

function TianshenhutiCtrl:OnWeekendBossPersonHurtRank(protocol)
	self.data:SetBossPersonalHurtInfo(protocol)
	GlobalEventSystem:Fire(MainUIEventType.OTHER_INFO_CHANGE, {change_type = 2, view = TianshenhutiBossRankView})
end

--周末装备抽奖结果
function TianshenhutiCtrl:OnTianshenhutiRollResult(protocol)
	self.tianshenhuti_box_show_view:SetData(protocol.reward_list, BindTool.Bind(TianshenhutiCtrl.SendTianshenhutiRoll, LAST_ROLL_TYPE))
end

--周末装备相关请求结果
function TianshenhutiCtrl:OnTianshenhutiReqResult(protocol)
	self.tianshenhuti_box_show_view:SetData(protocol.new_equip)
	self.data:ClearComposeSelectList()
end

--周末装备一键合成结果
function TianshenhutiCtrl:OnTianshenhutiCombineOneKeyResult(protocol)
	if #protocol.new_equip < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.OneKeyComposeTips)
		return
	end
	self.tianshenhuti_box_show_view:SetData(protocol.new_equip)
end

--周末装备积分变动
function TianshenhutiCtrl:OnTianshenhutiScoreChange(protocol)
	local old_score = self.data:GetRollScore()
	if protocol.roll_score > old_score then
		TipsCtrl.Instance:ShowFloatingLabel(
			string.format(Language.SysRemind.AddScore, protocol.roll_score - old_score))
	end
	self.data:SetTianshenhutiScore(protocol.roll_score)
	self.view:Flush()
end

--装备
function TianshenhutiCtrl.SendTianshenhutiPutOn(index)
	TianshenhutiCtrl.SendTianshenhutiReq(TIANSHENHUTI_REQ_TYPE.PUT_ON, index)
end

--脱下
function TianshenhutiCtrl.SendTianshenhutiTakeOff(eq_index)
	TianshenhutiCtrl.SendTianshenhutiReq(TIANSHENHUTI_REQ_TYPE.TAKE_OFF, eq_index)
end

--转化
function TianshenhutiCtrl.SendTianshenhutiTransform(index1, index2, slot)
	TianshenhutiCtrl.SendTianshenhutiReq(TIANSHENHUTI_REQ_TYPE.TRANSFORM, index1, index2, slot)
end

--合成
function TianshenhutiCtrl.SendTianshenhutiCombine(index1, index2, index3)
	TianshenhutiCtrl.SendTianshenhutiReq(TIANSHENHUTI_REQ_TYPE.COMBINE, index1, index2, index3)
end

--抽奖
function TianshenhutiCtrl.SendTianshenhutiRoll(roll_type)
	LAST_ROLL_TYPE = roll_type
	TianshenhutiCtrl.SendTianshenhutiReq(TIANSHENHUTI_REQ_TYPE.ROLL, roll_type)
end

--一键合成
function TianshenhutiCtrl.SendTianshenhutiQuickCombine(grade)
	TianshenhutiCtrl.SendTianshenhutiReq(TIANSHENHUTI_REQ_TYPE.QUICK_COMBINE, grade)
end

function TianshenhutiCtrl.SendTianshenhutiReq(req_type, param_1, param_2, param_3, param_4)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSTianshenhutiReq)
	protocol_send.req_type = req_type
	protocol_send.param_1 = param_1 or 0
	protocol_send.param_2 = param_2 or 0
	protocol_send.param_3 = param_3 or 0
	protocol_send.param_4 = param_4 or 0
	protocol_send:EncodeAndSend()
end

function TianshenhutiCtrl.SendWeekendBossPersonHurtRank()
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSWeekendBossPersonHurtRank)
	protocol_send:EncodeAndSend()
end

function TianshenhutiCtrl:ShowSelectView(index, data_list, from_view)
	self.select_view:SetSelectIndex(index)
	self.select_view:SetHadSelectData(data_list)
	self.select_view:SetFromView(from_view)
	self.select_view:Open()
end

function TianshenhutiCtrl:OpenSelectSlot(callback)
	self.selectslot_view:SetCallBack(callback)
	self.selectslot_view:Open()
end

function TianshenhutiCtrl:OpenOneKeyCompose()
	self.onekey_compose_view:Open()
end

function TianshenhutiCtrl:OpenAttrView()
	self.attr_view:Open()
end

local tsht_boss = nil
function TianshenhutiCtrl:OnObjCreate(obj)
	if obj:IsMonster() and self.data:IsTshtBoss(0, obj:GetMonsterId()) then
		tsht_boss = obj:GetMonsterId()
		GlobalEventSystem:Fire(MainUIEventType.OTHER_INFO_CHANGE, {change_type = 1, view = TianshenhutiBossRankView, title = Language.Tianshenhuti.Rank})
		if GET_BOSS_INFO_TIMER == nil then
			GET_BOSS_INFO_TIMER = GlobalTimerQuest:AddRunQuest(function ()
				TianshenhutiCtrl.SendWeekendBossPersonHurtRank()
			end, 2)
		end
	end
end

function TianshenhutiCtrl:OnObjDead(obj)
	if obj:IsMonster() and tsht_boss == obj:GetMonsterId() then
		GlobalEventSystem:Fire(MainUIEventType.OTHER_INFO_CHANGE, {change_type = 0, view = TianshenhutiBossRankView})
		tsht_boss = nil
		if GET_BOSS_INFO_TIMER then
			GlobalTimerQuest:CancelQuest(GET_BOSS_INFO_TIMER)
			GET_BOSS_INFO_TIMER = nil
		end
	end
end

function TianshenhutiCtrl:OnObjDelete(obj)
	if obj:IsMonster() and tsht_boss == obj:GetMonsterId() then
		GlobalEventSystem:Fire(MainUIEventType.OTHER_INFO_CHANGE, {change_type = 0, view = TianshenhutiBossRankView})
		tsht_boss = nil
		if GET_BOSS_INFO_TIMER then
			GlobalTimerQuest:CancelQuest(GET_BOSS_INFO_TIMER)
			GET_BOSS_INFO_TIMER = nil
		end
	end
end