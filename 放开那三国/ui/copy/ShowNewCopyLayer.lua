-- Filename：	ShowNewCopyLayer.lua
-- Author：		Cheng Liang
-- Date：		2013-9-10
-- Purpose：		新副本开启

module("ShowNewCopyLayer", package.seeall)



local _bgLayer = nil

local function fnEndCallback( tipSprite )
	if(_bgLayer)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
	end
end 

function showNewCopy()
	if(_bgLayer)then
		
		return
	end
	copy_id = DataCache.getNewNormalCopyId()
	if(copy_id~=nil)then
		copy_id = tonumber(copy_id)
		DataCache.setNewNormalCopyId(nil)
	else
		return
	end
	_bgLayer = CCLayer:create()
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer,2000)
	
	--提示背景
	local tipSprite  = CCSprite:create("images/copy/newcopybg.png")
	-- 开启副本的名字
	local nameSprite = CCSprite:create("images/copy/newcopyopen.png")
	nameSprite:setAnchorPoint(ccp(0.5,1))
	nameSprite:setPosition(ccp(tipSprite:getContentSize().width*0.5, 30))
	tipSprite:addChild(nameSprite)

	-- 副本名称图片
	require "db/DB_Copy"
	local copyInfo = DB_Copy.getDataById(copy_id)
	local r_sprite = CCSprite:create("images/copy/ncopy/newnameimage/" .. copyInfo.copy_show_name)
	r_sprite:setAnchorPoint(ccp(0.5,0))
	r_sprite:setPosition(ccp(tipSprite:getContentSize().width*0.5, 60))
	tipSprite:addChild(r_sprite)
	_bgLayer:addChild(tipSprite)
	
	tipSprite:setAnchorPoint(ccp(0.5, 0.5))
	tipSprite:setPosition(ccp(_bgLayer:getContentSize().width , _bgLayer:getContentSize().height*0.5))

	local delayEndFunc = function ( )
		local actionArr = CCArray:create()
		actionArr:addObject(CCFadeOut:create(2.0))
		actionArr:addObject(CCCallFuncN:create(fnEndCallback))
		tipSprite:runAction(CCSequence:create(actionArr))
		nameSprite:runAction(CCFadeOut:create(2.0))
		r_sprite:runAction(CCFadeOut:create(2.0))
		-- _bgLayer:runAction(CCFadeOut:create(4.0))
	end

	local delayActionArr = CCArray:create()
	delayActionArr:addObject(CCMoveTo:create(0.1, ccp(_bgLayer:getContentSize().width/2 , _bgLayer:getContentSize().height/2)))
	delayActionArr:addObject(CCDelayTime:create(2.5))
	delayActionArr:addObject(CCCallFuncN:create(delayEndFunc))
	tipSprite:runAction(CCSequence:create(delayActionArr))
end
