-- Filename: STSprite.lua
-- Author: bzx
-- Date: 2015-04-25
-- Purpose: 

STSprite = class("STSprite", function (...)
	local args = {...}
	local createName = args[1]
	table.remove(args, 1)
	local subnode = nil
	local spriteType = nil
	if createName == "createGraySprite" then
		subnode = BTGraySprite:create(unpack(args))
		spriteType = STSpriteType.GRAY
	elseif createName == "createGrayWithSprite" then
		subnode = BTGraySprite:createWithSprite(unpack(args))
		spriteType = STSpriteType.GRAY
	else
		subnode = CCSprite[createName](CCSprite, unpack(args))
		spriteType = STSpriteType.NORMAL
	end
	local ret = STNode:create()
	ret:setSubnode(subnode)
	ret._type = spriteType
	return ret
end)

ccs.combine(STNode, STSprite)

STSprite._isGray = false
STSprite._filename = nil
STSprite._type = nil

function STSprite:create(filename, rect)
	local ret = STSprite.new("create", filename, rect)
	ret._filename = filename
	return ret
end

function STSprite:createWithTexture( texture, rect )
	return STSprite.new("createWithTexture", texture, rect)
end

function STSprite:createWithSpriteFrame( spriteFrame )
	return STSprite.new("createWithSpriteFrame", spriteFrame)
end

function STSprite:createWithSpriteFrameName( spriteFrameName )
	return STSprite.new("createWithSpriteFrameName", spriteFrameName)
end

function STSprite:createGraySprite(filename)
	local ret = STSprite.new("createGraySprite", filename)
	ret._isGray = true
	return ret
end

function STSprite:createGrayWithSprite( sprite )
	local ret = STSprite.new("createGrayWithSprite", sprite)
	ret.isGray = true
	return ret
end

function STSprite:setFilename(filename)
	self._filename = filename
	local texture = CCTextureCache:sharedTextureCache():addImage(filename)
	local size = texture:getContentSize()
	local spriteFrame = CCSpriteFrame:create(filename, CCRect(0, 0, size.width, size.height))
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFrame(spriteFrame, filename)
	self:setDisplayFrame(spriteFrame)
end

function STSprite:setDisplayFrame( displayFrame )
	self._subnode:setDisplayFrame(displayFrame)
end

function STSprite:setGray(isGray)
	if self._isGray == isGray then
		return
	end
	if self._type == STSpriteType.NORMAL then
		local subnode = BTGraySprite:create(self._filename)
		self:setSubnode(subnode)
	else
		self._subnode:setGray(isGray)
	end
end