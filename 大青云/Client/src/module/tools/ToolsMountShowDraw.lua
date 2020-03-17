--[[ 
坐骑展示模型编辑工具
wangshuai
2015年8月27日10:42:54
]]

_G.UIToolMountShowDraw = BaseUI:new("UIToolMountShowDraw");

UIToolMountShowDraw.list={};
UIToolMountShowDraw.curid=0;
UIToolMountShowDraw.curModel = nil;
UIToolMountShowDraw.modelTurnDir = 0;--模型旋转方向 0,不旋转;1左;-1右
UIToolMountShowDraw.meshDir = 0; --模型的当前方向

UIToolMountShowDraw.defaultCfg = {
									EyePos = _Vector3.new(0,-100,25),
									LookPos = _Vector3.new(1,0,20),
									VPort = _Vector2.new(1800,1200),
									Rotation = 0,
								  };

function  UIToolMountShowDraw : Create()
	self:AddSWF("toolsMountShowDraw.swf",true,"center");
end;



function UIToolMountShowDraw:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self : OnCloseClick()end

	objSwf.btn_up.click = function () self : OnBtnUpclick()end;
	objSwf.btn_down.click = function () self : OnBtnDownclick()end;
	objSwf.btn_right.click = function  () self : OnBtnRightclick()end;
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
	
end;

function UIToolMountShowDraw:GetHeight()
	return 353;
end

function UIToolMountShowDraw:GetWidth()
	return 370;
end

function UIToolMountShowDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolMountShowDraw:UpdateMask()
	local objSwf = self.objSwf
	if not objSwf then return end
	local wWidth, wHeight = UIManager:GetWinSize()
	objSwf.mcMask._width = wWidth + 100
	objSwf.mcMask._height = wHeight + 100
end

function UIToolMountShowDraw : OnShow()
	--清除数据
	for l,k in pairs(UIDrawMountShowConfig) do
		if not t_mountmodel[l] then
			UIDrawMountShowConfig[l] = nil;
		end;
	end;
	self:InitList();
	self:UpdateMask();

end;
function UIToolMountShowDraw : InitList()

	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in pairs(t_mountmodel) do
		local moModel = i
		local listVo = {};
		listVo.name = cf.name;
		listVo.flag = UIDrawMountShowConfig[i] and "√" or "";
		listVo.mountid = i;
		table.push(self.list,listVo)
		objSwf.list.dataProvider:push(UIData.encode(listVo));
	end;
	objSwf.list:invalidateData();
	objSwf.list.selectedIndex = 0;
	self.id = self.list[1].mountid
	self:DrawMount(self.id)
end;


function UIToolMountShowDraw : OnListItemClick(e)
	local modelid = e.item.mountid;
	--Debug(modelid)
	self:DrawMount(modelid);
end;

function UIToolMountShowDraw : DrawMount(modelid)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self.curid = modelid;


	local mountAvatar = CHorseAvatar:new(self.curid)
	mountAvatar:Create(modelid);
	self.curModel = mountAvatar;

	local drawcfg = UIDrawMountShowConfig[modelid]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();

		UIDrawMountShowConfig[modelid] = drawcfg;
		
		self:SetListHasCfg(self.curid);
	end;

	objSwf.modelload._x = -750;
	objSwf.modelload._y = -460;
	
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("ToolMountShowDraw",mountAvatar, objSwf.modelload,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(mountAvatar);
	end;
	-- 模型旋转
	self.meshDir = drawcfg.Rotation;
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);

	self.objUIDraw:SetDraw(true);

	self:OnCfgChange();

end;

function UIToolMountShowDraw : OnRoleRight(state)
	
	if state == "down" then
		self.modelTurnDir = -1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;
function UIToolMountShowDraw : OnRoleLeft (state)
	if state == "down" then
		self.modelTurnDir = 1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;

function UIToolMountShowDraw:Update()
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
	if not UIDrawMountShowConfig[self.curid] then 
		UIDrawMountShowConfig[self.curid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawMountShowConfig[self.curid];
	cfg.Rotation = self.meshDir;
end
-- 配置变动
function UIToolMountShowDraw : OnCfgChange()
	if not self.objUIDraw then return ;end;

	local mountid = self.curid;
	if not UIDrawMountShowConfig[mountid] then 
		UIDrawMountShowConfig[mountid] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawMountShowConfig[mountid];
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
end;
--设置数据
function UIToolMountShowDraw:SetListHasCfg(mountid)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.mountid == mountid then
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

function UIToolMountShowDraw : OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawMountShowConfig.lua');
	file:write("--[[坐骑模型配置文件\nWangshuai\n]]\n".."_G.UIDrawMountShowConfig = {\n");
	for id,cfg in pairs(UIDrawMountShowConfig) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..cfg.Rotation..",\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end;
-- 使用参数
function UIToolMountShowDraw : OnBtnUserclick()
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
end;

function UIToolMountShowDraw : OnBtnDownclick()
	-- down
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end

end;
function UIToolMountShowDraw : OnBtnUpclick()
	-- up
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolMountShowDraw : OnBtnLeftclick()
	--left
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolMountShowDraw : OnBtnRightclick()
	--right
		if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;


function UIToolMountShowDraw : OnBtnSmallclick()
	--small
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolMountShowDraw : OnBtnMaxclick()
	-- max
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolMountShowDraw : OnBtnFuclick()
	-- fu
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolMountShowDraw : OnBtnYangclick()
	-- yang
		if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end
-- 创建配置文件
function UIToolMountShowDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end
function UIToolMountShowDraw : OnCloseClick()
	self:Hide();
end
 -- 必要处理
function UIToolMountShowDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.curid = 0;
end