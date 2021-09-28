--------------------------------------------------------------------------------------
-- 文件名:	WJQ_JuXianGe.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2014-12-10 10:24
-- 版  本:	1.0
-- 描  述:	活动界面
-- 应  用:  本例子使用一般方法的实现Scene
---------------------------------------------------------------------------------------

Game_FirstCharge = class("Game_FirstCharge")
Game_FirstCharge.__index = Game_FirstCharge

function Game_FirstCharge:initWnd()
	local CSV_ActivityOnlineRechargeTimeReward = g_DataMgr:getCsvConfigByOneKey("ActivityOnlineRechargeTimeReward", 1)
	local CSV_DropSubPackClient = g_DataMgr:getCsvConfig_SecondKeyTableData("DropSubPackClient", CSV_ActivityOnlineRechargeTimeReward.DropClientID)

	local Image_FirstChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_FirstChargePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_FirstChargePNL:getChildByName("Image_ContentPNL"), "ImageView")
	for i = 1, 4 do
		local Image_DropResource = tolua.cast(Image_ContentPNL:getChildByName("Image_DropResource"..i), "ImageView")
		local itemModel = g_CloneDropItemModel(CSV_DropSubPackClient[i])
		itemModel:setPositionXY(0,0)
		Image_DropResource:addChild(itemModel)
		
		local function onClick_ItemModel(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_ShowDropItemTip(CSV_DropSubPackClient[i])
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick_ItemModel)
	end
	
	local Button_Charge = tolua.cast(Image_ContentPNL:getChildByName("Button_Charge"), "ImageView")
	local function onClick_Button_Charge(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			g_WndMgr:openWnd("Game_ReCharge")
		end
	end
	Button_Charge:setTouchEnabled(true)
	Button_Charge:addTouchEventListener(onClick_Button_Charge)
end

function Game_FirstCharge:openWnd()
	local Image_FirstChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_FirstChargePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_FirstChargePNL:getChildByName("Image_ContentPNL"), "ImageView")
	local Button_Charge = tolua.cast(Image_ContentPNL:getChildByName("Button_Charge"), "ImageView")
	
	local tbMissions = g_act:getMissionsByID(common_pb.AOLT_RECHARD_COUNT) or {ActState.INVALID}
	local nStatus = tbMissions[1]
	if ActState.DOING == nStatus then --未充值
		local BitmapLabel_FuncName = tolua.cast(Button_Charge:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setText(_T("充值"))
		Button_Charge:setTouchEnabled(true)
		Button_Charge:setBright(true)
		local function onClick_Button_Charge(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_WndMgr:openWnd("Game_ReCharge")
			end
		end
		Button_Charge:addTouchEventListener(onClick_Button_Charge)
	elseif ActState.FINISHED == nStatus then --已充值未领取礼包
		local BitmapLabel_FuncName = tolua.cast(Button_Charge:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setText(_T("领取"))
		Button_Charge:setTouchEnabled(true)
		Button_Charge:setBright(true)
		local function onClick_Button_Charge(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				--打开RewardBox
				g_act:rewardRequest(common_pb.AOLT_RECHARD_COUNT, 1)
			end
		end
		Button_Charge:addTouchEventListener(onClick_Button_Charge)
	elseif ActState.INVALID == nStatus then
		local BitmapLabel_FuncName = tolua.cast(Button_Charge:getChildByName("BitmapLabel_FuncName"), "LabelBMFont")
		BitmapLabel_FuncName:setText(_T("已领取"))
		Button_Charge:setTouchEnabled(false)
		Button_Charge:setBright(false) --已充值已领取礼包
	end
end

function Game_FirstCharge:closeWnd()

end

function Game_FirstCharge:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_FirstChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_FirstChargePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_FirstChargePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
	mainWnd:showMainHomeZoomInAnimation()
end

function Game_FirstCharge:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_FirstChargePNL = tolua.cast(self.rootWidget:getChildByName("Image_FirstChargePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
		mainWnd:showMainHomeZoomOutAnimation()
	end
	g_CreateUIDisappearAnimation_Scale(Image_FirstChargePNL, actionEndCall, 1.05, 0.15, Image_Background)
end