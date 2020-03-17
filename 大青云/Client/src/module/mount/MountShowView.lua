--[[
坐骑展示
zhangshuhui
2015年3月10日17:30:25
]]

_G.UIMountShowView = BaseUI:new("UIMountShowView");

UIMountShowView.timerKey = nil;

UIMountShowView.modelDraw = nil;
UIMountShowView.mountLevel = 0;
UIMountShowView.objUIDraw = nil;
UIMountShowView.meshDir = 0; --模型的当前方向

function UIMountShowView:Create()
	self:AddSWF("mountShowPanel.swf",true,"top");
end

function UIMountShowView:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
	objSwf.btnGet.click = function() self:OnHitAreaClick(); end
	
	--模型防止阻挡鼠标
	objSwf.modelload.hitTestDisable = true;
end

function UIMountShowView:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.objUIDrawPfx then
		self.objUIDrawPfx:SetUILoader(nil);
	end
end

function UIMountShowView:GetHeight()
	return 353;
end

function UIMountShowView:GetWidth()
	return 370;
end

function UIMountShowView:OnResize(wWidth, wHeight)
	if not self.bShowState then return end
	self:UpdateMask()
end

function UIMountShowView:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UIMountShowView:OnShow()
	self:ShowInfo();
	self:UpdateMask();
end

function UIMountShowView:OnHide()
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	if not self.objUIDraw then
		return;
	end
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetMesh(nil);
	self.objUIDrawPfx:SetDraw(false);
	self.modelDraw:ExitMap();
	self.modelDraw = nil;
	
end

function UIMountShowView:OpenPanel(level)
	self.mountLevel = level;
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
	
	--播放音效
	self:PlayUpSound();
end

function UIMountShowView:PlayUpSound()
	local soundid = MountUtil:GetMountSound(self.mountLevel,MainPlayerModel.humanDetailInfo.eaProf);
	if soundid > 0 then
		SoundManager:PlaySfx(soundid);
	end
end

UIMountShowView.defaultCfg = {
									EyePos = _Vector3.new(0,-100,25),
									LookPos = _Vector3.new(1,0,20),
									VPort = _Vector2.new(1800,1200),
									Rotation = 0,
								  };
function UIMountShowView:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end
function UIMountShowView:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	local iconname = MountUtil:GetMountIconName(self.mountLevel, "nameIcon", playerinfo.eaProf)
	if self.mountLevel < MountConsts.SpecailDownid then
		objSwf.nameLoader.source = ResUtil:GetMountIconName(iconname);
		objSwf.modelload._x = -750;
		objSwf.modelload._y = -460;
		
		self:ShowMountModel();
	else
		objSwf.nameLoader.source = ResUtil:GetWuhunIcon(iconname);
		objSwf.modelload._x = -750;
		objSwf.modelload._y = -470;
		
		self:ShowZhanShouModel();
	end
end

function UIMountShowView:ShowMountModel()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	--模型
	local modelid = MountUtil:GetPlayerMountModelId(self.mountLevel);
	if modelid == 0 then
		self:Hide();
		return;
	end
	local drawcfg = UIDrawMountShowConfig[modelid]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
	end
	
	local horsecfg = {};
	if self.mountLevel < MountConsts.SpecailDownid then
		horsecfg = t_horse[self.mountLevel];
		if not horsecfg then
			Error("Cannot find config of horse. level:"..self.mountLevel);
			return;
		end
	else
		horsecfg = t_horselingshou[self.mountLevel];
		if not horsecfg then
			Error("Cannot find config of t_horselingshou. level:"..self.mountLevel);
			return;
		end
		
		for i,vo in pairs(t_wuhun) do
			if vo.order == self.mountLevel-MountConsts.LingShouSpecailDownid then
				drawcfg = UIDrawZhanshouCfg[vo.id];
				if not drawcfg then 
					drawcfg = self:GetDefaultCfg();
				end
				break;
			end
		end
	end

	local mountAvatar = CHorseAvatar:new(modelid)
	mountAvatar:Create(modelid);
	_rd.camera:shake(2,2,160);
	
	local cfg = t_mountmodel[modelid];
	local stunActionFile = cfg.san_show;
	mountAvatar:DoAction(stunActionFile,false);
	mountAvatar.objMesh.transform:mulScalingRight(horsecfg.ui_scale,horsecfg.ui_scale,horsecfg.ui_scale);
	
	self.modelDraw = nil;
	self.modelDraw = mountAvatar;
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("MountShowView",mountAvatar, objSwf.modelload,
									drawcfg.VPort,   drawcfg.EyePos,  
									drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(mountAvatar);
	end;
	
	self.meshDir = 0;
	-- 模型旋转
	self.objUIDraw:SetDraw(true);
	self.modelDraw.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	
	objSwf.loader._x = -750;
	objSwf.loader._y = -460;
	if not self.objUIDrawPfx then 
		self.objUIDrawPfx = UIPfxDraw:new("MountShowViewPfx",objSwf.loader,
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
		FuncManager:OpenFunc(FuncConsts.Horse,true);
	end,MountConsts.MountShowTime,0);
end

function UIMountShowView:ShowZhanShouModel()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local drawcfg = {};
	local uiCfg = {};
	for i,vo in pairs(t_wuhun) do
		if vo.order == self.mountLevel-MountConsts.LingShouSpecailDownid then
			drawcfg = UIDrawZhanshouCfg[vo.id];
			uiCfg = t_lingshouui[vo.ui_id]
			break;
		end
	end
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
	end
	if not uiCfg then
		return;
	end

	local mountAvatar = CZhanshouAvatar:new(uiCfg.model)
	_rd.camera:shake(2,2,160);
	
	local cfg = t_lingshoumodel[uiCfg.model];
	local stunActionFile = cfg.san_idle;
	mountAvatar:DoAction(stunActionFile,false);
	
	self.modelDraw = nil;
	self.modelDraw = mountAvatar;
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("MountShowView",mountAvatar, objSwf.modelload,
									drawcfg.VPort,   drawcfg.EyePos,  
									drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(mountAvatar);
	end;
	
	self.meshDir = 0;
	-- 模型旋转
	self.objUIDraw:SetDraw(true);
	self.modelDraw.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	
	objSwf.loader._x = -750;
	objSwf.loader._y = -460;
	if not self.objUIDrawPfx then 
		self.objUIDrawPfx = UIPfxDraw:new("MountShowViewPfx",objSwf.loader,
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
		FuncManager:OpenFunc(FuncConsts.Horse,true,FuncConsts.MountLingShou);
	end,MountConsts.MountShowTime,0);
end

function UIMountShowView:OnHitAreaClick()
	self:Hide();
	if self.mountLevel < MountConsts.SpecailDownid then
		FuncManager:OpenFunc(FuncConsts.Horse,true);
	else
		FuncManager:OpenFunc(FuncConsts.Horse,true,FuncConsts.MountLingShou);
	end
end

function UIMountShowView:Update()
	if not self.bShowState then return end
	
	-- if self.modelDraw then
		-- self.meshDir = self.meshDir - math.pi/200;
		-- self.modelDraw.objMesh.transform:setRotation(0,0,1,self.meshDir);
	-- end
end