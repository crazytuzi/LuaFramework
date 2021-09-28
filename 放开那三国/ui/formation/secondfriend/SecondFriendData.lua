-- FileName: SecondFriendData.lua 
-- Author: licong 
-- Date: 15-3-3 
-- Purpose: 第二套小伙伴数据


module("SecondFriendData", package.seeall)

local _secondFriendInfo = {}

--[[
	@des 	:设置缓存的信息
	@param 	:p_info:后端数据
	@return :
--]]
function setSecondFriendInfo( p_info )
	_secondFriendInfo = p_info
end

--[[
	@des 	:得到缓存的信息
	@param 	:
	@return :
--]]
function getSecondFriendInfo()
	return _secondFriendInfo 
end

--[[
	@des 	:设置该位置的hid
	@param 	:p_index p_hid:-1未开，0开了，N武将id
	@return :
--]]
function setPosHid( p_index, p_hid )
	if( not table.isEmpty(_secondFriendInfo) and _secondFriendInfo[tonumber(p_index)] ~= nil )then
		_secondFriendInfo[tonumber(p_index)] = p_hid
	end
end

--[[
	@des 	:获得属性的信息
	@param 	:p_attrId:属性id
	@return :table
--]]
function getAffixAttrInfoById( p_attrId )
	require "db/DB_Affix"
	local attrInfo = DB_Affix.getDataById(p_attrId)
	return attrInfo
end

--[[
	@des 	:获得第二套小伙伴增加的属性数组
	@param 	:
	@return :table
--]]
function getSecFriendAddAttrTab()
	require "db/DB_Formation"
	local dbInfo = DB_Formation.getDataById(1)
	local retTab = string.split(dbInfo.secondFriendsGetAffix, ",")
	return retTab
end

--[[
	@des 	:获得第二套小伙伴该位置增加的属性
	@param 	:p_index
	@return :table
--]]
function getSecFriendAddAttrByPos( p_index )
	local dbInfo = getDBdataByIndex(p_index)
	local temp = string.split(dbInfo.attribute, ",")
	local retTab = {}
	for k,v in pairs(temp) do
		local tab = string.split(v, "|")
		table.insert(retTab,tab)
	end
	return retTab
end

--[[
	@des 	:获得第二套小伙伴总个数
	@param 	:
	@return :num
--]]
function getSecFriendAllNum()
	require "db/DB_Secondfriends"
	local retNum = table.count(DB_Secondfriends.Secondfriends)
	return retNum
end

--[[
	@des 	:获得该位置配置信息
	@param 	:p_index
	@return :table
--]]
function getDBdataByIndex(p_index)
	require "db/DB_Secondfriends"
	local retData = DB_Secondfriends.getDataById(p_index)
	return retData
end

--[[
	@des 	:获得该位置开启消耗物品
	@param 	:p_index  
	@return :table{ {costType,costTid,costNum} }  1 金币 ；2 银币；3 物品
--]]
function getOpenCost(p_index)
	local retData = getDBdataByIndex(p_index)
	local temp = string.split(retData.cost, ",")
	local retTab = {}
	for i=1,#temp do
		local tab = string.split(temp[i], "|")
		local data = {}
		data.costType = tonumber(tab[1])
		data.costTid = tonumber(tab[2])
		data.costNum = tonumber(tab[3])
		table.insert(retTab,data)
	end
	return retTab
end

--[[
	@des 	:获得该位置开启等级
	@param 	:p_index
	@return :needConut,needLv,isHave
--]]
function getOpenLv(p_index)
	require "db/DB_Formation"
	local dbInfo = DB_Formation.getDataById(1)
	local temp = string.split(dbInfo.secondFriendsOpenLevel, ",")
	local needConut = 0
	local needLv = 0
	for i=1,#temp do
		local data = string.split(temp[i], "|")
		if( tonumber(data[1])+1 == tonumber(p_index) )then
			needConut = tonumber(data[2])
			needLv = tonumber(data[3])
			break
		end
	end

	local isHave = false
    require "script/ui/warcraft/WarcraftData"
    local haveCount = WarcraftData.getWarcraftCountByLevel(needLv)
    if( haveCount >= needConut)then
    	isHave = true
    end
	return needConut,needLv,isHave
end


--[[
	@des 	:获得该位置的hid 
	@param 	:p_index
	@return :-1未开，0开了，N武将id
--]]
function getSecondFriendHidByPos( p_index )
	local secondInfo = getSecondFriendInfo()
	local retHid = -1
	if( not table.isEmpty(secondInfo) and secondInfo[tonumber(p_index)] ~= nil )then
		retHid = tonumber(secondInfo[tonumber(p_index)])
	end
	return retHid
end

--[[
	@des 	:获得该位置的是否开启
	@param 	:p_index
	@return :false未开，true开了
--]]
function getIsOpenByPos( p_index )
	local retData = false
	local hid = getSecondFriendHidByPos(p_index)
	if( hid > -1)then
		retData = true
	end
	return retData
end

--[[
	@des 	:获得该位置的是否满足开启条件
	@param 	:p_index
	@return :false未开，true开了
--]]
function getIsCanOpenByPos( p_index )
	local retData = false

	local needConut,needLv,isHave = getOpenLv(p_index)
	local costTab = getOpenCost(p_index)

	local needType = {}
	for k,v in pairs(costTab) do
		if(v.costType == 1)then
			-- 金币
			if( UserModel.getGoldNumber() < v.costNum ) then
				table.insert(needType,v)
			end
		elseif(v.costType == 2)then
			-- 银币
			if( UserModel.getSilverNumber() < v.costNum ) then 
				table.insert(needType,v)
			end
		elseif(v.costType == 3)then
			-- 物品
			local havNum = ItemUtil.getCacheItemNumBy(v.costTid)
			if( havNum < v.costNum ) then 
				table.insert(needType,v)
			end
		end
	end

	if( isHave == true  and  table.isEmpty(needType) == true )then
		retData = true
	end

	return retData, needType
end


--[[
	@des 	:根据英雄hid得到位置
	@param 	:p_hid 英雄hid
	@return :
--]]
function getPosByHeroHid( p_hid )
	local retPos = nil
	if(p_hid == nil)then
		return retPos
	end
	local secondInfo = getSecondFriendInfo()
	for k,v in pairs(secondInfo) do
		if(tonumber(v) == tonumber(p_hid))then
			retPos = tonumber(k)
			break
		end
	end
	return retPos
end

-------------------------------------------------------------------------------------------------
--[[
	@des 	:是否有相同将领已经在小伙伴阵上 这一类武将在第二套小伙伴上的方法
	@param 	:p_hid 英雄hid
	@return : ture or false
--]]
function isHadSameTemplateOnSecondFriend( p_hid )
	require "db/DB_Heroes"
	local isOn = false
	local heroInfo = HeroUtil.getHeroInfoByHid(p_hid)
	local secondInfo = getSecondFriendInfo()
	if( table.isEmpty(secondInfo) )then
		return isOn
	end
	for k,v in pairs(secondInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = t_heroInfo.localInfo.model_id
			local modelIdB = heroInfo.localInfo.model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				isOn = true
				break
			end
		end
	end
	return isOn
end

--[[
	@des 	:是否有相同将领已经在小伙伴阵上 这一类武将在第二套小伙伴上的方法
	@param 	:p_htid 英雄htid
	@return : ture or false
--]]
function isHadSameTemplateOnSecondFriendByHtid( p_htid )
	require "db/DB_Heroes"
	local isOn = false
	local heroDBData = DB_Heroes.getDataById(p_htid)
	local secondInfo = getSecondFriendInfo()
	if(table.isEmpty(secondInfo))then
		return isOn
	end
	for k,v in pairs(secondInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = t_heroInfo.localInfo.model_id
			local modelIdB = heroDBData.model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				isOn = true
				break
			end
		end
	end
	return isOn
end

--[[
	@des 	:判断这个将领是否在第二套小伙伴上
	@param 	:p_hid 英雄hid
	@return : ture or false
--]]
function isInSecondFriendByHid(p_hid)
	local isOn = false
	local secondInfo = getSecondFriendInfo()
	if(table.isEmpty(secondInfo))then
		return isOn
	end
	for k,v in pairs(secondInfo) do
		if tonumber(p_hid) == tonumber(v) then
			isOn = true
			break
		end
	end
	return isOn
end

--[[
	@des 	:是否可以更换该武将到该位置上 更换第二套小伙伴伴用
	@param 	: p_hid:要更换的武将hid，p_position:要更换的位置
	@return :true 可以 
--]]
function isSwapHeroOnSecFriendByHid(p_hid,p_position)
	local retData = false
	local onPos = nil
	require "db/DB_Heroes"
	local heroInfo = HeroUtil.getHeroInfoByHid(tonumber(p_hid))
	local secondInfo = getSecondFriendInfo()
	if(table.isEmpty(secondInfo))then
		return retData
	end

	for k,v in pairs(secondInfo) do
		if(tonumber(v)>0)then
			local t_heroInfo = HeroUtil.getHeroInfoByHid(v)
			local modelIdA = t_heroInfo.localInfo.model_id
			local modelIdB = heroInfo.localInfo.model_id
			if(tonumber(modelIdA) == tonumber(modelIdB))then
				onPos = k
				break
			end
		end
	end

	if(onPos ~= nil)then
		if(tonumber(onPos) == tonumber(p_position))then
			retData = true
		else
			retData = false
		end
	else
		retData = true
	end
	return retData
end












