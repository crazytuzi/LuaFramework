--[[
	2014年12月30日, PM 09:52:58
	妖丹模型配置工具
	wangyanwei
]]

_G.UIToolsBogeyPillDraw = BaseUI:new("UIToolsBogeyPillDraw");

UIToolsBogeyPillDraw.list={};
UIToolsBogeyPillDraw.curid=0;
UIToolsBogeyPillDraw.curModel = nil;
UIToolsBogeyPillDraw.modelTurnDir = 0;--模型旋转方向 0,不旋转;1左;-1右
UIToolsBogeyPillDraw.meshDir = 0; --模型的当前方向
UIToolsBogeyPillDraw.curtexDriX = 0;

UIToolsBogeyPillDraw.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(805,1000),
									Rotation = 0,
									pfxRotationX = 0,
								  }
;

function UIToolsBogeyPillDraw:Create()
	self:AddSWF("roleBogeyTool.swf",true,"center");
end;

function UIToolsBogeyPillDraw:OnLoaded(objSwf,name)
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
end

function UIToolsBogeyPillDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsBogeyPillDraw:OnShow()
	for l,k in pairs(UIDrawBogeyPillConfig) do
		if not t_playerinfo[l] then 
			UIDrawBogeyPillConfig[l] = nil;
		end;
	end;
	self:Initlist();
end

function UIToolsBogeyPillDraw : OnListItemClick(e)
	local roleid = e.item.roleid;
	self:DrawRole(roleid);
end

function UIToolsBogeyPillDraw : Initlist()
	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in pairs(t_playerinfo) do
		local moModel = i
		local listVo = {};
		listVo.name = cf.name;
		listVo.flag = UIDrawBogeyPillConfig[i] and "√" or "";
		listVo.roleid = i;
		table.push(self.list,listVo)
		objSwf.list.dataProvider:push(UIData.encode(listVo));
	end;
	objSwf.list:invalidateData();
	objSwf.list.selectedIndex = 0;
	self.id = self.list[1].roleid;
	self:DrawRole(self.id)
end

UIToolsBogeyPillDraw.objAvatar = nil;
function UIToolsBogeyPillDraw : DrawRole(id)
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
	
	avatar:PlaySitAction();

	local drawcfg = UIDrawBogeyPillConfig[id]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();

		UIDrawBogeyPillConfig[id] = drawcfg;
		
		self:SetListHasCfg(self.curid);
	end;

	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("ToolsBogeyplayer",avatar, objSwf.uiLoader,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objSwf.uiLoader);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end;

	-- 模型旋转
	self.meshDir = drawcfg.Rotation;
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);

	self.objUIDraw:SetDraw(true);

	self:OnCfgChange();
	
	self.objAvatar = avatar;
end


function UIToolsBogeyPillDraw:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.objAvatar then
		self.objAvatar = nil;
	end
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
end

--设置数据
function UIToolsBogeyPillDraw:SetListHasCfg(id)
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

-- 配置变动
function UIToolsBogeyPillDraw : OnCfgChange()
	if not self.objUIDraw then return ;end;

	local roleid = self.curid;
	if not UIDrawBogeyPillConfig[roleid] then 
		UIDrawBogeyPillConfig[roleid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawBogeyPillConfig[roleid];
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

function UIToolsBogeyPillDraw : OnRoleRight(state)
	if state == "down" then
		self.modelTurnDir = -1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end
function UIToolsBogeyPillDraw : OnRoleLeft (state)
	if state == "down" then
		self.modelTurnDir = 1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end

function UIToolsBogeyPillDraw : OnBtnUpclick()
	-- up
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsBogeyPillDraw : OnBtnDownclick()
	-- down
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end

end

function UIToolsBogeyPillDraw : OnBtnRightclick()
	--right
		if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsBogeyPillDraw : OnBtnLeftclick()
	--left
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

function UIToolsBogeyPillDraw : OnCloseClick()
	self:Hide();
end

function UIToolsBogeyPillDraw : OnBtnSmallclick()
	--small
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsBogeyPillDraw : OnBtnMaxclick()
	-- max
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsBogeyPillDraw : OnBtnFuclick()
	-- fu
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsBogeyPillDraw : OnBtnYangclick()
	-- yang
		if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

-- 创建配置文件
function UIToolsBogeyPillDraw : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	cfg.pfxRotationX = 0;
	return cfg;
end

function UIToolsBogeyPillDraw : OnBtnUserclick()
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

function UIToolsBogeyPillDraw : OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawBogeyPillConfig.lua');
	file:write("--[[ 人物模型配置文件\nWangshuai\n]]\n".."_G.UIDrawBogeyPillConfig = {\n");
	for id,cfg in pairs(UIDrawBogeyPillConfig) do
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
