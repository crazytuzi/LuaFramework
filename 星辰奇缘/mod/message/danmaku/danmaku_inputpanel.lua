DanmakuPanel = DanmakuPanel or BaseClass(BasePanel)

function DanmakuPanel:__init(model)
    self.model = model
    self.name = "DanmakuPanel"

    self.resList = {
        {file = AssetConfig.danmaku_input_window, type = AssetType.Main}
    }

    self.imgLoader = nil
end

function DanmakuPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DanmakuPanel:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function DanmakuPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.danmaku_input_window))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "DanmakuPanel"
    self.transform = self.gameObject.transform

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() end)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:ClosePanel() end)
    self.transform:Find("Main/Container/Button"):GetComponent(Button).onClick:AddListener(function() self:OnBtnSend() end)

    self.texttips = self.transform:Find("Main/Container/Texttips"):GetComponent(Text)
    self.textneedhead = self.transform:Find("Main/Container/Text"):GetComponent(Text)
    self.textneed = self.transform:Find("Main/Container/Text/need"):GetComponent(Text)
    self.iconneed = self.transform:Find("Main/Container/Text/icon"):GetComponent(Image)
    -- self.textneed.text = tostring(DataWedding.data_wedding_action[string.format("6_%s_3", MarryManager.Instance.model.type)].max_num)
    self:UpdateText()
    self:InitInputField()
end

function DanmakuPanel:InitInputField()

    self.inputfield = self.transform:Find("Main/Container/InputField"):GetComponent(InputField)
    local ipf = self.inputfield:GetComponent(InputField)
    self.inputfield.onValueChange:AddListener(function (val) self:OnMsgChange(val) end)
    local textcom = self.inputfield.transform:Find("Text"):GetComponent(Text)
    local placeholder = self.inputfield.transform:Find("Placeholder"):GetComponent(Text)
    self.inputfield.textComponent = textcom
    self.inputfield.placeholder = placeholder
    if self.openArgs ~= nil then
        ipf.text = self.openArgs.defaultstr or ""
        placeholder.text = TI18N("请输入弹幕内容")
        if self.openArgs.cost == nil then
            self.textneedhead.gameObject:SetActive(false)
            self.transform:Find("Main/Container/Button").anchoredPosition3D = Vector3(0, -84.7, 0)
        else

        end
    else
        ipf.text = self.model:GetText()
    end
end

function DanmakuPanel:OnMsgChange(val)
    local len = string.utf8len(val)
    local remain = 40 - len

    self.texttips.text = string.format(TI18N("还可输入<color='#00ff00'>%s</color>个字"), tostring(remain))
end

function DanmakuPanel:OnBtnSend()
    if self.openArgs ~= nil and self.openArgs.sendCall ~= nil then
        if self.inputfield.text == "" then
            NoticeManager.Instance:FloatTipsByString(TI18N("弹幕内容不能为空！"))
            return
        end
        self.openArgs.sendCall(self.inputfield.text)
        self.model:ClosePanel()
    else
        if self.inputfield.text == "" then
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入你的祝福！"))
            return
        end
        DanmakuManager.Instance:SendDanmaku(self.inputfield.text)
    end
    -- self.inputfield.text = ""
end


function DanmakuPanel:UpdateText()
    if self.openArgs ~= nil then

    else
        local roleData = RoleManager.Instance.RoleData
        local data = DataWedding.data_wedding_action[string.format("%s_%s_3", 6, MarryManager.Instance.model.type)]
        local hasfreenum = MarryManager.Instance.model.action_times_list[6]
        -- BaseUtils.dump(data,"基础数据")
        -- BaseUtils.dump(hasfreenum,"协议数据")
        if hasfreenum ~= nil and hasfreenum.num >= data.free_num then
            self.textneed.text = tostring(data.cost[1][2])
            self.textneedhead.text = TI18N("消耗：")

            if self.imgLoader == nil then
                self.imgLoader = SingleIconLoader.New(self.iconneed.gameObject)
            end
            self.imgLoader:SetSprite(SingleIconType.Item, data.cost[1][1])

            self.iconneed.gameObject:SetActive(true)
        elseif hasfreenum ~= nil then
            self.iconneed.gameObject:SetActive(false)
            self.textneed.text = string.format("%s/%s", tostring(hasfreenum.num), tostring(data.free_num))
            self.textneedhead.text = TI18N("剩余免费：")
        else
            self.iconneed.gameObject:SetActive(false)
            self.textneed.text = string.format("%s/%s", tostring(data.free_num), tostring(data.free_num))
            self.textneedhead.text = TI18N("剩余免费：")
        end
    end
end
