AdvancedLevelView = AdvancedLevelView or BaseClass(BaseView)

function AdvancedLevelView:__init()
	self.title_img_path = ResPath.GetWord("title_jinjie")
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		
	}
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
		--{"common_ui_cfg", 3, {0}},
	}

	self.btn_info = {ViewDef.Advanced.Moshu,ViewDef.Advanced.YuanSu, ViewDef.Advanced.ShengShou}

	require("scripts/game/advanced_level/advanced_level_moshu_view").New(ViewDef.Advanced.Moshu)
	require("scripts/game/advanced_level/advanced_level_yuansu_view").New(ViewDef.Advanced.YuanSu)
	require("scripts/game/advanced_level/advanced_level_shengshou_view").New(ViewDef.Advanced.ShengShou)
end

function AdvancedLevelView:__delete()
	-- body
end

function AdvancedLevelView:LoadCallBack()
	if  nil == self.tabbar then
		self.tabbar = Tabbar.New()
		self.tabbar:SetTabbtnTxtOffset(2, 12)
		self.tabbar:SetClickItemValidFunc(function(index)
			return ViewManager.Instance:CanOpen(self.btn_info[index]) 
		end)
		self.tabbar:CreateWithNameList(self:GetRootNode(), 60, 650, BindTool.Bind(self.TabSelectCellBack, self),
			Language.Advanced.TabGroup, true, ResPath.GetCommon("toggle_110"), 25, true)
	end
	 self:BindGlobalEvent(OtherEventType.GAME_COND_CHANGE, BindTool.Bind(self.OnGameCondChange, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))
end

function AdvancedLevelView:TabSelectCellBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function AdvancedLevelView:OpenCallBack()
	-- body
end

function AdvancedLevelView:ShowIndexCallBack( ... )
	self:Flush(index)
end

function AdvancedLevelView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function AdvancedLevelView:CloseCallBack()
	-- body
end

function AdvancedLevelView:OnFlush()
	self:FlushBtns()
end
function AdvancedLevelView:OnGameCondChange()
	self:FlushBtns()
end

function AdvancedLevelView:FlushBtns()
	for k, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(k)
		end
		self:FlushBtnRemind(k)
		local vis = (ViewManager.Instance:CanOpen(v))
		self.tabbar:SetToggleVisible(k, vis)
	end
end

function AdvancedLevelView:OnRemindGroupChange(remind_group_name)
	if remind_group_name == RemindGroupName.MoshuTabbar then
		self:FlushBtnRemind(1)
	elseif remind_group_name == RemindGroupName.YuansuTababar then
		self:FlushBtnRemind(2)
	elseif remind_group_name == RemindGroupName.ShengShouTabbar then
		self:FlushBtnRemind(3)
	end
end


function AdvancedLevelView:FlushBtnRemind(index)
	local btn_info = self.btn_info[index]
	if btn_info and btn_info.remind_group_name then
		local vis = RemindManager.Instance:GetRemindGroup(btn_info.remind_group_name) > 0 and (not IS_ON_CROSSSERVER)
		self.tabbar:SetRemindByIndex(index, vis)
	end
end

