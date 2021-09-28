-- Filename：	VIPNumTool.lua
-- Author：		Zhang zihang
-- Date：		2014-4-2
-- Purpose：		vip级别生成工具

module("VIPNumTool", package.seeall)

require "script/model/user/UserModel"

--vip级别工具
function getVIPNumSprite()
	local numSprite
	local vipLevel = UserModel.getVipLevel()
	if tonumber(vipLevel) < 10 then
		numSprite = CCSprite:create("images/recharge/vip_benefit/vipNO/" .. tostring(vipLevel) .. ".png")
	else
		local vipTen = math.floor(vipLevel/10)
		local numTen = CCSprite:create("images/recharge/vip_benefit/vipNO/" .. tostring(vipTen) .. ".png")
		local vipSingle = vipLevel - vipTen*10
		local numSingle = CCSprite:create("images/recharge/vip_benefit/vipNO/" .. tostring(vipSingle) .. ".png")
		
		require "script/ui/guild/GuildUtil"

		numSprite = BaseUI.createHorizontalNode({numTen,numSingle})
	end

	return numSprite
end

--vip奖励物品信息
function unpackGiftInfo()
	require "db/DB_Vipsalary"
	local vipLevel = UserModel.getVipLevel()
	local vipInfoTable = DB_Vipsalary.getDataById(tonumber(vipLevel))
	local rewardInfo = tostring(vipInfoTable.reward)
	local stringOneTable = string.split(rewardInfo,",")
	local RWTable = {}
	for i = 1,#stringOneTable do
		local singleRW = {}
		local stringTwoTable = string.split(stringOneTable[i],"|")
		singleRW.itemKind = stringTwoTable[1]
		singleRW.itemId = stringTwoTable[2]
		singleRW.itemNum = stringTwoTable[3]
		table.insert(RWTable,singleRW)
	end

	print("RWT")
	print_t(RWTable)
	return RWTable
end

--vip奖励详细分解后返回
function vipGiftDetial(singleReward)
	local playerLevel = UserModel.getHeroLevel()

	local rewardKind = tonumber(singleReward.itemKind)
	local rewardId = tonumber(singleReward.itemId)
	local rewardNum = tonumber(singleReward.itemNum)

	local RSprite
	local RNum
	local RName

	local returnTable = {}

	require "script/ui/item/ItemSprite"
	require "script/ui/item/ItemUtil"

	if rewardKind == 1 then
		--银币
		returnTable.type = "silver"
		RSprite = ItemSprite.getSiliverIconSprite()
		RName = GetLocalizeStringBy("key_1687")
	elseif rewardKind == 2 then
		--将魂
		returnTable.type = "soul"
		RSprite = ItemSprite.getSoulIconSprite()
		RName = GetLocalizeStringBy("key_1616")
	elseif rewardKind == 3 then
		--金币
		returnTable.type = "gold"
		RSprite = ItemSprite.getGoldIconSprite()
		RName = GetLocalizeStringBy("key_1491")
	elseif rewardKind == 4 then
		--体力
		returnTable.type = "execution"
		RSprite = ItemSprite.getExecutionSprite()
		RName = GetLocalizeStringBy("key_1032")
	elseif rewardKind == 5 then
		--耐力
		returnTable.type = "stamina"
		RSprite = ItemSprite.getStaminaSprite()
		RName = GetLocalizeStringBy("key_2021")
	elseif (rewardKind == 6) or (rewardKind == 7) or (rewardKind == 14) then
		--物品
		returnTable.type = "item"
		RSprite = ItemSprite.getItemSpriteById(rewardId)
		RName = tostring(ItemUtil.getItemById(rewardId).name)
	elseif rewardKind == 8 then
		--银币*等级
		returnTable.type = "silver"
		RSprite = ItemSprite.getSiliverIconSprite()
		RName = GetLocalizeStringBy("key_1687")
	elseif rewardKind == 9 then
		--将魂*等级
		returnTable.type = "soul"
		RSprite = ItemSprite.getSoulIconSprite()
		RName = GetLocalizeStringBy("key_1616")
	elseif (rewardKind == 10) or (rewardKind == 13) then
		--武将
		returnTable.type = "hero"
		require "db/DB_Heroes"
		local db_hero = DB_Heroes.getDataById(tonumber(rewardId))
		RSprite = ItemSprite.getHeroIconItemByhtid(rewardId)
		RName = tostring(db_hero.name)
	elseif rewardKind == 11 then
		--魂玉
		returnTable.type = "jewel"
		RSprite = ItemSprite.getJewelSprite()
		RName = GetLocalizeStringBy("key_1510")
	elseif rewardKind == 12 then
		--声望
		returnTable.type = "prestige"
		RSprite = ItemSprite.getPrestigeSprite()
		RName = GetLocalizeStringBy("key_2231")
	end

	if (rewardKind == 8) or (rewardKind == 9) then
		RNum = rewardNum*playerLevel
	else
		RNum = rewardNum
	end

	returnTable.num = RNum

	returnTable.tid = rewardId

	return RSprite,RNum,RName,returnTable
end
