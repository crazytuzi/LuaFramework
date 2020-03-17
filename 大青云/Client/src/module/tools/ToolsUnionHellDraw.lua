--[[
工具：调整帮派副本:地宫炼狱boss在UI上的形象
haohu
2015年2月11日11:39:40
]]

_G.UIToolsUnionHellDraw = BaseUI:new("UIToolsUnionHellDraw");

UIToolsUnionHellDraw.defaultCfg = {
	EyePos = _Vector3.new(0,-103,19),
	LookPos = _Vector3.new(4,0,12),
	VPort = _Vector2.new(640,640),
	Rotation =0
};

UIToolsUnionHellDraw.currentId = 0;
UIToolsUnionHellDraw.list = {};
							
function UIToolsUnionHellDraw:Create()
	self:AddSWF("toolsUnionHellDraw.swf", true, "center");
end

function UIToolsUnionHellDraw:OnLoaded(objSwf,name)
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
	--
end

function UIToolsUnionHellDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsUnionHellDraw:OnShow()
	self:UpdateShow();
end

function UIToolsUnionHellDraw:UpdateShow()
	--清除无效数据
	for id, cfg in pairs(UIDrawUnionHellConfig) do
		if not t_guildHell[id] then
			UIDrawUnionHellConfig[id] = nil;
		end
	end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	self.list = {};
	for id, cfg in pairs( t_guildHell ) do
		local listVO = {};
		local monsterId = cfg.bossid;
		local monsterCfg = t_monster[monsterId];
		listVO.name = id .. " " .. monsterCfg.name;
		listVO.flag = UIDrawUnionHellConfig[id] and "√" or "";
		listVO.id = id;
		listVO.monsterId = monsterId;
		table.push( self.list, listVO );
		list.dataProvider:push( UIData.encode( listVO ) );
	end
	list:invalidateData();
	if #self.list <= 0 then return; end
	local selectedItem = self.list[1];
	self:Draw( selectedItem.id, selectedItem.monsterId );
	list:scrollToIndex( 0 );
	list.selectedIndex = 0;
end

function UIToolsUnionHellDraw:GetWidth()
	return 766;
end

function UIToolsUnionHellDraw:GetHeight()
	return 487;
end

function UIToolsUnionHellDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	self.currentId = 0;
end

--缩小
function UIToolsUnionHellDraw:OnBtnZoomOut()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newEye = uidraw.objCamera.eye:add(0, -1, 0);
		uidraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsUnionHellDraw:OnBtnZoomIn()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newEye = uidraw.objCamera.eye:add(0,1,0);
		uidraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolsUnionHellDraw:OnBtnLeft()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newLook = uidraw.objCamera.look:add(-1,0,0);
		uidraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsUnionHellDraw:OnBtnRight()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newLook = uidraw.objCamera.look:add(1,0,0);
		uidraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsUnionHellDraw:OnBtnUp()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newLook = uidraw.objCamera.look:add(0,0,-1);
		uidraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsUnionHellDraw:OnBtnDown()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newLook = uidraw.objCamera.look:add(0,0,1);
		uidraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsUnionHellDraw:OnBtnLookUp()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newEye = uidraw.objCamera.eye:add(0,0,-1);
		uidraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsUnionHellDraw:OnBtnLookDown()
	local uidraw = self.objUIDraw;
	if uidraw then
		local newEye = uidraw.objCamera.eye:add(0,0,1);
		uidraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolsUnionHellDraw:OnBtnTurnLeft()
	local uidraw = self.objUIDraw;
	if uidraw then
		rotation = rotation + 0.05;
		uidraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
		self:OnCfgChange();
	end
end

function UIToolsUnionHellDraw:OnBtnTurnRight()
	local uidraw = self.objUIDraw;
	if uidraw then
		rotation = rotation - 0.05;
		uidraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
		self:OnCfgChange();
	end
end

function UIToolsUnionHellDraw:Draw( id, monsterId )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currentId = id;
	local avatar = MonsterAvatar:NewMonsterAvatar( nil, monsterId );
	avatar:InitAvatar();
	local drawCfg = UIDrawUnionHellConfig[id];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawUnionHellConfig[id] = drawCfg;
		self:SetListHasCfg( id );
	end
	local uidraw = self.objUIDraw;
	if not uidraw then
		uidraw = UIDraw:new( "UIToolsUnionHellDraw", avatar, objSwf.loader,
							drawCfg.VPort, drawCfg.EyePos, drawCfg.LookPos,
							0x00000000 );
		self.objUIDraw = uidraw;
	else
		uidraw:SetUILoader(objSwf.loader);
		uidraw:SetCamera( drawCfg.VPort, drawCfg.EyePos, drawCfg.LookPos );
		uidraw:SetMesh( avatar );
	end
	rotation = drawCfg.Rotation or 0;
	avatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	uidraw:SetDraw(true);
	self:OnCfgChange();
	self:OnDraw();
end

--设置某项有了数据
function UIToolsUnionHellDraw:SetListHasCfg(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i, listVO in ipairs(self.list) do
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
function UIToolsUnionHellDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local currentId = self.currentId;
	if not UIDrawUnionHellConfig[currentId] then
		UIDrawUnionHellConfig[currentId] = self:GetDefaultCfg();
	end
	local cfg = UIDrawUnionHellConfig[currentId];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = rotation;
	--显示参数
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.ipEyeX.text      = cfg.EyePos.x;
	objSwf.ipEyeY.text      = cfg.EyePos.y;
	objSwf.ipEyeZ.text      = cfg.EyePos.z;
	objSwf.ipLookX.text     = cfg.LookPos.x;
	objSwf.ipLookY.text     = cfg.LookPos.y;
	objSwf.ipLookZ.text     = cfg.LookPos.z;
	objSwf.txtRotation.text = cfg.Rotation;
end

function UIToolsUnionHellDraw:OnDraw()
	-- self:PlayAction();
end

function UIToolsUnionHellDraw:OnListItemClick(e)
	local id = e.item.id;
	local monsterId = e.item.monsterId;
	self:Draw(id, monsterId);
end

function UIToolsUnionHellDraw:OnBtnUseParam()
	local uidraw = self.objUIDraw;
	if not uidraw then return; end
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
	uidraw.objCamera.eye:set(eyeX,eyeY,eyeZ);
	uidraw.objCamera.look:set(lookX,lookY,lookZ);
	uidraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rot );
	self:OnCfgChange();
end

function UIToolsUnionHellDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawUnionHellConfig.lua');
	file:write("_G.UIDrawUnionHellConfig = {\n");
	for id, cfg in pairs( UIDrawUnionHellConfig ) do
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

function UIToolsUnionHellDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos   = self.defaultCfg.EyePos:clone();
	cfg.LookPos  = self.defaultCfg.LookPos:clone();
	cfg.VPort    = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsUnionHellDraw:OnBtnCloseClick()
	self:Hide();
end

function UIToolsUnionHellDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currentId = 0;
end
