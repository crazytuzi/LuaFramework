--
-- @Author: LaoY
-- @Date:   2018-12-14 19:58:17
--
GiftMulItem = GiftMulItem or class("GiftMulItem",BaseCloneItem)
local GiftMulItem = GiftMulItem

function GiftMulItem:ctor(obj,parent_node,layer)
	GiftMulItem.super.Load(self)
end

function GiftMulItem:dctor()
	if self.item_list ~= nil then
		for i, v in pairs(self.item_list ) do
			v:destroy()
		end
	end

	self.item_list = nil
end

function GiftMulItem:LoadCallBack()
	self.nodes = {
		"img_bg","scroll","text_cost","scroll/Viewport/Content","btn_go","img_gift_box"
	}
	self:GetChildren(self.nodes)
	self.text_cost_component = self.text_cost:GetComponent('Text')
	self.img_bg_component = self.img_bg:GetComponent('Image')
	self.img_gift_box_component = self.img_gift_box:GetComponent('Image')
	self:AddEvent()
end

function GiftMulItem:AddEvent()
	local function call_back(target,x,y)
		if self.cost_number and RoleInfoModel:GetInstance():CheckGold(self.cost_number,self.cost_id) then
			-- GoodsController:GetInstance():RequestUseGoods(self.uid,self.number,{self.gift_id})
			GoodsController:GetInstance():RequestUseGoods(self.uid,1,{self.gift_id})
		end
	end
	AddClickEvent(self.btn_go.gameObject,call_back)
end

function GiftMulItem:SetData(index,gift_id,uid,number)
	self.index = index
	self.gift_id = gift_id
	self.uid = uid
	self.number = number
	self:SetRes()
	self:SetBoxRes()
	local gift_config = Config.db_item_gift[self.gift_id]
	if not gift_config then
		return
	end
	self.gift_config = gift_config
	local cost_config = String2Table(gift_config.cost)
	local cost_id = cost_config[1]
	if not cost_id then
		return
	end
	self.cost_id = cost_id
	local cost_number = cost_config[2]
	self.cost_number = cost_number

	local item_config = Config.db_item[self.cost_id] or {}
	local str
	if self.cost_number == 0 then
		str = "f"
	else
		str = string.format("%sg",self.cost_number)
	end
	self.text_cost_component.text = str

	self.item_list = self.item_list or {}
	local list = String2Table(gift_config.reward)
	local len = #list
	for i=1, len do
		local item = self.item_list[i]
		if not item then
			item = GoodsIconSettorTwo(self.Content)
			self.item_list[i] = item
		else
			item:SetVisible(true)
		end
		local info = list[i]
		local param = {}
		param["model"] = GoodsModel.GetInstance()
		param["item_id"] = info[1]
		param["num"] = info[2]
		param["can_click"] = true
		item:SetIcon(param)
		--item:UpdateIconByItemIdClick(info[1],info[2])
	end
	for i=len+1,#self.item_list do
		local item = self.item_list[i]
		item:SetVisible(false)
	end
end

function GiftMulItem:SetRes()
	local assetName = "img_gift_sel_bg_" .. self.index
	if self.assetName == assetName then
		return
	end
	self.assetName = assetName
	local abName = "goods_image"
	lua_resMgr:SetImageTexture(self,self.img_bg_component, abName, assetName,true)
end

function GiftMulItem:SetBoxRes()
	local assetName = "img_gift_box_bg_" .. self.index
	if self.box_assetName == assetName then
		return
	end
	self.box_assetName = assetName
	local abName = "goods_image"
	lua_resMgr:SetImageTexture(self,self.img_gift_box_component, abName, assetName,true)
end