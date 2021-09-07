-- ---------------------
-- 剧情动作处理
-- hosr
-- ---------------------
DramaActionModel = DramaActionModel or BaseClass(BaseModel)

function DramaActionModel:__init(callback)
    -- 处理完成回调
    self.callback = callback

    -- 动作计步
    self.step = 0
    -- 动作长度
    self.stepMax = 0
    -- 动作列表
    self.actionList = nil

    -- 剧本播放器
    self.plotModel = nil
    -- 同时播放器
    self.mutilPlotModel = nil

    -- 当前动作,需要界面显示的
    self.currentActionPanel = nil

    -- 当前数据
    self.currentActionData = nil

    -- 方法工厂
    self.factory = nil
end

function DramaActionModel:__delete()
    -- print("DramaActionModel:__delete")
    if self.factory ~= nil then
        self.factory:DeleteMe()
        self.factory = nil
    end
    if self.plotModel ~= nil then
        self.plotModel:DeleteMe()
        self.plotModel = nil
    end
    if self.mutilPlotModel ~= nil then
        self.mutilPlotModel:DeleteMe()
        self.mutilPlotModel = nil
    end
    if self.dramaLetter ~= nil then
        self.dramaLetter:DeleteMe()
        self.dramaLetter = nil
    end
    if self.thunder ~= nil then
        self.thunder:DeleteMe()
        self.thunder = nil
    end
end

-- 当前收到的所有动作播放完毕,回调上层
function DramaActionModel:EndActions(allover)
    if self.currentActionPanel ~= nil then
        self.currentActionPanel:Hiden()
    end
    self.step = 0
    self.stepMax = 0
    self.actionList = nil
    if self.callback ~= nil then
        self.callback(allover)
    end
end

-- 收到要播放的动作列表
function DramaActionModel:BeginActions(action_list)
    self.actionList = action_list
    self.step = 0
    self.stepMax = #self.actionList
    -- LuaTimer.Add(200, function() self:Loop() end)
    self:Loop()
end

-- 步骤处理每个动作
function DramaActionModel:Loop()
    if self.waitId ~= nil then
        LuaTimer.Delete(self.waitId)
        self.waitId = nil
    end
    self.step = self.step + 1
    if self.step > self.stepMax then
        self:EndActions()
    else
        self:Dispatcher(self.actionList[self.step])
    end
end

-- 分发到具体动作类处理
function DramaActionModel:Dispatcher(dramaAction)
    -- BaseUtils.dump(dramaAction, "分发动作")
    if SceneManager.Instance.sceneElementsModel.self_view == nil then
        self:Loop()
        return
    end

    self.currentActionData = dramaAction
    if dramaAction.type == DramaEumn.ActionType.Endplot then
        self:EndActions(true)
        if dramaAction.callback ~= nil then
            dramaAction.callback()
        end
    elseif dramaAction.type == DramaEumn.ActionType.Wait or dramaAction.type == DramaEumn.ActionType.WaitClient then
        if self.currentActionPanel ~= nil then
            self.currentActionPanel:Hiden()
        end
        self:Wait(tonumber(dramaAction.val))
    elseif dramaAction.type == DramaEumn.ActionType.Openpanel then
        WindowManager.Instance:OpenWindowById(tonumber(dramaAction.val))
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.Soundplay then
        SoundManager.Instance:Play(dramaAction.res_id)
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.Playguide then
        self:PlayGuide(dramaAction.val)
    elseif dramaAction.type == DramaEumn.ActionType.Playplot then
        self:HideMain()
        if self.currentActionPanel ~= nil then
            self.currentActionPanel:Hiden()
        end
        self:PlayPlot(dramaAction.val)
    elseif dramaAction.type == DramaEumn.ActionType.Multiaction then
        if self.currentActionPanel ~= nil then
            self.currentActionPanel:Hiden()
        end
        self:MutilPlay(dramaAction.val)
    elseif dramaAction.type == DramaEumn.ActionType.CustomMultiaction then
        if self.currentActionPanel ~= nil then
            self.currentActionPanel:Hiden()
        end
        BaseUtils.dump(dramaAction.val,"fdskjfklsdjfklsdjfkljsdklfjsdklf====================================================================================")
        self:CustomMutilPlay(dramaAction.val)

    elseif dramaAction.type == DramaEumn.ActionType.Plotunitcreate then
        DramaVirtualUnit.Instance:CreateUnit(dramaAction)
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.Plotunitdel then
        DramaVirtualUnit.Instance:RemoveUnit(dramaAction)
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.Inter_monologue then
        DramaManager.Instance.model:Feeling(dramaAction)
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.Opensys then
        self:OpenSys(dramaAction)
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.TouchNpc then
        SceneManager.Instance:Send10100(dramaAction.battle_id, dramaAction.unit_id)
        self:Loop()
    elseif dramaAction.type == DramaEumn.ActionType.Unittalkbubble then
        local battleid = dramaAction.battle_id
        local id = dramaAction.unit_id
        local msg = dramaAction.msg
        local time = dramaAction.time
        DramaSceneTalk.Instance:ShowNpcTalk(0, id, battleid, msg, time, function() self:Loop() end)
    elseif dramaAction.type == DramaEumn.ActionType.Roletalkbubble then
        local role = RoleManager.Instance.RoleData
        local msg = dramaAction.msg
        local time = dramaAction.time
        DramaSceneTalk.Instance:ShowPlayerTalk(0, role.id, role.platform, role.zone_id, msg, time, function() self:Loop() end)
    elseif dramaAction.type == DramaEumn.ActionType.Playeffect then
        local data = {}
        data.id = dramaAction.val
        data.time = dramaAction.ext_val / 1000
        data.type = 0
        data.map = 0
        data.x = 0
        data.y = 0
        data.scale = 1
        EffectBrocastManager.Instance:On9907(data)
        self:Wait(tonumber(dramaAction.ext_val))
    else
        if self.factory == nil then
            self.factory = DramaActionFactory.New()
        end
        local func = self.factory:GetAction(dramaAction.type)
        -- 如果前后动作不一样，隐藏上一个
        if self.currentActionPanel ~= nil and func ~= self.currentActionPanel then
            self.currentActionPanel:Hiden()
        end
        if func == nil then
            print("这个类型的动作没 ====  "..dramaAction.type)
            self:Loop()
        else
            self.currentActionPanel = func
            self.currentActionPanel.callback = function() self:Loop() end
            self.currentActionPanel:Show(dramaAction)
        end
    end
end

-- 组合播放
function DramaActionModel:MutilPlay(arg)
    if arg == 5000 then
        --进场雷电
        self:HideMain()
        self.thunder = DramaThunder.New(function() self:Loop() end)
    elseif arg == 5001 then
        --飞信
        self:HideMain()
        self.dramaLetter = DramaLetter.New(function() self:Loop() end)
        self.dramaLetter:Show()
    else
        if self.mutilPlotModel == nil then
            self.mutilPlotModel = PlotMutilModel.New()
        end
        self.mutilPlotModel:BeginPlot(arg)
        self:Loop()
    end
end

function DramaActionModel:CustomMutilPlay(arg)
    if self.mutilPlotModel == nil then
        self.mutilPlotModel = PlotMutilModel.New()
    end
    self.mutilPlotModel:CustomBeginPlot(arg)
    self:Loop()
end

function DramaActionModel:Wait(delay)
    self.waitId = LuaTimer.Add(delay, function() self:Loop() end)
end

-- 播放剧本动作处理
function DramaActionModel:PlayPlot(plotId)
    if self.plotModel == nil then
        self.plotModel = PlotModel.New(function() self:Loop() end)
    end
    self.plotModel:BeginPlot(plotId)
end

-- 播放指引
function DramaActionModel:PlayGuide(guideId)
    self:Loop()
    DramaManager.Instance.dramaGuide = true
    GuideManager.Instance:Start(guideId)
end

-- 功能开启
function DramaActionModel:OpenSys(args)
    OpensysManager.Instance:Show(args)
end

function DramaActionModel:HideMain()
    DramaManager.Instance.model:HideMain()
end

function DramaActionModel:OnJump()
    if self.waitId ~= nil then
        LuaTimer.Delete(self.waitId)
        self.waitId = nil
    end
    if self.currentActionPanel ~= nil then
        self.currentActionPanel:OnJump()
    end
    if self.plotModel ~= nil then
        self.plotModel:JumpPlot()
    end
    if self.mutilPlotModel ~= nil then
        self.mutilPlotModel:JumpPlot()
    end

    -- self:EndActions()
end