
_G.UIToolsVipShow = BaseUI:new("UIToolsVipShow");

UIToolsVipShow.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};

UIToolsVipShow.currId = 0;
UIToolsVipShow.list = {};
							
function UIToolsVipShow:Create()
	self:AddSWF( "toolVipModelDisplay.swf", true, "top" );
end

function UIToolsVipShow:OnLoaded(objSwf,name)
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

function UIToolsVipShow:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsVipShow:GetWidth()
	return 640;
end

function UIToolsVipShow:GetHeight()
	return 640;
end
function UIToolsVipShow:CheckList(modelList, modelId)
	for i,n in pairs (modelList) do
		if n == modelId then
			return false
		end
	end
	
	return true
end
function UIToolsVipShow:OnShow(name)
	local modelList = {}
	for k,v in pairs (t_viptype) do
		if self:CheckList(modelList, toint(v.model)) then
			table.insert(modelList, toint(v.model))
		end
	end
	for k,v in pairs (t_vip) do
		local vipModel = v.vipShowModel
		if v.vip_id == 11 then
			local modelprofList = split(v.vipShowModel, "#")
			for i,n in pairs (modelprofList) do
				vipModel = toint(n)
				if self:CheckList(modelList, toint(vipModel)) then
					table.insert(modelList, toint(vipModel))		
				end
			end
		else
			if self:CheckList(modelList, toint(vipModel)) then
				table.insert(modelList, toint(vipModel))		
			end
		end
	end
	
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,modelId in pairs(modelList) do
		local listVO = {};
		listVO.name = modelId;
		listVO.flag = UIDrawVipCfg[modelId] and "√" or "";
		listVO.id = modelId;
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

function UIToolsVipShow:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end

function UIToolsVipShow:OnBtnCloseClick()
	self:Hide()
end

--缩小
function UIToolsVipShow:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsVipShow:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolsVipShow:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsVipShow:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsVipShow:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsVipShow:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsVipShow:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsVipShow:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolsVipShow:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsVipShow:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsVipShow:Draw(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currId = id;
	local drawCfg = UIDrawVipCfg[id];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawVipCfg[id] = drawCfg;
		self:SetListHasCfg(id);
	end
	
	local loader = UIVipRenew.roleLoaders[1];
	local name      = 'UIToolsVipShow'
	local cameraPos = drawCfg.EyePos;
	local lookPos   = drawCfg.LookPos;
	local vport     = drawCfg.VPort;
	local objAvatar = VipAvatar:new(id)
	local objUIDraw = UIDrawManager:GetUIDraw( name );
	if not objUIDraw then
		objUIDraw = UIDraw:new( name, objAvatar, loader, vport, cameraPos, lookPos, 0x00000000);
		self.objUIDraw = objUIDraw;
	else
		objUIDraw:SetUILoader(loader);
		objUIDraw:SetCamera( vport, cameraPos, lookPos );
		objUIDraw:SetMesh( objAvatar );
	end
	objAvatar.objMesh.transform:setRotation( 0, 0, 1, drawCfg.Rotation );
	
	objUIDraw:SetDraw(true);
	
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolsVipShow:SetListHasCfg(id)
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
function UIToolsVipShow:OnCfgChange()
	if not self.objUIDraw then return; end
	local id = self.currId;
	if not UIDrawVipCfg[id] then		
		UIDrawVipCfg[id] = self:GetDefaultCfg();
	end
	local cfg = UIDrawVipCfg[id];
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

function UIToolsVipShow:OnListItemClick(e)
	local id = e.item.id;
	self:Draw(id);
end

function UIToolsVipShow:OnBtnUseParam()
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

function UIToolsVipShow:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawVipCfg.lua');
	file:write("_G.UIDrawVipCfg = {\n");
	for id,cfg in pairs(UIDrawVipCfg) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..cfg.Rotation.."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolsVipShow:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsVipShow:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end
