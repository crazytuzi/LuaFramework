--[[
法宝：外观
liyuan
]]
_G.LingQiFigure = {}
setmetatable(LingQiFigure, { __index = CAvatar })
LingQiFigure.FollowDis = 30 -- 跟随距离
LingQiFigure.FollowSpeed = 50 -- 跟随速度
LingQiFigure.FollowCount = 0 -- 行走次数
LingQiFigure.fwrpdis = 30 -- 行走动作播放距离

LingQiFigure.curPos = nil -- 坐标
LingQiFigure.isEnterMap = nil
LingQiFigure.modelId = nil
LingQiFigure.fadeTime = 0;
LingQiFigure.san = "";
LingQiFigure.xiuxian = "";
LingQiFigure.showDelay = 0;
LingQiFigure.hideDelay = 0;
function LingQiFigure:UpdateSpeed(speed)
	LingQiFigure.FollowSpeed = speed
end

function LingQiFigure:new(cfg, liuguang, liuspeed)
	local mesh = cfg.skn_scene
	local skl = cfg.skl_scene
	self.san = cfg.follow_idle
	self.xiuxian = cfg.san_idle
	local walksan = cfg.walk_idle or ""
	local timeArr = GetCommaTable(cfg.hide);
	self.showDelay = toint(timeArr[1]);
	self.hideDelay = toint(timeArr[2]);
	self.fadeTime = toint(timeArr[3]);
	-- Debug(mesh, skl, san, liuguang, liuspeed)
	local obj = CAvatar:new()
	obj.pickFlag = enPickFlag.EPF_Null
	obj.avtName = "lingQi"
	local sm = obj:SetPart("Body", mesh)
	--for i, v in next, obj.objMesh:getSubMeshs() do v.isPaint = true end
	obj.objMesh:enumMesh('', true, function(mesh, name)
		mesh.isPaint = true
	end)
	
	local params = split(cfg.followparams,",");
	obj.followdis = table.remove(params,1);
	obj.followdis = obj.followdis and tonumber(obj.followdis) or 30;
	obj.followangel = table.remove(params,1);
	obj.followangel = obj.followangel and tonumber(obj.followangel) or 0;
	obj.followangel = obj.followangel*math.pi/180;
	
	obj.objMesh:setEnvironmentMap(_Image.new(liuguang), true, 1)
	obj.objMesh.isPaint = true
	obj.objMesh.blender = _Blender.new()
	obj.objMesh.blender:environment(0, 0, 0.5, 1, 0, 1.5, false, 10000)
	obj.objMesh.blender.playMode = _Blender.PlayPingPong
	obj:ChangeSkl(skl)
	obj:SetIdleAction(self.san, true)
	if walksan and walksan ~= "" then
		obj:SetMoveAction(walksan, false)
	end

	setmetatable(obj, { __index = LingQiFigure })
	--Debug("LingQiFigure:new ", mesh, self, debug.traceback())
	return obj
end

function LingQiFigure:ChangeMagicWeapon(cfg, liuguang, liuspeed)
	local mesh = cfg.skn_scene
	local skl = cfg.skl_scene
	self.san = cfg.follow_idle
	self.xiuxian = cfg.san_idle
	local walksan = cfg.walk_idle or ""
	local timeArr = GetCommaTable(cfg.hide);
	self.showDelay = toint(timeArr[1]);
	self.hideDelay = toint(timeArr[2]);
	self.fadeTime = toint(timeArr[3]);
	local sm = self:SetPart("Body", mesh)
	self.objMesh:enumMesh('', true, function(mesh, name)
		mesh.isPaint = true
	end)
	self.objMesh:setEnvironmentMap(_Image.new(liuguang), true, 1)
	self.objMesh.isPaint = true
	self.objMesh.blender = _Blender.new()
	self.objMesh.blender:environment(0, 0, 0.5, 1, 0, 1.5, false, 10000)
	self.objMesh.blender.playMode = _Blender.PlayPingPong
	self:ChangeSkl(skl)
	
	local params = split(cfg.followparams,",");
	self.followdis = table.remove(params,1);
	self.followdis = self.followdis and tonumber(self.followdis) or 30;
	self.followangel = table.remove(params,1);
	self.followangel = self.followangel and tonumber(self.followangel) or 0;
	self.followangel = self.followangel*math.pi/180;
	
	self:SetIdleAction(self.san, true)
	if walksan and walksan ~= "" then
		self:SetMoveAction(walksan, false)
	end

	--Debug("LingQiFigure:ChangeLingQi ", mesh, self, debug.traceback())
end

function LingQiFigure:FadeIn()
	if not self.objMesh then
		return
	end
	if self.objMesh.objBlender then
		self:DeleteBlender()
	end
	self.objMesh.objBlender = _Blender.new()
	self.objMesh.objBlender:blend(0x00ffffff,0xffffffff,self.fadeTime);
end

function LingQiFigure:FadeOut()
	if not self.objMesh then
		return
	end
	if self.objMesh.objBlender then
		self:DeleteBlender()
	end
	self.objMesh.objBlender = _Blender.new()
	self.objMesh.objBlender:blend(0xffffffff,0x00ffffff,self.fadeTime);
end

function LingQiFigure:StartAutoIdle()
	local onHide = nil;
	local onShow = nil;
	onShow = function()
		if self.objNode then
			self.objNode.visible = true
		end

		self:FadeIn();
		self.aIdleTimer1 = TimerManager:RegisterTimer(function()
			--播放休闲动作
			--[[self:ExecAction(self.xiuxian,false,function()
				self:ExecIdleAction();
				self.aIdleTimer2 = TimerManager:RegisterTimer(function()
					onHide();
				end, self.showDelay, 1)
			end,true);]]
			self.aIdleTimer2 = TimerManager:RegisterTimer(function()
				onHide();
			end, self.showDelay, 1)
		end, self.fadeTime, 1)
	end
	onHide = function()
		self:FadeOut();
		self.aIdleTimer3 = TimerManager:RegisterTimer(function()
			if self.objNode then
				self.objNode.visible = false
			end

			self.aIdleTimer4 = TimerManager:RegisterTimer(function()
				onShow();
			end, self.hideDelay, 1)
		end, self.fadeTime, 1)
	end
	onShow();
end

function LingQiFigure:StopAutoIdle()
	if self.objMesh and self.objMesh.objBlender then
		self:DeleteBlender();
	end
	TimerManager:UnRegisterTimer(self.aIdleTimer1)
	self.aIdleTimer1 = nil
	TimerManager:UnRegisterTimer(self.aIdleTimer2)
	self.aIdleTimer2 = nil
	TimerManager:UnRegisterTimer(self.aIdleTimer3)
	self.aIdleTimer3 = nil
	TimerManager:UnRegisterTimer(self.aIdleTimer4)
	self.aIdleTimer4 = nil
end

--进入地图callback
function LingQiFigure:OnEnterScene(objNode)
	objNode.dwType = enEntType.eEntType_LingQi
	self:StopAutoIdle();
	self:StartAutoIdle();
end

local pos = _Vector2.new()
function LingQiFigure:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	pos.x = fXPos - self.followdis * math.sin(fDirValue + self.followangel);
	pos.y = fYPos + self.followdis * math.cos(fDirValue + self.followangel);
	self:EnterSceneMap(objSceneMap, pos, fDirValue);
	self.isEnterMap = true
	
	--[[
	-- if not self.isEnterMap then
	pos.x = fXPos - 10 * math.sin(fDirValue); pos.y = fYPos + 10 * math.cos(fDirValue)
	self:EnterSceneMap(objSceneMap, pos, fDirValue)
	-- self.objNode.dwType = enEntType.eEntType_LingQi
	self.isEnterMap = true
	-- end
	]]
end

function LingQiFigure:ExitMap()
	--assert(false, "fuck....")
	self:ExitSceneMap()
	self:Destroy()
	self.curPos = nil
	self.isEnterMap = nil
	self.modelId = nil
	if self.hideTime then
		TimerManager:UnRegisterTimer(self.hideTime)
		self.hideTime = nil
	end
	if self.hideTime1 then
		TimerManager:UnRegisterTimer(self.hideTime1)
		self.hideTime1 = nil
	end
	self:StopAutoIdle();
end

;

function LingQiFigure:Hide(time)
	self:PlayerPfx(10024)
	self.hideTime1 = TimerManager:RegisterTimer(function()
		if self and self.objNode and self.objNode.entity then
			self:StopAutoIdle()
			self.objNode.visible = false
		end
	end, 500, 1)
	if self.hideTime then
		TimerManager:UnRegisterTimer(self.hideTime)
		self.hideTime = nil
	end
	self.hideTime = TimerManager:RegisterTimer(function()
		if self and self.objNode and self.objNode.entity then
			self.objNode.visible = true
			self:PlayerPfx(10023)
		end
	end, time, 1)
end
