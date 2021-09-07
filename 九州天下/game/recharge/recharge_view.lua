require("game/recharge/recharge_content")

RechargeView = RechargeView or BaseClass(BaseView)

local variable_table = {
	recharge_bg = "recharge_bg",
	title_bg = "title_bg",
	word_chongzhi = "word_chongzhi",
	vip_bg = "vip_bg",
	vip = "vip",
	word_tequan = "word_tequan",
	btn_tequan = "btn_tequan",
	doublecharge = "doublecharge",
}

function RechargeView:__init()
	self.ui_config = {"uis/views/recharge", "ReChargeView"}
	self.contain_cell_list = {}
	self.full_screen = false
	self.play_audio = true
	self:SetMaskBg()

	RechargeView.Instance = self
end

function RechargeView:__delete()
	RechargeView.Instance = nil
end

function RechargeView:LoadCallBack()
	self.next_vip_level_text = self:FindVariable("next_vip_level_text")
	self.remain_exp_text = self:FindVariable("remain_exp_text")
	self.vip_exp_slider = self:FindVariable("vip_exp_slider")
	self.show_remain_exp = self:FindVariable("show_remain_exp")
	self.show_text = self:FindVariable("show_text")
	self.show_final_desc = self:FindVariable("show_final_desc")
	self.total_exp = self:FindVariable("total_exp")
	self.current_exp = self:FindVariable("current_exp")
	self.doule_charge = self:FindVariable("doule_charge")
	self.current_vip_level_text = self:FindVariable("current_vip_level_text")

	for k, v in pairs(variable_table) do
		self[v .. "_url"] = self:FindVariable(v .. "_url")
		self["show_" .. v] = self:FindVariable("show_" .. v)
	end

	self:ListenEvent("OnClickLookRight", BindTool.Bind(self.OnClickLookRight, self))
	self:ListenEvent("OnClickClose", BindTool.Bind(self.OnClickClose, self))

	self.list_view = self:FindObj("list_view")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
	self.doule_charge:SetValue(not RechargeData.Instance:IsFirstRecharge())

	self:Flush()
end

function RechargeView:ReleaseCallBack()
	for k,v in pairs(self.contain_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	self.contain_cell_list = {}
	
	self.full_screen = nil
	self.play_audio = nil
	self.vip_cur_level = nil
	self.vip_next_level = nil
	self.list_view = nil
	self.next_vip_level_text = nil
	self.remain_exp_text = nil
	self.vip_exp_slider = nil
	self.show_remain_exp = nil
	self.show_text = nil
	self.show_final_desc = nil
	self.total_exp = nil	
	self.current_exp = nil
	self.current_vip_level_text = nil
	self.doule_charge = nil

	for k, v in pairs(variable_table) do
		if self["show_" .. v] then
			self["show_" .. v] = nil
		end
		self[v .. "_url"] = nil
	end
end

function RechargeView:OnClickLookRight()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.VIP)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

function RechargeView:OnClickClose()
	self:Close()
end

function RechargeView:GetNumberOfCells()
	local recharge_id_list = RechargeData.Instance:GetRechargeIdList()
	if #recharge_id_list %4 ~= 0 then
		return math.floor(#recharge_id_list/4) + 1
	else
		return #recharge_id_list/4
	end
end

function RechargeView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RechargeContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	local id_list = RechargeData.Instance:GetRechargeListByIndex(cell_index)
	contain_cell:SetData({item_id_list = id_list})
end

function RechargeView:OnFlush()
	local current_vip_id = VipData.Instance:GetVipInfo().vip_level
	self.current_vip_level_text:SetValue(current_vip_id)
	if current_vip_id < 15 then
		self.show_remain_exp:SetValue(true)
		self.show_text:SetValue(true)
		self.show_final_desc:SetValue(false)
	else
		self.show_remain_exp:SetValue(false)
		self.show_text:SetValue(false)
		self.show_final_desc:SetValue(true)
	end
	local total_exp = VipData.Instance:GetVipExp(current_vip_id)
	local passlevel_consume = VipData.Instance:GetVipExp(current_vip_id - 1)
	local current_exp = VipData.Instance:GetVipInfo().vip_exp + passlevel_consume
	if current_vip_id < 15 then
		self.next_vip_level_text:SetValue(current_vip_id + 1)
		self.remain_exp_text:SetValue(total_exp - current_exp)
	end
	if current_vip_id == 15 then
		self.vip_exp_slider:SetValue(1)
	else
		self.vip_exp_slider:SetValue(current_exp/total_exp)
		self.total_exp:SetValue(total_exp)
		self.current_exp:SetValue(current_exp)
	end
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
	self.doule_charge:SetValue(not RechargeData.Instance:IsFirstRecharge())

	for k, v in pairs(variable_table) do
		if AssetManager.ExistedInStreaming("AgentAssets/" .. v .. ".png") then
			if self["show_" .. v] then
				self["show_" .. v]:SetValue(false)
			end
			GlobalTimerQuest:AddDelayTimer(function()
				local url = UnityEngine.Application.streamingAssetsPath .. "/AgentAssets/" .. v .. ".png"
				self[v .. "_url"]:SetValue(url)
			end, 0)
		else
			if self["show_" .. v] then
				self["show_" .. v]:SetValue(true)
			end
		end
	end
end

function RechargeView:SetRechargeActive(is_active)
	self.root_node:SetActive(is_active)
end