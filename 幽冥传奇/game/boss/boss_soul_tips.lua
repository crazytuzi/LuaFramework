-- BOSS兽魂tips
BossSoulTips = BossSoulTips or BaseClass(XuiBaseView)

function BossSoulTips:__init()
	self:SetModal(true)
	self:SetIsAnyClickClose(true)

	self:InitViewVal()
end

function BossSoulTips:__delete()
end

function BossSoulTips:ReleaseCallBack()
end

function BossSoulTips:LoadCallBack()
	self.big_bg = XUI.CreateImageViewScale9(0, 0, 0, 0, ResPath.GetCommon("img9_121"), true)
	self.root_node:addChild(self.big_bg, 1)

	self.layout_content = XUI.CreateLayout(0, 0, 0, 0)
	self.layout_content:setAnchorPoint(cc.p(0, 0))
	self.root_node:addChild(self.layout_content, 2)
end

function BossSoulTips:OnFlush(param_t, index)
	if self.layout_content == nil then return end
	self:ShowContent()

	self.layout_content:setContentWH(self.total_width, self.total_heigh)
	self.root_node:setContentWH(self.total_width, self.total_heigh)
	self.big_bg:setContentWH(self.total_width, self.total_heigh)
	self.big_bg:setPosition(self.total_width * 0.5,  self.total_heigh * 0.5)
	self.layout_content:setPosition(0, 0)
end

function BossSoulTips:OpenCallBack()
end

function BossSoulTips:CloseCallBack()
end

function BossSoulTips:InitViewVal()
	self.total_width = 350
	self.total_heigh = 0

	self.grade = 0
	self.level = 0
end

function BossSoulTips:SetData(grade, level)
	self:InitViewVal()
	self.grade = grade
	self.level = level

	self:Flush()
end

function BossSoulTips:CreateText(text, x, y, w, h, size, color, h_alignment)
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

function BossSoulTips:CreateLine()
	self.total_heigh = self.total_heigh + 10
	local line = XImage:create(ResPath.GetCommon("line_101"), true)
	line:setAnchorPoint(0, 0.5)
	line:setPosition(15, self.total_heigh)
	self.layout_content:addChild(line, 10)
	self.total_heigh = self.total_heigh + 10 
end

function BossSoulTips:ShowContent()
	self.layout_content:removeAllChildren()

	local data = BossData.GetAttrCfg(self.grade)
	local attr_cfg = data[1]
	if attr_cfg == nil then
		return
	end
	local consume = BossData.Instance:GetShouHunConsumeCfg(self.grade, self.level)
	local txt = Language.Boss.Consume_Jifen
	self:CreateText(txt, 30, nil, nil, 30, 21, COLOR3B.OLIVE)
	self:CreateText(consume, 150, nil, nil, 0, 21, COLOR3B.GREEN)
	
	local val_tab = RoleData.FormatRoleAttrStr(attr_cfg)
	for i = #val_tab, 1, -1 do
		self:CreateText(val_tab[i].type_str .. "：", nil, nil, 110, 30, 21, COLOR3B.OLIVE, cc.TEXT_ALIGNMENT_RIGHT)
		self:CreateText(val_tab[i].value_str, 150, nil, nil, 0, 21, COLOR3B.GREEN)
	end
	self:CreateLine()
	local name = BossData.Instance:SetShouHunName(self.grade, self.level)
	self:CreateText(name, nil, nil, nil, 30, 24, COLOR3B.OLIVE)

	local txt = ""
	local bool_active = false
	local grade = (BossData.Instance:GetShouHunPageData() == 0 and 1) or BossData.Instance:GetShouHunPageData()
	local level = BossData.Instance:GetShouHunHunZhuData()
	if self.grade <= grade then
		if self.level <= level then
			txt = Language.Role.HadActive
			bool_active = true
		else
			txt = Language.Role.NotActive
			bool_active = false
		end
	else
		txt = Language.Role.NotActive
		bool_active = false
	end

	local text = self:CreateText("["..txt.."]", 200, nil, nil, 0, 24, COLOR3B.GREEN)
	text:setColor(bool_active and COLOR3B.GREEN or COLOR3B.RED )
	self.total_heigh = self.total_heigh + 20
end
