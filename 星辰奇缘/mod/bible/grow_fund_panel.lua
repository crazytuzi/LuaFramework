GrowFundPanel = GrowFundPanel or BaseClass(BasePanel)

function GrowFundPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GrowFundPanel"

    self.resList = {
        {file = AssetConfig.grow_fund_panel, type = AssetType.Main},
        {file = AssetConfig.grow_fund_bg, type = AssetType.Main},
        {file = AssetConfig.button1, type = AssetType.Dep},
        {file = AssetConfig.open_server_textures, type = AssetType.Dep},
    }

    self.grow_bool =  false
    self.grow_type = 980
    -- self.rechargeAmount = 198
    self.buttonString = TI18N("现在购买\n立即领取")
    self.itemList = {}
    self.effectList = {}
    self.itemEffectList = {}

    self.updateListener = function() self:Reload() end
    self.showeffectListener = function() self:ShowRightEffect() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GrowFundPanel:OnOpen()
    self:RemoveListeners()
    PrivilegeManager.Instance.growthFundEvent:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.updateListener)
    BibleManager.Instance.showgrowEffect:AddListener(self.showeffectListener)

    self:Reload()
end

function GrowFundPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GrowFundPanel:OnHide()
    self:RemoveListeners()
end

function GrowFundPanel:__delete()
    self.OnHideEvent:Fire()
    if self.itemEffectList ~= nil then
        for _,v in pairs(self.itemEffectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemEffectList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v.data:DeleteMe()
                v.slot:DeleteMe()
                v.descExt:DeleteMe()
            end
        end
        self.itemList = nil
    end
    if self.specialTab ~= nil then
        self.specialTab.data:DeleteMe()
        self.specialTab.slot:DeleteMe()
        self.specialTab.descExt:DeleteMe()
    end

    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end

    if self.flashEffect ~= nil then
        self.flashEffect:DeleteMe()
        self.flashEffect = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function GrowFundPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.grow_fund_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = t

    self.bgObj = t:Find("Layer/Bg").gameObject
    UIUtils.AddBigbg(t:Find("Layer/Bg/Con"), GameObject.Instantiate(self:GetPrefab(AssetConfig.grow_fund_bg)))

    self.topTitle = t:Find("Layer/Bg/Text"):GetComponent(Text)
    self.topTitle.text = TI18N("<color='#00ff00'>65级</color>以下可购买")
    self.topTitle.transform.anchoredPosition = Vector2(215,10)

    self.noticeBtn = t:Find("Layer/Bg/Notice"):GetComponent(Button)
    self.noticeBtn.transform.anchoredPosition = Vector2(134.8, 8.1)

    self.scrollTrans = t:Find("Layer/Scroll")
    self.layout = LuaBoxLayout.New(t:Find("Layer/Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 5})
    self.special = t:Find("Layer/Scroll/Special").gameObject
    self.cloner = t:Find("Layer/Scroll/Cloner").gameObject

    self.scrollTrans:GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)

    self.special.transform:Find("Button/Text"):GetComponent(Text).text = self.buttonString
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)

    self.bigRewardContainer = t:Find("Layer/BigRewardContainer")
    self.bigRewardContainer:Find("Left/Button"):GetComponent(Button).onClick:AddListener(function()  self:OpenSubPanel(980) end)
    self.bigRewardContainer:Find("Right/Button"):GetComponent(Button).onClick:AddListener(function() self:OpenSubPanel(1980) end)

    self.bigRewardContainer:Find("Left/Button/MoreButton"):GetComponent(Button).enabled = false
    self.bigRewardContainer:Find("Right/Button/MoreButton"):GetComponent(Button).enabled = false

    self.bigRewardContainer:Find("Left/Button/MoreButton"):GetComponent(TransitionButton).enabled = false
    self.bigRewardContainer:Find("Right/Button/MoreButton"):GetComponent(TransitionButton).enabled = false

    self.bigRewardContainer:Find("Left/Button98"):GetComponent(Button).onClick:AddListener(function()
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = TI18N("两种基金只能<color='#ffff00'>二选一</color>哟，是否确认购买<color='#ffff00'>福利基金</color>？")
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                self:OnRecharge(98)
            end
            NoticeManager.Instance:ConfirmTips(data)
        end)
    self.bigRewardContainer:Find("Right/Button98"):GetComponent(Button).onClick:AddListener(function() self:OnRecharge(198)  end)

    self.flashimg = self.bigRewardContainer:Find("Right/Button/Flash"):GetComponent(Image)
    self.flashimg.enabled = false
    if self.flashEffect == nil then
        self.flashEffect = BaseUtils.ShowEffect(20419,self.flashimg.transform,Vector3(0.76,0.76,0.76),Vector3(0,0,-250))
    end

    self.growExt = MsgItemExt.New(t:Find("Layer/Tips/Text"):GetComponent(Text), 415, 16, 29)
end

function GrowFundPanel:Reload()
    local grow_type =(PrivilegeManager.Instance.growthFundStatus or {}).gold
    if grow_type == 1980 or grow_type == 980 then
        self.grow_bool = true
        self.grow_type = grow_type
    end
    local bool = self.grow_bool

    self.bigRewardContainer.gameObject:SetActive(not bool)
    self.scrollTrans.gameObject:SetActive(bool)
    self.transform:Find("Layer/Tips").gameObject:SetActive(bool)
    if not bool then return end

    ---------------------------------
    local totalBlue = 0
    local totalRed = 0
    local tips = ""

    if grow_type == 980 then
        tips = TI18N("福利基金")
    else
        tips = TI18N("豪华基金")
    end

    -- self.rechargeAmount = grow_type / 10

    for i = 1,8 do
        local key = string.format("%s_%s",grow_type,i)
        local basedata = DataGrowthFund.data_growth[key]
        if basedata.reward[1][1] == 90002 then
            totalBlue = totalBlue + basedata.reward[1][2]
        elseif basedata.reward[1][1] == 90026 then
            totalRed = totalRed + basedata.reward[1][2]
        end
    end

    ----------------------------------
    self.growExt:SetData(string.format(TI18N("已购买<color='#fff000'>%s</color>,总计获得%s{assets_2,90002}%s{assets_2,90026}"),tips,totalBlue,totalRed))

    local datalist = {}
    for i = 1, 8 do
        table.insert(datalist, false)
    end
    local receiveArray = (PrivilegeManager.Instance.growthFundStatus or {}).rewards or {}
    for _,v in ipairs(receiveArray) do
        datalist[v.id] = true
    end

    self.layout:ReSet()
    -- if bool == true then
    self.bgObj:SetActive(false)
    self.scrollTrans.sizeDelta = Vector2(541, 390)
    self.special:SetActive(false)
    -- else
    --     self.bgObj:SetActive(true)
    --     self:SetSpecial()
    --     self.special:SetActive(true)
    --     self.scrollTrans.sizeDelta = Vector2(541, 350)
    --     self.layout:AddCell(self.special)
    -- end

    local lev = RoleManager.Instance.RoleData.lev

    local pos = nil

    for i,v in ipairs(datalist) do
        local tab = self.itemList[i]
        local key = string.format("%s_%s",grow_type,i)
        local basedata = DataGrowthFund.data_growth[key]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.cloner)
                tab.transform = tab.gameObject.transform
                tab.slot = ItemSlot.New()
                tab.data = ItemData.New()
                NumberpadPanel.AddUIChild(tab.transform:Find("Con"), tab.slot.gameObject)
                tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
                tab.descExt = MsgItemExt.New(tab.transform:Find("Desc"):GetComponent(Text),  283, 18, 21)
                tab.button = tab.transform:Find("Button"):GetComponent(Button)
                tab.result = tab.transform:Find("Result").gameObject
                tab.resButton = tab.result:GetComponent(Button)
                tab.resultText = tab.transform:Find("Result/Text"):GetComponent(Text)
                tab.button.gameObject:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.button1, "Button1Green")
                local j = i
                tab.button.onClick:AddListener(function() self:OnReceive(j) end)
                tab.resButton.onClick:AddListener(function() self:OnResClick(j) end)
                self.itemList[i] = tab
            end
            tab.data:SetBase(DataItem.data_get[basedata.reward[1][1]])
            tab.slot:SetAll(tab.data, {inbag = false, nobuton = true})
            tab.slot:SetNum(basedata.reward[1][2])

            if GlobalEumn.CostTypeIconName[basedata.reward[1][1]] ~= nil then
                tab.slot:SetItemSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[basedata.reward[1][1]]))
            end

            if lev < basedata.lev then      -- 等级不足
                tab.resultText.text = string.format(TI18N("<color='#00ff00'>%s</color>级可领取"), tostring(basedata.lev))
                tab.resultText.gameObject:SetActive(true)
                tab.button.gameObject:SetActive(false)
            else
                tab.resultText.text = TI18N("已领取")
                tab.resultText.gameObject:SetActive(v == true)
                tab.result:SetActive(v == true)
                tab.button.gameObject:SetActive(v ~= true)

                if pos == nil and v ~= true then
                    pos = tab.transform.anchoredPosition.y
                end

                if v ~= true then
                    if self.effectList[i] == nil then
                        self.effectList[i] = BibleRewardPanel.ShowEffect(20118, tab.button.gameObject.transform, Vector3(0.95, 0.7, 1), Vector3(-49.7, 19.3, 0))
                    end
                else
                    if self.effectList[i] ~= nil then
                        self.effectList[i]:DeleteMe()
                        self.effectList[i] = nil
                    end
                end
            end

            tab.descExt:SetData(string.format(TI18N("立即返还：<color='#ffff00'>%s</color>{assets_2, %s}"), tostring(basedata.reward[1][2]), tostring(basedata.reward[1][1])))
            if i == 1 then
                tab.nameText.text = TI18N("购买基金")
            else
                tab.nameText.text = string.format(TI18N("达到%s级"), tostring(basedata.lev))
            end

            self.layout:AddCell(tab.gameObject)

        if self.itemEffectList[i] == nil and self.itemList[i] ~= nil then
            self.itemEffectList[i]= BibleRewardPanel.ShowEffect(20223,self.itemList[i].slot.transform,Vector3(1, 1, 1), Vector3(0, 0, 0))
        end
    end

    for i=#datalist + 1, #self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end

    self.layout.panelRect.anchoredPosition = Vector2(0, pos or 0)

    self.cloner:SetActive(false)
    self:OnValueChanged()
end

-- function GrowFundPanel:SetSpecial()
--     local tab = self.specialTab
--     if tab == nil then
--         tab = {}
--         tab.gameObject = self.special
--         tab.transform = tab.gameObject.transform
--         tab.slot = ItemSlot.New()
--         tab.data = ItemData.New()
--         NumberpadPanel.AddUIChild(tab.transform:Find("Con"), tab.slot.gameObject)
--         tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
--         tab.descExt = MsgItemExt.New(tab.transform:Find("Desc"):GetComponent(Text), 283, 18, 21)
--         tab.button = tab.transform:Find("Button"):GetComponent(Button)
--         tab.resultText = tab.transform:Find("Result"):GetComponent(Text)

--         tab.nameText.text = TI18N("购买基金")
--         tab.descExt:SetData(string.format(TI18N("立即返还：<color='#ffff00'>%s0</color>{assets_2,90002}"), tostring(self.rechargeAmount)))
--         tab.data:SetBase(DataItem.data_get[90002])
--         tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
--         tab.slot:SetNum(self.rechargeAmount * 10)
--         tab.button.onClick:AddListener(function() self:OnRecharge(198) end)

--         if self.itemEffectList[0] == nil then
--             self.itemEffectList[0]= BibleRewardPanel.ShowEffect(20223,tab.slot.transform,Vector3(1, 1, 1), Vector3(0, 0, 0))
--         end
--     end
-- end

function GrowFundPanel:RemoveListeners()
    PrivilegeManager.Instance.growthFundEvent:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.updateListener)
    BibleManager.Instance.showgrowEffect:RemoveListener(self.showeffectListener)
end

-- 新充值类型 4 成长基金
function GrowFundPanel:OnRecharge(money)
    if RoleManager.Instance.RoleData.lev < 65 then
        if SdkManager.Instance:RunSdk() then
            -- SdkManager.Instance:ShowChargeView(string.format("StardustRomance3K%s0", tostring(money)), money, money * 10, "4")
            SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(tonumber(money)*10), money, money * 10, "4")
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("65级或以上的玩家不能购买成长基金"))
    end
end

function GrowFundPanel:OnReceive(i)
    PrivilegeManager.Instance:send9936(i)
end

function GrowFundPanel:OnValueChanged()
    -- if self.lastTime ~= BaseUtils.BASE_TIME then
        local y = self.layout.panelRect.anchoredPosition.y
        local height = self.scrollTrans.rect.height
        for _,v in pairs(self.itemEffectList) do
            if v ~= nil and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
                local item = v.gameObject.transform.parent.parent.parent
                v.gameObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
            end
        end
        for _,v in pairs(self.effectList) do
            if v ~= nil and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
                local item = v.gameObject.transform.parent.parent
                v.gameObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
            end
        end
    --     self.lastTime = BaseUtils.BASE_TIME
    -- end
end

function GrowFundPanel:OnResClick(i)
    local bool = self.grow_bool
    local lev = RoleManager.Instance.RoleData.lev
    local key = string.format("%s_%s",self.grow_type,i)
    local basedata = DataGrowthFund.data_growth[key]
    if bool == true then
        if basedata.lev > lev then
            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#00ff00'>%s级</color>可领取"), tostring(basedata.lev)))
        end
    else
        -- self:OnRecharge((self.grow_type/10))
    end
end

function GrowFundPanel:OnNotice()
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {"1.成长基金只能在<color='#ffff00'>本页面</color>进行购买激活，商城充值无法激活", "2.成长基金<color='#ffff00'>不会触发</color>充值返利，累计充值等奖励"}})
end


function GrowFundPanel:OpenSubPanel(grow_type)
    if self.subpanel == nil then
        self.subpanel = GrowFundSubPanel.New(self.model,self.model.bibleWin.gameObject)
    end
    self.subpanel:Show(grow_type)
    self.flashimg.enabled = true
    self.flashEffect.gameObject:SetActive(false)
end

function GrowFundPanel:ShowRightEffect()
    self.flashimg.enabled = false
    if self.flashEffect ~= nil then
        self.flashEffect.gameObject:SetActive(true)
    end
end
