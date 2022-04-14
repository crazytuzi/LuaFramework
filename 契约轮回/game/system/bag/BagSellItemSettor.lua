--
-- @Author: chk
-- @Date:   2018-09-02 06:22:37
--
BagSellItemSettor = BagSellItemSettor or class("BagSellItemSettor",BaseBagIconSettor)
local BagSellItemSettor = BagSellItemSettor

function BagSellItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "BagSellItem"
	self.layer = layer

	self.events = {}
	BagSellItemSettor.super.Load(self)
end


function BagSellItemSettor:LoadCallBack()
	self.nodes = {
		"lockIcon",
	}

	self:GetChildren(self.nodes)

	BagSellItemSettor.super.LoadCallBack(self)

	SetVisible(self.lockIcon, false)
end

function BagSellItemSettor:AddEvent()
	self.events[#self.events + 1] = self.model:AddListener(BagEvent.OpenCell, handler(self, self.ResponeOpenCell))
	self.globalEvents[#self.globalEvents+1] = GlobalEvent:AddListener(GoodsEvent.DelItems,handler(self,self.DelItem))

	AddButtonEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

function BagSellItemSettor:ClickEvent()
	BagSellItemSettor.super.ClickEvent(self)
	if self.lockIcon.gameObject.activeInHierarchy then
		self.model:Brocast(BagEvent.OpenCellView, self.bag, self.__item_index)
	end
end

function BagSellItemSettor:SetData(data)

end

--接收到打开格子的通知，处理
function BagSellItemSettor:ResponeOpenCell(bagId, index)
	if bagId == self.bag and self.__item_index == index then
		SetVisible(self.lockIcon, false)
		RemoveClickEvent(self.gameObject)
	end
end
