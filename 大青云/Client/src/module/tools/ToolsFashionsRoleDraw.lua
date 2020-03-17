--[[
人物模型编译器
zhangshuihui
]]

_G.UIToolsFashionsRoleDraw = BaseUI:new("UIToolsFashionsRoleDraw");

UIToolsFashionsRoleDraw.list={};
UIToolsFashionsRoleDraw.curid=0;
UIToolsFashionsRoleDraw.curModel = nil;
UIToolsFashionsRoleDraw.modelTurnDir = 0;--模型旋转方向 0,不旋转;1左;-1右
UIToolsFashionsRoleDraw.meshDir = 0; --模型的当前方向
UIToolsFashionsRoleDraw.curtexDriX = 0;
UIToolsFashionsRoleDraw.texDri = 0;
UIToolsFashionsRoleDraw.texName = 0;
UIToolsFashionsRoleDraw.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(1000,1000),
									Rotation = 0,
									pfxRotationX = 0,
								  }
								  
function UIToolsFashionsRoleDraw:Create()
	self:AddSWF("toolsFashionsRoleDraw.swf",true,"center");
end

function UIToolsFashionsRoleDraw:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self : OnCloseClick()end

	objSwf.btn_up.click = function () self : OnBtnUpclick()end;
	objSwf.btn_down.click = function () self : OnBtnDownclick()end;
	objSwf.btn_right.click = function () self : OnBtnRightclick()end;
	objSwf.btn_left.click = function () self : OnBtnLeftclick()end;

	objSwf.btnRoleRight.stateChange = function (e) self : OnRoleRight(e.state)end;
	objSwf.btnRoleLeft.stateChange = function (e) self : OnRoleLeft(e.state)end;


	objSwf.btn_up.autoRepeat = true;
	objSwf.btn_down.autoRepeat = true;
	objSwf.btn_right.autoRepeat = true;
	objSwf.btn_left.autoRepeat = true;

	objSwf.btn_small.autoRepeat = true;
	objSwf.btn_max.autoRepeat = true;
	objSwf.btn_yang.autoRepeat = true;
	objSwf.btn_fu.autoRepeat = true;

	objSwf.btn_small.click = function () self : OnBtnSmallclick()end;
	objSwf.btn_max.click = function () self : OnBtnMaxclick()end;
	objSwf.btn_yang.click = function () self : OnBtnYangclick()end;
	objSwf.btn_fu.click = function () self : OnBtnFuclick()end;

	objSwf.btn_user.click = function () self : OnBtnUserclick()end;
	objSwf.btn_save.click = function () self : OnBtnSaveclick()end;

	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end

	objSwf.btnTexiao1.stateChange = function (e) self : OnBtnTexiao1(e.state)end;
	objSwf.btnTexiao2.stateChange = function (e) self : OnBtnTexiao2(e.state)end;
end

function UIToolsFashionsRoleDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsFashionsRoleDraw:OnShow()
	for l,k in pairs(UIDrawFashionsRoleConfig) do
		if not t_playerinfo[l] then 
			UIDrawFashionsRoleConfig[l] = nil;
		end;
	end;
	self:Initlist();
end

function UIToolsFashionsRoleDraw:OnListItemClick(e)
	local roleid = e.item.roleid;
	self:DrawRole(roleid);
end

function UIToolsFashionsRoleDraw:Initlist()
	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in pairs(t_playerinfo) do
		local moModel = i
		local listVo = {};
		listVo.name = cf.name;
		listVo.flag = UIDrawFashionsRoleConfig[i] and "√" or "";
		listVo.roleid = i;
		table.push(self.list,listVo)
		objSwf.list.dataProvider:push(UIData.encode(listVo));
	end;
	objSwf.list:invalidateData();
	objSwf.list.selectedIndex = 0;
	self.id = self.list[1].roleid;
	self:DrawRole(self.id)
end

function UIToolsFashionsRoleDraw:DrawRole(id)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self.curid = id;

	local avatar =  CPlayerAvatar:new();
	avatar:Create( 0, id );
	self.curModel = avatar;

	avatar:SetProf(id);
	local info = t_playerinfo[id]
	avatar:SetDress(info.dress);
	avatar:SetArms(info.arm);


	local drawcfg = UIDrawFashionsRoleConfig[id]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();

		UIDrawFashionsRoleConfig[id] = drawcfg;
		
		self:SetListHasCfg(self.curid);
	end;

	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("UIToolsFashionsRoleDraw",avatar, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end;

	-- 模型旋转
	self.meshDir = drawcfg.Rotation;
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);

	self.objUIDraw:SetDraw(true);

	self:OnCfgChange();

	--模型特效
	self.curtexDri = drawcfg.pfxRotationX;

	if self.texName ~= 0 then 
		self.objUIDraw:StopPfx(self.texName2)
	end;
	local sex = info.sex
	local pfxName = "ui_role_sex" ..sex.. ".pfx";
	local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	self.texName = pfxName
	self.texName2 = name;
	-- 微调参数
	pfx.transform:setRotationX(self.curtexDri);
end

function UIToolsFashionsRoleDraw:OnCfgChange()
if not self.objUIDraw then return ;end;

	local roleid = self.curid;
	if not UIDrawFashionsRoleConfig[roleid] then 
		UIDrawFashionsRoleConfig[roleid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawFashionsRoleConfig[roleid];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();

	-- 显示参数
	local objSwf = self.objSwf;
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
end

function UIToolsFashionsRoleDraw:OnBtnUserclick()
	-- user
	if not self.objUIDraw then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local eyeX = tonumber(objSwf.ipEyeX.text);
	local eyeY = tonumber(objSwf.ipEyeY.text);
	local eyeZ = tonumber(objSwf.ipEyeZ.text);
	if (not eyeX) or (not eyeY) or (not eyeZ) then
		FloatManager:AddNormal("无效的Eye参数");
		return;
	end
	local lookX = tonumber(objSwf.ipLookX.text);
	local lookY = tonumber(objSwf.ipLookY.text);
	local lookZ = tonumber(objSwf.ipLookZ.text);
	if (not lookX) or (not lookY) or (not lookZ) then
		FloatManager:AddNormal("无效的Look参数");
		return;
	end
	--
	self.objUIDraw.objCamera.eye:set(eyeX,eyeY,eyeZ);
	self.objUIDraw.objCamera.look:set(lookX,lookY,lookZ);
	self:OnCfgChange();
end

function UIToolsFashionsRoleDraw:OnRoleRight(state)
	if state == "down" then
		self.modelTurnDir = -1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end

function UIToolsFashionsRoleDraw:OnRoleLeft(state)
	if state == "down" then
		self.modelTurnDir = 1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end

function UIToolsFashionsRoleDraw:OnBtnTexiao1(state)
	if state == "down" then 
		self.texDri = 0.01
	elseif state == "release" then 
		self.texDri = 0
	elseif state == "out" then 
		self.texDri = 0
	end;
end

function UIToolsFashionsRoleDraw:OnBtnTexiao2(state)
	if state == "down" then 
		self.texDri = -0.01
	elseif state == "release" then 
		self.texDri = 0
	elseif state == "out" then 
		self.texDri = 0
	end;
end

function UIToolsFashionsRoleDraw:Update()
	self:SetTexiao()
	self:SetRoleRotation()
end

function UIToolsFashionsRoleDraw:SetTexiao()
	--模型特效
	if self.texDri == 0 then return end;
	if not self.curid then return end;
	if not self.curtexDri then return end;
	self.curtexDri = self.curtexDri + self.texDri

	local name,pfx = self.objUIDraw:PlayPfx(self.texName);
	-- 微调参数
	--print("参数微调")
	--if sex == PlayerConsts.Sex_woman then
		pfx.transform:setRotationX(self.curtexDri);
	--end
	local cfg = UIDrawFashionsRoleConfig[self.curid];
	cfg.pfxRotationX = self.curtexDri;
end

function UIToolsFashionsRoleDraw:SetRoleRotation()
	if self.modelTurnDir == 0 then
		return;
	end
	if not self.curModel then
		return;
	end
	self.meshDir = self.meshDir + math.pi/100*self.modelTurnDir;

	if self.meshDir < 0 then
		self.meshDir = self.meshDir + math.pi*2;
	end

	if self.meshDir > math.pi*2 then
		self.meshDir = self.meshDir - math.pi*2;
	end
	self.curModel.objMesh.transform:setRotation(0,0,1,self.meshDir);
	if not UIDrawFashionsRoleConfig[self.curid] then 
		UIDrawFashionsRoleConfig[self.curid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawFashionsRoleConfig[self.curid];
	cfg.Rotation = self.meshDir;
end

function UIToolsFashionsRoleDraw:SetListHasCfg(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.roleid == id then
			listVO.flag = "√";
			objSwf.list.dataProvider[i-1] = UIData.encode(listVO);
			local uiItem = objSwf.list:getRendererAt(i-1);
			if uiItem then
				uiItem:setData(UIData.encode(listVO));
			end
			return;
		end
	end
end

-- 创建配置文件
function UIToolsFashionsRoleDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	cfg.pfxRotationX = 0;
	return cfg;
end

function UIToolsFashionsRoleDraw:OnBtnSmallclick()
	--small
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnMaxclick()
	-- max
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnFuclick()
	-- fu
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnYangclick()
	-- yang
		if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnDownclick()
	-- down
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnUpclick()
	-- up
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnLeftclick()
	--left
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnBtnRightclick()
	--right
		if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsFashionsRoleDraw:OnCloseClick()
	self:Hide();
end

function UIToolsFashionsRoleDraw:OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawFashionsRoleConfig.lua');
	file:write("--[[ 人物模型配置文件\nzhangshuhui\n]]\n".."_G.UIDrawFashionsRoleConfig = {\n");
	for id,cfg in pairs(UIDrawFashionsRoleConfig) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..cfg.Rotation..",\n")
		file:write("\t\tpfxRotationX ="..cfg.pfxRotationX..",\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolsFashionsRoleDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.curid = 0;
end