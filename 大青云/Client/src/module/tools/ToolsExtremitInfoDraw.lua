--[[
	2015年3月23日, PM 09:04:05
	wangyanwei
	极限副本模型工具
]]
_G.UIToolsRxtremityDraw = BaseUI:new("UIToolsRxtremityDraw");

UIToolsRxtremityDraw.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(550,550),
	Rotation = 0
};

UIToolsRxtremityDraw.currNpcId = 0;
UIToolsRxtremityDraw.list = {};

function UIToolsRxtremityDraw:Create()
	self:AddSWF("toolExtremity.swf",true,"center");
end

function UIToolsRxtremityDraw:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnZoomOut.autoRepeat = true;
	objSwf.btnZoomIn.autoRepeat = true;
	objSwf.btnZoomOut.click = function() self:OnBtnZoomOut(); end
	objSwf.btnZoomIn.click = function() self:OnBtnZoomIn(); end
	objSwf.btnLeft.autoRepeat = true;
	objSwf.btnRight.autoRepeat = true;
	objSwf.btnLeft.click = function() self:OnBtnLeft(); end
	objSwf.btnRight.click = function() self:OnBtnRight(); end
	objSwf.btnUp.autoRepeat = true;
	objSwf.btnDown.autoRepeat = true;
	objSwf.btnUp.click = function() self:OnBtnUp(); end
	objSwf.btnDown.click = function() self:OnBtnDown(); end
	objSwf.btnLookUp.autoRepeat = true;
	objSwf.btnLookDown.autoRepeat = true;
	objSwf.btnLookUp.click = function() self:OnBtnLookUp(); end
	objSwf.btnLookDown.click = function() self:OnBtnLookDown(); end

	objSwf.btnTurnLeft.autoRepeat = true;
	objSwf.btnTurnLeft.buttonRepeatDelay = 20;
	objSwf.btnTurnLeft.buttonRepeatDuration = 20;
	objSwf.btnTurnRight.autoRepeat = true;
	objSwf.btnTurnRight.buttonRepeatDelay = 20;
	objSwf.btnTurnRight.buttonRepeatDuration = 20;
	objSwf.btnTurnLeft.click = function() self:OnBtnTurnLeft(); end
	objSwf.btnTurnRight.click = function() self:OnBtnTurnRight(); end
	--
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	objSwf.btnUseParam.click = function() self:OnBtnUseParam(); end
	objSwf.btnSave.click = function() self:OnBtnSave(); end
end

function UIToolsRxtremityDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsRxtremityDraw:OnShow(name)
	--清除无效数据
	for id,cfg in pairs(UIDrawExtremityCfg) do
		if not t_monster[id] then
			UIDrawExtremityCfg[id] = nil;
		end
	end
	--
	local objSwf = self:GetSWF("UIToolsRxtremityDraw");
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,cfg1 in ipairs(t_extremity) do
		local cfg = t_monster[cfg1.bossid];
		local listVO = {};
		listVO.name = cfg.name;
		listVO.flag = UIDrawExtremityCfg[cfg.id] and "√" or "";
		listVO.monsterId = cfg.id;
		table.push(self.list,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	self:DrawNpc(self.list[1].monsterId);
	objSwf.list:scrollToIndex(0);
	objSwf.list.selectedIndex = 0;
end

function UIToolsRxtremityDraw:OnListItemClick(e)
	local monsterId = e.item.monsterId;
	self:DrawNpc(monsterId);
end

function UIToolsRxtremityDraw:DrawNpc(monsterId)
	local objSwf = self:GetSWF("UIToolsRxtremityDraw");
	if not objSwf then return; end
	self.currNpcId = monsterId;
	local monsterAvatar = MonsterAvatar:NewMonsterAvatar(nil,monsterId);

	monsterAvatar:InitAvatar();
	local drawCfg = UIDrawExtremityCfg[monsterId];
	if not drawCfg then


		drawCfg = self:GetDefaultCfg();
		UIDrawExtremityCfg[monsterId] = drawCfg;
		self:SetListHasCfg(monsterId);



	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("toolsExtremityNpc",monsterAvatar, objSwf.npcLoader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000);
	else
		self.objUIDraw:SetUILoader(objSwf.npcLoader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvatar);
	end
	local rotation = drawCfg.Rotation or 0;
	monsterAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolsRxtremityDraw:SetListHasCfg(monsterId)
	local objSwf = self:GetSWF("UIToolsRxtremityDraw");
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.monsterId == monsterId then
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

function UIToolsRxtremityDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local monsterId = self.currNpcId;
	if not UIDrawExtremityCfg[monsterId] then
		UIDrawExtremityCfg[monsterId] = self:GetDefaultCfg();
	end
	local cfg = UIDrawExtremityCfg[monsterId];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = rotation;
	--显示参数
	local objSwf = self:GetSWF("UIToolsRxtremityDraw");
	if not objSwf then return; end
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
	objSwf.txtRotation.text = cfg.Rotation;
end

function UIToolsRxtremityDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsRxtremityDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currNpcId = 0;
end

function UIToolsRxtremityDraw:OnBtnUseParam()
	if not self.objUIDraw then return; end
	local objSwf = self:GetSWF("UIToolsRxtremityDraw");
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
	local rot = objSwf.txtRotation.text;
	if not tonumber(rot) then
		FloatManager:AddNormal("无效的Rotation参数");
		return;
	end
	--
	self.objUIDraw.objCamera.eye:set(eyeX,eyeY,eyeZ);
	self.objUIDraw.objCamera.look:set(lookX,lookY,lookZ);
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rot );
	self:OnCfgChange();
end

local rotation = -0.7;
function UIToolsRxtremityDraw:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsRxtremityDraw:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsRxtremityDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawExtremityCfg.lua');
	file:write("_G.UIDrawExtremityCfg = {\n");
	for npcId,cfg in pairs(UIDrawExtremityCfg) do
		file:write("\t["..npcId.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation =".. rotation .."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

--左移
function UIToolsRxtremityDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsRxtremityDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsRxtremityDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsRxtremityDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsRxtremityDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsRxtremityDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--缩小
function UIToolsRxtremityDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsRxtremityDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--关闭事件
function UIToolsRxtremityDraw:OnBtnCloseClick()
	self:Hide();
end