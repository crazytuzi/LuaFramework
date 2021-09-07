-- @author huangzefeng
-- @date 2016年6月23日,星期四

-- 武道会第一次晋级领取奖励面板

WorldChampionLvupWindow = WorldChampionLvupWindow or BaseClass(BaseWindow)

function WorldChampionLvupWindow:__init(model)
    self.model = model
    self.name = "WorldChampionLvupWindow"
    self.Mgr = WorldChampionManager.Instance
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
    self.slotlist = {}
end

function WorldChampionLvupWindow:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.slotlist) do
        v:DeleteMe()
    end
    self.slotlist = {}
    if self.preview ~= nil then
        self.preview:DeleteMe()
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function WorldChampionLvupWindow:InitPanel()
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

    self.transform:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function() if self.isend then self.model:CloseLvupWindow() self.model:OpenCountInfoWindow(self.data) end  end)

    local btn = self.transform:Find("Main/endText").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() if self.isend then self.model:CloseLvupWindow() self.model:OpenCountInfoWindow(self.data) end  end)
    -- self.Title = self.transform:Find("Title")
    -- self.Title.anchoredPosition = Vector2(0, 149)
    self.Item.gameObject:SetActive(false)
    -- self.Item.anchoredPosition = Vector2(0, 45)
    self.endText = t:Find("Main/endText").gameObject
    self.Button = t:Find("Main/Button"):GetComponent(Button)
    self.Num = t:Find("Main/Num"):GetComponent(Text)
    self.Button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")

    self:SetInfo()
end


function WorldChampionLvupWindow:SetInfo()
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
        name = "WorldChampionLvupWindow"
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

function WorldChampionLvupWindow:PreViewLoaded(composite)
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

function WorldChampionLvupWindow:OnClick()
    if self.isend then
        return
    end
    self.Mgr:Require16417()
end

function WorldChampionLvupWindow:ShowBox()
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
                self.endText:SetActive(true)
                self.Button.gameObject:SetActive(false)
                -- self.itemeffectgo:SetActive(true)
                self.isend = true
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