local BaseIconItem= require "Core.Module.Common.BaseIconItem"
local RideFeedItem = class("RideFeedItem", BaseIconItem);

function RideFeedItem:New()
	self = {};
	setmetatable(self, {__index = RideFeedItem});
	return self
end

function RideFeedItem:_InitOther()
	self._isSelect = false
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "num")
	self._goCheck = UIUtil.GetChildByName(self.transform, "goCheck").gameObject
end

function RideFeedItem:UpdateItem(data)
	self.data = data
	if(self.data) then	
		ProductManager.SetIconSprite(self._imgIcon, self.data:GetIcon_id())
		self._imgQuality.color = ColorDataManager.GetColorByQuality(self.data:GetQuality())
        self:_UpdateOther()
	end

end

function RideFeedItem:_UpdateOther()
	self._isSelect = RideProxy.IsMaterialSelect(self.data.id)
	self._goCheck:SetActive(self._isSelect)
	self._txtNum.text = self.data.am
end

function RideFeedItem:_OnClickIcon()
  
	self._isSelect = not self._isSelect
    self._goCheck:SetActive(self._isSelect)
	if(self._isSelect) then
		RideProxy.AddRideFeedMaterial(self.data.id,self.data.spId,self.data.am)
	else
		RideProxy.RemoveRideFeedMaterial(self.data.id)
	end

    MessageManager.Dispatch(RideNotes, RideNotes.MESSAGE_FEEDMATERIALS_CHANGE);
    	
end 

return RideFeedItem