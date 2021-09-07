--公会宝藏开启时间设定面板
-- @author zgs
GuildfightSetTimePanel = GuildfightSetTimePanel or BaseClass(BasePanel)

function GuildfightSetTimePanel:__init(model)
    self.model = model
    self.name = "GuildfightSetTimePanel"

    self.resList = {
        {file = AssetConfig.guild_fight_settime_panel, type = AssetType.Main}
    }
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:UpdatePanel()
    end)

    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        self:RemovePanel()
    end)
    self.lastToggle = nil
    self.timeList = {
        0,
        3600 * 13,
        3600 * 14,
        3600 * 15,
        3600 * 16,
        3600 * 17,
        3600 * 18,
        3600 * 19,
    }
    self.timeHourList = {
        0,
        13,
        14,
        15,
        16,
        17,
        18,
        19,
    }

    self.selectIndex = 1 --选择今天 = 1 ,明天 = 2
end


function GuildfightSetTimePanel:RemovePanel()
    self:DeleteMe()
end

function GuildfightSetTimePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdatePanel()
end

function GuildfightSetTimePanel:__delete()
    self.model.guildfightSetTimePanel = nil
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function GuildfightSetTimePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_settime_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.sureBtn = self.transform:Find("Main/Button"):GetComponent(Button)
    self.sureBtn.onClick:AddListener(function()
        self:OnClicksureBtn()
    end)

    self.timeText = self.transform:Find("Main/CImage/CTImage/Text"):GetComponent(Text)

    self.toggleGroup = self.transform:Find("Main/CImage/ToggleParent"):GetComponent(ToggleGroup)
    self.toggleList = {}
    for i=1,8 do
        local togDic = {}
        togDic.tog = self.toggleGroup.transform:Find("Toggle_"..i):GetComponent(Toggle)
        togDic.tog.onValueChanged:AddListener(function(status) self:OnCheck(i,status) end)
        togDic.txt = togDic.tog.gameObject.transform:Find("Label"):GetComponent(Text)
        self.toggleList[i] = togDic
    end

    self.ctImageBtn = self.transform:Find("Main/CImage/CTImage"):GetComponent(Button)
    self.ctImageBtn.onClick:AddListener(function()
        self:OnClickShowDragList()
    end)
    self.flagImageObj = self.transform:Find("Main/CImage/CTImage/FlagImage").gameObject --向下
    self.flagImageObj2 = self.transform:Find("Main/CImage/CTImage/FlagImage2").gameObject --向上
    self.flagImageObj2:SetActive(false)
    self.dragListObj = self.transform:Find("Main/CImage/DragListBgImage").gameObject
    self.dragListObj.transform:Find("TodayImage"):GetComponent(Button).onClick:AddListener(function()
        self:OnClickChooseDay(1)
    end)
    self.dragListObj.transform:Find("TomorrowImage"):GetComponent(Button).onClick:AddListener(function()
        self:OnClickChooseDay(2)
    end)

    self:DoClickPanel()
end

function GuildfightSetTimePanel:OnClickChooseDay(index)
    self.dragListObj:SetActive(false)
    self.flagImageObj:SetActive(true)
    self.flagImageObj2:SetActive(false)

    self.selectIndex = index
    if self.selectIndex == 1 then
        self.timeText.text = TI18N("今 天")
    else
        self.timeText.text = TI18N("明 天")
    end
    self:CheckToggleSelect()
end

function GuildfightSetTimePanel:OnClickShowDragList()
    self.dragListObj:SetActive(true)
    self.flagImageObj:SetActive(false)
    self.flagImageObj2:SetActive(true)
end

function GuildfightSetTimePanel:OnCheck(index, status)
    if status == true then
        self.dragListObj:SetActive(false)
        local ph = tonumber(os.date("%H", BaseUtils.BASE_TIME)) * 3600
        if self.selectIndex == 1 and index > 1 and ph >= self.timeList[index] then
            --
            NoticeManager.Instance:FloatTipsByString(TI18N("时间已过"))
            self.lastToggle.isOn = true
        elseif self.selectIndex == 2 and index == 1 then
            -- print(debug.traceback())
            NoticeManager.Instance:FloatTipsByString(TI18N("明天的当前时间不可选"))
            self.lastToggle.isOn = true
        else
            self.lastToggle = self.toggleList[index].tog
        end
    end
end

function GuildfightSetTimePanel:OnClicksureBtn()
    --确定
    local index = 1
    for i,v in ipairs(self.toggleList) do
        if v.tog.isOn == true then
            index = i
            break
        end
    end
    local timeTemp = self.timeList[index] + 86400 * (self.selectIndex - 1)
    -- print("GuildfightSetTimePanel:OnClicksureBtn()"..timeTemp)
    GuildManager.Instance:request11178(timeTemp)
    self:OnClickClose()
    -- NoticeManager.Instance:FloatTipsByString("开启时间设定成功")
end

function GuildfightSetTimePanel:OnClickClose()
    self:Hiden()
end

function GuildfightSetTimePanel:DoClickPanel()
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


function GuildfightSetTimePanel:UpdatePanel()
    -- self.toggleList[1].tog.isOn = true
    -- local weekday = tonumber(os.date("%w", GuildManager.Instance.model.guildTreasure.setting_time))
    -- print(weekday .. "==GuildfightSetTimePanel:UpdatePanel()")
    -- if weekday == 2 then
    --     self.timeText.text = "本周三"
    -- else
    --     self.timeText.text = "本周五"
    -- end
    self.dragListObj:SetActive(false)
    self.flagImageObj:SetActive(true)
    self.flagImageObj2:SetActive(false)
    self.timeText.text = TI18N("今 天")
    self.selectIndex = 1
    self:CheckToggleSelect()
end

function GuildfightSetTimePanel:CheckToggleSelect()
    local ph = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    -- self.toggleList[1].tog.isOn = false
    if self.selectIndex == 1 then
        --今天
        self.toggleList[1].tog.isOn = true
        self.lastToggle = self.toggleList[1].tog
        for i=2,8 do
            local tog = self.toggleList[i].tog
            local txt = self.toggleList[i].txt
            if ph >= self.timeHourList[i] then
                --时间已过
                txt.text = string.format("<color='#808080'>%s:00</color>", self.timeHourList[i])
            else
                --时间未到
                txt.text = string.format("%s:00", self.timeHourList[i])
            end
        end
        self.toggleList[1].txt.text = string.format(TI18N("当前"))
    else
        self.toggleList[2].tog.isOn = true
        self.lastToggle = self.toggleList[2].tog
        self.toggleList[1].txt.text = string.format(TI18N("<color='#808080'>当前</color>"))
        for i=2,8 do
            local txt = self.toggleList[i].txt
            txt.text = string.format("%s:00", self.timeHourList[i])
        end
    end
end
