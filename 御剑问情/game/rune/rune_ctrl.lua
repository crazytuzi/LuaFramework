require("game/rune/rune_view")
require("game/rune/rune_data")
require("game/rune/rune_bag_view")
require("game/rune/rune_item_cell")
require("game/rune/rune_item_tips")
require("game/rune/rune_preview_view")
require("game/rune/rune_awaken_view")
require("game/rune/rune_awaken_tips_view")
require("game/rune/special_rune_item_tips")

RuneCtrl = RuneCtrl or  BaseClass(BaseController)

function RuneCtrl:__init()
	if RuneCtrl.Instance ~= nil then
		print_error("[RuneCtrl] attempt to create singleton twice!")
		return
	end
	RuneCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = RuneView.New(ViewName.Rune)
	self.bag_view = RuneBagView.New(ViewName.RuneBag)
	self.tips_view = RuneItemTips.New(ViewName.RuneItemTips)
	self.preview_view = RunePreviewView.New(ViewName.RunePreview)
	self.special_rune_item_tips = SpecialRuneItemTips.New(ViewName.SpecialRuneItemTips)
	self.data = RuneData.New()
	self.old_rune_jinhua = -1
	--创建觉醒面板
	self.awaken_view = RuneAwakenView.New(ViewName.RuneAwakenView)
	self.awaken_tips_view = RuneAwakenTipsView.New(ViewName.RuneAwakenTipsView)
end

function RuneCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.bag_view ~= nil then
		self.bag_view:DeleteMe()
		self.bag_view = nil
	end

	if self.tips_view ~= nil then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	if self.preview_view ~= nil then
		self.preview_view:DeleteMe()
		self.preview_view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	--注销觉醒面板
	if self.awaken_view ~= nil then
		self.awaken_view:DeleteMe()
		self.awaken_view = nil
	end

	if self.awaken_tips_view ~= nil then
		self.awaken_tips_view:DeleteMe()
		self.awaken_tips_view = nil
	end

	if self.special_rune_item_tips ~= nil then
		self.special_rune_item_tips:DeleteMe()
		self.special_rune_item_tips = nil
	end

	RuneCtrl.Instance = nil
end

function RuneCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSRuneSystemReq)
	self:RegisterProtocol(CSRuneSystemDisposeOneKey)
	self:RegisterProtocol(SCRuneSystemBagInfo, "OnRuneSystemBagInfo")				--获取符文列表数据
	self:RegisterProtocol(SCRuneSystemRuneGridInfo, "OnRuneSystemRuneGridInfo")		--符文槽信息
	self:RegisterProtocol(SCRuneSystemOtherInfo, "OnRuneSystemOtherInfo")			--符文其他信息
	self:RegisterProtocol(SCRuneSystemComposeInfo, "OnRuneComposeSuc")				--成功合成道具
	self:RegisterProtocol(SCRuneSystemRuneGridAwakenInfo, "OnRuneGridAwakenInfo")	--开始觉醒
	self:RegisterProtocol(SCRuneSystemZhulingNotifyInfo, "OnRuneSystemZhulingNotifyInfo")	--符文注灵抽奖返回
	self:RegisterProtocol(SCRuneSystemZhulingAllInfo, "OnRuneSystemZhulingAllInfo")			--符文注灵信息
	self:RegisterProtocol(SCRuneSystemXunBaoResult, "OnRuneSystemXunBaoResult")				--符文寻宝结果
	self:RegisterProtocol(SCRuneSystemBestRuneInfo, "OnRuneSystemBestRuneInfo")				--终极符文信息
end

function RuneCtrl:RuneSystemReq(req_type, param1, param2, param3, param4)
	-- print_error(req_type, param1, param2, param3, param4)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneSystemReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol:EncodeAndSend()
end

function RuneCtrl:SendOneKeyAnalyze(list_count, index_list)
	-- print_error(list_count, index_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRuneSystemDisposeOneKey)
	send_protocol.list_count = list_count or 0
	send_protocol.index_list = index_list or {}
	send_protocol:EncodeAndSend()
end

function RuneCtrl:OnRuneSystemBagInfo(protocol)
	-- print_error("OnRuneSystemBagInfo")
	if protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_INVAILD then
		self.data:ChangeBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("analyze")
		end
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_ALL_BAG_INFO then			--背包
		self.data:SetBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("analyze")
		end
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_RUNE_XUNBAO_INFO then		--寻宝
		self.data:ChangeBagList(protocol.bag_list)
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_OPEN_BOX_INFO then			--宝箱
		self.data:SetBaoXiangList(protocol.bag_list)
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RUNE_BAOXIANG_MODE)
		self.data:ChangeBagList(protocol.bag_list)
	elseif protocol.info_type == RUNE_SYSTEM_INFO_TYPE.RUNE_SYSTEM_INFO_TYPE_CONVERT_INFO then			--兑换
		self.data:ChangeBagList(protocol.bag_list)
		if self.view:IsOpen() then
			self.view:Flush("exchange")
		end
	end
	RemindManager.Instance:Fire(RemindName.RuneZhuLing)
	RemindManager.Instance:Fire(RemindName.RuneInlay)
	RemindManager.Instance:Fire(RemindName.RuneAnalyze)
	RemindManager.Instance:Fire(RemindName.RuneCompose)
end

function RuneCtrl:OnRuneSystemRuneGridInfo(protocol)
	-- print_error("OnRuneSystemRuneGridInfo", protocol.rune_grid_awaken)
	self.data:SetSlotList(protocol.rune_grid)
	self.data:SetAwakenList(protocol.rune_grid_awaken)
	if self.view:IsOpen() then
		self.view:Flush("inlay")
		self.view:Flush("zhuling")
	end
	if self.awaken_view:IsOpen() then
		self.awaken_view:Flush("rightview")
	end
	RemindManager.Instance:Fire(RemindName.RuneZhuLing)
	RemindManager.Instance:Fire(RemindName.RuneInlay)
	RemindManager.Instance:Fire(RemindName.RuneCompose)
	RemindManager.Instance:Fire(RemindName.RuneAwake)
end

function RuneCtrl:OnRuneSystemOtherInfo(protocol)
	-- print_error("OnRuneSystemOtherInfo", protocol)
	if -1 == self.old_rune_jinhua then
		self.old_rune_jinhua = protocol.rune_jinghua
	else
		local add_jinhua = protocol.rune_jinghua - self.old_rune_jinhua
		self.old_rune_jinhua = protocol.rune_jinghua

		if add_jinhua > 0 then
			TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.SysRemind.AddRuneJinghua, add_jinhua))
		end
	end

	self.data:SetOtherInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("inlay")
		self.view:Flush("compose")
		self.view:Flush("zhuling")
	end
	if self.awaken_view:IsOpen() then
		self.awaken_view:Flush("diamondcost")
	end
	RemindManager.Instance:Fire(RemindName.RuneZhuLing)
	RemindManager.Instance:Fire(RemindName.RuneInlay)
	RemindManager.Instance:Fire(RemindName.RuneCompose)
	RemindManager.Instance:Fire(RemindName.RuneTreasure)
end

function RuneCtrl:OnRuneComposeSuc()
	if self.view:IsOpen() then
		self.view:Flush("compose_effect")
	end
end

function RuneCtrl:FlushTowerView()
	if self.view:IsOpen() then
		self.view:Flush("tower")
	end
end

function RuneCtrl:OnRuneGridAwakenInfo(protocol)
	self.data:SetAwakenSeq(protocol.awaken_seq)
	self.data:SetIsNeedRecalc(protocol.is_need_recalc)
	if self.awaken_view:IsOpen() then
		self.awaken_view:Flush("needle")
	end
end

function RuneCtrl:OnRuneSystemZhulingNotifyInfo(protocol)
	self.view:Flush("zhuling_bless", {protocol.index, protocol.zhuling_slot_bless})
	self.data:SetRuneZhulingSlotBless(protocol.zhuling_slot_bless)
	RemindManager.Instance:Fire(RemindName.RuneZhuLing)
end

function RuneCtrl:OnRuneSystemZhulingAllInfo(protocol)
	self.data:SetRuneZhulingInfo(protocol)
	self.view:Flush("zhuling")
	RemindManager.Instance:Fire(RemindName.RuneZhuLing)
end

function RuneCtrl:OnRuneSystemXunBaoResult(protocol)
	self.data:SetTreasureList(protocol)
	if #protocol.item_list >= 10 then
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RUNE_MODE_10)
	else
		TipsCtrl.Instance:ShowTreasureView(CHEST_SHOP_MODE.CHEST_RUNE_MODE_1)
	end
	if self.view:IsOpen() then
		self.view:Flush("treasure")
	end
end

function RuneCtrl:SetSlotIndex(slot)				--1开始
	self.bag_view:SetSlotIndex(slot)
end

function RuneCtrl:SetTipsData(data)
	self.tips_view:SetData(data)
end

function RuneCtrl:SetTipsCallBack(callback)
	self.tips_view:SetCloseCallBack(callback)
end

function RuneCtrl:SetAwakenTipsCallBack(callback)
	self.awaken_tips_view:SetCloseCallBack(callback)
end

function RuneCtrl:SetAwakenTipsOpenCallBack(callback)
	self.awaken_tips_view:SetOpenCallBack(callback)
end

function RuneCtrl:OnRuneSystemBestRuneInfo(protocol)
	self.data:SetSpecialRuneInfo(protocol)
	self.view:Flush("inlay")
	if self.special_rune_item_tips:IsOpen() then
		self.special_rune_item_tips:Flush()
	end
	RemindManager.Instance:Fire(RemindName.SpecialRune)
end