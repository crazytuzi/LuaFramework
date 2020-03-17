--[[黑色打字面板
liyuan
2014年9月28日10:33:06
]]

_G.StorySpeedUpEffect = BaseUI:new("StorySpeedUpEffect") 

function StorySpeedUpEffect:Create()
	self:AddSWF("storySpeedUpPanel.swf", true, "story")
end

function StorySpeedUpEffect:OnLoaded(objSwf,name)
	
	self:StopSpeedUpEffect()
end

-- 重新调整布局
function StorySpeedUpEffect:DoResize( dwWidth, dwHeight )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.speedUpLeftUp._x = 0
	objSwf.speedUpLeftUp._y = 120
	
	objSwf.speedUpLeftDown._x = 0
	objSwf.speedUpLeftDown._y = dwHeight - 540
	
	objSwf.speedUpRightUp._x = dwWidth - 960
	objSwf.speedUpRightUp._y = 120
	
	objSwf.speedUpRightDown._x = dwWidth - 960
	objSwf.speedUpRightDown._y = dwHeight - 540
end

function StorySpeedUpEffect:PlaySpeedUpEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.speedUpRightDown:play()
	objSwf.speedUpRightUp:play()
	objSwf.speedUpLeftUp:play()
	objSwf.speedUpLeftDown:play()
	objSwf.speedUpRightDown._visible = true
	objSwf.speedUpRightUp._visible = true
	objSwf.speedUpLeftUp._visible = true
	objSwf.speedUpLeftDown._visible = true
end

function StorySpeedUpEffect:StopSpeedUpEffect()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.speedUpRightDown:stop()
	objSwf.speedUpRightUp:stop()
	objSwf.speedUpLeftUp:stop()
	objSwf.speedUpLeftDown:stop()
	objSwf.speedUpRightDown._visible = false
	objSwf.speedUpRightUp._visible = false
	objSwf.speedUpLeftUp._visible = false
	objSwf.speedUpLeftDown._visible = false
end

function StorySpeedUpEffect:OnShow(name)
	local winW,winH = UIManager:GetWinSize()
	self:DoResize(winW,winH)
	self:PlaySpeedUpEffect()
end


function StorySpeedUpEffect:OnHide()
	self:StopSpeedUpEffect()
end

--从来不被回收
function StorySpeedUpEffect:NeverDeleteWhenHide()
	return true;
end