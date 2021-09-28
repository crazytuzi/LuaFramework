-- Filename：	HorseSprite.lua
-- Author：		llp
-- Date：		2016-4-6
-- Purpose：		马车类
require "script/utils/extern"
require "script/utils/LuaUtil"
require "script/animation/AnimationXML"
local carTable = {"images/horse/car/green.png","images/horse/car/blue.png","images/horse/car/purple.png","images/horse/car/red.png"}
HorseSprite = class("HorseSprite", function ()
	local item = CCMenuItemImage:create()
	return item
end)

function HorseSprite:ctor( ... )
	self._data 				= {}
	self._guildname 		= nil
	self._targetSprite   	= nil
	self._callBack 		 	= nil
	self._pos		     	= ccp(0,0)
	self._leftLabel      	= nil
	self._startTime 	 	= nil
	self._startPos 		 	= 0
	self._endPos 		 	= 0
	self._totalTime 	 	= 0
end

function HorseSprite:create( pData )
	self._data = pData
	self.totalTime = pData.totalTime
	self.begin_time = pData.begin_time
	self.deltY = pData.deltY
	self.beginY = pData.beginY
	self.uid = pData.uid
    --马Item
	local horseSprite = HorseSprite:new()
	local horse = CCSprite:create(carTable[pData.zoneId])
		  horseSprite:setNormalSpriteFrame(horse:displayFrame())
		  horseSprite:setAnchorPoint(ccp(0.5,0))
		  horseSprite:setPosition(ccp(0,0))
		  horseSprite:setScale(g_fScaleX)
	local uid = UserModel.getUserUid()
	if(uid==self.uid)then
		local spellEffectSprite = CCLayerSprite:layerSpriteWithName(CCString:create("images/horse/muniuliumahuan/muniuliumahuan"), -1,CCString:create(""));
	    spellEffectSprite:retain()
	    spellEffectSprite:setPosition(horseSprite:getContentSize().width * 0.5, 40)
	    horseSprite:addChild(spellEffectSprite, -1);
	    spellEffectSprite:release()
	end
	--主角名
	local node = CCSprite:create()
	horseSprite:addChild(node)
	local horseName = CCRenderLabel:create(pData.uname.." ", g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
		  horseName:setAnchorPoint(ccp(0,0))
		  horseName:setPosition(ccp(0,0))
	node:addChild(horseName)
	--被抢次数
	local leftTimeLabel = CCRenderLabel:create("("..pData.leftStr..")", g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
		  leftTimeLabel:setAnchorPoint(ccp(0,0))
		  leftTimeLabel:setPosition(ccp(horseName:getContentSize().width,0))
	node:addChild(leftTimeLabel)
	node:setAnchorPoint(ccp(0.5,1))
	node:setContentSize(CCSizeMake(horseName:getContentSize().width+leftTimeLabel:getContentSize().width,leftTimeLabel:getContentSize().height))
	node:setPosition(ccp(horseSprite:getContentSize().width*0.5,0))
	self._leftLabel = leftTimeLabel
	--军团名
	if(pData.guildName~=nil)then
		local guildNameLabel = CCRenderLabel:create("["..pData.guildName.."]", g_sFontName, 20, 1, ccc3(0x00,0x00,0x00), type_shadow)
			  guildNameLabel:setAnchorPoint(ccp(0.5,1))
			  guildNameLabel:setColor(ccc3(0xff,0xf6,0x00))
			  guildNameLabel:setPosition(ccp(horseSprite:getContentSize().width*0.5,leftTimeLabel:getPositionY()-leftTimeLabel:getContentSize().height))
		horseSprite:addChild(guildNameLabel)
	end
	return horseSprite
end

function HorseSprite:fresh()
	-- body
	local uid = UserModel.getUserUid()
	local servTime = BTUtil:getSvrTimeInterval()
	local deltTime = (servTime-self.begin_time)/self.totalTime
	self:setPositionY(deltTime*self.deltY+self.beginY)
	local timeDelt = (servTime-self.begin_time)
	if(timeDelt>=tonumber(self.totalTime))then
		if(uid==self.uid)then
			local isHaveSelf = false
			HorseData.setHorseQuality(1)
			HorseData.setHaveSelf(isHaveSelf)
			local data = {}
		    data.have_charge_dart="false"
		    HorseLayer.createSelfHorseItem(data)
		end
		local runningScene = CCDirector:sharedDirector():getRunningScene()
		local layer = runningScene:getChildByTag(self.uid)
		if(layer~=nil)then
			layer:removeFromParentAndCleanup(true)
			layer = nil
		end
		HorseLayer.reduceHorseItemTable(self)
		self:removeFromParentAndCleanup(true)
		self = nil
	end
end

function HorseSprite:finishSelf()
	-- body
	local uid = UserModel.getUserUid()
	if(self.uid==uid)then
		HorseLayer.reduceHorseItemTable(self)
		HorseData.setHaveSelf("false")
		self:removeFromParentAndCleanup(true)
		self = nil
	end
end