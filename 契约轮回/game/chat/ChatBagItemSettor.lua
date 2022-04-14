--
-- @Author: chk
-- @Date:   2018-09-04 20:40:28
--
ChatBagItemSettor = ChatBagItemSettor or class("ChatBagItemSettor",BaseBagIconSettor)
local ChatBagItemSettor = ChatBagItemSettor

function ChatBagItemSettor:ctor(parent_node,layer)
	self.abName = "system"
	self.assetName = "BagItem"
	self.layer = layer

	
	ChatBagItemSettor.super.Load(self)
end

function ChatBagItemSettor:AddEvent()
	ChatBagItemSettor.super.AddEvent(self)

	AddClickEvent(self.touch.gameObject,handler(self,self.ClickEvent))
end

function ChatBagItemSettor:ClickEvent( )
	if self.uid ~= nil and not self.is_multy_selet then
		if self.model.baseGoodSettorCLS ~= nil then
			self.model.baseGoodSettorCLS:SetSelected(false)
		end

		self:SetSelected(true)
		self.model.baseGoodSettorCLS = self

		--没有外面的回调，默认请求背包的物品信息
		if self.click_call_back ~= nil then
			self.click_call_back(self.__item_index)
		end
	end
end

function ChatBagItemSettor:DealGoodsDetailInfo(...)

end

