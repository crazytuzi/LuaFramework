--[[
工具：调整神兵在UI上的形象
haohu
2015年6月30日14:52:07
]]

_G.UIToolsMingYuDraw = BaseUI:new("UIToolsMingYuDraw");

UIToolsMingYuDraw.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};

UIToolsMingYuDraw.currId = 0;
UIToolsMingYuDraw.list = {};
							
function UIToolsMingYuDraw:Create()
	self:AddSWF( "toolMingYuModelDisplay.swf", true, "center" );
end

function UIToolsMingYuDraw:OnLoaded(objSwf,name)
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

function UIToolsMingYuDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsMingYuDraw:GetWidth()
	return 640;
end

function UIToolsMingYuDraw:GetHeight()
	return 640;
end

function UIToolsMingYuDraw:OnShow(name)
	--清除无效数据
	for id, cfg in pairs(UIDrawMingYuCfg) do
		if not t_mingyu[id] then
			UIDrawMingYuCfg[id] = nil;
		end
	end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,cfg in pairs(t_mingyu) do
		local listVO = {};
		listVO.name = cfg.name;
		listVO.flag = UIDrawMingYuCfg[cfg.id] and "√" or "";
		listVO.id = cfg.id;
		table.push(self.list,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	self:Draw(self.list[1].id);
	objSwf.list:scrollToIndex(0);
	objSwf.list.selectedIndex = 0;
	objSwf.nameLoader.source = ResUtil:GetMingYuNameImg(1)
end

function UIToolsMingYuDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end

function UIToolsMingYuDraw:OnBtnCloseClick()
	self:Hide()
end

--缩小
function UIToolsMingYuDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsMingYuDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolsMingYuDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsMingYuDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsMingYuDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsMingYuDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsMingYuDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsMingYuDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolsMingYuDraw:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 1, 0, rotation );
	self:OnCfgChange();
end

function UIToolsMingYuDraw:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 1, 0, rotation );
	self:OnCfgChange();
end

function UIToolsMingYuDraw:Draw(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currId = id;
	local cfg = _G.t_mingyu[id]
	if not cfg then return end
	local modelCfg = _G.t_mingyumodel[cfg.model]
	if not modelCfg then return end
	local avatar = MingYuFigure:new( modelCfg, cfg.liuguang, cfg.liu_speed )
	avatar:ExecMoveAction()
	local drawCfg = UIDrawMingYuCfg[id];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawMingYuCfg[id] = drawCfg;
		self:SetListHasCfg(id);
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new( "toolsMingYu",avatar, objSwf.loader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000 );
	else
		self.objUIDraw:SetUILoader(objSwf.loader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end
	rotation = drawCfg.Rotation or 0;
	avatar.objMesh.transform:setRotation( 0, 1, 0, rotation );
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolsMingYuDraw:SetListHasCfg(id)
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
function UIToolsMingYuDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local id = self.currId;
	if not UIDrawMingYuCfg[id] then
		UIDrawMingYuCfg[id] = self:GetDefaultCfg();
	end
	local cfg = UIDrawMingYuCfg[id];
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

function UIToolsMingYuDraw:OnListItemClick(e)
	local id = e.item.id;
	self:Draw(id);
end

function UIToolsMingYuDraw:OnBtnUseParam()
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
	rotation = tonumber(rot)
	if not tonumber(rot) then
		FloatManager:AddNormal("无效的Rotation参数");
		return;
	end
	--
	self.objUIDraw.objCamera.eye:set(eyeX,eyeY,eyeZ);
	self.objUIDraw.objCamera.look:set(lookX,lookY,lookZ);
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 1, 0, rot );
	self:OnCfgChange();
end

function UIToolsMingYuDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawMingYuConfig.lua');
	file:write("_G.UIDrawMingYuCfg = {\n");
	for id,cfg in pairs(UIDrawMingYuCfg) do
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

function UIToolsMingYuDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsMingYuDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end
