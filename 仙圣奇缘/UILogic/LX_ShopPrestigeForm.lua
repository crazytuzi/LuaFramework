--------------------------------------------------------------------------------------
-- 文件名:	Class_Fate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	2015-4-22
-- 版  本:	1.0
-- 描  述:	声望商店Form
-- 应  用:  
---------------------------------------------------------------------------------------
Game_ShopPrestige = class("Game_ShopPrestige")
Game_ShopPrestige.__index = Game_ShopPrestige

local MaxRaw = 4
local cellFlag = 0xffffffff


function Game_ShopPrestige:ctor()
	self.m_PageShop = nil

	self.m_ListVisw = nil
	--当前页 等级描述
	self.m_LableLeve = nil

	--声望商店数据
	self.m_Date = nil
end


function Game_ShopPrestige:initWnd()
	
	self.m_Date = Class_ShopPrestige.new()
	self.m_Date:InitDate()

	self:RegistFormMessage()
	
	local Image_ShopPrestigePNL = self.rootWidget:getChildByName("Image_ShopPrestigePNL")
	--窗口
	self.m_LableLeve = tolua.cast(Image_ShopPrestigePNL:getChildByName("Label_BuyCondition"),"Label")
	--[[if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		self.m_LableLeve:setFontSize(21)
	else
		self.m_LableLeve:setFontSize(24)
	end]]
	
	local uiPageView = tolua.cast(Image_ShopPrestigePNL:getChildByName("PageView_ShopItem"),"PageView")
	uiPageView:setClippingEnabled(true)

	local PageModule = uiPageView:getChildByName("Panel_ShopItemPage")
	PageModule:retain()
	local butforwatd = tolua.cast(Image_ShopPrestigePNL:getChildByName("Button_Forward"), "Button")
	local butNext 	 = tolua.cast(Image_ShopPrestigePNL:getChildByName("Button_Next"), "Button")

	self.m_PageShop = Class_LuaPageView:new()
	self.m_PageShop :setModel(PageModule, butforwatd, butNext, 1.0, 1.0)
	self.m_PageShop :setPageView(uiPageView)

	self.m_PageShop:registerUpdateFunction(handler(self,self.updatePageViewItem))

	self.m_PageShop:setCurPageIndex(self.m_Date:GetCurPage())
	self.m_PageShop:updatePageView(self.m_Date:GetShopPage())
	self.m_PageShop:registerClickEvent(handler(self,self.SigleStepPage))
    self:SigleStepPage(nil, self.m_Date:GetCurPage())    --设置起始页
	
	local Image_NPC = tolua.cast(self.rootWidget:getChildByName("Image_NPC"), "ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation("XiaoXianTong", 1, true)
	Image_NPC:removeAllNodes()
	Image_NPC:loadTexture(getUIImg("Blank"))
	Image_NPC:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getBackgroundJpgImg("Shop"))
end


function Game_ShopPrestige:openWnd()

    --调整界面位置
    local Label_BuyCondition = tolua.cast(self.rootWidget:getChildAllByName("Label_BuyCondition"),"Label")
    local Button_Forward = tolua.cast(self.rootWidget:getChildAllByName("Button_Forward"),"Button")
    local Button_Next = tolua.cast(self.rootWidget:getChildAllByName("Button_Next"),"Button")

    Label_BuyCondition_pos = Label_BuyCondition:getPosition()
    Label_BuyCondition_w2 = Label_BuyCondition:getSize().width/2
    Button_Forward_w2 = Button_Forward:getSize().width/2
    Button_Forward:setPositionX(Label_BuyCondition_pos.x - Label_BuyCondition_w2 - Button_Forward_w2 - 10)
    Button_Next:setPositionX(Label_BuyCondition_pos.x + Label_BuyCondition_w2 + Button_Forward_w2 + 10)
end


function Game_ShopPrestige:closeWnd(tbData)
	self.m_Uplistview = nil
	self.m_Uplistview = {}

	self.m_Dowmlistview = nil
	self.m_Dowmlistview = {}
	
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	Image_Background:loadTexture(getUIImg("Blank"))
	
end

function Game_ShopPrestige:updatePageViewItem(Panel_ShopItemPage, nPage)
	local num = self.m_Date:GetCurShopPageNum(nPage)
	 
	local Listview = tolua.cast(Panel_ShopItemPage:getChildByName("ListView_ShopItemPage"), "ListViewEx")
	local ListVeiwMoudle = Listview:getChildByName("Panel_ShopItemPageRow")
	
	local function updateListViewItem(Panel_ShopItemPageRow, nIndex)
		for i = ((nIndex -1)*MaxRaw) +1 , nIndex*MaxRaw do

			local wgtNmae = nil
			if i > MaxRaw then
				wgtNmae = "Button_ShopItem_"..(i - (nIndex -1)*MaxRaw)
			else
				wgtNmae = "Button_ShopItem_"..i
			end
			local info = self.m_Date:GetCurItemByIndex(nPage, i)
		
			local ShopItem = tolua.cast(Panel_ShopItemPageRow:getChildByName(wgtNmae), "Button")
			if info then
				self:setItemInfo(info, ShopItem)
			end

			ShopItem:setVisible(info ~= nil)
		end
	end

	self.m_ListVisw = Class_LuaListView:new()
    self.m_ListVisw:setModel(ListVeiwMoudle)
    self.m_ListVisw:setListView(Listview)
    self.m_ListVisw:setUpdateFunc(updateListViewItem)
	
    if num then
    	self.m_ListVisw:updateItems(math.ceil(num/MaxRaw))
    end
    
end

function Game_ShopPrestige:SigleStepPage(widget, nPage)
	local szText = string.format(_T("购买当前页面商品需要%d级"),self.m_Date:GetCurPageLevel(nPage))
	self.m_LableLeve:setText(szText)
end

function Game_ShopPrestige:setItemInfo(info, widget)
	if widget == nil or info == nil then
		return 
	end


	local itemModel, tbCsvBase, nColorType = g_CloneDropItemModel(info:GetItemDropInfo())
	if itemModel ~= nil then
		
		local cell = widget:getChildByTag(cellFlag)
		if cell ~= nil then
			cell:removeFromParentAndCleanup(true)
		end

		local oldcell = widget:getChildByName("Image_DropHunPoItem_0")
		if oldcell ~= nil then
			oldcell:removeFromParentAndCleanup(true)
		end

		local pos = CCPoint(0, 48)
		itemModel:setPosition(pos)
		itemModel:setScale(0.85)
		widget:addChild(itemModel)
		itemModel:setTag(cellFlag)
		local function onClick(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				g_ShowDropItemTip(info:GetItemDropInfo())
			end
		end
		itemModel:setTouchEnabled(true)
		itemModel:addTouchEventListener(onClick)
	end

	local Label_ItemName = tolua.cast(widget:getChildByName("Label_ItemName"), "Label")
	if Label_ItemName ~= nil then
		if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
			Label_ItemName:setFontSize(16)
			Label_ItemName:setText(g_stringSize_insert(tbCsvBase.Name, "\n", 16, 160))
		else
			Label_ItemName:setFontSize(21)
			Label_ItemName:setText(tbCsvBase.Name)
		end
		g_SetCardNameColorByEvoluteLev(Label_ItemName, nColorType)
	end

	local btnBuy = widget:getChildByName("Button_Buy")
	if btnBuy ~= nil then
		local icon = tolua.cast(btnBuy:getChildByName("Image_CurrencyIcon"), "ImageView")
		if icon ~= nil then
			icon:loadTexture(getUIImg(info:GetItemIcon()))
		end

		local Label_CurrencyValue  = tolua.cast(btnBuy:getChildByName("Label_CurrencyValue"), "Label")
		if Label_CurrencyValue ~= nil then
			Label_CurrencyValue:setText(info:getNeedCurrencyNum()) --info:getNeedCurrencyNum()
			g_SetLabelRed(Label_CurrencyValue, info:ISEnabelBuy() == false)
		end
	end

	local bv = info:ISEnabelBuy() and info:IsEnableLevel()
	widget:setTouchEnabled(bv)
	widget:setBright(bv)
	btnBuy:setTouchEnabled(bv)
	btnBuy:setBright(bv)
	btnBuy:setTag(info:GetShopID())
	btnBuy.needNum = info:getNeedCurrencyNum()
	-- --OnClick
	-- local function onClickBuy(pSender,eventType)
	-- 	local ntga = pSender:getTag()
	-- 	self.m_Date:requestBuyItemShopPrestige(nTag)
	-- end

	btnBuy:addTouchEventListener(handler(self,self.OnClickBtnBuy))
	return 
end

function Game_ShopPrestige:OnClickBtnBuy(pSender,eventType)

	if eventType == ccs.TouchEventType.ended then--离开事件
		local function onClickConfirm(nValue)
			local x = pSender:getTag()
			self.m_Date:requestBuyItemShopPrestige(x, nValue)
			--做点击后逻辑用
			self.flag = x
			self.needNum = pSender.needNum
            self.nBuyNum = nValue
		end
		g_ClientMsgTips:showConfirmInputNumber(_T("输入购买的数量"), math.floor( g_Hero:getPrestige()/pSender.needNum), onClickConfirm, onClickCancel, 1)
		
	end
end


function Game_ShopPrestige:RefreshWnd()

end


function Game_ShopPrestige:BuyShopPrestigeItem(tbMsg)
	local msgDetail = zone_pb.PrestigeShopItemResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	
	if msgDetail.update_item_type == macro_pb.ITEM_TYPE_MASTER_EXP then --主角经验
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_MASTER_ENERGY then --体力
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_COUPONS then --元宝
		g_Hero:setYuanBao(msgDetail.update_item_num)
			--声望商店 付费点
		gTalkingData:onPurchase(TDPurchase_Type.TDP_Reputation_Buy, 1, self.needNum)
	
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_GOLDS then --铜钱
		g_Hero:setCoins(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_PRESTIGE then --声望
		g_Hero:setPrestige(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_KNOWLEDGE then --阅历
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_INCENSE then --香贡
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_POWER then --神力/神识
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_ARENA_TIME then --竞技场挑战次数
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_ESSENCE then --元素精华、灵力
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_FRIENDHEART then --友情之心
		g_Hero:setFriendPoints(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_CARDEXPINBATTLE then --伙伴经验
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIAN_LING then --仙令
		g_Hero:setXianLing(msgDetail.update_item_num)
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_DRAGON_BALL then --神龙令
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ONE_KEY then --一键消除
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_BA_ZHE then --霸者横栏
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_LIAN_SUO then --消除连锁
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_DOU_ZHUAN then --斗转星移
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_DIAN_DAO then --颠倒乾坤
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_METAL then --金灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_NATURE then --木灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_WATER then --水灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_FIRE then --火灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_EARTH then --土灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_AIR then --风灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_XIANMAI_ELEMENT_LIGHTNING then --雷灵核
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_SECRET_JIANGHUN then --将魂石
		--
	elseif msgDetail.update_item_type == macro_pb.ITEM_TYPE_SECRET_REFRESH_TOKEN then --将魂令
		--
	end
	
	local info = g_DataMgr:getCsvConfigByOneKey(self.m_Date:GetCSVName(), self.flag)
	if info ~= nil then
        info.DropItemNum = self.nBuyNum
		g_ShowSingleRewardBox(info)
	end

	self:RefreshWnd()
	
end

function Game_ShopPrestige:RegistFormMessage()
	local order = msgid_pb.MSGID_PRESTIGE_SHOP_ITEM_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.BuyShopPrestigeItem))
end

function Game_ShopPrestige:ModifyWnd_viet_VIET()

end