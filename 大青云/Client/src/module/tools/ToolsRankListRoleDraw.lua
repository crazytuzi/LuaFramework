--[[
 排行榜人物编译器
 wangshuai
]]

_G.UIToolsRankList = BaseUI:new("UIToolsRankList")


UIToolsRankList.curIndex = 1;  -- 当前位置index
UIToolsRankList.curModelIndex = 1; -- 当前模型index
UIToolsRankList.curlist = {}; -- 当前listitemCfg
UIToolsRankList.curModel = {}; -- 当前模型
UIToolsRankList.curModelDir = 0; -- 当前模型方向
UIToolsRankList.curTexDir = 0; -- 当前特效方向
UIToolsRankList.curTexName = 0; --  播放名字，
UIToolsRankList.curTexName2 = 0; -- 关闭名字，
UIToolsRankList.modelTurnDir = 0; -- 模型旋转方向
UIToolsRankList.meshDir = 0;-- 模型当前的方向
UIToolsRankList.curtexDri = 0; -- 当前特效 0,不旋转;1上;-1下
UIToolsRankList.texDri = 0; -- 特效当前方向
UIToolsRankList.allNewModel = {}
-- cfg
UIToolsRankList.defaultCfg = {
									EyePos = _Vector3.new(0,-40,20),
									LookPos = _Vector3.new(0,0,10),
														--宽，高
									VPort = _Vector2.new(850,700),
									Rotation = 0,
									pfx = 0,
								  }
  

function UIToolsRankList:Create()
	self:AddSWF("toolsRankListRoleDraw.swf",true,"center")
end;

function UIToolsRankList:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:CloseBtn() end;
	-- modelBtn
	for i=1,3,1 do 
		objSwf["btn_Model"..i].click = function() self:OnModelClick(i)end;
	end;

	-- listclick
	objSwf.list.itemClick = function(e) self:OnListItemClick(e); end

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

	-- 旋转

	objSwf.btnRoleRight.stateChange = function (e) self : OnRoleRight(e.state)end;
	objSwf.btnRoleLeft.stateChange = function (e) self : OnRoleLeft(e.state)end;

	--保存
	objSwf.btn_save.click = function () self : OnBtnSaveclick()end;
	--使用数据
	objSwf.btn_user.click = function () self : OnBtnUserclick()end;

	-- 特效
	objSwf.btnTexiao1.stateChange = function (e) self : OnBtnTexiao1(e.state)end;
	objSwf.btnTexiao2.stateChange = function (e) self : OnBtnTexiao2(e.state)end;

end;

function UIToolsRankList:OnDelete()
	for _,objUIDraw in pairs(self.allNewModel) do
		objUIDraw:SetUILoader(nil);
	end
end

function UIToolsRankList:OnShow()

end;

function UIToolsRankList:OnHide()	
	for i,info in pairs(self.allNewModel) do
		if info then 
		info:SetDraw(false);
		end;
	end;
end;

function UIToolsRankList:CloseBtn()
	self:Hide();
end;


-- 画模型
function UIToolsRankList : DrawRole()
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


	local drawcfg = UIDrawRankList[self.curIndex][id]
	if not drawcfg then 
		drawcfg = self:GetDefaultCfg();
		UIDrawRankList[self.curIndex][id] = drawcfg;
		self:SetListHasCfg(id);
	end;
	if not self.allNewModel[self.curIndex] then 
	 	self.allNewModel[self.curIndex] = UIDraw:new("ToolsRankList"..self.curIndex,avatar, objSwf["roleloaer"..self.curIndex],  
			drawcfg.VPort,   drawcfg.EyePos,  
			drawcfg.LookPos,  0x00000000);
	else
		self.allNewModel[self.curIndex]:SetUILoader(objSwf["roleloaer"..self.curIndex]);
		self.allNewModel[self.curIndex]:SetCamera(drawcfg.VPort,drawcfg.EyePos,drawcfg.LookPos);
		self.allNewModel[self.curIndex]:SetMesh(avatar);
	end;
	
	-- 旋转
	self.curModelDir = drawcfg.Rotation;
	self.curModel.objMesh.transform:setRotation(0,0,1,drawcfg.Rotation);
	self.allNewModel[self.curIndex]:SetDraw(true);
	self:OnCfgChange();

	--特效
	self.curTexDir = drawcfg.pfx;
	if self.curTexName2 ~= 0 then 
		self.allNewModel[self.curIndex]:StopPfx(self.curTexName2)
	end;

	--local sex = info.sex;
	local pfxName = "duiyuan_daiji.pfx";
	local name,pfx = self.allNewModel[self.curIndex]:PlayPfx(pfxName);
	self.curTexName = pfxName
	self.curTexName2 = name;
	-- 微调参数
	pfx.transform:setRotationX(drawcfg.pfx);
	self.curModel:PlayRanklistAction()
end;	



function UIToolsRankList:Update()
	self:SetTexiao()
	self:SetRoleRotation()
end;


function UIToolsRankList:SetRoleRotation()
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
	if not UIDrawRankList[self.curIndex][self.curModelIndex] then 
		UIDrawRankList[self.curIndex][self.curModelIndex] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawRankList[self.curIndex][self.curModelIndex];
	cfg.Rotation = self.meshDir;
end;

function UIToolsRankList:SetTexiao()
	--模型特效
	if self.texDri == 0 then return end;
	if not self.curtexDri then return end;
	self.curtexDri = self.curtexDri + self.texDri

	local name,pfx = self.allNewModel[self.curIndex]:PlayPfx(self.curTexName);
	-- 微调参数
	pfx.transform:setRotationX(self.curtexDri);
	local cfg = UIDrawRankList[self.curIndex][self.curModelIndex];
	cfg.pfx = self.curtexDri;
end;

function UIToolsRankList : OnModelClick(e)
	if self.curTexName2 ~= 0 then 
		self.allNewModel[self.curIndex]:StopPfx(self.curTexName2)
	end;
	self.curIndex = e;
	self.curModelIndex = 1;
	self.objSwf.list.selectedIndex = 0
	self:ShowList(); --显示当前指定list
	--得到当前配置角度
	if not UIDrawRankList[self.curIndex] then UIDrawRankList[self.curIndex] = {} end;
	local cfg = UIDrawRankList[self.curIndex][self.curModelIndex];
	if not cfg then self.meshDir = 0 end;
	if cfg then self.meshDir = cfg.Rotation end;
	self:DrawRole();
end;
-- 显示list
function UIToolsRankList : ShowList()
	-- 得到当前的lsit
	local cfg = UIDrawRankList[self.curIndex];
	-- 显示list部分
	local objSwf = self.objSwf;
	objSwf.list.dataProvider:cleanUp();
	for i,cf in ipairs(t_playerinfo) do 
		local listVo = {};
		listVo.name = cf.name;
		listVo.flag = cfg[i] and "√" or "";
		listVo.roleid = i;
		table.push(self.curlist,listVo);
		objSwf.list.dataProvider:push(UIData.encode(listVo));
	end;
	objSwf.list:invalidateData();

end;

function UIToolsRankList : OnListItemClick(e)
	self.curModelIndex = e.item.roleid
	-- 花模型
	self:DrawRole();
end;

--创建配置文件
function UIToolsRankList : GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	cfg.pfx = 0;
	return cfg;
end

function UIToolsRankList : OnBtnDownclick()
	-- down
	if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(0,0,1);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end

end;
function UIToolsRankList : OnBtnUpclick()
	-- up
	if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(0,0,-1);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsRankList : OnBtnLeftclick()
	--left
	if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(-1,0,0);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end
end;
function UIToolsRankList : OnBtnRightclick()
	--right
		if self.allNewModel[self.curIndex] then
		local newLook = self.allNewModel[self.curIndex].objCamera.look:add(1,0,0);
		self.allNewModel[self.curIndex].objCamera.look = newLook;
		self:OnCfgChange();
	end
end;

function UIToolsRankList : OnBtnSmallclick()
	--small
	if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,-1,0);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsRankList : OnBtnMaxclick()
	-- max
	if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,1,0);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsRankList : OnBtnFuclick()
	-- fu
	if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,0,-1);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end;
function UIToolsRankList : OnBtnYangclick()
	-- yang
		if self.allNewModel[self.curIndex] then
		local newEye = self.allNewModel[self.curIndex].objCamera.eye:add(0,0,1);
		self.allNewModel[self.curIndex].objCamera.eye = newEye;
		self:OnCfgChange();
	end
end

function UIToolsRankList : OnRoleRight(state)
	if state == "down" then
		self.modelTurnDir = -1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;
function UIToolsRankList : OnRoleLeft (state)
	if state == "down" then
		self.modelTurnDir = 1;
	elseif state == "release" then
		self.modelTurnDir = 0;
	elseif state == "out" then
		self.modelTurnDir = 0;
	end
end;

function UIToolsRankList:OnBtnTexiao1(state)
	if state == "down" then 
		self.texDri = 0.01
	elseif state == "release" then 
		self.texDri = 0
	elseif state == "out" then 
		self.texDri = 0
	end;
end;
function UIToolsRankList:OnBtnTexiao2(state)
	if state == "down" then 
		self.texDri = -0.01
	elseif state == "release" then 
		self.texDri = 0
	elseif state == "out" then 
		self.texDri = 0
	end;
end;

--设置数据
function UIToolsRankList:SetListHasCfg(id)
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

-- 配置变动
function UIToolsRankList : OnCfgChange()
	local uDraw = self.allNewModel[self.curIndex]; -- 当前Draw模型
	if not uDraw then return ;end;
	if not UIDrawRankList[self.curIndex] then 
		UIDrawRankList[self.curIndex] = {};
	end;
	if not UIDrawRankList[self.curIndex][self.curModelIndex] then 
		UIDrawRankList[self.curIndex][self.curModelIndex] = self:GetDefaultCfg();
	end;
	local cfg = UIDrawRankList[self.curIndex][self.curModelIndex];


	cfg.EyePos = self.allNewModel[self.curIndex].objCamera.eye:clone();
	--print(cfg.EyePos.x,cfg.EyePos.y,cfg.EyePos.z)
	cfg.LookPos =self.allNewModel[self.curIndex].objCamera.look:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	-- 显示参数
	--UIDrawRankList[self.curIndex][self.curModelIndex] = cfg;
	local objSwf = self.objSwf;
	objSwf.ipEyeX.text = cfg.EyePos.x;
	objSwf.ipEyeY.text = cfg.EyePos.y;
	objSwf.ipEyeZ.text = cfg.EyePos.z;
	objSwf.ipLookX.text = cfg.LookPos.x;
	objSwf.ipLookY.text = cfg.LookPos.y;
	objSwf.ipLookZ.text = cfg.LookPos.z;
end;


function UIToolsRankList : OnBtnSaveclick()
	-- save
	local file = _File:new();
	file:create(ClientConfigPath .. 'config/gui/UIDrawRankListConfig.lua');
	file:write("--[[ 排行榜人物模型配置文件\nWangshuai\n]]\n".."_G.UIDrawRankList = {\n");
	for id,cfg in ipairs(UIDrawRankList) do
		file:write("\t["..id.."] = \n\t{\n")
		for i,info in ipairs(cfg) do 
			--print(info.EyePos.x,info.EyePos.y,info.EyePos.z,"dddddd")
			file:write("\t\t["..i.."] = \n\t\t{\n");
			file:write("\t\t\tEyePos = _Vector3.new(" ..info.EyePos.x.. "," ..info.EyePos.y.. "," ..info.EyePos.z .."),\n");
			file:write("\t\t\tLookPos = _Vector3.new(" ..info.LookPos.x.. "," ..info.LookPos.y.. "," ..info.LookPos.z .."),\n");
			file:write("\t\t\tVPort = _Vector2.new(" .. info.VPort.x.. "," ..info.VPort.y.. "),\n");
			file:write("\t\t\tRotation ="..info.Rotation..",\n")
			file:write("\t\t\tpfx ="..info.pfx..",\n")
			file:write("\t\t},\n");
		end;
		file:write("\t},\n");
	end
	file:write("\n}");
	file:close();
end;

-- 使用参数
function UIToolsRankList : OnBtnUserclick()
	-- UIToolsRankList
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