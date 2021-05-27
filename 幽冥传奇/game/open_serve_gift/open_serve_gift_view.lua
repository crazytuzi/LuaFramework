local OpenSerVeGiftView = OpenSerVeGiftView or BaseClass(BaseView)

function OpenSerVeGiftView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/open_serve_gift.png'
	self.texture_path_list[2] = "res/xui/vip.png"
	self.config_tab = {
		{"open_serve_gift_ui_cfg", 1, {0}},
	}

	self.tabbar = nil

	--数据来源
	self.model = OpenSerVeGiftData.Instance
end

function OpenSerVeGiftView:ShowIndexCallBack()
	-- self:OnFlushTabbar()
end

function OpenSerVeGiftView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
	end
	self.tabbar = nil
end

function OpenSerVeGiftView:LoadCallBack(index, loaded_times)
	self:InitTabbar()
	EventProxy.New(OpenSerVeGiftData.Instance, self):AddEventListener(OpenSerVeGiftData.TabbarChange, BindTool.Bind(self.OnFlushTabbar, self))
end

function OpenSerVeGiftView:OpenCallBack()
	if self.tabbar then
		self:OnFlushTabbar()
	end
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenSerVeGiftView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function OpenSerVeGiftView:OnFlushTabbar()
	local is_select = false
	for i, v in ipairs(self.model:GetTabVisList()) do
		self.tabbar:SetToggleVisible(i, v)
	end 

	for i, v in ipairs(self.model:GetTabVisList()) do
		if v then
			self:SelectTabCallback(i)
			is_select = true
			break
		end
	end 

	if not is_select then self:CloseHelper() end
end

function OpenSerVeGiftView:OnFlush(param_t, index)
end

function OpenSerVeGiftView:InitTabbar()
	if nil == self.tabbar then
		local name_group = {}
		for i, vdef in ipairs(self.model:GetTabNameList()) do
			name_group[i] = vdef.name
		end  

		self.tabbar = ScrollTabbar.New()
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 28, 0,
			BindTool.Bind(self.SelectTabCallback, self), name_group, 
			true, ResPath.GetCommon("toggle_120"))
	end

	self:OnFlushTabbar()
end


local view_tag = {
	SaleGift = ViewDef.OpenSerVeGift.SaleGift,
	LimitTimeBuy = ViewDef.OpenSerVeGift.LimitTimeBuy,
}
function OpenSerVeGiftView:SelectTabCallback(index)
	self:GetViewManager():OpenViewByDef(view_tag[self.model:GetTabNameList()[index].tag])
	OpenSerVeGiftData.Instance:SetTabbarIdx(index)
end


return OpenSerVeGiftView