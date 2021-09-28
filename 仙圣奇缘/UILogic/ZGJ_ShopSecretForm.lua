--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	周光剑
-- 日  期:	2015-5-5
-- 版  本:	1.0
-- 描  述:	神秘商店Form
-- 应  用:  
---------------------------------------------------------------------------------------
Game_ShopSecret = class("Game_ShopSecret")
Game_ShopSecret.__index = Game_ShopSecret

function Game_ShopSecret:setAllItemTag()
	--优化因窗口缓存
	if self.ScrollView_ShopItemUp:getChildByTag(1) then
		return 
	end

	for i=1,5 do
		local shopItem = tolua.cast(self.ScrollView_ShopItemUp:getChildByName("Button_ShopItem"..i), "Button")
		shopItem:setTag(i)
	end
    for i=6,10 do
		local shopItem = tolua.cast(self.ScrollView_ShopItemDown:getChildByName("Button_ShopItem"..i), "Button")
		shopItem:setTag(i-5)
	end
end

function Game_ShopSecret:setAllItemInfo(flag)  --flag 0:全部重设 ; 1:只重设btnBuy
	--设置上排物品
	for i=1,5 do
		local info = g_shopSecret:getShopItemByIndex(i)
		local shopItem = tolua.cast(self.ScrollView_ShopItemUp:getChildByTag(i), "Button")
		self:setItemInfo(info,shopItem,flag)
	end
	--设置下排物品
	for i=6,10 do
		local info = g_shopSecret:getShopItemByIndex(i)
		local shopItem = tolua.cast(self.ScrollView_ShopItemDown:getChildByTag(i-5), "Button")
		self:setItemInfo(info,shopItem,flag)
	end
end

function Game_ShopSecret:setItemInfo(info,shopItem,flag)
	if not info then return end
	local btnBuy = shopItem:getChildByName("Button_Buy")
	
	if flag == 0 then
		local ItemIcon =shopItem:getChildByTag(1)
		if ItemIcon ~= nil then
			ItemIcon:removeFromParentAndCleanup(true)
		end
		ItemIcon, CSV_Base = g_CloneDropItemModel(info:getItemDropInfo())
		local pos = CCPoint(0,48)
		ItemIcon:setPosition(pos)
		ItemIcon:setScale(0.85)
		ItemIcon:setTag(1)
		local function onClick(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_ShowDropItemTip(info:getItemDropInfo())
			end
		end
		ItemIcon:setTouchEnabled(true)
		ItemIcon:addTouchEventListener(onClick)
		if shopItem ~= nil then
			shopItem:addChild(ItemIcon)
		end
		
		local currencyIcon = tolua.cast(btnBuy:getChildByName("Image_CurrencyIcon"), "ImageView")
		if currencyIcon ~= nil then
			currencyIcon:loadTexture(getUIImg(info:getItemIcon()))
		end
		
		local labelName = tolua.cast(shopItem:getChildByName("Label_Name"),"Label")
		if CSV_Base then
			labelName:setText(CSV_Base.Name)
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				labelName:setFontSize(16)
				labelName:setText(g_stringSize_insert(CSV_Base.Name, "\n", 16, 160))
			else
				labelName:setFontSize(21)
				labelName:setText(CSV_Base.Name)
			end
		end
	end
	--设置物品btnBuy的效果
	local Label_CurrencyValue = tolua.cast(btnBuy:getChildByName("Label_CurrencyValue"), "Label")
	if Label_CurrencyValue ~= nil then
		if info:isBought() == true  then
			btnBuy:setBright(false)
			btnBuy:setTouchEnabled(false)
			Label_CurrencyValue:setText(_T("已购买"))
			g_SetLabelRed(Label_CurrencyValue, false)
		else
			Label_CurrencyValue:setText(info:getNeedCurrencyNum())
			btnBuy:setBright(true)
			if info:isEnabelBuy() then
				g_SetLabelRed(Label_CurrencyValue, false)
				btnBuy:setTouchEnabled(true)
			else
				g_SetLabelRed(Label_CurrencyValue, true)
				btnBuy:setTouchEnabled(false)
			end
		end
	end
	btnBuy:addTouchEventListener(handler(self,self.OnClickBtnBuy))
	btnBuy:setTag(info:getID())
	btnBuy.needNum = info:getNeedCurrencyNum()
	btnBuy.comsumeType = info:getItemConsumeType()
	--设置新物品标签
	local newTag = shopItem:getChildByName("Image_NewTag")
	if info:isNew() == 1 then
		newTag:setVisible(true)
	else
		newTag:setVisible(false)
	end	
end 

--打开动画
function Game_ShopSecret:openAnimation()
    local function endAnim()
        self:CheckRefreshButton()
    end


	local pos1 = self.ScrollView_ShopItemUp:getPosition()
	local moveto = CCMoveTo:create(0.6,pos1)
	self.ScrollView_ShopItemUp:setPosition(CCPoint(-1020, 270))
	self.ScrollView_ShopItemUp:runAction(moveto)
	
	local pos2 = self.ScrollView_ShopItemDown:getPosition()
    local arrAct = CCArray:create()
	local moveto = CCMoveTo:create(0.6,pos2)
    local callFunc = CCCallFuncN:create(endAnim)
    arrAct:addObject(moveto)
    arrAct:addObject(callFunc)
    local action =  CCSequence:create(arrAct)
	self.ScrollView_ShopItemDown:setPosition(CCPoint(1020, 25))
	self.ScrollView_ShopItemDown:runAction(action)

end

function Game_ShopSecret:setCoolTime()
	if not self.rootWidget then return true end
	local Image_SecretShopPNL = tolua.cast(self.rootWidget:getChildByName("Image_SecretShopPNL"),"ImageView")
	local Image_CoolTime = tolua.cast(Image_SecretShopPNL:getChildByName("Image_CoolTime"),"ImageView")
	local Label_CoolTimeLB = tolua.cast(Image_CoolTime:getChildByName("Label_CoolTimeLB"),"Label")
	local Label_CoolTime = tolua.cast(Label_CoolTimeLB:getChildByName("Label_CoolTime"),"Label")
	local coolTime = g_shopSecret:getCoolTime()
	local strTimes = TimeTableToStr(SecondsToTable(coolTime),":")
    Label_CoolTime:setText(strTimes)
end

function Game_ShopSecret:initWnd()
	local Image_SecretShopPNL = tolua.cast(self.rootWidget:getChildByName("Image_SecretShopPNL"),"ImageView")
	local Image_CoolTime = tolua.cast(Image_SecretShopPNL:getChildByName("Image_CoolTime"),"ImageView")
	self.refreshButton = tolua.cast(Image_CoolTime:getChildByName("Button_RefreshByYuanBao"), "Button")
	self.refreshButton:addTouchEventListener(handler(self,self.OnClickBtnRefresh))
    self:CheckRefreshButton()
	
	local Panel_ShopCut = tolua.cast(Image_SecretShopPNL:getChildByName("Panel_ShopCut"),"Layout")
	self.ScrollView_ShopItemUp = tolua.cast(Panel_ShopCut:getChildByName("ScrollView_ShopItemUp"), "ListViewEx")
    self.ScrollView_ShopItemDown = tolua.cast(Panel_ShopCut:getChildByName("ScrollView_ShopItemDown"), "ListViewEx")
	self:RegistFormMessage()
	self:setAllItemTag()
	
	self:setCoolTime()
	self.nTimerID_Game_ShopSecret_1 = g_Timer:pushLoopTimer(1,function()
		if not g_WndMgr:getWnd("Game_ShopSecret") then return true end
		self:setCoolTime()
	end)

	self:setAllItemInfo(0)
	self:openAnimation()
	
	self.layer = Layout:create()
	self.layer:setSize(self.rootWidget:getSize())
	self.rootWidget:addChild(self.layer,INT_MAX)
	
    self:CheckRefreshButton()
	
	local Image_JiangHunTip = tolua.cast(self.rootWidget:getChildByName("Image_JiangHunTip"),"ImageView")
	g_CreateScaleInOutAction(Image_JiangHunTip)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("Shop"))
end

function Game_ShopSecret:openWnd()
end

function Game_ShopSecret:closeWnd(tbData)
	g_Timer:destroyTimerByID(self.nTimerID_Game_ShopSecret_1)
	self.nTimerID_Game_ShopSecret_1 = nil
	g_Timer:destroyTimerByID(self.nTimerID_Game_ShopSecret_2)
	self.nTimerID_Game_ShopSecret_2 = nil
	g_shopSecret:setItemsOld()
	
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ShopSecretForm_RefreshNewItem)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ShopSecretForm_RefreshAllItem)
	g_FormMsgSystem:UnRegistFormMsg(FormMsg_ShopSecretForm_BuyItem)
	
	g_Hero:setBubbleNotify(macro_pb.NT_SECRET_SHOP, 0)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
end

function Game_ShopSecret:callback(tb)

end

--新物品刷新
function Game_ShopSecret:refreshNewItem()
	self.layer:setTouchEnabled(true)
	local shopItem_5 = tolua.cast(self.ScrollView_ShopItemUp:getChildByTag(5), "Button")
	shopItem_5 = tolua.cast(shopItem_5:clone(), "Button")
	
	local shopItem = tolua.cast(self.ScrollView_ShopItemUp:getChildByTag(1), "Button")
	shopItem = tolua.cast(shopItem:clone(), "Button")
    local info = g_shopSecret:getShopItemByIndex(10)
	self:setItemInfo(info,shopItem,0)
    shopItem:setPosition(CCPoint(-90,120))
	shopItem:setCascadeOpacityEnabled(true)
    shopItem:setOpacity(0)
	self.ScrollView_ShopItemUp:addChild(shopItem)
	self:newItemAnimation(self.ScrollView_ShopItemUp,shopItem, true)
	
	local btnBuy = shopItem_5:getChildByName("Button_Buy")
	btnBuy:addTouchEventListener(handler(self,self.OnClickBtnBuy))
    shopItem_5:setPosition(CCPoint(-90,120))
	shopItem_5:setCascadeOpacityEnabled(true)
    shopItem_5:setOpacity(0)
	self.ScrollView_ShopItemDown:addChild(shopItem_5)
	self.nTimerID_Game_ShopSecret_2 = g_Timer:pushLimtCountTimer(1,1,function()
		if not g_WndMgr:getWnd("Game_ShopSecret") then return true end
		self:newItemAnimation(self.ScrollView_ShopItemDown,shopItem_5, false)
	end)
end

--新物品刷新动画
function Game_ShopSecret:newItemAnimation(widget,tempItem, bLocked)
	local function removeItem()
        local lastItem = tolua.cast(widget:getChildByTag(6), "Button")
		lastItem:removeFromParentAndCleanup(true)
		self.layer:setTouchEnabled(bLocked)
	end
	--最后的淡出
    local lastItem = tolua.cast(widget:getChildByTag(5), "Button")
	local btnBuy = lastItem:getChildByName("Button_Buy")
	btnBuy:setTouchEnabled(false)
    lastItem:setTag(6)
	lastItem:setCascadeOpacityEnabled(true)
	local arrAct = CCArray:create()
    local moveBy = CCMoveBy:create(1,CCPoint(200,0))
	local actionFade = CCFadeOut:create(1)
    local action = CCSpawn:createWithTwoActions(moveBy,actionFade)
	arrAct:addObject(action)
	local callFunc = CCCallFuncN:create(removeItem)
	arrAct:addObject(callFunc)
	action = CCSequence:create(arrAct)
    lastItem:runAction(action)
	
	--前4个后移
	for i=4,1,-1 do
		local shopItem = tolua.cast(widget:getChildByTag(i), "Button")
		if shopItem ~= nil then
            local moveBy = CCMoveBy:create(1,CCPoint(190,0))
			shopItem:runAction(moveBy)
            shopItem:setTag(i+1)
		end
	end
	
	--新的淡进
	tempItem:setTag(1)
    local moveBy = CCMoveBy:create(1,CCPoint(190,0))
    local actionFade = CCFadeIn:create(1)
    local action = CCSpawn:createWithTwoActions(moveBy,actionFade)
    tempItem:runAction(action)
	
end

function Game_ShopSecret:OnClickBtnRefresh(pSender,eventType)
	if eventType == ccs.TouchEventType.ended then--离开事件
		g_shopSecret:requestrefreshAllItem()
	end
end

function Game_ShopSecret:OnClickBtnBuy(pSender,eventType)
	if eventType == ccs.TouchEventType.ended then--离开事件
		pSender:setTouchEnabled(false)
		self.layer:setTouchEnabled(true)
		self.buttonTag = pSender:getTag()
		g_shopSecret:requestBuyItemShopSecret(self.buttonTag)
	end
end

function Game_ShopSecret:buyShopSecretItem(tbMsg)
    --物品设为已购买
	g_shopSecret:setItemBeBought(self.buttonTag)
	
	--重设各物品button_buy
	self:setAllItemInfo(1)
	
    self:CheckRefreshButton()
	self.layer:setTouchEnabled(false)
end

function Game_ShopSecret:refreshAllItem()

	self:setAllItemInfo(0)
	self:openAnimation()
    self:CheckRefreshButton()
    self.refreshButton:setTouchEnabled(false)
    self.refreshButton:setBright(false)
end

function Game_ShopSecret:RegistFormMessage()
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ShopSecretForm_RefreshNewItem,handler(self,self.refreshNewItem))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ShopSecretForm_RefreshAllItem,handler(self,self.refreshAllItem))
	g_FormMsgSystem:RegisterFormMsg(FormMsg_ShopSecretForm_BuyItem,handler(self,self.buyShopSecretItem))
end

function Game_ShopSecret:CheckRefreshButton()
    --确定图标和数量
    local bEnabel = g_shopSecret:isEnableRefresh()
    local IconName = "Icon_PlayerInfo_JiangHunShi"
    local costCnt = g_shopSecret.refreshAllCost_JHS


    if g_Hero:getRefreshToken() >= g_shopSecret.refreshAllCost_SXL then
        IconName = "Icon_PlayerInfo_RefreshToken"
        costCnt = g_shopSecret.refreshAllCost_SXL
    end


    local Image_Icon = tolua.cast(self.refreshButton:getChildByName("Image_Icon"), "ImageView")
    Image_Icon:loadTexture(getUIImg(IconName))
    
    local BitmapLabel_NeedYuanBao = tolua.cast(self.refreshButton:getChildByName("BitmapLabel_NeedYuanBao"), "LabelBMFont")
    if bEnabel == false and g_Hero:getJiangHunShi() < g_shopSecret.refreshAllCost_JHS and g_Hero:getRefreshToken() < g_shopSecret.refreshAllCost_SXL then 
        BitmapLabel_NeedYuanBao:setColor(ccc3(255, 0, 0))
    else
        BitmapLabel_NeedYuanBao:setColor(ccc3(255, 255, 255))
    end
    BitmapLabel_NeedYuanBao:setText(tostring(costCnt))

    local Label_RefreshNum = tolua.cast(self.rootWidget:getChildAllByName("Label_RefreshNum"), "Label")
    local Label_RefreshNumMaxLB = tolua.cast(self.rootWidget:getChildAllByName("Label_RefreshNumMaxLB"), "Label")

    if bEnabel == false and
       g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP) >=  g_VIPBase:getVipLevelCntNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP) then 
        Label_RefreshNum:setColor(ccc3(255, 0, 0))
    else
        Label_RefreshNum:setColor(ccc3(0, 255, 0))
    end
    Label_RefreshNum:setText(tostring(g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP)))
    Label_RefreshNumMaxLB:setText(string.format("/%d",g_VIPBase:getVipLevelCntNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP) ))

    local Label_RefreshNumLB = tolua.cast(self.rootWidget:getChildAllByName("Label_RefreshNumLB"), "Label")
    Label_RefreshNum:setPositionX(Label_RefreshNumLB:getSize().width*Label_RefreshNumLB:getScaleX() + 1)

    g_AdjustWidgetsPosition({ Label_RefreshNum, Label_RefreshNumMaxLB},1)

    self.refreshButton:setTouchEnabled(bEnabel)
    self.refreshButton:setBright(bEnabel)
end

function Game_ShopSecret:ModifyWnd_viet_VIET()
	local Label_CoolTimeLB = self.rootWidget:getChildAllByName("Label_CoolTimeLB")
	local Label_CoolTime = self.rootWidget:getChildAllByName("Label_CoolTime")
	Label_CoolTime:setPositionX(Label_CoolTimeLB:getSize().width)
	Label_CoolTimeLB:setPositionX(-450)


end