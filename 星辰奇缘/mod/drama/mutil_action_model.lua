-- ----------------------------------------------
-- 同时播放, 调用动作马上就下一个，直到完为止
-- hosr
-- -----------------------------------------------
MutilActionModel = MutilActionModel or BaseClass(BaseModel)

function MutilActionModel:__init(callback)
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

function MutilActionModel:__delete()
    -- print("MutilActionModel:__delete")
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
function MutilActionModel:EndActions(allover)
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
function MutilActionModel:BeginActions(action_list)
    self.actionList = action_list
    self.step = 0
    self.stepMax = #self.actionList
    -- LuaTimer.Add(200, function() self:Loop() end)
    self:Loop()
end

-- 步骤处理每个动作
function MutilActionModel:Loop()
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
function MutilActionModel:Dispatcher(dramaAction)
    self.currentActionData = dramaAction
    if dramaAction.type == DramaEumn.ActionType.Plotunitcreate then
        table.insert(DramaManager.Instance.model.multiUnitList, dramaAction)
        DramaVirtualUnit.Instance:CreateUnit(dramaAction)
    elseif dramaAction.type == DramaEumn.ActionType.Plotunitdel then
        DramaVirtualUnit.Instance:RemoveUnit(dramaAction)
    elseif dramaAction.type == DramaEumn.ActionType.Inter_monologue then
        DramaManager.Instance.model:Feeling(dramaAction)
    elseif dramaAction.type == DramaEumn.ActionType.Soundplay then
        SoundManager.Instance:Play(dramaAction.res_id)
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
    else
        if self.factory == nil then
            self.factory = DramaActionFactory.New()
        end
        local func = self.factory:GetAction(dramaAction.type)
        -- local func = DramaActionFactory.Instance:GetAction(dramaAction.type)
        -- 如果前后动作不一样，隐藏上一个
        if self.currentActionPanel ~= nil and func ~= self.currentActionPanel then
            self.currentActionPanel:Hiden()
        end
        self.currentActionPanel = func
        self.currentActionPanel.isMulti = true
        self.currentActionPanel:Show(dramaAction)
    end
    self:Loop()
end

function MutilActionModel:OnJump()
    if self.currentActionPanel ~= nil then
        self.currentActionPanel:OnJump()
    end
end