--
-- @Author: LaoY
-- @Date:   2018-09-26 16:55:13
--
Drop = Drop or class("Drop", SceneObject)

function Drop:ctor()
    self.body_size = {width = 80, height = 85}
    self.img_size = {width = 50,height = 50}
    self.icon_con = PreloadManager:GetInstance():CreateWidget("system", "EmptyImage")
    self.icon_con_transform = self.icon_con.transform
    self.icon_con_transform:SetParent(self.model_parent)
    SetLocalPosition(self.icon_con_transform,0,0,0)
    SetLocalScale(self.icon_con_transform, 0.01, 0.01, 0.01)
    SetSizeDelta(self.icon_con_transform, self.img_size.width, self.img_size.height)

    self.is_loaded = true
    self.icon_img = self.icon_con:GetComponent("Image")

    self:LoadItem()
    if self.position then
        self:SetPosition(self.position.x, self.position.y)
    end
    -- if self.object_info.drop_type == 2 then
    -- end
    self.create_drop_time = Time.time
    self.is_in_pickuping = false

    self:UpdateBuff()
end

function Drop:dctor()
    self:StopTime()
    self:StopDestroyAction()
    self:StopFountain()
    self:StopGoldFountaion()
    self:DelGoldFountaionEffect()
    if self.is_in_pickuping then
        local main_role = SceneManager:GetInstance():GetMainRole()
        main_role:SetPickupingState(false)
    end
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
    if self.icon_con then
        if not poolMgr:AddGameObject("system", "EmptyImage",self.icon_con) then
            destroy(self.icon_con)
        end
        self.icon_con = nil
    end
    self.icon_con_transform = nil

    self:DelDropEffect()

    if self.role_buff_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_buff_event_id)
        self.role_buff_event_id = nil
    end
end

function Drop:AddEvent()
    local function call_back()
        self:UpdateBuff()
    end
    self.role_buff_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("buffs", call_back)
end

function Drop:UpdateBuff()
    local buff_effect_type
    local sceneId = SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        return
    end
    if config.type ~= enum.SCENE_TYPE.SCENE_TYPE_BOSS then
        return
    end
    local max_tired = 1
    -- 
     if config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_WORLD_BOSS
     or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD 
     or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME
     or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WILD
    then
        buff_effect_type = enum.BUFF_EFFECT.BUFF_EFFECT_BOSSTIRED
        max_tired = String2Table(Config.db_game.boss_tired.val)[1]
    elseif config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then
        buff_effect_type = enum.BUFF_EFFECT.BUFF_EFFECT_BEASTBOSSTIRED
        max_tired = String2Table(Config.db_game.boss_tired.val)[1]
    else
        return
    end
    local buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(buff_effect_type)
    local bo = false
    if buff_id then
        local buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(buff_id)
        if buff then
            bo = buff.value == max_tired
        end
    end
    if self.is_have_tired_buff == bo then
        return
    end
    self.is_have_tired_buff = bo
    self:UpdateState()
end

function Drop:UpdateState()
	local bo = self.object_info:IsBelongSelf() or not self.is_have_tired_buff
    self:ShowBody(bo)
    self.name_container:SetVisible(bo)
end

function Drop:IsCanPick()
    return self.object_info:IsBelongSelf() or 
    (not self.is_have_tired_buff and not self.object_info:IsLock())
end

function Drop:InitData(object_id)
    Drop.super.InitData(self, object_id)
end

function Drop:LoadItem()
    if not self.object_info or not self.object_info.id then
        return
    end
    local config = Config.db_item[self.object_info.id]
    if not config then
        return
    end
    if config.type == enum.ITEM_TYPE.ITEM_TYPE_MONEY then
        self.object_info.num = 0
    end
    if config.name then
        local name
        if config.type == enum.ITEM_TYPE.ITEM_TYPE_MONEY then
            name = ""
        -- 镇炎说不用的，我注释掉了
        -- elseif self.object_info.num > 1 then
        --     name =
        --         string.format(
        --         "<color=#%s>%sx%s</color>",
        --         ColorUtil.GetColor(config.color),
        --         config.name,
        --         self.object_info.num
        --     )
        else
            name = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(config.color), config.name)
        end
        self.name_container:SetName(name)
        self.parent_transform.name = name
    end

    -- local abName = GoodIconUtil.GetInstance():GetABNameById(config.icon)
    -- abName = "iconasset/" .. abName
    local abName = "system_image"
    local assetName = "drop_" .. config.drop_icon
    --local assetName = "drop_icon_1"
    --if config.type == enum.ITEM_TYPE.ITEM_TYPE_MONEY then
    --    assetName = "drop_icon_1"
    --elseif config.type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
    --    assetName = "drop_icon_3"
    --else
    --    assetName = "drop_icon_2"
    --end

    self.name_container:SetVisible(false)
    local function call_back(sprite)
        self.icon_img.sprite = sprite
        self.icon_img:SetNativeSize()
        self:StartFountain()
    end
    lua_resMgr:SetImageTexture(self, self.icon_img, abName, assetName, true, call_back)
end

function Drop:SetDropInfo()
    self:DelDropEffect()
    local config = Config.db_item[self.object_info.id]
    if config and config.trea_effect == 1 then
       self.drop_effect = self:SetTargetEffect("effect_ui_diaoluocheng", true,nil,pos(0,self.img_size.height*0.5 * 0.01))
    elseif config and config.trea_effect == 2 then
       self.drop_effect = self:SetTargetEffect("effect_ui_diaoluohong", true,nil,pos(0,self.img_size.height*0.5 * 0.01))
    end
    
	self:UpdateState()

    local scene_id = SceneManager:GetInstance():GetSceneId()
    local cf = Config.db_scene[scene_id]
    local is_gold_dungeon = false
    if cf and cf.type == enum.SCENE_TYPE.SCENE_TYPE_DUNGE and cf.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COIN then
        is_gold_dungeon = true
    end

    local pItem = EquipModel:GetInstance():GetEquipBySlot(enum.ITEM_STYPE.ITEM_STYPE_FAIRY)
    if pItem then
        local  IsExpire = BagModel:GetInstance():IsExpire(pItem.etime)
        local  item_id = EquipModel:GetInstance():GetEquipDevil()
        local config = Config.db_fairy[item_id]
        if  config then
            if not IsExpire and self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY  and config.pickup  == 1  then
                self:StartGoldFountain()
            end
        end
    end

    -- if is_gold_dungeon and self.object_info.drop_type == 2 and enum.ITEM.ITEM_COIN == self.object_info.id then
    if self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY2  then
        self:StartGoldFountain()
    end
end

function Drop:DelDropEffect()
    if self.drop_effect then
        self.drop_effect:destroy()
        self.drop_effect = nil
    end
end

function Drop:StartFountain()
    self:StopFountain()
    if not self.object_info.from_pos then
        self:SetDropInfo()
        return
    end
    local start_pos =
        Vector2(self.object_info.from_pos.x + math.random(25) * 3, self.object_info.from_pos.y + math.random(25) * 3)
    self:SetPosition(start_pos.x, start_pos.y)
    local end_pos = Vector2(self.object_info.coord.x, self.object_info.coord.y)
    local distance = Vector2.Distance(start_pos, end_pos)
    local radian = math.angle2radian(60)
    local cos = math.cos(radian)
    local dir = GetDirByVector(start_pos, end_pos, distance)
    local dis1 = distance * 0.3
    local dis2 = distance * 0.6
    local config = {
        control_1 = Vector2(start_pos.x + dir.x * dis1, start_pos.y + 200 + cos * (distance - dis1)),
        control_2 = Vector2(start_pos.x + dir.x * dis2, start_pos.y + 200 + cos * (distance - dis2)),
        end_pos = end_pos
    }
    local action = cc.BezierTo(0.6, config)
    action = cc.EaseInOut(action, 0.5)
    local function call_back()
        if self.is_dctored then
            return
        end
        self:StopFountain()
        self:SetDropInfo()
    end
    local call_action = cc.CallFunc(call_back)
    action = cc.Sequence(action, call_action)
    self.fountain_action = cc.ActionManager:GetInstance():addAction(action, self)
end

function Drop:StopFountain()
    if self.fountain_action then
        cc.ActionManager:GetInstance():removeAction(self.fountain_action)
        self.fountain_action = nil
    end
end

function Drop:StartGoldFountain()
    self:StopGoldFountaion()

    if not self.gold_action_gameobject then 
        self.gold_action_gameobject = GameObject("gold")
        self.gold_action_gameobject.transform:SetParent(self.model_parent)
        SetLocalPosition(self.gold_action_gameobject.transform,0,0,0)
        self.gold_action_gameobject:SetActive(false)
        self.gold_fountain_effect = self:SetTargetEffect("effect_ui_zidongshiqu",true,self.gold_action_gameobject.transform)
    end

    local main_role = SceneManager:GetInstance():GetMainRole()
    local main_pos = main_role:GetPosition()
    local height = main_role:GetBodyHeight()
    local start_pos = pos(self.position.x, self.position.y)
    local end_pos = pos(main_pos.x,main_pos.y + height * 0.8)
    local distance = Vector2.Distance(start_pos, end_pos)
    local radian = math.angle2radian(60)
    local dir = GetDirByVector(start_pos, end_pos, distance)
    local dis1 = distance * 0.5
    local config = {
        control_1 = pos(start_pos.x, end_pos.y + height),
        control_2 = pos(start_pos.x + dir.x * dis1, end_pos.y + height * 2),
        end_pos = end_pos
    }
    local bezier_time = self:GetBeziertime(distance)
    local bezier_action = cc.BezierTo(bezier_time, config)
    local action = cc.DelayTime(0.5)
    local call_action = cc.CallFunc(function()
        if self.gold_action_gameobject then
            self.gold_action_gameobject:SetActive(true)
        end

        if self.icon_con then
            SetVisible(self.icon_con,false)
        end
    end)
    action = cc.Sequence(action, call_action,bezier_action)
    local function call_back_2()
        self:destroy()
    end
    action = cc.Sequence(action,cc.DelayTime(0.1),cc.CallFunc(call_back_2))
    cc.ActionManager:GetInstance():addAction(action,self)
    self.gold_fountaion_action = action

    self.bezier_config = {
        bezier_action = bezier_action,
        start_pos = pos(start_pos.x,start_pos.y),
        end_pos = pos(main_pos.x,main_pos.y + height * 0.8)
    }
end

function Drop:GetBeziertime(distance)
    return distance/500 * 3.14 * 0.5
end

function Drop:DelGoldFountaionEffect()
    if self.gold_fountain_effect then
        self.gold_fountain_effect:destroy()
        self.gold_fountain_effect = nil
    end
end

function Drop:StopGoldFountaion()
    if self.gold_fountaion_action then
        cc.ActionManager:GetInstance():removeAction(self.gold_fountaion_action)
        self.gold_fountaion_action = nil
    end
end



function Drop:SetNameColor()
    self.name_container:SetColor(Color.green, Color.black)
end

function Drop:IsCanOClick()
    if self.object_info and (self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_BAG or 
        self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY2) then
        return false
    end

    if self.has_be_pick then
        return false
    end

    if not self:IsCanPick() then
        return false
    end

    -- if self.is_have_tired_buff then
    --     return false
    -- end

    if self.fountain_action then
        return false
    end
    if not self.is_loaded then
        return false
    end
    return true
end

function Drop:OnClick(autoNext)
    self.is_auto_pick_next = autoNext
    local main_role = SceneManager:GetInstance():GetMainRole()
    local main_pos = main_role:GetPosition()
    local distance = Vector2.DistanceNotSqrt(main_pos, self.position)
    local range_square = SceneConstant.DropRange * SceneConstant.DropRange
    if distance > range_square then
        local function call_back()
            if self.is_dctored then
                return
            end
            self:OnClick(autoNext)
        end
        local move_dis = math.max(math.sqrt(distance), 0)
        local end_pos = GetDirDistancePostion(main_pos, self.position, move_dis)
        OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, end_pos, call_back,1)
    end
    return true
end

local last_time = 0
function Drop.ShowTip()
    if Time.time - last_time > 3.0 then
        Notify.ShowText("You can't loot items from monsters slain by other players")
    end
end

function Drop:OnMainRoleStop()
    if self.is_dctored then
        return
    end
    self:StopTime()
    local main_role = SceneManager:GetInstance():GetMainRole()
    if main_role:IsPickuping() then
        return
    end

    if self.has_be_pick then
        return
    end

    if not self:IsCanPick() then
        if not self.is_show_tip and self.isShowBody then
            self.is_show_tip = true
            Drop.ShowTip()
        end
        return
    end

    -- if self.is_have_tired_buff then
    --     return
    -- end

    if self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY2 then
        return
    end

    local main_pos = main_role:GetPosition()
    main_pos = {x = main_pos.x, y = main_pos.y}

    if self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_BAG or 
        self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_SCENE then
        local scene_id = SceneManager:GetInstance():GetSceneId()
        GlobalEvent:Brocast(FightEvent.ReqPickUp, self.object_id, scene_id)
    end
    -- main_role:SetPickupingState(true)
    self.is_in_pickuping = true
    
    local function step()
        local cur_pos = main_role:GetPosition()
        if main_pos.x ~= cur_pos.x or main_pos.y ~= cur_pos.y then
            return
        end
        -- main_role:SetPickupingState(false)
        if self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_BAG or 
            self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_SCENE  then
            -- GlobalEvent:Brocast(FightEvent.ReqPickUp, self.object_id, 2)
            self.is_in_pickuping = false           
        elseif self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY then
            local tab = {
                coord = self.position,
                id = self.object_info.id,
                num = self.object_info.num
            }
            GlobalEvent:Brocast(FightEvent.AccPickUp, self.object_info.uid)--tab)
            self.is_in_pickuping = false            
            --self:destroy()
        end
        self.has_be_pick = true
    end
    -- self.time_id_pick_up = GlobalSchedule:StartOnce(step, 0)
    step()

    if self.is_auto_pick_next and OperationManager:GetInstance():IsSameTargetPos(self.position) then
        local drop_object = SceneManager:GetInstance():GetDropInScreen()
        if drop_object then
            drop_object:OnClick(true)
            return
        end
    end
end

function Drop:OnMainRoleTouch()
    self:OnMainRoleStop()
end

function Drop:StopTime()
    if self.time_id_pick_up then
        GlobalSchedule:Stop(self.time_id_pick_up)
    end
end

function Drop:CheckInBound(x, y)
    if
        x < (self.position.x - self.body_size.width / 2) or x > (self.position.x + self.body_size.width / 2) or
            y < (self.position.y - self.body_size.height / 2) or
            y > (self.position.y + self.body_size.height / 2)
     then
        return false
    end
    return true
end

function Drop:GetBodyHeight()
    return self.body_size.height / 2
end

function Drop:Update(delta_time)
    if self.is_dctored then
        return
    end
    if self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY or 
    self.object_info.drop_type == enum.DROP_MODE.DROP_MODE_DUMMY2 then
        if self.create_drop_time and Time.time - self.create_drop_time > 30 then
            self:destroy()
        end
    end

    if self.bezier_config and not self.bezier_config.bezier_action:isDone() then
        local progress = self.bezier_config.bezier_action:getProgress()
        if (progress == 0 or progress > 0.5) then
            local main_role = SceneManager:GetInstance():GetMainRole()
            local main_pos = main_role:GetPosition()
            local height = main_role:GetBodyHeight()
            local start_pos = pos(self.bezier_config.start_pos.x, self.bezier_config.start_pos.y)
            local end_pos = pos(main_pos.x,main_pos.y + height * 0.8)
            local distance = Vector2.Distance(start_pos, end_pos)
            if end_pos.x ~= self.bezier_config.end_pos.x or end_pos.y ~= self.bezier_config.end_pos.y then
                local bezier_time = self:GetBeziertime(distance)
                self.bezier_config.bezier_action._duration = bezier_time
                if progress == 0 then
                    local radian = math.angle2radian(60)
                    local dir = GetDirByVector(start_pos, end_pos, distance)
                    local dis1 = distance * 0.5
                    local config = {
                        control_1 = pos(start_pos.x, end_pos.y + height),
                        control_2 = pos(start_pos.x + dir.x * dis1, end_pos.y + height * 2),
                        end_pos = end_pos
                    }
                    self.bezier_config.bezier_action._toConfig = config
                    self.bezier_config.bezier_action:InitConfig()
                else
                    self.bezier_config.bezier_action._toConfig.end_pos.x = end_pos.x
                    self.bezier_config.bezier_action._toConfig.end_pos.y = end_pos.y
                    self.bezier_config.bezier_action:InitConfig()
                end

                self.bezier_config.end_pos.x = end_pos.x
                self.bezier_config.end_pos.y = end_pos.y
            end
        end
        
    end
end

function Drop:destroyWithPick()
    self:StopDestroyAction()
    self.is_destroying = true
    self.destroyAction =
        cc.Sequence(
        cc.MoveTo(0.2, self.position.x, self.position.y + 80, self.position.z),
        cc.CallFunc(
            function()
            	self.is_destroying = false
                self:destroy()
            end
        )
    )
    cc.ActionManager:GetInstance():addAction(self.destroyAction, self)    
end

function Drop:destroyWithAutoPick()
    if not lastObjectId then
        lastObjectId = self.object_id
    end
    self:StartGoldFountain()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
    self.schedule = GlobalSchedule.StartFun(handler(self, self.Update), 0, -1)
end

function Drop:StopDestroyAction()
    self.is_destroying = false
    if self.destroyAction then
        cc.ActionManager:GetInstance():removeAction(self.destroyAction)
        self.destroyAction = nil
    end
end

function Drop:GetDepth(y)
    --logError("self.is_in_pickuping------>" .. tostring(self.is_in_pickuping))
    if self.is_destroying or self.gold_fountaion_action then
        y = 0
    else
        y = MapManager:GetInstance().map_pixels_height
    end

    return LayerManager:GetInstance():GetSceneObjectDepth(y or 0)
end
