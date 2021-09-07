ZoneLooksPanel = ZoneLooksPanel or BaseClass(BasePanel)

ZoneLooksType = {
    style = 1,
    badge = 2,
    Frame = 3,
    BigBadge = 4,
}

function ZoneLooksPanel:__init(main)
    self.main = main
    self.zoneMgr = self.main.zoneMgr
    self.name = "ZoneLooksPanel"
    self.prefabsPath = "prefabs/ui/zone/zonelookspanel.unity3d"
    self.resList = {
        {file = self.prefabsPath, type = AssetType.Main}
        ,{file  =  AssetConfig.zonestyleicon, type  =  AssetType.Dep}
    }
    self.type = SpringFestivalEumn.Type.PlantsSprite
    self.data = nil
    self.index = 1

    self.currstyle = nil
    self.currstyle_id = nil
    self.currBadge = {}
    self.currbg = nil
    self.currbg_id = nil
    self.currBigBadge = nil
    self.currBigBadge_id = nil

    self.timestamp = 0

    self.OnOpenEvent:Add(function()
        self:OnShow()
    end)
    self.OnHideEvent:Add(function()
        self:OnHide()
    end)

    self.UpdateTabConListener = function()
        self:UpdateTabCon()
    end

    self.onupdateTimes = function() self:UpdateTimes() end
end

function ZoneLooksPanel:OnInitCompleted()

end

function ZoneLooksPanel:__delete()
    self:OnHide()
    if self.tabgroup ~= nil then
        self.tabgroup:DeleteMe()
        self.tabgroup = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ZoneLooksPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.prefabsPath))
    UIUtils.AddUIChild(self.main.transform.gameObject, self.gameObject)
    self.gameObject.name = "ZoneLooksPanel"
    self.transform = self.gameObject.transform
    self.transform:SetSiblingIndex(4)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self:Hiden()
    end)

    self.titleTxt = self.transform:Find("Top/Text"):GetComponent(Text)

    self.TopBar = self.transform:Find("Top")
    self.BotBar = self.transform:Find("Bot")
    self.MidBtn = self.transform:Find("MidButton")
    self.MidBtn:GetComponent(Button).onClick:AddListener(function()
        self:HideShow()
    end)

    self.Con1 = self.transform:Find("Bot/Con1")
    self.Con2 = self.transform:Find("Bot/Con2")
    self.Con3 = self.transform:Find("Bot/Con3")
    self.Con4 = self.transform:Find("Bot/Con4")
    self.Layout1 = self.transform:Find("Bot/Con1/MaskScroll/Layout")
    self.Layout2 = self.transform:Find("Bot/Con2/MaskScroll/Layout")
    self.Layout3 = self.transform:Find("Bot/Con3/MaskScroll/Layout")
    self.Layout4 = self.transform:Find("Bot/Con4/MaskScroll/Layout")
    self.baseItem = self.Con1:Find("Button").gameObject
    self.baseItem:SetActive(false)
    self.getBtn = self.transform:Find("Bot/GetButton"):GetComponent(Button)
    self.selectBtn = self.transform:Find("Bot/SelectButton"):GetComponent(Button)
    self.timeText = self.transform:Find("Bot/TimeText"):GetComponent(Text)
    self.timeText.gameObject:SetActive(true)
    self.timeText.text = ""

    local go = self.transform:Find("Bot/TabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end)
    local setting = {
        axis = BoxLayoutAxis.X
        ,spacing = 5
        ,Left = 1
        ,Top = 4
        ,border = 15
        -- ,scrollRect = self.LeftConGroup[3]
    }
    self.Layout1Obj = LuaBoxLayout.New(self.Layout1, setting)
    self.Layout2Obj = LuaBoxLayout.New(self.Layout2, setting)
    self.Layout3Obj = LuaBoxLayout.New(self.Layout3, setting)
    self.Layout4Obj = LuaBoxLayout.New(self.Layout4, setting)
    self:InitTabCon()

    self.getBtn.onClick:AddListener(function() self:OnGetBtn() end)
    self.selectBtn.onClick:AddListener(function() self:OnSelectBtn() end)

    self:OnShow()
end

function ZoneLooksPanel:OnBtn()

end

function ZoneLooksPanel:OnTabChange(index)

    self.Con1.gameObject:SetActive(index == 1)
    self.Con2.gameObject:SetActive(index == 2)
    self.Con3.gameObject:SetActive(index == 3)
    self.Con4.gameObject:SetActive(index == 4)
    self.index = index
    if index == 1 then

    elseif index == 2 then
        self.titleTxt.text = TI18N("徽章预览")

    elseif index == 3 then

    elseif index == 4 then
        self.titleTxt.text = TI18N("荣耀预览")
    end

    self.timestamp = 0
    self:UpdateButtonText()
end

function ZoneLooksPanel:OnShow()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.timerId = LuaTimer.Add(0, 1000, function() self:UpdateButtonText() end)

    AchievementManager.Instance.onUpdateBuyPanel:AddListener(self.UpdateTabConListener)
    WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.onupdateTimes)
    WorldChampionManager.Instance.onUpdateTimes:AddListener(self.onupdateTimes)
end

function ZoneLooksPanel:OnHide()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end

    AchievementManager.Instance.onUpdateBuyPanel:RemoveListener(self.UpdateTabConListener)
    WorldChampionManager.Instance.onUpdateTimes:RemoveListener(self.onupdateTimes)

    if self.main.currStyle ~= self.main.StylePanelObj.id then
        self.main.StylePanelObj:Reload(self.main.currStyle)
    end
    if self.main.currFrame ~= self.currbg_id then
        self.main:SetFrame(self.main.currFrame)
    end
    if self.main.currBigBadge ~= self.currBigBadge_id then
        self.main:SetBigBadge(self.main.currBigBadge)
    end
    local thesame = true
    -- BaseUtils.dump(self.main.currBadge,"AAAAAAAA")
    -- BaseUtils.dump(self.currBadge,"BBBBBB")
    if self.main.currBadge == nil or next(self.main.currBadge) == nil then
        -- print("默认空")
        thesame = false
    end
    for i,v in ipairs(self.main.currBadge) do
        if self.currBadge[v.badge_id] ~= true  then
            -- print("不匹配")
            thesame = false
        end
    end
    BaseUtils.dump(self.main.currBadge,"数据==================================")
    if thesame == false then
        -- print("不同")
        local resList = self.main.currBadge
        for i=1,3 do
            -- local resid = self.zoneMgr:GetResId(self.main.currBadge[i])
            if resList[i] ~= nil then
                local base_id = resList[i].badge_id
                self.main:SetBadge(i, base_id)
            end
        end

    end

    if self.gameObject ~= nil then
        self.TopBar.gameObject:SetActive(true)
        self.BotBar.gameObject:SetActive(true)
    end
end

function ZoneLooksPanel:InitTabCon()

    -- BaseUtils.dump(AchievementManager.Instance.model.shop_buylist,"成就商店列表==========================================================================")
    if self.main == nil or self.main.assetWrapper == nil then
        return
    end
    for k,v in ipairs(DataFriendZone.data_style) do
        local item = GameObject.Instantiate(self.baseItem)
        local icon = item.transform:Find("icon"):GetComponent(Image)
        icon.sprite = self.assetWrapper:GetSprite(AssetConfig.zonestyleicon, tostring(v.id))
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        if self.main.currStyle == v.id or (self.main.currStyle == nil and v.id == 0) then
            item.transform:Find("select").gameObject:SetActive(true)
            self.currstyle = item
        end
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self:OnClickStyle(item, v)
        end)
        self.Layout1Obj:AddCell(item)
    end
    -- local templist = DataFriendZone.data_badge
    local templist = self:GetBadgelevList()
    table.sort( templist, function(a,b)
        if self.zoneMgr:IsHasNew(a.base_id) and not self.zoneMgr:IsHasNew(b.base_id) then
            return true
        elseif not self.zoneMgr:IsHasNew(a.base_id) and self.zoneMgr:IsHasNew(b.base_id) then
            return false
        else
            return a.order < b.order
        end
    end )
    BaseUtils.dump(AchievementManager.Instance.model.shop_buylist,"成就已达成的徽章")
    BaseUtils.dump(self.main.currBadge,"当前已有的徽章")
    BaseUtils.dump(templist,"组织的徽章数据")
    for k,v in ipairs(templist) do
        local item = GameObject.Instantiate(self.baseItem)
        local icon = item.transform:Find("icon"):GetComponent(Image)



        icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[v.base_id].source_id))
        local has = self.zoneMgr:IsHasNew(v.base_id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        local hasselect = false
        for i,vv in ipairs(self.main.currBadge) do
            -- print(self.zoneMgr:GetResId(vv.badge_id))
            if vv.badge_id == v.base_id then
                hasselect = true
            end
        end
        if hasselect then
            item.transform:Find("select").gameObject:SetActive(true)
            self.currBadge[v.base_id] = true
            self.currstyle = item
        end
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self:OnClickBadge(item, v)
        end)

        if v.id == 20030 then
            self.specialBradgeItem = item
            --WorldChampionManager.Instance:Require16430(RoleManager.Instance.RoleData.id,RoleManager.Instance.RoleData.platform,RoleManager.Instance.RoleData.zone_id)
        else
            self.specialBradgeItem = nil
        end
        self.Layout2Obj:AddCell(item)
    end

    for k,v in ipairs(DataFriendZone.data_frame) do
        local item = GameObject.Instantiate(self.baseItem)
        local icon = item.transform:Find("icon"):GetComponent(Image)
        if v.id == 0 then
            icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.photo_frame, "0")
        else
            icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.photo_frame, string.format("icon%s", tostring(v.id)))
        end
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        if self.main.currFrame == v.id or (self.main.currFrame == nil and v.id == 0) then
            item.transform:Find("select").gameObject:SetActive(true)
            self.currbg = item
        end
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self:OnClickBg(item, v)
        end)
        self.Layout3Obj:AddCell(item)
    end

    for k,v in ipairs(DataFriendZone.data_bigbadge) do
        local item = GameObject.Instantiate(self.baseItem)
        local icon = item.transform:Find("icon"):GetComponent(Image)
        icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.bigbadge, v.id)
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        if self.main.currBigBadge == v.id or (self.main.currBigBadge == nil and v.id == 0) then
            item.transform:Find("select").gameObject:SetActive(true)
            self.currBigBadge = item
        end
        item.transform:GetComponent(Button).onClick:AddListener(function()
            self:OnClickBigBadge(item, v)
        end)
        self.Layout4Obj:AddCell(item)
    end
end

function ZoneLooksPanel:UpdateTimes()
    if self.specialBradgeItem ~= nil then
        if WorldChampionManager.Instance.times > 0 then
            local numberImg = self.specialBradgeItem.transform:Find("icon/iconNumber"):GetComponent(Image)
            numberImg.sprite = self.main.assetWrapper:GetSprite(AssetConfig.bigbadge,"Number" .. WorldChampionManager.Instance.times)
            self.specialBradgeItem.transform:Find("icon/iconNumber").gameObject:SetActive(false)
        else
            self.specialBradgeItem.transform:Find("icon/iconNumber").gameObject:SetActive(false)
        end
    end
end
function ZoneLooksPanel:HideShow()
    if self.TopBar.gameObject.activeSelf then
        self.TopBar.gameObject:SetActive(false)
        self.BotBar.gameObject:SetActive(false)
    else
        self.TopBar.gameObject:SetActive(true)
        self.BotBar.gameObject:SetActive(true)
    end
end

function ZoneLooksPanel:OnClickStyle(item, data)
    if self.currstyle_id == data.id then
        return
    end
    self.currstyle_id = data.id
    if self.currstyle == nil then
        self.currstyle = item
        self.currstyle.transform:Find("select").gameObject:SetActive(true)
    else
        self.currstyle.transform:Find("select").gameObject:SetActive(false)
        self.currstyle = item
        self.currstyle.transform:Find("select").gameObject:SetActive(true)
    end
    local has = self.zoneMgr:IsHas(data.id)
    self.getBtn.gameObject:SetActive(has == false)
    self.selectBtn.gameObject:SetActive(has == true)
    self.titleTxt.text = string.format(TI18N("空间装饰预览：<color='#ffff9a'>%s</color>"), tostring(data.name))
    if self.main.StylePanelObj ~= nil then
        self.main.StylePanelObj:Reload(data.id)
    end
    -- self.titleTxt.text = string.format("空间装饰预览：%s", DataFriendZone.data_style[id].name)
    self.timestamp = 0
    self:UpdateButtonText()
end

function ZoneLooksPanel:OnClickBadge(item, data)
    print(data.id)
    BaseUtils.dump(self.currBadge,"背包1111============================================================================")

    local currnum = 0
    for k,v in pairs(self.currBadge) do
        if v == true then
            currnum = currnum + 1
        end
    end
    if currnum >= 3 and self.currBadge[data.base_id] ~= true then
        NoticeManager.Instance:FloatTipsByString(TI18N("最多显示3个徽章"))
        return
    elseif self.currBadge[data.base_id] == true then
        self.currBadge[data.base_id] = false

        item.transform:Find("select").gameObject:SetActive(false)
    elseif currnum< 3 and self.currBadge[data.base_id] ~= true then
        local data1 = DataAchieveShop.data_list[data.base_id]
        NoticeManager.Instance:FloatTipsByString(data1.desc)
        self.currBadge[data.base_id] = true
        item.transform:Find("select").gameObject:SetActive(true)
    end
    local _index = 1
    BaseUtils.dump(self.currBadge,"背包222============================================================================")

    for i,v in ipairs(DataFriendZone.data_badge) do
        if self.currBadge[v.base_id] == true then
            self.main:SetBadge(_index, v.base_id)
            _index = _index + 1
        end
    end
    if _index <=3 then
        for i=_index,3 do
            self.main:SetBadge(i, 0)
        end
    end
    self.getBtn.gameObject:SetActive(false)
    self.selectBtn.gameObject:SetActive(true)

    self.timestamp = 0
    self:UpdateButtonText()
end

function ZoneLooksPanel:OnClickBg(item, data)
    self.currbg_id = data.id
    if self.currbg == nil then
        self.currbg = item
        self.currbg.transform:Find("select").gameObject:SetActive(true)
    else
        self.currbg.transform:Find("select").gameObject:SetActive(false)
        self.currbg = item
        self.currbg.transform:Find("select").gameObject:SetActive(true)
    end
    local has = self.zoneMgr:IsHas(data.id)
    self.getBtn.gameObject:SetActive(has == false)
    self.selectBtn.gameObject:SetActive(has == true)
    self.titleTxt.text = string.format(TI18N("相框预览：<color='#ffff9a'>%s</color>"), data.name)
    self.main:SetFrame(data.id)

    self.timestamp = 0
    self:UpdateButtonText()
end

function ZoneLooksPanel:OnClickBigBadge(item, data)
    self.currBigBadge_id = data.id
    if self.currBigBadge == nil then
        self.currBigBadge = item
        self.currBigBadge.transform:Find("select").gameObject:SetActive(true)
    else
        self.currBigBadge.transform:Find("select").gameObject:SetActive(false)
        self.currBigBadge = item
        self.currBigBadge.transform:Find("select").gameObject:SetActive(true)
    end
    local has = self.zoneMgr:IsHas(data.id)
    self.getBtn.gameObject:SetActive(has == false)
    self.selectBtn.gameObject:SetActive(has == true)
    self.titleTxt.text = string.format(TI18N("荣耀预览：<color='#ffff9a'>%s</color>"), data.name)
    self.main:SetBigBadge(data.id)

    self.timestamp = self.zoneMgr:GetTimestamp(data.id)
    self:UpdateButtonText()
end

function ZoneLooksPanel:OnGetBtn()
    -- NoticeManager.Instance:FloatTipsByString("打开成就兑换面板")
    if self.index == ZoneLooksType.style then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,1})
    elseif self.index == ZoneLooksType.badge then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,2})
    elseif self.index == ZoneLooksType.Frame then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,1})
    elseif self.index == ZoneLooksType.BigBadge then
        -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,1})
        for _, value in pairs(DataAchieveShop.data_list) do
            if self.currBigBadge_id == value.source_id then
                NoticeManager.Instance:FloatTipsByString(value.condition)
                return
            end
        end
    end
end

function ZoneLooksPanel:OnSelectBtn()
    -- if self.index == ZoneLooksType.style then
        local id = self.zoneMgr:ResIdToId(self.currstyle_id)
        self.zoneMgr:Require11850(id)
    -- elseif self.index == ZoneLooksType.badge then
        local list, nohasList = self:GetbadgeidList()
        BaseUtils.dump(list,'最终发送的数据')
        if #nohasList > 0 then
            local str = TI18N("未获得")
            for i,v in ipairs(nohasList) do
                str = string.format("%s<color='#ffff00'>%s、</color>", str, DataAchieveShop.data_list[v].name)
            end
            NoticeManager.Instance:FloatTipsByString(str)
            return
        end
        self.zoneMgr:Require11852(list)

    -- elseif self.index == ZoneLooksType.Frame then
        local id = self.zoneMgr:ResIdToId(self.currbg_id)
        self.zoneMgr:Require11851(id)
    -- end
        local id = self.zoneMgr:ResIdToId(self.currBigBadge_id)
        self.zoneMgr:Require11892(id)

    -- NoticeManager.Instance:FloatTipsByString("发送更换协议")
end

function ZoneLooksPanel:GetbadgeidList()
    local temp = {}
    local temp_res = {}
    local nohasList = {}
    for i,v in pairs(DataAchieveShop.data_list) do
        local currBadgeIsTrue = false

        if self.currBadge[v.id] == true then
            currBadgeIsTrue  = true
        end

        if currBadgeIsTrue == true then
            if self.zoneMgr:IsHasNew(v.id) == false then
                table.insert(nohasList, v.id)
            else
                if not table.containValue(temp_res, v.source_id) then
                    table.insert(temp, v.id)
                else
                    for key, value in pairs(temp_res) do
                          if value == v.id then
                               temp[key] = v.id
                               break
                           end
                    end
                end
                    -- local myId = nil
                    -- if resid >= 20001 and resid <= 20008 then
                    --     local myId = string.sub(tostring(resid),-2,-1)
                    -- end
                    table.insert(temp_res,v.id)
            end
        end
    end
    -- BaseUtils.dump(temp_res,"之前的数据========================================================================")

    return temp, nohasList
end

function ZoneLooksPanel:GetBadgelevList()
    local lvtypeList = {}

    for k,v in pairs(DataFriendZone.data_badge) do
        if self.zoneMgr:IsHasNew(v.base_id) then
            if lvtypeList[v.type] and lvtypeList[v.type].lev < v.lev then
                lvtypeList[v.type] = v
            else
                lvtypeList[v.type] = v
            end
        end
    end
        BaseUtils.dump(temp,"筛选前徽章的数据==============================================================")

    local temp = {}
    for k,v in pairs(DataFriendZone.data_badge) do

        if self.zoneMgr:IsHasNew(v.base_id) then
            if lvtypeList[v.type].lev == v.lev then
                table.insert(temp, v)
            end
        else
            if v.id < 20030 or v.id > 20038  then
                table.insert(temp, v)
            else
                print("我进来的是这里====================================" .. v.id)
            end
        end

    end
    BaseUtils.dump(temp,"徽章的数据==============================================================")
    return temp

end

function ZoneLooksPanel:UpdateButtonText()
    if self.timestamp ~= 0 then
        local time = self.timestamp - BaseUtils.BASE_TIME
        if time <= 0 then
            self.timeText.text = TI18N("已过期")
        else
            local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(time)
            if my_date ~= 0 then
                self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余%s天</color>"), my_date)
            elseif my_hour ~= 0 then
                self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余%s小时</color>"), my_hour)
            elseif my_minute ~= 0 then
                self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余%s分钟</color>"), my_minute)
            elseif my_second ~= 0 then
                self.timeText.text = string.format(TI18N("<color='#00ff00'>剩余%s秒</color>"), my_second)
            end
        end
    else
        self.timeText.text = ""
    end
end

function ZoneLooksPanel:UpdateTabCon()
    if self.main == nil or self.main.assetWrapper == nil then
        return
    end

    local index = 1
    for k,v in ipairs(DataFriendZone.data_style) do
        local item = self.Layout1Obj.cellList[index]
        local icon = item.transform:Find("icon"):GetComponent(Image)
        icon.sprite = self.assetWrapper:GetSprite(AssetConfig.zonestyleicon, tostring(v.id))
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        if self.index == 1 and self.currstyle_id == v.id then
            self:OnClickStyle(item, v)
        end
        index = index + 1
    end

    index = 1
    -- local templist = DataFriendZone.data_badge
    local templist = self:GetBadgelevList()
    table.sort( templist, function(a,b)
        if self.zoneMgr:IsHas(a.id) and not self.zoneMgr:IsHas(b.id) then
            return true
        elseif not self.zoneMgr:IsHas(a.id) and self.zoneMgr:IsHas(b.id) then
            return false
        else
            return a.order < b.order
        end
    end )


    for k,v in ipairs(templist) do
        local item = self.Layout2Obj.cellList[index]
        icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(DataAchieveShop.data_list[v.base_id].source_id))
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        index = index + 1
    end

    index = 1
    for k,v in ipairs(DataFriendZone.data_frame) do
        local item = self.Layout3Obj.cellList[index]
        local icon = item.transform:Find("icon"):GetComponent(Image)
        if v.id == 0 then
            icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.photo_frame, "0")
        else
            icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.photo_frame, string.format("icon%s", tostring(v.id)))
        end
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end
        if self.index == 3 and self.currbg_id == v.id then
            self:OnClickBg(item, v)
        end
        index = index + 1
    end

    index = 1
    for k,v in ipairs(DataFriendZone.data_bigbadge) do
        local item = self.Layout4Obj.cellList[index]
        local icon = item.transform:Find("icon"):GetComponent(Image)
        icon.sprite = self.main.assetWrapper:GetSprite(AssetConfig.bigbadge, v.id)
        local has = self.zoneMgr:IsHas(v.id)
        if not has then
            icon.color = Color(0.3, 0.3, 0.3)
        else
            icon.color = Color.white
        end

        if self.index == 4 and self.currBigBadge_id == v.id then
            self:OnClickBigBadge(item, v)
        end

        index = index + 1
    end
end