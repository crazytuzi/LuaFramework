--------------------------------------------------------
-- 装扮面板	
--------------------------------------------------------

FashionView = FashionView or BaseClass(BaseView)

function FashionView:__init()
	self.title_img_path = ResPath.GetWord("word_fashion")
	self.texture_path_list[1] = 'res/xui/fashion.png'
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}, nil, 999},
	}

	self.btn_info = {
		ViewDef.Fashion.FashionChild,
		ViewDef.Fashion.WuHuan,
		ViewDef.Fashion.ZhenQi,
		ViewDef.Fashion.Title,
	}

	require("scripts/game/fashion/fashion_child_view").New(ViewDef.Fashion.FashionChild)
	require("scripts/game/fashion/fashion_child_view").New(ViewDef.Fashion.WuHuan)
	require("scripts/game/fashion/fashion_child_view").New(ViewDef.Fashion.ZhenQi)
	require("scripts/game/fashion/fashion_child_view").New(ViewDef.Fashion.Title)
end

function FashionView:__delete()
end

--释放回调
function FashionView:ReleaseCallBack()
	self.set_flag = nil
end

--加载回调
function FashionView:LoadCallBack(index, loaded_times)
	self:CreateTabbar()

	
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChanged, self))
end

function FashionView:OpenCallBack()
	--播放声音
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function FashionView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--显示指数回调
function FashionView:ShowIndexCallBack(index)
	for i, v in pairs(self.btn_info) do
		if ViewManager.Instance:IsOpen(v) then
			self.tabbar:ChangeToIndex(i)
		end
		local vis = ViewManager.Instance:CanOpen(v)
		self.tabbar:SetToggleVisible(i, vis)
		
		self:FlushRemind(i)
	end
end

function FashionView:OnFlush(param_list)

end

----------视图函数----------

function FashionView:CreateTabbar()
	local parent = self:GetRootNode()
	local ph = {x = 60, y = 650, w = 10, h = 10} -- 锚点为0,0
	-- 标题文本
	local name_list = {}
	for k, v in ipairs(self.btn_info) do
		name_list[#name_list + 1] = v.name
	end
	local is_vertical = true 		-- 按钮-垂直排列
	local path = ResPath.GetCommon("toggle_110")
	local font_size = 25 			-- 标题字体大小
	local is_txt_vertical = true	-- 文本-垂直排列
	local interval = 10 			-- 间隔
	
	local callback = BindTool.Bind(self.TabbarSelectCallBack, self)	 -- 点击回调
	
	local tabbar = Tabbar.New()
	tabbar:SetTabbtnTxtOffset(2, 12)
	tabbar:SetSpaceInterval(interval)
	tabbar:CreateWithNameList(parent, ph.x, ph.y, callback, name_list, is_vertical, path, font_size, is_txt_vertical)
	self.tabbar = tabbar
	self:AddObj("tabbar")
end

--------------------

function FashionView:TabbarSelectCallBack(index)
	ViewManager.Instance:OpenViewByDef(self.btn_info[index])
end

function FashionView:FlushRemind(index)
	local remind_group_name = self.btn_info[index].remind_group_name
	if remind_group_name then
		local remind_count = RemindManager.Instance:GetRemindGroup(remind_group_name)
		self.tabbar:SetRemindByIndex(index, remind_count > 0)
	end
end

function FashionView:OnRemindGroupChanged(remind_group_name, num)
	if self:IsOpen() and self.tabbar then
		for i, view_def in ipairs(self.btn_info) do
			if view_def.remind_group_name == remind_group_name then
				self:FlushRemind(i)
			end
		end
	end
end