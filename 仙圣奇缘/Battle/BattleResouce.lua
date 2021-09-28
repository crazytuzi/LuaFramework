--------------------------------------------------------------------------------------
-- 文件名:	BattleResouce.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	战斗结束后清理特效资源 
-- 应  用:  此模块只在战斗里面加载
---------------------------------------------------------------------------------------

BattleResouce = class("BattleResouce")
BattleResouce.__index = BattleResouce


function BattleResouce:ctor()
	--
	self.tbPlistFile = {}

	self.tbSpineFile = {}

	self.tbAnimation = {}
end


function BattleResouce:LoadSpineFile(filename)

	local spine = nil

	if not self.tbSpineFile[filename] then
		local szJson = nil
		local szAtlas = nil
		if g_Cfg.Platform == kTargetWindows then
			 szJson = string.format("Effect_IOS/SkillSpine/%s.json", filename)
			 szAtlas = string.format("Effect_IOS/SkillSpine/%s.atlas", filename)
		else
			 szJson = string.format("Effect_IOS/SkillSpine/%s.json", filename)
			 szAtlas = string.format("Effect_IOS/SkillSpine/%s.atlas", filename)
		end

		spine = SkeletonAnimation:createWithFile(szJson, szAtlas, 1)

		self.tbSpineFile[filename] = spine
		self.tbSpineFile[filename]:retain()
		self.tbSpineFile[filename]:setVisible(false)
	end

	spine = self.tbSpineFile[filename]:clone()

	return spine
end

--[[
cocos 的CCArmatureDataManager 有缓存animation的json数据
而且 在c++里面重复调用addArmatureFileInfo 是不会重复加载
所以 这里只要维护animation的生存周期
]]
local function preLoadResouceCallBack(percent)
	cclog(percent.."preLoadResouceCallBack"..API_GetCurrentTime() /1000)
end

function BattleResouce:LoadAnimationFile(filepath, filename)
	if not self.tbAnimation[filepath] then

		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(filepath)

		self.tbAnimation[filepath] = filepath
	end

	local tpArmature = nil
	if filename then
		tpArmature = CCArmature:create(filename)
	end
	return tpArmature
end

--CCParticleSystemQuad 还没有缓存的机制
function BattleResouce:LoadParticleFile(filename)

end


function BattleResouce:ReleaseCach()
	for k, key in pairs(self.tbAnimation)do
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(key)
	end
	self.tbAnimation = {}

	for k, v in pairs(self.tbSpineFile)do
		v:release()
	end
	self.tbSpineFile = {}

end

g_BattleResouce = BattleResouce.new()