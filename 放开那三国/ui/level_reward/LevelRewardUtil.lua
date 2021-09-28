-- Filename: LevelRewardUtil.lua
-- Author: zhz
-- Date: 2013-8-29
-- Purpose: 该文件用于: 等级礼包的方法和数据缓存
module ("LevelRewardUtil", package.seeall)


local _curRewardInfo = nil			-- 当前等级礼包的信息

-- 保存 等级礼包信息
function setRewardInfo( curRewardInfo)
	_curRewardInfo = curRewardInfo
end

function getRewardInfo( )
	return _curRewardInfo
end

function addRewardInfo( curReceiveID)
	table.insert(_curRewardInfo,curReceiveID)
end

local _curRewardID
-- 保存当前reward 的id
function setCurRewardID( id)
	_curRewardID = id
end

function getCurRewardID()
	return _curRewardID
end

-- 判断当前是否有有奖励可领取
function boolReceived( )
	require "script/model/user/UserModel"
	local boolReceived=false
	-- 第几个奖励
	local index =0
	-- 有几个奖励尚未领取
	local canReceiveNum = 0
	local userInfo = UserModel.getUserInfo()
	local rewardData= getAllRewardData()
	for i=1,#rewardData do 
		if(tonumber(userInfo.level) >= tonumber(rewardData[i].level)) then
			index=i
		end
	end
	-- 

	if(not table.isEmpty(_curRewardInfo) ) then
		if(#_curRewardInfo< index) then
			-- print(" =================_curRewardInfo is : ", #_curRewardInfo ,"and index is : ",index, "canReceiveNum is :  ", canReceiveNum)
			boolReceived = true
			canReceiveNum=tonumber(index)- #_curRewardInfo
		end
	else
		if(index >0) then
			boolReceived = true
			canReceiveNum= index
		end
	end
	return boolReceived, canReceiveNum
end

-- 第一个可领取的index
function getFirstRewardIndex( )
	local index =0
	print("_curRewardInfo  is :  ")
	local rewardInfo={}
	table.hcopy(_curRewardInfo, rewardInfo)
	local function keySort ( rewardData_1, rewardData_2 )
	   	return tonumber(rewardData_1 ) < tonumber(rewardData_2)
	end
	table.sort( rewardInfo, keySort)
	print_t(rewardInfo)
	
	if(not table.isEmpty(rewardInfo) ) then
		for i=1,#rewardInfo do
			if(i~= tonumber(rewardInfo[i])) then
				index= i-1
				break
			end
		end
	end

	if(not table.isEmpty(rewardInfo) and index == 0 ) then
		index = #rewardInfo
	end

	-- 当所有的都领完时，结束
	if(index== table.count(DB_Level_reward.Level_reward)) then
		index= index -2
	end

	return index

end

-- 获取所有奖励的信息
function getAllRewardData()
	require "db/DB_Level_reward"
	local tData = {}
	for k,v in pairs(DB_Level_reward.Level_reward) do
		table.insert(tData, v)
	end
	local rewardData = {}
	for k,v in pairs(tData) do
		table.insert(rewardData, DB_Level_reward.getDataById(v[1]))
	end

	local function keySort ( rewardData_1, rewardData_2 )
	   	return tonumber(rewardData_1.level ) < tonumber(rewardData_2.level)
	end
	table.sort( rewardData, keySort)
	return rewardData
end

-- 通过奖励类型判断物品 1、银币,2、将魂,3、金币,4、体力,5、耐力,6、物品,7、多个物品,8、等级*银币,9、等级*将魂
-- 获取物品的图片
require "script/ui/hero/HeroPublicCC"
function getItemSp(reward_type, htid)
    reward_type = tonumber(reward_type)
    local itemSp 
    if(reward_type == 1) then
        itemSp = CCSprite:create("images/common/siliver_big.png")
    elseif(reward_type == 2) then
        itemSp = CCSprite:create("images/common/soul_big.png")
    elseif(reward_type == 3) then
        itemSp = CCSprite:create("images/common/gold_big.png")
    elseif(reward_type == 4) then
        itemSp = CCSprite:create("images/online/reward/energy_big.png")
    elseif(reward_type == 5) then
        itemSp = CCSprite:create("images/online/reward/stain_big.png")
    elseif(reward_type == 8) then
        itemSp = CCSprite:create("images/common/siliver_big.png")
    elseif(reward_type == 9 ) then
        itemSp =CCSprite:create("images/common/soul_big.png")
    elseif(reward_type == 10) then
    	print("htid is ", htid)
        itemSp = ItemSprite.getHeroIconItemByhtid( tonumber(htid), -605) --HeroPublicCC.getCMISHeadIconByHtid(htid)
    end
    return itemSp
    
end


function getRewardNum( reward_type, reward_values )
	 reward_type = tonumber(reward_type)
	 local number
	 if(reward_type == 1) then
       		number = reward_values 
	    elseif(reward_type == 2) then
	        number = reward_values
	    elseif(reward_type == 3) then
	       number = reward_values 
	    elseif(reward_type == 4) then
	       number = reward_values 
	    elseif(reward_type == 5) then
	      number =reward_values
	    elseif(reward_type == 6) then
	    	number = 1
	    elseif(reward_type == 8) then
	       number = reward_values 
	    elseif(reward_type == 9 ) then
	        number =reward_values 
	    elseif(reward_type == 7) then
	        number = lua_string_split(reward_values,'|')[2]
	    elseif(reward_type == 10) then
	       number =1 
	   else
	   	   number = 1
	   	end

		return number
end

-- 弹出奖励提示
function showRewardInfo( rewardData )
	local desc = GetLocalizeStringBy("key_1914")
	for i=1, #rewardData do
		-- desc = desc .. receiveData["reward_desc" .. i]
	    if(reward_type == 1) then
       		desc = desc .. GetLocalizeStringBy("key_1687") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 2) then
	        desc = desc .. GetLocalizeStringBy("key_1616") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 3) then
	       desc = desc .. GetLocalizeStringBy("key_1491") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 4) then
	       desc = desc .. GetLocalizeStringBy("key_3221") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 5) then
	      desc = desc .. GetLocalizeStringBy("key_1451") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 8) then
	       desc = desc .. GetLocalizeStringBy("key_1878") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 9 ) then
	        desc = desc .. GetLocalizeStringBy("key_1475") .. rewardData[i].reward_values .. "\n"
	    elseif(reward_type == 10) then
	       desc = desc .. rewardData[i].reward_desc .. "\n"
	   else
	   	   desc = desc .. rewardData[i].reward_desc .. "\n"
    end
	end
end





