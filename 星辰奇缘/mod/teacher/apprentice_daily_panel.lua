ApprenticeshipDailyPanel = ApprenticeshipDailyPanel or BaseClass(BasePanel)

function ApprenticeshipDailyPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.mgr = TeacherManager.Instance

    self.resList = {
        {file = AssetConfig.teacher_daily_panel, type = AssetType.Main}
        , {file = AssetConfig.teacher_textures, type = AssetType.Dep}
        ,{file = AssetConfig.bible_textures, type = AssetType.Dep}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
        ,{file = AssetConfig.teamquest, type = AssetType.Dep}
    }

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.onUpdateListener = function() self:ReloadItems() end

    self.itemList = {}
    self.sliderList = {}
    self.sliderTextList = {}
    self.gotoBtnList = {}
    self.gotoTextList = {}
    self.hasGetImageList = {}
    self.unreachObjList = {}
    self.descTextList = {}
    self.iconImageList = {}

    self.giftObjList = {}
    self.hasGetObjList = {}

    self.giftBtnList = {}
    self.hasGetRectList = {}

    self.hasFinish = false
    self.desc = TI18N("徒弟完成日常教学所有内容后\n师傅进行<color='#ffff00'>验收功课</color>后双方才会获得奖励")

    self.OnOpenEvent:AddListener(self.openListener)
    self.OnHideEvent:AddListener(self.hideListener)
end

function ApprenticeshipDailyPanel:__delete()
    self.OnHideEvent:Fire()
    if self.acceptEffect ~= nil then
        self.acceptEffect:DeleteMe()
        self.acceptEffect = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ApprenticeshipDailyPanel:InitPanel()
    if self.parent == nil then
        self:AssetClearAll()
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.teacher_daily_panel))
    self.gameObject.name = "DailyPanel"
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform

    t:Find("Bottom/Reward"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, "WelfareIcon3")

    self.rewardBtn = t:Find("Bottom/Reward"):GetComponent(Button)
    self.container = t:Find("MaskLayer/ScrollLayer/Container")
    self.cloner = t:Find("MaskLayer/ScrollLayer/Cloner").gameObject
    self.cloner:SetActive(false)

    self.cloner_2 = t:Find("MaskLayer/ScrollLayer/Cloner_2").gameObject
    self.cloner_2:SetActive(false)

    self.descText = t:Find("Bottom/Text"):GetComponent(Text)
    self.acceptBtn = t:Find("Bottom/Accept"):GetComponent(Button)
    self.acceptImage = t:Find("Bottom/Accept"):GetComponent(Image)
    self.acceptText = t:Find("Bottom/Accept/Text"):GetComponent(Text)
    self.rewardImage = t:Find("Bottom/Reward"):GetComponent(Image)
    self.rewardChildImage = t:Find("Bottom/Reward/Image"):GetComponent(Image)
    self.bottomText = t:Find("Bottom/Text"):GetComponent(Text)
    self.nothingObj = t:Find("MaskLayer/ScrollLayer/Nothing").gameObject

    self.layout = LuaBoxLayout.New(self.container, {cspacing = 5, axis = BoxLayoutAxis.Y, border = 5})

    self.acceptBtn.gameObject:SetActive(false)
    self.rewardBtn.gameObject:SetActive(false)
    self.rewardBtn.onClick:AddListener(function()
        local dailyData = self.model.dailyData[BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)]
        if dailyData == nil or dailyData.daily_reward == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("师傅已经验收了您的功课，可在邮件中领取奖励"))
            return      -- 已领取就不能弹框
        end

        if self.finish == true then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = TI18N("您已完成了今日的所有功课内容，是否邀请师傅进行验收？")
            confirmData.sureLabel = TI18N("邀请验收")
            confirmData.cancelLabel = TI18N("取 消")
            confirmData.sureCallback = function() TeacherManager.Instance:send15809(2,0) end
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请先完成上方师傅布置的所有任务哦！"))
        end
    end)

    self.acceptBtn.onClick:AddListener(function()
        if self.data ~= nil then
            if self.data.daily_reward == 0 then
                if self.finish == true then
                    self.model:OpenAccept(self.model.stuData)
                elseif self.nothingObj.activeSelf then
                    NoticeManager.Instance:FloatTipsByString(TI18N("你的徒弟没有领取今日日常功课"))
                else
                    -- NoticeManager.Instance:FloatTipsByString(TI18N("徒弟完成今天的所有<color='#ffff00'>日常功课</color>后才能验收，验收后可获得师道值奖励"))
                    local dat = BaseUtils.copytab(self.model.stuData)
                    dat.id = dat.rid
                    TeacherManager.Instance:Press(dat)
                end
                -- TeacherManager.Instance:send15817(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("你已领取了今天的教学日常奖励，明天继续努力~"))
            end
        end
    end)
    self.bottomText.text = self.desc
end

function ApprenticeshipDailyPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ApprenticeshipDailyPanel:OnOpen()
    local model = self.model
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.model.stuData = self.openArgs[1]
    end
    self:ReloadItems()

    self:RemoveListeners()
    self.mgr.onUpdateDaily:AddListener(self.onUpdateListener)
    self.mgr:send15824()
    self.mgr:send15805(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)
end

function ApprenticeshipDailyPanel:OnHide()
    self:RemoveListeners()
end

function ApprenticeshipDailyPanel:RemoveListeners()
    self.mgr.onUpdateDaily:RemoveListener(self.onUpdateListener)
end

function ApprenticeshipDailyPanel:ReloadItems()
    local model = self.model
    local dataList = {}
    self.finish = true
    self.data = model.dailyData[BaseUtils.Key(self.model.stuData.rid, self.model.stuData.platform, self.model.stuData.zone_id)]
    --BaseUtils.dump(self.data,"&&&&&&&&&&&&&&&&&&&&&&&&&&")
    if self.data == nil then
        return
    end

    -- dataList[1] = {
    --     name = TI18N("剧情任务"),
    --     value = -1,
    --     target_val = 0,
    --     finish = 0,
    --     id = DataTeacher.data_get_daily_length + 1,
    --     progress = {},
    -- }
    for i,v in ipairs(self.data.list) do
        table.insert(dataList, v)
    end

    table.sort(dataList, function (a,b)
        if a.finish ~= b.finish then return a.finish < b.finish
        else return a.id > b.id
        end
    end)
    --BaseUtils.dump(dataList,"&&&&&&&&&&&&&&&&&&&&&&&&&&")
    for i,v in ipairs(dataList) do
        if v.id == 11 then
            local specialData = v
            table.remove(dataList, i)
            table.insert(dataList, 1, specialData)
        end
    end


    for i,v in ipairs(dataList) do
        if self.itemList[i] == nil then
            local obj = nil
            if v.id == 11 then
                obj = GameObject.Instantiate(self.cloner_2)
            else
                obj = GameObject.Instantiate(self.cloner)
            end
            --local obj = GameObject.Instantiate(self.cloner)
            self.layout:AddCell(obj)
            self:SetItem(obj, v, i)
            self.itemList[i] = obj
            obj.name = tostring(i)
        end
        self:UpdateItem(self.itemList[i], v, i)
        self.itemList[i]:SetActive(true)
        -- if i ~= 1 then
            self.finish = self.finish and (v.finish == 1)
        -- end
    end

    for i=#dataList + 1, #self.itemList do
        self.itemList[i]:SetActive(false)
    end

    if #dataList ~= 0 then
        local rect = self.layout.cellList[#dataList]:GetComponent(RectTransform)
        self.layout.panelRect.sizeDelta = Vector2(0, self.layout.spacing + rect.sizeDelta.y - rect.anchoredPosition.y + self.layout.border)
    end

    self.nothingObj:SetActive(#dataList == 0)

    self.acceptBtn.gameObject:SetActive(model.myTeacherInfo.status == 3)
    self.rewardBtn.gameObject:SetActive(model.myTeacherInfo.status == 1)
    if self.data.daily_reward == 1 then
        self.acceptImage.enabled = false
        self.acceptBtn.enabled = false
        self.acceptText.text = TI18N("<color=#00FF00>[已验收]</color>")
        self.rewardChildImage.sprite = self.assetWrapper:GetSprite(AssetConfig.teacher_textures, "I18NComplete")
    else
        self.acceptImage.enabled = true
        self.acceptBtn.enabled = true
        if self.finish == true then
            self.acceptText.text = TI18N("验收功课")
        else
            self.acceptText.text = TI18N("督促功课")
        end
    end

    self.finish = self.finish and (#dataList > 0)

    -- self.rewardBtn.enabled = finish
    BaseUtils.SetGrey(self.rewardImage, not self.finish)
    BaseUtils.SetGrey(self.rewardChildImage, not self.finish)

    if self.acceptEffect ~= nil then  self.acceptEffect:DeleteMe() self.acceptEffect = nil end
    if self.data.daily_reward ~= 1 and self.finish then
        self.acceptEffect = BibleRewardPanel.ShowEffect(20118, self.acceptBtn.transform, Vector3(1.1, 0.85, 0), Vector3(-111.8, 22.14, 0))
    end
end

function ApprenticeshipDailyPanel:SetItem(obj, data, index)
    if data.id == 11 then
        local t = obj.transform
        t:Find("Arrow/Text"):GetComponent(Text).text = TI18N("每日目标")
        self.descTextList[index] = t:Find("Desc"):GetComponent(Text)
        self.sliderList[index] = t:Find("Slider"):GetComponent(Slider)
        self.sliderTextList[index] = t:Find("Slider/ProgressTxt"):GetComponent(Text)
        self.giftObjList[index] = t:Find("Gift").gameObject
        self.unreachObjList[index] = t:Find("Unreach").gameObject
        self.hasGetObjList[index] = t:Find("HasGet").gameObject
        self.giftBtnList[index] = t:Find("Gift"):GetComponent(Button)
        self.hasGetRectList[index] = self.hasGetObjList[index]:GetComponent(RectTransform)
        self.hasGetImageList[index] = self.hasGetObjList[index]:GetComponent(Image)
    else
        local t = obj.transform
        self.descTextList[index] = t:Find("Desc"):GetComponent(Text)
        self.iconImageList[index] = t:Find("Icon/Image"):GetComponent(Image)
        self.sliderList[index] = t:Find("Slider"):GetComponent(Slider)
        self.gotoBtnList[index] = t:Find("GoTo"):GetComponent(Button)
        self.gotoTextList[index] = t:Find("GoTo/Text"):GetComponent(Text)
        self.hasGetImageList[index] = t:Find("HasGet"):GetComponent(Image)
        self.sliderTextList[index] = t:Find("Slider/ProgressTxt"):GetComponent(Text)
        self.unreachObjList[index] = t:Find("Unreach").gameObject
        t:Find("Unreach"):GetComponent(Text).text = TI18N("[进行中]")
    end

end

function ApprenticeshipDailyPanel:UpdateItem(obj, data, index)
    if data.id == 11 then
        local progress = data.progress[1]
        local roleData = RoleManager.Instance.RoleData
        self.sliderList[index].value = progress.value / progress.target_val
        self.descTextList[index].text = data.name
        local target_val = progress.target_val
        if target_val <= 0 then
            target_val = "--"
        else
            target_val = tostring(target_val)
        end
        self.sliderTextList[index].text = tostring(progress.value).."/"..target_val
        self.hasGetRectList[index].anchoredPosition = Vector2(180, 0)

        self.hasGetObjList[index]:SetActive(data.finish == 1)
        self.giftObjList[index]:SetActive(data.finish == 0)
        self.unreachObjList[index]:SetActive(false)

        self.giftBtnList[index].onClick:RemoveAllListeners()
        self.giftBtnList[index].onClick:AddListener(function()
            self:OnClickReward(data)
        end)
    else
        if data.id ~= nil and data.id > 0 and data.id <= DataTeacher.data_get_daily_length then
            self.iconImageList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, tostring(DataTeacher.data_get_daily[data.id].icon_id))
        else
            self.iconImageList[index].sprite = self.assetWrapper:GetSprite(AssetConfig.teamquest, "TeamQuestIcon1")
        end

        local dataCpy = BaseUtils.copytab(data)
        local dat = DataTeacher.data_get_daily[data.id]
        local progress = data.progress[1]
        local model = self.model
        if progress == nil then
            progress = {value = -1, target_val = -1}
        end
        self.descTextList[index].text = data.name
        self.sliderList[index].value = progress.value / progress.target_val
        local target_val = progress.target_val
        local value = progress.value
        if target_val <= 0 then
            target_val = "--"
            self.sliderList[index].value = 1
        else
            target_val = tostring(target_val)
        end
        if value < 0 then
            value = "--"
        else
            value = tostring(value)
        end
        self.sliderTextList[index].text = value.."/"..target_val
        -- self.gotoTextList[index].text = self.gotoText[model.myTeacherInfo.status]
        if model.myTeacherInfo.status == 3 then
            self.gotoBtnList[index].gameObject:SetActive(false)
            self.hasGetImageList[index].gameObject:SetActive(data.finish == 1)
            self.unreachObjList[index]:SetActive(data.finish ~= 1)
        else
            self.gotoBtnList[index].gameObject:SetActive(data.finish ~= 1)
            self.hasGetImageList[index].gameObject:SetActive(data.finish == 1)
            self.unreachObjList[index]:SetActive(false)
        end

        self.gotoBtnList[index].onClick:RemoveAllListeners()
        self.gotoBtnList[index].onClick:AddListener(function()
            if dat == nil or self.model:SpecialDaily(dataCpy.id) then
                return
            end

            if dat.panel_id ~= 0 then
                self.model:CloseDailyWindow()
                WindowManager.Instance:OpenWindowById(dat.panel_id)
            elseif dat.npc_id ~= "0" then
                local uid = tostring(dat.npc_id)
                self.model:CloseDailyWindow()
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
            end
        end)
    end

end

function ApprenticeshipDailyPanel:OnClickReward(data)
    --点击礼物预览
    local Specialweekday = nil
    local week_day = tonumber(os.date("%w",BaseUtils.BASE_TIME))
    if week_day == 0 or week_day == 1 or week_day == 3 or week_day == 5 then
        Specialweekday = 1
    else
        Specialweekday = 0
    end
    local roleType = 0   --0 为徒弟  1 为师傅
    local stuLevel = nil       --徒弟等级
    if self.model.myTeacherInfo.status == 3 then
        stuLevel = self.data.lev
        roleType = 1
    else
        stuLevel = RoleManager.Instance.RoleData.lev
        roleType = 0
    end
    local DataTeacherDailyGoals = DataTeacher.data_get_daily_goals
    if DataTeacherDailyGoals ~= nil then
        local itemShow = {}
        local temp = {}
        for i,v in pairs(DataTeacherDailyGoals) do
            if stuLevel >= v.stu_lev_min and stuLevel <= v.stu_lev_max and v.week_day == Specialweekday then
                if roleType == 0 then
                    temp.item_id = v.student_reward[1][1]
                    temp.num = v.student_reward[1][3]
                elseif roleType == 1 then
                    temp.item_id = v.teacher_reward[1][1]
                    temp.num = v.teacher_reward[1][3]
                end
                table.insert(itemShow,temp)
            end
        end
        if self.possibleReward == nil then
            self.possibleReward = SevenLoginTipsPanel.New(self)
        end
        if roleType == 0 then
            self.possibleReward:Show({itemShow,4,{100,100,200,120},"与师父完成日常任务即可获得"})
        elseif roleType == 1 then
            local Times = self.model.teachergiftMax - self.model.teachergiftReceived
            if Times <= 0 then
                self.possibleReward:Show({itemShow,4,{100,150,200,120},string.format("带领徒弟完成日常任务即可获得奖励\n本周剩余获取次数: <color=#ff0000>%d</color> 次",Times)})
            elseif Times > 0 then
                self.possibleReward:Show({itemShow,4,{100,150,200,120},string.format("带领徒弟完成日常任务即可获得奖励\n本周剩余获取次数: <color=#00ff00>%d</color> 次",Times)})
            end

        end
    end
end
