--[[
绘制模型的渲染器
lizhuangzhuang
2014年11月11日19:55:15
]]

_G.classlist['UIDraw'] = 'UIDraw'
_G.UIDraw = {};
_G.UIDraw.objName = 'UIDraw'
--渲染器名字(唯一)
UIDraw.name ="";
UIDraw.objEntity = nil;
UIDraw.objUILoader = nil;
UIDraw.objCamera = nil;
UIDraw.objDrawBoard = nil;
UIDraw.objLight	= nil;
UIDraw.backColor = nil;
UIDraw.screenBlender = nil;
UIDraw.pfxIndex = 0;

--缩放倍数,解决模糊问题 
UIDraw.scale = 2;

--创建一个渲染器
function UIDraw:new(name,objEntity,objUILoader,vecVport,vecEye,vecLook,backColor,drawType,secondType)
	local drawObj = UIDrawManager:GetUIDraw(name);
	if drawObj then 
		print('Waring:Find a same UIDraw.');
		return drawObj; 
	end
	--
	local obj = {}
	for i,v in pairs(UIDraw) do
		if type(v) == "function" then
			obj[i] = v;
		end
	end
	obj.name = name;
	obj.objEntity = objEntity;

	if objEntity.avatarLoader.progress ~= 1 then
		--Debug("check it: 1", self.avatarLoader.progress)
		objEntity.objMesh:onDrawMesh(function(m)
			local p = (_G.aabb.z2 - _G.aabb.z1) * objEntity.avatarLoader.progress + objEntity:GetPos().z
			--Debug("check it: 2", self.avatarLoader.progress, p)
			_G.c1:clipZPositive(p)
			_G.c2:clipZNegative(p)

			_rd:useClipper(c1)
			_G.dummy1:drawMesh()
			_rd:popClipper()

			_rd:useClipper(c2)
			_G.dummy2:drawMesh()
			_rd:popClipper()
		end)
	end
	objEntity.avatarLoader:onFinish(function()
		--Debug("##############self.avatarLoader:onFinish")
		if objEntity.objMesh then objEntity.objMesh:onDrawMesh() end
	end)
	--渲染灯光
	if not drawType then drawType="Default"; end
	if not UIDrawLightCfg[drawType] then
		drawType = "Default";
	end
	obj.drawType = drawType;
	if drawType == "UIRole" then
		obj.scale = UIDraw.scale;
	elseif drawType=="UINpc" and _G.lightShadowQuality==DisplayQuality.highQuality then
		obj.scale = UIDraw.scale;
	else
		obj.scale = 1;
	end
	obj.Render = UIDraw.RenderMesh;
	obj.objUILoader = objUILoader;
	obj.vecVport = vecVport;
	---摄像机
	obj:SetCamera(vecVport,vecEye,vecLook);
	obj.backColor  = backColor or 0x00000000;
	
	obj.objLight = _SkyLight.new()--渲染灯光
	local cfg = UIDrawLightCfg[drawType];
	if secondType and cfg[secondType] then
		cfg = cfg[secondType];
	end
	obj.objLight.color = cfg.SkyLight.color;
	 _Vector3.sub(obj.objCamera.look,obj.objCamera.eye,obj.objLight.direction);
	obj.objLight.power = cfg.SkyLight.power;
	obj.objAmbLight = _AmbientLight.new();
	obj.objAmbLight.color = cfg.AmbientLight.color;
	
	obj.backlight = _SkyLight.new();
	_Vector3.sub(obj.objCamera.look, obj.objCamera.eye, obj.backlight.direction);
	obj.backlight.backLight = true;
	obj.backlight.color = cfg.Backlight.color;
	obj.backlight.power = cfg.Backlight.power;

    obj.bIsRender = false;
	obj.screenBlender = nil;
	obj.pfxMap = {};
	UIDrawManager:AddUIDraw(obj);
	return obj;
end

function UIDraw:AddChildEntity(name,objEntity)
	if not self.childEntity then
		self.childEntity = {};
	end
	self.childEntity[name] = objEntity;
end

function UIDraw:RemoveChildEntity(name)
	if not self.childEntity then return; end
	self.childEntity[name] = nil;
end

function UIDraw:RemoveAllChildEntity(name)
	if not self.childEntity then return; end
	self.childEntity = nil;
end

--设置相机参数
function UIDraw:SetCamera(vecVport,vecEye,vecLook)
	if not self.objCamera then
		self.objCamera = _Camera.new();
	end
	if self.drawType=="UINpc" and _G.lightShadowQuality==DisplayQuality.highQuality then
		self.scale = UIDraw.scale;
	elseif self.drawType == "UIRole" then
		self.scale = UIDraw.scale;
	else
		self.scale = 1;
	end
	local vecVport = vecVport or _Vector2.new(200,400);
	self.objCamera.look = vecLook or _Vector3.new(0,0,0);
	self.objCamera.eye = vecEye or _Vector3.new(1,1,1);
	--self.objCamera.viewport = _Rect.new(0,0,vecVport.x*self.scale,vecVport.y*self.scale);
end

--设置渲染状态
function UIDraw:SetDraw(bIsRender) 
	if bIsRender == self.bIsRender then return; end
	self.bIsRender = bIsRender;
	if bIsRender then
		if not self.objDrawBoard then
			self.objDrawBoard = _DrawBoard.new( self.vecVport.x*self.scale, self.vecVport.y*self.scale);
		end
		if self.objUILoader then
			self.objUILoader._xscale = 100/self.scale;
			self.objUILoader._yscale = 100/self.scale;
			if self.objUILoader.loadMovie then
				self.objUILoader:loadMovie(self.objDrawBoard);
			end
			if self.objUILoader then
				self.objUILoader.hitTestDisable = true;
			end
		end
	else
		self:StopAllPfx();
		if self.objDrawBoard then
			self.objDrawBoard = nil;
		end
		if self.objUILoader and self.objUILoader.unloadMovie then
			self.objUILoader:unloadMovie();
		end
		LuaGC();
	end
end

--设置模型
function UIDraw:SetMesh(objEntity)
	if objEntity ~= self.objEntity then
		if not objEntity 
			and self.objEntity
			and self.objEntity.Destroy then
			self.objEntity:Destroy();
		end
		self.objEntity = objEntity;
		return true
	end
	return false
end

--设置UILoader
function UIDraw:SetUILoader(objUILoader)
	if not objUILoader then
		self:SetDraw(false);
	end
	if self.objUILoader ~= objUILoader then
 	  	self.objUILoader = objUILoader;
 	end
 	return true
end

--灰化处理
function UIDraw:SetGrey(bIsGrey)
    if bIsGrey then
    	if not self.screenBlender then
    		self.screenBlender = _Blender.new();
    	end
     	self.screenBlender:gray(1, 1, 1);
    else
        self.screenBlender = nil;
    end
end

--描边 nil不画
function UIDraw:SetEdge(color)
	self.edgeColor = color;
end

--设置高亮
function UIDraw:SetHighLight(lightColor)
	if not lightColor then
		self.highLightBlender = nil;
	else
		if not self.highLightBlender then
			self.highLightBlender = _Blender.new();
		end
		self.highLightBlender:highlight(lightColor)
	end
end

--播放特效
--@return 特效唯一标示,播放的Pfx对象
function UIDraw:PlayPfx(resName)
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
function UIDraw:StopPfx(name)
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
function UIDraw:StopAllPfx()
	if not self.pfxSkl then return; end
	for name,vo in pairs(self.pfxMap) do
		if vo.isPlaying then
			self.pfxSkl.pfxPlayer:stop(name,true);
			vo.isPlaying = false;
		end
	end
end

--获取一个特效名字
function UIDraw:GetPfxName()
	UIDraw.pfxIndex = UIDraw.pfxIndex + 1;
	return "UIDraw"..UIDraw.pfxIndex;
end

local tempCamera = _Camera:new();
--渲染函数
function UIDraw:RenderMesh(dwInterval)
	if not self.objDrawBoard then return; end
	if not self.objCamera then return; end
	if not self.objEntity then return; end
	--self:SetGrey(true)
	_rd.shadowCaster = false
	_rd.shadowReceiver = false
	self.objEntity:Update()
	_rd:useDrawBoard( self.objDrawBoard , self.backColor)
	tempCamera:set(_rd.camera);--保留当前相机
	_rd.camera:set(self.objCamera);
	local mip = _rd.mip;
	_rd.mip = false;
	local edge = _rd.edge;
	if self.edgeColor then
		_rd.edge = true;
		_rd.edgeColor = self.edgeColor;
	end
	if self.objLight then  _rd:useLight(self.objLight);  end
	if self.objAmbLight then _rd:useLight(self.objAmbLight); end
	if self.backlight then _rd:useLight(self.backlight); end
    if self.screenBlender then _rd:useBlender(self.screenBlender) end
	if self.highLightBlender then _rd:useBlender(self.highLightBlender) end
	self.objEntity:DrawMesh();
	if self.pfxSkl then
		self.pfxSkl:drawSkeleton();
	end
	--有子模型的,画子模型
	if self.childEntity then
		for name,objEntity in pairs(self.childEntity) do
			objEntity:DrawMesh();
		end
	end
	if self.objLight then  _rd:popLight();   end
	if self.objAmbLight then  _rd:popLight();   end
	if self.backlight then  _rd:popLight();   end
    if self.screenBlender then _rd:popBlender();  end
	if self.highLightBlender then _rd:popBlender(); end
	_rd.camera:set(tempCamera);--还原摄像机
	if self.edgeColor then
		_rd.edge = edge;
	end
	_rd.mip = mip;
	_rd:resetDrawBoard();
end

--销毁
function UIDraw:Destroy()
	self:StopAllPfx();
	self.bIsRender = false;
	self.objEntity = nil;
	self.Render = nil;
	self.objUILoader = nil;
	self.objCamera = nil;
	self.objDrawBoard = nil;
end