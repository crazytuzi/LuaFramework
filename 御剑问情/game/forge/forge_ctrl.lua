require("game/forge/forge_base")
require("game/forge/forge_view")
require("game/forge/forge_data")

ForgeCtrl = ForgeCtrl or BaseClass(BaseController)

function ForgeCtrl:__init()
	if nil ~= ForgeCtrl.Instance then
		print_error("[ForgeCtrl] attempt to create singleton twice!")
		return
	end
	ForgeCtrl.Instance = self
	self.forge_view = ForgeView.New(ViewName.Forge)
	self.forge_data = ForgeData.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.OPERATE_RESULT, BindTool.Bind1(self.OnOperateResult, self), result)
	-- GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainOpenComplete, self))

	self.score_change_callback = BindTool.Bind1(self.ScoreDataChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)
end

function ForgeCtrl:__delete()
	if nil ~= self.forge_data then
		self.forge_data:DeleteMe()
		self.forge_data = nil
	end

	if nil ~= self.forge_view then
		self.forge_view:DeleteMe()
		self.forge_view = nil
	end

	if nil ~= self.gem_data then
		self.gem_data:DeleteMe()
		self.gem_data = nil
	end

	if self.score_change_callback then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
		self.score_change_callback = nil
	end

	ForgeCtrl.Instance = nil
end

-- 注册协议
function ForgeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSEquipCompound)
	-- self:RegisterProtocol(SCEquipCompoundRet, "OnEquipCompoundRet")
	self:RegisterProtocol(SCStoneInfo, "OnGemInfo")
	self:RegisterProtocol(SCNoticeTotalStrengLevel, "OnNoticeTotalStrengLevel")
	self:RegisterProtocol(SCDuanzaoSuitInfo, "OnDuanzaoSuitInfo")
end


function ForgeCtrl:OpenViewToIndex(index)
	if not OpenFunData.Instance:CheckIsHide("forge_strengthen") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.FunOpenTip)
		return
	end
	self.forge_view:SetTargetEquipIndex(index)
	self.forge_view:Open()
end

--角色武器颜色变化
function ForgeCtrl:OnNoticeTotalStrengLevel(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then
		return
	end
	obj:SetAttr("wuqi_color", protocol.wuqi_color)
	if obj:IsMainRole() then
		GlobalEventSystem:Fire(OtherEventType.EQUIP_DATA_CHANGE)
	end
end

function ForgeCtrl:FlyShenZhuEffect()
	if self.forge_view:IsOpen() then
		self.forge_view:Flush("shen_fly_effect")
	end
end

-- 红装进阶请求
function ForgeCtrl:SendEquipJinjie(equi_index)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSEquipCompound)
	protocol_send.equi_index = equi_index or 0
	protocol_send:EncodeAndSend()
end

-- -- 合成结果
-- function ForgeCtrl:OnEquipCompoundRet(protocol)
-- 	self.forge_data:SetIsComposeSucc(protocol.is_succ)
-- 	RemindManager.Instance:Fire(RemindName.Forge)
-- 	if self.forge_view:IsOpen() then
-- 		self.forge_view:Flush("after_compose")
-- 	end
-- end

--申请强化
function ForgeCtrl:SendQianghua(is_auto_buy, use_lucky_item)
	local data = self.forge_view:GetSelectData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipStrengthen)
	protocol.equip_index = data.index
	protocol.is_auto_buy = is_auto_buy
	protocol.use_lucky_item = use_lucky_item
	protocol.is_puton = 1
	protocol:EncodeAndSend()
	-- print("申请强化",'equip_index', protocol.equip_index, 'is_auto_buy', protocol.is_auto_buy, 'use_lucky_item', protocol.use_lucky_item)
end

--强化后回调函数
function ForgeCtrl:OnOperateResult(operate, result, param1, param2)
	if operate == MODULE_OPERATE_TYPE.OP_EQUIP_STRENGTHEN then
		-- print_log("强化后回调函数",result)
		self.forge_view:OnAfterStrengthen(result)
		if 1 == result then
			GlobalEventSystem:Fire(OtherEventType.EQUIP_DATA_CHANGE)
			RemindManager.Instance:Fire(RemindName.ForgeStrengthen)
			if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN) then
				KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN,
					RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
			end
			CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		end
	end
end

--申请装备升星
function ForgeCtrl:SendUpStarReq(equip_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipUpStar)
	protocol.equip_index = equip_index
	protocol:EncodeAndSend()
end

-- 宝石信息,镶嵌/摘除后也会调用
function ForgeCtrl:OnGemInfo(protocol)
	ForgeData.Instance:SetGemInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ForgeBaoshi)
	self.forge_view:OnGemChange()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	CompetitionActivityCtrl.Instance:SendGetBipinInfo()
end

--镶嵌宝石
--装备位置，宝石格子位置， 宝石在背包中的位置, is_inlay 0.摘除  1.镶嵌
function ForgeCtrl:SendStoneInlay(stone_slot, stone_index, is_inlay)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStoneInlay)
	local equip_index = self.forge_view:GetSelectData().index
	protocol.equip_part = equip_index
	protocol.stone_slot = stone_slot
	protocol.stone_index = stone_index
	protocol.is_inlay = is_inlay

	protocol:EncodeAndSend()
	local str = ToColorStr("发送镶嵌宝石".." "..protocol.equip_part.." "..protocol.stone_slot.." "
		..protocol.stone_index.." "..protocol.is_inlay, TEXT_COLOR.PURPLE)
	-- print(str)
end

--请求宝石信息
function ForgeCtrl:SendStoneInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(SCReqStoneInfo)
	protocol:EncodeAndSend()
end

--请求宝石信息
function ForgeCtrl:SendEquipUpEternityReq(equip_index, is_auto_buy)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipUpEternity)
	protocol.equip_index = equip_index or 0
	protocol.is_auto_buy = is_auto_buy or 0
	protocol:EncodeAndSend()
end

--宝石升级
--装备位置，宝石格子位置
function ForgeCtrl:SendStoneUpgrade(stone_slot, uplevel_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStoneUpgrade)
	local equip_index = self.forge_view:GetSelectData().index
	protocol.equip_part = equip_index
	protocol.stone_slot = stone_slot
	protocol.uplevel_type = uplevel_type
	protocol.reserve = 0
	protocol:EncodeAndSend()
end

--申请神铸
function ForgeCtrl:SendCast()
	local data = self.forge_view:GetSelectData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipShenZhu)
	protocol.equip_index = data.index
	protocol.is_puton = 1
	protocol:EncodeAndSend()
end

function ForgeCtrl:FlushRedPoint()
	-- self.forge_view:FlushRedPoint()
end

function ForgeCtrl:MainOpenComplete()
	-- self.forge_data:SetAllRedPoint()
	-- RemindManager.Instance:Fire(RemindName.Forge)
end

function ForgeCtrl:ScoreDataChange()
	-- self.forge_data:SetAllRedPoint()
	-- RemindManager.Instance:Fire(RemindName.Forge)
	-- if self.forge_view:IsOpen() then
	-- 	self:FlushRedPoint()
	-- end
end

--套装信息
function ForgeCtrl:OnDuanzaoSuitInfo(protocol)
	self.forge_data:SetForgeSuitInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ForgeSuit)
	if self.forge_view:IsOpen() then
		self.forge_view:OnSuitStrengthenCallBack()
	end
end

--套装操作
function ForgeCtrl:SendSuitStrengthReq(operate_type, equip_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDuanzaoSuitReq)
	protocol.operate_type = operate_type
	protocol.equip_index = equip_index
	protocol:EncodeAndSend()
end

function ForgeCtrl:SendUseFaZhenReq(eternity_level)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipUseEternityLevel)
	protocol.eternity_level = eternity_level or 0
	protocol:EncodeAndSend()
end

function ForgeCtrl:FlushView()
	self.forge_view:Flush()
end

function ForgeCtrl:PlaySuccedEffet()
	self.forge_view:PlaySuccedEffet()
end
--刷新升星红点
function ForgeCtrl:FlushUpstarTabRemind()
	RemindManager.Instance:Fire(RemindName.ForgeUpStar)
end

--合成彩装
function ForgeCtrl:SendColorEquipmentComposeReq(target_equipment_id, stuff_knapsack_index_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSColorEquipmentComposeReq)
	protocol.target_equipment_id = target_equipment_id or 0
	protocol.stuff_knapsack_index_list = stuff_knapsack_index_list or {}
	protocol:EncodeAndSend()
end