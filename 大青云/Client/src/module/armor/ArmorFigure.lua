--[[
宝甲：外观
liyuan
]]
_G.ArmorFigure = {}
setmetatable(ArmorFigure,{__index = CAvatar})
ArmorFigure.FollowDis = 20 		-- 跟随距离
ArmorFigure.FollowSpeed = 50 		-- 跟随速度
ArmorFigure.FollowCount = 0		-- 行走次数
ArmorFigure.fwrpdis = 30			-- 行走动作播放距离

ArmorFigure.curPos = nil			-- 坐标
ArmorFigure.isEnterMap = nil
ArmorFigure.modelId = nil

function ArmorFigure:UpdateSpeed(speed)
	ArmorFigure.FollowSpeed = speed
end

function ArmorFigure:new(cfg, liuguang, liuspeed)
	local mesh = cfg.skn_scene
	local skl = cfg.skl_scene
	local san = cfg.follow_idle
	local walksan = cfg.walk_idle or ""
	-- Debug(mesh, skl, san, liuguang, liuspeed)
	local obj = CAvatar:new()
	obj.pickFlag = enPickFlag.EPF_Null
	obj.avtName = "armor"
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
	if walksan and walksan ~= "" then
		obj:SetMoveAction(walksan, false)
	end
	
    setmetatable(obj, {__index = ArmorFigure})
	--Debug("ArmorFigure:new ", mesh, self, debug.traceback())
    return obj
end

function ArmorFigure:ChangeMagicWeapon(cfg, liuguang, liuspeed)
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
    self:SetIdleAction(san, true)
	if walksan and walksan ~= "" then
		self:SetMoveAction(walksan, false)
	end
	--Debug("ArmorFigure:ChangeMagicWeapon ", mesh, self, debug.traceback())
end

--进入地图callback
function ArmorFigure:OnEnterScene(objNode)
    objNode.dwType = enEntType.eEntType_MagicWeapon
end

local pos = _Vector2.new()
function ArmorFigure:EnterMap(objSceneMap, fXPos, fYPos, fDirValue)
	-- if not self.isEnterMap then
		pos.x = fXPos - 10 * math.sin(fDirValue); pos.y = fYPos + 10 * math.cos(fDirValue)
		self:EnterSceneMap(objSceneMap, pos, fDirValue)
		-- self.objNode.dwType = enEntType.eEntType_MagicWeapon
		self.isEnterMap = true
	-- end
end

function ArmorFigure:ExitMap()
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

function ArmorFigure:Hide(time)
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
