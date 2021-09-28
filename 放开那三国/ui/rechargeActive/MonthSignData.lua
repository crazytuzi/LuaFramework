-- Filename：	MonthSignData.lua
-- Author：		DJN
-- Date：		2014-10-13
-- Purpose：		月签到数据
module("MonthSignData", package.seeall)
local _signData = nil --从后端获取的当前已经签到的信息

--[[
	@des 	:--原数据"1|2,7|4,13|6,19|8"
             --数据表中的奖励 **，**，**转换成**|**|**的形式
	@param 	:
	@return :
--]]
function analyzeGoodsTabStr( goodsStr )
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
--"1|2,7|4,13|6,19|8"
--将数据表中的奖励 **，**，**转换成table的形式
function analyzeDateTabStr( goodsStr )
	if(goodsStr == nil)then
	    return
	end
	local goodsData = {}
	local goodTab = string.split(goodsStr, ",")

	local tableCount = table.count(goodTab)
	for i = 1,tableCount do
	    local tab = goodTab[i]
	    table.insert(goodsData,tab)
	end
	return goodsData
end
--[[
	@des 	:默认从2014年10月开始循环，以这个时间为起点,返回当月应该使用第几行（id为多少）的表数据
	@param 	:
	@return :DB_Month_sign对应id行
--]]
function getMonId( ... )
	require "script/utils/TimeUtil"
	local curTime = TimeUtil.getSvrTimeByOffset()	
	local curdate = os.date("*t", curTime)
	local length = nil
	local index
	-- if(curdate.year>2014)then
	-- 	--print("当前年份大于2014")
	-- 	length = (curdate.year - 2014 -1)*12 + 2 + curdate.month
	-- elseif(curdate.year == 2014 and curdate.month >= 10)then
	-- --	print("当前年份等于2014")
	-- 	length = curdate.month -10

	-- else
	-- 	--对于2014 10月之前的时间未做处理
	-- end
	
	-- --print("输出月份差",length)
	-- local i = math.floor(length/12)
	-- local index = tonumber((length - 12 * i)+1)
	if(curdate.month >= 10)then
		index = curdate.month - 10 + 1
	else
		index = curdate.month + 3
	end
    print("当前月份用的index")
    print(index)
	require "db/DB_Month_sign"
	local circle = DB_Month_sign.getDataById(1).circleId
	local monId = analyzeDateTabStr(circle)[index]
	return monId
end


--设置签到信息
function setSignData( data)
	_signData = data
	--print("已经设置data")
end
--返回签到信息
function getSignData( ... )
	return _signData

end
--[[
	@des 	:获得表中的VIP活动日字段
	@param 	:
	@return :返回表中的VIP日字段（未解析）
--]]
function getVIPday( ... )
	require "db/DB_Month_sign"
	local monId = tonumber(getMonId())
	local allDay = DB_Month_sign.getDataById(monId).doubleReward
	return allDay
end
--[[
	@des 	:返回本月的配置表中共配置了多少天签到次数
	@param 	:
	@return :返回表中次数的字段
--]]
function getSignNumInDB( ... )
	require "db/DB_Month_sign"
	local monId = tonumber(getMonId())
	local allDay = DB_Month_sign.getDataById(monId).num
	return tonumber(allDay)
end

--[[
	@des 	:获取玩家选定的奖励的描述和icon信息
	@param 	:从表中解析出来的奖励信息 包含三个字段 [type]，[num]，[tid]
	@return :用于弹窗展示的 头像 、名称、描述、数量
--]]
function getDes(p_infoTable)
	require "script/ui/item/ItemUtil"
	require "script/ui/item/ItemSprite"
	require "script/ui/hero/HeroPublicLua"
	local infoTable = p_infoTable

	local iconBg = nil
	local iconName = nil
	local nameColor = nil
	local desc = nil

	if(infoTable.type == "item")then
		
		if(tonumber(infoTable.tid) >= 400001 and tonumber(infoTable.tid) <= 500000)then
			--对于武魂，要创建带有武将信息回调的button头像
			iconBg = ItemSprite.getHeroSoulSprite(tonumber(infoTable.tid),MonthCbLayer.getTouchPriority(),MonthCbLayer.getZorder(),nil)
		else
			iconBg = ItemSprite.getItemSpriteByItemId(tonumber(infoTable.tid))
		end
	    local itemData = ItemUtil.getItemById(tonumber(infoTable.tid))
	    iconName = itemData.name
	    nameColor = HeroPublicLua.getCCColorByStarLevel(itemData.quality)
	    desc = itemData.desc	
	elseif(infoTable.type == "hero")then
		local heroData = DB_Heroes.getDataById(tonumber(infoTable.tid))
		iconName = heroData.name
		nameColor = HeroPublicLua.getCCColorByStarLevel(heroData.star_lv)
		desc = heroData.desc
		require "script/model/utils/HeroUtil"
		iconBg  = HeroUtil.getHeroIconByHTID(tonumber(infoTable.tid))		
	elseif(infoTable.type == "silver") then
		-- 银币
		iconBg= ItemSprite.getSiliverIconSprite()
		iconName = GetLocalizeStringBy("key_1687")
		local quality = ItemSprite.getSilverQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_68")
	elseif(infoTable.type == "soul") then
		-- 将魂
		iconBg= ItemSprite.getSoulIconSprite()
		iconName = GetLocalizeStringBy("key_1616")
		local quality = ItemSprite.getSoulQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_75")
	elseif(infoTable.type == "gold") then
		-- 金币
		iconBg= ItemSprite.getGoldIconSprite()
		iconName = GetLocalizeStringBy("key_1491")
		local quality = ItemSprite.getGoldQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_69")
    elseif(infoTable.type == "prestige") then
		-- 声望
		iconBg= ItemSprite.getPrestigeSprite()
		iconName = GetLocalizeStringBy("key_2231")
		local quality = ItemSprite.getPrestigeQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_70")
    elseif(infoTable.type == "jewel") then
		-- 魂玉
		iconBg= ItemSprite.getJewelSprite()
		iconName = GetLocalizeStringBy("key_1510")
		local quality = ItemSprite.getJewelQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_71")
    elseif(infoTable.type == "execution") then
		-- 体力
		iconBg= ItemSprite.getExecutionSprite()
		iconName = GetLocalizeStringBy("key_1032")
		local quality = ItemSprite.getExecutionQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
    elseif(infoTable.type == "stamina") then
		-- 耐力
		iconBg = ItemSprite.getStaminaSprite()
		iconName = GetLocalizeStringBy("key_2021")
		local quality = ItemSprite.getStaminaQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)

    elseif(infoTable.type == "honor") then
		-- 荣誉
		iconBg= ItemSprite.getHonorIconSprite()
		iconName = GetLocalizeStringBy("lcy_10040")
		local quality = ItemSprite.getHonorQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_72")
    elseif(infoTable.type == "contri") then
		-- 贡献
		iconBg= ItemSprite.getContriIconSprite()
		iconName = GetLocalizeStringBy("lcy_10041")
		local quality = ItemSprite.getContriQuality()
        nameColor = HeroPublicLua.getCCColorByStarLevel(quality)
        desc = GetLocalizeStringBy("djn_74")
        
    else

	end

	local desTable = {}

	desTable.iconBg = iconBg
	desTable.iconName = iconName
	desTable.nameColor = nameColor
	desTable.desc = desc 

	return desTable
	
end
--[[
	@des 	:--根据传入的时间戳，判断上次签到的时间和当前时间是否为同一天，即判断今天有没有签到过
	@param 	:
	@return :--今天没有领取过返回true  今天已经领取过返回false
--]]
function isDiffDay(timeArray)
	if(timeArray == nil or timeArray == 0)then
		return true
	end
	require "script/utils/TimeUtil"
	local curTime = TimeUtil.getSvrTimeByOffset()	
	local curdate = os.date("*t", curTime)
	local lastdate = os.date("*t", tonumber(timeArray))
	-- print("输出当前时间戳",curdate.day)
	-- print("输出上次时间戳",lastdate.day)
	if (curdate.year == lastdate.year and curdate.month == lastdate.month and curdate.day == lastdate.day)then
		--print("检测为同一天")
		return false
	else
		--print("不是同一天")
		return true
	end
end
--[[
	@des 	:领取奖励后调用，发奖更新数据
	@param 	:
	@return :
--]]
function setCurReward( ... )
    local rewardTag = MonthCbLayer.getRewardTag()
   -- print("获取的奖励Tag",rewardTag)
    local rewards = MonthCbLayer.getCurReward()
    if(rewardTag == 1)then
        UpdateUserModel(rewards)
    elseif(rewardTag == 2 )then
        --领VIP双倍 发两次
        UpdateUserModel(rewards)
        UpdateUserModel(rewards)
    elseif(rewardTag == 3 )then
        UpdateUserModel(rewards)
    else
    end
end
--[[
    @des    :更新用户获取的奖励
    @param  :
    @return :
--]]
function UpdateUserModel(infoTable)
	--print("更新一次奖励数据")
	require "script/model/user/UserModel"

	if(infoTable.type == "item")then
		--物品不做处理
	elseif(infoTable.type == "hero")then
		--英雄不做处理
	elseif(infoTable.type == "silver") then
		-- 银币
		UserModel.addSilverNumber(tonumber(infoTable.num))
	elseif(infoTable.type == "soul") then
		-- 将魂
		UserModel.addSoulNum(tonumber(infoTable.num))
	elseif(infoTable.type == "gold") then
		-- 金币
		UserModel.addGoldNumber(tonumber(infoTable.num))
    elseif(infoTable.type == "prestige") then
		-- 声望
		UserModel.addPrestigeNum(tonumber(infoTable.num)) 
    elseif(infoTable.type == "jewel") then
		-- 魂玉
		UserModel.addJewelNum(tonumber(infoTable.num)) 
    elseif(infoTable.type == "execution") then
		-- 体力
		UserModel.addEnergyValue(tonumber(infoTable.num))      
    elseif(infoTable.type == "stamina") then
		-- 耐力
        UserModel.addStaminaNumber(tonumber(infoTable.num))
	end
end

--[[
	@des 	:--判断今天是否是VIP活动日，如果是VIP活动日，通过判断最后一次领取时候的VIP等级来判断玩家是否有机会通过升VIP来补领奖励
	@param 	:
	@return :有机会:true  没机会:false
--]]
function haveChance( day )
	
	local chance = false
	local signedInfo = MonthSignData.getSignData()
	local diffDay = MonthSignData.isDiffDay(signedInfo.sign_time)
	local allDay = MonthSignData.getVIPday()
	local allDayforUse = MonthSignData.analyzeGoodsTabStr(allDay) --解析后的VIP天数和等级配置
	local dayCount = table.count(allDayforUse) --本月有多少天是VIP活动日
	 
	if(diffDay == false)then
		--大前提是上一次领取和今天是同一天
		for k = 1,dayCount do

	        if(tonumber(day)== tonumber(allDayforUse[k][1]))then
	        print("今天是VIP活动日")
	        --今天是VIP活动日
	        local lastSign = signedInfo.reward_vip	        
	       		print("最后一次签到的等级，当日活动等级",lastSign,"--",allDayforUse[k][2])
		        if(tonumber(lastSign) < tonumber(allDayforUse[k][2]))then
		            print("今日最后一次领奖时未达到VIP活动等级 有机会补领")
		            chance = true
		            			--上次签到的时候的等级没有达到今日VIP活动等级，意味着还有机会通过升级来补领
		            break
		        end
	        end
	    end
	end
    return chance
end
--[[
	@des 	:获取某日可双倍领奖的VIP等级
	@param 	:
	@return :注意，返回-1说明今天不是VIP活动日
--]]
function todayVip( day )
	local allDay = MonthSignData.getVIPday()

	local allDayforUse = MonthSignData.analyzeGoodsTabStr(allDay) --解析后的VIP天数和等级配置

	local dayCount = table.count(allDayforUse) --本月有多少天是VIP活动日

	local VIP = -1
	for k = 1,dayCount do

        if(tonumber(day)== tonumber(allDayforUse[k][1]))then
        --找到了活动日      
        	VIP = allDayforUse[k][2] 
	        break
	    end
        
    end
    return tonumber(VIP)
end


