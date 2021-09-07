-- @author 黄耀聪
-- @date 2016年7月27日

SingTimeWindow = SingTimeWindow or BaseClass(BaseWindow)

function SingTimeWindow:__init(model)
    self.model = model
    self.name = "SingTimeWindow"
    self.windowId = WindowConfig.WinID.sing_time_window

    self.resList = {
        {file = AssetConfig.sing_time_window, type = AssetType.Main},
        {file = AssetConfig.sing_res, type = AssetType.Dep},
    }

    self.tipsText = {TI18N("本服赛事结束后，好评数排名前10的选手将进入本服<color='#ffff00'>好声音名人堂</color>，获得好声音<color='#ffff00'>特殊称号</color>、<color='#ffff00'>定制聊天气泡、队长头标</color>，冠军还将获得<color='#ffff00'>特殊聊天标识与雕像</color>的荣耀{face_1,18}")}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.datalist = {
        {phase = TI18N("预选赛报名阶段"), time = TI18N("<color='#ffff00'>6月30日~7月01日</color>")},
        {phase = TI18N("预选赛投票阶段"), time = TI18N("<color='#ffff00'>7月02日~7月7日</color>")},
        {phase = TI18N("入围赛报名阶段"), time = TI18N("<color='#ffff00'>7月8日~7月10日</color>")},
        {phase = TI18N("入围赛投票阶段"), time = TI18N("<color='#ffff00'>7月12日~7月19日</color>")},
    }
    self.itemlist = {}

    self.imgLoader = nil
end

function SingTimeWindow:__delete()
    self.OnHideEvent:Fire()
    if self.model.multiItemPanel ~= nil then
        self.model.multiItemPanel:DeleteMe()
        self.model.multiItemPanel = nil
    end
    if self.model.singRankTypePanel ~= nil then
        self.model.singRankTypePanel:DeleteMe()
        self.model.singRankTypePanel = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    self:AssetClearAll()
end

function SingTimeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sing_time_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    local main = t:Find("Main")

    self.closeBtn = main:Find("CloseButton"):GetComponent(Button)
    self.container = main:Find("Bg/ScrollLayer/Container")
    self.cloner = main:Find("Bg/ScrollLayer/Cloner").gameObject
    self.gift = main:Find("Bg/Gift").gameObject
    self.giftBtn = self.gift.transform:Find("Button"):GetComponent(Button)
    self.giftImage = self.gift.transform:Find("Button/Image"):GetComponent(Image)
    self.giftImageBtn = self.giftImage.gameObject:GetComponent(Button)

    self.giftImageBtn.onClick:AddListener(function() self.giftBtn.onClick:Invoke() end)

    if self.imgLoader == nil then
        local go = self.giftImage.gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 22504)

    self.closeBtn.onClick:AddListener(function() self.model:CloseTime() end)
    self.giftBtn.onClick:AddListener(function() self:OnGiftTips() end)

    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 5, border = 0})
    main:Find("Title/Text"):GetComponent("Text").text = TI18N("星辰好声音")
end

function SingTimeWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SingTimeWindow:OnOpen()
    self:RemoveListeners()

    self:Reload()
end

function SingTimeWindow:Reload()
    self.layout:ReSet()
    for i,v in ipairs(self.datalist) do
        local tab = self.itemlist[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.cloner)
            tab.obj.name = tostring(i)
            tab.trans = tab.obj.transform
            tab.bg = tab.trans:Find("Bg").gameObject
            tab.phaseText = tab.trans:Find("Phase/Text"):GetComponent(Text)
            tab.timeText = tab.trans:Find("Time/Text"):GetComponent(Text)
            self.itemlist[i] = tab
        end

        self.layout:AddCell(tab.obj)
        if (i % 2 == 1) then
            tab.bg:GetComponent(Image).color = ColorHelper.ListItem1
        else
            tab.bg:GetComponent(Image).color = ColorHelper.ListItem2
        end

        -- tab.bg:SetActive(i % 2 == 1)
        tab.phaseText.text = v.phase
        tab.timeText.text = v.time
    end

    for i=#self.datalist + 1, #self.itemlist do
        self.itemlist[i].obj:SetActive(false)
    end

    -- self.layout:AddCell(self.gift)
    self.cloner:SetActive(false)
end

function SingTimeWindow:OnHide()
    self:RemoveListeners()
end

function SingTimeWindow:RemoveListeners()
end

function SingTimeWindow:OnGiftTips()
    self.model:ShowRankReward(self.gameObject)
end
