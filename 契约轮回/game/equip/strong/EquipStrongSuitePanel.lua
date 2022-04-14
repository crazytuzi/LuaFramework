EquipStrongSuitePanel = EquipStrongSuitePanel or class("EquipStrongSuitePanel",WindowPanel)
local EquipStrongSuitePanel = EquipStrongSuitePanel

function EquipStrongSuitePanel:ctor()
	self.abName = "equip"
	self.assetName = "EquipStrongSuitePanel"
	self.layer = "UI"

	-- self.change_scene_close = true 				--切换场景关闭
	-- self.default_table_index = 1					--默认选择的标签
	-- self.is_show_money = {Constant.GoldType.Coin,Constant.GoldType.BGold,Constant.GoldType.Gold}	--是否显示钱，不显示为false,默认显示金币、钻石、宝石，可配置
	
	self.panel_type = 3								--窗体样式  1 1280*720  2 850*545
	self.model = EquipStrongModel:GetInstance()
	self.globalEvents = {}
	self.attrs = {}
	self.next_attrs = {}
end

function EquipStrongSuitePanel:dctor()
end

function EquipStrongSuitePanel:Open( )
	EquipStrongSuitePanel.super.Open(self)
end

function EquipStrongSuitePanel:LoadCallBack()
	self.nodes = {
		"cur/power","cur/attr1","cur/attr2","cur/attr3","next/next_power",
		"next/next_attr1","next/next_attr2","next/next_attr3",
		"condition_title/condition","okbtn","condition_title",
		"max","next","cur","arrow",
	}
	self:GetChildren(self.nodes)
	self.attr1 = GetText(self.attr1)
	self.attr2 = GetText(self.attr2)
	self.attr3 = GetText(self.attr3)
	self.next_attr1 = GetText(self.next_attr1)
	self.next_attr2 = GetText(self.next_attr2)
	self.next_attr3 = GetText(self.next_attr3)
	self.condition = GetText(self.condition)
	self.power = GetText(self.power)
	self.next_power = GetText(self.next_power)
	self.okbtn = GetButton(self.okbtn)

	table.insert(self.attrs, self.attr1)
	table.insert(self.attrs, self.attr2)
	table.insert(self.attrs, self.attr3)
	table.insert(self.next_attrs, self.next_attr1)
	table.insert(self.next_attrs, self.next_attr2)
	table.insert(self.next_attrs, self.next_attr3)
	self:AddEvent()
	self:SetPanelSize(662, 480)
	self:SetTileTextImage("equipStrong_image", "strongsuite_title")
	EquipController.Instance:RequestStrongSuite()
end

function EquipStrongSuitePanel:AddEvent()
	local function call_back()
		self:UpdateView()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.ShowSuitAttr,call_back)

	local function call_back(target,x,y)
		local nextsuite = Config.db_equip_strength_suite[self.model.suitId+1]
		if nextsuite then
			local strongCount = self.model:GetStrongCountByPhase(nextsuite.phase,nextsuite.level)
			if strongCount >= nextsuite.num then
				EquipController.GetInstance():UpStrongSuite()
			else
				Notify.ShowText("Not enough Gear")
			end
		else
			Notify.ShowText("Max level reached")
		end
		
	end
	AddButtonEvent(self.okbtn.gameObject,call_back)
end

function EquipStrongSuitePanel:OpenCallBack()
	self:UpdateView()
end

function EquipStrongSuitePanel:UpdateView( )
	local cursuite = Config.db_equip_strength_suite[self.model.suitId]
	local nextsuite = Config.db_equip_strength_suite[self.model.suitId+1]
	if cursuite then
		local attrs = String2Table(cursuite.attrib)
		local next_attrs = {}
		if nextsuite then
			next_attrs = EquipModel.GetInstance():FormatAttr(nextsuite.attrib)
		end
		for i=1, #self.attrs do
			local attr = attrs[i]
			local attr_name = enumName.ATTR[attr[1]]
			self.attrs[i].text = string.format("%s：%s", attr_name, EquipModel.GetInstance():GetAttrTypeInfo(attr[1], attr[2]))
			if nextsuite then
				self.next_attrs[i].text = string.format("%s：<color=#3ab60e>%s</color>", attr_name, EquipModel.GetInstance():GetAttrTypeInfo(attr[1], next_attrs[attr[1]]))	
			end
		end
		if nextsuite then
			SetVisible(self.max, false)
			SetVisible(self.condition_title, true)
			SetVisible(self.next, true)
			SetVisible(self.arrow, true)
			SetLocalPositionX(self.cur.transform, -156.23)
			local next_attr_list = String2Table(nextsuite.attrib)
			self.next_power.text = GetPowerByConfigList(next_attr_list)
		else
			SetVisible(self.max, true)
			SetVisible(self.condition_title, false)
			SetVisible(self.next, false)
			SetVisible(self.arrow, false)
			SetLocalPositionX(self.cur.transform, 6.8)
		end
		self.power.text = GetPowerByConfigList(attrs, {})
	else
		SetLocalPositionX(self.cur.transform, -156.23)
		local attrs = String2Table(nextsuite.attrib)
		for i=1, #self.attrs do
			local attr = attrs[i]
			local attr_name = enumName.ATTR[attr[1]]
			self.attrs[i].text = string.format("%s：%s", attr_name, EquipModel.GetInstance():GetAttrTypeInfo(attr[1], 0))
			self.next_attrs[i].text = string.format("%s：%s", attr_name, EquipModel.GetInstance():GetAttrTypeInfo(attr[1], attr[2]))
		end
		self.power.text = 0
		self.next_power.text = GetPowerByConfigList(attrs, {})
		SetVisible(self.max, false)
	end
	if nextsuite then
		local strongCount = self.model:GetStrongCountByPhase(nextsuite.phase,nextsuite.level)
		local color = "eb0000"
		if strongCount >= nextsuite.num then
			color = "3ab60e"
			self.okbtn.interactable = true
			if not self.reddot then
				self.reddot = RedDot(self.okbtn.transform)
				SetLocalPosition(self.reddot.transform, 55, 14)
			end
			SetVisible(self.reddot, true)
		else
			self.okbtn.interactable = false
			if self.reddot then
				SetVisible(self.reddot, false)
			end
		end
		self.condition.text = string.format("Enhance <color=#3ab60e>%s</color> equipment to <color=#3ab60e>T%s Lv.%s</color><color=#%s>(%s/%s)</color>", nextsuite.num, nextsuite.phase, nextsuite.level,
			color, strongCount, nextsuite.num)
	end
end

function EquipStrongSuitePanel:CloseCallBack(  )
	GlobalEvent:RemoveTabListener(self.globalEvents)
	self.globalEvents = nil
	self.attrs = nil
	self.next_attrs = nil
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
end
function EquipStrongSuitePanel:SwitchCallBack(index)
	if self.table_index == index then
		return
	end
	if self.child_node then
	 	self.child_node:SetVisible(false)
	end
	self.table_index = index
	--if self.table_index == 1 then
		-- if not self.show_panel then
		-- 	self.show_panel = ChildPanel(self.transform)
		-- end
		-- self:PopUpChild(self.show_panel)
	--end
end