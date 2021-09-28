-- FileName: AchieTip.lua
-- Author: LLP
-- Date: 14-5-14
-- Purpose: function description of module


module("AchieTip", package.seeall)

require "script/ui/item/ItemUtil"
require "script/ui/hero/HeroPublicUI"
require "db/DB_Achie_table"

local dataCpy = nil
local itemCpy = nil
local tagCpy  = 0
local tagKey = 0
local jKey = 0
local Key = 0
function createCell( number)
	local achieData= DB_Achie_table.getDataById(number)
	local tcellData = achieData
	local cell = CCNode:create()
	cell:setAnchorPoint(ccp(0.5,0))
	print_t(tcellData)
	local iconSpriteBg1 = CCSprite:create("images/everyday/headBg1.png")
	-- 背景
	local fullRect = CCRectMake(0,0,400,97)
	local insetRect = CCRectMake(50,43,16,6)
	local cellBg = CCScale9Sprite:create("images/achie/achiebg.png",fullRect, insetRect)
	cellBg:setContentSize(CCSizeMake(500,117))
	cellBg:setAnchorPoint(ccp(0.5,0))
	cellBg:setPosition(ccp(0,0))

	-- 图标
	iconSpriteBg1:setAnchorPoint(ccp(0,0.5))
	iconSpriteBg1:setPosition(ccp(0,cellBg:getContentSize().height*0.5))
	cellBg:addChild(iconSpriteBg1)
	-- 图标底
	local iconSpriteBg2 = CCSprite:create("images/base/potential/props_" .. tcellData.achie_quality .. ".png")
	iconSpriteBg2:setAnchorPoint(ccp(0.5,0.5))
	iconSpriteBg2:setPosition(ccp(iconSpriteBg1:getContentSize().width*0.5,iconSpriteBg1:getContentSize().height*0.5))
	iconSpriteBg1:addChild(iconSpriteBg2)

	--发光底
	local shineSprite = CCSprite:create("images/achie/00.png")
	iconSpriteBg2:addChild(shineSprite)
	shineSprite:setAnchorPoint(ccp(0.5,0.5))
	shineSprite:setPosition(ccp(iconSpriteBg2:getContentSize().width*0.5,iconSpriteBg2:getContentSize().height*0.5))

	-- 真正的图标
	local iconSprite = CCSprite:create("images/achie/".. tcellData.achie_icon)
	iconSprite:setAnchorPoint(ccp(0.5,0.5))
	iconSprite:setPosition(ccp(iconSpriteBg2:getContentSize().width*0.5,iconSpriteBg2:getContentSize().height*0.5))
	iconSpriteBg2:addChild(iconSprite)

	-- 名字背景
	local nameBg = CCScale9Sprite:create("images/common/bg/9s_5.png")
	nameBg:setContentSize(CCSizeMake(282,33))
	nameBg:setAnchorPoint(ccp(0,1))
	nameBg:setPosition(ccp(125,cellBg:getContentSize().height-10))
	cellBg:addChild(nameBg)
	-- 名字 进度
	local str = tcellData.achie_name or GetLocalizeStringBy("key_10001")
	local name_font = CCLabelTTF:create(str,g_sFontPangWa,24)
 	name_font:setColor(ccc3(0x00,0xe4,0xff))
 	name_font:setAnchorPoint(ccp(0,0.5))
 	name_font:setPosition(ccp(14,nameBg:getContentSize().height*0.5))
 	nameBg:addChild(name_font)
 	-- 任务描述
 	local str = tcellData.achie_des or GetLocalizeStringBy("key_10001")
 	local taskDes = CCLabelTTF:create(str,g_sFontName,23)
 	taskDes:setColor(ccc3(0x00,0xff,0x18))
 	taskDes:setAnchorPoint(ccp(0,1))
 	taskDes:setPosition(ccp(135,cellBg:getContentSize().height-55))
 	cellBg:addChild(taskDes)
 	-- 获得的积分
 	local scoreBg = CCSprite:create("images/everyday/score_bg.png")
 	scoreBg:setAnchorPoint(ccp(0,0))
 	scoreBg:setPosition(ccp(135,0))
 	cellBg:addChild(scoreBg)
 	local str = GetLocalizeStringBy("zzh_1246")
 	local hude_font = CCLabelTTF:create(str,g_sFontPangWa,21)
 	hude_font:setColor(ccc3(0xff,0xe4,0x00))
 	hude_font:setAnchorPoint(ccp(0,0.5))
 	hude_font:setPosition(ccp(25,scoreBg:getContentSize().height*0.5))
 	scoreBg:addChild(hude_font)


 	local rewardNode = ItemUtil.getNodeByStr(tcellData.achie_reward,true)

 	hude_font:addChild(rewardNode)
 	rewardNode:setAnchorPoint(ccp(0,0))
 	rewardNode:setPosition(ccp(hude_font:getContentSize().width,0))

 --  	local img_path = CCString:create("images/base/effect/star/achieve/chengjiukuang")
	-- local addAchieveEffect = CCLayerSprite:layerSpriteWithNameAndCount(img_path:getCString(), 1,CCString:create(""))
	-- addAchieveEffect:setScale(g_fBgScaleRatio)

	-- icon
	-- local replaceXmlSprite_1 = tolua.cast( addAchieveEffect:getChildByTag(1003) , "CCXMLSprite")

 --    local img_path_2 = CCString:create("images/base/effect/star/lineRotation/lineRotation")
	-- local addAchieveEffect_2 = CCLayerSprite:layerSpriteWithNameAndCount(img_path_2:getCString(), -1,CCString:create(""))
	-- addAchieveEffect_2:setPosition(ccp(60, 60))
	-- replaceXmlSprite_1:addChild(addAchieveEffect_2)
	-- replaceXmlSprite_1:addChild(cellBg,1000)


	local runing_scene = CCDirector:sharedDirector():getRunningScene()
	runing_scene:addChild(cellBg,10000)
	-- cellBg:setPosition(ccp(g_winSize.width*0.5,g_winSize.height*0.6))
	cellBg:setPosition(ccp(g_winSize.width*1.5,g_winSize.height*0.6))

	local actionArray = CCArray:create()
		actionArray:addObject(CCMoveTo:create(0.5,ccp(g_winSize.width*0.5,g_winSize.height*0.6)))
		actionArray:addObject(CCDelayTime:create(3))
		actionArray:addObject(CCCallFuncN:create(function ( pNode )
	    	cellBg:removeFromParentAndCleanup(true)
	    end))
	cellBg:runAction(CCSequence:create(actionArray))
	-- local animationEnd = function(actionName,xmlSprite)
 --        addAchieveEffect:removeFromParentAndCleanup(true)
 --    end
 --    -- 每次回调
 --    local animationFrameChanged = function(frameIndex,xmlSprite)

 --    end

 --    --增加动画监听
 --    local delegate = BTAnimationEventDelegate:create()
 --    delegate:registerLayerEndedHandler(animationEnd)
 --    delegate:registerLayerChangedHandler(animationFrameChanged)
 --    addAchieveEffect:setDelegate(delegate)

	-- return cell
end

function showRewardById( achieId )

	require "db/DB_Achie_table"
	require "script/ui/item/ItemUtil"
	require "script/ui/item/ReceiveReward"

	local achieData= DB_Achie_table.getDataById(tonumber(achieId))
	local achie_reward = ItemUtil.getItemsDataByStr( achieData.achie_reward)
    ReceiveReward.showRewardWindow( achie_reward, nil , 10008, -800 )
    ItemUtil.addRewardByTable(achie_reward)
end


























