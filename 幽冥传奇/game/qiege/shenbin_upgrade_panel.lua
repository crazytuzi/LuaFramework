ShenBinUpgradePanel = ShenBinUpgradePanel or BaseClass(BaseView)

function ShenBinUpgradePanel:__init()
	self.is_any_click_close = true		
	self.texture_path_list = {
		'res/xui/qiege.png',
		
		}	
	self.config_tab = {
		{"qiege_ui_cfg", 3, {0}},
		
	}
	self.data = nil
end

function ShenBinUpgradePanel:__delete( ... )
	-- body
end

function ShenBinUpgradePanel:LoadCallBack(loaded_times, index)
	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind1(self.UpgradeShenBin, self), true)
	-- self.link_stuff = RichTextUtil.CreateLinkText("领取材料", 20, COLOR3B.GREEN)
	-- self.link_stuff:setPosition(500, 70)
	-- self.node_t_list.layout_upgrade.node:addChild(self.link_stuff, 99)
	-- XUI.AddClickEventListener(self.link_stuff, function()
	-- 		ViewManager.Instance:OpenViewByDef(ViewDef.QieGeView.QieGe)
	-- 		ViewManager.Instance:CloseViewByDef(ViewDef.QieGeUpgrade)
	-- 		GlobalEventSystem:Fire(OPEN_VIEW_EVENT.OpenEvent, 1)
	-- end, true)

	self.wapon_level_change = GlobalEventSystem:Bind(QIEGE_EVENT.QieGeShenBinUp, BindTool.Bind1(self.FlushView, self))

	self:CreateCell()
end

function ShenBinUpgradePanel:CreateCell( ... )
	if self.shen_bin_cell == nil then
		local ph = self.ph_list.ph_item
		self.shen_bin_cell = ShenBinCell.New()
		self.shen_bin_cell:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_upgrade.node:addChild(self.shen_bin_cell:GetView(), 99)
	end

	-- if self.cur_skill_cell == nil then
	-- 	local ph = self.ph_list.ph_skill 
	-- 	self.cur_skill_cell = BaseCell.New()
	-- 	self.cur_skill_cell:GetView():setPosition(ph.x, ph.y)
	-- 	self.node_t_list.layout_cur_attr.node:addChild(self.cur_skill_cell:GetView(), 99)
	-- end


	-- if self.next_skill_cell == nil then
	-- 	local ph = self.ph_list.ph_skill 
	-- 	self.next_skill_cell = BaseCell.New()
	-- 	self.next_skill_cell:GetView():setPosition(ph.x, ph.y)
	-- 	self.node_t_list.layout_next_attr.node:addChild(self.next_skill_cell:GetView(), 99)
	-- end
	self.cell_list = {}
	for i = 1, 4 do
		local ph = self.ph_list["ph_upcell_"..i]
		local cell = BaseCell.New()
		cell:GetView():setPosition(ph.x, ph.y)
		self.node_t_list.layout_upgrade.node:addChild(cell:GetView(), 99)
		table.insert(self.cell_list, cell)
	end
end

function ShenBinUpgradePanel:ReleaseCallBack( ... )
	if self.wapon_level_change then
		GlobalEventSystem:UnBind(self.wapon_level_change)
		self.wapon_level_change = nil
	end

	if self.shen_bin_cell then
		self.shen_bin_cell:DeleteMe()
		self.shen_bin_cell = nil
	end

	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	-- if self.cur_skill_cell then
	-- 	self.cur_skill_cell:DeleteMe()
	-- 	self.cur_skill_cell = nil
	-- end

	-- if self.next_skill_cell then
	-- 	self.next_skill_cell:DeleteMe()
	-- 	self.next_skill_cell = nil
	-- end
	self.link_stuff = nil
end

function ShenBinUpgradePanel:OpenCallBack()
	-- body
end

function ShenBinUpgradePanel:SetWeaponData(data)
	self.data = data 
	self:Flush(index)
end

function ShenBinUpgradePanel:ShowIndexCallBack(index)
	self:Flush(index)
end

function ShenBinUpgradePanel:FlushView()
	self:Flush(index)
end

function ShenBinUpgradePanel:OnFlush()
	if self.data == nil then
		return 
	end
	local data = QieGeData.Instance:GetInfoByType(self.data.type)
	--XUI.SetButtonEnabled(self.node_t_list.btn_up.node, QieGeData.Instance:GetSingleWeaponUpgrade(data))
	local text = data.level > 0 and "升级" or "激活"
	self.node_t_list.btn_up.node:setTitleText(text)
	local cur_config = data.upgradeconsume[data.level] or {}
	local content = "无"
	if cur_config.attrs then
		local cur_attr = cur_config.attrs or {}
		 content = RoleData.FormatAttrContent(cur_attr)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_cur_text.node, content)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_cur_text.node,5)
	
	local next_config = data.upgradeconsume[data.level + 1] 
	local next_content = Language.QieGe.showDesc6
	if next_config then
		local next_attr = next_config.attrs
		 next_content = RoleData.FormatAttrContent(next_attr)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_next_text.node, next_content,nil, COLOR3B.GREEN)
	XUI.SetRichTextVerticalSpace(self.node_t_list.rich_next_text.node,5)


	local item_config1 = ItemData.Instance:GetItemConfig(cur_config.virtualItemId)
	if cur_config.virtualItemId == nil then
		item_config1 = ItemData.Instance:GetItemConfig(next_config.virtualItemId)
	end
	local text = string.format("Lv.%d",data.level)
	RichTextUtil.ParseRichText(self.node_t_list.text_name.node, item_config1.name .."  "..text or "", 24)
	local skill_text =  item_config1.desc
	if data.level > 0 then
		local config = ClientQieGeSkillCfg[self.data.type][data.level]
		local item_config = ItemData.Instance:GetItemConfig(cur_config.skillvirtualItemId)
		if config.value2 ~= nil then
			skill_text = string.format(item_config.desc,config.value1, config.value2)
		else
			skill_text = string.format(item_config.desc,config.value1)
		end
	end
	XUI.RichTextSetCenter(self.node_t_list.text_name.node)
	RichTextUtil.ParseRichText(self.node_t_list.text_desc.node, skill_text or "")

	local skill_config = ItemData.Instance:GetItemConfig(data.skill_id)
	local skill_desc = string.format(Language.QieGe.showdesc7, skill_config.name, data.level)
	self.node_t_list.text_cur_name.node:setString(skill_desc)

	-- local item_config = cur_config
	-- if cur_config.virtualItemId == nil then
	-- 	item_config = next_config
	-- end

	self.shen_bin_cell:SetData({item_id = data.skill_id or 0, num= 1, is_bind = 0})
	local text = "" 
	if self.data.level <= 0 then
		local step, level = QieGeData.Instance:GetLevelAndStep(self.data.need_level)
		text = string.format(Language.QieGe.showDesc11, step, level)
	end
	local color = COLOR3B.RED
	if QieGeData.Instance:GetLevel() >= self.data.need_level then
		color = COLOR3B.GREEN
	end
	self.node_t_list.text_active.node:setString(text)
	self.node_t_list.text_active.node:setColor(color)
	-- if cur_config.skillvirtualItemId == nil then
	-- 	self.cur_skill_cell:SetData(nil)
	-- 	self.cur_skill_cell:GetView():setVisible(false)
	-- else
	-- 	self.cur_skill_cell:SetData({item_id = cur_config.skillvirtualItemId or 0, num= 1, is_bind = 0, virtual_type = self.data.type,virtual_level = data.level})	
	-- 	self.cur_skill_cell:GetView():setVisible(true)
	-- end
	

	-- if next_config ~= nil then
	-- 	self.next_skill_cell:GetView():setVisible(true)
	-- 	self.next_skill_cell:SetData({item_id = next_config.skillvirtualItemId or 0, num= 1, is_bind = 0, virtual_type = self.data.type,virtual_level = data.level+1})
	-- else
	-- 	self.next_skill_cell:GetView():setVisible(false)
	-- end
	
	local item_config = ItemData.Instance:GetItemConfig(cur_config.skillvirtualItemId or 0)
	local text = cur_config.skillvirtualItemId and string.format(Language.QieGe.showdesc7, item_config.name, data.level) or ""
	self.node_t_list.txt_cur_name.node:setString(text)

	local next_item_config =  ItemData.Instance:GetItemConfig(next_config and next_config.skillvirtualItemId or 0)
	local text1 = next_config and string.format(Language.QieGe.showdesc7, next_item_config.name, data.level + 1) or ""
	self.node_t_list.txt_cur_name1.node:setString(text1)
	local text = ""
	if data.level > 0 then
		text = Language.QieGe.showdesc9
	end
	for k, v in pairs(self.cell_list) do
		v:GetView():setVisible(false)
	end
	if(next_config) then
		local index = 0
		for k,v in pairs(next_config.consume) do
			if v.count > 0 and data.level > 0 then
				local cell = self.cell_list[k]
				if cell then
					cell:GetView():setVisible(true)
					cell:SetData({item_id = v.id, num = 1, is_bind = 0})
					local had_item_num = BagData.Instance:GetItemNumInBagById(v.id, nil)
					local color2 = had_item_num >= v.count and "00ff00" or "ff0000"
					local color = Str2C3b(color2)
					local text = string.format("%d/%d", had_item_num, v.count)
					cell:SetRightBottomText(text, color)
				end
				index = index + 1
			end
		end

		local offest = 0
		if index == 1 then
			offest = 130
		elseif index == 2 then
			offest = 80
		elseif  index == 3 then
			offest = 40
		end
		local ph = self.ph_list.ph_upcell_1
		for k, v in pairs(self.cell_list) do
			v:GetView():setPosition(ph.x + (k -1) * 80 + offest, ph.y)
		end
	end
	-- for k, v in pairs(self.cell_list) do
	-- 	v:GetView():setVisible(data.level > 0)
	-- end
	-- RichTextUtil.ParseRichText(self.node_t_list.text_consume.node, text)
	-- XUI.RichTextSetCenter(self.node_t_list.text_consume.node)
end


function ShenBinUpgradePanel:UpgradeShenBin()
	if self.data then
		local config = CuttingWeaponConfig[self.data.type]
		if self.data.level <= 0 then
			if QieGeData.Instance:GetLevel() >= config.cuttinglv then
				QieGeCtrl.Instance:SendQieGeShenBinUpgradeReq(self.data.type)
				return
			else
				local consume_step, star = QieGeData.Instance:GetLevelAndStep(config.cuttinglv)
				local text = string.format(Language.QieGe.showDesc11, consume_step, star)
				SysMsgCtrl.Instance:FloatingTopRightText(text)
				return
			end
		end
		QieGeCtrl.Instance:SendQieGeShenBinUpgradeReq(self.data.type)
	end
end

ShenBinCell = ShenBinCell or BaseClass(BaseCell)

function ShenBinCell:SetAddClickEventListener()
	-- body
end