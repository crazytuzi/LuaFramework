--
-- @Author: LaoY
-- @Date:   2018-12-14 22:02:50
--
GiftSelectItem = GiftSelectItem or class("GiftSelectItem",BaseCloneItem)
local GiftSelectItem = GiftSelectItem

function GiftSelectItem:ctor(obj,parent_node,layer)
	GiftSelectItem.super.Load(self)
end

function GiftSelectItem:dctor()
	if self.reward_item then
		self.reward_item:destroy()
		self.reward_item = nil
	end
end

function GiftSelectItem:LoadCallBack()
	self.nodes = {
		"con","img_sel","click"
	}
	self:GetChildren(self.nodes)

	self.reward_item = GoodsIconSettorTwo(self.con)
	--self.reward_item:UpdateSize(76)
	SetVisible(self.img_sel, false)
	self:AddEvent()
end

function GiftSelectItem:AddEvent()
	local function call_back(target,x,y)
		if self.select_flag then
			self.reward_item:ClickCallBack(ClickGoodsIconEvent.Click.DIRECT_SHOW_CFG)
		else
			if self.call_back then
				self.call_back(self.index)
			end
		end
	end
	AddClickEvent(self.click.gameObject,call_back)
end

function GiftSelectItem:SetCallBack(call_back)
	self.call_back = call_back
end

function GiftSelectItem:SetSelectState(flag)
	if self.select_flag == flag then
		return
	end
	self.select_flag = flag
	SetVisible(self.img_sel,self.select_flag)
end

function GiftSelectItem:GetItemID()
	local id = self.data and self.data[1]
	if id and type(id) == "table" then
		local sex = RoleInfoModel:GetInstance():GetRoleValue("gender")
		id = id[sex]
	end
	return id
end

function GiftSelectItem:SetData(index,data)
	self.index = index
	self.data = data
	local param = {}
	param["model"] = GoodsModel:GetInstance()
	param["item_id"] = data[1]
	param["num"] = data[2]
	param["size"] = {x=76,y=76}
	param["can_click"] = true;
    param["bind"] = data[3] == 2;
	self.reward_item:SetIcon(param)
	--self.reward_item:UpdateIconByItemId(data[1],data[2])
end