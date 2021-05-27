FubenCrystalView = FubenCrystalView or BaseClass(XuiBaseView)

function FubenCrystalView:__init()
	self.can_penetrate = true
	self.config_tab = {
		{"fuben_view_ui_cfg", 7, {0}},
	}
end

function FubenCrystalView:__delete()
end

function FubenCrystalView:ReleaseCallBack()
	if self.crystal_list ~= nil then
		self.crystal_list:DeleteMe()
		self.crystal_list = nil 
	end
end

function FubenCrystalView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateRanking()
		self.is_show = true
		self.node_t_list.layout_list_info.node:setVisible(self.is_show)
		XUI.AddClickEventListener(self.node_t_list.layout_btn.node, BindTool.Bind1(self.OnCrustoreBtn, self), true)
	end
end

function FubenCrystalView:OnCrustoreBtn()
	self.is_show = not self.is_show
	self.node_t_list.layout_list_info.node:setVisible(self.is_show)
end

function FubenCrystalView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FubenCrystalView:ShowIndexCallBack(index)
	self:Flush(index)
end

function FubenCrystalView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FubenCrystalView:OnFlush(param_t, index)
	local data = CrossUnionWarCfg.ExchangeItems
	self.crystal_list:SetData(data)
end

function FubenCrystalView:CreateRanking()
	if nil == self.crystal_list then
		local ph = self.ph_list.ph_crystal_list
		self.crystal_list = ListView.New()
		self.crystal_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CrystalRender, nil, nil, self.ph_list.ph_crystal_item)
		self.crystal_list:GetView():setAnchorPoint(0, 0)
		self.crystal_list:SetMargin(2)
		self.crystal_list:SetItemsInterval(20)
		self.crystal_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_info.layout_list_info.node:addChild(self.crystal_list:GetView(), 100)
	end	
end

CrystalRender = CrystalRender or BaseClass(BaseRender)
function CrystalRender:__init()
	self.item_data_changeback = BindTool.Bind1(self.ItemDataChangeCallback, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_changeback)
end

function CrystalRender:__delete()	
end

function CrystalRender:CreateChild()
	BaseRender.CreateChild(self)

	
end

function CrystalRender:OnFlush()
	if self.data == nil then return end
	
	local itme_data = ItemData.Instance:GetItemConfig(self.data.id)
	local item_num = ItemData.Instance:GetItemNumInBagById(self.data.id)
	self.node_tree.txt_name.node:setString(itme_data.name .. "×" .. item_num)
	if self.index == 1 then
		self.node_tree.txt_name.node:setColor(COLOR3B.WHITE)
	elseif self.index == 2 then
		self.node_tree.txt_name.node:setColor(COLOR3B.GREEN)
	elseif self.index == 3 then
		self.node_tree.txt_name.node:setColor(COLOR3B.BLUE)
	elseif self.index == 4 then
		self.node_tree.txt_name.node:setColor(COLOR3B.PURPLE)
	elseif self.index == 5 then
		self.node_tree.txt_name.node:setColor(COLOR3B.ORANGE)
	end	
	
end

function CrystalRender:ItemDataChangeCallback()
	self:OnFlush()
end