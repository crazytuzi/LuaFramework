StarChallengeTowerEndWindow = StarChallengeTowerEndWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function StarChallengeTowerEndWindow:__init(model)
    self.model = model

    self.name = "StarChallengeTowerEndWindow"
    self.Type = {
        normal = 1,
        rare = 2,
    }
    self.resList = {
        {file = AssetConfig.starchallengetowerendwin, type = AssetType.Main}
        , {file = string.format(AssetConfig.effect, 20408), type = AssetType.Main}
    }
    self.iconloader = {}
    self.hasget = false

    self.lastIndex = 1
end



function StarChallengeTowerEndWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.hasget == false then
        StarChallengeManager.Instance:Send20204(1)
    end
    self:ClearDepAsset()
end

function StarChallengeTowerEndWindow:InitPanel()
    self.opentime = Time.time
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.starchallengetowerendwin))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.Con = self.transform:Find("Main/Con")
    self.normalbox = self.transform:Find("Main/Normal")
    self.rarebox = self.transform:Find("Main/Rare")
    self.transform:Find("bgPanel"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    -- self.transform:Find("Main/Button"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    self:InitBox(self.openArgs[1])
end

function StarChallengeTowerEndWindow:OnClose()
    TipsManager.Instance.model:Closetips()
    if Time.time - self.opentime > 3 then
        self.model:CloseTower()
    end
end

function StarChallengeTowerEndWindow:AddTips(go, base_id)
    local cell = DataItem.data_get[base_id]
    local itemdata = ItemData.New()
    itemdata:SetBase(cell)
    local btn = go.transform:GetComponent(Button) or go.transform:AddComponent(Button)
    btn.onClick:AddListener(
        function ()
            TipsManager.Instance:ShowItem({["gameObject"] = go, ["itemData"] = itemdata})
        end
    )
end

function StarChallengeTowerEndWindow:InitBox(_type)
    if _type == self.Type.normal then
        for i = 1,2 do
            local location = Vector3(120, 0, 0)
            if i == 1 then
                location = Vector3(-120, 0, 0)
            end
            local box = GameObject.Instantiate(self.normalbox.gameObject)
            box.gameObject.name = tostring(i)
            UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
            box.transform.localPosition = location
            self:CloseBox(box.transform, i)

            local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20408)))
            effect.transform:SetParent(box.transform:Find("Close"))
            effect.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(effect, "UI")
            effect.transform.localScale = Vector3.one
            effect.transform.localPosition = Vector3(0, 0, -400)
        end
    else
        for i = 1,2 do
            local location = Vector3(120, 0, 0)
            if i == 1 then
                location = Vector3(-120, 0, 0)
            end
            local box = GameObject.Instantiate(self.rarebox.gameObject)
            box.gameObject.name = tostring(i)
            UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
            box.transform.localPosition = location
            self:CloseBox(box.transform, i)

            local effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20408)))
            effect.transform:SetParent(box.transform:Find("Close"))
            effect.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(effect.transform, "UI")
            effect.transform.localScale = Vector3.one
            effect.transform.localPosition = Vector3(0, 0, -400)
        end
    end
end

function StarChallengeTowerEndWindow:CloseBox(boxTs, index)
    local callback = function () StarChallengeManager.Instance:Send20204(index)   end
    boxTs:Find("Close").gameObject:SetActive(true)
    boxTs:Find("Open").gameObject:SetActive(false)
    boxTs:Find("Item").gameObject:SetActive(false)
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:GetComponent(Button).onClick:AddListener(function ()        self:DuangEffect(boxTs,callback)    end)
end

function StarChallengeTowerEndWindow:OpenBox(index, data)
    self.hasget = true
    if self.Con == nil then
        return
    end
    if index == 3 then
        if self.lastIndex == 1 then
            index = 2
        else
            index = 1
        end
        LuaTimer.Add(3000, function () if self.gameObject ~= nil then self:OnClose() end end)
    else
        self.lastIndex = index
    end

    local boxTs = self.Con:Find(tostring(index))
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:Find("Close").gameObject:SetActive(false)
    boxTs:Find("Open").gameObject:SetActive(true)
    boxTs:Find("Item").gameObject:SetActive(true)
    local base_id = data.item_id1 ~= nil and data.item_id1 or data.item_id2
    local num = data.num1 ~= nil and data.num1 or data.num2
    local baseData = DataItem.data_get[base_id]
    local Item = boxTs:Find("Item")
    local id = Item:Find("Icon").gameObject:GetInstanceID()
    if self.iconloader[id] == nil then
        self.iconloader[id] = SingleIconLoader.New(Item:Find("Icon").gameObject)
    end
    self.iconloader[id]:SetSprite(SingleIconType.Item, baseData.icon)
    if num > 9999 then
        Item:Find("Text"):GetComponent(Text).text = string.format(TI18N("%s万"), math.floor(num/10000))
    else
        Item:Find("Text"):GetComponent(Text).text = tostring(num)
    end
    Item:Find("Text").sizeDelta = Vector2(Item:Find("Text"):GetComponent(Text).preferredWidth, 20)
    Item:Find("Imagebg").sizeDelta = Vector2(Item:Find("Text").sizeDelta.x + 5, 20)
    Item:Find("ItemName/Text"):GetComponent(Text).text = baseData.name
    Item:Find("Get").gameObject:SetActive(data.item_id1 ~= nil)
    self:AddTips(Item.gameObject, base_id)
end

function StarChallengeTowerEndWindow:DuangEffect(target, callback)
    local second = function () Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one, 0.5, function() end , LeanTweenType.easeOutElastic)   end
    local descr1 = Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one*0.7, 0.2, function() second() callback() end, LeanTweenType.linear)
end
