BagSmeltItem = BagSmeltItem or class("BagSmeltItem",BaseItem)
local BagSmeltItem = BagSmeltItem

function BagSmeltItem:ctor(parent_node,layer)
	self.abName = "bag"
	self.assetName = "BagSmeltItem"
	self.layer = layer

	self.model = BagModel:GetInstance()
	BagSmeltItem.super.Load(self)
end

function BagSmeltItem:dctor()
	if self.goodsItem then
		self.goodsItem:destroy()
		self.goodsItem = nil
	end
	self.model = nil
end

function BagSmeltItem:LoadCallBack()
	self.nodes = {
		"item","select",
	}
	self:GetChildren(self.nodes)
	self:AddEvent()
	self:UpdateView()
end

function BagSmeltItem:AddEvent()
	local function call_back(target,x,y)
		if not self.data then
			return
		end
		if self.selected then
			self:Select(false)
		else
			self:Select(true)
		end
		self.model:Brocast(BagEvent.SmeltItemClick, self.data)
	end
	AddClickEvent(self.item.gameObject,call_back)
end

--data:p_item_base
function BagSmeltItem:SetData(data, selected, StencilId)
	self.data = data
	self.selected = selected
	self.StencilId = StencilId
	if self.is_loaded then
		self:UpdateView()
	end
end

function BagSmeltItem:GetData()
	return self.data
end

function BagSmeltItem:UpdateView()
	if self.goodsItem then
		self.goodsItem:destroy()
	end
	if self.data then
		local param = {}
		param["model"] = self.model
		param["item_id"] = self.data.id
		param["p_item_base"] = self.data
		param["color_effect"] = enum.COLOR.COLOR_PINK
		param["stencil_id"] = self.StencilId
		param["stencil_type"] = 3
		param["num"] = self.data.num
		param["p_item"] = self.data
		local cfg = Config.db_soul[self.data.id]
		if cfg and cfg.slot ~= 0 then
			param["lv"] = self.data.extra
			param["bind"] = 2
		end

		--宠物装备分解界面的item
		local item_cfg = Config.db_item[self.data.id]
		if item_cfg and item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP and  self.data.misc and  self.data.misc.stren_phase then
			cfg = Config.db_pet_equip[self.data.id .. "@" .. self.data.misc.stren_phase]
			param["cfg"] = cfg
			param["stren_lv"] =  self.data.misc.stren_lv
		end
		

		self.goodsItem = GoodsIconSettorTwo(self.item)
	    self.goodsItem:SetIcon(param)
	else
		self.goodsItem = GoodsIconSettorTwo(self.item)

	end
    SetVisible(self.select, self.selected)
end

function BagSmeltItem:Select(flag)
	SetVisible(self.select, flag)
	self.selected = flag
end

