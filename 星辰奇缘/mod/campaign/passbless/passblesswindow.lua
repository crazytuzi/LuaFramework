-- @author hze
-- @date 2018/04/27
-- 传递花语活动

PassBlessWindow = PassBlessWindow or BaseClass(BaseWindow)

function PassBlessWindow:__init(model)
    self.model = model
    self.name = "PassBlessWindow"

    self.windowId = WindowConfig.WinID.passblesswindow

    self.resList = {
        {file = AssetConfig.passblesswindow, type = AssetType.Main},
        {file = AssetConfig.passblesstitlebg, type = AssetType.Main},
        {file = AssetConfig.passblesstxti18n, type = AssetType.Main},
        {file = AssetConfig.anniversary_bg1, type = AssetType.Main},
        {file = AssetConfig.passbless_res, type = AssetType.Dep},
        {file = AssetConfig.anniversary_textures, type = AssetType.Dep},
        {file = AssetConfig.nationalsecond_accept_texture, type = AssetType.Dep}
    }

    self.itemList = {}  --花Slot列表
    self.itemIdList = {70086, 70087, 70088, 70089, 70090, 70091, 70092} --花id

    self.updateFlowerListListener = function() self:Reload() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function PassBlessWindow:__delete()
    self.OnHideEvent:Fire()

    if self.rewardeffect ~= nil then
        self.rewardeffect:DeleteMe()
        self.rewardeffect = nil
    end

    if self.itemList ~= nil then
        for i,v in ipairs(self.itemList) do
            if v.icon ~= nil then BaseUtils.ReleaseImage(v.icon) end
            if v.mark ~= nil then BaseUtils.ReleaseImage(v.mark) end
            if v.effect ~= nil then v.effect:DeleteMe() end
        end
        self.itemList = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PassBlessWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.passblesswindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")
    main:Find("Close"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    self.noticeBtn = main:Find("Notice/Image"):GetComponent(Button)
    self.noticeBtn.onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = self.helpDesc})
        end)


    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.anniversary_bg1)))
    UIUtils.AddBigbg(main:Find("TopBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.passblesstitlebg)))
    UIUtils.AddBigbg(main:Find("FancyTxt"), GameObject.Instantiate(self:GetPrefab(AssetConfig.passblesstxti18n)))

    self.descTxt = main:Find("DescTxt"):GetComponent(Text)
    self.timeTxt = main:Find("TimeTxt"):GetComponent(Text)

    self.peopleTxt = main:Find("PeopleTxt/Text"):GetComponent(Text)
    self.rankTxt = main:Find("RankTxt"):GetComponent(Text)


    self.itemArea = main:Find("ItemArea")
    self.rewardItem = self.itemArea:Find("RewardItem")
    self.rewardItem:GetComponent(Button).onClick:AddListener(function() self:ShowGiftPriview() end)
    self.rewardTerm = self.itemArea:Find("RewardTerm").gameObject
    self.rewardBtn = self.itemArea:Find("RewardButton"):GetComponent(Button)
    self.rewardBtnImg = self.rewardBtn.transform:GetComponent(Image)
    self.rewardBtnTxt = self.rewardBtn.transform:Find("Text"):GetComponent(Text)

    self.rewardBtn.onClick:AddListener(function() self:OnClickButton(2,0) end)

    self.flowerContainer = main:Find("FlowerContainer")
    self.flowerSlot = main:Find("FlowerSlot").gameObject
    self.flowerSlot.gameObject:SetActive(false)

    local layout = LuaBoxLayout.New(self.flowerContainer, {axis = BoxLayoutAxis.X, cspacing = 0, border = 5})
    for i = 1,7 do
        local tab = {}
        tab.gameObject = GameObject.Instantiate(self.flowerSlot)
        tab.gameObject.name = tostring(i)
        tab.transform = tab.gameObject.transform
        tab.meanTxt = tab.transform:Find("FlowerMean/Text"):GetComponent(Text)
        tab.nameTxt = tab.transform:Find("FlowerName/Text"):GetComponent(Text)
        tab.icon = tab.transform:Find("Flower"):GetComponent(Image)
        tab.iconBtn = tab.icon.transform:GetComponent(Button)
        tab.mark = tab.transform:Find("Mark"):GetComponent(Image)
        tab.bgmask = tab.transform:Find("BgMask").gameObject
        tab.flowerCountTxt = tab.transform:Find("FlowerCounts/Count"):GetComponent(Text)
        tab.btn = tab.transform:Find("Button"):GetComponent(Button)
        tab.btn.onClick:AddListener(function() self:OnClickButton(1,i) end)
        tab.btnImg = tab.btn.transform:GetComponent(Image)
        tab.btnTxt = tab.btn.transform:Find("Text"):GetComponent(Text)
        tab.effect = nil
        local itemData = ItemData.New()
        itemData:SetBase(DataItem.data_get[self.itemIdList[i]])
        tab.iconBtn.onClick:AddListener(function() TipsManager.Instance:ShowItem({gameObject = tab.iconBtn.gameObject, itemData = itemData, {inbag = false, nobutton = true}}) end)
        layout:AddCell(tab.gameObject)
        self.itemList[i] = tab
    end
    layout:DeleteMe()
end

function PassBlessWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function PassBlessWindow:OnOpen()
    self:RemoveListeners()
    SignDrawManager.Instance.OnUpdateFlowerListEvent:AddListener(self.updateFlowerListListener)

    if next(self.openArgs) ~= nil then
        self.campId = self.openArgs.campId or 1062
    end
    if self.campId == nil then print("活动ID为空") return end

    local campData = DataCampaign.data_list[self.campId]

    self.helpDesc = {campData.cond_desc}

    local startTime = campData.cli_start_time[1]
    local endTime = campData.cli_end_time[1]


    self.timeTxt.text = string.format("%s%s%s%s%s-%s%s%s%s",TI18N("活动时间:"),startTime[2],TI18N("月"),startTime[3],TI18N("日"),endTime[2],TI18N("月"),endTime[3],TI18N("日"))
    self.descTxt.text = campData.content

    SignDrawManager.Instance:Send20451()

end

function PassBlessWindow:OnHide()
    self:RemoveListeners()

    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end

    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
end

function PassBlessWindow:RemoveListeners()
    SignDrawManager.Instance.OnUpdateFlowerListEvent:RemoveListener(self.updateFlowerListListener)
end

function PassBlessWindow:Reload()
    local flowerData = self.model.flower_list

    self.peopleTxt.text = flowerData.finish_num

    local collect = 0
    for i,v in ipairs(self.itemList) do
        local flower_data = flowerData.flower_info[i]
        local cfgData = DataCampPassFlowerLanguage.data_get_flower_info[flower_data.flower_id]

        v.nameTxt.text = cfgData.name
        v.meanTxt.text = cfgData.meaning
        v.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.nationalsecond_accept_texture, cfgData.icon)

        v.flowerCountTxt.text = string.format("%d%s",flower_data.pass_times,TI18N("次"))

        if v.effect ~= nil then
            v.effect:DeleteMe()
            v.effect = nil
        end

        --未获得
        if flower_data.pass_flag == 0 then
            v["btnImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            v["btnTxt"].text = string.format(ColorHelper.DefaultButton4Str, TI18N("传递"))
            v["mark"].sprite = self.assetWrapper:GetSprite(AssetConfig.passbless_res, "unearnedi18n")
            v["bgmask"]:SetActive(true)
        --已获得
        elseif flower_data.pass_flag == 1 then
            v["btnImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            v["btnTxt"].text = string.format(ColorHelper.DefaultButton3Str, TI18N("传递"))
            v["mark"].sprite = self.assetWrapper:GetSprite(AssetConfig.passbless_res, "acquiredi18n")
            v["bgmask"]:SetActive(false)
            --流光转圈特效
            if v.effect == nil then
                v.effect = BaseUtils.ShowEffect(20053, v.btnImg.transform, Vector3(1.3, 0.7, 1), Vector3(-39, -15, -400))
            end
        --已传递
        elseif flower_data.pass_flag == 2 then
            v["btnImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            v["btnTxt"].text = string.format(ColorHelper.DefaultButton3Str, TI18N("领奖"))
            v["mark"].sprite = self.assetWrapper:GetSprite(AssetConfig.passbless_res, "passedi18n")
            v["bgmask"]:SetActive(false)
            --流光转圈特效
            if v.effect == nil then
                v.effect = BaseUtils.ShowEffect(20053, v.btnImg.transform, Vector3(1.3, 0.7, 1), Vector3(-39, -15, -400))
            end
            collect = collect + 1            --统计已传递次数
        --已领取
        elseif flower_data.pass_flag == 3 then
            v["btnImg"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            v["btnTxt"].text = string.format(ColorHelper.DefaultButton4Str, TI18N("已领奖"))
            v["mark"].sprite = self.assetWrapper:GetSprite(AssetConfig.passbless_res, "passedi18n")
            v["bgmask"]:SetActive(false)
            collect = collect + 1
        end

    end

    -- print(collect)
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    if collect ~= 7 then
        self.rewardTerm:SetActive(true)
        self.rewardBtn.transform.gameObject:SetActive(false)
        self.rankTxt.text = string.format("<color='#FFF9A0'>%s</color>",TI18N("我的名次:暂未集齐"))
    else
        self.rewardTerm:SetActive(false)
        self.rewardBtn.transform.gameObject:SetActive(true)
        self.rankTxt.text = string.format("<color='#FFF9A0'>%s</color><color='#ffffff'>%s</color>",TI18N("我的名次:"),flowerData.rank)
        --大礼包未领取
        if flowerData.gift_flag == 0 then
            --抖动效果
            self.timerId = LuaTimer.Add(1000, 3000, function()
                if self.rewardItem ~= nil then
                   self.rewardItem.localScale = Vector3(1.2,1.2,1)
                   if self.tweenId == nil then
                        self.tweenId = Tween.Instance:Scale(self.rewardItem.gameObject, Vector3(1,1,1), 1.2, function() self.tweenId = nil end, LeanTweenType.easeOutElastic).id
                   end
                end
           end)


            self.rewardBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            self.rewardBtnTxt.text = string.format(ColorHelper.DefaultButton3Str, TI18N("领奖"))
            --流光转圈特效
            if self.rewardeffect == nil then
                self.rewardeffect = BaseUtils.ShowEffect(20053, self.rewardBtn.transform, Vector3(1.3, 0.7, 1), Vector3(-39, -15, -400))
            end
            self.rewardeffect:SetActive(true)

        --大礼包已领取
        elseif flowerData.gift_flag == 1 then
            self.rewardBtnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            self.rewardBtnTxt.text = string.format(ColorHelper.DefaultButton4Str, TI18N("已领取"))
            if self.rewardeffect ~= nil then
                self.rewardeffect:SetActive(false)
            end
        end

    end

end

function PassBlessWindow:OnClickButton(type,index)

    local flower_data = self.model.flower_list.flower_info[index]

    local id = 0
    if flower_data ~= nil and type == 1 then
        id = flower_data.flower_id or 0
    end

    local flag = false
    --如果为已获得，变为可传递状态
    if flower_data ~= nil and flower_data.pass_flag == 1 then flag = true end
    --传递
    if flag then
        --请求可传递好友列表
        SignDrawManager.Instance:Send20455(id)
    else
        --发送领取协议
        SignDrawManager.Instance:Send20452(type,id)
    end
end

function PassBlessWindow:ShowGiftPriview()
    local base_id = 70130
    local reward = {}
    local temp_reward = CampaignManager.ItemFilter((DataCampPassFlowerLanguage.data_get_final_reward[base_id] or {}).reward)
    for _,v in ipairs(temp_reward or {}) do
        local temp = {}
        temp.item_id = v[1]
        temp.num = v[2]
        temp.is_effet = v[3]
        table.insert(reward, temp)
    end

    local callBack = function(myself) myself.gameObject.transform.localPosition = Vector3(myself.gameObject.transform.localPosition.x,myself.gameObject.transform.localPosition.y,200) end

    if self.possibleReward == nil then
        self.possibleReward = SevenLoginTipsPanel.New(self,callBack)
    end

    self.possibleReward:Show({reward,5,{110,110,100,90},"使用可获得以下道具中的一个"})
end
