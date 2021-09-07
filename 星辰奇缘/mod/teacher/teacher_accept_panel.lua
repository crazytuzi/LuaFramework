-- 师徒，师父对徒弟的工课评价
-- @author zgs
TeacherAcceptPanel = TeacherAcceptPanel or BaseClass(BasePanel)

function TeacherAcceptPanel:__init(model)
    self.model = model
    self.name = "TeacherAcceptPanel"

    self.resList = {
        {file = AssetConfig.teacher_accept_panel, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function()
        self.lev = self.openArgs[1]
        self:UpdatePanel()
    end)
end

function TeacherAcceptPanel:__delete()
    if self.msgItem1 ~= nil then
        self.msgItem1:DeleteMe()
        self.msgItem1 = nil
    end
    if self.msgItem2 ~= nil then
        self.msgItem2:DeleteMe()
        self.msgItem2 = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function TeacherAcceptPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teacher_accept_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("Main")
    self.mainRect = self.transform:Find("Main"):GetComponent(RectTransform)

    self.descText = self.MainCon:FindChild("Text"):GetComponent(Text)

    self.button_1 = self.MainCon:Find("Button1"):GetComponent(Button)
    self.button_2 = self.MainCon:Find("Button2"):GetComponent(Button)

    self.buttonText_1 = self.MainCon:Find("Button1/Text"):GetComponent(Text)
    self.buttonText_2 = self.MainCon:Find("Button2/Text"):GetComponent(Text)

    self.buttonRect_1 = self.button_1:GetComponent(RectTransform)
    self.buttonRect_2 = self.button_2:GetComponent(RectTransform)

    self.button_1.onClick:AddListener(function() self:onClickButton(2) end)
    self.button_2.onClick:AddListener(function() self:onClickButton(1) end)

    self.MainCon:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseAccept()
    end)

    -- self:DoClickPanel()
end

function TeacherAcceptPanel:OnInitCompleted()
    self.msgItem1 = MsgItemExt.New(self.buttonText_1, 340, 17, 20)
    self.msgItem1:SetData(TI18N("消耗{assets_1,90006, 50}给予鼓励（徒弟额外获得奖励）"), true)

    self.msgItem2 = MsgItemExt.New(self.buttonText_2, 340, 17, 20)
    self.msgItem2:SetData(TI18N("徒弟完成的很好，但可以继续努力"), true)
end

function TeacherAcceptPanel:onClickButton(index)
    TeacherManager.Instance:send15817(self.openArgs.rid, self.openArgs.platform, self.openArgs.zone_id, index)
    self.model:CloseAccept()
end

function TeacherAcceptPanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self.model:CloseAccept()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end
