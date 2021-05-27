-- 窗口导航（活动、副本）
MainuiTask = MainuiTask or BaseClass()

OTHER_TASK_GUIDE = {
	LEFT = "other_task_guide_left",
	RIGHT = "other_task_guide_right",
	BOTTOM = "other_task_guide_bottom",
	BOTTOM_ALL = "bottom_all",   --只是用来显示bottom面板的显隐问题用到，all代表左右两个面板都显示bottom面板
}

function MainuiTask:InitOtherTaskGuide()
	self.img_left = nil
	self.img_right = nil

	self.left_content = nil
	self.left_render = nil
	self.right_content = nil
	self.right_render = nil
	self.bottom_content = nil
	self.bottom_render = nil

	self.other_data = {}
end

function MainuiTask:DelOtherTaskGuide()
	self:ClearContent("left_content")
	self:ClearContent("right_content")
	self:ClearContent("bottom_content")
	self:InitOtherTaskGuide()
end

function MainuiTask:SetOtherData(data)
	for k, v in pairs(data or {}) do
		if k == OTHER_TASK_GUIDE.LEFT then
			self:RefreshLeftOtherView(v)
		elseif k == OTHER_TASK_GUIDE.RIGHT then
			self:RefreshRightOtherView(v)
		elseif k == OTHER_TASK_GUIDE.BOTTOM then
			self:RefreshBottomOtherView(v)
		end
	end
end

function MainuiTask:ClearOtherData()
	self:RefreshLeftOtherView()
	self:RefreshRightOtherView()
	self:RefreshBottomOtherView()
end

function MainuiTask:ClearContent(key)
	if self[key] and self[key].GetView then
		self[key]:GetView():setVisible(false)
		NodeCleaner.Instance:AddNode(self[key]:GetView())
		self[key]:DeleteMe()
		self[key] = nil
	end
end

-- 左边导航
function MainuiTask:RefreshLeftOtherView(data)
	self.other_data[OTHER_TASK_GUIDE.LEFT] = data or {}
	if self.other_data[OTHER_TASK_GUIDE.LEFT].guide_name then
		self.img_task:setVisible(false)
		if not data.is_hide then
			local x, y = self.img_task:getPosition()
			if data.btn_x then
				x = data.btn_x
			end
			if self.img_left == nil then
				self.img_left = XUI.CreateImageView(x, y, ResPath.GetMainui(data.btn_path), true)
				self.mt_layout_root:TextLayout():addChild(self.img_left)
				self.img_left:setHittedScale(1.03)
				XUI.AddClickEventListener(self.img_left, BindTool.Bind(self.OnClickLeft, self), true)
			else
				self.img_left:loadTexture(ResPath.GetMainui(data.btn_path))
				self.img_left:setVisible(true)
				self.img_left:setPosition(x, y)
			end
			
			local render = data.render or BaseTaskGuideRender
			if self.left_render == nil or self.left_render ~= render then
				self:ClearContent("left_content")
				self.left_render = render
				self.left_content = self.left_render.New()
				self.left_content:SetIndex(OTHER_TASK_GUIDE.LEFT)
				self.left_content:SetIsUseStepCalc(true)
				if nil ~= data.ui_config then
					self.left_content:SetUiConfig(data.ui_config, false)
				end
				local size = self.left_content:GetView():getContentSize()
				self.left_content:SetPosition(0, 0)
				self.mt_layout_root:TextLayout():addChild(self.left_content:GetView())
			end

			self.left_content:SetData(data.render_data)
		end

	else
		if self.img_left then
			self.img_left:setVisible(false)
		end
		self:ClearContent("left_content")
		self.left_render = nil
		self.img_task:setVisible(true)
	end

	self:SetShowContent(self.showing_type)
end

-- 右边导航
function MainuiTask:RefreshRightOtherView(data)
	self.other_data[OTHER_TASK_GUIDE.RIGHT] = data or {}
	if self.other_data[OTHER_TASK_GUIDE.RIGHT].guide_name then
		self.img_team:setVisible(false)
		if not data.is_hide then
			local x, y = self.img_team:getPosition()
			if data.btn_x then
				x = data.btn_x
			end
			if self.img_right == nil then
				self.img_right = XUI.CreateImageView(x, y, ResPath.GetMainui(data.btn_path), true)
				self.mt_layout_root:TextLayout():addChild(self.img_right)
				self.img_right:setHittedScale(1.03)
				XUI.AddClickEventListener(self.img_right, BindTool.Bind(self.OnClickRight, self), true)
			else
				self.img_right:loadTexture(ResPath.GetMainui(data.btn_path))
				self.img_right:setVisible(true)
				self.img_right:setPosition(x, y)
			end

			local render = data.render or BaseTaskGuideRender
			if self.right_render == nil or self.right_render ~= render then
				self:ClearContent("right_content")
				self.right_render = render
				self.right_content = self.right_render.New()
				self.right_content:SetIndex(OTHER_TASK_GUIDE.RIGHT)
				self.right_content:SetIsUseStepCalc(true)
				if nil ~= data.ui_config then
					self.right_content:SetUiConfig(data.ui_config, false)
				end
				local size = self.right_content:GetView():getContentSize()
				self.right_content:SetPosition(0, 0)
				self.mt_layout_root:TextLayout():addChild(self.right_content:GetView())
			end

			self.right_content:SetData(data.render_data)
		end

	else
		if self.img_right then
			self.img_right:setVisible(false)
		end
		self:ClearContent("right_content")
		self.right_render = nil
		self.img_team:setVisible(true)
	end

	self:SetShowContent(self.showing_type)
end

-- 底部导航
function MainuiTask:RefreshBottomOtherView(data)
	self.other_data[OTHER_TASK_GUIDE.BOTTOM] = data or {}
	if self.other_data[OTHER_TASK_GUIDE.BOTTOM].guide_name then
		local render = data.render or TaskBottomRender
		if self.bottom_render == nil or self.bottom_render ~= render then
			self:ClearContent("bottom_content")
			self.bottom_render = render
			local w = data.w or MainuiTask.Size.width
			local h = data.h or 40
			self.bottom_content = self.bottom_render.New(w, h)
			self.bottom_content:SetIndex(OTHER_TASK_GUIDE.BOTTOM)
			self.bottom_content:SetIsUseStepCalc(true)
			if nil ~= data.ui_config then
				self.bottom_content:SetUiConfig(data.ui_config, false)
			end
			local size = self.bottom_content:GetView():getContentSize()
			self.bottom_content:SetPosition(0, 0)
			self.bottom_content:GetView():setAnchorPoint(0, 1)
			self.mt_layout_root:TextLayout():addChild(self.bottom_content:GetView())
		end

		self.bottom_content:SetData(data.render_data)
	else
		self:ClearContent("bottom_content")
		self.bottom_render = nil
	end
end

function MainuiTask:SetOtherViewVis(vis)
	if self.left_content then
		self.left_content:GetView():setVisible(vis)
	end
	if self.right_content then
		self.right_content:GetView():setVisible(vis)
	end
	if self.bottom_content then
		self.bottom_content:GetView():setVisible(vis)
	end
	self:CheckTaskListEffectVisible()
end

function MainuiTask:OnClickLeft()
	self.showing_type = MainuiTask.SHOW_TYPE.LEFT

	self.task_listview:GetView():setVisible(false)
	self.team_listview:GetView():setVisible(false)

	if self.left_content then
		self.left_content:GetView():setVisible(true)	
	end
	if self.right_content then
		self.right_content:GetView():setVisible(false)	
	end
	if self.bottom_content then
		local data = self.bottom_content:GetData()
		local vis = data and (data.parent_panel == OTHER_TASK_GUIDE.LEFT or data.parent_panel == OTHER_TASK_GUIDE.BOTTOM_ALL) or false
		self.bottom_content:GetView():setVisible(vis)
	end
	self:OnFlushViewSize()
	self:CheckTaskListEffectVisible()
end

function MainuiTask:OnClickRight()
	self.showing_type = MainuiTask.SHOW_TYPE.RIGHT

	self.task_listview:GetView():setVisible(false)
	self.team_listview:GetView():setVisible(false)

	if self.left_content then
		self.left_content:GetView():setVisible(false)	
	end
	if self.right_content then
		self.right_content:GetView():setVisible(true)
	end
	if self.bottom_content then
		local data = self.bottom_content:GetData()
		local vis = data and (data.parent_panel == OTHER_TASK_GUIDE.RIGHT or data.parent_panel == OTHER_TASK_GUIDE.BOTTOM_ALL) or false
		self.bottom_content:GetView():setVisible(vis)
	end
	self:OnFlushViewSize()
	self:CheckTaskListEffectVisible()
end

function MainuiTask:GetRightContent()
	return self.right_content
end