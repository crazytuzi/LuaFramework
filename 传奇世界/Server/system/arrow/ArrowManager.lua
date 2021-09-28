--ArrowManager.lua
--/*-----------------------------------------------------------------
--* Module:  ArrowManager.lua
--* Author:  liucheng
--* Modified: 2016年3月30日
--* Purpose: Implementation of the class ArrowManager 
-------------------------------------------------------------------*/

require "system.arrow.ArrowConstant"
require "system.arrow.ArrowServlet"

ArrowManager = class(nil, Singleton)

function ArrowManager:__init()
	self._useArrowInfo = {}
	self._user = {}	
	
	g_listHandler:addListener(self)
end

--使用穿云箭
function ArrowManager:CallMember(roleID,slotIndex)
	local player = g_entityMgr:getPlayer(roleID)
	if not player then return end

	local roleSID = player:getSerialID()
	local RoleName = player:getName()
	local copyID = player:getCopyID()
	local curmapID = player:getMapID()		--6004 竞技场
	local curPos = player:getPosition()
	local activityMap = {6000,6001,6002,6003,6004,7000,7001,7002,7003}
	if copyID>0 or table.contains(activityMap,curmapID) then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_COPYMAP,0)			--在副本中无法使用此道具
		return
	end

	local factionID = player:getFactionID()
	if not factionID or factionID<=0 then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_NO_FACTINO,0)		--没有帮会
		return
	end

	local nowTime = os.time()
	if not self._useArrowInfo[roleSID] then
		self._useArrowInfo[roleSID] = 0
	end

	if nowTime-self._useArrowInfo[roleSID]<CALL_MEMBER_SPACE then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_IN_CD,1,{CALL_MEMBER_SPACE})	--道具还在时间间隔内
		return
	end
	self._useArrowInfo[roleSID] = nowTime

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local item = itemMgr:findItem(slotIndex)
	if not item then						--指定的物品
		--self:fireMessage(ITEM_CS_COMPOUND, {roleID}, EVENT_ITEM_SETS, Item_OP_Result_ItemNotExist, 0)
		return
	end

	local sourceItemID = item:getProtoID()
	local sourceName = item:getName()
	local sourceCnt = item:getCount()
	if sourceCnt<1 or sourceItemID~=ARROW_ITEM_ID then
		return
	end

	local flag=0
	local errcode=0
	flag, errcode = itemMgr:removeBagItem(slotIndex, 1, errcode)
	if not flag then									--去掉原物品个数 失败
		--self:fireMessage(ITEM_CS_COMPOUND, {roleID}, EVENT_ITEM_SETS, errcode, 0)
		return
	end

	self:sendErrMsg2Client(player:getID(),EVENT_ITEM_SETS,CALL_MEMBER_SUCC,1,{sourceName})	--使用成功
	
	local roleCurPos = {x=curPos.x,y=curPos.y}
	local luabuff = g_buffMgr:getLuaRPCEvent(SPILLFLOWER_SS_CALLMEMBER)
	luabuff:pushInt(roleSID)
	luabuff:pushInt(factionID)
	luabuff:pushInt(curmapID)
	luabuff:pushString(serialize(roleCurPos))
	luabuff:pushString(RoleName)
	
	g_engine:fireWorldEvent(FACTION_DATA_SERVER_ID, luabuff)

	--20150907
	local BindTmp = item:isBinded() and 1 or 0
end

--传送到玩家身边
function ArrowManager:SendToMember(RoleID,TRoleSID,TRoleMapID,TRolePos)
	local player = g_entityMgr:getPlayer(RoleID)
	if not player then return end

	local roleSID = player:getSerialID()
	local copyID = player:getCopyID()
	local curmapID = player:getMapID()
	
	if copyID>0 or 6004==curmapID or 7002==curmapID or 6000==curmapID or 6003==curmapID then
		self:sendErrMsg2Client(player:getID(),EVENT_LITTERFUN_SETS,CALL_MEMBER_IN_COPY,0)			--请结束战斗后再支援
		return
	end

	--local Tplayer = g_entityMgr:getPlayerBySID(TRoleSID)
	--if not Tplayer then return end
	--local pos = Tplayer:getPosition()
	--local TcurmapID = Tplayer:getMapID()		--6004 竞技场	
	--g_sceneMgr:enterPublicScene(roleID, Tplayer:getMapID(), pos.x, pos.y)
	local curPos = unserialize(TRolePos)
	if g_entityMgr:canSendto(RoleID, TRoleMapID, curPos.x, curPos.y) then
		g_sceneMgr:enterPublicScene(RoleID, TRoleMapID, curPos.x, curPos.y)
	end
end

function ArrowManager:sendErrMsg2Client(roleId, eventID, errId, paramCount, params)
	local retBuff = LuaEventManager:instance():getLuaRPCEvent(FRAME_SC_MESSAGE)
	retBuff:pushShort(eventID)
	retBuff:pushShort(errId)
	retBuff:pushShort(SpillFlowerServlet.getInstance():getCurEventID())
	retBuff:pushChar(paramCount)

	for i=1, paramCount do
		retBuff:pushString(tostring(params[i])or "")
	end

	g_engine:fireLuaEvent(roleId, retBuff)
end

function ArrowManager.getInstance()
	return ArrowManager()
end

g_ArrowMgr = ArrowManager.getInstance()