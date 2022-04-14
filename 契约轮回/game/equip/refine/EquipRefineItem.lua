EquipRefineItem = EquipRefineItem or class("EquipRefineItem",BaseCloneItem)
local EquipRefineItem = EquipRefineItem

function EquipRefineItem:ctor(obj,parent_node,layer)
	EquipRefineItem.super.Load(self)
end

function EquipRefineItem:dctor()
	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil
	end
	if self.reddot then
		self.reddot:destroy()
		self.reddot = nil
	end
	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.global_events)
end

function EquipRefineItem:LoadCallBack()
	self.nodes = {
		"icon", "icon/icon_bg", "icon/icon_bg/iconlock", "name", "phase", "select"
	}
	self.model = EquipRefineModel.GetInstance()
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.phase = GetText(self.phase)
	self:AddEvent()
end

function EquipRefineItem:AddEvent()
	self.events = self.events or {}
	self.global_events = self.global_events or {}
	local function call_back(target,x,y)
		if not self.model.slots[self.data] then
			local can_actvie, open_level = self:CanActive()
			if can_actvie then
				EquipController:GetInstance():RequestActiveSlot(self.data)
			else
				return Notify.ShowText(string.format("Unlock at Lv.%s", open_level))	
			end
		end
		if EquipModel.GetInstance():GetEquipBySlot(self.data) then
			self.model:Brocast(EquipEvent.SelectRefineItem, self.data)
		else
			Notify.ShowText(string.format("Please equip a %s first", enumName.ITEM_STYPE[self.data]))
		end
	end
	AddClickEvent(self.gameObject,call_back)

	local function call_back(slot)
		SetVisible(self.select, self.data == slot)
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectRefineItem, call_back)

	local function call_back()
		self:UpdateView()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.UpdateRefineInfo, call_back)
end

--data:slot
function EquipRefineItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function EquipRefineItem:UpdateView()
	local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
	local slot = self.data
	local open_level = Config.db_equip_refine[slot].open
	--已解锁
	if self.model.slots[slot] then
		local pitem = EquipModel:GetInstance():GetEquipBySlot(slot)
		if pitem then
			SetVisible(self.icon_bg, false)
			if not self.goodsitem then
				self.goodsitem = GoodsIconSettorTwo(self.icon) 
			end
			local param = {}
			param["not_need_compare"] = true
			param["model"] = self.model
			param["p_item"] = pitem
			param["item_id"] = pitem.id
			param["size"] = {x = 76,y=76}
			self.goodsitem:SetIcon(param)
			local itemcfg = Config.db_item[pitem.id]
			self.name.text = itemcfg.name
			self.phase.text = string.format("%s refinery attributes", #self.model.slots[slot].holes)
		else
			SetVisible(self.icon_bg, true)
			SetVisible(self.iconlock, false)
			self.name.text = string.format("Refinery: %s", enumName.ITEM_STYPE[slot])
			self.phase.text = "is empty"
		end
	--未解锁
	else
		SetVisible(self.icon_bg, true)
		self:SetNameInfo(slot, level, open_level)
	end
	self:ShowRedDot()
end

function EquipRefineItem:SetNameInfo(slot, level, open_level)
	self.name.text = string.format("Refinery: %s", enumName.ITEM_STYPE[slot])
	if level < open_level then
		self.phase.text = string.format("Unlock at Lv.%s", GetLevelShow(open_level))
	else
		self.phase.text = "Tap to unlock"
	end
end

function EquipRefineItem:CanActive()
	local slot = self.data
	local open_level = Config.db_equip_refine[slot].open
	local level = RoleInfoModel:GetInstance():GetMainRoleLevel()
	return level >= open_level, open_level
end

function EquipRefineItem:ShowRedDot()
	if self.model:IsCanActive(self.data) or self.model:IsHoleCanActive(self.data, 5) then
		if not self.reddot then
			self.reddot = RedDot(self.transform)
			SetLocalPosition(self.reddot.transform, 275, -19)
		end
		SetVisible(self.reddot, true)
	else
		if self.reddot then
			SetVisible(self.reddot, false)
		end
	end
end
