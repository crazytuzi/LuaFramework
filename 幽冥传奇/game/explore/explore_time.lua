-- 查看寻宝次数详情

local ExploreTimeView = BaseClass(SubView)

function ExploreTimeView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)
	self.texture_path_list[1] = 'res/xui/guild.png'
	self.config_tab = {
		{"explore_ui_cfg", 6, {0}},
	}

	self.num_index = 1
end

function ExploreTimeView:__delete()
end

function ExploreTimeView:ReleaseCallBack()
	if self.time_item_list then
		self.time_item_list:DeleteMe()
		self.time_item_list = nil
	end

	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end

	self.num_index = 1
end

function ExploreTimeView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateTabbar()
		self:CreateItemList()

		XUI.AddClickEventListener(self.node_t_list.btn_black2.node, BindTool.Bind1(self.OnClickBack, self))
		XUI.AddClickEventListener(self.node_t_list.btn_join.node, BindTool.Bind1(self.OnClickJoin, self))
	end

end

function ExploreTimeView:OnClickBack()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Fullserpro)
	ExploreCtrl.Instance:WorldInfoReq()
end

function ExploreTimeView:OnClickJoin()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
end

function ExploreTimeView:ShowIndexCallBack(index)
	self:Flush()
end
	
function ExploreTimeView:OpenCallBack()
end

function ExploreTimeView:CloseCallBack()
end

function ExploreTimeView:CreateTabbar()
	if nil == self.tabbar then
		self.tabbar = ScrollTabbar.New()
		self.tabbar:SetSpaceInterval(6)
		self.tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar.node, 8, -3,
			BindTool.Bind1(self.SelectTabCallback, self), Language.JiFenEquipment.TimeTabGroup, 
			true, ResPath.GetCommon("toggle_120"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
	end
end

function ExploreTimeView:SelectTabCallback(index)
	self.num_index = index

	self:FlushList()
end

function ExploreTimeView:FlushList()
	local current_index = self.num_index
	local data = ExploreData.Instance:GetTimeList(current_index)
	
	self.time_item_list:SetDataList(data)
end

function ExploreTimeView:CreateItemList()

	if nil == self.time_item_list then
		local ph = self.ph_list.ph_time_list
		self.time_item_list = ListView.New()
		self.time_item_list:Create(ph.x, ph.y, ph.w, ph.h, nil, TimeRender, nil, nil, self.ph_list.ph_time_item)
		-- self.time_item_list:GetView():setAnchorPoint(0, 0)
		-- self.time_item_list:SetItemsInterval(5)
		self.time_item_list:SetMargin(0)
		self.time_item_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_time.node:addChild(self.time_item_list:GetView(), 100)
	end
end

function ExploreTimeView:OnFlush(param_t, index)
	self:FlushList()
end

-- 列表Item
TimeRender = TimeRender or BaseClass(BaseRender)
function TimeRender:__init()
	self.save_data = {}
end

function TimeRender:__delete()
	
end

function TimeRender:CreateChild()
	BaseRender.CreateChild(self)
	
end

function TimeRender:OnFlush()
	if nil == self.data then return end

	self.node_tree.img9_bg.node:setColor((self.index % 2 == 0) and COLOR3B.WHITE or COLOR3B.GRAY)

	self.node_tree.lbl_name.node:setString(self.data.role_name)
	self.node_tree.lbl_level.node:setString(self.data.level .. "级")
	self.node_tree.lbl_guild.node:setString(self.data.guild_name == "" and "无" or self.data.guild_name)
	self.node_tree.lbl_time.node:setString(self.data.xb_num .. "次")
	self.node_tree.img_is_prize.node:setVisible(self.data.rew_type and self.data.rew_type > 0)
end

function TimeRender:CreateSelectEffect()
end

return ExploreTimeView