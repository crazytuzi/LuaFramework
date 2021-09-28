-- Filename：	TowerUtil.lua
-- Author：		Cheng Liang
-- Date：		2013-1-7
-- Purpose：		爬塔工具类


module("TowerUtil", package.seeall)


require "db/DB_Tower_layer"
require "db/DB_Tower"

local config_info = DB_Tower.getDataById(1)

-- 配置信息
function getTowerConfig()
	return DB_Tower.getDataById(1)
end

-- 最大重置次数
function getMaxResetTowerTimes()
	local config = DB_Tower.getDataById(1)
	return tonumber(config.times)
end

-- 最大失败次数
function getMaxFailedTimes()
	local config = DB_Tower.getDataById(1)
	return tonumber(config.loseTime)
end

-- 扫荡cd时间
function getWipeCD()
	local config = DB_Tower.getDataById(1)
	return tonumber(config.wipeCd)
end

-- 获取购买挑战次数的价格
function getCostGoldByTimes( times_num )
	times_num = tonumber(times_num)
	local cost_gold = config_info.loseTimeBaseGold + config_info.loseTimeGrowGold * (times_num -1)
	if(cost_gold>config_info.loseTimeMaxGold)then
		cost_gold = config_info.loseTimeMaxGold
	end

	return cost_gold
end

-- 最大购买挑战次数
function getMaxBuyDefeatTimes()
	require "db/DB_Vip"
	local data = DB_Vip.getDataById(UserModel.getVipLevel()+1)
	return data.towerLoseTimeLimit
end

------------
-- 获取某一层的信息
function getTowerFloorDescBy( floor_num )
	return DB_Tower_layer.getDataById(floor_num)
end

-- 获取最高塔的层数
function getMaxTower()
	local nums = 0
	for k,v in pairs(DB_Tower_layer.Tower_layer) do
		nums = nums + 1
	end

	return nums
end

-- 获取金币重置的最大次数
function getMaxGoldBuyResetTimes()
	local reset_num = 0
	require "db/DB_Vip"
	local vipInfo = DB_Vip.getDataById(UserModel.getVipLevel() +1)
	if(vipInfo and vipInfo.towerCost)then
		local towerCostArr = string.split(vipInfo.towerCost, "|")
		reset_num = tonumber(towerCostArr[1])
	end
	return reset_num
end

-- 通关条件
function getPassFloorCondition(condition_num)
	local conditionStr = GetLocalizeStringBy("key_1089")
	if(condition_num)then
		local c_arr = string.split(condition_num, "|")
		if(not table.isEmpty(c_arr))then
			conditionStr = getPassFloorConditionStr(c_arr[1], c_arr[2])
		end
	end


	return conditionStr
end
-- 文字显示
function getPassFloorConditionStr( type, num )
	local t_str_arr = {}
	table.insert(t_str_arr, GetLocalizeStringBy("key_1581") .. num)
	table.insert(t_str_arr, GetLocalizeStringBy("key_3350") .. string.format("%.2f", num/10000)*100 .. "%")
	table.insert(t_str_arr, GetLocalizeStringBy("key_2240") .. num)
	table.insert(t_str_arr, GetLocalizeStringBy("key_1614") .. num)
	table.insert(t_str_arr, GetLocalizeStringBy("key_1230") .. num .. GetLocalizeStringBy("key_1920"))
	table.insert(t_str_arr, GetLocalizeStringBy("key_1230") .. num .. GetLocalizeStringBy("key_1083"))
	return t_str_arr[tonumber(type)]
end

-- show黑闪一下
function showBlackFadeLayer()
	local showLayer = CCLayerColor:create(ccc4(1,1,1,255))
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(showLayer, 2000)

	local function removeSelf ( ... )
	   	showLayer:removeFromParentAndCleanup(true)
	   	showLayer = nil
	end

	local actionArr = CCArray:create()
    actionArr:addObject(CCFadeOut:create(1))
    actionArr:addObject(CCCallFuncN:create(removeSelf))
    local actions = CCSequence:create(actionArr)
    showLayer:runAction(actions)
end

-- 获得怪的形象
function getFloorItem(m_type, m_potential, m_fileName, m_tittle)
	local file_bg = nil
	local file_icon = nil
	m_potential = tonumber(m_potential)
	local m_anchorPoint = nil
	local m_scaleY = nil
	-- 图片 
	local icon_sp = nil --
	local icon_sp_h = nil --CCSprite:create(file_icon)
	if(tonumber(m_type) == 1)then
		-- 副本小图
		file_bg = "images/copy/ncopy/fortpotential/" .. m_potential .. ".png"

		file_icon = "images/base/hero/head_icon/" .. m_fileName
		icon_sp = CCSprite:create(file_icon)
		icon_sp_h = CCSprite:create(file_icon)

		m_anchorPoint = ccp(0.5, 0.5)
		m_scaleY = 0.53
	else
		-- 战斗大图
		local bg_arr = {"tong_bg.png", "yin_bg.png", "jin_bg.png"}
		file_bg = "images/match/" .. bg_arr[m_potential]

		require "script/battle/BattleCardUtil"
		icon_sp = BattleCardUtil.getFormationPlayerCard(111111111,nil, m_fileName)
		icon_sp_h = BattleCardUtil.getFormationPlayerCard(111111111,nil, m_fileName)

		m_anchorPoint = ccp(0.5, 0)
		m_scaleY = 35/191
	end
	local normalSprite		= CCSprite:create(file_bg)
	local highlightedSprite = CCSprite:create(file_bg)
	

	icon_sp:setAnchorPoint(m_anchorPoint)
	icon_sp:setPosition(ccp(normalSprite:getContentSize().width * 0.5,  normalSprite:getContentSize().height *m_scaleY))
	normalSprite:addChild(icon_sp)

	icon_sp_h:setAnchorPoint(m_anchorPoint)
	icon_sp_h:setPosition(ccp(normalSprite:getContentSize().width * 0.5,  normalSprite:getContentSize().height *m_scaleY))
	highlightedSprite:addChild(icon_sp_h)
	highlightedSprite:setScale(0.95)

	-- 按钮
	local menuItem = LuaMenuItem.createItemSprite(normalSprite, highlightedSprite)
	local menuItemSize = menuItem:getContentSize()

	
	-- 文字
	local titleLabel = CCRenderLabel:create(m_tittle, g_sFontPangWa, 23, 1, ccc3( 0x00, 0x00, 0x00), type_stroke)
    titleLabel:setColor(ccc3(0xff, 0xff, 0xff))
    titleLabel:setAnchorPoint(ccp(0.5, 0))
    titleLabel:setPosition(ccp( menuItem:getContentSize().width/2 , menuItem:getContentSize().height))
    menuItem:addChild(titleLabel)

    return menuItem
end

