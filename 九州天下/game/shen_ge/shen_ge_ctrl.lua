require("game/shen_ge/shen_ge_data")
require("game/shen_ge/shen_ge_view")
require("game/shen_ge/shen_ge_shen_ge_view")
require("game/shen_ge/shen_ge_bless_view")
require("game/shen_ge/shen_ge_group_view")
require("game/shen_ge/shen_ge_inlay_view")
require("game/shen_ge/shen_ge_compose_view")
require("game/shen_ge/shen_ge_select_view")
require("game/shen_ge/shen_ge_operate_view")
require("game/shen_ge/shen_ge_attr_view")
require("game/shen_ge/shen_ge_upgrade_view")
require("game/shen_ge/shen_ge_decompose_view")
require("game/shen_ge/shen_ge_decompose_detail_view")
require("game/shen_ge/shen_ge_bless_prop_tip")
require("game/shen_ge/shen_ge_zhangkong_view")
require("game/shen_ge/shen_ge_preview_view")
require("game/shen_ge/shen_ge_item_tips")
require("game/shen_ge/shen_ge_zk_attr_view")
require("game/shen_ge/shen_ge_godbody_view")


ShenGeCtrl = ShenGeCtrl or BaseClass(BaseController)

function ShenGeCtrl:__init()
	if nil ~= ShenGeCtrl.Instance then
		return
	end

	ShenGeCtrl.Instance = self

	self.data = ShenGeData.New()
	self.view = ShenGeView.New(ViewName.ShenGeView)
	self.compose_view = ShenGeComposeView.New(ViewName.ShenGeComposeView)
	self.select_view = ShenGeSelectView.New(ViewName.ShenGeSelectView)
	self.operate_view = ShenGeOperateView.New(ViewName.ShenGeOperateView)
	self.attr_view = ShenGeAttrView.New(ViewName.ShenGeAttrView)
	self.upgrade_view = ShenGeUpgradeView.New(ViewName.ShenGeUpgradeView)
	self.decompose_view = ShenGeDecomposeView.New(ViewName.ShenGeDecomposeView)
	self.decompose_detail_view = ShenGeDecomposeDetailView.New(ViewName.ShenGeDecomposeDetailView)
	self.bless_prop_view = ShenGePropTipView.New(ViewName.ShenGePropTipView)
	self.pre_view = ShenGePreviewView.New(ViewName.ShenGePreview)
	self.tips_view = ShenGeItemTips.New(ViewName.ShenGeItemTips)
	self.zk_attr_tip_view = ShenGeZKAttrTipView.New(ShenGeZKAttrTipView)

	self:RegisterAllProtocols()
end

function ShenGeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShengeSystemBagInfo, "OnShengeSystemBagInfo") 	--	神格信息
	self:RegisterProtocol(SCShengeZhangkongInfo,"OnShengeZhangkongTotalInfo")   --	神格掌控总信息
	self:RegisterProtocol(SCZhangkongUplevelAllInfo,"OnSCZhangkongUplevelAllInfo")	--	神格掌控单个信息

	self:RegisterProtocol(SCShengeShenquAllInfo,"OnShengeShenquAllInfo")	--	神格神躯所有信息
	self:RegisterProtocol(SCShengeShenquInfo,"OnShengeShenquInfo")	--	神格神躯单个信息
end

function ShenGeCtrl:__delete()
	ShenGeCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.compose_view:DeleteMe()
	self.compose_view = nil

	self.select_view:DeleteMe()
	self.select_view = nil

	self.operate_view:DeleteMe()
	self.operate_view = nil

	self.attr_view:DeleteMe()
	self.attr_view = nil

	self.upgrade_view:DeleteMe()
	self.upgrade_view = nil

	self.decompose_view:DeleteMe()
	self.decompose_view = nil

	self.decompose_detail_view:DeleteMe()
	self.decompose_detail_view = nil

	self.bless_prop_view:DeleteMe()
	self.bless_prop_view = nil

	if self.tips_view ~= nil then
		self.tips_view:DeleteMe()
		self.tips_view = nil
	end

	if self.zk_attr_tip_view ~= nil then
		self.zk_attr_tip_view:DeleteMe()
		self.zk_attr_tip_view = nil
	end
end

function ShenGeCtrl:OnShengeSystemBagInfo(protocol)
	-- 右下角漂浮文本
	if SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO == protocol.info_type then
		self:ShowFloatText(protocol)
	end

	self.data:SetShenGeSystemBagInfo(protocol)

	RemindManager.Instance:Fire(RemindName.ShenGe_Bless)
	RemindManager.Instance:Fire(RemindName.ShenGe_ShenGe)
	RemindManager.Instance:Fire(RemindName.ShenGe_Godbody)

	-- 弹出恭喜获得UI
	if SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_COMPOSE_SHENGE_INFO == protocol.info_type then
		local temp_data = {}
		temp_data.item_id = self.data:GetShenGeItemId(protocol.bag_list[0].type, protocol.bag_list[0].quality)
		temp_data.num = 1
		temp_data.shen_ge_data = protocol.bag_list[0]
		local shenge_attr_ibute_cfg = self.data:GetShenGeAttributeCfg(protocol.bag_list[0].type, protocol.bag_list[0].quality, protocol.bag_list[0].level)
		temp_data.shen_ge_kind = shenge_attr_ibute_cfg and shenge_attr_ibute_cfg.kind or 0
		local is_succe = protocol.param1 == 1
		TipsCtrl.Instance:OpenGuildRewardView(temp_data, is_succe)
	end
end

-- 神格操作请求
function ShenGeCtrl:SendShenGeSystemReq(info_type, param1, param2, param3, param4, index_count, virtual_index_list, select_slot_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengeSystemReq)
	send_protocol.info_type = info_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0

	if info_type == SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_XILIAN then
		local param4 = bit:d2b(0)
		if nil ~= select_slot_list and next(select_slot_list) then
			for i = 1, 3 do
				param4[32 - i + 1] = select_slot_list[i]
			end
			send_protocol.param4 = bit:b2d(param4)
		end
	end	

	send_protocol.index_count = index_count or 0
	send_protocol.virtual_index_list = virtual_index_list or {}
	send_protocol:EncodeAndSend()
end

-- 右下角漂浮文本
function ShenGeCtrl:ShowFloatText(protocol)
	local info = self.data:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ALL_MARROW_SCORE_INFO)
	if nil == info then return end

	local old_fragments = info.param3
	if old_fragments < protocol.param3 then
		local diff = protocol.param3 - old_fragments
		TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.ShenGe.FloatText, diff))
	end
end

function ShenGeCtrl:ShowSelectView(call_back, data_list, from_view)
	self.select_view:SetSelectCallBack(call_back)
	self.select_view:SetHadSelectData(data_list)
	self.select_view:SetFromView(from_view)

	self.select_view:Open()
end

function ShenGeCtrl:ShowOperateView(data, is_from_bag, close_call_back)
	self.operate_view:SetIsFromBag(is_from_bag)
	self.operate_view:SetCallBack(close_call_back)
	self.operate_view:SetData(data)
end

function ShenGeCtrl:ShowUpgradeView(data, is_from_bag, close_call_back)
	self.upgrade_view:SetIsFromBag(is_from_bag)
	self.upgrade_view:SetCallBack(close_call_back)
	self.upgrade_view:SetData(data)
end

function ShenGeCtrl:ShowDecomposeDetail(quality, call_back, is_select)
	self.decompose_detail_view:SetQuality(quality)
	self.decompose_detail_view:SetCallBack(call_back)
	self.decompose_detail_view:SetIsSelect(is_select)

	self.decompose_detail_view:Open()
end

function ShenGeCtrl:ShowBlessPropTip(data)
	self.bless_prop_view:SetData(data)
end

------神格掌控协议----
function ShenGeCtrl:OnShengeZhangkongTotalInfo(protocol)
	self.data:SetZhangkongTotalInfo(protocol)
	self.view:Flush()
end

function ShenGeCtrl:OnSCZhangkongUplevelAllInfo(protocol)
	if protocol.item_list ~= nil then
		for k,v in pairs(protocol.item_list) do
			self.data:SetZhangkongSingleInfo(v)
		end
	end
	-- self.data:SetZhangkongSingleInfo(protocol)

	-- local data = self.data:GetZhangkongInfoByGrid(protocol.grid)
	-- local exp_str = ""
	-- if data ~= nil and next(data) ~= nil then
	-- 	exp_str = string.format(Language.ShenGe.ZKFlagExp, data.name, protocol.add_exp)
	-- end
	
	-- if self.view:IsOpen() then
	-- 	self.view.zhangkong_view:AddAni(protocol.item_list)
	-- else
	-- 	if protocol.item_list ~= nil then
	-- 		for k,v in pairs(protocol.item_list) do
	-- 			local data = self.data:GetZhangkongInfoByGrid(v.grid)
	-- 			local exp_str = ""
	-- 			if data ~= nil and next(data) ~= nil then
	-- 				exp_str = string.format(Language.ShenGe.ZKFlagExp, data.name, v.add_exp)
	-- 			end
	-- 			TipsCtrl.Instance:ShowFloatingLabel(exp_str)
	-- 		end
	-- 	end
	-- end

	self.view:Flush("show_fly", {item_list = protocol.item_list})
end

function ShenGeCtrl:SetTipsData(data)
	self.tips_view:SetData(data)
end

function ShenGeCtrl:SetTipsCallBack(callback)
	self.tips_view:SetCloseCallBack(callback)
end

function ShenGeCtrl:ChangeZkFlag(index)
	if index ~= nil and self.view:IsOpen() then
		self.view:Flush("change_zk_flag", {flag_index = index})
	end
end

function ShenGeCtrl:OpenZKAttrTipView()
	if self.zk_attr_tip_view ~= nil then
		self.zk_attr_tip_view:Open()
	end
end

-----------神躯---------
function ShenGeCtrl:OnShengeShenquAllInfo(protocol)
	self.data:SetShenquAllInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.ShenGe_Bless)
	RemindManager.Instance:Fire(RemindName.ShenGe_Godbody)
end

function ShenGeCtrl:OnShengeShenquInfo(protocol)
	self.data:SetShenquSingleInfo(protocol)
	self.view:Flush()
end

function ShenGeCtrl:SendShenquReq(param1, param2, param3, select_slot_list)
	self:SendShenGeSystemReq(SHENGE_SYSTEM_REQ_TYPE.SHENGE_SYSTEM_REQ_TYPE_XILIAN, param1, param2, param3, nil, nil, nil, select_slot_list)
end 