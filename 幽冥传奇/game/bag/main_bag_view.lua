 MainBagView = MainBagView or BaseClass(BaseView)

function MainBagView:__init()
	self.close_mode = CloseMode.CloseVisible -- 关闭面板时,不释放

	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	--self.title_img_path = ResPath.GetWord("QieGe")
	-- self.title_img_path = ResPath.GetBag("titile_bag")
	self.texture_path_list = {
		--'res/xui/qiege.png',
		'res/xui/bag.png',
		
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},

	}

	--self.btn_info = {ViewDef MainBagView.QieGe, ViewDef MainBagView.Shenbi｝
	
	self.btn_info = {ViewDef.MainBagView.BagView, ViewDef.MainBagView.ComspoePanel, }

	self.remind_list = {}
	for k, v in pairs(self.btn_info) do
		if v.remind_group_name then
			self.remind_list[v.remind_group_name] = k
		end
	end
	self.panel_list = {}

	--require("scripts/game/bag/bag_view").New(ViewDef.MainBagView.BagView)

	
	
end

function MainBagView:__delete()
	
end

function MainBagView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	
end

function MainBagView:LoadCallBack(index, loaded_times)
	if (loaded_times <= 1) then
		if  nil == self.tabbar then
			self.tabbar = Tabbar.New()
			self.tabbar:SetTabbtnTxtOffset(2, 12)
			self.tabbar:SetClickItemValidFunc(function(index)
				return ViewManager.Instance:CanOpen(self.btn_info[index]) 
			end)
			self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
				Language.Bag.TabGroup1, true, ResPath.GetCommon("toggle_110"), 25, true)
		end
		self.tabbar:ChangeToIndex(1)
		self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
		self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
	end
end

function MainBagView:ChangTabbar(index)
	self.tabbar:ChangeToIndex(index or 1)
end

function MainBagView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function MainBagView:OpenCallBack(index)
	if self.tabbar then
		self.tabbar:ChangeToIndex(1)
	end
end

function MainBagView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MainBagView:CloseCallBack()
	-- override
end

function MainBagView:OnFlush(param_list)
	
	self:OnGameCondChange()
end

function MainBagView:OnRemindGroupChange(remind_name, num)
	if remind_name == RemindGroupName.BagComposeView then
		self:FlushBtnRemind(2)
	end
end

function MainBagView:OnGameCondChange( ... )
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		self:FlushBtnRemind(k)
		local vis = (ViewManager.Instance:CanOpen(v))
		self.tabbar:SetToggleVisible(k, vis)
	end
end


function MainBagView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)

		self.tabbar:SetRemindByIndex(index, vis)
	end
end