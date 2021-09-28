--------------------------------------------------------------------------------------
-- 文件名:	Hero.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-16 15:24
-- 版  本:	1.0
-- 描  述:	玩家数据
-- 应  用:
---------------------------------------------------------------------------------------

--初始化角色伙伴列表
function Class_Hero:initCard(tbData)
	
	self.CardList = self.CardList or {}
    self.cardGroupList = self.cardGroupList or {}
    self.groupTable = self.groupTable or  {}
	--设置伙伴列表
	cclog("玩家伙伴列表")
	-- echoj("===========玩家伙伴列表==========", tbData.cardinfo)
	if(tbData ) then
		local tbCard = tbData.cardinfo
		for i = 1, #tbCard do
			local tb = tbCard[i]
			if(not tb)then
			--	cclog("==initCard break=="..szKey)
				break
			end
			local GameObj_Card = Class_Card.new()
			local ID = GameObj_Card:initCardData(tb)
			self.CardList[ID] = GameObj_Card
		end
	end

	-- cclog("====玩家伙伴列表===== end")

end
--增加卡牌
function Class_Hero:addCard(tbDropItem)
	local nCsvID = tbDropItem.drop_item_config_id
	local nStarLevel = tbDropItem.drop_item_star_lv
	local nLevel = tbDropItem.drop_item_lv
	local nCardID = tbDropItem.drop_item_id
	local nEvoluteLevel = tbDropItem.drop_item_blv

	local GameObj_Card = Class_Card.new()
	GameObj_Card:initCardDataDrop(nCardID, nCsvID, nStarLevel, nLevel, nEvoluteLevel)
	self.CardList[nCardID] = GameObj_Card
	self:initCardMaterialList()

     --伙伴组合属性添加
    self.CardList[nCardID]:absentCardGroupAddProps()
    self.CardList[nCardID]:reCalculateBattleProps()



	if tbDropItem.drop_item_config_id == 2012 or tbDropItem.drop_item_config_id == 2024 then
		cclog("=============获得卡牌有布阵信息==============")
		if g_Hero:getMasterCardLevel() == 1 then
			local tbServerMsg = {}
			tbServerMsg.change_op = zone_pb.ChangeArrayType_Add
			tbServerMsg.array_card_list = {}
			tbServerMsg.array_card_list[1] = {}
			tbServerMsg.array_card_list[1].cardid = nCardID
			tbServerMsg.array_card_list[1].posidx = tbDropItem.zhenxin_id
			tbServerMsg.array_card_list[1].index = tbDropItem.array_idx
			
			g_Hero:changeBuZhen(tbServerMsg)
		end
	end
end

function Class_Hero:delCard(nServerID)
	self.CardList[nCardID] = GameObj_Card
end

--按伙伴的星等级降序排序, 在等级相同时, 则按照伙伴的职业从小到大排序,职业相同的，则按照伙伴的等级从大到小排序
local function sortHasSummonUnBattleCard(GameObj_CardA, GameObj_CardB)
	local nStarLevelA = GameObj_CardA:getStarLevel()
	local nStarLevelB = GameObj_CardB:getStarLevel()
	if(nStarLevelA == nStarLevelB)then
		local nEvoluteLevelA = GameObj_CardA:getEvoluteLevel()
		local nEvoluteLevelB = GameObj_CardB:getEvoluteLevel()
		if nEvoluteLevelA == nEvoluteLevelB then
			local nLevelA = GameObj_CardA:getLevel()
			local nLevelB = GameObj_CardB:getLevel()
			if nLevelA == nLevelB then
				return GameObj_CardA:getCsvBase().ID > GameObj_CardB:getCsvBase().ID
			else
				return nLevelA > nLevelB
			end
		else
			return nEvoluteLevelA > nEvoluteLevelB
		end
	else
		return nStarLevelA > nStarLevelB
	end
end

--按伙伴的星等级降序排序, 在等级相同时, 则按照伙伴的职业从小到大排序,职业相同的，则按照伙伴的等级从大到小排序
local function sortHasSummonUnBattleCardGuide(GameObj_CardA, GameObj_CardB)
	local nStarLevelA = GameObj_CardA:getStarLevel()
	local nStarLevelB = GameObj_CardB:getStarLevel()
	if(nStarLevelA == nStarLevelB)then
		local nEvoluteLevelA = GameObj_CardA:getEvoluteLevel()
		local nEvoluteLevelB = GameObj_CardB:getEvoluteLevel()
		if nEvoluteLevelA == nEvoluteLevelB then
			local nLevelA = GameObj_CardA:getLevel()
			local nLevelB = GameObj_CardB:getLevel()
			if nLevelA == nLevelB then
				return GameObj_CardA:getCsvBase().ID < GameObj_CardB:getCsvBase().ID
			else
				return nLevelA > nLevelB
			end
		else
			return nEvoluteLevelA > nEvoluteLevelB
		end
	else
		return nStarLevelA < nStarLevelB
	end
end

--未召唤的根据魂魄的CardStarLevel从小到大排序，然后根据CardID从小到大排序
--总结：不能用<=，不然会报错。当<与==拆分的时候，==(如果是最后一个if语句)必须要返回false。
local function sortUnSummonCard(CSV_CardHunPoA, CSV_CardHunPoB)	
	local nNeedHunPoNumA = CSV_CardHunPoA.NeedNum
	local nNeedHunPoNumB = CSV_CardHunPoB.NeedNum
	  
	local GameObj_CardHunPoA = g_Hero:getHunPoObj(CSV_CardHunPoA.ID)
	local GameObj_CardHunPoB = g_Hero:getHunPoObj(CSV_CardHunPoB.ID)
	local nHaveHunPoNumA = 0
	local nHaveHunPoNumB = 0
	if GameObj_CardHunPoA then 
		nHaveHunPoNumA = GameObj_CardHunPoA:getNum()
	end
	if GameObj_CardHunPoB then 
		nHaveHunPoNumB = GameObj_CardHunPoB:getNum()
	end
	
	local nHaveMaterialNumA = g_Hero:getItemNumByCsv(CSV_CardHunPoA.ReplaceMaterialID, CSV_CardHunPoA.ReplaceMaterialLevel)
	local nReplaceMaxNumA = math.min(nHaveMaterialNumA, CSV_CardHunPoA.ReplaceMaterialMaxNum)
	local nCostHunPoNumA = math.min(nHaveHunPoNumA, CSV_CardHunPoA.NeedNum)
	local nCostMaterialNumA = math.min(CSV_CardHunPoA.NeedNum - nCostHunPoNumA, nReplaceMaxNumA)
	local nCollectPercentA = math.floor(((nCostHunPoNumA+nCostMaterialNumA)/nNeedHunPoNumA)*100)
	
	local nHaveMaterialNumB = g_Hero:getItemNumByCsv(CSV_CardHunPoB.ReplaceMaterialID, CSV_CardHunPoB.ReplaceMaterialLevel)
	local nReplaceMaxNumB = math.min(nHaveMaterialNumB, CSV_CardHunPoB.ReplaceMaterialMaxNum)
	local nCostHunPoNumB = math.min(nHaveHunPoNumB, CSV_CardHunPoB.NeedNum)
	local nCostMaterialNumB = math.min(CSV_CardHunPoB.NeedNum - nCostHunPoNumB, nReplaceMaxNumB)
	local nCollectPercentB = math.floor(((nCostHunPoNumB+nCostMaterialNumB)/nNeedHunPoNumB)*100)
	
	if nCollectPercentA > 0 then
		if nCollectPercentB > 0 then
			return nCollectPercentA > nCollectPercentB
		else
			return true
		end
	else
		if nCollectPercentB > 0 then
			return false
		else
			local nStarLevelA = CSV_CardHunPoA.CardStarLevel
			local nStarLevelB = CSV_CardHunPoB.CardStarLevel
			return nStarLevelA > nStarLevelB
		end
	end
end

function Class_Hero:initCardMaterialList()
	self.tbHasSummonBattleCardList = {}
	 for nIndex = 1, #self.tbCardBattleList do
		local nServerID = self.tbCardBattleList[nIndex].nServerID
		if nServerID > 0 then
			local GameObj_Card = self.CardList[nServerID]
			if GameObj_Card then
				table.insert(self.tbHasSummonBattleCardList, GameObj_Card)
				cclog("=============出战卡牌ID=============="..GameObj_Card:getServerId())
			end
		end
	end
	
	self.tbHasSummonUnBattleCardList = {}
    local tbHasSummonCardList = {}
	for key, value in pairs(self.CardList) do
		if(not value:checkIsInBattle()) then --未出阵
			table.insert(self.tbHasSummonUnBattleCardList, value)
			cclog("=============未出战卡牌ID=============="..value:getServerId())
		end
        tbHasSummonCardList[value:getCsvID()] = true
	end
	
	if g_PlayerGuide:checkIsInGuide() then
		table.sort(self.tbHasSummonUnBattleCardList, sortHasSummonUnBattleCardGuide)
	else
		table.sort(self.tbHasSummonUnBattleCardList, sortHasSummonUnBattleCard)
	end

    self.tbUnSummonCardList = {}
	local CSV_CardHunPo = g_DataMgr:getCsvConfig("CardHunPo")
    for key, value in pairs(CSV_CardHunPo) do
        if not tbHasSummonCardList[key] and key ~= 0 and value.CanNotSummon == 0 then
            table.insert(self.tbUnSummonCardList,  value)
        end
    end
	table.sort(self.tbUnSummonCardList, sortUnSummonCard)
end


--获取出战伙伴列表
function Class_Hero:getHasSummonBattleCardList()
	return self.tbHasSummonBattleCardList
end

function Class_Hero:getHasSummonBattleCardListCount()
	return #self.tbHasSummonBattleCardList
end

function Class_Hero:getHasSummonBattleCardByIndex(nIndex)
	return self.tbHasSummonBattleCardList[nIndex]
end

--未出阵伙伴列表
function Class_Hero:getHasSummonUnBattleCardList()
	return self.tbHasSummonUnBattleCardList
end

function Class_Hero:getHasSummonUnBattleCardListCount()
	return #self.tbHasSummonUnBattleCardList
end

function Class_Hero:getHasSummonUnBattleCardByIndex(nIndex)
	return self.tbHasSummonUnBattleCardList[nIndex]
end

--获取所有已召唤的伙伴列表
function Class_Hero:getHasSummonCardListCount()
	return #self.tbHasSummonBattleCardList + #self.tbHasSummonUnBattleCardList
end

function Class_Hero:getHasSummonCardByIndex(nIndex)
	if nIndex <= #self.tbHasSummonBattleCardList then
		return self.tbHasSummonBattleCardList[nIndex]
	else
		-- return self.tbHasSummonUnBattleCardList[#self.tbHasSummonBattleCardList + nIndex]
		local count = nIndex - #self.tbHasSummonBattleCardList
		return self.tbHasSummonUnBattleCardList[count]
	end
end


--获取未召唤伙伴列表
function Class_Hero:getSortUnSummonCard()
	table.sort(self.tbUnSummonCardList, sortUnSummonCard)
end

function Class_Hero:getUnSummonCardListCount()
	return #self.tbUnSummonCardList
end

function Class_Hero:getUnSummonCardByIndex(nIndex)
	return self.tbUnSummonCardList[nIndex]
end

function Class_Hero:getUnSummonCardList()
	return self.tbUnSummonCardList
end

--获取所有的伙伴个数
function Class_Hero:getCardsAmmount()
	return #self.tbHasSummonUnBattleCardList + self:getBattleCardListCount()
end

function Class_Hero:getCardObjByServID(nServerID)
	if( nServerID == nil) or ( nServerID == 0) then
		cclog("Class_Hero:getCardObjByServID nil")
		return nil
	end
	return self.CardList[nServerID]
end

function Class_Hero:getCardObjByCsvID(nCardCsvID)
	for k, v in pairs (self.CardList) do
		if v.tbCsvBase.ID == nCardCsvID then
			return v
		end
	end
	return nil
end

--返回所有的伙伴
function Class_Hero:GetCardsList()
	return self.CardList
end

function Class_Hero:SetCardFlagPV(nFlag)
	self.nCardFlag = nFlag
end

function Class_Hero:GetCardFlagPV()
	return self.nCardFlag
end

--pageview分页浏览数量
function Class_Hero:GetCardAmmountForPV()
	if self.nCardFlag == 1 then --所有的伙伴
		return self:getCardsAmmount()
	elseif self.nCardFlag == 2 then --战斗中的伙伴
		return self:getBattleCardListCount()
	elseif self.nCardFlag == 3 then --材料伙伴
		return self:getHasSummonUnBattleCardListCount()
	end
end

--通过ID获取伙伴索引，分成战斗和非战斗场景打开
function Class_Hero:GetCardIndexByIDPV(nCardID, nCardFlag)
	local nFlag = nCardFlag or self.nCardFlag
	if nFlag == 1 then --所有的伙伴
		for i=1, self:getCardsAmmount() do
			local tbCardInfo = self:getCardsInfoByIndex(i)
			if tbCardInfo.nServerID == nCardID then
				return i
			end
		end
	elseif nFlag == 2 then --战斗中的伙伴
		for i=1, #self.tbCardBattleList do
            local value = self.tbCardBattleList[i]
			if value.nServerID == nCardID then
				return i
			end
		end
	elseif nFlag == 3 then --材料伙伴
		for i=1, #self.tbHasSummonUnBattleCardList do
			if self.tbHasSummonUnBattleCardList[i].nServerID == nCardID then
				return i
			end
		end
	end
end

function Class_Hero:GetCardIDByIndexPV(nIndex)
	if self.nCardFlag == 1 then
		local tbCardInfo = self:getCardsInfoByIndex(nIndex)
		return tbCardInfo.nServerID
	elseif self.nCardFlag == 2 then
		local nBattleIndex = 0
		for i=1,  #self.tbCardBattleList do
            local value = self.tbCardBattleList[i]
			if(value.nServerID > 0)then
				nBattleIndex = nBattleIndex + 1
				if nBattleIndex == nIndex then
					return value
				end
			end
		end
	elseif self.nCardFlag == 3 then
		return self.tbHasSummonUnBattleCardList[nIndex].nServerID
	end
end

function Class_Hero:getCardsInfoByIndex(nIndex)
	if(nIndex == nil)then
		cclog("Class_Hero:GetCardsInfo nil")
		return nil
	end

	local nCurIndex  = 0
    for i=1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[i]
		if(value.nServerID > 0)then
			nCurIndex = nCurIndex + 1
			if(nCurIndex == nIndex)then
				return self.CardList[value.nServerID]
			end
		end
	end

	local nMaterial = #self.tbHasSummonUnBattleCardList
	if(nIndex <= nCurIndex + nMaterial)then
		nIndex = nIndex - nCurIndex
		return self:getHasSummonUnBattleCardByIndex(nIndex)
	end

	return nil
end

-----------------获取布阵列表
--获取布阵列表成员
function Class_Hero:getBattleCardByIndex(nIndex)
	if g_BattleTeachSystem:IsTeaching()then
		return nil
	end

	if not self.tbCardBattleList then return nil end
    local value = self.tbCardBattleList[nIndex]
    if value and value.nServerID > 0 then
		return self.CardList[value.nServerID]
    end

    return nil
end

function Class_Hero:getBattleCardIDByIndex(nIndex)
    return self.tbCardBattleList[nIndex].nServerID
end

-----------------获取布阵列表
--获取布阵列表成员
function Class_Hero:getBuZhenPosByCardID(nCardID)
    for k, v in pairs (self.tbCardBattleList) do
		if v.nServerID > 0 and v.nServerID == nCardID then
			return v.nPosIdx
		end
	end

	return 0
end

function Class_Hero:getBattleCardList()
	return self.tbCardBattleList
end

function Class_Hero:getBattleCardListCount()
	local nCount = 0
	for i = 1, #self.tbCardBattleList do
        local value = self.tbCardBattleList[i]
		if value.nServerID > 0 then
            nCount = nCount +1
        end
	end
	return nCount
end

function Class_Hero:getBuZhenPosByIndex(nIndex)
    local value = self.tbCardBattleList[nIndex]
    if not value then return 0 end
    if value.nPosIdx > 5 then
        return value.nPosIdx - 6 + 10
    end

	local tbLeaderZhenFa = g_Hero:getCurrentZhenFaCsvByIndex(value.nPosIdx)
    if not tbLeaderZhenFa then return 0 end
    return tbLeaderZhenFa.BuZhenPosIndex
end

--卡牌组合是否激活
--function Class_Hero:checkCardGroupActivate(nGroupID)
--	local CSV_CardGroup = g_DataMgr:getCardGroupCsv(nGroupID)

--	for i = 1,5 do
--		local nCardCsvId = CSV_CardGroup["CardID"..i]
--		if nCardCsvId > 0 then
--			if not self:checkCardIsInBattleByCsvID(nCardCsvId) then
--				--出战卡牌数
--				return false
--			end
--		end
--	end

--	return true
--end

--获取布阵列表成员
function Class_Hero:getBattleCardByBuZhenPos(nPos)
	local nIndex = self:getCurZhenFaIndex(nPos)
	if (not nIndex) then return nil end
	local cardBattle = self:getBattleCardList()
    for i = 1, #cardBattle do
        local value = cardBattle[i]
        if value.nPosIdx == nIndex and value.nServerID > 0 then
	        return self:getCardObjByServID(value.nServerID)
        end
    end
end


--其他玩家 卡牌上阵信息
function Class_Hero:getRestCardBatte()
	return self.restCardBatte or {}
end

function Class_Hero:setRestCardBattedata(data)
	self.restCardBatte  = data
end


function Class_Hero:setRestCardBatte(nIndex,posIdx,nServerID)
	if not self.restCardBatte then self.restCardBatte ={} end 
	self.restCardBatte[nIndex] = {nPosIdx = posIdx, nServerID = nServerID}
end

-----------------------

--头像选择更换或者邀请伙伴
function Class_Hero:changeBuZhen(tbMsg)
	if(not tbMsg)then
		cclog("changeBuZhen nil")
		return
	else
		local tbArrayCard = tbMsg.array_card_list
		
		if(tbArrayCard)then
			for i=1, #tbArrayCard do
				local tbCardList = tbArrayCard[i]
				
				local nCardID = tbCardList.cardid
				local nPos = tbCardList.posidx
		    	local nIndex = tbCardList.index + 1
                if tbMsg.change_op == zone_pb.ChangeArrayType_Del then          --伙伴下阵
					local nOldCardID = self.tbCardBattleList[nIndex].nServerID
					local GameObj_CardOld = self.CardList[nOldCardID]
					if GameObj_CardOld then
						GameObj_CardOld:setBattleIndex(0)
					end
					
                    for i = nIndex, 5 do
                        self.tbCardBattleList[i] = self.tbCardBattleList[i+1]
						local nNewCardID = self.tbCardBattleList[i].nServerID
						local GameObj_CardNew = self.CardList[nNewCardID]
						if GameObj_CardNew then
							GameObj_CardNew:setBattleIndex(nIndex)
						end
                    end
                    self.tbCardBattleList[6] = {nPosIdx = nPos, nServerID = 0}

                    GameObj_CardOld:initCardPropAll()

                elseif tbMsg.change_op == zone_pb.ChangeArrayType_Add or tbMsg.change_op == zone_pb.ChangeArrayType_Inquire then --增加伙伴、更换伙伴
					
					local nOldCardID = self.tbCardBattleList[nIndex].nServerID
					local GameObj_CardOld = self.CardList[nOldCardID]
					if GameObj_CardOld then
						GameObj_CardOld:setBattleIndex(0)
					end
				    self.tbCardBattleList[nIndex] = {nPosIdx = nPos, nServerID = nCardID} --
					local nNewCardID = self.tbCardBattleList[nIndex].nServerID
					local GameObj_CardNew = self.CardList[nNewCardID]
					if GameObj_CardNew then
						GameObj_CardNew:setBattleIndex(nIndex)
					end
                else --只是移动伙伴
				    self.tbCardBattleList[nIndex] = {nPosIdx = nPos, nServerID = nCardID} --
                end
			end
		end
	end

	self:initCardMaterialList()

    --更改布阵后重新刷新附加的属性
	self:refreshTeamMemberAddProps(true)

end

-------------出售伙伴成功
function Class_Hero:decomposeCardSucc(nServerID)
	--删除卖掉的伙伴
	local GameObj_Card = self.CardList[nServerID]
	if GameObj_Card then
		local bSortEquip = nil
		local tbEquipIdList = GameObj_Card:getEquipIdList()
		if not self.tbUndressEquipList then
			self.tbUndressEquipList = {}
		end
		for i = 1, #tbEquipIdList do
			local GameObj_Equip = self:getEquipObjByServID(tbEquipIdList[i])
			if GameObj_Equip then
				bSortEquip = true
				GameObj_Equip:setOwnerID(nil)
				table.insert(self.tbUndressEquipList, GameObj_Equip)
			end
		end
		
		if bSortEquip then
			table.sort(self.tbUndressEquipList, unEquipSort)
		end
		
		local bSortFate = nil
		local tbFateIdList = GameObj_Card:getFateIdList()
		if not self.tbFateUnDressed then
			self.tbFateUnDressed = {}
		end
		for j = 1, #tbFateIdList do
			local GameObj_Fate = self:getFateInfoByID(tbFateIdList[j])
			if(GameObj_Fate)then
				bSortFate = true
				GameObj_Fate:setOwnerID(nil)
				local nFateType = GameObj_Fate:getCardFateCsv().Type
				self.tbCountUnDressedInType[nFateType] = self.tbCountUnDressedInType[nFateType] + 1
				table.insert(self.tbFateUnDressed, tbFateIdList[j])
			end
		end

		if bSortFate then
			table.sort(self.tbFateUnDressed, sortFate)
		end
		bSortFate = nil
	end

--    g_Hero.cardGroupList[self.CardList[nServerID].tbCsvBase.ID] = nil
    -- 伙伴消失后 刷新伙伴缘分
    self.CardList[nServerID]:decomposeCardGroup()

	self.CardList[nServerID] = nil
	self:initCardMaterialList()

    -- 伙伴消失后 刷新伙伴缘分
--    self:cardGroupAddProps()
   

end

--伙伴召唤 第一次请求刷新
function Class_Hero:onSummonCardRefresh(tbMsg)
	if not tbMsg then
		cclog("Class_Hero onSummonCardRefresh nil")
		return
	end

	self.tabSummonCardInfo = {}
	for key,v in ipairs(tbMsg.summon_card_cool_info) do
		local curcooldown = v.cooldown + g_GetServerTime()	
		self.tabSummonCardInfo[v.type] = {
			type = v.type,
			free_times = v.free_times,
			cooldown = curcooldown,
			cdown = v.cooldown,
			times = v.times
		}
	end
end

--伙伴召唤 购买请求
function Class_Hero:onSummonCard(tbMsg,tb)
	self.tabSummonCardInfo[tbMsg.type].free_times = tbMsg.cool_info.free_times
	self.tabSummonCardInfo[tbMsg.type].cooldown = tbMsg.cool_info.cooldown + g_GetServerTime()	
	self.tabSummonCardInfo[tbMsg.type].cdown = tbMsg.cool_info.cooldown 
	self.tabSummonCardInfo[tbMsg.type].times = tbMsg.cool_info.times 
	--剩余多少铜钱
	self:setCoins(tbMsg.updated_money)
	--剩余多少元宝
	self:setYuanBao(tbMsg.updated_coupons)
end

function Class_Hero:checkCardIsInBattleByCsvID(nCardCsvID)
    for i=1, #self.tbCardBattleList do
        local tbPosInfo = self.tbCardBattleList[i]
		local GameObj_Card = self:getCardObjByServID(tbPosInfo.nServerID)
		if GameObj_Card then
			if GameObj_Card.tbCsvBase.ID == nCardCsvID then
				return true
			end
		end
    end
    return false
end