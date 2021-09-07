-- ------------------------
-- 英雄擂台领取宝箱
-- hosr
-- ------------------------

PlayerkillRewardPanel = PlayerkillRewardPanel or BaseClass(BasePanel)

function PlayerkillRewardPanel:__init(model)
    self.model = model
    self.name = "PlayerkillRewardPanel"
    self.itemeffect = "prefabs/effect/20153.unity3d"
    self.boxeffect = "prefabs/effect/20146.unity3d"
    self.resList = {
        {file = AssetConfig.worldchampionlevup, type = AssetType.Main},
        {file = self.itemeffect, type = AssetType.Main},
        {file = self.boxeffect, type = AssetType.Main},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.no1inworld_textures, type = AssetType.Dep},
        {file = AssetConfig.getpet_textures, type = AssetType.Dep},
    }
    self.isend = false
    self.slotList = {}
end

function PlayerkillRewardPanel:__delete()
    if itemicon ~= nil then
        for i,v in ipairs(self.itemicon) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemicon = nil
    end

    self.OnHideEvent:Fire()
    if self.preview ~= nil then
        self.preview:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function PlayerkillRewardPanel:Close()
    self.model:CloseReward()
end

-- {group = 1, index = 1, stage_item = {{20006,1},{20056,1}}, season_item = {{20006,10},{20056,10}}, model_baseid = 79640},
function PlayerkillRewardPanel:InitPanel()
    self.data = self.openArgs
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.worldchampionlevup))
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

    -- self.transform:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function() if self.isend then self.model:CloseLvupWindow() self.model:OpenCountInfoWindow(self.data) end  end)
    self.transform:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
    -- self.Title = self.transform:Find("Title")
    -- self.Title.anchoredPosition = Vector2(0, 149)
    self.Item.gameObject:SetActive(false)
    -- self.Item.anchoredPosition = Vector2(0, 45)
    self.endText = t:Find("Main/endText").gameObject
    self.Button = t:Find("Main/Button"):GetComponent(Button)
    self.Button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")

    self.Num = t:Find("Main/Num"):GetComponent(Text)
    self:SetInfo()
end


function PlayerkillRewardPanel:SetInfo()
    self.itemicon = {}
    for i,v in ipairs(self.data.stage_item) do
        local baseid = v[1]
        local slot = ItemSlot.New()
        local info = ItemData.New()
        local base = DataItem.data_get[baseid]
        info:SetBase(base)
        info.quantity = v[2]
        local extra = {inbag = false, nobutton = true}
        slot:SetAll(info, extra)
        UIUtils.AddUIChild(self.Item.gameObject, slot.gameObject)
        local itemeffectgo = GameObject.Instantiate(self.itemeffectgo)
        itemeffectgo.transform:SetParent(slot.transform)
        itemeffectgo.transform.localScale = Vector3.one
        itemeffectgo.transform.localPosition = Vector3(0, 2, -1000)
        Utils.ChangeLayersRecursively(itemeffectgo.transform, "UI")
        itemeffectgo:SetActive(true)
        table.insert(self.itemicon, slot)
    end

    local baseData = DataRencounter.data_info[self.data.index]
    self.Num.text = string.format(TI18N("<color='#00ff00'>%s-%s</color>宝箱"), baseData.rencounter, baseData.title)
    self.unit_data = DataUnit.data_unit[self.data.model_baseid]
    local setting = {
        name = "PlayerkillRewardPanel"
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

function PlayerkillRewardPanel:PreViewLoaded(composite)
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

function PlayerkillRewardPanel:OnClick()
    if self.isend then
        self:Close()
        return
    end
    self:ShowBox()
    PlayerkillManager.Instance:Send19307(self.data.index)
end

function PlayerkillRewardPanel:ShowBox()
    if self.preview ~= nil then
        self.preview:PlayAnimation("Dead2")
    end
    local X = -1
    self.Item.gameObject:SetActive(true)
    for i,v in ipairs(self.itemicon) do
        v.transform.localScale = Vector3.zero
        v.gameObject:SetActive(true)
        if i == 1 then
            self.boxeffectgo:SetActive(true)
        end
        local endcall = function()
            if i == #self.itemicon then
                self.endText:SetActive(true)
                self.Button.gameObject:SetActive(false)
                -- self.itemeffectgo:SetActive(true)
                self.isend = true
            end
        end
        Tween.Instance:MoveLocalY(v.gameObject, 80, 0.6, endcall, LeanTweenType.linear)
        if #self.itemicon%2 == 0 then
            Tween.Instance:MoveLocalX(v.gameObject, math.ceil(i/2)*35*X, 0.6, nil, LeanTweenType.linear)
        else
            Tween.Instance:MoveLocalX(v.gameObject, math.floor(i/2)*70*X, 0.6, nil, LeanTweenType.linear)
        end
        Tween.Instance:Scale(v.gameObject, Vector3(1, 1, 1), 0.5, nil, LeanTweenType.linear)
        X = X*-1
        -- print(i,v)
    end
    -- LuaTimer.Add(300, function() if self.Item ~= nil then v:SetActive(true) end end)
end