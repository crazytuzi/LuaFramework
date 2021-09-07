-- 冠军联赛，领对显示面板
-- @author hzf
-- copyright © zgs
GuildLeagueTeamWindow = GuildLeagueTeamWindow or BaseClass(BaseWindow)

function GuildLeagueTeamWindow:__init(model)
    self.model = model
    self.Mgr = GuildLeagueManager.Instance
    self.name = "GuildLeagueTeamWindow"
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
        self.Mgr:Require17615()
    end)

    self.teamInfoList = {}

    self.LeaderUpdateFun = function ()
        self:updateWindow(1)
    end
    self.Mgr.LeagueTeamChange:AddListener(self.LeaderUpdateFun)

    self.lastLookTeamIndex = 1
end

function GuildLeagueTeamWindow:OnInitCompleted()
    if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        self.selectIndex = tonumber(self.openArgs[1])
    end
    self.Mgr:Require17615()
    -- GuildfightManager.Instance:send15501()
    -- GuildfightManager.Instance:send15506()
    -- self.isNeedShowTips = false
    -- local index = self.selectIndex
    -- self.tabgroup:ChangeTab(index)
end

function GuildLeagueTeamWindow:__delete()
    -- if self.panelList[1] ~= nil then
    --     self.panelList[1]:DeleteMe()
    --     self.panelList = nil
    -- end
    self.itemDic = nil
    self.Mgr.LeagueTeamChange:RemoveListener(self.LeaderUpdateFun)
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model.gfemp = nil
    self.model = nil
end

function GuildLeagueTeamWindow:InitPanel()
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
    self.tabGroupObj:SetActive(false)
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
    self.centerText.text = string.format(TI18N("1、比赛当天可安排<color='#00ff00'>3名</color><color='#ffff00'>王牌队领队</color>，领队可在战场准备期间自由组织队员\n2、<color='#ffff00'>以比赛开始时为准，领队所在队伍</color>即为王牌队（不一定要作为队长）\n3、王牌队所有成员将获得<color='#00ff00'>双倍行动力</color>，行动力不随队伍解散或更换队伍而变化\n4、充分了解对手、做好战前准备，<color='#00ff00'>合理安排</color>王牌队可引领公会走向胜利\n"))

    self.item_1 = self.MainCon:FindChild("Item_1")
    self.image_1 = self.item_1:Find("THead/HeadImage"):GetComponent(Image)
    self.image_1.gameObject:SetActive(false)
    self.sexIcon_1 = self.item_1:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_1.gameObject:SetActive(false)
    self.nameText_1 = self.item_1:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_1 = self.item_1:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_1 = self.item_1:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_1.text = TI18N("2号王牌队伍")
    self.changeBtn_1 = self.item_1:Find("OpposeButton"):GetComponent(Button)
    self.changeBtn_1.onClick:AddListener( function() self:onClickChangeBtn(2) end)
    self.setBtn_1 = self.item_1:Find("SetButton"):GetComponent(Button)
    self.setBtn_1.onClick:AddListener( function() self:onClickSetBtn(2) end)
    self.lookBtn_1 = self.item_1:Find("LookButton"):GetComponent(Button)
    self.lookBtn_1.onClick:AddListener( function() self:onClickLookBtn(2) end)
    self.headBg_1 = self.item_1:Find("THead"):GetComponent(Button)
    self.headBg_1.onClick:AddListener( function() self:onClickSetBtn(2) end)
    self.item_1:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(2) end)

    self.item_2 = self.MainCon:FindChild("Item_2")
    self.image_2 = self.item_2:Find("THead/HeadImage"):GetComponent(Image)
    self.image_2.gameObject:SetActive(false)
    self.sexIcon_2 = self.item_2:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_2.gameObject:SetActive(false)
    self.nameText_2 = self.item_2:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_2 = self.item_2:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_2 = self.item_2:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_2.text = TI18N("1号王牌队伍")
    self.changeBtn_2 = self.item_2:Find("OpposeButton"):GetComponent(Button)
    self.changeBtn_2.onClick:AddListener( function() self:onClickChangeBtn(1) end)
    self.setBtn_2 = self.item_2:Find("SetButton"):GetComponent(Button)
    self.setBtn_2.onClick:AddListener( function() self:onClickSetBtn(1) end)
    self.lookBtn_2 = self.item_2:Find("LookButton"):GetComponent(Button)
    self.lookBtn_2.onClick:AddListener( function() self:onClickLookBtn(1) end)
    self.headBg_2 = self.item_2:Find("THead"):GetComponent(Button)
    self.headBg_2.onClick:AddListener( function() self:onClickSetBtn(1) end)
    self.item_2:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(1) end)

    self.item_3 = self.MainCon:FindChild("Item_3")
    self.image_3 = self.item_3:Find("THead/HeadImage"):GetComponent(Image)
    self.image_3.gameObject:SetActive(false)
    self.sexIcon_3 = self.item_3:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_3.gameObject:SetActive(false)
    self.nameText_3 = self.item_3:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_3 = self.item_3:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_3 = self.item_3:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_3.text = TI18N("3号王牌队伍")
    self.changeBtn_3 = self.item_3:Find("OpposeButton"):GetComponent(Button)
    self.changeBtn_3.onClick:AddListener( function() self:onClickChangeBtn(3) end)
    self.setBtn_3 = self.item_3:Find("SetButton"):GetComponent(Button)
    self.setBtn_3.onClick:AddListener( function() self:onClickSetBtn(3) end)
    self.lookBtn_3 = self.item_3:Find("LookButton"):GetComponent(Button)
    self.lookBtn_3.onClick:AddListener( function() self:onClickLookBtn(3) end)
    self.headBg_3 = self.item_3:Find("THead"):GetComponent(Button)
    self.headBg_3.onClick:AddListener( function() self:onClickSetBtn(3) end)
    self.item_3:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(3) end)

    self.transform:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("冠军联赛")
    self.transform:Find("Main/ChooseLeaderPanel/CTBgImage/TDescText"):GetComponent(Text).text = TI18N("冠军联赛")
end
function GuildLeagueTeamWindow:TabChange(index)
    -- body
    self:updateWindow(index)
end
function GuildLeagueTeamWindow:onClickCloseTeamInfoBtn()
    self.teamInfoPanel.gameObject:SetActive(false)
    self.teamInfo.gameObject:SetActive(false)
end
--更换
function GuildLeagueTeamWindow:onClickChangeBtn(index)
    self.model:OpenLeaderSetWindow(true,index)
end
--安排
function GuildLeagueTeamWindow:onClickSetBtn(index)
    if GuildManager.Instance.model.my_guild_data.MyPost < 40 then
        NoticeManager.Instance:FloatTipsByString(TI18N("你没有权限操作"))
    else
        self.model:OpenLeaderSetWindow(true,index)
    end
end
--查看
function GuildLeagueTeamWindow:onClickLookBtn(index)
    -- 发协议，查看安排的队伍信息
    self.lastLookTeamIndex = index
    local strDesc = TI18N("2号王牌队伍")
    if self.lastLookTeamIndex == 1 then
        strDesc = TI18N("1号王牌队伍")
    elseif self.lastLookTeamIndex == 3 then
        strDesc = TI18N("3号王牌队伍")
    end
    local data = self:GetPosDataByPos(index)
    if data ~= nil then
        TeamManager.Instance:Send11736(data.rid, data.platform, data.zone_id)
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>暂未安排领队"),strDesc))
    end
end
--显示队伍信息
function GuildLeagueTeamWindow:updateTeamInfo(data)
    self.teamInfoPanel.gameObject:SetActive(true)
    self.teamInfo.gameObject:SetActive(true)

    local strDesc = TI18N("2号王牌队伍")
    if self.lastLookTeamIndex == 1 then
        strDesc = TI18N("1号王牌队伍")
    elseif self.lastLookTeamIndex == 3 then
        strDesc = TI18N("3号王牌队伍")
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

function GuildLeagueTeamWindow:GetPosDataByPos(pos)
    for i,v in ipairs(self.Mgr.kingTeam) do
        if v.pos == pos then
            return v
        end
    end
    return nil
end

function GuildLeagueTeamWindow:updateWindow(index)
    if index == 1 then --安排领队界面
        self.MainCon.gameObject:SetActive(true)
        self.fightLogsPanel.gameObject:SetActive(false)
        -- if self.panelList[1] ~= nil then
        --     self.panelList[1]:Hiden()
        -- end

        self.item_1.gameObject:SetActive(true)
        self.item_2.gameObject:SetActive(true)
        self.item_3.gameObject:SetActive(true)
        local data_1 = self:GetPosDataByPos(2)
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
        data_1 = self:GetPosDataByPos(1)
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
        -- 请求战绩
        -- self.Mgr:send16206()
    end
end

function GuildLeagueTeamWindow:OnClickClose()
    self.model:CloseTeamSetWindow()
end

function GuildLeagueTeamWindow:UpdateFightLogs(dataList)
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

        if itemTaken.dataItem.match_id ~= 0 and itemTaken.dataItem.position ~= 0 then
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

function GuildLeagueTeamWindow:onClickLookButtonFightHero(index)
    local item = self.itemDic[index]
    -- self.Mgr:send16207(item.dataItem.match_id,item.dataItem.position)
end

