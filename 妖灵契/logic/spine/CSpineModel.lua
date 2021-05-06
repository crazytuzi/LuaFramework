--[[例子
--在0通道, 立即播放动画anim1, 不循环，并且立即执行funStart, 动画完成后执行funComplete1
--SetAnimation(0, "anim1", false, funStart1, funComplete1); 
--在0通道, 添加动画anim2会在anim1播发完后播放, 不循环，并且在播发动画前执行funStart2, 动画完成后执行funComplete2, 
--AddAnimation(0, "anim2", false, funStart2, funComplete2)
--在0通道, 添加动画anim3会在anim2播发完后播放, 不循环，并且在播发动画前执行funStart3, 动画完成后执行funComplete3, 
--AddAnimation(0, "anim3", true,  funStart3, funComplete3)
--最后会循环播放anim3
function CTestView.OnTest10(self) 有例子
]]

local CSpineModel = class("CSpineModel", CObject)

function CSpineModel.ctor(self, obj)
	CObject.ctor(self, obj)
	CGameObjContainer.ctor(self, obj)
	self.m_SpineHandler = self:GetMissingComponent(classtype.SpineHandler)
	self.m_Delegate = nil
	self.m_AnimationCallBackDic = {}
end

function CSpineModel.InitAnimationDelegate(self, iTrackIndex, sAnimationName)
	self:CheckSpineHandler()
	if not self.m_Delegate then
		self.m_Delegate = g_DelegateCtrl:NewDelegate(callback(self, "OnAnimationCallBack"))
		self.m_SpineHandler:SetEventID(self.m_Delegate:GetID())
	end
end

function CSpineModel.AddAnimationEvent(self, sEvent, key, func)
	self:InitAnimationDelegate()
	local iEvent = enum.SpineAnimationEvent[sEvent]
	self.m_AnimationCallBackDic[key] = func
end

function CSpineModel.OnAnimationCallBack(self, iEvent, key, ...)
	--printc(iEvent, key, ...)
	local func = self.m_AnimationCallBackDic[key]
	if func then
		local ret = func(self, ...)
		if ret == false then
			self.m_AnimationCallBackDic[key] = nil
		end
		return ret		
	end
end

function CSpineModel.CheckSpineHandler(self)
	if not self.m_SpineHandler then
		self.m_SpineHandler = self:GetMissingComponent(classtype.SpineHandler)
	end
	return self.m_SpineHandler
end

function CSpineModel.SetFlipX(self, bFlipX)
	--printc("设置动画翻转FlipX:", bFlipX)
	if self:CheckSpineHandler() then
   		self.m_SpineHandler:SetFlipX(bFlipX)
   	end
end

function CSpineModel.SetFlipY(self, bFlipY)
	--printc("设置动画翻转FlipY:", bFlipY)
	if self:CheckSpineHandler() then
    	self.m_SpineHandler:SetFlipY(bFlipY)
    end
end

--iTrackIndex(通道,可以在同一时间播发几个spine动画)
--funStart会立即执行
--funComplete会在这个动画完成的时候执行
function CSpineModel.SetAnimation(self, iTrackIndex, sAnimationName, bLoop, funStart, funComplete)
	--printc("播放动画：", iTrackIndex, sAnimationName, bLoop)
    if self:CheckSpineHandler() and self:CheckHasAnimationName(sAnimationName) then
    	local startkey, completekey = "", ""
    	if funStart then
    		startkey = string.format("%d_%s_sync", iTrackIndex, sAnimationName)
    		self:AddAnimationEvent("Sync", startkey, funStart)
    	end
    	if funComplete then
    		completekey = string.format("%d_%s_complete", iTrackIndex, sAnimationName)
    		self:AddAnimationEvent("Complete", completekey, funComplete)
    	end
    	self.m_SpineHandler:SetAnimation(iTrackIndex, sAnimationName, bLoop, startkey, completekey)
    end
end

--funStart会在动画开始的时候执行
--funComplete会在这个动画完成的时候执行
function CSpineModel.AddAnimation(self, iTrackIndex, sAnimationName, bLoop, iDelay, funStart, funComplete)
	--printc("播放动画：", iTrackIndex, sAnimationName, bLoop)
    if self:CheckSpineHandler() and self:CheckHasAnimationName(sAnimationName) then
    	iDelay = iDelay or 0
    	local startkey, completekey = "", ""
    	if funStart then
    		startkey = string.format("%d_%s_start", iTrackIndex, sAnimationName)
    		self:AddAnimationEvent("Sync", startkey, funStart)
    	end
    	if funComplete then
    		completekey = string.format("%d_%s_complete", iTrackIndex, sAnimationName)
    		self:AddAnimationEvent("Complete", completekey, funComplete)
    	end
    	self.m_SpineHandler:AddAnimation(iTrackIndex, sAnimationName, bLoop, iDelay, startkey, completekey)
    end
end

function CSpineModel.GetAnimationNames(self)
	--printc("获取所有动画名称")
	if self:CheckSpineHandler() then
		return self.m_SpineHandler:GetAnimationNames()
	end
end

function CSpineModel.CheckHasAnimationName(self, sAnimationName)
	local lAnimationName = self:GetAnimationNames() or {}
	if table.index(lAnimationName, sAnimationName) then
		return true
	else
		printc(string.format("警告：找不到动画：%s",sAnimationName))
		return false
	end
end

function CSpineModel.RandomPlayAnimation(self)
	--printc("随机播放动画")
	if self:CheckSpineHandler() then 
		local animationNames = self:GetAnimationNames()
		local animation = table.randomvalue(animationNames)
		self:SetAnimation(0, animation, true)
	end
end

function CSpineModel.StopAnimation(self)
	if self:CheckSpineHandler() then
		self.m_SpineHandler:StopAnimation()
	end
end

function CSpineModel.SetTimeScale(self, iScale)
	if self:CheckSpineHandler() then
	 	self.m_SpineHandler:SetTimeScale(iScale)
	end
end

return CSpineModel