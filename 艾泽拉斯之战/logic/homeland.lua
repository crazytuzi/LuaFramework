homeland = {};

homeland.backupCameraPos  = LORD.Vector3(0,0,0);
homeland.backupCameraDir  = LORD.Vector3(0,0,0);
homeland.isCameraMoving = false;
homeland.isCameraCanTouchMove = true;

homeland.cameraMoveBuildType = "";
homeland.showNotify = true;

homeland.initCameraTarget = LORD.Vector3(6.3437,-3.6044,-20);
homeland.initCameraPos = LORD.Vector3(-65.7901,36.8274,35.0746);

-- 距离目标点最近的高度，和最远的高度
homeland.minCameraY = 26.67;
homeland.maxCameraY = 36.8274;
-- 最小的半径，x，z平面上的，用来做俯仰角变化的
homeland.minCameraRadius = 35;
-- 目标点的矩形区域范围, 相对于初始的target的偏移
homeland.cameraLeftOffset = -30;
homeland.cameraRightOffset = 50;
homeland.cameraTopOffset = 50;
homeland.cameraBottomOffset = -30;

-- 下面接个都是计算获得,变量
homeland.maxCameraRadius = 50;
homeland.disToTargetScale = 1;
homeland.cameraRadius = 1;

homeland.cameraOffset = LORD.Vector2(0,0);
homeland.cameraRealOffset = LORD.Vector2(0,0);
homeland.cameraTouchDownPos = LORD.Vector3(0,0,0);
homeland.cameraTouchDownTarget = LORD.Vector2(0,0);

homeland.cameraTarget	= LORD.Vector3(homeland.initCameraTarget.x, homeland.initCameraTarget.y, homeland.initCameraTarget.z);
homeland.cameraRotate = 0;

homeland.cameraDragTimer = -1;
homeland.cameraDragTimeStamp = 0;

homeland.cameraDragGoBackTimer = -1;
homeland.cameraDragGoBackTimeStamp = 0;

homeland.buildNotifyState = {};
homeland.buildNotifyUI = {};
homeland.buildNotifyUIIcon = {};

homeland.gotobase = false;
homeland.playBuildLevelupOK = nil;


-- 建筑升级特效
homeland.BUILD_LEVELUP_ATT = "jianzhushengji01";
homeland.BUILD_LEVELUP_OK_ATT = "jianzhushengji02";

-- 建筑的头上面板
homeland.buildPanels = {
	root = {},
	name = {},
	timer = {},
};

-- 建筑actor
homeland.buildActors = {
	actor = {}, 
	-- 点击播放动作的时间戳
	clickTimer = {},
	-- 休闲动作的时间戳
	idleTimer = {},
	-- win 时间戳
	winTimer = {},
	-- skill01 时间戳
	skill01Timer = {},
	-- skill02 时间戳
	skill02Timer = {},
	
	skillstate = {},
	
	-- 升级中的光效是否添加了
	levelupatt = {},
	
	-- 神像保护状态
	protectState = false,
	
	name = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = "jy_jinkuang.actor",
		[enum.HOMELAND_BUILD_TYPE.WOOD] = "jy_shujing.actor",
		[enum.HOMELAND_BUILD_TYPE.BASE] = "jy_zhucheng01.actor",
		[enum.HOMELAND_BUILD_TYPE.SHOP] = "jy_shangdian.actor",
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = "jy_fashita.actor",
		[enum.HOMELAND_BUILD_TYPE.ARENA] = "jy_jingjichang.actor",
		[enum.HOMELAND_BUILD_TYPE.SHIP] = "jy_bingying.actor",
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = "qijidiaoxiang.actor",
		[enum.HOMELAND_BUILD_TYPE.CARD] = "jy_zhongxindown.actor",
		[enum.HOMELAND_BUILD_TYPE.CARD2] = "jy_zhongxinup.actor",
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = "jy_feiting.actor",
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = "jy_gonghui.actor",
	},
	
	pos = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = LORD.Vector3(-18.4949, 0.159735, 13.2109),
		[enum.HOMELAND_BUILD_TYPE.WOOD] = LORD.Vector3(-35.5327, 2.82041, -33.4953),
		[enum.HOMELAND_BUILD_TYPE.BASE] = LORD.Vector3(-2.46149, 8.08924, -38.3214),
		[enum.HOMELAND_BUILD_TYPE.SHOP] = LORD.Vector3(-19.0944, 0.322833, 0.908924),
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = LORD.Vector3(12.9054, 6.69868, -28.6898),
		[enum.HOMELAND_BUILD_TYPE.ARENA] = LORD.Vector3(32.5435, -0.583147, 16.1501),
		[enum.HOMELAND_BUILD_TYPE.SHIP] = LORD.Vector3(18.8719, 1.40413, -7.6604),
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = LORD.Vector3(-19.7833, 6.70283, -29.3121),
		[enum.HOMELAND_BUILD_TYPE.CARD] = LORD.Vector3(-2.63272, 2.29857, -3.21088),
		[enum.HOMELAND_BUILD_TYPE.CARD2] = LORD.Vector3(-2.73589, 4.08265, -3.05465),
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = LORD.Vector3(-31.243, 2.34908, -8.58717),
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = LORD.Vector3(-2.52725, -0.920526, 22.0737),		
	},
	
	ori = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.WOOD] = LORD.Quaternion(0.987325, 0, -0.158713, 0),
		[enum.HOMELAND_BUILD_TYPE.BASE] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.SHOP] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.ARENA] = LORD.Quaternion(0.981511, -1.61394e-008, -0.191407, 2.39574e-008),
		[enum.HOMELAND_BUILD_TYPE.SHIP] = LORD.Quaternion(0.707107, -6.4742e-008, -0.707107, 2.27903e-008),
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.CARD] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.CARD2] = LORD.Quaternion(1, 0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = LORD.Quaternion(0.26428, 0, 0.978462, 0),
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = LORD.Quaternion(1, 0, 0, 0),		
	},	

	clickPlay = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = true,
		[enum.HOMELAND_BUILD_TYPE.WOOD] = true,
		[enum.HOMELAND_BUILD_TYPE.BASE] = false,
		[enum.HOMELAND_BUILD_TYPE.SHOP] = true,
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = true,
		[enum.HOMELAND_BUILD_TYPE.ARENA] = false,
		[enum.HOMELAND_BUILD_TYPE.SHIP] = false,
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = false,
		[enum.HOMELAND_BUILD_TYPE.CARD] = true,
		[enum.HOMELAND_BUILD_TYPE.CARD2] = true,
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = false,
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = false,
	},
	
	sound = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = "jinkuang.mp3",
		[enum.HOMELAND_BUILD_TYPE.WOOD] = "mucaichang.mp3",
		[enum.HOMELAND_BUILD_TYPE.BASE] = "zhucheng.mp3",
		[enum.HOMELAND_BUILD_TYPE.SHOP] = "shangdian.mp3",
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = "fashita.mp3",
		[enum.HOMELAND_BUILD_TYPE.ARENA] = "jingjichang.mp3",
		[enum.HOMELAND_BUILD_TYPE.SHIP] = "bingying.mp3",
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = "tiejiangpu.mp3",
		[enum.HOMELAND_BUILD_TYPE.CARD] = "zhaohuan.mp3",
		[enum.HOMELAND_BUILD_TYPE.CARD2] = "zhaohuan.mp3",
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = "maoxian.mp3",
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = "guowangshengji.mp3",
	},	
	
	idlePlay = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = false,
		[enum.HOMELAND_BUILD_TYPE.WOOD] = true,
		[enum.HOMELAND_BUILD_TYPE.BASE] = false,
		[enum.HOMELAND_BUILD_TYPE.SHOP] = false,
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = false,
		[enum.HOMELAND_BUILD_TYPE.ARENA] = false,
		[enum.HOMELAND_BUILD_TYPE.SHIP] = false,
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = false,
		[enum.HOMELAND_BUILD_TYPE.CARD] = false,
		[enum.HOMELAND_BUILD_TYPE.CARD2] = false,
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = false,
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = false,
	},
	
	box = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = LORD.Vector3(6, 8, 6),
		[enum.HOMELAND_BUILD_TYPE.WOOD] = LORD.Vector3(6, 15, 6),
		[enum.HOMELAND_BUILD_TYPE.BASE] = LORD.Vector3(10, 22, 10),
		[enum.HOMELAND_BUILD_TYPE.SHOP] = LORD.Vector3(6, 8, 6),
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = LORD.Vector3(9, 12, 9),
		[enum.HOMELAND_BUILD_TYPE.ARENA] = LORD.Vector3(22, 18, 22),
		[enum.HOMELAND_BUILD_TYPE.SHIP] = LORD.Vector3(8, 14, 8),
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = LORD.Vector3(6, 8, 6),
		[enum.HOMELAND_BUILD_TYPE.CARD] = LORD.Vector3(9, 8, 9),
		[enum.HOMELAND_BUILD_TYPE.CARD2] = LORD.Vector3(8, 5, 8),
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = LORD.Vector3(7, 8, 7),
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = LORD.Vector3(6, 10, 6),
	},
	
	shadow = {
		[enum.HOMELAND_BUILD_TYPE.GOLD] = LORD.Vector3(20, 20, 20),
		[enum.HOMELAND_BUILD_TYPE.WOOD] = LORD.Vector3(20, 20, 20),
		[enum.HOMELAND_BUILD_TYPE.BASE] = LORD.Vector3(20, 20, 20),
		[enum.HOMELAND_BUILD_TYPE.SHOP] = LORD.Vector3(20, 20, 20),
		[enum.HOMELAND_BUILD_TYPE.MAGIC] = LORD.Vector3(20, 20, 20),
		[enum.HOMELAND_BUILD_TYPE.ARENA] = LORD.Vector3(0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.SHIP] = LORD.Vector3(20, 20, 20),
		[enum.HOMELAND_BUILD_TYPE.EQUIP] = LORD.Vector3(0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.CARD] = LORD.Vector3(0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.CARD2] = LORD.Vector3(0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.INSTANCE] = LORD.Vector3(0, 0, 0),
		[enum.HOMELAND_BUILD_TYPE.GONGHUI] = LORD.Vector3(10, 10, 10),
	},	
			
};

-- panel计时器相关
homeland.INIT_SHOW_TIME = 10000; -- ms
homeland.CLICK_SHOW_TIME = 5000; -- ms
homeland.BUILD_IDLE_INTERVAL = 60; -- s

homeland.buildNotifyIcon = {
	[enum.HOMELAND_BUILD_TYPE.GOLD] = "set:maincontrol.xml image:gold";
	[enum.HOMELAND_BUILD_TYPE.WOOD] = "set:maincontrol.xml image:wood";
	[enum.HOMELAND_BUILD_TYPE.MAGIC] = "set:maincontrol.xml image:magictower";
	[enum.HOMELAND_BUILD_TYPE.INSTANCE] = "set:maincontrol.xml image:eventitem2";
	[enum.HOMELAND_BUILD_TYPE.CARD] = "set:maincontrol.xml image:eventitem";
	[enum.HOMELAND_BUILD_TYPE.SHOP] = "set:maincontrol.xml image:shop";
	[enum.HOMELAND_BUILD_TYPE.ARENA] = "set:maincontrol.xml image:eventitem";
	[enum.HOMELAND_BUILD_TYPE.GONGHUI] = "set:maincontrol.xml image:eventitem";
};

homeland.buildNotifyHeightOffset = {
	[enum.HOMELAND_BUILD_TYPE.GOLD] = 9;
	[enum.HOMELAND_BUILD_TYPE.WOOD] = 15;
	[enum.HOMELAND_BUILD_TYPE.BASE] = 16;
	[enum.HOMELAND_BUILD_TYPE.SHOP] = 8;
	[enum.HOMELAND_BUILD_TYPE.MAGIC] = 12;
	[enum.HOMELAND_BUILD_TYPE.ARENA] = 16;
	[enum.HOMELAND_BUILD_TYPE.SHIP] = 17;	
	[enum.HOMELAND_BUILD_TYPE.EQUIP] = 13;
	[enum.HOMELAND_BUILD_TYPE.CARD] = 8;
	[enum.HOMELAND_BUILD_TYPE.CARD2] = 8;
	[enum.HOMELAND_BUILD_TYPE.INSTANCE] = 8;
	[enum.HOMELAND_BUILD_TYPE.GONGHUI] = 12;
};

homeland.buildCameraPosition = {};
homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.WOOD] = {
	pos = LORD.Vector3(-38.3, 13, -13);
	dir = LORD.Vector3(-0.001, -0.16, -0.98);
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.SHIP] = {
	pos = LORD.Vector3(1.92, 7.1, 6.4);
	dir = LORD.Vector3(0.78, 0.05, -0.46);
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.GOLD] = {
	pos = LORD.Vector3(-30.77,7.05, 20);
	dir = LORD.Vector3(0.76, -0.21, -0.61);
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.ARENA] = {
	pos = LORD.Vector3(3.1, 18, 12.5);
	dir = LORD.Vector3(0.9, -0.38, 0.12);
	cameraMoveTime = 0.8;
};

local cardCameraPos = LORD.Vector3(-16.3, 13.57, 7.9);
local cardCameraDir = LORD.Vector3(homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x, homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].y + 2.5, homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z) - cardCameraPos;
cardCameraDir:normalize();

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD] = {
	pos = cardCameraPos;
	dir = cardCameraDir;
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.SHOP] = {
	pos = LORD.Vector3(-31, 7.34, 16);
	dir = LORD.Vector3(0.294, -0.22, -0.93);
	cameraMoveTime = 1.2;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.INSTANCE] = {
	pos = LORD.Vector3(-41,9.7,2.7);
	dir = LORD.Vector3(0.64, -0.23, -0.7);
	cameraMoveTime =0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.BASE] = {
	pos = LORD.Vector3(-5.28, 18.7, -3.27);
	dir = LORD.Vector3(-0.13, 0, -1);
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.MAGIC] = {
	pos = LORD.Vector3(1.65, 16.8, -13.4);
	dir = LORD.Vector3(0.52, -0.21,-0.83);
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.EQUIP] = {
	pos = LORD.Vector3(-14.75, 16.07, -2.32);
	dir = LORD.Vector3(-0.406, -0.1, -0.9);
	cameraMoveTime = 0.8;
};

homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.GONGHUI] = {
	pos = LORD.Vector3(-2.47, 4.13, 40);
	dir = LORD.Vector3(-0.162, 0, -1);
	cameraMoveTime = 0.8;
};

-- 进入建筑时的摄像机动画
function homeland.onEnterCameraStart(buildType)
		
	if homeland.isCameraMoving then
		return;
	end
	
	if homeland.buildCameraPosition[buildType] == nil then
		-- 没有摄像机动画，直接做相应的操作
		return;
	end
	
	local sound = homeland.buildActors.sound[buildType];
	LORD.SoundSystem:Instance():playEffect(sound);
	
	for k,v in pairs(homeland.unitList) do
			v:setActorHide(true);
	end
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE, })		
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	
	local camera = LORD.SceneManager:Instance():getMainCamera();
	local position = camera:getPosition();
	local dir = camera:GetDirection();
	homeland.backupCameraPos.x = position.x;
	homeland.backupCameraPos.y = position.y;
	homeland.backupCameraPos.z = position.z;

	homeland.backupCameraDir.x = dir.x;
	homeland.backupCameraDir.y = dir.y;
	homeland.backupCameraDir.z = dir.z;
	
	homeland.timeStamp = 0;
	homeland.moveHandle = scheduler.scheduleGlobal(homelandCameraMove, 0);
	
	homeland.cameraMoveBuildType = buildType;
	--print("buildType "..buildType);
	eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
	homeland.showNotify = false;
	
	homeland.isCameraCanTouchMove = false;
	
	homeland.handleBuildClickEffect(homeland.cameraMoveBuildType);
end

function homeland.recoverCamera(buildType)
	--local camera = LORD.SceneManager:Instance():getMainCamera();
	--camera:setPosition(homeland.backupCameraPos);
	--camera:setDirection(homeland.backupCameraDir);
	
	--eventManager.dispatchEvent({name = global_event.MAIN_UI_SHOW});
	if homeland.moveHandle > 0 then
		return;
	end
	
	--print("homeland.cameraMoveBuildType "..homeland.cameraMoveBuildType)
	if homeland.buildCameraPosition[homeland.cameraMoveBuildType] == nil then
		-- 没有摄像机动画，直接做相应的操作
		return;
	end
	eventManager.dispatchEvent({name = global_event.MODALTIP_HIDE, })	
	eventManager.dispatchEvent({name = global_event.GUIDEDIALOGUE_HIDE, })
	
	for k,v in pairs(homeland.unitList) do
			v:setActorHide(false);
			v:setState(homelandUnitStateMove);
	end
	
	homeland.handleBuildRecoverClickEffect(buildType);
		
	homeland.timeStamp = 0;
	homeland.moveHandle = scheduler.scheduleGlobal(homelandCameraRecoverMove, 0);

	--homeland.cameraMoveBuildType = buildType;
end

homeland.timeStamp = 0;
homeland.moveHandle = -1;

function homelandCameraMove(dt)
	
	local cameraData = homeland.buildCameraPosition[homeland.cameraMoveBuildType];
	if not cameraData then
		return;
	end
	
	homeland.isCameraMoving = true;
		
	local camera = LORD.SceneManager:Instance():getMainCamera();
	
	if homeland.timeStamp > cameraData.cameraMoveTime then		
		camera:setPosition(cameraData.pos);
		camera:setDirection(cameraData.dir);
		homeland.timeStamp = 0;
		
		--dump(cameraData);
		
		scheduler.unscheduleGlobal(homeland.moveHandle);
		
		if homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.WOOD then
			eventManager.dispatchEvent({name = global_event.WOOD_SHOW});
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.SHIP then
			--eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_SHOW, ship = 1});
			eventManager.dispatchEvent({name = global_event.ACTIVITY_SHOW});
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.BASE then
			eventManager.dispatchEvent({name = global_event.BASE_SHOW});
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.GOLD then
			eventManager.dispatchEvent({name = global_event.GOLDMINE_SHOW});
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.SHOP then
			global.openShop();
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.MAGIC then
			eventManager.dispatchEvent({name = global_event.SKILLTOWER_SHOW});
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.ARENA then
			local layout = layoutManager.getUI("pvp")
			if(false == layout:isShow())then
				eventManager.dispatchEvent({name = global_event.ARENA_SHOW});
			end
			
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.EQUIP then
			
			eventManager.dispatchEvent({name = global_event.MIRACLE_SHOW});
			
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.CARD then
			eventManager.dispatchEvent({name = global_event.CARD_SHOW});
		elseif homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.INSTANCE then
		   local zones = dataManager.instanceZonesData;
		   local stage = zones:getNewInstance(enum.Adventure_TYPE.NORMAL);
		   --eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, stage = stage, notips = true});
		   --判断是否需要特殊引导
		    local processSP = dataManager.playerData:getAdventureNormalProcess()
  			local stageSP =  dataManager.instanceZonesData:getStageWithAdventureID( processSP,enum.Adventure_TYPE.NORMAL )
				local starSP = stageSP:getVisStarNum()
		   	local _showStageInfo = true
		   	local GUIDE_PROCESS_LIMIT = 15
		   	if processSP <=GUIDE_PROCESS_LIMIT and starSP == 2 and processSP%2 == 0 then
		   		_showStageInfo = false
		   	end
		   	--
		   eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW,toNewStage = true,curSelStafeMode = enum.Adventure_TYPE.NORMAL, showStageInfo = _showStageInfo});
		elseif 	homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.GONGHUI then
			
			eventManager.dispatchEvent({name = global_event.IDOLSTATUS_SHOW});
		end
		
		--homeland.handleBuildClickEffect(homeland.cameraMoveBuildType);
				
		-- 清理数据
		homeland.isCameraMoving = false;
		--homeland.cameraMoveBuildType = "";
		homeland.moveHandle = -1;
		
	else
	
		local percent = homeland.timeStamp / cameraData.cameraMoveTime;
		--print(percent)
		local position = homeland.backupCameraPos + (cameraData.pos - homeland.backupCameraPos) * percent;
		local dir = homeland.backupCameraDir + (cameraData.dir - homeland.backupCameraDir) * percent;

		camera:setPosition(position);
		camera:setDirection(dir);
						
		homeland.timeStamp = homeland.timeStamp + dt;
	end
end

function homelandCameraRecoverMove(dt)
	
	local cameraData = homeland.buildCameraPosition[homeland.cameraMoveBuildType];
	if not cameraData then
		scheduler.unscheduleGlobal(homeland.moveHandle);
		homeland.moveHandle = -1;
		return;
	end
	
	--print("homelandCameraRecoverMove ");
	
	homeland.isCameraMoving = true;
	
	local camera = LORD.SceneManager:Instance():getMainCamera();
	
	if homeland.timeStamp > cameraData.cameraMoveTime then		
		camera:setPosition(homeland.backupCameraPos);
		camera:setDirection(homeland.backupCameraDir);
		homeland.timeStamp = 0;
		
		scheduler.unscheduleGlobal(homeland.moveHandle);
		
		eventManager.dispatchEvent({name = global_event.MAIN_UI_SHOW});
		
		--if homeland.cameraMoveBuildType == enum.HOMELAND_BUILD_TYPE.SHIP then
		--	homeland.onCheckUnitChange();
		--end
		
		homeland.showNotify = true;
		-- 清理数据
		homeland.isCameraMoving = false;
		homeland.cameraMoveBuildType = "";
		homeland.moveHandle = -1;
		
		homeland.isCameraCanTouchMove = true;
		
		-- 重新初始化计时器
		homeland.buildPanelTimer = homeland.INIT_SHOW_TIME;
		homeland.buildPanelHideFlag = false;
		
		for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
			uiaction.fadeIn(homeland.buildPanels.root[v], 200);
		end
		
		if homeland.gotobase == true then
			homeland.gotobase = false;
			homeland.baseHandle();
			
		end
		
	else
	
		local percent = homeland.timeStamp / cameraData.cameraMoveTime;
		--print(percent)
		local position = cameraData.pos + (homeland.backupCameraPos - cameraData.pos) * percent;
		local dir = cameraData.dir + (homeland.backupCameraDir - cameraData.dir) * percent;

		camera:setPosition(position);
		camera:setDirection(dir);
						
		homeland.timeStamp = homeland.timeStamp + dt;
	end
end

function homeland.instanceHandle()

	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.INSTANCE);	
	
	--[[
	if( 1 )then
	   local zones = dataManager.instanceZonesData;
	   local stage = zones:getNewInstance(enum.Adventure_TYPE.NORMAL);
	   --eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW, stage = stage, notips = true});
	   eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_SHOW,toNewStage = true});
 
	end
	--]]
	
end

function homeland.goldHandle()
	--eventManager.dispatchEvent({name = global_event.GOLDMINE_SHOW});
	--eventManager.dispatchEvent({name = global_event.MAIN_UI_CLOSE});
	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].goldMineLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].goldMineLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.GOLD] });
		return 		
	end
	
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.GOLD);
end

function homeland.woodHandle()

	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].lumberMillLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].lumberMillLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.WOOD] });
		return 		
	end
		
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.WOOD);
	--camera:setPosition(LORD.Vector3(-37.98, 7.35, 40.79));
	--camera:setDirection(LORD.Vector3(0.51, 0, -0.86));
	
	--eventManager.dispatchEvent({name = global_event.WOOD_SHOW});
end

function homeland.baseHandle()
	--eventManager.dispatchEvent({name = global_event.BASE_SHOW});
	
	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].mainBaseLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].mainBaseLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.BASE] });
		return 		
	end
		
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.BASE);
end

function homeland.shopHandle()
	--global.openShop()	
	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].shopLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].shopLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.SHOP] });
		return 		
	end
	
	
	dataManager.shopData:clickNotify();
	
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.SHOP);
	
end

function homeland.magicTowerHandle()

	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].magicTowerLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].magicTowerLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.MAGIC] });
		return 		
	end
	
	--eventManager.dispatchEvent({name = global_event.SKILLTOWER_SHOW});
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.MAGIC);
end


function homeland.arenaHandle()
	--eventManager.dispatchEvent({name = global_event.ARENA_SHOW});
	
	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].pvpLevelLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].pvpLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.ARENA] });
		return 		
	end
		
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.ARENA);
end

function homeland.shipHandle()
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.SHIP);	
end

function homeland.equipHandle()

	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].miracleLevelLimit)then
	
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].miracleLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.EQUIP] });
		
		return
	end
			
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.EQUIP);
end

function homeland.corpsHandle()

	local level = dataManager.playerData:getAdventureNormalProcess()
	
	if(level < dataConfig.configs.ConfigConfig[0].drawCardProcessLimit)then
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					--textInfo = dataConfig.configs.ConfigConfig[0].drawCardProcessLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.CARD] });
					textInfo = "通关1-1开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.CARD] });
		return 		
	end
	
	--eventManager.dispatchEvent({name = global_event.CARD_SHOW});
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.CARD);
end

function homeland.shenXiangHandle()

	local level = dataManager.playerData:getLevel()
	
	if(level < dataConfig.configs.ConfigConfig[0].idolLevelLimit)then
	
		eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
					messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
					textInfo = dataConfig.configs.ConfigConfig[0].idolLevelLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.GONGHUI] });
		
		return
	end
	
	--print("shenXiangHandle");	
	homeland.onEnterCameraStart(enum.HOMELAND_BUILD_TYPE.GONGHUI);
	
end

homeland.buildingClickHandle = {
	[enum.HOMELAND_BUILD_TYPE.INSTANCE] = homeland.instanceHandle;
	[enum.HOMELAND_BUILD_TYPE.GOLD] = homeland.goldHandle;
	[enum.HOMELAND_BUILD_TYPE.WOOD] = homeland.woodHandle;
	[enum.HOMELAND_BUILD_TYPE.BASE] = homeland.baseHandle;
	[enum.HOMELAND_BUILD_TYPE.SHOP] = homeland.shopHandle;
	[enum.HOMELAND_BUILD_TYPE.MAGIC] = homeland.magicTowerHandle;
	[enum.HOMELAND_BUILD_TYPE.ARENA] = homeland.arenaHandle;
	[enum.HOMELAND_BUILD_TYPE.SHIP] = homeland.shipHandle;
	[enum.HOMELAND_BUILD_TYPE.EQUIP] = homeland.equipHandle;
	[enum.HOMELAND_BUILD_TYPE.CARD] = homeland.corpsHandle;
	[enum.HOMELAND_BUILD_TYPE.CARD2] = homeland.corpsHandle;
	[enum.HOMELAND_BUILD_TYPE.GONGHUI] = homeland.shenXiangHandle;
};

function homeland.sceneInit()
	sceneManager.loadScene("jiayuanxinban");
	
	-- 进入家园摄像机动画检测
	if LORD.SceneManager:Instance():isPlayingCameraAnimate() then
		LORD.SceneManager:Instance():stopCameraAnimations();
	end
		
	local camera = LORD.SceneManager:Instance():getMainCamera();
	camera:setPosition(homeland.initCameraPos);
	camera:setTarget(homeland.initCameraTarget);
	homeland.cameraTarget	= LORD.Vector3(homeland.initCameraTarget.x, homeland.initCameraTarget.y, homeland.initCameraTarget.z);

	homeland.cameraOffset = LORD.Vector2(0,0);
	homeland.cameraRealOffset = LORD.Vector2(0,0);


	homeland.buildActors.protectState = false;
	homeland.buildActors.miracleFlag = false;
	
	-- 取消摄像机震动
	LORD.SceneManager:Instance():enableCameraShake(false);
		
	-- 初始化当前的缩放	
	local vector = homeland.initCameraPos - homeland.initCameraTarget;
	
	-- 初始化旋转和缩放
	-- x, z 相对于tareget的半径
	homeland.cameraRadius = math.sqrt(vector.x * vector.x + vector.z * vector.z);
	
	local theta = math.asin( math.abs(vector.z) / homeland.cameraRadius);
	if vector.x <= 0 and vector.z > 0 then
		homeland.cameraRotate = math.pi - theta;
	elseif vector.x <= 0 and vector.z <= 0 then
		homeland.cameraRotate = math.pi + theta;
	elseif vector.x > 0 and vector.z <= 0 then
		homeland.cameraRotate = 2 * math.pi - theta;
	else
		homeland.cameraRotate = theta;
	end
	
	-- 斜率
	homeland.tanY = homeland.initCameraTarget.y / homeland.cameraRadius;
	
	-- 缩放
	homeland.disToTargetScale = (homeland.initCameraPos.y - homeland.minCameraY) / (homeland.maxCameraY - homeland.minCameraY);
	homeland.maxCameraRadius = homeland.minCameraRadius + (homeland.cameraRadius-homeland.minCameraRadius)/ homeland.disToTargetScale;
	
	homeland.buildNotifyUI = {};
	homeland.buildNotifyUIIcon = {};
	homeland.buildNotifyState = {};
	homeland.showNotify = true;
	
	homeland.isCameraCanTouchMove = true;
		
	-- 初始化通知的ui	
	for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
		
		homeland.buildNotifyUI[v] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("homelandNotify_"..v, "bubble.dlg");
		engine.uiRoot:AddChildWindow(homeland.buildNotifyUI[v]);
		homeland.buildNotifyUIIcon[v] = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("homelandNotify_"..v.."_bubble-bubble"));
		
		homeland.buildNotifyState[v] = false;
	end
	
	-- 建筑的ui面板
	homeland.buildPanels = {
		root = {},
		name = {},
		timer = {},
	};
	
	homeland.buildActors.actor = {};
	homeland.buildActors.clickTimer = {};
	homeland.buildActors.winTimer = {};
	homeland.buildActors.skill01Timer = {};
	homeland.buildActors.skill02Timer = {};
	
	homeland.buildActors.idleTimer = {};
	homeland.buildActors.skillstate = {};
	
	for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
		homeland.buildPanels.root[v] = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("homelandBuildPanel-"..v, "buildPanel.dlg");
		homeland.buildPanels.name[v] = LORD.GUIWindowManager:Instance():GetGUIWindow("homelandBuildPanel-"..v.."_buildPanel-name");
		homeland.buildPanels.timer[v] = LORD.GUIWindowManager:Instance():GetGUIWindow("homelandBuildPanel-"..v.."_buildPanel-timer");
		
		engine.uiRoot:AddChildWindow(homeland.buildPanels.root[v]);
		
		homeland.buildPanels.name[v]:SetText(enum.HOMELAND_BUILD_NAME[v]);
		homeland.buildPanels.timer[v]:SetText("");
		
		-- actor init
		if homeland.buildActors.name[v] and homeland.buildActors.pos[v] and homeland.buildActors.ori[v] then
			homeland.buildActors.actor[v] = LORD.ActorManager:Instance():CreateActor(homeland.buildActors.name[v], "idle", false);
			homeland.buildActors.actor[v]:SetPosition(homeland.buildActors.pos[v]);
			homeland.buildActors.actor[v]:SetOrientation(homeland.buildActors.ori[v]);
			homeland.buildActors.actor[v]:SetUserData(v);
			
			homeland.buildActors.actor[v]:SetShadowVisible(false);
			--homeland.buildActors.actor[v]:AddPluginEffect("shadow", "", "shadow.effect", 1, 1, -1, LORD.Vector3(0, 0, 0), LORD.Quaternion(LORD.Vector3(0,1,0), 0), homeland.buildActors.shadow[v]);
			
			--print("init actor k "..k.." v "..v.." name "..homeland.buildActors.name[v])
		end
		
		homeland.buildActors.clickTimer[v] = 0;
		homeland.buildActors.winTimer[v] = 0;
		homeland.buildActors.skill01Timer[v] = 0;
		homeland.buildActors.skill02Timer[v] = 0;
		homeland.buildActors.idleTimer[v] = homeland.BUILD_IDLE_INTERVAL; -- s
		homeland.buildActors.skillstate[v] = "idle";
		homeland.buildActors.levelupatt[v] = "";
		
	end
	
	-- 进入场景10秒钟,隐藏
	homeland.buildPanelTimer = homeland.INIT_SHOW_TIME;
	homeland.buildPanelHideFlag = false;
	
	homeland.sceneInitOK = true;
	
	homeland.initUnit();
	homeland.unitPlayWin = false;
	
end

function homeland.createUnit(shipIndex, cardType)
	
	if cardType > 0 then
		local cardInstance = cardData.getCardInstance(cardType);
		local unitConfig = cardInstance:getConfig();
		
		local unitActor = homelandUnit.new(unitConfig.resourceName, homeland.unitScale);
		unitActor:init(shipIndex, unitConfig);
		unitActor:setCenterPosition(homeland.unitPosition[shipIndex]);
		unitActor:setMoveRadius(homeland.unitMoveRadius[shipIndex]);
		unitActor:SetPosition(homeland.unitPosition[shipIndex]);
		unitActor:setState(homelandUnitStateWin);
		homeland.unitList[shipIndex] = unitActor;
	end
end

function homeland.onCheckUnitChange()

	if(game.state ~= game.GAME_STATE_MAIN)then
		return;
	end
	
	for k,v in ipairs(shipData.shiplist) do
	
		local cardType = PLAN_CONFIG.getShipCardType(k);
		if cardType > 0 then
			if homeland.unitList[k] == nil then
				homeland.createUnit(k, cardType);
			else
				local cardInstance = cardData.getCardInstance(cardType);
				local unitConfig = cardInstance:getConfig();
				if homeland.unitList[k]:getActorName() ~= unitConfig.resourceName then
					homeland.unitList[k]:destroy();
					homeland.createUnit(k, cardType);
				end
			end
		end
	end
		
end

homeland.unitPosition = {
	[1] = LORD.Vector3(-10.32, 6.82, -27.85);
	[2] = LORD.Vector3(2.46,7,-27.85);
	[3] = LORD.Vector3(-2.75,3.84,-14.11);
	[4] = LORD.Vector3(-17.27,1.66,-12.29);
	[5] = LORD.Vector3(-29.32,-0.48,1.46);
	[6] = LORD.Vector3(-1.82,0.66,18.71);
};

homeland.unitMoveRadius = {
	[1] = 3;
	[2] = 3;
	[3] = 2;
	[4] = 2.5;
	[5] = 2;
	[6] = 2.5;
};

homeland.unitScale = LORD.Vector3(4, 4, 4);

function homeland.initUnit()
		
	homeland.unitList = {};
	
	for k,v in ipairs(shipData.shiplist) do
		local cardType = PLAN_CONFIG.getShipCardType(k);
		
		if cardType > 0 then
			homeland.createUnit(k, cardType);
		end
	end
	
end

function homeland.destroyUnit()
	
	for k,v in pairs(homeland.unitList) do
		v:destroy();
	end
	
	homeland.unitList = {};
end

function homeland.sceneDestroy()
	
	LORD.SceneManager:Instance():enableCameraShake(true);
	
	homeland.destroyUnit();
	
	homeland.sceneInitOK = false;
	
	for k,v in pairs(homeland.buildNotifyUI) do
		LORD.GUIWindowManager:Instance():DestroyGUIWindow(v);
	end
	
	for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
		if homeland.buildPanels.root[v] then
			LORD.GUIWindowManager:Instance():DestroyGUIWindow(homeland.buildPanels.root[v]);
		end
	
		if homeland.buildActors.actor[v] then
			LORD.ActorManager:Instance():DestroyActor(homeland.buildActors.actor[v]);
		end
		
	end
	
	homeland.buildActors.actor = {};
	
	homeland.buildPanels = {
		root = {},
		name = {},
		timer = {},
	};
		
	homeland.buildNotifyUI = {};
	homeland.buildNotifyUIIcon = {};
	homeland.buildNotifyState = {};
	homeland.showNotify = true;
	homeland.cameraMoveBuildType = "";
	sceneManager.closeScene();
	
	-- 关闭一些界面
	eventManager.dispatchEvent({name = global_event.SHIPREMOULD_HIDE, });
	eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_CLOSE, });
	eventManager.dispatchEvent({name = global_event.CHATROOM_HIDE, });
	
end

homeland.dragging = false;
homeland.totalChangePos = LORD.Vector2(0, 0);

-- 拖拽结束的摄像机的处理
function homeland.dragEndCameraFun(dt)
	
	local wholeTime = 0.2;
	-- move
	if homeland.cameraDragTimeStamp > wholeTime then
		homeland.cameraDragTimeStamp = 0;
		
		if homeland.cameraDragTimer >= 0 then
			scheduler.unscheduleGlobal(homeland.cameraDragTimer);
			homeland.cameraDragTimer = -1;
		end
		
		if homeland.dampOffset.x ~= 0 or
			homeland.dampOffset.y ~= 0 then
			
			homeland.cameraDragGoBackTimeStamp = 0;
			homeland.cameraDragGoBackTimer = scheduler.scheduleGlobal(homeland.goBackCameraFun, 0);
		end
						
	else
		
		local changePos = homeland.moveSpeed * dt * 1000 * 0.1;
		homeland.dragCamera(changePos);
		
		homeland.moveSpeed = homeland.moveSpeed * 0.9;
		
		homeland.cameraDragTimeStamp = homeland.cameraDragTimeStamp + dt;
	end

end

function homeland.dragCamera(changePos, goback)
	local camera = LORD.SceneManager:Instance():getMainCamera();
	local position = camera:getPosition();
	local right = camera:GetRight();
	local up = camera:GetUp();
	local front = up:cross(right);
	local dampRate = 0.2;
			
	-- change pos
	if goback then
		
		homeland.cameraOffset = homeland.cameraOffset + changePos;
	else
		local cameraOffset = LORD.Vector2(-0.1*changePos.x, 0.1*changePos.y); 
		homeland.cameraOffset = homeland.cameraOffset + cameraOffset;
	end
		
	if homeland.cameraOffset.x < homeland.cameraLeftOffset or
		homeland.cameraOffset.x > homeland.cameraRightOffset then

		if homeland.cameraOffset.x < homeland.cameraLeftOffset then			
			local offset = (homeland.cameraOffset.x - homeland.cameraLeftOffset) * dampRate;
			homeland.cameraRealOffset.x = homeland.cameraLeftOffset + offset;
			
		elseif homeland.cameraOffset.x > homeland.cameraRightOffset then
			local offset = (homeland.cameraOffset.x - homeland.cameraRightOffset) * dampRate;
			homeland.cameraRealOffset.x = homeland.cameraRightOffset + offset;		
		end
					
	else
		homeland.cameraRealOffset.x = homeland.cameraOffset.x;
	end
	
	if homeland.cameraOffset.y > homeland.cameraTopOffset or
			homeland.cameraOffset.y < homeland.cameraBottomOffset then
		
		if homeland.cameraOffset.y > homeland.cameraTopOffset then
			local offset = (homeland.cameraOffset.y - homeland.cameraTopOffset) * dampRate;
			homeland.cameraRealOffset.y = homeland.cameraTopOffset + offset;
				
		elseif homeland.cameraOffset.y < homeland.cameraBottomOffset then
			local offset = (homeland.cameraOffset.y - homeland.cameraBottomOffset) * dampRate;
			homeland.cameraRealOffset.y = homeland.cameraBottomOffset + offset;	
		end
		
	else
		homeland.cameraRealOffset.y = homeland.cameraOffset.y;
	end

	-- 新的target target 做相应的偏移
	local newTarget = homeland.initCameraTarget + right * homeland.cameraRealOffset.x;
	newTarget = newTarget + front * homeland.cameraRealOffset.y;
	homeland.cameraTarget = newTarget;
	
	local targetOffset = homeland.cameraTarget - homeland.cameraTouchDownTarget;
	local newPosition = homeland.cameraTouchDownPos + targetOffset;
	camera:setPosition(newPosition);
	camera:setTarget(newTarget);
	
	-- 记录超出的部分
	if not goback then
		
		if homeland.cameraOffset.x < homeland.cameraLeftOffset then			
			homeland.dampOffset.x = (homeland.cameraOffset.x - homeland.cameraLeftOffset);
		elseif homeland.cameraOffset.x > homeland.cameraRightOffset then
			homeland.dampOffset.x = (homeland.cameraOffset.x - homeland.cameraRightOffset);
		else
			homeland.dampOffset.x = 0;
		end

		if homeland.cameraOffset.y > homeland.cameraTopOffset then
			homeland.dampOffset.y = (homeland.cameraOffset.y - homeland.cameraTopOffset);
		elseif homeland.cameraOffset.y < homeland.cameraBottomOffset then
			homeland.dampOffset.y = (homeland.cameraOffset.y - homeland.cameraBottomOffset);
			
		else
			homeland.dampOffset.y = 0;
		end
				
	end

end

-- camera goback 的处理
function homeland.goBackCameraFun(dt)
	
	local wholeTime = 0.2;
	if homeland.cameraDragGoBackTimeStamp > wholeTime then

		if homeland.cameraDragGoBackTimer >= 0 then
			scheduler.unscheduleGlobal(homeland.cameraDragGoBackTimer);
			homeland.cameraDragGoBackTimer = -1;
		end
		
	else
		
		homeland.cameraDragGoBackTimeStamp = homeland.cameraDragGoBackTimeStamp + dt;
		
		local changePos = homeland.dampOffset * -dt / wholeTime;
		homeland.dragCamera(changePos, true);

	end
	
end


homeland.selectObj = nil;

function homeland.resetBuildPanelTimer()
	if homeland.buildPanelTimer < homeland.CLICK_SHOW_TIME then
		homeland.buildPanelTimer = homeland.CLICK_SHOW_TIME;
		homeland.buildPanelHideFlag = false;

		for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
			uiaction.fadeIn(homeland.buildPanels.root[v], 200);
		end

	end	
end

function homeland.touchHandle(touchType, touchPosition, touch)

		
	if homeland.cameraDragGoBackTimer > 0 then
		return;
	end
	
	if not homeland.isCameraCanTouchMove then
		return;
	end
	
	if homeland.multiTouchMove == true then
		return;
	end
	
	local position = LORD.SceneManager:Instance():getMainCamera():getPosition();
	--print("homeland.touchHandle(touchType, touchPosition) position x"..position.x.." position.z "..position.z.."");
		
	if("TouchUp" == touchType )then
	
		if sceneManager.scene and not homeland.dragging then
			local camera = LORD.SceneManager:Instance():getMainCamera();
			--local gameObject = LORD.ActorManager:Instance():RayPickActor(touchPosition.x, touchPosition.y);
			local gameObject = homeland.RayPickActor(touchPosition);
			
			if gameObject then
				local buildType = gameObject:getUserData();
				
				if homeland.selectObj == buildType and homeland.buildingClickHandle[buildType] then
					
					--homeland.handleBuildClickEffect(buildType);
					
					homeland.buildingClickHandle[buildType]();
					
					homeland.selectObj  = nil;
				end
			else
				-- 点击任意非功能区域
				
				homeland.resetBuildPanelTimer();
			end
		end
		
		if homeland.dragging then

			if homeland.cameraDragTimer >= 0 then
				scheduler.unscheduleGlobal(homeland.cameraDragTimer);
				homeland.cameraDragTimer = -1;
			end
						
			local elapsTime = LORD.Root:Instance():getCurrentTime() - homeland.touchdownTime;
			
			if elapsTime == 0 then
				elapsTime = 100;
			end
			
			homeland.moveSpeed = homeland.totalChangePos / elapsTime;
			--print("homeland.totalChangePos "..homeland.totalChangePos.x.." "..homeland.totalChangePos.y.." s "..homeland.moveSpeed.x.." "..homeland.moveSpeed.y.." "..elapsTime)
			if elapsTime > 500 then
				
				if homeland.dampOffset.x ~= 0 or
					homeland.dampOffset.y ~= 0 then
					
					homeland.cameraDragGoBackTimeStamp = 0;
					homeland.cameraDragGoBackTimer = scheduler.scheduleGlobal(homeland.goBackCameraFun, 0);
				end
				
			else
			
				if homeland.dampOffset.x ~= 0 or
					homeland.dampOffset.y ~= 0 then
					
					homeland.cameraDragGoBackTimeStamp = 0;
					homeland.cameraDragGoBackTimer = scheduler.scheduleGlobal(homeland.goBackCameraFun, 0);
				else
					homeland.cameraDragTimeStamp = 0;
					homeland.cameraDragTimer = scheduler.scheduleGlobal(homeland.dragEndCameraFun, 0);
				end					
			end
									
			homeland.dragging = false;
			
			-- 执行推拽的操作
			homeland.resetBuildPanelTimer();
		end
		
	elseif "TouchDown" == touchType then
		-- drag
		local camera = LORD.SceneManager:Instance():getMainCamera();
		--local gameObject = LORD.ActorManager:Instance():RayPickActor(touchPosition.x, touchPosition.y);
		local gameObject = homeland.RayPickActor(touchPosition);
		if gameObject then
			local buildType = gameObject:getUserData();
			homeland.selectObj = buildType;
		end
				
		if homeland.cameraDragTimer >= 0 then
			scheduler.unscheduleGlobal(homeland.cameraDragTimer);
			homeland.cameraDragTimer = -1;
		end
		
		homeland.moveSpeed = LORD.Vector2(0, 0);			
		homeland.touchdownTime = LORD.Root:Instance():getCurrentTime();
		homeland.totalChangePos = LORD.Vector2(0, 0);
		homeland.dampOffset = LORD.Vector2(0, 0);

		homeland.cameraTouchDownPos = camera:getPosition();
		homeland.cameraTouchDownTarget = LORD.Vector3(homeland.cameraTarget.x, homeland.cameraTarget.y, homeland.cameraTarget.z);
				
	elseif "TouchMove" == touchType then
	
	do
		return 
	
	end
		local touchPoint1 = touch:getTouchPoint();
		local prePoint1 = touch:getPrevPoint();

		-- 执行推拽的操作
		homeland.resetBuildPanelTimer();
		
		homeland.dragging = true;
		local changePos = touchPoint1 - prePoint1;
		
		-- 拖拽摄像机
		homeland.dragCamera(changePos);
		homeland.totalChangePos = homeland.totalChangePos + changePos;
		
	end
end

-- multi touch handle
function homeland.multiTouchHandle(touchType, touch1, touch2)
	do
		return 
	
	end
			
	if homeland.cameraDragGoBackTimer > 0 then
		return;
	end
		
	if not homeland.isCameraCanTouchMove then
		return;
	end
			
	local touchPoint1 = touch1:getTouchPoint();
	local touchPoint2 = touch2:getTouchPoint();
	
	local prePoint1 = touch1:getPrevPoint();
	local prePoint2 = touch2:getPrevPoint();
	
	--print("touchType "..touchType);
	--print("touchPoint1 x"..touchPoint1.x);
	--print("touchPoint1 y"..touchPoint1.y);

	--print("touchPoint2 x"..touchPoint2.x);
	--print("touchPoint2 y"..touchPoint2.y);
	
	if touchType == "TouchDown" then
		
	elseif touchType == "TouchUp" then
		homeland.multiTouchMove = false;
	elseif touchType == "TouchCancel" then
		homeland.multiTouchMove = false;
		
	elseif touchType == "TouchUpOne" or
					touchType == "TouchCancelOne" then
		
		homeland.multiTouchMove = false;					
		local camera = LORD.SceneManager:Instance():getMainCamera();
		homeland.moveSpeed = LORD.Vector2(0, 0);			
		homeland.touchdownTime = LORD.Root:Instance():getCurrentTime();
		homeland.totalChangePos = LORD.Vector2(0, 0);
		homeland.dampOffset = LORD.Vector2(0, 0);

		homeland.cameraTouchDownPos = camera:getPosition();
		homeland.cameraTouchDownTarget = LORD.Vector3(homeland.cameraTarget.x, homeland.cameraTarget.y, homeland.cameraTarget.z);
				
	elseif touchType == "TouchMove" then
		

			homeland.resetBuildPanelTimer();
			
			local camera = LORD.SceneManager:Instance():getMainCamera();
		
			-- 距离change
			local vector = touchPoint2 - touchPoint1;
			local preVector = prePoint2 - prePoint1;
			
			local dis = vector:len();
			local preDis = preVector:len();
			local change = dis - preDis;
			
			-- 角度change
			local cosTheta = preVector:cross(vector) / (dis * preDis);
			local angleChange = math.asin(cosTheta);
			
			-- 去掉旋转
			--homeland.cameraRotate = homeland.cameraRotate + angleChange;
			
			homeland.disToTargetScale = homeland.disToTargetScale - change * 0.001;
			
			if homeland.disToTargetScale < 0 then
				homeland.disToTargetScale = 0;
			end
			
			if homeland.disToTargetScale > 1 then
				homeland.disToTargetScale = 1;
			end
			
			local radius = homeland.minCameraRadius + homeland.disToTargetScale * (homeland.maxCameraRadius - homeland.minCameraRadius);
			
			-- 计算高度
			
			local y = homeland.minCameraY + homeland.disToTargetScale * (homeland.maxCameraY - homeland.minCameraY) - 2;
			
			local x = homeland.cameraTarget.x + radius * math.cos(homeland.cameraRotate);
			local z = homeland.cameraTarget.z + radius * math.sin(homeland.cameraRotate);
						
			camera:setPosition(LORD.Vector3(x, y, z));
			camera:setTarget(homeland.cameraTarget);
			
			homeland.multiTouchMove = true;
	end
	
end

homeland.askBuildResult = true;
homeland.unitPlayWin = false;

-- dt 
function homeland.logicTickFun(dt)

	if sceneManager.scene == nil then
		return;
	end
	
	local needAskBuildState = false;
	
	-- 抽卡相关的tick
	displayCardLogic.onDisplay(dt);
	
	if(LORD.Root:Instance():getThreadThread():HasTask() == false and homeland.unitPlayWin == false)then
		
		for k,v in pairs(homeland.unitList) do
			v:setState(homelandUnitStateWin);
		end
		
		homeland.unitPlayWin = true;
	end
	
	-- unit tick
	for k,v in pairs(homeland.unitList) do
		v:tick(dt);
	end
	
	
	homeland.updateMiracleEffect();
	
	for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
		homeland.buildActors.clickTimer[v] = homeland.buildActors.clickTimer[v] - 1000*dt;
		
		--print("homeland.buildActors.clickTimer[v] "..homeland.buildActors.clickTimer[v]);
		if homeland.buildActors.clickTimer[v] < 0 and homeland.buildActors.skillstate[v] == "open" then
			homeland.buildActors.clickTimer[v] = 0;
			
			homeland.buildActors.actor[v]:PlaySkill("openidle");
			homeland.buildActors.skillstate[v] = "openidle";
			
		end	

		homeland.buildActors.skill01Timer[v] = homeland.buildActors.skill01Timer[v] - 1000*dt;
		
		if homeland.buildActors.skill01Timer[v] < 0 and homeland.buildActors.skillstate[v] == "skill01" then
			homeland.buildActors.skill01Timer[v] = 0;
			
			homeland.buildActors.actor[v]:PlaySkill("openidle");
			homeland.buildActors.skillstate[v] = "openidle";
			
		end

		homeland.buildActors.skill02Timer[v] = homeland.buildActors.skill02Timer[v] - 1000*dt;
		
		if homeland.buildActors.skill02Timer[v] < 0 and homeland.buildActors.skillstate[v] == "skill02" then
			homeland.buildActors.skill02Timer[v] = 0;
			
			homeland.buildActors.actor[v]:PlaySkill("openidle");
			homeland.buildActors.skillstate[v] = "openidle";
			
		end
				
				
		local build = homeland.getBuildTypeByHomeland(v);
		-- 处理升级的att
		if homeland.buildActors.levelupatt[v] == "" and homeland.buildActors.actor[v] and homeland.buildActors.actor[v]:getHasInited() then
			
			if build and dataManager.build[build]:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING then
				homeland.buildActors.actor[v]:AddSkillAttack(homeland.BUILD_LEVELUP_ATT..build..".att");
				homeland.buildActors.levelupatt[v] = homeland.BUILD_LEVELUP_ATT..build..".att";
				
				print("BUILD_LEVELUP_ATT  ----ing ");
			end
			
		elseif homeland.buildActors.levelupatt[v] ~= "" and homeland.buildActors.actor[v] and homeland.buildActors.actor[v]:getHasInited() then

			if build and dataManager.build[build]:getLevelUpStatus() ~= enum_LEVELUP_STATUS.LEVELUP_ING then
				homeland.buildActors.actor[v]:RemoveSkillAttack(homeland.BUILD_LEVELUP_ATT..build..".att");
				homeland.buildActors.levelupatt[v] = "";
				
				print("BUILD_LEVELUP_ATT  ----remove ");
			end
						
		end
		
		-- 更新保护状态
		homeland.updateIdolProtectEffect();
		
		-- 升级的倒计时，如果升级ok了要请求
		if build and dataManager.build[build]:getLevelUpStatus() == enum_LEVELUP_STATUS.LEVELUP_ING and global.getBuildLevelupTime(v) <= 0 and homeland.askBuildResult == true then
			sendAskSyncBuild(build);
			homeland.askBuildResult = false;
		end
		
		if build and homeland.playBuildLevelupOK == build and homeland.buildActors.actor[v] and homeland.buildActors.actor[v]:getHasInited() then
			
			scheduler.performWithDelayGlobal(function()
				homeland.notifyBuildLevelupOK(homeland.playBuildLevelupOK); 
				homeland.playBuildLevelupOK = nil;
			end, 1);
			
		end
	
	end
	
end

-- handle ui
function homeland.handleUIWolrdPos(dt)
	if sceneManager.scene == nil then
		return;
	end
	
	homeland.buildPanelTimer = homeland.buildPanelTimer - dt;
		
	homeland.checkBuildNotifyState();
	
	local position = LORD.SceneManager:Instance():getMainCamera():getPosition();
	--print("homeland.logicTickFun(touchType, touchPosition) position x"..position.x.." position.z "..position.z.."");
	
	for k,v in pairs(homeland.buildNotifyState) do
		if homeland.buildNotifyUI[k] and homeland.buildNotifyUIIcon[k] then
			homeland.buildNotifyUI[k]:SetVisible(v);
			homeland.buildNotifyUIIcon[k]:SetImage(homeland.buildNotifyIcon[k]);
			-- 设置位置
			local gameobj = homeland.buildActors.actor[k];
			if gameobj and gameobj:frustumIntersects() and homeland.showNotify and homeland.isBuildActive(k) then
				local worldPos = gameobj:GetPosition();

				worldPos.y = worldPos.y + homeland.buildNotifyHeightOffset[k];
				local screenpos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);
				
				local uisize = homeland.buildNotifyUI[k]:GetPixelSize();
				
				local yoffset = 0;
				if global.getBuildLevelupTime(k) and global.getBuildLevelupTime(k) > 0 then
					yoffset = 64;
				else
					yoffset = 32;
				end
				
				homeland.buildNotifyUI[k]:SetPosition(LORD.UVector2(LORD.UDim(0, screenpos.x-uisize.x/2), LORD.UDim(0, screenpos.y - uisize.y - yoffset)));	
				
				
				--LORD.GUISystem:Instance():set2DBillBoardPosition(homeland.buildNotifyUI[k], worldPos, uisize.x * 0.3, uisize.y * 0.3);
			else
				homeland.buildNotifyUI[k]:SetVisible(false);
			end
		end
	end
	
	if homeland.buildPanelTimer <=0 and homeland.buildPanelHideFlag == false then
		-- 设置建筑的头顶信息
		for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
			--homeland.buildPanels.root[v]:SetVisible(false);			
			uiaction.fadeOut(homeland.buildPanels.root[v], 200);
		end
		
		homeland.buildPanelHideFlag = true;
	else
		-- 设置建筑的头顶信息
		for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
			local gameobj = homeland.buildActors.actor[v];
			
			local time = global.getBuildLevelupTime(v);
			
			if gameobj and gameobj:frustumIntersects() and homeland.showNotify and homeland.isBuildActive(v) then
			
					if time and time > 0 then
						homeland.buildPanels.timer[v]:SetText(formatTime(time, true));
					else
						homeland.buildPanels.timer[v]:SetText("");
					end
					
					homeland.buildPanels.root[v]:SetVisible(true);
					local worldPos = gameobj:GetPosition();
					
					if homeland.buildNotifyHeightOffset[v] then
						worldPos.y = worldPos.y + homeland.buildNotifyHeightOffset[v];
					end
					
					local screenpos = LORD.GUISystem:Instance():WorldPostionToScreen(worldPos);
					
					local uisize = homeland.buildPanels.root[v]:GetPixelSize();
					homeland.buildPanels.root[v]:SetPosition(LORD.UVector2(LORD.UDim(0, screenpos.x-uisize.x/2), LORD.UDim(0, screenpos.y - uisize.y)));
			else
				homeland.buildPanels.root[v]:SetVisible(false);			
			end
		end	
	end
end

function homeland.checkBuildNotifyState()
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.GOLD] = dataManager.goldMineData:hasNotifyState();
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.WOOD] = dataManager.lumberMillData:hasNotifyState();
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.MAGIC] = dataManager.magicTower:hasNotifyState();
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.INSTANCE] = dataManager.mainBase:hasNotifyState();
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.CARD] = dataManager.playerData:getNextFreeCardRemainTime() <= 0 ;
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.SHOP] = dataManager.shopData:hasNotifyState();
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.ARENA] = dataManager.pvpData:canMatching();
	homeland.buildNotifyState[enum.HOMELAND_BUILD_TYPE.GONGHUI] = dataManager.idolBuildData:hasNotifyState();
end

function homeland.handleBuildClickEffect(buildType)
	if homeland.buildActors.clickPlay[buildType] and homeland.buildActors.actor[buildType] then
		homeland.buildActors.clickTimer[buildType] = homeland.buildActors.actor[buildType]:PlaySkill("open");
		homeland.buildActors.skillstate[buildType] = "open";
	end
end

function homeland.handleBuildSkill01Effect(buildType)
	if homeland.buildActors.actor[buildType] then
		homeland.buildActors.skill01Timer[buildType] = homeland.buildActors.actor[buildType]:PlaySkill("skill01");
		homeland.buildActors.skillstate[buildType] = "skill01";
	end
end

function homeland.handleBuildSkill02Effect(buildType)
	if homeland.buildActors.actor[buildType] then
		homeland.buildActors.skill02Timer[buildType] = homeland.buildActors.actor[buildType]:PlaySkill("skill02");
		homeland.buildActors.skillstate[buildType] = "skill02";
	end
end

function homeland.handleBuildRecoverClickEffect(buildType)
	if homeland.buildActors.clickPlay[buildType] and homeland.buildActors.actor[buildType] then
		homeland.buildActors.actor[buildType]:PlaySkill("idle");
		homeland.buildActors.skillstate[buildType] = "idle";
	end
end


function homeland.isBuildActive(buildType)
	
	local level = dataManager.playerData:getLevel();
	
	if buildType == enum.HOMELAND_BUILD_TYPE.BASE then
		return level >= dataConfig.configs.ConfigConfig[0].mainBaseLevelLimit;
	elseif buildType == enum.HOMELAND_BUILD_TYPE.GOLD then
		return level >= dataConfig.configs.ConfigConfig[0].goldMineLevelLimit;
	elseif buildType == enum.HOMELAND_BUILD_TYPE.WOOD then
		return level >= dataConfig.configs.ConfigConfig[0].lumberMillLevelLimit;
	
	elseif buildType == enum.HOMELAND_BUILD_TYPE.CARD then
		return dataManager.playerData:getAdventureNormalProcess() >= dataConfig.configs.ConfigConfig[0].drawCardProcessLimit;
		
	elseif buildType == enum.HOMELAND_BUILD_TYPE.MAGIC then
		return level >= dataConfig.configs.ConfigConfig[0].magicTowerLevelLimit;
		
	elseif buildType == enum.HOMELAND_BUILD_TYPE.SHIP then
		--return level >= dataConfig.configs.ConfigConfig[0].shipLevelLimit;
		return true;
	
	elseif buildType == enum.HOMELAND_BUILD_TYPE.EQUIP then
	
		return level >= dataConfig.configs.ConfigConfig[0].miracleLevelLimit;

	elseif buildType == enum.HOMELAND_BUILD_TYPE.ARENA then
		return level >= dataConfig.configs.ConfigConfig[0].pvpLevelLimit;

	elseif buildType == enum.HOMELAND_BUILD_TYPE.SHOP then
		return level >= dataConfig.configs.ConfigConfig[0].shopLevelLimit;
	
	elseif buildType == enum.HOMELAND_BUILD_TYPE.GONGHUI then
		
		return level >= dataConfig.configs.ConfigConfig[0].idolLevelLimit;
					
	end
	
	
	return true;
end

function homeland.setCrystalVisible(visible)
	if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.CARD2] then
		homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.CARD2]:setActorHide(not visible);
	end
end

-- 根据服务器的枚举换成homeland的枚举
function homeland.getHomelandTypeByBuildType(build)

	if build == enum.BUILD.BUILD_MAIN_BASE then
		return enum.HOMELAND_BUILD_TYPE.BASE;
	elseif build == enum.BUILD.BUILD_GOLD_MINE then
		return enum.HOMELAND_BUILD_TYPE.GOLD;
	elseif build == enum.BUILD.BUILD_LUMBER_MILL then
		return enum.HOMELAND_BUILD_TYPE.WOOD;
	elseif build == enum.BUILD.BUILD_MAGIC_TOWER then
		return enum.HOMELAND_BUILD_TYPE.MAGIC;
	end
	
end

-- 根据homeland的枚举获得服务器枚举
function homeland.getBuildTypeByHomeland(homelandType)

	if homelandType == enum.HOMELAND_BUILD_TYPE.BASE then
		return enum.BUILD.BUILD_MAIN_BASE;
	elseif homelandType == enum.HOMELAND_BUILD_TYPE.GOLD then
		return enum.BUILD.BUILD_GOLD_MINE;
	elseif homelandType == enum.HOMELAND_BUILD_TYPE.WOOD then
		return enum.BUILD.BUILD_LUMBER_MILL;
	elseif homelandType == enum.HOMELAND_BUILD_TYPE.MAGIC then
		return enum.BUILD.BUILD_MAGIC_TOWER;
	end
	
end

function homeland.notifyBuildLevelupOK(build)
	
	local homelandType = homeland.getHomelandTypeByBuildType(build);
	
	if homeland.buildActors.actor[homelandType] then
		homeland.buildActors.actor[homelandType]:RemoveSkillAttack(homeland.BUILD_LEVELUP_ATT..build..".att");
		homeland.buildActors.levelupatt[homelandType] = "";
		homeland.buildActors.actor[homelandType]:AddSkillAttack(homeland.BUILD_LEVELUP_OK_ATT..build..".att");
		LORD.SoundSystem:Instance():playEffect("shengji.mp3");
	end

end

-- 神像升级成功的效果，跟别的建筑不同
function homeland.notifyIdolLevelupOK()
	
	if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI] then
		homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI]:RemoveSkillAttack("jianzhushengji024.att");
		homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI]:AddSkillAttack("jianzhushengji024.att");
		LORD.SoundSystem:Instance():playEffect("shengji.mp3");
	end
	
end

-- 奇迹升级成功的效果
function homeland.notifyMiracleLevelupOK()
	
	if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP] then
		homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP]:RemoveSkillAttack("jianzhushengji024.att");
		homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP]:AddSkillAttack("jianzhushengji024.att");
		LORD.SoundSystem:Instance():playEffect("shengji.mp3");
	end
	
	homeland.buildActors.miracleFlag = false;
	homeland.updateMiracleEffect();
	
end

-- 更新奇迹的特效
function homeland.updateMiracleEffect()

	if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP] then
		
		local config = dataManager.miracleData:getConfig();
		if config and config.gfxName and homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP]:getHasInited() and homeland.buildActors.miracleFlag == false then
		
			--remove all
			for k,v in pairs(dataConfig.configs.miracleConfig) do
				if v.gfxName then
					homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP]:RemoveSkillAttack(v.gfxName);
				end
			end
			
			homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.EQUIP]:AddSkillAttack(config.gfxName);
			
			homeland.buildActors.miracleFlag = true;
		end
	end
	
end


-- 更新神像保护状态
function homeland.updateIdolProtectEffect()
	
	if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI] then
		
		-- add
		if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI]:getHasInited() and dataManager.idolBuildData:getRemainProtectTime() > 0 and homeland.buildActors.protectState == false then
			homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI]:AddPluginEffect("protect", "", "jiayuantexiao_gonghui01.effect");
			
			homeland.buildActors.protectState = true;
		end
		
		-- del
		if homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI]:getHasInited() and dataManager.idolBuildData:getRemainProtectTime() <= 0 and homeland.buildActors.protectState == true then
			
			homeland.buildActors.actor[enum.HOMELAND_BUILD_TYPE.GONGHUI]:DelPluginEffect("protect", true);
			
			homeland.buildActors.protectState = false;
		end
		
	end
	
end

function homeland.changeBuildDarkExcludeCard(ratio)
	for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
		if homeland.buildActors.actor[v] and v ~= enum.HOMELAND_BUILD_TYPE.CARD and v ~= enum.HOMELAND_BUILD_TYPE.CARD2 then
			homeland.buildActors.actor[v]:ChangeDark(ratio);
		end
	end
end

function homeland.RevertBuildLight()
	for k,v in pairs(enum.HOMELAND_BUILD_TYPE) do
		if homeland.buildActors.actor[v] and v ~= enum.HOMELAND_BUILD_TYPE.CARD and v ~= enum.HOMELAND_BUILD_TYPE.CARD2 then
			homeland.buildActors.actor[v]:RevertLight();
		end
	end
end

-- 根据自定义包围盒
function homeland.RayPickActor(touchPosition)

	local camera = LORD.SceneManager:Instance():getMainCamera();	
	local ray = LORD.Ray();
	camera:getCameraRay(ray, touchPosition);
			
	for k,v in pairs(homeland.buildActors.box) do
		local pos = homeland.buildActors.pos[k];
		local vmin = pos - LORD.Vector3(v.x / 2, 0, v.z / 2);
		local vmax = pos + LORD.Vector3(v.x / 2, v.y, v.z / 2);
		local box = LORD.Box(vmin, vmax);
		
		if ray:hitBox(box) then
			return homeland.buildActors.actor[k];
		end
	end
	
	return nil;
end

function homeland.setUnitVisible(show)
	
	if homeland.unitList then
		for k,v in pairs(homeland.unitList) do
			v:setActorHide(not show);
			if show then
				v:setState(homelandUnitStateMove);
			end
		end
	end
end
