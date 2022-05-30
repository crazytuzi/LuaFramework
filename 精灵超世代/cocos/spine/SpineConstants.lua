if nil == sp then
    return
end

sp.EventType =
{
    ANIMATION_START = 0, 
    ANIMATION_END = 1, 
    ANIMATION_COMPLETE = 2, 
    ANIMATION_EVENT = 3,
}

--add by chenbin:spine 3.6版本支持
sp36.EventType =
{
    ANIMATION_START = 0,
	ANIMATION_INTERRUPT = 1,
	ANIMATION_END = 2,
	ANIMATION_COMPLETE = 3,
	ANIMATION_DISPOSE = 4,
	ANIMATION_EVENT = 5,
}

--让创建接口兼容3.4与3.6版本
local spRealCreater = sp.SkeletonAnimation.createWithBinaryFile
sp.SkeletonAnimation.createWithBinaryFile = function(self,skel_path, atlas_path, scale, pixelformal)
	local pos = string.find(skel_path, "spine/E")
	if not pos then pos = string.find(skel_path, "spine/H") end
	if pos then --3.4版本的spine放在这两个目录下
		return spRealCreater(self,skel_path, atlas_path, scale, pixelformal)
	else --其他的按照3.6版本处理
		self = sp36.SkeletonAnimation
		return sp36.SkeletonAnimation.createWithBinaryFile(self,skel_path, atlas_path, scale)
	end
end

--spine 3.4版本和3.6版本事件枚举值不一致，因此做以下转换
local spEventType2Sp36EventType = {
	[sp.EventType.ANIMATION_START] = sp36.EventType.ANIMATION_START,
	[sp.EventType.ANIMATION_END] = sp36.EventType.ANIMATION_END,
	[sp.EventType.ANIMATION_COMPLETE] = sp36.EventType.ANIMATION_COMPLETE,
	[sp.EventType.ANIMATION_EVENT] = sp36.EventType.ANIMATION_EVENT,
}
local realRegister = sp36.SkeletonAnimation.registerSpineEventHandler

sp36.SkeletonAnimation.registerSpineEventHandler = function(self,callback, eventType)
	-- print("WTF____registerSpineEventHandler___",eventType, spEventType2Sp36EventType[eventType])
	realRegister(self,callback, spEventType2Sp36EventType[eventType])
end


local spRealSetAnimation = sp.SkeletonAnimation.setAnimation

sp.SkeletonAnimation.setAnimation = function(self, trackIndex, name, loop)
	-- print("WTF__setAnimation____",name)
	-- print(debug.traceback())

	spRealSetAnimation(self, trackIndex, name, loop)
end

local sp36RealSetAnimation = sp36.SkeletonAnimation.setAnimation

--modified by chenbin:没必要调用此函数?
sp36.SkeletonAnimation.setToSetupPose = function() end

sp36.SkeletonAnimation.setAnimation = function(self, trackIndex, name, loop)
	name = BattleActionForPlayerAction[name] or name
	-- print("WTF__setAnimation____",name)
	-- print(debug.traceback())
	sp36RealSetAnimation(self, trackIndex, name, loop)
end