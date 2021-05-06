local CMapTouchCtrl = class("CMapTouchCtrl", CDelayCallBase)

function CMapTouchCtrl.ctor(self)
	CDelayCallBase.ctor(self)
	self.m_LayerMask = UnityEngine.LayerMask.GetMask("MapTerrain", "MapWalker")
	self.m_TouchEffects = {} --缓存几个
	self.m_PinchToucCount = 0
	for _,v in pairs(define.Map.TouchType) do
		self.m_TouchEffects[v.Name] = {}
	end
	self.m_LongPressTimer = nil
	self.m_LongPressDelta = 0
	self.m_LongPreePos = nil
	self.m_LongPreePosOffset = nil
	self.m_IsLongPress = false
end

function CMapTouchCtrl.SetLockTouch(self, bLock)
	self.m_LockTouch = bLock
end

function CMapTouchCtrl.OnTouchDown( self, touchPos )
	if self.m_PinchToucCount > 0 then
		self.m_PinchToucCount = self.m_PinchToucCount - 1
		return
	end
	g_MapCtrl:ClearTouchNpcTips()
	--长按操作开始监听
	self:LongPressCheck(touchPos, true)
end

function CMapTouchCtrl.OnSwipe( self, touchPos )
	if self.m_PinchToucCount > 0 then
	-- 	self.m_PinchToucCount = self.m_PinchToucCount - 1		
		return
	end

	--长按操作位置更新
	if self.m_IsLongPress then
		self.m_LongPreePos = self.m_LongPreePos + touchPos
		self.m_LongPreePosOffset = nil
	else
		if self.m_LongPreePosOffset then
			self.m_LongPreePosOffset = self.m_LongPreePosOffset + touchPos 
		end					
	end
end

function CMapTouchCtrl.LongPressCheck(self, touchPos, bPress)
	if self.m_LongPressTimer ~= nil then
		Utils.DelTimer(self.m_LongPressTimer)
		self.m_LongPressTimer = nil
	end
	if bPress then
		self.m_LongPreePos = touchPos	
		self.m_LongPreePosOffset = touchPos		
		self.m_LongPressDelta = 0
		local function wrap(dt)
			if not self.m_IsLongPress then
				if UITools.CheckInDistanceXY(self.m_LongPreePos, self.m_LongPreePosOffset, 0.01) then
					self.m_IsLongPress = true	
				else
					self.m_LongPressTimer = nil
					return false
				end
			end				
			if g_EasyTouchCtrl:GetTouchCount() > 0 then				
				self.m_LongPressDelta = self.m_LongPressDelta + dt
				if self.m_LongPressDelta > 0.2 then
					self.m_LongPressDelta = 0
					self:OnTouchUp(self.m_LongPreePos, true)			
				end
				return true				
			end
			return false			
		end
		self.m_LongPressTimer = Utils.AddTimer(wrap, 0, 0.5)
	else
		self.m_IsLongPress = false
		self.m_LongPreePos = nil	
		self.m_LongPreePosOffset = nil	
		self.m_LongPressDelta = 0
	end
end

--{[1]=gameobj, [2]=point,...}
function CMapTouchCtrl.OnTouchUp(self, touchPos, bLongPress)
	if self.m_LockTouch then
		return
	end
	if self.m_PinchToucCount > 0 then
		self.m_PinchToucCount = self.m_PinchToucCount - 1
		return
	end
	--长按操作结束
	if not bLongPress then
		self:LongPressCheck(touchPos, false)
	end

	g_UITouchCtrl:NotTouchUI()

	--护送和跟踪任务检测
	local oHero = g_MapCtrl:GetHero()
	if not Utils.IsExist(oHero) or not oHero:IsCanWalk() then
		if Utils.IsExist(oHero) and not oHero:IsCanWalk() then
			--如果此时正在跟踪任务
			local traceTarget =  g_TaskCtrl:IsDoingTraceTask()
			if traceTarget then
				local traceNpc = g_MapCtrl:GetTraceNpc(traceTarget)
				local oHero	= g_MapCtrl:GetHero()
				if traceNpc and oHero then
					traceNpc:SetFollow(false)	
				end							
			end
		end
		return
	end

	if g_MarryCtrl:IsExpressing() then
		return
	end

	if g_OrgWarCtrl:CheckMove() then
		return
	end

	--每日修行检测若，若在每日修行任务中，则无法点击地面	
	if g_ActivityCtrl:ClickTargetCheck(CActivityCtrl.DCClickEnum.Map) then
		return
	end

	--在世界boss场景中处于死亡状态，则无法点击地面	
	if g_ActivityCtrl:InWorldBossFB() and g_StateCtrl:GetState(1005) then
		return
	end

	--装备副本再点击地面时，停止自动	
	if g_EquipFubenCtrl:IsInEquipFB() then
		g_EquipFubenCtrl:StopAutoFuben()
	end

	if g_ActivityCtrl:GetYJFbCtrl():IsInFuben() then
		g_ActivityCtrl:GetYJFbCtrl():StopAutoFuben()
	end

	if g_TaskCtrl:IsAutoDoingShiMen() then
		g_TaskCtrl:StartAutoDoingShiMen(false)
	end

	--点地图，停止跑任务标志 
	g_TaskCtrl:StopWalingTask()

	--如果当前在暗雷探索，则无法点击地面
	if g_AnLeiCtrl:IsInAnLei() then
		return
	end

	local lTouch = C_api.EasyTouchHandler.SelectMultiple(g_CameraCtrl:GetMainCamera().m_Camera, touchPos.x, touchPos.y, self.m_LayerMask)
	if not lTouch or #lTouch == 0 then
		return
	end
	local iCnt = #lTouch / 2
	local vWalkPos = nil
	local func = nil
	local iOffsetDis = nil
	local vTerrianPos = nil
	local oToucWalker = nil
	local iMinY = nil
	local oWalkList = {}
	for i=1, iCnt do
		local go, point = lTouch[i*2-1], lTouch[i*2]
		-- oNpcList
		if go.layer == define.Layer.MapTerrain then
			vTerrianPos = point
			--开了break的话，先遍历到MapTerrain,其他东西就点不到了
			-- break
		elseif go.layer == define.Layer.MapWalker then
			local ref = g_MapCtrl.m_IntanceID2Walker[go:GetInstanceID()]
			local oWalker = getrefobj(ref)
			if oWalker then
				if oWalker.classname ~= "CHero" then
					table.insert(oWalkList, oWalker)
				end
				-- if oWalker.classname == "CPlayer" then
				-- 	local y = oWalker:GetPos().y
				-- 	if not iMinY then
				-- 		iMinY = y + 1
				-- 	end
				-- 	if y < iMinY then
				-- 		iMinY = y
				-- 		vWalkPos = oWalker:GetPos()--point
				-- 		iOffsetDis = define.Walker.Npc_Talk_Distance
				-- 		oToucWalker = oWalker
				-- 	end
				-- elseif oWalker.classname == "CNpc" or oWalker.classname == "CDynamicNpc" or oWalker.classname == "CTaskPickItem" then
				-- 	vWalkPos = oWalker:GetPos()
				-- 	func = function()
				-- 		if Utils.IsExist(oWalker) and oWalker.Trigger then
				-- 			oWalker:Trigger()
				-- 		end
				-- 	end
				-- 	iOffsetDis = define.Walker.Npc_Talk_Distance
				-- 	oToucWalker = oWalker
				-- 	break
				-- end
			end
		end
	end

	local function commonExecute()
		if oToucWalker and oToucWalker.OnTouch and not bLongPress then
			oToucWalker:OnTouch()
		end

		if self.m_WalkTimer then
			Utils.DelTimer(self.m_WalkTimer)
			self.m_WalkTimer = nil
		end

		if vWalkPos then
			self:ShowTouchEffect(vWalkPos, define.Map.TouchType.Walker)
			self:WalkToPos(vWalkPos, nil, iOffsetDis, func)

			if bLongPress then
				oHero:DelBindObj("auto_find")
			end
		else
			g_MapCtrl:SetPatrol(false)
			local oHero = g_MapCtrl:GetHero()
			if Utils.IsExist(oHero) then
				oHero:DelBindObj("auto_find")
				-- g_MainMenuCtrl:ShowAllArea()
				if vTerrianPos then
					self:ShowTouchEffect(vTerrianPos, define.Map.TouchType.Terrian)
					oHero:WalkToAndSyncPos(vTerrianPos.x, vTerrianPos.y)
				end				
			end
		end
	end

	local function walkerExecute(oWalker)
		if oWalker.classname == "CPlayer" then
			local y = oWalker:GetPos().y
			if not iMinY then
				iMinY = y + 1
			end
			if y < iMinY then
				iMinY = y
				vWalkPos = oWalker:GetPos()--point
				iOffsetDis = define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset()
				oToucWalker = oWalker
			end
		elseif oWalker.classname == "CNpc" or oWalker.classname == "CDynamicNpc" or oWalker.classname == "CTaskPickItem" 
			or oWalker.classname == "CEscortNpc" or oWalker.classname == "CTraceNpc" or oWalker.classname == "CChoukaNpc" 
			or oWalker.classname == "CTerrawarNpc" or oWalker.classname == "CMonsterNpc" or oWalker.classname == "CTaskChapterFbNpc" then
			vWalkPos = oWalker:GetPos()
			func = function()
				if Utils.IsExist(oWalker) and oWalker.Trigger and not bLongPress then
					oWalker:Trigger()
				end
			end
			iOffsetDis = define.Walker.Npc_Talk_Distance + g_DialogueCtrl:GetTalkDistanceOffset()
			oToucWalker = oWalker
		end
		commonExecute()
	end

	if #oWalkList > 0 then
		if #oWalkList == 1 then
			walkerExecute(oWalkList[1])
		else
			local npcList = {}
			local names = {"CPlayer", "CNpc", "CDynamicNpc", "CTaskPickItem", "CMonsterNpc"}
			for _,v in ipairs(oWalkList) do
				if table.index(names, v.classname) then
					local function cb()
						if not Utils.IsNil(v) then
							printc("结束寻路到指定npc", v:GetName())
							walkerExecute(v)
						end
					end
					local npcInfo = {}
					npcInfo.name = v.m_Name
					npcInfo.shape = v.m_Actor.m_Shape or v.m_Shape
					npcInfo.cb = cb
					npcInfo.classname = v.classname
					npcInfo.npcaoi = v.m_NpcAoi
					table.insert(npcList, npcInfo)
				end
			end
			g_MapCtrl:OnEventNpcList(npcList)
		end
		return
	end
	commonExecute()
end

function CMapTouchCtrl.OnPinch(self, touchCnt, pinchDis, isOverUI)
	if not g_SysSettingCtrl:GetZoomlensEnabled() then
		return
	end
	if self.m_PinchToucCount == 0 then
		self.m_PinchToucCount = touchCnt
		return
	end
	if not g_MapCtrl:GetHero() then
		return
	end
	local oMainView = CMainMenuView:GetView()
	if oMainView and oMainView:GetActiveHierarchy() then
		local oCam = g_CameraCtrl:GetMainCamera()
		local iCurSize = oCam:GetOrthographicSize()
		local iNewSize = math.max(1.8, math.min(iCurSize-pinchDis*0.005, 2.7))
		if iNewSize ~= iCurSize then
			g_CameraCtrl:SetMapCameraSize(iNewSize)
		end
	end
end

function CMapTouchCtrl.WalkToPos(self, pos, npcid, offset, func, walkconfig)
	local oHero = g_MapCtrl:GetHero()
	if not Utils.IsExist(oHero) then
		return
	end
	if g_OrgWarCtrl:CheckMove() then
		return
	end
	if self.m_WalkTimer then
		Utils.DelTimer(self.m_WalkTimer)
		self.m_WalkTimer = nil
	end

	if offset or func then
		local function check()
			if Utils.IsNil(oHero) then
				self.m_WalkTimer = nil
				return false
			end

			local walkFinish = UITools.CheckInDistanceXY(oHero:GetPos(), pos, offset)
			if walkFinish then
				oHero:StopWalk()
				if npcid then
					local oNpc = g_MapCtrl:GetNpc(npcid)
					if not oNpc then
						oNpc = g_MapCtrl:GetDynamicNpc(npcid)
					end
					if oNpc and oNpc.Trigger then
						oNpc:Trigger()
					end
				end
				if func then
					func()
				end
				self.m_WalkTimer = nil
			end
			return not walkFinish
		end
		-- 行走前判断一下，修复滑步表现
		if not check() then
			return
		end
		self.m_WalkTimer = Utils.AddTimer(check, 0.1, 0.1)
	end
	g_MapCtrl:SetPatrol(false)
	oHero:AddBindObj("auto_find")
	-- g_MainMenuCtrl:HideAreas(define.MainMenu.HideConfig.PathFind)
	oHero:WalkToAndSyncPos(pos.x, pos.y, nil, nil, walkconfig)
end

function CMapTouchCtrl.StopAutoWalk(self)
	local oHero = g_MapCtrl:GetHero()
	if oHero then
		oHero:StopWalk()
	end
	if self.m_WalkTimer then
		Utils.DelTimer(self.m_WalkTimer)
		self.m_WalkTimer = nil
	end
end

function CMapTouchCtrl.ShowTouchEffect(self, worldPos, touchType)
	if not worldPos then
		return
	end
	local path = string.format("Effect/Game/game_eff_%d/Prefabs/game_eff_%d.prefab", touchType.ID, touchType.ID)
	local function cb(obj)
		obj.m_Eff:SetLocalRotation(Quaternion.Euler(-30, 0, 0)) 
	end
	local oEffect = CEffect.New(path, UnityEngine.LayerMask.NameToLayer("MapTerrain"), true, cb)
	worldPos.z = 0
	oEffect:SetPos(worldPos)
	oEffect:AutoDestroy(1.2)
end

return CMapTouchCtrl