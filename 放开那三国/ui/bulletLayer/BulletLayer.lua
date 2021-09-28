-- Filename：	BulletLayer.lua
-- Author：		llp
-- Date：		2015-4-22
-- Purpose：		弹幕

module ("BulletLayer", package.seeall)
require "script/ui/main/BulletinData"
-- require "script/ui/bulletLayer/BulletUtil"
require "db/DB_Normal_config"

local _pLayer 				= nil
local _updateTimeScheduler  = nil

local index 				= 1
local _status 				= 0
local heightRandom 			= 1

local randomTable 			= {}

local color 				= ccc3( 0x00, 0xff, 0xff)

local function init()

	_pLayer 			 = nil
	_updateTimeScheduler = nil

	index 	 			 = 1
	_status 			 = 0
	heightRandom 		 = 1

	randomTable 		 = {}

	color 				 = ccc3( 0x00, 0xff, 0xff)
end
--随机高度
local heightTable = {
	0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7
}

function updateLabel( ... )
	-- body
	--获取聊天数据（msg,color,uid）
	if(table.count(randomTable)>=7)then
		return
	end
	local chatData = BulletinData.getBulletScreenData()

	if(table.isEmpty(chatData))then
		return
	end

	local actions1 = CCArray:create()
            actions1:addObject(CCDelayTime:create(1))
            actions1:addObject(CCCallFunc:create(function ( ... )
                	createLabelRandom(chatData[1])
                	BulletinData.deleteOneScreen(1)
            end))

    _pLayer:runAction(CCSequence:create(actions1))
end

function createLayer(  )
	init()

	_pLayer = CCLayerColor:create(ccc4(0,0,0,0))
	_pLayer:setContentSize(CCSizeMake(g_winSize.width,g_winSize.height))
	-- local node = CCNode:create()
	-- local actions1 = CCArray:create()
 --            actions1:addObject(CCDelayTime:create(1.5))
 --            actions1:addObject(CCCallFunc:create(function ( ... )
 --                	updateLabel()
 --            end))
 --    local sequence = CCSequence:create(actions1)
	-- local action = CCRepeatForever:create(sequence)
 --    node:runAction(action)
 --    _pLayer:addChild(node,1,775)
	-- _updateTimeScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateLabel, 1.5, false)

	return _pLayer
end

function closeLayer( ... )
	-- body
	BulletinData.releaseScreen()
	if(_pLayer~=nil)then
		local pChild = _pLayer:getChildByTag(heightRandom)
		if(pChild~=nil)then
			pChild:stopAllActions()
			pChild:removeFromParentAndCleanup(true)
			pChild = nil
		end
		local pNode = _pLayer:getChildByTag(775)
		if(pNode~=nil)then
			pNode:stopAllActions()
			pNode:removeFromParentAndCleanup(true)
			pNode = nil
		end
	    _pLayer:stopAllActions()
	    _pLayer:removeFromParentAndCleanup(true)
	    _pLayer = nil
	end

end
--根据数据创建随机位置的label
function createLabelRandom( labelData )
	-- body
	if(table.isEmpty(labelData))then
		return
	end

	local moveLabel = CCLabelTTF:create(labelData.msg,g_sFontName,28)
	local colorArray = string.split(labelData.color,",")
	moveLabel:setColor(ccc3(tonumber(colorArray[1]),tonumber(colorArray[2]),tonumber(colorArray[3])))
	heightRandom=BulletUtil.createRandomNum(randomTable)
	randomTable[heightRandom]=heightRandom
	local height = heightTable[heightRandom]*g_winSize.height

	local fullRect = CCRectMake(0,0,50,48)
	local insetRect = CCRectMake(25,24,10,8)
	local bg = CCScale9Sprite:create("images/bulletscreen/wenzikuang.png", fullRect, insetRect)

	local moveOverBgCallBack = function()
		if(bg~=nil)then
			randomTable[bg:getTag()]=nil
			bg:stopAllActions()
			bg:removeFromParentAndCleanup(true)
			bg = nil
		end
		updateLabel()
	end
	local moveOverLabelCallBack = function()
		-- body
		randomTable[moveLabel:getTag()]=nil
		moveLabel:stopAllActions()
		moveLabel:removeFromParentAndCleanup(true)
		moveLabel = nil
		updateLabel()
	end

	if(UserModel.getUserUid()==labelData.uid)then
		bg:setScale(g_fElementScaleRatio)
		_pLayer:addChild(bg,1,heightRandom)
		bg:setPosition(ccp(g_winSize.width,height))
		bg:setPreferredSize(CCSizeMake(moveLabel:getContentSize().width+40, moveLabel:getContentSize().height+18))
		moveLabel:setAnchorPoint(ccp(0.5,0.5))
		moveLabel:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5))
		bg:addChild(moveLabel)
		local moveTime = DB_Normal_config.getDataById(1).barrageTime/1000
		bg:runAction(CCSequence:createWithTwoActions(
		                   CCMoveTo:create(moveTime,ccp(-moveLabel:getContentSize().width,height)),
		                   CCCallFunc:create(moveOverBgCallBack)
		                   ))
	else
		_pLayer:addChild(moveLabel,1,heightRandom)
		moveLabel:setScale(g_fElementScaleRatio)
		moveLabel:setPosition(ccp(g_winSize.width,height))
		local moveTime = DB_Normal_config.getDataById(1).barrageTime/1000
		moveLabel:runAction(CCSequence:createWithTwoActions(
		                   CCMoveTo:create(moveTime,ccp(-moveLabel:getContentSize().width,height)),
		                   CCCallFunc:create(moveOverLabelCallBack)
		                   ))
	end
end

function showLayer( p_status,p_touch,p_zorder )
	-- body
	local runing_scene = CCDirector:sharedDirector():getRunningScene()
	if(runing_scene:getChildByTag(3241)~=nil)then
		return
	end
	local layer = createLayer()
	_status = p_status
    runing_scene:addChild(layer, 9500,3241)
end