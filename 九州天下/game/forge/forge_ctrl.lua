require("game/forge/forge_view")
require("game/forge/forge_data")
require("game/forge/forge_spirit_handbook_view")

ForgeCtrl = ForgeCtrl or BaseClass(BaseController)

function ForgeCtrl:__init()
	if nil ~= ForgeCtrl.Instance then
		print_error("[ForgeCtrl] attempt to create singleton twice!")
		return
	end
	ForgeCtrl.Instance = self
	self.forge_view = ForgeView.New(ViewName.Forge)
	self.forge_spirit_handbook_view = ForgeSpiritHandbook.New(ViewName.SoulHandBook)
	self.forge_data = ForgeData.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.OPERATE_RESULT, BindTool.Bind1(self.OnOperateResult, self), result)
	-- GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainOpenComplete, self))

	self.score_change_callback = BindTool.Bind1(self.ScoreDataChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)

	RemindManager.Instance:Register(RemindName.ForgeStrengthen, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.ForgeStrengthen))
	RemindManager.Instance:Register(RemindName.ForgeGem, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.ForgeGem))
	RemindManager.Instance:Register(RemindName.ForgeCast, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.ForgeCast))
	RemindManager.Instance:Register(RemindName.ForgeUpStar, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.ForgeUpStar))

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
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

	if nil ~= self.spirit_handbook_view then
		self.spirit_handbook_view:DeleteMe()
		self.spirit_handbook_view = nil
	end

	if self.score_change_callback then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
		self.score_change_callback = nil
	end

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	if self.forge_spirit_handbook_view ~= nil then
		self.forge_spirit_handbook_view:DeleteMe()
		self.forge_spirit_handbook_view = nil
	end
	RemindManager.Instance:UnRegister(RemindName.ForgeStrengthen)
	RemindManager.Instance:UnRegister(RemindName.ForgeGem)
	RemindManager.Instance:UnRegister(RemindName.ForgeCast)
	RemindManager.Instance:UnRegister(RemindName.ForgeUpStar)

	ForgeCtrl.Instance = nil
end

-- 注册协议
function ForgeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSEquipCompound)
	self:RegisterProtocol(SCEquipCompoundRet, "OnEquipCompoundRet")
	self:RegisterProtocol(SCStoneInfo, "OnGemInfo")
	self:RegisterProtocol(SCNoticeTotalStrengLevel, "OnNoticeTotalStrengLevel")
	self:RegisterProtocol(SCDuanzaoSuitInfo, "OnDuanzaoSuitInfo")
    self:RegisterProtocol(SCLieMingBagInfo, "GetSpiritSoulBagInfoReq")
	self:RegisterProtocol(SCLieMingInfo, "GetSpiritSlotSoulInfoReq")
	self:RegisterProtocol(SCJingLingInfo, "GetJingLingInfoReq")
	self:RegisterProtocol(SCLieMingSingleEquipInfo, "SCLieMingSingleEquipInfoReq")
end

function ForgeCtrl:OpenViewToIndex(index)
	if not OpenFunData.Instance:CheckIsHide("forge_strengthen") then
		SysMsgCtrl.Instance:ErrorRemind(Language.Forge.FunOpenTip)
		return
	end
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

-- 装备合成请求
function ForgeCtrl:SendEquipCompound(equip_item_id, equi_index, index, compound, index_list_count, knapsack_equipment_index_list)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSEquipCompound)
	protocol_send.equip_item_id = equip_item_id or 0
	protocol_send.equi_index = equi_index or 0
	protocol_send.index = index or 0
	protocol_send.compound = compound or 0
	protocol_send.index_list_count = index_list_count or 0
	for i = 1, index_list_count do
		protocol_send.knapsack_equipment_index_list[i] = knapsack_equipment_index_list[i] or 0
	end
	if index_list_count < 5 then
		for i = index_list_count + 1, 5 do
			protocol_send.knapsack_equipment_index_list[i] = 0
		end
	end
	protocol_send:EncodeAndSend()
end

-- 合成结果
function ForgeCtrl:OnEquipCompoundRet(protocol)
	self.forge_data:SetIsComposeSucc(protocol.is_succ)
	RemindManager.Instance:Fire(RemindName.Forge)
	if self.forge_view:IsOpen() then
		self.forge_view:Flush("after_compose")
	end
end

--申请强化
function ForgeCtrl:SendQianghua(index, is_auto_buy, use_lucky_item)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipStrengthen)
	protocol.equip_index = index
	protocol.is_auto_buy = is_auto_buy
	protocol.use_lucky_item = use_lucky_item
	protocol.is_puton = 1
	protocol:EncodeAndSend()
end

--强化后回调函数
function ForgeCtrl:OnOperateResult(operate, result, param1, param2)
	if operate == MODULE_OPERATE_TYPE.OP_EQUIP_STRENGTHEN then
		-- print_log("强化后回调函数",result)
		-- self.forge_view:OnAfterStrengthen(result)
		-- if 1 == result then
		-- 	GlobalEventSystem:Fire(OtherEventType.EQUIP_DATA_CHANGE)
		-- 	RemindManager.Instance:Fire(RemindName.Forge)
		-- 	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN) then
		-- 		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_EQUIP_STRENGHTEN,
		-- 			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
		-- 	end
		-- 	CompetitionActivityCtrl.Instance:SendGetBipinInfo()
		-- end
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
	RemindManager.Instance:Fire(RemindName.ForgeGem)
	RemindManager.Instance:Fire(RemindName.ForgeStrengthen)
	RemindManager.Instance:Fire(RemindName.ForgeCast)
	RemindManager.Instance:Fire(RemindName.ForgeUpStar)
	self.forge_view:OnGemChange()
	self.forge_view:OnInlayCan()
	if ActivityData.Instance:GetActivityIsOpen(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(RA_OPEN_SERVER_ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_UPGRADE_GEMSTONE,
			RA_OPEN_SERVER_OPERA_TYPE.RA_OPEN_SERVER_OPERA_TYPE_REQ_INFO)
	end
	CompetitionActivityCtrl.Instance:SendGetBipinInfo()
end

--镶嵌宝石
--装备位置，宝石格子位置， 宝石在背包中的位置, is_inlay 0.摘除  1.镶嵌
function ForgeCtrl:SendStoneInlay(equip_index, stone_slot, stone_index, is_inlay)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStoneInlay)
	protocol.equip_part = equip_index
	protocol.stone_slot = stone_slot
	protocol.stone_index = stone_index
	protocol.is_inlay = is_inlay

	protocol:EncodeAndSend()
end

--请求宝石信息
function ForgeCtrl:SendStoneInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(SCReqStoneInfo)
	protocol:EncodeAndSend()
end

--宝石升级
--装备位置，宝石格子位置
function ForgeCtrl:SendStoneUpgrade(stone_slot, uplevel_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStoneUpgrade)
	local equip_index = self.forge_view.gem_view:GetSelectData().index
	protocol.equip_part = equip_index
	protocol.stone_slot = stone_slot
	protocol.uplevel_type = uplevel_type
	protocol.reserve = 0
	protocol:EncodeAndSend()
end

--申请神铸
function ForgeCtrl:SendCast(equip_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipShenZhu)
	protocol.equip_index = equip_index or 0
	protocol.is_puton = 1
	protocol:EncodeAndSend()
end

function ForgeCtrl:FlushRedPoint()
	-- self.forge_view:FlushRedPoint()
end

function ForgeCtrl:MainOpenComplete()
	-- self.forge_data:SetAllRedPoint()
	RemindManager.Instance:Fire(RemindName.Forge)
end

function ForgeCtrl:ScoreDataChange()
	-- self.forge_data:SetAllRedPoint()
	RemindManager.Instance:Fire(RemindName.Forge)
	if self.forge_view:IsOpen() then
		self:FlushRedPoint()
	end
end

function ForgeCtrl:OnDuanzaoSuitInfo(protocol)
end

--套装操作
function ForgeCtrl:SendSuitStrengthReq(operate_type, equip_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDuanzaoSuitReq)
	protocol.operate_type = operate_type
	protocol.equip_index = equip_index
	protocol:EncodeAndSend()
end

function ForgeCtrl:FlushView()
	self.forge_view:Flush()
end

function ForgeCtrl:GetGemChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.ForgeStrengthen then
		for k, v in pairs(ForgeData.EquipIndex) do
			local open_flag = OpenFunData.Instance:CheckIsHide("forge_strengthen")
			if self.forge_data:GetStrengthRemindByIndex(v) and open_flag then
				flag = 1
			end
		end
	elseif remind_type == RemindName.ForgeGem then
		for k, v in pairs(ForgeData.EquipIndex) do
			local open_flag = OpenFunData.Instance:CheckIsHide("forge_baoshi")
			if self.forge_data:GetGemRemindByIndex(v) and open_flag then
				flag = 1
			end
		end
	elseif remind_type == RemindName.ForgeCast then
		for k, v in pairs(ForgeData.EquipIndex) do
			local open_flag = OpenFunData.Instance:CheckIsHide("forge_cast")
			if self.forge_data:GetCastRemindByIndex(v) and open_flag then
				flag = 1
			end
		end
	elseif remind_type == RemindName.ForgeUpStar then
		for k, v in pairs(ForgeData.EquipIndex) do
			local open_flag = OpenFunData.Instance:CheckIsHide("forge_up_star")
			if self.forge_data:GetUpStarRemindByIndex(v) and open_flag then
				flag = 1
			end
		end
	end

	return flag
end
------------------------------------
-- 精灵命魂槽信息
function ForgeCtrl:GetSpiritSlotSoulInfoReq(protocol)
	self.forge_data:SetSpiritSlotSoulInfo(protocol)
	self.forge_view:Flush("flush_soul_view")
	RemindManager.Instance:Fire(RemindName.SpiritSoulGet)
end

-- 精灵命魂背包信息
function ForgeCtrl:GetSpiritSoulBagInfoReq(protocol)
	if self.forge_data:GetSpiritSoulBagInfo().hunshou_exp then
		local delta_hunshou_exp = protocol.hunshou_exp - self.forge_data:GetSpiritSoulBagInfo().hunshou_exp
		if delta_hunshou_exp > 0 then
			TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddSoulExp, delta_hunshou_exp))
		end
	end
	self.forge_data:SetSpiritSoulBagInfo(protocol)
	self.forge_view:Flush("flush_soul_view")
	RemindManager.Instance:Fire(RemindName.SpiritSoulGet)
end

-- 精灵命魂操作
function ForgeCtrl:SendSpiritSoulOperaReq(opera_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSLieMingHunshouOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

function ForgeCtrl:GetJingLingInfoReq(protocol)
	self.forge_data:SetSpiritInfo(protocol)
	
	local main_role = Scene.Instance:GetMainRole()
	if main_role then
		main_role:SetAttr("used_sprite_id", protocol.use_jingling_id)
		main_role:SetAttr("sprite_name", protocol.jingling_name)
	end
end

function ForgeCtrl:SCLieMingSingleEquipInfoReq(protocol)
	self.forge_data:SetLieMingSingleInfo(protocol)
	self.forge_view:Flush("flush_soul_view")
	RemindManager.Instance:Fire(RemindName.SpiritSoulGet)
end

function ForgeCtrl:IsShowSoulBg(value)
	if self.forge_view then
		self.forge_view:IsSoulBg(value)
	end
end

function ForgeCtrl:ItemDataChangeCallback()
	self.forge_view:Flush()
	self.forge_view:DoRemind()
end