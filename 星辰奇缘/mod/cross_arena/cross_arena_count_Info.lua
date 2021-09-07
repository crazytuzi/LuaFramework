-- @author huangzefeng
-- 武道会战斗数据统计
-- @date 2016年7月21日

CrossArenaCountInfo = CrossArenaCountInfo or BaseClass(BasePanel)

function CrossArenaCountInfo:__init(model)
    self.model = model
    self.Mgr = self.model.mgr
    self.name = "CrossArenaCountInfo"
    self.GoodEffectPath = string.format(AssetConfig.effect, "20121")
    self.resList = {
        {file = AssetConfig.worldchampionfightinfo, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        -- {file = AssetConfig.worldchampion_LevIcon, type = AssetType.Dep},
        {file = AssetConfig.guard_head, type = AssetType.Dep},
        {file = self.GoodEffectPath, type = AssetType.Main},
    }
    self.iconposx = {
        [1] = 157,
        [2] = 192,
        [3] = 227,
        [4] = 262,
        [5] = 297,
        [6] = 332,
    }
    self.iconposy = {
        [1] = -41,
        [2] = -91,
        [3] = -141,
        [4] = -191,
        [5] = -241,
        [6] = -312.8,
        [7] = -362.8,
        [8] = -412.8,
        [9] = -462.8,
        [10] = -512.8,
    }
    self.firstinit = true
    self.maxdmg = {ii = 1, num = 0}
    self.maxkill = {ii = 1, num = 0}
    self.maxheal = {ii = 1, num = 0}
    self.mvper = {ii = 1, num = 0}
    self.lmvper = {ii = 1, num = 0}
    self.ctrer = {ii = 1, num = 0}
    self.godlike = {}
    self.badgeList = {}
    self.currRoleindex = 1
    self.currRoledata = nil
    self.roleInfoList = {}
    self.isend = false
end

function CrossArenaCountInfo:__delete()
    if self.quickpanel ~= nil then
        self.quickpanel:DeleteMe()
    end
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function CrossArenaCountInfo:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionfightinfo))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    self.data = self.openArgs
    BaseUtils.dump(self.data,"界面内结构")

    self.clickGo = GameObject.Instantiate(self:GetPrefab(self.GoodEffectPath))
    self.clickGo.transform:SetParent(self.transform)
    self.clickGo.transform.localScale = Vector3.one
    self.clickGo.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.clickGo.transform, "UI")
    self.clickGo:SetActive(false)

    self.closeBtn = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self.model:CloseCountInfowindow() end)

    self.continueBtn = self.transform:Find("Main/Button"):GetComponent(Button)
    self.continueBtn.onClick:AddListener(function() self.Mgr:Require16402() self.model:CloseCountInfowindow() end)

    self.transform:Find("Main/Title/I18NText"):GetComponent(Text).text = TI18N("跨服约战战绩")

    self.winImg = self.transform:Find("Main/Panel4/1").gameObject
    self.LoseImg = self.transform:Find("Main/Panel4/0").gameObject

    self.container = self.transform:Find("Main/Panel4/Panel/Container")
    self.ItemList = {}
    for i=1,10 do
        self.ItemList[i] = {}
        local trans = self.container:Find(string.format("Cloner_%s", i))
        self.ItemList[i].transform = trans
        self.ItemList[i].Btn = trans:GetComponent(Button)
        self.ItemList[i].Bg = trans:Find("Bg"):GetComponent(Image)
        self.ItemList[i].head = trans:Find("Character/Icon/Image"):GetComponent(Image)
        self.ItemList[i].Name = trans:Find("Character/CenterName"):GetComponent(Text)
        self.ItemList[i].RankValue = trans:Find("RankValue"):GetComponent(Text)
        self.ItemList[i].RankImage = trans:Find("Character/RankImage"):GetComponent(Image)
        self.ItemList[i].KD = trans:Find("KD"):GetComponent(Text)
        self.ItemList[i].RD = trans:Find("RD"):GetComponent(Text)
        self.ItemList[i].GoodButton = trans:Find("GoodButton"):GetComponent(Button)
        self.ItemList[i].GoodButtonIMG = trans:Find("GoodButton"):GetComponent(Image)
        self.ItemList[i].GoodButtonTxt = trans:Find("GoodButton/I18NText"):GetComponent(Text)
        self.ItemList[i].GoodButtonIcon = trans:Find("GoodButton/Image").gameObject
        self.ItemList[i].FriendButton = trans:Find("FriendButton"):GetComponent(Button)
        if self.data.type ~= nil and self.data.type == 1 then
            self.ItemList[i].GoodButton.gameObject:SetActive(false)
            -- self.ItemList[i].Btn.enabled = false
        end
    end
    self.Mvp = self.container:Find("Mvp")
    self.Mvp2 = self.container:Find("Mvp2")
    self.Mvpbtn = self.Mvp:GetComponent(Button)
    self.Mvp2btn = self.Mvp2:GetComponent(Button)
    self.LMvp = self.container:Find("LMvp")
    self.LMvp2 = self.container:Find("LMvp2")
    self.LMvpbtn = self.LMvp:GetComponent(Button)
    self.LMvp2btn = self.LMvp2:GetComponent(Button)
    self.GodLike = self.container:Find("GodLike")
    self.Killer = self.container:Find("Killer")
    self.Killerbtn = self.Killer:GetComponent(Button)
    self.Attacker = self.container:Find("Attacker")
    self.Attackerbtn = self.Attacker:GetComponent(Button)
    self.Defender = self.container:Find("Defender")
    self.Defenderbtn = self.Defender:GetComponent(Button)
    self.Ctrer = self.container:Find("Ctr")
    self.Ctrerbtn = self.Ctrer:GetComponent(Button)

    self.IconDescCon = self.transform:Find("IconDescCon")
    self.IconDescConBg = self.transform:Find("IconDescCon/Bg")
    self.showAllIconBtn = self.IconDescCon:Find("Bg/MoreButton"):GetComponent(Button)
    self.showAllIconBtn.onClick:AddListener(function()
        self:WatchIconByIndex(0)
    end)
    self.tipsPos = self.IconDescCon:Find("Bg/Tips")
    self.tipsPos:GetComponent(Text).text = TI18N("【结算称号可获得荣誉加分，多项荣誉则取最高】")
    self.IconDescList = {}
    for i=1,7 do
        self.IconDescList[i] = {}
        self.IconDescList[i].gameObject = self.IconDescCon:Find(string.format("Bg/Item%s", i)).gameObject
        self.IconDescList[i].anchoredPosition = self.IconDescList[i].gameObject.transform.anchoredPosition
    end
    self.IconDescCon:GetComponent(Button).onClick:AddListener(function()
        self.IconDescCon.gameObject:SetActive(false)
    end)
    self.IconDescCon:Find("Bg/Button"):GetComponent(Button).onClick:AddListener(function()
        self.IconDescCon.gameObject:SetActive(false)
    end)

    self.RoleDescPanel = self.transform:Find("RoleDescPanel")
    self.RoleDescPanel:GetComponent(Button).onClick:AddListener(function()
        self.RoleDescPanel.gameObject:SetActive(false)
    end)
    self.RoleDescPanel:Find("Bg/CloseButton"):GetComponent(Button).onClick:AddListener(function()
        self.RoleDescPanel.gameObject:SetActive(false)
    end)

    self.result1 = self.transform:Find("Main/Panel4/1")
    self.result0 = self.transform:Find("Main/Panel4/0")

    self.Role_bg = self.RoleDescPanel:Find("Bg/Cloner_1/Bg").gameObject
    self.Role_enmybg = self.RoleDescPanel:Find("Bg/Cloner_1/enmyBg").gameObject
    self.Role_Head = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Icon/Image"):GetComponent(Image)
    self.Role_Name = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Name"):GetComponent(Text)
    self.Role_Dfd = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Defender").gameObject
    self.Role_Atk = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Attacker").gameObject
    self.Role_Killer = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Killer").gameObject
    self.Role_Godlike = self.RoleDescPanel:Find("Bg/Cloner_1/Character/GodLike").gameObject
    self.Role_Ctr = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Ctr").gameObject
    self.Role_Mvp = self.RoleDescPanel:Find("Bg/Cloner_1/Character/Mvp").gameObject
    self.Role_LMvp = self.RoleDescPanel:Find("Bg/Cloner_1/Character/LMvp").gameObject
    self.Role_RD = self.RoleDescPanel:Find("Bg/RD"):GetComponent(Text)
    self.Role_KD = self.RoleDescPanel:Find("Bg/KD"):GetComponent(Text)
    self.Role_RankValue = self.RoleDescPanel:Find("Bg/RankValue"):GetComponent(Text)
    self.Role_AddBtn = self.RoleDescPanel:Find("Bg/AddButton"):GetComponent(Button)
    self.Role_GoodBtn = self.RoleDescPanel:Find("Bg/GoodButton"):GetComponent(Button)
    self.Role_RepBtn = self.RoleDescPanel:Find("Bg/RepButton"):GetComponent(Button)
    self.Role_LButton = self.RoleDescPanel:Find("Bg/LButton"):GetComponent(Button)
    self.Role_RButton = self.RoleDescPanel:Find("Bg/RButton"):GetComponent(Button)
    self.Role_AddBtn.onClick:AddListener(function()
        FriendManager.Instance:AddFriend(self.currRoledata.rid, self.currRoledata.platform, self.currRoledata.zone_id)
    end)
    self.Role_GoodBtn.onClick:AddListener(function()
        if self.currRoleindex > 5 then
            return
        else
            self.Mgr:Require16419(self.currRoledata.rid, self.currRoledata.platform, self.currRoledata.zone_id)
        end
    end)
    self.Role_RepBtn.onClick:AddListener(function()
        self.Mgr:Require16425(self.currRoledata.rid, self.currRoledata.platform, self.currRoledata.zone_id, self.data.r_id)
    end)
    self.Role_LButton.onClick:AddListener(function()
        self:SelectLeft()
    end)
    self.Role_RButton.onClick:AddListener(function()
        self:SelectRight()
    end)
    local setting = {title = TI18N("分享跨服约战"), type = 1}
    self.quickpanel = ZoneQuickShareStr.New(setting)
    self.transform:Find("Main/ShareButton"):GetComponent(Button).onClick:AddListener(function()
        self.quickpanel:Show()
    end)
    self.transform:Find("Main/playbackButton"):GetComponent(Button).onClick:AddListener(function()
        self.model:CloseCountInfowindow()
        if self.data.playback == 1 then
            CombatManager.Instance:Send10753(21, self.data.r_id, self.data.r_platform, self.data.r_zone_id)
        else
            CrossArenaManager.Instance:Send20717(self.data.r_id, self.data.r_platform, self.data.r_zone_id)
            -- CombatManager.Instance:Send10753(21, self.data.r_id, self.data.r_platform, self.data.r_zone_id)
        end
    end)
    if self.data.type ~= nil and self.data.type == 1 then
        self.transform:Find("Main/playbackButton").gameObject:SetActive(true)
        self.transform:Find("Main/ShareButton").gameObject:SetActive(false)
        self.continueBtn.gameObject:SetActive(false)
    end
    self:PraseData()
    self:LoadItem()
end


function CrossArenaCountInfo:LoadItem()
    local roleData = RoleManager.Instance.RoleData
    self.maxdmg = {ii = 1, num = 0}
    self.maxkill = {ii = 1, num = 0}
    self.maxheal = {ii = 1, num = 0}
    self.mvper = {ii = 1, num = -1}
    self.lmvper = {ii = 1, num = -1}
    self.ctrer = {ii = 1, num = 0}
    self.godlike = {}
    self.badgeList = {}
    self.result1.gameObject:SetActive(self.data.result == 1 or self.data.is_win == 1)
    self.result0.gameObject:SetActive(self.data.result == 2 or self.data.is_win == 2)
    for i,v in ipairs(self.data.mates) do
        if i > 5 then
            break
        end
        local item = self.ItemList[i]
        if i>5 then
            item.Bg.sprite = self.assetWrapper:GetSprite(AssetConfig.no1inworld_textures, "enemybg")
        end
        item.Btn.onClick:RemoveAllListeners()
        if v.rid == roleData.id and roleData.platform == v.platform and  roleData.zone_id == v.zone_id then
            item.transform:Find("Select").gameObject:SetActive(true)
            item.GoodButton.gameObject:SetActive(false)
            item.FriendButton.gameObject:SetActive(false)
        else
            item.GoodButton.gameObject:SetActive(true)
            item.FriendButton.gameObject:SetActive(true)
            item.Btn.onClick:AddListener(function()
                self:ClickItem(i, v)
            end)
            item.FriendButton.onClick:AddListener(function()
                self:ClickItem(i, v)
            end)
        end
        item.head.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, BaseUtils.Key(v.classes, v.sex))
        item.Name.text = v.name
        -- item.RankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, tostring(v.rank_lev))
        item.RankValue.text = string.format("%s/%s/%s", tostring(v.kill_num), tostring(v.dead_num), tostring(v.control_num))
        item.KD.text = self:FormatNum(v.total_dmg)
        item.RD.text = self:FormatNum(v.total_heal)
        item.GoodButton.onClick:RemoveAllListeners()
        if v.gooded then
            item.GoodButtonIMG.enabled = false
            item.GoodButtonIcon:SetActive(false)
            item.GoodButtonTxt.gameObject:SetActive(true)
            local effectgo = item.GoodButton.transform:Find("Effect")
            if effectgo ~= nil then
                effectgo.gameObject:SetActive(false)
            end
        else
            item.GoodButtonIMG.enabled = true
            item.GoodButtonIcon:SetActive(true)
            item.GoodButtonTxt.gameObject:SetActive(false)
            item.GoodButton.onClick:AddListener(function()
                self:ClickItem(i, v)
            end)
        end
        if self.data.type == 1 then
            item.GoodButton.gameObject:SetActive(false)
        end
        if v.total_dmg > self.maxdmg.num then
            self.maxdmg.ii = i
            self.maxdmg.num = v.total_dmg
        end
        if v.kill_num > self.maxkill.num then
            self.maxkill.ii = i
            self.maxkill.num = v.kill_num
        end
        if v.total_heal > self.maxheal.num then
            self.maxheal.ii = i
            self.maxheal.num = v.total_heal
        end
        if self.data.result == 1 or self.data.is_win == 1 then
            if v.mvp_score > self.mvper.num then
                self.mvper.ii = i
                self.mvper.num = v.mvp_score
            end
        else
            if v.mvp_score > self.lmvper.num then
                self.lmvper.ii = i
                self.lmvper.num = v.mvp_score
            end
        end
        if v.control_num > self.ctrer.num then
            self.ctrer.ii = i
            self.ctrer.num = v.control_num
        end
        if v.kill_num >= 8 then
            self.godlike[i] = true
        end
        self.badgeList[i] = 0

        if v.zone_id == 0 then
            item.RankImage.gameObject:SetActive(false)
            item.GoodButtonIMG.enabled = false
            item.GoodButtonIcon:SetActive(false)
            item.GoodButtonTxt.gameObject:SetActive(false)
            item.FriendButton.gameObject:SetActive(false)

            local guard_base_cfg = DataShouhu.data_guard_base_cfg[v.rid]
            item.head.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard_base_cfg.avatar_id))
        else
            -- item.RankImage.gameObject:SetActive(true)
            item.RankImage.gameObject:SetActive(false)
        end
    end
    for i=#self.data.mates+1, 5 do
        local item = self.ItemList[i]
        item.transform.gameObject:SetActive(false)
    end
    for i,v in ipairs(self.data.rival) do
        if i+5 > 10 then
            break
        end
        local item = self.ItemList[i+5]
        item.head.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, BaseUtils.Key(v.classes.."_"..v.sex))
        item.Name.text = v.name
        -- item.RankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.worldchampion_LevIcon, tostring(v.rank_lev))
        item.RankValue.text = string.format("%s/%s/%s", tostring(v.kill_num), tostring(v.dead_num), tostring(v.control_num))
        item.KD.text = self:FormatNum(v.total_dmg)
        item.RD.text = self:FormatNum(v.total_heal)
        item.Btn.onClick:RemoveAllListeners()
        item.Btn.onClick:AddListener(function()
            self:ClickItem(i+5, v)
        end)
        item.FriendButton.onClick:AddListener(function()
                self:ClickItem(i+5, v)
            end)
        item.GoodButton.onClick:RemoveAllListeners()
        if v.gooded then
            item.GoodButtonIMG.enabled = false
            item.GoodButtonIcon:SetActive(false)
            item.GoodButtonTxt.gameObject:SetActive(true)
        else
            item.GoodButtonIMG.enabled = true
            item.GoodButtonIcon:SetActive(true)
            item.GoodButtonTxt.gameObject:SetActive(false)
            item.GoodButton.onClick:AddListener(function()
                self:ClickItem(i+5, v)
            end)
        end
        if v.total_dmg > self.maxdmg.num then
            self.maxdmg.ii = i+5
            self.maxdmg.num = v.total_dmg
        end
        if v.kill_num > self.maxkill.num then
            self.maxkill.ii = i+5
            self.maxkill.num = v.kill_num
        end
        if v.total_heal > self.maxheal.num then
            self.maxheal.ii = i+5
            self.maxheal.num = v.total_heal
        end
        if v.kill_num >= 8 then
            self.godlike[i+5] = true
        end
        if self.data.result == 2 or self.data.is_win == 2 then
            if v.mvp_score > self.mvper.num then
                self.mvper.ii = i+5
                self.mvper.num = v.mvp_score
            end
        else
            if v.mvp_score > self.lmvper.num then
                self.lmvper.ii = i+5
                self.lmvper.num = v.mvp_score
            end
        end
        if v.control_num > self.ctrer.num then
            self.ctrer.ii = i+5
            self.ctrer.num = v.control_num
        end
        self.badgeList[i+5] = 0

        if v.zone_id == 0 then
            item.RankImage.gameObject:SetActive(false)
            item.GoodButtonIMG.enabled = false
            item.GoodButtonIcon:SetActive(false)
            item.GoodButtonTxt.gameObject:SetActive(false)
            item.FriendButton.gameObject:SetActive(false)

            local guard_base_cfg = DataShouhu.data_guard_base_cfg[v.rid]
            item.head.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard_base_cfg.avatar_id))
        else
            -- item.RankImage.gameObject:SetActive(true)
            item.RankImage.gameObject:SetActive(false)
        end
    end
    for i=#self.data.rival+1, 5 do
        local item = self.ItemList[i+5]
        item.transform.gameObject:SetActive(false)
    end
    if self.firstinit == false then
        return
    else
        self.firstinit = false
    end
    for k,v in pairs(self.godlike) do
        local badge = GameObject.Instantiate(self.GodLike.gameObject)
        badge.transform:SetParent(self.container)
        badge.transform.localScale = Vector3.one
        badge:SetActive(true)
        local currnum = self.badgeList[k]
        badge.transform.anchoredPosition = Vector2(self.iconposx[currnum+1], self.iconposy[k])
        badge:GetComponent(Button).onClick:AddListener(function()
            self:WatchIconByIndex(k)
        end)
        self.badgeList[k] = self.badgeList[k] + 1
        if k <= 5 then
            self:GiveEffect(self.ItemList[k].GoodButton.gameObject)
        end
    end
    -- BaseUtils.dump(self.maxdmg, "self.maxdmg")
    -- BaseUtils.dump(self.maxkill, "self.maxkill")
    -- BaseUtils.dump(self.maxheal, "self.maxheal")
    -- BaseUtils.dump(self.badgeList, "self.badgeList")
    -- BaseUtils.dump(self.godlike, "self.godlike")
    -- print(self.maxkill.ii)
    self.Attacker.anchoredPosition = Vector2(self.iconposx[self.badgeList[self.maxdmg.ii]+1], self.iconposy[self.maxdmg.ii])
    self.badgeList[self.maxdmg.ii] = self.badgeList[self.maxdmg.ii]+1
    self.Attacker.gameObject:SetActive(true)
    self.Attackerbtn.onClick:AddListener(function( ) self:WatchIconByIndex(self.maxdmg.ii) end)
    -- BaseUtils.dump(self.badgeList, "self.badgeList")

    self.Killer.anchoredPosition = Vector2(self.iconposx[self.badgeList[self.maxkill.ii]+1], self.iconposy[self.maxkill.ii])
    self.badgeList[self.maxkill.ii] = self.badgeList[self.maxkill.ii]+1
    self.Killer.gameObject:SetActive(true)
    self.Killerbtn.onClick:AddListener(function( ) self:WatchIconByIndex(self.maxkill.ii) end)
    -- BaseUtils.dump(self.badgeList, "self.badgeList")

    self.Mvp.anchoredPosition = Vector2(self.iconposx[self.badgeList[self.mvper.ii]+1], self.iconposy[self.mvper.ii])
    self.Mvp2.anchoredPosition = Vector2(-329.55, self.ItemList[self.mvper.ii].transform.anchoredPosition.y)
    self.badgeList[self.mvper.ii] = self.badgeList[self.mvper.ii]+1
    self.Mvp.gameObject:SetActive(true)
    self.Mvp2.gameObject:SetActive(true)
    self.Mvpbtn.onClick:AddListener(function( ) self:WatchIconByIndex(self.mvper.ii) end)
    self.Mvp2btn.onClick:AddListener(function( ) self:WatchIconByIndex(self.mvper.ii) end)
    if self.ItemList[self.mvper.ii].GoodButton.transform:Find("Effect") == nil then
        self:GiveEffect(self.ItemList[self.mvper.ii].GoodButton.gameObject)
    end

    self.LMvp.anchoredPosition = Vector2(self.iconposx[self.badgeList[self.lmvper.ii]+1], self.iconposy[self.lmvper.ii])
    self.LMvp2.anchoredPosition = Vector2(-329.55, self.ItemList[self.lmvper.ii].transform.anchoredPosition.y)
    self.badgeList[self.lmvper.ii] = self.badgeList[self.lmvper.ii]+1
    self.LMvp.gameObject:SetActive(true)
    self.LMvp2.gameObject:SetActive(true)
    self.LMvpbtn.onClick:AddListener(function( ) self:WatchIconByIndex(self.lmvper.ii) end)
    self.LMvp2btn.onClick:AddListener(function( ) self:WatchIconByIndex(self.lmvper.ii) end)
    if self.ItemList[self.lmvper.ii].GoodButton.transform:Find("Effect") == nil then
        self:GiveEffect(self.ItemList[self.lmvper.ii].GoodButton.gameObject)
    end
    -- BaseUtils.dump(self.badgeList, "self.badgeList")

    if self.maxheal.num ~= 0 then
        self.Defender.anchoredPosition = Vector2(self.iconposx[self.badgeList[self.maxheal.ii]+1], self.iconposy[self.maxheal.ii])
        self.badgeList[self.maxheal.ii] = self.badgeList[self.maxheal.ii]+1
        self.Defender.gameObject:SetActive(true)
        self.Defenderbtn.onClick:AddListener(function( ) self:WatchIconByIndex(self.maxheal.ii) end)
    end
    -- BaseUtils.dump(self.badgeList, "self.badgeList")

    if self.ctrer.num ~= 0 then
        self.Ctrer.anchoredPosition = Vector2(self.iconposx[self.badgeList[self.ctrer.ii]+1], self.iconposy[self.ctrer.ii])
        self.badgeList[self.ctrer.ii] = self.badgeList[self.ctrer.ii]+1
        self.Ctrer.gameObject:SetActive(true)
        self.Ctrerbtn.onClick:AddListener(function( ) self:WatchIconByIndex(self.ctrer.ii) end)
    end
    -- BaseUtils.dump(self.badgeList, "self.badgeList")

end

function CrossArenaCountInfo:PraseData()
    self.roleInfoList = {}
    for i,v in ipairs(self.data.mates) do
        table.insert(self.roleInfoList, v)
    end
    for i,v in ipairs(self.data.rival) do
        table.insert(self.roleInfoList, v)
    end
end

function CrossArenaCountInfo:GoodSuccess(rid, platform, zone_id)
    for i,v in ipairs(self.data.mates) do
        if v.rid == rid and platform == v.platform and  zone_id == v.zone_id then
            self.data.mates[i].gooded = true
        end
    end
    for i,v in ipairs(self.data.rival) do
        if v.rid == rid and platform == v.platform and  zone_id == v.zone_id then
            self.data.rival[i].gooded = true
        end
    end
    self:PraseData()
    self:LoadItem()
    if self.RoleDescPanel.gameObject.activeSelf then
        self:ClickItem(self.currRoleindex, self.roleInfoList[self.currRoleindex])
    end
end

function CrossArenaCountInfo:ClickItem(index , data)
    -- 改为守护不响应此操作
    if data == nil or data.zone_id == nil or data.zone_id == 0 then
        return
    end

    self.currRoleindex = index
    self.currRoledata = data
    self.RoleDescPanel.gameObject:SetActive(true)
    if data.zone_id == 0 then
        local guard_base_cfg = DataShouhu.data_guard_base_cfg[data.rid]
        self.Role_Head.sprite = self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard_base_cfg.avatar_id))
    else
        self.Role_Head.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, BaseUtils.Key(data.classes, data.sex))    
    end
    self.Role_Name.text = data.name
    local x = 0
    self.Role_bg:SetActive(index<=5)
    self.Role_enmybg:SetActive(index>5)
    self.Role_RepBtn.gameObject:SetActive(not(index > 5 or self.data.type == 1))
    if self.godlike[index] ~= true then
        self.Role_Godlike:SetActive(false)
    else
        self.Role_Godlike:SetActive(true)
        self.Role_Godlike.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end
    if self.maxdmg.ii ~= index then
        self.Role_Atk:SetActive(false)
    else
        self.Role_Atk:SetActive(true)
        self.Role_Atk.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end
    if self.maxkill.ii ~= index then
        self.Role_Killer:SetActive(false)
    else
        self.Role_Killer:SetActive(true)
        self.Role_Killer.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end
    if self.mvper.ii ~= index then
        self.Role_Mvp:SetActive(false)
    else
        self.Role_Mvp:SetActive(true)
        self.Role_Mvp.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end
    if self.maxheal.ii ~= index or self.maxheal.num == 0 then
        self.Role_Dfd:SetActive(false)
    else
        self.Role_Dfd:SetActive(true)
        self.Role_Dfd.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end
    if self.ctrer.ii ~= index or self.ctrer.num == 0 then
        self.Role_Ctr:SetActive(false)
    else
        self.Role_Ctr:SetActive(true)
        self.Role_Ctr.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end
    if self.lmvper.ii ~= index then
        self.Role_LMvp:SetActive(false)
    else
        self.Role_LMvp:SetActive(true)
        self.Role_LMvp.transform.anchoredPosition = Vector2(x, -47)
        x = x + 32
    end

    self.Role_RD.text = self:FormatNum(data.total_heal)
    self.Role_KD.text = self:FormatNum(data.total_dmg)
    self.Role_RankValue.text = string.format("%s/%s/%s", tostring(data.kill_num), tostring(data.dead_num), tostring(data.control_num))
    if FriendManager.Instance:IsFriend(data.rid, data.platform, data.zone_id) then
        -- self.Role_AddBtn.gameObject:SetActive(false)
        BaseUtils.SetGrey(self.Role_AddBtn.transform:GetComponent(Image), true)
    else
        BaseUtils.SetGrey(self.Role_AddBtn.transform:GetComponent(Image), false)
        -- self.Role_AddBtn.gameObject:SetActive(true)
    end
    BaseUtils.SetGrey(self.Role_GoodBtn.transform:GetComponent(Image), data.gooded == true or index > 5)
    self.Role_GoodBtn.gameObject:SetActive(self.data.type ~= 1)
    -- self.Role_GoodBtn.gameObject:SetActive(data.gooded~=true)
    self.Role_LButton = self.RoleDescPanel:Find("Bg/LButton"):GetComponent(Button)
    self.Role_RButton = self.RoleDescPanel:Find("Bg/RButton"):GetComponent(Button)
end

function CrossArenaCountInfo:SelectLeft()
    local roleData = RoleManager.Instance.RoleData
    local i = self.currRoleindex -1
    if i == 0 then
        i = 10
    end
    local data = self.roleInfoList[i]

    -- 改为守护不响应此操作
    if data == nil or data.zone_id == nil or data.zone_id == 0 then
        return
    end
    if data.rid == roleData.id and roleData.platform == data.platform and  roleData.zone_id == data.zone_id then
        i = i -1
        if i == 0 then
            i = 10
        end
        data = self.roleInfoList[i]
    end
    self:ClickItem(i, data)
end

function CrossArenaCountInfo:SelectRight()
    local roleData = RoleManager.Instance.RoleData
    local i = self.currRoleindex + 1
    if i >= 11 then
        i = 1
    end
    local data = self.roleInfoList[i]

    -- 改为守护不响应此操作
    if data == nil or data.zone_id == nil or data.zone_id == 0 then
        return
    end
    if data.rid == roleData.id and roleData.platform == data.platform and  roleData.zone_id == data.zone_id then
        i = i + 1
        if i >= 11 then
            i = 1
        end
        data = self.roleInfoList[i]
    end
    self:ClickItem(i, data)
end

function CrossArenaCountInfo:FormatNum(num)
    if num < 100000 then
        return tostring(num)
    else
        return string.format(TI18N("%s万"), tostring(Mathf.Round(num/10000)))
    end
end

function CrossArenaCountInfo:WatchIconByIndex(index)
    if index == nil or index == 0 then
        for i,v in ipairs(self.IconDescList) do
            v.gameObject.transform.anchoredPosition = v.anchoredPosition
            v.gameObject:SetActive(true)
        end
        self.showAllIconBtn.gameObject:SetActive(false)
        self.IconDescConBg.sizeDelta = Vector2(459, 483)
        self.tipsPos.anchoredPosition = Vector2(0,-440)
    else
        local num = 0
        local showindex = {}
        if self.godlike[index] == true then
            num = num + 1
            showindex[1] = true
        end
        if self.maxdmg.ii == index then
            num = num + 1
            showindex[2] = true
        end
        if self.maxkill.ii == index then
            num = num + 1
            showindex[3] = true
        end
        if self.mvper.ii == index then
            num = num + 1
            showindex[4] = true
        end
        if self.maxheal.ii == index and self.maxheal.num ~= 0 then
            num = num + 1
            showindex[5] = true
        end
        if self.ctrer.ii == index and self.ctrer.num ~= 0 then
            num = num + 1
            showindex[6] = true
        end
        if self.lmvper.ii == index then
            num = num + 1
            showindex[7] = true
        end
        if num > 0 then
            local currindex = 1
            for i,v in ipairs(self.IconDescList) do
                v.gameObject:SetActive(showindex[i] == true)
                if showindex[i] == true then
                    v.gameObject.transform.anchoredPosition = self.IconDescList[currindex].anchoredPosition
                    currindex = currindex + 1
                end
            end
            self.IconDescConBg.sizeDelta = Vector2(459, 133+(num+1)*50)
            self.showAllIconBtn.gameObject:SetActive(true)
            self.tipsPos.anchoredPosition = Vector2(0,-90-num*50)
        else
            for i,v in ipairs(self.IconDescList) do
                v.gameObject.transform.anchoredPosition = v.anchoredPosition
                v.gameObject:SetActive(true)
            end
            self.showAllIconBtn.gameObject:SetActive(false)
            self.IconDescConBg.sizeDelta = Vector2(459, 483)
            self.tipsPos.anchoredPosition = Vector2(0,-440)
        end

    end
    self.IconDescCon.gameObject:SetActive(true)
end

function CrossArenaCountInfo:GiveEffect(go)
    local effectgo = GameObject.Instantiate(self.clickGo)
    effectgo.name = "Effect"
    effectgo.transform:SetParent(go.transform)
    effectgo.transform.localScale = Vector3(0.6, 0.6, 1)
    effectgo.transform.localPosition = Vector3(0,0,-1620)
    effectgo:SetActive(true)
end