--[[
	2015年3月13日, AM 11:11:52
	NPC剧情对话框模型设置
	wangyanwei
]]

_G.UIToolsNpcChatFrameDraw = BaseUI:new("UIToolsNpcChatFrameDraw");

UIToolsNpcChatFrameDraw.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(490,320),
	Rotation = 0
};

UIToolsNpcChatFrameDraw.currNpcId = 0;
UIToolsNpcChatFrameDraw.list = {};

function UIToolsNpcChatFrameDraw:Create()
	self:AddSWF("toolChatFrame.swf",true,"center");
end

function UIToolsNpcChatFrameDraw:OnLoaded(objSwf,name)
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

function UIToolsNpcChatFrameDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsNpcChatFrameDraw:OnShow(name)
	--清除无效数据
	for id,cfg in pairs(UIDrawChatNpcCfg) do
		if not t_npc[id] then
			UIDrawChatNpcCfg[id] = nil;
		end
	end
	--
	local objSwf = self:GetSWF("UIToolsNpcChatFrameDraw");
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,cfg in pairs(t_npc) do
		local listVO = {};
		listVO.name = cfg.name;
		listVO.flag = UIDrawChatNpcCfg[cfg.id] and "√" or "";
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

function UIToolsNpcChatFrameDraw:OnListItemClick(e)
	local npcId = e.item.npcId;
	self:DrawNpc(npcId);
end

function UIToolsNpcChatFrameDraw:DrawNpc(npcId)
	local objSwf = self:GetSWF("UIToolsNpcChatFrameDraw");
	if not objSwf then return; end
	self.currNpcId = npcId;
	local npcAvatar = NpcAvatar:NewNpcAvatar(npcId);

	npcAvatar:InitAvatar();
	local drawCfg = UIDrawChatNpcCfg[npcId];
	if not drawCfg then


		drawCfg = self:GetDefaultCfg();
		UIDrawChatNpcCfg[npcId] = drawCfg;
		self:SetListHasCfg(npcId);



	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("toolsChatNpc",npcAvatar, objSwf.npcLoader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000,"UINpc");
	else
		self.objUIDraw:SetUILoader(objSwf.npcLoader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(npcAvatar);
	end
	local rotation = drawCfg.Rotation or 0;
	npcAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolsNpcChatFrameDraw:SetListHasCfg(npcId)
	local objSwf = self:GetSWF("UIToolsNpcChatFrameDraw");
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

local rotation = -0.7;
function UIToolsNpcChatFrameDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local npcId = self.currNpcId;
	local cfg = UIDrawChatNpcCfg[npcId];
	if not UIDrawChatNpcCfg[npcId] then
		cfg = self:GetDefaultCfg();
	end
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = rotation;
	--显示参数
	local objSwf = self:GetSWF("UIToolsNpcChatFrameDraw");
	if not objSwf then return; end
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
	objSwf.txtRotation.text = cfg.Rotation;
end

function UIToolsNpcChatFrameDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsNpcChatFrameDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currNpcId = 0;
end

function UIToolsNpcChatFrameDraw:OnBtnUseParam()
	if not self.objUIDraw then return; end
	local objSwf = self:GetSWF("UIToolsNpcChatFrameDraw");
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

function UIToolsNpcChatFrameDraw:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsNpcChatFrameDraw:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsNpcChatFrameDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawChatNpcConfig.lua');
	file:write("_G.UIDrawChatNpcCfg = {\n");
	for npcId,cfg in pairs(UIDrawChatNpcCfg) do
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
function UIToolsNpcChatFrameDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsNpcChatFrameDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsNpcChatFrameDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsNpcChatFrameDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsNpcChatFrameDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsNpcChatFrameDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--缩小
function UIToolsNpcChatFrameDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsNpcChatFrameDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--关闭事件
function UIToolsNpcChatFrameDraw:OnBtnCloseClick()
	self:Hide();
end