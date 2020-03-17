--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/17
-- Time: 22:18
--
--
_G.classlist['CPlayerMap'] = 'CPlayerMap'
_G.CPlayerMap = {}
CPlayerMap.objName = 'CPlayerMap'
--机关
CPlayerMap.gimmicks = nil;				
function CPlayerMap:Create()
	--分配场景管理器
	self.objSceneMap = CSceneMap:new();
	self.setAllPlayer = {};      --用来保存当前地图上的所有玩家
    self.currMapId = 0;
	self.currLine = 0;
	self.curMapInfo = nil;
    self.bChangeMaping = false;
    self.changePosState = false
    self.changeLineState = false
    self.teleportState = false
    self.allMapScriptNode = {}
	return true;
end;

local pos = _Vector3.new()
local mat =_Matrix3D.new()
local cameraPfxPos = _Vector3.new()
function CPlayerMap:Update(dwInterval)
	local mypos = nil;
	if self.objPointLight or self.facePointLight then
		mypos = self.objMainPlayer:GetPos();
		local faceto = self.objMainPlayer:GetDirValue()
        if self.objMainPlayer and faceto and mypos then
			if self.objPointLight then
				pos.x, pos.y, pos.z = 0, 0, 26
				_Vector3.add(mypos, pos, self.objPointLight.position)
			end
			
			
			if self.facePointLight then
				local x, y = GetPosByDis(mypos, faceto, RoleFaceLightDistance);
				mypos.x = x;
				mypos.y = y;
				mypos.z = mypos.z + 5;
				self.facePointLight.position = mypos;
			end
        end
	end;

	if self.cameraPfx then
		if self.currMapId == 10100003 then 
			-- cameraPfxPos.x = _rd.camera.eye.x - 40
			-- cameraPfxPos.y = _rd.camera.eye.y - 40
			-- cameraPfxPos.z = _rd.camera.eye.z - 40
			-- mat:setTranslation(cameraPfxPos)
			-- mat:mulScalingLeft(0.2, 0.2, 0.2)
			-- self.cameraPfx.transform:set(mat)
		else
			-- cameraPfxPos.x = _rd.camera.eye.x - 20
			-- cameraPfxPos.y = _rd.camera.eye.y - 20
			-- cameraPfxPos.z = _rd.camera.eye.z - 20
			-- mat:setTranslation(cameraPfxPos)
			-- mat:mulScalingLeft(10, 10, 10)
			-- self.cameraPfx.transform:set(mat)
		end
		
	end

    --update node pos and render node
	if self.objSceneMap then
		if self.objSceneMap.objScene then
			mypos = mypos and mypos or self.objMainPlayer:GetPos();
			self.objSceneMap.objScene:acrossGrass(mypos,10,5);
		end
		self.objSceneMap:Update(dwInterval);
		self:CheckGimmick(dwInterval);
	end;

	--gameobj update biz(handler playboard, action switch. etc)
	--注意画的顺序，排序，解决头顶文字遮挡问题
	--[[
	local keys = self:getKeysSortedByValue(MainPlayerModel.allDropItem)
	for i, v in pairs(keys) do
		local item = MainPlayerModel.allDropItem[v]
		if item then
			item:Update(dwInterval);
		end;
	end;
	--]]

	for i,item in pairs(MainPlayerModel.allDropItem) do
		if item then
			item:Update(dwInterval);
		end;
	end;

	local monsterList = MonsterModel:GetMonsterList()
	if monsterList then
		for cid, monster in pairs(monsterList) do
			monster:Update(dwInterval)
		end
	end
	
	if StoryController:IsStorying() then
		local storyMonsterList = MonsterModel.StoryNodes
		if storyMonsterList then
			for cid, monster in pairs(storyMonsterList) do
				monster:Update(dwInterval)
			end
		end
	end
	
	local npcList = NpcModel:GetNpcList()
	if npcList then
		for cid, npc in pairs(npcList) do
			npc:Update(dwInterval)
		end
	end

	local npcStoryList = NpcModel:GetStoryNpcList()
	if npcStoryList then
		for gid, snpc in pairs(npcStoryList) do
			snpc:Update(dwInterval)
		end
	end

	for i,Player in pairs(self.setAllPlayer) do
		if Player then
			Player:Update(dwInterval);
		end;
	end;

	local lingShouList = LSModel:GetLingShouList()
	for cid, ls in pairs(lingShouList) do
		if ls then
			ls:Update(dwInterval)
		end
	end

	CPlayerMap:UpdateMapScriptNode(dwInterval)

	local huncheList = HuncheModel:GetHuncheList()
	for cid, hunche in pairs(huncheList) do
		if hunche then
			hunche:Update(dwInterval)
		end
	end
	
	CameraControl:onUpdate(dwInterval);

end;

---头顶文字深度排序，看策划要求是否开启
local keys = {}
function CPlayerMap:getKeysSortedByValue(tbl)
	keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end

	table.sort(keys, function(a, b)
		local rst = true

		local entityA = tbl[a]
		local entityB = tbl[b]
		local disA = _Vector3.distance(entityA:GetPos(), _rd.camera.eye)
		local disB = _Vector3.distance(entityB:GetPos(), _rd.camera.eye)
		rst = disA >= disB

		return rst
	end)
	Debug(Utils.dump(keys))
	return keys
end


function CPlayerMap:Destroy()
	assert(false)
	self.objSceneMap = nil;
	CameraControl:Clear();
end;

--窗口最小化
function CPlayerMap:OnWindowMin()
	if self.objSceneMap then
		for _,objEnity in pairs(self.objSceneMap.setAllEntity)do
			if objEnity.OnWindowMin then
				objEnity:OnWindowMin();
			end
		end
	end
end;

--窗口还原
function CPlayerMap:OnWindowBack()
	if self.objSceneMap then
		for _,objEnity in pairs(self.objSceneMap.setAllEntity)do
			if objEnity.OnWindowBack then
				objEnity:OnWindowBack();
			end
		end
	end
end;

function CPlayerMap:addMapPortalPoint(point)
    self:AddPortal(point)
end

function CPlayerMap:GetMapPortals()
	return self.currMapPoint or {}
end

function CPlayerMap:ClearPortalPfx()
	if not self.currMapPoint then
		return
	end
	for cid, point in pairs(self.currMapPoint) do
		self:DeletePortal(cid)
		self.currMapPoint[cid] = nil 
	end
	self.currMapPoint = {}
end

function CPlayerMap:ClearLocalPortalPfx()
	if not self.currMapPoint then
		return
	end
	for cid, point in pairs(self.currMapPoint) do
		local id = point.id
		if t_portal[id] and t_portal[id].type ~= 6 then
			self:DeletePortal(cid)
			self.currMapPoint[cid] = nil 
		end
	end
end

function CPlayerMap:AddPortal(point)
    if not self.currMapPoint then
    	self.currMapPoint = {}
	end
	if self.currMapPoint[point.cid] then
		return
	end
	local portalVo = t_portal[point.id]
    if not portalVo then
    	return
    end 
    if portalVo.type == 6 then
    	point = PortalController:AddPortal(point)
    else
		self:DrawDoor(point)
	end
	self.currMapPoint[point.cid] = point
end

function CPlayerMap:DeletePortal(cid)
	if not self.currMapPoint then
		return
	end
	local point = self.currMapPoint[cid]
	if not point then
		return
	end
	local portalVo = t_portal[point.id]
    if not portalVo then
    	return
    end 

    if portalVo.type == 6 then
		PortalController:DeletePortal(cid)
	else
		self:NoDrawDoor(point)
	end
	self.currMapPoint[cid] = nil
end

function CPlayerMap:NoDrawDoor(point)
	local portalVo = t_portal[point.id]
    if not portalVo then
    	return
    end 
	if portalVo.pfx and portalVo.pfx ~= "" then
		self.objSceneMap:StopPfxByName("portal_pfx" .. point.cid)
	end
	if portalVo.name_pfx and portalVo.name_pfx ~= "" then
		self.objSceneMap:StopPfxByName("portal_name_pfx" .. point.cid)
	end
	return true
end

function CPlayerMap:DrawDoor(point)
    local portalVo = t_portal[point.id]
    if not portalVo then
    	return
    end
	point.portalRange = portalVo.trigger_dist
	local fz = self.objSceneMap:getSceneHeight(point.x, point.y)
	if portalVo.pfx and portalVo.pfx ~= "" then
		local mat =_Matrix3D.new()
		mat:setTranslation(_Vector3.new(point.x, point.y, fz))
    	self.objSceneMap:PlayerPfxByMat("portal_pfx" .. point.cid, portalVo.pfx, mat)
    end
    if portalVo.name_pfx and portalVo.name_pfx ~= "" then
    	local mat =_Matrix3D.new()
    	mat:setTranslation(_Vector3.new(point.x, point.y, fz + portalVo.name_height))
    	self.objSceneMap:PlayerPfxByMat("portal_name_pfx" .. point.cid, portalVo.name_pfx, mat)
    end
    return true
end

local mat =_Matrix3D.new()
local from = _Vector2.new()
local to = _Vector2.new()
local dist = _Vector2.new()
function CPlayerMap:ComPosInRange(point,vecPos)
	from.x = point.x
	from.y = point.y
	to.x = vecPos.x
	to.y = vecPos.y
	_Vector2.sub(from, to, dist)
	return dist:magnitude() < point.portalRange   --玩家位置小于传送门半径

end;

function CPlayerMap:ComputeChangeMap()
	--获取自己的位置
	local selfPlayer = MainPlayerController:GetPlayer()
	if not selfPlayer then
		print("MainPlayerController not selfPlayer")
	end
	local mePos = MainPlayerController:GetPlayer():GetPos()
	if not mePos then
		print("MainPlayerController:GetPlayer() not GetPos()")
		return
	end
	--得到当前地图数据
    if self.currMapPoint == nil then 
    	return
    end
	for cid, point in pairs(self.currMapPoint) do
		local portalVo = t_portal[point.id];
		if portalVo.type ~= 6 then
			if self:ComPosInRange(point, mePos) then
				--[[
				--特殊处理抢宝箱活动进入传送门问题
				local inActivityBox = false;
				for k,activity in pairs(ActivityModel.list) do
					if activity:GetId() == ActivityConsts.RobBox and activity:IsIn() then   --获取是抢宝箱活动并且在活动中
						inActivityBox = true;
					end
				end
				if inActivityBox then
					return;
				else
					
				end
				--]]
				
				MainPlayerController:ReqPortalDoor(point.cid, point.id);
					break;
	        end
	    end
    end
end

function CPlayerMap:OnEnterMascotCome(point)
	local portalVo = t_portal[point.id]
    if not portalVo then
    	return
	end
	local activity;
	if ActivityMascotCome.currentChooseMascotComeActivityID == 0 then
		activity = ActivityUtils:GetCanInMascotComeActivity();
	else
		activity = ActivityModel:GetActivity(ActivityMascotCome.currentChooseMascotComeActivityID);
	end
	if not activity then return end
	ActivityMascotCome.currentChooseMascotComeActivityID = activity:GetId();

	local enterNum = activity:GetDailyTimes();
	local activityCfg = t_activity[activity:GetId()];
	if not activityCfg then return end
	
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	if level < activityCfg.needLvl then
		FloatManager:AddCenter(StrConfig['activityMascotCome1']);
		return 
	end
	
	if activityCfg.dailyJoin - enterNum <= 0 then
		local func = function()
			return 
		end
		UIConfirm:Open(StrConfig['mascotCome006'],func);
		return 
	end
	
	local func = function()
		MainPlayerController:ReqPortalDoor(point.cid, point.id)
	end
	local num = activityCfg.dailyJoin - enterNum;	--剩余数量
	self.uiconfirmID = UIConfirm:Open(string.format(StrConfig['mascotCome005'],num),func);
	ActivityMascotCome.currentChooseMascotComeActivityID = 0;
end

--获取场景
function CPlayerMap:GetSceneMap()
	return self.objSceneMap;
end;

--播放场景背景与音乐
function CPlayerMap:PlaySound(soundId)
	SoundManager:PlayBackSfx(soundId)
end

function CPlayerMap:StopSound()

end

function CPlayerMap:InitMainPlayerPos(sInfo)

    local cameraBorn = self.objSceneMap.objScene.graData:getCamera('camera1');
	if not cameraBorn then
		local cameras = self.objSceneMap.objScene.graData:getCameras()
		for i, v in pairs(cameras) do
			Debug(v.name, v.eye, v.look)
			Debug("scene camera eye: ", v.eye.x, v.eye.y, v.eye.z)
			Debug("scene camera look: ", v.look.x, v.look.y, v.look.z)
			Debug("scene camear fov: ", v.fov)
			cameraBorn  = v;
		end
	end

    --assert(false)

    --初始化玩家位置
    self.objMainPlayer = MainPlayerController:GetPlayer();
    self.setAllPlayer[self.objMainPlayer:GetRoleID()] = self.objMainPlayer;

    self.objMainPlayer.objAvatar.Control = CPlayerControl; --UpdatePosByRender
	Debug("sInfo: ", Utils.dump(sInfo))
    self.objMainPlayer:EnterMap(self.objSceneMap,sInfo.posX,sInfo.posY,sInfo.dir);--设置位置
    self.objMainPlayer:ResetHorse()
    MainPlayerController:ClearPlayerState()
	self.objMainPlayer.objAvatar.objNode.bIsMe = true;
	self.objMainPlayer.objAvatar:ResetTerrain()
    local mePos = self.objMainPlayer:GetPos()
    local dwProfID = self.objMainPlayer:GetPlayerInfoByType(enAttrType.eaProf);--职业得到摄像机位置
    local sProfConfig = RoleConfig.ProfConfig[dwProfID]

    CPlayerControl.dwCameraHeight = sProfConfig.dwCameraHeight
	
    --compute camera eye look
    local subVec = _Vector3.sub(cameraBorn.eye, cameraBorn.look);
	-- subVec.z = CPlayerControl:GetCameraMaxHeight()
	--Debug("#######", subVec.x, subVec.y, subVec.z)
    -- subVec.x = 30 subVec.y = 110 subVec.z = RenderConfig.cameraMaxHeight
	--subVec.x = 80 subVec.y = 80 subVec.z = 100
    --subVec.x = 200 subVec.y = 200 subVec.z = 200 --test
    local mLook = _Vector3.new(mePos.x, mePos.y, mePos.z + sProfConfig.dwCameraHeight)
    local mEye = _Vector3.add(mLook, subVec)
    _rd.camera.look = mLook
    _rd.camera.eye = mEye
    _rd.camera.fov = cameraBorn.fov
	
	CPlayerControl:ChangeCameraDist(0);
	cameraBorn.look = _rd.camera.look;
    cameraBorn.eye = _rd.camera.eye
	
	CPlayerControl.senSubVec = _Vector3.new(mEye.x - mLook.x, mEye.y - mLook.y, mEye.z - mLook.z)
	CPlayerControl.showName = true																					--TODO Init camera

    self.objPointLight = nil;
    local mapId = sInfo.mapID or CPlayerMap:GetCurMapID()
    local mapInfo = t_map[mapId]
	if self.cameraPfx then self.objMainPlayer.objAvatar.objMesh.pfxPlayer:stopAll() end
    if mapInfo and mapInfo["scene_camera_pfx"] and mapInfo["scene_camera_pfx"] ~= "" then
		--self.cameraPfx = self.objSceneMap:PlayerPfxByMat("camera", mapInfo["scene_camera_pfx"])
		self.cameraPfx = self.objMainPlayer.objAvatar.objMesh.pfxPlayer:play(mapInfo["scene_camera_pfx"])
		self.cameraPfx.bind = false
	else
		self.cameraPfx = nil
	end

    --主角头顶点光
    print("InitMainPlayerPos................", mapId)
    
	--设置主角光
	self:SetPlayerLight();
    --全屏光
	self:SetSceneLight();
	--设置高度雾
	self:SetSceneFog();
	
	--灵路用场景编辑器里的摄像机
	if mapId == 10400025 then
		_rd.camera.look = cameraBorn.look
		_rd.camera.eye = cameraBorn.eye
		_rd.camera.fov = cameraBorn.fov
		self.objSceneMap:PlayPfxOnNode('czfb_neiquan3', 'changjing_pubu01', 'changjing_pubu.pfx')
	end

	if mapId == 10100000 then
		local avatar = self.objMainPlayer.objAvatar
		local Showcfg = t_playerinfo[dwProfID]
		avatar:SetDress(Showcfg.create_dress)
		CPlayerMap.changeDress = true
	else
		if CPlayerMap.changeDress then
			self.objMainPlayer:UpdateShowEquip()
			CPlayerMap.changeDress = false
		end
	end
	
	-- if 10100001 == mapId or 10100000 == mapId then
		-- StorySpeedUpEffect:Show()
		-- StorySpeedUpEffect:Hide()
	-- end

	if mapId and mapInfo then
		if mapInfo.type == 3 then
			MainPlayerController:GetPlayer():InitStateInfo()
			SkillController.stiffTime = 0
		end
	end

	--
	local quest = QuestModel:GetTrunkQuest()
	if quest then
		local questId = quest:GetId()
		MainPlayerController:ChangeMesh(questId, 1)
		--NpcController:AddQuestNpcByQuestId(questId, 1)
		--CPlayerMap:SetCamera(questId)
	end
	
	if not isPublic and isDebug then
		-- self:SetUseFieldEffect(false);
		-- self:SetUseFieldShadow(false);
		self:FieldChange(mePos);
	else
		self:FieldChange(mePos);
	end

end

function CPlayerMap:SetSceneLight(light)
	light = light or Light.GetSceneLight(self:GetCurMapID());
	_rd.glowFactor = light.glowFactor;
	_rd.lightFactor = light.lightFactor;
	_G.gameGlowFactor = _rd.glowFactor;
	self:SetUseFieldEffect(light.fieldEffect);
	self:SetUseFieldShadow(light.fieldShadow);
end

function CPlayerMap:SetPlayerLight(light)
	light = light or Light.GetEntityLight(enEntType.eEntType_Player,self:GetCurMapID());
	local point = light.pointlight;
	if self.objPointLight == nil then self.objPointLight = _PointLight.new() end
	self.objPointLight.color = point.color;
    self.objPointLight.power = point.power;
    self.objPointLight.range = point.range;
	
	local sky = light.skylight;
	if self.objSkyLight == nil then self.objSkyLight = _SkyLight.new() end
	_G.dwSkyLightColor = sky.color;
	_G.dwSkyLightPower = sky.power;
	self.objSkyLight.color = dwSkyLightColor;
	self.objSkyLight.power = dwSkyLightPower;
	self.objSkyLight.backLight = sky.backLight;
	self.objSkyLight.fogLight = sky.fogLight;
	
	local back = light.backskylight;
	if self.objSkyBackLight == nil then self.objSkyBackLight = _SkyLight.new() end
	_G.dwSkyBackLightColor = back.color;
	_G.dwSkyBackLightPower = back.power;
	self.objSkyBackLight.color = dwSkyBackLightColor;
	self.objSkyBackLight.power = dwSkyBackLightPower;
	self.objSkyBackLight.backLight = false;
	self.objSkyBackLight.fogLight = false;
	
	local face = light.facelight;
	self.facePointLight = nil;
	if face.power==0 then
		self.facePointLight = nil;
	else
		if self.facePointLight == nil then self.facePointLight = _PointLight.new() end
		self.facePointLight.color = face.color;
		self.facePointLight.power = face.power;
		self.facePointLight.range = face.range;
	end
	
end

function CPlayerMap:SetSceneFog(fog)
	fog = fog or Light.GetSceneFog(self:GetCurMapID());
	self.fog = fog;
	if not self.fog or not self.fog.use then
		self.fogclipper = nil;
		return;
	end
	self.fogclipper = self.fogclipper or _Clipper.new();
	self.fogclipper:fadeZ(fog.start,fog.over,fog.color);
	if not self.objSceneMap then
		return;
	end
	local scene = self.objSceneMap.objScene;
	if not scene then
		return;
	end
	local sf = scene.graData:getFog(1);
	sf.near = fog.near;
	sf.far = fog.far;
end

function CPlayerMap:DoChangeMap(sInfo, onChanged)
	--设置切换场景标记位
	self.bChangeMaping = true
	--停止移动
	MainPlayerController:StopMove()
	--清除各种状态
	MainPlayerController:ClearPlayerState()
	--关闭自动战斗
	AutoBattleController:InterruptAutoBattle()
	--离开场景
	GameController:OnLeaveSceneMap()
	--清理音效
	SoundManager:StopBackSfx()
	SoundManager:StopSfx()
	--清理寻路特效
	SceneRoute:InitRoute()
	--清楚机关信息
	self:ClearGimmick();
	UIMainFightFly:Hide() --切换地图直接关闭战斗力特效
	print("Unloading scene file............ ")
	if not sInfo then
		return false;
	end;
	if not self.objSceneMap then
		return false;
	end;

	--删除当前场景上的所有玩家
	for i,Player in pairs(self.setAllPlayer) do
		if Player ~= MainPlayerController:GetPlayer() then
			Player:ClearTimePlan()
			Player:ExitMap();
			Player = nil;
		end
	end;
	self.setAllPlayer = {};
	self:ClearMapScriptNode()
	self:ClearSafeAreaLine()
	self:ClearPortalPfx()
	NpcController:DeleteQuestNpc()
	
	if self.objSceneMap then
		self.objSceneMap:Unload();
	end;
	self.curMapInfo = t_map[sInfo.mapID];
    Debug("########### sInfo.mapID ", sInfo.mapID)
    Debug("########### self.curMapInfo ", Utils.dump(sInfo))
	self.curMapInfo.dwMapID = sInfo.mapID;
    self.curMapInfo.dwLineID = sInfo.lineID;
    self.curMapInfo.dwDungeonId = sInfo.dungeonId;
    self.currMapId = sInfo.mapID
	--载入场景
	self.objSceneMap.onSceneLoaded = function()
		print("load scene file finish............ ")
		QuestGuideManager:OnSceneLoadEnd();
		TimerManager:RegisterTimer(function()
     		self.bChangeMaping = false
			self:InitMainPlayerPos(sInfo)
			self:PlayMapScript()
			self:DrawSafeAreaLine()
			self:InitGimmick();
			self:PlayInSceneSan();
			self:PlaySound(self.curMapInfo.sound_id)
			print("onSceneLoaded in Timer ............ ")
			if onChanged then
				onChanged()
			end
     	end, 3000, 1)
	end
	QuestGuideManager:OnSceneLoadStart();
    self.objSceneMap:Load(self.curMapInfo)
    print("loading scene file............ ")
end


--降落在当前场景的某个位置
function CPlayerMap:DoChangePos(roleId, x, y)
	if not self.objSceneMap then
		return false
	end
	local player = CPlayerMap:GetPlayer(roleId)
	if not player then
		print("CPlayerMap:DoChangePos ========= not player")
		return
	end
	player:SetPos(x, y)
end

--获取当前地图的ID
function CPlayerMap:GetCurMapID()
	return self.currMapId;
end;

function CPlayerMap:GetCurrMapIsPk()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].canPk == false then
		return false
	end
	return true
end

function CPlayerMap:GetCurrMapIsSit()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].can_sit == false then
		return false
	end
	return true
end

function CPlayerMap:GetCurrMapIsRide()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].can_ride == false then
		return false
	end
	return true
end

function CPlayerMap:GetCurrMapIsChangeLine()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].type == 1 or t_map[mapId].type == 2 then
		return true
	end
	return false
end

function CPlayerMap:GetCurLineID()
	return self.currLine;
end

function CPlayerMap:SetCurLineID(id)
	self.currLine = id;
end

--获取当前地图上的所有玩家
function CPlayerMap:GetAllPlayer()
	return self.setAllPlayer;
end;

--通知服务器自己开始位移

function CPlayerMap:SendMoveTo(vecSrc,vecTarget,bUseCanTo)

    --local speed = MainPlayerModel.speed and MainPlayerModel.speed or _G.fSpeed;
    local msg = ReqSceneMoveMsg:new()
    msg.srcX = vecSrc.x
    msg.srcY = vecSrc.y
    msg.dirX = vecTarget.x
    msg.dirY = vecTarget.y
    --msg.speedB = speed
    --msg.speedA = 0
    --msg.speedP = 0
    --msg.useCanTo = 1
    MsgManager:Send(msg)
end;


--通知服务器自己位移停止

function CPlayerMap:SendStopMove(vecPoint,fDirValue)
    if vecPoint then
        local msg = ReqSceneMoveStopMsg:new()
        msg.stopX = vecPoint.x
        msg.stopY = vecPoint.y
        msg.dir = fDirValue
        MsgManager:Send(msg);
    end;
end;

--- 已进入游戏场景，通过传送门 切换场景地图
-- @param nResultCode
-- @param sGameInfo
--
function CPlayerMap:ExecChangeMap(nResultCode, sGameInfo)
    if MainPlayerController:GetPlayer() == nil then
	    assert(false, "never enter here.")
		if not MainPlayerController:CreatePlayer() then
	        Debug("CPlayerMap:ExecChangeMap Create main Player Error")
            assert(false, "fuck her create mainplayer error")
	        return
	    end
	end

    self:DoChangeMap(sGameInfo, function()
		Debug("OnSceneLoaded: ExecChangeMap")
		local reqSceneEnterMsg = ReqSceneEnterSceneMsg:new();
		reqSceneEnterMsg.initGame = 1; --取值1为切换地图状态
		MsgManager:Send(reqSceneEnterMsg);
		--
		GameController:OnChangeSceneMap() --- trigger all module change scene
		
	end);
end;

---
-- 客户端登陆成功后，服务器通知客户端进入游戏，客户端 创建主角，进行场景加载， 初始化主角位置，进入场景；
-- @param sGameInfo
---
function CPlayerMap:OnEnterGameResult(sGameInfo,onFinish)

    Debug("CPlayerMap:OnEnterGameResult: ", sGameInfo.result, sGameInfo)
	
	if not MainPlayerController:CreatePlayer() then
		Debug("CPlayerMap:OnEnterGameResult Create main Player Error");
        assert(false, "fuck her create mainplayer error")
        return;
	end;

	self:DoChangeMap(sGameInfo, function()
		Debug("OnSceneLoaded: EnterGame")
		if onFinish then
			onFinish();
		end
	end);
end;

--- 其它玩家进入视野
-- @param info
--
function CPlayerMap:OnAddRole(info)
	local roleId = info.dwRoleID
	local player = CPlayerMap:GetPlayer(roleId)
	TransformController:SetTransform(roleId,info.TransferModel,true);
	
    if player then	 --该玩家已经存在了 去更新他的info
		--self:OnUpdateRole(info)
		player:SetEquipsActState(self.useEquipAct);
		return
	end
	
	local player = CPlayer:new(roleId)
	player:SetEquipsActState(self.useEquipAct);
	TransformController:SetTransform(roleId,info.TransferModel);
	if not player then
		Error("new Player Error")
		return
	end
	if not player:Create(info,true) then
		Error("Create Player Error")
		return
	end

    --其他玩家玩家进入地图
	player:EnterMap(self.objSceneMap, info.x, info.y, info.faceto)
    player:GetAvatar():ChangeArms() ---触发穿戴武器
    player:SetHorse() --有马的话上马
	--添加到玩家列表中
	self:AddPlayer(player)
	if player:IsDead() then
		player:Dead()
	end
	if StoryController:IsStorying() then
		player:HideSelf(true)
	end
	player:SetSitState(player.sitInfo.sitId, player.sitInfo.sitIndex)
	player:EatLunch()
	return player
end

--得到一个地图上的玩家
function CPlayerMap:GetPlayer(dwRoleID)
	if dwRoleID == MainPlayerController:GetRoleID() then
		return MainPlayerController:GetPlayer()
	else
		return self.setAllPlayer[dwRoleID]
	end
end

function CPlayerMap:AddPlayer(player)
	self.setAllPlayer[player.dwRoleID] = player
end

function CPlayerMap:DeletePlayer(player)
	self.setAllPlayer[player.dwRoleID] = nil
end

function CPlayerMap:GetPlayerNum()
	local count = 0
	for _, v in pairs(self.setAllPlayer) do
		if v ~= nil then
			count = count + 1
		end
	end
	return count;
end
	--有一个玩家离开地图
function CPlayerMap:DelRole(roleId)
	-- if roleId == MainPlayerController:GetRoleID() then
	-- 	return
	-- end
	local player = self:GetPlayer(roleId)
	if not player then
		return
	end
	self:DeletePlayer(player)
	player:ExitMap()
	player = nil
end

--接收到别人移动的消息
function CPlayerMap:OnPlayerMoveTo(roleId, formX, formY, toX, toY)
    if roleId == MainPlayerController:GetRoleID() then
		return
    end
	local player = self.setAllPlayer[roleId]
	if not player then
		return
	end
	local speed = player:GetSpeed()
	player:AddMoveTo(formX, formY, toX, toY, speed)
end

-- 接收到别人位置的修正消息，停止
function CPlayerMap:OnPlayerMoveEnd(roleId, x, y, dir)
    if roleId == MainPlayerController:GetRoleID() then
		return
    end
	local player = self.setAllPlayer[roleId]
	if not player then
		return
	end
	player:AddMoveStop(x, y, dir)
end


--处理玩家换装
function CPlayerMap:OnPlayerEquipChange(roleId, key, meshId)
    local objPlayer = self:GetPlayer(roleId)
	if not objPlayer then
		return
	end
	local playerShowInfo = objPlayer:GetPlayerShowInfo()
	playerShowInfo[key] = meshId
	objPlayer:UpdateShowEquip()
end

--处理玩家换坐骑
function CPlayerMap:OnPlayerMountChange(roleId, horseId)
	local objPlayer = self:GetPlayer(roleId)
	if not objPlayer then
		return
	end
	local oldHorseId = objPlayer:GetPlayerShowInfo().dwHorseID
	if oldHorseId == horseId then
		return
	end
	objPlayer:GetPlayerShowInfo().dwHorseID = horseId
	objPlayer:UpdateShowEquip()
end


function CPlayerMap:GetPlayerInfo(roleId)
	local player = self:GetPlayer(roleId)
	if not player then
		return
	end
	local playerInfo = player:GetPlayerInfo()
	if not playerInfo then
		return
	end
	return playerInfo
end

function CPlayerMap:onObjAttrInfoNotify(roleId, info)  --4
	if roleId == MainPlayerController:GetRoleID() then
		MainPlayerModel:UpdateMainPlayerAttr(info)   --5
		local player = self:GetPlayer(roleId)
		if not player then
			if not MainPlayerModel.sMePlayerInfo then
				MainPlayerModel.sMePlayerInfo = {}
			end
			for k, v in pairs(info) do
				MainPlayerModel.sMePlayerInfo[k] = v
			end
			return
		end
	end

	local player = self:GetPlayer(roleId)
	if not player then
		return
	end

    player:UpdatePlayerInfo(info)   --5.1
	info = nil
end

function CPlayerMap:GetPortalByCid(cid)
	if not self.curMapInfo then
		return 0
	end
	if not self.currMapPoint then
		return 0
	end
	local point = self.currMapPoint[cid]
	if not point then
		return 0
	end
	return point.id
end

function CPlayerMap:GetPlayerNode(cid)
	local player = self:GetPlayer(cid)
	if not player then
		return
	end
	local avatar = player:GetAvatar()
	if not avatar then
		return
	end
	return avatar.objNode
end

function CPlayerMap:PlayMapScript()
	local currMapId = CPlayerMap:GetCurMapID()
	local mapNodeList = MapScript[currMapId]
	if not mapNodeList then
		return
	end
	for index, node in pairs(mapNodeList) do
		local avatar = MapScriptNodeAvatar:Init(node)
		if avatar then
			table.insert(CPlayerMap.allMapScriptNode, avatar)
		end
	end
end

function CPlayerMap:ClearMapScriptNode()
	if CPlayerMap.allMapScriptNode then
		for index = #CPlayerMap.allMapScriptNode, 1, -1 do
			local avatar = CPlayerMap.allMapScriptNode[index]
			if avatar then
				avatar:ExitMap()
				avatar = nil
			end
		end
	end
	CPlayerMap.allMapScriptNode = {}
end

function CPlayerMap:UpdateMapScriptNode(dwInterval)
	if CPlayerMap.allMapScriptNode then
		for index = #CPlayerMap.allMapScriptNode, 1, -1 do
			local avatar = CPlayerMap.allMapScriptNode[index]
			if avatar then
				avatar:UpdatePos(dwInterval)
			end
		end
	end
end

function CPlayerMap:DrawSafeAreaLine()
    local mapId = self:GetCurMapID()
    local mapInfo = t_map[mapId]
    local safeareaLineConfig = mapInfo.safeareaLineConfig
    if safeareaLineConfig and safeareaLineConfig ~= "" then
    	local list = GetPoundTable(safeareaLineConfig)
    	for i = 1, #list do 
	        local pointTable = GetCommaTable(list[i])
	        local x1, y1 = tonumber(pointTable[1]), tonumber(pointTable[2])
	        local z1 = self.objSceneMap:getSceneHeight(x1, y1)
	        local x2, y2 = tonumber(pointTable[3]), tonumber(pointTable[4])
	        local point1 = {x = x1, y = y1}
	        local point2 = {x = x2, y = y2}
	        local dis = GetDistanceTwoPoint(point1, point2)
	        local dir = GetDirTwoPoint(point1, point2)
	        self.objSceneMap:PlayerPfx(10025, _Vector3.new(x1, y1, z1))
	        for j = 1, math.floor(dis / safeAreaPfxWight) do
	        	local tempX, tempY = GetPosByDis(point1, dir, j * safeAreaPfxWight)
	        	local tempZ = self.objSceneMap:getSceneHeight(tempX, tempY)
	        	self.objSceneMap:PlayerPfx(10025, _Vector3.new(tempX, tempY, tempZ))
	        end
	    end
    end
end

function CPlayerMap:ClearSafeAreaLine()
	self.objSceneMap:StopPfx(10025)
end

function CPlayerMap:IsMainCity()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].type == 2 then
		return true
	end
	return false
end

function CPlayerMap:IsFieldMap()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	if t_map[mapId].type == 1 then
		return true
	end
	if t_map[mapId].type == 14 then
		return true
	end
	return false
end

function CPlayerMap:SetCamera(questId)
	do return end
	local quest = t_quest[questId]
	if quest then
		local useBornCamera = quest.useBornCamera
		if useBornCamera == 1 then
			local subVec = _Vector3.new()
			subVec.x = -62 subVec.y = -108 subVec.z = 86
			local mEye = _Vector3.add(_rd.camera.look, subVec)
			_rd.camera.eye = mEye
			CPlayerMap.useBornCamera = true
		end
	end
end

function CPlayerMap:IsCanCastLingzhen()
	local mapId = self:GetCurMapID()
	if not t_map[mapId] then
		return false
	end
	local lingzhen = t_map[mapId].lingzhen
	if lingzhen and lingzhen == 1 then
		return true
	end
	return false
end

function CPlayerMap:PlayEffectLight(param)
	if not param then
		return;
	end;
	
	if not self.EffectLight then
		self.EffectLight = _PointLight.new();
	end;
	
	Tween:KillOfByTarget(self.EffectLight);
	
	if param.state == 1 then
		self.EffectLight.power = 0.1;
		self.EffectLight.range = 0;
		self.EffectLight.color = param.color;
		if self.objMainPlayer then
			local pos = self.objMainPlayer:GetPos();
			local faceto = self.objMainPlayer:GetDirValue()
			local x, y = GetPosByDis(pos, faceto, param.distance);
			pos.x = x;
			pos.y = y;
			pos.z = pos.z + 40;
			self.EffectLight.position = pos;
			if self.facePointLight then
				self.facePointLight.power = 0;
			end
			if self.objPointLight then
				self.objPointLight.power = 0;
			end
        end
	end;
	self.EffectLight._target = 'EffectLight';
	Tween:To(self.EffectLight,param.time/1000,param,{onComplete = function()
			if param.state == 0 then
				self.EffectLight.power = 0;
				self.EffectLight.range = 0;
				self.EffectLight.color = nil;
				
				local light = Light.GetEntityLight(enEntType.eEntType_Player,self.currMapId);
				if self.facePointLight then
					self.facePointLight.power = light.facelight.power;
				end
				
				if self.objPointLight then
					self.objPointLight.power = light.pointlight.power;
				end
			end;
		end;
	},true);
	
end;

function CPlayerMap:PlayEffectBlur(param)
	if not param then
		return;
	end
	
	if self.objMainPlayer then
		local pos = self.objMainPlayer:GetPos();
		local v = _Vector2.new();
		_rd:projectPoint(pos.x,pos.y,pos.z,v);
		if _rd.screenBlender ~= nil then   ---修改：侯旭东 
			_rd.screenBlender:radialblur(v.x, v.y-100, param.radius, param.offset,true, param.time);
			_rd.screenBlender.playMode = _Blender.PlayOnlyOnce;
		end
	end
	
end

function CPlayerMap:InitGimmick()
	self:ClearGimmick();
	if not t_jiguan then
		return;
	end
	self.gimmicks = {};
	local markers = self.objSceneMap:GetMarkers();
	for index,config in pairs(t_jiguan) do
		if config.map == self.currMapId then
			local info = {};
			info.id = config.id;
			info.config = config;
			if config.range ~= '' then
				local points = GetCommaTable(config.range);
				if #points == 3 then
					info.isrect = false;
					info.radius = info.points[3];
					info.points = _Vector3.new(points[1],points[2],0);
				else
					info.points ={}
					table.push(info.points,_Vector3.new(points[1],points[2],0));
					table.push(info.points,_Vector3.new(points[3],points[4],0));
					info.isrect = true;
				end
			end
			
			info.activeTime = 0;
			info.active = false;
			info.toserver = config.server;
			info.tryOpen = false;
			info.activedTime = 0;
			info.one = false;
			info.flag = info.config.air_wall_status == 0 and true or false;
			self.objSceneMap:SwitchAirWall(info.config.air_wall,info.flag);
			
			local cameras = GetPoundTable(config.camera);
			if cameras and #cameras>0 then
				info.cameras = {};
				for i,camera in ipairs(cameras) do
					local cis = GetColonTable(camera);
					local ci = {};
					ci.camera = cis[1];
					ci.time = toint(cis[2]);
					table.push(info.cameras,ci);
				end
			end
			
			if markers then
				local effects = GetPoundTable(config.effect);
				if effects and #effects>0 then
					info.effects = {};
					for j,effect in ipairs(effects) do
						local eis = GetVerticalTable(effect);
						local ei = {};
						ei.name = eis[1];
						ei.marker = markers[eis[2]];
						ei.open = eis[3] == 'true' and true or false;
						table.push(info.effects,ei);
					end
				end
			end
			
			table.push(self.gimmicks,info);
		end
	end
	
end

function CPlayerMap:PlayInSceneSan()
	if not self.gimmicks or #self.gimmicks<1 then
		return;
	end
	
	for i,gimmick in ipairs(self.gimmicks) do
		if gimmick.config.type == 1 then
			if gimmick.effects then
				for index,effect in ipairs(gimmick.effects) do
					if effect.open then
						local pfxMat =_Matrix3D.new():setRotation(effect.marker.rot.x, effect.marker.rot.y, effect.marker.rot.z, effect.marker.rot.r);
						pfxMat:mulTranslationRight(effect.marker.pos.x, effect.marker.pos.y, effect.marker.pos.z);
						self.objSceneMap:PlayerPfxByMat(effect.marker.name,effect.name, pfxMat);
					else
						self.objSceneMap:StopPfxByName(effect.marker.name);
					end
				end
			end
			self.objSceneMap:PlayTaskAnima(gimmick.config.mesh,gimmick.config.mesh_san,nil,false,true);
			if gimmick.cameras then
				if self:PlayCameraGra(gimmick.cameras) then
					break;
				end
			end
		end
	end
end

function CPlayerMap:PlayCameraGra(cameras)
	if not cameras or #cameras<1 then
		return;
	end
	
	local player = MainPlayerController:GetPlayer();
	local avatar = nil; 
	if player then
		avatar = player:GetAvatar();
	end
	if avatar then
		CControlBase:SetControlDisable(true);
		avatar:DisableCameraFollow();
	end
	
	local lookCircle = {};
	local eyeCircle = {};
	local dc = _rd.camera;
	local endTime = 0;
	table.push(lookCircle,{time=0,x = dc.look.x, y = dc.look.y, z = dc.look.z});
	table.push(eyeCircle,{time=0,x = dc.eye.x, y = dc.eye.y, z = dc.eye.z});
	for i,camera in ipairs(cameras) do
		local sc = self.objSceneMap.objScene.graData:getCamera(camera.camera);
		table.push(lookCircle,{time=camera.time,x = sc.look.x, y = sc.look.y, z = sc.look.z});
		table.push(eyeCircle,{time=camera.time,x = sc.eye.x, y = sc.eye.y, z = sc.eye.z});
		endTime = camera.time;
	end
	endTime = endTime + 1000;
	table.push(lookCircle,{time=endTime,x = dc.look.x, y = dc.look.y, z = dc.look.z});
	table.push(eyeCircle,{time=endTime,x = dc.eye.x, y = dc.eye.y, z = dc.eye.z});

	CameraControl.circleCamera:SetFov(dc.fov);
	CameraControl.circleCamera:SetLook(dc.look.x, dc.look.y, dc.look.z);
	CameraControl:RecordCamera();
	CameraControl:SetLookCircle(lookCircle);
	CameraControl:SetEyeCircle(eyeCircle);
	CameraControl:PlayCamera(true,false,function()
								avatar:SetCameraFollow();
								CControlBase:SetControlDisable(false);
								CameraControl:Clear();
							end);
	
	return true;
end

function CPlayerMap:ClearGimmick()
	self.gimmicks = nil;
end

function CPlayerMap:CheckGimmick(interval)
	if not self.gimmicks then
		return;
	end
	
	for index,info in ipairs(self.gimmicks) do
		if info.config.type ~= 1 then
			if not info.one then
				if info.tryOpen then
					if info.serverOpen then
						info.activedTime = info.activedTime + interval;
						if info.activedTime>= info.config.delay_time then
							self.objSceneMap:SwitchAirWall(info.config.air_wall,info.flag);
							info.tryOpen = false;
							info.serverOpen = false;
							info.one = info.config.loop_jiguan == false;
						end
					end
				else
					local inrange = false;
					local pos = MainPlayerController:GetPlayer():GetPos();
					if info.points then
						if info.isrect then
							if ((info.points[1].x > pos.x and info.points[2].x < pos.x) or (info.points[1].x < pos.x and info.points[2].x > pos.x)) and 
													((info.points[1].y > pos.y and info.points[2].y < pos.y) or (info.points[1].y < pos.y and info.points[2].y > pos.y)) then
								inrange = true;
							end
						else
							info.points.z = pos.z;
							local dis = GetDistanceTwoPoint(pos, info.points);
							if dis<info.radius then
								inrange = true;
							end
						end
					end
					
					if inrange then
						if info.active then
							info.activeTime = info.activeTime + interval;
							if info.activeTime>=info.config.stay_time then
								info.tryOpen = true;
								if info.toserver then
									local msg = ReqTriggerObjMsg:new();
									msg.jiguan  = info.id;
									MsgManager:Send(msg);
								else
									self:PlayGimmick(info);
								end
							end
						else
							info.active = inrange;
						end
						local temp = self.gimmicks[1];
						self.gimmicks[1] = info;
						self.gimmicks[index] = temp;
						break;
					else
						info.active = inrange;
						info.activeTime = 0;
						info.tryOpen = false;
						info.activedTime = 0;
					end
					
				end
			end
		end
	end
	
end

function CPlayerMap:PlayGimmick(gimmick)
	if not self.objSceneMap then
		return;
	end
	
	gimmick.one = gimmick.config.loop_jiguan == false;
	gimmick.tryOpen = true;
	
	if gimmick.config.voice and gimmick.config.voice > 0 then
		SoundManager:PlaySkillSfx(gimmick.config.voice);
	end
	
	if gimmick.effects then
		for index,effect in ipairs(gimmick.effects) do
			if effect.open then
				local pfxMat =_Matrix3D.new():setRotation(effect.marker.rot.x, effect.marker.rot.y, effect.marker.rot.z, effect.marker.rot.r);
				pfxMat:mulTranslationRight(effect.marker.pos.x, effect.marker.pos.y, effect.marker.pos.z);
				self.objSceneMap:PlayerPfxByMat(effect.marker.name,effect.name, pfxMat);
			else
				self.objSceneMap:StopPfxByName(effect.marker.name);
			end
		end
	end
	
	self:PlayCameraGra(gimmick.cameras);
	self.objSceneMap:PlayTaskAnima(gimmick.config.mesh,gimmick.config.mesh_san,function()
		gimmick.active = false;
		gimmick.tryOpen = false;
		gimmick.activedTime = 0;
		gimmick.activeTime = 0;
	end,
	gimmick.config.loop,true);
	
end

function CPlayerMap:GimmickReset(id)
	if not self.gimmicks then
		return;
	end
	
	for i,gimmick in ipairs(self.gimmicks) do
		if gimmick.id == id then
			gimmick.active = false;
			gimmick.tryOpen = false;
			gimmick.activedTime = 0;
			gimmick.activeTime = 0;
			gimmick.serverOpen = false;
			gimmick.one = false;
			break;
		end
	end
	
end

function CPlayerMap:PlayGimmickById(id,flag)
	if not self.gimmicks then
		return;
	end
	
	for i,gimmick in ipairs(self.gimmicks) do
		if gimmick.id == id then
			gimmick.serverOpen = gimmick.config.air_wall ~='' and true or false;
			gimmick.flag = flag;
			if gimmick.config.voice and gimmick.config.voice > 0 then
				SoundManager:PlaySkillSfx(gimmick.config.voice);
			end
			
			if gimmick.effects then
				for index,effect in ipairs(gimmick.effects) do
					if effect.open then
						local pfxMat =_Matrix3D.new():setRotation(effect.marker.rot.x, effect.marker.rot.y, effect.marker.rot.z, effect.marker.rot.r);
						pfxMat:mulTranslationRight(effect.marker.pos.x, effect.marker.pos.y, effect.marker.pos.z);
						self.objSceneMap:PlayerPfxByMat(effect.marker.name,effect.name, pfxMat);
					else
						self.objSceneMap:StopPfxByName(effect.marker.name);
					end
				end
			end
			
			self:PlayCameraGra(gimmick.cameras);
			
			self.objSceneMap:PlayTaskAnima(gimmick.config.mesh,gimmick.config.mesh_san,function()
				gimmick.active = false;
				gimmick.activedTime = 0;
				gimmick.activeTime = 0;
			end,
			gimmick.config.loop,true);
			return gimmick.serverOpen;
		end
	end
end

CPlayerMap.useEquipAct = false;
function CPlayerMap:SetPlayerEquipActState(state)
	self.useEquipAct = state;
	for i,Player in pairs(self.setAllPlayer) do
		Player:SetEquipsActState(state);
	end
end

function CPlayerMap:EngineUpdate(e)
	if self.objSceneMap then
		self.objSceneMap:EngineUpdate(e);
	end
end

CPlayerMap.usedFieldEffect = true;
CPlayerMap.usedFieldShadow = true;
function CPlayerMap:FieldChange(pos)
	self:FieldToEffect(pos);
	self:FieldToShadow(pos);
end

function CPlayerMap:SetUseFieldEffect(used,erase)
	self.usedFieldEffect = used;
	if used then
		self:FieldToEffect(self.objMainPlayer:GetPos());
	else
		if not erase then
			if self.objSceneMap.effects then
				local effects = self.objSceneMap.effects;
				for i,effect in ipairs(effects) do
					self.objSceneMap:PlayerPfxByMat(effect.logicname,effect.name,effect.transform);
					effect.playing = true;
				end
			end
		end
	end
end

function CPlayerMap:FieldToEffect(pos)
	if not pos or not self.usedFieldEffect then
		return;
	end
	
	if self.objSceneMap.effects then
		local effects = self.objSceneMap.effects;
		for i,effect in ipairs(effects) do
			local ep = effect.pos;
			local dis = GetDistanceTwoPoint(pos,ep);
			local full = dis<=effect.range;
			if full then
				if not effect.playing then
					self.objSceneMap:PlayerPfxByMat(effect.logicname,effect.name,effect.transform);
					effect.playing = true;
				end
			else
				if effect.playing then
					self.objSceneMap:RemoveParticle(effect.logicname);
					effect.playing = false;
				end
			end
		end
	end	
end

function CPlayerMap:SetUseFieldShadow(used,erase)
	self.usedFieldShadow = used;
	if used then
		self:FieldToShadow(self.objMainPlayer:GetPos());
	else
		if not erase then
			if self.objSceneMap.shadows then
				local shadows = self.objSceneMap.shadows;
				for i,shadow in pairs(shadows) do
					shadow.node.logicShadow = true;
					shadow.using = true;
				end
			end	
		end
	end
end

function CPlayerMap:FieldToShadow(pos)
	if not pos or not self.usedFieldShadow then
		return;
	end
	
	if self.objSceneMap.shadows then
		local shadows = self.objSceneMap.shadows;
		for i,shadow in pairs(shadows) do
			local sp = shadow.pos;
			local dis = GetDistanceTwoPoint(pos,sp);
			local full = dis<=shadow.range;
			shadow.node.logicShadow = full;
			shadow.using = full;
		end
	end	
end