local ReXueGodZhanShenPanel = BaseClass(SubView)

function ReXueGodZhanShenPanel:__init( ... )
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 2, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
	
end


function ReXueGodZhanShenPanel:__delete( ... )
	-- body
end

function ReXueGodZhanShenPanel:ReleaseCallBack( ... )
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
	if self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil
	end

	if self.bag_cell then
		self.bag_cell:DeleteMe()
		self.bag_cell = nil
	end

	if self.preview_cell then
		self.preview_cell:DeleteMe()
		self.preview_cell = nil
	end
end

function ReXueGodZhanShenPanel:LoadCallBack( ... )
	ReXueGodZhanShenPanel_EquipPos =   {
		{equip_slot = EquipData.EquipSlot.itGodWarHelmetPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itGodWarNecklacePos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itGodWarLeftBraceletPos, cell_pos = 3, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 衣战神_左手镯
		{equip_slot = EquipData.EquipSlot.itGodWarRightBraceletPos, cell_pos = 4, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 战神_右手镯
		{equip_slot = EquipData.EquipSlot.itGodWarLeftRingPos, cell_pos = 5, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 战神_左戒指
		{equip_slot = EquipData.EquipSlot.itGodWarRightRingPos, cell_pos = 6, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 战神_右戒指
		{equip_slot = EquipData.EquipSlot.itGodWarGirdlePos, cell_pos =7,cell_img = ResPath.GetEquipImg("cs_bg_7")},	-- 战神_腰带
		{equip_slot = EquipData.EquipSlot.itGodWarShoesPos,  cell_pos =8,cell_img = ResPath.GetEquipImg("cs_bg_8")},	-- 战神_鞋子 52
		
	}

	self.select_equip_pos = EquipData.EquipSlot.itGodWarHelmetPos
	self:CreateRoleDisplay()
	self:CreateCell()
	self:CreateShowCell()
	XUI.AddClickEventListener(self.node_t_list.btn_zhanshen_tip.node, BindTool.Bind1(self.OpenTips, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_compose_zhanshen.node, BindTool.Bind1(self.OnCompoeData, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_suit_tip2.node, BindTool.Bind1(self.OpenReXueSuitTip, self), true)


	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function ReXueGodZhanShenPanel:OpenReXueSuitTip( ... )
	ReXueGodEquipCtrl.Instance:OpenTipView(12)
end

function ReXueGodZhanShenPanel:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.ZhanShenGodEquipContent, Language.DescTip.ZhenShenGodEquipTitle)
end

function ReXueGodZhanShenPanel:CreateRoleDisplay( ... )
	if nil == self.role_display then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_zhanshen.node, 100, false, false, true, true)
		self.role_display:SetPosition(self.ph_list.ph_model.x + 60, self.ph_list.ph_model.y + 80)
		self.role_display:SetScale(0.8)
	end
	self:UpdateApperance()
end

function ReXueGodZhanShenPanel:UpdateApperance()
	if nil ~= self.role_display then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()

		self.role_display:SetRoleVo(role_vo)
	end
end


function ReXueGodZhanShenPanel:CreateCell( ... )
	self.cell_list = {}
	for k, v in pairs(ReXueGodZhanShenPanel_EquipPos) do
		local cell = ReXueGodZhanShenPanel.ZhanShenEquipCell.New()
		local ph = self.ph_list["ph_item_"..(v.cell_pos)]
		cell:GetView():setPosition(ph.x,ph.y)  
		cell:SetData(v)
		self.node_t_list.layout_zhanshen.node:addChild(cell:GetView(), 99)
		cell:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		self.cell_list[v.equip_slot] = cell
	end

	if self.select_equip_pos and self.cell_list[self.select_equip_pos] then
		--print(">>>>>>>>>>", self.select_equip_pos)
		self.cell_list[self.select_equip_pos]:SetSelect(true)
	end
end

function ReXueGodZhanShenPanel:SelectCellCallBack(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end
	cell:SetSelect(true)
	self.select_data = cell:GetData()
	if self.select_equip_pos and self.cell_list[self.select_equip_pos] and 
		self.select_equip_pos ~= self.select_data.equip_slot then

		self.cell_list[self.select_equip_pos]:SetSelect(false)
	end
	
	self.select_equip_pos = self.select_data.equip_slot

	local equip_data = ReXueGodEquipData.Instance:SetReXueCanBestData(self.select_equip_pos)
	if equip_data ~= nil then
		EquipCtrl.SendFitOutEquip(equip_data.series, EquipData.SLOT_HAND_POS[self.select_equip_pos])
	end
	self:FlushShow()
end

function ReXueGodZhanShenPanel:CreateShowCell( ... )
	if nil == self.equip_cell then
		local ph = self.ph_list.ph_wear_cell 
		self.equip_cell = BaseCell.New()
		self.node_t_list.layout_zhanshen.node:addChild(self.equip_cell:GetView(), 99)
		self.equip_cell:GetView():setPosition(ph.x, ph.y)
	end
	if nil == self.bag_cell then
		local ph = self.ph_list.ph_reward_cell 
		self.bag_cell = BaseCell.New()
		self.node_t_list.layout_zhanshen.node:addChild(self.bag_cell:GetView(), 99)
		self.bag_cell:GetView():setPosition(ph.x, ph.y)
	end

	if nil == self.preview_cell then
		local ph = self.ph_list.ph_preview_cell 
		self.preview_cell = BaseCell.New()
		self.node_t_list.layout_zhanshen.node:addChild(self.preview_cell:GetView(), 99)
		self.preview_cell:GetView():setPosition(ph.x, ph.y)
	end
end

function ReXueGodZhanShenPanel:FlushShow( ... )
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_equip_pos)
	self.equip_cell:SetData(equip_data)
	local config = ReXueGodEquipData.Instance:GetConfiByTypeEquipPos(2, self.select_equip_pos, equip_data and equip_data.item_id )
	local text = ""
	local data = nil
	if config ~= nil then
		data = {item_id = config.itemId, num = 1, is_bind = 0}
		local item_config = ItemData.Instance:GetItemConfig(config.itemId)
		text = item_config.name
	end
	if equip_data == nil then

		data = {item_id = ReXueGodEquipShow[self.select_equip_pos], num =1,is_bind = 0 }
		local item_config = ItemData.Instance:GetItemConfig(data.item_id)
		text = item_config.name
	end
	self.preview_cell:SetData(data)
	self.node_t_list.text_equip_name.node:setString(text)
	local bag_data = nil 
	local con_text = ""
	if config  then
		local num = BagData.Instance:GetItemNumInBagById(config.consume[1].id, nil)
		if num > 0 then
			bag_data = {item_id = config.consume[1].id, num = 1, is_bind = 0}
		end

		con_text = self:FlushComsumeMoney(config.consume)
	end

	if equip_data == nil then
		con_text = "" 
	end
	self.bag_cell:SetData(bag_data)
	RichTextUtil.ParseRichText(self.node_t_list.rich_zhanshen_consume.node, con_text)
	XUI.RichTextSetCenter(self.node_t_list.rich_zhanshen_consume.node)

	local text = "合成"
	if equip_data == nil then
		text = "前往获取"
	end
	self.node_t_list.btn_compose_zhanshen.node:setTitleText(text)
	
end


function ReXueGodZhanShenPanel:FlushComsumeMoney(consume)
	local text = ""
	for k, v in pairs(consume) do
		local item_id = v.id
		local num = BagData.Instance:GetItemNumInBagById(v.id, nil)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local path = ResPath.GetItem(item_cfg.icon)
		if v.type > 0 then
			item_id = tagAwardItemIdDef[v.type]

			num = RoleData.Instance:GetMainMoneyByType(v.type) or 0
			path =  RoleData.GetMoneyTypeIconByAwardType(v.type)
			local color = (num >= v.count) and "00ff00" or "ff0000"
			local is_show_tips = v.type > 0 and 0 or 1
			local scale = v.type > 0 and 1 or 0.5
			text = text .. string.format(Language.Bag.ComposeTip, path,"20,20", scale, v.id, is_show_tips, color, v.count).."   "
		end
		
	end
	return text 
end

function ReXueGodZhanShenPanel:ItemDataListChangeCallback( ... )
	for k, v in pairs(ReXueGodZhanShenPanel_EquipPos) do
		if self.cell_list[v.equip_slot] then
			local cell = self.cell_list[v.equip_slot]
			cell:SetData(v) 
		end
	end
	
	self:FlushShow()
	self:FlushPoint()
end

function ReXueGodZhanShenPanel:OpenCallBack( ... )
	-- body
end

function ReXueGodZhanShenPanel:ShowIndexCallBack( ... )
	self:Flush(index)
end

function ReXueGodZhanShenPanel:OnFlush( ... )
	self:FlushShow()
	self:FlushPoint()
end


function ReXueGodZhanShenPanel:CloseCallBack( ... )
	-- body
end

function ReXueGodZhanShenPanel:FlushPoint( ... )

	--ReXueGodEquipData:GetCanCompose(equip, type, equip_pos)
	for k, v in pairs(ReXueGodZhanShenPanel_EquipPos) do
		local cell = self.cell_list[v.equip_slot]
		if cell then
			local best_data = ReXueGodEquipData.Instance:SetReXueCanBestData(v.equip_slot)
				
			local vis = (best_data ~= nil) and true or false
			if not vis then
				local equip = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
				if equip then  
					vis = ReXueGodEquipData.Instance:GetCanCompose(equip, 2, v.equip_slot)
				end
			end
			cell:FlushRemind(vis)
		end
	end
end


function ReXueGodZhanShenPanel:OnCompoeData(  )
	--if self.select_data ~= nil then
		local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_equip_pos)
		if equip_data == nil then
			ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
			GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 3)
		else
			ReXueGodEquipCtrl.Instance:ReqComspoeEquip(2, self.select_equip_pos)
		end
	--end
end

local ZhanShenEquipCell = BaseClass(BaseRender)
 ReXueGodZhanShenPanel.ZhanShenEquipCell = ZhanShenEquipCell
ZhanShenEquipCell.size = cc.size(92, 98)
function ZhanShenEquipCell:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(ZhanShenEquipCell.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(ZhanShenEquipCell.size.width / 2, ZhanShenEquipCell.size.height - BaseCell.SIZE / 2 -10)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.cell:SetCellBgVis(true)
	
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)
	self.red_image = XUI.CreateImageView(BaseCell.SIZE-15, BaseCell.SIZE -15, ResPath.GetMainUiImg("remind_flag"), true)
	self.red_image:setVisible(false)
	self.cell:GetView():addChild(self.red_image,11)
end

function ZhanShenEquipCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function ZhanShenEquipCell:CreateChild()
	ZhanShenEquipCell.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(ZhanShenEquipCell.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function ZhanShenEquipCell:OnFlush()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot)
	if equip_data then
		self.cell:SetData(equip_data)
	end

	--self.cell:SetRemind(EquipData.Instance:GetChuanShiCanUp(self.data.equip_slot) > 0)

	-- local equip = EquipData.Instance:GetBestCSEquip(equip_data, self.data.equip_slot)
	-- local vis = equip  and true or false
	self.red_image:setVisible(vis)
	if nil == equip_data then
		-- local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(self.data.equip_slot))
		-- if act_cfg then
		-- 	local next_equip_id = act_cfg.targetEquips
		-- 	RichTextUtil.ParseRichText(self.rich_under, ItemData.Instance:GetItemNameRich(next_equip_id))
		-- 	self.cell:SetData({item_id = next_equip_id, num = 1, is_bind = 0})
		-- 	self.cell:SetCfgEffVis(false)
		-- end
		self.cell:SetData(nil)
		self:SetItemIcon(self.data.cell_img)
		--self.cell:MakeGray(true)
		
	else
		self.cell:SetCfgEffVis(true)
	end
	self.cell:SetCellBg(ResPath.GetCommon("cell_101"))
end

function ZhanShenEquipCell:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function ZhanShenEquipCell:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

function ZhanShenEquipCell:SetItemIcon(path)
	if self.cell then
		self.cell:SetItemIcon(path)
	end
end

function ZhanShenEquipCell:CreateSelectEffect()
	self.select_effect = XUI.CreateImageViewScale9(ZhanShenEquipCell.size.width / 2, ZhanShenEquipCell.size.height/2,
		BaseCell.SIZE, BaseCell.SIZE, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.select_effect, 999)
end

function ZhanShenEquipCell:FlushRemind(vis)
	local path = path or ResPath.GetMainui("remind_flag")
	local size = self.view:getContentSize()
	x = size.width -10
	y = size.height - 20
	if vis and nil == self.remind_bg_sprite then		
		self.remind_bg_sprite = XUI.CreateImageView(x, y, path, true)
		self.remind_bg_sprite:setScale(0.6)
		self.view:addChild(self.remind_bg_sprite, 999, 999)
	elseif self.remind_bg_sprite then
		self.remind_bg_sprite:setVisible(vis)
	end
end

return ReXueGodZhanShenPanel