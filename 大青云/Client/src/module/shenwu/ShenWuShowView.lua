--[[
神武 领取界面
2015年12月29日19:20:56
haohu
]]

_G.UIShenWuShow = BaseUI:new("UIShenWuShow")

UIShenWuShow.ShowTime = 5 -- 展示时间 5s
UIShenWuShow.objUIDraw = nil -- UIDraw
UIShenWuShow.defaultDrawCfg = {
	EyePos   = _Vector3.new( 0, -60, 25 ),
	LookPos  = _Vector3.new( 1, 0, 20 ),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
}

function UIShenWuShow:Create()
	self:AddSWF( "shenwuModelDisplay.swf", true, "top" );
end

function UIShenWuShow:OnLoaded(objSwf)
	objSwf.mcMask.click = function() self:OnBgClick() end
	objSwf.btnConfirm.click = function() self:OnBtnConfirmClick() end
	objSwf.loader.hitTestDisable = true --模型防止阻挡鼠标
end

function UIShenWuShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
	end
end

function UIShenWuShow:GetHeight()
	return 640
end

function UIShenWuShow:GetWidth()
	return 640
end

function UIShenWuShow:OnHide()
	self:StopUIDraw()
	self:StopTimer()
	FuncManager:OpenFunc( FuncConsts.ShenWu )
end

function UIShenWuShow:OnShow()
	_rd.camera:shake( 2, 2, 160 )
	self:UpdateShow()
	self:UpdateMask()
	self:StartTimer()
	SoundManager:PlaySfx( MagicWeaponConsts.SfxNewWeaponShow )
end

function UIShenWuShow:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIShenWuShow:UpdateShow()
	self:ShowName()
	self:ShowModel()
end

function UIShenWuShow:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 10
	objSwf.mcMask._height = wHeight + 10
end

function UIShenWuShow:ShowName()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = ShenWuModel:GetLevel()
	objSwf.nameLoader.source = ResUtil:GetShenWuNameImg(level)
end

local viewPort
function UIShenWuShow:ShowModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local level = ShenWuModel:GetLevel();
	if not self.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(1800, 1200) end
		self.objUIDraw = UISceneDraw:new( "UIShenWuShow", objSwf.loader, viewPort );
	end

	local func = function()
		local equipId = ShenWuUtils:GetCurrentWuQiId()
		local skn, skl, san = ShenWuUtils:GetModelInfo(equipId)
		self.objAvatar = ShenWuAvatar:new(skn, skl, san)
		local list = self.objUIDraw:GetMarkers()
		local marker
		for _, mkr in pairs(list) do
			marker = mkr
			break
		end
		if not marker then return end
		self.objAvatar:EnterUIScene( self.objUIDraw.objScene, marker.pos, marker.dir, marker.scale, enEntType.eEntType_ShenWu)
		local bone, pfx = ShenWuUtils:GetUIPfxInfo(level)
		if bone and pfx then
			self.objAvatar:PlayPfxOnBone(bone, pfx, pfx)
		end
		self.objAvatar:ExecIdleAction()
	end

	self.objUIDraw:SetUILoader(objSwf.loader)
	self.objUIDraw:SetScene( ShenWuUtils:GetUIShowScene(), func )
	self.objUIDraw:SetDraw( true )
end

function UIShenWuShow:GetDrawCfg( level )
	return UIDrawShenbingCfg[level] or self.defaultDrawCfg
end

function UIShenWuShow:StopUIDraw()
	if self.objAvatar then
		self.objAvatar:Destroy()
		self.objAvatar = nil
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false)
	end
end

function UIShenWuShow:OnBtnConfirmClick()
	self:Hide()
end

function UIShenWuShow:OnBgClick()
	self:Hide()
end

-------------------------------------倒计时处理------------------------------------------
local timerKey
local time
function UIShenWuShow:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = self.ShowTime
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
end

function UIShenWuShow:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UIShenWuShow:OnTimeUp()
	self:Hide()
end

function UIShenWuShow:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end