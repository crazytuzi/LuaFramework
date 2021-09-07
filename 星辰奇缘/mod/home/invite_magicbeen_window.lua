-- ----------------------------------------------------------
-- UI - 创建家园窗口
-- ljh 20160712
-- ----------------------------------------------------------
InviteMagicBeenWindow = InviteMagicBeenWindow or BaseClass(BaseWindow)

function InviteMagicBeenWindow:__init(model)
    self.model = model
    self.name = "InviteMagicBeenWindow"
    self.windowId = WindowConfig.WinID.invitemagicbeenwindow

    self.resList = {
        {file = AssetConfig.invitemagicbeenwindow, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil
    self.subTransform = nil

    self.main = nil
    self.sub = nil

    ------------------------------------------------
    self.showType = 1
    self.timer_id = nil

    ------------------------------------------------
    self.descText = nil
    self.timeText = nil

    ------------------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function InviteMagicBeenWindow:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self:AssetClearAll()
end

function InviteMagicBeenWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.invitemagicbeenwindow))
    self.gameObject.name = "InviteMagicBeenWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")
    self.subTransform = self.transform:FindChild("Sub")

    self.main = self.mainTransform.gameObject
    self.sub = self.subTransform.gameObject

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.descText = self.mainTransform:FindChild("DescText"):GetComponent(Text)

    self.timeText = self.mainTransform:FindChild("TimeText"):GetComponent(Text)

    self.mainTransform:FindChild("Button1"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton1() end)
    self.mainTransform:FindChild("Button2"):GetComponent(Button).onClick:AddListener(function() self:OnClickButton2() end)
    ----------------------------

    self:OnShow()
end

function InviteMagicBeenWindow:OnClickClose()
    if self.showType == 1 then
        self:OnHide()
        WindowManager.Instance:CloseWindow(self)
    else
        self.showType = 1
        self.main:SetActive(true)
        self.sub:SetActive(false)
    end
end

function InviteMagicBeenWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self.endTime = self.openArgs[1]
    end
    self:update()
    self:timer_update()
end

function InviteMagicBeenWindow:OnHide()
    if self.timer_id ~= nil then
        LuaTimer.Delete(self.timer_id)
    end
end

function InviteMagicBeenWindow:update()
    if self.showType == 1 then
        self.descText.text = "" --"文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字文字"

        if self.timer_id ~= nil then
            LuaTimer.Delete(self.timer_id)
        end
        self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_update() end)
    else
        local list = {}
        if self.showType == 2 then
        elseif self.showType == 3 then
        end
    end
end

function InviteMagicBeenWindow:timer_update()
    if self.endTime >= BaseUtils.BASE_TIME then
        local time = BaseUtils.formate_time_gap(self.endTime - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.HOUR)
        self.timeText.text = string.format("%s %s", TI18N("剩余时间"), time)
    else
        self.timeText.text = TI18N("已超时")
    end
end

function InviteMagicBeenWindow:OnClickButton1()
	-- HomeManager.Instance:Send11201()
    self:OnClickClose()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gethome)
end

function InviteMagicBeenWindow:OnClickButton2()
    -- HomeManager.Instance:Send11201()
    self:OnClickClose()
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.gethome)
end