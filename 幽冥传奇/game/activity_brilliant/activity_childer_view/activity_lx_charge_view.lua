--------------------------------------------------
-- 连续充值 32, 42
--------------------------------------------------

LianXuCZView = LianXuCZView or BaseClass(ActBaseView)

function LianXuCZView:__init(view, parent, act_id)
	self:LoadView(parent)
end

function LianXuCZView:__delete()
	if nil~=self.grid_lianxu_charge_scroll_list then
		self.grid_lianxu_charge_scroll_list:DeleteMe()
	end
	self.grid_lianxu_charge_scroll_list = nil
end

function LianXuCZView:InitView()
	self:CreateLXChargeGridScroll()
end

function LianXuCZView:RefreshView(param_list)
	local data = ActivityBrilliantData.Instance
	local cfg = data:GetActCfgByIndex(self.act_id)
	local pay = cfg.config.pay
	local day_charge = data.day_charge[self.act_id] or 0
	local str = day_charge .."/".. pay

	self.node_t_list.layout_charge_lianxu.lbl_activity_tip.node:setString(str)
	if day_charge >= pay then
		self.node_t_list.layout_charge_lianxu.lbl_activity_tip.node:setColor(COLOR3B.GREEN)
	end
	
	local data_list = ActivityBrilliantData.Instance:GetLXchargeItemList(self.act_id)
	self.grid_lianxu_charge_scroll_list:SetDataList(data_list)
	self.grid_lianxu_charge_scroll_list:JumpToTop()
end

--连续充值
function LianXuCZView:CreateLXChargeGridScroll()
	if nil == self.node_t_list.layout_charge_lianxu then
		return
	end
	if nil == self.grid_lianxu_charge_scroll_list then
		local ph = self.ph_list["ph_charge_view_list"]
		self.grid_lianxu_charge_scroll_list = GridScroll.New()
		self.grid_lianxu_charge_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, self.ph_list.ph_charge_list.h+2, LXChargeItemRender, ScrollDir.Vertical, false, self.ph_list.ph_charge_list)
		self.node_t_list.layout_charge_lianxu.node:addChild(self.grid_lianxu_charge_scroll_list:GetView(), 100)
	end
end