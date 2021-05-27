local AdvancedLevelYuansuView  = BaseClass(SubView)

function AdvancedLevelYuansuView:__init()
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
		{"advance_ui_cfg", 3, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
		--{"common_ui_cfg", 3, {0}},
	}
	-- self.btn_info = {ViewDef.Advanced.Moshu,ViewDef.Advanced.YuanSu, ViewDef.Advanced.ShengShou}

	-- require("scripts/game/advanced_level/advanced_level_moshu_view").New(ViewDef.Advanced.Moshu)
end

function AdvancedLevelYuansuView:__delete()
	-- body
end

function AdvancedLevelYuansuView:ReleaseCallBack()
	if self.equip_cell then
		for k, v in pairs(self.equip_cell) do
			v:DeleteMe()
		end
		self.equip_cell = {}
	end
	if self.consume_cell then
		self.consume_cell:DeleteMe()
		self.consume_cell = nil
	end
	if self.cur_attr_list then
		self.cur_attr_list:DeleteMe()
		self.cur_attr_list = nil
	end

	if self.skill_cell then
		self.skill_cell:DeleteMe()
		self.skill_cell = nil
	end

	if self.main_effect then
		self.main_effect:setStop()
		self.main_effect = nil 
	end

	if self.effect_list then
		for k, v in pairs(self.effect_list) do
			v:setStop()
		end
		self.effect_list = {}
	end
	if self.once_effect then
		self.once_effect:setStop()
		self.once_effect = nil 
	end
end

function AdvancedLevelYuansuView:LoadCallBack()
	self:CreateEquipCells()
	self:CreateConsumeCell()
	self:CreateAttrList()
	self:CreateEffEct()
	self.select_index = 1
	self.select_data = nil
	XUI.AddClickEventListener(self.node_t_list.btn_xiulian.node, BindTool.Bind1(self.OnUpYuansu, self), true)
	self.yuansu_change = GlobalEventSystem:Bind(JINJIE_EVENT.YUSU_UP_CHANGE, BindTool.Bind1(self.OnYuansuChange,self))

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function AdvancedLevelYuansuView:OnYuansuChange(slot, slot_level)
	local data = {}
	data.index = slot 
	data.level = slot_level
	local cell = self.equip_cell[slot]
	if cell then
		cell:SetData(data)
	end
	self:FlushSkillShow()
	self:FlushAttrShow()
	self:FlushConsumeShow()
	self:CreateUpEffect(slot)
end

function AdvancedLevelYuansuView:CreateUpEffect(slot)
	if self.once_effect  == nil then
		self.once_effect = AnimateSprite:create()
		self.node_t_list.layout_yuansu.node:addChild(self.once_effect, 999)
	end

	local ph = self.ph_list["ph_cell_"..slot]
	self.once_effect:setPosition(ph.x + 35, ph.y + 50)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1204)
	self.once_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function AdvancedLevelYuansuView:ItemDataListChangeCallback( ... )
	self:SetAllData()
	self:FlushConsumeShow()
end

function AdvancedLevelYuansuView:CreateConsumeCell()
	if nil == self.consume_cell then
		local ph = self.ph_list.ph_yuansu_consume_cell
		self.consume_cell = BaseCell.New()
		self.consume_cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_yuansu.node:addChild(self.consume_cell:GetView(), 99)
	end

	if nil == self.skill_cell then
		local ph = self.ph_list.ph_skill

		self.skill_cell = BaseCell.New()
		self.skill_cell.SetAddClickEventListener = function() end
		self.skill_cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_yuansu.node:addChild(self.skill_cell:GetView(), 99)
	end
end


function AdvancedLevelYuansuView:CreateEffEct( ... )
	if self.main_effect  == nil then
		self.main_effect = AnimateSprite:create()
		local ph = self.ph_list.ph_cell_7 
		self.main_effect:setPosition(ph.x + 48, ph.y + 38)
		self.node_t_list.layout_yuansu.node:addChild(self.main_effect, 99)

		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1203)
		self.main_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end

end


function AdvancedLevelYuansuView:OnUpYuansu()
	if self.select_data then
		local level = AdvancedLevelData.Instance:GetYuanSuSingleData(self.select_data.index) or 0
		local consume = AdvancedLevelData.Instance:GetConsumeBySlotAndLevel(self.select_data.index, level + 1)
		if consume == nil then
			SysMsgCtrl.Instance:FloatingTopRightText(Language.Advanced.TipsMaxShow)
			return
		end
		local num = BagData.Instance:GetItemNumInBagById(consume.id)
		if num >= consume.count then
			AdvancedLevelCtrl.SendUpCrestSlotReq(self.select_data.index)
		else
			TipCtrl.Instance:OpenGetNewStuffTip(consume.id, 1)
		end
	end
end

function AdvancedLevelYuansuView:CreateAttrList()
	if nil == self.cur_attr_list then
		local ph = self.ph_list.ph_base_attr1--获取区间列表
		self.cur_attr_list = ListView.New()
		self.cur_attr_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, ShuLingAttrItem, nil, nil, self.ph_list.ph_item_yuansu)
		self.cur_attr_list:SetItemsInterval(5)--格子间距
		self.cur_attr_list:SetJumpDirection(ListView.Top)--置顶
		self.node_t_list.layout_attr1.node:addChild(self.cur_attr_list:GetView(), 20)

		self.cur_attr_list:GetView():setAnchorPoint(0, 0)
	end
end

function AdvancedLevelYuansuView:OpenCallBack()
	-- body
end



function AdvancedLevelYuansuView:ShowIndexCallBack(index)
	self:Flush(index)
end

function AdvancedLevelYuansuView:CloseCallBack()
	-- body
end

function AdvancedLevelYuansuView:OnFlush()
	self:SetAllData()
	if self.select_index and self.equip_cell[self.select_index] then
		self.equip_cell[self.select_index]:SetSelect(true)
		self:OnClickEquipCell(self.equip_cell[self.select_index])
	end
	self:FlushSkillShow()
end

function AdvancedLevelYuansuView:CreateEquipCells()
	self.equip_cell = {}
	for i = 1,6 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = self:CreateCellRender(i, ph, cur_data)
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
		table.insert(self.equip_cell, cell)
	end
end

function AdvancedLevelYuansuView:CreateCellRender(i, ph, cur_data)
	local cell = YuansuCellRender.New()
	local render_ph = self.ph_list.ph_item_render 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	self.node_t_list["layout_yuansu"].node:addChild(cell:GetView(), 101)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end


function AdvancedLevelYuansuView:OnClickEquipCell(cell)
	if cell == nil or cell:GetData() == nil then 
		return
	end
	cell:SetSelect(true)
	if self.select_index and self.equip_cell[self.select_index] 
	 and  self.select_index ~= cell:GetIndex() then
		self.equip_cell[self.select_index]:SetSelect(false)
	end
	self.select_index = cell:GetIndex()
	self.select_data = cell:GetData()
	self:FlushConsumeShow()
	self:FlushAttrShow()
end


function AdvancedLevelYuansuView:FlushConsumeShow()
	if self.select_data == nil then
		return 
	end
	local level = AdvancedLevelData.Instance:GetYuanSuSingleData(self.select_data.index) or 0
	local consume = AdvancedLevelData.Instance:GetConsumeBySlotAndLevel(self.select_data.index, level + 1)
	if consume then
		self.consume_cell:SetData({item_id = consume.id, num = 1, is_bind = 0})

		local num = BagData.Instance:GetItemNumInBagById(consume.id)
		local color = num >= consume.count and COLOR3B.GREEN or COLOR3B.RED 
		local text = num .. "/".. consume.count

		self.consume_cell:SetRightBottomText(text,color)
	end
end


function AdvancedLevelYuansuView:FlushAttrShow()
	if self.select_data == nil then
		return
	end
	local all_attr = AdvancedLevelData.Instance:GetCurAllAttr()

	local all_attr_list = RoleData.FormatRoleAttrStr(all_attr)

	local level = AdvancedLevelData.Instance:GetYuanSuSingleData(self.select_data.index) or 0
	local next_attr = AdvancedLevelData.Instance:GetAttrBySlot(self.select_data.index, level + 1)

	local cur_attr = AdvancedLevelData.Instance:GetAttrBySlot(self.select_data.index, level)
	local add_attr = CommonDataManager.LerpAttributeAttr(cur_attr, next_attr)
	local add_attr_list  = RoleData.FormatRoleAttrStr(add_attr)
	
	for k, v in pairs(all_attr_list) do
		v.next_value_str = ""
		for k1, v1 in pairs(add_attr_list) do
			if v1.type == v.type  and v1.value > 0 then
				v.next_value_str = v1.value_str
			end
		end
	end
	self.cur_attr_list:SetDataList(all_attr_list)
end


function AdvancedLevelYuansuView:SetAllData()
	for k, v in pairs(self.equip_cell) do
		local data = {}
		data.index = k
		data.level = AdvancedLevelData.Instance:GetYuanSuSingleData(k)
		v:SetData(data)
	end
end


function AdvancedLevelYuansuView:FlushSkillShow()
	local skill_data = AdvancedLevelData.Instance:GetSkillLevelAndSkillId()
	local bool = true
	if next(skill_data) == nil then
		skill_data = AdvancedLevelData.Instance:GetCfgSkillLevel(1)
		bool = false
	end
	local skill_cfg  = SkillData.GetSkillLvCfg(skill_data.skillid, skill_data.skilllv)
	local name = skill_cfg.name or "烈焰火球"
	local desc = skill_cfg.desc 
	self.node_t_list.text_name.node:setString(name .."Lv."..skill_data.skilllv)
	local path = ResPath.GetSkillIcon(SkillData.Instance:GetSkillIconId(skill_data.skillid))
	self.skill_cell:SetItemIcon(path)
	RichTextUtil.ParseRichText(self.node_t_list.rich_text_desc.node, desc, 16)

	local skill_level = bool and skill_data.skilllv + 1 or skill_data.skilllv

	local config = AdvancedLevelData.Instance:GetCfgSkillLevel(skill_level)
	local text = string.format(Language.Advanced.TipsShow, config.level)

	self.node_t_list.text_condition.node:setString(text)
end

YuansuCellRender = YuansuCellRender or BaseClass(BaseRender)
function YuansuCellRender:__init()
	-- body
end

function YuansuCellRender:__delete()
	if self.effect_show then
		self.effect_show:setStop()
		self.effect_show = nil 
	end
end

function YuansuCellRender:CreateChild()
	BaseRender.CreateChild(self)
	self.node_tree.img_red.node:setVisible(false)
	if self.effect_show == nil then
		local ph = self.ph_list.ph_effect
	-- 	local ph = self.ph_list["ph_cell_"..i]
		self.effect_show = AnimateSprite:create()
		self.effect_show:setPosition(ph.x, ph.y )
		self.view:addChild(self.effect_show, 99)
	end
	
end

function YuansuCellRender:OnFlush()
	if self.data == nil then
		return
	end
	self.node_tree.text_step.node:setString(self.data.level .. "阶")
	local vis = AdvancedLevelData.Instance:GetSingleCanUp(self.data.index, self.data.level + 1)
	self.node_tree.img_red.node:setVisible(vis)
	self.node_tree.img_bg1.node:loadTexture(ResPath.GetJinJiePath("yuansu_bg_".. self.data.index))
	self.node_tree.text_step.node:setLocalZOrder(999)
	self.node_tree.img_red.node:setLocalZOrder(999)

	--狗策划叫美术出的特效不一致，需对齐，调节位置
	local ph = self.ph_list.ph_effect
	if self.index == 1 then
		self.effect_show:setPosition(ph.x + 18, ph.y + 22 )
	elseif self.index == 2 then
		self.effect_show:setPosition(ph.x + 9, ph.y + 6)
	elseif self.index == 3 then
		self.effect_show:setPosition(ph.x+ 4, ph.y + 4)
	elseif self.index == 4 then
		self.effect_show:setPosition(ph.x + 9, ph.y + 11)
	elseif self.index == 5 then
		self.effect_show:setPosition(ph.x+14, ph.y + 5)
	elseif self.index == 6 then
		self.effect_show:setPosition(ph.x + 10, ph.y + 15)
	end

	if self.effect_show then
		local effect_id = AdvancedLevelData.EffectList[self.data.index] 
		local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
		self.effect_show:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	end
end

function YuansuCellRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2, size.height / 2, ResPath.GetJinJiePath("yuansu_select"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end

return AdvancedLevelYuansuView