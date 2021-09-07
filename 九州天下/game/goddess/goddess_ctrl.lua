require("game/goddess/goddess_data")
require("game/goddess/goddess_view")
require("game/goddess/goddess_gongming_up_view")
require("game/goddess/goddess_shengwu_skill_tip_view")
require("game/goddess/goddess_search_aura_view")
require("game/goddess/tips_goddess_attr_view")
GoddessCtrl = GoddessCtrl or BaseClass(BaseController)

local piaozi_pos = {
	[0] = {x = -450, y = 270},
	[1] = {x = 300, y = -270},
	[2] = {x = 300, y = 270},
	[3] = {x = -450, y = -270},
}

function GoddessCtrl:__init()
	if GoddessCtrl.Instance then
		print_error("[GoddessCtrl] Attemp to create a singleton twice !")
	end
	GoddessCtrl.Instance = self

	self.data = GoddessData.New()
	self.view = GoddessView.New(ViewName.Goddess)
	self.aura_search_view = GoddessSearchAuraView.New(ViewName.GoddessSearchAuraView)
	self.goddess_gongming_up_view = GoddessGongMingUpView.New()
	self.goddess_skill_tip_view = GoddessShengWuSkillView.New()
	self.tips_goddess_attr_view = TipsGoddessAttrView.New(ViewName.TipsGoddessAttr)

	self:RegisterAllProtocols()
end

function GoddessCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.goddess_gongming_up_view:DeleteMe()
	self.goddess_gongming_up_view = nil

	self.goddess_skill_tip_view:DeleteMe()
	self.goddess_skill_tip_view = nil

	self.aura_search_view:DeleteMe()
	self.aura_search_view = nil

	if self.tips_goddess_attr_view ~= nil then
		self.tips_goddess_attr_view:DeleteMe()
		self.tips_goddess_attr_view = nil
	end
    
	self.data:DeleteMe()
	self.data = nil

	GoddessCtrl.Instance = nil
end

function GoddessCtrl:GetView()
	return self.view
end

function GoddessCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCAllXiannvInfo, "OnGoddessInfo")
	self:RegisterProtocol(SCXiannvInfo, "OnSCXiannvInfo")
	self:RegisterProtocol(SCXiannvViewChange, "OnSCXiannvViewChange")
	self:RegisterProtocol(SCXiannvShengwuMilingList, "OnSCXiannvShengwuMilingList")
	self:RegisterProtocol(SCXiannvShengwuChangeInfo, "OnSCXiannvShengwuChangeInfo")
	self:RegisterProtocol(SCXiannvShengwuChouExpList, "OnSCXiannvShengwuChouExpList")
	self:RegisterProtocol(SCXiannvShengwuChouExpResult, "OnSCXiannvShengwuChouExpResult")
end

--仙女信息同步
function GoddessCtrl:OnGoddessInfo(protocol)
	local flush_flag = false
	self.data:OnGoddessInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	if self.aura_search_view:IsOpen() then
		self.aura_search_view:FlushReceivedTime()
		self.aura_search_view:FlushFreeTimes()
	end

	RemindManager.Instance:Fire(RemindName.Goddess_FaZhe)
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing)
end

--升级信息同步
function GoddessCtrl:OnSCXiannvInfo(protocol)
	
end

function GoddessCtrl:OnSCXiannvViewChange(protocol)
	
end

--请求仙女激活
function GoddessCtrl:SendCSXiannvActiveReq(id, item_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvActiveReq)
	send_protocol.xiannv_id = id
	send_protocol.item_index = ItemData.Instance:GetItemIndex(item_id)
	send_protocol:EncodeAndSend()
end

--请求仙女升级
function GoddessCtrl:SendCSXiannvUpLevelReq(id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvUpLevelReq)
	send_protocol.xiannv_id = id
	send_protocol.auto_buy = 1
	send_protocol:EncodeAndSend()
end

--请求仙女出战
function GoddessCtrl:SendCSXiannvCall(pos_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvCall)
	send_protocol.pos_list = pos_list
	send_protocol:EncodeAndSend()
end

--请求仙女重命名
function GoddessCtrl:SendCSXiannvRename(xiannv_id,name)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvRename)
	send_protocol.xiannv_id = xiannv_id
	send_protocol.new_name = name
	send_protocol:EncodeAndSend()
end

--请求仙女激活幻化
function GoddessCtrl:SendXiannvActiveHuanhua(xiannv_id,item_index)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvActiveHuanhua)
	send_protocol.xiannv_id = xiannv_id
	send_protocol.item_index = item_index
	send_protocol:EncodeAndSend()
end

--请求改变幻化形象
function GoddessCtrl:SentXiannvImageReq(huanhua_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvImageReq)
	send_protocol.huanhua_id = huanhua_id
	send_protocol:EncodeAndSend()
end

--请求幻化形象升级
function GoddessCtrl:SentXiannvHuanHuaUpLevelReq(huanhua_id,auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvHuanHuaUpLevelReq)
	send_protocol.huanhua_id = huanhua_id
	send_protocol.auto_buy = auto_buy
	send_protocol:EncodeAndSend()
end

--请求改变幻化形象
function GoddessCtrl:SentXiannvImageReq(huanhua_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvImageReq)
	send_protocol.huanhua_id = huanhua_id
	send_protocol:EncodeAndSend()
end

--请求加资质
function GoddessCtrl:SentXiannvAddZizhiReq(xiannv_id)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvAddZizhiReq)
	send_protocol.xiannv_id = xiannv_id
	send_protocol.auto_buy = 0
	send_protocol:EncodeAndSend()
end

function GoddessCtrl:FlushView(param_list)
	self.view:Flush(param_list)
end

function GoddessCtrl:OnSCXiannvShengwuChouExpList(protocol)
	self.data:SetXiannvShengwuChouExpList(protocol)
	self.view:Flush()
end

function GoddessCtrl:OnSCXiannvShengwuChouExpResult(protocol)
	self.data:SetXiannvShengwuChouExpResult(protocol)
	self.view:Flush("shengwu_fly")
end

--请求女神圣器请求协议
function GoddessCtrl:SentCSXiannvShengwuReqReq(req_type, param1, param2, param3)
	if req_type == nil then
		return
	end
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSXiannvShengwuReq)
	send_protocol.req_type = req_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol:EncodeAndSend()
end

-- 打开共鸣升级面板
function GoddessCtrl:OpenGoddessGongMingUpView(param1)
	self.goddess_gongming_up_view:SetGridId(param1)
	self.goddess_gongming_up_view:Open()
end

-- 打开技能显示面板
function GoddessCtrl:OpenGoddessSkillTipView(param1)
	self.goddess_skill_tip_view:SetShengWuId(param1)
	self.goddess_skill_tip_view:Open()
end

-- 打开诡道属性Tip
function GoddessCtrl:OpenGoddessAttrTipView(param1)
	self.tips_goddess_attr_view:SetAttrData(param1)
	self.tips_goddess_attr_view:Open()
end

function GoddessCtrl:OnSCXiannvShengwuMilingList(protocol)
	self.data:SetXiannvShengwuMilingList(protocol)
	function sortfun(a, b)
		return a < b
	end
	table.sort(protocol.miling_list, sortfun)
	self.aura_search_view:Flush("miling_list",protocol.miling_list)
end

function GoddessCtrl:OnSCXiannvShengwuChangeInfo(protocol)
	RemindManager.Instance:Fire(RemindName.Goddess_FaZhe)
	RemindManager.Instance:Fire(RemindName.Goddess_GongMing)

	if protocol.notify_type == GODDESS_NOTIFY_TYPE.UNFETCH_EXP then
		self.data:SetHadUsedFreeTimes(protocol)
		self.data:SetShengWuLingYeValue(protocol.param4)
		self.view:Flush()
		-- if self.goddess_gongming_up_view:IsOpen() then
		-- 	self.goddess_gongming_up_view:Flush()
		-- end
		-- self.view:Flush("miling_change")
		local value = self.data:GetLingYeChange()
		if value > 0 then
			value = ToColorStr(value, TEXT_COLOR.GREEN)
			TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.Goddess.GetLingYeTip, value))
		end

		if self.goddess_gongming_up_view:IsOpen() then
			self.goddess_gongming_up_view:Flush()
		end
	elseif protocol.notify_type == GODDESS_NOTIFY_TYPE.SHENGWU_INFO then
		local goddess_data = self.data:GetXiannvScShengWuIconAttr(protocol.param1)
		self:ShowFloatingTips(protocol.param1, goddess_data, {level = protocol.param2, exp = protocol.param4})
		self.data:SetXiannvScShengWuIconAttr(protocol)
		self.view:Flush()
	elseif protocol.notify_type == GODDESS_NOTIFY_TYPE.GRID_INFO then
		self.data:SetXiannvShengwuGridLevel(protocol)
		self.view:Flush()
	end
end

function GoddessCtrl:ShowFloatingTips(id, old_data, cur_data)
	local old_exp = old_data.exp or 0
	local cur_exp = cur_data.exp or 0

	local old_level = old_data.level or 0
	local cur_level = cur_data.level or 0
	local add_exp = 0
	if old_level ~= cur_level then 
		add_exp = self.data:GetShengWuAddExp(id, old_level, cur_level, old_exp, cur_exp)
	else
		add_exp = cur_exp - old_exp
	end

	local msg = ToColorStr("+" .. add_exp, TEXT_COLOR.GREEN)
	if add_exp > 0 then
		self.floating_view = TipsFloatingView.New()
		self.floating_view:Show(string.format(Language.Goddess.AddExp, add_exp), piaozi_pos[id].x, piaozi_pos[id].y, true)
	end
end

function GoddessCtrl:ResetEff()
	if self.aura_search_view:IsOpen() then
		self.aura_search_view:Flush("reset_eff")
	end
end