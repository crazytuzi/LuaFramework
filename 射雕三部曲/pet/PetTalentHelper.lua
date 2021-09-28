--[[
	文件名：PetTalentHelper.lua
	描述：存放外功秘籍参悟公用函数
	创建人：peiyaoqiang
	创建时间：2017.03.21
--]]

PetTalentHelper = {}

-- 根据外功秘籍信息及参悟ID获取参悟描述
--[[
	params:
	petInfo 			-- 外功秘籍实例信息
	talentId 			-- 参悟ID
	isNextLevelDesc 	-- 是否返回下一级参悟的描述，true:返回下一级的描述，false or nil:返回当前等级的描述，仅在当前参悟被激活且不为特技的条件下有效
	petModelId 			-- 外功秘籍模型Id，仅当petInfo为空时生效，返回参悟初始描述
--]]
function PetTalentHelper.getPetTalentIntroduce(petInfo, talentId, isNextLevelDesc, petModelId)
	local talItem = PetTalTreeModel.items[talentId]
	local descStr = nil

	-- 只传了参悟ID没有传外功秘籍信息，默认返回原始描述
	if not petInfo and petModelId then
		descStr = talItem.intro
		if descStr == "" then
			-- 特技只有1级，不可升级
			local buffItem = PetExtraBuffRelation.items[petModelId]
			descStr = buffItem[talentId].intro
		end

		return descStr
	end

	-- 该参悟是否已被激活
	local haveActived, talInfo = false, nil
	for k, v in pairs(petInfo.TalentInfoList or {}) do
		if v.TalentID == talentId then
			haveActived = true
			talInfo = v
			break
		end
	end

	-- 宠物特技，intro字段为空，需读取PetExtraBuffRelation.lua表
	if talItem.intro ~= "" then
		descStr = talItem.intro
		if haveActived then
			-- "人物伤害+600"/"人物PVP伤害+3%"二种情况
			if string.find(descStr, "%%") then
				local tempStr1 = string.splitBySep(descStr, "+")
				local tempStr2 = string.splitBySep(tempStr1[2], "%%")
				local currNum = 0
				if isNextLevelDesc then
					if talInfo.TalentNum < talItem.totalNum then
						currNum = tonumber(tempStr2[1]) * (talInfo.TalentNum + 1)
						descStr = string.format("%s+%s%%", tempStr1[1], tostring(currNum))
					else
						descStr = nil
					end
				else
					currNum = tonumber(tempStr2[1]) * talInfo.TalentNum
					descStr = string.format("%s+%s%%", tempStr1[1], tostring(currNum))
				end
			else
				local tempStr = string.splitBySep(descStr, "+")
				local currNum = 0
				if isNextLevelDesc then
					if talInfo.TalentNum < talItem.totalNum then
						currNum = tonumber(tempStr[2]) * (talInfo.TalentNum + 1)
						descStr = string.format("%s+%s", tempStr[1], tostring(currNum))						
					else
						descStr = nil
					end
				else
					currNum = tonumber(tempStr[2]) * talInfo.TalentNum
					descStr = string.format("%s+%s", tempStr[1], tostring(currNum))						
				end
			end
		end	
	else
		-- 特技只有1级，不可升级
		local buffItem = PetExtraBuffRelation.items[petInfo.ModelId]
		descStr = buffItem[talentId].intro
	end

	return descStr
end

-- 读取外功参悟的消耗
--[[
	如果返回nil，说明传入的招式不能学习
--]]
function PetTalentHelper.getTalentCostlist(petInfo, talItem, talInfo)
	if (petInfo == nil) or (talItem == nil) then
		return nil
	end

	local costList = {mustCost = {}, petCost = {}, subCost = {}}
	local petModel = PetModel.items[petInfo.ModelId] or {}

	-- 判断是否可以学习
	local curIndex = 0
	if (talItem.layer - petInfo.Layer) > 1 then
		-- 当前层的下一层的以下，需要先学习上一层
		return nil
	elseif (talItem.layer - petInfo.Layer) == 1 then
		-- 当前层的下一层，此时 talInfo 必然为空
		curIndex = 0
	else
		-- 当前层
		-- 该层已经学习了其他招式
		if not talInfo then
			return nil
		end

		-- 该层招式已学习到最高
		if talInfo.TalentNum >= talItem.totalNum then
			return nil
		end

		curIndex = talInfo.TalentNum
	end

	-- 读取固定的消耗
	local tempList = Utility.analysisStrResList(talItem.perUseStr)
    for _, v in ipairs(tempList) do
        if v.num > 0 then
            table.insert(costList.mustCost, v)
        end
    end

    -- 读取同名外功的消耗
    local tempList = string.split(talItem.perExp, "|")
    local needNum = tonumber((tempList[curIndex + 1] or "0"))
    if (needNum > 0) then
    	table.insert(costList.petCost, {modelId = petInfo.ModelId, num = needNum, resourceTypeSub = math.floor(petInfo.ModelId/10000)})
    end

    -- 读取替代品的消耗
    if (petModel.ifSub == true) and (needNum > 0) then
    	local petConfig = PetConfig.items[1]
    	table.insert(costList.subCost, {modelId = petConfig.alteGoodsId, num = (needNum * petConfig.consumMultiple), resourceTypeSub = math.floor(petConfig.alteGoodsId/10000)})
    end

    return costList
end

-- 判断外功参悟的消耗品是否足够
--[[
	如果传了 selectItem 参数，则判断它是否足够；否则的话，只要同名外功或替代道具任意一种足够即可
--]]
function PetTalentHelper.isResourceEnough(petInfo, talItem, talInfo, selectItem)
	local resList = {}
	local costList = PetTalentHelper.getTalentCostlist(petInfo, talItem, talInfo)
	if (costList == nil) then
		return false
	end

	-- 判断必选消耗
	for _, v in ipairs(costList.mustCost) do
        local haveNum = Utility.getOwnedGoodsCount(v.resourceTypeSub, v.modelId)
        if haveNum < v.num then
            table.insert(resList, clone(v))
        end
    end

    -- 判断同名外功或替代道具是否足够
    local function isPetOrSubEnough(item)
    	if Utility.isPet(item.resourceTypeSub) then
    		local list = PetObj:findByModelId(item.modelId, {
	            excludeIdList = {petInfo.Id}, 	-- 过滤掉自己，在参悟未上阵的外功时要用到
	            notInFormation = true, 
	            Lv = 1,
	        })
	        return (#list >= item.num)
    	else
    		-- 替代道具不是必须的
    		return ((item.modelId ~= nil) and (Utility.getOwnedGoodsCount(item.resourceTypeSub, item.modelId) >= item.num))
    	end
    end
    if (selectItem ~= nil) and (selectItem.modelId ~= nil) then
    	-- 如果玩家自己选择了材料，则只判断它是否足够
    	if not isPetOrSubEnough(selectItem) then
    		table.insert(resList, clone(selectItem))
    	end
    else
    	-- 如果玩家没有选择，则同名外功或替代道具任意一种足够即可（两者都不一定是必须的）
    	local petCostItem = costList.petCost[1] or {}
		local subCostItem = costList.subCost[1] or {}
		if (petCostItem.modelId ~= nil) then
			-- 需要同名外功，判断是否足够
	        if not isPetOrSubEnough(petCostItem) then
	        	-- 同名外功不足，则判断替代品
	        	if (subCostItem.modelId == nil) or (not isPetOrSubEnough(subCostItem)) then
	        		-- 不能用替代品，或者替代品不足，则必须使用同名外功
	        		table.insert(resList, clone(petCostItem))
	        	end
	        else
	        	-- 如果同名外功足够就直接忽略
	        end
	    else
	    	-- 如果不需要同名外功，则也不需要替代品
		end
    end

    return (#resList == 0), resList
end

-- 读取遗忘招式需要的消耗
function PetTalentHelper.getResetCost(petInfo)
	-- 是否有参悟招式
	local currNum = petInfo.TotalNum - petInfo.CanUseTalNum
    if (currNum == 0) then
        return nil
    end

    -- 重置消耗，需读取外功秘籍重生表
    local petModel = PetModel.items[petInfo.ModelId]
    local petRebirthList = PetRebirthRelation.items[petModel.quality]

    -- 构建新表，便于访问
    local tempList = {}
    for _, v in pairs(petRebirthList) do
        table.insert(tempList, v)
    end
    table.sort(tempList, function(a, b)
        return a.talTreeNum < b.talTreeNum
    end)

    -- 重置所需元宝数目
    local needNum = nil
    for _, v in ipairs(tempList) do
        if currNum >= v.talTreeNum then
            needNum = v.useDiamond
        end
    end
    if not needNum then
        needNum = 0
    end

    return {resourceTypeSub = ResourcetypeSub.eDiamond, num = needNum}
end
