--[[
翅膀tips工具
lizhuangzhuang
2015年9月8日16:40:44
]]

_G.UIToolWingTipsDraw = BaseUI:new("UIToolWingTipsDraw");

UIToolWingTipsDraw.defaultCfg = {
	EyePos = _Vector3.new(0,-60,10),
	LookPos = _Vector3.new(-5,0,7),
	VPort = _Vector2.new(340,250),
};

UIToolWingTipsDraw.winglist = {};
UIToolWingTipsDraw.list = {};
UIToolWingTipsDraw.currId = 0;

function UIToolWingTipsDraw:Create()
	self:AddSWF("toolsWingTips.swf",true,"center");
end

function UIToolWingTipsDraw:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:Hide(); end
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
	--
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	objSwf.btnUseParam.click = function() self:OnBtnUseParam(); end
	objSwf.btnSave.click = function() self:OnBtnSave(); end
end

function UIToolWingTipsDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolWingTipsDraw:OnShow()
	self.winglist = {};
	for _,cfg in pairs(t_item) do
		if cfg.sub == 13 then
			self.winglist[cfg.id] = cfg;
		end
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i,cfg in pairs(self.winglist) do
		local listVO = {};
		listVO.name = cfg.name;
		listVO.flag = UIDrawWingTipsCfg[cfg.id] and "√" or "";
		listVO.id = cfg.id;
		table.push(self.list,listVO);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	self:DrawModel(self.list[1].id);
	objSwf.list:scrollToIndex(0);
	objSwf.list.selectedIndex = 0;
end

function UIToolWingTipsDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currId = 0;
end

--缩小
function UIToolWingTipsDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolWingTipsDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolWingTipsDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolWingTipsDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolWingTipsDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolWingTipsDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolWingTipsDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolWingTipsDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolWingTipsDraw:DrawModel(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currId = id;
	local itemCfg = t_item[id];
	if not itemCfg then return; end
	local wingCfg = t_wing[itemCfg.link_param];
	if not wingCfg then return; end
	
	local wingAvatar = CAvatar:new();
	wingAvatar.avtName = "wingtips";
	wingAvatar:SetPart("Body",wingCfg.tipsSkn);
	wingAvatar:ChangeSkl(wingCfg.tipsSkl);
	wingAvatar:ExecAction(wingCfg.tipsSan,true);
	
	local drawCfg = UIDrawWingTipsCfg[id];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawWingTipsCfg[id] = drawCfg;
		self:SetListHasCfg(id);
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("WingTipsDrawTool",wingAvatar, objSwf.modelloader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000,"UIWing");
	else
		self.objUIDraw:SetUILoader(objSwf.modelloader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(wingAvatar);
	end
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
end

function UIToolWingTipsDraw:SetListHasCfg(id)
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
function UIToolWingTipsDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local id = self.currId;
	if not UIDrawWingTipsCfg[id] then
		UIDrawWingTipsCfg[id] = self:GetDefaultCfg();
	end
	local cfg = UIDrawWingTipsCfg[id];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	--显示参数
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
end

function UIToolWingTipsDraw:OnListItemClick(e)
	local id = e.item.id;
	self:DrawModel(id);
end

function UIToolWingTipsDraw:OnBtnUseParam()
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
end

function UIToolWingTipsDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawWingTipsCfg.lua');
	file:write("_G.UIDrawWingTipsCfg = {\n");
	for id,cfg in pairs(UIDrawWingTipsCfg) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolWingTipsDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	return cfg;
end