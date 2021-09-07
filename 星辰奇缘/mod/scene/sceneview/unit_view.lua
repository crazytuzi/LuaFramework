UnitView = UnitView or BaseClass(BaseView)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function UnitView:__init(data)
    self.gameObject = nil
    self.cachedTransform = nil

	self.loadList = BaseUtils.create_queue()

    self.active = true

    self.controller = nil

    self.animator = nil
    self.animator_head = nil

    self.tpose = nil
    self.cachedTposeTransform = nil
    self.animationData = nil
    self.headTpose = nil
    self.headAnimationData = nil

    self.lastAction = nil
    self.lastActionTime = 0

	self.data = data
	self.TargetPositionList = {}
    self.canMove = true

    self.TargetOrienation = nil
    self.orienation = 0

    self.ride_fly = false -- 坐骑飞行，需要与 SceneConstData.unitstate_fly 配合使用

    self.can_alpha = true
    self.alpha = 1
    self.scale = 1

    self.namePrefix = ""

    self.idle_count_max = 600
    self.idle_count = math.random(1, self.idle_count_max)

    self.effectdict = {}

    self.CreateTpose_Mark = false

    self.moveEnd_CallBack = nil
    self.action_callback = nil
    self.map = nil
    self.isdelete = false

    self.isShowFoot = true
    self.footMarkCount = 20
    self.footMarkPos = nil
    --self.footMarkSign = false
end

function UnitView:__delete()
    self.isdelete = true
    if SceneManager.Instance.sceneElementsModel.Selected_Effect_Parent == self then
        SceneManager.Instance.sceneElementsModel:Set_Selected_Effect()
        if self.gameObject ~= nil and SceneManager.Instance.sceneElementsModel.CurrentClickObject == self.gameObject then
            SceneManager.Instance.sceneElementsModel.target_uniqueid = self.gameObject.name
        end
    end

    if self.gameObject ~= nil then
        local p = self.gameObject.transform.position
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        self.data.x = p.x
        self.data.y = p.y
        if #self.TargetPositionList > 0 then
            local targetPosition = self.TargetPositionList[1]
            self.data.targetPosition = SceneManager.Instance.sceneModel:transport_big_pos(targetPosition.x, targetPosition.y)
        else
            self.data.targetPosition = nil
        end

        GameObject.Destroy(self.gameObject)
        self.cachedTransform = nil
        self.cachedTposeTransform = nil
        self.gameObject = nil
        self.map = nil
    end

    self.poolData = nil
end

-- 资源加载
function UnitView:LoadAssetBundleBatch(resList, OnCompleted)
    if self.assetWrapper == nil then
        self.assetWrapper = AssetBatchWrapper.New()
        local callback = function()
            OnCompleted()
            self:OnResLoadCompleted()
        end
        self.assetWrapper:LoadAssetBundle(resList, callback)
    else
        BaseUtils.enqueue(self.loadList, { resList = resList, OnCompleted = OnCompleted })
    end
end

-- 资源加载完成，加载下一波资源
function UnitView:OnResLoadCompleted()
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if self.gameObject == nil then return end

    local loadData = BaseUtils.dequeue(self.loadList)
    if loadData ~= nil then
        self:LoadAssetBundleBatch(loadData.resList, loadData.OnCompleted)
    end
end

function UnitView:SetActive(active, hard)
    if self.active ~= active or hard then
        self.active = active
        if not BaseUtils.is_null(self.gameObject) then
            self.gameObject:SetActive(self.active)
        end

        if self.active then
            self:PlayAction(self.lastAction)
        else

        end
    end
end

function UnitView:FixedUpdate()
    if self.gameObject ~= nil then
        if self.canMove and #self.TargetPositionList > 0 then
            local position = self:GetCachedTransform().position
            if self.isShowFoot and self.data.foot_mark ~= 0 then
                if (self.data.ride ~= SceneConstData.unitstate_fly) or (self.data.ride == SceneConstData.unitstate_fly and not self.ride_fly) then
                    if BaseUtils.GetClientVerion() == "9.9.9" then
                        --内网包
                        self.footMarkCount = self.footMarkCount + 1
                        if self.footMarkCount % 26 == 0 then
                            self.footMarkPos = position
                            self:ShowFootMarks(self.data.foot_mark)
                        end
                    else
                        --只有自己看得到自己的足迹
                        if self.data.uniqueid == SceneManager.Instance.sceneElementsModel.self_unique then
                            self.footMarkCount = self.footMarkCount + 1
                            if self.footMarkCount % 26 == 0 then
                                self.footMarkPos = position
                                self:ShowFootMarks(self.data.foot_mark)
                            end
                        end
                    end
                else
                    if self.footMarkPos ~= nil then
                        self.footMarkPos = nil
                    end
                end
            end
    		local targetPosition = self.TargetPositionList[1]
			targetPosition = Vector3(targetPosition.x, targetPosition.y, targetPosition.y)
            if position ~= targetPosition then
    			local p = Vector3.MoveTowards(position, targetPosition, self.Speed * SceneManager.Instance.deltaTime)
				self:GetCachedTransform().position = p
                self:UpdateAlpha()
            else
    			table.remove(self.TargetPositionList, 1)
                if #self.TargetPositionList > 0 then
                    local targetPosition = self.TargetPositionList[1]
                    self:FaceToPoint(targetPosition, true)
                    self:PlayMoveAction()
                else
                    if not table.containValue(SceneManager.Instance.sceneElementsModel.FollowUnit_List, self) then
                        self:StopMoveTo()
                        self.footMarkPos = nil  --停下来就清空足迹表
                    end
                end
    		end
    	end

        if self.TargetOrienation ~= nil then
            if (math.abs(self.orienation - self.TargetOrienation) > 300 * SceneManager.Instance.deltaTime) then
                local form = self.orienation
                local to = self.TargetOrienation
                local value = self.TargetOrienation - self.orienation
                local valueTemp = 0

                if ((value < 180 and value > 0) or (value > -360 and value < -180)) then
                    valueTemp = 300 * SceneManager.Instance.deltaTime
                else
                    valueTemp = -300 * SceneManager.Instance.deltaTime
                end

                if ((value >= 90 and value < 270) or (value >= -270 and value < -90)) then
                    valueTemp = valueTemp * 3
                elseif ((value > 45 and value < 90) or (value > 270 and value < 315) or (value > -90 and value < -45) or (value > -315 and value < -270)) then
                    valueTemp = valueTemp * 2
                end

                self.orienation = self.orienation + valueTemp
            else
                self.orienation = self.TargetOrienation
                self.TargetOrienation = nil
            end
            self:SetOrientation(self.orienation, true)
        end
	end

    if self.data.canIdle and self.lastAction == SceneConstData.UnitAction.Stand
        and self.data.event ~= RoleEumn.Event.Marry_cere and self.data.ride ~= SceneConstData.unitstate_ride then
        if self.idle_count == self.idle_count_max then
            if self.animationData ~= nil and self.animationData.idle_id ~= 0 then
                self:PlayAction(SceneConstData.UnitAction.Idle)
            end
            self.idle_count = 0
        end
        self.idle_count = self.idle_count + 1
    end
end

function UnitView:UpdateAlpha(hard)
    if self.tpose == nil then return end
    if not self.can_alpha then if self.set_alpha ~= nil then self:SetAlpha(self.set_alpha) self.set_alpha = nil end return end

    local alpha = 1
    local p = self:GetCachedTransform().position

    -- 审核服处理人审，对角色进行变色
    -- if BaseUtils.IsVerify then 
    --     self.alpha = 0.3 
    --     self.controller:SetAlphaChlid(self:GetCachedTposeTransform(), self.alpha) 
    --     local renders = self:GetCachedTposeTransform():GetComponentsInChildren(Renderer, true) 
    --     if renders ~= nil then 
    --         for k,v in pairs(renders) do 
    --             if string.find(v.name, "Mesh_") then 
    --                 v.material.color = BaseUtils.GetVerifyColor()
    --             end 
    --         end
    --         -- for i=1, #renders do 
    --         --     local v = renders[i]
    --         --     if string.find(v.name, "Mesh_") then 
    --         --         v.material.color = BaseUtils.GetVerifyColor()
    --         --     end 
    --         -- end
    --     end 
    --     return 
    -- end

    self.map = ctx.sceneManager.Map
    if self.map:Transparent(p.x, p.y) then
        alpha = 0.3
    end
    if self.data.ride == SceneConstData.unitstate_fly then
        alpha = 1
    end
    if self.alpha ~= alpha or hard then
        self.alpha = alpha
        self.controller:SetAlphaChlid(self:GetCachedTposeTransform(), self.alpha)
    end
end

function UnitView:JumpTo_by_big_pos(tx, ty)
    local p = SceneManager.Instance.sceneModel:transport_small_pos(tx, ty)
    self:JumpTo(p.x, p.y)
end

function UnitView:JumpTo(tx, ty)
    if self.gameObject == nil then return end
	local v3 = Vector3(tx, ty, ty)
    self:GetCachedTransform().position = v3
    self.TargetPositionList = {}

    if self.lastAction ~= SceneConstData.UnitAction.Stand and self.lastAction ~= SceneConstData.UnitAction.FlyStand then
        self:PlayStandAction()
    end
    self:UpdateAlpha()
end

function UnitView:MoveTo_NoPaths(x, y)
    self.TargetPositionList = {{ x = x, y = y }}
    if #self.TargetPositionList > 0 then
        local targetPosition = self.TargetPositionList[1]
        self:FaceToPoint(targetPosition, true)
        -- 移动动作
        self:PlayMoveAction()
    end
end

function UnitView:MoveTo(x, y, isfly)
    if not self.canMove then
        return
    end

    local fly = 0
    if self.data.unittype == SceneConstData.unittype_role then
        fly = self.data.ride
    end

    if isfly == true then
        fly = 1
    end

    if fly == 2 then
        fly = 0
    elseif fly == 3 then
        fly = 1
    end

    local result = ctx.sceneManager.PathFinder:MoveTo(self.controller, x, y, fly)
    if BaseUtils.is_null(result) then
        self:StopMoveTo()
        return
    end

    local path = {}
    for i=1, result.Length-1 do
        table.insert(path, result[i])
    end
    self.TargetPositionList = path
    if #self.TargetPositionList > 0 then
        local targetPosition = self.TargetPositionList[1]
        self:FaceToPoint(targetPosition, true)
        -- 移动动作
        self:PlayMoveAction()
    else
        self:StopMoveTo()
    end
end

function UnitView:StopMoveTo()
    self.TargetPositionList = {}
    -- 站立动作
    self:PlayStandAction()

    if self.moveEnd_CallBack ~= nil then
        local callback = self.moveEnd_CallBack
        self.moveEnd_CallBack = nil
        callback()
    end
end

function UnitView:MoveToRoadPoint()
    local result = ctx.sceneManager.PathFinder:MoveToRoadPoint(self.controller, 1)
    if BaseUtils.is_null(result) then
        self:StopMoveTo()
        return
    end

    local path = {}
    for i=1, result.Length-1 do
        table.insert(path, result[i])
    end
    self.TargetPositionList = path
    if #self.TargetPositionList > 0 then
        local targetPosition = self.TargetPositionList[1]
        self:FaceToPoint(targetPosition, true)
        -- 移动动作
        self:PlayMoveAction()
    else
        self:StopMoveTo()
    end
end

function UnitView:FaceToPoint(target_point, force)
    -- force 用于npc自己本身移动时候的面向
    if self.data.no_facetopoint and not force then return end
    local dx = self:GetCachedTransform().position.x - target_point.x
    local dy = self:GetCachedTransform().position.y - target_point.y
    local angle = ((math.atan2(dx, dy)) * 180 / math.pi)
    self:FaceTo(angle)
end

function UnitView:FaceTo(angle)
    angle = (angle + 720) % 360
    self.TargetOrienation = angle
end

function UnitView:FaceTo_Now(angle)
    self:SetOrientation(angle, true)
    self.TargetOrienation = nil
end

function UnitView:SetOrientation(angle, rotationFromZore)
    angle = (angle + 720) % 360
    if self.tpose ~= nil then
        if rotationFromZore then
            self:GetCachedTposeTransform().rotation = Quaternion.identity
            self:GetCachedTposeTransform():Rotate(Vector3(-20, 0, 0))
        end
        self:GetCachedTposeTransform():Rotate(Vector3(0, angle, 0))
    end
    self.orienation = angle
end

--直接传人动作名称播放；如技能动作 1000
function UnitView:play_action_name(act_name, nostand)
    if BaseUtils.is_null(self.animator) then
        self.action_cacheData = { act_name = act_name, nostand = nostand }
        return
    end

    if self.timeId ~= nil then LuaTimer.Delete(self.timeId) self.timeId = nil end

    self.animator:Play(tostring(act_name))
    if not nostand then
        LuaTimer.Add(50, function() self:DelayUpdate() end)
    end
end

function UnitView:play_action(action, nostand, donotchecktransform)
    if BaseUtils.is_null(self.animator) then
        self.action_cacheData = { action = action, nostand = nostand }
        return
    end

    if self.timeId ~= nil then LuaTimer.Delete(self.timeId) self.timeId = nil end

    if not donotchecktransform and self.transform_id ~= nil and self.transform_id ~= 0 then
        if action ~= SceneConstData.UnitAction.Stand and action ~= SceneConstData.UnitAction.Move
            and action ~= SceneConstData.UnitAction.Idle then
            action = SceneConstData.UnitAction.Stand
        end
    end

    if self.ride then
    -- if (self.data.ride == SceneConstData.unitstate_fly and self.ride_fly)
    --     or (self.data.ride == SceneConstData.unitstate_ride) then
        if action ~= SceneConstData.UnitAction.Stand and action ~= SceneConstData.UnitAction.Move
            and action ~= SceneConstData.UnitAction.Idle then
            action = SceneConstData.UnitAction.Stand
        end
        if self.lastAction == SceneConstData.UnitAction.FlyStand then
            self.lastAction = SceneConstData.UnitAction.Stand
        end
        if self.lastAction == SceneConstData.UnitAction.FlyMove then
            self.lastAction = SceneConstData.UnitAction.Move
        end
    end

    local iscallback = false
    if action == SceneConstData.UnitAction.Stand then
        if self.lastAction == SceneConstData.UnitAction.FlyStand then
            self.animator:CrossFade(SceneConstData.genanimationname("Stand", self.animationData.stand_id), 0.3)
        else
            self.animator:Play(SceneConstData.genanimationname("Stand", self.animationData.stand_id))
        end
    elseif action == SceneConstData.UnitAction.Move then
        if self.lastAction == SceneConstData.UnitAction.FlyMove then
            self.animator:CrossFade(SceneConstData.genanimationname("Move", self.animationData.move_id), 0.3)
        else
            self.animator:Play(SceneConstData.genanimationname("Move", self.animationData.move_id))
        end
    elseif action ==  SceneConstData.UnitAction.BattleMove then
        self.animator:Play(SceneConstData.genanimationname("Move", self.animationData.battlemove_id))
    elseif action ==  SceneConstData.UnitAction.BattleStand then
        self.animator:Play(SceneConstData.genanimationname("Stand", self.animationData.battlestand_id))
    elseif action ==  SceneConstData.UnitAction.Pick then
        self.animator:Play(SceneConstData.genanimationname("Pick", self.animationData.pick_id))
    elseif action ==  SceneConstData.UnitAction.Hit then
        iscallback = true
        self.animator:Play(SceneConstData.genanimationname("Hit", self.animationData.hit_id))
    elseif action ==  SceneConstData.UnitAction.Dead then
        -- iscallback = true
        self.animator:Play(SceneConstData.genanimationname("Dead", self.animationData.dead_id))
    elseif action ==  SceneConstData.UnitAction.Jump then
        self.animator:Play(SceneConstData.genanimationname("Jump", self.animationData.jump_id))
    elseif action ==  SceneConstData.UnitAction.Standup then
        iscallback = true
        self.animator:Play(SceneConstData.genanimationname("Standup", self.animationData.standup_id))
    elseif action ==  SceneConstData.UnitAction.Show then
        iscallback = true
        self.animator:Play(SceneConstData.genanimationname("Show", self.animationData.show_id))
    elseif action ==  SceneConstData.UnitAction.Idle then
        iscallback = true
        self.animator:Play(SceneConstData.genanimationname("Idle", self.animationData.idle_id))
    elseif action ==  SceneConstData.UnitAction.FlyStand then
        if self.lastAction == SceneConstData.UnitAction.Stand then
            self.animator:CrossFade(SceneConstData.genanimationname("Flystand", self.animationData.flystand_id), 0.3)
        else
            self.animator:Play(SceneConstData.genanimationname("Flystand", self.animationData.flystand_id))
        end
    elseif action ==  SceneConstData.UnitAction.FlyMove then
        if self.lastAction == SceneConstData.UnitAction.Move then
            self.animator:CrossFade(SceneConstData.genanimationname("Flymove", self.animationData.flymove_id), 0.3)
        else
            self.animator:Play(SceneConstData.genanimationname("Flymove", self.animationData.flymove_id))
        end
    elseif action == SceneConstData.UnitAction.JumpUp then
        self.animator:Play(SceneConstData.genanimationname("Jumpup", self.animationData.jumpup))
    elseif action == SceneConstData.UnitAction.JumpMove then
        self.animator:Play(SceneConstData.genanimationname("Jumpmove", self.animationData.jumpup_move))
    elseif action == SceneConstData.UnitAction.JumpDown then
        self.animator:Play(SceneConstData.genanimationname("Jumpdown", self.animationData.jumpup_down))
    elseif action == SceneConstData.UnitAction.Sit then
        self.animator:Play(SceneConstData.genanimationname("Sit", self.animationData.ridestand_id))
    end
    self.lastAction = action
    -- self:play_action_head(action) -- 播放头部动作

    if iscallback and not nostand then
        LuaTimer.Add(50, function() self:DelayUpdate() end)
    end
end

function UnitView:play_action_head(action)
    if BaseUtils.is_null(self.animator_head) or BaseUtils.isnull(self.headAnimationData) then
        return
    end
    if action == SceneConstData.UnitAction.Stand then
        if self.lastAction == SceneConstData.UnitAction.FlyStand then
            self.animator_head:CrossFade(self.headAnimationData.stand_id, 0.3)
        else
            self.animator_head:Play(self.headAnimationData.stand_id)
        end
    elseif action == SceneConstData.UnitAction.Move then
        if self.lastAction == SceneConstData.UnitAction.FlyMove then
            self.animator_head:CrossFade(self.headAnimationData.move_id, 0.3)
        else
            self.animator_head:Play(self.headAnimationData.move_id)
        end
    elseif action ==  SceneConstData.UnitAction.BattleMove then
        self.animator_head:Play(self.headAnimationData.battlemove_id)
    elseif action ==  SceneConstData.UnitAction.BattleStand then
        self.animator_head:Play(self.headAnimationData.battlestand_id)
    elseif action ==  SceneConstData.UnitAction.Pick then
        self.animator_head:Play(self.headAnimationData.pick_id)
    elseif action ==  SceneConstData.UnitAction.Hit then
        self.animator_head:Play(self.headAnimationData.hit_id)
    elseif action ==  SceneConstData.UnitAction.Dead then
        self.animator_head:Play(self.headAnimationData.dead_id)
    elseif action ==  SceneConstData.UnitAction.Jump then
        self.animator_head:Play(self.headAnimationData.jump_id)
    elseif action ==  SceneConstData.UnitAction.Standup then
        self.animator_head:Play(self.headAnimationData.standup_id)
    elseif action ==  SceneConstData.UnitAction.Show then
        self.animator_head:Play(self.headAnimationData.show_id)
    elseif action ==  SceneConstData.UnitAction.Idle then
        self.animator_head:Play(self.headAnimationData.idle_id)
    elseif action ==  SceneConstData.UnitAction.FlyStand then
        if self.lastAction == SceneConstData.UnitAction.Stand then
            self.animator_head:CrossFade(self.headAnimationData.flystand_id, 0.3)
        else
            self.animator_head:Play(self.headAnimationData.flystand_id)
        end
    elseif action ==  SceneConstData.UnitAction.FlyMove then
        if self.lastAction == SceneConstData.UnitAction.Move then
            self.animator_head:CrossFade(self.headAnimationData.flymove_id, 0.3)
        else
            self.animator_head:Play(self.headAnimationData.flymove_id)
        end
    elseif action == SceneConstData.UnitAction.JumpUp then
        self.animator_head:Play(self.headAnimationData.jumpup)
    elseif action == SceneConstData.UnitAction.JumpMove then
        self.animator_head:Play(self.headAnimationData.jumpup_move)
    elseif action == SceneConstData.UnitAction.JumpDown then
        self.animator_head:Play(self.headAnimationData.jumpup_down)
    end
end

function UnitView:PlayAction(action)
    -- if self.data.uniqueid == SceneManager.Instance.sceneElementsModel.self_unique then print(string.format("PlayAction0000000000000000 %s", action)) print(debug.traceback()) end
    if not self.active then
        self.lastAction = action
        return
    end

    if self.transform_id ~= nil and self.transform_id ~= 0 then
        if action ~= SceneConstData.UnitAction.Stand and action ~= SceneConstData.UnitAction.Move
            and action ~= SceneConstData.UnitAction.Idle then
            action = SceneConstData.UnitAction.Stand
        end
    end

    if Time.time - self.lastActionTime < 0.07 then
        self.action_cache = action
        LuaTimer.Add(0, 8,  function(id)
                                LuaTimer.Delete(id)
                                if self.action_cache ~= nil then
                                    self:PlayAction(self.action_cache)
                                end
                            end)
    else
        -- if self.data.uniqueid == SceneManager.Instance.sceneElementsModel.self_unique then print(string.format("PlayAction %s", action)) end
        self.action_cache = nil
        self:play_action(action)
        self.lastActionTime = Time.time
    end
end

function UnitView:PlayActionName(actionName, nostand)
    -- if self.data.uniqueid == SceneManager.Instance.sceneElementsModel.self_unique then print(string.format("PlayAction0000000000000000 %s", action)) print(debug.traceback()) end
    if not self.active then
        self.lastActionName = actionName
        return
    end

    -- if self.transform_id ~= nil and self.transform_id ~= 0 then
    --     if actionName ~= "Stand15" and actionName ~= "Stand16"
    --         and actionName ~= "Move15" and actionName ~= "Move16" then
    --         actionName = "Stand15"
    --     end
    -- end

    if Time.time - self.lastActionTime < 0.07 then
        self.action_name_cache = actionName
        self.action_name_cache_nostand = nostand
        LuaTimer.Add(0, 8,  function(id)
                                LuaTimer.Delete(id)
                                if self.action_name_cache ~= nil then
                                    self:PlayActionName(self.action_name_cache, self.action_name_cache_nostand)
                                end
                            end)
    else
        -- if self.data.uniqueid == SceneManager.Instance.sceneElementsModel.self_unique then print(string.format("PlayAction %s", actionName)) end
        self.action_name_cache = nil
        self.action_name_cache_nostand = nil
        self:play_action_name(actionName, nostand)
        self.lastActionTime = Time.time
    end
end

function UnitView:PlayStandAction()
    if self.data.unittype == SceneConstData.unittype_role then
        -- 如果是在结缘状态中，截他胡，改他动作
        if self.data.event == RoleEumn.Event.Marry_cere then
            if self.data.sex == 1 then
                self:PlayActionName("Stand15", true)
            else
                self:PlayActionName("Stand16", true)
            end
            return
        end

        if self.data.ride == SceneConstData.unitstate_walk then
            self:PlayAction(SceneConstData.UnitAction.Stand)
        elseif self.data.ride == SceneConstData.unitstate_fly then
            if self.ride_fly then
                self:PlayAction(SceneConstData.UnitAction.Stand)
            else
                self:PlayAction(SceneConstData.UnitAction.FlyStand)
            end
        elseif self.data.ride == SceneConstData.unitstate_ride then
            self:PlayAction(SceneConstData.UnitAction.Stand)
        end
    else
        self:PlayAction(SceneConstData.UnitAction.Stand)
    end
end

function UnitView:PlayMoveAction()
    if self.data.unittype == SceneConstData.unittype_role then
        -- 如果是在结缘状态中，截他胡，改他动作
        if self.data.event == RoleEumn.Event.Marry_cere then
            if self.data.sex == 1 then
                self:PlayActionName("Move15", true)
            else
                self:PlayActionName("Move16", true)
            end
            return
        end
        if self.data.ride == SceneConstData.unitstate_walk then
            self:PlayAction(SceneConstData.UnitAction.Move)
        elseif self.data.ride == SceneConstData.unitstate_fly then
            if self.ride_fly then
                self:PlayAction(SceneConstData.UnitAction.Move)
            else
                self:PlayAction(SceneConstData.UnitAction.FlyMove)
            end
        elseif self.data.ride == SceneConstData.unitstate_ride then
            self:PlayAction(SceneConstData.UnitAction.Move)
        end
    else
        self:PlayAction(SceneConstData.UnitAction.Move)
    end
end

--在下一帧更新时取到当前播放的动作的时长 =。=
--也只能这样了，unity就是蛋疼,在animator里面取animation的信息很麻烦，很多网上的方法能用，但不适合本项目生成的那套动作
function UnitView:DelayUpdate()
    if not BaseUtils.is_null(self.animator) then
        local delay = self.animator:GetCurrentAnimatorStateInfo(0).length
        if delay ~= 0 then
            self.timeId = LuaTimer.Add(delay * 1000, function() self:ActionEnd() end)
        end
    end
end

function UnitView:ActionEnd()
    self:PlayAction(SceneConstData.UnitAction.Stand)
    if self.action_callback ~= nil then
        self.action_callback(self)
        self.action_callback = nil
    end
end

function UnitView:CreateEffect(effectId)
    -- print(debug.traceback())
    if self.tpose == nil then
        print(string.format("tpose 未创建完 %s", effectId))
        return
    end

    local effectData = DataEffect.data_effect[effectId]
    if effectData == nil then
        print(string.format("effect_data 这个特效id数据没有啊 %s", effectId))
        return
    end

    -- local effect = BaseEffectView.New({ effectId = effectData.res_id, callback = callback })
    local key = tostring(effectData.id)
    if self.effectdict[key] == nil then
        local callback = function(effect)
            if not BaseUtils.is_null(self.gameObject) then
                self:BindEffect(effectData, self.tpose, effect.gameObject)
                effect.gameObject.name = string.format("Effect%s", effect.gameObject.name)
            else
                GameObject.DestroyImmediate(effect.gameObject)
                effect.gameObject = nil
            end
        end
        local effect = BaseEffectView.New({ effectId = effectData.res_id, callback = callback })
        self.effectdict[key] = {effect = effect, effectId = effectData.id}
    end
end

function UnitView:BindEffect(effectData, tpose, effect)
    if effectData.mounter == EffectDataMounter.Custom then
        local mounter = BaseUtils.GetChildPath(tpose.transform, effectData.mounter_str)
        if mounter ~= "" then
            local m = tpose.transform:Find(mounter)
            if m ~= nil then
                effect.transform:SetParent(m)
                self:EffectSetting(effect)
            end
        end
    elseif effectData.mounter == EffectDataMounter.Origin then
        effect.transform:SetParent(tpose.transform)
        self:EffectSetting(effect)
    elseif effectData.mounter == EffectDataMounter.TopOrigin then
        effect.transform:SetParent(self.gameObject.transform)
        self:EffectSetting(effect)
        effect.transform.localPosition = Vector3(0, 0.75, 0)
    elseif effectData.mounter == EffectDataMounter.Weapon then
        local lmounter = BaseUtils.GetChildPath(tpose.transform, "Bip_L_Weapon")
        local rmounter = BaseUtils.GetChildPath(tpose.transform, "Bip_R_Weapon")
        if lmounter ~= "" or rmounter ~= "" then
            local clone = false
            if lmounter ~= "" then
                local lm = tpose.transform:Find(lmounter)
                if lm ~= nil then
                    effect.transform:SetParent(lm)
                    self:EffectSetting(effect)
                    clone = true
                end
            end
            if rmounter ~= "" then
                local rm = tpose.transform:Find(rmounter)
                if rm ~= nil then
                    -- if clone  then
                    --     local reffect = nil
                    --     if #effectlist > 1 then
                    --         reffect = effectlist[2]
                    --     else
                    --         reffect = GameObject.Instantiate(effect)
                    --         table.insert(effectlist, reffect)
                    --     end
                    --     reffect.transform:SetParent(rm)
                    --     self:EffectSetting(reffect)
                    -- else
                        effect.transform:SetParent(rm)
                        self:EffectSetting(effect)
                    -- end
                end
            end
        else
            effect.transform:SetParent(tpose.transform)
            self:EffectSetting(effect)
        end
    else
        local mounterPath = nil
        if effectData.mounter == EffectDataMounter.Wing then
            mounterPath = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
        elseif effectData.mounter == EffectDataMounter.WingL1 then
            -- 看以后需求改
            mounterPath = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
        else
            mounterPath = BaseUtils.GetChildPath(tpose.transform, "bp_wing")
        end
        if mounterPath ~= nil then
            local mounter = tpose.transform:Find(mounterPath)
            if mounter ~= nil then
                effect.transform:SetParent(mounter)
                self:EffectSetting(effect)
            end
        end
    end
end

function UnitView:EffectSetting(effect)
    effect.transform.localScale = Vector3(1, 1, 1)
    effect.transform.localPosition = Vector3(0, 0, 0)
    effect.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(effect.transform, "Model")
    effect:SetActive(true)
end

function UnitView:ShowEffect(effectId, show)
    local effectData = DataEffect.data_effect[effectId]
    if effectData ~= nil then
        local key = tostring(effectData.id)
        local data = self.effectdict[key]
        if data ~= nil then
            data.effect:SetActive(show)
        end
    end
end

function UnitView:DestroyEffect(effectId)
    local effectData = DataEffect.data_effect[effectId]
    if effectData ~= nil then
        local key = tostring(effectData.id)
        local data = self.effectdict[key]
        if data ~= nil then
            -- GameObject.Destroy(data.effect)
            data.effect:DeleteMe()
            self.effectdict[key] = nil
        end
    end
end

function UnitView:CleanAllEffect()
    for k,v in pairs(self.effectdict) do
        v.effect:DeleteMe()
    end
    self.effectdict = {}
end

-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------
-------------------------------------------------------

-- 设置胶囊型碰撞体大小(玩家)
function UnitView:SetCapsuleCollider(radius, height, center)
    if self.gameObject == nil or BaseUtils.is_null(self.gameObject)then
        return
    else
        local collider = self.gameObject:GetComponent(CapsuleCollider)
        if not BaseUtils.is_null(collider) then
            collider.radius = radius
            collider.height = height
            collider.center = Vector3(0, center, 0)
        end
    end
end

-- 设置方形碰撞体大小(场景单位)
function UnitView:SetBoxCollider(collider_data)
    if self.gameObject == nil or BaseUtils.is_null(self.gameObject) or collider_data == nil then
        return
    else
        local collider = self.gameObject:GetComponent(BoxCollider)
        if collider_data ~= nil and #collider_data == 6 then
            collider.center = Vector3(tonumber(collider_data[1].val), tonumber(collider_data[2].val), tonumber(collider_data[3].val))
            collider.size = Vector3(tonumber(collider_data[4].val), tonumber(collider_data[5].val), tonumber(collider_data[6].val))
        else
            collider.center = Vector3(0, 0.5, 0)
            collider.size = Vector3(0.5, 1, 0.5)
        end
    end
end

-- 设置模型缩放大小
function UnitView:SetScale(scale)
    self.scale = scale
    if not BaseUtils.is_null(self.tpose) then
        local scale_now = self.scale
        if self.baseData ~= nil then scale_now = scale_now * self.baseData.scale / 100 end
        self.tpose.transform.localScale = Vector3(scale_now, scale_now, scale_now)
    end
end

-- 设置名字前缀颜色
function UnitView:SetNameColor(color)
    if self.rolename_object ~= nil then
        self.rolename_object:GetComponent(TextMesh).color = color
    end
end

-- 设置公会名字颜色
function UnitView:SetGuildNameColor(color)
    if self.guildname_object ~= nil then
        self.guildname_object:GetComponent(TextMesh).color = color
    end
end

-- 设置透明状态
function UnitView:SetAlpha(alpha, hard)
    if self.tpose == nil then self.set_alpha = alpha return end
    if self.alpha ~= alpha or hard then
        self.alpha = alpha
        self.controller:SetAlphaChlid(self:GetCachedTposeTransform(), self.alpha)
    end
end

function UnitView:Get_IsMoving()
    return #self.TargetPositionList > 0
end

function UnitView:Get_IsMovingAction()
    return self.lastAction == SceneConstData.UnitAction.Move or self.lastAction == SceneConstData.UnitAction.FlyMove
end

--减少在FixedUpdate和OnTick函数中高频率调用.transform过程中Lua->C#调用的额外消耗
function UnitView:GetCachedTransform()
    if self.cachedTransform == nil then
        self.cachedTransform = self.gameObject.transform;
    end
    return self.cachedTransform
end

function UnitView:GetCachedTposeTransform()
    if self.cachedTposeTransform == nil then
        self.cachedTposeTransform = self.tpose.transform
    end
    return self.cachedTposeTransform
end

function UnitView:ShowFootMarks(foot_mark)
    if self.footMarkPos ~= nil then
        local pos = self.footMarkPos
        local uniqueid = self.data.uniqueid
        local effectid = AchievementManager.Instance.model:getFootSourceId(foot_mark)
        SceneManager.Instance.sceneElementsModel:ShowFootMarks(pos, uniqueid, effectid)
        self.footMarkPos = nil
    end
end
