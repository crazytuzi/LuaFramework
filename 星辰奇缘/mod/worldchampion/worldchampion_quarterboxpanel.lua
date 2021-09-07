-- @author huangzefeng
-- @date 2016年6月21日,星期二

WorldChampionQuarterBoxPanel = WorldChampionQuarterBoxPanel or BaseClass(BasePanel)

function WorldChampionQuarterBoxPanel:__init(model)
    self.model = model
    self.Mgr = WorldChampionManager.Instance
    self.parent = parent
    self.name = "WorldChampionQuarterBoxPanel"
    self.itemeffect = "prefabs/effect/20153.unity3d"
    self.boxeffect = "prefabs/effect/20146.unity3d"
    self.resList = {
        {file = AssetConfig.worldchampionquarter, type = AssetType.Main},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = self.itemeffect, type = AssetType.Main},
        {file = self.boxeffect, type = AssetType.Main},
        {file = AssetConfig.getpet_textures, type = AssetType.Dep},
        -- {file = AssetConfig.classcardgroup_textures, type = AssetType.Dep},

    }
    self.slotlist = {}
-- PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(shouhuData.classes))
end

function WorldChampionQuarterBoxPanel:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}

    if self.preview ~= nil then
        self.preview:DeleteMe()
        self.preview = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionQuarterBoxPanel:InitPanel()
    self.data = self.openArgs
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionquarter))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = t

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
            self.model:CloseQuarterBoxPanel()
        else
            self.transform:Find("Main").gameObject:SetActive(false)
            self.transform:Find("Main2").gameObject:SetActive(true)
            self:ShownextLev()
        end
    end)
    self.Title = self.transform:Find("Main/Title"):GetComponent(Text)
    -- self.Title.anchoredPosition = Vector2(0, 149)
    self.Title.text = string.format(TI18N("第%s赛季结算奖励"), BaseUtils.NumToChn(1))
    self.Item.gameObject:SetActive(false)
    -- self.Item.anchoredPosition = Vector2(0, 45)
    self.endText = t:Find("Main2/endText").gameObject
    self.Button = t:Find("Main/Button"):GetComponent(Button)
    self.Num = t:Find("Main/Num"):GetComponent(Text)


    self.Title2 = self.transform:Find("Main2/Title"):GetComponent(Text)
    self.Title2.text = string.format(TI18N("第%s赛季初始头衔"), BaseUtils.NumToChn(1))
    self.CenterCircle2 = self.transform:Find("Main2/CenterCircle")
    self.c21 = self.CenterCircle2:GetChild(0)
    self.c22 = self.CenterCircle2:GetChild(1)
    self.c23 = self.CenterCircle2:GetChild(3)
    self.center = self.CenterCircle2:Find("center")
    self.c3 = self.CenterCircle2:Find("c3")
    self.bgc = self.CenterCircle2:Find("bgc")
    self.cf = self.CenterCircle2:Find("cf")
    self.headbg = self.CenterCircle2:Find("headbg")

    self.Circle = self.CenterCircle2:Find("Circle"):GetComponent(Image)
    self.Circle2 = self.CenterCircle2:Find("Circle2"):GetComponent(Image)
    self.Head = self.transform:Find("Main2/Head")
    self.bgImage = self.transform:Find("Main2/bgImage")
    self.LevText = self.transform:Find("Main2/LevText")

    self.CenterCircle2.gameObject:SetActive(false)
    self.Head.gameObject:SetActive(false)
    self.bgImage.gameObject:SetActive(false)
    self.LevText.gameObject:SetActive(false)

    self.data = {}
    self.data.assets = {{assets_id = 23032, val = 1}, {assets_id = 23039, val = 2}}
    self.data.a_rank_lev = 4
    self:SetInfo()
end

function WorldChampionQuarterBoxPanel:SetInfo()
    self.itemicon = {}
    for i,v in ipairs(self.data.assets) do
        local baseid = v.assets_id
        local slot = ItemSlot.New()
        local info = ItemData.New()
        local base = DataItem.data_get[baseid]
        info:SetBase(base)
        info.quantity = v.val
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

    local LvData = DataTournament.data_list[self.data.a_rank_lev]
    self.Num.text = string.format(TI18N("%s宝箱"), LvData.boxname)
    self.unit_data = DataUnit.data_unit[LvData.boxres]
    local setting = {
        name = "WorldChampionQuarterBoxPanel"
        ,orthographicSize = 0.28
        ,width = 256
        ,height = 256
        ,offsetY = -0.17
        ,noDrag = true
    }

    local modelData = {type = PreViewType.Npc, skinId = self.unit_data.skin, modelId = self.unit_data.res, animationId = self.unit_data.animation_id, scale = 1}
    self.preview = PreviewComposite.New(function(composite) self:PreViewLoaded(composite) end, setting, modelData)

    self.Button.onClick:AddListener(function() self:OnClick() end)
end

function WorldChampionQuarterBoxPanel:PreViewLoaded(composite)
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

function WorldChampionQuarterBoxPanel:OnClick()
    if self.isend then
        return
    end
    -- self.Mgr:Require16417()
    self:ShowBox()
end

function WorldChampionQuarterBoxPanel:ShowBox()
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
                self.Button.gameObject:SetActive(false)
                -- self.itemeffectgo:SetActive(true)
                -- self.isend = true
            end
        end
        Tween.Instance:MoveLocalY(v, 80, 0.6, endcall, LeanTweenType.linear)
        if #self.itemicon%2 == 0 then
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

function WorldChampionQuarterBoxPanel:ShownextLev()
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
        self.bgImage.gameObject:SetActive(true)
        self.LevText.gameObject:SetActive(true)


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
            Tween.Instance:Scale(self.headbg, Vector3(1, 1, 1), 0.3, function() self.endText:SetActive(true) self.isend = true end, LeanTweenType.easeOutBack)
        end)
end