_G.classlist['PlayerPendant'] = 'PlayerPendant';
_G.PlayerPendant = {};
PlayerPendant.sceneAvatar = nil;
----- 跟随模式下使用
PlayerPendant.FollowDis = 20 -- 跟随距离
PlayerPendant.FollowSpeed = 50 -- 跟随速度
PlayerPendant.FollowCount = 0 -- 行走次数
PlayerPendant.fwrpdis = 30 -- 行走动作播放距离
PlayerPendant.curPos = nil -- 坐标
-------------
function PlayerPendant:new(id)
	local obj = {}
	obj.name = 'Pendant' .. id;
	obj.id = id;
	obj.config = self:ParseConfig(t_pendant[id]);
	obj.parts = self:GetParts(obj.config);
	obj.meshDir = 0;
	obj.curPos = self.curPos;
	setmetatable(obj, { __index = PlayerPendant })
	return obj;
end

function PlayerPendant:Bind(player)
	self.player = player;
	self:Refresh();
end

function PlayerPendant:Refresh()
	if not self.player then
		return;
	end

	local type = self.config.config.type;
	if type == 1 then
		self:BindScene();
	elseif type == 2 then
		self:BindPlayer();
	elseif type == 3 then
		self:BindFollow();
	end
end

function PlayerPendant:BindScene()
	local skl = self.player:GetSkl();
	if self.sceneAvatar then
		self.sceneAvatar:ExitSceneMap();
		self.sceneAvatar = nil;
	end
	self.sceneAvatar = CAvatar:new();
	self.sceneAvatar.ownerId = self.player:GetRoleID();
	for i = 1, #self.parts do
		local part = self.parts[i];
		if part.skl then
			part:ChangeSkl(part.skl);
			local mat = _Matrix3D.new();
			local scale = self.config.config.model_scale;
			mat:setScaling(scale, scale, scale);
			part:GetSkl():adjustRoot(mat);
		end
		part:SetPart(part.skn, part.skn);
		if part.point then
			local mat = nil;
			if not part.point or part.point == 'root' then
				mat = _Matrix3D.new();
				mat:identity();
			else
				mat = skl:getBone(part.point);
			end
			mat:mulTranslationLeft(0, 0, part.config.model_hight);
			part.objMesh.transform = mat;
		end
		self.sceneAvatar.objMesh:addSubMesh(part.objMesh);
		part:ExecAction(part.san, true, nil, true);
	end

	local currScene = CPlayerMap:GetSceneMap();
	local pos = self.player:GetPos();
	self.sceneAvatar:EnterSceneMap(currScene,
		_Vector3.new(pos.x, pos.y, 0),
		0)
	if self.sceneAvatar.objNode then
		self.sceneAvatar.objNode.dwType = enEntType.eEntType_Pet;
	end
	self.sceneMat = self.sceneMat or _Matrix3D.new();

	self:PlayInitActions();
end

function PlayerPendant:BindPlayer()
	local skl = self.player:GetSkl();
	for i = 1, #self.parts do
		local part = self.parts[i];
		if part.skl then
			part:ChangeSkl(part.skl);
			local mat = _Matrix3D.new();
			local scale = self.config.config.model_scale;
			mat:setScaling(scale, scale, scale);
			part:GetSkl():adjustRoot(mat);
		end
		part:SetPart(part.skn, part.skn);
		if part.point then
			local mat = nil;
			if not part.point or part.point == 'root' then
				mat = _Matrix3D.new();
				mat:identity();
			else
				mat = skl:getBone(part.point);
			end
			mat:mulTranslationLeft(0, 0, part.config.model_hight);
			part.objMesh.transform = mat;
		end
		self.player.objMesh:addSubMesh(part.objMesh);
		part:ExecAction(part.san, true, nil, true);
	end

	self:PlayInitActions();
end

function PlayerPendant:BindFollow()
	self:BindScene();
	self:ResetPos();
end

function PlayerPendant:PlayInitActions()
end

function PlayerPendant:PlayAction(action)
end

function PlayerPendant:OnUpdate(e)
	if not self.player then
		return;
	end

	if self.sceneAvatar then
		local type = self.config.config.type;
		if type == 1 then
			self.sceneMat.parent = self.player.objNode.transform;
			self.sceneMat.ignoreRotation = true;
			self.sceneAvatar.objNode.transform:set(self.sceneMat);
		end

		if type == 3 and self.sceneAvatar:IsInMap() then
			if not self.mwDiff then self.mwDiff = _Vector3.new() end
			local player = CPlayerMap:GetPlayer(self.player.dwRoleID);
			local pos = player:GetPos()
			local speed = player:GetSpeed() or 40;
			self.mwDiff = _Vector3.sub(pos, self.curPos, self.mwDiff)

			local dis = self.mwDiff:magnitude()

			if dis > self.FollowDis then
				self.mwDiff = self.mwDiff:normalize():mul(dis - self.FollowDis + 0.01)
				self.curPos = self.curPos:add(self.mwDiff)
				self.sceneAvatar:MoveTo(self.curPos, function() end, speed, nil, true)
			end
		end
	end
end

function PlayerPendant:ResetPos(isForce)
	if not self.objNode then return; end
	local player = self.player;
	local pos = player:GetPos()
	if not pos then return; end
	if isForce or not self.curPos then

		self.curPos = _Vector3.new()

		local dir = player:GetDirValue()
		self.curPos.x = pos.x - 10 * math.sin(dir)
		self.curPos.y = pos.y + 10 * math.cos(dir)
		self.curPos.z = pos.z

		self.sceneAvatar:SetDirValue(dir)
		self.sceneAvatar:SetPos(self.curPos)
	end
end

function PlayerPendant:GetParts(config)
	if not config then
		return;
	end

	local parts = {};
	for i = 1, #config.skns do
		local avatar = CAvatar:new();
		avatar.skn = config.skns[i];
		if config.skls then
			avatar.skl = config.skls[i];
		end
		if config.sans then
			avatar.san = config.sans[i];
		end
		if config.points then
			avatar.point = config.points[i];
		end
		avatar.name = avatar.skn;
		avatar.config = config.config;
		parts[i] = avatar;
	end
	return parts;
end

function PlayerPendant:ParseConfig(config)
	local obj = {};
	local nums = {};
	if not config then return; end
	obj.skls = GetPoundTable(config.skl);
	obj.skns = GetPoundTable(config.skn);
	obj.sans = GetPoundTable(config.san);
	obj.points = GetPoundTable(config.bind_point);
	obj.hight = config.model_hight;
	obj.config = config;
	return obj;
end

function PlayerPendant:SetVisible(visible)
	if self.sceneAvatar and self.sceneAvatar.objNode then
		self.sceneAvatar.objNode.visible = visible;
	end
end

function PlayerPendant:Destroy()
	local type = self.config.config.type;
	local nodeAvatar = type == 1 and self.sceneAvatar or self.player;
	for i = 1, #self.parts do
		local part = self.parts[i];
		if nodeAvatar then
			if nodeAvatar.objMesh then --changer：houxudong date:2016/8/20 0:29:25
			nodeAvatar.objMesh:delSubMesh(part.objMesh);
			end
		end
		part.skn = nil;
		part.skl = nil;
		part.point = nil;
		part.san = nil;
		part.name = nil;
		part:Destroy();
	end

	if self.sceneAvatar then
		self.sceneAvatar:ExitSceneMap();
	end

	self.config = nil;
	nodeAvatar = nil;
	self.sceneAvatar = nil;
	self.parts = nil;
	self.sceneMat = nil;
	self.player.RotateCallback = nil;
	self.curPos = nil;
end

