-- -----------------------
-- 基础的信息项
-- hosr
-- -----------------------
MsgItem = MsgItem or BaseClass()

function MsgItem:__init()
    self.imgTab = {}
    self.btnTab = {}
    self.faceTab = {}

    self.imgTempTab = {}
    self.btnTempTab = {}
    self.faceTempTab = {}

    self.isReuse = false
    self.wholeOffsetX = 0
    self.wholeOffsetChar = 0
    self.selfWidth = 0
    self.selfHeight = 0
    self.fontSize = 17
    self.staticFontSize = 19
    self.lineSpace = 0
    self.lastCharPos = Vector2.zero -- 最后一个字符的位置并且加上自己的宽度
    self.lineCount = 0
    self.isChatMiniItem = false
    self.isSceneFace = false -- 是否是场景表情

    self.loaders = {}
end

function MsgItem:__delete()
    self:ReleaseIconLoader()

    if self.loaders ~= nil then
        for _,v in pairs(self.loaders) do
            v:DeleteMe()
        end
        self.loaders = nil
    end

    if self.imgTab ~= nil then
        for i,v in ipairs(self.imgTab) do
            GameObject.DestroyImmediate(v.gameObject)
        end
        self.imgTab = nil
    end

    if self.btnTab ~= nil then
        for i,v in ipairs(self.btnTab) do
            GameObject.DestroyImmediate(v.gameObject)
        end
        self.btnTab = nil
    end

    if self.faceTab ~= nil then
        for i,v in ipairs(self.faceTab) do
            v:DeleteMe()
        end
        self.faceTab = nil
    end

    self.imgTab = nil
    self.btnTab = nil
    self.faceTab = nil

    if self.imgTempTab ~= nil then
        for i,v in ipairs(self.imgTempTab) do
            GameObject.DestroyImmediate(v.gameObject)
        end
        self.imgTempTab = nil
    end

    if self.btnTempTab ~= nil then
        for i,v in ipairs(self.btnTempTab) do
            GameObject.DestroyImmediate(v.gameObject)
        end
        self.btnTempTab = nil
    end

    if self.faceTempTab ~= nil then
        for i,v in ipairs(self.faceTempTab) do
            v:DeleteMe()
        end
        self.faceTempTab = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

    self.rect = nil
    self.wholeOffsetX = nil
    self.wholeOffsetChar = nil
    self.selfWidth = nil
    self.selfHeight = nil
    self.fontSize = nil
    self.lineSpace = nil
    self.isReuse = nil
    self.msgData = nil
    self.data = nil
    self.needDelete = nil
    self.txtMaxWidth = nil
end

function MsgItem:ReleaseIconLoader()
    if self.loaders ~= nil then
        for k,v in pairs(self.loaders) do
            v:DeleteMe()
        end
    end
    self.loaders = nil
    self.loaders = {}
end

-- 外部重写
function MsgItem:InitPanel()
end

function MsgItem:Reset()
    self:ReleaseIconLoader()

    self.needDelete = false
    self.posxDic = {}
    self.posyDic = {}
    self.wholeOffsetChar = 0
    if self.data ~= nil and self.data.showType == MsgEumn.ChatShowType.Voice then
        ChatManager.Instance.model:DelAudioClip(self.data.cacheId, self.data.platform, self.data.zone_id)
    end
    self:HideImg()
    if self.rect ~= nil then
        self:AnchorTop()
    end
end

function MsgItem:HideImg()
    for i,v in ipairs(self.imgTempTab) do
        v:SetActive(false)
        table.insert(self.imgTab, v)
    end
    for i,v in ipairs(self.btnTempTab) do
        v.gameObject:SetActive(false)
        table.insert(self.btnTab, v)
    end
    for i,v in ipairs(self.faceTempTab) do
        v:DeleteMe()
        v = nil
    end
    self.imgTempTab = {}
    self.btnTempTab = {}
    self.faceTempTab = {}
    self.faceTab = {}
end

-- 外部重写
function MsgItem:Layout()
end

-- -------------------------------------------------------------------------------------------
-- 新增的时候，锚点在左下方，这样可以利用锚点的特性，保持所有元素不变，和左下角一起往下移
-- 省下每个都更新位置的操作，只是把容器拉大就行了
function MsgItem:AnchorBottom(y)
    -- print("AnchorBottom")
    -- self.rect.pivot = Vector2(0, 0)
    self.rect.anchorMax = Vector2.zero
    self.rect.anchorMin = Vector2.zero
    self.rect.anchoredPosition = Vector3(0, y, 0)
end

-- 需要复用某一个元素时，要把最底的元素复用到最上，然后往上拉大容器,并从底减少容器高度
-- 在减少容器高度时，元素锚点要设成左上角，保持元素位置不变
function MsgItem:AnchorTop()
    -- print("AnchorTop")
    -- 调用这个的时候，有两个情况
    -- 新增和重用
    -- 不管那种，都是新的消息放到最上面
    -- 设完后把容器拉大就好了
    self.rect.pivot = Vector2(0, 1)
    self.rect.anchorMax = Vector2(0, 1)
    self.rect.anchorMin = Vector2(0, 1)
    self.rect.anchoredPosition = Vector3.zero
end

function MsgItem:GetMsgData(msg)
    -- 只要是用图文混排，都要用标签, 很多配置的颜色字段都用color了，这里这个兼容。。。。
    -- hosr 20160615
    msg = string.gsub(msg, "<color='(.-)'>(.-)</color>", "{string_2,%1,%2}")
    msg = string.gsub(msg, " ", "　")
    return MessageParser.OneMethod(msg)
end

-- ---------------------------------
-- 处理元素
-- ---------------------------------
function MsgItem:ShowElements(elements)
    self:HideImg()
    for i,msg in ipairs(elements) do
        local func = function()
            local btn = self:GetButton()
            local rect = btn.gameObject:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(msg.width, self.lineSpace)
            rect.anchoredPosition = Vector2(self.posxDic[i], self.posyDic[i])
            btn.onClick:RemoveAllListeners()
            btn.gameObject:SetActive(true)
            table.insert(self.btnTempTab, btn)
            return btn
        end
        if msg.assetId ~= 0 then
            local img = self:GetImage()
            local id = img:GetInstanceID()
            local imgLoader = self.loaders[id]
            if imgLoader == nil then
                imgLoader = SingleIconLoader.New(img)
                self.loaders[id] = imgLoader
            end
            if GlobalEumn.CostTypeIconName[msg.assetId] == nil then
                if DataItem.data_get[tonumber(msg.assetId)] ~= nil then
                    imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[tonumber(msg.assetId)].icon)
                end
            else
                imgLoader:SetOtherSprite(PreloadManager.Instance:GetSprite(AssetConfig.base_textures, GlobalEumn.CostTypeIconName[msg.assetId]))
            end
            local rect = img:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(28, 28)
            rect.anchoredPosition = Vector2(self.posxDic[i], self.posyDic[i])
            img:SetActive(true)
            table.insert(self.imgTempTab, img)
        elseif msg.showSprite == true and self.smallSprite ~= nil then
            local img = self:GetImage()
            local id = img:GetInstanceID()
            local imgLoader = self.loaders[id]
            if imgLoader == nil then
                imgLoader = SingleIconLoader.New(img)
                self.loaders[id] = imgLoader
            end
            imgLoader:SetOtherSprite(self.smallSprite)
            local rect = img:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(msg.imgWidth, msg.imgHeight)
            rect.anchoredPosition = Vector2(self.posxDic[i], self.posyDic[i] + 3)
            img:SetActive(true)
            table.insert(self.imgTempTab, img)
        elseif msg.matchId ~= nil and msg.matchId ~= 0 then
            -- 没处理
        elseif msg.prefix1 ~= nil and msg.prefix1 ~= "" then
            local btn = func()
            local itemData = {rid = msg.rid, platform = msg.platform, zone_id = msg.zoneId, name = msg.content, lev = 0}
            btn.onClick:AddListener(function() TipsManager.Instance:ShowPlayer(itemData) end)
        elseif msg.singId ~= 0 then
            local btn = func()
            btn.onClick:AddListener(function()
                if msg.rid == RoleManager.Instance.RoleData.id and msg.platform == RoleManager.Instance.RoleData.platform and msg.zoneId == RoleManager.Instance.RoleData.zone_id then
                    -- 自己的不用请求
                    SingManager.Instance.model:OpenAdvert()
                else
                    SingManager.Instance:Send16808(msg.rid, msg.platform, msg.zoneId)
                end
            end)
        elseif msg.talismancacheId ~= nil then
            local btn = func()
            btn.onClick:AddListener(function()
                ChatManager.Instance:Send10427(msg.talismancacheId, msg.platform, msg.zoneId)
            end)
        elseif msg.tid ~= nil then
            local btn = func()
            btn.onClick:AddListener(function()
                WorldChampionManager.Instance:Require16424(msg.tid, msg.tplatform, msg.tzone_id)
            end)
        elseif msg.itemId ~= 0 then
            local btn = func()
            local itemData = DataItem.data_get[msg.itemId]
            if itemData ~= nil then
                if msg.cacheId ~= 0 then
                    if BackpackManager.Instance:IsEquip(itemData.type) then
                        btn.onClick:AddListener(function() ChatManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Equip, msg, self.data) end)
                    else
                        btn.onClick:AddListener(function() ChatManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Item, msg, self.data) end)
                    end
                else
                    local baseData = ItemData.New()
                    baseData:SetBase(itemData)
                    btn.onClick:AddListener(function() TipsManager.Instance:ShowAllItemTips({gameObject = btn.gameObject, itemData = baseData, extra = {nobutton = true}}) end)
                end
            end
        elseif msg.questId ~= 0 then
            local btn = func()
            local questData = DataQuest.data_get[msg.questId]
            if questData ~= nil then
                local itemData = {
                    string.format("<color='%s'>[%s]%s</color>", QuestEumn.ColorName(questData.sec_type), QuestEumn.TypeName[questData.sec_type], questData.name)
                }
                btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = btn.gameObject, itemData = itemData}) end)
            end
        elseif msg.petId ~= 0 then
            local btn = func()
            if msg.cacheId ~= 0 then
                btn.onClick:AddListener(function() ChatManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Pet, msg, self.data) end)
            end
        elseif msg.childId ~= 0 then
            local btn = func()
            if msg.cacheId ~= 0 then
                btn.onClick:AddListener(function() ChatManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Child, msg, self.data) end)
            end
        elseif msg.guardId ~= 0 then
            local btn = func()
            if msg.cacheId ~= 0 then
                btn.onClick:AddListener(function() ChatManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Guard, msg, self.data) end)
            end
        elseif msg.homeTag ~= nil then
            local btn = func()
            btn.onClick:AddListener(function() HomeManager.Instance:Send11233(msg.rid, msg.platform, msg.zoneId) end)
        elseif msg.godWarRid ~= nil then
            print("666666666666111")
            local btn = func()
            local itemData = {rid = msg.godWarRid, platform = msg.godWarPlatform, zone_id = msg.godWarZoneId, name = msg.content, lev = 0}
            btn.onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.godswarshowwin,itemData) end)
        elseif msg.rid ~= 0 then
            local btn = func()
            local itemData = {rid = msg.rid, platform = msg.platform, zone_id = msg.zoneId, name = msg.content, lev = 0}
            btn.onClick:AddListener(function() TipsManager.Instance:ShowPlayer(itemData) end)
        elseif msg.panelId ~= 0 then
            local btn = func()
            btn.onClick:AddListener(function()
                if msg.levlimit ~=nil and RoleManager.Instance.RoleData.lev < msg.levlimit then
                    NoticeManager.Instance:FloatTipsByString(string.format(TI18N("到达%s级开启哦"), tostring(msg.levlimit)))
                    return
                end
                WindowManager.Instance:OpenWindowById(msg.panelId, msg.args)
            end)
        elseif msg.badgeList ~= 0 and msg.badgeList ~= nil then
            local btn = func()
            btn.onClick:AddListener(function()
                WorldChampionManager.Instance.model:OpenBadgeLookWindow({[1]=msg.args[1],[2]=msg.args[2],[3]=msg.args[3]})
            end)
        elseif msg.guildpray_1 ~= nil then
            local btn = func()
            btn.onClick:AddListener(function()
                GuildManager.Instance:FindSpecialUnit()
            end)
        elseif msg.faceId ~= 0 and msg.faceId ~= nil then
            -- 表情处理
                local imgBackGround = self.contentTrans.parent.transform:GetComponent(Image)
                if DataChatFace.data_new_face[msg.faceId] ~= nil and DataChatFace.data_new_face[msg.faceId].type == FaceEumn.FaceType.Big and self.contentTrans.parent.gameObject.name == "MessageBackground" then
                    if imgBackGround ~= nil then
                        imgBackGround.color = Color(1,1,1,0)
                    end
                end


            local face = self:GetFaceItem()
            face:Show(msg.faceId, Vector2(self.posxDic[i], self.posyDic[i]), self.isSceneFace)
            if msg.faceId >= 1000 then
                if msg.noRoll then
                    face:JustShowResult(msg.randomVal)
                else
                    face:ShowRandom(msg.randomVal)
                end
                msg.noRoll = true
            end
            table.insert(self.faceTempTab, face)

        elseif msg.linkUrl ~= "" then
            local btn = func()
            btn.onClick:AddListener(function() Application.OpenURL(msg.linkUrl) end)
        elseif msg.honorId ~= 0 then
            local btn = func()

            local honorData = nil
            if msg.honorId > 100000 then
                honorData = DataAchievement.data_list[msg.honorId]
            else
                honorData = DataHonor.data_get_honor_list[msg.honorId]
            end

            if honorData ~= nil then
                local itemData = {}
                local name = string.gsub(msg.content, "<.->", "")
                table.insert(itemData, string.format("<color='#ffff00'>%s</color>", name))
                local desc = honorData.desc
                if desc == "" then
                    desc = honorData.cond_desc
                end
                table.insert(itemData, desc)
                btn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = btn.gameObject, itemData = itemData}) end)
            end
        elseif msg.unitId ~= 0 and not msg.isFlower and not msg.isUnitBtn then
            -- 寻路单位
            local btn = func()
            btn.onClick:AddListener(
                function()
                    if msg.battleId == 14 then
                        GuildManager.Instance.model:GoToGuildAreaForWaterFlower(msg)
                    else
                        local key = BaseUtils.get_unique_npcid(msg.unitId, msg.battleId)
                        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)
                    end
                end)
        elseif msg.achievement_id ~= 0 then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    AchievementManager.Instance.model:OpenAchievementTips({msg})
                end)
        elseif msg.rec_id ~= nil and msg.rec_id ~= 0 then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    CombatManager.Instance:Send10753(msg.rec_type, msg.rec_id, msg.rec_platform, msg.rec_zoneId)
                end
            )
        elseif msg.watch_id ~= nil and msg.watch_id ~= 0 then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    CombatManager.Instance:Send10705(msg.watch_id, msg.watch_platform, msg.watch_zoneId)
                end
            )
        elseif msg.wing_id ~= nil then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    ChatManager.Instance:Send10417(msg.wing_platform, msg.wing_zoneid, msg.wing_id, msg.wing_classes, msg.owner)
                end
            )
        elseif msg.sound_id ~= nil then
            SoundManager.Instance:PlayCombatChat(msg.sound_id)
        elseif msg.strategy_id ~= nil then
            local btn = func()
            btn.onClick:AddListener(function()
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.strategy_window, {2, 99, msg.strategy_id})
            end)
        elseif msg.rideId ~= nil then
            local btn = func()
            if msg.cacheId ~= 0 then
                btn.onClick:AddListener(function() ChatManager.Instance:ShowCacheData(btn.gameObject, MsgEumn.CacheType.Ride, msg, self.data) end)
            end
        elseif msg.marriagecertificate_id ~= nil and msg.marriagecertificate_id ~= 0 then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    MarryManager.Instance:Send15029(msg.marriagecertificate_id, msg.marriagecertificate_platform, msg.marriagecertificate_zoneId)
                    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marriage_certificate_window)
                end)
        elseif msg.magpiefestival_id ~= nil and msg.magpiefestival_id ~= 0 then
            local data = {rid = msg.magpiefestival_id,platform = msg.magpiefestival_platform,zone_id = msg.magpiefestival_zoneId}
            local btn = func()
            btn.onClick:AddListener(
                function()
                    QiXiLoveManager.Instance.model:ApplyLoveMatch(data)
                    if FriendManager.Instance:IsFriend(data.rid, data.platform, data.zone_id) == false then
                        FriendManager.Instance:AddFriend(data.rid, data.platform, data.zone_id)
                    end
                    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.marriage_certificate_window)
                end)
        elseif msg.bargain_id ~= nil and msg.bargain_id ~= 0 then
            local data = {rid = msg.bargain_id,platform = msg.bargain_platform,zone_id = msg.bargain_zoneId,name = msg.bargain_name,campId = msg.campId}
            local btn = func()
            btn.onClick:AddListener(
                function()
                    if RoleManager.Instance.RoleData.id == msg.bargain_id and RoleManager.Instance.RoleData.platform == msg.bargain_platform and RoleManager.Instance.RoleData.zone_id == msg.bargain_zoneId then
                        NoticeManager.Instance:FloatTipsByString("快去呼朋唤友来砍价吧！让人意向不到的优惠折扣在等着你哟~{face_1,54}")
                    else
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.campaign_autumn_help_window,data)
                    end
                end
            )
        elseif msg.fation_selection_fashionId ~= nil and msg.fation_selection_fashionId ~= 0 then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    if RoleManager.Instance.RoleData.id == msg.fation_selection_Id and RoleManager.Instance.RoleData.platform == msg.fation_selection_platform and RoleManager.Instance.RoleData.zone_id == msg.fation_selection_zoneId then
                        NoticeManager.Instance:FloatTipsByString("快去呼朋唤友来为您心仪的时装投票吧！{face_1,18}")
                    else

                        local data ={[1] = msg.fation_selection_fashionId,[2] = msg.fation_selection_roleClasses,[3]= msg.fation_selection_sex,[4] = msg.fation_selection_weapModel,[5] = msg.fation_selection_weapVal,[6] = msg.fation_selection_Id,[7] = msg.fation_selection_platform,[8] = msg.fation_selection_zoneId,[9] = msg.fation_selection_name,[10] = msg.fation_selection_lev}
                        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.fashion_help_window,data)
                    end
                end
            )
        elseif msg.guardWakeup ~= nil then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    ShouhuManager.Instance.model:OpenShouhuWakeUpAttrTipsUI(msg)
                end
            )
        elseif msg.dianhuaBadge ~= nil then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    EquipStrengthManager.Instance.model:OpenEquipDianhuaShareUI(msg)
                end
            )
        elseif msg.cross_arena_room_id ~= nil then
            local btn = func()
            btn.onClick:AddListener(function()
                CrossArenaManager.Instance.model:AcceptInvitationByMessage(msg.cross_arena_room_id, msg.cross_arena_room_password, msg.cross_arena_msg_type, msg.cross_arena_room_rid, msg.cross_arena_room_platform, msg.cross_arena_room_zone_id)
            end)
        elseif msg.cmd ~= nil then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    local data = {}
                    data.id =  msg.arg1
                    data.platform = msg.arg2
                    data.zone_id = msg.arg3
                    Connection.Instance:send(msg.cmd, data)
                end
            )
        elseif msg.action ~= nil then
            local btn = func()
            btn.onClick:AddListener(
                function()
                    MessageAction.DoAction(msg.action)
                end
            )
        end
    end
end

function MsgItem:GetImage()
    local img = nil
    local rect = nil
    if #self.imgTab > 0 then
        img = self.imgTab[1]
        table.remove(self.imgTab, 1)
    else
        img = GameObject()
        img:AddComponent(Image)
        img.name = "Image"
        local trans = img.transform
        trans:SetParent(self.contentTrans)
        trans.localScale = Vector3.one
        trans.localPosition = Vector3.zero
        rect = img:GetComponent(RectTransform)
        rect.anchorMin = Vector2(0, 1)
        rect.anchorMax = Vector2(0, 1)
        rect.pivot = Vector2(0, 1)
    end
    return img
end

function MsgItem:GetButton()
    local btn = nil
    local rect = nil
    if #self.btnTab > 0 then
        btn = self.btnTab[1]
        table.remove(self.btnTab, 1)
    else
        local g = GameObject()
        g.name = "Button"
        local img = g:AddComponent(Image)
        img.color = Color(0,0,0,0)
        -- img.color = Color(0,0,0,0.5)
        btn = g:AddComponent(Button)
        local trans = btn.gameObject.transform
        trans:SetParent(self.contentTrans)
        trans.localScale = Vector3.one
        trans.localPosition = Vector3.zero
        rect = btn.gameObject:GetComponent(RectTransform)
        rect.anchorMin = Vector2(0, 1)
        rect.anchorMax = Vector2(0, 1)
        rect.pivot = Vector2(0, 1)
    end
    return btn
end

function MsgItem:GetFaceItem()
    local face = nil
    if #self.faceTab > 0 then
        face = self.faceTab[1]
        table.remove(self.faceTab, 1)
    else
        face = FaceItem.New(self.contentTrans)
    end
    return face
end

function MsgItem:Generator()
    -- 获取linespace
    self.lineSpace = NoticeManager.Instance.model.calculator:LineSpace(self.contentTxt.fontSize, self.contentTxt.lineSpacing)
    local generator = self.contentTxt.cachedTextGeneratorForLayout
    local isDynamic = self.contentTxt.font.dynamic

    -- print("####################### begin ##########################")
    -- print("text=\n" .. self.contentTxt.text)
    -- print("lineCount=" .. generator.lineCount)
    self.lineCount = generator.lineCount
    local lineDic = {}
    self.posxDic = {}
    self.posyDic = {}
    for i = 1, generator.lineCount do
        local lineInfo = generator.lines[i - 1]
        -- UILineInfo
        -- print("UILineInfo " .. i)
        -- print("height=" .. lineInfo.height)
        -- print("line=" .. i .. ",startCharIdx=" .. lineInfo.startCharIdx + 1)
        table.insert(lineDic, lineInfo.startCharIdx + 1)
    end

    local getLine = function(idx)
        for line,startIdx in ipairs(lineDic) do
            if idx < startIdx then
                return line - 1
            end
        end
        return #lineDic
    end

    local getWidth = function(element)
        local gw = 0
        for a = element.tagIndex, element.tagEndIndex do
            gw = gw + generator.characters[a - 1].charWidth
        end
        return gw
    end

    -- print("characterCount=" .. generator.characterCount)
    -- for i = 1, generator.characterCount do
    --     local charInfo = generator.characters[i - 1]
    --     print("charWidth=" .. charInfo.charWidth)
    --     print("cursorPos=[" .. charInfo.cursorPos.x .. "," .. charInfo.cursorPos.y .. "]")
    -- end

    local lastCharInfo = generator.characters[generator.characterCount - 1]
    if isDynamic then
        self.lastCharPos = Vector2(lastCharInfo.cursorPos.x + lastCharInfo.charWidth, -self.lineSpace * (generator.lineCount - 1))
    else
        self.lastCharPos = Vector2((lastCharInfo.cursorPos.x + lastCharInfo.charWidth) * (self.contentTxt.fontSize / self.staticFontSize), -self.lineSpace * (generator.lineCount - 1))
    end
    -- BaseUtils.dump(self.lastCharPos, "lastCharPos")

    local needMore = {}
    local hasInsert = 0

    for i,element in ipairs(self.msgData.elements) do
        local idx = element.tagIndex + element.offsetChar + self.wholeOffsetChar
        element.tagEndIndex = element.tagEndIndex + self.wholeOffsetChar
        local charInfo = generator.characters[idx - 1]
        local line = getLine(idx)
        local height = -self.lineSpace * (line - 1) + element.offsetY
        local width = charInfo.cursorPos.x + element.offsetX

        if not isDynamic then
            -- 静态字体取到的值是以静态字体本身设置的大小(19号)为标准的，这里如果显示的字体不是设置大小的话，需要一个比例来矫正
            width = width * (self.contentTxt.fontSize / self.staticFontSize)
        end

        element.width = getWidth(element)
        if isDynamic == true then
            width = MessageParser.ScaleVal(width, self.isSceneFace)
        end
        element.width = MessageParser.ScaleVal(element.width, self.isSceneFace)
        table.insert(self.posxDic, width)
        table.insert(self.posyDic, height)

        if element.tag == "item_1" or element.tag == "pet_1" or element.tag == "role_1" or element.tag == "unit_2" or element.tag == "honor_1" or element.tag == "panel_1" or element.tag == "panel_2" or element.tag == "rec_1" or element.tag == "wing_1" or element.tag == "achievement_1" or element.tag == "strategy_1" or element.tag == "sing_1" or element.tag == "marriagecertificate_1" or element.tag == "watch_1" or element.tag == "prefix_1" or element.tag == "child_1" or element.tag == "noonebadge_1" then
            local firstWidth = 0
            local secondWidth = 0
            for j = idx, element.tagEndIndex do
                if secondWidth == 0 then
                    if width + MessageParser.ScaleVal(firstWidth + generator.characters[j - 1].charWidth, self.isSceneFace) >= self.txtMaxWidth then
                        secondWidth = generator.characters[j - 1].charWidth
                    else
                        firstWidth = firstWidth + generator.characters[j - 1].charWidth
                    end
                else
                    secondWidth = secondWidth + generator.characters[j - 1].charWidth
                end
            end

            firstWidth = MessageParser.ScaleVal(firstWidth, self.isSceneFace)
            secondWidth = MessageParser.ScaleVal(secondWidth, self.isSceneFace)

            if secondWidth > 0 then
                element.width = firstWidth
                local addOne = BaseUtils.copytab(element)
                addOne.width = secondWidth
                table.insert(needMore, {idx = i + 1 + hasInsert, add = addOne})
                table.insert(self.posxDic, 0)
                table.insert(self.posyDic, height - self.lineSpace)
                hasInsert = hasInsert + 1
            end
        end
    end
    -- print("####################### end  ##########################")

    for _,v in ipairs(needMore) do
        table.insert(self.msgData.elements, v.idx, v.add)
    end

    self:ShowElements(self.msgData.elements)
    self.contentTxt.text = self.msgData.showString
end

