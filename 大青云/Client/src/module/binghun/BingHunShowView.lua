--[[
兵魂展示
lizhuangzhuang
2015年10月9日17:13:16
]]

_G.UIBingHunShow = BaseUI:new("UIBingHunShow");

UIBingHunShow.objUIDraw = nil;
UIBingHunShow.objAvatar = nil;

UIBingHunShow.modelId = 0;

function UIBingHunShow:Create()
	self:AddSWF("bingHunShowPanel.swf",true,"top");
end

function UIBingHunShow:OnLoaded(objSwf)
	objSwf.hitArea.click = function() self:OnHitAreaClick(); end
end

function UIBingHunShow:OnResize()
	self:ShowMask();
end

function UIBingHunShow:GetHeight()
	return 370;
end

function UIBingHunShow:GetWidth()
	return 353;
end

function UIBingHunShow:Open(modelId)
	self.modelId = modelId;
	if self:IsShow() then
		self:ShowInfo();
	else
		self:Show();
	end
end

function UIBingHunShow:OnShow()
	self:ShowMask();
	self:ShowInfo();
end

function UIBingHunShow:ShowMask()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local x,y = self:GetPos();
	local wWidth,wHeight = UIManager:GetWinSize();
	objSwf.mask._x = -x;
	objSwf.mask._y = -y;
	objSwf.mask._width = wWidth;
	objSwf.mask._height = wHeight;
end

function UIBingHunShow:OnHide()
	self.objUIDraw:SetDraw(false);
	self.objUIDraw:SetUILoader(nil);
	UIDrawManager:RemoveUIDraw(self.objUIDraw);
	self.objUIDraw = nil;
	self.objAvatar = nil;
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.modelId = 0;
end

function UIBingHunShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
		self.objUIDraw = nil;
	end
end

function UIBingHunShow:ShowInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = t_binghunmodel[self.modelId];
	if not cfg then return; end
	local uiloader = objSwf.modelLoader;
	uiloader._x = -750;
	uiloader._y = -560;
	
	self.objAvatar = CAvatar:new();
	self.objAvatar.avtName = "binghunfuncmodel";
	self.objAvatar:SetPart("Body",cfg.skn);
	self.objAvatar:ChangeSkl(cfg.skl);
	self.objAvatar:ExecAction(cfg.follow_idle,true);
	_rd.camera:shake(2,2,160);
	
	if self.modelId == 20010999	then
		self.objAvatar.objMesh.transform:mulScalingRight(2,2,2);
		self.objAvatar.objMesh.transform:mulTranslationRight(0, 0, -15)
	elseif self.modelId == 20020999	then
		self.objAvatar.objMesh.transform:mulScalingRight(1.2,1.2,1.2);
	elseif self.modelId == 20030999 then
		self.objAvatar.objMesh.transform:mulScalingRight(1.5,1.5,1.5);
		self.objAvatar.objMesh.transform:mulTranslationRight(0, 0, -5)
	elseif self.modelId == 20040999 then
		self.objAvatar.objMesh.transform:mulScalingRight(3,3,3);
		self.objAvatar.objMesh.transform:mulTranslationRight(0, 0, -15)
	end
	
	self.objUIDraw = UIDraw:new("FuncOpenBingHunDraw",self.objAvatar,uiloader,
								_Vector2.new(1800,1200),
								_Vector3.new(0,-100,25),
								_Vector3.new(1,0,20),
								0x00000000);
	self.objUIDraw:SetDraw(true);
	self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
	
	if self.timerKey then
		TimerManager:UnRegisterTimer(self.timerKey);
	end
	self.timerKey = TimerManager:RegisterTimer(function()
		self:Hide();
	end,FuncConsts.AutoOpenTime,1);
end

function UIBingHunShow:OnHitAreaClick()
	self:Hide();
end