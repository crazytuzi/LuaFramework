-- Filename: RechargeFeedbackCache.lua
-- Author: ZQ
-- Date: 2014-01-09
-- Purpose: 解析和获取充值回馈数据

module("RechargeFeedbackCache",package.seeall)

require "db/DB_Recharge_back"
require "script/model/user/UserModel"

--[[
	/**
		 * 得到充值回馈信息
		 * @return array
		 * <code>
		 * array(
		 * gold_accum: num 累计充值的金币
		 * reward: array(id1, id2) 已经领取奖励的id
		 * )
		 * </code>
		 */
		public function getTopupFundInfo();
		
		/**
		 * 领取奖励
		 * @param unknown_type $id 奖励id( 由1开始 )
		 * <code>
		 *
		 * array(
		 * prizeSilver => 银币,
		 * prizeSoul => 将魂,
		 * prizeGold => 金币,
		 * prizeHeroArr => array( array( 模板id ，数量 ),array( 模板id ， 数量 )... )奖励卡牌
		 * prizeItemArr => array( array( 模板id ，数量 ),array( 模板id ， 数量 )... )奖励物品
		 *
		 * )
		 * </code>
		*/
		public function gainReward($id);
		
	}
	/* vim: set ts=4 sw=4 sts=4 tw=100 noet: */
	服务器数据拉取: PreRequest.lua => getRechargeFeedbackInfo()
	服务器数据获取
--]]
local _allFeedbackFormatData = {}
-- local _rechargeFeedbackInfo = {reward = {1,4,3},gold_accum = 6000}
local _rechargeFeedbackInfo = {}

function getRechargeFeedbackInfoFromSever(funcCb)
	local function setRechargeFeedbackInfoCb(cbFlag, dictData, bRet)
		if bRet == true then
			_rechargeFeedbackInfo = dictData.ret
			print("=======_rechargeFeedbackInfo begin========")
			print_t(dictData.ret)
			print("=======_rechargeFeedbackInfo end========")
			if funcCb ~= nil then
				funcCb()
			end
		end
	end

	require "script/network/Network"
	Network.rpc(setRechargeFeedbackInfoCb,"topupfund.getTopupFundInfo","topupfund.getTopupFundInfo",nil,true)
end

function setRechargeFeedbackInfo(rechargeFeedbackInfo)
	_rechargeFeedbackInfo = rechargeFeedbackInfo
end

function getRechargeFeedbackInfo()
	return _rechargeFeedbackInfo
end

--	获取实际累积充值的金币（不含返还金币）
function getTotalRechargeGoldNum()
	return _rechargeFeedbackInfo.gold_accum
end

--	获取已经领取的奖励id数组
function getFeedbackIdHasReceived()
	return _rechargeFeedbackInfo.reward
end

--	是否领取充值回馈奖励
--	true: 已经领取充值回馈奖励
function isFeedbackHasReceivedById(iId)
	local feedbackHasReceived = false
	if _rechargeFeedbackInfo.reward ~= nil then 
		print_t(_rechargeFeedbackInfo.reward)
		for _,v in pairs(_rechargeFeedbackInfo.reward) do
			if tonumber(v) == iId then
				feedbackHasReceived = true
				break
			end
		end
	end
	return feedbackHasReceived
end

--	获取已领取回馈奖励id中第一个不连续的数字
--	输入数组: 1,2,3,5,7,8,10 => 返回值: 3
--          2,3,4,5,7,8,9  => 返回值: 0
function getFirstDiscontinousFeedbackIdHasReceived()
	local total = #_allFeedbackFormatData
	assert(total >= 0)
	if total == 0 then return 0 end

	local num = 0
	for i = 1,total do
		if not isFeedbackHasReceivedById(i) then
			num = i - 1
			break
		end
	end
	return num
end

--[[
	充值回馈活动配置文件数据解析
--]]
require "script/model/utils/ActivityConfig"
function getFeedbackStartTime()
	return tonumber(ActivityConfig.ConfigCache.topupFund.start_time)
end

function getFeedbackEndTime()
	return tonumber(ActivityConfig.ConfigCache.topupFund.end_time)
end

function getFeedbackOpenTime()
	return tonumber(ActivityConfig.ConfigCache.topupFund.need_open_time)
end

-- 判断充值回馈是否开启 added by zhz 
function isFeedbackOpen( )
	
	if(not table.isEmpty(ActivityConfigUtil.getDataByKey("topupFund")) and not table.isEmpty(ActivityConfigUtil.getDataByKey("topupFund").data)) then
		if(ActivityConfigUtil.isActivityOpen("topupFund") ) then
			return true
		end
		return false
	end
end

-------------------------------被函数（getAllFeedback）替换 开始----------------------------
-- --	文件路径: DB/DB_Recharge_back.lua
-- --	DB:获取充值回馈活动配置文件中的活动数据
-- function getAllFeedback()
-- 	local allFeedback = {}
-- 	for _,v in pairs(DB_Recharge_back.Recharge_back) do
-- 		table.insert(allFeedback,DB_Recharge_back.getDataById(v[1]))
-- 	end

-- 	local function sortFunc(value1,value2)
-- 		return tonumber(value1.id) < tonumber(value2.id)
-- 	end
-- 	table.sort(allFeedback,sortFunc)
-- 	return allFeedback
-- end
-------------------------------被函数（getAllFeedback）替换 结束----------------------------
require "script/ui/tip/SingleTip"
function getAllFeedback()
	if table.isEmpty(ActivityConfig.ConfigCache.topupFund.data) then
		SingleTip.showSingleTip(GetLocalizeStringBy("key_1210"))
		return
	end
	--local allFeedback = ActivityConfig.ConfigCache.topupFund.data
	local allFeedback = {}

	for _,v in pairs(ActivityConfig.ConfigCache.topupFund.data) do
		table.insert(allFeedback,v)
	end

	local function sortFunc(value1,value2)
		return tonumber(value1.id) < tonumber(value2.id)
	end
	table.sort(allFeedback,sortFunc)
	return allFeedback
end

--	解析充值回馈奖励字符串
--	param :"1|0|10000,2|0|10000,3|0|100, ..."
--	return: table = {feedback_type1 = 1,
--	                 feedback_id1 = 0,
--	                 feedback_num1 = 10000,
--	                 feedback_type2 = 2,
--	                 ...
--	                 }
function getDataTableBySplitString(str)
	local dataTableTemp = {}
	local tableTemp = lua_string_split(str,",")
	local feedback_total_temp = 0
	for i,v in ipairs(tableTemp) do
		local tableTemp0 = lua_string_split(v,"|")
		dataTableTemp["feedback_type" .. i] = tonumber(tableTemp0[1])
		dataTableTemp["feedback_id" .. i] = tonumber(tableTemp0[2])
		--计算等级与奖励之积
		if tonumber(tableTemp0[1]) == 8 or tonumber(tableTemp0[1]) == 9 then
			dataTableTemp["feedback_num" .. i] = tonumber(tableTemp0[3]) * tonumber(UserModel.getHeroLevel())
		else
			dataTableTemp["feedback_num" .. i] = tonumber(tableTemp0[3])
		end
		feedback_total_temp = i
	end

	--	合并奖励 银币和银币*等级 将魂和将魂*等级
	local dataTable = {}
	local count = 1
	for i = 1,feedback_total_temp do
		if dataTableTemp["feedback_type" .. i] == 1 or dataTableTemp["feedback_type" .. i] == 8 then
			local notExist = true
			for j = 1,table.count(dataTable) do
				if dataTable["feedback_type" .. j] == 1 or dataTable["feedback_type" .. j] == 8 then
					dataTable["feedback_num" .. j] = dataTable["feedback_num" .. j] + dataTableTemp["feedback_num" .. i]
					notExist = false
				end
			end
			if notExist then
				dataTable["feedback_type" .. count] = dataTableTemp["feedback_type" .. i]
				dataTable["feedback_id" .. count] = dataTableTemp["feedback_id" .. i]
				dataTable["feedback_num" .. count] = dataTableTemp["feedback_num" .. i]
				count = count + 1
			end
		elseif dataTableTemp["feedback_type" .. i] == 2 or dataTableTemp["feedback_type" .. i] == 9 then
			local notExist = true
			for j = 1,table.count(dataTable) do
				if dataTable["feedback_type" .. j] == 2 or dataTable["feedback_type" .. j] == 9 then
					dataTable["feedback_num" .. j] = dataTable["feedback_num" .. j] + dataTableTemp["feedback_num" .. i]
					notExist = false
				end
			end
			if notExist then
				dataTable["feedback_type" .. count] = dataTableTemp["feedback_type" .. i]
				dataTable["feedback_id" .. count] = dataTableTemp["feedback_id" .. i]
				dataTable["feedback_num" .. count] = dataTableTemp["feedback_num" .. i]
				count = count + 1
			end
		else
			dataTable["feedback_type" .. count] = dataTableTemp["feedback_type" .. i]
			dataTable["feedback_id" .. count] = dataTableTemp["feedback_id" .. i]
			dataTable["feedback_num" .. count] = dataTableTemp["feedback_num" .. i]
			count = count + 1
		end
	end

	return dataTable,(count - 1)
end

--	解析充值回馈活动数据
function getAllFeedbackFormatData()
	local allFeedbackFormatData = {}
	local allFeedback = getAllFeedback()

	for i,v in ipairs(allFeedback) do
		local feedbackFormatData = {}
		feedbackFormatData.id = tonumber(v.id)
		feedbackFormatData.des = tostring(v.des)
		feedbackFormatData.expenseGold = tonumber(v.expenseGold)
		local tableTemp,total = getDataTableBySplitString(v.reward)
		for j,w in pairs(tableTemp) do
			feedbackFormatData[j] = w
		end
		feedbackFormatData.feedback_total = total
		table.insert(allFeedbackFormatData,feedbackFormatData)
	end

	_allFeedbackFormatData = allFeedbackFormatData
	return allFeedbackFormatData
end

--	获取充值回馈奖励的图标
--	1、银币		2、将魂		3、金币		4、体力		5、耐力		6、物品
--	7、多个物品	8、等级*银币	9、等级*将魂	10、英雄ID（单个英雄）		11、魂玉（新加）
--	12、声望（新加）			13、多个英雄（数量可大于1）
require "script/ui/item/ItemSprite"
require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicLua"
-- 查看物品信息返回回调 为了显示下排按钮
function showDownMenu( ... )
    MainScene.setMainSceneViewsVisible(true, false, false)
end
function getIconByTypeAndId(iType,iId,iNum)
	local icon = nil
	local bottomDesc = nil
	local quality = nil
	if iType == 1 then
		icon = ItemSprite.getSiliverIconSprite()
		bottomDesc = GetLocalizeStringBy("key_1687")
		quality = ItemSprite.getSilverQuality()
	elseif iType == 2 then
		icon = ItemSprite.getSoulIconSprite()
		bottomDesc = GetLocalizeStringBy("key_1616")
		quality = ItemSprite.getSoulQuality()
	elseif iType == 3 then
		icon = ItemSprite.getGoldIconSprite()
		bottomDesc = GetLocalizeStringBy("key_1491")
		quality = ItemSprite.getGoldQuality()
	elseif iType == 4 then
		icon = ItemSprite.getExecutionSprite()
		bottomDesc = GetLocalizeStringBy("key_1032")
		quality = ItemSprite.getExecutionQuality()
	elseif iType == 5 then
		icon = ItemSprite.getStaminaSprite()
		bottomDesc = GetLocalizeStringBy("key_2021")
		quality = ItemSprite.getStaminaQuality()
	elseif iType == 6 or iType == 7 or iType == 14 then
		--icon = ItemSprite.getItemSpriteById(iId,nil,itemDelegateAction,nil,-600,1000)
		icon = ItemSprite.getItemSpriteById(iId,nil,showDownMenu,nil,-130,nil,-430)
		local itemData = ItemUtil.getItemById(iId)
		--bottomDesc = GetLocalizeStringBy("key_1207")
		bottomDesc = ItemUtil.getItemNameByTid(iId)
		quality = itemData.quality
	elseif iType == 8 then
		icon = ItemSprite.getSiliverIconSprite()
		bottomDesc = GetLocalizeStringBy("key_1189")
		quality = ItemSprite.getSilverQuality()
	elseif iType == 9 then
		icon = ItemSprite.getSoulIconSprite()
		bottomDesc = GetLocalizeStringBy("key_1469")
		quality = ItemSprite.getSoulQuality()
	elseif iType == 10 or iType == 13 then
		icon = ItemSprite.getHeroIconItemByhtid(iId,-130,nil,-430)
		--bottomDesc = GetLocalizeStringBy("key_2100")
		require "db/DB_Heroes"
		local heroData = DB_Heroes.getDataById(iId)
		bottomDesc = heroData.name
		quality = heroData.star_lv
	elseif iType == 11 then
		icon = ItemSprite.getJewelSprite()
		bottomDesc = GetLocalizeStringBy("key_1510")
		quality = ItemSprite.getJewelQuality()
	elseif iType == 12 then
		icon = ItemSprite.getPrestigeSprite()
		bottomDesc = GetLocalizeStringBy("key_2231")
		quality = ItemSprite.getPrestigeQuality()
	else
	end

	if iNum ~= nil and iNum ~= 1 then
		local numLabel = nil
		if iType == 1 or iType == 8 then  -- modified by yangrui at 2015-12-03
			numLabel = CCRenderLabel:create(string.convertSilverUtilByInternational(iNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
		else
			numLabel = CCRenderLabel:create(tostring(iNum),g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
		end
		numLabel:setColor(ccc3(0x00,0xff,0x18))
		numLabel:setAnchorPoint(ccp(1,0))
		numLabel:setPosition(icon:getContentSize().width-3,3)
		icon:addChild(numLabel)
	end

	if bottomDesc ~= nil then
		local fontColor = ccc3(0xff,0xff,0xff)
		if quality then
			fontColor = HeroPublicLua.getCCColorByStarLevel(quality)
		end
		local bottomLabel = CCRenderLabel:create(bottomDesc,g_sFontName,18,1,ccc3(0x00,0x00,0x00),type_shadow)
		bottomLabel:setColor(fontColor)
		bottomLabel:setAnchorPoint(ccp(0.5,1))
		bottomLabel:setPosition(icon:getContentSize().width*0.5,-4)
		icon:addChild(bottomLabel)
	end

	return icon
end

function getFeedbackDataById(iId)
	return _allFeedbackFormatData[iId]
end

function intTypeToStringType(iType)
	local str = nil
	if iType == 1 or iType == 8 then
		str = "silver"
	elseif iType == 2 or iType == 9 then
		str = "soul"
	elseif iType == 3 then
		str = "gold"
	elseif iType == 4 then
		str = "execution"
	elseif iType == 5 then
		str = "stamina"
	elseif iType == 6 or iType == 7 or iType == 14 then
		str = "item"
	elseif iType == 10 or iType == 13 then
		str = "hero"
	elseif iType == 11 then
		str = "jewel"
	elseif iType == 12 then
		str = "prestige"
	else
	end
	return str
end

function getShowFeedbackFormatData(cellDataTable)
	local formatData = {}
	for i = 1,tonumber(cellDataTable.feedback_total) do
		local temp = {}
		temp.type = intTypeToStringType(tonumber(cellDataTable["feedback_type" .. i]))
		temp.num = tonumber(cellDataTable["feedback_num" .. i])
		temp.tid = tonumber(cellDataTable["feedback_id" .. i])
		table.insert(formatData, temp)
	end
	return formatData
end

--[[
	修改服务器中数据
--]]
--	增加服务器中的用户数据
function addUserServerData(funcCb,args)
	Network.rpc(funcCb,"topupfund.gainReward","topupfund.gainReward",args,true)
end

--	判断背包是否还能容纳充值回馈奖励
function canBagReceiveFeedback(cellDataTable)
	local isItem = false
	local index = nil
	for i = 1,tonumber(cellDataTable.feedback_total) do
		index = "feedback_type" .. i
		if tonumber(cellDataTable[index]) == 6 or tonumber(cellDataTable[index]) == 7 then
			isItem = true
			break
		end
	end
	require "script/ui/item/ItemUtil"
	if isItem and ItemUtil.isBagFull() then
		return false
	else
		return true
	end
end

--	判断携是否还能携带充值回馈奖励武将
function canCarryHero(cellDataTable)
	local isHero = false
	local index = nil
	for i = 1,tonumber(cellDataTable.feedback_total) do
		index = "feedback_type" .. i
		if tonumber(cellDataTable[index]) == 10 or tonumber(cellDataTable[index]) == 13 then
			isHero = true
			break
		end
	end
	require "script/ui/hero/HeroPublicUI"
	if isHero and HeroPublicUI.showHeroIsLimitedUI() then
		return false
	else
		return true
	end
end

function addIdIntoIdArrayHaveReceived(iId)
	table.insert(_rechargeFeedbackInfo.reward,iId)
end

function addUserLocalData(cellDataTable)
	local iType = nil
	local iNum = nil
	require "script/model/user/UserModel"
	for i = 1,tonumber(cellDataTable.feedback_total) do
		iType = tonumber(cellDataTable["feedback_type" .. i])
		iNum = tonumber(cellDataTable["feedback_num" .. i])
		if iType == 1 or iType == 8 then
			UserModel.addSilverNumber(iNum)
		elseif iType == 2 or iType == 9 then
			UserModel.addSoulNum(iNum)
		elseif iType == 3 then
			UserModel.addGoldNumber(iNum)
		elseif iType == 4 then
			UserModel.addEnergyValue(iNum)
		elseif iType == 5 then
			UserModel.addStaminaNumber(iNum)
		elseif iType == 6 or iType == 7 or iType == 14 then
			-- 不用这里处理（后端直接增加）
		elseif iType == 10 or iType == 13 then
			-- 不用这里处理
		elseif iType == 11 then
			UserModel.addJewelNum(iNum)
		elseif iType == 12 then
			UserModel.addPrestigeNum(iNum)
		else
		end
	end
end

