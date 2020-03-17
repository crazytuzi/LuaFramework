--[[
	封妖怪物形象调整工具
	zhangshuhui
	2014年11月21日11:31:21
]]

_G.UIToolsFengyaoMonster = BaseUI:new("UIToolsFengyaoMonster");

UIToolsFengyaoMonster.list={};
UIToolsFengyaoMonster.curMonster=0;
UIToolsFengyaoMonster.curModel = nil;
UIToolsFengyaoMonster.modelTurnDir = 0;--模型旋转方向 0,不旋转;1左;-1右
UIToolsFengyaoMonster.meshDir = 0; --模型的当前方向

UIToolsFengyaoMonster.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(500,600),
									Rotation = 0,
								  };

function  UIToolsFengyaoMonster : Create()
	self:AddSWF("toolsFengYaoMonster.swf",true,"center");
end;



function UIToolsFengyaoMonster:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self : OnCloseClick()end

	objSwf.btn_up.click = function () self : OnBtnUpclick()end;
	objSwf.btn_down.click = function () self : OnBtnDownclick()end;
	objSwf.btn_right.click = function () self : OnBtnRightclick()end;
	objSwf.btn_left.click = function () self : OnBtnLeftclick()end;
	
	objSwf.btnRoleRight.stateChange = function (e) self : OnRoleRight(e.state)end;
	objSwf.btnRoleLeft.stateChange = function (e) self : OnRoleLeft(e.state)end;

	objSwf.btn_up.autoRepeat = true;
	objSwf.btn_down.autoRepeat = true;
	objSwf.btn_right.autoRepeat = true;
	objSwf.btn_left.autoRepeat = true;

	objSwf.btn_small.autoRepeat = true;
	objSwf.btn_max.autoRepeat = true;
	objSwf.btn_yang.autoRepeat = true;
	objSwf.btn_fu.autoRepeat = true;

	objSwf.btn_small.click = function () self : OnBtnSmallclick()end;
	objSwf.btn_max.click = function () self : OnBtnMaxclick()end;
	objSwf.btn_yang.click = function () self : OnBtnYangclick()end;
	objSwf.btn_fu.click = function () self : OnBtnFuclick()end;

	objSwf.btn_user.click = function () self : OnBtnUserclick()end;
	objSwf.btn_save.click = function () self : OnBtnSaveclick()end;

	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end
	
end;

function UIToolsFengyaoMonster:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsFengyaoMonster : OnShow()

	-- 清除无效Config
	local monsterlist = {};
	for i,p in pairs(t_fengyao) do 
		local monsters = split(p.monster_id,',');
		local t = tonumber(monsters[1])
		monsterlist[t] = 0;
	end;

	for id,cfg in pairs(UIDrawFengYaoMonsterConfig) do
		if not monsterlist[id] then
			UIDrawFengYaoMonsterConfig[id] = nil;
		end
	end
	self:InitList();
end;



function UIToolsFengyaoMonster : InitList()

	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in pairs(t_fengyao) do
		local monsters = split(cf.monster_id,',');
		local t = tonumber(monsters[1])
		local moModel = t_monster[t]--.modelId;
		local listVo = {};
		listVo.name = moModel.name;
		listVo.flag = UIDrawFengYaoMonsterConfig[moModel.id] and "√" or "";
		listVo.monsterid = moModel.id;
		table.push(self.list,listVo)
		objSwf.list.dataProvider:push(UIData.encode(listVo));
	end;
	objSwf.list:invalidateData();

end;


function UIToolsFengyaoMonster : OnListItemClick(e)
	local monster = e.item.monsterid;
	self:DrawMonster(monster);
end;

function UIToolsFengyaoMonster : DrawMonster(monster)
	local objswf = self.objSwf;
	if not objswf then return end;
	self.curMonster = monster;


	local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,self.curMonster)
	monsterAvater:InitAvatar();
	self.curModel = monsterAvater;

	local drawcfg = UIDrawFengYaoMonsterConfig[monster]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();

		UIDrawFengYaoMonsterConfig[monster] = drawcfg;
		
		self:SetListHasCfg(self.curMonster);
	end;
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("toolsFengYaoMonster",monsterAvater, objswf.monsterLoad,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else 
		self.objUIDraw:SetUILoader(objswf.monsterLoad);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end;
	-- 模型旋转
	self.meshDir = drawcfg.Rotation;
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	
	self.objUIDraw:SetDraw(true);

	self:OnCfgChange();

end;

function UIToolsFengyaoMonster : OnRoleRight(state)
	
	if state == "down" then
		self.modelTurnDir = -1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;
function UIToolsFengyaoMonster : OnRoleLeft (state)
	if state == "down" then
		self.modelTurnDir = 1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;

function UIToolsFengyaoMonster:Update()
	if self.modelTurnDir == 0 then
		return;
	end
	if not self.curModel then
		return;
	end
	self.meshDir = self.meshDir + math.pi/100*self.modelTurnDir;

	if self.meshDir < 0 then
		self.meshDir = self.meshDir + math.pi*2;
	end

	if self.meshDir > math.pi*2 then
		self.meshDir = self.meshDir - math.pi*2;
	end

	self.curModel.objMesh.transform:setRotation(0,0,1,self.meshDir);
	if not UIDrawFengYaoMonsterConfig[self.curMonster] then 
		UIDrawFengYaoMonsterConfig[self.curMonster] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawFengYaoMonsterConfig[self.curMonster];
	cfg.Rotation = self.meshDir;
end

-- 配置变动
function UIToolsFengyaoMonster : OnCfgChange()
	if not self.objUIDraw then return ;end;
	local monster = self.curMonster;
	if not UIDrawFengYaoMonsterConfig[monster] then 
		UIDrawFengYaoMonsterConfig[monster] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawFengYaoMonsterConfig[monster];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();

	-- 显示参数
	local objSwf = self.objSwf;
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
end;
--设置数据
function UIToolsFengyaoMonster:SetListHasCfg(monsterId)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.monsterid == monsterId then
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

function UIToolsFengyaoMonster : OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawFengYaoMonsterConfig.lua');
	file:write("--[[封妖3D模型配置文件\nzhangshuhui\n]]\n".."_G.UIDrawFengYaoMonsterConfig = {\n");
	for id,cfg in pairs(UIDrawFengYaoMonsterConfig) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		file:write("\t\tRotation ="..cfg.Rotation.."\n")
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end;
-- 使用参数
function UIToolsFengyaoMonster : OnBtnUserclick()
	-- user
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
end;

function UIToolsFengyaoMonster : OnBtnDownclick()
	-- down
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end

end;
function UIToolsFengyaoMonster : OnBtnUpclick()
	-- up
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsFengyaoMonster : OnBtnLeftclick()
	--left
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsFengyaoMonster : OnBtnRightclick()
	--right
		if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;


function UIToolsFengyaoMonster : OnBtnSmallclick()
	--small
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsFengyaoMonster : OnBtnMaxclick()
	-- max
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsFengyaoMonster : OnBtnFuclick()
	-- fu
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsFengyaoMonster : OnBtnYangclick()
	-- yang
		if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end
-- 创建配置文件
function UIToolsFengyaoMonster:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end
function UIToolsFengyaoMonster : OnCloseClick()
	self:Hide();
end
 -- 必要处理
function UIToolsFengyaoMonster:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.curMonster = 0;
end