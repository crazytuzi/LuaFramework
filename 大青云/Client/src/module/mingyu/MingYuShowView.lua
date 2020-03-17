--[[
新玉佩展示
2015年6月30日11:36:33
haohu
]]
------------------------------------------------------------------

_G.UIMingYuShow = BaseUI:new("UIMingYuShow")

UIMingYuShow.ShowTime = 5 -- 展示时间 5s
UIMingYuShow.objUIDraw = nil -- UIDraw
UIMingYuShow.defaultDrawCfg = {
	EyePos   = _Vector3.new( 0, -60, 25 ),
	LookPos  = _Vector3.new( 1, 0, 20 ),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
}

function UIMingYuShow:Create()
	self:AddSWF( "modelDisplay.swf", true, "top" );
end

function UIMingYuShow:OnLoaded(objSwf)
	objSwf.mcMask.click = function() self:OnBgClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.loader.hitTestDisable = true --模型防止阻挡鼠标
end

function UIMingYuShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
	end
end

function UIMingYuShow:GetHeight()
	return 640
end

function UIMingYuShow:GetWidth()
	return 640
end

function UIMingYuShow:OnHide()
	self:StopUIDraw()
	self:StopTimer()
	FuncManager:OpenFunc( FuncConsts.MingYuDZZ )
end

function UIMingYuShow:OnShow()
	_rd.camera:shake( 2, 2, 160 )
	self:UpdateShow()
	self:UpdateMask()
	self:StartTimer()
	SoundManager:PlaySfx( MingYuConsts.SfxNewWeaponShow )
end

function UIMingYuShow:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIMingYuShow:UpdateShow()
	self:ShowName()
	self:ShowModel()
end

function UIMingYuShow:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function UIMingYuShow:ShowName()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = MingYuModel:GetLevel() -- 当前玉佩等级(即配表id)
	objSwf.nameLoader.source = ResUtil:GetMingYuNameImg(level)
end

function UIMingYuShow:ShowModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = MingYuModel:GetLevel() -- 当前玉佩等级(即配表id)
	local cfg = _G.t_mingyu[level]
	if not cfg then return end
	local modelCfg = _G.t_mingyumodel[cfg.model]
	if not modelCfg then return end
	local avatar = MingYuFigure:new( modelCfg, cfg.liuguang, cfg.liu_speed )
	avatar:ExecMoveAction()
	local drawcfg = self:GetDrawCfg(level)
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new( "UIMingYuShow", avatar, objSwf.loader, drawcfg.VPort, drawcfg.EyePos,  
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

function UIMingYuShow:GetDrawCfg( level )
	return UIDrawMingYuCfg[level] or self.defaultDrawCfg
end

function UIMingYuShow:StopUIDraw()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	objUIDraw:SetDraw( false )
	objUIDraw:SetMesh( nil )
	
end

function UIMingYuShow:OnBtnConfirmClick()
	self:Hide()
end

function UIMingYuShow:OnBgClick()
	self:Hide()
end

-------------------------------------倒计时处理------------------------------------------
local timerKey
local time
function UIMingYuShow:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = self.ShowTime
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
end

function UIMingYuShow:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UIMingYuShow:OnTimeUp()
	self:Hide()
end

function UIMingYuShow:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end