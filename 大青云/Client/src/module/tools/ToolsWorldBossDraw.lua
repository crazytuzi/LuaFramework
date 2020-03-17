--[[
工具：调整世界boss在UI上的形象
haohu
2014年12月25日17:51:44
]]

_G.UIToolsWorldBossDraw = BaseUI:new("UIToolsWorldBossDraw");

UIToolsWorldBossDraw.defaultCfg = {
	EyePos   = _Vector3.new( 0, -40, 20 ),
	LookPos  = _Vector3.new( 0, 0, 10 ),
	VPort    = _Vector2.new( 2000, 1600 ),
	Rotation = 0
};

UIToolsWorldBossDraw.currmonsterId = 0;
UIToolsWorldBossDraw.list = {};
							
function UIToolsWorldBossDraw:Create()
	self:AddSWF("toolsWorldBossDraw.swf", true, "center");
end

function UIToolsWorldBossDraw:OnLoaded(objSwf,name)
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
	objSwf.btnSkill.click = function() self:OnBtnSkillClick(); end
end

function UIToolsWorldBossDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsWorldBossDraw:OnShow()
	--清除无效数据
	for id,cfg in pairs(UIDrawWorldBossConfig) do
		if not t_monster[id] then
			UIDrawWorldBossConfig[id] = nil;
		end
	end
	--
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.list.dataProvider:cleanUp();
	self.list = {};
	for i, cfg in pairs( t_worldboss ) do
		local monsterCfg = t_monster[cfg.monster];
		local listVO = {};
		listVO.name = monsterCfg.name;
		listVO.flag = UIDrawWorldBossConfig[monsterCfg.id] and "√" or "";
		listVO.monsterId = monsterCfg.id;
		listVO.bossId = cfg.id;
		table.push( self.list, listVO );
		objSwf.list.dataProvider:push( UIData.encode( listVO ) );
	end
	objSwf.list:invalidateData();
	if #self.list <= 0 then return; end
	local selectedItem = self.list[1];
	self:DrawBoss( selectedItem.bossId, selectedItem.monsterId );
	objSwf.list:scrollToIndex( 0 );
	objSwf.list.selectedIndex = 0;
end

function UIToolsWorldBossDraw:GetWidth()
	return 919;
end

function UIToolsWorldBossDraw:GetHeight()
	return 648;
end

function UIToolsWorldBossDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currmonsterId = 0;
end

--缩小
function UIToolsWorldBossDraw:OnBtnZoomOut()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--放大
function UIToolsWorldBossDraw:OnBtnZoomIn()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--左移
function UIToolsWorldBossDraw:OnBtnLeft()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--右移
function UIToolsWorldBossDraw:OnBtnRight()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--上移
function UIToolsWorldBossDraw:OnBtnUp()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--下移
function UIToolsWorldBossDraw:OnBtnDown()
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end

--仰视
function UIToolsWorldBossDraw:OnBtnLookUp()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

--俯视
function UIToolsWorldBossDraw:OnBtnLookDown()
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

local rotation = 0;
function UIToolsWorldBossDraw:OnBtnTurnLeft()
	rotation = rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsWorldBossDraw:OnBtnTurnRight()
	rotation = rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self:OnCfgChange();
end

function UIToolsWorldBossDraw:OnBtnSkillClick()
	self:PlaySkill();
end

function UIToolsWorldBossDraw:DrawBoss( bossId, monsterId )
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self.currbossId = bossId;
	self.currmonsterId = monsterId;
	local avatar = MonsterAvatar:NewMonsterAvatar( nil, monsterId );
	avatar:InitAvatar();
	local drawCfg = UIDrawWorldBossConfig[monsterId];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawWorldBossConfig[monsterId] = drawCfg;
		self:SetListHasCfg( monsterId );
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new( "toolsWorldBoss", avatar, objSwf.bossLoader,
							drawCfg.VPort, drawCfg.EyePos, drawCfg.LookPos,
							0x00000000 );
	else
		self.objUIDraw:SetUILoader(objSwf.bossLoader);
		self.objUIDraw:SetCamera( drawCfg.VPort, drawCfg.EyePos, drawCfg.LookPos );
		self.objUIDraw:SetMesh( avatar );
	end
	rotation = drawCfg.Rotation or 0;
	avatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	self:OnCfgChange();
	self:OnDrawBoss();
end

--设置某项有了数据
function UIToolsWorldBossDraw:SetListHasCfg(monsterId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i, listVO in ipairs(self.list) do
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

--配置变动
function UIToolsWorldBossDraw:OnCfgChange()
	if not self.objUIDraw then return; end
	local monsterId = self.currmonsterId;
	if not UIDrawWorldBossConfig[monsterId] then
		UIDrawWorldBossConfig[monsterId] = self:GetDefaultCfg();
	end
	local cfg = UIDrawWorldBossConfig[monsterId];
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

function UIToolsWorldBossDraw:OnDrawBoss()
	self:PlaySkill();
end

function UIToolsWorldBossDraw:OnListItemClick(e)
	local bossId = e.item.bossId;
	local monsterId = e.item.monsterId;
	self:DrawBoss(bossId, monsterId);
end

function UIToolsWorldBossDraw:OnBtnUseParam()
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

function UIToolsWorldBossDraw:OnBtnSave()
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawWorldBossConfig.lua');
	file:write("_G.UIDrawWorldBossConfig = {\n");
	for monsterId, cfg in pairs( UIDrawWorldBossConfig ) do
		file:write("\t["..monsterId.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..rotation.."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end

function UIToolsWorldBossDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos   = self.defaultCfg.EyePos:clone();
	cfg.LookPos  = self.defaultCfg.LookPos:clone();
	cfg.VPort    = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function UIToolsWorldBossDraw:OnBtnCloseClick()
	self:Hide();
end

function UIToolsWorldBossDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.currmonsterId = 0;
end

function UIToolsWorldBossDraw:PlaySkill()
	local bossId = self.currbossId;
	local avatar = self.objUIDraw and self.objUIDraw.objEntity;
	if avatar then
		local bossCfg = t_worldboss[bossId];
		if not bossCfg then return; end
		local skillId = bossCfg.skill;
		avatar:PlaySkillOnUI( skillId );
	end
end
