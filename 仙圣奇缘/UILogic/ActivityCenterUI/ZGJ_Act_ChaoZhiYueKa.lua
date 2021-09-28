Act_ChaoZhiYueKa = class("Act_ChaoZhiYueKa",Act_Template)
Act_ChaoZhiYueKa.__index = Act_Template

function Act_ChaoZhiYueKa:init(panel)
	local Image_ContentPNL1 = panel:getChildByName("Image_ContentPNL1")
	
	local function onClick(pSender, nTag)
		local tbParam = {
			OpenType = "PuTongYueKa",
			ListViewIndex = 1
		}
		if 2 == nTag then
			tbParam.OpenType = "GaoJiYueKa"
		end
		g_WndMgr:openWnd("Game_ReCharge", tbParam)
	end

    local shop_recharge = ConfigMgr["ShopRecharge"]
    local shop_30yueka
    local shop_68yueka
    for i,v in pairs(shop_recharge) do
        if v["FunctionType"] == 2 then
            shop_30yueka = v    
        elseif v["FunctionType"] == 3 then
            shop_68yueka = v    
        end
    end
    
	local Button_YueKa1 = tolua.cast(Image_ContentPNL1:getChildByName("Button_YueKa1"),"Button")
	g_SetBtnWithPressImage(Button_YueKa1, 1, onClick, true, 1)
    if shop_30yueka then
        local YueKa1_name = tolua.cast(Button_YueKa1:getChildByName("Image_FuncName"),"ImageView")
        YueKa1_name:loadTexture(getShopMallImg(shop_30yueka["Title"]))

        local Image_ReturnYuanBao = Button_YueKa1:getChildByName("Image_ReturnYuanBao")
        local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"), "Label")
        Label_FirstChargeReturn:setText(shop_30yueka["Desc"])

        local YueKa1_explain = Button_YueKa1:getChildByName("Image_Mask")
        local YueKa1_curYuanbao = tolua.cast(YueKa1_explain:getChildByName("Label_Desc1"), "Label")
        local strTip = string.format(_T("购买立即获得%d元宝"), shop_30yueka["SellNum"])
        YueKa1_curYuanbao:setText(strTip)
        local YueKa1_everyDayYuanbao = tolua.cast(YueKa1_explain:getChildByName("Label_Desc2"), "Label")
        strTip = string.format(_T("30天内每天领取%d元宝"), ConfigMgr["ActivityReward"][3][1]["ShowRewardValue"])
        YueKa1_everyDayYuanbao:setText(strTip) 
    end
    

	local Button_YueKa2 =  tolua.cast(Image_ContentPNL1:getChildByName("Button_YueKa2"),"Button")
	g_SetBtnWithPressImage(Button_YueKa2, 2, onClick, true, 1)
    if shop_68yueka then
        local YueKa2_name = tolua.cast(Button_YueKa2:getChildByName("Image_FuncName"),"ImageView")
        YueKa2_name:loadTexture(getShopMallImg(shop_68yueka["Title"]))

        local Image_ReturnYuanBao = Button_YueKa2:getChildByName("Image_ReturnYuanBao")
        local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"), "Label")
        Label_FirstChargeReturn:setText(shop_68yueka["Desc"])

        local YueKa2_explain = Button_YueKa2:getChildByName("Image_Mask")
        local YueKa2_curYuanbao = tolua.cast(YueKa2_explain:getChildByName("Label_Desc1"), "Label")
        local strTip = string.format(_T("购买立即获得%d元宝"), shop_68yueka["SellNum"])
        YueKa2_curYuanbao:setText(strTip)
        local YueKa2_everyDayYuanbao = tolua.cast(YueKa2_explain:getChildByName("Label_Desc2"), "Label")
        strTip = string.format(_T("30天内每天领取%d元宝"), ConfigMgr["ActivityReward"][4][1]["ShowRewardValue"])
        YueKa2_everyDayYuanbao:setText(strTip)
    end

	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		local Label_Tip = tolua.cast(Button_YueKa1:getChildAllByName("Label_Tip"),"Label")
		Label_Tip:setFontSize(16)
		local Image_ReturnYuanBao = Button_YueKa1:getChildAllByName("Image_ReturnYuanBao")
		Image_ReturnYuanBao:setScaleX(1.2)
		local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"),"Label")
		Label_FirstChargeReturn:setFontSize(16)
		Label_FirstChargeReturn:setScaleX(1/1.2)
		local CCNode_FirstChargeReturn = tolua.cast(Label_FirstChargeReturn:getVirtualRenderer(), "CCLabelTTF")
		CCNode_FirstChargeReturn:disableShadow(true)
	
		local Label_Tip = tolua.cast(Button_YueKa2:getChildAllByName("Label_Tip"),"Label")
		Label_Tip:setFontSize(16)
		local Image_ReturnYuanBao = Button_YueKa2:getChildAllByName("Image_ReturnYuanBao")
		Image_ReturnYuanBao:setScaleX(1.2)
		local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"),"Label")
		Label_FirstChargeReturn:setFontSize(16)
		Label_FirstChargeReturn:setScaleX(1/1.2)
		local CCNode_FirstChargeReturn = tolua.cast(Label_FirstChargeReturn:getVirtualRenderer(), "CCLabelTTF")
		CCNode_FirstChargeReturn:disableShadow(true)
	else
		local Image_ReturnYuanBao = Button_YueKa1:getChildAllByName("Image_ReturnYuanBao")
		local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"),"Label")
		local CCNode_FirstChargeReturn = tolua.cast(Label_FirstChargeReturn:getVirtualRenderer(), "CCLabelTTF")
		CCNode_FirstChargeReturn:disableShadow(true)
		
		local Image_ReturnYuanBao = Button_YueKa2:getChildAllByName("Image_ReturnYuanBao")
		local Label_FirstChargeReturn = tolua.cast(Image_ReturnYuanBao:getChildByName("Label_FirstChargeReturn"),"Label")
		local CCNode_FirstChargeReturn = tolua.cast(Label_FirstChargeReturn:getVirtualRenderer(), "CCLabelTTF")
		CCNode_FirstChargeReturn:disableShadow(true)
	end

    g_act:resetBubbleById(self.nActivetyID) --重置可领取奖励个数
end

--活动是否有效
function Act_ChaoZhiYueKa:isEnable(id)
    self.nActivetyID = id
	return true
end
