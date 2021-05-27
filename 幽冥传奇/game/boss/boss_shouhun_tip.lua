-- BOSS兽魂tips
BossShouHunTip = BossShouHunTip or BaseClass(XuiBaseView)

function BossShouHunTip:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self:InitViewVal()
end

function BossShouHunTip:__delete()
end

function BossShouHunTip:ReleaseCallBack()
end

function BossShouHunTip:LoadCallBack()
	self.big_bg = XUI.CreateImageViewScale9(0, 0, 0, 0, ResPath.GetCommon("img9_121"), true)
	self.root_node:addChild(self.big_bg, 1)

	self.layout_content = XUI.CreateLayout(0, 0, 0, 0)
	self.layout_content:setAnchorPoint(cc.p(0, 0))
	self.root_node:addChild(self.layout_content, 2)
end

function BossShouHunTip:OnFlush(param_t, index)
	if self.layout_content == nil then return end
	self:ShowContent()

	self.layout_content:setContentWH(self.total_width, self.total_heigh)
	self.root_node:setContentWH(self.total_width, self.total_heigh)
	self.big_bg:setContentWH(self.total_width, self.total_heigh)
	self.big_bg:setPosition(self.total_width * 0.5,  self.total_heigh * 0.5)
	self.layout_content:setPosition(0, 0)
end

function BossShouHunTip:OpenCallBack()
end

function BossShouHunTip:CloseCallBack()
end

function BossShouHunTip:InitViewVal()
	self.total_width = 350
	self.total_heigh = 0

	self.index = 0
	self.shouhun_data = 0
end

function BossShouHunTip:SetData(index, data)
	self:InitViewVal()
	self.index = index
	self.shouhun_data = data

	self:Flush()
end

function BossShouHunTip:CreateText(text, x, y, w, h, size, color, h_alignment)
	x = x or 18
	y = y or 0
	w = w or 180
	h = h or 0
	h_alignment = h_alignment or cc.TEXT_ALIGNMENT_LEFT
	self.total_heigh = self.total_heigh + h

	local text = XUI.CreateText(x, self.total_heigh, w, 0, h_alignment, text, nil, size, color)
	text:setAnchorPoint(0, 1)
	self.layout_content:addChild(text, 10)

	return text
end

function BossShouHunTip:CreateLine()
	self.total_heigh = self.total_heigh + 10
	local line = XImage:create(ResPath.GetCommon("line_101"), true)
	line:setAnchorPoint(0, 0.5)
	line:setPosition(15, self.total_heigh)
	self.layout_content:addChild(line, 10)
	self.total_heigh = self.total_heigh + 10 
end

function BossShouHunTip:ShowContent()
	self.layout_content:removeAllChildren()
	local attr_cfg = BossData.GetAttr(self.index, self.shouhun_data.shouhun_level)
	if attr_cfg ~= nil then
		local val_tab = RoleData.FormatRoleAttrStr(attr_cfg)
		for i = #val_tab, 1, -1 do
			self:CreateText(val_tab[i].type_str .. "：", nil, nil, 140, 30, 21, COLOR3B.OLIVE, cc.TEXT_ALIGNMENT_LEFT)
			self:CreateText(val_tab[i].value_str, 160, nil, nil, 0, 21, COLOR3B.GREEN, cc.TEXT_ALIGNMENT_LEFT)
		end
		self.total_heigh = self.total_heigh + 10
	else
		self.total_heigh = self.total_heigh + 20
	end
	local txt = string.format(Language.Boss.AttributeName[self.index], self.shouhun_data.shouhun_level)
	self:CreateText(txt, 100, nil, nil, 30, 24, COLOR3B.OLIVE)
	self.total_heigh = self.total_heigh + 10
end