-- 公会英雄战，战斗状态、观战面板
-- @author zgs
GuildfightEliteLookWindow = GuildfightEliteLookWindow or BaseClass(BaseWindow)

function GuildfightEliteLookWindow:__init(model)
    self.model = model
    self.name = "GuildfightEliteLookWindow"
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.selectIndex = 1
    self.itemDic = {}

    self.resList = {
        {file = AssetConfig.guild_fight_elite_look_window, type = AssetType.Main}
        ,{file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        ,{file = AssetConfig.heads, type = AssetType.Dep},
    }
    self.isNeedShowTips = false
    self.OnOpenEvent:AddListener(function()
        -- GuildfightManager.Instance:send15501()
        -- GuildfightManager.Instance:send15506()
        -- self.isNeedShowTips = false
        -- -- local index = self.selectIndex
        -- if self.openArgs ~= nil and self.openArgs[1] ~= nil then
        --     self.selectIndex = tonumber(self.openArgs[1])
        -- end
        -- -- self.tabgroup:ChangeTab(index)
        GuildFightEliteManager.Instance:send16201()
        -- self:updateWindow()
    end)

    -- self.panelList = {}

    self.guildfightDataUpdateFun = function ()
        self:updateWindow()
    end
    EventMgr.Instance:AddListener(event_name.guild_elite_war_match_info_change, self.guildfightDataUpdateFun)

    self.guildfightEliteLeaderUpdateFun = function ()
        self:updateWindow()
    end
    EventMgr.Instance:AddListener(event_name.guildfight_elite_leaderinfo_change, self.guildfightEliteLeaderUpdateFun)

    self.lastLookTeamIndex = 1

end

function GuildfightEliteLookWindow:OnInitCompleted()
    -- if self.openArgs ~= nil and self.openArgs[1] ~= nil then
    --     self.selectIndex = tonumber(self.openArgs[1])
    -- end
    GuildFightEliteManager.Instance:send16201()
    -- GuildfightManager.Instance:send15501()
    -- GuildfightManager.Instance:send15506()
    -- self.isNeedShowTips = false
    -- local index = self.selectIndex
    -- self.tabgroup:ChangeTab(index)
    -- self:updateWindow()
end

function GuildfightEliteLookWindow:__delete()
    -- if self.panelList[1] ~= nil then
    --     self.panelList[1]:DeleteMe()
    --     self.panelList = nil
    -- end
    self.itemDic = nil
    EventMgr.Instance:RemoveListener(event_name.guild_elite_war_match_info_change, self.guildfightDataUpdateFun)
    EventMgr.Instance:RemoveListener(event_name.guildfight_elite_leaderinfo_change, self.guildfightEliteLeaderUpdateFun)
    self.OnOpenEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    GuildFightEliteManager.Instance.model.elw = nil
    self.model = nil
end

function GuildfightEliteLookWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_elite_look_window))
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function()
        self:OnClickClose()
    end)

    self.Main = self.transform:Find("Main")

    self.MainCon = self.Main:Find("ChooseLeaderPanel")

    self.centerText = self.MainCon:Find("CCText_1"):GetComponent(Text)
    -- self.centerText.lineSpacing = 1.1
    self.centerText.text = string.format(TI18N("激烈的<color='#2fc823'>[公会英雄]</color>赛事正在进行，可选择以下代表队进行观战\n（可通过<color='#ffff00'>[活动面板]</color>再次选择观战目标）"))

    self.item_1 = self.MainCon:FindChild("Item_1")
    self.item_1:Find("THead/BgImage").gameObject:SetActive(false)
    self.image_1 = self.item_1:Find("THead/HeadImage"):GetComponent(Image)
    self.image_1.gameObject:SetActive(false)
    self.sexIcon_1 = self.item_1:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_1.gameObject:SetActive(false)
    self.nameText_1 = self.item_1:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_1 = self.item_1:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_1 = self.item_1:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_1.text = TI18N("月亮代表队")
    self.resultBtn_1 = self.item_1:Find("ResultButton"):GetComponent(Button)
    self.resultBtn_1.onClick:AddListener( function() self:onClickChangeBtn(1) end)
    self.resultTxt_1 = self.item_1:FindChild("ResultButton/Text"):GetComponent(Text)
    self.notStartBtn_1 = self.item_1:Find("NoStartButton"):GetComponent(Button)
    self.notStartBtn_1.onClick:AddListener( function() self:onClickSetBtn(1) end)
    self.lookBtn_1 = self.item_1:Find("LookButton"):GetComponent(Button)
    self.lookBtn_1.onClick:AddListener( function() self:onClickLookBtn(1) end)
    -- self.headBg_1 = self.item_1:Find("THead"):GetComponent(Button)
    -- self.headBg_1.onClick:AddListener( function() self:onClickSetBtn(1) end)
    -- self.item_1:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(1) end)

    self.item_2 = self.MainCon:FindChild("Item_2")
    self.item_2:Find("THead/BgImage").gameObject:SetActive(false)
    self.image_2 = self.item_2:Find("THead/HeadImage"):GetComponent(Image)
    self.image_2.gameObject:SetActive(false)
    self.sexIcon_2 = self.item_2:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_2.gameObject:SetActive(false)
    self.nameText_2 = self.item_2:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_2 = self.item_2:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_2 = self.item_2:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_2.text = TI18N("太阳代表队")
    self.resultBtn_2 = self.item_2:Find("ResultButton"):GetComponent(Button)
    self.resultBtn_2.onClick:AddListener( function() self:onClickChangeBtn(2) end)
    self.resultTxt_2 = self.item_2:FindChild("ResultButton/Text"):GetComponent(Text)
    self.notStartBtn_2 = self.item_2:Find("NoStartButton"):GetComponent(Button)
    self.notStartBtn_2.onClick:AddListener( function() self:onClickSetBtn(2) end)
    self.lookBtn_2 = self.item_2:Find("LookButton"):GetComponent(Button)
    self.lookBtn_2.onClick:AddListener( function() self:onClickLookBtn(2) end)
    -- self.headBg_2 = self.item_2:Find("THead"):GetComponent(Button)
    -- self.headBg_2.onClick:AddListener( function() self:onClickSetBtn(2) end)
    -- self.item_2:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(2) end)

    self.item_3 = self.MainCon:FindChild("Item_3")
    self.item_3:Find("THead/BgImage").gameObject:SetActive(false)
    self.image_3 = self.item_3:Find("THead/HeadImage"):GetComponent(Image)
    self.image_3.gameObject:SetActive(false)
    self.sexIcon_3 = self.item_3:Find("THead/SexIcon"):GetComponent(Image)
    self.sexIcon_3.gameObject:SetActive(false)
    self.nameText_3 = self.item_3:FindChild("THead/NameText"):GetComponent(Text)
    self.classText_3 = self.item_3:FindChild("THead/ClassText"):GetComponent(Text)
    self.titleDescText_3 = self.item_3:FindChild("Tobj/TeamDescText"):GetComponent(Text)
    self.titleDescText_3.text = TI18N("星辰代表队")
    self.resultBtn_3 = self.item_3:Find("ResultButton"):GetComponent(Button)
    self.resultBtn_3.onClick:AddListener( function() self:onClickChangeBtn(3) end)
    self.resultTxt_3 = self.item_3:FindChild("ResultButton/Text"):GetComponent(Text)
    self.notStartBtn_3 = self.item_3:Find("NoStartButton"):GetComponent(Button)
    self.notStartBtn_3.onClick:AddListener( function() self:onClickSetBtn(3) end)
    self.lookBtn_3 = self.item_3:Find("LookButton"):GetComponent(Button)
    self.lookBtn_3.onClick:AddListener( function() self:onClickLookBtn(3) end)
    -- self.headBg_3 = self.item_3:Find("THead"):GetComponent(Button)
    -- self.headBg_3.onClick:AddListener( function() self:onClickSetBtn(3) end)
    -- self.item_3:GetComponent(Button).onClick:AddListener( function() self:onClickSetBtn(3) end)
end
--已结束
function GuildfightEliteLookWindow:onClickChangeBtn(index)
    -- self.model:ShowEliteMemberPanel(true,index)
    self.lastLookTeamIndex = index
    local strDesc = TI18N("太阳代表队")
    if self.lastLookTeamIndex == 1 then
        strDesc = TI18N("月亮代表队")
    elseif self.lastLookTeamIndex == 3 then
        strDesc = TI18N("星辰代表队")
    end
    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>当前没有战斗，请稍候"),strDesc))
end
--未开始
function GuildfightEliteLookWindow:onClickSetBtn(index)
    self.lastLookTeamIndex = index
    local strDesc = TI18N("太阳代表队")
    if self.lastLookTeamIndex == 1 then
        strDesc = TI18N("月亮代表队")
    elseif self.lastLookTeamIndex == 3 then
        strDesc = TI18N("星辰代表队")
    end
    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("<color='#ffff00'>%s</color>当前没有战斗，请稍候"),strDesc))
    -- self.model:ShowEliteMemberPanel(true,index)
end
--查看
function GuildfightEliteLookWindow:onClickLookBtn(index)
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
        CombatManager.Instance:Send10705(data.rid, data.platform, data.zone_id)
        self:OnClickClose()
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("开始观看<color='#ffff00'>%s</color>的战斗"),strDesc))
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("请求<color='#ffff00'>%s</color>观战失败"),strDesc))
    end
end
--显示队伍信息
function GuildfightEliteLookWindow:updateTeamInfo(data)
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

function GuildfightEliteLookWindow:GetPosDataByPos(pos)
    for i,v in ipairs(GuildFightEliteManager.Instance.eliteLeaderInfo) do
        if v.position == pos then
            return v
        end
    end
    return nil
end

function GuildfightEliteLookWindow:updateWindow()
    -- if self.panelList[1] ~= nil then
    --     self.panelList[1]:Hiden()
    -- end

    self.item_1.gameObject:SetActive(true)
    self.item_2.gameObject:SetActive(true)
    self.item_3.gameObject:SetActive(true)
    local data_1 = self:GetPosDataByPos(1)
    if data_1 ~= nil then

        self.image_1.gameObject:SetActive(true)
        self.image_1.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
        self.sexIcon_1.gameObject:SetActive(true)
        self.sexIcon_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
        -- self.classIcon_1.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
        self.nameText_1.text = data_1.name
        self.classText_1.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])

        local fightDataItem = self:GetFightDataInfo(data_1)
        -- local uniqueid = BaseUtils.get_unique_roleid(data_1.rid, data_1.zone_id, data_1.platform)
        -- -- print(uniqueid)
        -- local captinSceneData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(uniqueid)
        -- -- BaseUtils.dump(captinSceneData,"------------")
        -- if captinSceneData ~= nil and captinSceneData.status == 2 then
        if fightDataItem ~= nil and fightDataItem.is_fighting == 1 then
            --战斗中
            self.lookBtn_1.gameObject:SetActive(true)
            self.notStartBtn_1.gameObject:SetActive(false)
            self.resultBtn_1.gameObject:SetActive(false)
        else
            if fightDataItem ~= nil then
                if fightDataItem.is_win == 1 then
                    self.lookBtn_1.gameObject:SetActive(false)
                    self.notStartBtn_1.gameObject:SetActive(false)
                    self.resultBtn_1.gameObject:SetActive(true)
                    self.resultTxt_1.text = TI18N("已获胜")
                elseif fightDataItem.is_win == 2 then
                    self.lookBtn_1.gameObject:SetActive(false)
                    self.notStartBtn_1.gameObject:SetActive(false)
                    self.resultBtn_1.gameObject:SetActive(true)
                    self.resultTxt_1.text = TI18N("已战败")
                else
                    self.lookBtn_1.gameObject:SetActive(false)
                    self.notStartBtn_1.gameObject:SetActive(true)
                    self.resultBtn_1.gameObject:SetActive(false)
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("数据出错，对战信息中，没有当前领队的信息") .. data_1.name)
            end
        end
    else
        self.nameText_1.text = TI18N("暂未安排")
        self.classText_1.text = string.format(TI18N("？？级 暂无"))
        self.image_1.gameObject:SetActive(false)
        self.sexIcon_1.gameObject:SetActive(false)

        self.lookBtn_1.gameObject:SetActive(false)
        self.notStartBtn_1.gameObject:SetActive(true)
        self.resultBtn_1.gameObject:SetActive(false)
    end
    data_1 = self:GetPosDataByPos(2)
    if data_1 ~= nil then
        self.image_2.gameObject:SetActive(true)
        self.image_2.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
        self.sexIcon_2.gameObject:SetActive(true)
        self.sexIcon_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
        -- self.classIcon_2.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
        self.nameText_2.text = data_1.name
        self.classText_2.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])

        local fightDataItem = self:GetFightDataInfo(data_1)
        -- local uniqueid = BaseUtils.get_unique_roleid(data_1.rid, data_1.zone_id, data_1.platform)
        -- local captinSceneData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(uniqueid)
        -- if captinSceneData ~= nil and captinSceneData.status == 2 then
        if fightDataItem ~= nil and fightDataItem.is_fighting == 1 then
            --战斗中
            self.lookBtn_2.gameObject:SetActive(true)
            self.notStartBtn_2.gameObject:SetActive(false)
            self.resultBtn_2.gameObject:SetActive(false)
        else
            if fightDataItem ~= nil then
                if fightDataItem.is_win == 1 then
                    self.lookBtn_2.gameObject:SetActive(false)
                    self.notStartBtn_2.gameObject:SetActive(false)
                    self.resultBtn_2.gameObject:SetActive(true)
                    self.resultTxt_2.text = TI18N("已获胜")
                elseif fightDataItem.is_win == 2 then
                    self.lookBtn_2.gameObject:SetActive(false)
                    self.notStartBtn_2.gameObject:SetActive(false)
                    self.resultBtn_2.gameObject:SetActive(true)
                    self.resultTxt_2.text = TI18N("已战败")
                else
                    self.lookBtn_2.gameObject:SetActive(false)
                    self.notStartBtn_2.gameObject:SetActive(true)
                    self.resultBtn_2.gameObject:SetActive(false)
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("数据出错，对战信息中，没有当前领队的信息") .. data_1.name)
            end
        end
    else
        self.nameText_2.text = TI18N("暂未安排")
        self.classText_2.text = string.format(TI18N("？？级 暂无"))
        self.image_2.gameObject:SetActive(false)
        self.sexIcon_2.gameObject:SetActive(false)

        self.notStartBtn_2.gameObject:SetActive(true)
        self.resultBtn_2.gameObject:SetActive(false)
        self.lookBtn_2.gameObject:SetActive(false)
        -- self.item_2.gameObject:SetActive(false)
    end
    data_1 = self:GetPosDataByPos(3)
    if data_1 ~= nil then
        self.image_3.gameObject:SetActive(true)
        self.image_3.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_%s", data_1.classes, data_1.sex))
        self.sexIcon_3.gameObject:SetActive(true)
        self.sexIcon_3.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, (data_1.sex == 0 and "IconSex0" or "IconSex1"))
        -- self.classIcon_3.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data_1.classes))
        self.nameText_3.text = data_1.name
        self.classText_3.text = string.format(TI18N("%d级 %s"),data_1.lev,KvData.classes_name[data_1.classes])

        local fightDataItem = self:GetFightDataInfo(data_1)
        -- local uniqueid = BaseUtils.get_unique_roleid(data_1.rid, data_1.zone_id, data_1.platform)
        -- local captinSceneData = SceneManager.Instance.sceneElementsModel:GetSceneData_OneRole(uniqueid)
        -- if captinSceneData ~= nil and captinSceneData.status == 2 then
        if fightDataItem ~= nil and fightDataItem.is_fighting == 1 then
            --战斗中
            self.lookBtn_3.gameObject:SetActive(true)
            self.notStartBtn_3.gameObject:SetActive(false)
            self.resultBtn_3.gameObject:SetActive(false)
        else
            if fightDataItem ~= nil then
                if fightDataItem.is_win == 1 then
                    self.lookBtn_3.gameObject:SetActive(false)
                    self.notStartBtn_3.gameObject:SetActive(false)
                    self.resultBtn_3.gameObject:SetActive(true)
                    self.resultTxt_3.text = TI18N("已获胜")
                elseif fightDataItem.is_win == 2 then
                    self.lookBtn_3.gameObject:SetActive(false)
                    self.notStartBtn_3.gameObject:SetActive(false)
                    self.resultBtn_3.gameObject:SetActive(true)
                    self.resultTxt_3.text = TI18N("已战败")
                else
                    self.lookBtn_3.gameObject:SetActive(false)
                    self.notStartBtn_3.gameObject:SetActive(true)
                    self.resultBtn_3.gameObject:SetActive(false)
                end
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("数据出错，对战信息中，没有当前领队的信息") .. data_1.name)
            end
        end
    else
        self.nameText_3.text = TI18N("暂未安排")
        self.classText_3.text = string.format(TI18N("？？级 暂无"))
        self.image_3.gameObject:SetActive(false)
        self.sexIcon_3.gameObject:SetActive(false)

        self.notStartBtn_3.gameObject:SetActive(true)
        self.resultBtn_3.gameObject:SetActive(false)
        self.lookBtn_3.gameObject:SetActive(false)
        -- self.item_3.gameObject:SetActive(false)
    end
end

function GuildfightEliteLookWindow:OnClickClose()
    GuildFightEliteManager.Instance.model:ShowEliteLookWindow(false)
end

function GuildfightEliteLookWindow:GetFightDataInfo(data)
    local guildMatchInfo = GuildFightEliteManager.Instance.guildEliteWarMatch
    if guildMatchInfo ~= nil then
        for i,v in ipairs(guildMatchInfo.leaders) do
            if v.rid == data.rid and v.platform == data.platform and v.zone_id == data.zone_id then
                return v
            end
        end
    end
    return nil
end

