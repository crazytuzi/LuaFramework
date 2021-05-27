HoroscopeView = HoroscopeView or BaseClass(SubView)

function HoroscopeView:__init()
	self.is_model =true
	self:SetBackRenderTexture(true)
	
	self.texture_path_list = {
		'res/xui/horoscope.png',
	}
	self.config_tab = {
		
		{"horoscope_ui_cfg", 1, {0}},
		{"horoscope_ui_cfg", 3, {0}},
		{"horoscope_ui_cfg", 6, {0}},
		{"horoscope_ui_cfg", 9, {0}},
	}
	self.need_del_objs = {}
	self.fight_power_view = nil
	self.cell_list = {}
	self.effect_show1 = nil
	-- self:GetConstellationDataList(function(data)
	-- HoroscopeData.Instance:GetConstellationData(data.equip_slot)
	-- end)
	-- require("scripts/game/role/horoscope/slot_strengthen_view").New(ViewDef.Role.Horoscope.SlotStrengthen)
	-- require("scripts/game/role/horoscope/collection_view").New(ViewDef.Role.Horoscope.Collection)
end

function HoroscopeView:__delete()
	self.cell_list = {}
end

function HoroscopeView:LoadCallBack()
	self.fight_power_view = FightPowerView.New(136, 35, self.node_t_list.layout_fighting_power.node, 99)
	self.need_del_objs[#self.need_del_objs + 1] = self.fight_power_view
	XUI.AddClickEventListener(self.node_t_list.btn_1.node, BindTool.Bind(self.OnBtnClick, self))
	XUI.AddClickEventListener(self.node_t_list.btn_collection.node, BindTool.Bind(self.OnCollectionClick, self))
	XUI.AddClickEventListener(self.node_t_list.img_suit_tip_show.node, BindTool.Bind(self.OpenTipsView, self))
	EventProxy.New(HoroscopeData.Instance, self):AddEventListener(HoroscopeData.CONSTELLATION_DATA_CHANGE, BindTool.Bind(self.EquipDataChange, self))
	EventProxy.New(HoroscopeData.Instance, self):AddEventListener(HoroscopeData.SLOT_STRENGTHEN_DATA_CHANGE, BindTool.Bind(self.OtherationDataChage, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OtherationDataChage, self))
	self:CreateHoroscope()
	self:CreateAttrList()
	if nil == self.effect_show1 then
		local ph = self.ph_list.ph_effEct
		self.effect_show1 = AnimateSprite:create()
		self.effect_show1:setPosition(ph.x + 25, ph.y + 25)
		 self.node_t_list.layout_horoscope.node:addChild(self.effect_show1,99)
	end
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(1127)
	self.effect_show1:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)

	XUI.AddClickEventListener(self.node_t_list.img_xinghun_tip100.node, BindTool.Bind(self.OnOpenXingHunTip, self))

	local ph_duihuan = self.ph_list["ph_text_1"]
	local text = RichTextUtil.CreateLinkText(Language.ZhuanSheng.Buy, 19, COLOR3B.GREEN)
	text:setPosition(ph_duihuan.x, ph_duihuan.y)
	self.node_t_list.layout_tujing1.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnBtnGo, self, 1), true)
	
	local ph_buy = self.ph_list["ph_text_2"]
	local text = RichTextUtil.CreateLinkText(Language.Compose.StuffSourceAction[2], 19, COLOR3B.GREEN)
	text:setPosition(ph_buy.x, ph_buy.y)
	self.node_t_list.layout_tujing1.node:addChild(text, 90)
	XUI.AddClickEventListener(text, BindTool.Bind(self.OnGoExplore, self, 1), true)
end

function HoroscopeView:OnBtnGo()
	ViewManager.Instance:OpenViewByDef(ViewDef.NewlyBossView.Rare.XhBoss)
	ViewManager.Instance:CloseViewByDef(ViewDef.Horoscope)
end

function HoroscopeView:OnGoExplore( ... )
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
end

function HoroscopeView:OnOpenXingHunTip( ... )
	DescTip.Instance:SetContent(Language.DescTip.XinghunContent2, Language.DescTip.XinghunTitle2)
end

function HoroscopeView:OpenTipsView()
	ViewManager.Instance:OpenViewByDef(ViewDef.XingHUnSuitTip)
end


function HoroscopeView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}

	if self.cell_list then

		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.attr_list then
		self.attr_list:DeleteMe()
		self.attr_list = nil 
	end

	if self.effect_show1 then
		self.effect_show1:setStop()
		self.effect_show1 = nil 
	end
end

function HoroscopeView:ShowIndexCallBack()
	self:Flush()
end


function HoroscopeView:OnFlush()
	self:FlushPowerValueView(false)
end

-- 创建星盘视图
function HoroscopeView:CreateHoroscope()
	for i = 0, 11 do
		--	local ph = self.ph_list["ph_cell_" .. i + 1 ]
		-- local x = ph.x
		-- local y = ph.y
		-- local cell = BaseCell.New() --RoleInfoView.EquipCell.New()
		-- cell:SetPosition(x, y)
		-- cell:GetView():setAnchorPoint(0.5, 0.5)
		-- local bg = ResPath.Horoscope("cell_bg")
		-- local bg_ta = ResPath.Horoscope("constellatory_bg_" .. i + 1 )
		-- cell:SetSkinStyle({ bg = bg, bg_ta = bg_ta })
		-- --cell:SetGetEquipDataFunc(BindTool.Bind(self.GetConstellationDataList, self))
		-- --cell:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		-- cell:SetCfgEffVis(false)
		-- XUI.AddClickEventListener(cell:GetView(), BindTool.Bind(self.SelectCellCallBack, self, cell))
		-- HoroscopeData.Instance:GetConstellationData(i)

		-- cell:SetData(HoroscopeData.Instance:GetConstellationData(i))
		-- cell:SetIndex(i)
		-- self.need_del_objs[#self.need_del_objs + 1] = cell
		-- self.node_t_list.layout_horoscope.node:addChild(cell:GetView(), 99)

		local ph = self.ph_list["ph_cell_" .. i + 1 ]
		local cell = self:CreateCellRender(i, ph, cur_data)
		cell:SetIndex(i)
		cell:AddClickEventListener(BindTool.Bind1(self.OnClickEquipCell, self), true)
		-- table.insert(self.equip_cell, cell)
		
		self.cell_list[i] = cell
	end
	self:ConstellationDataChage()
end

function HoroscopeView:CreateCellRender(i, ph, cur_data)
	local cell = XingHunCellRender.New()
	local render_ph = self.ph_list.ph_item_render 
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x+3, ph.y-1)
	cell:GetView():setAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_horoscope.node:addChild(cell:GetView(), 99)
	if cur_data then
		cell:SetData(cur_data)
	end
	return cell
end



function HoroscopeView:OnClickEquipCell(cell)
	local slot = cell:GetIndex()
	local data = cell:GetData()
	local is_best, max_best = HoroscopeData.Instance:GetBestEquip(slot, data)
	if is_best then
		if max_best then
			HoroscopeCtrl.PutOnConstellation(max_best.series)
		end
	else
		TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_HOROSCOPE, {horoscope_slot = slot})
	end
end

-- 刷新战力值视图
function HoroscopeView:FlushPowerValueView(bool)
	--local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	--local attrs_data = LevelData.Instance:GetAttrTypeValueFormat(level)
	--
	---- 如果配置为空,战力显示为0
	--if nil == attrs_data then
	--	 self.power_view:SetNumber(0)
	--	 return
	--end
	--
	
	local data = HoroscopeData.Instance:GetAllConstellationData()
	local attr = {}
	for k, v in pairs(data) do
		local config = ItemData.Instance:GetItemConfig(v.item_id)
		local strength_data =	HoroscopeData.Instance:GetSlotInfoDataList(config.stype)
		local strength_cfg = HoroscopeData.GetSlotAttrCfg(config.stype)
		local attrs = strength_data and strength_cfg[strength_data.level] and strength_cfg[strength_data.level].attrs or {}
		local attr1 = CommonDataManager.AddAttr(attrs, config.staitcAttrs)
		attr = CommonDataManager.AddAttr(attr, attr1) 
	end

	local suit_level = HoroscopeData.Instance:GetSuitId()
	local suit_config = SuitPlusConfig[8].list[suit_level]
	if suit_config then
		attr = CommonDataManager.AddAttr(attr, suit_config.attrs)
	end

	local power_value = CommonDataManager.GetAttrSetScore(attr)
	self.fight_power_view:SetNumber(power_value)

	local attr_list = RoleData.FormatRoleAttrStr(attr, is_range, prof_ignore)
	for k, v in pairs(attr_list) do
		v.is_show = bool
	end
	if #attr_list > 0 then
		self.attr_list:SetDataList(attr_list)
	else
		local client_attr = {
			{type = 9, value = 0},
			{type = 11, value = 0},
			{type = 21, value = 0},
			{type = 23, value = 0},
		}
		local attr_list = RoleData.FormatRoleAttrStr(client_attr, is_range, prof_ignore)
		for k,v in pairs(attr_list) do
			v.is_show = false
		end
		self.attr_list:SetDataList(attr_list) 
	end
	--self.node_t_list.text_show.node:setVisible(#attr_list <= 0)
	self:SetStrenthRed()
end

function HoroscopeView:OnBtnClick()
	ViewManager.Instance:OpenViewByDef(ViewDef.Horoscope.SlotStrengthen)
	--ViewManager.Instance:CloseViewByDef(ViewDef.Role.Horoscope)
end

function HoroscopeView:OnCollectionClick()
	if ViewManager.Instance:CanOpen(ViewDef.Horoscope.Collection) then
		ViewManager.Instance:OpenViewByDef(ViewDef.Horoscope.Collection)
	else
		local text = GameCond[ViewDef.Horoscope.Collection.v_open_cond].Tip
		SysMsgCtrl.Instance:FloatingTopRightText(text)
	end

	-- ViewManager.Instance:CloseViewByDef(ViewDef.Role.Horoscope)
end

function HoroscopeView:ConstellationDataChage()
	for k, v in pairs(self.cell_list) do
		-- print(HoroscopeData.Instance:GetConstellationData(k)
		v:SetData(HoroscopeData.Instance:GetConstellationData(k))
	end

end

function HoroscopeView:EquipDataChange(data)
	-- if self.cell_list[data.index] then
	--		self.cell_list[data.index]:SetData(HoroscopeData.Instance:GetConstellationData(data.index))
	-- end
	self:ConstellationDataChage()
	self:FlushPowerValueView(true)
end

function HoroscopeView:OtherationDataChage(data)

	self:ConstellationDataChage()
	 self:FlushPowerValueView(false)
end

function HoroscopeView:SlotStrengthenDataChange()
	self:Flush()
end


function HoroscopeView:SetStrenthRed( ... )
	local vis = HoroscopeData.Instance:GetIsCanStrenth()
	self.node_t_list.img_qianghua_red.node:setVisible(vis)

	local vis1 = HoroscopeData.Instance:GetShowPointRed()
	self.node_t_list.img_shouhu_red.node:setVisible(vis1)
end

function HoroscopeView:CreateAttrList()
	if self.attr_list == nil then
		self.attr_list = ListView.New()
		local ph = self.ph_list.ph_base_attr
		self.attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, HoroscopeAttrItem, nil, nil, self.ph_list.ph_role_attr_item4)
		self.node_t_list.layout_attr.node:addChild(self.attr_list:GetView(),1)
		self.attr_list:GetView():setAnchorPoint(0.5, 0.5)
		self.attr_list:SetItemsInterval(6)
		self.attr_list:SetDataList(self.zhu_attr)
		self.attr_list:JumpToTop(true)
	end
end

HoroscopeAttrItem =	HoroscopeAttrItem or BaseClass(BaseRender)
function HoroscopeAttrItem:__init()

end

function HoroscopeAttrItem:__delete()
	-- body
end

function HoroscopeAttrItem:CreateChild()
	BaseRender.CreateChild(self)
end

function HoroscopeAttrItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str.."：")
	self.node_tree.lbl_attr_value.node:setString(self.data.value_str)
	if self.data.is_show then
		if nil == self.select_effect then
			local size = self.node_tree.img9_bg.node:getContentSize()
			self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width, size.height, ResPath.GetCommon("img9_292"), true)
			self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
			self.select_effect:setOpacity(0)
		end

		local fade_out = cc.FadeTo:create(0.2, 140)
		local fade_in = cc.FadeTo:create(0.3, 80)
		local fade_in2 = cc.FadeTo:create(0.2, 0)
		local action = cc.Sequence:create(fade_out, fade_in, fade_out, fade_in2)
		self.select_effect:runAction(action)
	end
end

XingHunCellRender = XingHunCellRender or BaseClass(BaseRender)
function XingHunCellRender:__init( ... )
	-- body
end

function XingHunCellRender:__delete()
	-- body
end

function XingHunCellRender:CreateChild()
	BaseRender.CreateChild(self)
end

function XingHunCellRender:OnFlush( )
	self:Clear()
	if self.data == nil then 
		return
	end
	self.node_tree.img_bg1.node:setVisible(false)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local icon = ResPath.GetItem(item_cfg.icon)
	self.node_tree.img_icon.node:setVisible(true)
	self.node_tree.img_icon.node:loadTexture(icon)
	
end

function XingHunCellRender:Clear()
	local is_best = HoroscopeData.Instance:GetBestEquip(self.index, self.data)
	self.node_tree.img_red.node:setVisible(is_best)
	self.node_tree.text_strength_level.node:setString("")
	self.node_tree.img_icon.node:setVisible(false)
	self.node_tree.img_bg1.node:setVisible(true)
	self.node_tree.img_bg1.node:loadTexture(ResPath.Horoscope("constellatory_bg_" .. self.index + 1))

	local strenth_data =	HoroscopeData.Instance:GetSlotInfoDataList(self.index) or {}
	local text =	(strenth_data and strenth_data.level or 0) > 0 and "+"..(strenth_data and strenth_data.level or "") or ""
	self.node_tree.text_strength_level.node:setString(text)
end

HoroscopeCell = HoroscopeCell or BaseClass(BaseCell)
function HoroscopeCell:CreateChild()
	local ui_config = { bg = ResPath.Horoscope("cell_bg"),
						bg_ta = ResPath.Horoscope("constellatory_bg_" .. self.index + 1)}
	self:SetSkinStyle(ui_config)
	self:SetIsShowTips(false)
	self:SetCfgEffVis(false)
end

return HoroscopeView
