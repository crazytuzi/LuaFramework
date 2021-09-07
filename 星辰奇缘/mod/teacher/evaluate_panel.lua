-- 师徒，徒弟评价师父
-- @author zgs
EvaluatePanel = EvaluatePanel or BaseClass(BasePanel)

function EvaluatePanel:__init(model)
    self.model = model
    self.name = "EvaluatePanel"

    self.resList = {
        {file = AssetConfig.evaluate_panel, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function()
        self.lev = self.openArgs[1]
        self:UpdatePanel()
    end)

    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:RemovePanel()
    end)
end


function EvaluatePanel:RemovePanel()
    self:DeleteMe()
end

function EvaluatePanel:OnInitCompleted()
    self.lev = self.openArgs[1]
    self:UpdatePanel()
end

function EvaluatePanel:__delete()
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.ep = nil
    self.model = nil
end

function EvaluatePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.evaluate_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.MainCon = self.transform:FindChild("Main/Con")

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:Hiden()
    end)

    self.descText = self.MainCon:FindChild("DescText"):GetComponent(Text)
    self.levText = self.MainCon:FindChild("LevText"):GetComponent(Text)

    self.button_1 = self.MainCon:Find("Button_1"):GetComponent(Button)
    self.btntext_1 = self.button_1.transform:Find("Text"):GetComponent(Text)
    self.msgItemExt_1 = MsgItemExt.New(self.btntext_1, 350, 18, 19)
    self.button_2 = self.MainCon:Find("Button_2"):GetComponent(Button)
    self.btntext_2 = self.button_2.transform:Find("Text"):GetComponent(Text)
    -- self.btntext_2.transform:GetComponent(RectTransform).anchoredPosition = Vector3(22,-22,0)
    self.msgItemExt_2 = MsgItemExt.New(self.btntext_2, 350, 18, 19)
    self.button_3 = self.MainCon:Find("Button_3"):GetComponent(Button)
    self.btntext_3 = self.button_3.transform:Find("Text"):GetComponent(Text)
    self.msgItemExt_3 = MsgItemExt.New(self.btntext_3, 350, 18, 19)

    self.button_1.onClick:AddListener( function() self:onClickButton(3) end)
    self.button_2.onClick:AddListener( function() self:onClickButton(2) end)
    self.button_3.onClick:AddListener( function() self:onClickButton(1) end)

    -- self:DoClickPanel()
end

function EvaluatePanel:onClickButton(index)
    TeacherManager.Instance:send15810(self.lev,index)
    self:Hiden()
end

function EvaluatePanel:DoClickPanel()
    if self.gameObject ~= nil then
        local panel = self.gameObject.transform:FindChild("Panel")
        if panel ~= nil then
            local panelBut = panel:GetComponent(Button)
            if panelBut ~= nil then
                local onClick = function()
                    self:Hiden()
                end
                panelBut.onClick:AddListener(onClick)
            end
        end
    end
end


function EvaluatePanel:UpdatePanel()
    self.levText.text = string.format(TI18N("恭喜您升级到<color='%s'>%d级</color>"),ColorHelper.color[1],self.lev)
    self.msgItemExt_1:SetData(TI18N("{face_1, 3}师傅非常关心爱护我,陪我一起升级成长"))
    self.msgItemExt_2:SetData(TI18N("{face_1, 38}师傅偶尔会关心一下我"))
    self.msgItemExt_3:SetData(TI18N("{face_1, 21}师傅从来没有理过我，内心好受伤"))
end
