GloryConfirmWindow = GloryConfirmWindow or BaseClass(BaseWindow)

function GloryConfirmWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.glory_confirm_window

    self.resList = {
        {file = AssetConfig.glory_confirm_window, type = AssetType.Main}
        , {file = AssetConfig.glory_textures, type = AssetType.Dep}
    }

    self.slotList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
end

function GloryConfirmWindow:__delete()
    for k,v in pairs(self.slotList) do
        if v ~= nil then
            if v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self.slotList = nil
end

function GloryConfirmWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_confirm_window))
    self.gameObject.name = "GloryConfirmWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    local main = self.gameObject.transform:Find("Main")
    self.mainRect = main:GetComponent(RectTransform)

    self.titleText = main:Find("Title/Text"):GetComponent(Text)
    self.titleRect = main:Find("Title")

    -- 确定按钮
    self.confirmBtn = main:Find("Confirm"):GetComponent(Button)

    -- 奖励列表
    self.container = main:Find("Content/RewardPanel/Container")
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 0})
    self.rewardTitleText = main:Find("Content/RewardPanel/Title/Text"):GetComponent(Text)
    for i=1,3 do
        local tab = {}
        tab.transform = self.container:Find("Slot"..i)
        tab.gameObject = tab.transform.gameObject
        self.slotList[i] = tab
    end

    -- 信息区域
    self.descObj = main:Find("Content/Info/Desc")
    self.descExt = MsgItemExt.New(self.descObj:Find("Text"):GetComponent(Text), 380, 17, 19.68421)
    self.resultText = main:Find("Content/Info/Desc/Result"):GetComponent(Text)
    self.titleObj = main:Find("Content/Info/Title")
    self.titleImage = self.titleObj:Find("Image"):GetComponent(Image)

    self.resultText.gameObject:SetActive(false)

    self.confirmBtn.onClick:AddListener(
    function()
        if self.data.isChief == true then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.chief_challenge_window)
        elseif self.data.is_break == 1 then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_new_record_window,self.data)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.glory_window)
        end
    end)
end

function GloryConfirmWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryConfirmWindow:OnOpen()
    self.data = self.openArgs[1]
    -- local time = string.format(TI18N("%s分%s秒"), os.date("%M", self.data.time), os.date("%S", self.data.time))
    self.titleObj.gameObject:SetActive(false)
    self.descObj.gameObject:SetActive(true)

    self.descExt:SetData(self.data.msg) -- , string.format(TI18N("用时:%s 回合数:%s"), ColorHelper.Fill("#ace92a", time), ColorHelper.Fill("#ace92a", tostring(data.round)))))
    if self.data.isChief == true then
        self.titleText.text = TI18N("挑战奖励")
    else
        self.titleText.text = TI18N("爵位奖励") -- string.format(TI18N("第%s关奖励"), tostring(data.id))
    end

    local rect = self.descExt.contentTrans.sizeDelta
    self.descExt.contentTrans.anchoredPosition = Vector2(-rect.x / 2, 0)

    self.mainRect.sizeDelta = Vector2(470, 225 + rect.y)

    self.layout:ReSet()
    for i,v in ipairs(self.data.gl_list) do
        local tab = self.slotList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.slotList[1].gameObject)
            tab.transform = tab.transform
            self.slotList[i] = tab
        end
        if tab.slot == nil then
            tab.slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(tab.gameObject, tab.slot.gameObject)
        end
        self.layout:AddCell(tab.gameObject)
        tab.slot:SetAll(DataItem.data_get[v.base_id], {inbag = false, nobutton = true})
        tab.slot:SetNum(v.val)
    end
    for i=#self.data.gl_list + 1,#self.slotList do
        self.slotList[i].gameObject:SetActive(false)
    end
end
