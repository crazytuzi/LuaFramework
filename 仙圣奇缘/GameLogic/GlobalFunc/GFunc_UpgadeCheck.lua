--------------------------------------------------------------------------------------
-- 文件名:	g_UpgradeCheck.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------


------------------------------------功能开启---------------------------------------
function g_CheckFuncCanOpenByWidgetName(WidgetName)

	if WidgetName ~= "Button_DeBug" then
		local CSV_FunctionOpenLevel = getFunctionOpenLevelCsvByStr(WidgetName)
		
		if CSV_FunctionOpenLevel.OpenLevel == 0 then return true end
		
		if g_Hero:getMasterCardLevel() < CSV_FunctionOpenLevel.OpenLevel then
			if CSV_FunctionOpenLevel.OpenVipLevel <= 0 then
				return false
			else
				if g_VIPBase:getVIPLevelId() < CSV_FunctionOpenLevel.OpenVipLevel then
					return false
				else
					return true
				end
			end
		end
	else
		if CGamePlatform:SharedInstance():GetCurPlatform() ~= CGamePlatform:GetPlatformType_Debug() then
			return false
		end
	end
	return true
end

function g_CheckIsHaveOpenFunc(nOpenLevel)
	local CSV_FunctionOpenLevel = g_DataMgr:getFunctionOpenLevelCsv(nOpenLevel, 1)
	if CSV_FunctionOpenLevel.WidgetName ~= "" and CSV_FunctionOpenLevel.IsNeedOpenGuide == 1 then
		return true
	end
	return false
end

--------------------------------------阵法系统-----------------------------------------
function g_CheckZhenFaItem(nZhenFaCsvID)
	if not (g_Hero:getCurrentZhenFaCsvID() == nZhenFaCsvID) then return false end
	if not g_Hero:checkZhenFaRelease(nZhenFaCsvID) then return false end
	if not g_Hero:checkZhenFaCost(nZhenFaCsvID) then return false end
	if not g_Hero:checkZhenFaLevel(nZhenFaCsvID) then return false end
	return true
end

function g_CheckZhenFa()
	if not g_CheckFuncCanOpenByWidgetName("Button_ZhenFa") then return false end
	for nZhenFaCsvID = 1, g_Hero:getZhenFaListCount() do
		if g_Hero:getCurrentZhenFaCsvID() == nZhenFaCsvID then
			if g_CheckZhenFaItem(nZhenFaCsvID) then return true end
		end
    end
	return false
end

--------------------------------------心法系统-----------------------------------------
function g_CheckXinFalItem(nXinFaCsvID)
	if not g_Hero:checkXinFaRelease(nXinFaCsvID) then return false end
	if not g_Hero:checkXinFaCost(nXinFaCsvID) then return false end
	if not g_Hero:checkXinFaLevel(nXinFaCsvID) then return false end
	return true
end

function g_CheckXinFa()
	if not g_CheckFuncCanOpenByWidgetName("Button_XinFa") then return false end
    for nXinFaCsvID = 1, g_Hero:getXinFaListCount() do
	    if g_CheckXinFalItem(nXinFaCsvID) then return true end
    end
	return false
end

--------------------------------------阵心系统-----------------------------------------
function g_CheckZhenXinItem(nZhanShuCsvID, nZhenXinCsvID)
	if not g_Hero:checkZhanShuZhenXinCost(nZhanShuCsvID, nZhenXinCsvID) then return false end
	if not g_Hero:checkZhanShuZhenXinLevel(nZhanShuCsvID, nZhenXinCsvID) then return false end
	return true
end

function g_CheckZhenXin(nZhanShuCsvID)
	if g_Hero:getCurZhanShuCsvID() == nZhanShuCsvID then
		for nZhenXinCsvID = 1, 5 do	
			if g_CheckZhenXinItem(nZhanShuCsvID, nZhenXinCsvID) then return true end
		end
	end
    return false
end

--------------------------------------战术系统-----------------------------------------
function g_CheckZhanShulItem(nZhanShuCsvID)
	if not g_Hero:checkZhanShuRelease(nZhanShuCsvID) then return false end
	if not g_CheckZhenXin(nZhanShuCsvID) then return false end
	return true
end

function g_CheckZhanShu()
	if not g_CheckFuncCanOpenByWidgetName("Button_ZhanShu") then return false end
	
	for nZhanShuCsvID = 1, 6 do
		if g_Hero:getCurZhanShuCsvID() == nZhanShuCsvID then
			if g_CheckZhanShulItem(nZhanShuCsvID) then return true end
		end
	end
	return false
end

--------------------------------------奇术系统-----------------------------------------
function g_CheckQiShu()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_QiShu") then return false end
	
    if g_CheckZhenFa() then return true end
	if g_CheckXinFa() then return true end
	if g_CheckZhanShu() then return true end
    return false
end

--------------------------------------装备强化-----------------------------------------
function g_CheckEquipStrengthen(tbEquip)
	if not g_CheckFuncCanOpenByWidgetName("Button_Strengthen") then return false end
	
	-- local nStrengthenLev = tbEquip:getStrengthenLev()
	-- if tbEquip:checkIsStrengthenLevelFull() then return false end
	-- if tbEquip:getStrengthenCost() > g_Hero:getCoins() then return false end
	-- return true
	return false
end

--------------------------------------装备合成-----------------------------------------
function g_CheckRefineMaterialByCsv(EquipHeChengMaterial)
	if not EquipHeChengMaterial.GroupID == 0 then cclog("EquipHeChengMaterial.GroupID Is Zero") return false end
	--合成材料
	for nMaterialIndex = 1, 4 do
		local nCsvID = EquipHeChengMaterial["MaterialID"..nMaterialIndex]
		if nCsvID and nCsvID > 0 then
			local nStarLevel = EquipHeChengMaterial["MaterialStarLevel"..nMaterialIndex]
			local nNeedNum = EquipHeChengMaterial["MaterialNum"..nMaterialIndex]
			local nHaveNum = g_Hero:getItemNumByCsv(nCsvID, nStarLevel)
			cclog("================nNeedNum==============="..nNeedNum)
			cclog("================nHaveNum==============="..nHaveNum)
			if nNeedNum > nHaveNum then
				local CSV_ItemCompose = g_DataMgr:getCsvConfigByTwoKey("ItemCompose", nCsvID, nStarLevel)
				local nHaveFragNum = g_Hero:getItemNumByCsv(CSV_ItemCompose.MaterialID1, CSV_ItemCompose.MaterialStarLevel1)
				cclog("================nHaveFragNum==============="..nHaveFragNum)
				if nHaveFragNum * 3 < (nNeedNum - nHaveNum) then
					return false
				end
			end
		end
	end
	return true
end

-------------------------------装备升星-------------------
function g_CheckEquipRefineStarUp(tbEquip)
	if not g_CheckFuncCanOpenByWidgetName("Button_EquipStarUp") then return false end
	
	local nNextRefineLevel,CSVRefineLevelInfo = tbEquip:getNextRefineLevel()
	if tbEquip:getRefineLev() >= nNextRefineLevel then 
		return false 
	end
	
	local CSV_Equip = tbEquip:getCsvBase()
	if CSV_Equip.Type == Enum_EuipMainType.Weapon then
		if  CSVRefineLevelInfo.NeedMoney_Weapon > g_Hero:getCoins() then 
			return false
		end
		if CSVRefineLevelInfo.NeedDragonBall_Weapon > g_Hero:getDragonBall() then 
			return false
		end
	elseif CSV_Equip.Type == Enum_EuipMainType.Ring then
		if  CSVRefineLevelInfo.NeedMoney_Ring > g_Hero:getCoins() then 
			return false
		end
		if CSVRefineLevelInfo.NeedDragonBall_Ring > g_Hero:getDragonBall() then 
			return false
		end
	else
		if  CSVRefineLevelInfo.NeedMoney > g_Hero:getCoins() then 
			return false
		end
		if CSVRefineLevelInfo.NeedDragonBall > g_Hero:getDragonBall() then 
			return false
		end
	end
	
	return true
end


function g_CheckEquipRefine(tbEquip)
	if not g_CheckFuncCanOpenByWidgetName("Button_Refine") then return false end
	local CSV_Equip = tbEquip:getCsvBase()
	
	--配方材料
	local nRefineFormulaID = CSV_Equip.HeChengFormulaID
	local nRefineFormulaStar = CSV_Equip.HeChengFormulaStar
	local CSV_ItemBase = g_DataMgr:getCsvConfigByTwoKey("ItemBase", nRefineFormulaID, nRefineFormulaStar)
	local nHasNum = g_Hero:getItemNumByCsv(CSV_ItemBase.ID, CSV_ItemBase.StarLevel)
	if nHasNum == 0 then  return false  end
	--满级
	if tbEquip:checkMaxRefineAndMaxStar() then return false end
	
	--不符合穿戴等级
	local nStarLevelNext, CSV_EquipNext = tbEquip:getNextEquipStarLevel()
	if nStarLevelNext > 0 and g_Hero:getMasterCardLevel() < CSV_EquipNext.NeedLevel then return false end
	
	--当前等级的 材料数据
	local CSV_EquipHeChengMaterial = g_DataMgr:getEquipHeChengMaterialCsv(CSV_Equip.HeChengMaterialGroupID)
	--消耗不足
	if g_Hero:getCoins() < CSV_EquipHeChengMaterial.NeedMoney then return false end 
	
	--检查所有材料和碎片
	local nCount = 0
	for nMaterialIndex = 1, 4 do
		local nCsvID = CSV_EquipHeChengMaterial[tostring("MaterialID"..nMaterialIndex)]
		if nCsvID and nCsvID > 0 then
			local nStarLevel = CSV_EquipHeChengMaterial[tostring("MaterialStarLevel"..nMaterialIndex)]
			local nNeedNum = CSV_EquipHeChengMaterial[tostring("MaterialNum"..nMaterialIndex)]
			if nNeedNum > 0 then
				local nHasMaterialNum = g_Hero:getItemNumByCsv(nCsvID, nStarLevel)
				if nHasMaterialNum < nNeedNum then 
					local CSV_ItemCompose = g_DataMgr:getCsvConfigByTwoKey("ItemCompose", nCsvID, nStarLevel)
					if CSV_ItemCompose.MaterialID1 > 0 then
						local nHasFragNum = g_Hero:getItemNumByCsv(CSV_ItemCompose.MaterialID1, CSV_ItemCompose.MaterialStarLevel1)
						if nHasFragNum < (nNeedNum - nHasMaterialNum) * 3 then
							return false
						end
					end
				end
			end
		end
	end
	
	return true
end

--------------------------------------装备重铸-----------------------------------------
function g_CheckChongZhuMaterialByCsv(CSV_EquipWorkMaterialGroup)
	if CSV_EquipWorkMaterialGroup.GroupID == 0 then cclog("CSV_EquipWorkMaterialGroup.GroupID Is Zero") return end
	for nMaterialIndex = 1, 6 do
		local nCsvID = CSV_EquipWorkMaterialGroup[tostring("MaterialID"..nMaterialIndex)]
		local nStarLevel = CSV_EquipWorkMaterialGroup[tostring("MaterialStarLevel"..nMaterialIndex)]
		local nNeedNum = CSV_EquipWorkMaterialGroup[tostring("MaterialNum"..nMaterialIndex)]
		if not nCsvID or nCsvID <= 0 then return true end
		if not (g_Hero:getItemNumByCsv(nCsvID, nStarLevel) >= nNeedNum ) then return false end
	end
	return true
end

function g_CheckEquipChongZhu(tbEquip)
	-- if not g_CheckFuncCanOpenByWidgetName("Button_ChongZhu") then return false end
	
	-- local tbCsvBase = tbEquip:getCsvBase()
	-- local CSV_EquipWorkMaterialGroup = g_DataMgr:getEquipWorkMaterialGroupCsv(tbCsvBase.ChongZhuMaterialGroupID)
	-- if not CSV_EquipWorkMaterialGroup then return false end
	
	-- if tbCsvBase.ChongZhuBaseCost > g_Hero:getCoins() then return false end
	-- local bMaterialEnough = g_CheckChongZhuMaterialByCsv(CSV_EquipWorkMaterialGroup)
	-- if not bMaterialEnough then return false end
	return false
end

--------------------------------------装备合并-----------------------------------------
function g_CheckEquipUpgradeByType(tbEquip, nType)
    if nType == 1 then
    	if g_CheckEquipStrengthen(tbEquip) then return true end
    elseif nType == 2 then
		if g_CheckEquipRefine(tbEquip) then return true end
    elseif nType == 3 then
		--升星
		if g_CheckEquipRefineStarUp(tbEquip) then return true end 
	elseif nType == 4 then
		--重铸
	   if g_CheckEquipChongZhu(tbEquip) then return true end
    end

    return false
end

function g_CheckEquipUpgrade(tbEquip)
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_Equip") then return false end
    if not tbEquip then return false  end
    if g_CheckEquipStrengthen(tbEquip) then return true end
	if g_CheckEquipRefine(tbEquip) then return true end
	if g_CheckEquipChongZhu(tbEquip) then return true end
	--装备升星-------------------
	if g_CheckEquipRefineStarUp(tbEquip) then return true end 
    return false
end

--------------------------------------伙伴装备-----------------------------------------
function g_CheckCardEquip(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_Equip") then return false end
	if not tbCard:checkIsInBattle() then return false end
	for nEquipPos = 1, 6 do
		local tbEquip = tbCard:getEquipTbByPos(nEquipPos)
        if g_CheckEquipUpgrade(tbEquip) then return true end
    end
	return false
end

--------------------------------------伙伴渡劫-----------------------------------------
function g_CheckCardCanDuJie(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_JingJie") then return false end
	
	if tbCard:IsCardRealmLevMax() then return false end	--顶级
	if tbCard:IsNeedDujie() then --渡劫
		if tbCard:IsCardDuJieLevQualified() then
			return true
		end
    end
	echoj("=========伴渡劫-------========dssssssssssssssssssssssssss")
	return false
end

--------------------------------------提升境界-----------------------------------------
function g_CheckCardCanRealmUp(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_JingJie") then return false end
	
	if tbCard:IsCardRealmLevMax() then return false end	--顶级
	if not tbCard:IsNeedDujie() then --渡劫
        if g_Hero:getSoulListCount() < 1 then  return false end	--没有可以吞噬的材料
		if tbCard:getRealmFullNeedExp() <= 0 then return false end
	else
		return false
    end
	
	return true
end

--------------------------------------伙伴境界-----------------------------------------
function g_CheckCardRealmUp(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_JingJie") then return false, "FunctionLock" end
	
	if tbCard:IsCardRealmLevMax() then return false, "RealmIsMax" end	--顶级
	if tbCard:IsNeedDujie() then --渡劫
		if tbCard:IsCardDuJieLevQualified() then
			cclog("=============g_CheckCardRealmUpAAAAAAAAAAAAAA============")
			
			return true, "CanDuJie" --卡牌可以渡劫
		else
			return false, "CanNotDuJie"
		end
    else
        -- if g_Hero:getSoulListCount() <= 0 then  return false, "NotEnoughMaterial" end	--没有可以吞噬的材料
        if g_Hero:getDescendSoulListCount() <= 0 then  return false, "NotEnoughMaterial" end	--没有可以吞噬的材料
		if tbCard:getRealmFullNeedExp() <= 0 then return false, "RealmExpIsFull" end
    end
	
	return true, "CanConsume"
end

--------------------------------------伙伴丹药-----------------------------------------
function g_CheckCardDanYao(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_Evolute") then return false end
	local CSV_CardBase = tbCard:getCsvBase()
	local tbDanyaoLv = tbCard:getDanyaoLvList()
	local evoluteLevel = tbCard:getEvoluteLevel()
	--技能
	for i = 1,3 do
		local PowerfulSkillID = CSV_CardBase["PowerfulSkillID"..i]
		local tbSkillData = g_DataMgr:getSkillBaseCsv(PowerfulSkillID)
		 --技能id
		local skillID = tbSkillData.ID
		local skillLevel = tbCard:getSkillLevel(i) --技能等级
		local bLevel = tbCard:getEvoluteLevel()--突破等级
		local tbDanYao = tbDanyaoLv[i]
		local need,oneKeyUp = g_ComposeData:OneKeyUpgradeByHintShow(tbDanYao,skillLevel,skillID,bLevel)
		--可以一键升级 
		if oneKeyUp then 
			return true 
		end
		--单个技能中的某个丹药达到条件 
		for j = 1,3 do
			if g_ComposeData:danyaoAllActivate(skillLevel,evoluteLevel,tbDanYao,skillID)
            and g_ComposeData:composeMaterailContrast(skillID,j,tbDanYao[j]) then 
				return true 
			end
		end
		
		local maxDanyaoLevel = tbCard:getDanyaoMaxLevel()
		if skillLevel >= maxDanyaoLevel  then  
			return false  
		end
		
		if need > g_Hero:getCoins() then 
			return false  
		end
		
		if g_ComposeData:danyaoAllActivate(skillLevel,evoluteLevel,tbDanYao,skillID) then
			return true 
		end
	end

	return false
end

function g_CheckDanYaoUpgrade(tbDanYao,skillLevel,skillID,bLevel,maxDanyaoLevel)
	if not g_CheckFuncCanOpenByWidgetName("Button_Evolute") then return false end
	if skillLevel > bLevel then return false end --是否突破
	if skillLevel >= maxDanyaoLevel then return false end --是否到最大等级
	local need,onekeyUpgradeFlag = g_ComposeData:OneKeyUpgradeByHintShow(tbDanYao,skillLevel,skillID,bLevel)
	if onekeyUpgradeFlag then  return true end --是否可以一键升级丹药
	if need > g_Hero:getCoins() then  return false  end --消耗是否足够
	for i = 1,3 do
		local strStateFlag = g_ComposeData:composeCheckDanyaoItemState(tbDanYao[i],skillLevel)
		if strStateFlag == COMPOSE_STATE.NotActivate and
			g_ComposeData:composeMaterailContrast(skillID,i,tbDanYao[i]) then 
			return true
		end
	end
	return false
end

--------------------------------------伙伴技能-----------------------------------------
function g_CheckCardEvoluteBySkillIndex(tbCard, nIndex)
	if not g_CheckFuncCanOpenByWidgetName("Button_Evolute") then return false end
	if g_Hero:getMasterCardLevel() < 3 then return false end
	if tbCard:getSkillLevel(nIndex) > tbCard:getEvoluteLevel() then 
		return false 
	end
	return true
 end

--------------------------------------伙伴突破-----------------------------------------
function g_CheckCardEvolute(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_Evolute") then return false end
	if tbCard:getLevel() < tbCard:getCardEvolutePropCsv().NeedLevel then return false end
	if g_Hero:getMasterCardLevel() < 3 then return false end
	local nActiveCout = 0
	for i = 1, 3 do
		if not g_CheckCardEvoluteBySkillIndex(tbCard,i) then 
			nActiveCout = nActiveCout + 1
		end
	end
	return nActiveCout == 3 
end

--------------------------------------伙伴升星-----------------------------------------
function g_CheckCardStarUp(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_StarUp") then return false end
	if g_Hero:getMasterCardLevel() < 6 then return false end
	if tbCard:checkCanSarUp() then return true end
	return false
end

--------------------------------------伙伴合并-----------------------------------------
function g_CheckCardUpgrade(tbCard)
	if not tbCard:checkIsInBattle() then return false end
	if g_CheckCardEquip(tbCard) then return true end
	if g_CheckCardEvolute(tbCard) then return true end
	if g_CheckCardStarUp(tbCard) then return true end 
	if g_CheckCardDanYao(tbCard) then return true end
	if g_CheckCardRealmUp(tbCard) then return true end 
    return false
end

--------------------------------------异兽系统-----------------------------------------
function g_CheckCardFateUpgrade(tbCard)
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_YiShou") then return false end
	
	local nUnDressedFateCount = g_Hero:getFateUnDressedAmmount()
	if nUnDressedFateCount <= 0 then
		return false	--异兽背包为空
	end
	
    local tbCardList = g_Hero:GetCardsList()
    for key, tbCardInfo in pairs(tbCardList) do
        --已经镶嵌上的异兽
		local nReleaseCount = tbCardInfo:getFateReleasePosCount()
        for nPosIndex = 1, nReleaseCount do
	        local nNeedCardLev = g_DataMgr:getCardFateReleaseCsvLevel(nPosIndex)
            if tbCardInfo.nLevel >= nNeedCardLev then        	 
		        local nFateID = tbCardInfo:getFateIDByPos(nPosIndex)
		        if nFateID == 0 then
					for nFateType = 1, 16 do
						if not tbCardInfo:checkFateTypeIsInLay(nFateType) then
							if g_Hero:getFateUnDressedAmmountByType(nFateType) > 0 then
								return true
							end
						end
					end
		        end
            end
        end
    end
	
    return false
end

--------------------------------------仙脉系统-----------------------------------------
STATE_TYPE = {
	TYPE_ACTIVATE = 1,--表示可激活
	TYPE_BREAK = 2,--表示可突破
	TYPE_NOT = 3,--表示不可激活或突破
}
function g_CheckXianMaiItem(nIndex)
	if API_GetBitsByPos(g_XianMaiInfoData:getActiveInfo(), nIndex) == GAME_XIANMAI_NOT_ACTIVATE then --还没有激活
		local CSV_XianMai = g_DataMgr:getCsvConfigByOneKey("PlayerXianMai", g_XianMaiInfoData:getXianmaiLevel()) 
		if CSV_XianMai.NeedElementNum <= g_XianMaiInfoData:getTbElementList()[nIndex] then --某一个元素数量足够
			return STATE_TYPE.TYPE_ACTIVATE
		else
			return STATE_TYPE.TYPE_BREAK
		end
	end
	return STATE_TYPE.TYPE_NOT
end

function g_CheckXianMai()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_XianMai") then return 3 end
	local maxNum = 7
	local nActivateCount = 0
	for nIndex = 1,maxNum do
		local nCheckType = g_CheckXianMaiItem(nIndex)
		if nCheckType == STATE_TYPE.TYPE_ACTIVATE then
			return STATE_TYPE.TYPE_ACTIVATE	--表示可激活
		end
		if nCheckType == STATE_TYPE.TYPE_NOT then
			nActivateCount = nActivateCount + 1
		end
	end
	
	if nActivateCount == maxNum then
		return STATE_TYPE.TYPE_BREAK	--表示可突破
	end

	return STATE_TYPE.TYPE_NOT	--表示不可激活或突破
end

function g_CheckJueXing()
	if g_CheckXianMai() == STATE_TYPE.TYPE_ACTIVATE or g_CheckXianMai() == STATE_TYPE.TYPE_BREAK then
		return true
	end
	if g_Hero:getEssence() >= 10 then return true end
	return false
end
--------------------------------------上香系统-----------------------------------------
function g_CheckShangXiang()
	if not g_CheckFuncCanOpenByWidgetName("Button_Main_ShangXiang") then return false end
	
	g_Hero:SetCardFlagPV(1)
	
	local nNum = g_Hero:getCardsAmmount()

	for i = 1,nNum do
		local nCardID = g_Hero:GetCardIDByIndexPV(i)
		local tbCard = g_Hero:getCardObjByServID(nCardID)
		local nLevel = tbCard:getLevel()
		
		if tbCard:checkIsInBattle() then
			local cardIncense = g_DataMgr:getCsvConfigByOneKey("CardIncense",nLevel)
			local needMoney  = cardIncense.NeedMoney --铜钱
			local needIncense = cardIncense.NeedIncense --香供
			if g_Hero:getCoins() >= needMoney and g_Hero:getIncense() >= needIncense then 
				return true
			end
		end
	end
	
	return false
end

-------------------------------药园-----------------------------
function g_CheckFarmByIncenseNum()
	local nCount = 0
    local tbIncense = g_DataMgr:getCsvConfig("ActivityFarmIncense")
    for i = 1, 3 do
        local tbCurData = tbIncense[i]
        if i == 1 then
			if  g_Hero:getKnowledge() >= tbCurData.CostKnowledge then 
				nCount =  1
			end
        else
			if g_Hero:getCoins() >= tbCurData.CostCoupons then 
				nCount = 1
			end
        end      
		local nDailyType = macro_pb.Incense_Times 
		local bTimesFull = g_Hero:IsDailyNoticeFull(nDailyType)
		if bTimesFull then 
			nCount = 0
		end
    end 
	return nCount
end

-- FFS_PLANTED = 2;	// 已种植
-- FFS_COOLINGDOWN = 3;// 冷却中
-- FFS_OPENED = 4;		// 空闲
-- common_pb.FFS_LOCKED,		--锁住
-- common_pb.FFS_PLANTED,		--已种植
-- common_pb.FFS_COOLINGDOWN,	--冷却中
-- common_pb.FFS_OPENED,		--空闲
function g_CheckFarmByStatusNum()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_Farm") then return 0 end
	local nCount = 0
	local farmData = g_FarmData:getFarmRefresh()
	local data = farmData.fields
	for i = 1, #data do
		local status = data[i].status
		if status == common_pb.FFS_COOLINGDOWN then --空闲
			if data[i].deadline < g_GetServerTime() then
				g_FarmData:setFarmDataStatus(i,common_pb.FFS_OPENED,nil,nil,nil)
			end
		end
	end
			
	local farmData = g_FarmData:getFarmRefresh()
	local d = farmData.fields		
	for i = 1,#d do
		local status = d[i].status
		if status == common_pb.FFS_OPENED then --空闲
			nCount = nCount + 1
		end
	end
	local incenseNum = g_CheckFarmByIncenseNum()
	return nCount + incenseNum
end

function g_GetOpenFarmNum()
	local nCount = 0
	local farmData = g_FarmData:getFarmRefresh()
	if not farmData then
		return 0
	end
	local data = farmData.fields
	for i = 1,#data do
		local status = data[i].status
		if status == common_pb.FFS_OPENED then --空闲
			nCount = nCount + 1
		elseif status == common_pb.FFS_PLANTED then --种植
			nCount = nCount + 1
		elseif status == common_pb.FFS_COOLINGDOWN then --冷却
			nCount = nCount + 1
		end
	end
	return nCount
end

----------------召唤台---------------------------
function g_GetNoticeNum_ZhaoHuanTai()
	local nNoticeNum = 0
	for nIndex,v in pairs(g_Hero.tabSummonCardInfo) do
		local summonInfo = g_Hero.tabSummonCardInfo[nIndex]
		local free_times = summonInfo.free_times
		local ndif = summonInfo.cooldown - g_GetServerTime()	
		if ndif < 0  then
			nNoticeNum = nNoticeNum + free_times
		end
	end
	
	return nNoticeNum
end

----------------------以上是召唤台---------------

function g_CheckFuncCanOpenByTime(nActivityID)
	local CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityBase", nActivityID, 1)
	local nTime = g_GetServerTime()
	nTime = os.date("%w", nTime)
	if nTime == 0 then
		nTime = 7
	end
	
	local CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", nActivityID)
	local tbOpenDay = string.split(CSV_ActivityBase.OpenDay, "|")
	for i,v in ipairs(tbOpenDay)do
		if nTime == v then
			return true
		end
	end
	
	return false
end

function g_GetActivityNoticeNumByID(nActivityID)
	local CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("ActivityBase", nActivityID, 1)
	if g_Hero:getMasterCardLevel() < CSV_ActivityBase.OpenLevel then return 0 end
	
	local CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", nActivityID)
	local nMaxTimes = CSV_ActivityBase.MaxTimes
	local nUseTimes = g_Hero:getDailyNoticeByType(g_ActivityType[nActivityID]) or 0
	
	local nVIPAddMaxtimes = 0
	if nActivityID == 1 then 
		nVIPAddMaxtimes = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_ActivityExpTimes) --活动 卧龙潭 购买次数
	elseif nActivityID == 2 then 
		nVIPAddMaxtimes = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_ActivityMoneyTimes) -- 活动 财神岛 购买次数
	elseif nActivityID == 3 then 
		nVIPAddMaxtimes = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_ActivityKnowledgeTimes) -- 活动 藏经阁 购买次数
	end
	
	return (nMaxTimes + nVIPAddMaxtimes - nUseTimes)
end

function g_GetNoticeNum_FuLuDao() --福禄岛
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_FuLuShan") then return 0 end
	
	return g_GetActivityNoticeNumByID(g_ActivityCfgID.WoLongTan)
	+ g_GetActivityNoticeNumByID(g_ActivityCfgID.CaiShenDong)
	+ g_GetActivityNoticeNumByID(g_ActivityCfgID.CangJingGe)
end

-------------------------------神仙试炼(老世界Boss)-------------------------------
function g_checkTime(CSV_ActivityBase)
    local nCurTime = g_GetServerHour()*60 +g_GetServerMin()
	if not CSV_ActivityBase.StarTime then return true end
    local list = string.split(CSV_ActivityBase.StarTime, ":");
    local nBegin = tonumber(list[1])*60 + tonumber(list[2])
    list = string.split(CSV_ActivityBase.EndTime, ":");
    local nEnd = tonumber(list[1])*60 + tonumber(list[2])
    if nCurTime >= nBegin and nCurTime <= nEnd then 
        return true
    else
        return false
    end
end

-------------------------------神仙试炼(老世界Boss)-------------------------------
function g_GetNoticeNum_ShenXianShiLian()
	if not g_CheckFuncCanOpenByWidgetName("Button_ActivityShiLianShanPNL1") then return 0 end
	
	-- if g_Hero:getBubbleNotify(macro_pb.NT_WorldBoss) == 0 then
		-- return 0
	-- end

	local CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", 7)
	if not CSV_ActivityBase then return 0 end

	local types = VipType.VipBuyOpType_WorldBossTimes
	local addNum = g_VIPBase:getAddTableByNum(types)
	
	if g_checkTime(CSV_ActivityBase) then --
		local nUseNum = g_Hero:getDailyNoticeByType(macro_pb.Activity_AMBoss)
		return CSV_ActivityBase.MaxTimes + addNum - nUseNum
	else
		CSV_ActivityBase = g_DataMgr:getCsvConfig_FirstKeyData("ActivityBase", 8)
		if not CSV_ActivityBase then return false end
		if g_checkTime(CSV_ActivityBase) then
			local nUseNum = g_Hero:getDailyNoticeByType(macro_pb.Activity_PMBoss)
			return CSV_ActivityBase.MaxTimes + addNum - nUseNum
		end
	end	
	
	return 0
end

-------------------------------封印妖魔(新世界Boss)-------------------------------
function g_GetNoticeNum_FengYinYaoMo()
	if not g_CheckFuncCanOpenByWidgetName("Button_ActivityShiLianShanPNL2") then return 0 end
	return g_Hero:getBubbleNotify(macro_pb.NT_SceneBoss)
end

-------------------------------八仙过海祭拜-------------------------------
function g_GetNoticeNum_BaXianPray()
	if not g_CheckFuncCanOpenByWidgetName("Button_ActivityShiLianShanPNL3") then return 0 end
	local nLimit = g_Hero:getDailyNoticeLimitByType(macro_pb.BaXianIncenstTimes)
	local nTimes = g_Hero:getDailyNoticeByType(macro_pb.BaXianIncenstTimes)
	nTimes = nLimit - nTimes
    if nTimes < 0 then nTimes = 0 end
	return nTimes
end
-------------------------------八仙过海-------------------------------
function g_GetNoticeNum_BaXianGuoHai()
	if not g_CheckFuncCanOpenByWidgetName("Button_ActivityShiLianShanPNL3") then return 0 end
	--当前剩余可护送次数的数量+当前剩余可打劫次数的数量+当前可祭拜道祖的次数
    local  NtcCnt = g_BaXianGuoHaiSystem.EscortTimes
    NtcCnt = NtcCnt + g_BaXianGuoHaiSystem.RobTimes
   
    
    NtcCnt = NtcCnt + g_GetNoticeNum_BaXianPray()

    return NtcCnt
end

-------------------------------试炼山-------------------------------
function g_GetNoticeNum_ShiLianShan()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_ShiLianShan") then return 0 end

	return g_GetNoticeNum_ShenXianShiLian() + g_GetNoticeNum_FengYinYaoMo() + g_GetNoticeNum_BaXianGuoHai()
end

-------------------------------感悟神灵-------------------------------
function g_GetNoticeNum_GanWu()
	if not g_CheckFuncCanOpenByWidgetName("Button_ActivityJuXianGePNL1") then return 0 end
	local useCount = g_Hero:getDailyNoticeByType(macro_pb.DT_GanWu)	
	local num = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_GanWuCnt)
	return g_DataMgr:getGlobalCfgCsv("ganwu_number") + num - useCount
end

-------------------------------神龙上供-------------------------------
function g_GetNoticeNum_DragonPray()
	if not g_CheckFuncCanOpenByWidgetName("Button_ActivityJuXianGePNL2") then return 0 end
	local nTime, nMax = g_DragonPray:getPrayTime()
	return nMax - nTime
end

-------------------------------聚仙阁-------------------------------
function g_GetNoticeNum_JuXianGe()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_JuXianGe") then return 0 end
	
	return g_GetNoticeNum_GanWu() + g_GetNoticeNum_DragonPray()
end

-------------------------------声望商店-------------------------------
function g_GetNoticeNum_ShengWangShop()
	if not g_CheckFuncCanOpenByWidgetName("Button_JuBaoGePNL1") then return 0 end
	return 0
end

-------------------------------神秘商店-------------------------------
function g_GetNoticeNum_ShenMiShop()
	if not g_CheckFuncCanOpenByWidgetName("Button_JuBaoGePNL2") then return 0 end
	return g_Hero:getBubbleNotify(macro_pb.NT_SECRET_SHOP)
end

-------------------------------聚宝阁-------------------------------
function g_GetNoticeNum_JuBaoGe()
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_JuBaoGe") then return 0 end
	
	return g_GetNoticeNum_ShengWangShop() + g_GetNoticeNum_ShenMiShop()
end

function g_GetNoticeNum_HuntFate() --猎妖塔
	if not g_CheckFuncCanOpenByWidgetName("Button_Building_LianYaoTa") then return 0 end
	local nMaxTimes = g_Hero:getDailyNoticeLimitByType(macro_pb.HuntFateTimes)
	local nUseTimes = g_Hero:getDailyNoticeByType(macro_pb.HuntFateTimes)
	return nMaxTimes - nUseTimes
end

function g_GetNoticeNum_ZhaoCai() --招财
	if not g_CheckFuncCanOpenByWidgetName("Button_ZhaoCai") then return 0 end
	
	local nUseTimes = g_Hero:getDailyNoticeByType(macro_pb.Activity_ZhaoCai)
	local nMaxTimes = g_Hero:getVIPLevelMaxNumZhaoCai()
	return nMaxTimes - nUseTimes
end

function g_GetNoticeNum_Register() --签到
	if not g_CheckFuncCanOpenByWidgetName("Button_QianDao") then return 0 end
	
	if g_Hero:getSignDateStatus() <= 0 then
		return 0
	else
		return 1
	end
end

function g_GetNoticeNum_Assistant_Task()	--小助手日常
	local nNoticeNum = 0
	for k, v in pairs (g_Hero.tbAssistantInfo) do
		local CSV_ActivityAssistant = g_DataMgr:getCsvConfigByOneKey("ActivityAssistant", k)
		if g_Hero:getMasterCardLevel() >= CSV_ActivityAssistant.OpenLevel and v.bIsOpenToday and v.nProgress < 100 then
			nNoticeNum = nNoticeNum + 1
		end
	end
	cclog("===================g_GetNoticeNum_Assistant_Task====================="..nNoticeNum)
	return nNoticeNum
end

function g_GetNoticeNum_Assistant_Reward()	--小助手日常
	local nNoticeNum = 0
	for k, v in pairs (g_Hero.tbReward) do
		if k == common_pb.RewardType_AM_Energy or k == common_pb.RewardType_PM_Energy then --体力奖励
			local CSV_ActivityReward = g_DataMgr:getCsvConfigByTwoKey("ActivityReward", k, 1)
			local nStartMin = CSV_ActivityReward.StartHour*60 + CSV_ActivityReward.StartMin
			local nEndMin = CSV_ActivityReward.EndHour*60 + CSV_ActivityReward.EndMin
			local nMin = g_GetServerHour()*60 + g_GetServerMin()
			if nMin >= nStartMin and nMin <= nEndMin then
				nNoticeNum = nNoticeNum + 1
			end
		else
			nNoticeNum = nNoticeNum + 1
		end
	end
	cclog("===================g_GetNoticeNum_Assistant_Reward====================="..nNoticeNum)
	return nNoticeNum
end

function g_GetNoticeNum_Assistant_Achievement()	--小助手日常
	local nNoticeNum = g_AssistantData:getAchievementNotice()
	cclog("===================g_GetNoticeNum_Assistant_Reward====================="..nNoticeNum)
	return nNoticeNum
end

function g_GetNoticeNum_Assistant()	--助手
	if not g_CheckFuncCanOpenByWidgetName("Button_Assistant") then return 0 end
	return g_GetNoticeNum_Assistant_Task() + g_GetNoticeNum_Assistant_Reward() + g_GetNoticeNum_Assistant_Achievement()
end

function g_GetNoticeNum_FirstCharge() --首充
	if not g_CheckFuncCanOpenByWidgetName("Button_FirstCharge") then return 0 end
	local tbMissions = g_act:getMissionsByID(common_pb.AOLT_RECHARD_COUNT) or {ActState.INVALID}
	local nStatus = tbMissions[1]
	if ActState.INVALID == nStatus then --未充值
		return 0
	else
		return 1
	end
end

function g_GetNoticeNum_OnLineReward() --在线奖励
	if not g_CheckFuncCanOpenByWidgetName("Button_OnLineReward") then return 0 end
	return g_act:getBubbleByID(common_pb.AOLT_ONLINE)
end

function g_GetNoticeNum_JiaNianHua() --开服狂欢0
	if not g_CheckFuncCanOpenByWidgetName("Button_JiaNianHua") then return 0 end
	local nWholeRewardBubble = 0
	if g_SOTSystem:isWholeRewardEnabled() then
		nWholeRewardBubble = 1
	end
	return g_SOTSystem:getTotalBubbles() + nWholeRewardBubble
end

function g_CheckJiaNianHuaIsOver()
	--如果开服开服狂欢时间已截止，并且所有奖励都领完，并且最终魂魄奖励也领完，则返回false
	--其他返回true
	return g_SOTSystem:isEnable()
end

function g_GetNoticeNum_DeBug() --调试按钮
	if CGamePlatform:SharedInstance():GetCurPlatform() == CGamePlatform:GetPlatformType_Debug() then
		return 1
	else
		return 0
	end
end

function g_GetNoticeNum_ChatCenter() --聊天
	if not g_CheckFuncCanOpenByWidgetName("Button_Friend") then return 0 end
	return g_Hero:getBubbleNotify("ChatCenter") + g_TBSocial.NewChatNumber
end

function g_GetNoticeNum_Friend() --好友
	if not g_CheckFuncCanOpenByWidgetName("Button_Friend") then return 0 end
	
	return g_Hero:getBubbleNotify("social") + g_Hero:getBubbleNotify("heart")
end

function g_GetNoticeNum_Group()	--帮派
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	local allNum = g_GetNoticeNum_GroupRequest() + g_GetNoticeNum_GroupChat() + g_GetNoticeNum_GroupUpgrade() + g_GetNoticeNum_GroupBuilding()
		+ g_GetNoticeNum_Activity()
	return allNum
end

function g_GetNoticeNum_GroupChat()	--帮派聊天
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	return g_Hero:getBubbleNotify(macro_pb.NT_GuildChat)
end

function g_GetNoticeNum_GroupRequest()	--帮派申请
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	return g_Hero:getBubbleNotify(macro_pb.NT_Guild)
end

--帮派升级
function g_GetNoticeNum_GroupUpgrade()
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	
	local curLevel = g_Guild:getUserGuildLevel()
	local CSV_GuildLevel = g_DataMgr:getCsvConfigByOneKey("GuildLevel", curLevel)

	local Next_CSV_tbMsg = g_DataMgr:getCsvConfigByOneKey("GuildLevel", curLevel+1)
	if  Next_CSV_tbMsg.MemberLimit == 0 then
		--"已满级
		return 0
	end
	
	local curGroupCont = g_Guild:getGuildExp() --帮派经验 也是帮贡
	local costExp = CSV_GuildLevel.CostExp --需要的经验
	if curGroupCont > costExp then 
		return 1
	end
	return 0
end

--帮派建筑
function g_GetNoticeNum_GroupBuilding()	
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	return g_Hero:getBubbleNotify(macro_pb.NT_GuildBuilding)
end

--静心斋
function g_GetNoticeNum_GroupJinXinZhai()
	
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	
	local tbItemList = g_DataMgr:getCsvConfig("GuildBuilding")
	if g_Guild:getUserGuildLevel() < tbItemList[macro_pb.GuildBuildType_Jingxinzai]["NeedGuidLevel"] then 
		return 0
	end
	--已经领取
	if g_Guild:getBuildTimeatList(macro_pb.GuildBuildType_Jingxinzai) > 0 then 
		return 0
	end
	return 1
end
--万宝楼
function  g_GetNoticeNum_GroupWanBaoLou()
	
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	
	local tbItemList = g_DataMgr:getCsvConfig("GuildBuilding")
	if g_Guild:getUserGuildLevel() < tbItemList[macro_pb.GuildBuildType_Wanbaolou]["NeedGuidLevel"] then 
		return 0
	end
	
	local num = 0
	
	--还没有建造
	local bankLevel =  g_Guild:getBuildingLevel(macro_pb.GuildBuildType_Wanbaolou )
	
	if bankLevel < g_Guild:getUserGuildLevel()  and g_Guild:getBuildTimeatList(macro_pb.GuildBuildType_Wanbaolou) <= 0 then 
		num = num + 1
	end
	
	local bankDataReward = g_DataMgr:getCsvConfig("GuildBuildingBankReward")
	local itemData = bankDataReward[1]
	--建筑等级
	if bankLevel >= itemData.OpenLevel then
		--铜钱足
		if itemData.CostCoins <= g_Hero:getCoins() then
			--还没有认购
			local chooseType = g_Guild:getLastChooseType(1)
			if chooseType <= 0 then 
				num = num + 1
			end
		end
	end

	return num
end
--书画院 GuildBuildType_Shuhuayuan
function  g_GetNoticeNum_GroupShuHuaYuan()
	
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	local tbItemList = g_DataMgr:getCsvConfig("GuildBuilding")
	if g_Guild:getUserGuildLevel() < tbItemList[macro_pb.GuildBuildType_Shuhuayuan]["NeedGuidLevel"] then 
		return 0
	end

	local num = 0
	
	local schoolLevel = g_Guild:getBuildingLevel(macro_pb.GuildBuildType_Shuhuayuan)
	--还没有建造
	if schoolLevel < g_Guild:getUserGuildLevel()  and g_Guild:getBuildTimeatList(macro_pb.GuildBuildType_Shuhuayuan) <= 0 then 
		num = num + 1
	end
	
	local schoolDataReward = g_DataMgr:getCsvConfig("GuildBuildingSchoolReward")

	local itemData = schoolDataReward[1]
	--建筑等级
	if schoolLevel >= itemData.OpenLevel then
		--阅历足
		if itemData.CostKnowledege <= g_Hero:getKnowledge() then
			--还没有阅读
			local chooseType = g_Guild:getLastChooseType(2)
			if chooseType <= 0 then 
				num = num + 1
			end
		end
	end
	
	return num
end

--技能建筑  
	-- GuildBuildType_Lianshenta = 4;			// 炼神塔
	-- GuildBuildType_Jingangtang = 5;			// 金刚堂
	-- GuildBuildType_Shenbingdian = 6;		// 神兵殿
function g_GetNoticeNum_GroupSkillBuild(buildType)
	
	if not g_CheckFuncCanOpenByWidgetName("Button_Group") then return 0 end
	
	local tbItemList = g_DataMgr:getCsvConfig("GuildBuilding")
	if g_Guild:getUserGuildLevel() < tbItemList[buildType]["NeedGuidLevel"] then 
		return 0
	end
	
	local buildLeve = g_Guild:getBuildingLevel(buildType)
	local cvsSkillLevel = nil;
	local skillData = nil;
	local buildIndex = 1
	if buildType == macro_pb.GuildBuildType_Lianshenta then 
		--炼神塔
		cvsSkillLevel = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillHpLevel",buildLeve)
		skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillHp")
		
	elseif buildType == macro_pb.GuildBuildType_Jingangtang then 
		--金刚堂
		cvsSkillLevel = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillDefenceLevel",buildLeve)
		skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillDefence")
		buildIndex =  2
	elseif buildType == macro_pb.GuildBuildType_Shenbingdian then 
		-- 神兵殿
		cvsSkillLevel = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillAttackLevel",buildLeve)
		skillData = g_DataMgr:getCsvConfig("GuildBuildingSkillAttack")
		buildIndex = 3
	end

	if not cvsSkillLevel then return 0 end
	if not skillData then return 0 end
	
	local num = 0

	--还没有建造
	if cvsSkillLevel.BuildNeedKnowledge <= g_Hero:getKnowledge() 
		and buildLeve < g_Guild:getUserGuildLevel()  and  g_Guild:getBuildTimeatList(buildType) <= 0 then 
		num = num + 1
	end
	
	local maxLevel = #g_DataMgr:getCsvConfig("QiShuUpgradeCost")
		
	for nIndex = 1, #skillData do 
		local jnLevel = g_Guild:getBuildSkillLevel(buildIndex, nIndex)  --技能等级
		
		local costJnLevel = jnLevel + 1
		if costJnLevel > maxLevel then costJnLevel = maxLevel end
		local qiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost",costJnLevel)
		
		local costNeed =  math.floor( qiShuUpgradeCost.ZhenXinCost * skillData[nIndex].CostFactor / g_BasePercent )
		--技能等级是否达到最高等级了
		if jnLevel < cvsSkillLevel.MaxSkillLevel then 
			local openLevel = skillData[nIndex].OpenLevel
			--阅历足够
				--建筑等级
			if costNeed < g_Hero:getKnowledge() and buildLeve >=  openLevel then 
				num = num + 1
			end
		end
	
	end
	return num
end


function g_GetNoticeNum_Activity()
	return GroupActivityPNL:getBubble()
end


function g_GetNoticeNum_Mail() --邮件
	if not g_CheckFuncCanOpenByWidgetName("Button_Mail") then return 0 end
	
	return g_Hero:getBubbleNotify("mail")
end

function g_GetNoticeNum_Turntable() --爱心转盘
	if not g_CheckFuncCanOpenByWidgetName("Button_Turntable") then return 0 end
	
	--今天已经使用的次数
	local nUseTimes = g_Hero:getDailyNoticeByType(macro_pb.TurntableTimes)
	--每天的上限值
	local nMaxTimes = g_Hero:getDailyNoticeLimitByType(macro_pb.TurntableTimes)
	--vip配置表提升上限
	local nVIPAddMaxtimes = g_VIPBase:getAddTableByNum(VipType.VipBuyOpType_TurnTableTimes)	
	
	local showCount = 0
	local coldTiemat = g_TurnTableInfoData:getTurnShowColdTiemat()		
	if coldTiemat < g_GetServerTime() then 
		showCount = nMaxTimes + nVIPAddMaxtimes - nUseTimes
	end
	
	return showCount
end

function g_GetNoticeNum_ActivityCenter() --活动中心
	if not g_CheckFuncCanOpenByWidgetName("Button_HuoDong") then return 0 end
	return g_act:getBubbleTotal()
end
--跨服
function g_GetNoticeNum_ArenaKuaFu()
	if not g_CheckFuncCanOpenByWidgetName("Button_SubBuilding_TianBang1") then return 0 end
	--今天已经使用的次数
	local nUseTimes = g_Hero:getDailyNoticeByType(macro_pb.Cross_Arena_Challenge_Times)
	--每天的上限值
	local nMaxTimes = g_Hero:getDailyNoticeLimitByType(macro_pb.Cross_Arena_Challenge_Times)
	--vip配置表提升上限
	local num = g_ArenaKuaFuData:getWorldRankRewardRecvStatus() == true and 1 or 0
	
	return nMaxTimes + num - nUseTimes
end


function g_CheckNoticeNumByBtnName(strBtnName)
	if strBtnName == "Button_ChongZhi" then
		return true
	elseif strBtnName == "Button_Assistant" then
		return true
	elseif strBtnName == "Button_ZhaoCai" then
		return g_GetNoticeNum_ZhaoCai() > 0
	elseif strBtnName == "Button_HuoDong" then
		--return g_GetNoticeNum_ActivityCenter() > 0
		return true
	elseif strBtnName == "Button_QianDao" then
		return g_GetNoticeNum_Register() > 0
	elseif strBtnName == "Button_FirstCharge" then
		return g_GetNoticeNum_FirstCharge() > 0
	elseif strBtnName == "Button_OnLineReward" then
		return g_act:getMissionsByID(common_pb.AOLT_ONLINE)
	elseif strBtnName == "Button_JiaNianHua" then
		return g_CheckJiaNianHuaIsOver()
	elseif strBtnName == "Button_DeBug" then
		return g_GetNoticeNum_DeBug() > 0
	elseif strBtnName == "Button_Friend" then
		return true
	elseif strBtnName == "Button_Group" then
		return true
	elseif strBtnName == "Button_Mail" then
		return g_GetNoticeNum_Mail() > 0
	elseif strBtnName == "Button_Turntable" then
		--return g_GetNoticeNum_Turntable() > 0
		return true
	end
end




-- getDailyNoticeByType的类型
-- Buy_Enerngy_Times			= 0;		//购买体力次数
-- Gain_Enerngy_Times			= 1;		//领取体力奖励次数
-- Buy_Shop_Use_Prestige1		= 2;		//竞技场声望购买排名1
-- Buy_Shop_Use_Prestige2		= 3;		
-- Buy_Shop_Use_Prestige3		= 4;
-- Buy_Shop_Use_Prestige4		= 5;
-- Buy_Shop_Use_Prestige5		= 6;
-- Buy_Shop_Use_Prestige6		= 7;
-- Buy_Shop_Use_Prestige7		= 8;
-- Buy_Shop_Use_Prestige8		= 9;
-- Buy_Shop_Use_Prestige9		= 10;
-- Buy_Shop_Use_Prestige10		= 11;
-- Buy_Shop_Use_Prestige11		= 12;
-- Buy_Shop_Use_Prestige12		= 13;
-- Arena_Use_Challenge_Times	= 14;
-- Arena_Buy_Challenge_Times	= 15;
-- Arena_Gain_ReWard_Times		= 16;
-- Sign_Up_Times				= 17; //签到
-- Activity_Money				= 18; //搞钱活动
-- Activity_Exp				= 19; //搞经验活动
-- Activity_Tribute			= 20; //贡品
-- Activity_Aura				= 21; //灵气
-- Activity_Knowledge			= 22; //阅历
-- Activity_ZhaoCai			= 23; //招财神符
-- Activity_AMBoss				= 24; //上午世界boss挑战次数
-- Activity_PMBoss				= 25; //下午世界boss挑战次数
-- Incense_Times				= 26; //上香次数
-- TurntableTimes				= 27; //转盘次数
-- HuntFateTimes				= 28; //免费猎命次数
-- Gain_Daily_Bread			= 29; //每日俸禄
-- Gain_OrdinaryCard1			= 30; //元宝月卡1
-- Gain_OrdinaryCard2			= 31; //元宝月卡2
-- Gain_OrdinaryCard3			= 32; //元宝月卡3

--getTbNoticeByType
-- NoticeType_Friend			= 1; //好友
-- NoticeType_MailNotice		= 2; //邮件通知
-- NoticeType_TurnTable		= 3; //转盘
-- NoticeType_Card				= 4; //卡牌
-- NoticeType_Equip			= 5; //装备
-- NoticeType_Qishu			= 6; //奇术
-- NoticeType_SignUp			= 7; //签到
-- NoticeType_GainRewar      d		= 8; //领取礼包
-- NoticeType_ZhaoCaiShenFu	= 9; //招财
-- NoticeType_FarmNotCold		= 10; //菜园不在冷却中
-- NoticeType_FreeCall			= 11; //召唤台
-- NoticeType_ArenaTimes		= 12; //天榜
-- NoticeType_WorldBoss		= 13; //世界boss次数
-- NoticeType_FuLuShan			= 14; //福禄山次数
-- NoticeType_ShiLianDao		= 15; //试炼岛次数
-- NoticeType_FreeFate			= 16; //免费猎命次数
-- NoticeType_XianMai			= 17; //仙脉
-- NoticeType_Task				= 18; //任务
-- NoticeType_EquipFate		= 19; //有可装备异兽
-- NoticeType_BurnIncense		= 20; //上香
-- NoticeType_GuildLvup		= 21; //帮派升级
-- NoticeType_GuildHaveApply	= 22; //有人申请我的帮派



