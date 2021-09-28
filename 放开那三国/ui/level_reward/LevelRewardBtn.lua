-- Filename: LevelRewardBtn.lua
-- Author: zhz
-- Date: 2013-8-30
-- Purpose: 该文件用于: 等级礼包按钮的创建

module ("LevelRewardBtn", package.seeall)

require "script/ui/level_reward/LevelRewardLayer"
require "script/model/DataCache"
require "script/audio/AudioUtil"
require "script/ui/level_reward/LevelRewardUtil"
require "script/utils/ItemDropUtil"

local IMG_PATH = "images/level_reward/"
local _levelRewardBtn
local _effect=nil
local _tipSprite= nil
local _ksTipTag= 101			-- 提示有X个奖励

local function init( ... )
	_levelRewardBtn= nil
	_effect = nil
	_tipSprite = nil
end


local levelRewardBtnCallback = nil

 function levelRewardBtnCb(tag, itemBtn)
 	if(levelRewardBtnCallback ~= nil)then
 		levelRewardBtnCallback()
 	end

 	---[==[等级礼包新手引导屏蔽层
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/guide/NewGuide"
		if(NewGuide.guideClass == ksGuideFiveLevelGift) then
			require "script/guide/LevelGiftBagGuide"
			LevelGiftBagGuide.changLayer()
		end
		---------------------end-------------------------------------
	--]==]
	local canEnter = DataCache.getSwitchNodeState(ksSwitchLevelGift)
	if(canEnter) then 
		-- 调用签到界面函数
		AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
		LevelRewardLayer.createLevelRewardLayer()
	else
		return
	end

	

	---[==[ 第二步等级礼包领取按钮
		---------------------新手引导---------------------------------
		--add by licong 2013.09.09
		require "script/ui/level_reward/LevelRewardLayer"
		local didCreateTableView = function ( ... )
		    require "script/guide/NewGuide"
			print("g_guideClass = ", NewGuide.guideClass)
		    require "script/guide/LevelGiftBagGuide"
		    if(NewGuide.guideClass ==  ksGuideFiveLevelGift and LevelGiftBagGuide.stepNum == 1) then
		        local levelGiftBagGuide_button = LevelRewardLayer.getReceiveBtn(0)
		        local touchRect = getSpriteScreenRect(levelGiftBagGuide_button)
		        LevelGiftBagGuide.show(2, touchRect)
		    end
		end
		LevelRewardLayer.registerDidTableViewCallBack(didCreateTableView)
		---------------------end-------------------------------------
	--]==]
end

function getReardBtn( )
	return _levelRewardBtn
end


function createLevelRewardBtn(bglayer)
 	init()

 	if( isReceivedAll() ) then 
 		print( "sReceivedAll()", isReceivedAll)
		return 
	end

 	local bgSize = bglayer:getContentSize()
 	local menu = CCMenu:create()
 	menu:setPosition(ccp(0,0))
 	bglayer:addChild(menu)
 	local boolEffect  =LevelRewardUtil.boolReceived()

 	_levelRewardBtn = CCMenuItemImage:create(IMG_PATH .. "level_reward_n.png", IMG_PATH .. "level_reward_h.png")
 	_levelRewardBtn:setAnchorPoint(ccp(0, 0))
 	_levelRewardBtn:setPosition(ccp(0, 0))
 	menu:addChild(_levelRewardBtn)
 	_levelRewardBtn:registerScriptTapHandler(levelRewardBtnCb)
 	levelEffect()
 end

function isShow()
	if not tolua.isnull(_levelRewardBtn) then
		if _levelRewardBtn:isVisible() then
			return true
		end
	end
	return false
end



-- 获得特效
function levelEffect( )
	local boolEffect , canReceiveNum =LevelRewardUtil.boolReceived()
	
	-- 特效
	if(_effect ~= nil) then
		_effect:removeFromParentAndCleanup(true)
		_effect = nil
		-- _tipSprite:removeFromParentAndCleanup(true)
		_tipSprite:setVisible(false)
	end


	_tipSprite=ItemDropUtil.getTipSpriteByNum(canReceiveNum) --CCSprite:create("images/common/tip_1.png")
	_tipSprite:setPosition(ccp(_levelRewardBtn:getContentSize().width*0.97, _levelRewardBtn:getContentSize().height*0.98))
	_tipSprite:setAnchorPoint(ccp(1,1))
	_tipSprite:setVisible(false)
	_levelRewardBtn:addChild(_tipSprite,11)

	-- local numLabel = CCLabelTTF:create("" .. canReceiveNum ,g_sFontName, 21)
	-- -- numLabel:setColor()
	-- numLabel:setPosition(ccp(_tipSprite:getContentSize().width/2-3,_tipSprite:getContentSize().height/2+3))
	-- numLabel:setAnchorPoint(ccp(0.5,0.5))
	-- _tipSprite:addChild(numLabel,1,_ksTipTag)
	
	if(boolEffect == true ) then
		local img_path = CCString:create("images/level_reward/dengjilibao/dengjilibao") 
		_effect =  CCLayerSprite:layerSpriteWithName(img_path, -1,CCString:create(""))
		-- 适配
		_effect:setPosition(ccp(_levelRewardBtn:getContentSize().width*0.5,_levelRewardBtn:getContentSize().height*0.5))
		_effect:setAnchorPoint(ccp(0.5,0.5))
		_tipSprite:setVisible(true)
		_effect:setFPS_interval(1/60.0)
		_levelRewardBtn:addChild(_effect,1)
	end
end

-- 判断是否可以释放特效
function releaseEffect( )

	local boolEffect , canReceiveNum =LevelRewardUtil.boolReceived()
	if(boolEffect== false and _effect ~= nil) then
		_effect:removeFromParentAndCleanup(true)
		_effect = nil
		-- _tipSprite:removeFromParentAndCleanup(true)
		_tipSprite:setVisible(false)
	else
		-- local numLabel= tolua.cast(_tipSprite:getChildByTag(_ksTipTag), "CCLabelTTF") 
		-- numLabel:setString("" .. canReceiveNum)
		ItemDropUtil.refreshNum(_tipSprite,canReceiveNum)
	end
end

-- 判断是否已经领完 
function isReceivedAll( )
	require "db/DB_Level_reward"
	 if(table.count(LevelRewardUtil.getRewardInfo())== table.count(DB_Level_reward.Level_reward) ) then 
		return true
	else
		return false
	end
	
end

-- 释放按钮
function releaseBtn( )
	if(_levelRewardBtn~= nil) then
		_levelRewardBtn:removeFromParentAndCleanup(true)
		_levelRewardBtn= nil
	end
end

 --add by lichenyang

 function registerLevelRewardBtnCallback( p_callback )
 	levelRewardBtnCallback = p_callback
 end







