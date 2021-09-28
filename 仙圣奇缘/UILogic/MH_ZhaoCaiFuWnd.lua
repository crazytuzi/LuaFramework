Game_ZhaoCaiFu = class("Game_ZhaoCaiFu")
Game_ZhaoCaiFu.__index = Game_ZhaoCaiFu

function Game_ZhaoCaiFu:getZCaiIndex(times)
	local nIndex = 1
	for k,v in ipairs(self.ZhaoCaiShenFuPrice) do
		if times >= v then
		else
			nIndex = v
			local CSV_ZhaoCaiShenFuPrice = g_DataMgr:getCsvConfigByOneKey("ZhaoCaiShenFuPrice", nIndex)
			return nIndex, CSV_ZhaoCaiShenFuPrice.NeedCoupons
		end
	end
	local CSV_ZhaoCaiShenFuPrice = g_DataMgr:getCsvConfigByOneKey("ZhaoCaiShenFuPrice", #self.ZhaoCaiShenFuPrice)
	return  #self.ZhaoCaiShenFuPrice, CSV_ZhaoCaiShenFuPrice.NeedCoupons
end

local function GetPageData(times)
	local ret = {}
	ret.countLeft =  times
	local wnd = g_WndMgr:getWnd("Game_ZhaoCaiFu")
	if wnd then
		local nIndex, couponCost = g_WndMgr:getWnd("Game_ZhaoCaiFu"):getZCaiIndex(times)
		ret.couponCost = couponCost
		local CSV_PlayerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp", times + 1)
		ret.coinGet = CSV_PlayerExp.ZhaoCaiCoins
	end
	return ret
end

function Game_ZhaoCaiFu:initWnd()
	self.rootWidget:addTouchEventListener(function(pSender,eventType)
        if eventType ==ccs.TouchEventType.ended then
			g_playSoundEffect("Sound/ButtonClick.mp3")
			g_WndMgr:closeWnd("Game_ZhaoCaiFu")
        end
	end)
	local Image_ZhaoCaiFuPNL = self.rootWidget:getChildByName("Image_ZhaoCaiFuPNL")
	Image_ZhaoCaiFuPNL:setTouchEnabled(true)
	local Image_SymbolBlueLight = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	Image_SymbolBlueLight:removeAllNodes()
	
	local armature,energyAnimation = g_CreateCoCosAnimation("ZhaoCaiTongQian", nil, 2)
	armature:setScale(0.6)
	Image_SymbolBlueLight:addNode(armature, 2, 0)
	energyAnimation:playWithIndex(0)
	
	local Button_ZhaoCai = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Button_ZhaoCai"), "Button")
	local function onClickZhaoCai()
		g_MsgMgr:requestActivity(6)
	end
	g_SetBtnWithGuideCheck(Button_ZhaoCai, 1, onClickZhaoCai, true)
	self.Button_ZhaoCai = Button_ZhaoCai
	
	self.ZhaoCaiShenFuPrice = {}
	local CSV_ZhaoCaiShenFuPrice = g_DataMgr:getCsvConfig("ZhaoCaiShenFuPrice")
	for k,v in pairs(CSV_ZhaoCaiShenFuPrice) do
		table.insert(self.ZhaoCaiShenFuPrice, k)
	end
	table.sort(self.ZhaoCaiShenFuPrice)
	
	local Image_SymbolBlueLight = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_SymbolBlueLight"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	
	local Image_SymbolOutside = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_SymbolOutside"), "ImageView")
	local Image_SymbolInside = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_SymbolInside"), "ImageView")
	
	local actionRotateTo_SymbolOutside = CCRotateBy:create(45, -360) 
	local actionForever_SymbolOutside = CCRepeatForever:create(actionRotateTo_SymbolOutside)
	Image_SymbolOutside:runAction(actionForever_SymbolOutside)
	
	local actionRotateTo_SymbolInside = CCRotateBy:create(45, 360) 
	local actionForever_SymbolInsidet = CCRepeatForever:create(actionRotateTo_SymbolInside)
	Image_SymbolInside:runAction(actionForever_SymbolInsidet)
	
	local Button_ZhaoCaiGuide = tolua.cast(self.rootWidget:getChildByName("Button_ZhaoCaiGuide"), "Button")
	g_RegisterGuideTipButtonWithoutAni(Button_ZhaoCaiGuide)
	
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getBackgroundJpgImg("Background_Money1"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getBackgroundPngImg("Background_Money2"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getBackgroundPngImg("Background_Money3"))
end

function Game_ZhaoCaiFu:openWnd()
	local nUseZhaoCaiNum = g_Hero.tbDailyNotice[macro_pb.Activity_ZhaoCai]
	local pageData = GetPageData(nUseZhaoCaiNum)
	if not pageData then return end
	
	self.coinGet = pageData.coinGet
	
	local CSV_PlayerExp = g_DataMgr:getCsvConfigByOneKey("PlayerExp", g_Hero:getMasterCardLevel())
	
	local Image_ZhaoCaiFuPNL = self.rootWidget:getChildByName("Image_ZhaoCaiFuPNL")
	
	local Image_Coupons = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_Coupons"), "ImageView")
	local Label_NeedCoupons = tolua.cast(Image_Coupons:getChildByName("Label_NeedCoupons"), "Label")
	Label_NeedCoupons:setText(pageData.couponCost)
	
	local Image_Coins = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_Coins"), "ImageView")
	local Label_GetCoins = tolua.cast(Image_Coins:getChildByName("Label_GetCoins"), "Label")
	Label_GetCoins:setText(CSV_PlayerExp.ZhaoCaiCoins)

	local Image_VIPLevel = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Image_VIPLevel"), "ImageView")
	Image_VIPLevel:loadTexture(getShopMallImg("VIP"..g_VIPBase:getVIPLevelId()))
	
	local Label_RemainNum = tolua.cast(Image_ZhaoCaiFuPNL:getChildByName("Label_RemainNum"), "Label")
	Label_RemainNum:setText(nUseZhaoCaiNum)
	local RemainSize = Label_RemainNum:getSize()
	
	local ZhaoCaiMaxNum = g_Hero:getVIPLevelMaxNumZhaoCai()
	local Label_RemainNumMax = tolua.cast(Label_RemainNum:getChildByName("Label_RemainNumMax"), "Label")
	Label_RemainNumMax:setText("/"..ZhaoCaiMaxNum)
	Label_RemainNumMax:setPosition(ccp(RemainSize.width,0))
	
	local bEnable = true
	if nUseZhaoCaiNum ==  ZhaoCaiMaxNum then
		bEnable = false
		Label_RemainNum:setColor(ccc3(255,0,0))
	else
		Label_RemainNum:setColor(ccc3(0,255,0))
	end
	
	if g_Hero:getYuanBao() < pageData.couponCost then
		bEnable = false
		Label_NeedCoupons:setColor(ccc3(255,0,0))
	else
		Label_NeedCoupons:setColor(ccc3(0,255,0))
	end
	g_SetBtnEnable(self.Button_ZhaoCai, bEnable)
end

function Game_ZhaoCaiFu:checkData()
	if not g_CheckFuncCanOpenByWidgetName("Button_ZhaoCai") then		
		local nOpenLevel = getFunctionOpenLevelCsvByStr("Button_ZhaoCai").OpenLevel
		local strOpenFuncName = getFunctionOpenLevelCsvByStr("Button_ZhaoCai").OpenFuncName
		local nOpenVipLevel = getFunctionOpenLevelCsvByStr("Button_ZhaoCai").OpenVipLevel
		if nOpenLevel <= 200 then
			if nOpenVipLevel >= 1 then
				g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
				return false
			else
				g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
				return false
			end
		else
			g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
			return false
		end
	end
	return true
end

function Game_ZhaoCaiFu:closeWnd()
	local ImageView_Background1 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background1"), "ImageView")
	ImageView_Background1:loadTexture(getUIImg("Blank"))
	local ImageView_Background2 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background2"), "ImageView")
	ImageView_Background2:loadTexture(getUIImg("Blank"))
	local ImageView_Background3 = tolua.cast(self.rootWidget:getChildByName("ImageView_Background3"), "ImageView")
	ImageView_Background3:loadTexture(getUIImg("Blank"))
end

function Game_ZhaoCaiFu:ModifyWnd_viet_VIET()
    local Label_RemainNumLB = self.rootWidget:getChildAllByName("Label_RemainNumLB")
	local Label_RemainNum = self.rootWidget:getChildAllByName("Label_RemainNum")
	local Label_RemainNumMax = self.rootWidget:getChildAllByName("Label_RemainNumMax")
    g_AdjustWidgetsPosition({Label_RemainNumLB, Label_RemainNum, Label_RemainNumMax},1)
end