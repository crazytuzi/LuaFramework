
AutoRecycleListView = AutoRecycleListView or BaseClass(XuiBaseView)
function AutoRecycleListView:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self.config_tab = {
		{"storage_ui_cfg", 7, {0}},
	}
end

function AutoRecycleListView:__delete()
	
end

function AutoRecycleListView:ReleaseCallBack()
	if self.auto_recycle_select_list then
		self.auto_recycle_select_list:DeleteMe()
		self.auto_recycle_select_list = nil 
	end
end

function AutoRecycleListView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		if nil == self.auto_recycle_select_list then
			self.auto_recycle_select_list = ListView.New()
			local ph = self.ph_list.ph_auto_recycle_list
			self.auto_recycle_select_list:Create(ph.x+105, ph.y+215,ph.w,ph.h, nil, AutoRecycleSelectRender, nil, nil,self.ph_list.ph_auto_recycle_list_item)
			self.auto_recycle_select_list:SetItemsInterval(6)
			self.node_t_list.layout_auto_recycle_page.node:addChild(self.auto_recycle_select_list:GetView(), 100)
			self.auto_recycle_select_list:SetSelectCallBack(BindTool.Bind1(self.ShowDescCallBack, self))
			self.auto_recycle_select_list:SetJumpDirection(ListView.Top)
			self.auto_recycle_select_list:SetMargin(3)
			local type_cfg = ConfigManager.Instance:GetAutoConfig("auto_recycle_item").item_name
			self.auto_recycle_select_list:SetDataList(type_cfg)
		end
	end
end

function AutoRecycleListView:ShowDescCallBack(item)
	local index = item:GetIndex()
	if index >0 then
		local temp = RecycleDataTemp[index]
		if temp and temp[1] and temp[2] then
			cc.UserDefault:getInstance():setIntegerForKey("auto_bag_recycle_circle",temp[1])
			cc.UserDefault:getInstance():setIntegerForKey("auto_bag_recycle_level",temp[2])
			ViewManager.Instance:FlushView(ViewName.Recycle, 0, "select_level")
			self:Close()
		end
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end


function AutoRecycleListView:ShowIndexCallBack(index)
	self:Flush(index)
end
	
function AutoRecycleListView:OpenCallBack()

end

function AutoRecycleListView:CloseCallBack()

end


function AutoRecycleListView:OnFlush(param_t, index)

end


AutoRecycleSelectRender = AutoRecycleSelectRender or BaseClass(BaseRender)
function AutoRecycleSelectRender:__init()
	self.count_down_time = 0
	self.timer_quest = nil
end

function AutoRecycleSelectRender:__delete()
	if self.timer_quest then
		GlobalTimerQuest:CancelQuest(self.timer_quest)
		self.timer_quest = nil
	end
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end
end

function AutoRecycleSelectRender:CreateChild()
	BaseRender.CreateChild(self)
	-- self:CreateDrawNode()
end

function AutoRecycleSelectRender:OnFlush()
	if not self.data then return end
	self.node_tree.txt_level.node:setString(self.data)
end