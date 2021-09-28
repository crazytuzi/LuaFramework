--------------------------------------------------------------------------------------
-- 文件名:	ResourcePack.lua.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:
-- 日  期:
-- 版  本:
-- 描  述:	管理plist
-- 应  用:  
---------------------------------------------------------------------------------------

ResourcePack = class("ResourcePack")
ResourcePack.__index = ResourcePack

function ResourcePack:ctor()
	self.TabReSource = {}

	--暂时关闭
    self.Game_ResourcePack = false
end

function ResourcePack:Init()
	if not self.Game_ResourcePack then return end

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common0.plist","ResourcePack/Common0.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common1.plist","ResourcePack/Common1.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common2.plist","ResourcePack/Common2.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common3.plist","ResourcePack/Common3.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common4.plist","ResourcePack/Common4.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common5.plist","ResourcePack/Common5.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Common6.plist","ResourcePack/Common6.png")
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile("ResourcePack/Dialogue0.plist","ResourcePack/Dialogue0.png")
end

function ResourcePack:LoaderResource(filename)
	if self.Game_ResourcePack == false then return end
	
	local plistname = "ResourcePack/"..filename..".plist"
	local pPngname = "ResourcePack/"..filename..".png"
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plistname, pPngname)
	cclog("ResourcePack:LoaderResource ----> "..plistname)
end

function ResourcePack:DeleteResource(filename)
	if self.Game_ResourcePack == false then return end

	local plistname = "ResourcePack/"..filename..".plist"
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(plistname)
	cclog("ResourcePack:DeleteResource ----> "..plistname)
end

g_ResourcePack = ResourcePack.new()
g_ResourcePack:Init()

