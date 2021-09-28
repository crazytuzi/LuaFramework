--DigBossServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  DigBossServlet.lua
 --* Author:  liucheng
 --* Modified: 2015年6月1日
 --* Purpose: 挖掘功能消息接口
 -------------------------------------------------------------------*/
require "system.digboss.DigBossManager"

DigBossServlet = class(EventSetDoer, Singleton)

function DigBossServlet:__init()
	self._doer = {
		[BOSSDIG_CS_DIG] = DigBossServlet.BossDigReq,
	}
end

function DigBossServlet:sendErrMsg2Client(roleId, eventID, errId, paramCount, params)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(eventID)
	retBuff:pushShort(errId)
	retBuff:pushShort(self:getCurEventID())
	retBuff:pushChar(paramCount)

	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end

	g_engine:fireLuaEvent(roleId, retBuff)
end

--类似跑马灯消息
function DigBossServlet:sendBroad2Client(errId, paramCount, params, roleID)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(EVENT_PUSH_MESSAGE)
	retBuff:pushShort(errId)
	retBuff:pushShort(self:getCurEventID())	--XunBaoServlet.getInstance():getCurEventID()
	retBuff:pushChar(paramCount)

	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end
	
	g_engine:broadWorldEvent(retBuff)
end

function DigBossServlet:BossDigReq(buffer1)
	local params = buffer1:getParams()
	local buffer = params[1]
	local roleID = buffer:popInt()
	local BossID = buffer:popInt()

	local player = g_entityMgr:getPlayer(roleID)
	if player then
		local roleSID = player:getSerialID()
		local copyID = player:getCopyID()
		if copyID>0 and table.contains(g_DigBossMgr._BossDig, BossID) then			
			local DigInfo = g_DigBossMgr._UserDigInfo[roleSID]
			if DigInfo and DigInfo.BossID==BossID and DigInfo.Num<DIG_MAX then
				--判断是否有挖掘道具 1021   如果没有就用元宝
				local DigType = 0
				local itemMgr = player:getItemMgr()
				local count = itemMgr:getItemCount(DIG_PROP_ID)
				if count<1 then
					--判断元宝是否充足
					local Ingot = player:getIngot()
					if Ingot >= DIG_INGOT then
						DigType = 2
					end
				else
					DigType = 1
				end

				if 0 == DigType then
					--挖掘符不够  元宝也不够
					self:sendErrMsg2Client(player:getID(), EVENT_XUNBAO_SETS, DIG_ERR_INGOT, 0)

					local retBuff = LuaEventManager:instance():getLuaRPCEvent(BOSSDIG_SC_RET)
					retBuff:pushBool(true)
					retBuff:pushInt(DIG_MAX-DigInfo.Num)	--挖掘不成功  本次不计算
					g_engine:fireLuaEvent(player:getID(), retBuff)
					return
				elseif 1 == DigType then
					--使用挖掘符

					--显示使用的道具
					local ItemTmp = itemMgr:findItemByItemID(DIG_PROP_ID)
					if ItemTmp then
						local DigPropName = ItemTmp:getName()		--boss挖掘使用的道具的名字
						if DigPropName then
							self:sendErrMsg2Client(player:getID(), EVENT_ITEM_SETS, DIG_MSG_ITEM_USE, 1, {'['..DigPropName..']X1'})
						end
					end

					local errId = 0
					itemMgr:destoryItem(DIG_PROP_ID, 1, errId)
				elseif 2 == DigType then
					--使用元宝
					local Ingot = player:getIngot()
					local CurIngot = Ingot-DIG_INGOT
					player:setIngot(CurIngot)
					g_achieveSer:costIngot(roleSID, DIG_INGOT)	--消耗元宝 可能 达到成就 20150813

					--元宝日志	20150907
					g_PayRecord:Record(roleID, -DIG_INGOT, CURRENCY_INGOT, DIG_INGOT_RECORD)

					--货币变化日志	20150907
				end
				DigInfo.Num = DigInfo.Num+1
				--通知客户端可挖掘
				local retBuff = LuaEventManager:instance():getLuaRPCEvent(BOSSDIG_SC_RET)
				retBuff:pushBool(true)
				retBuff:pushInt(DIG_MAX-DigInfo.Num)
				g_engine:fireLuaEvent(player:getID(), retBuff)
							
				local ret,strDrop = rewardByDropID(roleSID, DIG_DROP_ID, 41, 94)			
				if not strDrop then return end
				--返回物品			
				local dropItems = unserialize(strDrop)
				if #dropItems <= 0 then
					return
				end

				local GetPropID = dropItems[1].itemID
				if not GetPropID then 
					return 
				end

				local findItem = false
				local GetPropName
				for i,v in pairs(g_DigBossMgr._DigDropItem) do
					if GetPropID==v.itemID then
						GetPropName = v.itemName
						findItem  = true
						break
					end						
				end

				if GetPropName then
					if table.contains(DIG_SPE_ITEM_GET, GetPropID) then
						self:sendBroad2Client(DIG_BROAD_MSG_ID, 2, {player:getName(),GetPropName},player:getID())
					else						
						--显示获得的道具
						local Buff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_PICKUP)
						Buff:pushChar(1)	--0 经验  1 物品  2 金币
						Buff:pushInt(GetPropID)
						g_engine:fireLuaEvent(player:getID(), Buff)
					end
					--物品产出	20150907
					if dropItems[1].count and dropItems[1].bind then
						local countTmp = itemMgr:getItemCount(GetPropID)
					end
				end
				return
			end
		end
		--不可挖掘
		local retBuff = LuaEventManager:instance():getLuaRPCEvent(BOSSDIG_SC_RET)
		retBuff:pushBool(false)
		retBuff:pushInt(0)
		g_engine:fireLuaEvent(player:getID(), retBuff)
	end
end

function DigBossServlet.getInstance()
	return DigBossServlet()
end

g_eventMgr:addEventListener(DigBossServlet.getInstance())