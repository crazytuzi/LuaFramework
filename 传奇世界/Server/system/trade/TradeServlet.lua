--TradeServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  TradeServlet.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年5月14日
 --* Purpose: Implementation of the class TradeServlet
 -------------------------------------------------------------------*/

TradeServlet = class(EventSetDoer, Singleton)

function TradeServlet:__init()
	self._doer = {
			[TRADE_CS_AREQ]			=	TradeServlet.TradeAreq,
			[TRADE_CS_BRET]			=	TradeServlet.TradeBret,
			[TRADE_CS_ITEMREQ]		=	TradeServlet.ItemReq,
			[TRADE_CS_LOCK]			=	TradeServlet.TradeLock,
			[TRADE_CS_TRADE]		=	TradeServlet.DoTrade,
			[TRADE_CS_BLOCKTRADE]	=	TradeServlet.BlockTrade,

			[TRADE_CS_SELL]			=	TradeServlet.Sell,
			[TRADE_CS_BACKSELL]		=	TradeServlet.BackSell,

			[TRADE_CS_TRADEMALL]	=	TradeServlet.TradeMall,
			[TRADE_CS_MALLREQ]		=	TradeServlet.MallReq,
			[TRADE_CS_SPE_TRADE]	=	TradeServlet.SpeTrade,
			[TRADE_CS_ALLLIMITREQ]  =   TradeServlet.GetALLLimit,
			[TRADE_CS_TRADEMALLBYITEMID] = TradeServlet.TradeMallItemID,
			
			[TRADE_CS_MYSTREQ]		=	TradeServlet.MystReq,
			[TRADE_CS_MYSTBUY]		=	TradeServlet.MystBuy,
			[TRADE_CS_MYST_LIMIT_REQ] = TradeServlet.MystLimitReq,
			[TRADE_CS_SPE_ITEM] 	= 	TradeServlet.MystSpeItem,

			[TRADE_CS_CHECK_NEW] 	= 	TradeServlet.MallCheckNew,
		}

		local PublicSvr = FACTION_DATA_SERVER_ID or 2
		if g_spaceID == 0 or g_spaceID == PublicSvr then
			g_frame:registerMsg(TRADE_CS_ALLLIMITREQ)
			require "system.trade.TradePublic"
		end
end

--神秘商店请求
function TradeServlet:MystReq(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("MysteryShopReqProtocol", pbc_string)
	if not req then
		print('TradeServlet:MystReq '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	
	local shop = req.shopType
	if g_mystShopMgr:getMysteryshopActive()<1 then return end
	local user = g_mystShopMgr:getUserInfo(roleSID)
	if user then
		local isOpen = user:getSmelterMall()
		if isOpen < 1 then
			user:setOpenSmelterMall(1)
			user:setUpdateDB(true)
			user:cast2DB()
		end
		user:Req(shop)
	end
end

--神秘商店购买
function TradeServlet:MystBuy(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("MysteryShopBuyProtocol", pbc_string)
	if not req then
		print('TradeServlet:MystBuy '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local shop = req.shopType
	local Type = req.moneyType
	local Index = req.arrayIndex
	local ItemID = req.itemID
	local buyNum = req.buyNum

	if g_mystShopMgr:getMysteryshopActive()<1 then return end
	if buyNum<=0 then return end

	local user = g_mystShopMgr:getUserInfo(roleSID)
	if user then
		local isOpen = user:getSmelterMall()
		if isOpen < 1 then
			user:setOpenSmelterMall(1)
			user:setUpdateDB(true)
			user:cast2DB()
		end
		user:Buy(shop, Type, Index, ItemID, buyNum)
	end
end

function TradeServlet:MystLimitReq(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("MysteryLimitReqProtocol", pbc_string)
	if not req then
		print('TradeServlet:MystLimitReq '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	if g_mystShopMgr:getMysteryshopActive()<1 then return end
	local mallID = req.shopType
	local moneyType = req.moneyType
	local arrayIndex = req.arrayIndex
	local itemID = req.itemID

	local user = g_mystShopMgr:getUserInfo(roleSID)
	if user then
		user:getMystLimit(mallID,moneyType,arrayIndex,itemID)
	end
end

function TradeServlet:MystSpeItem(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("MallSpeItem", pbc_string)
	if not req then
		print('TradeServlet:MystSpeItem '..tostring(err))
		return
	end

	local playerA = g_entityMgr:getPlayerBySID(roleSID)
	if not playerA then
		print("TradeServlet:MystSpeItem no playerA")
		return 
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end

	if g_mystShopMgr:getMysteryshopActive()<1 then return end
	local slot = req.slot
	local user = g_mystShopMgr:getUserInfo(roleSID)
	if user then
		user:mystUseSpeItem(playerA,slot)
	end
end

function TradeServlet:MallCheckNew(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("MallCheckNew", pbc_string)
	if not req then
		print('TradeServlet:MallCheckNew '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end

	if g_mystShopMgr:getMysteryshopActive()<1 then return end
	local mallID = req.mallType
	local isClose = req.isClose

	if MYSTERYSHOP_SMELTER == mallID then
		if isClose then
			local user = g_mystShopMgr:getUserInfo(roleSID)
			if user then
				local isOpen = user:getSmelterMall()
				if isOpen < 1 then
					user:setOpenSmelterMall(1)
					user:setUpdateDB(true)
					user:cast2DB()
				end
			end
		end
	end
end

--玩家A请求交易
function TradeServlet:TradeAreq(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("TradeAReqProtocol" , pbc_string)
	if not req then
		print('TradeServlet:TradeAreq '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local playerA = g_entityMgr:getPlayerBySID(roleSID)
	if not playerA then
		print("TradeServlet:TradeAreq no playerA")
		return 
	end
	local AID = playerA:getID()
	local BID = req.bRoleID

	if g_tradeMgr:getTradeActive()<1 then return end
	--判断A当前能否交易
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerB then 
		print("TradeServlet:TradeAreq no playerB")
		return 
	end

	--判断等级
	local ALevel = playerA:getLevel()
	local BLevel = playerB:getLevel()
	if TRADE_LEVEL_LIMIT>ALevel or TRADE_LEVEL_LIMIT>BLevel then
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_A_LEVEL_LIMIT, 1, {TRADE_LEVEL_LIMIT})
		return
	end

	--判断A是否在B的黑名单	
	if g_relationMgr:isBeBlack(AID,playerB:getSerialID()) then
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_REJECT, 0, {})
		return
	end

	local BSID =  playerB:getSerialID()
	if playerA:getStatus()~=eEntityNormal or playerB:getStatus()~=eEntityNormal then
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_SENCE, 0, {})
		return
	end

	local UserA = g_tradeMgr:getUserInfo(AID)
	local UserB = g_tradeMgr:getUserInfo(BID)
	if not UserA or not UserB then
		--self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
		--print("not on line")
		return
	end

	--玩家是否在交易
	local stateA = UserA:getTradeState()
	local stateB = UserB:getTradeState()
	if TRADE_ON == stateA or TRADE_ON == stateB then
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_ON_TRADING, 0, {})
		--self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
		--print("somebody is trading")
		return
	end

	--B玩家是否允许交易
	local permitB = UserB:getBlockTrade()
	if true == permitB then
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_BLOCK_TRADE, 0, {})
	    --self:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
		--print("b is not permitted")
		return
	end

	local applyTick = UserB:getRecvApplyTick()
	local nowTick = os.time()
	if applyTick+APPLY_TRADE_TICK>=nowTick then
		--玩家B还没回应别人的交易请求
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_BUSY, 0, {})		
		return
	end

	--玩家A的背包空间
	if playerA:getItemMgr():getEmptySize() < 4 then
	    --g_tradeMgr:SEND_TRADE_SC_ARET(AID, BID, BID, false, playerB:getName(), playerB:getLevel())
	    g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_BAG_NOTENOUGH, 0, {})
		return
	end

	self:SEND_TRADE_SC_BREQ(playerB, 0, playerA)
	g_tradeMgr:sendErrMsg2Client(AID, TRADE_REQ_SEND, 0, {})
	UserA:setApplyTrade(BSID,nowTick)	
	UserB:setRecvApplyTick(nowTick)
end

--玩家B回复请求
function TradeServlet:TradeBret(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("TradeBRetProtocol" , pbc_string)
	if not req then
		print('TradeServlet:TradeBret '..tostring(err))
		return
	end

	local playerB = g_entityMgr:getPlayerBySID(roleSID)
	if not playerB then
		print("TradeServlet:TradeBret no playerB")
		return 
	end
	local BID = playerB:getID()	
	local AID = req.aRoleID
	local TID = req.tradeID
	local Bret = req.bAnswer
	local UID = 0

	if g_tradeMgr:getTradeActive()<1 then return end
	local BSID = playerB:getSerialID()

	local UserA = g_tradeMgr:getUserInfo(AID)
	local UserB = g_tradeMgr:getUserInfo(BID)
	if not UserA or not UserB then return end

	--判断是否在同一线
	local playerA = g_entityMgr:getPlayer(AID)
	if not playerA or playerA:getStatus()~=eEntityNormal then
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_OFFLINE, 0, {})
		UserB:setRecvApplyTick(0)
		g_tradeMgr:SEND_TRADE_SC_RET(BID,0,false,AID,playerA:getLevel(),playerA:getName())
		return
	end

	--if playerB:getLine()~=playerA:getLine() then
	if playerB:getScene()~=playerA:getScene() then
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_SENCE, 0, {})
		UserB:setRecvApplyTick(0)
		g_tradeMgr:SEND_TRADE_SC_RET(BID,0,false,AID,playerA:getLevel(),playerA:getName())
		return
	end

	if Bret then
		local itemMgrB = playerB:getItemMgr()
		if not itemMgrB then return end
		if itemMgrB:getEmptySize() < 4 then		    
		    g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_BAG_NOTENOUGH, 0, {})

		    g_tradeMgr:SEND_TRADE_SC_RET(AID,0,false,BID,playerB:getLevel(),playerB:getName())
		    g_tradeMgr:sendErrMsg2Client(AID, TRADE_REJECT, 0, {})
			return
		end

		UserB:setRecvApplyTick(0)

		--判断是否超时  
		local nowTick = os.time()
		if UserA:getApplyTradeTick(BSID)+APPLY_TRADE_TICK<nowTick then
			 g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_NOACTIVE, 0, {})
			 g_tradeMgr:SEND_TRADE_SC_RET(BID,0,false,AID,playerA:getLevel(),playerA:getName())
			return
		end
		
		--A已经与其他玩家开始交易
		local stateA = UserA:getTradeState()
		if TRADE_ON == stateA then
	    	g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_ON_TRADING, 0, {})
	    	g_tradeMgr:SEND_TRADE_SC_RET(BID,0,false,AID,playerA:getLevel(),playerA:getName())
	    	return
	    end

	    g_relationMgr:addMeet(AID, playerB:getSerialID())  	--第一个是玩家动态ID，第二个是熟人静态ID
	    g_relationMgr:addMeet(BID, playerA:getSerialID())  	--第一个是玩家动态ID，第二个是熟人静态ID
	    
	    local trade = g_tradeMgr:createNewTrade(AID, BID)
		if trade then
			trade:tradeOn()
		end
	else
		UserB:setRecvApplyTick(0)

		--判断是否超时  
		local nowTick = os.time()
		if UserA:getApplyTradeTick(BSID)+APPLY_TRADE_TICK<nowTick then
			 g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_NOACTIVE, 0, {})
			return
		end

		g_tradeMgr:sendErrMsg2Client(AID, TRADE_REJECT, 0, {})
		UserB:setRecvApplyTick(0)
		UserA:setApplyTrade(BSID,nil)

		--trade = g_tradeMgr:getTradeInfo(TID)
		--if trade then
			--AID = trade:getUserAID()
			--g_tradeMgr:sendErrMsg2Client(AID, TRADE_REJECT, 0, {})
		--end
		--g_tradeMgr:tradeDelete(TID)
	end
end

--玩家交易框放入物品
function TradeServlet:ItemReq(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("TradeItemReqProtocol" , pbc_string)
	if not req then
		print('TradeServlet:ItemReq '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		print("TradeServlet:ItemReq no player")
		return 
	end
	--local UID = player:getID()
	local TID = req.tradeID	
	local bagSlot = req.bagSlot
	local num = req.itemNum
	local tradeSlot = req.operation

	if g_tradeMgr:getTradeActive()<1 then return end
	local trade = g_tradeMgr:getTradeInfo(TID)
	if trade then
		trade:tradeItem(player, bagSlot, num, tradeSlot)
	end
end

--玩家锁定交易栏
function TradeServlet:TradeLock(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("TradeLockProtocol" , pbc_string)
	if not req then
		print('TradeServlet:TradeLock '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		print("radeServlet:TradeLock no player")
		return 
	end
	--local UID = player:getID()
	local TID = req.tradeID
	
	if g_tradeMgr:getTradeActive()<1 then return end
	local trade = g_tradeMgr:getTradeInfo(TID)
	if trade then
		trade:tradeLock(player)
	end
end

function TradeServlet.APay2BCallBack(AroleSID, ret, money, itemId, itemCount, callBackContext, billno)
	print("function TradeServlet.APay2BCallBack", AroleSID, billno)
	local tradeContext = unserialize(callBackContext)
	local TID = tradeContext.tradeID
	local ver = tradeContext.version
	
	local trade = g_tradeMgr:getTradeInfo(TID)
	if not trade then
		print("TradeServlet.BPay2ACallBack trade id is invlid", TID)
		return TPAY_FAILED
	end
	
	local AID = trade:getUserAID()
	local BID = trade:getUserBID()

	if ret ~= 0 then
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
		trade:close()
		trade:tradeOff()
		g_tradeMgr:tradeFinish(TID)
		return TPAY_FAILED
	end
	
	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerA or not playerB then
		print("TradeServlet.APay2BCallBack two player not online and ret == 0")
		return TPAY_FAILED
	end
	
	if g_tradeMgr:getTradeActive()<1 then 
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
		trade:close()
		trade:tradeOff()
		g_tradeMgr:tradeFinish(TID)
		return TPAY_FAILED 
	end
	
	local otherBillno = trade:SetTransferBillno(AID, billno)
	if otherBillno ~= nil then
		if true == trade:itemRealExchange(tradeContext) then
			g_tPayMgr:TPayScriptConfirmTransferMoney(playerB, otherBillno)
			trade:tradeOff()
			g_tradeMgr:tradeFinish(TID)
			return TPAY_SUCESS
		else
			g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
			g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
			trade:close()
			trade:tradeOff()
			g_tradeMgr:tradeFinish(TID)
			return TPAY_FAILED
		end
	else
		return TPAY_PROCESS	
	end
end

function TradeServlet.BPay2ACallBack(BroleSID, ret, money, itemId, itemCount, callBackContext, billno)
	print("function TradeServlet.BPay2ACallBack", BroleSID, billno)
	local tradeContext = unserialize(callBackContext)
	local TID = tradeContext.tradeID
	local ver = tradeContext.version
	
	local trade = g_tradeMgr:getTradeInfo(TID)
	if not trade then
		print("TradeServlet.BPay2ACallBack trade id is invlid", TID)
		return TPAY_FAILED
	end
	
	local AID = trade:getUserAID()
	local BID = trade:getUserBID()

	if ret ~= 0 then
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
		SEND_TRADE_SC_TRADERET(AID, false)
		SEND_TRADE_SC_TRADERET(BID, false)
		trade:tradeOff()
		g_tradeMgr:tradeFinish(TID)
		return TPAY_FAILED
	end
	
	local playerA = g_entityMgr:getPlayer(AID)
	local playerB = g_entityMgr:getPlayer(BID)
	if not playerA or not playerB then
		print("TradeServlet.BPay2ACallBack two player not online and ret == 0")
		return TPAY_FAILED
	end

	if g_tradeMgr:getTradeActive()<1 then 
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
		SEND_TRADE_SC_TRADERET(AID, false)
		SEND_TRADE_SC_TRADERET(BID, false)
		trade:tradeOff()
		g_tradeMgr:tradeFinish(TID)
		return TPAY_FAILED 
	end
	
	if trade:getVersion() ~= ver then
		g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
		g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
		SEND_TRADE_SC_TRADERET(AID, false)
		SEND_TRADE_SC_TRADERET(BID, false)
		trade:tradeOff()
		g_tradeMgr:tradeFinish(TID)
		return TPAY_FAILED 
	end
	
	local otherBillno = trade:SetTransferBillno(BID, billno)
	if otherBillno ~= nil then
		if true == trade:itemRealExchange(tradeContext) then
			g_tPayMgr:TPayScriptConfirmTransferMoney(playerA, otherBillno)
			trade:tradeOff()
			g_tradeMgr:tradeFinish(TID)
			return TPAY_SUCESS
		else
			g_tPayMgr:TPayScriptCancelTransferMoney(playerA, otherBillno)
			g_tradeMgr:sendErrMsg2Client(AID, TRADE_ERR_FAILED, 0, {})
			g_tradeMgr:sendErrMsg2Client(BID, TRADE_ERR_FAILED, 0, {})
			trade:tradeOff()
			g_tradeMgr:tradeFinish(TID)
			return TPAY_FAILED
		end
	else
		return TPAY_PROCESS	
	end
end

--玩家点击交易
function TradeServlet:DoTrade(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("TradeDoProtocol" , pbc_string)
	if not req then
		print('TradeServlet:DoTrade '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then 
		print("TradeServlet:DoTrade no player")
		return 
	end
	local UID = player:getID()
	local TID = req.tradeID
	local b_trade = req.isTrade
	local ver = req.version
	
	if g_tradeMgr:getTradeActive()<1 then return end
	if true == b_trade then
		local trade = g_tradeMgr:getTradeInfo(TID)
		if trade and false == trade:doTrade(UID, ver) then
			trade:close()
			trade:tradeOff()
			g_tradeMgr:tradeFinish(TID)
		end
	else		
		local trade = g_tradeMgr:getTradeInfo(TID)
		if trade then
			trade:close()
			trade:SEND_TRADE_SC_TRADERET(UID, false)
			trade:tradeOff()
		end
		g_tradeMgr:tradeFinish(TID)
	end

end

--屏蔽交易
function TradeServlet:BlockTrade(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("TradeBlockProtocol" , pbc_string)
	if not req then
		print('TradeServlet:BlockTrade '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local block = req.isBlock
	
	if g_tradeMgr:getTradeActive()<1 then return end
	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		User:setBlockTrade(block)
		self:SEND_TRADE_SC_BLOCKTRADE(UID, User:getBlockTrade())
	end
end

--商城交易
function TradeServlet:TradeMall(event)	
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("TradeMallProtocol" , pbc_string)
	if not req then
		print('TradeServlet:TradeMall '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()	
	local ItemBuyID = req.itemBuyID		--物品购买ID
	local Count = req.num

	--判断系统开关
	local item = g_tradeMgr:getItem(ItemBuyID)
	if not item then return end
	local Type = item.shop_type or 0
	if MALL_TYPE_INGOT==Type or MALL_TYPE_BINDINGOT==Type or MALL_TYPE_MONEY==Type or MALL_TYPE_JIFEN==Type then
		if g_tradeMgr:getMallActive()<1 then return end
	elseif MALL_TYPE_MERITORIOUS==Type then
		if g_tradeMgr:getMeritoriousActive()<1 then return end
	elseif MALL_TYPE_FACTION_MIN<=Type and Type<=MALL_TYPE_FACTION_MAX then
		if g_tradeMgr:getFactionshopActive()<1 then return end
	elseif MALL_TYPE_FACTION_MIN2<=Type and Type<=MALL_TYPE_FACTION_MAX2 then
		if g_tradeMgr:getFactionshopActive()<1 then return end
	else
	end
	
	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		User:Buy(ItemBuyID, Count, false)
	end
end

--商城交易 通过物品ID
function TradeServlet:TradeMallItemID(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("TradeByItemIDProtocol" , pbc_string)
	if not req then
		print('TradeServlet:TradeMallItemID '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local ShopType = req.shopType
	local ItemID = req.itemID		--物品ID
	local Count = req.num

	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		User:BuyByItemID(ShopType,ItemID,Count)
	end
end

--背包卖物品
function TradeServlet:Sell(event)	
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("TradeSellProtocol" , pbc_string)
	if not req then
		print('TradeServlet:Sell '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local bagSlot = req.bagSlot
	local num = req.num
	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		User:SellItem(bagSlot, num)
	end
end

--回购物品
function TradeServlet:BackSell(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("TradeBackSellProtocol" , pbc_string)
	if not req then
		print('TradeServlet:BackSell '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local backSlot = req.bagSlot
	local num = req.num
	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		User:BackItem(backSlot, num)
	end
end

--商城物品查询
function TradeServlet:MallReq(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local hGate = params[3]
	local req, err = protobuf.decode("TradeMallReqProtocol" , pbc_string)
	if not req then
		print('TradeServlet:MallReq '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local Type = req.shopType
	local User = g_tradeMgr:getUserInfo(UID)

	--判断系统开关
	if MALL_TYPE_INGOT==Type or MALL_TYPE_BINDINGOT==Type or MALL_TYPE_MONEY==Type or MALL_TYPE_JIFEN==Type then
		if g_tradeMgr:getMallActive()<1 then return end
	elseif MALL_TYPE_MERITORIOUS==Type then
		if g_tradeMgr:getMeritoriousActive()<1 then return end
	elseif MALL_TYPE_FACTION_MIN<=Type and Type<=MALL_TYPE_FACTION_MAX then
		if g_tradeMgr:getFactionshopActive()<1 then return end
	elseif MALL_TYPE_FACTION_MIN2<=Type and Type<=MALL_TYPE_FACTION_MAX2 then
		if g_tradeMgr:getFactionshopActive()<1 then return end
	else
	end

	if User then
		User:getMallItem(Type,roleSID,hGate)
	end	
end

--全服限购查询	20151031
function TradeServlet:GetALLLimit(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("AllLimitReqProtocol", pbc_string)
	if not req then
		print('TradeServlet:GetALLLimit '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()	
	local ItemID = req.itemBuyID
	if g_TradePublic then 		--and hGate and roleSid 
		g_TradePublic:GetAllLimitLeft(roleSID, ItemID)
	end

	--local User = g_tradeMgr:getUserInfo(UID)
	--if User and ItemID>0 then
		--User:GetAllLimitLeft(ItemID)
	--end
end

function TradeServlet:SEND_TRADE_SC_BREQ(playerB, TID, playerA)
	--local player = g_entityMgr:getPlayer(AID)
	if not playerB or not playerA then
		print("TradeServlet:SEND_TRADE_SC_BREQ no player")		
		return
	end
	local UID = playerB:getID()

	local retData = {}
	retData.tradeID = TID
	retData.aRoleID = playerA:getID()
	retData.aRoleName = playerA:getName()
	retData.aRoleLevel = playerA:getLevel()
	fireProtoMessage(UID,TRADE_SC_BREQ,"TradeBReqProtocol",retData)
end

function TradeServlet:SEND_TRADE_SC_BLOCKTRADE(UID, Block)
	local retData = {}
	retData.isBlock = Block
	fireProtoMessage(UID,TRADE_SC_BLOCKTRADE,"TradeBlockRetProtocol",retData)
end

function TradeServlet:SpeTrade(event)
	local params = event:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]
	local req, err = protobuf.decode("SpeTradeProtocol" , pbc_string)
	if not req then
		print('TradeServlet:SpeTrade '..tostring(err))
		return
	end

	--二次密码验证
	if g_SecondPassMgr:IsRoleHasCheckedForLua(roleSID) ~= 1 then
		return
	end	

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local UID = player:getID()
	local ItemParam = req.buyParam    	--1 小飞鞋
	local paramTemp = req.addParam

	if g_tradeMgr:getMallActive()<1 then return end
	local User = g_tradeMgr:getUserInfo(UID)
	if User then
		User:speTrade(UID, ItemParam, paramTemp)
	end
end

function TradeServlet.getInstance()
	return TradeServlet()
end

g_eventMgr:addEventListener(TradeServlet.getInstance())
