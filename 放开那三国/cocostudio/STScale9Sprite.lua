-- Filename: STScale9Sprite.lua
-- Author: bzx
-- Date: 2015-04-24
-- Purpose: 

STScale9Sprite = class("STScale9Sprite", function ()
	local ret = STNode:create()
	return ret
end)

ccs.combine(STNode, STScale9Sprite)


function STScale9Sprite:create(file, capInsets)
	local texture = CCTextureCache:sharedTextureCache():addImage(file)
  	local size = texture:getContentSize()
 	local spriteFrame = CCSpriteFrame:createWithTexture(texture, CCRectMake(0, 0, size.width, size.height))
	if capInsets == nil then
		capInsets = CCRect(size.width * 0.5 - 1, size.height * 0.5 - 1, size.width * 0.5 + 1, size.height * 0.5 + 1)
	end
	local ret = STScale9Sprite.new()
	local subnode = CCScale9Sprite:createWithSpriteFrame(spriteFrame, capInsets)
	ret:setSubnode(subnode)
	return ret
end

function STScale9Sprite:setCapInsets( capInsets )
	self._subnode:setCapInsets(capInsets)
end