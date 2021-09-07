-- @author 黄耀聪
-- @date 2016年9月8日
-- 中秋中秋彩灯会

MainuiTraceSkylantern = MainuiTraceSkylantern or BaseClass(BaseTracePanel)

function MainuiTraceSkylantern:__init(main)
    self.main = main
    self.isInit = false

    self.descString = TI18N("1.按<color='#ffff00'>场景人数</color>刷出孔明灯\n2.<color='#ffff00'>抢到并答对</color>以避免被淘汰\n3.留下最后<color='#ffff00'>5人</color>将获得<color='#ffff00'>最终奖励</color>")
    self.titleString = TI18N("灯会")
    self.timeFormat1 = TI18N("%s秒")
    self.timeFormat2 = TI18N("%s分%s秒")
    self.timeFormat3 = TI18N("%s小时%s分")
    self.timeFormat4 = TI18N("%s天%s小时")

    self.resList = {
        {file = AssetConfig.lanternfair_content, type = AssetType.Main}
    }

    self.timeListener = function() self:DoTime() end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function MainuiTraceSkylantern:__delete()
    self:RemoveListeners()
end

function MainuiTraceSkylantern:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.lanternfair_content))
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.transform:Find("Main/Container"))
    self.transform.localScale = Vector3.one
    self.transform.anchoredPosition = Vector3(0, -45, 0)

    local t = self.transform

    self.titleText = t:Find("Panel/Title/Text"):GetComponent(Text)
    self.text = t:Find("Panel/Desc"):GetComponent(Text)
    self.singleLineTimeText = t:Find("Panel/TimeExt"):GetComponent(Text)
    self.extText = t:Find("Panel/Text"):GetComponent(Text)
    self.clock = t:Find("Panel/Clock").gameObject
    self.timeDescText = t:Find("Panel/Clock/Text"):GetComponent(Text)
    self.timeText = t:Find("Panel/Clock/Time"):GetComponent(Text)
    self.exitBtn = t:Find("Panel/BtnArea/Box2/Button"):GetComponent(Button)

    self.text.text = self.descString
    self.titleText.text = self.titleString
    self.singleLineTimeText.color = ColorHelper.DefaultButton1
    self.exitBtn.onClick:RemoveAllListeners()
    self.exitBtn.onClick:AddListener(function() self:OnExit() end)
    t:Find("Panel/BtnArea/Box2/Button/Text"):GetComponent(Text).text = TI18N("退出")
end

function MainuiTraceSkylantern:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiTraceSkylantern:OnShow()
    self:RemoveListeners()
    MidAutumnFestivalManager.Instance.tickEvent:AddListener(self.timeListener)

    self:DoTime()
    MidAutumnFestivalManager.Instance:ShowLanternMainUI()
end

function MainuiTraceSkylantern:OnHide()
    self:RemoveListeners()
end

function MainuiTraceSkylantern:OnExit()
    MidAutumnFestivalManager.Instance:send14059()
end

function MainuiTraceSkylantern:RemoveListeners()
    MidAutumnFestivalManager.Instance.tickEvent:RemoveListener(self.timeListener)
end

function MainuiTraceSkylantern:DoTime()
    local model = MidAutumnFestivalManager.Instance.model
    local status = model.lantern_state or 0
    local times = TI18N("0秒")

    model.lantern_target_time = model.lantern_target_time or 0

    local leftTime = model.lantern_target_time - BaseUtils.BASE_TIME
    local d = nil
    local h = nil
    local m = nil
    local s = nil
    d,h,m,s = BaseUtils.time_gap_to_timer(leftTime)
    if d > 0 then
        times = string.format(self.timeFormat4, tostring(d), tostring(h))
    elseif h > 0 then
        times = string.format(self.timeFormat3, tostring(h), tostring(m))
    elseif m > 0 then
        times = string.format(self.timeFormat2, tostring(m), tostring(s))
    elseif s > 0 then
        times = string.format(self.timeFormat1, tostring(s))
    else
        times = string.format(self.timeFormat1, tostring(0))
    end

    if status == MidAutumnFestivalManager.Instance.skyLanternStatus.FirstWave then
        self.clock:SetActive(true)
        self.singleLineTimeText.gameObject:SetActive(false)
        self.timeText.text = tostring(times)
        self.timeDescText.text = TI18N("剩余出现时间:")
        self.extText.text = TI18N("孔明灯即将刷新")
    elseif status == MidAutumnFestivalManager.Instance.skyLanternStatus.Fight then
        if MidAutumnFestivalManager.Instance.isCorrect == true then
            self.clock:SetActive(false)
            self.singleLineTimeText.gameObject:SetActive(true)
            self.singleLineTimeText.text = TI18N("恭喜进入下一轮")
            self.extText.text = TI18N("请等待其他玩家")
        else
            self.clock:SetActive(true)
            self.singleLineTimeText.gameObject:SetActive(false)
            self.timeDescText.text = TI18N("存活剩余时间:")
            self.timeText.text = tostring(times)
            self.extText.text = TI18N("答对灯谜可增加存活时间")
        end
    elseif status == MidAutumnFestivalManager.Instance.skyLanternStatus.Clean then
        if MidAutumnFestivalManager.Instance.isCorrect == false then
            self.clock:SetActive(true)
            self.singleLineTimeText.gameObject:SetActive(false)
            self.timeDescText.text = TI18N("存活剩余时间:")
            self.timeText.text = tostring(times)
            self.extText.text = TI18N("答对灯谜可增加存活时间")
        else
            self.clock:SetActive(false)
            self.singleLineTimeText.gameObject:SetActive(true)
            self.singleLineTimeText.text = TI18N("恭喜进入下一轮")
            self.extText.text = TI18N("请等待其他玩家")
        end
    elseif status == MidAutumnFestivalManager.Instance.skyLanternStatus.Wait then
        self.clock:SetActive(false)
        self.singleLineTimeText.gameObject:SetActive(true)
        self.singleLineTimeText.text = TI18N("恭喜进入下一轮")
        self.extText.text = TI18N("请等待其他玩家")
    end
end


