--[[
人物技能界面工具
wangshuaui
]]


_G.UIToolsRoleSkillDraw = BaseUI:new("UIToolsRoleSkillDraw")

UIToolsRoleSkillDraw.infolist = {};
UIToolsRoleSkillDraw.curskid = nil;
UIToolsRoleSkillDraw.list = {};

UIToolsRoleSkillDraw.curAvta = nil;

UIToolsRoleSkillDraw.modelTurnDir = 0;--模型旋转方向 0,不旋转;1左;-1右
UIToolsRoleSkillDraw.meshDir = 0; --模型的当前方向



UIToolsRoleSkillDraw.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(1000,600),
									Rotation = 0,
								  }
;

function UIToolsRoleSkillDraw : Create()
	self:AddSWF("toolsRoleSkillPanel.swf",true,"center")
end;
function UIToolsRoleSkillDraw : OnLoaded(objSwf,name)
	objSwf.modelload.hitTestDisable = true;
	-- close
	objSwf.btnClose.click = function() self : OnCloseClick()end

	-- itemclick
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end

	-- playerRoleSkill 
	objSwf.btn_PlayerSkill.click = function () self:OnPlayerSk()end;

	objSwf.btn_up.click = function () self : OnBtnUpclick()end;
	objSwf.btn_down.click = function () self : OnBtnDownclick()end;
	objSwf.btn_right.click = function () self : OnBtnRightclick()end;
	objSwf.btn_left.click = function () self : OnBtnLeftclick()end;

	objSwf.btn_small.click = function () self : OnBtnSmallclick()end;
	objSwf.btn_max.click = function () self : OnBtnMaxclick()end;
	objSwf.btn_yang.click = function () self : OnBtnYangclick()end;
	objSwf.btn_fu.click = function () self : OnBtnFuclick()end;

	objSwf.btn_up.autoRepeat = true;
	objSwf.btn_down.autoRepeat = true;
	objSwf.btn_right.autoRepeat = true;
	objSwf.btn_left.autoRepeat = true;

	objSwf.btn_small.autoRepeat = true;
	objSwf.btn_max.autoRepeat = true;
	objSwf.btn_yang.autoRepeat = true;
	objSwf.btn_fu.autoRepeat = true;


	objSwf.btnRoleRight.stateChange = function (e) self : OnRoleRight(e.state)end;
	objSwf.btnRoleLeft.stateChange = function (e) self : OnRoleLeft(e.state)end;

	objSwf.btn_save.click = function () self : OnBtnSaveclick()end;
	objSwf.btn_user.click = function () self : OnBtnUserclick()end;
	for i=1,4,1 do 
		objSwf["role"..i].click = function ()self:OnRoleBtn(i)end;
	end;
end;

function UIToolsRoleSkillDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end


function UIToolsRoleSkillDraw : OnShow()

	self:PrepareInfo()
	self:ShowList(1);
end;
function UIToolsRoleSkillDraw : OnRoleBtn(i) 
	self:ShowList(i);
end;
-- 播放技能
function UIToolsRoleSkillDraw : OnPlayerSk()
	local id = self.infolist[self.curskid].id;
	local drawcfg = UIDrawSkillCfg[self.curskid]
	if not drawcfg then drawcfg.Rotation = 0 end;
	self.curAvta.objMesh.transform:setTranslation(0,0,0);
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.curAvta:PlaySkillOnUI(id)
end;
-- 显示list
function UIToolsRoleSkillDraw : ShowList(typec)
	self.list = {};
	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in pairs(self.infolist) do
		if cf.roletype == typec then 
		local vo = {};
		vo.name = cf.name;
		vo.flag = UIDrawSkillCfg[i] and "√" or "";
		vo.skid = cf.id;
		vo.roletype = cf.roletype;
		vo.groupId = cf.groupId;
		table.push(self.list,vo)
		objSwf.list.dataProvider:push(UIData.encode(vo));
		end;
	end;
	objSwf.list:invalidateData();
	objSwf.list.selectedIndex = 0;
	if not self.list[1] then return end;
	self.curskid = self.list[1].groupId;
	self:DrawRole()
end;

-- itemclick
function UIToolsRoleSkillDraw : OnListItemClick(e)
	--local roleid = e.item.roleid;
	local cfg = UIDrawSkillCfg[e.item.groupId];
	if not cfg  then self.meshDir = 0; end;
	if cfg then self.meshDir = cfg.Rotation end;
	self.curskid = e.item.groupId
	self:DrawRole();
end;


-- 使用参数
function UIToolsRoleSkillDraw : OnBtnUserclick()
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
	local rota = tonumber(objSwf.Rotationtxt.text)
	self.objUIDraw.objCamera.eye:set(eyeX,eyeY,eyeZ);
	self.objUIDraw.objCamera.look:set(lookX,lookY,lookZ);
	self.curModel.objMesh.transform:setRotation(0,0,1,rota);

	if not UIDrawSkillCfg[self.curskid] then 
		UIDrawSkillCfg[self.curskid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawSkillCfg[self.curskid];
	cfg.Rotation = rota;

	self:OnCfgChange();
end;

function UIToolsRoleSkillDraw : DrawRole()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	
	local id = self.curskid;
	if id == 0 then return end
	local avatar = CPlayerAvatar:new();
	local roleid = self.infolist[id].roletype
	avatar:Create( 0, roleid );
	self.curModel = avatar;

	avatar:SetProf(roleid);
	local info = t_playerinfo[roleid]
	avatar:SetDress(info.create_dress);
	avatar:SetArms(info.create_arm);

	self.curAvta = avatar;

	local drawcfg = UIDrawSkillCfg[id]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
		UIDrawSkillCfg[id] = drawcfg;
		self:SetListHasCfg(id);
	end;

	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("ToolsRoleskPanelplayer",avatar, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end;	

	
	self.meshDir = drawcfg.Rotation;
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.objUIDraw:SetDraw(true);
	--self:OnCfgChange();
end;
-- 准备人物技能数据
function UIToolsRoleSkillDraw : PrepareInfo()
	for i,info in pairs(t_skill) do 
		if not self.infolist[info.group_id] then 
			if info.showtype <= 4 then
				local vo = {};
				vo.name = info.name ;
				vo.id = info.id;
				vo.groupId = info.group_id;
				vo.roletype = info.showtype;
				self.infolist[info.group_id] = vo;
			end;
		end;
	end;
end;


--设置数据
function UIToolsRoleSkillDraw:SetListHasCfg(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.groupId == id then
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
--人物旋转
function UIToolsRoleSkillDraw : OnRoleRight(state)
	if state == "down" then
		self.modelTurnDir = -1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;
function UIToolsRoleSkillDraw : OnRoleLeft (state)
	if state == "down" then
		self.modelTurnDir = 1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;


function UIToolsRoleSkillDraw:Update()
	--self:SetTexiao()
	self:SetRoleRotation()
end


function UIToolsRoleSkillDraw:SetRoleRotation()
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
	if not UIDrawSkillCfg[self.curskid] then 
		UIDrawSkillCfg[self.curskid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawSkillCfg[self.curskid];
	cfg.Rotation = self.meshDir;
	self:OnCfgChange();
end;


function UIToolsRoleSkillDraw : OnBtnDownclick()
	-- down
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end

end;
function UIToolsRoleSkillDraw : OnBtnUpclick()
	-- up
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsRoleSkillDraw : OnBtnLeftclick()
	--left
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsRoleSkillDraw : OnBtnRightclick()
	--right
		if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;


function UIToolsRoleSkillDraw : OnBtnSmallclick()
	--small
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsRoleSkillDraw : OnBtnMaxclick()
	-- max
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsRoleSkillDraw : OnBtnFuclick()
	-- fu
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsRoleSkillDraw : OnBtnYangclick()
	-- yang
		if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end


-- 配置变动
function UIToolsRoleSkillDraw : OnCfgChange()
	if not self.objUIDraw then return ;end;

	local skid = self.curskid--self.curid;
	if not UIDrawSkillCfg[skid] then 
		UIDrawSkillCfg[skid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawSkillCfg[skid];
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
	objSwf.Rotationtxt.text = cfg.Rotation;
end;

-- 创建配置文件
function UIToolsRoleSkillDraw : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
--	cfg.pfxRotationX = 0;
	return cfg;
end

function UIToolsRoleSkillDraw : OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawRoleSkillConfig.lua');
	file:write("--[[ 人物技能配置文件\nWangshuai\n]]\n".."_G.UIDrawSkillCfg = {\n");
	for id,cfg in pairs(UIDrawSkillCfg) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..cfg.Rotation..",\n")
		--file:write("\t\tpfxRotationX ="..cfg.pfxRotationX..",\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end;

-- 关闭处理
function UIToolsRoleSkillDraw : OnCloseClick()
	self:Hide();
end;
 -- 必要处理
function UIToolsRoleSkillDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.curskid = 0;
end
function UIToolsRoleSkillDraw:GetWidth()
	return 708
end;
function UIToolsRoleSkillDraw:GetHeight()
	return 548
end;