-- Filename：	RewardMenuSprite.lua
-- Author：		LLP
-- Date：		2014-12-12
-- Purpose：		奖品menu


module("RewardMenuSprite", package.seeall)

require "script/ui/item/ItemSprite"
require "db/DB_Overcome_chest"

-- 按钮的Tag值
local Tag_One 		= 1
local Tag_Two 		= 2
local Tag_Three 	= 3
local Tag_Four 		= 4

-- 奖励回调
function bottomMenuAction( p_tag, p_itemBtn )
	require "script/audio/AudioUtil"
	AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
	if(tag == Tag_One)then
		-- OneItem

	elseif(tag == Tag_Two)then
		-- TwoItem

	elseif(tag == Tag_Three)then
		-- ThreeItem

    elseif(tag == Tag_Four)then
		-- FourItem

	end
end

--动画特效 我日一闪一闪亮晶晶
function getStarEffect( item )
	AudioUtil.playEffect("audio/effect/wupindakai.mp3")
	local godOpenEffect = CCLayerSprite:layerSpriteWithName(CCString:create("images/base/effect/god_copy/wupindakai/wupindakai"), 1,CCString:create(""));
	--增加动画监听
    local delegate = BTAnimationEventDelegate:create()
    delegate:registerLayerEndedHandler(function ( ... )
    	godOpenEffect:removeFromParentAndCleanup(true)
    	item:setScale(0.1)
    	item:setVisible(true)
    	local scale_1 = CCScaleTo:create(0.05, 1.1)
    	local scale_2 = CCScaleTo:create(0.05, 0.9)
    	local scale_3 = CCScaleTo:create(0.05, 1)

    	local array = CCArray:create()
    	array:addObject(scale_1)
	    array:addObject(scale_2)
	    array:addObject(scale_3)
	    local seq = CCSequence:create(array)
	    item:runAction(seq)

    end)
    godOpenEffect:setDelegate(delegate)
	return godOpenEffect
end

-- 创建奖励menu
function createRewardMenuSprite(p_data)
	local rewardMenuSprite = CCSprite:create()
	--奖励按钮
	local rewardItem = nil
	local rewardTable = {}
	for k,v in pairs(p_data)do
		rewardData = DB_Overcome_chest.getDataById(tonumber(v))
		table.insert(rewardTable,rewardData.RewardItem)
	end

	for i=1,table.count(rewardTable) do
		local rewardArrySp = ItemUtil.getItemsDataByStr(rewardTable[i])
		-- print(rewardArrySp.type.."rewardArrySp.type")
		-- print(rewardArrySp.num.."rewardArrySp.num")
		local userLevel = UserModel.getHeroLevel()
		rewardArrySp[1].num = rewardArrySp[1].num
		if(tostring(rewardArrySp[1].type)=="silver")then
			rewardArrySp[1].num = rewardArrySp[1].num
			UserModel.addSilverNumber(rewardArrySp[1].num)
		end
		local rewardArry = string.split(rewardTable[i], "|")

		rewardItem = ItemUtil.createGoodsIcon(rewardArrySp[1],-3000,nil,-3001)

		rewardMenuSprite:addChild(rewardItem,1,i)

		-- --下方奖励名称
		local rewardItemNameLabel = CCLabelTTF:create("1",g_sFontName,21)
		rewardItemNameLabel:setAnchorPoint(ccp(0.5,1))
		rewardItemNameLabel:setPosition(ccp(rewardItem:getContentSize().width*0.5,-10))
		rewardItem:addChild(rewardItemNameLabel,1,i)
		rewardItemNameLabel:setVisible(false)

		rewardItem:setVisible(false)

	end
	local itemWidth = rewardItem:getContentSize().width
	for i=Tag_One, Tag_One+table.count(rewardTable)-1 do
		rewardMenuSprite:getChildByTag(i):setAnchorPoint(ccp(0.5, 0.5))
		rewardMenuSprite:getChildByTag(i):setPosition(ccp(itemWidth*((i-1)*1.5 + 0.5),rewardMenuSprite:getChildByTag(i):getChildByTag(i):getContentSize().height))

		performCallfunc(function( ... )
			if( tolua.cast( rewardMenuSprite, "CCSprite" )  )then
				local m_item = rewardMenuSprite:getChildByTag(i)
				if( tolua.cast( m_item, "CCSprite" ) )then
					local starEffect = getStarEffect(rewardMenuSprite:getChildByTag(i))
					starEffect:setPosition(ccp( itemWidth*(((i-1)*1.5 + 0.5) ), rewardMenuSprite:getChildByTag(i):getChildByTag(i):getContentSize().height))
					rewardMenuSprite:addChild(starEffect,10)
				end
			end
		end, i*0.1 )

	end
	local spriteWidth = rewardMenuSprite:getChildByTag(table.count(rewardTable)):getPositionX()-rewardMenuSprite:getChildByTag(1):getPositionX()+rewardMenuSprite:getChildByTag(table.count(rewardTable)):getContentSize().width
	local labelWidth = rewardMenuSprite:getChildByTag(table.count(rewardTable)):getChildByTag(table.count(rewardTable)):getPositionX()-rewardMenuSprite:getChildByTag(1):getChildByTag(1):getPositionX()+rewardMenuSprite:getChildByTag(1):getChildByTag(1):getContentSize().width*0.5+rewardMenuSprite:getChildByTag(table.count(rewardTable)):getChildByTag(table.count(rewardTable)):getContentSize().width*0.5
	--图片大图片宽度作为node宽度 反之label宽度作为node宽度
	if(spriteWidth>labelWidth)then
		rewardMenuSprite:setContentSize(CCSizeMake(spriteWidth,rewardMenuSprite:getChildByTag(table.count(rewardTable)):getContentSize().height+10+rewardMenuSprite:getChildByTag(table.count(rewardTable)):getChildByTag(table.count(rewardTable)):getContentSize().height))
	else
		rewardMenuSprite:setContentSize(CCSizeMake(labelWidth,rewardMenuSprite:getChildByTag(table.count(rewardTable)):getContentSize().height+10+rewardMenuSprite:getChildByTag(table.count(rewardTable)):getChildByTag(table.count(rewardTable)):getContentSize().height))
	end


	return rewardMenuSprite
end
