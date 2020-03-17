--[[
新神兵展示
2015年6月30日11:36:33
haohu
]]
------------------------------------------------------------------

_G.UICollectionShow = BaseUI:new("UICollectionShow")
UICollectionShow.okCallBackFunc = nil
UICollectionShow.ShowTime = 5 -- 展示时间 5s
UICollectionShow.objUIDraw = nil -- UIDraw
UICollectionShow.defaultDrawCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 10
}

function UICollectionShow:Create()
	self:AddSWF( "collectionDisplay.swf", true, "top" );
end

function UICollectionShow:OnLoaded(objSwf)
	objSwf.bg.click = function() self:OnBgClick() end
	objSwf.btnGet.click = function() self:OnBgClick() end
	objSwf.loader.hitTestDisable = true --模型防止阻挡鼠标
end

function UICollectionShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
	end
end

function UICollectionShow:GetHeight()
	return 640
end

function UICollectionShow:GetWidth()
	return 640
end

function UICollectionShow:OnHide()
	if self.okCallBackFunc then
		UIFuncGuide:Close(UIFuncGuide.Type_EquipGuide);
		self:okCallBackFunc()
		self.okCallBackFunc = nil
	end
	self:StopUIDraw()
	self:StopTimer()
end

function UICollectionShow:OnShow()
	_rd.camera:shake( 2, 2, 160 )
	self:UpdateShow()
	self:StartTimer()
end

function UICollectionShow:Open(funcCallBack)
	self.okCallBackFunc = funcCallBack
	if self.bShowState then
		self:OnShow()
	else
		self:Show()
	end 
end

function UICollectionShow:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	self:ShowName()
	self:ShowModel()
	-- local showFunc = function()
		-- objSwf.btnEffect._visible  = true;
	-- end
	-- local unshowFunc = function()
		-- objSwf.btnEffect._visible  = false;
	-- end
	-- UIFuncGuide:Open({
		-- type = UIFuncGuide.Type_EquipGuide,
		-- getButton = objSwf.bg,
		-- pos = UIFuncGuide.Left,
		-- mcArrow = objSwf.mcArrow,
		-- mcTxt = objSwf.mcTxt,
		-- showFunc = showFunc,
		-- unshowFunc = unshowFunc,
	-- });
end

function UICollectionShow:ShowName()
	local objSwf = self.objSwf
	if not objSwf then return end
	-- local level = MagicWeaponModel:GetLevel() -- 当前神兵等级(即配表id)
	-- objSwf.nameLoader.source = ResUtil:GetMagicWeaponNameImg(level)
end

function UICollectionShow:ShowModel()
	local objSwf = self.objSwf
	if not objSwf then return end
	local configId = 108
	local cfg = t_collection[configId]
	if not cfg then
		Error("don't exist this npc  configId" .. configId)
		return
	end
	local modelList = nil
	if cfg.profmodelId and cfg.profmodelId ~= "" then
		modelList = split(cfg.profmodelId, ",")
	end
	local lookId = 0
	local dwProf = MainPlayerModel.humanDetailInfo.eaProf
	if modelList and #modelList == 4 then
		lookId = tonumber(modelList[dwProf])
	else
		lookId = cfg.modelId
	end
	
	local avatar = CollectionAvatar:NewCollectionAvatar(configId, 99999)
	avatar:InitAvatar()
	if t_model[lookId] then
		avatar:ExecAction(t_model[lookId].san_move, true)
	end
	local drawcfg = self:GetDrawCfg(dwProf)
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new( "UICollectionShow", avatar, objSwf.loader, drawcfg.VPort, drawcfg.EyePos,  
			drawcfg.LookPos, 0x00000000 )
	else
		self.objUIDraw:SetUILoader( objSwf.loader )
		self.objUIDraw:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos )
		self.objUIDraw:SetMesh( avatar )
	end
	-- 模型旋转
	-- avatar.objMesh.transform:setRotation( 0, 0, 1, drawcfg.Rotation )
	self.objUIDraw:SetDraw(true)
end

function UICollectionShow:GetDrawCfg( profId )
	return UIDrawCollectionCfg[profId] or self.defaultDrawCfg
end

function UICollectionShow:StopUIDraw()
	local objUIDraw = self.objUIDraw
	if not objUIDraw then return end
	objUIDraw:SetDraw( false )
	objUIDraw:SetMesh( nil )
end

function UICollectionShow:OnBgClick()
	ClickLog:Send(ClickLog.T_Quest_Equip);
	self:Hide()
end

-------------------------------------倒计时处理------------------------------------------
local timerKey
local time
function UICollectionShow:StartTimer()
	self:StopTimer()
	local func = function() self:OnTimer() end
	time = self.ShowTime
	timerKey = TimerManager:RegisterTimer( func, 1000, 0 )
end

function UICollectionShow:OnTimer()
	time = time - 1
	if time <= 0 then
		self:StopTimer()
		self:OnTimeUp()
		return
	end
end

function UICollectionShow:OnTimeUp()
	ClickLog:Send(ClickLog.T_Quest_Equip );
	self:Hide()
end

function UICollectionShow:StopTimer()
	if timerKey then
		TimerManager:UnRegisterTimer( timerKey )
		timerKey = nil
	end
end