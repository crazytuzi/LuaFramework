--
-- Author: MiYu
-- Date: 2014-02-12 11:33:35
--



function TFDirector:description(...)

end

--[[
	清除movieClip缓存
]]
function TFDirector:clearMovieClipCache()
	me.MCManager:clear()
end

--[[
	清除未使用的SpriteFrame缓存
]]
function TFDirector:removeUnusedSpriteFrames()
	me.FrameCache:removeUnusedSpriteFrames()
end

--[[
	清除所有SpriteFrame缓存
]]
function TFDirector:removeSpriteFrames()
	me.FrameCache:removeSpriteFrames()
end

--[[
	清除未使用的纹理缓存
]]
function TFDirector:removeUnusedTextures()
	me.TextureCache:removeUnusedTextures()
end

--[[
	清除所有纹理缓存
]]
function TFDirector:removeAllTextures()
	me.TextureCache:removeAllTextures()
end