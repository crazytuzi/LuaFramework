--[[
工具：调整NPC在UI上的形象
lizhuangzhuang
2014年10月16日10:06:07
]]

_G.UIToolsNpcDraw = BaseUI:new("UIToolsNpcDraw");

UIToolsNpcDraw.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(800, 800),
	Rotation = 0
};
UIToolsNpcDraw.currNpcId = 0;
UIToolsNpcDraw.list = {};
							
function UIToolsNpcDraw:Create()
	self:AddSWF("toolsNpcDraw.swf",true,"center");
end

function UIToolsNpcDraw:OnLoaded(objSwf,name)
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
	objSwf.btnUse.click = function() self:OnBtnUseClick(); end
	objSwf.btnSave.click = function() self:OnBtnSave(); end
end

function UIToolsNpcDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsNpcDraw:GetHeight()
	return 300;
end

function UIToolsNpcDraw:OnShow(name)
	--清除无效数据
	for id,cfg in pairs(UIDrawNpcCfg) do
		if not t_npc[id] then
			UIDrawNpcCfg[id] = nil;
		end
	end
	--
	local objSwf = self:GetSWF("UIToolsNpcDraw");
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,cfg in pairs(t_npc) do
		local listVO = {};
		listVO.name = cfg.name;
		listVO.flag = UIDrawNpcCfg[cfg.id] and "√" or "";
		listVO.npcId = cfg.id;
		table.push(self.list,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	self:DrawNpc(self.list[1].npcId);
	objSwf.list:scrollToIndex(0);
	objSwf.list.selectedIndex = 0;
end

function UIToolsNpcDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currNpcId = 0;
end

--缩小
function UIToolsNpcDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsNpcDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolsNpcDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsNpcDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsNpcDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsNpcDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsNpcDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsNpcDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolsNpcDraw:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsNpcDraw:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsNpcDraw:DrawNpc(npcId)
	local objSwf = self:GetSWF("UIToolsNpcDraw");
	if not objSwf then return; end
	self.currNpcId = npcId;
	local npcAvatar = NpcAvatar:NewNpcAvatar(npcId);

	npcAvatar:InitAvatar();
	local drawCfg = UIDrawNpcCfg[npcId];
	if not drawCfg then


		drawCfg = self:GetDefaultCfg();
		UIDrawNpcCfg[npcId] = drawCfg;
		self:SetListHasCfg(npcId);



	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("toolsNpc",npcAvatar, objSwf.npcLoader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000,"UINpc");
	else
		self.objUIDraw:SetUILoader(objSwf.npcLoader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(npcAvatar);
	end
	rotation = drawCfg.Rotation or 0;
	npcAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolsNpcDraw:SetListHasCfg(npcId)
	local objSwf = self:GetSWF("UIToolsNpcDraw");
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.npcId == npcId then
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

--配置变动
function UIToolsNpcDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local npcId = self.currNpcId;
	if not UIDrawNpcCfg[npcId] then
		UIDrawNpcCfg[npcId] = self:GetDefaultCfg();
	end
	local cfg = UIDrawNpcCfg[npcId];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = rotation;
	--显示参数
	local objSwf = self:GetSWF("UIToolsNpcDraw");
	if not objSwf then return; end
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
	objSwf.txtRotation.text = cfg.Rotation;
end

function UIToolsNpcDraw:OnListItemClick(e)
	local npcId = e.item.npcId;
	self:DrawNpc(npcId);
end

function UIToolsNpcDraw:OnBtnUseParam()
	if not self.objUIDraw then return; end
	local objSwf = self:GetSWF("UIToolsNpcDraw");
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

function UIToolsNpcDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawNpcConfig.lua');
	file:write("_G.UIDrawNpcCfg = {\n");
	for npcId,cfg in pairs(UIDrawNpcCfg) do
		file:write("\t["..npcId.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..rotation.."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

--同步
function UIToolsNpcDraw:OnBtnUseClick()
	local npcId = self.currNpcId;
	local currNpcCfg = t_npc[self.currNpcId];
	local currCfg = UIDrawNpcCfg[npcId];
	if not currCfg then return; end
	for npcId,cfg in pairs(UIDrawNpcCfg) do
		local npcCfg = t_npc[npcId];
		if npcId ~= self.currNpcId and currNpcCfg.look==npcCfg.look then
			cfg.EyePos = currCfg.EyePos:clone();
			cfg.LookPos = currCfg.LookPos:clone();
			cfg.VPort = _Vector2.new(currCfg.VPort.x,currCfg.VPort.y);
			cfg.Rotation = currCfg.Rotation;
		end
	end
end

function UIToolsNpcDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsNpcDraw:OnBtnCloseClick()
	self:Hide();
end

function UIToolsNpcDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currNpcId = 0;
end
