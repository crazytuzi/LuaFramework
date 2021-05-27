
----------------------------------------------------
-- Tabbar
----------------------------------------------------

TabbarDef = {
	def_path = ResPath.GetCommon("toggle_100"),
}

Tabbar = Tabbar or BaseClass(BaseRender)

Tabbar.AlignmentType = {
	Left = 0, -- 横向-左对齐 或 坚向-上对齐
	Center = 1, -- 横向-居中 或 坚向-居中
	Right = 2, -- 横向-右对齐 或 坚向-下对齐
}

function Tabbar:__init()
	self.radio_button = RadioButton.New()
	self.is_vertical = false						-- 是否坚向
	self.alignment_type = Tabbar.AlignmentType.Left	-- 对齐方式 默认 横向-左对齐 或 坚向-上对齐
	self.space_interval = nil 						-- 间隔
	self.space_interval_H = 10 						-- 坚向默认间隔
	self.space_interval_V = 0						-- 横向默认间隔
	self.font_size = 22
	self.end_select = false
	self.count = 0
	self.tabbtn_txt_offset = {x = 0, y = 0}
	self.notify_callback_list = {}
end

function Tabbar:__delete()
	self.radio_button:DeleteMe()

	for k, v in pairs(self.notify_callback_list) do
		v()
	end
end

function Tabbar:GetRadioButton()
	return self.radio_button
end

function Tabbar:GetCount()
	return self.count
end

function Tabbar:CreateWithNameList(parent, x, y, callback, name_list, is_vertical, def_path, font_size, is_txt_vertical, zorder)	
	x = x or -28
	y = y or 586
	self.font_size = font_size or self.font_size
	parent:addChild(self.view, zorder or 999, zorder or 999)
	self.view:setPosition(x, y)
	self.radio_button:SetSelectCallback(callback)
	self:SetNameList(name_list, is_vertical, def_path or TabbarDef.def_path, is_txt_vertical)
end

function Tabbar:CreateWithPathList(parent, x, y, callback, path_list, is_vertical)
	x = x or 982
	y = y or 500
	parent:addChild(self.view, 999, 999)
	self.view:setPosition(x, y)
	self.radio_button:SetSelectCallback(callback)
	self:SetPathList(path_list, is_vertical)
end

function Tabbar:SetTabbtnTxtOffset(x, y)
	self.tabbtn_txt_offset.x = x
	self.tabbtn_txt_offset.y = y
end

function Tabbar:SetNameList(name_list, is_vertical, def_path, is_txt_vertical)
	self.is_vertical = is_vertical
	-- 未设置间隔时才取默认值
	self.space_interval = self.space_interval or (self.is_vertical and self.space_interval_V or self.space_interval_H)
	local old_ocunt = self.radio_button:GetCount()
	self.count = #name_list

	if self.count > old_ocunt then
		local normal_path, select_path = self:GetPath(def_path)
		local btn = nil
		for i= 1, self.count - old_ocunt do
			btn = TabbarBtn.New(normal_path, select_path, self.end_select)
			btn:SetTitleTextOffset(self.tabbtn_txt_offset.x, self.tabbtn_txt_offset.y)
			btn:setTitleFontSize(self.font_size)
			btn:setTitleFontName(COMMON_CONSTS.FONT)
			btn:enableOutline(cc.c4b(0, 0, 0, 255), XUI.outline_size)
			self.view:addChild(btn:GetView())
			self.radio_button:AddToggle(btn)
		end
	elseif self.count < old_ocunt then
		for i= 1, old_ocunt - self.count do
			self.radio_button:DelLastToggle()
		end
	end

	local set_txt_verical = function (str)
		local t_str = ""
		-- str = "出售"
		for i = 1, string.len(str), 3 do
			t_str = t_str .. string.sub(str,i, i+2) .. "\n"
		end
		return t_str
	end

	for k, v in pairs(self.radio_button:GetToggleList()) do
		local str = is_txt_vertical and set_txt_verical(name_list[k]) or name_list[k]
		v:setTitleText(str)
	end

	self.radio_button:ChangeToIndex(1)

	self:UpdatePosition()
end

function Tabbar:SetNameByIndex(index, name, color)
	for k, v in pairs(self.radio_button:GetToggleList()) do
		if k == index then
			v:setTitleText(name)
			if color then
				v:setTitleColor(color)
			end
		end
	end
end

function Tabbar:SetPathList(path_list, is_vertical)
	self.is_vertical = is_vertical

	for k, v in pairs(self.radio_button:GetToggleList()) do
		v:GetView():removeFromParent()
		v:DeleteMe()
	end
	self.radio_button:Clear()

	local normal_path = ""
	local select_path = ""
	local btn = nil
	for i, v in ipairs(path_list) do
		normal_path, select_path = self:GetPath(v)
		btn = TabbarBtn.New(normal_path, select_path, self.end_select)
		self.view:addChild(btn:GetView())
		self.radio_button:AddToggle(btn)
	end
	
	self.radio_button:ChangeToIndex(1)
	
	self:UpdatePosition()
end

function Tabbar:SetClickItemValidFunc(func)
	self.radio_button:SetSelectValidFunc(func)
end

function Tabbar:SetClickItemCallBack(callback)
	self.radio_button:SetSelectCallback(callback)
end

function Tabbar:SetToggleVisible(index, is_visible)
	local btn = self.radio_button:GetToggle(index)
	if nil ~= btn then
		btn:setVisible(is_visible)
		self:UpdatePosition()
	end
end

function Tabbar:GetCurSelectIndex()
	return self.radio_button:GetSelectIndex()
end

-- 选中某项，带回调
function Tabbar:SelectIndex(index)
	self.radio_button:SelectIndex(index)
end

-- 切换到某项，无回调
function Tabbar:ChangeToIndex(index)
	self.radio_button:ChangeToIndex(index)
end

-- 设置提醒数字
function Tabbar:SetRemindNumByIndex(index, num)
	local btn = self.radio_button:GetToggle(index)
	if nil ~= btn then
		btn:SetRemindNum(num)
	end
end

-- 设置提醒
function Tabbar:SetRemindByIndex(index, vis, path, x, y)
	local btn = self.radio_button:GetToggle(index)
	if nil ~= btn then
		btn:SetRemind(vis, path, x, y)
	end
end

-- 设置字体大小
function Tabbar:SetTitleFontSize(index, vis, path, x, y)
	local btn = self.radio_button:GetToggle(index)
	if nil ~= btn then
		btn:SetRemind(vis, path, x, y)
	end
end

-- 设置按钮间隔
function Tabbar:SetSpaceInterval(space_interval)
	self.space_interval = space_interval
	self:UpdatePosition()
end

-- 设置按钮居中
function Tabbar:SetAlignmentType(_type)
	self.alignment_type = _type
	self:UpdatePosition()
end

-- Tabbar.AlignmentType = {
-- 	Left = 0, -- 横向-左对齐 或 坚向-上对齐
-- 	Center = 1, -- 横向-居中 或 坚向-居中
-- 	Right = 2, -- 横向-右对齐 或 坚向-下对齐
-- }
function Tabbar:UpdatePosition()
	local offset = 0

	if self.is_vertical then
		if self.alignment_type ~= Tabbar.AlignmentType.Left then
			for k, v in ipairs(self.radio_button:GetToggleList()) do
				if v:isVisible() then
					offset = offset - v:getContentSize().height - self.space_interval
				end
			end

			if self.alignment_type == Tabbar.AlignmentType.Center then
				offset = (offset + self.space_interval) / -2
			elseif self.alignment_type == Tabbar.AlignmentType.Right then
				offset = - (offset + self.space_interval)
			end
		end

		for k, v in ipairs(self.radio_button:GetToggleList()) do
			if v:isVisible() then
				offset = offset - v:getContentSize().height
				v:setPositionY(offset)
				offset = offset - self.space_interval
			end
		end

	else
		if self.alignment_type ~= Tabbar.AlignmentType.Left then
			for k, v in ipairs(self.radio_button:GetToggleList()) do
				if v:isVisible() then
					offset = offset + v:getContentSize().width + self.space_interval
				end
			end

			if self.alignment_type == Tabbar.AlignmentType.Center then
				offset = (offset - self.space_interval) / -2
			elseif self.alignment_type == Tabbar.AlignmentType.Right then
				offset = - (offset - self.space_interval)
			end
		end

		for k, v in ipairs(self.radio_button:GetToggleList()) do
			if v:isVisible() then
				v:setPositionX(offset)
				offset = offset + v:getContentSize().width + self.space_interval
			end
		end
	end
end

function Tabbar:IsAllInvisible()
	for k, v in ipairs(self.radio_button:GetToggleList()) do
		if v:isVisible() then
			return false
		end
	end
	return true
end

function Tabbar:GetPath(path)
	path = path or ResPath.GetCommon("btn_103_normal")
	local normal_path = path
	if not string.find(normal_path, "_normal") then
		normal_path = string.gsub(normal_path, ".png", "_normal.png")
	end
	local select_path = string.gsub(normal_path, "_normal", "_select")
	return normal_path, select_path
end

function Tabbar:GetToggle(index)
	local toggle = self.radio_button:GetToggle(index)
	if nil == toggle then
		return nil
	end
	return toggle:GetView()
end

-- 根据index取按钮
function Tabbar:GetToggleByIndex(index)
	return self:GetToggle(index)
end

function Tabbar:SetBtnModalEnabled(index, value, callback)
	local toggle = self.radio_button:GetToggle(index)
	if nil == toggle then
		return nil
	end
	toggle:SetModalEnabled(value, callback)
end

function Tabbar:RegisterDeleteHandler(callback)
	self.notify_callback_list[callback] = callback
end

function Tabbar:UnRegisterDeleteHandler(callback)
	self.notify_callback_list[callback] = nil
end

----------------------------------------------------
-- TabbarBtn
----------------------------------------------------
TabbarBtn = TabbarBtn or BaseClass()
function TabbarBtn:__init(normal, select, end_select)
	self.img_normal = XImage:create(normal)
	self.img_select = XImage:create(select)
	self.txt_title = nil
	self.end_select = end_select

	if nil == self.img_normal or nil == self.img_select then
		return
	end

	self.img_select:setVisible(false)

	local size = self.img_normal:getContentSize()
	self.view = XLayout:create(size.width, size.height)

	self.img_normal:setPosition(size.width / 2, size.height / 2)
	self.img_select:setPosition(size.width / 2, size.height / 2)

	self.view:addChild(self.img_normal)
	self.view:addChild(self.img_select)

	self.modal = XLayout:create(size.width, size.height)
	self.modal:addClickEventListener(BindTool.Bind(self.OnClickModalCallback, self))
	self.view:addChild(self.modal, 999)

	self.view:setTouchEnabled(true)
	self.view:addTouchEventListener(BindTool.Bind(self.OnTouchCallback, self))

	self.is_pressed = false
	self.click_callback = nil
	self.valid_click_func = nil
	self.remind_bg_sprite = nil
	self.title_txt_offset = {x = 0, y = 0}
end

function TabbarBtn:__delete()
	
end

function TabbarBtn:GetView()
	return self.view
end

function TabbarBtn:OnTouchCallback(sender, event_type, touch)
	if (self.end_select and event_type == XuiTouchEventType.Ended) or (not self.end_select and event_type == XuiTouchEventType.Began) then
		if nil == self.valid_click_func or self.valid_click_func() then
			self:setTogglePressed(not self.is_pressed)
			if nil ~= self.click_callback then
				self.click_callback()
			end
		end
	end
end

function TabbarBtn:SetTitleTextOffset(x, y)
	self.title_txt_offset.x = x 
	self.title_txt_offset.y = y
end

function TabbarBtn:GetText()
	if nil == self.txt_title then
		self.txt_title = XText:create()
		self.txt_title:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		local size = self.view:getContentSize()
		self.txt_title:setPosition(size.width / 2 + self.title_txt_offset.x, size.height / 2 + self.title_txt_offset.y)
		self.txt_title:setColor(COLOR3B.OLIVE)
		self.view:addChild(self.txt_title, 1, 1)
	end

	return self.txt_title
end

-- 设置提醒数字
function TabbarBtn:SetRemindNum(num)
	if nil == self.remind_bg_sprite then
		local size = self.view:getContentSize()
		self.remind_bg_sprite = XUI.CreateImageView(size.width - 9, size.height - 11, ResPath.GetCommon("remind_bg_1"), true)
		self.view:addChild(self.remind_bg_sprite, 1, 1)
	end
	if nil == self.remind_label then
		local size = self.view:getContentSize()
		self.remind_label = XUI.CreateText(size.width - 9, size.height - 9, 0, 0, cc.TEXT_ALIGNMENT_CENTER, "", nil, 18)
		self.view:addChild(self.remind_label, 1, 1)
	end
	if num > 99 then num = 99 end

	if num < 10 then
		self.remind_bg_sprite:loadTexture(ResPath.GetCommon("remind_bg_1"), true)
	elseif num > 0 then
		self.remind_bg_sprite:loadTexture(ResPath.GetCommon("remind_bg_1"), true)
	end

	self.remind_label:setString(tostring(num))
	self.remind_bg_sprite:setVisible(0 ~= num)
	self.remind_label:setVisible(0 ~= num)
end

-- 设置提醒
function TabbarBtn:SetRemind(vis, path, x, y)
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) <= RemindLimitAll then return end 
	path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = x or size.width - 10
	y = y or size.height - 5
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.view:addChild(self.remind_bg_sprite, 1, 1)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

function TabbarBtn:SetModalEnabled(value, callback)
	self.modal:setTouchEnabled(value)
	if callback then		
		self.modal_callback = callback
	end
end

function TabbarBtn:OnClickModalCallback()
	if self.modal_callback then
		self.modal_callback()
	end
end

function TabbarBtn:SetValidClickFunc(callback)
	self.valid_click_func = callback
end

----------------------------------------------------
-- 模拟Toggle接口 begin
----------------------------------------------------
function TabbarBtn:isTogglePressed()
	return self.is_pressed
end

function TabbarBtn:setTogglePressed(is_pressed)
	if self.is_pressed ~= is_pressed then
		self.is_pressed = is_pressed
		self.img_normal:setVisible(not is_pressed)
		self.img_select:setVisible(is_pressed)
	end
end

function TabbarBtn:addClickEventListener(callback)
	self.click_callback = callback
end

function TabbarBtn:setTitleText(text)
	self:GetText():setString(text)
end

function TabbarBtn:setTitleFontSize(font_size)
	self:GetText():setFontSize(font_size)
end

function TabbarBtn:setTitleFontName(name)
	self:GetText():setFontName(name)
end

function TabbarBtn:setTitleColor(color)
	self:GetText():setColor(color)
end

function TabbarBtn:enableOutline(color, outline_size)
	self:GetText():enableOutline(color, outline_size)
end

function TabbarBtn:setAnchorPoint(x, y)
	self.view:setAnchorPoint(x, y)
end

function TabbarBtn:isVisible()
	return self.view:isVisible()
end

function TabbarBtn:setVisible(is_visible)
	self.view:setVisible(is_visible)
end

function TabbarBtn:setPositionX(x)
	self.view:setPositionX(x)
end

function TabbarBtn:setPositionY(y)
	self.view:setPositionY(y)
end

function TabbarBtn:setPosition(x, y)
	self.view:setPosition(x, y)
end

function TabbarBtn:getContentSize()
	return self.view:getContentSize()
end

function TabbarBtn:removeFromParent()
	return self.view:removeFromParent()
end

----------------------------------------------------
-- 模拟Toggle接口 end
----------------------------------------------------
