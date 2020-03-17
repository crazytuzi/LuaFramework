_G.RoleDrawRender = {}

function RoleDrawRender:New(drawUI, drawName, isUserGrey)
	local drawController = {}
	setmetatable(drawController, {__index = RoleDrawRender})
	
	drawController.objUIDraw = nil;
	drawController.objAvatar = nil;
	drawController.roleTurnDir = 0;
	drawController.meshDir = 0;
	drawController.drawUI = drawUI;
	drawUI.hitTestDisable = true;
	drawController.lastWuhunId = nil;
	drawController.wuhunId = nil;
	drawController.DrawName = drawName;
	drawController.isUserGrey = isUserGrey;
	drawController.roleVo = nil
	drawController.isShow = false
	return drawController
end

-- function RoleDrawRender:RegisterNotification(notificationList)
	-- local setNotificatioin = notificationList
	-- if not setNotificatioin then return; end
	-- local callback = function(name,body)
		-- self:HandleNotification(name, body);
	-- end;
	-- for i,name in pairs(setNotificatioin) do
		-- Notifier:registerNotification(name, callback)
	-- end
-- end

-- function RoleDrawRender:HandleNotification(name, body)
	-- if not self.isShow then return end

	-- if name == NotifyConsts.PlayerModelChange then
		-- if self.wuhunId then
			-- self:DrawRole(self.wuhunId);
		-- end
	-- end
-- end

--[[
@param roleVo
roleVo.prof 
roleVo.arms 
roleVo.dress 
roleVo.fashionsHead 
roleVo.fashionsArms 
roleVo.fashionsDress
roleVo.wuhunId
--]]
function RoleDrawRender:DrawRole(roleVo, noGrey)
	self.isShow = true

	self.roleVo = roleVo
	local uiLoader = self.drawUI
	local prof = roleVo.prof;
 
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(roleVo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
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

	-- local sex = roleVo.sex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIDraw:PlayPfx(pfxName);

	-- 微调参数
	-- pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end


function RoleDrawRender:OnBtnRoleLeftStateChange(state, fDelta)
	local delta = fDelta or 0
	if state == "down" then
		self.roleTurnDir = delta;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end
function RoleDrawRender:OnBtnRoleRightStateChange(state, fDelta)
	local delta = fDelta or 0
	if state == "down" then
		self.roleTurnDir = -delta;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end

function RoleDrawRender:Update()
	if self.roleTurnDir == 0 then
		return;
	end
	if not self.objAvatar then
		return;
	end
	self.meshDir = self.meshDir + math.pi/200*self.roleTurnDir;
	if self.meshDir < 0 then
		self.meshDir = self.meshDir + math.pi*2;
	end
	if self.meshDir > math.pi*2 then
		self.meshDir = self.meshDir - math.pi*2;
	end
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
end

function RoleDrawRender:SetWuhunFushengPfx(wuhunId)
	local prof = self.roleVo.prof; 
	local roleAvatar = self.objAvatar
	if self.lastWuhunId then self:RemoveWuhunFushengPfx(self.lastWuhunId) end
	SpiritsUtil:SetWuhunFushengPfx(wuhunId,prof,roleAvatar)
	self.lastWuhunId = wuhunId;
end

function RoleDrawRender:RemoveWuhunFushengPfx(wuhunId)
	local prof = self.roleVo.prof; 
	local roleAvatar = self.objAvatar
	SpiritsUtil:RemoveWuhunFushengPfx(wuhunId,prof,roleAvatar)
end

function RoleDrawRender:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil)
		UIDrawManager:RemoveUIDraw(self.objUIDraw);
		self.objUIDraw = nil;
	end
	self.drawUI = nil
end

function RoleDrawRender:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	self.roleTurnDir = 0;
	self.roleVo = nil
	self.isShow = false
end