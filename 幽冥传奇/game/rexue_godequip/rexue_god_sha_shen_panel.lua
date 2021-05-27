local  ReXueGodShaShenPanel = BaseClass(SubView)

function ReXueGodShaShenPanel:__init( ... )

	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.config_tab = {
		--{"common_ui_cfg", 1, {0}},
		{"rexue_god_equip_ui_cfg", 3, {0}},
		--{"common_ui_cfg", 2, {0}, nil, 999},
	}
end


function ReXueGodShaShenPanel:__delete( ... )
	-- body
end

function ReXueGodShaShenPanel:ReleaseCallBack( ... )
	if self.sha_shen_equip_cell then
		self.sha_shen_equip_cell:DeleteMe()
		self.sha_shen_equip_cell = nil
	end

	if self.sha_shen_bag_cell then
		self.sha_shen_bag_cell:DeleteMe()
		self.sha_shen_bag_cell = nil
	end

	if self.sha_shen_preview_cell then
		self.sha_shen_preview_cell:DeleteMe()
		self.sha_shen_preview_cell = nil
	end
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
end

function ReXueGodShaShenPanel:LoadCallBack( ... )

	ReXueGodShaShenPanel_EquipPos =   {
		{equip_slot = EquipData.EquipSlot.itKillArrayShaPos, cell_pos = 1, cell_img = ResPath.GetEquipImg("41")},	-- 战神_头盔	45
		{equip_slot = EquipData.EquipSlot.itKillArrayMostPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("42")},	-- 战神_项链
		{equip_slot = EquipData.EquipSlot.itKillArrayRobberyPos, cell_pos = 3, cell_img = ResPath.GetEquipImg("43")},	-- 衣战神_左手镯
		{equip_slot = EquipData.EquipSlot.itKillArrayLifePos, cell_pos = 4, cell_img = ResPath.GetEquipImg("44")},	-- 战神_右手镯
		
	}
	self.select_equip_pos = EquipData.EquipSlot.itKillArrayShaPos
	self:CreateCell()
	self:CreateCellList()
	self.select_data = nil
	XUI.AddClickEventListener(self.node_t_list.btn_sha_shen_tip.node, BindTool.Bind1(self.OpenTips, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_compose_shashen.node, BindTool.Bind1(self.OnCompoundData, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_suit_tip3.node, BindTool.Bind1(self.OpenShaShenSuitTip, self), true)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

function ReXueGodShaShenPanel:OpenShaShenSuitTip( ... )
	ReXueGodEquipCtrl.Instance:OpenTipView(13)
end

function ReXueGodShaShenPanel:CreateCell()
	if nil == self.sha_shen_equip_cell then
		local ph = self.ph_list.ph_wear_cell1 
		self.sha_shen_equip_cell = BaseCell.New()
		self.node_t_list.layout_shazhen.node:addChild(self.sha_shen_equip_cell:GetView(), 99)
		self.sha_shen_equip_cell:GetView():setPosition(ph.x, ph.y)
	end
	if nil == self.sha_shen_bag_cell then
		local ph = self.ph_list.ph_reward_cell2 
		self.sha_shen_bag_cell = BaseCell.New()
		self.node_t_list.layout_shazhen.node:addChild(self.sha_shen_bag_cell:GetView(), 99)
		self.sha_shen_bag_cell:GetView():setPosition(ph.x, ph.y)
	end

	if nil == self.sha_shen_preview_cell then
		local ph = self.ph_list.ph_preview_cell3
		self.sha_shen_preview_cell = BaseCell.New()
		self.node_t_list.layout_shazhen.node:addChild(self.sha_shen_preview_cell:GetView(), 99)
		self.sha_shen_preview_cell:GetView():setPosition(ph.x, ph.y)
	end
end


function ReXueGodShaShenPanel:CreateCellList( ... )
	self.cell_list = {}
	for k, v in pairs(ReXueGodShaShenPanel_EquipPos) do
		local cell = ReXueGodShaShenPanel.ShaShenEquipCell.New()
		local ph = self.ph_list["equip_cell"..(v.cell_pos)]
		cell:GetView():setPosition(ph.x,ph.y)  
		cell:SetData(v)
		self.node_t_list.layout_shazhen.node:addChild(cell:GetView(), 99)
		cell:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		self.cell_list[v.equip_slot] = cell
	end

	if self.select_equip_pos and self.cell_list[self.select_equip_pos] then
		self.cell_list[self.select_equip_pos]:SetSelect(true)
	end
end

function ReXueGodShaShenPanel:SelectCellCallBack(cell)
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
	self:FlushShaShenShow()
end


function ReXueGodShaShenPanel:OpenTips( ... )
	DescTip.Instance:SetContent(Language.DescTip.ShaShenGodEquipContent, Language.DescTip.SHaShenGodEquipTitle)
end

function ReXueGodShaShenPanel:OnCompoundData( ... )
	--if self.select_data ~= nil then
		local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_equip_pos)
		if equip_data == nil then
			ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView.RexueGodEquipDuiHuan)
			GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 3)
		else

			ReXueGodEquipCtrl.Instance:ReqComspoeEquip(1, self.select_equip_pos)
		end
	--end
end


function ReXueGodShaShenPanel:ShowIndexCallBack( ... )
	self:Flush(index)
end

function ReXueGodShaShenPanel:OpenCallBack( ... )
	-- body
end

function ReXueGodShaShenPanel:OnFlush( ... )
	self:FlushShaShenShow()
	if self.select_equip_pos and self.cell_list[self.select_equip_pos] then
		self.cell_list[self.select_equip_pos]:SetSelect(true)
	end
	self:FlushShaShenPoint()
end


function ReXueGodShaShenPanel:CloseCallBack( ... )
	-- body
end

function ReXueGodShaShenPanel:FlushShaShenShow()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_equip_pos)
	self.sha_shen_equip_cell:SetData(equip_data)
	local config = ReXueGodEquipData.Instance:GetConfiByTypeEquipPos(1, self.select_equip_pos, equip_data and equip_data.item_id )
	local pre_data = {}
	if config ~= nil then
		pre_data = {item_id = config.itemId, num = 1, is_bind = 0}
		
	end
	local data = nil 
	local text = ""
	local name= ""
	if config  then
		local num = BagData.Instance:GetItemNumInBagById(config.consume[2].id, nil)
		if num > 0 then
			data = {item_id = config.consume[2].id, num = 1, is_bind = 0}
		end
		local item_config = ItemData.Instance:GetItemConfig(config.itemId)
		name = item_config.name
		text = self:FlushComsumeMoney(config.consume)
	end

	if equip_data == nil then

		pre_data = {item_id = ReXueGodEquipShow[self.select_equip_pos], num =1,is_bind = 0 }
		local item_config = ItemData.Instance:GetItemConfig(pre_data.item_id)
		name = item_config.name
		text = ""
	end
	self.sha_shen_preview_cell:SetData(pre_data)
	self.node_t_list.rich_sha_shen_name.node:setString(name)
	self.sha_shen_bag_cell:SetData(data)

	RichTextUtil.ParseRichText(self.node_t_list.rich_shashen_consume.node, text)
	XUI.RichTextSetCenter(self.node_t_list.rich_shashen_consume.node)

	local btn_text = "合成"
	if equip_data == nil then
		btn_text = "前往获取"
	end
	self.node_t_list.btn_compose_shashen.node:setTitleText(btn_text)
	
end


function ReXueGodShaShenPanel:FlushComsumeMoney(consume)
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

function ReXueGodShaShenPanel:ItemDataListChangeCallback( ... )
	for k, v in pairs(ReXueGodShaShenPanel_EquipPos) do
		if self.cell_list[v.equip_slot] then
			local cell = self.cell_list[v.equip_slot]
			cell:SetData(v) 
		end
	end
	
	self:FlushShaShenShow()
	self:FlushShaShenPoint()
end


function ReXueGodShaShenPanel:FlushShaShenPoint( ... )

	--ReXueGodEquipData:GetCanCompose(equip, type, equip_pos)
	for k, v in pairs(ReXueGodShaShenPanel_EquipPos) do
		local cell = self.cell_list[v.equip_slot]
		if cell then
			local best_data = ReXueGodEquipData.Instance:SetReXueCanBestData(v.equip_slot)
				
			local vis = (best_data ~= nil) and true or false
			if not vis then
				local equip = EquipData.Instance:GetEquipDataBySolt(v.equip_slot)
				if equip then  
					vis = ReXueGodEquipData.Instance:GetCanCompose(equip, 1, v.equip_slot)
				end
			end
			cell:FlushRemind(vis)
		end
	end
end


local ShaShenEquipCell = BaseClass(BaseRender)
 ReXueGodShaShenPanel.ShaShenEquipCell = ShaShenEquipCell
ShaShenEquipCell.size = cc.size(92, 98)
function ShaShenEquipCell:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(ShaShenEquipCell.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(ShaShenEquipCell.size.width / 2, ShaShenEquipCell.size.height - BaseCell.SIZE / 2 -10)
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

function ShaShenEquipCell:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function ShaShenEquipCell:CreateChild()
	ShaShenEquipCell.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(ShaShenEquipCell.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function ShaShenEquipCell:OnFlush()
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

function ShaShenEquipCell:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function ShaShenEquipCell:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

function ShaShenEquipCell:SetItemIcon(path)
	if self.cell then
		self.cell:SetItemIcon(path)
	end
end

function ShaShenEquipCell:CreateSelectEffect()
	self.select_effect = XUI.CreateImageViewScale9(ShaShenEquipCell.size.width / 2, ShaShenEquipCell.size.height/2,
		BaseCell.SIZE, BaseCell.SIZE, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.select_effect, 999)
end

function ShaShenEquipCell:FlushRemind(vis)
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

return ReXueGodShaShenPanel