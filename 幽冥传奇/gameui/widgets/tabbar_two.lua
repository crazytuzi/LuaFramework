
----------------------------------------------------
-- TabbarTwo 
----------------------------------------------------
TabbarPosDef = {
	GroupX = -21,
	GroupY = 640,
	SubX = 145,
	SubY = 587,
}

TabbarTwo = TabbarTwo or BaseClass()
function TabbarTwo:__init()
	self.group_cfg_list = nil						-- {path or text, ...}，坚向配置，可以是路径也可以是文字
	self.sub_cfg_list = nil							-- {{text, text ...}, ... }
	self.group_is_text = true

	self.tabbar_group = nil
	self.tabbar_list = nil
	self.select_callback = nil
	self.cur_index = 0
	self.parent = nil
	self.visible_list = {}
	self.space_interval = 24
	self.notify_callback_list = {}

	self.group_x = TabbarPosDef.GroupX
	self.group_y = TabbarPosDef.GroupY
	self.sub_x = TabbarPosDef.SubX
	self.sub_y = TabbarPosDef.SubY
end

function TabbarTwo:__delete()
	self:Release()
end

function TabbarTwo:Release()
	if nil ~= self.tabbar_group then
		self.tabbar_group:DeleteMe()
		self.tabbar_group = nil
	end
	if nil ~= self.tabbar_list then
		for k, v in pairs(self.tabbar_list) do
			v:DeleteMe()
		end
		self.tabbar_list = nil
	end
	self.cur_index = 0
	self.parent = nil

	for k, v in pairs(self.notify_callback_list) do
		v()
	end
	self.notify_callback_list = {}
end

-- 初始化，传入配置指tabbar样式
-- @group_cfg_list {path or text, ...}
-- @sub_cfg_list {{text, text ...}, ... }
-- @group_is_text bool
function TabbarTwo:Init(group_cfg_list, sub_cfg_list, group_is_text)
	self.group_cfg_list = group_cfg_list
	self.sub_cfg_list = sub_cfg_list
	self.group_is_text = group_is_text or true
end

function TabbarTwo:SetSelectCallback(callback)
	self.select_callback = callback
end

-- 选中某项，带回调
function TabbarTwo:SelectIndex(index, parent)
	if self:ChangeToIndex(index, parent) and nil ~= self.select_callback then
		self.select_callback(index)
	end
end

-- 切换到某项，无回调
function TabbarTwo:ChangeToIndex(index, parent)
	if index == self.cur_index then
		return false
	end
	self.cur_index = index
	self.parent = parent

	local group = 1
	if index >= 10 then
		group = math.floor(index / 10)
		self:ChangeGroupIndex(group)
	end

	self:ChangeSubIndex(group, index % 10)
	return true
end

function TabbarTwo:IsGroupTabIndexVisible(group)
	if self.sub_cfg_list[group] ~= nil then
		for k,v in pairs(self.sub_cfg_list[group]) do
			if self.visible_list[group * 10 + k] == nil or self.visible_list[group * 10 + k] then
				return true
			end
		end
	elseif self.visible_list[group * 10 ] == nil or self.visible_list[group * 10] then
		return true
	end
	return false
end

function TabbarTwo:ChangeGroupIndex(group)
	if nil == self.parent or nil == self.group_cfg_list then
		return
	end

	if nil == self.tabbar_group then
		self.tabbar_group = Tabbar.New()
		self.tabbar_group:SetTabbtnTxtOffset(8, 0)
		if self.group_is_text then
			self.tabbar_group:CreateWithNameList(self.parent, self.group_x, self.group_y, BindTool.Bind(self.OnSelectGroupCallback, self), self.group_cfg_list, true, ResPath.GetCommon("toggle_103"), 20)
		else
			self.tabbar_group:CreateWithPathList(self.parent, self.group_x, self.group_y, BindTool.Bind(self.OnSelectGroupCallback, self), self.group_cfg_list, true)
		end
		for k,v in pairs(self.group_cfg_list ) do
			self.tabbar_group:SetToggleVisible(k, self:IsGroupTabIndexVisible(k))
		end
		
		self.tabbar_group:SetSpaceInterval(self.space_interval)
	end
	self.tabbar_group:ChangeToIndex(group)
end

function TabbarTwo:ChangeSubIndex(group, index)
	if nil == self.parent then
		return
	end

	if nil ~= self.sub_cfg_list and nil ~= self.sub_cfg_list[group] then
		self.tabbar_list = self.tabbar_list or {}
		if nil == self.tabbar_list[group] then
			self.tabbar_list[group] = Tabbar.New()
			self.tabbar_list[group]:CreateWithNameList(self.parent, self.sub_x, self.sub_y, BindTool.Bind1(self.OnSelectSubCallback, self), self.sub_cfg_list[group], false, ResPath.GetCommon("toggle_118"))
			for k,v in pairs(self.sub_cfg_list[group]) do
				if self.visible_list[group * 10 + k] ~= nil then
					self:SetToggleVisible(group * 10 + k, self.visible_list[group * 10 + k])
				end
			end
		end

		if nil ~= index then
			self.tabbar_list[group]:ChangeToIndex(index)
		end
	end

	if nil ~= self.tabbar_list then
		for k, v in pairs(self.tabbar_list) do
			v:SetVisible(k == group)
		end
	end
end

function TabbarTwo:OnSelectGroupCallback(group)
	self:ChangeSubIndex(group)
	
	if nil ~= self.select_callback and self.cur_index ~=self:GetCurSelectIndex() then
		self.cur_index = self:GetCurSelectIndex()
		self.select_callback(self:GetCurSelectIndex())
	end
end

function TabbarTwo:OnSelectSubCallback(index)
	if nil ~= self.select_callback and self.cur_index ~= self:GetCurSelectIndex() then
		self.cur_index = self:GetCurSelectIndex()
		self.select_callback(self:GetCurSelectIndex())
	end
end

function TabbarTwo:GetCurSelectIndex()
	local index = 0
	local group = 1

	if nil ~= self.tabbar_group then
		group = self.tabbar_group:GetCurSelectIndex()
		index = group * 10
	end

	if nil ~= self.tabbar_list and nil ~= self.tabbar_list[group] then
		index = index + self.tabbar_list[group]:GetCurSelectIndex()
	end

	return index
end

function TabbarTwo:SetGroupPosition(x, y)
	self.group_x, self.group_y = x, y
	if nil ~= self.tabbar_group then
		self.tabbar_group:SetPosition(x, y)
	end
end

function TabbarTwo:SetSubPosition(x, y)
	self.sub_x, self.sub_y = x, y
	if nil ~= self.tabbar_list then
		for k, v in pairs(self.tabbar_list) do
			v:SetPosition(x, y)
		end
	end
end

function TabbarTwo:SetInterval(interval)
	self.space_interval = interval
	if self.tabbar_group then
		self.tabbar_group:SetSpaceInterval(space_interval)
	end
end

function TabbarTwo:SetToggleVisible(index, is_visible)
	local group = math.floor(index / 10)
	if self.tabbar_list and self.tabbar_list[group] then
		local tab =  self.tabbar_list[group]
		tab:SetToggleVisible(index % 10, is_visible)
		tab:UpdatePosition()		
	end
	self.visible_list[index] = is_visible
	if self.tabbar_group then
		self.tabbar_group:SetToggleVisible(group, self:IsGroupTabIndexVisible(group))
		self.tabbar_group:UpdatePosition()
	end
end

-- 设置提醒数字
function TabbarTwo:SetRemindNumByIndex(index, num)
	local group = math.floor(index / 10)
	if self.tabbar_list and self.tabbar_list[group] then
		local tab =  self.tabbar_list[group]
		local btn = tab.radio_button:GetToggle(index % 10)
		if nil ~= btn then
			btn:SetRemindNum(num)
		end 
	elseif index % 10 == 0 and self.tabbar_group:GetToggle(group) then
		local btn = self.tabbar_group.radio_button:GetToggle(group)
		if btn then
			btn:SetRemindNum(num)
		end
	end
end


-- 设置提醒
function TabbarTwo:SetRemindByIndex(index, vis, path, x, y)
	local group = math.floor(index / 10)
	if self.tabbar_list and self.tabbar_list[group] then
		local tab =  self.tabbar_list[group]
		local btn = tab.radio_button:GetToggle(index % 10)
		if nil ~= btn then
			btn:SetRemind(num)
		end 
	elseif index % 10 == 0 and self.tabbar_group then
		local btn = self.tabbar_group.radio_button:GetToggle(group)
		if btn then
			btn:SetRemind(vis, path, x, y)
		end
	end
end

-- 根据index取按钮，如果group不在当前index，优先取group 按钮
function TabbarTwo:GetToggleByIndex(index)
	local group = 1
	if index > 10 then
		group = math.floor(index / 10)
	end

	if nil ~= self.tabbar_group then
		if group ~= self.tabbar_group:GetCurSelectIndex() then
			return self.tabbar_group:GetToggle(group), (index % 10 == 0)
		elseif index % 10 == 0 then
			return self.tabbar_group:GetToggle(group), true
		end
	end

	if nil ~= self.tabbar_list and nil ~= self.tabbar_list[group] then
		return self.tabbar_list[group]:GetToggle(index % 10)
	end

	return nil
end

function TabbarTwo:SetBtnModalEnabled(index, value, callback)
	local group = 1
	if index > 10 then
		group = math.floor(index / 10)
	end

	if nil ~= self.tabbar_group then
		if group ~= self.tabbar_group:GetCurSelectIndex() then
			self.tabbar_group:SetBtnModalEnabled(group, value, callback)
		elseif index % 10 == 0 then
			self.tabbar_group:SetBtnModalEnabled(group, value, callback)
		end
	end

	if nil ~= self.tabbar_list and nil ~= self.tabbar_list[group] then
		self.tabbar_list[group]:SetBtnModalEnabled(index % 10, value, callback)
	end
end

function TabbarTwo:RegisterDeleteHandler(callback)
	self.notify_callback_list[callback] = callback
end

function TabbarTwo:UnRegisterDeleteHandler(callback)
	self.notify_callback_list[callback] = nil
end
