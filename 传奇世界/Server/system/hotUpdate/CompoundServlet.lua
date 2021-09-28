--CompoundServlet.lua
--合成


CompoundServlet = class(EventSetDoer, Singleton)

function CompoundServlet:__init()
	self._compoundConfig = {}
	self._doer = {
			--[ITEM_CS_COMPOUND] 			= CompoundServlet.doCompound,
			--[ITEM_CS_COMPOUND_EQUIP] 	= CompoundServlet.doCompoundEquip,
			}
end

--发送提示消息
function CompoundServlet:fireMessage(mesID, roleID, eventID, eCode, paramCnt, params)
	fireProtoSysMessage(mesID, roleID, eventID, eCode, paramCnt, params)
end

function CompoundServlet:doCompound(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("ItemCompoundProtocol" , pbc_string)
	if not req then
		print('CompoundServlet:doCompound '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local roleID = player:getID()
	local type = req.compoundAll
	local slot = req.slot1
	local slot2 = req.slot2	

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local item = itemMgr:findItem(slot)
	if not item then						--指定的物品
		self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, Item_OP_Result_ItemNotExist, 0)
		return
	end

	local sourceItemID = item:getProtoID()
	local config = self._compoundConfig[sourceItemID]
	if not config then						--合成配置不存在
		self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, Item_OP_Result_CannotCompound, 0)
		return
	end

	local sourceCnt = 0
	local sourceCnt1 = item:getCount()
	sourceCnt = sourceCnt1

	--只要原材料中有绑定的  合成之后的道具就是绑定的  20150824
	local isBind = false
	local isBind1 = item:isBinded()
	local isBind2 = false
	local item2 = itemMgr:findItem(slot2)
	if item2 then			--两个格子一起合成	20150824
		isBind2 = item2:isBinded()
		local sourceCnt2 = item2:getCount()
		sourceCnt = sourceCnt1 + sourceCnt2
	end
	isBind = isBind1 or isBind2

	if sourceCnt<0 then
		return
	end

	if not isMatEnough(player, sourceItemID, config.q_needCnt) then
	--if sourceCnt < config.q_needCnt then	--物品数量低于合成的数量
		self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, Item_OP_Result_EquipMaterialNotEnough, 0)
		return
	end

	local proCnt = 1
	local needMoney = config.q_needmoney
	if type then 										--全部合成
		proCnt = math.floor(sourceCnt/config.q_needCnt)
		needMoney = config.q_needmoney * proCnt
	end

	if proCnt<0 or needMoney<0 then
		return
	end

	--if player:getMoney()<needMoney then					--20151012	合成只消耗金币
	if not isMoneyEnough(player,needMoney) then
		self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, Item_OP_Result_MoneyNotEnough, 0)	
		return
	end

	local emptySlot = itemMgr:findFreeSlot()		
	if emptySlot < 1 then								--背包空闲格子不够
		self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, Item_OP_Result_NoFreeSlot, 0)
		return
	end

	local flag=0
	local errcode=0
	if config.q_needCnt * proCnt <= sourceCnt then
		if config.q_needCnt * proCnt <= sourceCnt1 then
			flag, errcode = itemMgr:removeBagItem(slot, config.q_needCnt * proCnt, errcode)
			if not flag then									--去掉原物品个数 失败
				self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, errcode, 0)
				return
			end

		else
			flag, errcode = itemMgr:removeBagItem(slot, sourceCnt1, errcode)
			if not flag then									--去掉原物品个数 失败
				self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, errcode, 0)
				return
			end

			flag, errcode = itemMgr:removeBagItem(slot2, config.q_needCnt * proCnt-sourceCnt1, errcode)
			if not flag then									--去掉原物品个数 失败
				self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, errcode, 0)

				--还原刚才扣除的  slot 的物品个数
				flag, errcode = itemMgr:addItemBySlot(1, slot, sourceItemID, sourceCnt1, isBind1, errcode)
				return
			end

		end

		--消耗道具日志	20150907
		local optItemCountTmp = config.q_needCnt * proCnt 			--本次操作item数量
	end
	
	local tSchool = player:getSchool()		--职业 1战士 2法师 3道士
	local roleSex = player:getSex()			--1表示男  2表示女
	if config.sffj and config.sffj>0 then	--极品属性
		local fjjlTemp = config.fjjl		--'500,450,50'										
		local fjjlList = {}

		while (true) do
			local pos = string.find(fjjlTemp, ',')
			if (not pos) then
				fjjlList[#fjjlList + 1] = fjjlTemp
				break;
			end

			local sub_str = string.sub(fjjlTemp, 1, pos - 1);
			fjjlList[#fjjlList + 1] = sub_str;
			fjjlTemp = string.sub(fjjlTemp, pos + 1, #fjjlTemp)											
		end
		
		if not fjjlList[1] then
			fjjlList[1] = '500'
		end

		if not fjjlList[2] then
			fjjlList[2] = '450'
		end

		if not fjjlList[3] then
			fjjlList[3] = '50'
		end

		local fjjlTemp2 = tonumber(fjjlList[1])+tonumber(fjjlList[2])+tonumber(fjjlList[3])										
		local randValue = math.random(1, fjjlTemp2)
		local randAttribute = 0
		if randValue>tonumber(fjjlList[1])+tonumber(fjjlList[2]) then
			randAttribute = 3
		elseif randValue>tonumber(fjjlList[1]) then
			randAttribute = 2
		else
			randAttribute = 1
		end
		--addItem(short bagIndex, int itemID, int count, bool bBinded, int &errorCode, int strength = 0, int timeLimit = 0);
		flag, errcode = itemMgr:addItem(1,config.q_produceid[tSchool+(roleSex-1)*3], config.q_produceCnt * proCnt, isBind, errorCode, 0, 0);
	else
		flag, errcode = itemMgr:addBagItem(config.q_produceid[tSchool+(roleSex-1)*3], config.q_produceCnt * proCnt, isBind, errcode)
	end

	--产出物品日志	20150907
	local newItemID = config.q_produceid[tSchool+(roleSex-1)*3]
	local newItemNum = config.q_produceCnt * proCnt 		--本次获得个数

	if not flag then
		self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, errcode, 0)
	else
		--local ret = costMoney(player, needMoney)
		
		costMoney(player,needMoney,35)
		--player:setMoney(player:getMoney()-needMoney)	--20151012 合成只消耗金币
		--g_logManager:writeMoneyChange(player:getSerialID(),"",1,35,player:getMoney(),needMoney,2)

		logtb = {}
		logtb.mtype = type
		logtb.delmat ={{id=sourceItemID, cnt=config.q_needCnt * proCnt, isBind = isBind}}
		logtb.addmat ={{id=config.q_produceid[tSchool+(roleSex-1)*3], cnt=config.q_produceCnt *proCnt, isBind = isBind}}
		--[[
		if ret == 1 then
			logtb.bind = {changed=-needMoney, remained=player:getBindMoney()}	
		else
			logtb.money = {changed=-needMoney, remained=player:getMoney()}
		end
		]]
--		g_entityDao:writeRecord(player:getSerialID(), "item_compound", serialize(logtb))

		local retData = {}
		retData.result = 1		
		fireProtoMessage(roleID,ITEM_SC_COMPOUNDRET,"ItemCompoundRetProtocol",retData)
	end
end

function CompoundServlet:doCompoundEquip(buffer1)
	local params = buffer1:getParams()
	local pbc_string = params[1]
	local roleSID = params[2]

	local req, err = protobuf.decode("EquipCompoundProtocol" , pbc_string)
	if not req then
		print('CompoundServlet:doCompoundEquip '..tostring(err))
		return
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if not player then return end
	local roleID = player:getID()
	local itemID = req.itemID

	local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	if itemID>0 then
		local itemLevel = 0
		--local ItemTmp = itemMgr:findItemByItemID(itemID) 		--背包没有是读不出来的
		--if ItemTmp then
			--itemLevel = ItemTmp:getLevel()			
		--end

		local compandTable = {}
		if g_XunBaoMgr._ItemCompandAndSmelter then
			if g_XunBaoMgr._ItemCompandAndSmelter.compand then
				compandTable = g_XunBaoMgr._ItemCompandAndSmelter.compand
			end
		end

		if g_XunBaoMgr._ItemLevel then
			if g_XunBaoMgr._ItemLevel[itemID] then
				itemLevel = g_XunBaoMgr._ItemLevel[itemID]				
			end
		end

		if itemLevel>0 then
			local needItemID = 0
			local needItemNum = 0
			local needItemID2 = 0
			local needItemNum2 = 0
			local compandNeed = 0
			local compandNeedMoney = 0

			if compandTable[itemLevel] then
				for i,v in pairs(compandTable[itemLevel]) do
					if v.itemID == itemID then
						if v.needID>0 and v.needNum>0 then
							needItemID = v.needID
							needItemNum = v.needNum
						end

						if v.needID2>0 and v.needNum2>0 then
							needItemID2 = v.needID2
							needItemNum2 = v.needNum2
						end
						break
					end
				end
			end

			if needItemID2>0 and needItemNum2>0 then
				if 999998==needItemID2 then
					local curMoney = player:getMoney()
					if not isMoneyEnough(player,needItemNum2) then
					--if curMoney<needItemNum2 then
						self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, -39, 0)						
						local retData = {}
						retData.result = 0
						fireProtoMessage(roleID,ITEM_SC_COMPOUNDRET,"ItemCompoundRetProtocol",retData)

						return
					else
						compandNeedMoney = needItemNum2
						compandNeed = compandNeed + 1
					end
				end
			end

			if needItemID>0 and needItemNum>0 then
				local count = itemMgr:getItemCount(needItemID)
				local Binded = 0
				local ItemTmp = itemMgr:findItemByItemID(needItemID)
				if ItemTmp then
					Binded = ItemTmp:isBinded() and 1 or 0
				end
				
				if not isMatEnough(player, needItemID, needItemNum) then
				--if count<needItemNum then
					self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, Item_OP_Result_EquipMaterialNotEnough, 0)

					local retData = {}
					retData.result = 0
					fireProtoMessage(roleID,ITEM_SC_COMPOUNDRET,"ItemCompoundRetProtocol",retData)
					return
				end

				local errId = 0
				itemMgr:destoryItem(needItemID, needItemNum, errId)

				if 1219==needItemID then
					--g_logManager:writePropChange(player:getSerialID(),2,81,needItemID,0,needItemNum,Binded)
					g_RedBagMgr:makeEquipment(roleSID, needItemNum)
				elseif 1220==needItemID then
					--g_logManager:writePropChange(player:getSerialID(),2,82,needItemID,0,needItemNum,Binded)
				else
				end
				compandNeed = compandNeed + 1
			end

			if compandNeedMoney>0 then
				costMoney(player,compandNeedMoney,106)
				--player:setMoney(player:getMoney()-compandNeedMoney)
				--g_logManager:writeMoneyChange(player:getSerialID(),"",1,106,player:getMoney(),compandNeedMoney,2)
			end

			if compandNeed>0 then
				local emptySize = itemMgr:getEmptySize(Item_BagIndex_Bag)
				local freeSlotNum = itemMgr:getEmptySize()
				if freeSlotNum < 1 then
					--提示背包满
					local offlineMgr = g_entityMgr:getOfflineMgr()
					local email = offlineMgr:createEamil()
					local emailConfigId = 53
					email:setDescId(emailConfigId)
					email:insertProto(itemID, 1, false)
					offlineMgr:recvEamil(player:getSerialID(), email, 106, 0)
				else
					itemMgr:addItem(Item_BagIndex_Bag,itemID,1, 0, 0, 0, 0, 0)
				end

				self:fireMessage(ITEM_CS_COMPOUND, roleID, EVENT_ITEM_SETS, 21, 0)
			
				local retData = {}
				retData.result = 1
				fireProtoMessage(roleID,ITEM_SC_COMPOUNDRET,"ItemCompoundRetProtocol",retData)
				return
			end
		end
	end
end

function CompoundServlet:parseCompound()
	package.loaded["data.CompoundDB"] = nil
	local tmpData = require "data.CompoundDB"
	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			data.q_produceid = unserialize('{'..data.q_produceid..'}')	--将字符串转换成表

			if self._compoundConfig[data.q_sourceid] then
				table.deepCopy1(data, self._compoundConfig[data.q_sourceid])
			else
				self._compoundConfig[data.q_sourceid] = data
			end
		end
	end
end

function CompoundServlet.getInstance()
	return CompoundServlet()
end

CompoundServlet.getInstance():parseCompound()

g_eventMgr:addEventListener(CompoundServlet.getInstance())
