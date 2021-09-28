--CardPrizeMgr.lua
--/*-----------------------------------------------------------------
 --* Module:  CardPrizeMgr.lua
 --* Author:  Hu Suorong
 --* Modified: 2016年1月6日 10:14:14
 --* Purpose: Implementation of the class CardPrizeMgr
 -------------------------------------------------------------------*/
CardPrizeMgr = class(nil, Singleton)
function CardPrizeMgr:__init()
	self._prizeInfos = {}     --在线玩家奖励信息表
	self._guardCopyLastLayer = {} --恶魔城副本记录最后完成的关卡数目	
	g_listHandler:addListener(self)
end

function CardPrizeMgr:__release()
end

function CardPrizeMgr.getInstance()
	return CardPrizeMgr()
end

function  CardPrizeMgr:OpenCardPrizeWindow(roleID,curlayer,copyId)
	--local retBuff = LuaEventManager:instance():getLuaRPCEvent(CARDPRIZE_SC_OPEN)
	local ret = {}
	ret.dropId = {}
	local prizelist = {}
	prizelist = self._prizeInfos[roleID]
	for v,k in pairs(prizelist) do
		table.insert(ret.dropId,v)
	end
	ret.curlayer = curlayer
	ret.copyId = copyId
	fireProtoMessage(roleID, CARDPRIZE_SC_OPEN, 'CardPrizeOpenProtocol', ret)
end

function CardPrizeMgr:checkHasPrize(roleID)
	if self._prizeInfos[roleID]==nil then
		return false
	else
		return true
	end

end

function CardPrizeMgr:addPrizeInfo(roleID,proto)
	self._prizeInfos[roleID] = proto:getCardPrize()
end

function CardPrizeMgr:addGuardCopyLastLayer(roleID,lastLayer)
	self._guardCopyLastLayer[roleID] = lastLayer
end

function CardPrizeMgr:JudgeMoneyTypeItem(itemid)
	if itemid == 999998 or itemid == 999999 or itemid == 222222 or itemid == 111111 or itemid == 333333 or itemid == 444444 or itemid == 555555 or itemid == 666666 or itemid == 777777 then
		return true
	else
		return false
	end
end

--1	金币 2	绑定金币 3	元宝 4	绑定元宝 5	声望值 6	熔炼值 	7	行会贡献值 8	行会贡献值
function CardPrizeMgr:getMoneyType(itemid)
	if itemid == 999998 or itemid == 999999 then
		return 1
	elseif itemid == 222222 then
		return 3
	elseif itemid == 888888 then
		return 4
	elseif itemid == 777777 then
		return 5
	elseif itemid == 666666 then
		return 6
	elseif itemid == 111111 then
		return 7
	end
end


function CardPrizeMgr:drawPrize(roleID,roleSId,drawIndex,moduleIndex)
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	local rnd = math.random(100)
	local prizelist = {}
	prizelist = self._prizeInfos[roleID]
	if not prizelist then return end
	local count = 0
	local rewardData = {}
	local ret = false
	for v,k in pairs(prizelist) do
		prize = v
		count = k+count
		if count >= rnd then
			if moduleIndex == 1 then 
				rewardData = g_entityMgr:dropItemToEmail(roleSId, prize, 51, 53,0)
				g_litterfunServlet:sendErrMsg2Client(roleID,20,1,{"通天塔翻牌奖励"})
			elseif moduleIndex == 2 then
				rewardData = g_entityMgr:dropItemToEmail(roleSId, prize, 15, 17,0,false,"恶魔城")
				g_litterfunServlet:sendErrMsg2Client(roleID,20,1,{"恶魔城翻牌奖励"})
				local lastLayer = self._guardCopyLastLayer[roleID]
				g_copyMgr:setPlayerLastGuard(roleID,lastLayer)
			else
				ret,rewardData = rewardByDropID(roleSId,prize,35,0) 
			end
			local retStr = {}
			retStr.rewardData = serialize(rewardData)
			retStr.drawIndex = drawIndex
			fireProtoMessage(roleID, CARDPRIZE_SC_REP, 'CardPrizeRetProtocol', retStr)

			self._prizeInfos[roleID] = nil
			return
		end
	end
end

g_CardPrizeMgr = CardPrizeMgr.getInstance()



