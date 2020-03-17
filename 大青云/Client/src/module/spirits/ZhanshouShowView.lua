--[[
坐骑展示
zhangshuhui
2015年3月10日17:30:25
]]

_G.UIZhanshouShowView = BaseUI:new("UIZhanshouShowView");

UIZhanshouShowView.timerKey = nil;

UIZhanshouShowView.modelDraw = nil;

UIZhanshouShowView.objUIDraw = nil;
-- UIZhanshouShowView.objUIDrawPfx = nil;
UIZhanshouShowView.meshDir = 0; --模型的当前方向
UIZhanshouShowView.defaultDrawCfg = {
	EyePos   = _Vector3.new( 0, -60, 25 ),
	LookPos  = _Vector3.new( 1, 0, 20 ),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
}

function UIZhanshouShowView:Create()
	self:AddSWF("zhanshouShowPanel.swf",true,"top");
end

function UIZhanshouShowView:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
	
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
end

function UIZhanshouShowView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.objUIDrawPfx then
		self.objUIDrawPfx:SetUILoader(nil);
	end
end

function UIZhanshouShowView:GetHeight()
	return 353;
end

function UIZhanshouShowView:GetWidth()
	return 370;
end

function UIZhanshouShowView:OnShow()
	self:ShowInfo();
end

function UIZhanshouShowView:OnHide()
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetMesh(nil);
	self.objUIDrawPfx:SetDraw(false);
	self.modelDraw:ExitMap();
	self.modelDraw = nil;
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
end

function UIZhanshouShowView:OpenPanel()
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
	
	--播放音效
	self:PlayUpSound();
end

function UIZhanshouShowView:PlayUpSound()
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end

	local cfg = t_wuhun[wuhunId]
	if cfg.sound then
		SoundManager:PlaySfx(cfg.sound)
	end
end
local viewPort;
function UIZhanshouShowView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local wuhunId = SpiritsModel:getWuhuVO().wuhunId
	if not wuhunId or wuhunId <= 0 then
		FPrint("要显示的武魂id不正确")
		return
	end

	local cfg = t_wuhun[wuhunId]
	if not cfg then return end
	local uiCfg = t_lingshouui[cfg.ui_id]
	if not uiCfg then
		FPrint("要显示的武魂ui_id不正确"..cfg.ui_id)
		return
	end
	
	objSwf.nameLoader.source = ResUtil:GetWuhunIcon(uiCfg.name_icon)
	
	local zhanshouAvatar = CZhanshouAvatar:new(uiCfg.model)
	_rd.camera:shake(2,2,160);
	
	local cfg = t_lingshoumodel[uiCfg.model];
	local stunActionFile = cfg.san_idle;
	zhanshouAvatar:DoAction(stunActionFile,false);
	
	self.modelDraw = nil;
	self.modelDraw = zhanshouAvatar;	
	
	local drawcfg = self:GetDrawCfg(wuhunId)
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new( "UIZhanshouShowView", zhanshouAvatar, objSwf.modelload, drawcfg.VPort, drawcfg.EyePos,  
			drawcfg.LookPos, 0x00000000 )
	else
		self.objUIDraw:SetUILoader( objSwf.modelload )
		self.objUIDraw:SetCamera( drawcfg.VPort, drawcfg.EyePos, drawcfg.LookPos )
		self.objUIDraw:SetMesh( zhanshouAvatar )
	end
	zhanshouAvatar.objMesh.transform:setRotation( 0, 0, 1, drawcfg.Rotation );
	-- 模型旋转
	self.objUIDraw:SetDraw(true);
	-- self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
	if not self.objUIDrawPfx then 
		self.objUIDrawPfx = UIPfxDraw:new("UIZhanshouShowViewPfx",objSwf.loader,
									_Vector2.new(1800,1200),
									_Vector3.new(0,-100,25),
									_Vector3.new(1,0,20),
									0x00000000);
		self.objUIDrawPfx:PlayPfx("zuoqifazhen.pfx")
	else
		self.objUIDrawPfx:SetUILoader(objSwf.loader);
		self.objUIDrawPfx:SetCamera(_Vector2.new(1800,1200),_Vector3.new(0,-100,25),_Vector3.new(1,0,20));
	end;
	self.objUIDrawPfx:SetDraw(true)
	
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:Hide();
		FuncManager:OpenFunc(FuncConsts.FaBao,true);
	end,5000,0);
end

function UIZhanshouShowView:OnHitAreaClick()
	self:Hide();
	FuncManager:OpenFunc(FuncConsts.FaBao,true);
end

function UIZhanshouShowView:GetDrawCfg( level )
	return UIDrawZhanshouCfg[level] or self.defaultDrawCfg
end

function UIZhanshouShowView:Update()
	if not self.bShowState then return end
	
	-- if self.modelDraw then
		-- self.meshDir = self.meshDir - math.pi/200;
		-- self.modelDraw.objMesh.transform:setRotation(0,0,1,self.meshDir);
	-- end
end