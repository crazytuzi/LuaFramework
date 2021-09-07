PumpkinDamakuWindow = PumpkinDamakuWindow or BaseClass(BaseWindow)

function PumpkinDamakuWindow:__init(model)
    self.model = model
    self.name = "PumpkinDamakuWindow"

    self.windowId = WindowConfig.WinID.pumpkin_damaku_window

    self.resList = {
        {file = AssetConfig.pumpkin_damaku_window, type = AssetType.Main},
        -- {file = AssetConfig.halloween_textures, type = AssetType.Dep},
    }

    self.showTextList = {
        TI18N("队友加油"),
        TI18N("点我的那个你别走！！！"),
        TI18N("让我起来我还能送！！！"),
        TI18N("如果找到我，我就让你嘿嘿嘿！"),
        TI18N("看不到我，看不到我！"),
        TI18N("我要抓人了！还有谁！"),
    }
    self.itemList = {}
    self.currentIndex = nil

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PumpkinDamakuWindow:__delete()
    self.OnHideEvent:Fire()
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self:AssetClearAll()
end

function PumpkinDamakuWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.pumpkin_damaku_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.layout = LuaBoxLayout.New(t:Find("Main/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 3})
    self.cloner = t:Find("Main/Scroll/Cloner").gameObject

    self.cloner:SetActive(false)

    t:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function PumpkinDamakuWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PumpkinDamakuWindow:OnOpen()
    self:Reload()
end

function PumpkinDamakuWindow:OnHide()
end

function PumpkinDamakuWindow:Reload()
    self.layout:ReSet()
    for i,v in ipairs(self.showTextList) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.cloner)
            tab.transform = tab.gameObject.transform
            tab.tick = tab.transform:Find("Tick").gameObject
            tab.text = tab.transform:Find("Text"):GetComponent(Text)
            local j = i
            tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:OnSelect(j) end)
            self.itemList[i] = tab
        end
        tab.text.text = v
        self.layout:AddCell(tab.gameObject)
        tab.tick:SetActive(false)
    end
    for i=#self.showTextList + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
end

function PumpkinDamakuWindow:OnSelect(index)
    if self.currentIndex ~= nil then
        self.itemList[self.currentIndex].tick:SetActive(false)
    end
    self.itemList[index].tick:SetActive(true)
    self.currentIndex = index
end

function PumpkinDamakuWindow:OnClick()
    if self.currentIndex ~= nil then
        -- 对接发送弹幕协议
        -- NoticeManager.Instance:FloatTipsByString(string.format("发弹幕啦！%s", string.format(self.showTextList[self.currentIndex], )))
        HalloweenManager.Instance:send17836(self.currentIndex)

        WindowManager.Instance:CloseWindow(self)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要发送的内容"))
    end
end

