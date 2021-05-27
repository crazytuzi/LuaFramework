require("scripts/game/equip/equip_data")
require("scripts/game/equip/god_equip_data")

require("scripts/game/equip/view/chuanshi_equip_view")
require("scripts/game/equip/view/rexue_equip_view")

--------------------------------------------------------------
--装备相关
--------------------------------------------------------------
EquipCtrl = EquipCtrl or BaseClass(BaseController)
function EquipCtrl:__init()
	if EquipCtrl.Instance then
		ErrorLog("[EquipCtrl] Attemp to create a singleton twice !")
	end
	EquipCtrl.Instance = self

	self.equip_data = EquipData.New()
	self.god_equip_data = GodEquipData.New()

	self.chuanshi_equip_view = ChuanShiEquipView.New(ViewDef.ChuanShiEquip)
	self.rexue_equip_view = RexueEquipView.New(ViewDef.ReXueShiEquip)

	self:RegisterAllProtocols()

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))

	self.special_data = nil 
	self.tanchuang_num = 0
	self.wear_num = 0
	self.tanchuang_num_1 = 0
end

function EquipCtrl:__delete()
	EquipCtrl.Instance = nil

	self.equip_data:DeleteMe()
	self.equip_data = nil

	self.god_equip_data:DeleteMe()
	self.god_equip_data = nil

	self.chuanshi_equip_view:DeleteMe()
	self.chuanshi_equip_view = nil

	self.rexue_equip_view:DeleteMe()
	self.rexue_equip_view = nil

	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest) -- 取消计时器任务
		self.timer_quest = nil
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
end

function EquipCtrl:OnRecvMainRoleInfo()
	EquipCtrl.SendGetOwnEquipInfo()
	--EquipCtrl.SendRexueEquipZhulingDataReq()
end

function EquipCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCEquipList, "OnEquipList")
	self:RegisterProtocol(SCOneEquip, "OnOneEquip")
	self:RegisterProtocol(SCDelOneEquip, "OnDelOneEquip")
	self:RegisterProtocol(SCTakeOffOneEquip, "OnTakeOffOneEquip")

	self:RegisterProtocol(SCChanShiInfo, "OnChanShiInfo")
	self:RegisterProtocol(SCChuanShiUpResult, "OnChuanShiUpResult")

	self:RegisterProtocol(SCRexueEquipZhulingData, "OnRexueEquipZhulingData")
	self:RegisterProtocol(SCRexueEquipZhulingResult, "OnRexueEquipZhulingResult")

	RemindManager.Instance:RegisterCheckRemind(function ()
		local best_equip_list = EquipData.Instance:GetBestEquipList()
		for equip_slot, v in pairs(best_equip_list) do
			if v.best_equip_data and v.now_equip_data ~= v.best_equip_data then
				return 1
			end
		end
		return 0
	end, RemindName.BestEquip)

	RemindManager.Instance:RegisterCheckRemind(function ()
		if ReXueGodEquipData.Instance:GetIsCanWear() then
			return 1
		end
		return 0
	end, RemindName.BestRexueEquip)

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

-- 下发玩家装备数据
function EquipCtrl:OnEquipList(protocol)
	EquipData.Instance:SetDataList(protocol.equip_list)
	self:AutoReplaceEquip()
	for k, v in pairs(protocol.equip_list) do
		if v.item_id == 2093 or  v.item_id == 2094 or v.item_id == 2095 then
			self.special_data = v
			break
		end
	end
	if self.special_data  and self.tanchuang_num == 0 then
		self.tanchuang_num = 1
		self:OnDelayTimeOpen()
		GlobalEventSystem:Fire(TIYAN_SHEN_BIn_EVENT.TIYAN_SKILL_TiME,  self.special_data)
	end

	--self.equip_data:SetSpecailData(self.special_data)
	RemindManager.Instance:DoRemindDelayTime(RemindName.BestEquip)
	RemindManager.Instance:DoRemindDelayTime(RemindName.BestRexueEquip)
end

local equip_audio_res = {
	[1] = 61,
	[14] = 61,
	[28] = 61,
	[121] = 61,

	[2] = 62,
	[12] = 62,
	[29] = 62,
	[120] = 62,

	[3] = 64,
	[4] = 64,
	[6] = 64,
	[7] = 64,
	[8] = 64,
	[9] = 64,
	[30] = 64,
	[31] = 64,
	[32] = 64,
	[33] = 64,
	[34] = 64,
	[35] = 64,
}
-- 下发装备一件物品
function EquipCtrl:OnOneEquip(protocol)
	self.equip_data:PutOnEquip(protocol.equip)

	if equip_audio_res[protocol.equip.type] then
		AudioManager.Instance:PlayEffect(ResPath.GetAudioEffectResPath(equip_audio_res[protocol.equip.type]), AudioInterval.Common)
	end
	--PrintTable(protocol.equip)
	-- self:AutoReplaceEquip()
	if protocol.equip.item_id == 2093 or  protocol.equip.item_id == 2094 or  protocol.equip.item_id == 2095 then --穿戴热血装备
		self.special_data = protocol.equip
		self.wear_num  = self.wear_num + 1
	end
	if self.special_data and self.tanchuang_num == 0 then
		self.tanchuang_num = self.tanchuang_num + 1
		self:OnDelayTimeOpen()
	end
	if self.wear_num >= 2  and self.special_data and self.tanchuang_num_1 == 0 then
		ViewManager.Instance:OpenViewByDef(ViewDef.TaskEquipTiYanGuide)
		ViewManager.Instance:FlushViewByDef(ViewDef.TaskEquipTiYanGuide, 0, "change_btn1", {index = 1})
		GlobalEventSystem:Fire(TIYAN_SHEN_BIn_EVENT.TIYAN_SKILL_TiME,  protocol.equip)
		self.tanchuang_num_1 = self.tanchuang_num_1 + 1
	end

	RemindManager.Instance:DoRemindDelayTime(RemindName.BestEquip)
	RemindManager.Instance:DoRemindDelayTime(RemindName.BestRexueEquip)
end

function EquipCtrl:OnDelayTimeOpen( ... )
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest) -- 取消计时器任务
		self.timer_quest = nil
	end
	
	self.timer_quest = GlobalTimerQuest:AddRunQuest(function ( ... )
			local time = self.special_data.use_time  - TimeCtrl.Instance:GetServerTime()
			if time <= 0 then
				if self.timer_quest then
					GlobalTimerQuest:CancelQuest(self.timer_quest) -- 取消计时器任务
					self.timer_quest = nil
				end
				ViewManager.Instance:OpenViewByDef(ViewDef.TaskEquipTiYanGuide)
				ViewManager.Instance:FlushViewByDef(ViewDef.TaskEquipTiYanGuide, 0, "change_btn", {index = 1})
			end
	end, 1)
end



-- 下发删除一件物品
function EquipCtrl:OnDelOneEquip(protocol)
	self.equip_data:DelOneEquip(protocol.series)
end

-- 脱下一件装备
function EquipCtrl:OnTakeOffOneEquip(protocol)
	self.equip_data:TakeOffOneEquip(protocol.series)
	RemindManager.Instance:DoRemindDelayTime(RemindName.BestEquip)
	RemindManager.Instance:DoRemindDelayTime(RemindName.BestRexueEquip)
end

------------------------------------------------------------------------

-- 获取自身的装备
function EquipCtrl.SendGetOwnEquipInfo()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetOwnEquipInfo)
	protocol:EncodeAndSend()
end

-- 通过物品序列号装备一件物品
function EquipCtrl.SendFitOutEquip(series, seat, tran_stone)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFitOutEquip)
	protocol.series = series
	protocol.seat = seat or 0
	protocol.tran_stone = tran_stone or 0
	protocol:EncodeAndSend()
end

-- 根据物品序列号脱下一件装备
function EquipCtrl.SendTakeOffEquip(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTakeOffEquip)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 显示/隐藏圣器外观
function EquipCtrl.SendShenqiShowState(show_wuqi, show_cloth)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetShowFashionReq)
	protocol.show_wuqi = show_wuqi
	protocol.show_cloth = show_cloth
	protocol:EncodeAndSend()
end

-- 显示/隐藏圣器外观
function EquipCtrl.SendSetShowPeerlessReq(show_wuqi, show_cloth)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSetShowPeerlessReq)
	protocol.show_wuqi = show_wuqi
	protocol.show_cloth = show_cloth
	protocol:EncodeAndSend()
end

function EquipCtrl:FitOutEquip(item_data, hand_pos)
	EquipCtrl.SendFitOutEquip(item_data.series, hand_pos)
end

-- 神装操作
function EquipCtrl.SendGodEquipReq(equip_slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGodEquipReq)
	protocol.equip_slot = equip_slot
	protocol:EncodeAndSend()
end

-- 80级之前，如果背包有比自身战力高的装备。自动帮玩家替换
function EquipCtrl:AutoReplaceEquip()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	if(level < 80) then
		for equip_slot, v in pairs(EquipData.Instance:GetBestEquipList()) do
			if v.best_equip_data and v.now_equip_data ~= v.best_equip_data then
				EquipCtrl.SendFitOutEquip(v.best_equip_data.series, EquipData.GetEquipHandPos(equip_slot))
			end
		end
	end
end

----------------------------------------------------
-- 传世 begin
----------------------------------------------------
--申请传世装备等级数据
function EquipCtrl.SendChuanShiInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSChuanShiInfoReq)
	protocol:EncodeAndSend()
end

-- 传世装备操作(升级与进阶/激活)
function EquipCtrl.SendChuanShiOptReq(opt_type, slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSChuanShiOptReq)
	protocol.opt_type = opt_type
	protocol.slot = slot
	protocol:EncodeAndSend()
end

function EquipCtrl:OnChanShiInfo(protocol)
	self.equip_data:SetChuanShiLevelList(protocol.equip_list)
end

function EquipCtrl:OnChuanShiUpResult(protocol)
	self.equip_data:SetChuanShiLevel(protocol.slot, protocol.level)
end
----------------------------------------------------
-- 传世 end
----------------------------------------------------

----------------------------------------------------
-- 热血装备 begin
----------------------------------------------------
--申请激活热血装备
function EquipCtrl.SendActRexueEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSActRexueEquipReq)
	protocol.series = series
	protocol:EncodeAndSend()
end

-- 申请热血装备注灵数据
function EquipCtrl.SendRexueEquipZhulingDataReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSRexueEquipZhulingDataReq)
	protocol:EncodeAndSend()
end

-- 注灵热血装备
function EquipCtrl.SendRexueEquipZhulingOptReq(slot, equip_list)
	slot = EquipData.GetRexueCfgSlotIndex(slot)

	local protocol = ProtocolPool.Instance:GetProtocol(CSRexueEquipZhulingOptReq)
	protocol.slot = slot
	protocol.equip_list = equip_list
	protocol:EncodeAndSend()
end

-- 附魔热血装备
function EquipCtrl.SendRexueEquipFumoOptReq(slot)
	slot = EquipData.GetRexueCfgSlotIndex(slot)

	local protocol = ProtocolPool.Instance:GetProtocol(CSRexueEquipFumoOptReq)
	protocol.slot = slot
	protocol:EncodeAndSend()
end

-- 下发热血装备注灵数据
function EquipCtrl:OnRexueEquipZhulingData(protocol)
	for slot, v in pairs(protocol.data) do
		--self.equip_data:SetRexueZhuling(slot, v.level, v.val)
	end
end

-- 下发注灵热血成功结果
function EquipCtrl:OnRexueEquipZhulingResult(protocol)
	--self.equip_data:SetRexueZhuling(protocol.slot, protocol.zhuling_level, protocol.zhuling_val)
end


function EquipCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		RemindManager.Instance:DoRemindDelayTime(RemindName.BestRexueEquip)
	end
end 

function EquipCtrl:ItemDataListChangeCallback( ... )
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
			RemindManager.Instance:DoRemindDelayTime(RemindName.BestRexueEquip)
			if self.delay_timer then
				GlobalTimerQuest:CancelQuest(self.delay_timer)
				self.delay_timer = nil
			end
	end, 0.5)
end
----------------------------------------------------
-- 热血装备 end
----------------------------------------------------
