-- @author #pwj
-- @date 2018年7月2日,星期一

TwiceConfirmPanel = TwiceConfirmPanel or BaseClass(BasePanel)

function TwiceConfirmPanel:__init(model,setting)
    self.model = model
    self.name = "TwiceConfirmPanel"
    self.resList = {
        {file = AssetConfig.ConfirmTwice, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.setting = setting
    self.callback = self.setting.confirm_callback

end
function TwiceConfirmPanel:__delete()
    self.OnHideEvent:Fire()

    if self.top_I18N__Msg_Text ~= nil then 
        self.top_I18N__Msg_Text:DeleteMe()
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function TwiceConfirmPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ConfirmTwice))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.transform = t

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:ClosetwiceConfirmPanel() end)

    self.mainCon = t:Find("Main")

    self.TitleText = self.mainCon:Find("Title/Text"):GetComponent(Text)
    self.top_I18N_Text = self.mainCon:Find("I18N_Text"):GetComponent(Text)
    self.center_I18N_Text = self.mainCon:Find("I18N_PassWord"):GetComponent(Text)
    self.center_I18N_Text1 = self.mainCon:Find("I18N_Desc"):GetComponent(Text)
    self.input_field = self.mainCon:Find("InputCon/InputField"):GetComponent(InputField)
    self.okButton = self.mainCon:Find("OkButton"):GetComponent(Button)
    self.okButton.onClick:AddListener(function() self:OnOkButtonClick() end)
    self.okDesc = self.mainCon:Find("OkButton/Text"):GetComponent(Text)

    self.cancelButton = self.mainCon:Find("CancelButton"):GetComponent(Button)
    self.cancelButton.onClick:AddListener(function() self.model:ClosetwiceConfirmPanel() end)
    self.cancelDesc = self.mainCon:Find("CancelButton/Text"):GetComponent(Text)

    self.top_I18N__Msg_Text = MsgItemExt.New(self.top_I18N_Text, 320, 17, 20)
end

function TwiceConfirmPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function TwiceConfirmPanel:OnOpen()
    self:SetData()
end
function TwiceConfirmPanel:OnHide()
end

-- self.setting = {
--     titleTop = TI18N("确认跃升")
--     , title = string.format(TI18N("跃升后可达等级:%d,输入验证码可跃升"),85)
--     , password = TI18N("1234")
--     , confirm_str = TI18N("跃 升")
--     , cancel_str = TI18N("取 消")
--     , confirm_callback = function() end
-- }
function TwiceConfirmPanel:SetData()
    if self.setting ~= nil then
        self.TitleText.text = self.setting.titleTop
        if self.setting.password ~= nil then
            self.top_I18N__Msg_Text:SetData(self.setting.title)
            self.center_I18N_Text.text = self.setting.password
        else
            self.top_I18N_Text.transform.anchoredPosition = Vector2(88,-76)
            self.center_I18N_Text.gameObject:SetActive(false)
            self.center_I18N_Text1.gameObject:SetActive(false)
        end
        self.okDesc.text = self.setting.confirm_str
        self.cancelDesc.text = self.setting.cancel_str
    end
end


function TwiceConfirmPanel:OnOkButtonClick()
    local str = string.lower(self.input_field.text)
    if self.setting ~= nil and self.callback ~= nil then
        self.setting.password = self.setting.password or "YES"
        if string.upper(str) == string.upper(self.setting.password)then
            self.callback()
            self.model:ClosetwiceConfirmPanel()
        else
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("需要输入%s进行确认"),self.setting.password))
        end
    end
end




