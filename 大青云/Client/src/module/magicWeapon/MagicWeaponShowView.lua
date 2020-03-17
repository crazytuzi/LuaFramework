--[[
新神兵展示
2015年6月30日11:36:33
haohu
]]
------------------------------------------------------------------

_G.UIMagicWeaponShow = BaseUI:new("UIMagicWeaponShow")

UIMagicWeaponShow.ShowTime = 5 -- 展示时间 5s
UIMagicWeaponShow.objUIDraw = nil -- UIDraw
UIMagicWeaponShow.defaultDrawCfg = {
	EyePos   = _Vector3.new( 0, -60, 25 ),
	LookPos  = _Vector3.new( 1, 0, 20 ),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
}

function UIMagicWeaponShow:Create()
	self:AddSWF( "modelDisplay.swf", true, "top" );
end

function UIMagicWeaponShow:OnLoaded(objSwf)
	objSwf.mcMask.click = function() self:OnBgClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.loader.hitTestDisable = true --模型防止阻挡鼠标
end

function UIMagicWeaponShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
	end
end

function UIMagicWeaponShow:GetHeight()
	return 640
end

function UIMagicWeaponShow:GetWidth()
	return 640
end

function UIMagicWeaponShow:OnHide()
	self:StopUIDraw()
	self:StopTimer()
	FuncManager:OpenFunc( FuncConsts.MagicWeapon )
end

function UIMagicWeaponShow:OnShow()
	_rd.camera:shake( 2, 2, 160 )
	self:UpdateShow()
	self:UpdateMask()
	self:StartTimer()
	SoundManager:PlaySfx( MagicWeaponConsts.SfxNewWeaponShow )
end

function UIMagicWeaponShow:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIMagicWeaponShow:UpdateShow()
	self:ShowName()
	self:ShowModel()
end

function UIMagicWeaponShow:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function UIMagicWeaponShow:ShowName()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = MagicWeaponModel:GetLevel() -- 当前神兵等级(即配表id)
	objSwf.nameLoader.source = ResUtil:GetMagicWeaponNameImg(level)
end

function UIMagicWeaponShow:ShowModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = MagicWeaponModel:GetLevel() -- 当前神兵等级(即配表id)
	local cfg = _G.t_shenbing[level]
	if not cfg then return end
	local modelCfg = _G.t_shenbingmodel[cfg.model]
	if not modelCfg then return end
	local avatar = MagicWeaponFigure:new( modelCfg, cfg.liuguang, cfg.liu_speed )
	avatar:ExecMoveAction()
	local drawcfg = self:GetDrawCfg(level)
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new( "UIMagicWeaponShow", avatar, objSwf.loader, drawcfg.VPort, drawcfg.EyePos,  
			drawcfg.LookPos, 0x00000000 )
	else
		self.objUIDraw:SetUILoader( objSwf.loader )
		self.objUIDraw:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos )
		self.objUIDraw:SetMesh( avatar )
	end
	-- 模型旋转
	avatar.objMesh.transform:setRotation( 0, 1, 0, drawcfg.Rotation )
	self.objUIDraw:SetDraw(true)
end

function UIMagicWeaponShow:GetDrawCfg( level )
	return UIDrawShenbingCfg[level] or self.defaultDrawCfg
end

function UIMagicWeaponShow:StopUIDraw()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	objUIDraw:SetDraw( false )
	objUIDraw:SetMesh( nil )
	
end

function UIMagicWeaponShow:OnBtnConfirmClick()
	self:Hide()
end

function UIMagicWeaponShow:OnBgClick()
	self:Hide()
end

-------------------------------------倒计时处理------------------------------------------
local timerKey
local time
function UIMagicWeaponShow:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = self.ShowTime
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
end

function UIMagicWeaponShow:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UIMagicWeaponShow:OnTimeUp()
	self:Hide()
end

function UIMagicWeaponShow:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end