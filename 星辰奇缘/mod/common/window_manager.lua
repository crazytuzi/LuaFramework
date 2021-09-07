-- 窗口管理
-- 不保存和销毁window对象，window对像还是由model负责
WindowManager = WindowManager or BaseClass()

function WindowManager:__init()
    if WindowManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end
    WindowManager.Instance = self

    -- 窗口实例
    self.winList = {}

    -- 当前窗口 用于连动
    self.currentWin = nil
    self.lastWin = nil
end

function WindowManager:__delete()
end

function WindowManager:OnTick()
    if (not IS_DEBUG) and CombatManager.Instance.isFighting then
        return
    end

    local time = Time.time
    local destroyList = {}
    for _, win in ipairs(self.winList) do
        if win:CheckToDestroy(time) then
            table.insert(destroyList, win)
        end
    end

    for _, win in ipairs(destroyList) do
        local model = win.model
        for key, data in pairs(model) do
            if data == win then
                if win == self.currentWin then
                    self.currentWin = nil
                end
                if win == self.lastWin then
                    self.lastWin = nil
                end
                model[key]:DeleteMe()
                model[key] = nil
            end
        end
    end
end

function WindowManager:AddWindow(win)
    for _, data in ipairs(self.winList) do
        if data == win then
            return
        end
    end
    table.insert(self.winList, win)
end

function WindowManager:RemoveWindow(win)
    local idx = -1
    for index, data in ipairs(self.winList) do
        if data == win then
            idx = index
            break
        end
    end
    if idx ~= -1 then
        table.remove(self.winList, idx)
    else
        Log.Error("移除窗口出错：" .. win.name)
    end
end

function WindowManager:CloseWindow(win, doCheck)
    TipsManager.Instance.model:Closetips()
    if doCheck == nil then
        doCheck = true
    end
    if win.cacheMode == CacheMode.Visible then
        win:Hide()
    else
        local model = win.model
        for key, data in pairs(model) do
            if data == win then
                model[key]:DeleteMe()
                model[key] = nil
                if self.currentWin == win then
                    self.currentWin = nil
                end
                if self.lastWin == win then
                    self.lastWin = nil
                end
            end
        end
    end
    if doCheck == true then
        if self.lastWin ~= nil and self.lastWin.gameObject ~= nil then
            self.currentWin = self.lastWin
            self.currentWin:Open()
            self.lastWin = nil
            return
        else
            self.lastWin = nil
        end
    end

    if win.name ~= "LoginView" and win.name ~= "CreateRoleWindow" then
        self:ShowUI(true)
    end
end

function WindowManager:OpenWindow(win)
    if win ~= nil then
        win:Open()
    end
end

-- private
function WindowManager:OnOpenWindow(win)
    AutoRunManager.Instance:ClearTime()
    TipsManager.Instance.model:Closetips()
    if self.currentWin ~= nil and self.currentWin.gameObject == nil then
        self.currentWin = nil
        self.lastWin = nil
    end
    if self.currentWin ~= nil
        and self.currentWin.winLinkType == WinLinkType.Link
        and self.currentWin.gameObject.activeSelf
        and self.currentWin.cacheMode == CacheMode.Visible
        and self.currentWin.isOpen
    then
        self.lastWin = self.currentWin
    else
        self.lastWin = nil
    end

    if self.currentWin ~= nil and self.currentWin.gameObject.activeSelf then
        if win.windowId ~= self.currentWin.windowId then
            self:CloseWindow(self.currentWin, false)
        else
            self.lastWin = nil
        end
    end
    if win.winLinkType == WinLinkType.Link
        and win.name ~= "MainUIIconView"
        and win.name ~= "ChatWindow"
        and win.name ~= "ChatMiniWindow"
    then
        self.currentWin = win
    end

    if win.name ~= "ImproveWindow" and win.name ~= "MainUIIconView" and win.name ~= "CreateRoleWindow" and win.isHideMainUI then
        self:ShowUI(false)
    end
end

function WindowManager:OpenWindowById(id, args)
    if id == WindowConfig.WinID.world_boss or id == WindowConfig.WinID.trialwindow or id == WindowConfig.WinID.glory_window then
        if RoleManager.Instance:CheckCross() then
            return
        end
    end
    if WindowConfig.OpenFunc[id] ~= nil then
        WindowConfig.OpenFunc[id](args)
    else
        -- Log.Error(string.format("不存在该ID=%s的面板配置", id))
    end
end

function WindowManager:CloseWindowById(id,doCheck)
    for _, data in ipairs(self.winList) do
        if data.windowId == id then
            self:CloseWindow(data,doCheck)
            return
        end
    end
end

-- 打开窗口隐藏主UI，关闭显示
function WindowManager:ShowUI(bool)
    MainUIManager.Instance:ShowMainUICanvas(bool)
    ChatManager.Instance.model:ShowCanvas(bool)
    HomeManager.Instance:ShowOtherUI()
    if bool then
        NoticeManager.Instance:ShowAutoUse()
    else
        NoticeManager.Instance:HideAutoUse()
    end
end

-- 关闭当前面板，不处理打开缓存
function WindowManager:CloseCurrentWindow()
    if self.currentWin ~= nil then
        self:CloseWindow(self.currentWin, false)
    end
end

function WindowManager:ClearWindows()
    for _,win in pairs(self.winList) do
        if win ~= nil then
            win.holdTime = 0
        end
    end
    self:OnTick()
end
