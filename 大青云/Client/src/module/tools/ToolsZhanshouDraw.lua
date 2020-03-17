--[[
工具：调整灵兽在UI上的形象
]]

_G.UIToolZhanshouDraw = BaseUI:new("UIToolZhanshouDraw");

UIToolZhanshouDraw.defaultCfg = {
	EyePos   = _Vector3.new(0,-60,25),
	LookPos  = _Vector3.new(1,0,20),
	VPort    = _Vector2.new( 1800, 1200 ),
	Rotation = 0
};

UIToolZhanshouDraw.currId = 0;
UIToolZhanshouDraw.list = {};
							
function UIToolZhanshouDraw:Create()
	self:AddSWF( "toolZhanshouModelDisplay.swf", true, "center" );
end

function UIToolZhanshouDraw:OnLoaded(objSwf,name)
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

function UIToolZhanshouDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
	if self.objUIDrawPfx then
		self.objUIDrawPfx:SetUILoader(nil);
	end
end

function UIToolZhanshouDraw:GetWidth()
	return 353;
end

function UIToolZhanshouDraw:GetHeight()
	return 370;
end

function UIToolZhanshouDraw:OnShow(name)
	--清除无效数据
	for id, cfg in pairs(UIDrawZhanshouCfg) do
		if not t_wuhun[id] then
			UIDrawZhanshouCfg[id] = nil;
		end
	end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,cfg in pairs(t_wuhun) do
		local listVO = {};
		listVO.name = cfg.name;
		listVO.flag = UIDrawZhanshouCfg[cfg.id] and "√" or "";
		listVO.id = cfg.id;
		table.push(self.list,listVO);
		FTrace(listVO,'000000000000000000000')
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	self:Draw(self.list[1].id);
	objSwf.list:scrollToIndex(0);
	objSwf.list.selectedIndex = 0;
	objSwf.nameLoader.source = ResUtil:GetWuhunIcon('ls_jyq')
end

function UIToolZhanshouDraw:OnHide()	
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	if self.objUIDrawPfx then
		self.objUIDrawPfx:SetDraw(false);
	end
	self.currId = 0;
end

function UIToolZhanshouDraw:OnBtnCloseClick()	
	self:Hide()
end

--缩小
function UIToolZhanshouDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolZhanshouDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolZhanshouDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolZhanshouDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolZhanshouDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolZhanshouDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolZhanshouDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolZhanshouDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolZhanshouDraw:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolZhanshouDraw:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolZhanshouDraw:Draw(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currId = id;
	local cfg = _G.t_wuhun[id]
	
	
	if not cfg then return end
	local uiCfg = t_lingshouui[cfg.ui_id]
	if not uiCfg then
		FPrint("要显示的武魂ui_id不正确"..cfg.ui_id)
		return
	end
	local modelCfg =t_lingshoumodel[uiCfg.model];
	if not modelCfg then return end
	local avatar = CZhanshouAvatar:new(uiCfg.model)
	local stunActionFile = modelCfg.san_idle;
	avatar:DoAction(stunActionFile,false);
	local drawCfg = UIDrawZhanshouCfg[id];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawZhanshouCfg[id] = drawCfg;
		self:SetListHasCfg(id);
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new( "toolsZhanshou",avatar, objSwf.modelload,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000 );
	else
		self.objUIDraw:SetUILoader(objSwf.modelload);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(avatar);
	end
	-- self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
	rotation = drawCfg.Rotation or 0;
	avatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	-- self.objUIDraw:PlayPfx("zuoqifazhen.pfx");
	if not self.objUIDrawPfx then 
		self.objUIDrawPfx = UIPfxDraw:new("toolsZhanshouShowViewPfx",objSwf.loader,
									_Vector2.new(1800,1200),
									_Vector3.new(0,-100,25),
									_Vector3.new(1,0,20),
									0x00000000);
		self.objUIDrawPfx:PlayPfx("zuoqifazhen.pfx")
	else
		self.objUIDrawPfx:SetUILoader(objSwf.loader);
		self.objUIDrawPfx:SetCamera(_Vector2.new(1800,1200),_Vector3.new(0,-100,25),_Vector3.new(1,0,20));
	end;
	self.objUIDrawPfx:SetDraw(true)
	-- FPrint('self.objUIDrawPfx:SetDraw(true)')
	-- print(debug.traceback())
	
	self:OnCfgChange();
end

--设置某项有了数据
function UIToolZhanshouDraw:SetListHasCfg(id)
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
function UIToolZhanshouDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local id = self.currId;
	if not UIDrawZhanshouCfg[id] then
		UIDrawZhanshouCfg[id] = self:GetDefaultCfg();
	end
	local cfg = UIDrawZhanshouCfg[id];
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

function UIToolZhanshouDraw:OnListItemClick(e)
	local id = e.item.id;
	self:Draw(id);
end

function UIToolZhanshouDraw:OnBtnUseParam()
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

function UIToolZhanshouDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawZhanshouConfig.lua');
	file:write("_G.UIDrawZhanshouCfg = {\n");
	for id,cfg in pairs(UIDrawZhanshouCfg) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..rotation.."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolZhanshouDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

