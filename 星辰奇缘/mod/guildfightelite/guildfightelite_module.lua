-- @author zgs
GuildfightEliteModel = GuildfightEliteModel or BaseClass(BaseModel)

function GuildfightEliteModel:__init()
    self.gaWin = nil

    self.guildfightEliteMemPanel = nil

    self.sortLogsByTime = function (a,b)
        return a.time > b.time
    end

    self.isInLookFightRecord = false
    self.endfrightcallback = function()
        if self.isInLookFightRecord == true then
            self.isInLookFightRecord = false
            self:OpenWindow({2})
        end
    end

    EventMgr.Instance:AddListener(event_name.end_fight, self.endfrightcallback)
end

function GuildfightEliteModel:__delete()
    if self.gaWin then
        self.gaWin = nil
    end
end

function GuildfightEliteModel:OpenWindow(args)
    if self.gaWin == nil then
        self.gaWin = GuildfightEliteWindow.New(self)
    end
    self.gaWin:Open(args)
end

function GuildfightEliteModel:CloseMain()
    WindowManager.Instance:CloseWindow(self.gaWin, true)
end

function GuildfightEliteModel:ShowTeamInfoPanel(args)
    if self.gaWin ~= nil then
        self.gaWin:updateTeamInfo(args)
    end
end

function GuildfightEliteModel:ShowEliteMemberPanel(bo,pos)
    if bo == true then
        if self.gfemp == nil then
            self.gfemp = GuildFightEliteMemberPanel.New(self)
        end
        self.gfemp:Show({pos})
    else
        if self.gfemp ~= nil then
            self.gfemp:Hiden()
        end
    end
end

function GuildfightEliteModel:UpdateFightLogs(data)
    if self.gaWin ~= nil then
        table.sort( data, self.sortLogsByTime )
        self.gaWin:UpdateFightLogs(data)
    end
end

function GuildfightEliteModel:ShowEliteLookWindow(bo)
    if bo == true then
        if self.elw == nil then
            self.elw = GuildfightEliteLookWindow.New(self)
        end
        -- print("GuildfightEliteModel:ShowEliteLookWindow(bo)"..debug.traceback())
        self.elw:Open()
    else
        if self.elw ~= nil then
            WindowManager.Instance:CloseWindow(self.elw, true)
        end
    end
end