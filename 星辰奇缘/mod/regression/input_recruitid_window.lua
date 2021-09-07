InputRecruitidWindow = InputRecruitidWindow or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function InputRecruitidWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.inputrecruitidwindow
    self.name = "InputRecruitidWindow"
    self.resList = {
        {file = AssetConfig.inputrecruitidwindow, type = AssetType.Main}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    
    
    -----------------------------------------
    self.select_item = nil
    self.select_data = nil
end

function InputRecruitidWindow:__delete()
    self:ClearDepAsset()
end

function InputRecruitidWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.inputrecruitidwindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.transform:Find("Main").localPosition = Vector3(0, -5, -500)
    self.CloseButton = self.transform:Find("Main/Close")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.InputFieldDesc = self.transform:Find("Main/InputField/Placeholder"):GetComponent(Text)
    self.InputFieldDesc.text = TI18N("输入绑定者ID...")
    self.InputFieldCDKey = self.transform:Find("Main/InputField"):GetComponent(InputField)
    self.btnCDKey = self.transform:Find("Main/Button"):GetComponent(Button)
    self.btnCDKey.onClick:AddListener(function()
        self:GetRewardByCDKey()
    end)

    -- self.textExt = MsgItemExt.New(self.transform:Find("Main/DescText"):GetComponent(Text), 330, 16, 22)
    -- self.textExt:SetData(TI18N("回归期间只能绑定一位招募人，绑定后即可领取奖励"))
    self.transform:Find("Main/DescText"):GetComponent(Text).text = TI18N("         回归期间只能绑定一位招募人")
    self.transform:Find("Main/Button/Text"):GetComponent(Text).text = TI18N("绑 定")
end

function InputRecruitidWindow:Close()
    self.model:CloseInputRecruitidWindow()
end

function InputRecruitidWindow:GetRewardByCDKey()
    if self.InputFieldCDKey.text ~= "" then
        if tonumber(self.InputFieldCDKey.text) == nil then
            NoticeManager.Instance:FloatTipsByString(TI18N("请先输入正确的绑定者ID"))
        else
            RegressionManager.Instance:Send11880(self.InputFieldCDKey.text)    
            self:Close()
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请先输入绑定者ID,再点领取"))
    end
end