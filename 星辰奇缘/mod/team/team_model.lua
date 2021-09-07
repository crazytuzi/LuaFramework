TeamModel = TeamModel or BaseClass(BaseModel)

function TeamModel:__init()
    self.mgr = TeamManager.Instance
    self.repeatTimeId = 0

    self.mainWindow = nil

    self.canRefresh = true

    self._UpdateRecruitDataList = function(type) self:UpdateRecruitDataList(type) end
end

function TeamModel:__delete()
    if self.mainWindow ~= nil then
        self.mainWindow:DeleteMe()
        self.mainWindow = nil
    end
end

function TeamModel:OpenMain(args)
    if self.mainWindow == nil then
        self.mainWindow = TeamMainWindow.New(self)
    end
    self.mainWindow:Open(args)
end

function TeamModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.mainWindow)
end

function TeamModel:RepeatMatchRoom()
    if self.repeatTimeId ~= 0 then
        return
    end
    self.repeatTimeId = LuaTimer.Add(0, 5000, function() self.mgr:Send11712() end)
end

function TeamModel:CancelRepeatMatch()
    if self.repeatTimeId ~= 0 then
        LuaTimer.Delete(self.repeatTimeId)
    end
end

function TeamModel:RefreshCd(callback)
    self.canRefresh = false
    local func = function()
        if callback ~= nil then
            callback()
        end
        self.canRefresh = true
    end
    LuaTimer.Add(0, 1000, func)
end

function TeamModel:OpenLoveTeamWindow(args)
    if self.loveteamwindow == nil then
        self.loveteamwindow = LoveTeamWindow.New(self)
    end
    self.loveteamwindow:Show(args)
end

function TeamModel:CloseLoveTeamWindow()
    if self.loveteamwindow ~= nil then
        self.loveteamwindow:DeleteMe()
        self.loveteamwindow = nil
    end
end

function TeamModel:UpdateRecruitDataList(type)
    if type == "add" then
        self:OpenLoveTeamWindow()
    end
end