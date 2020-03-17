--[[
绘制模型的渲染器
lizhuangzhuang
2014年11月11日19:55:15
]]

_G.classlist['UISceneDraw'] = 'UISceneDraw'
_G.UISceneDraw = {};
_G.UISceneDraw.objName = 'UISceneDraw'
--渲染器名字(唯一)
UISceneDraw.name ="";

UISceneDraw.objUILoader = nil;
UISceneDraw.objCamera = nil;
UISceneDraw.objDrawBoard = nil;
UISceneDraw.first = nil
UISceneDraw.rotateSpeed = .01
UISceneDraw.pfxIndex = 0;

--创建一个渲染器
function UISceneDraw:new(name, objUILoader, vecVport, isUseLight)
	local drawObj = UIDrawManager:GetUIDraw(name);
	if drawObj then 
		print('Waring:Find a same UISceneDraw.');
		return drawObj; 
	end
	--
	local obj = {}
	for i,v in pairs(UISceneDraw) do
		if type(v) == "function" then
			obj[i] = v;
		end
	end
	obj.name = name;
	obj.sceneLoaded = false
	obj.backColor  = 0x00000000;
	obj.Render = UISceneDraw.RenderScene;
	obj.objUILoader = objUILoader;
	obj.vecVport =  vecVport or _Vector2.new(200,400);
	obj.roleTurnDir = 0
	obj.meshDir = 0;
	obj.isUseLight = isUseLight;
	obj.bIsRender = false;
	obj.pfxMap = {};
	UIDrawManager:AddUIDraw(obj);
	return obj;
end

--设置渲染状态
function UISceneDraw:SetDraw(bIsRender)
	if bIsRender == self.bIsRender then return; end
	self.bIsRender = bIsRender;
	if bIsRender then
		if not self.objDrawBoard then
			self.objDrawBoard = _DrawBoard.new( self.vecVport.x, self.vecVport.y);
		end
		if self.objUILoader then
			self.objUILoader:loadMovie(self.objDrawBoard);
			if self.objUILoader then
				self.objUILoader.hitTestDisable = true;
			end
		end
	else
		if self.objDrawBoard then
			self.objDrawBoard = nil;
		end
		if not self.sceneLoaded and self.sceneLoader then
			self.sceneLoader:stop();
		end
		self.sceneLoader = nil;
		self.sceneLoaded = false;
		self.objCamera = nil;
		if self.objScene then
			self.objScene:clear()
		end
		self.objScene = nil;
		if self.objUILoader and self.objUILoader.unloadMovie then
			self.objUILoader:unloadMovie();
		end
		LuaGC();
	end
end


--设置UILoader
function UISceneDraw:SetUILoader(objUILoader)
	if not objUILoader then
		self:SetDraw(false);
	end
   	self.objUILoader = objUILoader;
end

--设置场景
function UISceneDraw:SetScene(senName,callback)
	self.first = nil
	self.meshDir = 0;
	if self.objScene then
		self.objScene:clear();
		self.objScene = nil;
		self.sceneLoaded = false;
		self.objCamera = nil;
		if self.sceneLoader then
			self.sceneLoader:stop();
			self.sceneLoader = nil;
		end
		self.callback = nil
	end
	self.callback = callback
	self.senName = _G.strtrim(senName);
	asyncLoad(false,"scene");
	self.sceneLoader = _Loader.new()
	local f = string.sub(senName,1,#senName-4);
	self.sceneLoader:loadGroup(f)
	self.sceneLoader:onFinish(function()				--TODO Model will be Change
		self.objScene = _Scene.new(self.senName);
		asyncLoad(true,"scene")
		local nodes = self.objScene:getNodes();
		for i,v in ipairs(nodes) do
			if v.mesh then
				local mn = FileFormatTransform(v.name,'fmt');
				if mn then
					if _sys:fileExist(mn,false) then
						v.mesh:loadLMaterialManager(mn);
					end
				end
			end	
		end
		
		local fn = function(node)
			self:OnSceneRender(node)
		end
		local cameras = self.objScene.graData:getCameras()
		for i, v in pairs(cameras) do
			self.objCamera  = v;
			break;
		end
		if not self.objCamera then
			Error( string.format( 'cannot find camera in sen:%s', self.senName ) );
		end
		--self.objCamera.viewport = _Rect.new(0,0,self.vecVport.x,self.vecVport.y);
		self.objScene:onRender(fn);
		self.sceneLoaded = true
			
		
		if self.callback then
			self.callback();
		end
	end)
end

function UISceneDraw:GetScene()
	if not self.sceneLoaded then return nil; end
	return self.objScene;
end

--某个节点执行某个动作
function UISceneDraw:NodeAnimation(nodeName,aniName)
	if not self.sceneLoaded then return; end
	if not self.objScene then return; end
	local nodes = self.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(nodeName) then
			node = v;
			break;
		end
	end
	if not node then return; end
	local anima = node.mesh.skeleton:getAnima(aniName);
	if not anima then
		anima = node.mesh.skeleton:addAnima(aniName);
	end
	anima:play();
	return anima
end

--隐藏显示某个节点
function UISceneDraw:NodeVisible(nodeName,nodeVisible)
	if not self.sceneLoaded then return; end
	if not self.objScene then return; end
	local nodes = self.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		local resName = string.sub(v.resname, 1, -5)
		if resName == nodeName then
			node = v;
			break;
		end
		-- if v.name:find(nodeName) then
		-- end
	end
	if not node then return; end
	node.visible = nodeVisible
end

function UISceneDraw:OnBtnRoleLeftStateChange(state, fDelta )
	local delta = fDelta or 0
	if state == "down" then
		self.roleTurnDir = UISceneDraw.rotateSpeed*delta ;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end
function UISceneDraw:OnBtnRoleRightStateChange(state,fDelta )
	local delta = fDelta or 0
	if state == "down" then
		self.roleTurnDir = -UISceneDraw.rotateSpeed*delta ;
	elseif state == "release" then
		self.roleTurnDir = 0;
	elseif state == "out" then
		self.roleTurnDir = 0;
	end
end

local axis = _Vector3.new(0,0,1)
function UISceneDraw:Update(nodeName)
	if not self.sceneLoaded then return; end
	if not self.objScene then return; end
	local nodes = self.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		local resName = string.sub(v.resname, 1, -5)
		if resName == nodeName then
			node = v;
			break;
		end
	end
	if not node then return; end

	if self.roleTurnDir == 0 then
		return;
	end
	
	-- self.meshDir = self.meshDir + math.pi/40*self.roleTurnDir;
	-- if self.meshDir < 0 then
		-- self.meshDir = self.meshDir + math.pi*2;
	-- end
	-- if self.meshDir > math.pi*2 then
		-- self.meshDir = self.meshDir - math.pi*2;
	-- end
	
	node.transform:mulRotationLeft(axis,self.roleTurnDir);
	-- node.mesh.transform:setRotation(0,0,1,self.meshDir);
end

--某个节点播放某个特效
function UISceneDraw:PlayNodePfx(nodeName,pfxName)
	if not self.sceneLoaded then return; end
	if not self.objScene then return; end
	local nodes = self.objScene:getNodes();
	local node = nil;
	for i,v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(nodeName) then
			node = v;
			break;
		end
	end
	if not node then return; end
	
	asyncLoad(true); --异步
	node.mesh.skeleton.pfxPlayer:stop("pfx_"..pfxName,true)
	local pfx = node.mesh.skeleton.pfxPlayer:play("ui_"..pfxName..".pfx", "ui_"..pfxName..".pfx")
	local BindMat  = node.mesh.skeleton:getBone("pfx_"..pfxName);
    if BindMat then
        pfx.transform = BindMat
    end
end

--渲染函数
local tempCamera = _Camera:new();
function UISceneDraw:RenderScene(dwInterval)
	if not self.sceneLoaded then return end;
	if not self.objDrawBoard then return; end
	if not self.objCamera then return; end
	_rd:useDrawBoard( self.objDrawBoard , self.backColor)
	tempCamera:set(_rd.camera);--保留当前相机
	_rd.camera:set(self.objCamera);
	local mip = _rd.mip;
	_rd.mip = false;
	self.objScene:render();
	_rd.mip = mip;
	_rd.camera:set(tempCamera);--还原摄像机
	_rd:resetDrawBoard();
end

local RenderDelayTime = 100
local avatarMaterial = _Material.new()
avatarMaterial:setAmbient( 1.5, 1.5, 1.5, 1 )
avatarMaterial:setDiffuse( 0.7, 0.7, 0.7, 1 )
local objSkyLight = _SkyLight.new()
local objSkyBackLight = _SkyLight.new()
objSkyLight.backLight = false
objSkyBackLight.backLight = true

local sl = _SkyLight.new()
sl.color = 0xff333333
sl.power = 10
sl.direction = _Vector3.new(1, 0, -1)
local mat = _Matrix3D.new()
local restMat = _Matrix3D.new()
local vec = _Vector3.new(0, 0, 1)
local total = 0.001
mat:setRotation(vec, total)
restMat:mulLeft(mat)

local m = _Material.new()
m.emissive = _Color.Green
m.power = 2

function UISceneDraw:OnSceneRender(node)
	-- if not self.first then self.first = GetCurTime() end
	-- if GetCurTime() - self.first < RenderDelayTime then return end
	_rd.shadowReceiver = false
	_rd.shadowCaster = false
	if node.mesh then
		if node.dwType == enEntType.eEntType_Player then 
			if self.isUseLight then  --竞技场特殊处理
				local light = Light.GetUILight();
				
				local material = light.material;
				avatarMaterial:setAmbient( material.ambient, material.ambient, material.ambient, material.ambient );
				avatarMaterial:setDiffuse( material.diffuse, material.diffuse, material.diffuse, material.diffuse );
				_rd:useMaterial(avatarMaterial);
	
				local sky = light.skylight;
				objSkyLight.color = sky.color;
				objSkyLight.power = sky.power;
				
				local back = light.backskylight;
				objSkyBackLight.color = back.color;
				objSkyBackLight.power = back.power;
				_Vector3.sub(_rd.camera.look, _rd.camera.eye, objSkyLight.direction)
				_Vector3.sub(_rd.camera.look, _rd.camera.eye, objSkyBackLight.direction)
				_rd:useLight(objSkyLight)
				_rd:useLight(objSkyBackLight)
			end
			local mip = _rd.mip
			_rd.mip = false
			node.mesh:drawMesh()
			if self.isUseLight then
				_rd:popMaterial()
				_rd:popLight()
				_rd:popLight()
			end
			_rd.mip = mip
		elseif node.dwType == enEntType.eEntType_mainBuild then
			local mip = _rd.mip
			_rd.mip = false
			node.mesh:drawMesh()
			_rd.mip = mip
		else --其它场景Mesh
			if node.isEmissive == true then
				_rd:useMaterial(m)
			end
			local mip = _rd.mip
			_rd.mip = false
			node.mesh:drawMesh()
			_rd.mip = mip
			if node.isEmissive == true then
				_rd:popMaterial()
			end	
		end
	elseif node.terrain then
		_rd.shadowReceiver = true
		node.terrain:draw()
		_rd.shadowReceiver = false
	end
end

--销毁
function UISceneDraw:Destroy()
	self:StopAllPfx();
	self.bIsRender = false;
	self.Render = nil;
	self.objUILoader = nil;
	self.objDrawBoard = nil;
	if not self.sceneLoaded and self.sceneLoader then
		self.sceneLoader:stop();
	end
	self.sceneLoader = nil;
	self.sceneLoaded = false;
	self.objCamera = nil;
	if self.objScene then
		self.objScene:clear();
		self.objScene = nil;
	end
end

local rotationRot = _Vector4.new()
function UISceneDraw:GetMarkers()
	local posList = {}
	if self.objScene then
		local markerList = self.objScene.graData:getMarkers()
		for i, v in pairs(markerList) do
			local pos = v:getTranslation()
			v:getRotation(rotationRot)
			local dir = 0
			if rotationRot then
				dir = rotationRot.r
				if rotationRot.z < 0 then
				    dir = 2 * math.pi - dir
				end
			end
			local scale = v:getScaling()
			posList[v.name] = {}
			posList[v.name].pos = pos
			posList[v.name].dir = dir
			posList[v.name].scale = scale
		end
	end
	return posList
end

function UISceneDraw:AddNode(avatar, pos, dir, type)
	if not avatar then
		return
	end
	avatar:EnterUIScene(self.objScene, pos, dir, type)
end


function UISceneDraw:PlayNodePfxByBoneName(nodeName, pfxName, boneName)
	if not self.sceneLoaded then
		return
	end
	if not self.objScene then
		return
	end
	local nodes = self.objScene:getNodes()
	local node = nil
	for i, v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(nodeName) then
			node = v
			break
		end
	end
	if not node then
		return
	end
	
	asyncLoad(true)
	
	local pfx = node.mesh.skeleton.pfxPlayer:play(pfxName, pfxName)
	if boneName and boneName ~= "" then
		local boneMat  = node.mesh.skeleton:getBone(boneName)
	    if boneMat then
	        pfx.transform = boneMat
	    end
	end
end

function UISceneDraw:StopNodePfxByBoneName(nodeName, pfxName)
	if not self.sceneLoaded then
		return
	end
	if not self.objScene then
		return
	end
	local nodes = self.objScene:getNodes()
	local node = nil
	for i, v in ipairs(nodes) do
		if v.mesh and v.mesh.skeleton and v.name:find(nodeName) then
			node = v
			break
		end
	end
	if not node then
		return
	end
	
	asyncLoad(true)

	node.mesh.skeleton.pfxPlayer:stop(pfxName, true)
end

--得到某个节点的mesh
function UISceneDraw:GetNodeMesh(nodeName)
	if not self.sceneLoaded then
		return
	end
	if not self.objScene then
		return
	end
	local nodes = self.objScene:getNodes()
	local node = nil
	for i,v in ipairs(nodes) do
		local resName = string.sub(v.resname, 1, -5)
		if v.mesh and v.mesh.skeleton and resName == nodeName then
			node = v
			break
		end
	end
	if not node then
		return
	end
	return node.mesh
end

--得到某个节点的skl
function UISceneDraw:GetNodeSkl(nodeName)
	if not self.sceneLoaded then
		return
	end
	if not self.objScene then
		return
	end
	local nodes = self.objScene:getNodes()
	local node = nil
	for i,v in ipairs(nodes) do
		local resName = string.sub(v.resname, 1, -5)
		if v.mesh and v.mesh.skeleton and resName == nodeName then
			node = v
			break
		end
	end
	if not node then
		return
	end
	if not node.mesh then
		return
	end
	return node.mesh.skeleton
end

--设置相机参数
function UISceneDraw:SetCamera(vecVport,vecEye,vecLook)
	if not self.objCamera then
		self.objCamera = _Camera.new();
	end
	local vecVport = vecVport or _Vector2.new(200,400);
	self.objCamera.look = vecLook or _Vector3.new(0,0,0);
	self.objCamera.eye = vecEye or _Vector3.new(1,1,1);
end

--播放特效
--@return 特效唯一标示,播放的Pfx对象
function UISceneDraw:PlayPfx(resName)
	if not self.pfxSkl then
		self.pfxSkl = _Skeleton.new();
	end
	for name,vo in pairs(self.pfxMap) do
		if vo.resName == resName then
			if not vo.isPlaying then
				self.pfxSkl.pfxPlayer:reset(name);
				vo.isPlaying = true;
			end
			return name,vo.pfx;
		end
	end
	local name = self:GetPfxName();
	local pfx = self.pfxSkl.pfxPlayer:play(name,resName);
	Debug("pfx.resname ", pfx.resname)
	pfx.keepInPlayer = true;
	local vo = {};
	vo.resName = resName;
	vo.pfx = pfx;
	vo.isPlaying = true;
	self.pfxMap[name] = vo;
	return name,pfx;
end

--停止特效
--@param name 特效唯一标示
function UISceneDraw:StopPfx(name)
	if not self.pfxSkl then return; end
	for n,vo in pairs(self.pfxMap) do
		if n == name then
			if vo.isPlaying then
				self.pfxSkl.pfxPlayer:stop(name,true);
				vo.isPlaying = false;
			end
		end
	end
end

--停止所有特效
function UISceneDraw:StopAllPfx()
	if not self.pfxSkl then return; end
	for name,vo in pairs(self.pfxMap) do
		if vo.isPlaying then
			self.pfxSkl.pfxPlayer:stop(name,true);
			vo.isPlaying = false;
		end
	end
end

--获取一个特效名字
function UISceneDraw:GetPfxName()
	UISceneDraw.pfxIndex = UISceneDraw.pfxIndex + 1;
	return "UIDraw"..UISceneDraw.pfxIndex;
end