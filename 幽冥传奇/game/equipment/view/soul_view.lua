local MoldingSoulView = BaseClass(SubView)

function MoldingSoulView:__init()
	self.texture_path_list[1] = 'res/xui/equipment.png'
    self.config_tab = {
		{"equipment_ui_cfg", 4, {0}},
	}
	self.is_bullet_window = false
end

function MoldingSoulView:__delete()
end

function MoldingSoulView:LoadCallBack(index, loaded_times)
	local ph = self.ph_list.ph_soul_select
	self.select_soul_index = 1
	self.link_eff = {}
	self.soul_cell_list = {}
	for i = 1, 10 do
		ph = self.ph_list["ph_soul_" .. i]
		local cell = self:CreateSoulCell(ph, i, false)	
		cell:SetShowTips(false)
		table.insert(self.soul_cell_list, cell)
		self:SetLinkEff(i)
	end
	self:CreateNumberBar()
	self:CreatePowerNumEffect()
	local ph = self.ph_list.ph_soul_cur_attr
	self.cur_soul_attr = ListView.New()
	self.cur_soul_attr:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, AttrTextRender, nil, nil, self.ph_list.ph_soul_attr_item)
	self.cur_soul_attr:SetItemsInterval(2)
	self.cur_soul_attr:SetMargin(2)
	self.node_t_list.layout_eq_soul.node:addChild(self.cur_soul_attr:GetView(), 50)

	ph = self.ph_list.ph_soul_next_attr
	self.next_soul_attr = ListView.New()
	self.next_soul_attr:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, AttrTextRender, nil, nil, self.ph_list.ph_soul_attr_item)
	self.next_soul_attr:SetItemsInterval(2)
	self.next_soul_attr:SetMargin(2)
	self.node_t_list.layout_eq_soul.node:addChild(self.next_soul_attr:GetView(), 50)

    self.txt_get_soul_stuff = RichTextUtil.CreateLinkText(Language.Equipment.GetProp, 20, COLOR3B.GREEN)
    local posx, posy = self.node_t_list.layout_eq_soul.img_soul_stone.node:getPosition()
	self.txt_get_soul_stuff:setPosition(posx, posy-30)
	self.node_t_list.layout_eq_soul.node:addChild(self.txt_get_soul_stuff, 20)
	
	self.node_t_list.btn_soul_upgrade.node:setTitleFontSize(22)
	self.node_t_list.btn_soul_upgrade.node:setTitleText(Language.Equipment.UpGradeBtnTxt[1])
	XUI.AddClickEventListener(self.node_t_list.btn_soul_upgrade.node, BindTool.Bind(self.OnClickSoulUpgrade, self))
	XUI.AddClickEventListener(self.node_t_list.btn_soul_upgrade_1key.node, BindTool.Bind(self.OnClickSoulOnekeyUp, self))
	XUI.AddClickEventListener(self.txt_get_soul_stuff, BindTool.Bind(self.OnClickGetSoulStuff, self), true)
	self.btn_effec = RenderUnit.CreateEffect(23, self.node_t_list.btn_soul_upgrade.node, 10)
	self.btn_effec:setVisible(false)
	self.btn_effec_1key = RenderUnit.CreateEffect(23, self.node_t_list.btn_soul_upgrade_1key.node, 10)
	self.btn_effec_1key:setVisible(false)


	EventProxy.New(MoldingSoulData.Instance, self):AddEventListener(MoldingSoulData.EQUIP_SOUL_INFO, BindTool.Bind(self.OnEquipSoulInfo, self))
	EventProxy.New(MoldingSoulData.Instance, self):AddEventListener(MoldingSoulData.SOUL_UP_GRADE, BindTool.Bind(self.OnSoulUpGrade, self))
	EventProxy.New(MoldingSoulData.Instance, self):AddEventListener(MoldingSoulData.SOUL_UP_DEFEATED, BindTool.Bind(self.OnSoulUpDefeated, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	self:BindGlobalEvent(MoldingSoulData.SOUL_1KEY_UP_SUCCED, BindTool.Bind(self.OnOneKeySucc,self))
	self.is_soul_up = true
	MoldingSoulCtrl.SendMsStrengthenInfoReq()
end

function MoldingSoulView:CloseCallBack(...)
end

function MoldingSoulView:ReleaseCallBack()
	for k, v in pairs(self.soul_cell_list or {}) do
		v:DeleteMe()
	end
	self.soul_cell_list = nil

    if self.cur_soul_attr then
        self.cur_soul_attr:DeleteMe()
        self.cur_soul_attr = nil
	end
	
	if self.next_soul_attr then
        self.next_soul_attr:DeleteMe()
        self.next_soul_attr = nil
	end

	if self.soul_num then
		self.soul_num:DeleteMe()
		self.soul_num = nil
	end	

	self.play_eff = nil
	self.power_effect = nil
	self.max_lv_text = nil
	self.is_bullet_window = nil
end


function MoldingSoulView:OnOneKeySucc()
	self:SetShowPlayEff(17, 480, 300)
end

function MoldingSoulView:CreateNumberBar()
	if nil == self.soul_num then
		local ph = self.ph_list.ph_soul_num
		self.soul_num = NumberBar.New()
		self.soul_num:SetRootPath(ResPath.GetCommon("num_121_"))
		self.soul_num:SetPosition(ph.x, ph.y)
		self.soul_num:SetGravity(NumberBarGravity.Left)
		self.node_t_list.layout_eq_soul.node:addChild(self.soul_num:GetView(), 300, 300)
	end
end

function MoldingSoulView:CreateSoulCell(ph, index, show_tip)
	local cell = MoldingSoulView.EqSoulItem.New()
	cell:SetAnchorPoint(0.5, 0.5)
	cell:SetIndex(index)
	cell:SetUiConfig(ph, true)
	cell:SetPosition(ph.x, ph.y)
	cell:SetShowTips(show_tip)
	self.node_t_list.layout_eq_soul.node:addChild(cell:GetView(), 100)
	return cell
end

function MoldingSoulView:CreatePowerNumEffect()
	if nil == self.power_effect then
		self.power_effect = RenderUnit.CreateEffect(21, self.node_t_list.layout_eq_soul.node, 22)
	end
	local ph = self.ph_list.ph_soul_num
	self.power_effect:setPosition(ph.x + 15, ph.y + 20)
end


function MoldingSoulView:OnClickSoulCell(cell)
	self.soul_cell_list[self.select_soul_index]:SetSelect(false)
	self.select_soul_index = cell:GetIndex()
	cell:SetSelect(true)
	self:FlushSoulAttrView()
	self:FlushSoulConsume()
end

function MoldingSoulView:OnFlush(param_t)
end

function MoldingSoulView:OnEquipSoulInfo()
	self:FlushAllSoulCell()
	self:FlushSoulAttrView()
	self:FlushSoulConsume()
	self:BtnRemindEffecShow()
end

function MoldingSoulView:SetLinkEff(index)
	if nil == self.link_eff[index] then
		self.link_eff[index]  = RenderUnit.CreateEffect(11, self.node_t_list.layout_eq_soul.node, 50)
	end
	local ph_1 = self.ph_list["ph_soul_" .. index]
	local next_index = index + 1 > 10 and 1 or index + 1
	local ph_2 = self.ph_list["ph_soul_" .. next_index]
	self.link_eff[index]:setPosition((ph_1.x + ph_2.x) / 2, (ph_1.y + ph_2.y) / 2)
	local d_x = ph_1.x - ph_2.x
	local d_y = ph_1.y - ph_2.y
	local angle = math.atan2(d_x, d_y) * 180 / math.pi
	self.link_eff[index]:setRotation(angle - 90)
	self.link_eff[index]:setVisible(false)
end

function MoldingSoulView:SetLinkLineAction(index)
	local ph_1 = self.ph_list["ph_soul_" .. index]
	local next_index = index + 1 > 10 and 1 or index + 1
	local ph_2 = self.ph_list["ph_soul_" .. next_index]

	self.link_eff[index]:setScaleX(0.1)
	self.link_eff[index]:setPosition(ph_1.x, ph_1.y)
	self.link_eff[index]:setVisible(true)

	local scaleX = cc.ScaleTo:create(0.8, 1, 1)
	local move_to =cc.MoveTo:create(0.8, cc.p((ph_1.x + ph_2.x) / 2,  (ph_1.y + ph_2.y) / 2))
	local spawn = cc.Spawn:create(scaleX, move_to)
	return spawn
end

function MoldingSoulView:OnSoulUpGrade()
	local action = self:SetLinkLineAction(self.select_soul_index)
	local callback = cc.CallFunc:create(function ()
		self.select_soul_index = MoldingSoulData.Instance:GetSoulCurSlot()
		cell = self.soul_cell_list[self.select_soul_index]
		self:OnClickSoulCell(cell)
		self:SetShowPlayEff(17, 480, 300)
		self:FlushAllSoulCell()
		self.is_soul_up = true
	end)
	local sequence = cc.Sequence:create(action, callback)
	self.link_eff[self.select_soul_index]:runAction(sequence)
	self:BtnRemindEffecShow()
end

function MoldingSoulView:OnSoulUpDefeated()
	self.is_soul_up = true
end

function MoldingSoulView:OnBagItemChange(event)
	local item_id = -1
	local consume_id = 3480
	local select_data = self.soul_cell_list[self.select_soul_index]:GetData()
	if not select_data then return end
	local cfg = MoldingSoulData.Instance.GetMoldingSoulConsume(self.select_soul_index, select_data.soul_level + 1)
	if cfg then
		consume_id = cfg.id
	end
	local is_flush = false
	if event.GetChangeDataList then
		for i,v in ipairs(event:GetChangeDataList()) do
			if v.data and v.data.item_id == consume_id and self.soul_cell_list then
				is_flush = true
				break
			end
		end
	end
	if is_flush then
		self:FlushSoulConsume()
		self:BtnRemindEffecShow()
	end
end

function MoldingSoulView:FlushSoulConsume()
	local select_data = self.soul_cell_list[self.select_soul_index]:GetData()
	local cfg = MoldingSoulData.Instance.GetMoldingSoulConsume(self.select_soul_index, select_data.soul_level + 1)
	if cfg then
        self.node_t_list.btn_soul_upgrade.node:setVisible(true)
        self.node_t_list.btn_soul_upgrade_1key.node:setVisible(true)
		local has_count = BagData.Instance:GetItemNumInBagById(cfg.id)
		local soul_stone_txt = string.format(Language.Equipment.StrengthPropNum, has_count >= cfg.count and COLORSTR.GREEN or COLORSTR.RED, has_count, cfg.count) 
		RichTextUtil.ParseRichText(self.node_t_list.rich_soul_stone.node, soul_stone_txt, 18)

		self.node_t_list.layout_eq_soul.img_soul_stone.node:loadTexture(ResPath.GetItem(cfg.id))
		self.node_t_list.layout_eq_soul.img_soul_stone.node:setScale(0.35)

		self.is_bullet_window = has_count < cfg.count
	else
		if self.max_lv_text == nil then
			local btn_x, btn_y = self.node_t_list.btn_soul_upgrade.node:getPosition()
			self.max_lv_text = XUI.CreateText(btn_x+100, btn_y, 0, 0, nil, Language.Common.AlreadyTopLv, "", 22, COLOR3B.G_W2)
			self.max_lv_text:setAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_eq_soul.node:addChild(self.max_lv_text, 999)
		end
        self.node_t_list.btn_soul_upgrade.node:setVisible(false)
        self.node_t_list.btn_soul_upgrade_1key.node:setVisible(false)
        self.node_t_list.rich_soul_stone.node:setVisible(false)
    end
end

function MoldingSoulView:FlushSoulAttrView()
	local select_data = self.soul_cell_list[self.select_soul_index]:GetData()
    local attr_data = MoldingSoulData.Instance:GetSoulAttr(self.select_soul_index, select_data.soul_level)
	local n_attr_data = MoldingSoulData.Instance:GetSoulAttr(self.select_soul_index, select_data.soul_level + 1)
	local next_attr = {{type_str = Language.Common.MaxLv,},}
	if n_attr_data then 
		table.sort(n_attr_data, function(a, b)
			return a.type < b.type
		end)
		next_attr = RoleData.FormatRoleAttrStr(n_attr_data)
	end
	local cur_attr = RoleData.FormatRoleAttrStr(attr_data)

	table.sort(cur_attr, function(a, b)
		return a.type < b.type
	end)
    self.cur_soul_attr:SetDataList(cur_attr)
	self.next_soul_attr:SetDataList(next_attr)
	self.soul_num:SetNumber(CommonDataManager.GetAttrSetScore(attr_data))
end

function MoldingSoulView:FlushAllSoulCell()
	self.select_soul_index = MoldingSoulData.Instance:GetSoulCurSlot()
    for i, v in ipairs(MoldingSoulData.Instance:GetEqSoulShowData()) do
        self.soul_cell_list[i]:SetData(v)
        self.soul_cell_list[i]:ShowUpLevel(self.select_soul_index)
        if i == self.select_soul_index then
			self.soul_cell_list[i]:SetSelect(true)
		else
			self.soul_cell_list[i]:SetSelect(false)
        end
	end
	for i,v in ipairs(self.link_eff) do
		v:setVisible(self.select_soul_index > i)
	end
end

function MoldingSoulView:SetShowPlayEff(eff_id, x, y)
	if self.play_eff == nil then
		self.play_eff = AnimateSprite:create()
		self.node_t_list.layout_eq_soul.node:addChild(self.play_eff, 999)
	end
	self.play_eff:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(eff_id)
	self.play_eff:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

function MoldingSoulView:BtnRemindEffecShow()
	local num = MoldingSoulData.Instance:GetCanMoldingSoulNum()
	self.btn_effec:setVisible(num>0)
	self.btn_effec_1key:setVisible(num>0)
end

function MoldingSoulView:OnClickSoulUpgrade()
	if self.is_bullet_window then
		self:OnClickGetSoulStuff()
	elseif self.select_soul_index and self.is_soul_up then
		MoldingSoulCtrl.Instance.SendMsStrengthen()
		self.is_soul_up = false
	end
end

function MoldingSoulView:OnClickSoulOnekeyUp()
	if self.is_bullet_window then
		self:OnClickGetSoulStuff()
	else
		MoldingSoulCtrl.OneKeyMoldingSoulReq()
	end
end

function MoldingSoulView:OnClickGetSoulStuff()
	TipCtrl.Instance:OpenBuyTip(EquipmentData.Instance:GetAdvStuffWayConfig()[EquipmentData.TabIndex.equipment_molding_soul][1])
end


MoldingSoulView.EqSoulItem = BaseClass(BaseRender)
local EqSoulItem = MoldingSoulView.EqSoulItem
function EqSoulItem:__delete()
end

function EqSoulItem:CreateChild()
	BaseRender.CreateChild(self)
	
	local size = self.view:getContentSize()
	self.eq_soul_bg = XImage:create()
	self.eq_soul_bg:setAnchorPoint(0.5, 0.5)
	self.eq_soul_bg:setPosition(size.width / 2, size.height / 2)
	self.view:addChild(self.eq_soul_bg)

	self.soul_lv_text = XUI.CreateText(60, 65, 0, 0, nil, "", nil, 18, COLOR3B.YELLOW)
	self.soul_lv_text:setAnchorPoint(1, 1)
	self.view:addChild(self.soul_lv_text, 50)

	self.has_up_effect = RenderUnit.CreateEffect(10, self.view, 999)
	self.has_up_effect:setPosition(size.width / 2, size.height / 2)
	self.has_up_effect:setVisible(false)
	-- self.has_up_effect:setScale(0.8)
end

function EqSoulItem:SetShowTips(is_show)
	if self.cell then
		self.cell:SetEventEnabled(is_show)
		self.cell:SetIsShowTips(is_show)
	end
end

-- local quality = {[0] = "normal", "normal", "refine", "perfect"}
function EqSoulItem:OnFlush()
	if not self.data then
		return
    end
	
	self.eq_soul_bg:loadTexture(ResPath.GetEquipment("molding_soul_" .. self.index))
	self.soul_lv_text:setString(self.data.soul_level)
end

function EqSoulItem:ShowUpLevel(index)
	self.has_up_effect:setVisible(self.index < index)
end

-- 创建选中特效
function EqSoulItem:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = RenderUnit.CreateEffect(7, self.view, 999)
	self.select_effect:setPosition(size.width / 2, size.height / 2)
	self.select_effect:setScale(0.5)
end

return MoldingSoulView