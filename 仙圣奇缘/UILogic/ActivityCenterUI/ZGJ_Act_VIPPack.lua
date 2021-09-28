Act_VIPPack = class("Act_VIPPack",Act_Template)
Act_VIPPack.__index = Act_Template

Act_VIPPack.prefix = "VIP"
Act_VIPPack.szImage_RewardStatus = "Image_BuyStatus"

--override
function Act_VIPPack:onClickGainReward(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		local cost = self.tbItemList[pSender:getTag()]["ActivityPrice"]
		if not g_CheckYuanBaoConfirm(cost, _T("购买VIP特权礼包需要消耗")..tostring(cost).._T("元宝")) then
			return
		end
		local str = _T("是否花费")..tostring(tostring(cost).._T("元宝购买？"))
		g_ClientMsgTips:showConfirm(str, function() 
			self.super.onClickGainReward(self, pSender, eventType)
		end)
	end
end

--override
function Act_VIPPack:setPanelItem(widget, nIndex)
	self.super.setPanelItem(self, widget, nIndex)

	local Button_Activety = tolua.cast(widget:getChildByName("Button_Activety"), "Button")
	local Image_OldPrice = Button_Activety:getChildByName("Image_OldPrice")
	local Label_OldPrice = tolua.cast(Image_OldPrice:getChildByName("Label_OldPrice"), "Label")
	Label_OldPrice:setText(self.tbItemList[nIndex]["ActivityOldPrice"])
	local Image_Price = Button_Activety:getChildByName("Image_Price")
	local Label_NewPrice = tolua.cast(Image_Price:getChildByName("Label_NewPrice"), "Label")
	Label_NewPrice:setText(self.tbItemList[nIndex]["ActivityPrice"])
	local BitmapLabel_Discount = tolua.cast(Button_Activety:getChildByName("BitmapLabel_Discount"), "LabelBMFont")
	BitmapLabel_Discount:setText(self.tbItemList[nIndex]["Discount"])
end

--override
function Act_VIPPack:isEnable(id)
	self.nActivetyID = id
	self.tbMissions = g_act:getMissionsByID(id)
	if not self.tbMissions then
		return false
	else
		for i = 1, #self.tbMissions do
			if self.tbItemList[i] and ActState.INVALID ~= self.tbMissions[self.tbItemList[i].ID] and self.tbItemList[i]["NeedValue"] <= g_VIPBase:getVIPLevelId() then
				self.tbMissions[self.tbItemList[i].ID] = ActState.FINISHED
			end
		end
		return true
	end
end