-- Filename：	ReResourceData.lua
-- Author：		DJN
-- Date：		2014-12-12
-- Purpose：		资源追回数据

module("ReResourceData", package.seeall)
require "db/DB_Resourceback"
require "script/ui/item/ItemUtil"
require "script/model/user/UserModel"
require "script/utils/TimeUtil"
--当前可追回资源的信息
local _resourceInfo = {}
local _isFirst = false
------设置可追回资源信息
function setResourceInfo(p_info)
    _resourceInfo = {}
    for k,v in pairs(p_info) do
        table.insert(_resourceInfo,v)
    end
end
-----获取可追回资源信息
function getResourceInfo( ... )
	return _resourceInfo
end

function setIsFirst( pIsFirst )
	_isFirst = pIsFirst
end

function getIsFirst( ... )
	return _isFirst
end
--"1|2,7|4,13|6,19|8"
--将数据表中的奖励 **|**|**转换成table的形式
function analyzeStrToTable( goodsStr )
	if(goodsStr == nil)then
	    return
	end
	local goodsData = {}
	local goodTab = string.split(goodsStr, ",")

	local tableCount = table.count(goodTab)
	for i = 1,tableCount do
	    local tab = string.split(goodTab[i],"|")
	    table.insert(goodsData,tab)
	end
	return goodsData
end
-----根据typeid返回该活动的所有补领奖励，对应 DB_Resourceback  
function getAllRewardByType(p_type,p_coin)
	--默认首页上展示银币奖励
	local coin = p_coin or "silver" 
	local rewards = nil
	
	if(coin == "silver")then
		rewards = DB_Resourceback.getDataById(p_type).silverreward
	elseif(coin == "gold")then
		rewards = DB_Resourceback.getDataById(p_type).goldreward
	end

	--rewards = analyzeStrToTable(rewards)
	rewards = ItemUtil.getItemsDataByStr(rewards)
	
    return rewards
end
-- -----获取全部补领需要的金币总数
-- function getAllGoldNum()
-- 	local rewardList = getResourceInfo()
--     --当前可补领的数量
--     local resourceNum = table.count(rewardList)
--     local totalGoldNum = 0
--     --print("可补领活动数量")
--     for i =1,resourceNum do
--     	--print("第i个的type",rewardList[i].type)
-- 		totalGoldNum = totalGoldNum + DB_Resourceback.getDataById(rewardList[i].type).goldcost
-- 	end
--     return totalGoldNum
-- end
-- -----获取全部补领需要的银币总数
-- function getAllSilverNum()
-- 	local rewardList = getResourceInfo()
--     --当前可补领的数量
--     local resourceNum = table.count(rewardList)
--     local totalSilverNum = 0
--     --print("可补领活动数量")
--     for i =1,resourceNum do
--     	--print("第i个的type",rewardList[i].type)
-- 		totalSilverNum = totalSilverNum + DB_Resourceback.getDataById(rewardList[i].type).silvercost
-- 	end
--     return totalSilverNum
-- end
-----获取当前是否有可领奖励
function ifHaveReward( ... )
	local rewardList = getResourceInfo()
	local flag = false
	for k,v in pairs(rewardList)do
        local intervalTime = tonumber(v.endTime)- tonumber(TimeUtil.getSvrTimeByOffset()) 
        if(intervalTime > 0)then
	       	flag = true
	       	break
        end
	end
	return flag
end
-----获取参数传进的奖励id需要多少金币，参数可能为string，可能为table
function getGoldByParam(p_param)
	local goldcost = 0
    if(type(p_param) == "string" or type(p_param) == "number")then
    	goldcost = DB_Resourceback.getDataById(p_param).goldcost
    elseif(type(p_param) == "table")then
    	for k,v in pairs(p_param)do
    		goldcost = goldcost + getGoldByParam(v)
    	end
    end
    return goldcost
end
-----获取参数传进的奖励id需要多少银币，参数可能为string，可能为table
function getSilverByParam(p_param)
	local silvercost = 0
    if(type(p_param) == "string" or type(p_param) == "number" )then
    	local dbInfo = DB_Resourceback.getDataById(p_param).silvercost   	
    	local silvercostDb = {}
	    local tab = string.split(dbInfo,"|")
	    table.insert(silvercostDb,tab)
    	if(tonumber(silvercostDb[1][1]) == 1)then
    		silvercost = tonumber(silvercostDb[1][2])
    	elseif(tonumber(silvercostDb[1][1]) == 2)then
    		--local vip = UserModel.getVipLevel() > 0  and UserModel.getVipLevel() or 1
    		local level = UserModel.getHeroLevel()
    		silvercost = level * tonumber(silvercostDb[1][2])
    	end
    elseif(type(p_param) == "table")then
    	for k,v in pairs(p_param)do
    		silvercost = silvercost + getSilverByParam(v)
    	end
    end
    return silvercost
end
----获取全部领取当前奖励的奖励id table
function getAllRewardTable( )
	local rewardTable = {}
	local allReward = getResourceInfo()
	for k,v in pairs(allReward) do
		local num = tonumber(v.num) or 1
		for i=1,num do
			table.insert(rewardTable,v.type)
		end
	end
	return rewardTable
end
----判断要补领传入的参数的资源当前银币够不够  
function isSilverEnough( p_param)
	local silverNeed = getSilverByParam(p_param)
	local curSilver  = UserModel.getSilverNumber()
	if((curSilver - silverNeed) >= 0 )then
		return true
	else
		return false
	end

end
----判断要补领传入的参数的资源当前金币够不够  
function isGoldEnough( p_param )
	local goldNeed = getGoldByParam(p_param)
	local curGold  = UserModel.getGoldNumber()
	if((curGold - goldNeed) >= 0 )then
		return true
	else
		return false
	end
end
----扣银币
function UpSilver( p_param )
	local silverNeed = tonumber(getSilverByParam(p_param))
	UserModel.addSilverNumber(-silverNeed)
end
----扣金币
function UpGold( p_param )
	local goldNeed = getGoldByParam(p_param)
    UserModel.addGoldNumber(-goldNeed)
end
-- ----更新本地缓存数据

function deleteTypeFromCache(  p_type )
    local p_type = tonumber(p_type)
    if(p_type == nil or table.isEmpty(_resourceInfo))then
        return
    end
    for k,v in pairs(_resourceInfo) do
        if(tonumber(v.type) == p_type)then
            table.remove(_resourceInfo,k)
        end
    end
end


--[[
	@desc	: 获取全部可金币追回的奖励id数组
    @param	: 
    @return	: table 奖励id数组
—-]]
function getAllCanReviceByGoldTypes()
	local retTab = {}
	local resourceInfo = getResourceInfo()
	for k,v in pairs(resourceInfo) do
		local canUseGold = (DB_Resourceback.getDataById(v.type).goldcost ~= nil) and (DB_Resourceback.getDataById(v.type).goldreward ~= nil)
		if (canUseGold) then
			table.insert(retTab,v.type)
		end
	end
	return retTab
end

--[[
	@desc	: 获取全部可银币领取的奖励id数组
    @param	: 
    @return	: table 奖励id数组
—-]]
function getAllCanReviceBySilverTypes()
	local retTab = {}
	local resourceInfo = getResourceInfo()
	for k,v in pairs(resourceInfo) do
		local canUseSilver = (DB_Resourceback.getDataById(v.type).silvercost ~= nil) and (DB_Resourceback.getDataById(v.type).silverreward ~= nil)
		if (canUseSilver) then
			table.insert(retTab,v.type)
		end
	end
	return retTab
end

--[[
	@desc	: 获取缓存数据中对应资源类型的剩余追回次数
    @param	: pType 资源类型
    @return	: number 剩余追回次数 默认返回1次
—-]]
function getTypeNumFromCache( pType )
	pType = tonumber(pType)
	local resourceInfo = getResourceInfo()
	local typeNum = 1
    if (pType == nil or table.isEmpty(resourceInfo)) then
        return typeNum
    end
	
	for k,v in pairs(resourceInfo) do
        if (tonumber(v.type) == pType and v.num and tonumber(v.num) > 0) then
        	typeNum = tonumber(v.num)
        	break
        end
	end
	return typeNum
end

--[[
	@desc	: 更新缓存数据中对应资源类型的剩余追回次数
    @param	: pType 资源类型 pNum 次数
    @return	: 
—-]]
function updateTypeNumFromCache( pType, pNum )
	pType = tonumber(pType)
    if(pType == nil or table.isEmpty(_resourceInfo))then
        return
    end
    for k,v in pairs(_resourceInfo) do
        if (tonumber(v.type) == pType) then
        	v.num = v.num + tonumber(pNum)
        	if (v.num <= 0) then
            	table.remove(_resourceInfo,k)
        	end
        	break
        end
    end
end

--[[
	@desc	: 是否有可银币追回的奖励
    @param	: pRwardArr 当前可追回奖励id数组
    @return	: 可否银币追回
—-]]
function isCanRetrieveBySilver( pRwardArr )
	local canRetrieveBySilver = false
	for k,v in pairs(pRwardArr)do
		local canUseSilver = (DB_Resourceback.getDataById(v).silvercost ~= nil) and (DB_Resourceback.getDataById(v).silverreward ~= nil)
		if (canUseSilver) then
			canRetrieveBySilver = canUseSilver
			break
		end
	end
    return canRetrieveBySilver
end

--[[
	@desc	: 合并奖励数据
    @param	: pRewardArr 奖励信息
    @return	: table 合并后的奖励数据
—-]]
function mergeRewardTable( pRewardArr )
	local retData = {}
	if (not table.isEmpty(pRewardArr)) then
		for i,v in ipairs(pRewardArr) do
			local isIn = false
			local pos = 0
			for j,rv in ipairs(retData) do
				if (v.type == rv.type and v.tid == rv.tid) then
					isIn = true
					pos = j
					break
				end
			end
			if (isIn and pos > 0) then
				-- print("pos =>",pos,"num =>",retData[pos].num,"add =>",v.num)
				retData[pos].num = retData[pos].num + v.num
			else
				local tab = table.hcopy(v, {})
				table.insert(retData, tab)
			end
		end
	end
	return retData
end
