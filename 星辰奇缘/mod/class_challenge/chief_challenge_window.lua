-- 职业首席挑战面板
-- xhs  20180108

ChiefChallengeWindow = ChiefChallengeWindow or BaseClass(BaseWindow)

function ChiefChallengeWindow:__init(model)
    self.Mgr = ClassesChallengeManager.Instance
    self.model = model
    self.name = "ChiefChallengeWindow"
    self.windowId = WindowConfig.WinID.chief_challenge_window
    self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.chief_challenge_win, type = AssetType.Main},
        {file = AssetConfig.chief_challenge_textures, type = AssetType.Dep},
        {file = AssetConfig.chiefchallengebg, type = AssetType.Main},
        {file = AssetConfig.rolebgnew, type = AssetType.Dep},
        {file = AssetConfig.wingsbookbg, type = AssetType.Dep},
        -- {file = AssetConfig.basecompress_textures, type = AssetType.Dep},
    }

    self.enum = {[1] = "狂剑", [2] = "魔导", [3] = "战弓", [4] = "兽灵", [5] = "秘言", [6] = "月魂", [7] = "圣骑"}
    -- self.data = {{1,false,"玩家2312"},{2,true,"玩家3312"},{3,false,"玩家654"},{4,true,"玩家787"},{5,false,"玩家534"},{6,false,"玩家909"},{7,false,"玩家276"}}
    self.itemlist = {}
    self.slotList = {}

    self.updateData = function()
        self:SetData()
        self:UpdatePreview()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ChiefChallengeWindow:__delete()
    self.OnHideEvent:Fire()
    if self.previewComp ~= nil then
        self.previewComp:DeleteMe()
        self.previewComp = nil
    end
    if self.slotList ~= nil then
        for k,v in pairs(self.slotList) do
            v:DeleteMe()
        end
        self.slotList = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ChiefChallengeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.chief_challenge_win))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    local main = self.gameObject.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    local con = main:Find("Con")
    UIUtils.AddBigbg(con:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.chiefchallengebg)))
    con:Find("Right/bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgnew,"rolebgnew")
    con:Find("Right/bot"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg,"wingsbookbg")
    self.preview = con:Find("Right/Preview").gameObject

    self.preview:SetActive(false)
    self.playerName = con:Find("Right/nameBg/name"):GetComponent(Text)
    self.cloner = con:Find("Left/cloner").gameObject
    for i=1,7 do
        local item = GameObject.Instantiate(self.cloner)
        item.transform:SetParent(con:Find("Left"))
        item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
        if i < 5 then
            item:GetComponent(RectTransform).anchoredPosition = Vector2(110*i-280,66)
        else
            item:GetComponent(RectTransform).anchoredPosition = Vector2(110*i-669,-70)
        end
        self.itemlist[i] = {}
        self.itemlist[i].badge = item.transform:Find("badge"):GetComponent(Image)
        self.itemlist[i].classes = item.transform:Find("classes/Text"):GetComponent(Text)
        self.itemlist[i].pass = item.transform:Find("pass").gameObject
        self.itemlist[i].select = item.transform:Find("select").gameObject
        item:GetComponent(Button).onClick:AddListener(function()
            if self.select ~= i then
                self.itemlist[self.select].select:SetActive(false)
                self.itemlist[i].select:SetActive(true)
                self.select = i
                self:UpdatePreview()
            end
        end)
    end
    self.cloner:SetActive(false)
    con:Find("Bottom/Button"):GetComponent(Button).onClick:AddListener(function()
        ClassesChallengeManager.Instance:Send10826(self.data[self.select].leader_id)
        for k,v in pairs(ClassesChallengeManager.Instance.chiefPassData.skill_clsld_done) do
            if v.leader_id == self.data[self.select].leader_id then
                return
            end
        end
        if self.TimerCD == nil then
            self:OnClose()
        end
    end)
    self.btnText = con:Find("Bottom/Button/Text"):GetComponent(Text)
    self.btnImg = con:Find("Bottom/Button"):GetComponent(Image)
    local index = 0
    for k,v in pairs(DataSkillUnique.data_chief_monster[1].reward ) do
        if v[3] == 0 or v[3] == RoleManager.Instance.RoleData.classes then
            local itemSlot = ItemSlot.New()
            UIUtils.AddUIChild(con:Find("Bottom/Reward/cloner"), itemSlot.gameObject)
            itemSlot.gameObject:GetComponent(RectTransform).localPosition = Vector2(80*index,0)
            local itemBaseData = BackpackManager.Instance:GetItemBase(v[1])
            local itemData = ItemData.New()
            itemData:SetBase(itemBaseData)
            itemData.quantity = v[2]
            itemSlot:SetAll(itemData, { nobutton = true })
            index = index + 1
            table.insert(self.slotList,itemSlot)
        end
    end
end

function ChiefChallengeWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
    self.data = {}
    for k,v in pairs(ClassesChallengeManager.Instance.chiefData.chief_classes) do
        self.data[v.leader_id] = v
    end
    for i=1,7 do
        if self.data[i] == nil then
            self.data[i] = {leader_id = i, isMonster = true}
        end
    end
end

function ChiefChallengeWindow:OnOpen()
    self:AddListeners()
    ClassesChallengeManager.Instance:Send10832()
end

function ChiefChallengeWindow:OnHide()
    self:RemoveListeners()
    if self.previewComp ~= nil then
        self.previewComp:Hide()
    end
    if self.TimerCD ~= nil then
        LuaTimer.Delete(self.TimerCD)
        self.TimerCD = nil
    end
end

function ChiefChallengeWindow:AddListeners()
    ClassesChallengeManager.Instance.OnUpdateChief:AddListener(self.updateData)
end

function ChiefChallengeWindow:RemoveListeners()
    ClassesChallengeManager.Instance.OnUpdateChief:RemoveListener(self.updateData)
end

function ChiefChallengeWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
end

function ChiefChallengeWindow:SetData()
    local pass = ClassesChallengeManager.Instance.chiefPassData.skill_clsld_done

    local function ispass(id)
        for k,v in pairs(pass) do
            if v.leader_id == id then
                return true
            end
        end
        return false
    end

    local function sort_(a, b)
        if ispass(a.leader_id) and ispass(b.leader_id) then
            return a.leader_id < b.leader_id
        elseif (not ispass(a.leader_id)) and (not ispass(b.leader_id)) then
            return a.leader_id < b.leader_id
        elseif ispass(a.leader_id) and (not ispass(b.leader_id)) then
            return false
        else
            return true
        end
    end
    table.sort(self.data,sort_)


    for i=1,7 do
        if self.data[i].isMonster == nil then
            self.itemlist[i].badge.sprite = self.assetWrapper:GetSprite(AssetConfig.chief_challenge_textures,self.data[i].classes)
            self.itemlist[i].classes.text = self.enum[self.data[i].classes].."首席"
            self.itemlist[i].pass:SetActive(ispass(self.data[i].leader_id))
        else
            local data = DataSkillUnique.data_chief_monster[self.data[i].leader_id]
            self.itemlist[i].badge.sprite = self.assetWrapper:GetSprite(AssetConfig.chief_challenge_textures,data.classes)
            self.itemlist[i].classes.text = self.enum[data.classes].."首席"
            self.itemlist[i].pass:SetActive(ispass(self.data[i].leader_id))
        end
    end

    self.select = 1
    self.itemlist[1].select:SetActive(true)

    local offTime = (ClassesChallengeManager.Instance.chiefPassData.cooldown or 0) - BaseUtils.BASE_TIME;
    if offTime > 0 then

        if self.TimerCD ~= nil then
            LuaTimer.Delete(self.TimerCD)
        end
        self.TimerCD = LuaTimer.Add(0, 1000,
        function()
            local time = (ClassesChallengeManager.Instance.chiefPassData.cooldown or 0) - BaseUtils.BASE_TIME;
            if time > 0 then
                self.btnText.text  = BaseUtils.formate_time_gap(time, ":", 0, BaseUtils.time_formate.MIN);
            else
                if self.TimerCD ~= nil then
                    LuaTimer.Delete(self.TimerCD)
                    self.TimerCD = nil
                end
                self.btnText.text = TI18N("开始挑战")
                self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            end
        end )
        self.btnText.text = BaseUtils.formate_time_gap(offTime, ":", 0, BaseUtils.time_formate.MIN)
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
    else
        self.btnText.text = TI18N("开始挑战")
        self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
    end
end

function ChiefChallengeWindow:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "ClassesChief"
        ,orthographicSize = 0.45
        ,width = 220
        ,height = 220
        ,offsetY = -0.4
    }
    local modelData = {}
    if self.data[self.select].isMonster == nil then
        self.playerName.text = self.data[self.select].name
        modelData = {type = PreViewType.Role, classes =  self.data[self.select].classes , sex = self.data[self.select].sex, looks = self.data[self.select].looks}
    else
        local data = DataSkillUnique.data_chief_monster[self.data[self.select].leader_id]
        local BaseData = DataUnit.data_unit[data.unit_id[1][1]]
        self.playerName.text = BaseData.name
        modelData = {type = PreViewType.Npc, skinId = BaseData.skin, modelId = BaseData.res, animationId = BaseData.animation_id, scale = 1}
    end
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function ChiefChallengeWindow:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(-5, 30, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end
