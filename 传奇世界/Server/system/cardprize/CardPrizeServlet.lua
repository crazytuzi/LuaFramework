--CardPrizeServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  CardPrizeServlet.lua
 --* Author:  Hu Suorong
 --* Modified: 2015年1月6日 9:24:14
 --* Purpose: Implementation of the class CardServlet
 -------------------------------------------------------------------*/

 require "system.cardprize.CardPrizeMgr"

 CardPrizeServlet = class(EventSetDoer, Singleton)

 function CardPrizeServlet:__init()
	self._doer = {
			[CARDPRIZE_CS_REQ] = CardPrizeServlet.doDrawCard,
		}
end

function CardPrizeServlet:__release()
end

function CardPrizeServlet.getInstance()
	return CardPrizeServlet()
end

function CardPrizeServlet:doDrawCard(event)
	local params = event:getParams()
	local buffer = params[1]
	local sid = params[2]
	local player = g_entityMgr:getPlayerBySID(sid)
	if not player then return end
	local roleID = player:getID()
	local req, err = protobuf.decode("CardPrizeProtocol" , buffer)
	if not req then
		print('CardPrizeServlet:doDrawCard '..tostring(err))
		return
	end
	local drawIndex = req.drawIndex
	local moduleIndex = req.moduleIndex

	g_CardPrizeMgr:drawPrize(roleID,sid,drawIndex,moduleIndex)
end

g_eventMgr:addEventListener(CardPrizeServlet.getInstance())

g_CardPrizeServlet = CardPrizeServlet.getInstance()