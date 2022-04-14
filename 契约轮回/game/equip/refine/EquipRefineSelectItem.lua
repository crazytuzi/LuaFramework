EquipRefineSelectItem = EquipRefineSelectItem or class("EquipRefineSelectItem",BaseCloneItem)
local EquipRefineSelectItem = EquipRefineSelectItem

function EquipRefineSelectItem:ctor(obj,parent_node,layer)
	EquipRefineSelectItem.super.Load(self)
end

function EquipRefineSelectItem:dctor()
	if self.goodsitem then
		self.goodsitem:destroy()
		self.goodsitem = nil
	end
	self.model:RemoveTabListener(self.events)
end

function EquipRefineSelectItem:LoadCallBack()
	self.nodes = {
		"icon", "name", "phase", "select"
	}
	self.model = EquipRefineModel.GetInstance()
	self:GetChildren(self.nodes)
	self.name = GetText(self.name)
	self.phase = GetText(self.phase)
	self:AddEvent()
end

function EquipRefineSelectItem:AddEvent()
	self.events = self.events or {}
	local function call_back(target,x,y)
		self.model.select_itemid = self.item_id
		self.model:Brocast(EquipEvent.SelectRefineMateria, self.item_id)
	end
	AddClickEvent(self.gameObject,call_back)


	local function call_back(item_id)
		SetVisible(self.select, item_id == self.item_id)
	end
	self.events[#self.events+1] = self.model:AddListener(EquipEvent.SelectRefineMateria, call_back)
end

function EquipRefineSelectItem:SetData(item_id, num)
	self.item_id = item_id
	self.num = num
	if self.is_loaded then
		self:UpdateView()
	end
end

function EquipRefineSelectItem:UpdateView()
	if not self.goodsitem then
		self.goodsitem = GoodsIconSettorTwo(self.icon)
	end
	local param = {}
	param["item_id"] = self.item_id
	param["size"] = {x = 70, y=70}
	param["bind"] = 2
	param["can_click"] = false 
	local num_str = ""
	if self.num > 0 then
		num_str = string.format("%s/1", self.num)
	else
		num_str = string.format("%s/1", ColorUtil.GetHtmlStr(enum.COLOR.COLOR_RED, self.num))
	end
	param["num"] = num_str
	self.goodsitem:SetIcon(param)
	if self.num > 0 then
		self.goodsitem:SetIconNormal()
	else
		self.goodsitem:SetIconGray()
	end
	if self.model.select_itemid == self.item_id then
		SetVisible(self.select, true)
	else
		SetVisible(self.select, false)
	end
	local itemcfg = Config.db_item[self.item_id]
	self.name.text = itemcfg.name
	self.phase.text = itemcfg.useway
end