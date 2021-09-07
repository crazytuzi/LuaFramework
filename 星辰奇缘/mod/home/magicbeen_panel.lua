-- ----------------------------------------------------------
-- UI - 创建家园窗口
-- ljh 20160712
-- copy bu GuildInvitewaterPanel
-- ----------------------------------------------------------
MagicBeenPanel = MagicBeenPanel or BaseClass(BaseWindow)

function MagicBeenPanel:__init(model)
    self.model = model
    self.name = "MagicBeenPanel"
    self.windowId = WindowConfig.WinID.magicbeenpanel

    --是否隐藏主ui
    self.isHideMainUI = false
    self.starEffectPath = "prefabs/effect/10128.unity3d"
    self.moonEffectPath = "prefabs/effect/10132.unity3d"
    self.clickEffectPath = "prefabs/effect/20162.unity3d"
    self.getStatEffectPath = "prefabs/effect/20163.unity3d"
    self.getMoonEffectPath = "prefabs/effect/20164.unity3d"
    self.resList = {
        {file = AssetConfig.magicbeenpanel, type = AssetType.Main}
        , {file = AssetConfig.homeTexture, type = AssetType.Dep}
        , {file = self.starEffectPath, type = AssetType.Main}
        , {file = self.moonEffectPath, type = AssetType.Main}
        , {file = self.clickEffectPath, type = AssetType.Main}
        , {file = self.getStatEffectPath, type = AssetType.Main}
        , {file = self.getMoonEffectPath, type = AssetType.Main}
    }
    self.currmotion = nil
    self.gameObject = nil
    self.transform = nil
    self.effectList = {}
    self.mainTransform = nil
    self.lockBtn = false
    self.plantFlowerInfoData = nil
    ------------------------------------------------
    self._bean_data_update = function()
        self:UpdateWindow()
    end

    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)

    self.isOpenRecord = false
    self.waterDesc = {
        [1] = TI18N("给许愿树浇水"),
        [2] = TI18N("一边念叨着“快快长大吧”，一边给许愿树浇了水"),
        [3] = TI18N("给许愿树浇了水后深吸一口：“哇，好香啊~"),
        [4] = TI18N("用全身力气扛起一桶水，哗啦啦的浇在了许愿树之上"),
        [5] = TI18N("在为许愿树拔除了杂草后，又浇了一壶水"),
    }

    self.descRole = {
        TI18N("1.每次培育可使许愿树成长值<color='#00ff00'>+1</color>"),
        TI18N("2.每人<color='#ffff00'>每天</color>对同一株许愿树只能培育<color='#00ff00'>1次</color>"),
        TI18N("3.每人<color='#ffff00'>每天</color>最多培育<color='#00ff00'>20次</color>许愿树"),
        TI18N("4.获得<color='#00ff00'>10点</color>成长值后，许愿树将收集<color='#00ff00'>1颗</color>星星，星星中蕴藏着丰厚<color='#ffff00'>宝藏</color>，第5颗星星开启后还可将<color='#ffff00'>宝藏</color>赠送给好友,共同分享收获的喜悦哦"),
    }

end

function MagicBeenPanel:OnInitCompleted()
    self:UpdateWindow()
end

function MagicBeenPanel:__delete()
    self:StopCountDown()
    EventMgr.Instance:RemoveListener(event_name.home_bean_info_update, self._bean_data_update)
    if self.preview ~= nil then
        self.preview:DeleteMe()
    end
    if self.timer ~= nil then
        LuaTimer.Delete(self.timer)
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
    end

    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function MagicBeenPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.magicbeenpanel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainContainer = self.transform:Find("Main")
    self.MainBg = self.transform:Find("Main/MainBg")
    self.waterrecord = self.mainContainer:Find("WaterRecord")
    self.grid = self.waterrecord:Find("Container/Grid"):GetComponent(RectTransform)
    self.waterContainerText = self.waterrecord:Find("Container/Grid/WaterContainText"):GetComponent(Text)
    self.waterrecord.gameObject:SetActive(false)
    self.waterbg = self.waterrecord:Find("Bg"):GetComponent(Button)
    self.waterbg.onClick:AddListener(function()
        self.waterrecord.gameObject:SetActive(false)
        self.MainBg.gameObject:SetActive(true)
    end)
    self.closeBtn = self.transform:Find("Main/MainBg/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.PreviewCon = self.transform:Find("Main/MainBg/ImageFlower")
    self.FlowerList = {}
    for i=1, 5 do
        self.FlowerList[i] = self.MainBg:Find(string.format("FlowreCon/%s", i)):GetComponent(Image)
    end
    self.slider = self.transform:Find("Main/MainBg/Slider"):GetComponent(Slider)
    self.ruleInfobtn = self.transform:Find("Main/MainBg/InfoBtn"):GetComponent(Button)
    self.ruleInfobtn.onClick:AddListener(function() self:OnClickRuleBtn() end)
    self.waterTimesText = self.transform:Find("Main/MainBg/Slider/WaterTimesText"):GetComponent(Text)
    self.sureBtn = self.transform:Find("Main/MainBg/SureButton"):GetComponent(Button)
    self.sureBtntxt = self.transform:Find("Main/MainBg/SureButton/Text"):GetComponent(Text)
    self.cancelBtn = self.transform:Find("Main/MainBg/CancelButton"):GetComponent(Button)
    self.cancelBtntxt = self.transform:Find("Main/MainBg/CancelButton/Text"):GetComponent(Text)
    self.sureBtntxt.text = TI18N("许 愿")
    self.cancelBtntxt.text = TI18N("许愿记录")

    self.I18NLevDescText = self.transform:Find("Main/MainBg/I18NLevDescText").gameObject
    self.CountDownText = self.transform:Find("Main/MainBg/CountDown/Text"):GetComponent(Text)
    self.CDItem = self.transform:Find("Main/MainBg/CountDown").gameObject

    self.RecordItemList = {}
    self.WaterRecord = self.transform:Find("Main/WaterRecord").gameObject
    self.WaterRecordbg = self.transform:Find("Main/WaterRecord/Bg"):GetComponent(Button)
    self.WaterRecordbg.onClick:AddListener(function() self.WaterRecord:SetActive(false) end)
    self.WaterTimesDescText = self.transform:Find("Main/WaterRecord/WaterTimesDescText"):GetComponent(Text)
    self.WaterTimesDescText.text = TI18N("许愿记录：")
    self.WaterRecordCloseBtn = self.transform:Find("Main/WaterRecord/CloseButton"):GetComponent(Button)
    self.WaterRecordCloseBtn.onClick:AddListener(function()
        self.WaterRecord:SetActive(false)
    end)
    self.WaterContainText = self.WaterRecord.transform:Find("Container/Grid/WaterContainText").gameObject
    self.WaterContainText:SetActive(false)
    self.RecContainer = self.WaterRecord.transform:Find("Container/Grid")

    self.cancelBtn.onClick:AddListener(function()
        self.WaterRecord:SetActive(true)
    end)

    self.sureBtn.onClick:AddListener(function()
        self:OnSure()
    end)
    self.clickGo = GameObject.Instantiate(self:GetPrefab(self.clickEffectPath))
    self.clickGo.transform:SetParent(self.sureBtn.transform)
    self.clickGo.transform.localScale = Vector3.one
    self.clickGo.transform.localPosition = Vector3(-60, 23, -1000)
    Utils.ChangeLayersRecursively(self.clickGo.transform, "UI")
    self.clickGo:SetActive(false)

    self.clickStarGo = GameObject.Instantiate(self:GetPrefab(self.getStatEffectPath))
    self.clickStarGo.transform:SetParent(self.sureBtn.transform)
    self.clickStarGo.transform.localScale = Vector3.one
    self.clickStarGo.transform.localPosition = Vector3(-60, 23, -1000)
    Utils.ChangeLayersRecursively(self.clickStarGo.transform, "UI")
    self.clickStarGo:SetActive(false)

    self.clickMoonGo = GameObject.Instantiate(self:GetPrefab(self.getMoonEffectPath))
    self.clickMoonGo.transform:SetParent(self.sureBtn.transform)
    self.clickMoonGo.transform.localScale = Vector3.one
    self.clickMoonGo.transform.localPosition = Vector3(-60, 23, -1000)
    Utils.ChangeLayersRecursively(self.clickMoonGo.transform, "UI")
    self.clickMoonGo:SetActive(false)

    self.StarGo = GameObject.Instantiate(self:GetPrefab(self.starEffectPath))
    self.StarGo.transform:SetParent(self.sureBtn.transform)
    self.StarGo.transform.localScale = Vector3.one
    self.StarGo.transform.localPosition = Vector3(0, 0, -1000)
    Utils.ChangeLayersRecursively(self.StarGo.transform, "UI")
    self.StarGo:SetActive(false)

    self.MoonGo = GameObject.Instantiate(self:GetPrefab(self.moonEffectPath))
    self.MoonGo.transform:SetParent(self.sureBtn.transform)
    self.MoonGo.transform.localScale = Vector3.one
    self.MoonGo.transform.localPosition = Vector3(0, 0, -1000)
    Utils.ChangeLayersRecursively(self.MoonGo.transform, "UI")
    self.MoonGo:SetActive(false)
    self:StopCountDown()
    EventMgr.Instance:AddListener(event_name.home_bean_info_update, self._bean_data_update)
end

function MagicBeenPanel:OnClickClose()
    -- WindowManager.Instance:CloseWindow(self)
    self.isOpenRecord = false
    self:Hide()
end

--点击显示浇水规则
function MagicBeenPanel:OnClickRuleBtn()
    TipsManager.Instance:ShowText({gameObject = self.ruleInfobtn.gameObject, itemData = self.descRole})
end


function MagicBeenPanel:UpdateWindow()
    -- Log.Error(#self.plantFlowerInfoData.irrigations)
    self.plantFlowerInfoData = self.model.bean_data
    local setting = {
        name = "MagicBeenPanel"
        ,orthographicSize = 0.7
        ,width = 335
        ,height = 341
        ,offsetY = -0.60
        ,noDrag = true
    }
    local modelData = {type = PreViewType.Npc, skinId = 70138, modelId = 70138, animationId = 7013801, scale = 1}
    if self.preview == nil then
        self.preview = PreviewComposite.New(function(composite) self:PreViewLoaded(composite) end, setting, modelData)
    end
    if self.plantFlowerInfoData ~= nil then
        -- BaseUtils.dump(self.plantFlowerInfoData)
        if self.plantFlowerInfoData.wake_time > BaseUtils.BASE_TIME and self.plantFlowerInfoData.growth == 0 and self.plantFlowerInfoData.flower_num == 0 then
            self:SetFlowerNum(5)
        else
            self:SetFlowerNum(self.plantFlowerInfoData.flower_num)
        end
        self.slider.value = self.plantFlowerInfoData.growth/10
        self.waterTimesText.text = string.format("%s/10", tostring(self.plantFlowerInfoData.growth))
        self:RefreshRec()
        self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
        -- BaseUtils.SetGrey(self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image), false)
        self.sureBtntxt.color = ColorHelper.DefaultButton3
        if self.plantFlowerInfoData.wake_time > BaseUtils.BASE_TIME and self.plantFlowerInfoData.growth == 0 and self.plantFlowerInfoData.flower_num == 0 then
                self:StartCountDown()
            if HomeManager.Instance.model:CanEditHome() then
                if self.plantFlowerInfoData.inviters ~= nil then
                    self.sureBtntxt.text = string.format("%s%s/10", TI18N("赠送"),10-(#self.plantFlowerInfoData.inviters))
                else
                    self.sureBtntxt.text = TI18N("赠 送")
                end
                self.lockBtn = false
            else
                -- BaseUtils.SetGrey(self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image), true)
                self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                self.sureBtntxt.color = ColorHelper.DefaultButton4
                self.lockBtn = true
                self.sureBtntxt.text = TI18N("领取奖励")
            end
        else
            if self.plantFlowerInfoData.wake_time > BaseUtils.BASE_TIME then
                self.lockBtn = true
                self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                -- BaseUtils.SetGrey(self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image), true)
                self.sureBtntxt.color = ColorHelper.DefaultButton4
                self:StartCountDown()
            else
                self:StopCountDown()
            end
            if self.plantFlowerInfoData.growth < 10 then
                for i,v in ipairs(self.plantFlowerInfoData.fosters) do
                    if v.fsttid == RoleManager.Instance.RoleData.id and v.fstplatform == RoleManager.Instance.RoleData.platform and v.fstzone_id  == RoleManager.Instance.RoleData.zone_id then
                        self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                        -- BaseUtils.SetGrey(self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image), true)
                        self.sureBtntxt.color = ColorHelper.DefaultButton4
                        self.lockBtn = true
                    end
                end
            else

                if HomeManager.Instance.model:CanEditHome() then
                    self.sureBtntxt.text = TI18N("领取奖励")
                else
                    -- BaseUtils.SetGrey(self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image), true)
                    self.transform:Find("Main/MainBg/SureButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
                    self.sureBtntxt.color = ColorHelper.DefaultButton4
                    self.lockBtn = true
                    self.sureBtntxt.text = TI18N("许 愿")
                end
            end
        end
    else
        Log.Debug("星星信息为空")
    end
end

function MagicBeenPanel:PreViewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        rawImage.transform:SetParent(self.PreviewCon)
        rawImage.transform.localPosition = Vector3(-17, 109, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform.rotation = Quaternion.identity
        -- composite.tpose.transform:Rotate(Vector3(0, 0, 0))
    end
    if self.preview ~= nil and self.currmotion ~= nil then
        self.preview:PlayAnimation(self.currmotion)
    end

end

function MagicBeenPanel:SetFlowerNum(num)
    for i=1, 5 do
        if self.effectList[i] == nil and i <= num then
            local go = nil
            if i < 5 then
                go = GameObject.Instantiate(self.StarGo)
            else
                go = GameObject.Instantiate(self.MoonGo)
            end
            local path = self:GetChildPath(i)
            if self.preview ~= nil and self.preview.tpose ~= nil then
                local parent = BaseUtils.GetChildPath(self.preview.tpose.transform, path)
                go.transform:SetParent(self.preview.tpose.transform:Find(parent))
                Utils.ChangeLayersRecursively(go.transform, "ModelPreview")
                go.transform.localScale = Vector3.one
                go.transform.localPosition = Vector3.zero
                go.transform.localRotation = Quaternion.identity
                go:SetActive(true)
                self.effectList[i] = go
            end
        elseif i <= num and self.effectList[i] ~= nil then
            self.effectList[i]:SetActive(true)
            elseif self.effectList[i] ~= nil then
            self.effectList[i]:SetActive(false)
        end
    end
    for i,v in ipairs(self.FlowerList) do
        BaseUtils.SetGrey(v, i>num)
    end
    -- if self.preview ~= nil then
    --     LuaTimer.Add(20, function()
    --         self.preview:PlayAnimation("Stand1")
    --     end)
    -- end
end

function MagicBeenPanel:RefreshRec()
    for k,v in pairs(self.RecordItemList) do
        if not BaseUtils.isnull(v.contentTrans) then
            GameObject.DestroyImmediate(v.contentTrans.gameObject)
        end
    end
    self.RecordItemList = {}
    if self.plantFlowerInfoData ~= nil then
        local H = 0
        local num = 0
        for i,v in ipairs(self.plantFlowerInfoData.event_record) do
            local index = v.role_name..tostring(v.time)
            if self.RecordItemList[index] == nil then
                local item = GameObject.Instantiate(self.WaterContainText)
                item.name = index
                item.transform:SetParent(self.RecContainer)
                item.transform.localScale = Vector3.one
                item:SetActive(true)
                self.RecordItemList[index] = MsgItemExt.New(item.transform:GetComponent(Text), 260, 18, 25)
                local its = self.RecordItemList[index].contentTrans

                local str = self.waterDesc[Random.Range(1,5)]
                local hours = os.date("%H", v.time)
                local min = os.date("%M", v.time)
                local roleData = RoleManager.Instance.RoleData
                if (roleData.id == v.wid and roleData.platform == v.wplatform and roleData.zone_id == v.wzone_id) or v.wid == 0 then
                    self.RecordItemList[index]:SetData(string.format("%s:%s　<color='#ffff00'>%s</color>%s", hours, min, v.role_name, str))
                else
                    self.RecordItemList[index]:SetData(string.format("%s:%s　{home_1, %s, %s, %s, %s}%s", hours, min, v.role_name, v.wid, v.wplatform, v.wzone_id, str))
                end
                its.anchoredPosition = Vector2(0, -H)
                H = H+10+self.RecordItemList[index].selfHeight
                num = num + 1
                if num >= 10 then
                    break
                end
            end
        end
        self.RecContainer.sizeDelta = Vector2(260, H)
    end
end

function MagicBeenPanel:GetReward()
    HomeManager.Instance:Send11227()
end

function MagicBeenPanel:InviteFriend(List)
    local temp = {}
    for k,v in pairs(List) do
        table.insert(temp, {rid = v.id, platform = v.platform, zone_id = v.zone_id})
    end
    HomeManager.Instance:Send11228(temp)
end

function MagicBeenPanel:FriendGetReward()
    -- HomeManager.Instance:Send11229()
end

function MagicBeenPanel:GetChildPath(num)
    return string.format("bp_star_0%s", num)
end

function MagicBeenPanel:StartCountDown()
    print("来世倒计时")
    self.CDItem:SetActive(true)
    self.I18NLevDescText:SetActive(false)
    self.slider.gameObject:SetActive(false)
    if self.cdtimer ~= nil then
        LuaTimer.Delete(self.cdtimer)
    end
    self.cdtimer = LuaTimer.Add(0, 500,function()
        self:SetCDText()
    end)
end

function MagicBeenPanel:SetCDText()
    local day,hour,min,second = BaseUtils.time_gap_to_timer(self.plantFlowerInfoData.wake_time - BaseUtils.BASE_TIME)
    -- local _, _, day,hour,min,second = BaseUtils.TimeDetail(self.plantFlowerInfoData.wake_time - BaseUtils.BASE_TIME)
    if day > 0 then
        hour = 24*day + hour
    end
    if hour < 10 then
        hour = "0"..hour
    end
    if min < 10 then
        min = "0"..min
    end
    if second < 10 then
        second = "0"..second
    end
    self.CountDownText.text = string.format("%s:%s:%s", hour, min, second)
end


function MagicBeenPanel:StopCountDown()
    self.I18NLevDescText:SetActive(true)
    self.slider.gameObject:SetActive(true)
    self.CDItem:SetActive(false)
    if self.cdtimer ~= nil then
        LuaTimer.Delete(self.cdtimer)
    end
end

function MagicBeenPanel:OnSure()
    -- if self.lockBtn then
    --     return
    -- end
    -- BaseUtils.dump({fid = self.model.fid, platform = self.model.platform, zone_id = self.model.zone_id})
    if self.plantFlowerInfoData.wake_time > BaseUtils.BASE_TIME and self.plantFlowerInfoData.growth == 0 and self.plantFlowerInfoData.flower_num == 0 then
        if HomeManager.Instance.model:CanEditHome() then
            -- if self.friendPanel == nil then
            --     local setting = {
            --         list_type = 2,
            --         ismulti = true,
            --         callback = function(list) self:InviteFriend(list) end
            --     }
            --     self.friendPanel = FriendSelectPanel.New(self.gameObject, setting)
            -- end
            -- self.friendPanel:Show()
            self.model:OpenBeanInviteWindow()
        else
            self:FriendGetReward()
        end
    else
        if self.plantFlowerInfoData.growth < 10 then
            if self.clickStarGo ~= nil and self.lockBtn == false then
                self.clickGo:SetActive(false)
                self.clickGo:SetActive(true)
            end
            HomeManager.Instance:Send11226(self.model.fid, self.model.platform, self.model.zone_id)
        else
            if self.plantFlowerInfoData.flower_num < 5 then
                if self.clickStarGo ~= nil and self.lockBtn == false  then
                    self.clickStarGo:SetActive(false)
                    self.clickStarGo:SetActive(true)
                end
            else
                if self.clickMoonGo ~= nil and self.lockBtn == false  then
                    self.clickMoonGo:SetActive(false)
                    self.clickMoonGo:SetActive(true)
                end
            end
            if self.model:CanEditHome() then
                self:GetReward()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("许愿值当前已满，请稍后再来！"))
            end
        end
    end
end