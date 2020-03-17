_G.OtherSpiritsDrawController = {}

function OtherSpiritsDrawController:New(drawUI, drawName)
	local drawController = {}
	setmetatable(drawController, {__index = OtherSpiritsDrawController})
	
	drawController.objUIDraw = nil;
	drawController.objAvatar = nil;
	drawController.roleTurnDir = 0;
	drawController.meshDir = 0;
	drawController.drawUI = drawUI;
	drawController.lastWuhunId = nil;
	drawController.wuhunId = nil;
	drawController.DrawName = drawName;
	return drawController
end

function OtherSpiritsDrawController:DrawRole(wuhunId)
	local uiLoader = self.drawUI
	local prof = OtherRoleModel.otherhumanBSInfo.prof; 
	
	if self.objAvatar then 
		self.objAvatar:ExitMap()
		self.objAvatar = nil;
	end;
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(OtherRoleModel.otherhumanBSInfo);

    --
	-- local VPort = _Vector2.new(UIDrawRoleCfg[prof].VPort.x,UIDrawRoleCfg[prof].VPort.y + 100)
	-- local EyePos = _Vector3.new(UIDrawRoleCfg[prof].EyePos.x,UIDrawRoleCfg[prof].EyePos.y - 100,UIDrawRoleCfg[prof].VPort.z)
	if not self.objUIDraw then
		local prof = OtherRoleModel.otherhumanBSInfo.prof; --取玩家职业
		self.objUIDraw = UIDraw:new(self.DrawName, self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);

	local sex = OtherRoleModel.otherhumanBSInfo.sex;
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end


function OtherSpiritsDrawController:OnBtnRoleLeftStateChange(state)
	if state == "down" then
		self.roleTurnDir = 1;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end
function OtherSpiritsDrawController:OnBtnRoleRightStateChange(state)
	if state == "down" then
		self.roleTurnDir = -1;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end

function OtherSpiritsDrawController:Update()
	if not self.bShowState then return end
	
	if self.roleTurnDir == 0 then
		return;
	end
	if not self.objAvatar then
		return;
	end
	self.meshDir = self.meshDir + math.pi/40*self.roleTurnDir;
	if self.meshDir < 0 then
		self.meshDir = self.meshDir + math.pi*2;
	end
	if self.meshDir > math.pi*2 then
		self.meshDir = self.meshDir - math.pi*2;
	end
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end

function OtherSpiritsDrawController:SetWuhunFushengPfx(wuhunId)
	local prof = OtherRoleModel.otherhumanBSInfo.prof; 
	local roleAvatar = self.objAvatar
	if self.lastWuhunId then self:RemoveWuhunFushengPfx(self.lastWuhunId) end
	SpiritsUtil:SetWuhunFushengPfx(wuhunId,prof,roleAvatar)
	self.lastWuhunId = wuhunId;
end

function OtherSpiritsDrawController:RemoveWuhunFushengPfx(wuhunId)
	local prof = MainPlayerModel.humanDetailInfo.prof; 
	local roleAvatar = self.objAvatar
	SpiritsUtil:RemoveWuhunFushengPfx(wuhunId,prof,roleAvatar)
end

function OtherSpiritsDrawController:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.roleTurnDir = 0;
end

function OtherSpiritsDrawController:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	self.drawUI = nil;
end