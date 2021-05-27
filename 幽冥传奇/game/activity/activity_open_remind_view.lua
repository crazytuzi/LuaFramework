ActivityOpenRemindView = ActivityOpenRemindView or BaseClass(XuiBaseView)

function ActivityOpenRemindView:__init()
	self.texture_path_list[1] = "res/xui/activity.png"
	self.view_name = ViewName.ActOpenRemind
	self.config_tab = {{"activity_ui_cfg", 3, {0}}}
	self.zorder = -1
end

function ActivityOpenRemindView:__delete()

end

function ActivityOpenRemindView:ReleaseCallBack()
	if self.flush_data then
		self.flush_data = nil
	end

	if self.act_open_remind_list then
		self.act_open_remind_list:DeleteMe()
		self.act_open_remind_list = nil
	end
end

function ActivityOpenRemindView:LoadCallBack(index, loaded_time)
	if loaded_time <= 1 then
		local screen_w, screen_h = HandleRenderUnit:GetWidth(), HandleRenderUnit:GetHeight()
		self.root_node:setAnchorPoint(0, 1)
		self.root_node:setPosition(screen_w - 295, screen_h - 160)

		local swallow = false
		self.root_node:setSwallowTouches(swallow)
		self.node_t_list.layout_act_open_remind.node:setSwallowTouches(swallow)

		if not self.act_open_remind_list then
			local ph = self.ph_list.ph_act_open_remind_list
			self.act_open_remind_list = ListView.New()
			self.act_open_remind_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ActivityOpenRemindRender, nil, nil, self.ph_list.ph_act_open_remind)
			self.act_open_remind_list:SetItemsInterval(4)
			self.act_open_remind_list:GetView():setAnchorPoint(0, 0)
			self.act_open_remind_list:SetJumpDirection(ListView.Top)
			self.act_open_remind_list:SetMargin(2)
			self.act_open_remind_list:GetView():setSwallowTouches(swallow)
			self.node_t_list.layout_act_open_remind.node:addChild(self.act_open_remind_list:GetView())
		end
	end
end

function ActivityOpenRemindView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityOpenRemindView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ActivityOpenRemindView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ActivityOpenRemindView:SetFlushData(data)
	self.flush_data = data or nil
end

function ActivityOpenRemindView:OnFlush(param_t, index)
	if nil == self.flush_data then return end

	self.act_open_remind_list:SetData(self.flush_data)
end

-- function ActivityOpenRemindView:OnLayoutClicked()
-- 	ViewManager.Instance:Open(ViewName.Activity)
-- end


---------------------------------
-- ActivityOpenRemindRender
---------------------------------
ActivityOpenRemindRender = ActivityOpenRemindRender or BaseClass(BaseRender)
function ActivityOpenRemindRender:__init()
	self:AddClickEventListener(BindTool.Bind(self.OnClickRender, self))
end

function ActivityOpenRemindRender:__delete()
end

function ActivityOpenRemindRender:CreateChild()
	BaseRender.CreateChild(self)

	self.rich_content = self.node_tree.rich_content.node
	self.rich_content:setIgnoreSize(true)
	self.rich_content:setHorizontalAlignment(RichHAlignment.HA_LEFT)

	local effect = RenderUnit.CreateEffect(923, self.view, 2, FrameTime.Effect, COMMON_CONSTS.MAX_LOOPS, 145, 23)
	effect:setScale(1.1)
end

function ActivityOpenRemindRender:OnFlush()
	if not self.data then return end

	local _, _, content = string.find(ActivityData.GetOneTypeActivityCfg(self.data.type or 3).name, "({.-})")
	content = content .. (self.data.time_str or "00:00-24:00")
	if self.rich_content then
		RichTextUtil.ParseRichText(self.rich_content, content, 20, COLOR3B.BRIGHT_GREEN)
	end
end

function ActivityOpenRemindRender:CreateSelectEffect()
	
end

function ActivityOpenRemindRender:OnClickRender()
	ViewManager.Instance:Open(ViewName.Activity)
end