-- @author 黄耀聪
-- @date 2016年11月1日

SwornReasonWindow = SwornReasonWindow or BaseClass(BaseWindow)

function SwornReasonWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.sworn_reason
    self.name = "SwornReasonWindow"

    self.resList = {
        {file = AssetConfig.sworn_reason, type = AssetType.Main},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
    }

    self.toggleList = {}
    self.labelText = {}
    self.labelString = {"长期不在线", "不团结兄弟", "表现不积极", "性格不合"}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SwornReasonWindow:__delete()
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SwornReasonWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sworn_reason))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    local main = t:Find("Main")
    self.group = main:Find("Bg/Group")
    self.cancelBtn = main:Find("Cancel"):GetComponent(Button)
    self.sureBtn = main:Find("Sure"):GetComponent(Button)

    for i=1,5 do
        self.toggleList[i] = self.group:Find("Reason" .. i):GetComponent(Toggle)
        -- self.toggleList[i].onValueChanged:RemoveAllListeners()
        self.toggleList[i].isOn = false
        local k = i
        self.toggleList[i].onValueChanged:AddListener(function() self:OnValueChanged(k) end)
    end

    for i=1,4 do
        self.labelText[i] = self.toggleList[i].transform:Find("Label"):GetComponent(Text)
        self.labelText[i].text = self.labelString[i]
    end
    self.inputField = self.toggleList[5].transform:Find("InputField"):GetComponent(InputField)

    self.cancelBtn.onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)
    self.sureBtn.onClick:AddListener(function() self:OnClick() end)
end

function SwornReasonWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SwornReasonWindow:OnOpen()
    self:RemoveListeners()
end

function SwornReasonWindow:OnHide()
    self:RemoveListeners()
end

function SwornReasonWindow:RemoveListeners()
end

function SwornReasonWindow:OnValueChanged(i)
    if self.toggleList[i].isOn == false then
        return
    end
    for k,v in ipairs(self.toggleList) do
        if k ~= i then
            v.isOn = false
        end
    end
    self.selectIndex = i

    for i,v in ipairs(self.toggleList) do
        local k = i
        v.onValueChanged:AddListener(function() self:OnValueChanged(k) end)
    end
end

function SwornReasonWindow:OnClick()
    if self.selectIndex == nil then
        return
    end

    local text = self.labelString[self.selectIndex]
    if text == nil then
        if self.inputField.text == "" then
            NoticeManager.Instance:FloatTipsByString(TI18N("请输入其他原因"))
            return
        else
            text = self.inputField.text
        end
    end

    if self.model.selectGetouInfo ~= nil then
        SwornManager.Instance:send17710(self.model.selectGetouInfo.id, self.model.selectGetouInfo.platform, self.model.selectGetouInfo.zone_id, self.selectIndex, text)
    end

    WindowManager.Instance:CloseWindow(self)
end

