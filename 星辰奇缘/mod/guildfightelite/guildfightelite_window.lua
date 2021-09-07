-- 公会英雄战，领取显示面板
-- @author zgs
GuildfightEliteWindow = GuildfightEliteWindow or BaseClass(BaseWindow)

function GuildfightEliteWindow:__init(model)
    self.model = model
    self.name = "GuildfightEliteWindow"
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.TypeTeam_sun = 1  --太阳
    self.TypeTeam_mon = 2  --月亮
    self.TypeTeam_star = 3 --星辰

    self.selectIndex = 1
    self.itemDic = {}

    self.resList = {
        {file = AssetConfig.guild_fight_elite_window, type = AssetType.Main}
        ,{file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep},
    }
    self.isNeedShowTips = false
    self.OnOpenEvent:AddListener(function()
        -- GuildfightManager.Instance:send15501()
        -- GuildfightManager.Instance:send15506()
        -- self.isNeedShowTips = false
        -- local index = self.selectIndex
        if self.openArgs ~= nil and self.openArgs[1] ~= nil then
            self.selectIndex = tonumber(self.openArgs[1])
        end
        -- self.tabgroup:ChangeTab(index)
        GuildFightEliteManager.Instance:send16201()
    end)

    -- self.panelList = {}
    self.teamInfoList = {}

    self.guildfightEliteLeaderUpdateFun = function ()
        if self.tabgroup ~= nil then
            self.tabgroup:ChangeTab(self.selectIndex)
        end
    end
    EventMgr.Instance:AddListener(event_name.guildfight_elite_leaderinfo_change, self.guildfightEliteLeaderUpdateFun)

    self.lastLookTeamIndex = 1
end

function GuildfightEliteWindow:OnInitCompleted()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.selectIndex = tonumber(self.openArgs[1])
    end
    GuildFightEliteManager.Instance:send16201()
    -- GuildfightManager.Instance:send15501()
    -- GuildfightManager.Instance:send15506()
    -- self.isNeedShowTips = false
    -- local index = self.selectIndex
    -- self.tabgroup:ChangeTab(index)
end

function GuildfightEliteWindow:__delete()
    -- if self.panelList[1] ~= nil then
    --     self.panelList[1]:DeleteMe()
    --     self.panelList = nil
    -- end
    self.itemDic = nil
    EventMgr.Instance:RemoveListener(event_name.guildfight_elite_leaderinfo_change, self.guildfightEliteLeaderUpdateFun)
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.gfemp = nil
    self.model = nil
end

function GuildfightEliteWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_elite_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.teamInfoPanel = self.transform:Find("TeamInfoPanel")
    self.teamInfoPanelBtn = self.teamInfoPanel.gameObject:GetComponent(Button)
    self.teamInfoPanelBtn.onClick:AddListener( function() self:onClickCloseTeamInfoBtn() end)
    self.teamInfo = self.transform:Find("TeamInfo")
    self.teamDescText = self.teamInfo:Find("BgImage/DescText"):GetComponent(Text)
    self.teamDescText.supportRichText = true
    self.teamInfoPanel.gameObject:SetActive(false)
    self.teamInfo.gameObject:SetActive(false)
    for i=1,5 do
        --
        local teamInfoItem = {}
        local itemTeam = self.teamInfo:Find("BgImage/THead_"..i)
        teamInfoItem.item = itemTeam
        teamInfoItem.nameText = itemTeam:Find("NameText"):GetComponent(Text)
        teamInfoItem.levBg = itemTeam:Find("LevBgImage")
        teamInfoItem.levText = itemTeam:Find("LevBgImage/LevText"):GetComponent(Text)
        teamInfoItem.head = itemTeam:Find("HeadImage"):GetComponent(Image)

        table.insert(self.teamInfoList,teamInfoItem)
    end

    self.Main = self.transform:Find("Main")
    self.tabGroupObj = self.Main:Find("TabButtonGroup").gameObject
    local setting = {
        notAutoSelect = true,
        noCheckRepeat = true,
        openLevel = {0,0,999},
        perWidth = 62,
        perHeight = 100,
        isVertical = true
    }
    self.tabgroup = TabGroup.New(self.tabGroupObj, function(index) self:TabChange(index) end, setting)

    self.fightLogsPanel = self.Main:Find("FightRecordPanel")
    self.grid = self.fightLogsPanel:Find("ScorllPanel/Grid")
    self.itemGpt = self.grid:Find("Item").gameObject
    self.itemGpt:SetActive(false)
    self.gptLayout = LuaBoxLayout.New(self.grid.gameObject, {axis = BoxLayoutAxis.Y, cspacing = 3,border = 4})
    self.noneLogs = self.fightLogsPanel:Find("NoneImage").gameObject
    self.noneLogs:SetActive(false)

    self.MainCon = self.Main:Find("ChooseLeaderPanel")

    self.centerText = self.MainCon:Find("CCText_1"):GetComponent(Text)
    -- self.centerText.lineSpacing = 1.1
    self.centerText.text = string.format(TI18N("1、公会英雄活动于每<color='#ffff00'>周五21：45</color>开启，会长、副会长或长老可在<color='#ffff00'>当天15：00</color>后进行安排\n2、活动开始后系统将会自动匹配出对战公会<color='#ffff00'>（共2轮）</color>\n3、双方太阳、月亮、星辰<color='#ffff00'>相互交战</color>，率先取得<color='#ffff00'>两场胜利</color>的一方即为胜利\n4、领队需要在活动时组队进入准备厅，队伍<color='#ffff00'>不足3人</color>将被视作放弃比赛\n5、两轮比赛打完后，获胜公会准备区将会洒下<color='#ffff00'>胜利宝箱</color>，所有公会成员都可开启\n6、代表队每获得一场胜利<color='#ffff00'>全体成员</color>均可得到奖励（参战者获得的奖励翻倍）"))

    self.item_1 = self.MainCon:FindChild("Item_1")
    self.image_1 = self.item_1:Find("THead/HeadImage"):GetComponent(Image)
    self.image_1.gameObject:SetActive(false)
    self.sexIcon_1 = self.item_1:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_1.gameObject:SetActive(false)
    self.nameText_1 = self.item_1:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_1 = self.item_1:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_1 = self.item_1:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_1.text = TI18N("月亮代表队")
    self.changeBtn_1 = self.item_1:Find("OpposeButton"):GetComponent(Button)
    self.changeBtn_1.onClick:AddListener( function() self:onClickChangeBtn(1) end)
    self.setBtn_1 = self.item_1:Find("SetButton"):GetComponent(Button)
    self.setBtn_1.onClick:AddListener( function() self:onClickSetBtn(1) end)
    self.lookBtn_1 = self.item_1:Find("LookButton"):GetComponent(Button)
    self.lookBtn_1.onClick:AddListener( function() self:onClickLookBtn(1) end)
    self.headBg_1 = self.item_1:Find("THead"):GetComponent(Button)
    self.headBg_1.onClick:AddListener( function() self:onClickSetBtn(1) end)
    self.item_1:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(1) end)

    self.item_2 = self.MainCon:FindChild("Item_2")
    self.image_2 = self.item_2:Find("THead/HeadImage"):GetComponent(Image)
    self.image_2.gameObject:SetActive(false)
    self.sexIcon_2 = self.item_2:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_2.gameObject:SetActive(false)
    self.nameText_2 = self.item_2:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_2 = self.item_2:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_2 = self.item_2:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_2.text = TI18N("太阳代表队")
    self.changeBtn_2 = self.item_2:Find("OpposeButton"):GetComponent(Button)
    self.changeBtn_2.onClick:AddListener( function() self:onClickChangeBtn(2) end)
    self.setBtn_2 = self.item_2:Find("SetButton"):GetComponent(Button)
    self.setBtn_2.onClick:AddListener( function() self:onClickSetBtn(2) end)
    self.lookBtn_2 = self.item_2:Find("LookButton"):GetComponent(Button)
    self.lookBtn_2.onClick:AddListener( function() self:onClickLookBtn(2) end)
    self.headBg_2 = self.item_2:Find("THead"):GetComponent(Button)
    self.headBg_2.onClick:AddListener( function() self:onClickSetBtn(2) end)
    self.item_2:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(2) end)

    self.item_3 = self.MainCon:FindChild("Item_3")
    self.image_3 = self.item_3:Find("THead/HeadImage"):GetComponent(Image)
    self.image_3.gameObject:SetActive(false)
    self.sexIcon_3 = self.item_3:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_3.gameObject:SetActive(false)
    self.nameText_3 = self.item_3:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_3 = self.item_3:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_3 = self.item_3:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_3.text = TI18N("星辰代表队")
    self.changeBtn_3 = self.item_3:Find("OpposeButton"):GetComponent(Button)
    self.changeBtn_3.onClick:AddListener( function() self:onClickChangeBtn(3) end)
    self.setBtn_3 = self.item_3:Find("SetButton"):GetComponent(Button)
    self.setBtn_3.onClick:AddListener( function() self:onClickSetBtn(3) end)
    self.lookBtn_3 = self.item_3:Find("LookButton"):GetComponent(Button)
    self.lookBtn_3.onClick:AddListener( function() self:onClickLookBtn(3) end)
    self.headBg_3 = self.item_3:Find("THead"):GetComponent(Button)
    self.headBg_3.onClick:AddListener( function() self:onClickSetBtn(3) end)
    self.item_3:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(3) end)
end
function GuildfightEliteWindow:TabChange(index)
    -- body
    self:updateWindow(index)
end
function GuildfightEliteWindow:onClickCloseTeamInfoBtn()
    self.teamInfoPanel.gameObject:SetActive(false)
    self.teamInfo.gameObject:SetActive(false)
end
--更换
function GuildfightEliteWindow:onClickChangeBtn(index)
    self.model:ShowEliteMemberPanel(true,index)
end
--安排
function GuildfightEliteWindow:onClickSetBtn(index)
    self.model:ShowEliteMemberPanel(true,index)
end
--查看
function GuildfightEliteWindow:onClickLookBtn(index)
    -- 发协议，查看安排的队伍信息
    self.lastLookTeamIndex = index
    local strDesc = TI18N("太阳代表队")
    if self.lastLookTeamIndex == 1 then
        strDesc = TI18N("月亮代表队")
    elseif self.lastLookTeamIndex == 3 then
        strDesc = TI18N("星辰代表队")
    end
    local data = self:GetPosDataByPos(index)
    if data ~= nil then
        TeamManager.Instance:Send11736(data.rid, data.platform, data.zone_id)
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>暂未安排领队"),strDesc))
    end
end
--显示队伍信息
function GuildfightEliteWindow:updateTeamInfo(data)
    self.teamInfoPanel.gameObject:SetActive(true)
    self.teamInfo.gameObject:SetActive(true)

    local strDesc = TI18N("太阳代表队")
    if self.lastLookTeamIndex == 1 then
        strDesc = TI18N("月亮代表队")
    elseif self.lastLookTeamIndex == 3 then
        strDesc = TI18N("星辰代表队")
    end
    self.teamDescText.text = string.format(TI18N("<color='#ffff00'>%s</color>当前组队状态："),strDesc)

    for i,v in ipairs(self.teamInfoList) do
        local dataItem = data.members[i]
        if dataItem ~= nil then
            v.nameText.text = dataItem.name
            v.head.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", dataItem.classes, dataItem.sex))
            v.head.gameObject:SetActive(true)
            v.levText.text = tostring(dataItem.lev)
            v.levBg.gameObject:SetActive(true)
        else
            v.head.gameObject:SetActive(false)
            v.levBg.gameObject:SetActive(false)
            v.nameText.text = TI18N("暂无队员")
        end
    end
end

function GuildfightEliteWindow:GetPosDataByPos(pos)
    for i,v in ipairs(GuildFightEliteManager.Instance.eliteLeaderInfo) do
        if v.position == pos then
            return v
        end
    end
    return nil
end

function GuildfightEliteWindow:updateWindow(index)
    if index == 1 then --安排领队界面
        self.MainCon.gameObject:SetActive(true)
        self.fightLogsPanel.gameObject:SetActive(false)
        -- if self.panelList[1] ~= nil then
        --     self.panelList[1]:Hiden()
        -- end

        self.item_1.gameObject:SetActive(true)
        self.item_2.gameObject:SetActive(true)
        self.item_3.gameObject:SetActive(true)
        local data_1 = self:GetPosDataByPos(1)
        if data_1 ~= nil then
            self.setBtn_1.gameObject:SetActive(false)
            self.changeBtn_1.gameObject:SetActive(true)
            self.image_1.gameObject:SetActive(true)
            self.image_1.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
            self.sexIcon_1.gameObject:SetActive(true)
            self.sexIcon_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
            -- self.classIcon_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
            self.nameText_1.text = data_1.name
            self.classText_1.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])
        else
            self.nameText_1.text = TI18N("暂未安排")
            self.classText_1.text = string.format(TI18N("？？级 暂无"))
            self.image_1.gameObject:SetActive(false)
            self.sexIcon_1.gameObject:SetActive(false)
            self.setBtn_1.gameObject:SetActive(true)
            self.changeBtn_1.gameObject:SetActive(false)
        end
        data_1 = self:GetPosDataByPos(2)
        if data_1 ~= nil then
            self.setBtn_2.gameObject:SetActive(false)
            self.changeBtn_2.gameObject:SetActive(true)
            self.image_2.gameObject:SetActive(true)
            self.image_2.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
            self.sexIcon_2.gameObject:SetActive(true)
            self.sexIcon_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
            -- self.classIcon_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
            self.nameText_2.text = data_1.name
            self.classText_2.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])
        else
            self.nameText_2.text = TI18N("暂未安排")
            self.classText_2.text = string.format(TI18N("？？级 暂无"))
            self.image_2.gameObject:SetActive(false)
            self.sexIcon_2.gameObject:SetActive(false)
            self.setBtn_2.gameObject:SetActive(true)
            self.changeBtn_2.gameObject:SetActive(false)
            -- self.item_2.gameObject:SetActive(false)
        end
        data_1 = self:GetPosDataByPos(3)
        if data_1 ~= nil then
            self.setBtn_3.gameObject:SetActive(false)
            self.changeBtn_3.gameObject:SetActive(true)
            self.image_3.gameObject:SetActive(true)
            self.image_3.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
            self.sexIcon_3.gameObject:SetActive(true)
            self.sexIcon_3.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
            -- self.classIcon_3.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
            self.nameText_3.text = data_1.name
            self.classText_3.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])
        else
            self.nameText_3.text = TI18N("暂未安排")
            self.classText_3.text = string.format(TI18N("？？级 暂无"))
            self.image_3.gameObject:SetActive(false)
            self.sexIcon_3.gameObject:SetActive(false)
            self.setBtn_3.gameObject:SetActive(true)
            self.changeBtn_3.gameObject:SetActive(false)
            -- self.item_3.gameObject:SetActive(false)
        end
    elseif index == 2 then
        self.MainCon.gameObject:SetActive(false)
        self.fightLogsPanel.gameObject:SetActive(true)
        -- if self.panelList[1] == nil then
        --     -- self.panelList[1] =
        -- end
        -- -- self.panelList[1]:Show()
        GuildFightEliteManager.Instance:send16206()
    end
end

function GuildfightEliteWindow:OnClickClose()
    self.model:CloseMain()
end

function GuildfightEliteWindow:UpdateFightLogs(dataList)
    for i,v in ipairs(self.itemDic) do
        if v.thisObj ~= nil then
            v.thisObj:SetActive(false)
        end
    end
    for i,v in ipairs(dataList) do
        local itemTaken = self.itemDic[i]
        local data = dataList[i]
        if itemTaken == nil then
            local obj = GameObject.Instantiate(self.itemGpt)
            obj.name = tostring(i)

            self.gptLayout:AddCell(obj)
            local itemDicTemp = {
                index = i,
                thisObj = obj,
                dataItem = data,
                logText = obj.transform:Find("CCText_1"):GetComponent(Text),
                btn = obj.transform:Find("LookButton"):GetComponent(Button),
            }
            itemDicTemp.btn.onClick:AddListener( function() self:onClickLookButtonFightHero(i) end)
            self.itemDic[i] = itemDicTemp
            self.itemDic[i].msgItemExt = MsgItemExt.New(itemDicTemp.logText, 630, 17, 23)

            itemTaken = itemDicTemp

            itemTaken.btn.gameObject:SetActive(false)
        end
        itemTaken.dataItem = data
        itemTaken.thisObj:SetActive(true)

        local py = tostring(os.date("%Y", itemTaken.dataItem.time))
        local pmm = tostring(os.date("%m", itemTaken.dataItem.time))
        local pd = tostring(os.date("%d", itemTaken.dataItem.time))
        local ph = tostring(os.date("%H", itemTaken.dataItem.time))
        local pm = tostring(os.date("%M", itemTaken.dataItem.time))
        local strTemp = string.format(TI18N("<color='#ffff00'>%s年%s月%s日　%s:%s</color>　　%s"),py,pmm,pd,ph,pm,itemTaken.dataItem.name)
        itemTaken.msgItemExt:SetData(strTemp)

        if itemTaken.dataItem.match_type ~= 0 and itemTaken.dataItem.match_local_id ~= 0 and itemTaken.dataItem.position ~= 0 then
            itemTaken.btn.gameObject:SetActive(true)
        else
            itemTaken.btn.gameObject:SetActive(false)
        end
    end
    if #dataList > 0 then
        self.noneLogs:SetActive(false)
    else
        self.noneLogs:SetActive(true)
    end
end

function GuildfightEliteWindow:onClickLookButtonFightHero(index)
    local item = self.itemDic[index]
    GuildFightEliteManager.Instance:send16207(item.dataItem.match_type, item.dataItem.match_local_id, item.dataItem.position)
end

