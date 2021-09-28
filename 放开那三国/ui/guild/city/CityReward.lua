-- FileName: CityReward.lua 
-- Author: licong 
-- Date: 14-4-26 
-- Purpose: 城池宝箱奖励


module("CityReward", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/guild/city/CityData"
require "script/ui/guild/city/CityService"

local _thisCityID 			= nil
local retSprite 			= nil

-- 网络请求回调
function serviceCallFunc( dataRet )
	-- 领奖成功 删除宝箱
	if(retSprite)then
		retSprite:removeFromParentAndCleanup(true)
		retSprite = nil
	end

	-- 前端 计算奖励
	-- 得到自己职位的奖励系数
	-- local data = GuildDataCache.getMineSigleGuildInfo()
	print(GetLocalizeStringBy("key_3182"))
	print_t(dataRet)
	print(dataRet.member_type)
	local xiShu = CityData.getXiShuByMemberType(dataRet.member_type)
	-- 表配置奖励数据
	local thisCityBaseData = CityData.getDataById(_thisCityID)
	local rewardData = ItemUtil.getItemsDataByStr( thisCityBaseData.baseReward )
	for k,v in pairs(rewardData) do
		-- 真实数据 表配置基础值*系数 向下取整
		v.num = math.floor(v.num * xiShu)
	end
	-- 修改本地数据 加奖励
	print("rewardData")
	print_t(rewardData)
	ItemUtil.addRewardByTable(rewardData)

	-- 展现领取奖励列表
 	require "script/ui/item/ReceiveReward"
    ReceiveReward.showRewardWindow( rewardData, nil , 1001, -455 )

    -- 领完奖励后修改数据
    CityData.setHaveReward()
end


-- box action 
function boxItemCallFun( )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	-- 背包判断
	if(ItemUtil.isBagFull() == true )then
		return
	end
	-- 网络请求
	CityService.getReward( _thisCityID, serviceCallFunc)
end


-- 创建宝箱
function createBoxReward( city_id )
	_thisCityID = city_id

	-- 返回空sp
	local btnSize = CCSizeMake(80,80)
	retSprite = CCScale9Sprite:create("images/common/transparent.png")
	retSprite:setContentSize(btnSize)
	-- 空按钮
	local boxMenu = CCMenu:create()
	boxMenu:setPosition(ccp(0,0))
	boxMenu:setTouchPriority(-440)
	retSprite:addChild(boxMenu)
	local sprite1 = CCScale9Sprite:create("images/common/transparent.png")
	sprite1:setContentSize(btnSize)
	local sprite2 = CCScale9Sprite:create("images/common/transparent.png")
	sprite2:setContentSize(btnSize)
	local boxItem = CCMenuItemSprite:create(sprite1, sprite2)
	boxItem:setPosition(0, 0)
	boxItem:setAnchorPoint(ccp(0, 0))
	boxItem:registerScriptTapHandler(boxItemCallFun)
	boxMenu:addChild(boxItem)
	-- 特效
	local boxAnimSprite = CCLayerSprite:layerSpriteWithNameAndCount("images/base/effect/xuanzhuanbaoxiang/xuanzhuanbaoxiang", -1,CCString:create(""))
	boxAnimSprite:setAnchorPoint(ccp(0,0))
	boxAnimSprite:setPosition(ccp(boxItem:getContentSize().width/2,boxItem:getContentSize().height/2))
	boxItem:addChild(boxAnimSprite)

	return retSprite
end
























































