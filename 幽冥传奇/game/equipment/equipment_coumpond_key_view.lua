
EquipmentCoumpundKeyView = EquipmentCoumpundKeyView or BaseClass(XuiBaseView)
EquipmentCoumpundKeyView.Width = 262
EquipmentCoumpundKeyView.Height = 316

function EquipmentCoumpundKeyView:__init()
	self:SetModal(true)
   	self.texture_path_list[1] = "res/xui/quick_use_equip.png"
	self.config_tab = {
						{"itemtip_ui_cfg", 18, {0}},
					}
	self.is_async_load = false
	self.btn_index = nil
	self.cur_item_index = nil
	self.data_id = nil
	self.data_item_id = nil
	self.equip_cfg = {}
end

function EquipmentCoumpundKeyView:__delete()
	
end

function EquipmentCoumpundKeyView:ReleaseCallBack()
	if 	self.equip_cell then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil 
	end
	if self.alert_window then
		self.alert_window:DeleteMe()
		self.alert_window = nil 
	end
end

function EquipmentCoumpundKeyView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		local screen_w = HandleRenderUnit:GetWidth()
		local screen_h = HandleRenderUnit:GetHeight()

		local ph = self.ph_list.ph_cell_1
		self.equip_cell = BaseCell.New()
		self.equip_cell:SetPosition(ph.x, ph.y)
		self.node_t_list.layout_quick_coumpond_item.node:addChild(self.equip_cell:GetView(), 99)

		self.btn_equip_compound = self.node_t_list.btn_compund.node
		self.btn_equip_compound:addClickEventListener(BindTool.Bind(self.OnClickEquipCoupond, self))
	end
end

function EquipmentCoumpundKeyView:SetData(btn_index, cur_item_index, id, item_id, equips_cfg)
	self.btn_index = btn_index
	self.cur_item_index = cur_item_index
	self.data_id = id
	self.data_item_id = item_id
	self.equip_cfg = equips_cfg
	if self:IsOpen() then
		self:Flush()
	else	
		self:Open()
	end	
end

function EquipmentCoumpundKeyView:ShowIndexCallBack(index)
	self:Flush(index)
end

function EquipmentCoumpundKeyView:OpenCallBack()
	self.root_node:setPosition(HandleRenderUnit:GetWidth() - EquipmentCoumpundKeyView.Width  + 30, EquipmentCoumpundKeyView.Height)
	self.root_node:setOpacity(0)
	local move_to = cc.MoveTo:create(0.2, cc.p(HandleRenderUnit:GetWidth() - EquipmentCoumpundKeyView.Width + 30, EquipmentCoumpundKeyView.Height + 100))
	local fade_in = cc.FadeIn:create(0.2)
	local spawn = cc.Spawn:create(move_to, fade_in)
	self.root_node:runAction(spawn)
end

function EquipmentCoumpundKeyView:CloseCallBack(is_all)
	
end

--刷新相应界面
function EquipmentCoumpundKeyView:OnFlush(paramt, index)
	if self.data_id ~= nil then 
		self.equip_cell:SetData({item_id = self.data_id, num = 1, is_bind = 0})
		local cfg = ItemData.Instance:GetItemConfig(self.data_id)
		self.node_t_list.equip_coumpond_name.node:setString(cfg.name)
	end
	self.btn_equip_compound:setTitleText(Language.Equipment.Btn_Text)
end


function EquipmentCoumpundKeyView:OnClickEquipCoupond()
	if self.btn_index ~= nil and self.cur_item_index ~= nil and self.data_id ~= nil and self.equip_cfg and self.data_item_id then
		if self:GetComposeBaoStrenth(self.data_item_id, self.equip_cfg) then
			if nil == self.alert_window then
				self.alert_window = Alert.New()
			end
			local des = Language.Equipment.Compoud_tips
			self.alert_window:SetLableString(des)
			self.alert_window:SetOkFunc(function()
						ViewManager.Instance:Open(ViewName.Equipment, TabIndex.equipment_compound)
						ViewManager.Instance:FlushView(ViewName.Equipment, TabIndex.equipment_compound, "tiaozhuan", {data = self.btn_index, id = self.data_id})
						self:Close()
					end)
			self.alert_window:SetShowCheckBox(true)
			self.alert_window:Open()	
		else
			ViewManager.Instance:Open(ViewName.Equipment, TabIndex.equipment_compound)
			ViewManager.Instance:FlushView(ViewName.Equipment, TabIndex.equipment_compound, "tiaozhuan", {data = self.btn_index, id = self.data_id})
			self:Close()
		end
	end
end

function EquipmentCoumpundKeyView:GetComposeBaoStrenth(item_id, equips_cfg)
	if #equips_cfg == 0 then return false end
	local equips = ItemData.Instance:GetBagEquipList()
	local data = EquipmentData.Instance:SortData(equips, item_id)
	local cur_data = nil 
	local series = {}
	for k, v in pairs(equips_cfg) do
		cur_data = nil
		for i = #data, 1 , -1 do
			if data[i].item_id == v then
				cur_data = table.remove(data,i)
				table.insert(series, cur_data.series)
				break
			end	
		end	
	end
	for k, v in pairs(series) do
		local data = ItemData.Instance:GetItemInBagBySeries(v)
		if data.strengthen_level > 0 or data.infuse_level > 0 then
			return true
		end
	end
	return false
end