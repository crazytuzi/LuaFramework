--[[
	地宫BOSS模型

]]

_G.UIToolsPalaceBossDraw = BaseUI:new("UIToolsPalaceBossDraw");

UIToolsPalaceBossDraw.list={};
UIToolsPalaceBossDraw.curMonster=0;
UIToolsPalaceBossDraw.defaultCfg = {
										EyePos = _Vector3.new(0,-40,20),
										LookPos = _Vector3.new(0,0,10),
										VPort = _Vector2.new(935,500),
										Rotation = 0
								  }
;

UIToolsPalaceBossDraw.bossList = {[10210015] = 10210015,[10210030] = 10210030,[10210045] = 10210045,[10210060] = 10210060}


UIToolsPalaceBossDraw.rotation = 0;
function UIToolsPalaceBossDraw:Create()
	self:AddSWF("toolPalaceBoss.swf",true,"center");
end;

function UIToolsPalaceBossDraw:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self : OnCloseClick()end

	objSwf.btn_up.click = function () self : OnBtnUpclick()end;
	objSwf.btn_down.click = function () self : OnBtnDownclick()end;
	objSwf.btn_right.click = function () self : OnBtnRightclick()end;
	objSwf.btn_left.click = function () self : OnBtnLeftclick()end;

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

	objSwf.btnTurnLeft.autoRepeat = true;
	objSwf.btnTurnLeft.buttonRepeatDelay = 20;
	objSwf.btnTurnLeft.buttonRepeatDuration = 20;
	objSwf.btnTurnRight.autoRepeat = true;
	objSwf.btnTurnRight.buttonRepeatDelay = 20;
	objSwf.btnTurnRight.buttonRepeatDuration = 20;
	objSwf.btnTurnLeft.click = function() self:OnBtnTurnLeft(); end
	objSwf.btnTurnRight.click = function() self:OnBtnTurnRight(); end
end

function UIToolsPalaceBossDraw:OnDelete()
	if self.objUIDraw then
		self.objUIDraw:SetUILoader(nil);
	end
end

function UIToolsPalaceBossDraw:OnShow()
	for l,k in pairs(UIDrawPalaceBossConfig) do
		if not UIDrawPalaceBossConfig[l] then
			UIDrawPalaceBossConfig[l] = nil;
		end;
	end;
	self:Initlist();
end

function UIToolsPalaceBossDraw : Initlist()
	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i=1,5 do
		local cfg =t_xianyuancave[i];
		local cf = t_monster[cfg.bossID];
		local moModel = i
		local listVo = {};
		listVo.name = cf.name;
		listVo.flag = UIDrawPalaceBossConfig[i] and "√" or "";
		listVo.monsterid = cf.id;
		table.push(self.list,listVo)
		objSwf.list.dataProvider:push(UIData.encode(listVo));

	end
	objSwf.list:invalidateData();
	objSwf.list.selectedIndex = 0;
	--self:DrawBoss(self.bossList[10210015])
end;

function UIToolsPalaceBossDraw : OnListItemClick(e)
	local monsterid = e.item.monsterid;
	self:DrawBoss(monsterid);
end

function UIToolsPalaceBossDraw : OnBtnUserclick()
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
end;

function UIToolsPalaceBossDraw:DrawBoss(monster)
	local objswf = self.objSwf;
	if not objswf then return end;
	self.curMonster = monster;


	local monsterAvater = MonsterAvatar:NewMonsterAvatar(nil,self.curMonster)
	monsterAvater:InitAvatar();
	local drawcfg = UIDrawPalaceBossConfig[monster];
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();

		UIDrawPalaceBossConfig[monster] = drawcfg;
		
		self:SetListHasCfg(self.curMonster);
	end;
	if not self.objUIDraw then 
		self.objUIDraw = UIDraw:new("toolPalaceBoss",monsterAvater, objswf.monsterLoad,
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000,"UIPalaceBossTools");
	else 
		self.objUIDraw:SetUILoader(objswf.monsterLoad);
		self.objUIDraw:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.objUIDraw:SetMesh(monsterAvater);
	end;
	self.rotation = drawcfg.Rotation or 0;
	monsterAvater.objMesh.transform:setRotation( 0, 0, 1, self.rotation );
	self.objUIDraw:SetDraw(true);

	self:OnCfgChange();

	self.objAvatar = monsterAvater;
end

-- 配置变动
function UIToolsPalaceBossDraw : OnCfgChange()
	if not self.objUIDraw then return ;end;
	local monster = self.curMonster;
	if not UIDrawPalaceBossConfig[monster] then
		UIDrawPalaceBossConfig[monster] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawPalaceBossConfig[monster];
	cfg.EyePos = self.objUIDraw.objCamera.eye:clone();
	cfg.LookPos = self.objUIDraw.objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = self.rotation;
	-- 显示参数
	local objSwf = self.objSwf;
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
	objSwf.txtRotation.text = cfg.Rotation;
end;

-- 创建配置文件
function UIToolsPalaceBossDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

--设置数据
function UIToolsPalaceBossDraw:SetListHasCfg(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.list) do
		if listVO.roleid == id then
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

function UIToolsPalaceBossDraw : OnBtnSmallclick()
	--small
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,-1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsPalaceBossDraw : OnBtnMaxclick()
	-- max
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,1,0);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsPalaceBossDraw : OnBtnFuclick()
	-- fu
	if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,-1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsPalaceBossDraw : OnBtnYangclick()
	-- yang
		if self.objUIDraw then
		local newEye = self.objUIDraw.objCamera.eye:add(0,0,1);
		self.objUIDraw.objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolsPalaceBossDraw : OnBtnDownclick()
	-- down
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end

end;
function UIToolsPalaceBossDraw : OnBtnUpclick()
	-- up
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(0,0,-1);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsPalaceBossDraw : OnBtnLeftclick()
	--left
	if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(-1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsPalaceBossDraw : OnBtnRightclick()
	--right
		if self.objUIDraw then
		local newLook = self.objUIDraw.objCamera.look:add(1,0,0);
		self.objUIDraw.objCamera.look = newLook;
		self:OnCfgChange();
	end
end;

function UIToolsPalaceBossDraw:OnBtnTurnLeft()
	if not self.objUIDraw then return ;end;
	self.rotation = self.rotation + 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, self.rotation );
	self:OnCfgChange();
end

function UIToolsPalaceBossDraw:OnBtnTurnRight()
	if not self.objUIDraw then return ;end;
	self.rotation = self.rotation - 0.05;
	self.objUIDraw.objEntity.objMesh.transform:setRotation( 0, 0, 1, self.rotation );
	self:OnCfgChange();
end
--关闭
function UIToolsPalaceBossDraw:OnCloseClick()
	self:Hide();
end

 -- 必要处理
function UIToolsPalaceBossDraw:OnHide()
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
	end
	self.curMonster = 0;
end

function UIToolsPalaceBossDraw : OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawPalaceBossConfig.lua');
	file:write("--[[ 地宫BOSS模型配置文件\nwangyanwei\n]]\n".."_G.UIDrawPalaceBossConfig = {\n");
	for id,cfg in pairs(UIDrawPalaceBossConfig) do
		file:write("\t["..id.."] = \n\t{\n");
		file:write("\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		if cfg.Rotation then
			file:write("\t\tRotation ="..cfg.Rotation.."\n")
		end
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end;