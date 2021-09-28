require "Core.Module.Common.UIItem"
local CashGiftsItem = class("CashGiftsItem", UIItem)
local BaseIconWithNumItem = require "Core.Module.Common.BaseIconWithNumItem"

function CashGiftsItem:New()
	self = {};
	setmetatable(self, {__index = CashGiftsItem});
	return self
end

function CashGiftsItem:_Init()
	self._baseIconItem = BaseIconWithNumItem:New()
	self._baseIconItem:Init(self.transform)
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtDes = UIUtil.GetChildByName(self.transform, "UILabel", "des")
	self._trshadCharge = UIUtil.GetChildByName(self.transform, "hadCharge")
	self._btnCharge = UIUtil.GetChildByName(self.transform, "UIButton", "btncharge")
	self._txtChargeLabel = UIUtil.GetChildByName(self._btnCharge, "UILabel", "chargeLabel")	
	self:_AddBtnListen(self._btnCharge.gameObject)
end

function CashGiftsItem:_Dispose()
	self._baseIconItem:Dispose()
	self._baseIconItem = nil
end

function CashGiftsItem:_OnBtnsClick(go)
	if go == self._btnCharge.gameObject then
		self:_OnClickBtnCharge()
	end
end

function CashGiftsItem:_OnClickBtnCharge()
	if(self.data) then
		VIPManager.SendCharge(self.data.recharge_id, CashGiftProxy.SendGetClashGiftsInfo)
	end
end

local _CashGiftsManager = CashGiftsManager
function CashGiftsItem:UpdateItem(data)
	self.data = data
	if(self.data) then
		self._baseIconItem:UpdateItem(self.data.showItem)
		self._txtName.text = self.data.showItem.name
		self._txtDes.text = self.data.product_show
		self._txtChargeLabel.text = self.data.product_name
		if(_CashGiftsManager.GetTimeByChargeId(self.data.recharge_id) > 0) then
			self._btnCharge.gameObject:SetActive(false)
			SetUIEnable(self._trshadCharge, true)
		else
			self._btnCharge.gameObject:SetActive(true)
			SetUIEnable(self._trshadCharge, false)			
		end
	end
end

return CashGiftsItem 