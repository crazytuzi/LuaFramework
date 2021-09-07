-- 主界面 万圣节南瓜精标题
-- ljh 20161021

HalloweenTitleView = HalloweenTitleView or BaseClass(BasePanel)

local Vector3 = UnityEngine.Vector3
function HalloweenTitleView:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.halloweentitle, type = AssetType.Main}
        , {file = AssetConfig.halloween_textures, type = AssetType.Dep}
    }

    self.name = "HalloweenTitleView"

    self.skillId = {
        {base_id = 82180, cd = 60},
        {base_id = 82181, cd = 60},
    }

    self.canUseSkill = {}
    self.isUp = {}

    self.gameObject = nil
    self.transform = nil

    ------------------------------------
    self.timeText = nil
    self.text1 = nil
    self.text2 = nil

    self.tipsString = { TI18N("1.成功识破敌方选手积分<color='#ffff00'>+1</color>分，被识破则<color='#ffff00'>不加分</color>")
                        , TI18N("2.<color='#ffff00'>无法识破</color>已倒地的南瓜精")
                        , TI18N("3.被识破后需等待<color='#ffff00'>20s</color>才能复活，冷却时间内无法识破他人且不会被他人识破")
                        , TI18N("4.<color='#ffff00'>美猴王</color>拥有火眼金睛会识破离自己一定范围内的玩家，千万要躲远点哦")
                        , TI18N("5.率先获得<color='#ffff00'>20分</color>的队伍直接获胜，若倒计时结束后双方得分相同则<color='#ffff00'>率先达到</color>该得分的一方获得胜利")
                    }
    ------------------------------------
    self._update = function()
    	self:update()
	end

    self._update_time = function()
        self:update_time()
    end

    self.traceListener = function() self:HideOrShowTrace() end

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

	-- self:LoadAssetBundleBatch()
end

function HalloweenTitleView:__delete()
    self.OnHideEvent:Fire()
    for i,v in ipairs(self.slotList) do
        if v.slot ~= nil then
            v.slot:DeleteMe()
            v.slot = nil
        end
    end
    self.slotList = nil

    self:AssetClearAll()
end

function HalloweenTitleView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloweentitle))
    self.gameObject.name = self.name
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3.zero
    self.gameObject.transform.localScale = Vector3.one

    self.gameObject.transform.anchoredPosition = Vector2.zero

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform

    -- transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guildleaguebig, "GuildLeaguebig1")

    self.button = transform:FindChild("Bg/Button").gameObject
    self.button:GetComponent(Button).onClick:AddListener(function() self:button_click() end)

    self.timeText = transform:FindChild("Bg/TimeText"):GetComponent(Text)
    self.text1 = transform:FindChild("Text1"):GetComponent(Text)
    self.text2 = transform:FindChild("Text2"):GetComponent(Text)
    self.damakuBtn = transform:Find("DamakuBtn"):GetComponent(Button)
    self.damakuBtn.onClick:AddListener(function() self:OnDanmaku() end)

    self.slotList = {}
    self.skillContainer = transform:Find("SkillArea")
    for i=1,2 do
        self.slotList[i] = {}
        local slot = SkillSlot.New()
        NumberpadPanel.AddUIChild(self.skillContainer:GetChild(i - 1).gameObject, slot.gameObject)
        local trans = self.skillContainer:GetChild(i - 1)
        local nameText = trans:Find("Name"):GetComponent(Text)
        slot.gameObject.transform:SetAsFirstSibling()
        self.slotList[i].slot = slot
        self.slotList[i].maskImg = trans:Find("Mask"):GetComponent(Image)
        self.slotList[i].timeText = trans:Find("Time"):GetComponent(Text)
        self.slotList[i].nameText = nameText
        self.slotList[i].customButton = trans:GetComponent(CustomButton)

        local j = i
        if i == 1 then
            slot:SetAll(Skilltype.petskill, DataSkill.data_skill_other[self.skillId[i].base_id])
        else
            slot:SetAll(Skilltype.wingskill, DataSkill.data_skill_other[self.skillId[i].base_id])
        end
        self.slotList[i].customButton.onDown:AddListener(function() self:OnDown(j) end)
        self.slotList[i].customButton.onUp:AddListener(function() self:OnUp(j) end)
        self.slotList[i].customButton.onHold:AddListener(function() self:OnHold(j) end)
        self.slotList[i].customButton.onClick:AddListener(function() self:OnClick(j) end)
        nameText.text = DataSkill.data_skill_other[self.skillId[i].base_id].name
    end

 --    -----------------------------
 --    EventMgr.Instance:AddListener(event_name.treasuremap_compass_update, self._update)
 --    EventMgr.Instance:AddListener(event_name.scene_load, self._change_map)

end

function HalloweenTitleView:OnInitCompleted()
    self:OnShow()
end

function HalloweenTitleView:OnShow()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.halloween_rank_update, self._update)
    EventMgr.Instance:AddListener(event_name.trace_quest_hide, self.traceListener)
    EventMgr.Instance:AddListener(event_name.trace_quest_show, self.traceListener)

    self:update()
    if self.timerId == nil then
        self.timerId = LuaTimer.Add(0, 1000, self._update_time)
    end

    if self.skillTimerId ~= nil then
        LuaTimer.Delete(self.skillTimerId)
        self.skillTimerId = nil
    end
    self.skillTimerId = LuaTimer.Add(0, 100, function() self:OnTime() end)

    self:HideOrShowTrace()
end

function HalloweenTitleView:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.halloween_rank_update, self._update)
    EventMgr.Instance:RemoveListener(event_name.trace_quest_hide, self.traceListener)
    EventMgr.Instance:RemoveListener(event_name.trace_quest_show, self.traceListener)
end

function HalloweenTitleView:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.skillTimerId ~= nil then
        LuaTimer.Delete(self.skillTimerId)
        self.skillTimerId = nil
    end
    for i,v in ipairs(self.slotList) do
        if v.arrowEffect ~= nil then
            v.arrowEffect:SetActive(false)
        end
    end
end

function HalloweenTitleView:update()
    if not BaseUtils.is_null(self.gameObject) then
        self.text1.text = tostring(self.model.blue_score)
        self.text2.text = tostring(self.model.red_score)
    end
end

function HalloweenTitleView:update_time()
    if self.model.end_time >= BaseUtils.BASE_TIME then
        self.timeText.text = BaseUtils.formate_time_gap(self.model.end_time - BaseUtils.BASE_TIME, ":", 0, BaseUtils.time_formate.MIN)
    end
end

function HalloweenTitleView:button_click()
     TipsManager.Instance:ShowText({gameObject = self.button, itemData = self.tipsString})
end

function HalloweenTitleView:OnHold(index)
    TipsManager.Instance:ShowText({gameObject = self.slotList[index].slot.gameObject, itemData = {DataSkill.data_skill_other[self.skillId[index].base_id].desc}})
end

function HalloweenTitleView:ShowHoldEffect(i, bool)
    if bool ~= false then
        if self.slotList[i].arrowEffect == nil then
            self.slotList[i].arrowEffect = BibleRewardPanel.ShowEffect(20009, self.slotList[i].slot.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            self.slotList[i].arrowEffect:SetActive(true)
        end
    else
        if self.slotList[i].arrowEffect ~= nil then
            self.slotList[i].arrowEffect:SetActive(false)
        end
    end
end

function HalloweenTitleView:OnDown(index)
    self.isUp[index] = false
    self.canClick = true
    LuaTimer.Add(150, function()
        if self.isUp[index] ~= false then
            return
        end
        self:ShowHoldEffect(index)
        self.canClick = false
    end)
end

function HalloweenTitleView:OnUp(index)
    self.isUp[index] = true
    self:ShowHoldEffect(index, false)
end

function HalloweenTitleView:OnClick(index)
    if self.canClick == true then
        if self.canUseSkill[index] == true then
            if index == 1 then
                HalloweenManager.Instance:send17834()
            elseif index == 2 then
                HalloweenManager.Instance:send17835()
            end
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("技能冷却中"))
        end
    end
end

function HalloweenTitleView:OnTime()
    for i,v in ipairs(self.slotList) do
        local dis = ((HalloweenManager.Instance.model.skillStatusList[self.skillId[i].base_id] or {}).timestamp or 0) - BaseUtils.BASE_TIME
        if dis > 0 then
            self.canUseSkill[i] = false
            v.maskImg.fillAmount = dis / self.skillId[i].cd
            v.timeText.gameObject:SetActive(true)
            if dis > 30 then
                v.timeText.text = string.format("<color='#00ff00'>%smin</color>", math.ceil(dis / 60))
            else
                v.timeText.text = string.format("<color='#00ff00'>%s</color>", dis)
            end
        else
            self.canUseSkill[i] = true
            v.maskImg.fillAmount = 0
            v.timeText.gameObject:SetActive(false)
        end
    end
end

function HalloweenTitleView:HideOrShowTrace()
    local show = (MainUIManager.Instance.mainuitracepanel ~= nil) and (MainUIManager.Instance.mainuitracepanel.isShow == true)
    self.skillContainer.gameObject:SetActive(not show)

    if show then
        self.damakuBtn.transform.anchoredPosition = Vector2(212,-411)
    else
        self.damakuBtn.transform.anchoredPosition = Vector2(444,-411)
    end
end

function HalloweenTitleView:OnDanmaku()
    self.model.danmakuMoment = self.model.danmakuMoment or 0
    if BaseUtils.BASE_TIME - self.model.danmakuMoment > 20 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pumpkin_damaku_window)
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("弹幕cd还有<color='#ffff00'>%s</color>秒"), tostring(20 - (BaseUtils.BASE_TIME - self.model.danmakuMoment))))
    end
end
