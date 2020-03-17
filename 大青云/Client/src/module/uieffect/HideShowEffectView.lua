--[[
黑亮
liyuan
2014年10月18日10:32:23
]]

_G.UIHideShowEffect = BaseUI:new("UIHideShowEffect") 
-- 自动镜头配置

function UIHideShowEffect:Create()
	self:AddSWF("hideAndShowEffect.swf", true, "story")
end

function UIHideShowEffect:OnShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local winW,winH = UIManager:GetWinSize()
	self:DoResize(winW,winH)
	objSwf.cover2:playEffect(1)
end

function UIHideShowEffect:OnLoaded(objSwf,name)
	local winW,winH = UIManager:GetWinSize()
	self:DoResize(winW,winH)
	objSwf.cover2.complete = function()
		self:Hide()
	end
end

-- 重新调整布局
function UIHideShowEffect:DoResize(dwWidth, dwHeight)
	local objSwf = self.objSwf
	if not objSwf then return end
		
	if objSwf.cover2 then
		objSwf.cover2._width = dwWidth;
		objSwf.cover2._height = dwHeight;
	end	
end