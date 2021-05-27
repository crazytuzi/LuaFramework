local AdvancedLevelShengShouView  = BaseClass(SubView)

function AdvancedLevelShengShouView:__init()
	-- self.title_img_path = ResPath.GetWord("title_jinjie")
	-- self:SetModal(true)
	-- self.texture_path_list = {
		
	-- }
	self:SetModal(true)
	self.texture_path_list = {
		'res/xui/role.png',
		'res/xui/advanced_level.png',
		'res/xui/bag.png',
	}
	self.config_tab = {
		{"advance_ui_cfg", 4, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
		--{"common_ui_cfg", 3, {0}},
	}

	-- self.btn_info = {ViewDef.Advanced.Moshu,ViewDef.Advanced.YuanSu, ViewDef.Advanced.ShengShou}

	-- require("scripts/game/advanced_level/advanced_level_moshu_view").New(ViewDef.Advanced.Moshu)
end

function AdvancedLevelShengShouView:ReleaseCallBack()
	if self.sheng_shou_list then
		self.sheng_shou_list:DeleteMe()
		self.sheng_shou_list = nil
	end
	if self.item_cell then
		for k, v in pairs(self.item_cell) do
			v:DeleteMe()
		end
		self.item_cell = {}
	end 
end

function AdvancedLevelShengShouView:__delete()
	-- body
end

function AdvancedLevelShengShouView:LoadCallBack()

	XUI.AddClickEventListener(self.node_t_list.btn_up_shenshou.node, BindTool.Bind1(self.OnUpLevel, self), true)

	self:CreateEquipCells()
	self.shengshou_event = GlobalEventSystem:Bind(JINJIE_EVENT.SHENGSHOU_UP_ENENT, BindTool.Bind1(self.OnChangeEvent,self))
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
end


function AdvancedLevelShengShouView:CreateEquipCells()
	self.item_cell = {}
	for i = 1,4 do
		local ph = self.ph_list["ph_grid_list"..i]
		local cell = self:CreateCellRender(i, ph, cur_data)
		cell:SetIndex(i)
		--cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
		table.insert(self.item_cell, cell)
	end
end

function AdvancedLevelShengShouView:CreateCellRender(i, ph, cur_data)
	local cell = ShengShouRender.New()
	local render_ph = self.ph_list.ph_grid_list_item 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	self.node_t_list["layout_sheng_shou"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end

function AdvancedLevelShengShouView:OnChangeEvent()
	self:FlushData()
	self:FlushConsume()
end

function AdvancedLevelShengShouView:ShowIndexCallBack( ... )
	self:Flush(index)
end


function AdvancedLevelShengShouView:OpenCallBack()
	-- body
end

function AdvancedLevelShengShouView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_ENERGY then
		self:FlushConsume()
	end
end

function AdvancedLevelShengShouView:CloseCallBack()
	-- body
end

function AdvancedLevelShengShouView:OnFlush()
	self:FlushData()
	self:FlushConsume()
end

function AdvancedLevelShengShouView:FlushData()
	local data = AdvancedLevelData.Instance:GetLevelListShow()
	for k, v in pairs(self.item_cell) do
		v:SetData(data[k])
	end
	for k, v in pairs(self.item_cell) do
		v:SetSelect(false)
	end
	local index = AdvancedLevelData.Instance:GetSelectIndex()
	if self.item_cell[index] then
		self.item_cell[index]:SetSelect(true)
	end
end

function AdvancedLevelShengShouView:FlushConsume()
	local level = AdvancedLevelData.Instance:GetCurLevel()
	-- body
	local consume =  AdvancedLevelData.Instance:GetConsumeBylevel(level + 1)
	if consume == nil then
		self.node_t_list.prog9_progress1.node:setPercent(100)
		self.node_t_list.lbl_shou_prog.node:setString("")
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_2.node, "")
		RichTextUtil.ParseRichText(self.node_t_list.fich_text_1.node, "")
	else

		local consume_count = consume[1].count
		local had_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ENERGY)
		local text = had_num.."/"..consume_count
		local color = had_num >= consume_count and COLOR3B.GREEN or COLOR3B.RED
		self.node_t_list.lbl_shou_prog.node:setString(text)
		self.node_t_list.lbl_shou_prog.node:setColor(color)
		local percent = had_num/consume_count > 1 and 100 or had_num/consume_count * 100
		self.node_t_list.prog9_progress1.node:setPercent(percent)

		local index = AdvancedLevelData.Instance:GetSelectIndex()
		local name = Language.Advanced.ShenshouName[index] 

		local data = self.item_cell[index]:GetData()
		local level = data.level 
		local step, star = AdvancedLevelData.Instance:CanGetStepByLevel(data.level)
		local text3 = string.format(Language.Advanced.ShenshouTips, name, step, star)
		RichTextUtil.ParseRichText(self.node_t_list.rich_text_2.node,  Language.Advanced.ShenshouTips2)
		RichTextUtil.ParseRichText(self.node_t_list.fich_text_1.node,  text3)
		XUI.RichTextSetCenter(self.node_t_list.rich_text_2.node)
		XUI.RichTextSetCenter(self.node_t_list.fich_text_1.node)
	
	end

end

function AdvancedLevelShengShouView:OnUpLevel()

	 local level = AdvancedLevelData.Instance:GetCurLevel()
	 -- body
	 local consume =  AdvancedLevelData.Instance:GetConsumeBylevel(level + 1)
	 if consume == nil then
	 	SysMsgCtrl.Instance:FloatingTopRightText(Language.Common.MaxLvTips)
	 else
		local consume_count = consume[1].count
		local had_num = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_ENERGY)
		if had_num >= consume_count then
			 AdvancedLevelCtrl.Instance:SendMeridiansReq(2)
		else
			TipCtrl.Instance:OpenGetStuffTip(479)
		end
	 end
end


ShengShouRender = ShengShouRender or BaseClass(BaseRender)
function ShengShouRender:__init()
	
end

function ShengShouRender:__delete( ... )
	-- body
end

function ShengShouRender:CreateChild( ... )
	BaseRender.CreateChild(self)
	self.star_list = {}
	local ph = self.ph_list.ph_star
	for i = 1, 10 do
		local star  =  XUI.CreateImageView(ph.x +5 + (i-1)*20, ph.y + 15, ResPath.GetCommon("star_1_lock"), true)
		star:setScale(0.8)
		self.view:addChild(star, 999)
		self.star_list[i] = star
	end
end

function ShengShouRender:OnFlush()
	if self.data == nil then
		return
	end
	local path = ResPath.GetBigPainting("advance_level_shenshou".. self.data.index, false)
	self.node_tree.img_bg1.node:loadTexture(path)
	local step, star = AdvancedLevelData.Instance:CanGetStepByLevel(self.data.level)
	local path1 = ResPath.GetCommon("daxie_"..step)
	if step == 10 then
		path1 = ResPath.GetCommon("daxie_"..0)
	end
	self.node_tree.img_jie1.node:loadTexture(path1)
	for k, v in pairs(self.star_list) do
		if star >= k then
			v:loadTexture(ResPath.GetCommon("star_1_select"))
		else
			v:loadTexture(ResPath.GetCommon("star_1_lock"))
		end
	end
	local attr = AdvancedLevelData.Instance:GetCurAttrListByIndex(self.data.index)

	local attr_content_list =  RoleData.FormatRoleAttrStr(attr)

	local text = ""
	for k, v in pairs(attr_content_list) do
		text = text .. (v.type_str) ..":"..(v.value_str ).. "\n"
	end
	RichTextUtil.ParseRichText(self.node_tree.rich_text.node, text)
	XUI.RichTextSetCenter(self.node_tree.rich_text.node)
end

function ShengShouRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetBigPainting("img_select_painting", false), false)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

return AdvancedLevelShengShouView