	--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/6/20
-- Time: 17:33
--功能说明：玩家自身Avatar的控制,摄像机的控制，地图、模型的Pick控制
_G.classlist['CPlayerControl'] = 'CPlayerControl'
_G.CPlayerControl = CControlBase:new(false);
CPlayerControl.objName = 'CPlayerControl'
CPlayerControl.setKeyFunc = {};
CPlayerControl.setMouseWheelInfo = {};
CPlayerControl.setCameraZPosInfo = {};
CPlayerControl.listDelta = 0;
CPlayerControl.cameratime = 0
CPlayerControl.totalcameratime = 1000
CPlayerControl.tempV3dis = _Vector3.new()
CPlayerControl.tempV3neweye = _Vector3.new()
CPlayerControl.showName = true

CPlayerControl.bDrawPath = false;
CPlayerControl.AreaRect = false;
CPlayerControl.dwPathHight = 10;
CPlayerControl.gMousex = 0;
CPlayerControl.gMousey = 0;
--pick管理
CPlayerControl.objMoveNode = nil;
CPlayerControl.setPickListen = {}

CPlayerControl.funCallBack = nil
CPlayerControl.isMouseDownMonster = false; --标记玩家是否点击了怪物,如果点击了怪物，那么不再执行FollowMouseMove
function CPlayerControl:ClearFunMoveEndCallBack()
	self.funCallBack = nil
end

--添加一个pick监听
function CPlayerControl:AddPickListen(objListen)
	table.insert(self.setPickListen,objListen);
end;


--删除一个pick监听
function CPlayerControl:RemovePickListen(objListen)
	for i , obj in pairs(self.setPickListen) do
		if obj == objListen then
			table.remove(self.setPickListen,i);
			self.setPickListen[i] = nil;
		end;
	end;
end;

function CPlayerControl:OnActive(bIsActive)
	if not bIsActive then
		self.vecDistance.x = 0;
		self.vecDistance.y = 0;
	end;
end;

function CPlayerControl:OnMouseMove(nXPos,nYPos)
    if _G.isDebug or ToolsController.cameraFree or ToolsController.sceneFree then
		if _sys:isKeyDown(_System.MouseMiddle) then
			if (_G.IsCameraToolsShow or ToolsController.sceneFree) and not _sys:isKeyDown(_System.KeyAlt) then
				local dir = _Vector3.sub(_rd.camera.look, _rd.camera.eye)
				local vx = _Vector3.cross(dir,  _rd.camera.up):normalize()
				local vy = _Vector3.cross(dir, vx):normalize()
				local nearx = _Vector3.mul(vx, -(self.gMousex - nXPos) * 0.001)
				local neary = _Vector3.mul(vy,  (self.gMousey - nYPos) * 0.001)
				local movex = _Vector3.mul(nearx, dir:magnitude() / _rd.camera.viewNear)
				local movey = _Vector3.mul(neary, dir:magnitude() / _rd.camera.viewNear)
				local move = _Vector3.add(movex , movey)
				_rd.camera:moveEye(_rd.camera.eye.x + move.x, _rd.camera.eye.y + move.y, _rd.camera.eye.z + move.z)
				_rd.camera:moveLook(_rd.camera.look.x + move.x, _rd.camera.look.y + move.y, _rd.camera.look.z + move.z)
				self.gMousex = nXPos; self.gMousey = nYPos;
			else
				if GameController.currentState == enNormalUpdate and _sys:isKeyDown(_System.KeyAlt) and (_G.IsCameraToolsShow or ToolsController.cameraFree) then
					local diffx =  (nXPos -self.gMousex) / 200;
					_rd.camera:movePhi(diffx);

					local diffy =  (nYPos -self.gMousey) / 200;
					_rd.camera:moveTheta(diffy);
				end
			end
		end
		self.gMousex = nXPos; self.gMousey = nYPos;
	end

    if not CPlayerMap:GetSceneMap() then
		return;
	end;
	
	local ray = _rd:buildRay( nXPos,nYPos);
	if not ray then
		return;
	end;
	local picked = CPlayerMap:GetSceneMap():DoRayQuery(ray);
	if ( not picked or not picked.node ) then
		CPlayerControl:OnMouseOut()
		return
	end
	if CPlayerControl.objMoveNode ~= picked.node then
		CPlayerControl:OnMouseOut()
		CPlayerControl:OnMouseOver(picked.node)
	end
end

function CPlayerControl:OnMouseOver(node)
	CPlayerControl.objMoveNode = node
	for i , Listenr in pairs(self.setPickListen) do
		if Listenr.bCanUse and Listenr.OnRollOver then
			Listenr:OnRollOver(CPlayerControl.objMoveNode.dwType, CPlayerControl.objMoveNode.entity)
		end
	end
end

function CPlayerControl:OnMouseOut()
	if CPlayerControl.objMoveNode then
		for i ,Listenr in pairs(self.setPickListen) do
			if Listenr.bCanUse and Listenr.OnRollOut then
				Listenr:OnRollOut(CPlayerControl.objMoveNode.dwType,CPlayerControl.objMoveNode.entity)
			end
		end
		CPlayerControl.objMoveNode = nil
	end
end

local pos = _Vector3.new()
function CPlayerControl:OnMouseDown(nButton,nXPos,nYPos)
	self.moveTime = GetCurTime();
	self.moveEnable = false;

	if SkillController.lingzhenState then
		if nButton == 0 then
			SkillController:TryUseLingzhen()
		else
			SkillController:InterruptLingzhen()
		end
		return
	end
	if MainPlayerController:TryBreakAutoRun(nButton,nXPos,nYPos) then
		return;
	end
	
    if GameController.currentState == nil then return end
    MainPlayerController.laseOpTime = GetCurTime()
	--如果目标点不能走
	local picked = CPlayerMap:GetSceneMap():DoEntityPick( nXPos, nYPos)
    if( picked ) then
		if not picked.node or not picked.node.entity then
            Debug("pick: 2")
            return ;
		end;

		--如果点击的是场景中的怪物，那么做个标记
		if picked.node.dwType == enEntType.eEntType_Monster then
			self.isMouseDownMonster = true;
		else
			self.isMouseDownMonster = false;
		end

		for i ,Listenr in pairs(self.setPickListen) do 
			if Listenr.bCanUse and Listenr.OnBtnPick then
			   Listenr:OnBtnPick(nButton,picked.node.dwType,picked.node.entity);
			end;
		end;
	else
		self.isMouseDownMonster = false;

    	if nButton == 0 then
			CPlayerControl:MoveToPos(nXPos,nYPos);
		elseif nButton == 1 then
			AutoBattleController:DoNormalAttack(nButton)
		end
	end
end;

function CPlayerControl:MoveToPos(xpos,ypos)
	local picked = CPlayerMap:GetSceneMap():DoPick( xpos, ypos )
	if picked then
		--播放特效，鼠标点地特效
		pos.x,pos.y,pos.z = picked.x, picked.y, picked.z+0.5
		
		local vecSrc = MainPlayerController:GetPlayer():GetPos()
		local lstPathLine, bFindRes = AreaPathFinder:GetPathLine(vecSrc, pos)
		if lstPathLine then
			--打断自动施法
			AutoBattleController:InterruptAutoBattle()
			self:AutoRun(picked,nil,lstPathLine)
		end

		if bFindRes then
			CPlayerMap:GetSceneMap():PlayerPfx(90001, pos)
		else
			CPlayerMap:GetSceneMap():PlayerPfx(90002, pos)
		end
		--打断任务引导
		QuestGuideManager:BreakGuide();
		MainPlayerController:ResetAutoSitTime();
	end
end
 
function CPlayerControl:OnMouseUp(nButton,nXPos,nYPos)
	if nButton == 0 then
		self.moveEnable = false;
		self.moveTime = 5e+20;
	end
end;
 
function CPlayerControl:OnMouseDbclick(nXPos,nYPos) 

end;

function CPlayerControl:OnMouseWheel(fDelta)
    --_rd.camera:moveRadius(fDelta * -0.1 * _rd.camera.radius)
	if _G.isDebug and _G.IsCameraToolsShow or ToolsController.cameraFree then
		_rd.camera:moveRadius(fDelta * -0.1 * _rd.camera.radius)
		return
	end
	if StoryController:IsStoryCamera() then return end
	if CameraControl:IsPlaying() then return end
	if CPlayerMap:GetCurMapID() == 10400025 then return end
	if CPlayerMap.useBornCamera then return end
	
	
	if fDelta > 0 then
		if self.listDelta ~= 1 then
			self.setMouseWheelInfo = {};
			self.listDelta = 1;
		end;
		for i = 1 , 10 do
		    table.insert(self.setMouseWheelInfo, RenderConfig.fWheelSpeed);
		end;
	else
		if self.listDelta ~= -1 then
			self.setMouseWheelInfo = {};
			self.listDelta = -1;
		end;
		for i = 1 , 10 do
		    table.insert(self.setMouseWheelInfo, -RenderConfig.fWheelSpeed);
		end;
	end;
	
end;

function CPlayerControl:RegKeyEvent(dwKey,funProc,obj)
	local KeyObj = {dwKey= dwKey,funProc = funProc,obj =obj};
	table.insert(self.setKeyFunc,KeyObj);
end;
local num = 0
function CPlayerControl:OnKeyDown(dwKeyCode)
	
	--
	if not _G.isDebug then
		return
	end

	if dwKeyCode == _System.KeyL then
		-- print('############# full gc..')
		-- _gc();
		sysMonitor()
		_debug.monitor = not _debug.monitor
		--return;
		--_G.QizhanState = not _G.QizhanState -- for test 
	end
	
    if dwKeyCode == _System.KeyTab then
		_debug.monitor = not _debug.monitor
		LuaGC()
		--_debug:throwException("xxxxxxxxxxxxxx")
    elseif dwKeyCode == _System.KeyA then
        --_sys.asyncLoad = not _sys.asyncLoad
		RenderConfig.batch = not RenderConfig.batch
		Debug("RenderConfig.batch = ", RenderConfig.batch)
	elseif dwKeyCode == _System.KeyH then
    	--CharController:HidePlayerAndMonster()
		--_app.speed = 0.5
		--self:ChangeCameraDist(0)
		-- local subVec = self.senSubVec; 
		-- Debug("###senSubVec:", subVec.x, subVec.y, subVec.z)
		-- Debug("###cameraSubVec: ",  _rd.camera.eye.x - _rd.camera.look.x, 
		-- 							_rd.camera.eye.y - _rd.camera.look.y, 
		-- 							_rd.camera.eye.z - _rd.camera.look.z)
		--_G.lightShadowQuality = 1;
		local pos = MainPlayerController:GetPlayer():GetPos()
		print("curr pos x, y : ", pos.x, pos.y)
	elseif dwKeyCode == _System.KeyS then
    	--CharController:ShowPlayerAndMonster()
		--_sys.fpsLimit = 20
		--_rd.glowFactor = 0;
		--_G.lightShadowQuality = 2;
		--MainPlayerController:MakeViewGray(true, 500)
		_sys.showStat = not _sys.showStat
	elseif dwKeyCode == _System.KeyG then
		_gc();
		--ConnManager:close()
		--_sys.fpsLimit = 60
		-- _sys.pausePfx = not _sys.pausePfx
		--_rd.glowFactor = 0.3;
		--_G.lightShadowQuality = 3;
		--local avatar = MainPlayerController:GetPlayer():GetAvatar()
		--avatar:SetScale(1.2)
		--MainPlayerController:MakeViewGray(false)

	elseif dwKeyCode == _System.KeyJ then
		_debug:logAlloc( 1 )
  --   	--MonsterController:AddMonster100()
		-- CMemoryDebug:Show("Monster")
		-- CMemoryDebug:Show("Message")
		-- CMemoryDebug:Show("FlyVO")
		-- CMemoryDebug:Show("UIFlyLoader")
		-- CMemoryDebug:Show("EffectLoader")
		-- CMemoryDebug:Show("DropItem")
		-- CMemoryDebug:Show("DropItemAvatar")
		-- CMemoryDebug:Show("MonsterAvatar")
		-- CMemoryDebug:Show("Entity")
		-- CMemoryDebug:Show("CAvatar")

		-- _gc()
		--print('CMemoryDebug:Show obj')
		--CMemoryDebug:Show('attackMonster', true)
		--CMemoryDebug:Show('CPlayer.objAvatar', true)
		--CMemoryDebug:Show('Monster', true)
		--_G.hdMode = not _G.hdMode
		--local avatar = MainPlayerController:GetPlayer():GetAvatar()
		--avatar:SetScale(1)
		--_G.NOT_NET_RECEIVE = false
		--print("set NOT_NET_RECEIVE = false")
    elseif dwKeyCode == _System.KeyK then
		_debug:logAlloc( 0 )
    	--MonsterController:DeleteMonster100()
    	-- _gc()
		--[[
		local p = MainPlayerController:GetPlayer():GetPos();
		local me = MainPlayerController:GetPlayer():GetAvatar();
		Debug('########### test npc ', p.x, p.y, p.z);
		local avt = CAvatar:new()
		avt:ChangeSkl('linjing.skl')
		avt:SetPart('body', 'linjing.skn')
		avt.szIdleAction = 'linjing_jianzhuzi.san';
		avt:ExecIdleAction()
		avt:EnterSceneMap(me.objSceneMap, p, 0)
		avt.objNode.dwType = enEntType.eEntType_Npc;
		--]]
    elseif dwKeyCode == _System.KeyN then
    	--MonsterController:AddMonster200()
		
		---- for i=1,100 do
		-- 	local playerAvatar = CPlayerAvatar:new();
		-- 	playerAvatar:Create( 0, 2 );
		-- 	playerAvatar:SetProf(2);
		-- 	playerAvatar:SetDress(220010002);
		-- 	playerAvatar:SetArms(220011000);
		
		-- 	playerAvatar:ExitMap()
		-- 	playerAvatar = nil;
		-- end
  --   	_gc()
    elseif dwKeyCode == _System.KeyM then
    	--MonsterController:DeleteMonster200()
		--_rd.miniPolygonOnly = not _rd.miniPolygonOnly
		num = num + 1
		if RenderConfig.isDebugDrawBoard then
		  RenderConfig.screenDB:saveToFile('bg' .. num .. '.png', 1)			
		end
    elseif dwKeyCode == _System.KeyL then
        CPlayerMap.objSceneMap:SwitchAirWall("block001", false)
    elseif dwKeyCode == _System.KeyP then
    	 _sys.showPfx = not _sys.showPfx
        --CPlayerMap.objSceneMap.objPathFinder:enableGroup('block002', false)
	elseif dwKeyCode == _System.KeyO then
		local objScene = CPlayerMap.objSceneMap.objScene;
		objScene.logicNode.visible = not objScene.logicNode.visible;
		
				
	
	
	elseif dwKeyCode == _System.KeyT then
		RenderConfig.show9Tile = not RenderConfig.show9Tile
		if RenderConfig.show9Tile then
			CPlayerMap.objSceneMap:BuildTiles()
		end
	end
	if _sys:isKeyDown(_System.KeyCtrl) then
		if dwKeyCode == _System.Key0 then
			-- StoryController:StoryStartMsg(toint(TestStoryConfig['storyId']))
        elseif dwKeyCode == _System.Key0 + 1 then
            -- Debug("ResetCameraPos: ")
            -- local roleAvatar =  MainPlayerController:GetPlayer():GetAvatar()
            -- roleAvatar.Control = self;
            -- self:ResetCameraPos(1000)
		--	UILingzhenShowView:Show()
        elseif dwKeyCode == _System.Key0 + 9 then
			self.bDrawPath = not self.bDrawPath;
			Debug("self.bDrawPath",self.bDrawPath);
		elseif dwKeyCode == _System.Key0 + 8 then
			CPlayerControl.AreaRect = not CPlayerControl.AreaRect
            -- RenderConfig.pfxSkl.pfxPlayer:play("zudui_yiwancheng.pfx", "zudui_yiwancheng.pfx")
            -- RenderConfig.isDebugDrawBoard = not RenderConfig.isDebugDrawBoard;
        elseif dwKeyCode == _System.Key0 + 3 then
            _G.drawAxis = not _G.drawAxis
            _G.drawMeshBBox = not _G.drawMeshBBox
            _G.drawBone = not _G.drawBone
		elseif dwKeyCode == _System.KeyF then
            UIZhanshouShowView:OpenPanel();
        end

	end;

    for i,KeyObj in pairs(self.setKeyFunc) do
		if KeyObj and dwKeyCode == KeyObj.dwKey then
			KeyObj.funProc(KeyObj.obj,dwKeyCode);
			return;
		end;
	end;

    if  CControlBase.oldKey[_System.KeyCtrl] then
		if dwKeyCode == _System.KeyTab then
			_debug.downloadMonitor = not _debug.downloadMonitor
			return;
		end
		if dwKeyCode == _System.KeyX then
			if _app.speed == 1 then
				_app.speed = 6;
				FloatManager:AddCenter("进入加速模式,预计Bug未知~~~~~~");
			else
				_app.speed = 1;
				FloatManager:AddCenter("退出加速模式");
			end
			return;
		end
	
        if _sys:isKeyDown(_System.KeyAlt) then
            if dwKeyCode == _System.KeyW then
                _rd.wireframe = not _rd.wireframe
            elseif dwKeyCode == _System.KeyE then
            elseif dwKeyCode == _System.KeyU then
                UIManager:Switch();
            elseif dwKeyCode == _System.Key0 + 2 then
                -- local equipInfo = {roleID = MainPlayerController:GetRoleID(), wear_pos = 0, meshId = 2100010000} --change weapon
                -- MainPlayerController:OnEquipChange(equipInfo)
            elseif dwKeyCode == _System.Key0 + 3 then

            elseif dwKeyCode == _System.Key0 + 4 then
                -- local objScene = CPlayerMap.objSceneMap.objScene;
                -- local nodes = objScene:getNodes()
                -- _app.console:Debug('#Nodes ' .. #nodes)
            elseif dwKeyCode == _System.Key0 + 5 then
				
				
            elseif dwKeyCode == _System.Key0 + 6 then
            elseif dwKeyCode == _System.Key0 + 7 then
                -- local pos = MainPlayerController:GetPlayer():GetPos()

                -- Debug("pos: ", pos.x, pos.y, pos.z)
            elseif dwKeyCode == _System.Key0 + 8 then
                -- local roleAvatar =  MainPlayerController:GetPlayer():GetAvatar()
                -- roleAvatar:PlayerPfx(10005)
            elseif dwKeyCode == _System.Key0 + 9 then

				Debug("####################SSSS")
				local roleAvatar =  MainPlayerController:GetPlayer():GetAvatar()
				Debug("skl: ",  roleAvatar.objSkeleton.resname)
				local sans = roleAvatar.objSkeleton:getAnimas()
                for i, v in ipairs(sans) do
                     Debug("san: ", v.resname, v.loop, v.pause, v.current, v.isPlaying)
                end

                local horseAvatar = roleAvatar.horse;
				if horseAvatar then
                    local sans = horseAvatar.objSkeleton:getAnimas()
                    for i, v in ipairs(sans) do
                        Debug("san: ", v.resname, v.loop, v.pause, v.current, v.isPlaying)
                    end
				end

				Debug("Face: ", roleAvatar.objMesh:getFaceCount())
				Debug("Vertex: ", roleAvatar.objMesh:getVertexCount())
            elseif dwKeyCode == _System.KeyB then
				RenderConfig.showWall = true
				local subVec = _Vector3.sub(_rd.camera.eye, _rd.camera.look)
				Debug("MainCamera subVec: ",subVec.x, subVec.y, subVec.z)
				local objScene = CPlayerMap.objSceneMap.objScene;
				local graData = _GraphicsData.new();
				local camera = _Camera.new()
				camera.name = "MainPlayerCamera"
				camera.eye = _rd.camera.eye
				camera.look = _rd.camera.look;
				graData:addCamera(camera);
				graData:save("resfile\\gra\\mainplayer.gra")
				
				local rootTransform = objScene.terrainNode.transform
				local tran = rootTransform:getTranslation()
				local rot = rootTransform:getRotation()
				local dir = rot.r
				
				local tempCamEye = _Vector2.new()
				tempCamEye.x = _rd.camera.eye.x
				tempCamEye.y = _rd.camera.eye.y

				local tempCamLook = _Vector2.new()
				tempCamLook.x = _rd.camera.look.x
				tempCamLook.y = _rd.camera.look.y
				local tempCamTowar = _Vector2.new()
				_Vector2.sub(tempCamLook, tempCamEye, tempCamTowar)
				tempCamTowar:normalize()
				local angle = math.deg(math.acos(tempCamTowar.y * (-1) / tempCamTowar:magnitude()))
				if tempCamTowar.x < 0 then
					angle = 360 - angle
				end
					
				
				Debug("0 root trans:  ", tran.x, tran.y, tran.z)
				Debug('0 rot: ', dir)
				Debug('0 camera rot: ', angle)	
				
				StoryController.isZoomPlaying = true
				self.bDrawPath = true
				local h = CPlayerMap.objSceneMap:getSceneHeight(0,0)
				camera.eye.x = 1
				camera.eye.y = 0
				camera.eye.z = h + 4000
				camera.look.x = 0
				camera.look.y = 0
				camera.look.z = h
				
				_rd.camera = camera
				
				local rootTransform = objScene.terrainNode.transform
				local tran = rootTransform:getTranslation()
				local rot = rootTransform:getRotation()
				local dir = rot.r
				if rot.z < 0 then
					dir = 2 * math.pi - dir
				end
				Debug("root trans:  ", tran.x, tran.y, tran.z)
				Debug('rot: ', dir)
				
				local tempCamEye = _Vector2.new()
				tempCamEye.x = _rd.camera.eye.x
				tempCamEye.y = _rd.camera.eye.y

				local tempCamLook = _Vector2.new()
				tempCamLook.x = _rd.camera.look.x
				tempCamLook.y = _rd.camera.look.y
				local tempCamTowar = _Vector2.new()
				_Vector2.sub(tempCamLook, tempCamEye, tempCamTowar)
				tempCamTowar:normalize()
				local angle = math.deg(math.acos(tempCamTowar.y * (-1) / tempCamTowar:magnitude())) --这么写是以-y方向为起始方向，顺时针为正方向
				if tempCamTowar.x < 0 then
					angle = 360 - angle
				end
				Debug('camera rot: ', angle)	
				
				objScene.skyBox = nil;
			end

        end

    end

	if  CControlBase.oldKey[_System.KeyZ] then
		if dwKeyCode == _System.Key0 +8 then
   --          Debug("cross map nav: ")
   --          MainPlayerController:DoAutoRun(10100001,_Vector3.new(940, -500, 0),
			-- function(param)
			-- 	Debug("complete auto run by",param)
			-- end, 10100001)
        elseif dwKeyCode == _System.Key0 + 9 then
            -- Debug("cross map nav: ")
            -- MainPlayerController:DoAutoRun(10100004,_Vector3.new(565, 148, 0),
            --     function(param)
            --         Debug("complete auto run by",param)
            --     end, 10400001)
		elseif  dwKeyCode == _System.Key0 +0 then
            -- local mountInfo = {roleID = MainPlayerController:GetRoleID(), type=6, newVal = 60100001}
            -- MainPlayerController:OnPlayerShowChange(mountInfo)
            -- local skillId = MainPlayerController:GetNormalAttackSkillId()
            -- SkillController:PlayCastSkill(skillId);
        elseif  dwKeyCode == _System.Key0 +5 then
            -- local mountInfo = {roleID = MainPlayerController:GetRoleID(),type=6, newVal = 0}
            -- MainPlayerController:OnPlayerShowChange(mountInfo)
        elseif dwKeyCode == _System.Key0 + 4 then
            --local value = MainPlayerController:GetPlayer():GetDirValue()
            --Debug("main player dir: ", value)
        elseif dwKeyCode == _System.Key0 + 3 then
            --local p = MainPlayerController:GetPlayer()
            --Debug("p: ", p:GetDirValue())
            --p:SetDirValue(0)
        elseif dwKeyCode == _System.Key0 + 1 then
            --SkillController:TryUseSkill(1001000)
            -- SkillController:SkillCastBegin(MainPlayerController:GetRoleID(), 1001000)
            -- local targetList = MonsterController:GetMonsterByRange(nil, 10)
            -- for _, v in pairs(targetList) do 
            -- 	SkillController:CastEffect(v:GetCid(), nil, 100)
            -- end
        end
	end;


	self:WsadMove(dwKeyCode,true);
end;
 
function CPlayerControl:OnKeyUp(dwKeyCode)
	if not isDebug then
		return;
	end
	self:WsadMove(dwKeyCode,false);
end; 

function CPlayerControl:setPlayerControl()
	local roleAvatar =  MainPlayerController:GetPlayer():GetAvatar()
	roleAvatar.Control = CPlayerControl;
end


function CPlayerControl:Create()
	CPlayerControl:SetPathList(nil)
	--self.lstPathLine = nil;				--自动寻路连
	self.dwCurLineIndex = 1;
	self.dwLastMoveCameraTime = 0;
	--用来控制位移aswd
	self.vecDistance = _Vector3.new();
	self.vecDistance.x = 0;
	self.vecDistance.y = 0;
	self.vecDistance.z = 0; 
	self.matMoveStart = _Matrix3D.new(); --用来计算位移
	
	--鼠标相关
	self.dwMouseXPos = 0;
	self.dwMouseYPos = 0;  	
	return true;
end;

function CPlayerControl:Update(dwInterval)
	CPlayerControl:UpdateCameraMove(dwInterval);
	CPlayerControl:UpdateCameraDist();
	CPlayerControl:FollowMouseMove();
	
	if self.lstPathLine and self.waitMove then
		local vecSrc = MainPlayerController:GetPlayer():GetPos();
		local vecTarget = self.lstPathLine[self.dwCurLineIndex];
		if vecSrc and vecTarget then
			if self.dwCurLineIndex == #self.lstPathLine then
				if self:ProcMoveTo(vecSrc,vecTarget,CPlayerControl.MoveCamplete, nil, CPlayerControl.dwDis) == 1 then
					self.waitMove = false;
				end
			else
				if self:ProcMoveTo(vecSrc,vecTarget,CPlayerControl.MoveCamplete) == 1 then
					self.waitMove = false;
				end
			end
		end
	end
end;

CPlayerControl.moveEnable = false;
CPlayerControl.moveTime = 5e+20;
function CPlayerControl:FollowMouseMove()
	if not _sys:isKeyDown(_System.MouseLeft) then
		self.moveEnable = false;
		self.moveTime = 5e+20;
		return;
	end
	if not self.moveEnable then
		if _sys:isKeyDown(_System.MouseLeft) then
			local curtime = GetCurTime();
			if curtime - self.moveTime > 400 then
				self.moveEnable = true;
				self.moveTime = 0;				
			end
		end
	end

	if self.isMouseDownMonster then return end

	if self.moveEnable then
		if SkillController.lingzhenState then
			self.moveEnable = false;
			self.moveTime = 5e+20
			return
		end
		if MainPlayerController:TryBreakAutoRun(nButton,nXPos,nYPos) then
			self.moveEnable = false;
			self.moveTime = 5e+20;
			return;
		end
		if GameController.currentState == nil then
			self.moveEnable = false;
			self.moveTime = 5e+20;
			return 
		end
		local curtime = GetCurTime();
		if curtime - self.moveTime > 400 then
			self.moveTime = curtime;
			local pos = _sys:getRelativeMouse();
			CPlayerControl:MoveToPos(pos.x,pos.y);
		end
	end
end

function CPlayerControl:Destroy()
	if CPlayerMap.objMainPlayer then
		self:MoveStop();
		self.isMouseDownMonster = false;
	end;
end;  

function CPlayerControl:UpdateCameraDist()
	if StoryController:IsStoryCamera() then return end
	if CameraControl:IsPlaying() then return end
	
    for i,v in pairs(self.setMouseWheelInfo) do
        self:ChangeCameraDist(v);
        self.setMouseWheelInfo[i] = nil;
        break;
    end;
end;

function CPlayerControl:ChangeCameraDist(Delta)

    --第一步，移动到原点位置
    local distance = _Vector3.sub( _Vector3.new(0, 0, 0), _rd.camera.look)
    _rd.camera.look = _Vector3.new(0, 0, 0)
    _rd.camera.eye = _Vector3.add( _rd.camera.eye, distance)
    
    --旋转向量在xy平面上的投影和x轴的夹角
    local phi = _rd.camera.phi
    _rd.camera:movePhi(-phi)
    _rd.camera.eye.y = 0
    --第二部，计算水平和垂直上的改变（指数函数）
    local x = _rd.camera.eye.x - Delta * 0.8
    local z = RenderConfig.eparam ^ x
	--Debug("x = ", x)
	--Debug("z = ", z)
	local prof = MainPlayerController:GetProfID()
	local minHeight = RenderConfig.cameraMinHeight[prof]
	local maxHeight = CPlayerControl:GetCameraMaxHeight()
	--print("CPlayerControl:GetCameraMaxHeight() ======", maxHeight)
    if z <= minHeight or z > maxHeight then
        self.setMouseWheelInfo = {}
    
		if z <= minHeight then
			_rd.camera:movePhi(phi)
			_rd.camera.look = _Vector3.sub( _Vector3.new(0, 0, 0), distance)
			_rd.camera.eye = _Vector3.sub( _rd.camera.eye, distance)
		end
		
		if z > maxHeight then
			z = maxHeight
			x = math.log(maxHeight, RenderConfig.eparam)
			_rd.camera.eye = _Vector3.new(x, 0, z)
		    _rd.camera:movePhi(phi)
		    _rd.camera.look = _Vector3.sub( _Vector3.new(0,0,0), distance)
		    _rd.camera.eye = _Vector3.sub( _rd.camera.eye, distance )


			--local mePos = MainPlayerController:GetPlayer():GetPos()					
			--local mLook = _Vector3.new(mePos.x, mePos.y, mePos.z + self.dwCameraHeight)
			--CPlayerControl.senSubVec.x = math.log(maxHeight, RenderConfig.eparam)
			--CPlayerControl.senSubVec.y = math.log(maxHeight, RenderConfig.eparam)
			--CPlayerControl.senSubVec.z = maxHeight
			--local mEye = _Vector3.add(mLook, CPlayerControl.senSubVec)
			--_rd.camera.look = mLook
			--_rd.camera.eye = mEye				
		end
		
		--Debug("###camera check ret: ", z, RenderConfig.cameraMinHeight[prof], RenderConfig.cameraMaxHeight)
		--Debug("Reset camera subVec: ", _rd.camera.eye.x - _rd.camera.look.x, 
		--								_rd.camera.eye.y - _rd.camera.look.y, 
		--								_rd.camera.eye.z - _rd.camera.look.z)
									
        return
    end
    if z < RenderConfig.cameraMaxHeight - 20 then
    	CPlayerControl.showName = false
	else
		CPlayerControl.showName = true
	end

    --_rd.camera.fov = _rd.camera.fov - Delta*0.3;

    --设置
    _rd.camera.eye = _Vector3.new(x, 0, z)

    --还原
    _rd.camera:movePhi(phi)
    _rd.camera.look = _Vector3.sub( _Vector3.new(0,0,0), distance)
    _rd.camera.eye = _Vector3.sub( _rd.camera.eye, distance )

end;



--摄像机跟踪主玩家
local dif = _Vector3.new()
local dir = _Vector3.new()
local pos = _Vector3.new()
local qu = _Vector4.new()
function CPlayerControl:UpdateCameraPos(curPos, useBeatPoint)

	--Debug("CPlayerControl:UpdateCameraPos: ")
	if not curPos then
		Debug("why curPos is nil")
		Debug(debug.traceback())
		return
	end

	local lookXunyou = false
	local hunchePos = HuncheController:GetFollowerPos()
	if hunchePos then
		lookXunyou = true
		curPos = hunchePos
	end

	if lookXunyou then
		_rd.camera.look.x = curPos.x
		_rd.camera.look.y = curPos.y
		_rd.camera.look.z = curPos.z
		dif.x = 40
		dif.y = 60
		dif.z = RenderConfig.cameraMaxHeight
		_Vector3.add(_rd.camera.look, dif, _rd.camera.eye)
	else
		_Vector3.sub(_rd.camera.eye, _rd.camera.look, dif)
		_rd.camera.look = curPos
		if not useBeatPoint then
			if self.dwCameraHeight then
				_rd.camera.look.z = curPos.z + self.dwCameraHeight
			else
				_rd.camera.look.z = curPos.z
			end
		end
		_Vector3.add(_rd.camera.look, dif, _rd.camera.eye)
	end

    if CPlayerMap.objSceneMap.objScene then
        _Vector3.sub(curPos, _rd.camera.eye, dir)
        dir = dir:normalize()
		
		local nodes = CPlayerMap.objSceneMap.objScene:getNodes()
		local result = CPlayerMap.objSceneMap.objScene:pick(_rd.camera.eye, dir)
		local picknodes = CPlayerMap.objSceneMap.objScene:getPickedNodes()		
		local mePos = MainPlayerController:GetPlayer():GetPos()
		
		for i,an in ipairs(nodes) do
			if an.mesh and an.name:find("autohide") then
				local old = an.mesh.shielded
				an.mesh.shielded = false
				if picknodes then
					for j,sn in ipairs(picknodes) do
						if an == sn then
							sn.transform:getTranslation(pos)
							if mePos.x < pos.x or mePos.y < pos.y then
								sn.mesh.shielded = true
							end					
						end
					end
				end
				local now = an.mesh.shielded
				if old then
					if now == false then
						an.mesh.alpaFlag = BlenderFlag.FadeOut
					end
				else
					if now then
						an.mesh.alpaFlag = BlenderFlag.FadeIn
					end
				end
			end
		end
		
		picknodes = nil
		nodes = nil
    end
end;

--移动摄像机
--funCallBack:移动完成后的回调函数
function CPlayerControl:MoveCameraPos(vLookPos,vEyePos,dwTime,funCallBack)
	self.vecOldLook = self.vecOldLook or _Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z);  
	self.vecOldEye = self.vecOldEye or _Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z);  

	self.vLookOrbit = self.vLookOrbit or _Orbit.new()
	self.vEyeOrbit = self.vEyeOrbit or _Orbit.new()
	if vLookPos then
		self.vLookOrbit:create({
			{time=0,pos=_Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z)};
			{time=dwTime,pos=vLookPos}
		})
	end
	if vEyePos then
		self.vEyeOrbit:create({
			{time=0,pos=_Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z)};
			{time=dwTime,pos=vEyePos};
		})
	end
	-- if type(funCallBack)=="function" then
		-- CTimer:AddTimer( dwTime, false, funCallBack )
	-- end
	self.funCallBack = funCallBack
	self.bMoving = true
end
--还原摄像机
--funCallBack:移动完成后的回调函数
function CPlayerControl:ResetCameraPos(dwTime,funCallBack)
	--_rd.camera.eye = self.vecOldEye or _rd.camera.eye
	--_rd.camera.look = self.vecOldLook or _rd.camera.look
	self.bMoving = false
	

	if self.vecOldLook then
		_rd.camera:moveLook(self.vecOldLook.x,self.vecOldLook.y,self.vecOldLook.z,dwTime)
	end
	if self.vecOldEye then
		_rd.camera:moveEye(self.vecOldEye.x,self.vecOldEye.y,self.vecOldEye.z,dwTime)
	end
	--]]
	self.vecOldLook = nil
	self.vecOldEye = nil
	if type(funCallBack)=="function" then
		CTimer:AddTimer( dwTime, false, funCallBack )
	end
	--self.funCallBack = funCallBack;
end

function CPlayerControl:ClearOldCamera()
	self.vecOldLook = nil
	self.vecOldEye = nil
end

--设置默认摄像机
function CPlayerControl:ResetCameraOldPos()
	self.bMoving = false
	if self.vecOldLook then
		_rd.camera.look = self.vecOldLook
	end
	if self.vecOldEye then
		_rd.camera.eye = self.vecOldEye
	end
	self.vecOldLook = nil
	self.vecOldEye = nil
end

--直接设置镜头
function CPlayerControl:SetCameraPos(vLookPos,vEyePos)
	-- SpiritsUtil:Trace(vLookPos)
	-- SpiritsUtil:Trace(vEyePos)
	self.bMoving = false

	self.vecOldLook = self.vecOldLook or _Vector3.new(_rd.camera.look.x,_rd.camera.look.y,_rd.camera.look.z);  
	self.vecOldEye = self.vecOldEye or _Vector3.new(_rd.camera.eye.x,_rd.camera.eye.y,_rd.camera.eye.z);  
	
	_rd.camera.eye = vEyePos or _rd.camera.eye
	_rd.camera.look = vLookPos or _rd.camera.look
	
end
function CPlayerControl:UpdateCameraMove(dwInterval)
	if self.bMoving then
		self.vLookOrbit:update(dwInterval)
		self.vEyeOrbit:update(dwInterval)
		if self.vLookOrbit.over~=true then
			_rd.camera.look = self.vLookOrbit.pos
		end
		if self.vEyeOrbit.over~=true then
			_rd.camera.eye = self.vEyeOrbit.pos
		end
		
		if (self.vLookOrbit.over==true) and (self.vEyeOrbit.over) then
			self.bMoving = false
			if type(self.funCallBack)=="function" then
				self.funCallBack();
			end
		end
	
	end
end;

CPlayerControl.WsadMoveFunc = {};
function CPlayerControl:WsadMove(dwKey,bUpOrDown)
    local funcDown = function(bUpOrDown)
		if bUpOrDown then
			return 1;
		else
			return -1;
		end;
	end;
	
	local arrFunc =
	{
		[_System.KeyW] = function(bUpOrDown) self.vecDistance.y = self.vecDistance.y - funcDown(bUpOrDown) end;
		[_System.KeyS] = function(bUpOrDown) self.vecDistance.y = self.vecDistance.y + funcDown(bUpOrDown) end;
		[_System.KeyA] = function(bUpOrDown) self.vecDistance.x = self.vecDistance.x + funcDown(bUpOrDown) end;
		[_System.KeyD] = function(bUpOrDown) self.vecDistance.x = self.vecDistance.x - funcDown(bUpOrDown) end;
	} 
	local func = arrFunc[dwKey];
	if func then
		MainPlayerController:BreakAutoRun();
		func(bUpOrDown ); 
		self:ComputeSpeed();
	end;
end;


function CPlayerControl:EquipVector3() 
	if math.abs( self.vecDistance.x - 0) >= 0.000001 then
		return false;
	end;
	if math.abs( self.vecDistance.y - 0) >= 0.000001 then
		return false;
	end;
	if math.abs( self.vecDistance.z - 0) >= 0.000001 then
		return false;
	end;
	return true; 
end;

function _G.WhenComplete(obj) 
	if not obj.Control then
		return;
	end;
	if obj.Control.vecDistance then
		if obj.Control:EquipVector3()then
			obj.Control:MoveStop();
			return false;
		end;
		obj.Control:MoveStart(obj.Control.vecDistance,WhenComplete);
		return true;
	end;
	return false;
end;

function CPlayerControl:ComputeSpeed()
	if self:EquipVector3()then
        Debug("EquipVector3: MoveStop")
		self:MoveStop();
		return;
	end;
	if  self.vecDistance.y  > 1 then
	     self.vecDistance.y  =1;
	elseif  self.vecDistance.y < -1 then
		self.vecDistance.y  = -1;
	end;
	if  self.vecDistance.x  > 1 then
	     self.vecDistance.x  =1;
	elseif  self.vecDistance.x < -1 then
		self.vecDistance.x  = -1;
	end;
	--Debug("ComputeSpeed:", self.vecDistance.x, self.vecDistance.y)
	self:MoveStart(self.vecDistance,WhenComplete);
end; 

local dir, dis, tar = _Vector3.new(), _Vector3.new(), _Vector3.new();
local oni = _Vector3.new(0,-1,0);
function CPlayerControl:MoveStart(vecDistance,WhenComplete)
	_Vector3.sub(_rd.camera.look, _rd.camera.eye, dir);
	dir.z = 0;
	dir:normalize( );

	self.matMoveStart:identity(); 
	self.matMoveStart:mulFaceToRight( vecDistance.x,vecDistance.y,0, dir.x, dir.y, 0, 0 ); 
	
	self.matMoveStart:apply(oni,dis);
	_Vector3.mul(dis, 10, dis);
	dis.z = 0;
	local cur = MainPlayerController:GetPlayer():GetPos();
	cur.z = 0;
	_Vector3.add(cur, dis, tar);
 
	local cur = MainPlayerController:GetPlayer():GetPos();
	self:ProcMoveTo(cur,tar,WhenComplete,true); --客户端无视阻挡
	self.bMoveByASWD = true;
end;

--停止位移
function CPlayerControl:MoveStop(keepPath)
	Debug("CPlayerControl:MoveStop()")
	self.bMoveByASWD = nil
	self.waitMove = false
	local selfPlayer = MainPlayerController:GetPlayer()
	if selfPlayer:IsMoveState() then
		selfPlayer:DoStopMove()
		local pos = selfPlayer:GetPos()
		local dir = selfPlayer:GetDir()
		CPlayerMap:SendStopMove(pos, dir)
	end
	if not keepPath then
		CPlayerControl:SetPathList(nil)
		--CPlayerControl.lstPathLine = nil
		MapController:DelAutoLine()
		--任务引导
		QuestGuideManager:WhenStop()
		MainPlayerController:ResetAutoSitTime()
	end
end

--自动寻路
--@return true可以到达,false不可到达
function CPlayerControl:AutoRun(vecDes, arrComp, path, dwDis)
	--Debug("CPlayerControl:AutoRun: ", debug.traceback(), vecDes.x, vecDes.y)
	--通过自己的场景得到一系列的连线，并且能播放动画
	if not MainPlayerController:GetPlayer() then
		Debug("=======AutoRun -1=======")
		return false;
	end;
	local vecSrc = MainPlayerController:GetPlayer():GetPos();--取得当前位置
	if not vecSrc then
		return
	end
	local dis = math.sqrt((vecSrc.x - vecDes.x)^2 + (vecSrc.y - vecDes.y)^2)
	self.dwDis = dwDis
	if dis < (dwDis or 1) then
		if arrComp and arrComp.func then
			arrComp.func(arrComp.param)
		end
		return true
	end

	local lstPathLine,bFindRes = nil,false;
	if path then
		lstPathLine = path;
		bFindRes = true;
	else
		lstPathLine ,bFindRes = AreaPathFinder:GetPathLine(vecSrc,vecDes);--路径数组、获取路径是否成功result
	end
	if not bFindRes then
		print(debug.traceback())
		Debug('#Error找不到路径', vecSrc.x, vecSrc.y, vecSrc.z, vecDes.x, vecDes.y, vecDes.z)
		return false;
	end
    --Debug(4)
    --重置寻路
    self.dwCurLineIndex = 2;
    CPlayerControl:SetPathList(lstPathLine)
    --self.lstPathLine = lstPathLine;
    -- 画寻路点
	self:DrawLine();

    local vecTarget = self.lstPathLine[self.dwCurLineIndex];
    if not vecTarget then
        Debug("=======AutoRun -3=======")
        return false;
    else
        --Debug("CPlayerControl:AutoRun dwCurLineIndex: ", self.dwCurLineIndex)
        --Debug("CPlayerControl:AutoRun vecSrc: ",vecSrc.x, vecSrc.y)
        --Debug("CPlayerControl:AutoRun vecTarget: ", vecTarget.x, vecTarget.y)
    end;
    self.arrComp = arrComp;
	
	MainPlayerController:ClearAutoSitTime();
	--处理位移
	local rst
	if self.dwCurLineIndex == #self.lstPathLine then
		rst = self:ProcMoveTo(vecSrc,vecTarget,CPlayerControl.MoveCamplete, nil, dwDis);
	else
		rst = self:ProcMoveTo(vecSrc,vecTarget,CPlayerControl.MoveCamplete);
	end
	if rst == 1 then
		return true;
	elseif rst == -1 then
		self.waitMove = true;
		return true;
	else
		CPlayerControl:SetPathList(nil)
		--CPlayerControl.lstPathLine = nil
		MapController:DelAutoLine()
		return false;
	end
end; 

--设置寻路路线
function CPlayerControl:DrawLine()
	MapController:DrawLine( self.lstPathLine );
end

--计算比较长的路程，从新计算

--过区域传送门,重新向目标点寻路
function CPlayerControl:OnAreaTelport()
	if not CPlayerControl.lstPathLine then return; end
	--索引是最后一个的情况是手点了传送门
	if #self.lstPathLine == CPlayerControl.dwCurLineIndex then
		CPlayerControl.MoveCamplete()
		return;
	end
	local vecTarget = self.lstPathLine[#self.lstPathLine];
	CPlayerControl:AutoRun(vecTarget, self.arrComp, nil, self.dwDis);
end

--更新
function CPlayerControl.MoveCamplete()
    --Debug("cplayercontrol.movecamplete enter:")
	if not CPlayerControl.lstPathLine then
		if CPlayerControl.arrComp ~= nil then 
			CPlayerControl.arrComp.func = nil
			CPlayerControl.arrComp = nil;
		end
		return false;
	end; 
	CPlayerControl.dwCurLineIndex = CPlayerControl.dwCurLineIndex+1;
	local vecTarget = CPlayerControl.lstPathLine[CPlayerControl.dwCurLineIndex];

	if vecTarget == nil then
		--Debug("cplayercontrol.movecamplete run complete we stop")
		MainPlayerController:StopMove();
		CPlayerControl:SetPathList(nil)
		MainPlayerController:ResetAutoSitTime();
		--CPlayerControl.lstPathLine =nil;
		CPlayerControl.dwCurLineIndex =1;
		if CPlayerControl.arrComp then
			CPlayerControl.arrComp.func(CPlayerControl.arrComp.param);
			CPlayerControl.arrComp.func = nil
			CPlayerControl.arrComp = nil;
		end; 
		return false;
	end;
	--继续移动
	local vecSrc = MainPlayerController:GetPlayer():GetPos();--取得当前位置
    --Debug("cplayercontrol.movecamplete run continue  vecTarget: ", vecTarget.x, vecTarget.y)
    if CPlayerControl.dwCurLineIndex == #CPlayerControl.lstPathLine then
		CPlayerControl:ProcMoveTo(vecSrc,vecTarget,CPlayerControl.MoveCamplete, nil, CPlayerControl.dwDis);
	else
		CPlayerControl:ProcMoveTo(vecSrc,vecTarget,CPlayerControl.MoveCamplete);
	end
	return true;
end;

--让玩家移动的公用接口
--@return 1成功;-1技能硬直麻痹等导致的不能移动,做等待处理;-2当前人物状态不能移动
function CPlayerControl:ProcMoveTo(vecSrc,vecTar,funComp,bUseCanTo, dwDis)
	--Debug(debug.traceback())
	if HuncheController.followerGuid
		and HuncheController.followerGuid ~= "0_0" then
    	return -2
    end

	if CPlayerMap.teleportState == true then
		--Debug("CPlayerMap.teleportState")
		return -2
	end

	if CPlayerMap.bChangeMaping then
		--Debug("CPlayerMap.bChangeMaping")
		return -2
	end

	if CPlayerMap.changeLineState == true then
		--Debug("CPlayerMap.changeLineState")
		return -2
	end

	if CPlayerMap.changePosState then
		--Debug("CPlayerMap.changePosState")
		return -2
	end

	if StoryController:IsStorying() then
		--Debug("StoryController:IsStorying()")
		return -2
	end

	if CameraControl:IsPlaying() then
		return -2
	end

	local selfPlayer = MainPlayerController:GetPlayer()
    if selfPlayer:IsDead() then--死亡不能移动
		--Debug("selfPlayer:IsDead()")
    	return -2;
    end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STIFF) == 1 then--硬直中
		--Debug("PlayerState.UNIT_BIT_STIFF")
		return -1;
	end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_PALSY) == 1 then--麻痹中
		--Debug("PlayerState.UNIT_BIT_PALSY")
		return -1;
	end
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_HOLD) == 1 then--定身中
		--Debug("PlayerState.UNIT_BIT_HOLD")
		return -1;
	end	
	if selfPlayer:GetStateInfoByType(PlayerState.UNIT_BIT_STUN) == 1 then--眩晕中
		--Debug("PlayerState.UNIT_BIT_STUN")
		return -1;
	end	
    if SkillController:IsStiff() then--技能硬直
		--Debug("SkillController:IsStiff")
    	return -1;
    end
    if not selfPlayer:IsPunish() then--不能移动
		--Debug("not selfPlayer:IsPunish()")
    	return -1;
    end
	if SkillController:IsNeedInterruptState() == true then
		--Debug("SkillController:IsNeedInterruptState()")
		SkillController:TryInterruptCast()
		return -1;
    end
	if selfPlayer:IsPrepState() then
		--Debug("selfPlayer:IsPrepState()")
        return -1
    end
    --打断打坐
	MainPlayerController:ReqCancelSit()
	--打断吃饭
	if ActivityController:GetCurrId() == ActivityConsts.Lunch then
		MainPlayerController:ReqCancelEatLunch()
	end
    local fSpeed =  MainPlayerModel.speed and MainPlayerModel.speed or _G.fSpeed
	selfPlayer:DoMoveTo(vecTar,funComp,bUseCanTo,fSpeed, dwDis)
	CPlayerMap:SendMoveTo(vecSrc,vecTar,bUseCanTo)
	return 1
end

function CPlayerControl:SetPathList(pathList)
	CPlayerControl.lstPathLine = pathList
	SceneRoute:InitRoute(pathList)
end

function CPlayerControl:GetCameraMaxHeight()
	local cameraMaxHeight = RenderConfig.cameraMaxHeight
	if SetSystemController.isHighView then
		cameraMaxHeight = RenderConfig.cameraMaxHeight * SetSystemConsts.cameraMaxHeightMultiple
	end
	return cameraMaxHeight
end