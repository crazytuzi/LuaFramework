--SmelterManager.lua
--/*-----------------------------------------------------------------
 --* Module:  SmelterManager.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年9月12日
 --* Purpose: Implementation of the class SmelterManager
 -------------------------------------------------------------------*/

require ("system.smelter.SmelterServlet")
require ("system.smelter.SmelterConstants")
require ("system.smelter.SmelterReader")

SmelterManager = class(nil, Singleton)

function SmelterManager:__init()
	--loadSmelterDB()
	loadPropData()
	g_listHandler:addListener(self)
end

function SmelterManager:sendErrMsg2Client(roleId, errId, paramCount, params)
	fireProtoSysMessage(SmelterServlet.getInstance():getCurEventID(), roleId, EVENT_SMELTER_SETS, errId, paramCount, params)
end

function SmelterManager:Resolve(roleID, slotList)
	local tplayer = g_entityMgr:getPlayer(roleID)
	if not tplayer then	return end
	local tRoleSID = tplayer:getSerialID()

	local itemMgr = tplayer:getItemMgr()
	if not itemMgr then return end

	local basicGetMoney = 0           --商店回收价
	local smelterGet = {}
	local smelterGetSoul = 0
	local smelterGetqicai = 0
	local smelterPropNums = 0         --本次成功熔炼的装备

	for i,v in pairs(slotList) do
		local equipType = itemMgr:getItemEquipType(v)
		local strengthLvl = itemMgr:getItemEquipStrengthLevel(v)
		local itemID = 0
		local itemLevel = 0				

		local item = itemMgr:findItem(v)
		if item then
			itemID = item:getProtoID()
			itemLevel = item:getLevel()
			local equipType = itemMgr:getItemEquipType(v)
			local strengthLvl = itemMgr:getItemEquipStrengthLevel(v)

			--如果该装备强化过
			if EquipStreng[equipType] then
				if EquipStreng[equipType][strengthLvl] then				
					local backID1 = EquipStreng[equipType][strengthLvl].backID1 or 0
					local backNum1 = EquipStreng[equipType][strengthLvl].backNum1 or 0
					if backID1>0 and backNum1>0 then
						if not smelterGet[backID1] then
							smelterGet[backID1] = 0
						end
						smelterGet[backID1] = smelterGet[backID1] + backNum1
					end

					backID1 = EquipStreng[equipType][strengthLvl].backID2 or 0
					backNum1 = EquipStreng[equipType][strengthLvl].backNum2 or 0
					if backID1>0 and backNum1>0 then
						if not smelterGet[backID1] then
							smelterGet[backID1] = 0
						end
						smelterGet[backID1] = smelterGet[backID1] + backNum1
					end

					backID1 = EquipStreng[equipType][strengthLvl].backID3 or 0
					backNum1 = EquipStreng[equipType][strengthLvl].backNum3 or 0
					if backID1>0 and backNum1>0 then
						if not smelterGet[backID1] then
							smelterGet[backID1] = 0
						end
						smelterGet[backID1] = smelterGet[backID1] + backNum1
					end

					backID1 = EquipStreng[equipType][strengthLvl].backID4 or 0
					backNum1 = EquipStreng[equipType][strengthLvl].backNum4 or 0
					if backID1>0 and backNum1>0 then
						if not smelterGet[backID1] then
							smelterGet[backID1] = 0
						end
						smelterGet[backID1] = smelterGet[backID1] + backNum1
					end
				end			
			end

			if g_XunBaoMgr._ItemCompandAndSmelter then
				if g_XunBaoMgr._ItemCompandAndSmelter.smelter then
					local smelterTable = g_XunBaoMgr._ItemCompandAndSmelter.smelter
					if smelterTable[itemLevel] then
						for m,n in pairs(smelterTable[itemLevel]) do
							if n.itemID then
								if itemID==n.itemID then
									if n.soul and n.soul>0 then
										smelterGetSoul = smelterGetSoul + n.soul
									end

									if n.sellPrice and n.sellPrice>0 then
										basicGetMoney = basicGetMoney + n.sellPrice
									end

									if n.qicai2 and n.qicai2>0 then										
										local rand = math.random(n.qicai2)
										if rand<n.qicai1 then
											rand=n.qicai1
										end
										smelterGetqicai = smelterGetqicai + rand
									end
									break
								end
							end
						end
					end
				end
			end		

			--从背包删除道具
			smelterPropNums = smelterPropNums + 1
			local errorCode = 0
			itemMgr:deleteBagItem(v, errorCode)
			--道具变化日志	20150907		
		end
	end

	if smelterGetSoul>0 then
		local oldSoulScore = tplayer:getSoulScore()
		tplayer:setSoulScore(oldSoulScore+smelterGetSoul)		
	end

	if smelterGetqicai>0 then
		if not smelterGet[SMELTER_ITEM_QICAI] then
			smelterGet[SMELTER_ITEM_QICAI] = 0
		end		
		smelterGet[SMELTER_ITEM_QICAI] = smelterGet[SMELTER_ITEM_QICAI] + smelterGetqicai
	end

	local smelterGetMoney = 0	
	for i,v in pairs(smelterGet) do
		if i>0 then
			if 999998==i then
				smelterGetMoney = smelterGetMoney + v
			else
				local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
				local freeSlotNum = itemMgr:getEmptySize()
				if freeSlotNum < 1 then
					--提示背包满
					local offlineMgr = g_entityMgr:getOfflineMgr()
					local email = offlineMgr:createEamil()
					local emailConfigId = 31
					email:setDescId(emailConfigId)
					email:insertProto(i, v, true)
					offlineMgr:recvEamil(tplayer:getSerialID(), email, 5, 0)
				else
					itemMgr:addItem(Item_BagIndex_Bag,i,v, 1, 0, 0, 0, 0)
				end
			end
		end
	end
	
	if smelterGetMoney+basicGetMoney>0 then
		local oldMoney = tplayer:getMoney()
		tplayer:setMoney(oldMoney+smelterGetMoney+basicGetMoney)
	end
	
	local Operation = false
	if smelterPropNums>0 then
		Operation = true
	end	

	local retData = {}
	retData.newEquipID = 0 								--新的紫装ID
	retData.smelterRet = Operation
	retData.getMoney = smelterGetMoney+basicGetMoney 	--金币
	retData.getSoulscore = smelterGetSoul 				--熔炼值
	fireProtoMessage(tplayer:getID(),SMELTER_SC_RET,"SmelterRetProtocol",retData)

	--提示
	self:smelterResultTip(tplayer:getID(),smelterGetMoney,basicGetMoney,smelterGetSoul,smelterGet)
end

function SmelterManager:smelterResultTip(roleID,smelterGetMoney,basicGetMoney,smelterGetSoul,smelterGet)
	if g_XunBaoMgr._ItemSmelterSpecial then
		local specialItemIDTmp = {30000,30001,30002,999998,666666,1219}
		local msgstr = ""
		if smelterGetMoney+basicGetMoney>0 then
			local ItemName = g_XunBaoMgr._ItemSmelterSpecial[999998].itemName
			msgstr = msgstr .. ItemName .. tostring(smelterGetMoney+basicGetMoney)
		end

		if smelterGetSoul>0 then
			if #msgstr>0 then
				msgstr = msgstr .. "，"
			end
			local ItemName = g_XunBaoMgr._ItemSmelterSpecial[666666].itemName
			msgstr = msgstr .. ItemName .. tostring(smelterGetSoul)
		end

		if smelterGet[1219] and smelterGet[1219]>0 then
			if #msgstr>0 then
				msgstr = msgstr .. "，"
			end
			local ItemName = g_XunBaoMgr._ItemSmelterSpecial[1219].itemName
			msgstr = msgstr .. ItemName .. tostring(smelterGet[1219])
		end

		if smelterGet[30000] and smelterGet[30000]>0 then
			if #msgstr>0 then
				msgstr = msgstr .. "，"
			end
			local ItemName = g_XunBaoMgr._ItemSmelterSpecial[30000].itemName
			msgstr = msgstr .. ItemName .. tostring(smelterGet[30000])
		end 

		if smelterGet[30001] and smelterGet[30001]>0 then
			if #msgstr>0 then
				msgstr = msgstr .. "，"
			end
			local ItemName = g_XunBaoMgr._ItemSmelterSpecial[30001].itemName
			msgstr = msgstr .. ItemName .. tostring(smelterGet[30001])
		end

		if smelterGet[30002] and smelterGet[30002]>0 then
			if #msgstr>0 then
				msgstr = msgstr .. "，"
			end
			local ItemName = g_XunBaoMgr._ItemSmelterSpecial[30002].itemName
			msgstr = msgstr .. ItemName .. tostring(smelterGet[30002])
		end
		self:sendErrMsg2Client(roleID,SMELTER_SUCC_BASIC,1,{msgstr})
	end
end


function SmelterManager.getInstance()
	return SmelterManager()
end

g_smelterMgr = SmelterManager.getInstance()