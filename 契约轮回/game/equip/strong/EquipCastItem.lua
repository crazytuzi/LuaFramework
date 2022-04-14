EquipCastItem = EquipCastItem or class("EquipCastItem",BaseCloneItem)
local EquipCastItem = EquipCastItem

function EquipCastItem:ctor(obj,parent_node,layer)
	EquipCastItem.super.Load(self)
end

function EquipCastItem:dctor()
	if self.iconItem then
		self.iconItem:destroy()
		self.iconItem = nil
	end
	if self.red_dot then
		self.red_dot:destroy()
		self.red_dot = nil
	end

	self.model:RemoveTabListener(self.events)
	GlobalEvent:RemoveTabListener(self.global_events)
end

function EquipCastItem:LoadCallBack()
	self.nodes = {
		"select", "icon", "name", "castlevel", "nexttip"
	}
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.castlevel = GetText(self.castlevel)
	self.nexttip = GetText(self.nexttip)
	self.model = EquipStrongModel:GetInstance()
	self:AddEvent()
end

function EquipCastItem:AddEvent()
	self.events = self.events or {}
	self.global_events = self.global_events or {}
	local function call_back(target,x,y)
		self.model:Brocast(EquipEvent.SelectCastItem, self.data)
	end
	AddClickEvent(self.gameObject,call_back)

	local function call_back(pitem)
		self:SelectItem(self.data.uid == pitem.uid)
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectCastItem, call_back)

	local function call_back(equipdetail)
		if self.data.uid == equipdetail.uid then
			self.data = equipdetail
			self:UpdateView()
		end
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(EquipEvent.UpdateEquipDetail, call_back)

	local function call_back()
		self:ShowRedDot()
	end
	self.global_events[#self.global_events+1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end

function EquipCastItem:SelectItem(flag)
	SetVisible(self.select, flag)
end

--data:p_item
function EquipCastItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function EquipCastItem:UpdateView()
	local itemcfg = Config.db_item[self.data.id]
	local equipcfg = Config.db_equip[self.data.id]
	if not self.iconItem then
		self.iconItem = GoodsIconSettorTwo(self.icon)
	end
	local param = {}
	param["not_need_compare"] = true
	param["model"] = self.model
	param["p_item"] = self.data
	param["item_id"] = self.data.id
	param["size"] = {x = 76,y=76}
	self.iconItem:SetIcon(param)

	self.name.text = ColorUtil.GetHtmlStr(itemcfg.color, itemcfg.name)
	local cast_level = self.data.equip.cast
	local key = string.format("%s@%s", equipcfg.slot, cast_level)
	local castcfg = Config.db_equip_cast[key]
	if cast_level > 0 then
		self.castlevel.text = string.format("Equipped<color=#09b005>%s</color>", castcfg.name)
	else
		if self.model:GetCastMaxLevel(itemcfg.id) == 0 then
			self.castlevel.text = "Unforgeable"
		else
			self.castlevel.text = ""
		end
	end
	local nextkey = string.format("%s@%s", equipcfg.slot, cast_level+1)
	local nextcastcfg = Config.db_equip_cast[nextkey]
	if nextcastcfg then
		self.nexttip.text = string.format("%s Tier.Can be forged as<color=#09b005>%s</color>", nextcastcfg.order, nextcastcfg.name)
	else
		self.nexttip.text = "Max level reached"
	end
	self:ShowRedDot()
end


function EquipCastItem:ShowRedDot()
	if not self.red_dot then
		self.red_dot = RedDot(self.transform)
		SetLocalPosition(self.red_dot.transform, 275, -19,0)
	end
	local show_red = self.model:IsNeedShowCastRedDotByEquip(self.data)
	SetVisible(self.red_dot, show_red)
end