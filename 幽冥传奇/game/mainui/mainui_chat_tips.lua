----------------------------------------------------
-- 主ui小部件（提示图标）
----------------------------------------------------
MainuiChat = MainuiChat or BaseClass()

function MainuiChat:InitTips()
	self.tip_icon_list = {}
	self.mt_layout_tip = nil
	-- self.tip_y = 150
	self.tip_y = 240
	self.record_show_menu = show_menu
end

function MainuiChat:DeleteTips()
	for k,v in pairs(self.tip_icon_list) do
		v:DeleteMe()
	end
	self.tip_icon_list = nil
end

function MainuiChat:InitTipsUi(mt_layout_root)
	-- 加一层做动画
	-- self.mt_layout_tip_bg = MainuiMultiLayout.CreateMultiLayout(500, self.tip_y, cc.p(0, 0), cc.size(400, 32), mt_layout_root)
	self.mt_layout_tip_bg = MainuiMultiLayout.CreateMultiLayout(450, self.tip_y, cc.p(0, 0), cc.size(400, 32), mt_layout_root)

	self.mt_layout_tip = MainuiMultiLayout.CreateMultiLayout(0, 0, cc.p(0, 0), cc.size(400, 32), self.mt_layout_tip_bg)
	-- 为了固定图标位置距离中心点的位置 ghf add at 20191227
	self.tip_icon_base_x = self.mt_layout_tip:TextureLayout():convertToNodeSpace(cc.p(HandleRenderUnit:GetWidth()*0.5,0)).x-130
end

function MainuiChat:SetTipsUiVisible(value)
	if self.mt_layout_tip then
		self.mt_layout_tip:setVisible(value)
	end
end

function MainuiChat:UpdateAllTipIconPos(x, y)
	if nil ~= self.mt_layout_tip then
		if self.tip_x ~= x or self.tip_y ~= y then
			self.tip_x = x
			self.tip_y = y
			self.mt_layout_tip:stopAllActions()
			self:ChangeTipShowState(self.record_show_menu)
		end
	end
end

function MainuiChat:ChangeTipShowState(show_menu)
	self.record_show_menu = show_menu
	self.mt_layout_tip_bg:setVisible(not show_menu)
	self.mt_layout_tip_bg:MoveTo(PLAY_TIME, self.tip_x, self.tip_y)
end

-- 添加tip图标
function MainuiChat:AddTipIcon(tip_type, callback, num, param, effect_id, anim_pos, repetition_num)
	if repetition_num == nil then
		repetition_num = num > 0 and 1 or 0
	end
	local tip_list = self:GetTipIconList(tip_type)
	local icon = nil
	effect_id = effect_id or 3053
	if repetition_num > #tip_list then
		icon = MainUiIcon.New(60, 60)
		icon:Create(self.mt_layout_tip)
		icon:SetIconPath(ResPath.GetMainui("tip_"..tip_type))
		-- icon:PlayIconEffect(effect_id, anim_pos or {x = 23, y = 21})
		table.insert(self.tip_icon_list, icon)
	else
		for k,v in pairs(tip_list) do
			if nil == icon then
				icon = v
			end
			if not v:IsVisible() then
				icon = v
				break
			end
		end
	end
	if nil ~= icon then
		icon:SetVisible(true)
		local data = {tip_type = tip_type, callback = callback, tip_index = #self.tip_icon_list, param = param}
		icon:SetData(data)
		icon:SetRemindNumTxt(num)
		icon:AddClickEventListener(BindTool.Bind2(self.ClickTipIconHandler, self, icon))
	end	
	self:UpdateTipIconPos()
	return icon
end

-- 移除tips图标
function MainuiChat:RemoveTipIcon(tip_type)
	local icon_list = self:GetTipIconList(tip_type)
	for k,v in pairs(icon_list) do
		if nil ~= v then
			v:SetVisible(false)			
		end
	end
	self:UpdateTipIconPos()
end

function MainuiChat:RemoveTipIconByIconObj(icon)
	for k,v in pairs(self.tip_icon_list) do
		if v == icon then
			icon:SetVisible(false)
			self:UpdateTipIconPos()
			return
		end
	end
end

function MainuiChat:GetTipIcon(tip_type)
	for k,v in pairs(self.tip_icon_list) do
		if v:GetData() and v:GetData().tip_type == tip_type then
			return v
		end
	end
	return nil
end

function MainuiChat:GetTipIconList(tip_type)
	local icon_list = {}
	for k,v in pairs(self.tip_icon_list) do
		if v:GetData() and v:GetData().tip_type == tip_type then
			table.insert(icon_list, v)
		end
	end
	return icon_list
end

function MainuiChat:GetTipIconByIndex(tip_index)
	for k, v in pairs(self.tip_icon_list) do
		if v:GetData() and v:GetData().tip_index == tip_index then
			return v
		end
	end
	return nil
end

function MainuiChat:UpdateTipIconPos()
	local index = 1
	for i, v in ipairs(self.tip_icon_list) do
		if v:IsVisible() then
			-- v:SetPosition(index * 66 - 80, 50)
			-- v:SetPosition(index * 66 + 120, 15-100)
			v:SetPosition(self.tip_icon_base_x +index * 66, 15-100)
			index = index + 1
		end
	end
end

function MainuiChat:ClickTipIconHandler(icon)
	if IS_ON_CROSSSERVER then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OnCrossServerTip)
		return 
	end
	local data = icon:GetData()
	if nil ~= data and nil ~= data.callback then
		data.callback(icon)
	end
end
