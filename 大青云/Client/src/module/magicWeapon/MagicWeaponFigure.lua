--[[
神兵：外观
liyuan
]]
_G.MagicWeaponFigure = {}
setmetatable(MagicWeaponFigure,{__index = CAvatar})
MagicWeaponFigure.FollowDis = 30 		-- 跟随距离
MagicWeaponFigure.FollowSpeed = 50 		-- 跟随速度
MagicWeaponFigure.FollowCount = 0		-- 行走次数
MagicWeaponFigure.fwrpdis = 30			-- 行走动作播放距离

MagicWeaponFigure.curPos = nil			-- 坐标
MagicWeaponFigure.isEnterMap = nil
MagicWeaponFigure.modelId = nil

function MagicWeaponFigure:UpdateSpeed(speed)
	MagicWeaponFigure.FollowSpeed = speed
end

function MagicWeaponFigure:new(cfg, liuguang, liuspeed)
	local mesh = cfg.skn_scene
	local skl = cfg.skl_scene
	local san = cfg.follow_idle
	local walksan = cfg.walk_idle or ""
	-- Debug(mesh, skl, san, liuguang, liuspeed)
	local obj = CAvatar:new()
	obj.pickFlag = enPickFlag.EPF_Null
	obj.avtName = "magicWeapon"
    local sm = obj:SetPart("Body", mesh)
	--for i, v in next, obj.objMesh:getSubMeshs() do v.isPaint = true end
	obj.objMesh:enumMesh('', true, function(mesh, name)
		mesh.isPaint = true
	end)
	obj.objMesh:setEnvironmentMap(_Image.new(liuguang), true, 1)
	obj.objMesh.isPaint = true
	obj.objMesh.blender = _Blender.new()
	obj.objMesh.blender:environment(0, 0, 0.5, 1, 0, 1.5, false, 10000)
	obj.objMesh.blender.playMode = _Blender.PlayPingPong
	obj:ChangeSkl(skl)
    obj:SetIdleAction(san, true)
	
	local params = split(cfg.followparams,",");
	obj.followdis = table.remove(params,1);
	obj.followdis = obj.followdis and tonumber(obj.followdis) or 30;
	obj.followangel = table.remove(params,1);
	obj.followangel = obj.followangel and tonumber(obj.followangel) or 0;
	obj.followangel = obj.followangel*math.pi/180;
	
	if walksan and walksan ~= "" then
		obj:SetMoveAction(walksan, false)
	end
	
    setmetatable(obj, {__index = MagicWeaponFigure})
	--Debug("MagicWeaponFigure:new ", mesh, self, debug.traceback())
    return obj
end

function MagicWeaponFigure:ChangeMagicWeapon(cfg, liuguang, liuspeed)
	local mesh = cfg.skn_scene
	local skl = cfg.skl_scene
	local san = cfg.follow_idle
	local walksan = cfg.walk_idle or ""
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
	
    self:SetIdleAction(san, true)
	if walksan and walksan ~= "" then
		self:SetMoveAction(walksan, false)
	end
	--Debug("MagicWeaponFigure:ChangeMagicWeapon ", mesh, self, debug.traceback())
end

--进入地图callback
function MagicWeaponFigure:OnEnterScene(objNode)
    objNode.dwType = enEntType.eEntType_MagicWeapon
end

local pos = _Vector2.new()
function MagicWeaponFigure:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	if ArenaBattle.inArenaScene == 1 then return; end
	pos.x = fXPos - self.followdis * math.sin(fDirValue + self.followangel);
	pos.y = fYPos + self.followdis * math.cos(fDirValue + self.followangel);
	self:EnterSceneMap(objSceneMap, pos, fDirValue);
	self.isEnterMap = true

	--[[
	-- if not self.isEnterMap then
		pos.x = fXPos - 10 * math.sin(fDirValue);
		pos.y = fYPos + 10 * math.cos(fDirValue)
		self:EnterSceneMap(objSceneMap, pos, fDirValue)
		-- self.objNode.dwType = enEntType.eEntType_MagicWeapon
		self.isEnterMap = true
	-- end
	]]
end

function MagicWeaponFigure:ExitMap()
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
end;

function MagicWeaponFigure:Hide(time)
	self:PlayerPfx(10024)
	self.hideTime1 = TimerManager:RegisterTimer(function()
	    if self and self.objNode and self.objNode.entity then
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
