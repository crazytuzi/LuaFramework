-- FileName: PetController.lua
-- Author: shengyixian
-- Date: 2016-01-28
-- Purpose: 宠物控制层
module("PetController",package.seeall)

--[[
	@des 	:宠物吞噬
	@param 	:
	@return :
--]]
function swallowPet( pSwallowedPetId,pCallBack )
	-- body
	local petId = PetMainLayer.getCurPetId()
	local petInfo = PetData.getPetInfoById(tonumber(petId))
	local swallowedPetInfo = PetData.getPetInfoById(tonumber(pSwallowedPetId))
	local curPetTmpl, swallowNum= petInfo.pet_tmpl , petInfo.swallow 
	local petDbData = DB_Pet.getDataById(tonumber(curPetTmpl) )
	local canSwallowNum= PetUtil.getCanSwallowNum( curPetTmpl, petInfo.level )
	local expUpgradeID= petDbData.expUpgradeID
	-- 宠物吞噬已达上限判断
	if(canSwallowNum <= tonumber(petInfo.swallow) + tonumber( swallowedPetInfo.swallow)  ) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2289"))
		return
	end
	-- 宠物满级判断
	if(tonumber(petInfo.level )>= UserModel.getHeroLevel() and  tonumber(swallowedPetInfo.pet_tmpl)~= tonumber(petInfo.pet_tmpl)) then
		AnimationTip.showTip(GetLocalizeStringBy("key_3171"))
        return
	end
	local callBack = function ( pData )
			local orginPetExp = tonumber(petInfo.exp)
			local originLv = tonumber(petInfo.level )
			
			local swallowExp =tonumber(swallowedPetInfo.exp) 
			local swallowPoint =  pData.petinfo.skill_point - petInfo.skill_point --petDbData.swallow*( tonumber(swallowedPetInfo.swallow)+1)
			local allExp= tonumber(pData.petinfo.exp )--+ swallowExp --tonumber(swallowedPetInfo.exp)
			local curLv,curExp,needExp = LevelUpUtil.getObjectCurExp(expUpgradeID,allExp)

			local curLv= tonumber(pData.petinfo.level) 

			local levelPoint = PetUtil.getAddSkillPoint(originLv, curLv,curPetTmpl)
	

			if(originLv >=UserModel.getHeroLevel() ) then
				swallowExp= 0
			end

			if(swallowExp >0) then
				LevelUpUtil.showFloatText(GetLocalizeStringBy("key_2972") .. swallowExp ,g_sFontPangWa)
			end
			local addLv= curLv- originLv 
			if( addLv >0 ) then
				AnimationTip.showTip(GetLocalizeStringBy("key_2544").. curLv- originLv .. GetLocalizeStringBy("key_1584") ..  swallowPoint ..GetLocalizeStringBy("key_2429"))
			elseif( swallowPoint >0 ) then
				AnimationTip.showTip(GetLocalizeStringBy("key_1984") .. swallowPoint ..GetLocalizeStringBy("key_2429"))
			end	

			petInfo.level = curLv
			petInfo.exp= allExp
			petInfo.skill_point= pData.petinfo.skill_point --tonumber(swallowPoint)+petInfo.skill_point+ tonumber(levelPoint)
			petInfo.swallow= pData.petinfo.swallow  --tonumber(petInfo.swallow) + swallowedPetInfo.swallow+1
			PetData.removePetById(pSwallowedPetId)
			if (pCallBack) then
				pCallBack()
			end
		SelSwallowPetLayer.closeAction()
		if(curLv > originLv) then
			PetMainLayer.feedEffect(true)
		else
			PetMainLayer.feedEffect(false)
		end

		-- 判断是否有物品返还, add 20160330 lgx
	    local isItemReturn = false
	    for k,v in pairs(pData.item) do
	        if (tonumber(v) > 0) then
	            isItemReturn = true
	            break
	        end
	    end

	    if (isItemReturn) then
	        -- 有返还物品 弹出返还的物品信息板子
	        local rewardInfo = {}
	        -- 物品
	        for k,v in pairs(pData.item) do
	            local itemTab = {}
	            itemTab.type = "item"
	            itemTab.num  = tonumber(v)
	            itemTab.tid  = tonumber(k)
	            -- 加入奖励数组
	            if(table.isEmpty(itemTab) == false) then
	                table.insert(rewardInfo,itemTab)
	            end
	        end
	        require "script/ui/item/ReceiveReward"
	        ReceiveReward.showRewardWindow(rewardInfo, nil , 10000, -800, GetLocalizeStringBy("lgx_1014"))
	    end

	end
	PetService.swallowPet(petId, pSwallowedPetId, callBack )
end
--解析表中的 ， | 形式 变成二维数组
function analysisDbStr(p_info)
    if(p_info == nil)then
        return
    end
    local resultTab = {}
    local tabData = string.split(p_info,",")
  
    for k , v in pairs(tabData)do
        local tmpTab = string.split(v,"|")
        table.insert(resultTab,tmpTab)

    end
    return resultTab
    
end
--[[
	@des 	:宠物技能
	@param 	:
	@return :
--]]
function learnSkill( pPetIndex,pCallBack )
	-- body
    local feededPetInfo = PetData.getFeededPetInfo()
    local ColumLimit = feededPetInfo[pPetIndex].petDesc.ColumLimit or 0
    local levelLimit = feededPetInfo[pPetIndex].petDesc.levelLimit or 0
    local maxSkillNumber= tonumber(ColumLimit)*tonumber(levelLimit)

    -- local ColumLimit = feededPetInfo[pPetIndex].petDesc.ColumLimit or 0
    -- local levelLimit = feededPetInfo[pPetIndex].petDesc.levelLimit or 0
    -- local addlevel = 0
    -- local evolveLevel = tonumber(feededPetInfo[pPetIndex].va_pet.evolveLevel) or 0
    -- local evolveSkill = PetController.analysisDbStr(feededPetInfo[pPetIndex].petDesc.evolveSkill)

    -- if(not table.isEmpty(evolveSkill) and evolveLevel > 0)then
    --     for i =1,#evolveSkill do
    --         if(evolveLevel >= tonumber(evolveSkill[i][1]))then
    --             addlevel = addlevel + tonumber(evolveSkill[i][2])
    --         else
    --             break;
    --         end
    --     end
    -- end

    -- local maxSkillNumber= tonumber(ColumLimit)*(tonumber(levelLimit) + addlevel)

    local curSkillNumber= 0
    local skillNormal =  feededPetInfo[pPetIndex].va_pet.skillNormal 
    for i=1, table.count(skillNormal) do
        if(tonumber(skillNormal[i].id) ~= 0 ) then
            curSkillNumber = curSkillNumber+ skillNormal[i].level
        end
    end
    if(tonumber(curSkillNumber)>= maxSkillNumber ) then
        AnimationTip.showTip(GetLocalizeStringBy("key_1193"))
        return 
    end
    local petId= feededPetInfo[pPetIndex].petid
    local petInfo = PetData.getPetInfoById(tonumber(petId))
	if(tonumber(petInfo.skill_point)<1) then
		AnimationTip.showTip(GetLocalizeStringBy("key_2865"))
		return
	end
	local callBack = function ( pData )
		-- 领悟技能失败
		if(pData == "fail" ) then
			AnimationTip.showTip(GetLocalizeStringBy("key_2692"))
			PetData.addPetSKillPointById(petId, -1 )
			PetGraspLayer.update(false)
			return
		end
		-- 成功
		PetData.setPetInfoById(petId, pData )
		PetData.getPetAffixValue(true)
		PetGraspLayer.update(true)
		PetGraspLayer.updateResetBtn()
	end
    PetService.learnSkill(petId , callBack )
end
--[[
	@des 	:重置技能
	@param 	:
	@return :
--]]
function resetSkill( pPetIndex,pCallBack )
	-- body
	local feededPetInfo = PetData.getFeededPetInfo()
	local petInfo = feededPetInfo[pPetIndex]
	local goldCost = petInfo.petDesc.resetSkillGold
    if goldCost > UserModel.getGoldNumber() then
        -- AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
		LackGoldTip.showTip()
        return
    end
    local petId= petInfo.petid
    local callBack = function ( pData )
    	-- body
		UserModel.addGoldNumber(-goldCost)
		PetData.setPetInfoById(petId, pData )
		PetData.getPetAffixValue(true)
		if pCallBack then
			pCallBack()
		end
    end
    PetService.resetSkill(petId,callBack)
end
--[[
	@des 	:宠物进阶
	@param 	:
	@return :
--]]
function evolve( pPetId,pCallBack )
	-- body
	local petInfo = PetData.getPetInfoById(pPetId)
	-- 等级判断
	local curLv = tonumber(petInfo.va_pet.evolveLevel) or 0
	-- 进阶等级
	if curLv >= PetData.getMaxEvolveLevel(petInfo) then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1092",lvLimit))
		return
	end
	-- 宠物等级
	local lvLimit = PetData.getLevelLimitValue(pPetId,curLv + 1)
	if tonumber(petInfo.level) < lvLimit then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1091",lvLimit))
		return
	end
	if petInfo.va_pet.evolveLevel == nil then
		petInfo.va_pet.evolveLevel = 0
	end
	local dataStrAry = PetData.getAdvanceCostByLevel(tonumber(petInfo.petDesc.id),tonumber(petInfo.va_pet.evolveLevel) + 1)
    local data = ItemUtil.getItemsDataByStr(dataStrAry)
    local silverCost = 0
    for i,costItemData in ipairs(data) do
    	if costItemData.type == "silver" then
    		-- 判断银币
    		if (costItemData.num > UserModel.getSilverNumber()) then
    			AnimationTip.showTip(GetLocalizeStringBy("key_1114"))
    			return
    		end
    		silverCost = costItemData.num
    	elseif costItemData.type == "item" then
    		-- 进阶材料
			local itemNum = ItemUtil.getCacheItemNumBy(costItemData.tid)
    		if (costItemData.num > itemNum) then
    			AnimationTip.showTip(GetLocalizeStringBy("zzh_1226"))
    			return
    		end
    	end
    end
	local callBack = function ( pData )
    	-- body
    	PetData.addPetEvolveLv(pPetId)
    	UserModel.addSilverNumber(-silverCost)
 		PetData.getPetAffixValue(true)
		if pCallBack then
			pCallBack()
		end
    end
    -- callBack()
	PetService.evolve(pPetId,callBack)
end
--[[
	@des 	:宠物洗练
	@param 	:pPetInfo 宠物数据
	@param 	:pGrade   洗练档次(1,2,3)
	@param 	:pNum     洗练次数，默认1
	@return :
--]]
function wash( pPetInfo, pGrade, pNum,pCallBack,pIsForce )
	-- body
	pNum = pNum or 1
	pIsForce = pIsForce or 0
	-- 判断材料是否充足
	local itemNum = PetData.getItemIdByTrainGrade(pPetInfo,pGrade)
	local costUnit = PetData.getItemCostNumByPetNowAttNum(pPetInfo)
	local totalCost = costUnit * pNum
	-- 如果材料不足，则只洗练能洗练的次数
	if totalCost > itemNum then
		pNum = math.floor(itemNum / costUnit)
	end
	if pNum <= 0 then
		AnimationTip.showTip(GetLocalizeStringBy("syx_1095"))
		return
	end
	local callBack = function ( pData )
    	-- body
    	-- print("洗练成功")
    	-- print_t(pData)
 		pPetInfo.va_pet.toConfirm = pData
		if pCallBack then
			pCallBack(pData,pNum)
		end
		-- PetTrainLayer.updateCurAttrValueLabel()
    end
	PetService.wash(pPetInfo.petid,pGrade,pNum,callBack,pIsForce)
end
--[[
	@des 	:确认洗练属性
	@param 	:
	@return :
--]]
function ensure( pPetInfo,pCallBack )
	-- body
	local callBack = function ( pData )
    	-- body
 		PetData.addAttrValue(pPetInfo)
 		PetData.getPetAffixValue(true)
		if pCallBack then
			pCallBack()
		end
    end
	PetService.ensure(pPetInfo.petid,callBack)
end
--[[
	@des 	:取消洗练属性
	@param 	:
	@return :
--]]
function giveUp( pPetInfo,pCallBack )
	-- body
	local callBack = function ( pData )
    	-- body
		pPetInfo.va_pet.toConfirm = nil
		if pCallBack then
			pCallBack()
		end
    end
	PetService.giveUp(pPetInfo.petid,callBack)
end
--[[
	@des 	:宠物资质兑换
	@param 	:
	@return :
--]]
function exchange( pPetInfo,pSwapPetInfo,pCallBack )
	-- body
	if table.isEmpty(pSwapPetInfo) then
        AnimationTip.showTip(GetLocalizeStringBy("syx_1108"))
        return
	end
	-- 金币是否充足
    local goldCost = PetData.getSwapGoldCost()
    if goldCost > UserModel.getGoldNumber() then
        AnimationTip.showTip(GetLocalizeStringBy("key_1092"))
        return
    end
    -- 如果两个宠物均未培养或未进阶，就不能互换
    print("pPetInfo1111")
    print_t(pPetInfo)
    print_t(pSwapPetInfo)
    if ((pPetInfo.va_pet.evolveLevel == nil or tonumber(pPetInfo.va_pet.evolveLevel) == 0) and (pPetInfo.va_pet.confirmed == nil or table.isEmpty(pPetInfo.va_pet.confirmed))) and 
       ((pSwapPetInfo.va_pet.evolveLevel == nil or tonumber(pSwapPetInfo.va_pet.evolveLevel) == 0) and (pSwapPetInfo.va_pet.confirmed == nil or table.isEmpty(pSwapPetInfo.va_pet.confirmed))) then
        AnimationTip.showTip(GetLocalizeStringBy("syx_1114"))
        return
    end
    local callBack = function ( isConfirm )
        -- body
        if not isConfirm then
            return
        end
		local callBack = function ( pData )
	    	-- body
	    	UserModel.addGoldNumber(-goldCost)
	    	local resourceData,resourceDataTable = PetData.countTotalResource(pPetInfo,pSwapPetInfo)
	    	if resourceDataTable["silver"] then
	    		UserModel.addSilverNumber(resourceDataTable["silver"].num)
	    	end
	    	PetData.exchangePetInfo(pPetInfo,pSwapPetInfo)
	 		PetData.getPetAffixValue(true)
			if pCallBack then
				pCallBack()
			end
			PetAptitudeSwapLayer.updateAfterExchange()
	    	AnimationTip.showTip(GetLocalizeStringBy("syx_1109"))
	    	if not table.isEmpty(resourceData) then
		    	require "script/ui/pet/ShowResourceLayer"
		    	ShowResourceLayer.showLayer(resourceData)
	    	end
	    end
	    -- callBack()
		PetService.exchange(pPetInfo.petid,pSwapPetInfo.petid,callBack)
    end
    AlertTip.showAlert(GetLocalizeStringBy("syx_1110"),callBack,true)

end