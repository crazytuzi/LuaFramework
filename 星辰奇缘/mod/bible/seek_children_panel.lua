SeekChildrenPanel = SeekChildrenPanel or BaseClass(BasePanel)

function SeekChildrenPanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.resList = {
        {file = AssetConfig.seek_children_panel, type = AssetType.Main},
        {file = AssetConfig.bigatlas_summer_happy_bg, type = AssetType.Main},
        {file = AssetConfig.summer_res, type = AssetType.Dep},
        {file = AssetConfig.sworn_textures, type = AssetType.Dep},
        {file = AssetConfig.springfestival_texture,type = AssetType.Dep}
    }

    self.itemDic = {}

    self.OnOpenEvent:AddListener(function()
        self:UpdateWindow()
    end)

    self.campId = nil

    self.seek_child_finish_refreshFun = function ()
        self:UpdateWindow()
    end

    EventMgr.Instance:AddListener(event_name.seek_child_finish_refresh, self.seek_child_finish_refreshFun)
end

function SeekChildrenPanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdateWindow()
end

function SeekChildrenPanel:__delete()
    EventMgr.Instance:RemoveListener(event_name.seek_child_finish_refresh, self.seek_child_finish_refreshFun)
    if self.topBgImg ~= nil then
        self.topBgImg.sprite = nil
    end
    self:AssetClearAll()
end

function SeekChildrenPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.seek_children_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.gameObject.name = "SeekChildrenPanel"
    self.transform = self.gameObject.transform

    -- self.transform:Find("TitleFlagImage/BgImage").transform.anchoredPosition = Vector3(2,-3,0)
    UIUtils.AddBigbg(self.transform:Find("TitleFlagImage/BgImage"), GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_summer_happy_bg)))

    self.topleftDescText = self.transform:Find("TitleFlagImage/Image/Text"):GetComponent(Text)
    self.timeText = self.transform:Find("TitleFlagImage/Image/Image/Text"):GetComponent(Text)
    self.transform:Find("TitleFlagImage/Image/Image"):GetComponent(Image).enabled = false

    -- self.transform:Find("TitleFlagImage/Image").sizeDelta = Vector2(554,60)
    self.transform:Find("TitleFlagImage/ActivityNameBgImage").transform.anchoredPosition = Vector3(-195.3,46,0)
    self.transform:Find("TitleFlagImage/ActivityNameBgImage").gameObject:SetActive(false)

    self.topleftTitleText = self.transform:Find("TitleFlagImage/ActivityNameBgImage/Text"):GetComponent(Text)
    self.topleftTitleText.text = TI18N("捉迷藏")

    self.centerTitleText = self.transform:Find("DescText"):GetComponent(Text)
    self.centerTitleText.text = TI18N("一起来玩捉迷藏吧")

    self.ruleBtn = self.transform:Find("Img"):GetComponent(Button)
    self.ruleBtn.onClick:AddListener(function()
                self:OnClickRuleButton()
            end)

    for i=1,5 do
        local obj = self.transform:Find("Content/Item_"..i)
        local itemTemp = {
            thisObj = obj,
            finishFlagImg = obj:Find("FinishFlagImage"):GetComponent(Image),
            placeTxt = obj:Find("PlaceNameText"):GetComponent(Text),
            descText = obj:Find("DescText"):GetComponent(Text),
            girlImg = obj:Find("GirlImage"):GetComponent(Image),
        }
        itemTemp.placeTxt.supportRichText = true
        itemTemp.girlImg.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(-6,0)
        itemTemp.finishFlagImg.gameObject:SetActive(false)
        itemTemp.thisObj:GetComponent(Button).onClick:AddListener(function()
                self:OnClickItem(i)
            end)
        table.insert(self.itemDic,itemTemp)
    end

    self.boxItem = self.transform:Find("Content/BoxItem")
    self.boxImg = self.boxItem:Find("GirlImage"):GetComponent(Image)
    self.finishTimesTxt = self.boxItem:Find("PlaceNameText"):GetComponent(Text)
    self.finishTimesTxt.supportRichText = true
    self.boxDescTxt = self.boxItem:Find("DescText"):GetComponent(Text)
    self.boxItem:GetComponent(Button).onClick:AddListener(function()
                self:OnClickBoxItem()
            end)

    local campData = DataCampaign.data_list[self.campId]
    self.timeText.text = campData.timestr
end

function SeekChildrenPanel:OnClickRuleButton()
    -- self.descRole = {
    --         "1.愉快的春节，绯月大陆的孩子们邀请你一起<color='#ffff00'>捉迷藏</color>。",
    --         "2.每天<color='#00ff00'>9:30-23:30</color>将有<color='#ffff00'>5</color>名孩子躲藏在场景中，找到他们并提供帮助，会有一些<color='#ffff00'>惊喜</color>喔。",
    --         "3.每天找到<color='#ffff00'>所有的孩子</color>，并实现他们的愿望，可获得一份<color='#ffff00'>欢乐春节礼盒</color>。",
    --     }
    -- TipsManager.Instance:ShowText({gameObject = self.ruleBtn.gameObject, itemData = self.descRole})
    local npcBase = BaseUtils.copytab(DataUnit.data_unit[76519])
    npcBase.buttons = {}
    -- npcBase.plot_talk = TI18N("1.春节到了，淘气的孩子们和大家玩起了<color='#ffff00'>捉迷藏</color>，大伙赶快一起去找到这些调皮的孩子们吧！\n".."2.活动当天<color='#00ff00'>0：00-23:59</color>将有<color='#ffff00'>5</color>名孩子躲藏在场景中，找到他们并提供帮助，会有一些<color='#ffff00'>惊喜</color>喔。\n".."3.每天找到<color='#ffff00'>所有的孩子</color>，并实现他们的愿望，可获得一份<color='#ffff00'>喜迎春节礼盒</color>。")
    MainUIManager.Instance:OpenDialog({baseid = 76519, name = npcBase.name}, {base = npcBase}, true, true)
end

function SeekChildrenPanel:OnClickItem(index)
    if self.childrenData.group ~= 0 then
        local item = self.itemDic[index]
        self.model:ShowSeekChildrenDetailPanel(true,item)
    else
        NoticeManager.Instance:FloatTipsByString(DataCampaign.data_list[self.campId].timestr)
    end
end

function SeekChildrenPanel:OnClickBoxItem()
    if #self.childrenData.list == 5 then
        SummerManager.Instance:request14031()
    elseif self.childrenData.is_reward == 0 then
        local npcBase = BaseUtils.copytab(DataUnit.data_unit[76519])
        npcBase.buttons = {}
        npcBase.plot_talk = TI18N("找齐全部小孩就能领取奖励啦{face_1,36}")
        MainUIManager.Instance:OpenDialog({baseid = 76519, name = npcBase.name}, {base = npcBase}, true, true)
    elseif self.childrenData.is_reward == 1 then
        local npcBase = BaseUtils.copytab(DataUnit.data_unit[76519])
        npcBase.buttons = {}
        npcBase.plot_talk = TI18N("今天玩得很开心，明天再来看看吧{face_1,3}")
        MainUIManager.Instance:OpenDialog({baseid = 76519, name = npcBase.name}, {base = npcBase}, true, true)
    end
end

function SeekChildrenPanel:isFinish(id)
    for i,v in ipairs(self.childrenData.list) do
        if v.id == id then
            return true
        end
    end
    return false
end

function SeekChildrenPanel:checkGoDirect(id)
    local childrenData = SummerManager.Instance.childrensGroupData
    for i,v in ipairs(childrenData.active_list) do
        if v.id == id then
            local isDone = false
            for ii,vv in ipairs(childrenData.list) do
                if vv.id == v.id then
                    isDone = true
                    break
                end
            end
            if isDone == false then
                return true
            end
        end
    end
    return false
end

function SeekChildrenPanel:updateChild(index,id,mapid)
    local item = self.itemDic[index]
    local childInfo = DataCampHideSeek.data_child_unit[id]
    local mapInfo = DataMap.data_list[DataCampHideSeek.data_child_task_map[mapid].map_id]
    -- print(mapid)
    item.girlImg.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, childInfo.child_res_name)
    -- item.girlImg:SetNativeSize()
    item.descText.text = childInfo.name_child
    item.isFinish = self:isFinish(id)
    if item.isFinish == true then
        item.finishFlagImg.gameObject:SetActive(true)
        item.placeTxt.text = string.format("<color='#ffff00'>%s</color>",mapInfo.name)
    else
        item.finishFlagImg.gameObject:SetActive(false)
        item.placeTxt.text = "  ？？？"
    end
    -- if index == 1 or self:checkGoDirect(id) == true then
    if self:checkGoDirect(id) == true then
        item.placeTxt.text = string.format("<color='#ffff00'>%s</color>",mapInfo.name)
    end
    item.index = index
    item.childInfo = childInfo
    item.mapInfo = mapInfo
    -- print(mapid)
    -- BaseUtils.dump(item,"SeekChildrenPanel:updateChild(index,id,mapid)"..mapid)
end

function SeekChildrenPanel:UpdateWindow()

    self.childrenData = SummerManager.Instance.childrensGroupData
    local curGroup = self.childrenData.group
    if curGroup == 0 then
        curGroup = 1
    end
    local childrenList = DataCampHideSeek.data_child_group[curGroup]
    for i,v in ipairs(childrenList.unit_list) do
        --id,mapid
        self:updateChild(i,v[1],v[2])
    end
    self.campaignData = DataCampaign.data_list[self.campId]
    self.topleftDescText.text = self.campaignData.content
    self.boxDescTxt.text = self.campaignData.reward_content
    --TI18N("春节来了，帮助家长们找到淘气的孩子们，可获得一些<color='#ffff00'>惊喜</color>哟~")
    self.finishTimesTxt.text = string.format(TI18N("已完成 <color='#ffff00'>%d/5</color>"), #self.childrenData.list)
    if self.childrenData.is_reward == 0 then
        self.boxImg.color = Color(1,1 ,1 , 1)
        if #self.childrenData.list == 5 then
            if self.boxImgNormalEffer ~= nil then
                self.boxImgNormalEffer.gameObject:SetActive(false)
            end
            if self.boxImgCanReceiveEffer == nil then
                local fun = function(effectView)
                    local effectObject = effectView.gameObject

                    effectObject.transform:SetParent(self.boxImg.transform)
                    effectObject.transform.localScale = Vector3(1, 1, 1)
                    effectObject.transform.localPosition = Vector3(0, 0, -400)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    effectObject:SetActive(true)
                end
                self.boxImgCanReceiveEffer = BaseEffectView.New({effectId = 20119, time = nil, callback = fun})
            else
                self.boxImgCanReceiveEffer.gameObject:SetActive(true)
            end
        else
            if self.boxImgNormalEffer == nil then
                local funNormal = function(effectView)
                    local effectObject = effectView.gameObject

                    effectObject.transform:SetParent(self.boxImg.transform)
                    effectObject.transform.localScale = Vector3(1, 1, 1)
                    effectObject.transform.localPosition = Vector3(0, 0, -400)
                    effectObject.transform.localRotation = Quaternion.identity

                    Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    effectObject:SetActive(true)
                end
                self.boxImgNormalEffer = BaseEffectView.New({effectId = 20125, time = nil, callback = funNormal})
            else
                self.boxImgNormalEffer.gameObject:SetActive(true)
            end
            if self.boxImgCanReceiveEffer ~= nil then
                self.boxImgCanReceiveEffer.gameObject:SetActive(false)
            end
        end
    else
        if self.boxImgNormalEffer ~= nil then
                self.boxImgNormalEffer.gameObject:SetActive(false)
            end
        if self.boxImgCanReceiveEffer ~= nil then
            self.boxImgCanReceiveEffer.gameObject:SetActive(false)
        end
        self.boxImg.color = Color(0.4 ,0.4 ,0.4 , 1)
        self.finishTimesTxt.text = string.format(TI18N("<color='#00ff00'>已领取</color>"))
    end
end


