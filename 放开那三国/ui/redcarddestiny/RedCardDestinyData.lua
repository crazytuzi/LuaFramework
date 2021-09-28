-- FileName: RedCardDestinyData.lua 
-- Author: llp
-- Date: 16-05-30
-- Purpose: function description of module 

module("RedCardDestinyData", package.seeall)
require "db/DB_Heroes"
require "db/DB_Hero_destiny"
finalFightData = {}
function getInfoByTypeAndPage(p_page)
    local pageArray = DB_Hero_destiny.getArrDataByField("tier",tonumber(p_page))
    if(table.isEmpty(pageArray))then
        return
    end

    for k,v in pairs (pageArray) do
        if(tonumber(v.tier) == tonumber(p_page))then
            return v
        end
    end
end

function getToSpecialDestinyCount( pCurDestinyIndex )
	local index = 1
	local haveNextSpecial = false
	for i=pCurDestinyIndex+1,table.count(DB_Hero_destiny.Hero_destiny)do
		local data = DB_Hero_destiny.getDataById(i)
		if(tonumber(data.special)==2)then
			haveNextSpecial = true
			return index
		else
			index = index + 1
		end
	end
	if(haveNextSpecial==false)then
		return -1
	end
end

function getSpecialName( pCurDestinyIndex,pHeroInfo )
	local haveNextSpecial = false
	
	for i=pCurDestinyIndex+1,table.count(DB_Hero_destiny.Hero_destiny)do
		local data = DB_Hero_destiny.getDataById(i)
		if(tonumber(data.special)==2)then
			haveNextSpecial = true
			local dbData = nil
			if(pHeroInfo.localInfo~=nil)then
				dbData = string.split(pHeroInfo.localInfo.destinyName,",")
			else
				dbData = string.split(DB_Heroes.getDataById(heroData.htid).destinyName,",")
			end
			
			for j=1,table.count(dbData)do
				local dbData1 = string.split(dbData[j],"|")
				if(tonumber(dbData1[1])>tonumber(pCurDestinyIndex))then
					return dbData1[2]
				end
			end
			return i
		end
	end
	if(haveNextSpecial==false)then
		return -1
	end
end

function getCurSpecialName( pCurDestinyIndex,pHeroInfo )
	local haveNextSpecial = false
	local dbInfo = DB_Heroes.getDataById(pHeroInfo.htid)
	local dbData = string.split(dbInfo.destinyName,",")
	for j=1,table.count(dbData)do
		local dbData1 = string.split(dbData[j],"|")
		if(tonumber(dbData1[1])==tonumber(pCurDestinyIndex))then
			haveNextSpecial = true
			return dbData1[2]
		end
	end
	if(haveNextSpecial==false)then
		return ""
	end
end

function getCurSpecialAwake( pCurDestinyIndex,pHeroInfo )
	local haveNextSpecial = false
	local dbData = string.split(pHeroInfo.localInfo.destinyAwake,",")
	for j=1,table.count(dbData)do
		local dbData1 = string.split(dbData[j],"|")
		if(tonumber(dbData1[1])==(tonumber(pCurDestinyIndex)))then
			haveNextSpecial = true
			local awakeData = DB_Awake_ability.getDataById(dbData1[2])
			return awakeData
		end
	end
	if(haveNextSpecial==false)then
		return -1
	end
end

function getCostData( pCurDestinyIndex,pHeroInfo,pAddOne )
	local costData = nil
	if(pCurDestinyIndex==table.count(DB_Hero_destiny.Hero_destiny))then
		return {}
	end
	if(pAddOne)then
		costData = DB_Hero_destiny.getDataById(pCurDestinyIndex+1).lightCost
	else
		costData = DB_Hero_destiny.getDataById(pCurDestinyIndex).lightCost
	end
	local extraCostStr = pHeroInfo.localInfo.destinyCost
	local extraCostArray = string.split(extraCostStr,",")
	local extraCostCache = ""
	for i=1,table.count(extraCostArray)do
		local extraCostArray1 = string.split(extraCostArray[i],"|")
		if(tonumber(pCurDestinyIndex+1)==tonumber(extraCostArray1[1]))then
			extraCostCache = extraCostArray1[2].."|"..extraCostArray1[3].."|"..extraCostArray1[4]
		end
	end
	if(string.len(extraCostCache)>0)then
		return costData..","..extraCostCache
	else
		return costData
	end
end

function getHeroRealName( pHid,pHeroInfo )
	local heroData = nil
	if(pHeroInfo~=nil)then
		heroData = pHeroInfo
	else
		heroData = HeroUtil.getHeroInfoByHid(pHid)
	end
	local nameStr = ""
	if(heroData.localInfo~=nil)then
		nameStr = heroData.localInfo.name
	else
		nameStr = DB_Heroes.getDataById(heroData.htid).name
	end
	local specialName = getCurSpecialName(heroData.destiny,heroData)
	if(specialName~=-1 and string.len(specialName)>1)then
		nameStr = specialName
	end
	return nameStr
end

function getAllReward( p_heroInfo )
	local rewardTable = {}
    for i=1,tonumber(p_heroInfo.destiny) do
        table.insert(rewardTable,RedCardDestinyData.getCostData(i,p_heroInfo))
    end
    local finalRewardData = {}
    for k,v in pairs(rewardTable) do
        local data = string.split(v,",")
            for k,v in pairs(data) do
            	if table.isEmpty(finalRewardData) then
            		for k,v in pairs(data) do
            			table.insert(finalRewardData,v)
            		end
            		break
            	else
            		local haveSameValue = false
	                for fKey,fValue in pairs(finalRewardData) do
	                    local fData = string.split(fValue,"|")
	                    local data1 = string.split(v,"|")
	                    if(tonumber(fData[2])==tonumber(data1[2]))then
	                    	haveSameValue = true
	                        finalRewardData[fKey] = fData[1].."|"..(fData[2]).."|"..(fData[3]+data1[3])
	                    end
	                end
	                if(haveSameValue==false)then
	                	table.insert(finalRewardData,v)
	                end
	            end
            end
    end
    return finalRewardData
end

function getCurAtt( tag )
    -- body
    local dbInfo = DB_Hero_destiny.getDataById(tag)
    local flyArray = {}
    if(dbInfo==nil)then
    	return flyArray
    end
    local attStr = dbInfo.attArr
    local attArray = string.split(attStr,",")
    for i,v in pairs(attArray) do
        local temArr = {}
        local data = string.split(v,"|")
        local attName,disNum,realNum = ItemUtil.getAtrrNameAndNum(data[1],data[2])
        temArr.txt = data[1]
        temArr.num = data[2]
        table.insert(flyArray,temArr)
    end
    return flyArray
end

function getTotalAtt( p_heroInfo )
    local rewardTable = {}
    for i=1,tonumber(p_heroInfo.destiny) do
        table.insert(rewardTable,getCurAtt(i)[1])
    end
    local finalRewardData = {}
    for k,v in pairs(rewardTable) do
        if(table.isEmpty(finalRewardData))then
            table.insert(finalRewardData,v)
        else
            local isHave = false
            -- if(tonumber(v.txt)==51 or tonumber(v.txt)==54 or tonumber(v.txt)==55 or tonumber(v.txt)==100)then
                for fKey,fValue in pairs(finalRewardData) do
                    if(tonumber(fValue.txt)==tonumber(v.txt))then
                        isHave = true
                        finalRewardData[fKey].num = tonumber(fValue.num) + tonumber(v.num)
                        break
                    end
                end
                if(isHave==false)then
                    table.insert(finalRewardData,v)
                end
            -- end
        end
    end
    return finalRewardData
end

function getSpecialAwakeForFightForce( pCurDestinyIndex,pHeroInfo )
	local dbData = string.split(pHeroInfo.localInfo.destinyAwake,",")
	local awakeTable = {}
	for j=1,table.count(dbData)do
		local dbData1 = string.split(dbData[j],"|")
		if(tonumber(dbData1[1])<=(tonumber(pCurDestinyIndex)))then
			table.insert(awakeTable,dbData1[2])
		end
	end
	return awakeTable
end

function clearTotalAttForFightForce( pHid )
	finalFightData[pHid] = nil
end

function getTotalAttForFightForce( p_heroInfo )
	if(finalFightData[p_heroInfo.hid]~=nil)then
		return finalFightData[p_heroInfo.hid]
	end
	local rewardTable = {}
    for i=1,tonumber(p_heroInfo.destiny) do
        table.insert(rewardTable,getCurAtt(i)[1])
    end
    local data = getSpecialAwakeForFightForce(p_heroInfo.destiny,p_heroInfo)
    local awakeTable = {}
    -- for k,v in pairs(data) do
    -- 	local awakeData = DB_Awake_ability.getDataById(v)
    -- 	if(awakeData.attri_ids~=nil)then
    -- 		local attArry = string.split(awakeData.attri_ids,",")
    -- 		local valueArry = string.split(awakeData.attri_values,",")
    -- 		if(table.count(attArry)>1)then
    -- 			for k,v in pairs(attArry) do
    -- 				if(awakeTable[v]==nil)then
    -- 					awakeTable[v] = valueArry[k]
    -- 				else
    -- 					awakeTable[v] = awakeTable[v]+valueArry[k]
    -- 				end
    -- 			end
    -- 		else
    -- 			if(awakeTable[awakeData.attri_ids]==nil)then
    -- 				awakeTable[awakeData.attri_ids] = awakeData.attri_values
    -- 			else
    -- 				awakeTable[awakeData.attri_ids] = awakeTable[awakeData.attri_ids] + awakeData.attri_values
    -- 			end
    -- 		end
    -- 	end
    -- end

    for i,v in pairs(awakeTable) do
        local temArr = {}
        temArr.txt = i
        temArr.num = v
        table.insert(rewardTable,temArr)
    end

    local finalRewardData = {}
    for k,v in pairs(rewardTable) do
        if(table.isEmpty(finalRewardData))then
            table.insert(finalRewardData,v)
        else
            local isHave = false        
            for fKey,fValue in pairs(finalRewardData) do
                if(tonumber(fValue.txt)==tonumber(v.txt))then
                    isHave = true
                    finalRewardData[fKey].num = tonumber(fValue.num) + tonumber(v.num)
                    break
                end
            end
            if(isHave==false)then
                table.insert(finalRewardData,v)
            end
        end
    end

    local finalFightTable = {}
    for k,v in pairs(finalRewardData) do
    	finalFightTable[v.txt] = tonumber(v.num)
    end
    finalFightData[p_heroInfo.hid] = finalFightTable
    return finalFightTable
end