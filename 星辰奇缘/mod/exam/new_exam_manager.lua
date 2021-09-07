NewExamManager = NewExamManager or BaseClass(BaseManager)

function NewExamManager:__init()
    if NewExamManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    NewExamManager.Instance = self;
    self:InitHandler()

    self.model = NewExamModel.New()

    self.OnUpdateQuestionData = EventLib.New()
    self.OnUpdateRankData = EventLib.New()

    self.bornPointList = {
        {
             { x = 1150, y = 740 }
            ,{ x = 1000, y = 760 }
            ,{ x = 960, y = 660 }
            ,{ x = 1110, y = 600 }
            ,{ x = 900, y = 630 }
            ,{ x = 930, y = 600 }
        }
        , {
            { x = 1480, y = 720 }
            ,{ x = 1420, y = 780 }
            ,{ x = 1570, y = 760 }
            ,{ x = 1410, y = 600 }
            ,{ x = 1530, y = 660 }
            ,{ x = 1530, y = 580 }
        }
    }

    self.zoneA_x1 = 0
    self.zoneA_x2 = 1280
    self.zoneA_y1 = 400
    self.zoneA_y2 = 900
    self.zoneB_x1 = 1280
    self.zoneB_x2 = 2380
    self.zoneB_y1 = 270
    self.zoneB_y2 = 930

    self.jumpPointA_X = 1142
    self.jumpPointA_Y = 667
    self.jumpPointB_X = 1390
    self.jumpPointB_Y = 680

    self.jumpZoneA_x1 = 1080
    self.jumpZoneA_x2 = 1275
    self.jumpZoneA_y1 = 630
    self.jumpZoneA_y2 = 705
    self.jumpZoneB_x1 = 1275
    self.jumpZoneB_x2 = 1440
    self.jumpZoneB_y1 = 660
    self.jumpZoneB_y2 = 720
end

function NewExamManager:__delete()
    self.OnUpdateQuestionData:DeleteMe()
    self.OnUpdateQuestionData = nil
    self.OnUpdateRankData:DeleteMe()
    self.OnUpdateRankData = nil

    self.model:DeleteMe()
    self.model = nil
end

function NewExamManager:InitHandler()
    self:AddNetHandler(20100,self.on20100)
    self:AddNetHandler(20101,self.on20101)
    self:AddNetHandler(20102,self.on20102)
    self:AddNetHandler(20103,self.on20103)
    self:AddNetHandler(20104,self.on20104)
    self:AddNetHandler(20105,self.on20105)
    self:AddNetHandler(20106,self.on20106)
    self:AddNetHandler(20107,self.on20107)
    self:AddNetHandler(20108,self.on20108)
    self:AddNetHandler(20109,self.on20109)

    self.on_role_change = function(data)
        self:send20100()
    end
    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)

    EventMgr.Instance:AddListener(event_name.role_event_change, function(event, old_event) self:UpdateEvent(event, old_event) end)
end

function NewExamManager:RequestInitData()
    self:send20100()

    self.model:RequestInitData()
end

---------------------------------------协议接收逻辑
function NewExamManager:send20100()
    -- print("<color='#ff0000'>send20100</color>")
    Connection.Instance:send(20100, {})
end

function NewExamManager:on20100(data)
    -- BaseUtils.dump(data, "<color='#ff0000'>on20100</color>")
    self.model.status = data.status
    self.model.endtime = data.endtime

    self.model:UpdateIcon()
    self:UpdateEvent(RoleManager.Instance.RoleData.event)
end

function NewExamManager:send20101()
    Connection.Instance:send(20101, {})
end

function NewExamManager:on20101(data)
    -- BaseUtils.dump(data, "on20101")
    self.model.questionData = data
    self.model.lessTime = data.endtime - BaseUtils.BASE_TIME
    self.OnUpdateQuestionData:Fire()
end

function NewExamManager:send20102()
    Connection.Instance:send(20102, {})
end

function NewExamManager:on20102(data)
    -- BaseUtils.dump(data, "on20102")
    for i=1, #data.choose_info do
        if data.choose_info[i].choose == 1 then
            self.model.chooseA_count = data.choose_info[i].count
        else
            self.model.chooseB_count = data.choose_info[i].count
        end
    end
    self.OnUpdateQuestionData:Fire()
end

function NewExamManager:send20103()
    Connection.Instance:send(20103, {})
end

function NewExamManager:on20103(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NewExamManager:send20104()
    -- print("NewExamManager:send20104()")
    -- Log.Error("发送了小猪的退出协议")
    -- Log.Error(debug.traceback())
    Connection.Instance:send(20104, {})
end

function NewExamManager:on20104(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.err_code == 1 then
        self.model.questionData = nil
        self.model.myQuestionData = nil
        self.model.questionRankData = {}
    end
end

function NewExamManager:send20105(choose)
    Connection.Instance:send(20105, { choose = choose })
end

function NewExamManager:on20105(data)
    -- BaseUtils.dump(data, "on20105")
    self.model.last_choose = data.choose
    self.OnUpdateQuestionData:Fire()

    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function NewExamManager:send20106()
    Connection.Instance:send(20106, {})
end

function NewExamManager:on20106(data)
    BaseUtils.dump(data, "on20106")
    self.model.questionRankData = data.rank_list
    self.OnUpdateRankData:Fire()
end

function NewExamManager:send20107()
    Connection.Instance:send(20107, {})
end

function NewExamManager:on20107(data)
    -- BaseUtils.dump(data, "on20107")
    self.model.myQuestionData = data
    local exp = 0
    for k,v in ipairs(data.his_items) do
        if v.assets == 90010 then
            exp = exp + v.val
        end
    end
    self.model.myQuestionData.exp = exp
    self.model.last_choose = data.choose
    self.OnUpdateQuestionData:Fire()
end

function NewExamManager:send20108()
    Connection.Instance:send(20108, {})
end

function NewExamManager:on20108(data)
    -- BaseUtils.dump(data, "on20108")
    for i=1, #self.model.questionRankData do
        local rankData = self.model.questionRankData
        if rankData.id == data.id and rankData.platform == data.platform and rankData.zone_id == data.zone_id then
            rankData.choose = data.rankData
        end
    end
    self.OnUpdateRankData:Fire()
end

function NewExamManager:send20109()
    Connection.Instance:send(20109, {})
end

function NewExamManager:on20109(data)
    -- BaseUtils.dump(data, "on20109")
    self.model.rank_list = data.rank_list
    self.model.self_rank = 0
    local roleData = RoleManager.Instance.RoleData
    for k,v in ipairs(data.rank_list) do
        if roleData.id == v.rid and roleData.platform == v.platform and roleData.zone_id == v.zone_id then
            self.model.self_rank = v.rank
        end
    end

    if #self.model.rank_list == 0 then
        NoticeManager.Instance:FloatTipsByString(TI18N("答题还没开始呢{face_1,1}第一题后才有排行哦{face_1,7}"))
    else
        self.model:OpenNewExamRank()
    end
end

--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------
function NewExamManager:UpdateEvent(event, old_event)
    if event == RoleEumn.Event.NewQuestionMatch then
        SceneManager.Instance.sceneElementsModel:Show_Self_Pet(false)
        if self.model.status == 1 then
            self.model:CloseNewExamTop()
        elseif self.model.status == 2 then
            self.model:OpenNewExamTop()
            if MainUIManager.Instance.MainUIIconView ~= nil then
                MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {})
                MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, true)
            end
            MainUIManager.Instance:HideRoleInfo()
            MainUIManager.Instance:HidePetInfo()
            MainUIManager.Instance:HideMapInfo()
        end

        if self.model.questionData == nil then
            self:send20101()
        end
        if self.model.myQuestionData == nil then
            self:send20107()
        end
        if self.model.questionRankData == nil then
            self:send20106()
        end

        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(self.model.limitStatus == 1)
    elseif old_event == RoleEumn.Event.NewQuestionMatch then
        SceneManager.Instance.sceneElementsModel:Show_Self_Pet(true)
        self.model:CloseNewExamTop()
        if MainUIManager.Instance.MainUIIconView ~= nil then
            MainUIManager.Instance.MainUIIconView:Set_ShowTop(true)
            MainUIManager.Instance.MainUIIconView:hide_icon_by_idlist(303, false)
        end
        MainUIManager.Instance:ShowRoleInfo()
        MainUIManager.Instance:ShowPetInfo()
        MainUIManager.Instance:ShowMapInfo()

        SceneManager.Instance.MainCamera:SetOffsetTargetvalue(0)

        SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson) == true)
    end
end

-- 是否在别的区
function NewExamManager:IsOtherZone(target, x, y)
    if target.gameObject == nil then return false end
    if SceneManager.Instance:CurrentMapId() ~= 53001 then return false end

    local targetZone = 0
    local p = target:GetCachedTransform().localPosition
    p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
    if p.x > self.zoneA_x1 and p.x < self.zoneA_x2 and p.y > self.zoneA_y1 and p.y < self.zoneA_y2 then
        targetZone = 1
    elseif p.x > self.zoneB_x1 and p.x < self.zoneB_x2 and p.y > self.zoneB_y1 and p.y < self.zoneB_y2 then
        targetZone = 2
    end

    local clickZone = 0
    p = SceneManager.Instance.sceneModel:transport_big_pos(x, y)
    if p.x > self.zoneA_x1 and p.x < self.zoneA_x2 and p.y > self.zoneA_y1 and p.y < self.zoneA_y2 then
        clickZone = 1
    elseif p.x > self.zoneB_x1 and p.x < self.zoneB_x2 and p.y > self.zoneB_y1 and p.y < self.zoneB_y2 then
        clickZone = 2
    end

    if targetZone ~= 0 and clickZone ~= 0 then
        if targetZone ~= clickZone then
            if targetZone == 1 then
                self:GotoJumpPointA()
                if self.model.status == 2 and self.model.last_choose ~= 2 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("已经选择答案B{face_1,3}"))
                end
                return true
            else
                self:GotoJumpPointB()
                if self.model.status == 2 and self.model.last_choose ~= 1 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("已经选择答案A{face_1,3}"))
                end
                return true
            end
        elseif self.model.status == 2 then
            if clickZone == 1 then
                if self.model.last_choose ~= 1 then
                    NewExamManager.Instance:send20105(1)
                end
            else
                if self.model.last_choose ~= 2 then
                    NewExamManager.Instance:send20105(2)
                end
            end
        end
    end

    return false
end

-- 是否在跳跃区域
function NewExamManager:IsJumpZone(target)
    if SceneManager.Instance:CurrentMapId() ~= 53001 then return end

    local jumpToZone = 0
    local targetPoint = target:GetCachedTransform().localPosition
    targetPoint = SceneManager.Instance.sceneModel:transport_big_pos(targetPoint.x, targetPoint.y)
    if targetPoint.x > self.jumpZoneA_x1 and targetPoint.x < self.jumpZoneA_x2 and targetPoint.y > self.jumpZoneA_y1 and targetPoint.y < self.jumpZoneA_y2 then
        jumpToZone = 2
    elseif targetPoint.x > self.jumpZoneB_x1 and targetPoint.x < self.jumpZoneB_x2 and targetPoint.y > self.jumpZoneB_y1 and targetPoint.y < self.jumpZoneB_y2 then
        jumpToZone = 1
    end

    if jumpToZone ~= 0 then
        local jumpEndPoint = nil
        -- local gotoPoint = nil
        if jumpToZone == 1 then
            -- gotoPoint = self.bornPointList[1][Random.Range(1, #self.bornPointList[1])]
            -- jumpEndPoint = { x = 1200, y = targetPoint.y }
            jumpEndPoint = self.bornPointList[1][Random.Range(1, #self.bornPointList[1])]
            if self.model.status == 2 and self.model.last_choose ~= 1 then
                NewExamManager.Instance:send20105(1)
            end
        else
            -- gotoPoint = self.bornPointList[2][Random.Range(1, #self.bornPointList[2])]
            -- jumpEndPoint = { x = 2040, y = targetPoint.y }
            jumpEndPoint = self.bornPointList[2][Random.Range(1, #self.bornPointList[2])]
            if self.model.status == 2 and self.model.last_choose ~= 2 then
                NewExamManager.Instance:send20105(2)
            end
        end

        SceneManager.Instance.sceneElementsModel:Self_StopMove()
        SceneManager.Instance.sceneElementsModel:Set_isovercontroll(false)
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view.noSendMove = true
        end
        local roleJump = SceneJump.New()
        roleJump.callback = function()
            SceneManager.Instance.sceneElementsModel:Set_isovercontroll(true)
            if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
                SceneManager.Instance.sceneElementsModel.self_view.noSendMove = false
            end
            roleJump:DeleteMe()
            -- local p = SceneManager.Instance.sceneModel:transport_small_pos(gotoPoint.x, gotoPoint.y)
            -- SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(p.x, p.y)

            -- if self.model.last_choose == 2 and self:InZoneA() then
            --     self:GotoJumpPointA()
            -- elseif self.model.last_choose == 1 and self:InZoneB() then
            --     self:GotoJumpPointB()
            -- end
        end
        roleJump:Show({ val = { targetPoint, jumpEndPoint } })
    end
end

-- 检查自己是否在跳跃点上
function NewExamManager:CheckOnArena()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.NewQuestionMatch then
        return
    end

    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        if not SceneManager.Instance.sceneElementsModel.self_view.noSendMove then
            self:IsJumpZone(SceneManager.Instance.sceneElementsModel.self_view)
        end
    end
end

function NewExamManager:InZoneA()
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local p = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().localPosition
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        if p.x > self.zoneA_x1 and p.x < self.zoneA_x2 and p.y > self.zoneA_y1 and p.y < self.zoneA_y2 then
            return true
        end
    end
    return false
end

function NewExamManager:InZoneB()
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        local p = SceneManager.Instance.sceneElementsModel.self_view:GetCachedTransform().localPosition
        p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        if p.x > self.zoneB_x1 and p.x < self.zoneB_x2 and p.y > self.zoneB_y1 and p.y < self.zoneB_y2 then
            return true
        end
    end
    return false
end

function NewExamManager:GotoJumpPointA()
    if self.model.status == 2 and self.model.last_choose ~= 2 then
        NewExamManager.Instance:send20105(2)
    end
    if self:InZoneA() then
        local p = SceneManager.Instance.sceneModel:transport_small_pos(self.jumpPointA_X, self.jumpPointA_Y)
        SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(p.x, p.y)
    else
        SceneManager.Instance.sceneElementsModel:Self_StopMove()
    end
end

function NewExamManager:GotoJumpPointB()
    if self.model.status == 2 and self.model.last_choose ~= 1 then
        NewExamManager.Instance:send20105(1)
    end
    if self:InZoneB() then
        local p = SceneManager.Instance.sceneModel:transport_small_pos(self.jumpPointB_X, self.jumpPointB_Y)
        SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(p.x, p.y)
    else
        SceneManager.Instance.sceneElementsModel:Self_StopMove()
    end
end

-- 是否在别的区,如果是则跳跃过去（根据别的玩家移动包处理）
function NewExamManager:CheckInOtherZone(target, x, y)
    if target.gameObject == nil then return false end
    if SceneManager.Instance:CurrentMapId() ~= 53001 then return false end

    local targetZone = 0
    local p = target:GetCachedTransform().localPosition
    p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
    if p.x > self.zoneA_x1 and p.x < self.zoneA_x2 and p.y > self.zoneA_y1 and p.y < self.zoneA_y2 then
        targetZone = 1
    elseif p.x > self.zoneB_x1 and p.x < self.zoneB_x2 and p.y > self.zoneB_y1 and p.y < self.zoneB_y2 then
        targetZone = 2
    end

    local clickZone = 0
    -- p = SceneManager.Instance.sceneModel:transport_big_pos(x, y)
    p = { x = x, y = y }
    if p.x > self.zoneA_x1 and p.x < self.zoneA_x2 and p.y > self.zoneA_y1 and p.y < self.zoneA_y2 then
        clickZone = 1
    elseif p.x > self.zoneB_x1 and p.x < self.zoneB_x2 and p.y > self.zoneB_y1 and p.y < self.zoneB_y2 then
        clickZone = 2
    end

    if targetZone ~= 0 and clickZone ~= 0 then
        if targetZone ~= clickZone then
            if targetZone == 1 then
                self:JumpToPoint(target, x, y)
                target.data.x = x
                target.data.y = y
                return true
            else
                self:JumpToPoint(target, x, y)
                target.data.x = x
                target.data.y = y
                return true
            end
        end
    end

    return false
end

function NewExamManager:JumpToPoint(target, x, y)
    target:StopMoveTo()
    local roleJump = SceneJump.New()
    roleJump.callback = function()
        roleJump:DeleteMe()
        target.data.x = x
        target.data.y = y
    end

    local targetPoint = target:GetCachedTransform().localPosition
    targetPoint = SceneManager.Instance.sceneModel:transport_big_pos(targetPoint.x, targetPoint.y)
    local jumpToPoint = { x = x, y = y }
    roleJump:Show({ target = target, val = { targetPoint, jumpToPoint } })
end

function NewExamManager:SetLimit(bool)
    SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(bool)
end

