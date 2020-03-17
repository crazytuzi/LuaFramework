--[[
专门绘制特效的渲染器
lizhuangzhuang
2014年11月11日20:01:46
]]
_G.classlist['UIPfxDraw'] = 'UIPfxDraw'
_G.UIPfxDraw = {};
_G.UIPfxDraw.objName = 'UIPfxDraw'
function UIPfxDraw:new(name,objUILoader,vecVport,vecEye,vecLook,backColor)
	local drawObj = UIDrawManager:GetUIDraw(name);
	if drawObj then 
		Debug("Waring:Find a same UIPfxDraw.");
		return drawObj; 
	end
	--
	local obj = {};
	for i,v in pairs(UIPfxDraw) do
		if type(v) == "function" then
			obj[i] = v;
		end;
	end
	obj.name = name;
	obj.objUILoader = objUILoader;
	---摄像机 
	local vecVport1 = vecVport or _Vector2.new(200,275);
	obj.Render = UIPfxDraw.RenderSkl;
	obj.vecVport = vecVport1;
	obj:SetCamera(vecVport1,vecEye,vecLook); 
	obj.backColor  = backColor or 0x00000000;
	--渲染灯光
	obj.objLight = _SkyLight.new()
	obj.objLight.color = 0xFFFFFFFF;--0xff555555;
	_Vector3.sub(obj.objCamera.eye, obj.objCamera.look, obj.objLight.direction);
	obj.objLight.power = 20;
	obj.objAmbLight = _AmbientLight.new();
	obj.objAmbLight.color = 0xFFFFFFFF;--0xd9ccbdff;
	--
	obj.bIsRender = false;
	UIDrawManager:AddUIDraw(obj);
	return obj;
end

--设置相机参数
function UIPfxDraw:SetCamera(vecVport,vecEye,vecLook)
	if not self.objCamera then
		self.objCamera = _Camera.new();
	end
	--local vecVport = vecVport or _Vector2.new(200,400);
	self.objCamera.look = vecLook or _Vector3.new(0,0,0);
	self.objCamera.eye = vecEye or _Vector3.new(1,1,1);
	--self.objCamera.viewport = _Rect.new(0,0,vecVport.x,vecVport.y);
end

--设置渲染,默认为渲染
function UIPfxDraw:SetDraw(bIsRender) 
	if self.bIsRender == bIsRender then return; end
	self.bIsRender = bIsRender;
	if bIsRender then
		if not self.objDrawBoard then
			self.objDrawBoard = _DrawBoard.new( self.vecVport.x, self.vecVport.y);
		end
		if self.objUILoader then
			self.objUILoader:loadMovie(self.objDrawBoard);
			self.objUILoader.hitTestDisable = true;
		end
		if self.pfxName and self.pfxName~="" then
			self:PlayPfx(self.pfxName);
		end
	else
		if self.objUILoader and self.objUILoader.unloadMovie then
			self.objUILoader:unloadMovie();
		end
		if self.objDrawBoard then
			self.objDrawBoard = nil;
			LuaGC();
		end
	end
end

--设置UILoader
function UIPfxDraw:SetUILoader(objUILoader)
   	self.objUILoader = objUILoader;
end

--播放特效
function UIPfxDraw:PlayPfx(resName)
	if not self.pfxSkl then
		self.pfxSkl = _Skeleton.new()
	end
	if not resName or resName == "" then
		return
	end
	if resName == self.pfxName then
		self.pfxSkl.pfxPlayer:reset(resName)
	else
		asyncLoad(true)
		local pfx = self.pfxSkl.pfxPlayer:play(resName, resName)
		self.pfxName = resName
		pfx.keepInPlayer = true
	end
end

function UIPfxDraw:StopPfx()
	if not self.pfxSkl then return; end
	if not self.pfxName or self.pfxName=="" then return; end
	self.pfxSkl.pfxPlayer:stop(self.pfxName,true);
end

local tempCamera = _Camera:new();
--渲染方法
function UIPfxDraw:RenderSkl()
	if not self.pfxSkl then 
		return; 
	end
	_rd:useDrawBoard( self.objDrawBoard , self.backColor)
	tempCamera:set(_rd.camera);--保存当前摄像机
	_rd.camera:set(self.objCamera);							--设置摄像机
	if self.objAmbLight then _rd:useLight(self.objAmbLight); end; 
	self.pfxSkl:drawSkeleton(); 
	if self.objAmbLight then  _rd:popLight(); end;
	_rd.camera:set(tempCamera);	--还原摄像机
	_rd:resetDrawBoard( )
end

--销毁
function UIPfxDraw:Destroy()
	self:StopPfx();
	self.pfxName = "";
	self.bIsRender = false;
	self.pfxSkl = nil;
	self.objUILoader = nil;
	self.objCamera = nil;
	self.objDrawBoard = nil;
end