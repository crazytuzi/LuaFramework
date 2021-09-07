-- @author 黄耀聪
-- @date 2016年9月8日
-- 中秋孔明灯会

MainuiTraceEnjoymoon = MainuiTraceEnjoymoon or BaseClass()

function MainuiTraceEnjoymoon:__init(main)
    self.main = main
    self.isInit = false
    self.titleString = TI18N("赏月晚会")
    self.exitString = TI18N("退出")
    self.mgr = MidAutumnFestivalManager.Instance
    self.model = self.mgr.model

    self.timeFormat2 = TI18N("%s小时")
    self.timeFormat3 = TI18N("%s分钟")
    self.timeFormat4 = TI18N("%s秒")
    self.timeString2 = TI18N("活动已结束")

    self.infoListener = function() self:OnInfo() end
    self.tickListener = function() self:OnTick() end
    self.redListener = function() self:CheckRed() end

    self.descTips =  {
        TI18N("1.盛大的中秋晚会开始，活动场景内即可获得{assets_2,90010}"),
        TI18N("2.每隔一段时间，酒麦大叔将洒下月宫宝箱"),
        TI18N("3.祈愿放飞带有祝福的孔明灯，将获得丰厚奖励喔"),
        TI18N("4.请大家发表祝福，享受这美好的中秋月圆之夜吧^_^"),
    }

    self.resList = {
        {file = AssetConfig.enjoymoon_content, type = AssetType.Main}
    }

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceEnjoymoon:__delete()
    self:RemoveListeners()
end

function MainuiTraceEnjoymoon:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.enjoymoon_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition3D = Vector3(0, -45, 0)
    local t = self.transform

    self.titleText = t:Find("Panel/Title/Text"):GetComponent(Text)
    self.timeText = t:Find("Panel/PhaseBattle/Time/Text"):GetComponent(Text)
    self.expText = t:Find("Panel/PhaseBattle/Exp/Text"):GetComponent(Text)
    self.exitBtn = t:Find("Panel/BtnArea/Box2/Button"):GetComponent(Button)
    self.button = t:Find("Panel/PhaseBattle/Button"):GetComponent(Button)
    self.toggle = t:Find("Panel/PhaseBattle/Toggle"):GetComponent(Toggle)
    self.toggle1 = t:Find("Panel/PhaseBattle/Toggle1"):GetComponent(Toggle)
    self.button.gameObject:SetActive(false)

    local obj = t:Find("Panel/PhaseBattle/InfoBtn")
    obj:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = obj, itemData = self.descTips}) end)

    self.rankList = self.rankList or {}
    local rank = t:Find("Panel/PhaseBattle/Rank")
    rank:Find("Panel").gameObject:SetActive(true)
    for i=1,rank.childCount-1 do
        local item = rank:GetChild(i - 1)
        local tab = {}
        tab.obj = item.gameObject
        tab.rankText = item:Find("Rank"):GetComponent(Text)
        tab.nameText = item:Find("Name"):GetComponent(Text)
        tab.scoreText = item:Find("Score"):GetComponent(Text)
        self.rankList[i] = tab
    end
    self.rankObj = rank.gameObject

    self.titleText.text = self.titleString
    t:Find("Panel/BtnArea/Box2/Button/Text"):GetComponent(Text).text = self.exitString
    self.extText = t:Find("Panel/PhaseBattle/I18N_Text").gameObject
    self.exitBtn.onClick:AddListener(function() self:OnExit() end)
    t:Find("Panel/BtnArea/Box1/Button"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_letitgo, {1}) end)
    self.box1Red = t:Find("Panel/BtnArea/Box1/Button/NotifyPoint").gameObject
    self.box1Red:SetActive(false)

    self.button.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_letitgo, {1}) end)
    self.rankObj:GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_letitgo, {2}) end)
    t:Find("Panel/PhaseBattle/Bless"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.mid_autumn_letitgo, {1}) end)

    self.toggle.isOn = false
    self.toggle.onValueChanged:AddListener(function() self:OnValueChanged() end)

    self.toggle1.onValueChanged:RemoveAllListeners()
    self.toggle1.isOn = self.model.hideStatus
    self.toggle1.onValueChanged:AddListener(function(status) self:SetHide(status) end)

    self:OnValueChanged()
end

function MainuiTraceEnjoymoon:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceEnjoymoon:OnShow()
    self:RemoveListeners()
    self.mgr.infoEvent:AddListener(self.infoListener)
    self.mgr.tickEvent:AddListener(self.tickListener)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.redListener)

    self:OnInfo()
    self:CheckRed()
    MidAutumnFestivalManager.Instance:ShowEnjoyMoonMainUI()
    MidAutumnFestivalManager.Instance:send14065()
end

function MainuiTraceEnjoymoon:OnHide()
    self:RemoveListeners()
end

function MainuiTraceEnjoymoon:OnExit()
    local confirmData = NoticeConfirmData.New()
    confirmData.type = ConfirmData.Style.Normal
    confirmData.cancelSecond = 30
    confirmData.sureLabel = TI18N("确认")
    confirmData.cancelLabel = TI18N("取消")
    confirmData.sureCallback = function()
        MidAutumnFestivalManager.Instance:send14061()
    end
    confirmData.content = TI18N("是否退出赏月会？")
    NoticeManager.Instance:ConfirmTips(confirmData)
end

function MainuiTraceEnjoymoon:OnInfo()
    local model = self.model
    self.expText.text = tostring(model["enjoymoon_add_exp"] or 0)

    local list = model["enjoymoon_rank_info"] or {}
    table.sort(list, function(a,b) return a.wish_val > b.wish_val end)

    for i,v in ipairs(self.rankList) do
        local data = list[i]
        if data == nil then
            v.obj:SetActive(false)
        else
            v.obj:SetActive(true)
            v.rankText.text = tostring(i)
            v.nameText.text = data.guild_name
            v.scoreText.text = tostring(data.wish_val)
        end
    end

    if #list > 0 then
        self.button.gameObject:SetActive(false)
        self.extText.gameObject:SetActive(false)
        self.toggle.gameObject:SetActive(true)
        self.toggle1.gameObject:SetActive(true)
    else
        self.extText.gameObject:SetActive(true)
        self.button.gameObject:SetActive(false)
        self.toggle.gameObject:SetActive(false)
        self.toggle1.gameObject:SetActive(false)
    end
end

function MainuiTraceEnjoymoon:OnTick()
    local model = self.model
    local left_time = model["enjoymoon_left_time"] or 0
    local h = 0
    local m = 0
    local s = 0
    _,h,m,s = BaseUtils.time_gap_to_timer(left_time)
    if h > 0 then
        self.timeText.text = string.format(self.timeFormat2, tostring(h))
    elseif m > 0 then
        self.timeText.text = string.format(self.timeFormat3, tostring(m))
    elseif s > 0 then
        self.timeText.text = string.format(self.timeFormat4, tostring(s))
    else
        self.timeText.text = self.timeString2
    end
end

function MainuiTraceEnjoymoon:RemoveListeners()
    self.mgr.infoEvent:RemoveListener(self.infoListener)
    self.mgr.tickEvent:RemoveListener(self.tickListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.redListener)
end

function MainuiTraceEnjoymoon:OnValueChanged()
    DanmakuManager.Instance.CloseNormal = (self.toggle.isOn == true)
end

function MainuiTraceEnjoymoon:CheckRed()
    local num = BackpackManager.Instance:GetItemCount(23596) + BackpackManager.Instance:GetItemCount(23597)
    if num > 0 then
        self.box1Red:SetActive(true)
    else
        self.box1Red:SetActive(false)
    end
end

function MainuiTraceEnjoymoon:SetHide(status)
    self.mgr:SetEnjoymoonHide(status)
end


