--
-- @Author: chk
-- @Date:   2018-10-31 17:56:13
--
EquipSuitItemSettor = EquipSuitItemSettor or class("EquipSuitItemSettor",BaseItem)
local EquipSuitItemSettor = EquipSuitItemSettor

function EquipSuitItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipSuitItem"
	self.layer = layer

	self.events = {}
	self.model = EquipSuitModel:GetInstance()
	EquipSuitItemSettor.super.Load(self)

	self.global_events = {}

	self.desc = nil;
end

function EquipSuitItemSettor:dctor()
	self.model.last_select_item = nil

	for i, v in pairs(self.events) do
		self.model:RemoveListener(v)
	end

	for i=1, #self.global_events do
		GlobalEvent:RemoveListener(self.global_events[i])
	end

	if self.iconCls ~= nil then
		self.iconCls:destroy()
		self.iconCls = nil
	end

	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
	self.model = nil
end

function EquipSuitItemSettor:LoadCallBack()
	self.nodes = {
		"select",
		"icon",
		"name",
		"to",
		"suitCount",
	}
	self:GetChildren(self.nodes)
	self:GetRectTransform()
	self:AddEvent()
	if self.need_load_end then
		self:UpdateInfo(self.equipItem,self.__index,self.suitLv)
	end
end

function EquipSuitItemSettor:AddEvent()
	AddClickEvent(self.gameObject,handler(self,self.SelectItem))

	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SuitList,handler(self,self.DealSuitList))
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectDefaultSuit,handler(self,self.SelectDefaultItem))

	local function call_back( )
		self:ShowRedDot()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(GoodsEvent.DelItems, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(BagEvent.AddItems, call_back)
    self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.BuildSuitSucess, call_back)
end

function EquipSuitItemSettor:DealSuitList()
	self:UpdateSuitInfo(self.equipItem)
end

function EquipSuitItemSettor:GetRectTransform()
	self.nameTxt = self.name:GetComponent('Text')
	self.toTxt = self.to:GetComponent('Text')
	self.toTxt.text = ""
	self.suitCountTxt = self.suitCount:GetComponent('Text')
end

function EquipSuitItemSettor:SetData(data)

end

function EquipSuitItemSettor:SetItemPosition()
	local y = (self.__index - 1) * 96
	SetLocalPosition(self.transform,0,-y,0)
end

function EquipSuitItemSettor:UpdateSuitInfo(equip)
	--local equipConfig = Config.db_equip[equip.id]
	if self.equipItem.id ~= equip.id then
		return
	end

	local equipConfig = Config.db_equip[equip.id]
	local itemCfg = Config.db_item[equip.id]
	if self.model:GetActiveByEquip(equipConfig.slot,2) then
		self.nameTxt.text = string.format("<color=#%s>%s</color>",
				ColorUtil.GetColor(itemCfg.color), "[" .. self.model.suitTypeName[2] .. "]" .. equipConfig.name)
	elseif self.model:GetActiveByEquip(equipConfig.slot,1) then
		self.nameTxt.text = string.format("<color=#%s>%s</color>",
				ColorUtil.GetColor(itemCfg.color), "[" .. self.model.suitTypeName[1] .. "]" .. equipConfig.name)
	else
		self.nameTxt.text = string.format("<color=#%s>%s</color>",
				ColorUtil.GetColor(itemCfg.color), equipConfig.name)
	end


	local suitCfg = self.model:GetSuitConfig(equipConfig.slot,equipConfig.order,self.suitLv)

	local showSuitLv = self.suitLv
	if showSuitLv == 1 then
		showSuitLv = self.model:GetShowSuitLvByEquip(equip)
	end

	if self.model:GetActiveByEquip(equipConfig.slot,showSuitLv) then
		if not table.isempty(suitCfg) then
			local totalCount = self.model:GetSuitCount(equipConfig.slot,equipConfig.order,showSuitLv)
			local hasCount = self.model:GetActiveSuitCount(equipConfig.slot,equipConfig.order,showSuitLv)

			self.suitCountTxt.text = string.format("<color=#93572c>%s</color>",
					ConfigLanguage.Equip.HadSuitEquip .. "(" ..  hasCount .. "/" .. totalCount .. ")")

			local toSuitLv = 1
			if self.suitLv == 1 then
				if self.model:GetActiveByEquip(equipConfig.slot,2) then
					self.toTxt.text = ""
					self.suitCountTxt.text = string.format(ConfigLanguage.Equip.HadSuitTo,self.model.suitTypeName[2])
				elseif self.model:GetCanBuildSuit(self.equipItem,2) then
					toSuitLv = 2
					self.toTxt.text = string.format(ConfigLanguage.Equip.CanToSuit,self.model.suitTypeName[2])
				end
			end
		else
			self.toTxt.text = ""
			local desc = string.format("<color=#b31010>%s</color>",ConfigLanguage.Equip.CannotSuit)
			self.desc = desc
			self.suitCountTxt.text = "Can't activate"
		end
	elseif self.model:GetCanBuildSuit(self.equipItem,showSuitLv) then
		self.toTxt.text = ""
		if self.suitLv == 2 and not self.model:GetActiveByEquip(equipConfig.slot,1) then
			self.suitCountTxt.text = string.format(ConfigLanguage.Equip.NeedToBuild,self.model.suitTypeName[1] ..
			ConfigLanguage.Equip.Suit)
		else
			self.suitCountTxt.text = string.format(ConfigLanguage.Equip.CanToSuit,self.model.suitTypeName[showSuitLv])
		end
	else
		self.toTxt.text = ""

		local suitLvCfg = Config.db_equip_suite_level[showSuitLv]
		if equipConfig.order < suitLvCfg.order then
			local desc = string.format(ConfigLanguage.Equip.CannotSuit,suitLvCfg.order)
			self.desc = desc
			self.suitCountTxt.text = "Can't activate"
		elseif itemCfg.color < suitLvCfg.color or equipConfig.star < suitLvCfg.star then
			local desc = string.format(ConfigLanguage.Equip.CannotSuit2,enumName.COLOR[suitLvCfg.color],suitLvCfg.star)
			self.suitCountTxt.text = desc
		end
	end
end

function EquipSuitItemSettor:UpdateInfo(equip,index,suitLv)
	self.__index = index
	self.equipItem = equip
	self.suitLv = suitLv
	if self.is_loaded then
		self:UpdateSuitInfo(equip)

		if self.iconCls == nil then
			self.iconCls = GoodsIconSettorTwo(self.icon)
		end

		local param = {}
		param["not_need_compare"] = true
		param["model"] = self.model
		param["p_item"] = equip
		param["item_id"] = equip.id
		param["size"] = {x = 76,y=76}
		--param["can_click"] = true
		self.iconCls:SetIcon(param)

		--self.iconCls:UpdateIconByItemId(equip.id)

		self.need_load_end = false

		self:SetItemPosition()
		if self.model.select_equip ~= nil and self.model.select_equip.id == self.equipItem.id then
			self.model.selectDefaultEquip[self.suitLv] = self.model.select_equip
			self:SelectDefaultItem(self.model.select_equip,self.suitLv)
		else
			local equip = EquipModel.Instance:GetFstSuitEquip()
			if equip ~= nil and equip.id == self.equipItem.id then
				self.model.selectDefaultEquip[self.suitLv] = self.equipItem
				self:SelectItem()
				GlobalEvent:Brocast(EquipEvent.SuitItemPos,self.transform)
			end
		end
		self:ShowRedDot()
	else
		self.need_load_end = true
	end
end


function EquipSuitItemSettor:ShowSelectBG(show)
	SetVisible(self.select.gameObject,show)
end

function EquipSuitItemSettor:SelectDefaultItem(equipDetail,suitLv)
	if equipDetail ~= nil and self.equipItem ~= nil and self.equipItem.id == equipDetail.id
			and self.suitLv == suitLv then
		self:SelectItem()

		GlobalEvent:Brocast(EquipEvent.SuitItemPos,self.transform,self.suitLv)
	end

end

function EquipSuitItemSettor:SelectItem()

	if self.model.last_select_item ~= nil then
		self.model.last_select_item:ShowSelectBG(false)

		if self.model.last_select_item.equipItem ~= nil and self.model.last_select_item.equipItem.id == self.equipItem.id then
			self:ShowSelectBG(true)
			return
		end
	end

	self:ShowSelectBG(true)
	self.model.last_select_item = self

	local equipConfig = Config.db_equip[self.equipItem.id]
	if EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot] ~= nil then
		self.model.operateItemId = equipConfig.id
		self.model.operateSlot = equipConfig.slot

		self.model.selectDefaultEquip[self.suitLv] = EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot]
		GlobalEvent:Brocast(EquipEvent.ShowSuitViewInfo,EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot])
		-- else
		-- 	GoodsController.Instance:RequestItemInfo(1,equipConfig.slot)

		self.model:Brocast(EquipEvent.ShowSuiteDesc, self.desc)
	end

end

function EquipSuitItemSettor:ShowRedDot()
	local show_reddot = self.model:GetNeedShowRedDotByEquip(self.equipItem, self.suitLv)
	if not self.red_dot then
		self.red_dot = RedDot(self.transform)
		SetLocalPosition(self.red_dot.transform, 275, -19)
	end
	SetVisible(self.red_dot, show_reddot)
end