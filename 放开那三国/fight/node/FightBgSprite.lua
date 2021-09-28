-- FileName: FightBgSprite.lua 
-- Author: lichenyang 
-- Date: 13-9-29 
-- Purpose: 战斗背景类

FightBgSprite = class("FightBgSprite",function ()
	return CCSprite:create()
end)

function FightBgSprite:ctor()
 	self._bgSpriteArray = {}
 	self._imageName = nil
 	self._pos = 0
end 


--[[
	@des:根据一个背景名称创建一个背景
	@parm:pBgImageName 背景图片名称
--]]
function FightBgSprite:create()
	local bgSprite = FightBgSprite:new()
	bgSprite._imageName = FightModel.getBgName()
	bgSprite:setContentSize(CCSizeMake(640, 0))
	bgSprite:updateBgImage()
	
	return  bgSprite
end
--[[
	@des:根据一个背景名称创建一个背景
	@parm:pBgImageName 背景图片名称
--]]
function FightBgSprite:createWithName(pBgImageName)
	local bgSprite = FightBgSprite:new()
	bgSprite._imageName = string.sub(pBgImageName,1,string.len(pBgImageName)-4)
	bgSprite:setContentSize(CCSizeMake(640, 0))
	bgSprite:updateBgImage()
	return  bgSprite
end

--[[
	@des:更新背景
--]]
function FightBgSprite:updateBgImage()
	self:removeAllChildrenWithCleanup(true)
	local bgPath = BattlePath.BG_PATH
	local i,mh = 0,0
	local imagePath = string.format("%s%s_%d.jpg",bgPath,self._imageName,i)
	imagePath = CCFileUtils:sharedFileUtils():fullPathForFilename(imagePath)
	print("imagePath:",imagePath)
	while CCFileUtils:sharedFileUtils():isFileExist(imagePath) do
		print("imagePath",imagePath)
		local sprite = CCSprite:create(imagePath)
		print("sprite", sprite)
		sprite:setAnchorPoint(ccp(0.5, 0))
		sprite:setPosition(ccp(320, mh))
		self:addChild(sprite)
		mh = mh + sprite:getContentSize().height
		i = i + 1
		imagePath = string.format("%s%s_%d.jpg",bgPath,self._imageName,i)
		imagePath = CCFileUtils:sharedFileUtils():fullPathForFilename(imagePath)
	end
	self:setContentSize(CCSizeMake(640, mh))
end

--[[
	@des:重新设置背景
--]]
function FightBgSprite:setBgName( pBgImageName )
	print("pBgImageName",pBgImageName)
	self._imageName = string.split(pBgImageName,".j")[1]
	print("self._imageName",self._imageName)
	self:updateBgImage()
	self._pos = 0
	self:setOffsetPos(self._pos)
end

--[[
	@des:前进到下一个部队
	@parm:p_callback 结束回调
--]]
function FightBgSprite:moveToNext( p_callback )
	local moveDistance = self:getMoveDistance()
	local actionArray = CCArray:create()
	actionArray:addObject(CCMoveBy:create(2.5,ccp(0, -moveDistance)))
	actionArray:addObject(CCCallFunc:create(p_callback))
	local ation = CCSequence:create(actionArray)
	self:runAction(ation)
	self._pos = self._pos + 1
end

--[[
	@des:得到移动距离
--]]
function FightBgSprite:getMoveDistance()
	local moveFar = (2400*g_fScaleX - g_winSize.height)
	local armyCount = 4
	return moveFar/armyCount
end

--[[
	@des:设置偏移
--]]
function FightBgSprite:setOffsetPos( pPos )
	local moveFar = self:getMoveDistance()
	self:setPosition(self:getPositionX(), -moveFar*pPos)
	self._pos = pPos
end
