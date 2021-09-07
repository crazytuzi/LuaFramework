TowerEndWindow = TowerEndWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function TowerEndWindow:__init(model)
    self.model = model

    self.name = "TowerEndWindow"
    self.dunMgr = self.model.dunMgr
    self.Type = {
        normal = 1,
        rare = 2,
    }
    self.resList = {
        {file = AssetConfig.towerend, type = AssetType.Main}
    }
    self.iconloader = {}
    self.hasget = false
end



function TowerEndWindow:__delete()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.hasget == false then
        self.dunMgr:Require14304(1)
    end
    self:ClearDepAsset()
end

function TowerEndWindow:InitPanel()
    self.opentime = Time.time
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.towerend))
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

function TowerEndWindow:OnClose()
    TipsManager.Instance.model:Closetips()
    if Time.time - self.opentime > 3 then
        self.model:CloseTower()
    end
end

function TowerEndWindow:AddTips(go, base_id)
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

function TowerEndWindow:InitBox(_type)
    if _type == self.Type.normal then
        for i = 1,3 do
            local location = Vector3((i-2)*150, 0, 0)
            local box = GameObject.Instantiate(self.normalbox.gameObject)
            box.gameObject.name = tostring(i)
            UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
            box.transform.localPosition = location
            self:CloseBox(box.transform, i)
        end
    else
        for i = 1,3 do
            local location = Vector3((i-2)*150, 0, 0)
            local box = GameObject.Instantiate(self.rarebox.gameObject)
            box.gameObject.name = tostring(i)
            UIUtils.AddUIChild(self.Con.gameObject, box.gameObject)
            box.transform.localPosition = location
            self:CloseBox(box.transform, i)
        end
    end
end

function TowerEndWindow:CloseBox(boxTs, index)
    local callback = function ()  self.dunMgr:Require14304(index)   end
    boxTs:Find("Close").gameObject:SetActive(true)
    boxTs:Find("Open").gameObject:SetActive(false)
    boxTs:Find("Item").gameObject:SetActive(false)
    boxTs:GetComponent(Button).onClick:RemoveAllListeners()
    boxTs:GetComponent(Button).onClick:AddListener(function ()        self:DuangEffect(boxTs,callback)    end)
end

function TowerEndWindow:OpenBox(index, data)
    self.hasget = true
    if self.Con == nil then
        return
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
    LuaTimer.Add(3000, function () if self.gameObject ~= nil then self:OnClose() end end)
end

function TowerEndWindow:DuangEffect(target, callback)
    local second = function () Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one, 0.5, function() end , LeanTweenType.easeOutElastic)   end
    local descr1 = Tween.Instance:Scale(target:GetComponent(RectTransform), Vector3.one*0.7, 0.2, function() second() callback() end, LeanTweenType.linear)
end
