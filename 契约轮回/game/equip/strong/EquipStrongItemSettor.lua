--
-- @Author: chk
-- @Date:   2018-09-18 16:17:26
--
EquipStrongItemSettor = EquipStrongItemSettor or class("EquipStrongItemSettor",BaseItem)
local EquipStrongItemSettor = EquipStrongItemSettor

function EquipStrongItemSettor:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "EquipStrongItem"
	self.layer = layer

	self.model = EquipStrongModel:GetInstance()
	self.need_load_end = false
	self.iconCls = nil
	self.globalEvents = {}
	self.__index = 0
	EquipStrongItemSettor.super.Load(self)
end

function EquipStrongItemSettor:dctor()
	for i, v in pairs(self.globalEvents) do
		GlobalEvent:RemoveListener(v)
	end
	self.globalEvents = {}
	if self.bind_data_event then
		RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.bind_data_event)
	end

	if self.iconCls ~= nil then
		self.iconCls:destroy()
	end
	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end
end

function EquipStrongItemSettor:LoadCallBack()
	self.nodes = {
		"select",
		"icon",
		"name",
		"phase",
		"name_type",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self.phaseTxt = self.phase:GetComponent('Text')
	self.name_type = GetText(self.name_type)
	if self.need_load_end then
		self:UpdateInfo(self.equipItem,self.__index)
	end
end

function EquipStrongItemSettor:AddEvent()
	AddClickEvent(self.gameObject,handler(self,self.SelectItem))

	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.PhaseChange, handler(self,self.UpdatePhase))

	local function call_back(select_equip)
		if select_equip.id == self.equipItem.id then
			self:SelectItem()
		end
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.SelectEquipItem, call_back)
	local function call_back()
		self:ShowRedDot()
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StrongSucess, call_back)
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.StrongFail, call_back)
	self.bind_data_event = RoleInfoModel:GetInstance():GetMainRoleData():BindData("coin", call_back)

	local function call_back()
		local equipConfig = Config.db_equip[self.equipItem.id]
		local pitem = EquipModel:GetInstance():GetEquipBySlot(equipConfig.slot)
		self:UpdateInfo(pitem, self.__index)
	end
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(EquipEvent.EquipStrongAll, call_back)
end

--function EquipStrongItemSettor:DealGoodsDetail(equipDetail)
--	if self.equipItem.uid == equipDetail.uid then
--		GlobalEvent:Brocast(EquipEvent.ShowStrongInfo,equipDetail)
--	end
--end

function EquipStrongItemSettor:SetData(data)

end

function EquipStrongItemSettor:SelectItem()

	if self.model.is_auto_strong then
		return
	end


	if self.model.last_select_item ~= nil then
		self.model.last_select_item:ShowSelectBG(false)
	end

	self:ShowSelectBG(true)
	self.model.last_select_item = self

	local equipConfig = Config.db_equip[self.equipItem.id]
	if EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot] ~= nil then
		GlobalEvent:Brocast(EquipEvent.ShowStrongInfo,EquipModel.Instance.putOnedEquipDetailList[equipConfig.slot])
	-- else
	-- 	GoodsController.Instance:RequestItemInfo(1,equipConfig.slot)
	end


end

function EquipStrongItemSettor:ShowSelectBG(show)
	SetVisible(self.select.gameObject,show)
end

function EquipStrongItemSettor:SetItemPosition()
	local y = (self.__index - 1) * 96
	SetLocalPosition(self.transform,0,-y,0)
end

function EquipStrongItemSettor:UpdatePhase(equipItem,phaseInfo)
	if equipItem.id == self.equipItem.id and self.phaseTxt ~= nil then
		self.equipItem = equipItem
		self.phaseTxt.text = phaseInfo
	end
end

function EquipStrongItemSettor:UpdateInfo(equip,index)
	self.__index = index
	self.equipItem = equip
	if self.is_loaded then
		local equipConfig = Config.db_equip[equip.id]
		local itemConfig = Config.db_item[equip.id]
		self.name:GetComponent('Text').text =  string.format("<color=#%s>%s</color>",
				ColorUtil.GetColor(itemConfig.color), equipConfig.name)
		self.name_type.text = enumName.ITEM_STYPE[equipConfig.slot]
		if not self.iconCls then
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
		local phaseInfo = "T"..equip.equip.stren_phase .."Lv."..
				equip.equip.stren_lv
        local itemConfig = Config.db_item[equip.id]
        local strong_limit_key = equipConfig.slot .. "@" .. equipConfig.order .. "@" .. itemConfig.color
        if self.model:GetNextPhase(equipConfig.slot,equip.equip.stren_phase,equip.equip.stren_lv) >= Config.db_equip_strength_limit[strong_limit_key].max_phase then
            phaseInfo =  phaseInfo .. "(" .. ConfigLanguage.Equip.StrongestLV .. ")"
        end
		self:UpdatePhase(self.equipItem,phaseInfo)
		self.need_load_end = false
		self:SetItemPosition()
		if self.model.select_equip ~= nil and self.model.select_equip.id == self.equipItem.id then

			self:SelectItem()

			GlobalEvent:Brocast(EquipEvent.StrongItemPos,self.transform)
		elseif self.model.minStrongEquip ~= nil and self.equipItem.id == self.model.minStrongEquip.id then
			self:SelectItem()

			GlobalEvent:Brocast(EquipEvent.StrongItemPos,self.transform)
		end
		self:ShowRedDot()
	else
		self.need_load_end = true
	end

end

function EquipStrongItemSettor:ShowRedDot()
	if not self.red_dot then
		self.red_dot = RedDot(self.transform)
		SetLocalPosition(self.red_dot.transform, 275, -19,0)
	end
	local show_red = self.model:GetNeedShowRedDotByEquip(self.equipItem)
	SetVisible(self.red_dot, show_red)
end
