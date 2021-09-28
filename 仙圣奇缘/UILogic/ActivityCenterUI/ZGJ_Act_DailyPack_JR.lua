--------------------------------------------------------------------------------------
-- 文件名:	XXX.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-6-8
-- 版  本:	1.0
-- 描  述:	开服活跃活动
-- 应  用:  
---------------------------------------------------------------------------------------
Act_DailyPack_JR = class("Act_DailyPack_JR",Act_Template)
Act_DailyPack_JR.__index = Act_Template

Act_DailyPack_JR.prefix = "VIP"
Act_DailyPack_JR.szImage_RewardStatus = "Image_BuyStatus"

--override
function Act_DailyPack_JR:onClickGainReward(pSender, eventType)
	if eventType == ccs.TouchEventType.ended then
		local cost = self.tbItemList[pSender:getTag()]["ActivityPrice"]
		if not g_CheckYuanBaoConfirm(cost, _T("购买VIP特权礼包需要消耗")..tostring(cost).._T("元宝")) then
			return
		end
		local str = _T("是否花费")..tostring(cost).._T("元宝购买？")
		g_ClientMsgTips:showConfirm(str, function() 
			self.super.onClickGainReward(self, pSender, eventType)
		end)
	end
end

--override
function Act_DailyPack_JR:setPanelItem(widget, nIndex)
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

    --当前购买次数
    local Label_Remain = tolua.cast(Button_Activety:getChildByName("Label_Remain"), "Label")
    local cur_buy = g_act:getActValueByID(self.nActivetyID)
    local strTip = string.format(_T("剩余:%d/%d"), cur_buy[self.tbItemList[nIndex]["ID"]], self.tbItemList[nIndex]["LimitCount"])
    Label_Remain:setText(strTip)
end

--override
function Act_DailyPack_JR:isEnable(id)
	self.nActivetyID = id
	self.tbMissions = g_act:getMissionsByID(id)
	if not self.tbMissions then
		return false
	else
		for i = 1, #self.tbMissions do
			if ActState.INVALID ~= self.tbMissions[i] then
				self.tbMissions[i] = ActState.FINISHED
			end
		end
		return true
	end
end