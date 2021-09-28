-- Filename：	GuildUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-12-20
-- Purpose：		军团工具


module("GuildUtil", package.seeall)

require "db/DB_Legion"
require "db/DB_Legion_feast"
require "db/DB_Legion_icon"
require "script/ui/guild/GuildDataCache"
require "db/DB_Legion_shop"
require "db/DB_Legion_copy"
require "db/DB_Corps_quest_config"
require "db/DB_Legion_granary"

local guildDBInfo = DB_Legion.getDataById(1)

-- 开启
function isGuildOpen()
	
end

-- 创建所需银币
function getCreateNeedSilver()
	return guildDBInfo.costSilver
end

-- 创建所需金币
function getCreateNeedGold()
	return guildDBInfo.costGold
end

-- 军团人数上限 param 军团等级
function getMaxMemberNum(curLv)
	curLv = tonumber(curLv)
	local baseNumStr = guildDBInfo.baseNum
	local maxMemberNum = 1
	local baseNumArr = string.split(guildDBInfo.baseNum, ",")
	for k,v in pairs(baseNumArr) do
		local b_v = string.split(v, "|")
		if(tonumber(b_v[1]) == curLv )then
			maxMemberNum = tonumber(b_v[2])
			break
		end
	end

	return maxMemberNum
end

-- 是否达到成员流动次数上限
function isCanAgreeNum()
	return getMaxMemberNum() + guildDBInfo.jionNumLimit
end

-- 捐献方式
function getDonateInfoBy( d_type )
	local donateStr = guildDBInfo["donate"..d_type]
	local donateArr = string.split(donateStr, "|")
	
	local t_donate = {}

	t_donate.silver 	 = tonumber(donateArr[1])
	t_donate.gold 		 = tonumber(donateArr[2])
	t_donate.guildDonate = tonumber(donateArr[3])
	t_donate.sigleDonate = tonumber(donateArr[4])
	t_donate.needVip 	 = tonumber(donateArr[5])

	return t_donate
end


-- 副军团长人数 param 军团等级
function getMaxViceLeaderNumBy(curLv)
	curLv = tonumber(curLv)
	local donateArr = string.split(guildDBInfo.viceLevelArr, ",")
	local viceNum = 99

	for k, v in pairs(donateArr) do
		local v_arr = string.split(v, "|")
		if( curLv <= tonumber(v_arr[1]) and viceNum > tonumber(v_arr[2]) )then
			viceNum = tonumber(v_arr[2])
		end
	end

	return viceNum
end

-- 军团大厅升级所需经验
function getNeedExpByLv( curLv )
	require "script/utils/LevelUpUtil"
	local needExp = 0
	needExp = LevelUpUtil.getNeedExpByIdAndLv( guildDBInfo.expId, curLv )
	return needExp
end

-- 关公殿
function getGuanyuNeedExpByLv( curLv )
	require "script/utils/LevelUpUtil"
	local needExp = 0
	needExp = LevelUpUtil.getNeedExpByIdAndLv( DB_Legion_feast.getDataById(1).expId, curLv )
	return needExp
end

-- 商城
function getShopNeedExpByLv( curLv )
	require "script/utils/LevelUpUtil"
	local needExp = 0
	needExp = LevelUpUtil.getNeedExpByIdAndLv( DB_Legion_shop.getDataById(1).legionShopExp, curLv )
	return needExp
end

-- 军机大厅
function getMilitaryNeedExpByLv( curLv )
	require "script/utils/LevelUpUtil"
	local needExp = 0
	needExp = LevelUpUtil.getNeedExpByIdAndLv( DB_Legion_copy.getDataById(1).expId, curLv )
	return needExp
end

-- 军团任务大厅
function getTaskNeedExpByLv( curLv )
	require "script/utils/LevelUpUtil"
	local needExp = 0
	needExp = LevelUpUtil.getNeedExpByIdAndLv( DB_Corps_quest_config.getDataById(1).legionTaskExp, curLv )
	return needExp
end

-- 军团粮仓
function getLiangCangNeedExpByLv( curLv )
	require "script/utils/LevelUpUtil"
	local needExp = 0
	needExp = LevelUpUtil.getNeedExpByIdAndLv( DB_Legion_granary.getDataById(1).expId, curLv )
	return needExp
end

-- 弹劾军团长的费用
function getCostForAccuse()
	return guildDBInfo.accuseCost
end


-- 得到创建军团所需的等级
function getCreateGuildNeedLevel( ... )
	return tonumber(guildDBInfo.needLevel)
end

-- 军团最大等级
function getMaxGuildLevel()
	return guildDBInfo.maxLevel
end

-- 关公殿最大等级
function getMaxGongyuLevel()
	return math.ceil(getMaxGuildLevel()*DB_Legion_feast.getDataById(1).levelRatio/100)
end

-- 军团商店最大等级
function getMaxShopLevel()
	return math.ceil(getMaxGuildLevel()*DB_Legion_shop.getDataById(1).levelRatio/100)
end

-- 军机大厅最大等级
function getMaxHallCopyLevel()
	return math.ceil(getMaxGuildLevel()*DB_Legion_copy.getDataById(1).levelRatio/100)
end

-- 粮仓最大等级
function getMaxBarnLevel()
	return math.ceil(getMaxGuildLevel()*DB_Legion_granary.getDataById(1).levelRatio/100)
end

--------------------------- 军团商店 -------------------------
require "db/DB_Legion_goods" 
require "script/ui/guild/GuildDataCache"

local _normalGoodsInfo = {}
local _specialGoodsInfo= {}

-- 获得道具的物品信息
function getNormalGoods( )
	local normalGoods= DB_Legion_goods.getArrDataByField("goodType", 2)


	_normalGoodsInfo = {}
	-- 对数据进行排序
    local function keySort ( rewardData_1, rewardData_2 )
        return tonumber(rewardData_1.sortType ) < tonumber(rewardData_2.sortType)
    end
    table.sort( normalGoods, keySort)
    for i=1, #normalGoods do 
    	if(tonumber(normalGoods[i].isSold)==1) then
    		--从后端返回的数据中获取已经购买的次数
			local alreadyBuyNum = GuildDataCache.getNorAlreadyBuyNumById(normalGoods[i].id)
			-- print("alreadyBuyNum",alreadyBuyNum)
			local goodInfo= {}
			 local normalGoods = normalGoods[i]
			if(normalGoods.limitType == 2)then
				if(normalGoods.baseNum - alreadyBuyNum) > 0 then
				  
				    local goods = lua_string_split(normalGoods.items,"|")
				    goodInfo.id= normalGoods.id
				    goodInfo.type = tonumber(goods[1])
			        goodInfo.tid = tonumber(goods[2]) 
			        goodInfo.num = tonumber(goods[3])
			        goodInfo.costContribution = normalGoods.costContribution
			        goodInfo.limitType= normalGoods.limitType
			        goodInfo.needLegionLevel= normalGoods.needLegionLevel
			        goodInfo.baseNum= normalGoods.baseNum
			        goodInfo.personalLimit= normalGoods.personalLimit
			        goodInfo.levelLimit = normalGoods.levelLimit
			  
			     end
		        
		    else
		    	
				    -- local normalGoods = normalGoods[i]
				    local goods = lua_string_split(normalGoods.items,"|")
				    goodInfo.id= normalGoods.id
				    goodInfo.type = tonumber(goods[1])
			        goodInfo.tid = tonumber(goods[2]) 
			        goodInfo.num = tonumber(goods[3])
			        goodInfo.costContribution = normalGoods.costContribution
			        goodInfo.limitType= normalGoods.limitType
			        goodInfo.needLegionLevel= normalGoods.needLegionLevel
			        goodInfo.baseNum= normalGoods.baseNum
			        goodInfo.personalLimit= normalGoods.personalLimit
			        goodInfo.levelLimit = normalGoods.levelLimit
			      
			end
			-- 新增额外消耗 20160414
	        if (normalGoods.extraCost and goodInfo.id) then
	        	require "script/ui/item/ItemUtil"
        		local extraCostTab = ItemUtil.getItemsDataByStr(normalGoods.extraCost)[1]
        		goodInfo.extraCost = extraCostTab
	    	end
	    	if(not table.isEmpty(goodInfo))then
	    		 table.insert( _normalGoodsInfo ,goodInfo)
	    	end
		end
	end
	return _normalGoodsInfo
end

-- 通过 goodId来获得某一个道具物品信息
function getNormalGoodById( id)
	for i=1,#_normalGoodsInfo do
		if(tonumber(id)== _normalGoodsInfo[i].id) then
			return _normalGoodsInfo[i]
		end
	end
end

-- 获得珍品的物品信息
function getSpecialGoods( )

	local specialGoods = GuildDataCache.getSpecialGoodsInfo()

	_specialGoodsInfo={}
	for goodId, values in pairs(specialGoods) do
		local goodInfo = {}
		print(" goodId is : ", goodId)

		local goodData = DB_Legion_goods.getDataById(tonumber(goodId))
		print_t(goodData)
		local goods = lua_string_split(goodData.items,"|")
        goodInfo.id = goodData.id
        goodInfo.type = tonumber(goods[1])
        goodInfo.tid = tonumber(goods[2]) 
        goodInfo.num = tonumber(goods[3])
        goodInfo.sortType= goodData.sortType
  		goodInfo.costContribution = goodData.costContribution
	    goodInfo.limitType= goodData.limitType
	    goodInfo.needLegionLevel= goodData.needLegionLevel
	    goodInfo.baseNum= goodData.baseNum
	    goodInfo.personalLimit= goodData.personalLimit
	    goodInfo.levelLimit = goodData.levelLimit
		-- 新增额外消耗 20160414
        if (goodData.extraCost) then
        	require "script/ui/item/ItemUtil"
        	local extraCostTab = ItemUtil.getItemsDataByStr(goodData.extraCost)[1]
        	goodInfo.extraCost = extraCostTab
    	end
	    table.insert(_specialGoodsInfo, goodInfo)
	end

	local function keySort ( rewardData_1, rewardData_2 )
        return tonumber(rewardData_1.sortType ) < tonumber(rewardData_2.sortType)
    end
    table.sort( _specialGoodsInfo, keySort)

    return _specialGoodsInfo
end

-- 通过 goodId 来获得某一珍品的物品信息
function getSpcialGooodById( id)
	-- print("getSpcialGooodById  getSpcialGooodById getSpcialGooodById")
	-- print_t(_specialGoodsInfo[1])

	for i=1,#_specialGoodsInfo do
		if(tonumber(id)== _specialGoodsInfo[i].id) then
			return _specialGoodsInfo[i]
		end
	end
end


-- 建设情况
function getContriStringByInfo(member_info)
	local t_text_arr = {}
	l_time = member_info.contri_time or 0
	l_time = tonumber(l_time)
	-- 今天00:00:00 的时间戳
	local t_time = TimeUtil.getSvrIntervalByTime(000000)
	local c_text = ""
	if(l_time>=t_time)then
		if(tonumber(member_info.contri_type) == 1)then
			local t_text = {}
			t_text.text = GetLocalizeStringBy("key_2267")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
		elseif(tonumber(member_info.contri_type) == 2)then	
			--
			local t_text = {}
			t_text.text = GetLocalizeStringBy("key_1898")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
			--
			local t_text_2 = {}
			t_text_2.text = GetLocalizeStringBy("key_1334")
			t_text_2.color = ccc3(0xff, 0xf6, 0x00)
			table.insert(t_text_arr, t_text_2)
			--
			local t_text_3 = {}
			t_text_3.text = GetLocalizeStringBy("key_1653")
			t_text_3.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text_3)

		elseif(tonumber(member_info.contri_type) == 3)then
			local t_text = {}
			t_text.text = GetLocalizeStringBy("key_1898")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
			--
			local t_text_2 = {}
			t_text_2.text = GetLocalizeStringBy("key_3411")
			t_text_2.color = ccc3(0xff, 0xf6, 0x00)
			table.insert(t_text_arr, t_text_2)
			--
			local t_text_3 = {}
			t_text_3.text = GetLocalizeStringBy("key_1653")
			t_text_3.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text_3)
		elseif(tonumber(member_info.contri_type) == 4)then
			local t_text = {}
			t_text.text = GetLocalizeStringBy("key_1898")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
			--
			local t_text_2 = {}
			t_text_2.text = GetLocalizeStringBy("lic_1124")
			t_text_2.color = ccc3(0xff, 0xf6, 0x00)
			table.insert(t_text_arr, t_text_2)
			--
			local t_text_3 = {}
			t_text_3.text = GetLocalizeStringBy("key_1653")
			t_text_3.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text_3)
		elseif(tonumber(member_info.contri_type) == 5) then
			local t_text = {}
			t_text.text = GetLocalizeStringBy("key_1898")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
			--
			local t_text_2 = {}
			t_text_2.text = GetLocalizeStringBy("zzh_1213")
			t_text_2.color = ccc3(0xff, 0xf6, 0x00)
			table.insert(t_text_arr, t_text_2)
			--
			local t_text_3 = {}
			t_text_3.text = GetLocalizeStringBy("key_1653")
			t_text_3.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text_3)
		else
			print("this contri_type is no add !!!")
		end

	else
		local c_days = 0 
		c_days = math.ceil( ( t_time- l_time)/(60*60*24) ) 
		if(c_days<=7)then
			local t_text = {}
			t_text.text = c_days .. GetLocalizeStringBy("key_1650")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
		else
			local t_text = {}
			t_text.text = GetLocalizeStringBy("key_3275")
			t_text.color = ccc3(0xff, 0xff, 0xff)
			table.insert(t_text_arr, t_text)
		end
	end
	return t_text_arr
end


-- 成员审核排序 按时间
function sortCheckByTime( memberData )
	local function keySort ( data_1, data_2 )

		if(tonumber(data_1.apply_time) > tonumber(data_2.apply_time))then
			-- 按在线
			return false
		else
			return true
		end

	end
	table.sort( memberData, keySort )
	return memberData
end

-- 成员审核排序 按等级
function sortCheckByLevel( memberData )
	local function keySort ( data_1, data_2 )
		if(tonumber(data_1.level) >= tonumber(data_2.level))then
			return false
		else
			return true
		end
	end
	table.sort( memberData, keySort )
	return memberData
end

-- 成员审核排序 按战斗力
function sortCheckByForce( memberData )
	local function keySort ( data_1, data_2 )
		if(tonumber(data_1.fight_force) >= tonumber(data_2.fight_force))then
			return false
		else
			return true
		end
	end
	table.sort( memberData, keySort )
	return memberData
end

-- 成员审核排序 按竞技排名
function sortCheckByRank( memberData )
	local function keySort ( data_1, data_2 )
		if(data_1.position == nil)then
			return true
		end
		if(data_2.position == nil)then
			return false
		end
		if(tonumber(data_1.position) <= tonumber(data_2.position))then
			return false
		else
			return true
		end
	end
	table.sort( memberData, keySort )
	return memberData
end

--[[
    @des:       判断字符串中是否含有空格
    @param:     字符串
    @return:    布尔值，true含有空格，false不含空格
--]]
function checkSpace(p_string)
    --是否含有空格初始化为false
    local haveSpace = false
    --过滤掉空格
    local gsubString = string.gsub(p_string," ","")
    
    --如果过滤前后字符串不等，则代表中间有空格
    if gsubString ~= p_string then
        haveSpace = true
    end

    return haveSpace
end

--[[
	@desc:		得到军团军旗id得到军团军旗icon
	@p_iconId:	军团军旗id
	@return:	CCSprite  军团军旗icon
--]]
function getGuildIcon(p_iconId)
	local legionIconDb = DB_Legion_icon.getDataById(p_iconId)
	local iconBg = CCSprite:create()
	local iconPath = "images/guild/badge/icon/" .. legionIconDb.icon
	local icon = CCSprite:create(iconPath)
	iconBg:setContentSize(icon:getContentSize())
	iconBg:addChild(icon)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setPosition(ccpsprite(0.5, 0.5, iconBg))
	return iconBg
end

--[[
	@desc:		得到自己军团的军旗
	@return:	CCSprite 自己的军团军旗icon
--]]
function getMyGuildIcon()
	local myGuildIconId = GuildDataCache.getGuildIconId()
	local myGuildIcon = getGuildIcon(myGuildIconId)
	return myGuildIcon
end

------------------------------ 军团科技 ---------------------------------
--[[
	@desc:		获取开启军团科技大厅的条件
	@return:	tab {需要军团大厅等级}
--]]
function getGuildSkillOpenNeedLv()
	local retTab = {}
	local skillTab = string.split(guildDBInfo.skill_open, ",")
	for k,v in pairs(skillTab) do
		local tab = string.split(v, "|")
		table.insert(retTab,tonumber(tab[2]))
	end
	return retTab
end
