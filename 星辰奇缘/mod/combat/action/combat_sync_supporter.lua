-- 同时执行
SyncSupporter = SyncSupporter or BaseClass(CombatBaseAction)

function SyncSupporter:__init(brocastCtx, actions)
    -- 间隔时间(秒)
    self.spanTime = 0
    self.index = 1
    self.old = false
    -- self.traceback = debug.traceback()
    if actions == nil then
        self.actions = {}
    else
        self.actions = actions
    end
end

function SyncSupporter:AddAction(action)
    table.insert(self.actions, action)
end

function SyncSupporter:Play()
    if self.old then
        print("[重复Action]") --..self.traceback
        return
    end
    self.old = true
    if #self.actions == 0 then
        self:OnActionEnd()
    else
        local taper = TaperSupporter.New(self.brocastCtx)
        taper:AddEvent(CombatEventType.End, self.OnActionEnd, self)
        for _, action in ipairs(self.actions) do
            action:AddTaperEvent(CombatEventType.End, taper)
        end
        if self.spanTime == 0 then
            for _, action in ipairs(self.actions) do
                LuaTimer.Add(1, function () action:Play() end)
            end
        else
            self.actions[self.index]:Play()
            self.index = self.index + 1
            if self.index <= #self.actions then
                LuaTimer.Add(self.spanTime*1000, function () self:Next() end)
            end
        end
    end
end

function SyncSupporter:Next()
    if self.index <= #self.actions then
        self.actions[self.index]:Play()
        self.index = self.index + 1
        if self.index <= #self.actions then
            LuaTimer.Add(self.spanTime*1000, function () self:Next() end)
        end
    end
end

function SyncSupporter:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
