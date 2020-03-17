
_G.UIToolsCollectionShow = BaseUI:new("UIToolsCollectionShow");

UIToolsCollectionShow.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};

UIToolsCollectionShow.currId = 0;
UIToolsCollectionShow.list = {};
							
function UIToolsCollectionShow:Create()
	self:AddSWF( "toolCollectionModelDisplay.swf", true, "center" );
end

function UIToolsCollectionShow:OnLoaded(objSwf,name)
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
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
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

function UIToolsCollectionShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsCollectionShow:GetWidth()
	return 640;
end

function UIToolsCollectionShow:GetHeight()
	return 640;
end

function UIToolsCollectionShow:OnShow(name)
	local configId = 108
	local cfg = t_collection[configId]
	if not cfg then
		Error("don't exist this npc  configId" .. configId)
		return
	end
		
	local modelList = nil
	if cfg.profmodelId and cfg.profmodelId ~= "" then
		modelList = split(cfg.profmodelId, ",")
	end
	if not modelList then
		modelList = {cfg.modelId}
	end
	
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,modelId in pairs(modelList) do
		local listVO = {};
		listVO.name = i;
		listVO.flag = UIDrawCollectionCfg[i] and "√" or "";
		listVO.id = i;
		table.push(self.list,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	self:Draw(self.list[1].id);
	objSwf.list:scrollToIndex(0);
	objSwf.list.selectedIndex = 0;
	-- objSwf.nameLoader.source = ResUtil:GetMagicWeaponNameImg(1)
end

function UIToolsCollectionShow:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end

function UIToolsCollectionShow:OnBtnCloseClick()
	self:Hide()
end

--缩小
function UIToolsCollectionShow:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsCollectionShow:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolsCollectionShow:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsCollectionShow:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsCollectionShow:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsCollectionShow:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsCollectionShow:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsCollectionShow:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolsCollectionShow:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsCollectionShow:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsCollectionShow:Draw(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currId = id;
	local configId = 108
	local cfg = t_collection[configId]
	if not cfg then
		Error("don't exist this npc  configId" .. configId)
		return
	end
	local modelList = nil
	if cfg.profmodelId and cfg.profmodelId ~= "" then
		modelList = split(cfg.profmodelId, ",")
	end
	local lookId = 0
	if modelList and #modelList == 4 then
		lookId = tonumber(modelList[id])
	else
		lookId = cfg.modelId
	end
	
	local avatar = CollectionAvatar:NewCollectionAvatar(configId, 99999)
	avatar:InitAvatar(lookId)
	if t_model[lookId] then
		avatar:ExecAction(t_model[lookId].san_move, true)
	end
	local drawCfg = UIDrawCollectionCfg[id];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawCollectionCfg[id] = drawCfg;
		self:SetListHasCfg(id);
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new( "UIToolsCollectionShow",avatar, UIVipRenew.roleLoaders[1],
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000 );
	else
		self.objUIDraw:SetUILoader(UIVipRenew.roleLoaders[1]);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end
	rotation = drawCfg.Rotation or 0;
	avatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolsCollectionShow:SetListHasCfg(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.id == id then
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
function UIToolsCollectionShow:OnCfgChange()
	if not self.objUIDraw then return; end
	local id = self.currId;
	if not UIDrawCollectionCfg[id] then
		UIDrawCollectionCfg[id] = self:GetDefaultCfg();
	end
	local cfg = UIDrawCollectionCfg[id];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = rotation;
	--显示参数
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
	objSwf.txtRotation.text = cfg.Rotation;
end

function UIToolsCollectionShow:OnListItemClick(e)
	local id = e.item.id;
	self:Draw(id);
end

function UIToolsCollectionShow:OnBtnUseParam()
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

function UIToolsCollectionShow:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawCollectionCfg.lua');
	file:write("_G.UIDrawCollectionCfg = {\n");
	for id,cfg in pairs(UIDrawCollectionCfg) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..cfg.Rotatio.."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolsCollectionShow:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsCollectionShow:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end
