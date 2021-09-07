-- @author huangzefeng
-- @date 2016年6月21日,星期二

WorldChampionQuarterPanel = WorldChampionQuarterPanel or BaseClass(BasePanel)

function WorldChampionQuarterPanel:__init(model)
    self.model = model
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.name = "WorldChampionQuarterPanel"
    self.itemeffect = "prefabs/effect/20153.unity3d"
    self.boxeffect = "prefabs/effect/20146.unity3d"
    self.resList = {
        {file = AssetConfig.worldchampionquarter, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = self.itemeffect, type = AssetType.Main},
        {file = self.boxeffect, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.getpet_textures, type = AssetType.Dep},
        -- {file = AssetConfig.classcardgroup_textures, type = AssetType.Dep},

    }
    self.firstend = false
    self.rotateid = nil
    self.slotlist = {}
-- PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(shouhuData.classes))
end

function WorldChampionQuarterPanel:__delete()
    if self.rotateid ~= nil then
        Tween.Instance:Cancel(self.rotateid.id)
    end
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    if self.preview ~= nil then
        self.preview:DeleteMe()
        self.preview = nil
    end
    self.slotlist = {}
    self.rotateid = nil
    self.OnHideEvent:Fire()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionQuarterPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionquarter))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

    self.data = self.openArgs
    --BaseUtils.dump(self.data,"界面内结构")
    -- self.data = {
    --     rewarded = 0,
    --     final_reward = {
    --         [1] = {
    --             item_id = 20006,
    --             num = 12,
    --         },
    --     },
    --     reward_lev = 2,
    --     season_id = 2,
    --     new_lev = 2,
    -- }

    self.Title = self.transform:Find("Main/Title"):GetComponent(Text)
    self.Item = t:Find("Main/Item")
    self.CenterCircle = self.transform:Find("Main/CenterCircle")
    self.itemeffectgo = GameObject.Instantiate(self:GetPrefab(self.itemeffect))
        self.itemeffectgo.transform:SetParent(self.Item)
        self.itemeffectgo.transform.localScale = Vector3.one
        self.itemeffectgo.transform.localPosition = Vector3(0, 12, -1000)
        Utils.ChangeLayersRecursively(self.itemeffectgo.transform, "UI")
        self.itemeffectgo:SetActive(false)

    self.boxeffectgo = GameObject.Instantiate(self:GetPrefab(self.boxeffect))
    self.boxeffectgo.transform:SetParent(self.CenterCircle)
    self.boxeffectgo.transform.localScale = Vector3.one
    self.boxeffectgo.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.boxeffectgo.transform, "UI")
    self.boxeffectgo:SetActive(false)

    self.transform:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function()
        if self.isend then
            self.model:CloseQuarterPanel()
        elseif self.firstend then
            local endfunc = function()
                self.transform:Find("Main").gameObject:SetActive(false)
                self.transform:Find("Main2").gameObject:SetActive(true)
                self:StarAnimate()
            end
            -- Tween.Instance:MoveLocalX(self.transform:Find("Main").gameObject, -650, 0.6, endfunc, LeanTweenType.easeInBack)
            Tween.Instance:Scale(self.transform:Find("Main").gameObject, Vector3.zero, 0.3, endfunc, LeanTweenType.easeInBack)
        end
    end)
    -- self.Title = self.transform:Find("Title")
    -- self.Title.anchoredPosition = Vector2(0, 149)
    self.Item.gameObject:SetActive(false)
    -- self.Item.anchoredPosition = Vector2(0, 45)
    self.endText1 = t:Find("Main/endText"):GetComponent(Text)
    self.Button = t:Find("Main/Button"):GetComponent(Button)
    self.Num = t:Find("Main/Num"):GetComponent(Text)

    self.Title2 = self.transform:Find("Main2/Title"):GetComponent(Text)
    self.CenterCircle2 = self.transform:Find("Main2/CenterCircle")
    self.c21 = self.CenterCircle2:GetChild(0)
    self.c22 = self.CenterCircle2:GetChild(1)
    self.c23 = self.CenterCircle2:GetChild(3)
    self.center = self.CenterCircle2:Find("center")
    self.c3 = self.CenterCircle2:Find("c3")
    self.bgc = self.CenterCircle2:Find("bgc")
    self.cf = self.CenterCircle2:Find("cf")
    self.headbg = self.CenterCircle2:Find("headbg")
    self.endText2 = t:Find("Main2/endText"):GetComponent(Text)

    self.Circle = self.CenterCircle2:Find("Circle"):GetComponent(Image)
    self.Circle2 = self.CenterCircle2:Find("Circle2"):GetComponent(Image)
    self.Head = self.transform:Find("Main2/Head")
    self.bgImage = self.transform:Find("Main2/bgImage")
    self.LevText = self.transform:Find("Main2/LevText"):GetComponent(Text)

    self:SetInfo()
end


function WorldChampionQuarterPanel:SetInfo()
    self.itemicon = {}
    for i,v in ipairs(self.data.final_reward) do
        local baseid = v.item_id
        local slot = ItemSlot.New()
        local info = ItemData.New()
        local base = DataItem.data_get[baseid]
        info:SetBase(base)
        info.quantity = v.num
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)
        table.insert(self.slotlist, slot)
        UIUtils.AddUIChild(self.Item.gameObject, slot.gameObject)
        local itemeffectgo = GameObject.Instantiate(self.itemeffectgo)
        itemeffectgo.transform:SetParent(slot.transform)
        itemeffectgo.transform.localScale = Vector3.one
        itemeffectgo.transform.localPosition = Vector3(0, 2, -1000)
        Utils.ChangeLayersRecursively(itemeffectgo.transform, "UI")
        itemeffectgo:SetActive(true)
        table.insert(self.itemicon, slot.gameObject)
    end

    local LvData = DataTournament.data_list[self.data.reward_lev]
    self.Num.text = string.format(TI18N("%s宝箱"), LvData.boxname)
    self.unit_data = DataUnit.data_unit[LvData.boxres]
    local setting = {
        name = "WorldChampionQuarterPanel"
        ,orthographicSize = 0.28
        ,width = 256
        ,height = 256
        ,offsetY = -0.17
        ,noDrag = true
    }
    self.Title.text = string.format(TI18N("第%s赛季结算奖励"), BaseUtils.NumToChn(self.data.season_id-1))
    self.Title2.text = string.format(TI18N("第%s赛季初始头衔"), BaseUtils.NumToChn(self.data.season_id))
    local modelData = {type = PreViewType.Npc, skinId = self.unit_data.skin, modelId = self.unit_data.res, animationId = self.unit_data.animation_id, scale = 1}
    self.preview = PreviewComposite.New(function(composite) self:PreViewLoaded(composite) end, setting, modelData)

    self.Button.onClick:AddListener(function() self:OnClick() end)
    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.Head:GetComponent(Image).gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet,LvData.icon)
    -- self.Head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(LvData.icon), LvData.icon)
    self.transform:Find("Main").localScale = Vector3.zero
    Tween.Instance:Scale(self.transform:Find("Main").gameObject, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeInOutBack)
end

function WorldChampionQuarterPanel:PreViewLoaded(composite)
    local rawImage = composite.rawImage
    if rawImage ~= nil then
        rawImage.transform:SetParent(self.CenterCircle)
        rawImage.transform.localPosition = Vector3(0, 39, 0)
        rawImage.transform.localScale = Vector3(1, 1, 1)
        composite.tpose.transform:Rotate(Vector3(350,340,5))
        rawImage.transform.sizeDelta = Vector2(256, 256)
        local btn = rawImage:AddComponent(Button)
        btn.onClick:AddListener(function() self:OnClick() end)
        composite:PlayAnimation("Stand2")
    end

end

function WorldChampionQuarterPanel:OnClick()
    if self.isend then
        return
    end
    self.Mgr:Require16422()
    -- self:ShowBox()
end

function WorldChampionQuarterPanel:ShowBox()
    if self.preview ~= nil then
        self.preview:PlayAnimation("Dead2")
    end
    local X = -1
    self.Item.gameObject:SetActive(true)
    for i,v in ipairs(self.itemicon) do
        v.transform.localScale = Vector3.zero
        v:SetActive(true)
        if i == 1 then
            self.boxeffectgo:SetActive(true)
        end
        local endcall = function()
            if i == #self.itemicon then
                self.endText1.text = TI18N("--点击空白处--")
                self.Button.gameObject:SetActive(false)
                -- self.itemeffectgo:SetActive(true)
                self.firstend = true
            end
        end
        Tween.Instance:MoveLocalY(v, 80, 0.6, endcall, LeanTweenType.linear)
        if #self.itemicon%2  == 0 then
            Tween.Instance:MoveLocalX(v, math.ceil(i/2)*35*X, 0.6, nil, LeanTweenType.linear)
        else
            Tween.Instance:MoveLocalX(v, math.floor(i/2)*70*X, 0.6, nil, LeanTweenType.linear)
        end
        Tween.Instance:Scale(v, Vector3(1, 1, 1), 0.5, nil, LeanTweenType.linear)
        X = X*-1
        -- print(i,v)
    end
    -- LuaTimer.Add(300, function() if self.Item ~= nil then v:SetActive(true) end end)
end


function WorldChampionQuarterPanel:StarAnimate()
    self.CenterCircle2.gameObject:SetActive(false)
    self.Head.gameObject:SetActive(false)
    self.bgImage.gameObject:SetActive(false)
    self.LevText.gameObject:SetActive(false)

    local endpos = self.Title2.transform.localPosition
    self.Title2.transform.localPosition = Vector3(0, 336, 0)

    local endfunc = function()
        local cfg_data = DataTournament.data_list[self.data.new_lev]
        self.LevText.text = cfg_data.name
        self.bgImage.gameObject:SetActive(true)
        self.LevText.gameObject:SetActive(true)
        self.endText2.text = TI18N("--点击空白处关闭--")
        self.isend = true
    end
    self.rotateid = Tween.Instance:Rotate(self.c3, 359, 5, function() print("旋转结束") end, LeanTweenType.linear):setLoopClamp()
    self.tween3 = function()
        if BaseUtils.isnull(self.Head) then
            return
        end
        -- self.CenterCircle.localScale = Vector3.zero
        self.c21.localScale = Vector3.zero
        self.c22.localScale = Vector3.zero
        self.c23.localScale = Vector3.zero
        self.center.localScale = Vector3.zero
        self.c3.localScale = Vector3.zero
        self.bgc.localScale = Vector3.zero
        self.cf.localScale = Vector3.zero
        self.headbg.localScale = Vector3.zero
        self.CenterCircle2.gameObject:SetActive(true)
        self.Head.gameObject:SetActive(true)


        Tween.Instance:Scale(self.c21, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.c22, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.c23, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        Tween.Instance:Scale(self.center, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        -- LuaTimer.Add(200,function()
        -- end)
        LuaTimer.Add(300,function()
            Tween.Instance:Scale(self.c3, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
        end)
        LuaTimer.Add(500,function()
            Tween.Instance:Scale(self.cf, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(self.bgc, Vector3(1, 1, 1), 0.3, function()end, LeanTweenType.easeOutBack)
            Tween.Instance:Scale(self.headbg, Vector3(1, 1, 1), 0.3, endfunc, LeanTweenType.easeOutBack)
        end)
    end

    self.tween2 = function()
        if BaseUtils.isnull(self.Title2) then
            return
        end
        Tween.Instance:MoveLocalY(self.Title2.gameObject, endpos.y, 0.3, self.tween3, LeanTweenType.easeOutBack)
    end
    self.tween2()
    -- Tween.Instance:Scale(self.TitleImage, Vector3(1, 1, 1), 0.8, tween2, LeanTweenType.easeOutBack)
end