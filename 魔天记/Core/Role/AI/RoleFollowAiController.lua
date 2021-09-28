require "Core.Role.AI.AbsAiController";

RoleFollowAiController = class("RoleFollowAiController", AbsAiController)

RoleFollowAiController.FOLLOW_TYPE_LEADER = 1; -- 队长
RoleFollowAiController.FOLLOW_TYPE_OTHER = 2; -- 其他人

RoleFollowAiController.MESSAGE_FOLLOWTARGET_CHANGE = "MESSAGE_FOLLOWTARGET_CHANGE";


-- 只能跟随 某个角色
--[[HeroController:Die         --
HeroController:MoveToAngle
HeroController:MovePath
HeroController:MoveTo
HeroController:MoveToNpc
HeroController:CastSkill
HeroController:StartAutoFight
HeroController:StopCurrentActAndAI  --
这几个方法都要停止跟随ai，然后你在跟随ai中，重写HeroController:MoveTo方法的功能

CmdType.GetRolePosInfo = 0x0313;

]]
-- IsPause
function RoleFollowAiController:New(role)
	self = {};
	setmetatable(self, {__index = RoleFollowAiController});
	self:_Init(role);
	self.waitTime = 0;
	return self;
end



-- 开始
function RoleFollowAiController:Start()
	
	self:Stop()
	
	if(self._timer == nil) then
		self._timer = Timer.New(function(val) self:_OnTickHandler(val) end, 1, - 1, false);
		-- 两秒 更新一次
	end
	self._timer:Start();
	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetRolePosInfo, self._GetRolePosInfoResult);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetRolePosInfo, self._GetRolePosInfoResult, self);
	
	self.hasInView = false;
	self.can_not_follow = false;
	
	-- 判断是否在视野内
	if GameSceneManager.map ~= nil then
		local inv = GameSceneManager.map:GetRoleById(self.currFollowTarget.target_id);
		
		if inv ~= nil then
			--  log("  " .. self.currFollowTarget.target_id .. "  in view ---------------");
			self.hasInView = true;
		else
			-- log("  " .. self.currFollowTarget.target_id .. "  not in view ---------------");
			self.hasInView = false;
		end
		
	end
	
	self:TryTargetInfo();
end

function RoleFollowAiController:SetFollowTarget(p_id, followType)
	
	if p_id == nil then
		self.currFollowTarget = nil;
	else
		self.currFollowTarget = {target_id = p_id, type = follow_type};
	end
	
	MessageManager.Dispatch(RoleFollowAiController, RoleFollowAiController.MESSAGE_FOLLOWTARGET_CHANGE);
end


-- 心跳调用函数，子类重写   2 秒
function RoleFollowAiController:_OnTimerHandler() 
	self:TryTargetInfo(); 
end

function RoleFollowAiController:TryTargetInfo()
	if self.currFollowTarget ~= nil then
		
		local t_id = self.currFollowTarget.target_id .. "";
		
		-- 如果 是 玩家 是 被  队长 通知跳场景的， 那么在跳场景 后，
		-- 需要看看 队长是否在 视野内， 如果在， 那么就马上 获取信息并跟随，
		-- 如果 不在 视野内， 那么就  等 5 秒
		if GameSceneManager.gotoSceneForFollow and GameSceneManager.map ~= nil then
			local role = GameSceneManager.map._roles:GetRole(t_id);
			if role == nil then
				self.waitTime = 3;
			else
				self.waitTime = 0;
			end
			
			GameSceneManager.gotoSceneForFollow = false;
		end
		
		if GameSceneManager.map == nil then
			self.waitTime = 1;
		end
		
		if self.waitTime > 0 then
			self.waitTime = self.waitTime - 1;
			-- log("  self.waitTime  " .. self.waitTime);
		else
			SocketClientLua.Get_ins():SendMessage(CmdType.GetRolePosInfo, {id = t_id});
		end
		
	end
end

function RoleFollowAiController:_GetRandomPosition()
	-- math.randomseed(os.time());
	local masterPt = self.targetPosInfo;
	
	local res = {};
	res.x = masterPt.x * 0.01 + math.random() * 0.5 + 0.5;
	res.z = masterPt.z * 0.01 + math.random() * 0.5 + 0.5;
	res.y = masterPt.y;
	return MapTerrain.SampleTerrainPosition(res);
	
end

function RoleFollowAiController:GetDistance(pos1, pos2)
	
	local dx = pos1.x - pos2.x;
	local dz = pos1.z - pos2.z;
	
	local dl = dx * dx + dz * dz;
	dl = math.sqrt(dl);
	return dl * 0.01;
end


function RoleFollowAiController:CheckInView(p_id)
	
	if self.currFollowTarget ~= nil then
		
		p_id = p_id + 0;
		local target_id = self.currFollowTarget.target_id + 0;
		
		-- log("------------------------RoleFollowAiController:CheckInView---------------------------  " .. p_id);
		if p_id == target_id then
			self.hasInView = true;
		end
		
	end
	
	
end

--   S <-- 15:05:23.402, 0x0313, 22, {"z":-576.0,"mapId":"709999","y":55.0,"x":-53.0,"id":"20100582"}
function RoleFollowAiController:_GetRolePosInfoResult(cmd, data)
	
	if(data.errCode == nil) then
		
		if GameSceneManager.goingToScene then
			-- 正在跳场景的时候， 不能 有跟随动作
			return;
		end
		
		self.targetPosInfo = data;
		
		local mapId = self.targetPosInfo.mapId + 0;
		local currId = GameSceneManager.id + 0;
		
		-- log("--------_GetRolePosInfoResult-------- " .. mapId .. "  " .. currId);
		self.can_not_follow = false;
		if mapId == currId then
			-- 如果是 同一个场景， 那么久 直接 移动到目标位置
			local my_position = HeroController:GetInstance().transform.position;
			
			--  log("myPos " .. my_position.x .. " " .. my_position.z);
			--  log("tgPos " .. self.targetPosInfo.x .. " " .. self.targetPosInfo.z);
			local dl = self:GetDistance({x = my_position.x * 100, z = my_position.z * 100}, self.targetPosInfo);
			
			--  log("--------- dl " .. dl);
			if dl < 3 then
				-- 不需要 继续跟随了
			else
				local pt = self:_GetRandomPosition();
				HeroController:GetInstance():MoveToForFollow(pt);
			end
			
		else
			
			-- 不在同一个场景， 如果目标位置是在副本中， 那么久不能进入， 否则可以进入
			local mapCf = ConfigManager.GetMapById(mapId);
			local mymapCf = ConfigManager.GetMapById(currId);
			
			if(mapCf.type == InstanceDataManager.MapType.Field or mapCf.type == InstanceDataManager.MapType.Main) and
			(mymapCf.type == InstanceDataManager.MapType.Field or mymapCf.type == InstanceDataManager.MapType.Main) then
				-- 不在 副本中， 可以跟随
				-- 跳到目标场景
				-- 这里需要 判断 跟随后是否 有过 在同一个试图
				local toScene
				if self.hasInView then
					-- 同在 试图内， 那么就传送到 目标 场景位置上
					local tx = self.targetPosInfo.x + math.random() * 50;
					local ty = self.targetPosInfo.y;
					local tz = self.targetPosInfo.z + math.random() * 50;
					
					toScene = {}
					toScene.sid = mapId;
					toScene.position = Convert.PointFromServer(tx, ty, tz);
					toScene.rot = 0;				
				end
				
				-- 在跳场景之前必须停止当前 动作
				HeroController:GetInstance():StopActBeforGoToScene();
				GameSceneManager.GotoScene(mapId, nil, toScene);
				
			elseif mapCf.type == InstanceDataManager.MapType.Guild then
				-- elseif mapCf.type == InstanceDataManager.MapType.Guild and mymapCf.type ~= InstanceDataManager.MapType.Instance then
				-- http://192.168.0.8:3000/issues/2612
				-- 队员是同一个仙盟 的话， 可以跟去 仙盟驻地
				local myHero = HeroController.GetInstance();
				local mydata = myHero.info;
				local my_id = mydata.id .. "";
				local t_id = self.targetPosInfo.id;
				local b = PartData.CheckIsSameGuild(my_id, t_id)
				
				
				if b then
					local toScene;
					if self.hasInView then
						-- 同在 试图内， 那么就传送到 目标 场景位置上
						local tx = self.targetPosInfo.x + math.random() * 50;
						local ty = self.targetPosInfo.y;
						local tz = self.targetPosInfo.z + math.random() * 50;
						
						toScene = {};
						toScene.sid = mapId;
						toScene.position = Convert.PointFromServer(tx, ty, tz);
						toScene.rot = 0;
					end
					
					
					-- 在跳场景之前必须停止当前 动作
					HeroController:GetInstance():StopActBeforGoToScene();
					GameSceneManager.GotoScene(mapId,nil,toScene);
					
				else
					
					self.can_not_follow = true;
					MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("RoleFollowAiController/label1", {n = mapCf.name}));
				end
				
			else
				-- 在副本中， 不能跟随
				self.can_not_follow = true;
				MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("RoleFollowAiController/label1", {n = mapCf.name}));
				
			end
			
		end
		
		
		
		
	else
		-- 出错  停止  跟随
		-- self._role:StopFollow();
	end
	
	
end

function RoleFollowAiController:Dispose()
	
	self.hasInView = false;
	self:Stop();
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetRolePosInfo, self._GetRolePosInfoResult);
end 