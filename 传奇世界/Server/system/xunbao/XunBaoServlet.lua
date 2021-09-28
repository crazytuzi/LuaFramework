--XunBaoServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  XunBaoServlet.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年6月16日
 --* Purpose: Implementation of the class XunBaoServlet
 -------------------------------------------------------------------*/

XunBaoServlet = class(EventSetDoer, Singleton)

function XunBaoServlet:__init()
	self._doer = {
			--1[XUNBAO_CS_ZHAOHUAN]		=	XunBaoServlet.Zhaohuan,			
			--1[XUNBAO_CS_REQ]				=	XunBaoServlet.Req,			
			--1[XUNBAO_CS_REWARD]			=	XunBaoServlet.Reward,
			--1[XUNBAO_CS_FREE]			=   XunBaoServlet.FreeXunbaoReq,

			--[XUNBAO_CS_REFRESH]			=   XunBaoServlet.Refresh,
			--[XUNBAO_CS_WITHDRAW]		=   XunBaoServlet.Withdraw,
			--[XUNBAO_CS_BROADCAST]		=	XunBaoServlet.Broadcast,
		}			
end

function XunBaoServlet:Reward(event)
	local params = event:getParams()
	local buffer = params[1]	
	local UID = buffer:popInt()
	
	local User = g_XunBaoMgr._UserInfos[UID]
	if User then
		if User._step < 4 then
			g_XunBaoMgr:sendErrMsg2Client(User:getUID(), XUNBAO_ERR_NO_LUCK, 0, {})
			return
		end
		local player = g_entityMgr:getPlayer(UID)
		if player then
			local itemMgr = player:getItemMgr()
			if itemMgr then
				local slot = itemMgr:getEmptySize()
				if slot < 1 then
					g_XunBaoMgr:sendErrMsg2Client(User:getUID(), XUNBAO_ERR_NOSLOT, 0, {})
					return
				end
				User._luck = 0
				User._step = 0
				User._time = 0
				local itemID = User._reward
				local itemNum = User._rewardNum                            --1
				itemMgr:addBagItem(itemID, itemNum, true)
				
				--产出物品日志	20150907
				
				local buff = LuaEventManager:instance():getLuaRPCEvent(XUNBAO_SC_REWARD)
				buff:pushInt(User._step)
				buff:pushInt(math.max((User._time - os.time()), 0))
				buff:pushInt(User._reward)
				buff:pushInt(itemNum)
				g_engine:fireLuaEvent(UID, buff)

				--User:refresh()
				User:setUpdateDB(true)
				User:cast2DB()

				--下一次的集字奖励
				User._luck = 0
				User._step = 0
				User._time = 0
				local buff = LuaEventManager:instance():getLuaRPCEvent(XUNBAO_SC_REFRESH)
				buff:pushInt(User._reward)
				buff:pushInt(User._rewardNum)
				if User._buyCount > XUNBAO_REFRESH_MAX then
					buff:pushInt(XUNBAO_REFRESH[XUNBAO_REFRESH_MAX])
				else
					buff:pushInt(XUNBAO_REFRESH[User._buyCount])
				end
				buff:pushInt(User._step)
				buff:pushInt(math.max((User._time - os.time()), 0))
				g_engine:fireLuaEvent(UID, buff)
			end
		end
	end
end

function XunBaoServlet:Refresh(event)
	local params = event:getParams()
	local buffer = params[1]	
	local UID = buffer:popInt()
	
	local User = g_XunBaoMgr._UserInfos[UID]
	if User then
		local player = g_entityMgr:getPlayer(UID)
		if player then
			local ingot = player:getIngot()
			local count = User._buyCount
			if count > XUNBAO_REFRESH_MAX then
				count = XUNBAO_REFRESH_MAX
			end
			local price = XUNBAO_REFRESH[count]
			if ingot < price or price < 0 then
				g_XunBaoMgr:sendErrMsg2Client(User:getUID(), XUNBAO_ERR_NOINGOT, 0, {})
				return
			end
			--扣元宝
			player:setIngot(ingot - price)
			--元宝日志
			g_PayRecord:Record(User:getUID(), -price, CURRENCY_INGOT, 21)
			--货币变化日志	20150907

			User:refresh()			

			User._buyCount = User._buyCount + 1
			User._luck = 0
			User._step = 0
			User._time = 0
			local buff = LuaEventManager:instance():getLuaRPCEvent(XUNBAO_SC_REFRESH)
			buff:pushInt(User._reward)
			buff:pushInt(User._rewardNum)
			if User._buyCount > XUNBAO_REFRESH_MAX then
				buff:pushInt(XUNBAO_REFRESH[XUNBAO_REFRESH_MAX])
			else
				buff:pushInt(XUNBAO_REFRESH[User._buyCount])
			end
			buff:pushInt(User._step)
			buff:pushInt(math.max((User._time - os.time()), 0))
			g_engine:fireLuaEvent(UID, buff)

			User:setUpdateDB(true)
			User:cast2DB()
		end
	end
end

function XunBaoServlet:Req(event)	
	local params = event:getParams()
	local buffer = params[1]	
	local UID = buffer:popInt()
	
	local User = g_XunBaoMgr._UserInfos[UID]
	if User then
		if User._time == 0 then
			User._luck = 0
			User._step = 0
		end

		--if 0==User._reward and 0==User._rewardNum then
			--User:refresh()
			--User:setUpdateDB(true)
			--User:cast2DB()
		--end

		local buff = LuaEventManager:instance():getLuaRPCEvent(XUNBAO_SC_RET)
		buff:pushInt(User._step)
		buff:pushInt(User._reward)
		buff:pushInt(User._rewardNum) 					--100
		if User._buyCount > XUNBAO_REFRESH_MAX then
			buff:pushInt(XUNBAO_REFRESH[XUNBAO_REFRESH_MAX])
		else
			buff:pushInt(XUNBAO_REFRESH[User._buyCount])
		end
		buff:pushInt(math.max((User._time - os.time()), 0))
		buff:pushInt(math.max((User._free - os.time()), 0))
		g_engine:fireLuaEvent(UID, buff)
	end
end

function XunBaoServlet:Zhaohuan(event)	
	local params = event:getParams()
	local buffer = params[1]
	local UID = buffer:popInt()
	local style = buffer:popInt()
	
	local User = g_XunBaoMgr:getUserInfo(UID)
	--print("style"..style)
	if User then
		local taskID = g_taskMgr:getMainTaskId(UID)
		if taskID == 10081 then
			User:ZhaoHuan()
			return
		end
		
		if User._time == 0 then
			User._luck = 0
			User._step = 0
		end

		if style == 1 then
			User:ZhaoHuan1()
			return
		elseif style == 2 then
			User:ZhaoHuan2()
			return
		elseif style == 3 then
			User:ZhaoHuan3()
			return
		elseif style == 4 then
			User:ZhaoHuan4()
			return
		else
		end
	end

end

function XunBaoServlet:FreeXunbaoReq(event)
	local params = event:getParams()
	local buffer = params[1]
	local UID = buffer:popInt()
	
	local bFree = false
	local User = g_XunBaoMgr:getUserInfo(UID)
	if User then
		if os.time()>=User._free then
			bFree = true
		end
	end

	local buff = LuaEventManager:instance():getLuaRPCEvent(XUNBAO_SC_FREE)
	buff:pushBool(bFree)
	g_engine:fireLuaEvent(UID, buff)
end

function XunBaoServlet.getInstance()
	return XunBaoServlet()
end

g_eventMgr:addEventListener(XunBaoServlet.getInstance())
