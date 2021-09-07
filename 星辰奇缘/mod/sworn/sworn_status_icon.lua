-- @author 黄耀聪
-- @date 2016年11月1日

SwornStatusIcon = SwornStatusIcon or BaseClass(BasePanel)

function SwornStatusIcon:__init(model)
    self.model = model
    self.name = "SwornStatusIcon"

    self.resList = {
        {file = AssetConfig.sworn_status_icon, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornStatusIcon:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornStatusIcon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_status_icon))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.transform, self.gameObject)
    self.transform = t

    self.button = t:Find("Button"):GetComponent(Button)
    self.timeObj = t:Find("Time").gameObject
    self.timeText = t:Find("Time/Text"):GetComponent(Text)

    self.button.onClick:AddListener(function() self:OnClick() end)
end

function SwornStatusIcon:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornStatusIcon:OnOpen()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:OnTick() end)
end

function SwornStatusIcon:OnHide()
    self:RemoveListeners()

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end
end

function SwornStatusIcon:RemoveListeners()
end

function SwornStatusIcon:OnClick()
    print(SwornManager.Instance.status)
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_progress_window)
end

function SwornStatusIcon:OnTick()
    local swornData = self.model.swornData or {}
    local timeout = swornData.timeout or BaseUtils.BASE_TIME

    local m = nil
    local s = nil
    local _ = nil
    
    if timeout - BaseUtils.BASE_TIME <= 0 then
        self.timeObj:SetActive(false)
    else
        _,_,m,s = BaseUtils.time_gap_to_timer(timeout - BaseUtils.BASE_TIME)
        if m > 9 then
            if s > 9 then
                self.timeText.text = string.format("%s:%s", tostring(m), tostring(s))
            else
                self.timeText.text = string.format("%s:0%s", tostring(m), tostring(s))
            end
        else
            if s > 9 then
                self.timeText.text = string.format("0%s:%s", tostring(m), tostring(s))
            else
                self.timeText.text = string.format("0%s:0%s", tostring(m), tostring(s))
            end
        end
        self.timeObj:SetActive(true)
    end
end

