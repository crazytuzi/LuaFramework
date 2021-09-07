
BackpackSelectSuitItem = BackpackSelectSuitItem or BaseClass()
function BackpackSelectSuitItem:__init(origin_item)
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.gameObject:SetActive(true)
    self.ConIcon = self.transform:FindChild("ConIcon").gameObject
    --主图片
    self.SlotCon = self.ConIcon.transform:Find("SlotCon")
    self.ImgHasGot = self.ConIcon.transform:FindChild("ImgHasGot")
    self.ImgUnActive = self.ConIcon.transform:FindChild("ImgUnActive")
    self.ImgHasGot:GetComponent(RectTransform).sizeDelta = Vector2(43, 21.6)
    self.ImgUnActive:GetComponent(RectTransform).sizeDelta = Vector2(43, 21.6)
    --名字
    self.nameText = self.transform:FindChild("TxtName"):GetComponent(Text)
    --选中
    self.ImgSelected = self.transform:FindChild("ImgSelected"):GetComponent(Image)
    self.ImgSelected.gameObject:SetActive(false)

    self.Btn = self.transform:GetComponent(Button)
    --self.Btn.onClick:AddListener(function() self:DoSelect(true) end)
    self.BaseData = nil
end

function BackpackSelectSuitItem:__delete()


    if self.RewardEffect ~= nil then
        self.RewardEffect:DeleteMe()
        self.RewardEffect = nil
    end

    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
end

function BackpackSelectSuitItem:SetData(id)
    -- 传入item_id            是否已拥有 iconid
    --self.BaseData = data
    -- if self.BaseData == nil then
    --     return
    -- end
    if self.length >= 2 then
        self.timerId1 = LuaTimer.Add((self.nowIndex - 1) * 5000 + 500, self.length * 5000, function()
                if self.RewardEffect == nil then   --20478
                    self.RewardEffect = BaseUtils.ShowEffect(20478, self.transform, Vector3(0.7, 0.7, 1), Vector3(43.5, 0, -100))
                end
                self.RewardEffect:SetActive(false)
                self.RewardEffect:SetActive(true)
                if self.timerId2 ~= nil then
                    LuaTimer.Delete(self.timerId2)
                    self.timerId2 = nil
                end
                self.timerId2 = LuaTimer.Add(5000,function()
                    if self.RewardEffect ~= nil then
                        self.RewardEffect:SetActive(false)
                    end
                end)
            end)
    end

    local active = 0    -- 0  未获得   1 已获得
    local data = DataItem.data_get[id]
    if data ~= nil then
        -- local i,j = string.find(data.name,"·")
        -- if i ~= nil and j ~= nil then
        --     self.nameText.text = TI18N(string.sub(data.name, 1, i-1))
        -- else
        --     self.nameText.text = TI18N(data.name)
        -- end
        local deal_icon = DataItem.data_get[data.icon].icon
        self.nameText.text = TI18N(DataItem.data_get[deal_icon].name)

        if self.imgLoader == nil then
            local go =  self.ConIcon.transform:FindChild("SlotCon").gameObject
            self.imgLoader = SingleIconLoader.New(go)
        end
        self.imgLoader:SetSprite(SingleIconType.Item,data.icon)

        local weaponData = FashionManager.Instance.model:get_weapon_data_list()
        local beltData = FashionManager.Instance.model:get_belt_data_list()
        local suitData = FashionManager.Instance.model:get_suit_data_list()
        local wingData = WingsManager.Instance.hasGetIds
        local specialwingData = WingsManager.Instance.illusionTab
        if weaponData ~= nil and weaponData[deal_icon] ~= nil then
            --print("是武饰")
            active = weaponData[deal_icon].active
        elseif beltData ~= nil and beltData[deal_icon] ~= nil then
            --print("是头饰")
            active = beltData[deal_icon].active
        elseif suitData ~= nil and suitData[deal_icon] ~= nil then
            --print("是套装")
            active = suitData[deal_icon].active
        elseif wingData ~= nil then
            local WingId = DataItem.data_get[id].effect[1].val[1]
            if wingData[WingId] == 1 or specialwingData[WingId] ~= nil then
                active = 1
            else
                active = 0
            end
        else
            print("该装饰不存在")
        end
        if active == 0 then
            self.ImgUnActive.gameObject:SetActive(true)
            self.ImgHasGot.gameObject:SetActive(false)
        elseif active == 1 then
            self.ImgHasGot.gameObject:SetActive(true)
            self.ImgUnActive.gameObject:SetActive(false)
        end
    end
    self:DoSelect(false)
end

function BackpackSelectSuitItem:DoSelect(bool)
    self.ImgSelected.gameObject:SetActive(bool)
end

function BackpackSelectSuitItem:StopEffect()
    if self.timerId1 ~= nil then
        LuaTimer.Delete(self.timerId1)
        self.timerId1 = nil
    end

    if self.timerId2 ~= nil then
        LuaTimer.Delete(self.timerId2)
        self.timerId2 = nil
    end

    if self.RewardEffect ~= nil then
        self.RewardEffect:SetActive(false)
    end

end

function BackpackSelectSuitItem:OnlyShowEffect()
    if self.RewardEffect == nil then   --20478
        self.RewardEffect = BaseUtils.ShowEffect(20478, self.transform, Vector3(0.7, 0.7, 1), Vector3(43.5, 0, -100))
    end
    self.RewardEffect:SetActive(false)
    self.RewardEffect:SetActive(true)
end
