DragonChessIconView = DragonChessIconView or BaseClass(BasePanel)

function DragonChessIconView:__init(model)
    self.model = model
    self.name = "DragonChessIconView"

    self.resList = {
        {file = AssetConfig.dragon_chess_iconview, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_textures, type = AssetType.Dep},
    }

    self.days = nil
    self.hours = nil
    self.minutes = nil
    self.seconds = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DragonChessIconView:__delete()
    self.OnHideEvent:Fire()
end

function DragonChessIconView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_iconview))
    self.gameObject.name =self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform
    self.timeText = self.transform:Find("Icon/Text"):GetComponent(Text)

    self.transform:Find("Icon"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.dragon_chess_match) end)
end

function DragonChessIconView:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DragonChessIconView:OnOpen()
    self.model.beginTime = self.model.beginTime or BaseUtils.BASE_TIME

    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 160, function() self:OnTime() end)
    end
end

function DragonChessIconView:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function DragonChessIconView:OnTime()
    self.timeText.text = BaseUtils.formate_time_gap(BaseUtils.BASE_TIME - self.model.beginTime, ":", 0, BaseUtils.time_formate.MIN)
end

