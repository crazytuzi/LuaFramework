-- ----------------------------------------
-- 引导管理
-- hosr
-- ----------------------------------------
GuideManager = GuideManager or BaseClass(BaseManager)

function GuideManager:__init()
    if GuideManager.Instance then
        return
    end

    GuideManager.Instance = self
    self.running = false
    -- 点击功能按钮
    self.funcClick = GuideFuncBtn.New()
    -- 点击主线寻路
    self.mainTask = GuideMainTask.New()
    -- 关闭界面
    self.closeWin = GuideCloseWin.New()
    -- 点击指定按钮
    self.clickBtn = GuideClickBtn.New()
    -- 特效显示
    self.effect = GuideEffect.New()
    --通过日程入口的功能
    self.agendaFunc = GuideAgendaFunc.New()
    -- 宠物引导
    self.petGuide = nil

    --当前引导数据
    self.guide = nil
    --步骤总计
    self.allStep = 0
    --当前引导进展
    self.step = 0
    --指引点击主界面按钮
    self.isfunctionguide = false

    self.actionType = {
        func = "function",
        btn = "button_path",
        task = "task",
        close = "close",
        agenda_func = "agenda_func",
        pet = "pet"
    }

    self.funcIdToPanelId = {
        [1] = WindowConfig.WinID.backpack, --背包
        [2] = WindowConfig.WinID.guildinfowindow, --公会
        [3] = WindowConfig.WinID.skill, --技能
        [4] = WindowConfig.WinID.pet, --宠物
        [5] = WindowConfig.WinID.eqmadvance, --锻造
        [6] = WindowConfig.WinID.shop, --商城
        [7] = WindowConfig.WinID.ui_rank, --排行
        [8] = WindowConfig.WinID.setting_window, --设置
        [9] = WindowConfig.WinID.agendamain, --活动
        [11] = WindowConfig.WinID.guardian, --守护
        [14] = WindowConfig.WinID.agendamain, --日程
        [17] = 17, -- 提升
        [28] = WindowConfig.WinID.arena_window,--竞技场
        [10500] = WindowConfig.WinID.pet, -- 宠物
        [22] = WindowConfig.WinID.biblemain, --奖励
    }
end

--获取格式化数据
function GuideManager:GetParsedData(guideId)
    local newData = nil
    local data = DataPlot.data_guide[guideId]
    if data ~= nil then
        newData = BaseUtils.copytab(data)
        newData.flow = nil
        newData.flow = {}
        for v in string.gmatch(data.flow, "{(.-)}") do
            local ll = {}
            for i,a in ipairs(BaseUtils.split(v, ",")) do
                table.insert(ll, a)
            end
            table.insert(newData.flow, ll)
        end
    end
    return newData
end

--外部调用，开始一个引导
function GuideManager:Start(guideId)
    if BaseUtils.IsVerify then
        -- 审核服不引导
        return
    end
    if guideId == nil then
        return
    end
    self.guide = self:GetParsedData(guideId)

    if guideId == 10004 then
        -- 后面改了任务剧情，线上处理
        self:Finish()
        return
    end

    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow or RoleManager.Instance.RoleData.status == RoleEumn.Status.Fight then
        self:Finish()
        return
    end
    if self.guide ~= nil then
        self.running = true
        self.allStep = #self.guide.flow
        self.step = 0
        WindowManager.Instance:CloseCurrentWindow()
        self:Continue()
    else
        print(string.format("不存在该引导数据 ID=%s", guideId))
    end
end

--引导中断
function GuideManager:Interupt()
    print("中断引导")
    self.step = 0
    self:Continue()
end

--引导完成
function GuideManager:Finish()
    print("完成引导")
    if self.guide ~= nil then
        DramaManager.Instance:Send11006(self.guide.id)
    end
    self.running = false
    self.guide = nil
    self.step = 0
    self.allStep = 0
    self.effect:Hide()
end

--继续引导
function GuideManager:Continue()
    if self.guide == nil then
        return
    end
    if self.step == self.allStep then
        self:Finish()
    else
        self.step = self.step + 1
        if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
            SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
        end
        self:Dispachter(self.guide.flow[self.step])
    end
end

function GuideManager:Dispachter(args)
    if BaseUtils.IsVerify then
        -- 审核服不引导
        return
    end
    self.actType = tostring(args[1])
    if self.actionType.func == self.actType then
        self.funcClick:Start(args, function() self:Continue() end)
    elseif self.actionType.close == self.actType then
        self.closeWin:Start(args, function() self:Continue() end)
    elseif self.actionType.task == self.actType then
        self.mainTask:Start(args, function() self:Continue() end)
    elseif self.actionType.btn == self.actType then
        self.clickBtn:Start(args, function() self:Continue() end)
    elseif self.actionType.agenda_func == self.actType then
        self.agendaFunc:Start(args, function() self:Continue() end)
    elseif self.actionType.pet == self.actType then
        if self.petGuide == nil then
            self.petGuide = GuidePet.New()
        end
        self.petGuide:Start(args, function() self:Continue() end)
    end
end

--判断引导是否已完成
function GuideManager:IsFinish()
end

function GuideManager:OpenWindow(id)
    if BaseUtils.IsVerify then
        -- 审核服不引导
        return
    end
    if not self.running then
        return
    end
    if self.funcClick ~= nil then
        self.funcClick:OnOpen(id)
    elseif self.actionType.agenda_func == self.actType then
        self.agendaFunc:OnOpen(id)
    elseif self.actionType.pet == self.actType then
        self.petGuide:OnOpen(id)
    end
end

function GuideManager:CloseWindow(id)
    if not self.running then
        return
    end
    if self.actionType.btn == self.actType then
        if self.clickBtn ~= nil then
            self.clickBtn:OnClose(id)
        end
    elseif self.actionType.close == self.actType then
        if self.closeWin ~= nil then
            self.closeWin:OnClose(id)
        end
    elseif self.actionType.agenda_func == self.actType then
        self.agendaFunc:OnClose(id)
    elseif self.actionType.pet == self.actType then
        self.petGuide:OnClose(id)
    end
end

function GuideManager:GuideImprove(derect)
    if BaseUtils.IsVerify then
        -- 审核服不引导
        return
    end
    if self.improveId ~= nil then
        LuaTimer.Delete(self.improveId)
        self.improveId = nil
    end
    if derect then
        self:Start(10006)
    else
        self.improveId = LuaTimer.Add(6000, function() GuideManager.Instance:Start(10006) end)
    end
end
