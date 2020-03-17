--[[
竞技场人物明编译工具
wangshuai
]]

_G.UIToolsArenaRoleDraw = BaseUI:new("UIToolsArenaRoleDraw")

UIToolsArenaRoleDraw.curIndex = 0;
UIToolsArenaRoleDraw.curModelIndex = 0;
UIToolsArenaRoleDraw.curlist  = {};
UIToolsArenaRoleDraw.curModel = nil;
UIToolsArenaRoleDraw.curModelDir = 0; -- 当前模型方向
UIToolsArenaRoleDraw.curTexDir = 0; -- 当前特效方向
UIToolsArenaRoleDraw.curTexName = 0; --  播放名字，
UIToolsArenaRoleDraw.curTexName2 = 0; -- 关闭名字，
UIToolsArenaRoleDraw.modelTurnDir = 0; -- 模型旋转方向
UIToolsArenaRoleDraw.meshDir = 0;-- 模型当前的方向
UIToolsArenaRoleDraw.curtexDri = 0; -- 当前特效 0,不旋转;1上;-1下
UIToolsArenaRoleDraw.texDri = 0; -- 特效当前方向
UIToolsArenaRoleDraw.allNewModel = {}
UIToolsArenaRoleDraw.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
									VPort = _Vector2.new(640,900),
								  }
UIToolsArenaRoleDraw.RoleModeList = {};


UIToolsArenaRoleDraw.taiZiList = {};
UIToolsArenaRoleDraw.roleYMove = 0;
UIToolsArenaRoleDraw.roleScaleValue = 0;
UIToolsArenaRoleDraw.roleYMoveValue = 0; 
UIToolsArenaRoleDraw.roleXMoveValue = 0; 
UIToolsArenaRoleDraw.roleScale = 0;
function UIToolsArenaRoleDraw : Create()
	self:AddSWF("toolsArenaRoleModelDraw.swf",true,"center")
end;

function UIToolsArenaRoleDraw:OnLoaded(objSwf)
	objSwf.btnClose.click = function () self:CloseClick()end;
	objSwf.btn_frist.click = function () self:SwitchClick()end;

	for i=1,4 do 
		objSwf.beRolePanel["btn_Model"..i].click = function () self:ModelClick(i)end;
	end;

	for c=5,7 do 
		objSwf.fristpanel["btn_Model"..c].click = function () self:ModelClick(c)end;
	end;

	objSwf.list.itemClick = function (e) self:ItemClickFun(e)end;

	-- 上下左右
	objSwf.btn_up.click = function () self : OnBtnUpclick()end;
	objSwf.btn_down.click = function () self : OnBtnDownclick()end;
	objSwf.btn_right.click = function () self : OnBtnRightclick()end;
	objSwf.btn_left.click = function () self : OnBtnLeftclick()end;
	objSwf.btn_up.autoRepeat = true;
	objSwf.btn_down.autoRepeat = true;
	objSwf.btn_right.autoRepeat = true;
	objSwf.btn_left.autoRepeat = true;

		-- 大小仰俯
	objSwf.btn_small.click = function () self : OnBtnSmallclick()end;
	objSwf.btn_max.click = function () self : OnBtnMaxclick()end;
	objSwf.btn_yang.click = function () self : OnBtnYangclick()end;
	objSwf.btn_fu.click = function () self : OnBtnFuclick()end;
	objSwf.btn_small.autoRepeat = true;
	objSwf.btn_max.autoRepeat = true;
	objSwf.btn_yang.autoRepeat = true;
	objSwf.btn_fu.autoRepeat = true;

	-- -- 旋转

	-- objSwf.btnRoleRight.stateChange = function (e) self : OnRoleRight(e.state)end;
	-- objSwf.btnRoleLeft.stateChange = function (e) self : OnRoleLeft(e.state)end;


	--保存
	objSwf.btn_save.click = function () self : OnBtnSaveclick()end;
	--使用数据
	objSwf.btn_user.click = function () self : OnBtnUserclick()end;

	--人物放大缩小
	objSwf.roleMax.click = function() self:RoleMaxClick()end;
	objSwf.roleMini.click = function() self:RoleMiniClick()end;
	--人物y轴移动
	objSwf.roleYjia.click = function() self:RoleYChangejia()end;
	objSwf.roleYjian.click = function() self:RoleYChangejian()end;

	objSwf.roleYjia.autoRepeat = true;
	objSwf.roleYjian.autoRepeat = true;
	objSwf.roleMax.autoRepeat = true;
	objSwf.roleMini.autoRepeat = true;
end;

function UIToolsArenaRoleDraw:OnDelete()
	for _,objUIDraw in pairs(self.allNewModel) do
		objUIDraw:SetUILoader(nil);
	end
end

function UIToolsArenaRoleDraw:RoleMaxClick()
	self.roleScale = 1;
	self:SetRoleScale();
end;
function UIToolsArenaRoleDraw:RoleMiniClick()
	self.roleScale = -1;
	self:SetRoleScale();
end;
function UIToolsArenaRoleDraw:RoleYChangejia()
	self.roleYMove = -1;
	self:SetRoleYMove()
end;
function UIToolsArenaRoleDraw:RoleYChangejian()
	self.roleYMove = 1;
	self:SetRoleYMove()
end;

-- Z 轴调整
function UIToolsArenaRoleDraw:SetRoleYMove()
	local cfg = UIDrawArenaCfg[self.curIndex][self.curModelIndex]
	if not cfg then 
		UIDrawArenaCfg[self.curIndex][self.curModelIndex] = self:GetDefaultCfgRole();
		cfg = UIDrawArenaCfg[self.curIndex][self.curModelIndex]
	end;
	self.roleYMoveValue = cfg.roleZ;
	self.roleYMoveValue = self.roleYMoveValue + (self.roleYMove / 2);
	-- 设置当前模型，z轴坐标
	self.curModel.objMesh.transform:mulTranslationLeft(0,0,(self.roleYMove / 2));
	UIDrawArenaCfg[self.curIndex][self.curModelIndex].roleZ = self.roleYMoveValue;
end;
-- 放大缩小
function UIToolsArenaRoleDraw:SetRoleScale()
	local cfg = UIDrawArenaCfg[self.curIndex][self.curModelIndex]
	if not cfg then 
		UIDrawArenaCfg[self.curIndex][self.curModelIndex] = self:GetDefaultCfgRole();
		cfg = UIDrawArenaCfg[self.curIndex][self.curModelIndex]
	end;
	self.roleScaleValue = cfg.scale;
	self.roleScaleValue = self.roleScaleValue +(self.roleScale / 20)
	-- 设置大小
	self.curModel.objMesh.transform:setScaling(self.roleScaleValue,self.roleScaleValue,self.roleScaleValue);
	-- 重新设置z轴坐标
	self.curModel.objMesh.transform:mulTranslationLeft(0,0,self.roleYMoveValue);
	UIDrawArenaCfg[self.curIndex][self.curModelIndex].scale = self.roleScaleValue

end;

function UIToolsArenaRoleDraw:OnShow()
	local objSwf = self.objSwf;
	objSwf.fristpanel._visible = false;
	objSwf.beRolePanel._visible = true;

	self.curIndex = 1;
	self.curModelIndex = 1;
end;

function UIToolsArenaRoleDraw:OnHide()
	self.curIndex = 0;
	self.curModelIndex = 0;

	for i,info in pairs(self.allNewModel) do
		if info then 
		info:SetDraw(false);
		end;
	end;
end;

function UIToolsArenaRoleDraw:ItemClickFun(e)
	self.curModelIndex = e.item.roleid;

		--得到当前配置角度
	if not UIDrawArenaCfg[self.curIndex] then UIDrawArenaCfg[self.curIndex] = {} end;
	local cfg = UIDrawArenaCfg[self.curIndex];
	if not cfg then self.meshDir = 0 end;
	if cfg then self.meshDir = cfg.Rotation end;
	
	self:DrawRole();
end;
function UIToolsArenaRoleDraw:ModelClick(i)
	self.curIndex = i;
	self:ShowList()
	self:DrawRole();

end;

-- 画模型
function UIToolsArenaRoleDraw:DrawRole()
	local  objSwf = self.objSwf;
	if not objSwf then return end;
	local id = self.curModelIndex
	-- avatar
	local avatar = CPlayerAvatar:new();
	avatar:Create( 0, id );
	avatar:SetProf(id);
	local info = t_playerinfo[id]
	avatar:SetDress(info.dress);
	avatar:SetArms(info.arm);
	self.curModel = avatar;

	local drawcfg = UIDrawArenaCfg[self.curIndex];
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
		if not UIDrawArenaCfg[self.curIndex] then UIDrawArenaCfg[self.curIndex] = {} end;
		UIDrawArenaCfg[self.curIndex] = drawcfg;
		--self:SetListHasCfg(id)
	end;
	local load = nil;
		print("赋值load",self.curIndex)
	if self.curIndex <= 4 then 
		load = objSwf.beRolePanel["model"..self.curIndex]
	else
		load = objSwf.fristpanel["model"..self.curIndex]
	end;
	if not self.allNewModel[self.curIndex] then 
	 	self.allNewModel[self.curIndex] = UIDraw:new("ArenaRoleplayer"..self.curIndex,avatar, load,  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else
		self.allNewModel[self.curIndex]:SetUILoader(load);
		self.allNewModel[self.curIndex]:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.allNewModel[self.curIndex]:SetMesh(avatar);
	end;

	
	--画台子
	if not self.taiZiList[self.curIndex] then 
		local type = 1 ;
		if self.curIndex == 5 then 
			type = 2
		elseif self.curIndex == 6 then 
			type = 3;
		else
			type = 1
		end;
		self.taiZiList[self.curIndex] = CAvatar:new();
		self.taiZiList[self.curIndex].avtName = "taizi1";
		self.taiZiList[self.curIndex].cid = 0;
		self.taiZiList[self.curIndex]:SetPart("body", "jingjitai"..type.."01.skn")
		self.taiZiList[self.curIndex]:ChangeSkl("jingjitai"..type.."01.skl")
		self.taiZiList[self.curIndex]:SetIdleAction("jingjitai"..type.."01.san", true);
		self.allNewModel[self.curIndex]:AddChildEntity("taizi",self.taiZiList[self.curIndex])
	end;

	if not drawcfg[self.curModelIndex] then 
		drawcfg[self.curModelIndex] = self:GetDefaultCfgRole();
		self:SetListHasCfg(id)
	end;
	-- 设置人物坐标大小
	local scale = drawcfg[self.curModelIndex].scale
	local roleZ = drawcfg[self.curModelIndex].roleZ

	self.curModel.objMesh.transform:setScaling(scale,scale,scale);
	-- 重新设置z轴坐标
	self.curModel.objMesh.transform:mulTranslationLeft(0,0,roleZ);

	self.allNewModel[self.curIndex]:SetDraw(true);
	self:OnCfgChange();


end;	


--设置数据
function UIToolsArenaRoleDraw:SetListHasCfg(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,listVO in ipairs(self.curlist) do
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

function UIToolsArenaRoleDraw:OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawArenaConfig.lua');
	file:write("--[[ 竞技场人物模型配置文件\nWangshuai\n]]\n".."_G.UIDrawArenaCfg = {\n");
	for id,cfg in ipairs(UIDrawArenaCfg) do
		file:write("\t["..id.."] = \n\t{\n")
		file:write("\t\t\tEyePos = _Vector3.new(" ..cfg.EyePos.x.. "," ..cfg.EyePos.y.. "," ..cfg.EyePos.z .."),\n");
		file:write("\t\t\tLookPos = _Vector3.new(" ..cfg.LookPos.x.. "," ..cfg.LookPos.y.. "," ..cfg.LookPos.z .."),\n");
		file:write("\t\t\tVPort = _Vector2.new(" .. cfg.VPort.x.. "," ..cfg.VPort.y.. "),\n");
		for i,info in ipairs(cfg) do 
			file:write("\t\t["..i.."] = \n\t\t{\n");
			file:write("\t\t\troleZ ="..info.roleZ..",\n")
			file:write("\t\t\tscale ="..info.scale..",\n")
			file:write("\t\t},\n");
		end;
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end;

-- 配置变动
function UIToolsArenaRoleDraw:OnCfgChange()
	local uDraw = self.allNewModel[self.curIndex]; -- 当前Draw模型
	if not uDraw then return ;end;
	if not UIDrawArenaCfg[self.curIndex] then 
		UIDrawArenaCfg[self.curIndex] = {};
	end;
	if not UIDrawArenaCfg[self.curIndex] then 
		UIDrawArenaCfg[self.curIndex] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawArenaCfg[self.curIndex];


	cfg.EyePos = self.allNewModel[self.curIndex].objCamera.eye:clone();
	--print(cfg.EyePos.x,cfg.EyePos.y,cfg.EyePos.z)
	cfg.LookPos =self.allNewModel[self.curIndex].objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.taiZi = self.taiziZoomValue;
	-- 显示参数
	local objSwf = self.objSwf;
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
end;


-- 使用参数
function UIToolsArenaRoleDraw:OnBtnUserclick()
	-- user
	if not self.allNewModel[self.curIndex] then return; end
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
	self.allNewModel[self.curIndex].objCamera.eye:set(eyeX,eyeY,eyeZ);
	self.allNewModel[self.curIndex].objCamera.look:set(lookX,lookY,lookZ);
	self:OnCfgChange();
end;

--显示list
function UIToolsArenaRoleDraw:ShowList()
	local objSwf = self.objSwf;
	local cfg = UIDrawArenaCfg[self.curIndex];
	if not cfg then cfg = {} end;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in ipairs(t_playerinfo) do 
		local vo = {};
		vo.name = cf.name;
		vo.flag = cfg[i] and "√" or "";
		vo.roleid = i;
		table.push(self.curlist,vo);
		objSwf.list.dataProvider:push(UIData.encode(vo));
	end;
	objSwf.list:invalidateData();
end;
--切换面板
function UIToolsArenaRoleDraw:SwitchClick()
	local objSwf = self.objSwf;

	objSwf.fristpanel._visible = not objSwf.fristpanel._visible;
	objSwf.beRolePanel._visible = not objSwf.beRolePanel._visible;
end;

function UIToolsArenaRoleDraw:OnBtnDownclick()
	-- down
	if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(0,0,1);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end

end;
function UIToolsArenaRoleDraw:OnBtnUpclick()
	-- up
	if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(0,0,-1);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsArenaRoleDraw:OnBtnLeftclick()
	--left
	if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(-1,0,0);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsArenaRoleDraw:OnBtnRightclick()
	--right
		if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(1,0,0);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end
end;

function UIToolsArenaRoleDraw:OnBtnSmallclick()
	--small
	if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,-1,0);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsArenaRoleDraw:OnBtnMaxclick()
	-- max
	if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,1,0);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsArenaRoleDraw:OnBtnFuclick()
	-- fu
	if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,0,-1);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsArenaRoleDraw:OnBtnYangclick()
	-- yang
		if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,0,1);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end


--创建配置文件
function UIToolsArenaRoleDraw:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	return cfg;
end

function UIToolsArenaRoleDraw:GetDefaultCfgRole()
	local cfg = {};
	cfg.scale =1;
	cfg.roleZ = 0;
	return cfg;
end;
function UIToolsArenaRoleDraw:CloseClick()
	self:Hide();
end;

function UIToolsArenaRoleDraw:GetWidth()
	return 1300
end;

function UIToolsArenaRoleDraw:GetHeight()
	return 800
end;