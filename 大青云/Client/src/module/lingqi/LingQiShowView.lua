--[[
新法宝展示
2015年6月30日11:36:33
haohu
]]
------------------------------------------------------------------

_G.UILingQiShow = BaseUI:new("UILingQiShow")

UILingQiShow.ShowTime = 5 -- 展示时间 5s
UILingQiShow.objUIDraw = nil -- UIDraw
UILingQiShow.defaultDrawCfg = {
	EyePos = _Vector3.new(0, -60, 25),
	LookPos = _Vector3.new(1, 0, 20),
	VPort = _Vector2.new(1800, 1200),
	Rotation = 0
}

function UILingQiShow:Create()
	self:AddSWF("modelDisplay.swf", true, "top");
end

function UILingQiShow:OnLoaded(objSwf)
	objSwf.mcMask.click = function() self:OnBgClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.loader.hitTestDisable = true --模型防止阻挡鼠标
	objSwf.btnConfirm = StrConfig['lingQi013']
end

function UILingQiShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
	end
end

function UILingQiShow:GetHeight()
	return 640
end

function UILingQiShow:GetWidth()
	return 640
end

function UILingQiShow:OnHide()
	self:StopUIDraw()
	self:StopTimer()
	FuncManager:OpenFunc(FuncConsts.LingQi)
end

function UILingQiShow:OnShow()
	_rd.camera:shake(2, 2, 160)
	self:UpdateShow()
	self:UpdateMask()
	self:StartTimer()
	SoundManager:PlaySfx(LingQiConsts.SfxNewWeaponShow)
end

function UILingQiShow:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UILingQiShow:UpdateShow()
	self:ShowName()
	self:ShowModel()
end

function UILingQiShow:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function UILingQiShow:ShowName()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = LingQiModel:GetLevel() -- 当前法宝等级(即配表id)
	objSwf.nameLoader.source = ResUtil:GetLingQiNameImg(level)
end

function UILingQiShow:ShowModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = LingQiModel:GetLevel() -- 当前法宝等级(即配表id)
	local cfg = _G.t_lingqi[level]
	if not cfg then return end
	local modelCfg = _G.t_lingqimodel[cfg.model]
	if not modelCfg then return end
	local avatar = LingQiFigure:new(modelCfg, cfg.liuguang, cfg.liu_speed)
	avatar:ExecMoveAction()
	local drawcfg = self:GetDrawCfg(level)
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("UILingQiShow", avatar, objSwf.loader, drawcfg.VPort, drawcfg.EyePos,
			drawcfg.LookPos, 0x00000000)
	else
		self.objUIDraw:SetUILoader(objSwf.loader)
		self.objUIDraw:SetCamera(drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos)
		self.objUIDraw:SetMesh(avatar)
	end
	-- 模型旋转
	avatar.objMesh.transform:setRotation(0, 1, 0, drawcfg.Rotation)
	self.objUIDraw:SetDraw(true)
end

function UILingQiShow:GetDrawCfg(level)
	return UIDrawLingQiCfg[level] or self.defaultDrawCfg
end

function UILingQiShow:StopUIDraw()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	objUIDraw:SetDraw(false)
	objUIDraw:SetMesh(nil)
end

function UILingQiShow:OnBtnConfirmClick()
	self:Hide()
end

function UILingQiShow:OnBgClick()
	self:Hide()
end

------------------------------------- 倒计时处理------------------------------------------
local timerKey
local time
function UILingQiShow:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = self.ShowTime
	timerKey = TimerManager:RegisterTimer(func, 1000, 0)
end

function UILingQiShow:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UILingQiShow:OnTimeUp()
	self:Hide()
end

function UILingQiShow:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer(timerKey)
		timerKey = nil
	end
end