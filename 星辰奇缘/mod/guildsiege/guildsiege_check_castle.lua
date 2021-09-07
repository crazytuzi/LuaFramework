-- @author 黄耀聪
-- @date 2017年2月27日

-- 开战前，查看堡垒

GuildSiegeCheckCastle = GuildSiegeCheckCastle or BaseClass(BasePanel)

function GuildSiegeCheckCastle:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "GuildSiegeCheckCastle"

    self.resList = {
        {file = AssetConfig.guildsiege_checkcastle, type = AssetType.Main},
        {file = AssetConfig.guildsiege, type = AssetType.Dep},
        {file = AssetConfig.arena_textures, type = AssetType.Dep},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
    }

    self.updateListener = function() self:UpdateForce(self.castle) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GuildSiegeCheckCastle:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GuildSiegeCheckCastle:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guildsiege_checkcastle))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    t.localPosition = Vector3(0, 0, -1500)

    local main = t:Find("Main")

    -- 个人信息区域
    self.roleInfoObj = main:Find("RoleInfo").gameObject
    self.roleImage = main:Find("RoleInfo/Head/Icon"):GetComponent(Image)
    self.roleLevBg = main:Find("RoleInfo/Head/LevBg").gameObject
    self.roleLevText = main:Find("RoleInfo/Head/Lev"):GetComponent(Text)
    self.roleNameText = main:Find("RoleInfo/Forces/Name"):GetComponent(Text)
    self.unknownText = main:Find("RoleInfo/Unknow"):GetComponent(Text)
    self.guildList = {}
    self.guildContainer = main:Find("RoleInfo/Forces")
    for i=1,4 do
        self.guildList[i] = {
            gameObject = self.guildContainer:GetChild(i).gameObject,
            icon = self.guildContainer:GetChild(i):Find("Icon"):GetComponent(Image),
        }
    end

    self.line = main:Find("Line").gameObject

    -- 描述区域
    self.descExt = MsgItemExt.New(main:Find("DescArea/Desc"):GetComponent(Text), 300, 18, 20.8421)

    -- 城堡区域
    local castle = main:Find("Castle")
    self.castleImage = castle:Find("Image"):GetComponent(Image)
    self.descExt1 = MsgItemExt.New(castle:Find("Text"):GetComponent(Text), 150, 18, 21)
    self.castleArea = castle.gameObject

    -- 按钮区域
    self.buttonArea = main:Find("ButtonArea").gameObject
    self.guildAtBtn = main:Find("ButtonArea/GuildAtIt"):GetComponent(Button)
    self.chatBtn = main:Find("ButtonArea/Chat"):GetComponent(Button)

    if self.guildAtBtn == nil then
        self.guildAtBtn = main:Find("ButtonArea/GuildAtIt").gameObject:AddComponent(Button)
    end
    if self.chatBtn == nil then
        self.chatBtn = main:Find("ButtonArea/Chat").gameObject:AddComponent(Button)
    end

    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.unknownText.text = self.model.unknownString

    self.layout = LuaBoxLayout.New(main, {border = 5, axis = BoxLayoutAxis.Y, cspacing = 0})
    self.guildAtBtn.onClick:AddListener(function() self:OnAt() end)
    self.chatBtn.onClick:AddListener(function() self:OnChat() end)
end

function GuildSiegeCheckCastle:OnAt()
    ChatManager.Instance.model:ShowCanvas(true)
    if self.castle ~= nil then
        ChatManager.Instance.model:ShowChatWindow({MsgEumn.ChatChannel.Guild})
        local str = string.format("@%s", self.castle.name)
        local element = {}
        element.type = MsgEumn.AppendElementType.Prefix1
        element.showString = string.format("@%s ", self.castle.name)
        element.sendString = string.format("{prefix_1,%s,%s,%s,%s,%s,%s}", RoleManager.Instance.RoleData.name, self.castle.name, self.castle.r_id, self.castle.r_plat, self.castle.r_zone, ChatManager.Instance:CurrentChannel())
        element.matchString = str
        LuaTimer.Add(300, function() ChatManager.Instance:AppendInputElement(element, MsgEumn.ExtPanelType.Chat) end)
    end
    self:Hiden()
end

function GuildSiegeCheckCastle:OnChat()
    if self.castle ~= nil then
        FriendManager.Instance:TalkToUnknowMan({
                id = self.castle.r_id,
                platform = self.castle.r_plat,
                zone_id = self.castle.r_zone,
                classes = self.castle.classes,
                sex = self.castle.sex,
                lev = self.castle.lev,
            }, false)
    end
    self:Hiden()
end

function GuildSiegeCheckCastle:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GuildSiegeCheckCastle:OnOpen()
    self:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateMy:AddListener(self.updateListener)

    self.castle = self.openArgs
    self.isOpen = true
    GuildSiegeManager.Instance:send19102(self.castle.type, self.castle.order)

    self:UpdateForce(self.castle)
    self:SetDesc(self.castle)
    self:SetDesc1(self.castle)

    self:Reload(self.castle)
end

function GuildSiegeCheckCastle:OnHide()
    self:RemoveListeners()
    self.isOpen = false
    GuildSiegeManager.Instance.onUpdateStatus:Fire()
end

function GuildSiegeCheckCastle:RemoveListeners()
    GuildSiegeManager.Instance.onUpdateMy:RemoveListener(self.updateListener)
end

function GuildSiegeCheckCastle:UpdateForce(castle)
    if castle.type == 1 or castle.can_look == 1 then
        self.roleImage.sprite = PreloadManager.Instance:GetClassesHeadSprite(castle.classes, castle.sex)
        self.guildContainer.gameObject:SetActive(true)
        self.unknownText.gameObject:SetActive(false)
        self.roleLevBg.gameObject:SetActive(true)
        self.roleNameText.text = string.format("%s.%s", castle.order, castle.name)
        self.roleLevText.gameObject:SetActive(true)
        self.roleLevText.text = castle.lev

        for i,v in ipairs(self.guildList) do
            if (castle.guards or {})[i] == nil then
                v.icon.gameObject:SetActive(false)
            else
                v.icon.gameObject:SetActive(true)
                -- print((castle.guards or {})[i].guard_id)
                v.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, (castle.guards or {})[i].guard_id or 0)
            end
        end
    else
        self.roleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "Unknow")
        self.roleLevBg.gameObject:SetActive(false)
        self.roleLevText.gameObject:SetActive(false)
        self.guildContainer.gameObject:SetActive(false)
        self.unknownText.gameObject:SetActive(true)
    end
    self.castleImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Castle" .. ((DataGuildSiege.data_castle[castle.order] or {}).type or 0))
end

-- 强行图文混排，心好累
function GuildSiegeCheckCastle:SetDesc1(castle)
    local castleData = DataGuildSiege.data_castle[castle.order]
    local typeString = TI18N("我方")
    if castle.type == 1 then
        typeString = TI18N("敌方")
    end

    local buildString = nil
    if castleData.type == 0 then
        buildString = GuildSiegeEumn.CastleType[castleData.type]
    else
        buildString = string.format(TI18N("%s"), GuildSiegeEumn.CastleType[castleData.type])
    end

    self.descExt1.contentTrans.pivot = Vector2(0,1)
    if castleData.desc ~= "" then
        self.descExt1:SetData(string.format("第<color='#ffff00'>%s</color>号建筑-<color='#ffff00'>%s</color>\n\n效果:%s", castle.order, buildString, castleData.desc, castleData.desc))
    else
        self.descExt1:SetData(string.format("第<color='#ffff00'>%s</color>号-<color='#ffff00'>%s</color>\n效果:被完全摧毁时，%s可获得{assets_2,90002}<color='#ffff00'>×3</color>", castle.order, buildString, typeString))
    end

    if self.descExt1.contentTrans:Find("Image") ~= nil then
        self.descExt1.contentTrans:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
    end
    self.descExt1.contentTrans.anchorMax = Vector2(0, 0.5)
    self.descExt1.contentTrans.anchorMin = Vector2(0, 0.5)
    self.descExt1.contentTrans.anchoredPosition = Vector2(132.8, self.descExt1.contentTrans.sizeDelta.y / 2)

    if self.castle.order > 0 then
        local castleData = DataGuildSiege.data_castle[self.castle.order]
        if castleData.type ~= 0 then
            if self.effect ~= nil then self.effect:DeleteMe() end
            if castleData.type == 1 then
                self.effect = BibleRewardPanel.ShowEffect(20307, self.castleImage.transform, Vector3(0.625, 0.625, 0.625), Vector3(0, 48, -400))
            elseif castleData.type == 2 then
                self.effect = BibleRewardPanel.ShowEffect(20306, self.castleImage.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
            elseif castleData.type == 3 then
                self.effect = BibleRewardPanel.ShowEffect(20308, self.castleImage.transform, Vector3(1, 1, 1), Vector3(0, 48, -400))
            end
        else
            if self.effect ~= nil then
                self.effect:SetActive(false)
            end
        end
    else
        if self.effect ~= nil then
            self.effect:SetActive(false)
        end
    end

    if self.descExt1.contentTrans.sizeDelta.y > self.castleImage.transform.sizeDelta.y then
        self.castleArea.transform.sizeDelta = Vector2(310, self.descExt1.contentTrans.sizeDelta.y + 20)
    else
        self.castleArea.transform.sizeDelta = Vector2(310, self.castleImage.transform.sizeDelta.y+ 20)
    end
end

function GuildSiegeCheckCastle:SetDesc(castle)
    local castleData = DataGuildSiege.data_castle[castle.order]
    self.descExt.contentTrans.pivot = Vector2(0,1)
    if castleData.desc ~= "" then
        self.descExt:SetData(string.format("我方<color='#ffff00'>第%s-%s</color>\n%s\n由<color='#ae22da'>%s</color>镇守\n被完全摧毁时，敌方将获得{assets_2,90002}<color='#ffff00'>×3</color>", castle.order, GuildSiegeEumn.CastleType[castleData.type], castleData.desc .. "\n", castle.name))
    else
        self.descExt:SetData(string.format("我方<color='#ffff00'>第%s-%s</color>\n由<color='#ae22da'>%s</color>镇守\n被完全摧毁时，敌方将获得{assets_2,90002}<color='#ffff00'>×3</color>", castle.order, GuildSiegeEumn.CastleType[castleData.type], castle.name))
    end
    self.descExt.contentTrans:Find("Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.guildsiege, "Star")
end

function GuildSiegeCheckCastle:Reload(castle)
    self.buttonArea.gameObject:SetActive(false)
    self.descExt.contentTrans.gameObject:SetActive(false)
    self.castleArea.gameObject:SetActive(false)

    self.layout:ReSet()
    self.layout:AddCell(self.roleInfoObj)
    self.layout:AddCell(self.line)

    local extraHeight = 0

    -- if castle.type == 1 then    -- 查看己方
    --     self.layout:AddCell(self.descExt.contentTrans.gameObject)
    --     if castle.r_id ~= RoleManager.Instance.RoleData.id or castle.r_plat ~= RoleManager.Instance.RoleData.platform or castle.r_zone ~= RoleManager.Instance.RoleData.zone_id then
    --         self.layout:AddCell(self.buttonArea)
    --     else
    --         extraHeight = 10
    --     end
    -- else
        self.layout:AddCell(self.castleArea)
    -- end

    self.layout.panelRect.sizeDelta = Vector2(self.layout.panelRect.sizeDelta.x, self.layout.panelRect.sizeDelta.y + extraHeight)
end

