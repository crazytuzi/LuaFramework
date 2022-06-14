displayFuli = class("displayFuli");

function displayFuli:ctor()
	
	self.cameraPos = LORD.Vector3(0,0,0);
	self.cameraDir = LORD.Vector3(0,0,0);
	self.actorPos = LORD.Vector3(0,0,0);
	self.actorOri = LORD.Quaternion(1,0,0,0);
	self.actorScale = LORD.Vector3(1,1,1);
	
	self.actorName = "";
	self.skillName = "";
	
	self.actor = nil;
	
	self.playTime = 0;
	
	self.timer = -1;
	
	self.dardRatio = 0.65;
end

function displayFuli:setCameraParams(pos, dir)
	
	self.cameraPos = pos;
	self.cameraDir = dir;
	
end

function displayFuli:setActorParams(actorName, skillName, pos, ori, scale)
	
	self.actorName = actorName;
	self.skillName = skillName;
	self.actorPos = pos;
	self.actorOri = ori;
	self.actorScale = LORD.Vector3(scale, scale, scale);
end

function displayFuli:setDarkParam(ratio)
	self.dardRatio = ratio;
end

function displayFuli:start()

	homeland.setUnitVisible(false);
	homeland.showNotify = false;
	
	eventManager.dispatchEvent({ name = global_event.MAIN_UI_CLOSE });
	eventManager.dispatchEvent({ name = global_event.BLADEAWARD_SHOW });
	eventManager.dispatchEvent({ name = global_event.GUIDEDIALOGUE_HIDE });
	
	
	homeland.setCrystalVisible(false);
	
	-- 场景变黑
	if sceneManager.scene then
		sceneManager.scene:ChangeDark(self.dardRatio);
		homeland.changeBuildDarkExcludeCard(self.dardRatio);
	end
	
	-- 初始化摄像机位置
	local camera = LORD.SceneManager:Instance():getMainCamera();
	self.originPos = camera:getPosition();
	self.originDir = camera:GetDirection();
		
	camera:setPosition(self.cameraPos);
	camera:setDirection(self.cameraDir);
	
	if self.actor or self.timer > 0 then
		return;
	end
	
	-- 创建actor
	self.actor = LORD.ActorManager:Instance():CreateActor(self.actorName, self.skillName, false);
	self.actor:SetPosition(self.actorPos);
	self.actor:SetOrientation(self.actorOri);
	self.actor:SetScale(self.actorScale);
	
	self.playTime = 0.001 * self.actor:PlaySkill(self.skillName, false,false,1, -1, -1, self.actor:getActorNameID());	
	
	scheduler.performWithDelayGlobal(function() 
		self:endPlay();
	end, self.playTime);
	
end

function displayFuli:endPlay()

	homeland.setUnitVisible(true);
	homeland.showNotify = true;
	
	eventManager.dispatchEvent({ name = global_event.BLADEAWARD_HIDE });
	eventManager.dispatchEvent({ name = global_event.MAIN_UI_SHOW });
	eventManager.dispatchEvent({ name = global_event.TASK_SHOW, showType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_SIGN_IN });
	
	homeland.setCrystalVisible(true);
	
	if sceneManager.scene then
		sceneManager.scene:RevertLight();
		homeland.RevertBuildLight();
	end
		
	if self.actor then
		LORD.ActorManager:Instance():DestroyActor(self.actor);
		self.actor = nil;
	end

	local camera = LORD.SceneManager:Instance():getMainCamera();		
	camera:setPosition(self.originPos);
	camera:setDirection(self.originDir);
		
	self:destroy();
	
end

function displayFuli:destroy()
	
	self.cameraPos = LORD.Vector3(0,0,0);
	self.cameraDir = LORD.Vector3(0,0,0);
	
	self.actorName = "";
	self.skillName = "";
	
	self.actor = nil;
	
	self.playTime = 0;
	
	self.timer = nil;
		
end
