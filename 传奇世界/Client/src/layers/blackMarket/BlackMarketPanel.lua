--Author:		bishaoqing
--DateTime:		2016-05-13 15:04:26
--Region:		黑市界面
local BlackMarketPanel = class("BlackMarketPanel", require("src/layers/base/BasePanel"))
local Arg = require("src/layers/blackMarket/BlackMarketCfg")
local Mprop = require( "src/layers/bag/prop" )
local MpropOp = require("src/config/propOp")

BlackMarketPanel.pInstance = nil
BlackMarketPanel.getInstance = function( ... )
	-- body
	if BlackMarketPanel.pInstance then
		BlackMarketPanel.pInstance:OnClose()
	end
	BlackMarketPanel.pInstance = BlackMarketPanel.new(...)
	return BlackMarketPanel.pInstance
end

local bDebug = false
function BlackMarketPanel:ctor( ... )
	-- body
	if G_NPC_SOUND then
		AudioEnginer.stopEffect(G_NPC_SOUND)
		G_NPC_SOUND = nil
	end
	BlackMarketPanel.super.ctor(self, ...)
	self.m_nShopType = Arg.BlackMarket

	GetBlackMarketCtr():GetMsgFromServer()
	if bDebug then
		self:RefreshUI()
	end
end

function BlackMarketPanel:setShopType( nShopType )
	-- body
	self.m_nShopType = nShopType
end

function BlackMarketPanel:InitUI( ... )
	-- body
	BlackMarketPanel.super.InitUI(self)


	local stWinSize = cc.Director:getInstance():getWinSize()
	-- local stBgSize = cc.size(850, 600)
	-- self.m_imgBg = createScale9Sprite(self.m_uiRoot, "res/common/bg/bg27.png", cc.p(stWinSize.width/2, stWinSize.height/2), stBgSize, cc.p(0.5, 0.5))
	-- self.m_imgBg = createSprite(self.m_uiRoot, "res/common/bg/bg18.png", cc.p(stWinSize.width/2, stWinSize.height/2), cc.p(0.5, 0.5))
	self.m_imgBg, self.m_btnClose, self.m_tfTitle = createBgSprite(self.m_uiRoot, "x", nil, nil, handler(self, self.OnClose))
	registerOutsideCloseFunc( self.m_imgBg , function() self:OnClose() end,true)
	
	local stBgSize = self.m_imgBg:getContentSize()

	-- local bg = createSprite(self.m_imgBg, "res/common/bg/bg-6.png", cc.p(stBgSize.width/2, stBgSize.height/2 - 30), cc.p(0.5, 0.5))


	local left_bg_size = cc.size(320, 440)
	--local left_bg = createScale9Sprite(self.m_imgBg, "res/common/bg/bg50.png", cc.p(355, 315), left_bg_size, cc.p(1, 0.5))
	local left_bg_size = cc.size(320, 450)
	local left_bg = createScale9Frame(
        self.m_imgBg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(30, 90),
        left_bg_size,
        5
    )
	local nv_pos = cc.p(left_bg_size.width/2, 0)
	self.m_uiPerson = createSprite(left_bg, "res/mainui/npc_big_head/0-1.png", nv_pos, cc.p(0.5, 0))
	-- local nvzhujiao = Mnode.createSprite(
	-- {
	-- 	src = "res/mainui/npc_big_head/0-1.png",
	-- 	parent = left_bg,
	-- 	pos = nv_pos,
	-- })

	local isSpeaking = false
	local res = "res/layers/shop/"

	local bubble = Mnode.createSprite(
	{
		src = res.."bubble.png",
		parent = left_bg,
		anchor = cc.p(0.5, 1),
		pos = cc.p(left_bg_size.width/2, left_bg_size.height-5),
		opacity = 0,
	})

	local bubble_size = bubble:getContentSize()

	local statement = Mnode.createLabel(
	{
		src = "老板~~~，照顾下我的生意吧！",
		parent = bubble,
		size = 20,
		color = MColor.lable_yellow,
		pos = cc.p(bubble_size.width/2, bubble_size.height/2+12),
		hide = true,
	})

	local generate = function()
		local tIdAsKey = getConfigItemByKey("scshb", "ID")
		local voiceTab = {11,12,13}
		if self.m_nShopType == Arg.BookMarket then
			voiceTab = {9,10}
		end
		local id = math.random(1,#voiceTab)
		local num = voiceTab[id]
		return tostring(tIdAsKey[num].nr), ("sounds/shopVoice/".. tostring(num) .. ".mp3")
	end

	local speak = function()
		-- self.m_uiPerson.catch = true
		isSpeaking = true
		dump("speaking")
		
		-- 淡入
		local duration = 0.25
		local speakTime = 4
		local FadeIn = cc.FadeIn:create(duration)
		statement:setVisible(true)
		local text ,mp3 = generate()
		statement:setString(text)
		self.audio = AudioEnginer.playEffectOld(mp3, false)
		local DelayTime = cc.DelayTime:create(speakTime)
				
		-- 淡出
		local FadeOut = cc.FadeOut:create(duration)
		
		local func = cc.CallFunc:create(function(node)
			statement:setVisible(false)
			isSpeaking = false
			--bubble:setOpacity(0)
		end)
		local final = cc.Sequence:create(FadeIn, DelayTime, FadeOut, func)
		bubble:runAction(final)
	end

	speak()
	Mnode.listenTouchEvent(
	{
		node = self.m_uiPerson,
		swallow = false,
		begin = function(touch, event)
			local node = event:getCurrentTarget()
			if node.catch then return false end
			
			local inside = Mnode.isTouchInNodeAABB(node, touch)
			if inside and not isSpeaking then
				node.catch = true
				-- isSpeaking = true
				-- dump("speaking")
				
				-- -- 淡入
				-- local duration = 0.25
				-- local speakTime = 3
				-- local FadeIn = cc.FadeIn:create(duration)
				
				-- 说话
				-- statement:setVisible(true)

				-- statement:setString(Arg.getSpeakWords(self.m_nShopType))
				-- local text ,mp3 = generate()
				-- statement:setString(text)
				-- self.audio = AudioEnginer.playEffectOld(mp3, false)
				speak()
				
				-- local DelayTime = cc.DelayTime:create(speakTime)
				
				-- -- 淡出
				-- local FadeOut = cc.FadeOut:create(duration)
				
				-- local func = cc.CallFunc:create(function(node)
				-- 	statement:setVisible(false)
				-- 	isSpeaking = false
				-- 	--bubble:setOpacity(0)
				-- end)
				-- local final = cc.Sequence:create(FadeIn, DelayTime, FadeOut, func)
				-- bubble:runAction(final)
				
				return true
			end
			
			return false
		end,
		
		ended = function(touch, event)
			local node = event:getCurrentTarget()
			node.catch = false
			
			--if Mnode.isTouchInNodeAABB(node, touch) then end
		end,
	})

	local uibar = createScale9Frame(
        self.m_imgBg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(33, 39),
        cc.size(754, 41),
        4
    )
	uibar:setLocalZOrder(99)

	local function openRaisePanel( ... )
		-- body
		__GotoTarget( { ru = "a33" } )
	end

	local btnRaise = createMenuItem( uibar , "res/component/button/49.png", cc.p(0,0), openRaisePanel )
	btnRaise:setAnchorPoint(cc.p(0.5, 0.5))
	btnRaise:setPosition(cc.p(830, 22))
	local stSize = btnRaise:getContentSize()
	local tfTitle = createLabel(btnRaise, "充值", cc.p(stSize.width/2 + 20, stSize.height/2), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	createSprite(btnRaise, "res/group/currency/5.png", cc.p(stSize.width/2 - 30, stSize.height/2), cc.p(0.5, 0.5))
	self.uibar=uibar
	

	--local sprBlackBg = createScale9Sprite(self.m_imgBg, "res/common/bg/bg51.png", cc.p(358, 315), cc.size(570, 440), cc.p(0, 0.5))
	
	local right_bg_size = cc.size(570, 450)
	local right_bg = createScale9Frame(
        self.m_imgBg,
        "res/common/scalable/panel_outer_base.png",
        "res/common/scalable/panel_outer_frame_scale9.png",
        cc.p(358, 90),
        right_bg_size,
        5
    )

	self.m_sclContent = GetWidgetFactory():CreateScrollView(cc.size(565, 435), false)
    self.m_imgBg:addChild(self.m_sclContent)
    self.m_sclContent:setAnchorPoint(cc.p(0, 0.5))
	self.m_sclContent:setPosition(cc.p(365, 315))
    
	-- self.m_btnClose = createMenuItem( self.m_imgBg , "res/component/button/X.png" , cc.p(809, 505) , handler(self, self.OnClose) )

	-- local tfTitle = createLabel(self.m_imgBg, "黑市商人", cc.p(425, 505), cc.p(0.5, 0.5), GetUiCfg().stFontSize.FirstTabsSize)
	-- tfTitle:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)
	-- self.m_tfTitle = tfTitle

	local tfLimit = createLabel(uibar, "每天12点和18点售卖的珍宝将自动刷新", cc.p(60, 8), cc.p(0, 0), GetUiCfg().stFontSize.NormalSize)
	tfLimit:setColor(MColor.white)

	self.m_tfLimit = tfLimit
	self.audio = nil
	self.m_imgBg:registerScriptHandler(function(event)
		if event == "enter" then
			
		elseif event == "exit" then
			if self.audio then
				AudioEnginer.stopEffect(self.audio)
		  		self.audio = nil
			end
		end
	end)
end

function BlackMarketPanel:setLimitLabelVisible( bVisible )
	-- body
	if IsNodeValid(self.m_tfLimit) then
		self.m_tfLimit:setVisible(bVisible)
		if self.uiGold then
			self.uiGold:removeFromParent()
		end
		local Mcurrency = require "src/functional/currency"
		local moneyNodes = {
						[3] = Mcurrency.new(
						{
							cate = PLAYER_MONEY,
							--bg = "res/common/19.png",
							color = MColor.white,
						}),
						[1] = Mcurrency.new(
						{
							cate = PLAYER_INGOT,
							--bg = "res/common/19.png",
							color = MColor.white,
						}),
						
						[2] = Mcurrency.new(
						{
							cate = PLAYER_BINDINGOT,
							--bg = "res/common/19.png",
							color = MColor.white,
						})
					}
		local item_margin = 60
		local position=cc.p(5,5)
		if bVisible then
			moneyNodes = {
						[1] = Mcurrency.new(
						{
							cate = PLAYER_INGOT,
							--bg = "res/common/19.png",
							color = MColor.white,
						}),
					}
			item_margin = 80
			position=cc.p(560,5)
		end

		local uiGold = Mnode.combineNode(
					{
						nodes = moneyNodes,
						
						margins = item_margin,
						orientation = "-"
					})

		self.uibar:addChild(uiGold)
		uiGold:setPosition(position)
		self.uiGold=uiGold
	end
end

function BlackMarketPanel:setTitle( nShopType )
	-- body
	if IsNodeValid(self.m_tfTitle) then
		self.m_tfTitle:setString(Arg.GetShopName(nShopType))
	end
end

function BlackMarketPanel:setPerson( nShopType )
	-- body
	if IsNodeValid(self.m_uiPerson) then
		self.m_uiPerson:setTexture(Arg.getPerson(nShopType))
	end
end

function BlackMarketPanel:AddEvent( ... )
	-- body
	BlackMarketPanel.super.AddEvent(self)
	Event.Add(EventName.UpdateBlackMarket, self, self.RefreshUI)
	Event.Add(EventName.OnLimitReturn, self, self.ShowBuyPanel)
end

function BlackMarketPanel:RemoveEvent( ... )
	-- body
	BlackMarketPanel.super.RemoveEvent(self)
	Event.Remove(EventName.UpdateBlackMarket, self)
	Event.Remove(EventName.OnLimitReturn, self)
end

function BlackMarketPanel:RefreshUI( ... )
	-- body
	print("BlackMarketPanel:RefreshUI")
	self:Reset()

	local vAllItems = GetBlackMarketCtr():GetAllCach(true)
	if vAllItems then
		print("#vAllItems", #vAllItems)
	end
	--边距
	local nPadding = 5
	local nColPadding = 5
	
	local vAllRows = {}
	--每一行有几个物品
	local nPerItemEachRow = 2

	for i,oItem in ipairs(vAllItems) do
	-- for i=1,14 do
		local uiCate = self:CreateCate(oItem)
		if IsNodeValid(uiCate) then
			local iIndex = math.floor((i - 1) / nPerItemEachRow) + 1
			if not vAllRows[iIndex] then
				local uiNode = cc.Node:create()
				vAllRows[iIndex] = uiNode
				uiNode:setContentSize(cc.size(uiCate:getContentSize().width * nPerItemEachRow, uiCate:getContentSize().height))
				self.m_sclContent:addChild(uiNode)
			end
			vAllRows[iIndex]:addChild(uiCate)
		end
	end
	for i,v in ipairs(vAllRows) do
		GetUIHelper():FixNode(v, nColPadding, true)
	end
	--设置滑动控件的高度和子控件的位置
	GetUIHelper():FixScrollView(self.m_sclContent, nPadding)
end

function BlackMarketPanel:OnItemClick( oItem )
	-- body
	
	if oItem:IsServerLimit() then
		--查询全服限购数目
		GetBlackMarketCtr():GetLimitFromServer(oItem)
	elseif oItem:IsSingleLimit() then
		--查询个人限购数目
		GetBlackMarketCtr():GetLimitFromServer(oItem)
	else
		self:ShowBuyPanel(oItem)
	end
end

function BlackMarketPanel:ShowBuyPanel( oItem )
	-- body
	--如果需要现实特殊界面就显示
	-- release_print("ShowBuyPanel", oItem:needShowRideBuyPanel())
	if oItem:needShowRideBuyPanel() then
		return require("src/layers/blackMarket/RideBuyPanel").new(oItem)
	end
	local price = oItem:GetPrice() or 1
	local maxNum = oItem:GetItemLeft() or 1
	local protoId = oItem:GetItemID() or 1001
	local storeId = GetBlackMarketCtr():GetShopType() or 0
	local nTotalNum = oItem:GetSouceNum()
	local nLeft = oItem:GetItemLeft() or 0
	local whole = oItem:IsServerLimit()
	local single = oItem:IsSingleLimit()
	local nSingleCur = oItem:getRoleCurBuy()
	local nSingleTotal = oItem:getRoleLimie()

	local nSingleLeft = nSingleTotal - nSingleCur
	if maxNum > nSingleLeft and nSingleLeft >= 0 then
		maxNum = nSingleLeft
	end

	local bIsBind = oItem:IsBind()
	--如果不是限购
	if not oItem:IsLimit() then
		-- maxNum = MpropOp.maxOverlay(protoId)
		maxNum = oItem:GetMaxNum()
	end

    ----------------------------------------------------------------------
    local realMaxNum = math.floor(MRoleStruct:getAttr(PLAYER_INGOT) / price) 
    if realMaxNum == 0 then
        realMaxNum = 1
    end
    if realMaxNum < maxNum then
        maxNum = realMaxNum
    end
    --maxNum = 20
    ----------------------------------------------------------------------

	local MChoose = require("src/functional/ChooseQuantity")
	local box = MChoose.new(
	{
		title = game.getStrByKey("buy_prop"),
		parent = self.m_uiRoot,
		config = { sp = maxNum == 0 and 0 or 1, ep = maxNum, cur = maxNum == 0 and 0 or 1 },
		builder = function(box, parent)
			local cSize = parent:getContentSize()
			
			box:buildPropName(MPackStruct:buildGirdFromProtoId(protoId), bIsBind)
			
			-- 物品图标
			local icon = Mprop.new(
			{
				protoId = protoId,
				cb = "tips",
				isBind = bIsBind,
			})
			
			Mnode.addChild(
			{
				parent = parent,
				child = icon,
				pos = cc.p(70, 264),
			})
			
			box.icon = icon
			
			local nodes = {}
			
			if single then
				nodes[#nodes+1] = Mnode.createLabel(
				{
					src = (protoId == 1076 and "限购" or game.getStrByKey("single_buy_limits")) .. ": " .. (nSingleCur).."/" .. nSingleTotal,
					color = MColor.lable_yellow,
					size = 20,
					outline = false,
				})
			end

			if whole then
				nodes[#nodes+1] = Mnode.createLabel(
				{
					src = game.getStrByKey("whole_buy_limits") .. ": " .. (nTotalNum-nLeft) .. "/" .. nTotalNum,
					color = MColor.lable_yellow,
					size = 20,
					outline = false,
				})
			end
			
			local TotalPrice = Mnode.createKVP(
			{
				k = Mnode.createLabel(
				{
					src = game.getStrByKey("buy_totle_price").." ",
					color = MColor.lable_yellow,
					size = 20,
					outline = false,
				}),
				
				v = {
					src = "",
					color = MColor.lable_yellow,
					size = 20,
				},
			})
			
			nodes[#nodes+1] = TotalPrice
			
			Mnode.addChild(
			{
				parent = parent,
				child = Mnode.combineNode(
				{
					nodes = nodes,
					ori = "|",
					align = "l",
					margins = 5,
				}),
				
				anchor = cc.p(0, 0.5),
				--pos = cc.p(153, 243),
				pos = cc.p(130, 264),
			})
			
			box.TotalPrice = TotalPrice
		end,
		
		handler = function(box, value)
			if maxNum < 1 then
				TIPS({ type = 1  , str = game.getStrByKey("buy_rul_tips") })
				return
			end
			GetBlackMarketCtr():Buy(oItem, value)
			
			if box then removeFromParent(box) box = nil end
		end,
		
		onValueChanged = function(box, value)
			box.icon:setOverlay(value)
			box.TotalPrice:setValue(price * value .. " " .. Arg.GetMoneyName(storeId))
		end,
	})
end

--创建scrollview里面重复的部件
function BlackMarketPanel:CreateCate( oItem )
	-- body
	local m_plCate = cc.Sprite:create("res/layers/shop/cell_bg.png")
	m_plCate:setName("m_plCate")
	local function OnItemClick()
		self:OnItemClick(oItem)
	end
	local listener = GetUIHelper():AddTouchEventListener(false, m_plCate, nil, OnItemClick)
	m_plCate:setAnchorPoint(cc.p(0, 0))
	m_plCate:registerScriptHandler(function(event)
		if event == "exit" then
			m_plCate:getEventDispatcher():removeEventListener( listener );
		end
	end)

	local stCateContentSize = m_plCate:getContentSize()

	local storeId = GetBlackMarketCtr():GetShopType() or 0
	local protoId = oItem:GetItemID()
	local price = oItem:GetPrice()
	local itemLeft = oItem:GetItemLeft()
	local moneyType = oItem:GetMoneyType()
	local bIsBind = oItem:IsBind()

	-- 物品图标
	local icon = Mprop.new(
	{
		protoId = protoId,
		cb = "tips",
		isBind = bIsBind,
	})
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(cc.p(12, stCateContentSize.height/2))
	m_plCate:addChild(icon)


	local stIconSize = icon:getContentSize()

	local tf_name = createLabel(m_plCate, tostring(MpropOp.name(protoId)), cc.p(107, 81), cc.p(0, 0.5), GetUiCfg().stFontSize.TooMuchWordsSize)
	tf_name:setName("tf_name")
	tf_name:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

	local uiGold = createSprite(m_plCate,  Arg.GetMoneyIcon(moneyType), cc.p(109, 54), cc.p(0, 0.5))
	uiGold:setName("uiGold")
	uiGold:setScale(0.8)

	local tfPrice = createLabel(m_plCate, tostring(price), cc.p(149, 50), cc.p(0, 0.5), GetUiCfg().stFontSize.TooMuchWordsSize)
	tfPrice:setName("tfPrice")
	tfPrice:setColor(MColor.white)

	if oItem:IsLimit() then
		local tfLimit = createLabel(m_plCate, "限量：", cc.p(107, 23), cc.p(0, 0.5), GetUiCfg().stFontSize.TooMuchWordsSize)
		tfLimit:setName("tfLimit")
		tfLimit:setColor(GetUiCfg().FontColor.ButtonTabsAndTitleColor)

		local tfLimitnum = createLabel(m_plCate, tostring(itemLeft), cc.p(167, 23), cc.p(0, 0.5), GetUiCfg().stFontSize.TooMuchWordsSize)
		tfLimitnum:setName("tfLimitnum")
		tfLimitnum:setColor(MColor.white)

		local uiLimit = createSprite(m_plCate, "res/blackmarket/limit.png", cc.p(0, stCateContentSize.height), cc.p(0, 1))
		uiLimit:setName("uiLimit")


		if itemLeft == 0 then
			local uiGray = createScale9Sprite(m_plCate, "res/blackmarket/gray.png", cc.p(0, 0), stCateContentSize, cc.p(0, 0))
			uiGray:setName("uiGray")

			local uiNoMore = createSprite(m_plCate, "res/component/flag/13.png", cc.p(stCateContentSize.width/2, stCateContentSize.height/2), cc.p(0.5, 0.5))
			uiNoMore:setName("uiNoMore")
		end
	else
		tf_name:setPosition(cc.p(105,71))
		uiGold:setPosition(cc.p(105, 36))
		tfPrice:setPosition(cc.p(145, 36))
	end
	return m_plCate
end

function BlackMarketPanel:Reset( ... )
	-- body
	self.m_sclContent:getContainer():removeAllChildren()
end

function BlackMarketPanel:Dispose( ... )
	-- body
	BlackMarketPanel.super.Dispose(self,...)

	if IsNodeValid(BlackMarketPanel.pInstance) then
		BlackMarketPanel.pInstance:OnClose()
	end
	BlackMarketPanel.pInstance = nil
end

return BlackMarketPanel