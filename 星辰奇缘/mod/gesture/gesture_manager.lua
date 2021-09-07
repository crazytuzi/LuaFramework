-- -----------------------------------------------
-- 手势管理
-- hosr
-- -----------------------------------------------
GestureManager = GestureManager or BaseClass(BaseManager)

function GestureManager:__init()
    if GestureManager.Instance then
        return
    end
    GestureManager.Instance = self

    self.IsOpen = true

    self.beganPosition1 = nil
    self.beganPosition2 = nil
    self.endPosition1 = nil
    self.endPosition2 = nil
    self.hasMoved1 = false
    self.hasMoved2 = false

    self.standard = 1500

    self.count = 0

    self.isEnterGame = false
    self.mainuiLoad = function() self:MainuiLoad() end
    EventMgr.Instance:AddListener(event_name.mainui_loaded, self.mainuiLoad)
    self.beginFight = function() self:OnBeginFight() end
    self.endFight = function() self:OnEndFight() end
    self.isFighting = false
    self.platform = Application.platform
end

function GestureManager:MainuiLoad()
    EventMgr.Instance:RemoveListener(event_name.mainui_loaded, self.mainuiLoad)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFight)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFight)
    self.mainuiLoad = nil
    self.isEnterGame = true
end

function GestureManager:OnBeginFight()
    self.isFighting = true
    self:SoBusy()
end

function GestureManager:OnEndFight()
    self.isFighting = false
end

-- 手势开关
function GestureManager:SetOpen(bool)
    self.IsOpen = bool
end

function GestureManager:FixedUpdate()
    if not self.isEnterGame then
        return
    end

    if not self.IsOpen then
        return
    end

    if self.isFighting then
        return
    end

    if RoleManager.Instance.RoleData.drama_status == RoleEumn.DramaStatus.Running then
        return
    end

    -- if WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.gameObject ~= nil and WindowManager.Instance.currentWin.gameObject.activeSelf then
    if WindowManager.Instance.currentWin ~= nil and WindowManager.Instance.currentWin.gameObject ~= nil and WindowManager.Instance.currentWin.isOpen then
        return
    end

    if HomeManager.Instance.isHomeCanvasShow then
        return
    end

    if self.platform == RuntimePlatform.WindowsPlayer or self.platform == RuntimePlatform.WindowsEditor
        or self.platform == RuntimePlatform.OSXEditor or self.platform == RuntimePlatform.OSXPlayer then
        if Input.GetKeyDown(KeyCode.F4) then
            self:SoCool()
        elseif Input.GetKeyDown(KeyCode.F5) then
            self:SoBusy()
        elseif Input.GetKeyDown(KeyCode.F6) then
            if IS_DEBUG then
                MainUIManager.Instance:ToAdaptIPhoneX()
            end
        end
    else
        self.count = Input.touchCount
        if self.count == 2 then
            if self.beganPosition1 == nil then
                self.beganPosition1 = Input.GetTouch(0).position
            end

            if self.beganPosition2 == nil then
                self.beganPosition2 = Input.GetTouch(1).position
            end

            local ok1 = false
            local ok2 = false
            local change1 = false
            local change2 = false

            if Input.GetTouch(0).phase == TouchPhase.Moved then
                change1 = Input.GetTouch(0).deltaPosition.x / Input.GetTouch(0).deltaTime
                ok1 = (change1 >= self.standard) or (change1 <= (-self.standard))
            end

            if Input.GetTouch(1).phase == TouchPhase.Moved then
                change2 = Input.GetTouch(1).deltaPosition.x / Input.GetTouch(1).deltaTime
                ok2 = (change2 >= self.standard) or (change2 <= (-self.standard))
            end

            if ok1 and ok2 then
                if math.abs(self.beganPosition1.x - self.beganPosition2.x) > math.abs(Input.GetTouch(0).position.x - Input.GetTouch(1).position.x) then
                    -- 往里面
                    self:SoBusy()
                elseif math.abs(self.beganPosition1.x - self.beganPosition2.x) < math.abs(Input.GetTouch(0).position.x - Input.GetTouch(1).position.x) then
                    -- 往外面
                    self:SoCool()
                end
                self:Reset()
            end
        elseif self.count == 1 then
            if self.beganPosition1 == nil then
                self.beganPosition1 = Input.GetTouch(0).position
            end

            local dx = Input.GetTouch(0).deltaPosition.x
            local change = dx / Input.GetTouch(0).deltaTime
            if Input.GetTouch(0).position.x <= ctx.ScreenWidth / 2 then
                -- 中间往左
                -- if dx < 0 and change <= (-self.standard) then
                --     self:HideLeft()
                -- elseif dx > 0 and change >= self.standard then
                --     self:ShowLeft()
                -- end
            elseif self.beganPosition1.x >= ctx.ScreenWidth * 3 / 4 and math.abs(Input.GetTouch(0).position.x - self.beganPosition1.x) >= ctx.ScreenWidth / 8 then
            -- elseif Input.GetTouch(0).position.x >= ctx.ScreenWidth / 2 then
                -- 中间往右
                if dx > 0 and change >= self.standard then
                    self:HideRight()
                elseif dx < 0 and change <= (-self.standard) then
                    self:ShowRight()
                end
            end
        else
            self:Reset()
        end
    end
end

function GestureManager:Reset()
    self.beganPosition1 = nil
    self.beganPosition2 = nil
    self.endPosition1 = nil
    self.endPosition2 = nil
end

function GestureManager:SoCool()
    if ChatManager.Instance.model.isChatShow then
        ChatManager.Instance.model:HideChatWindow()
    end
    ChatManager.Instance.model:HideChatMini()
    MainUIManager.Instance:HideTracePanel()
    MainUIManager.Instance:HideRoleInfo()
    MainUIManager.Instance:HidePetInfo()
    MainUIManager.Instance:HideMapInfo()
    MainUIManager.Instance:HideIconPanel()
    MainUIManager.Instance:HideSysInfo()
    MainUIManager.Instance:ShowBackView()
    self:Reset()
end

function GestureManager:SoBusy()
    ChatManager.Instance.model:ShowChatMini()
    MainUIManager.Instance:ShowTracePanel()
    MainUIManager.Instance:ShowRoleInfo()
    MainUIManager.Instance:ShowPetInfo()
    MainUIManager.Instance:ShowMapInfo()
    MainUIManager.Instance:ShowIconPanel()
    MainUIManager.Instance:ShowSysInfo()
    MainUIManager.Instance:HideBackView()
    self:Reset()
end

function GestureManager:ShowLeft()
    ChatManager.Instance.model:ShowChatWindow()
    self:Reset()
end

function GestureManager:HideLeft()
    ChatManager.Instance.model:HideChatWindow()
    self:Reset()
end

function GestureManager:ShowRight()
    MainUIManager.Instance:ShowTracePanel()
    self:Reset()
end

function GestureManager:HideRight()
    MainUIManager.Instance:HideTracePanel()
    self:Reset()
end