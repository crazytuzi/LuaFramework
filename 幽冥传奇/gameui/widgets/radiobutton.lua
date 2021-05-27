
RadioButton = RadioButton or BaseClass()

function RadioButton:__init()
	self.toggle_list = {}
	self.select_index = 0
	self.select_callback = nil
	self.select_vaild_func = nil
end

function RadioButton:__delete()
	self.toggle_list = {}
end

function RadioButton:GetToggleList()
	return self.toggle_list
end

function RadioButton:SetToggleList(toggle_list)
	if #self.toggle_list > 0 then
		return
	end

	for i, v in ipairs(toggle_list) do
		self:AddToggle(v)
	end
	self:ChangeToIndex(1)
end

function RadioButton:SetRadioButton(radiobutton_list)
	if nil == radiobutton_list then return end
	local toggle_list = {}
	for k,v in pairs(radiobutton_list) do
		if string.find(k, "toggle") then
			local ch = string.sub(k, string.len(k))
			toggle_list[ch + 1] = v.node
		end
	end
	self:SetToggleList(toggle_list)
end

function RadioButton:SetVisible(visible)
	for _,v in pairs(self.toggle_list) do
		v:setVisible(visible)
	end
end

function RadioButton:SetToggleVisible(index, visible)
	if nil ~= self.toggle_list[index] then
		self.toggle_list[index]:setVisible(visible)
	end
end

function RadioButton:GetToggle(index)
	return self.toggle_list[index]
end

function RadioButton:AddToggle(toggle)
	table.insert(self.toggle_list, toggle)
	if toggle.SetValidClickFunc then
		toggle:SetValidClickFunc(BindTool.Bind(self.SelectVaildFunc, self, #self.toggle_list))
	end
	toggle:addClickEventListener(BindTool.Bind(self.OnClickCallback, self, #self.toggle_list))
end

function RadioButton:DelToggle(index)
	local total_count = #self.toggle_list
	if index <= 0 or index > total_count then
		return
	end

	if index < self.select_index then
		self.select_index = self.select_index - 1
	elseif index == self.select_index then
		if total_count == 1 then
			self.select_index = 0
			if nil ~= self.select_callback then
				self.select_callback(0)
			end
		else
			self:SelectIndex(1)
		end
	end
	local btn = table.remove(self.toggle_list, index)
	btn:removeFromParent()
end

function RadioButton:DelLastToggle()
	self:DelToggle(#self.toggle_list)
end

function RadioButton:GetCount()
	return #self.toggle_list
end

function RadioButton:Clear()
	self.toggle_list = {}
	self.select_index = 0
end

function RadioButton:GetSelectIndex()
	return self.select_index
end

function RadioButton:SetSelectValidFunc(func)
	self.select_vaild_func = func
end

function RadioButton:SetSelectCallback(callback)
	self.select_callback = callback
end

function RadioButton:SelectVaildFunc(index)
	if nil ~= self.select_vaild_func then
		return self.select_vaild_func(index)
	else
		return true
	end
end

function RadioButton:OnClickCallback(index)
	self:SelectIndex(index)
end

function RadioButton:SelectIndex(index)
	if self:ChangeToIndex(index) and nil ~= self.select_callback then
		self.select_callback(index)
	end
end

function RadioButton:ChangeToIndex(index)
	if nil ~= self.toggle_list[index] then
		self.toggle_list[index]:setTogglePressed(true)
	end
	if self.select_index == index then
		return false
	end

	local total_count = #self.toggle_list
	if index <= 0 or index > total_count then
		return false
	end

	if nil ~= self.toggle_list[self.select_index] then
		self.toggle_list[self.select_index]:setTogglePressed(false)
	end
	self.select_index = index

	return true
end

--设置提醒数量
function RadioButton:SetRemindNum(index, num)
	local radio_btn = self.toggle_list[index]
	if radio_btn == nil then return end
	
	local size = radio_btn:getContentSize()
	local remind_bg_sprite = radio_btn:getChildByTag(123)
	if nil == remind_bg_sprite then
		remind_bg_sprite = XUI.CreateImageView(size.width - 15,size.height - 15, ResPath.GetCommon("remind_bg"), true)
		radio_btn:addChild(remind_bg_sprite, 123, 123)
	end
	if num < 10 then
		remind_bg_sprite:loadTexture(ResPath.GetCommon("remind_bg"), XUI.IS_PLIST)
	else
		remind_bg_sprite:loadTexture(ResPath.GetCommon("remind_bg2"), XUI.IS_PLIST)
	end
	local remind_txt = radio_btn:getChildByTag(321)
	if nil == remind_txt then
		remind_txt = XUI.CreateText(size.width - 15, size.height - 15, 36, 20, cc.TEXT_ALIGNMENT_CENTER, "", COMMON_CONSTS.FONT, 18, COLOR3B.WHITE)
		remind_txt:setPosition(size.width - 15, size.height - 15)
		radio_btn:addChild(remind_txt, 321, 321)
	end
	if num > 99 then num = 99 end
	remind_txt:setString(tostring(num))
	remind_bg_sprite:setVisible(0 ~= num)
	remind_txt:setVisible(0 ~= num)
end