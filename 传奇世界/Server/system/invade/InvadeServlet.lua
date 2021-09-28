--InvadeServlet.lua
--/*-----------------------------------------------------------------
 --* Module:  InvadeServlet.lua
 --* Author:  Andy
 --* Modified: 2016年03月21日
 --* Purpose: Implementation of the class InvadeServlet
 -------------------------------------------------------------------*/

InvadeServlet = class(EventSetDoer, Singleton)

function InvadeServlet:__init()
	self._doer = {
		[INVADE_CS_REWARD] = InvadeServlet.reward,
	}
end

--玩家领取山贼入侵奖励
function InvadeServlet:reward(event)
    local params = event:getParams()
	local pbc_string, dbid = params[1], params[2]
	-- self:decodeProto(pbc_string, "InvadeReward")
	local player = g_entityMgr:getPlayerBySID(dbid)
	if not player then
		return
	end
	local roleID = player:getID()
	local dropID = g_InvadeMgr:getUserDropID(roleID)
	if dropID and dropID ~= 0 then
		local reward = g_InvadeMgr:getRewardByDropID(dropID)
		if table.size(reward) > 0 then
			local rewards = {}
			local itemMgr = player:getItemMgr()
			if itemMgr and itemMgr:getEmptySize(Item_BagIndex_Bag) >= table.size(reward) then
				for _, item in pairs(reward) do
					itemMgr:addItem(Item_BagIndex_Bag, item.itemID, item.count, item.bind, 0, 0, item.strength)
					g_logManager:writePropChange(dbid, 1, 205, item.itemID, 0, item.count, item.bind)
					local reward = {}
					reward.itemID = item.itemID
					reward.count = item.count
					reward.bind = item.bind
					reward.strength = item.strength
					reward.timeLimit = 0
					table.insert(rewards, reward)
				end
			else
				local offlineMgr = g_entityMgr:getOfflineMgr()
				local email = offlineMgr:createEamil()
				email:setDescId(INVADE_EMAIL_ID)
				for _, item in pairs(reward) do
					if item.bind == 0 then
						item.bind = false
					end
					email:insertProto(item.itemID, item.count, item.bind, item.strength)
					local reward = {}
					reward.itemID = item.itemID
					reward.count = item.count
					reward.bind = item.bind
					reward.strength = item.strength
					reward.timeLimit = 0
					table.insert(rewards, reward)
				end
				offlineMgr:recvEamil(dbid, email, 205, 0)
			end
			dropID = 0
			g_InvadeMgr:setUserDropID(roleID, dropID)
			g_commonMgr:setInvadeDropID(roleID, dropID)
			fireProtoMessage(roleID, INVADE_SC_REWARD_RET, "InvadeRewardRet", {reward = rewards})
		end
	end
end

function InvadeServlet:decodeProto(pb_str, protoName)
	local protoData, errorCode = protobuf.decode(protoName, pb_str)
	if not protoData then
		print("decodeProto error! InvadeServlet:", protoName, errorCode)
		return
	end
	return protoData
end

function InvadeServlet.getInstance()
	return InvadeServlet()
end

g_eventMgr:addEventListener(InvadeServlet.getInstance())