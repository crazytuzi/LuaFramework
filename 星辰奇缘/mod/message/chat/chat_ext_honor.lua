-- --------------------------------
-- 聊天扩展界面--称号
-- --------------------------------
ChatExtHonor = ChatExtHonor or BaseClass(ChatExtBase)

function ChatExtHonor:__init(gameObject, type, otherOption)
    self.gameObject = gameObject
    self.gameObject.name = "ChatExtHonor"

    -- 用任务id做key
    self.itemTab = { }
    self.currentPageCount = 1
    self.pageTab = { }
    self.type = type
    self.otherOption = otherOption
    self:InitPanel()
end

function ChatExtHonor:GetItem(pageTransform)
    for i = 1, 9 do
        local item = pageTransform:GetChild(i - 1)
        local tab = { }
        tab["gameObject"] = item.gameObject
        tab["transform"] = item.transform
        tab["button"] = item.gameObject:GetComponent(Button)
        tab["label"] = item.transform:Find("TxtLev"):GetComponent(Text)
        tab["img"] = item.transform:Find("Image"):GetComponent(Image)
        tab["txt"] = item.transform:Find("Image/Text"):GetComponent(Text)
        item.transform:Find("Image/Text"):GetComponent(RectTransform).sizeDelta = Vector2(45, 30)
        tab["ImgMiniIcon"] = item.transform:Find("ImgMiniIcon"):GetComponent(Image)
        table.insert(self.itemTab, tab)
        local index = #self.itemTab
        tab["button"].onClick:RemoveAllListeners()
        tab["button"].onClick:AddListener( function() self:ClickBtn(index) end)
    end
end

function ChatExtHonor:Show()
    if self.gameObject ~= nil then
        self.gameObject:SetActive(true)
    end

    local list = { }
    local count = 0
    local count1 = 1
    local count2 = 1
    local count3 = 1
    local count4 = 1
    if WorldChampionManager.Instance.model:CheckShowLev() then
        table.insert(list, { id = 1, name = TI18N("武道战绩"), special = true })
        count = count + 1
        count1 = count
    end

    if ConstellationManager.Instance:CheckProfileOpen() then
        table.insert(list, { id = 2, name = TI18N("星座驾照"), special = true })
        count = count + 1
        count2 = count
    end

    if WorldChampionManager.Instance.model:CheckShowBadge() then
        table.insert(list, { id = 3, name = TI18N("王者徽章"), special = true })
        count = count + 1
        count3 = count
    end

    if RoleManager.Instance.RoleData.lev >= 80 then
        table.insert(list, { id = 4, name = TI18N("诸神荣誉"), special = true })
        count = count + 1
        count4 = count
    end

    if self.otherOption ~= nil then
        if self.otherOption.showWorldChampionGuide then
            if self.guide == nil then
                self.guide = GuideWorldChampionShare.New(self)
            end
            self.guide:Show()
        end
        if self.otherOption.showConstellationGuide then
            if self.guide2 == nil then
                self.guide2 = GuideWorldChampionShare.New(self, count2)
            end
            self.guide2:Show()
        end
        if self.otherOption.showWorldChampionBadge  then
            if self.guide3 == nil then
                self.guide3 = GuideWorldChampionShare.New(self, count3)
            end
            self.guide3:Show()
        end

        if self.otherOption.showWorldGodsWarGuide  then
            if self.guide4 == nil then
                self.guide4 = GuideWorldChampionShare.New(self, count4)
            end
            self.guide4:Show()
        end

        -- if self.otherOption.godsWarJiFen  then
        --     if self.guide4 == nil then
        --         self.guide4 = GuideWorldChampionShare.New(self, count4)
        --     end
        --     self.guide4:Show()
        -- end
    end

    for _, v in ipairs(HonorManager.Instance.model.mine_honor_list) do
        table.insert(list, { id = v.id })
    end

    -- for _, v in pairs(AchievementManager.Instance.model.achievementList) do
    --     if v.finish ~= 0 then
    --         -- 加入完成的成就
    --         table.insert(list, { id = v.id })
    --     end
    -- end

    table.sort(list, function(a, b) return a.id < b.id end)
    self:InitPage(list, 560, 9)
    if self.mainPanel ~= nil then
        -- self.mainPanel:UpdateToggleShow(self.pageMax)
        -- self.mainPanel:UpdateToggleIndex(self.currentPageCount)
        self.mainPanel:UpdateToggleShow(0)
        -- self.mainPanel:UpdateToggleIndex(self.currentPageCount)
    end
end

function ChatExtHonor:Refresh(list)
    local count = 0
    for i, honor in ipairs(list) do
        local honorData = nil
        if honor.special then
            honorData = honor
        elseif honor.id > 100000 then
            honorData = DataAchievement.data_list[honor.id]
        else
            honorData = DataHonor.data_get_honor_list[honor.id]
        end
        if honorData ~= nil then
            count = i
            local tab = self.itemTab[i]
            local name = honorData.name
            tab["special"] = honorData.specail
            if honorData.special == true then
                -- 特殊
                tab["id"] = honorData.id
                tab["label"].text = name
                tab["match"] = string.format("%%[%s%%]", name)
                tab["append"] = string.format("[%s]", name)
                local rid = RoleManager.Instance.RoleData.id
                local platform = RoleManager.Instance.RoleData.platform
                local zone_id = RoleManager.Instance.RoleData.zone_id
                tab["send"] = string.format("{honor_3,%s,%s,%s,%s,%s}", honorData.id, rid, platform, zone_id, name)
                -- if DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id] ~= nil then
                --     name = DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id].pre_name .. "·" .. name
                -- end
                tab["gameObject"]:SetActive(true)
                if honorData.id == 1 then
                    tab["button"].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    tab["img"].gameObject:SetActive(false)
                    tab["label"].color = ColorHelper.DefaultButton3
                    tab["ImgMiniIcon"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "QulifyIcon")
                    tab["ImgMiniIcon"].gameObject:SetActive(true)
                elseif honorData.id == 3 then
                    tab["button"].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    tab["img"].gameObject:SetActive(false)
                    tab["label"].color = ColorHelper.DefaultButton3

                    -- self.assetWrapper = AssetBatchWrapper.New()
                    -- self.resList = { {file = AssetConfig.no1inworld_textures, type = AssetType.Main }}

                    -- local func = function()
                    --     if self.assetWrapper == nil then
                    --         return
                    --     end
                        tab["ImgMiniIcon"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "iconFirst")
                    --     self.assetWrapper:DeleteMe()
                    --     self.assetWrapper = nil
                    -- end
                    -- self.assetWrapper:LoadAssetBundle(self.resList, func)
                    tab["ImgMiniIcon"].gameObject:SetActive(true)
                    local badgeList = ""
                    for k,v in pairs(WorldChampionManager.Instance.model.badgeData) do
                        badgeList = badgeList.."|"..tostring(v)
                    end
                    local combinationList = ""
                    for k,v in pairs(WorldChampionManager.Instance.model.combinationData) do
                        combinationList = combinationList.."|"..tostring(v)
                    end
                    local role = RoleManager.Instance.RoleData
                    tab["send"] = string.format("{noonebadge_1,%s,%s,%s}",badgeList,combinationList,role.classes)
                elseif honorData.id == 4 then
                    tab["button"].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    tab["img"].gameObject:SetActive(false)
                    tab["label"].color = ColorHelper.DefaultButton3

                    -- self.assetWrapper = AssetBatchWrapper.New()
                    -- self.resList = { {file = AssetConfig.no1inworld_textures, type = AssetType.Main }}

                    -- local func = function()
                    --     if self.assetWrapper == nil then
                    --         return
                    --     end
                    self.imgLoader = SingleIconLoader.New(tab["ImgMiniIcon"].gameObject)
                    self.imgLoader:SetSprite(SingleIconType.Item, 90056)
                    --     self.assetWrapper:DeleteMe()
                    --     self.assetWrapper = nil
                    -- end
                    -- self.assetWrapper:LoadAssetBundle(self.resList, func)
                    tab["ImgMiniIcon"].gameObject:SetActive(true)
                    local badgeList = ""
                    for k,v in pairs(WorldChampionManager.Instance.model.badgeData) do
                        badgeList = badgeList.."|"..tostring(v)
                    end
                    local combinationList = ""
                    for k,v in pairs(WorldChampionManager.Instance.model.combinationData) do
                        combinationList = combinationList.."|"..tostring(v)
                    end
                    local role = RoleManager.Instance.RoleData
                    local message = "诸神荣誉"
                    tab["send"] = string.format("{godswar_1,%s,%s,%s,%s}",message,role.id,role.platform,role.zone_id)
                elseif honorData.id == 2 then
                    local myStart =string.format(TI18N("%s星%s"), math.max(1, ConstellationManager.Instance.currentLev), name);
                    if DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id] ~= nil then
                        name = DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id].pre_name .. "·" .. name
                    end
                    tab["send"] = string.format("{honor_5,%s,%s,%s,%s,%s}", honorData.id, rid, platform, zone_id, myStart)
                    tab["button"].image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
                    tab["img"].gameObject:SetActive(false)
                    tab["label"].color = ColorHelper.DefaultButton3

                    -- self.assetWrapper = AssetBatchWrapper.New()
                    -- self.resList = { {file = AssetConfig.dailyicon, type = AssetType.Main }}

                    -- local func = function()
                    --     if self.assetWrapper == nil then
                    --         return
                    --     end
                        tab["ImgMiniIcon"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "IconCaptin")
                    --     self.assetWrapper:DeleteMe()
                    --     self.assetWrapper = nil
                    -- end
                    -- self.assetWrapper:LoadAssetBundle(self.resList, func)
                    tab["ImgMiniIcon"].gameObject:SetActive(true)
                end
            else
                if honor.id < 100000 then
                    -- 称号
                    if honorData.type == 3 then
                        -- 公会称号带上公会名
                        if GuildManager.Instance.model.my_guild_data ~= nil then
                            name = string.format("%s%s", GuildManager.Instance.model.my_guild_data.Name, name)
                        end
                    elseif honorData.type == 6 then
                        -- 伴侣的补上对方名称
                        name = string.format(TI18N("%s的%s"), RoleManager.Instance.RoleData.lover_name, name)
                    elseif honorData.type == 7 then
                        if TeacherManager.Instance.model.myTeacherInfo.name ~= "" then
                            name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, honorData.name)
                        elseif TeacherManager.Instance.model.myTeacherInfo.status == 3 then
                            -- 师傅
                            name = honorData.name
                        elseif TeacherManager.Instance.model.myTeacherInfo.status ~= 0 then
                            -- 徒弟或者已出师
                            name = string.format("%s%s", TeacherManager.Instance.model.myTeacherInfo.name, honorData.name)
                        end
                    elseif honorData.type == 10 then
                        -- 结拜
                        if SwornManager.Instance.model.swornData ~= nil and SwornManager.Instance.model.swornData.status == SwornManager.Instance.statusEumn.Sworn then
                            name = string.format(TI18N("%s之%s%s"), SwornManager.Instance.model.swornData.name, SwornManager.Instance.model.rankList[SwornManager.Instance.model.myPos], SwornManager.Instance.model.swornData.members[SwornManager.Instance.model.myPos].name_defined)
                        end
                    end
                    tab["txt"].text = TI18N("称号")
                    tab["img"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel1")
                else
                    tab["txt"].text = TI18N("成就")
                    tab["img"].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel3")
                end
                tab["id"] = honorData.id
                tab["label"].text = name
                tab["match"] = string.format("%%[%s%%]", name)
                tab["append"] = string.format("[%s]", name)

                if DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id] ~= nil and HonorManager.Instance.model.current_honor_id == honorData.id then
                    name = DataHonor.data_get_pre_honor_list[HonorManager.Instance.model.current_pre_honor_id].pre_name .. "·" .. name
                end
                tab["send"] = string.format("{honor_2,%s,%s}", honorData.id, name)

                -- tab["send"] = string.format("{honor_1,%s}", honorData.id)
                tab["gameObject"]:SetActive(true)
            end
        end
    end
    -- 多出来的隐藏
    local allLen = #self.itemTab
    for i = count + 1, allLen do
        local tab = self.itemTab[i]
        tab["gameObject"]:SetActive(false)
    end
end

function ChatExtHonor:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end
function ChatExtHonor:ClickBtn(index)
    if ChatManager.Instance.honorCd > 0 then
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("%s秒后可以分享称号"), ChatManager.Instance.honorCd))
        return
    end
    ChatManager.Instance.honorCd = 10

    local tab = self.itemTab[index]
    if self.type == MsgEumn.ExtPanelType.Chat then
        if tab["special"] then
            ChatManager.Instance:SendMsg(ChatManager.Instance:CurrentChannel(), tab["send"])
        elseif tab["id"] < 100000 then
            ChatManager.Instance:SendMsg(ChatManager.Instance:CurrentChannel(), tab["send"])
        else
            -- 成就分享
            AchievementManager.Instance.model:ShareAchievement(MsgEumn.ExtPanelType.Chat, ChatManager.Instance:CurrentChannel(), tab["id"])
        end
    elseif self.type == MsgEumn.ExtPanelType.Friend or self.type == MsgEumn.ExtPanelType.Group then
        if tab["id"] < 100000 then
            FriendManager.Instance.model:SendQuest(tab["send"], self.type)
        else
            -- 成就分享
            if self.type == MsgEumn.ExtPanelType.Group then
                if FriendManager.Instance.model.friendWin.groupchatPanel ~= nil then
                    local targetinfo = FriendManager.Instance.model.friendWin.groupchatPanel.targetData
                    AchievementManager.Instance.model:ShareAchievement(MsgEumn.ExtPanelType.Group, targetinfo, tab["id"])
                end
            else
                AchievementManager.Instance.model:ShareAchievement(MsgEumn.ExtPanelType.Friend, FriendManager.Instance.model.chatTargetInfo, tab["id"])
            end
        end
    end
end