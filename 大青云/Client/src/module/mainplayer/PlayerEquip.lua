_G.classlist['PlayerEquip'] = 'PlayerEquip'
_G.PlayerEquip = {}
PlayerEquip.objName = 'PlayerEquip'
PlayerEquip.actionQueue = nil;
PlayerEquip.battle = false;
PlayerEquip.actionIndex = 0;

PlayerEquip.currAction = nil;
PlayerEquip.queueActCompleted = nil;
PlayerEquip.actionPlaying = false;

PlayerEquip.ToBattleAction = 0;
PlayerEquip.ToNormalAction = 1;

PlayerEquip.Loop = false;


function PlayerEquip:new(equipId)
	local obj = {}
	obj.name = 'Equip'..tostring(equipId);
	obj.id = equipId;
	obj.config = self:ParseConfig(t_equipmodel[equipId]);
	obj.parts = self:GetParts(obj.config);
	setmetatable(obj, {__index = PlayerEquip})
    return obj;
end

--绑定角色
function PlayerEquip:Bind(player)
	self.player = player;
	self:Refresh();
end

function PlayerEquip:Refresh()
	if not self.player then
		return;
	end
	local skl = self.player:GetSkl();
	local config = t_equipmodel[self.id];
	for i = 1,#self.parts do
		local part = self.parts[i];
		part.sketch = self.player.sketch;
		part.closeEffect = config.close_effect;
		part.closeEnvironment = config.close_liuguang;
		if part.skl then
			part:ChangeSkl(part.skl);
		end
		part:SetPart(part.skn,part.skn);
		if part.point then
			local mat = skl:getBone(part.point);
			part.objMesh.transform = mat;
		end
		self.player.objMesh:addSubMesh(part.objMesh);
	end
	self:PlayInitActions();
end

function PlayerEquip:PlayInitActions()
	self.actionQueue = {};
	if self.player.bIsAttack then	
		table.push(self.actionQueue,{action='tnbsan',count=0});		
		table.push(self.actionQueue,{action='bsan',count=0});
	else
		table.push(self.actionQueue,{action='nbsan',count=0});
		table.push(self.actionQueue,{action='tnbsan',count=0});
		table.push(self.actionQueue,{action='bsan',count=0});
		table.push(self.actionQueue,{action='tbsan',count=0});
		table.push(self.actionQueue,{action='nbsan',count=0});
	end
	self.actionIndex = 1;
	self:PlayActionQueue(self.actionQueue,self.actionIndex);
end

function PlayerEquip:PlayActionByDir(dir)
	self.actionIndex = 1;
	self.actionQueue = self:GetActionQueue(dir);
	self:PlayActionQueue(self.actionQueue,self.actionIndex);
end

function PlayerEquip:PlayActionByParam(actions)
	if not actions or #actions<1 then
		return;
	end
	self.actionQueue = {};
	for i,action in ipairs(actions) do
		table.push(self.actionQueue,{action=action,count=0});
	end
	self.actionIndex = 1;
	self:PlayActionQueue(self.actionQueue,self.actionIndex);
end

--根据人物状态改变动作
function PlayerEquip:AllChangeBattleSan(battle)
	self.battle = battle;
	for i = 1,#self.parts do
		local part = self.parts[i];
		part:StopAllAction();
	end
	
	self.actionIndex = 1;
	if battle then
		self.actionQueue = self:GetActionQueue(PlayerEquip.ToBattleAction);
	else
		self.actionQueue = self:GetActionQueue(PlayerEquip.ToNormalAction);
	end
	self:PlayActionQueue(self.actionQueue,self.actionIndex);
end

function PlayerEquip:playShapeAction(param)
	for k, part in pairs(self.parts) do
		if part.partname == param.part then
			part:setShapeInfo(param)
		end
	end
end

function PlayerEquip:PlayActionQueue(queue,index)
	if not queue or #queue<1 then
		self.actionPlaying = false;
		if self.queueActCompleted then
			self.queueActCompleted(self.id);
		end
		return;
	end
	
	self.actionQueue = queue;
	self.actionIndex = index;
	local completed = function(part,anima) self:ActionCompleted(part,anima); end
	return self:PlayAction(self.actionQueue[self.actionIndex].action,completed);
end

function PlayerEquip:PlayAction(action,completed)
	if not action then
		return;
	end
	
	self.actionPlaying = true;
	self.currAction = action;
	for i = 1,#self.parts do
		local part = self.parts[i];
		if not part[action] then
			if completed then
				completed(part);
			end
		else
			self.Loop = false;
			if part.loop then
				self.Loop = part.loop[part[action]];
			end
			local duration, anima = part:ExecAction(part[action],self.Loop,completed,true);
			anima.action = action;
		end
	end
	return true;
end

function PlayerEquip:ActionCompleted(part,anima)
	if anima and anima.action ~= self.currAction then
		return;
	end
	if not self.actionQueue or self.actionIndex ==0 then
		return;
	end
	local action = self.actionQueue[self.actionIndex];
	action.count = action.count+1;
	if action.count < #self.parts then
		return;
	end
	
	self.currAction = nil;
	self.actionIndex = self.actionIndex+1;
	if self.actionIndex>#self.actionQueue then
		self.actionQueue = nil;
		self.actionIndex = 0;
		if self.queueActCompleted then
			self.actionPlaying = false;
			self.queueActCompleted(self.id);
		end
	else
		self:PlayActionQueue(self.actionQueue,self.actionIndex);
	end
end

--获取动作队列
function PlayerEquip:GetActionQueue(dir)
	local queue = nil; 
	if dir == PlayerEquip.ToBattleAction then
		queue = {};
		table.push(queue,{action='tnbsan',count=0});
		table.push(queue,{action='bsan',count=0});
	elseif dir == PlayerEquip.ToNormalAction then
		queue = {};
		table.push(queue,{action='tbsan',count=0});
		table.push(queue,{action='nbsan',count=0});
	end
	return queue;
end

function PlayerEquip:ParseConfig(config)
	local obj = {};
	local nums = {};
	if not config then return; end
	obj.position = config.postion;
	obj.skls = GetPoundTable(config.skl);
	obj.points = GetPoundTable(config.bind_point);
	obj.skns = GetPoundTable(config.skn);
	obj.bsans =  GetPoundTable(config.weapon_battle_san);
	if obj.bsans then
		table.push(nums,#obj.bsans);
	end
	obj.nbsans =  GetPoundTable(config.weapon_non_battle_san);
	if obj.nbsans then
		table.push(nums,#obj.nbsans);
	end
	obj.tnbsans =  GetPoundTable(config.weapon_non_battle_san_transit);
	if obj.tnbsans then
		table.push(nums,#obj.tnbsans);
	end
	obj.tbsans =  GetPoundTable(config.weapon_battle_san_transit);
	if obj.tbsans then
		table.push(nums,#obj.tbsans);
	end
	obj.partnames = GetPoundTable(config.part)
	if obj.partnames then
		table.push(nums, #obj.partnames)
	end
	if #nums>0 then
		obj.maxActNum = math.max(unpack(nums));
	else
		obj.maxActNum = 0;
	end
	
	local loops = GetPoundTable(config.loop);
	if loops then
		obj.loops = {};
		for i,loop in ipairs(loops) do
			local parent = GetVerticalTable(loop);
			local data = {};
			for j,node in ipairs(parent) do
				local ns = GetColonTable(node);
				data[ns[1]] = ns[2] == 'true' and true or false;
			end
			table.push(obj.loops,data)
		end
	end
	
	return obj;
end

function PlayerEquip:GetMaxActionNum()
	return self.config.maxActNum;
end

function PlayerEquip:GetParts(config)
	if not config then
		return;
	end
	
	local parts = {};
	for i = 1,#config.skns do
		local avatar = CAvatar:new();
		avatar.skn = config.skns[i];
		if config.skls then
			avatar.skl = config.skls[i];
		end
		if config.points then
			avatar.point = config.points[i];
		end
		if config.nbsans then
			avatar.nbsan = config.nbsans[i];
		end
		if config.bsans then
			avatar.bsan = config.bsans[i];
		end
		if config.tbsans then
			avatar.tbsan = config.tbsans[i];
		end
		if config.tnbsans then
			avatar.tnbsan = config.tnbsans[i];
		end
		if config.loops then
			avatar.loop = config.loops[i];
		end
		avatar.name = avatar.skn;
		avatar.partname = config.partnames and config.partnames[i] or ""
		parts[i] = avatar;
	end
	return parts;
end

function PlayerEquip:Destroy()
	self.config  = nil;
	self.actionQueue = nil;
	self.battle = false;
	self.actionIndex = 0;
	self.actionPlaying = false;
	if self.queueActCompleted then
		self.queueActCompleted(self.id);
	end
	self.queueActCompleted = nil;
	self.id = 0;
	
	for i = 1,#self.parts do
		local part = self.parts[i];
		if self.player and self.player.objMesh then
			self.player.objMesh:delSubMesh(part.objMesh);
		end
		part.skn = nil;
		part.skl = nil;
		part.point = nil;
		part.nbsan = nil;
		part.bsan = nil;
		part.name = nil;
		part:Destroy();
	end
	self.parts  = nil;
	self.player = nil;
	
end

function PlayerEquip:OnUpdate()
	for k, part in pairs(self.parts) do
		part:updateScaling()
	end
end

function PlayerEquip:GetPosition()
	local pos = self.config and self.config.position or 0;
	return pos;
end
