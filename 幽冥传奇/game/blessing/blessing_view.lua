------------------------------------------------------------
--祈福View
------------------------------------------------------------
BlessingView = BlessingView or BaseClass(BaseView)

function BlessingView:__init()
	self.title_img_path = ResPath.GetWord("word_blessing")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"blessing_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, true, 999},
	}

	self.btn_info = {ViewDef.BlessingView.Fortune, ViewDef.BlessingView.Blessing}

	require("scripts/game/blessing/fortune_view").New(ViewDef.BlessingView.Fortune, self)
	--require("scripts/game/blessing/make_vow_view").New(ViewDef.BlessingView.Blessing, self)
end

function BlessingView:__delete()
end

function BlessingView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function BlessingView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
    	self:InitTabbar()

    	EventProxy.New(BlessingData.Instance, self):AddEventListener(BlessingData.BLESSING_NUM, BindTool.Bind(self.TabbarRemind, self))
    	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.TabbarRemind, self))
    end
end

function BlessingView:InitTabbar()
	if nil == self.tabbar then
		local tabgroup = {}
		for k, v in pairs(self.btn_info) do
			tabgroup[#tabgroup + 1] = v.name
		end
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(2, 12)
		self.tabbar:CreateWithNameList(self.node_t_list.layout_comon_bg.node, self.ph_list.ph_tabbar.x, self.ph_list.ph_tabbar.y + 60,
		BindTool.Bind(self.TabSelectCellBack, self),
		tabgroup, true, ResPath.GetCommon("toggle_110"), 25, true)
		-- self.tabbar:SetSpaceInterval(15)
		self.tabbar:GetView():setLocalZOrder(1)
		self.tabbar:SetToggleVisible(1, false)
		self.tabbar:SetToggleVisible(2, false)
	end
end

--选择标签回调
function BlessingView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
	--刷新标签栏显示
	-- self.tabbar:ChangeToIndex(index)
end

function BlessingView:OpenCallBack()
	-- BlessingCtrl.Instance:SendBlessData(1)
end

function BlessingView:ShowIndexCallBack(index)
	-- self.tabbar:ChangeToIndex(self.index)

	self:Flush()
end

function BlessingView:OnFlush(param_t, index)
	self:TabbarRemind()
end

function BlessingView:CloseCallBack()
end

function BlessingView:TabbarRemind()
	for k, v in pairs(self.btn_info) do
		-- if ViewManager.Instance:IsOpen(v) then
			-- 当前选中的tabbar
		-- 	self.tabbar:ChangeToIndex(k)
		-- end
		-- 提醒
		if v == ViewDef.BlessingView.Fortune then
			self.tabbar:SetRemindByIndex(k, false)
		elseif v == ViewDef.BlessingView.Blessing then
			self.tabbar:SetRemindByIndex(k, BlessingData.Instance:RemindBlessing() > 0)
		end
	end
end
