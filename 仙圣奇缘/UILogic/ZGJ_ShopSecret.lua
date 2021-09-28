--------------------------------------------------------------------------------------
-- ÎÄ¼þÃû:	Class_Fate.lua
-- °æ  È¨:	(C)ÉîÛÚÃÀÌì»¥¶¯¿Æ¼¼ÓÐÏÞ¹«Ë¾
-- ´´½¨ÈË:	ÖÜ¹â½£
-- ÈÕ  ÆÚ:	2015-5-5
-- °æ  ±¾:	1.0
-- Ãè  Êö:	ÉñÃØÉÌµêÊý¾Ý
-- Ó¦  ÓÃ:  
---------------------------------------------------------------------------------------

--SecretItem
SecretItem = class("SecretItem")
SecretItem.__index = SecretItem

function SecretItem:init(tab)
	self.tab = tab;
end

function SecretItem:getID()
	return self.tab.id or 0
end

--ÉÌÆ·ÏûºÄ»õ±ÒÍ¼±ê
function SecretItem:getItemIcon()
	return self.tab.CurrencyIcon or ""
end

function SecretItem:isNew()
	return self.tab["newTag"]
end

function SecretItem:isBought()
	return self.tab["state"] == macro_pb.SSIS_BE_BUY
end

function SecretItem:isEnabelBuy()
	
	if self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_COUPONS then
		return g_Hero:getYuanBao() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_GOLDS then
		return g_Hero:getCoins() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_IMMORTAL_TOKEN then
		return g_Hero:getXianLing() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_FRIENDHEART then
		return g_Hero:getFriendPoints() >= self:getNeedCurrencyNum()
	elseif self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then
		return g_Hero:getJiangHunShi() >= self:getNeedCurrencyNum()
	end

	return false
end

function SecretItem:getNeedCurrencyNum()
	if self.tab and self.tab.NeedCurrencyNum then
		return self.tab.NeedCurrencyNum
	end
	return 0
end

function SecretItem:getItemDropInfo()
	local DropItem = nil
	if g_Hero:getMasterSex() == 1 then
		DropItem=
		{
			DropItemType 			= self.tab["DropItemType"],
			DropItemID 				= self.tab["DropItemID"],
			DropItemStarLevel 		= self.tab["DropItemStarLevel"],
			DropItemNum 			= self.tab["DropItemNum"],
			DropItemEvoluteLevel	= 0,
		}
	else
		DropItem=
		{
			DropItemType 			= self.tab["DropItemType"],
			DropItemID 				= self.tab["DropItemID_Female"],
			DropItemStarLevel 		= self.tab["DropItemStarLevel"],
			DropItemNum 			= self.tab["DropItemNum"],
			DropItemEvoluteLevel	= 0,
		}
	end
	
	return DropItem
end


function SecretItem:getItemConsumeType()
	if self.tab["CurrencyType"] == macro_pb.ITEM_TYPE_COUPONS then
		return true
	end
	return false
end



Class_ShopSecret = class("Class_ShopSecret")
Class_ShopSecret.__index = Class_ShopSecret

function Class_ShopSecret:init()
end

function Class_ShopSecret:buyShopSecretItem(tbMsg)
	local msgDetail = zone_pb.SecretShopBuyResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	if msgDetail.update_item_type == macro_pb.ITEM_TYPE_GOLDS then
		g_Hero:setCoins(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_PRESTIGE then
		g_Hero:setPrestige(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIAN_LING then
		g_Hero:setXianLing(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_FRIENDHEART then
		g_Hero:setFriendPoints(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_COUPONS then
		
		--神秘商店购买物品 付费点 元宝消耗的时候

		local yuanBao = g_Hero:getYuanBao() - msgDetail.update_item_num
		if yuanBao > 0 then 
			gTalkingData:onPurchase(TDPurchase_Type.TDP_Mystical_Buy, 1, yuanBao)	
		end
		
		g_Hero:setYuanBao(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then
		g_Hero:setJiangHunShi(msgDetail.update_item_num)
	end
	
	g_FormMsgSystem:PostFormMsg(FormMsg_ShopSecretForm_BuyItem,nil)
	
end


function Class_ShopSecret:refreshNewItem(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()
	local msgDetail = zone_pb.SecretShopNewItemResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local coupons = msgDetail.cost_value
	local shopItems = msgDetail.secret_shop_items
	for i=1,#shopItems do
		local tab = g_copyTab(g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ShopSecret",shopItems[i].DropPackID,shopItems[i].ShopItemID))--g_DataMgr:getCsvConfigByTwoKey("ShopSecret",shopItems[i].DropPackID,shopItems[i].ShopItemID))
		tab["id"] = shopItems[i].id
		tab["newTag"] = 1
		tab["state"] = shopItems[i].state
		local tm = SecretItem.new()
		tm:init(tab)
		table.insert(self.itemQue,tm)
        table.remove(self.itemQue,1)
		if self.shopStartTime ~= 0 and coupons == 0 and #shopItems == 1 then
			g_FormMsgSystem:PostFormMsg(FormMsg_ShopSecretForm_RefreshNewItem,nil)
		end
	end
	if self.shopStartTime == 0 then
		self.shopStartTime = g_GetServerTime()
		g_FormMsgSystem:PostFormMsg(FormMsg_ShopSecretForm_RefreshAllItem,nil)
		g_Timer:pushLoopTimer(1,function()
		self:updateMsg()
		end)
	end
    --刷新次数
    g_VIPBase:setAddTableByNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP,msgDetail.vip_times )	
	if #shopItems ~= 1 then--coupons ~= 0 then     --µÚÒ»´Î´ò¿ªÉÌµê´¦Àí
        if msgDetail.cost_type == 1 then --将魂石
            g_Hero:setJiangHunShi(coupons)
        elseif msgDetail.cost_type == 2 then --刷新令
            g_Hero:setRefreshToken(coupons)
        end
		
		g_FormMsgSystem:PostFormMsg(FormMsg_ShopSecretForm_RefreshAllItem,nil)
	end



	if not g_WndMgr:isVisible("Game_ShopSecret") then
		g_WndMgr:openWnd("Game_ShopSecret")
	end
	
end

function Class_ShopSecret:setItemsOld()
	for i=1,#self.itemQue do
		self.itemQue[i].tab["newTag"] = 0
	end
end

function Class_ShopSecret:getShopItemByIndex(index)
	return self.itemQue[index]
end

function Class_ShopSecret:getCoolTime(index)
	return self.coolTime or 3600
end

--ÉñÃØÉÌµê¹ºÂòÎïÆ·
function Class_ShopSecret:requestBuyItemShopSecret(id)
	local msg = zone_pb.SecretShopBuyRequest() 
	msg.id = id 
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_SHOP_BUY_REQUEST, msg)
end

--ÉñÃØÉÌµêË¢ÐÂÎïÆ·
-- function Class_ShopSecret:isFisrtTime()
-- 	if self.shopStartTime == 0 then
-- 		g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_SHOP_NEW_ITEM_REQUEST,nil)
-- 		return true
-- 	end
-- 	return false
-- end


function Class_ShopSecret:requestNewItem()
	if g_Hero:getBubbleNotify(macro_pb.NT_SECRET_SHOP) > 0 or self.itemQue[1].tab["id"] == nil then
		g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_SHOP_NEW_ITEM_REQUEST,nil)
	else
		g_WndMgr:openWnd("Game_ShopSecret")
	end
end

--ÉñÃØÉÌµêË¢ÐÂËùÓÐÎïÆ·
function Class_ShopSecret:requestrefreshAllItem(id)
    --检测刷新次数是否用完
    if  g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP) >=  g_VIPBase:getVipLevelCntNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP)then 
        showMsgConfirm(_T("今天已达到购买次数上限\n升级VIP等级可以提升每天购买次数的上限"))
        return
    end 
    --检测刷新货币是哪种
    local typeCost = 2--刷新令
    --local strTmp = string.format(_T("是否消耗%d个刷新令进行刷新。"), self.refreshAllCost_SXL)
    local isEnable = g_Hero:getRefreshToken() >= self.refreshAllCost_SXL
    if isEnable == false then
        isEnable = g_Hero:getJiangHunShi() >= self.refreshAllCost_JHS
        typeCost = 1--将魂石
        --strTmp = string.format(_T("是否消耗%d个将魂石进行刷新"), self.refreshAllCost_JHS)
    end
    if isEnable == false then return end

    local rootMsg = zone_pb.SecretShopNewItemRequest()
    rootMsg.cost_type = typeCost
	g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_SHOP_REFRESH_REQUEST,rootMsg)
    g_MsgNetWorkWarning:showWarningText(true)   

end

--ÉèÖÃ³õÊ¼Êý¾Ý
function Class_ShopSecret:setShopBaseInfo(tbShopMsg)
	if not tbShopMsg then
		cclog("ShopBaseInfo nil")
	end
    self.itemQue = nil
    self.itemQue = {}
    self.shopStartTime = tbShopMsg.secret_shop_start_sec
	local shopItems = tbShopMsg.secret_shop_items
    local temp = shopItems[1]
    if temp ~= nil then 
		for i=1,10 do
			local tab = g_copyTab(g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ShopSecret",shopItems[i].DropPackID,shopItems[i].ShopItemID))--g_DataMgr:getCsvConfigByTwoKey("ShopSecret",shopItems[i].DropPackID,shopItems[i].ShopItemID))
			tab["id"] = shopItems[i].id
			tab["newTag"] = 0
			tab["state"] = shopItems[i].state
			local tm = SecretItem.new()
			tm:init(tab)
			table.insert(self.itemQue,tm)
		end
	else
		for i=1,10 do
			local tm = SecretItem.new()
			local tab ={}
			tm:init(tab)
			table.insert(self.itemQue,tm)
		end
	end
	
	--ÉèÖÃÀäÈ´Ê±¼äºÍË¢ÐÂËùÐèÔª±¦
	local tab = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 66)
	self.shopCD = tab["Data"]
	--self.shopCD = 5
	tab = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 69)
	self.refreshAllCost_JHS = tab["Data"]
	tab = g_DataMgr:getCsvConfigByOneKey("GlobalCfg", 124)
	self.refreshAllCost_SXL = tab["Data"]	

	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SECRET_SHOP_NEW_ITEM_RESPONSE,handler(self,self.refreshNewItem))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SECRET_SHOP_REFRESH_RESPONSE,handler(self,self.refreshNewItem))
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SECRET_SHOP_BUY_RESPONSE,handler(self,self.buyShopSecretItem))
	local isCD = tbShopMsg.secret_shop_is_cd
	-- if not isCD then
	-- 	g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_SHOP_NEW_ITEM_REQUEST,nil)
	-- end
	if self.shopStartTime ~= 0 then 
		self.nTimerID = g_Timer:pushLoopTimer(1,function()
			self:updateMsg()
		end)
	end
    
end

function Class_ShopSecret:isEnableRefresh()
    --return g_Hero:getYuanBao() >= self.refreshAllCost
    local isEnable = g_Hero:getRefreshToken() >= self.refreshAllCost_SXL
    if isEnable == false then
        isEnable = g_Hero:getJiangHunShi() >= self.refreshAllCost_JHS
    end

    if isEnable == true and 
    g_VIPBase:getAddTableByNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP) >=  g_VIPBase:getVipLevelCntNum(VipType.VIP_TYPE_REFRESH_SECRETSHOP)then 
        isEnable = false
    end 

    return isEnable
end

function Class_ShopSecret:setItemBeBought(id)
	for i=1,10 do
		if self.itemQue[i].tab["id"] == id then
			self.itemQue[i].tab["state"] = macro_pb.SSIS_BE_BUY
			g_ShowSingleRewardBox(self.itemQue[i].getItemDropInfo(self.itemQue[i]))
			break
		end
	end
	
end

function Class_ShopSecret:updateMsg()
    self.coolTime = self.shopCD-(g_GetServerTime() - self.shopStartTime)%self.shopCD
    if self.coolTime == self.shopCD then
		self.coolTime = 0
		if g_WndMgr:isVisible("Game_ShopSecret") then
			g_MsgMgr:sendMsg(msgid_pb.MSGID_SECRET_SHOP_NEW_ITEM_REQUEST,nil)
		else
			local nBubble = g_Hero:getBubbleNotify(macro_pb.NT_SECRET_SHOP) + 1
			nBubble = math.min(nBubble, 10)
			g_Hero:setBubbleNotify(macro_pb.NT_SECRET_SHOP, nBubble)
		end
	end
end

function Class_ShopSecret:getShopStartTime()
    return self.shopStartTime
end

if not g_shopSecret then
    g_shopSecret = Class_ShopSecret.new()
elseif g_shopSecret.nTimerID then
	g_shopSecret.nTimerID = g_Timer:pushLoopTimer(1,function()
		g_shopSecret:updateMsg()
	end)
end