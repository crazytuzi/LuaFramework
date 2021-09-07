-- @author pwj
-- @date 2019年1月14日,星期一

ScratchCardPanel = ScratchCardPanel or BaseClass(BasePanel)

function ScratchCardPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ScratchCardPanel"

    self.resList = {
        {file = AssetConfig.scratchcardpanel, type = AssetType.Main}
        ,{file = AssetConfig.scratchcardbg, type = AssetType.Main}
        ,{file = AssetConfig.cardexchangetexture, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    --self.texture2d = Texture2D(100, 100, TextureFormat.ARGB32, false)
    self.initColor = Color(232/255, 205/255, 132/255, 0)
    --self.resetColor = Color()
    --self.drawColor = Color(255/255, 230/255, 131/255, 0)
    self.alphaPixelNum = {} --透明像素基数
    self.alphaCount = 0
    self.item_min = -40
    self.item_max = 40
    self.item_holeNum = 4 * math.abs(self.item_min) * math.abs(self.item_max)
    self.colorList = {}
    self.radius = 8
    self.minX = 0
    self.minY = 0
    self.maxX = nil
    self.maxY = nil
    self.lastPos = nil  --记录是否画点还是画线
    self.firstTag = true  --是否是第一次刮奖/正在刮奖的标志
    self.consumeId = 20005
    self.rewardList = {}
    self._updateScratchcard = function() self:SetShowIcon() end
    self._updateScratchPrice = function() self:InitDraw() self:SetRewardNum() end
    self.ItemChangeHandler = function() self:SetOwnerItem() end
end

function ScratchCardPanel:__delete()
    self.OnHideEvent:Fire()
    if self.iconLoader ~= nil then
        self.iconLoader:DeleteMe()
        self.iconLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ScratchCardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.scratchcardpanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent.mainContainer.gameObject, self.gameObject)
    self.transform = t

    self.backBg = t:Find("Bg/BackGroundBg")
    local bg = GameObject.Instantiate(self:GetPrefab(AssetConfig.scratchcardbg))
    UIUtils.AddBigbg(self.backBg, bg)

    self.main = t:Find("Bg/MainPanel")
    self.timeText = self.main:Find("TimeArea/StaticText"):GetComponent(Text)
    self.ownerImg = self.main:Find("OwnerArea/Image").gameObject
    self.ownerSingleLoader = SingleIconLoader.New(self.ownerImg)

    self.ownerNum = self.main:Find("OwnerArea/Num"):GetComponent(Text)

    self.aboveImage = self.main:Find("ScratchArea/latImage"):GetComponent(RawImage)
    self.minX = 0
    self.minY = 0
    self.maxX = self.aboveImage.transform.sizeDelta.x
    self.maxY = self.aboveImage.transform.sizeDelta.y

    self.width = self.aboveImage.transform.sizeDelta.x
    self.height = self.aboveImage.transform.sizeDelta.y
    --self.texture2d:Resize(self.width, self.height)

    self.aboveImage.gameObject:GetComponent(CustomDragButton).onBeginDrag:AddListener(function() self:OnDragStart() end)
    self.aboveImage.gameObject:GetComponent(CustomDragButton).onDrag:AddListener(function() self:OnDrag() end)
    self.aboveImage.gameObject:GetComponent(CustomDragButton).onEndDrag:AddListener(function() self:OnDrawEnd() end)

    self.lowerImage = self.main:Find("ScratchArea/PreImage/Icon"):GetComponent(Image)
    self.iconLoader = SingleIconLoader.New(self.lowerImage.gameObject)
    --self.iconLoader:SetSprite(SingleIconType.Item, 23228)

    self.straButton = self.main:Find("ScratchArea/StraButton"):GetComponent(Button)
    self.straButton.onClick:AddListener(function() self:OnStraButton() end)

    self.showArea = self.main:Find("ShowArea")

    self.container = self.showArea:Find("RectScroll/Container")
    self.cloner = self.showArea:Find("RectScroll/Container/Item")
    self.cloner.gameObject:SetActive(false)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.X, cspacing = 12, border = 2})

    local initTexture = self.assetWrapper:GetTextures(AssetConfig.cardexchangetexture, "scratchaboveimg2")
    self.byte = initTexture.texture:EncodeToPNG()
end

function ScratchCardPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ScratchCardPanel:OnOpen()
    self:RemoveListeners()
    self:AddListeners()
    CardExchangeManager.Instance:Send20469() --请求初始id
    self:InitDraw()
    self:InitData()
end

function ScratchCardPanel:OnHide()
    self:RemoveListeners()
    if self.firstTag == false then
        CardExchangeManager.Instance:Send20464(0)
        self.firstTag = true
    end
    if self.GetPriceTimer ~= nil then
        LuaTimer.Delete(self.GetPriceTimer)
        self.GetPriceTimer = nil
    end
end

function ScratchCardPanel:AddListeners()
    CardExchangeManager.Instance.updateScratchcard:AddListener(self._updateScratchcard)
    CardExchangeManager.Instance.updateScratchprice:AddListener(self._updateScratchPrice)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.ItemChangeHandler)
end

function ScratchCardPanel:RemoveListeners()
    CardExchangeManager.Instance.updateScratchcard:RemoveListener(self._updateScratchcard)
    CardExchangeManager.Instance.updateScratchprice:RemoveListener(self._updateScratchPrice)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.ItemChangeHandler)
end

function ScratchCardPanel:InitDraw()
    local width = self.aboveImage.transform.sizeDelta.x
    local height = self.aboveImage.transform.sizeDelta.y
    self.texture2d = nil
    self.texture2d = Texture2D(100, 100, TextureFormat.ARGB32, false)
    self.texture2d:Resize(self.width, self.height)
    self.texture2d:LoadImage(self.byte)
    self.texture2d:Apply()
    self.aboveImage.texture = self.texture2d
    self.firstTag = true
end

function ScratchCardPanel:InitData()
    self.firstTag = true
    self:SetTimes()
    self:SetOwnerItem()
    self:SetReward()
end


function ScratchCardPanel:SetReward()
    local reward = DataCampaign.data_list[self.campId].reward
    for i,v in pairs(reward) do
        if self.rewardList[i] == nil then
            local item = { }
            item.gameObject = GameObject.Instantiate(self.cloner.gameObject)
            item.slotParent = item.gameObject.transform:Find("Slot")
            item.num = item.gameObject.transform:Find("Num"):GetComponent(Text)
            item.slot = ItemSlot.New()
            UIUtils.AddUIChild(item.slotParent.gameObject, item.slot.gameObject)
            local itemdata = ItemData.New()
            itemdata:SetBase(DataItem.data_get[v[1]])
            item.slot:SetAll(itemdata, {inbag = false, nobutton = true, noqualitybg = true, noselect = true})
            item.slot:ShowBg(false)
            item.num.text = BackpackManager.Instance:GetItemCount(v[1])
            self.rewardList[i] = item
            self.layout:AddCell(item.gameObject)
        end
    end
end

function ScratchCardPanel:SetRewardNum()
    local reward = DataCampaign.data_list[self.campId].reward
    for i,v in pairs(reward) do
        if self.rewardList[i] ~= nil then
            local num = self.rewardList[i].num
            num.text = BackpackManager.Instance:GetItemCount(v[1])
        end
    end
end

function ScratchCardPanel:OnStraButton()
    if self.firstTag == false then
        NoticeManager.Instance:FloatTipsByString("正在刮奖中")
        return
    end
    if self:CheckHasItem() then  --检查消耗
        if self.firstTag then
            CardExchangeManager.Instance:Send20463(2) --单张
            self.firstTag = false
        end
        self:DrawAllShow()
    else
        local base_data = DataItem.data_get[self.consumeId]
        local info = { itemData = base_data, gameObject = nil }
        TipsManager.Instance:ShowItem(info)
        NoticeManager.Instance:FloatTipsByString("道具不足，请前往获得{face_1,3}")
    end

end

-- drag相关
function ScratchCardPanel:OnDragStart()
    if self.firstTag == false then
        --NoticeManager.Instance:FloatTipsByString("正在刮奖中")
        return
    end
    if self:CheckHasItem() then  --检查消耗
        if self.firstTag then
            CardExchangeManager.Instance:Send20463(1) --单张
            self.firstTag = false
        end
        self:OnDrag()
    else
        local base_data = DataItem.data_get[self.consumeId]
        local info = { itemData = base_data, gameObject = nil }
        TipsManager.Instance:ShowItem(info)
        NoticeManager.Instance:FloatTipsByString("道具不足，请前往获得{face_1,3}")
    end
end

function ScratchCardPanel:OnDrag()
    if self.firstTag then return end
    local pos = self.aboveImage.transform:InverseTransformPoint(ctx.UICamera:ScreenToWorldPoint(Input.mousePosition))
    --print(pos.x.."----"..pos.y)
    if self.lastPos == nil then
        self:DrawPoint(pos.x + self.width / 2, pos.y + self.height / 2)
    else
        self:DrawLine(pos.x + self.width / 2, pos.y + self.height / 2, self.lastPos.x + self.width / 2, self.lastPos.y + self.height / 2)
    end
    self.lastPos = pos
end

function ScratchCardPanel:OnDrawEnd()
    --检查
    self:OnDrag()
    if self.alphaCount / self.item_holeNum >= 0.6 then
        self:DrawAllShow()
        self.alphaCount = 0
    end
    self.lastPos = nil
end

function ScratchCardPanel:Reset()
    --重置初始状态
    self.lastPos = nil
    self:InitDraw()
end

--刮完后的处理
function ScratchCardPanel:DrawAllShow()
    local width = self.aboveImage.transform.sizeDelta.x
    local height = self.aboveImage.transform.sizeDelta.y

    for i = 1, width do
        for j = 1, height do
            local originColor = self.texture2d:GetPixel(i, j)
            originColor.a = 0
            self.texture2d:SetPixel(i, j, originColor)
        end
    end
    self.texture2d:Apply()
    self.GetPriceTimer = LuaTimer.Add(1000, function() CardExchangeManager.Instance:Send20464(0) CardExchangeManager.Instance:Send20469() end)
end

function ScratchCardPanel:DrawPoint(x, y)
    local minX = x - self.radius
    if minX < self.minX then minX = self.minX end
    local minY = y - self.radius
    if minY < self.minY then minY = self.minY end
    local maxX = x + self.radius
    if maxX > self.maxX then maxX = self.maxX end
    local maxY = y + self.radius
    if maxY > self.maxY then maxY = self.maxY end
    local resColor = nil
    for i = minX, maxX do
        for j = minY, maxY do
            if (i-x)*(i-x) + (j-y)*(j-y) <= self.radius * self.radius then
                local originColor = self.texture2d:GetPixel(i, j)
                if originColor.a ~= 0 then
                    self:CalcuAlphaNum(i,j)
                    originColor.a = 0
                    self.texture2d:SetPixel(i, j, originColor)
                end
            end
        end
    end
    self.texture2d:Apply()
end

function ScratchCardPanel:CalcuAlphaNum(x, y)
    if (x - (self.width/2)) >= self.item_min and (x - (self.width/2)) <= self.item_max and (y - (self.height/2)) >= self.item_min and (y - (self.height/2)) <= self.item_max then
        self.alphaCount = self.alphaCount + 1
    end
end

function ScratchCardPanel:DrawLine(x, y, lx, ly)
    local minX = x - self.radius
    if minX > lx - self.radius then minX = lx - self.radius end
    if minX < self.minX then minX = self.minX end

    local minY = y - self.radius
    if minY > ly - self.radius then minY = ly - self.radius end
    if minY < self.minY then minY = self.minY end

    local maxX = x + self.radius
    if maxX < lx + self.radius then maxX = lx + self.radius end
    if maxX > self.maxX then maxX = self.maxX end

    local maxY = y + self.radius
    if maxY < ly + self.radius then maxY = ly + self.radius end
    if maxY > self.maxY then maxY = self.maxY end

    local scale = nil
    local resColor = nil
    local begin = Vector2(lx, ly)
    local direct = Vector2(x, y) - begin
    local length = direct.magnitude
    for i = minX, maxX do
        for j = minY, maxY do
            scale = Vector2.Dot((Vector2(i, j) - begin), direct) / Vector2.Dot(direct, direct)  --画的点在两点之间的投影/两点距离
            if scale >= 1 then
                if (i-x)*(i-x) + (j-y)*(j-y) <= self.radius * self.radius then
                    -- resColor = self.texture2d:GetPixel(i, j)
                    -- resColor.a = 0
                    -- self.texture2d:SetPixel(i, j, resColor)
                    local originColor = self.texture2d:GetPixel(i, j)
                    if originColor.a ~= 0 then
                        self:CalcuAlphaNum(i,j)
                        originColor.a = 0
                        self.texture2d:SetPixel(i, j, originColor)
                    end
                end
            elseif scale <= 0 then
                if (i-lx)*(i-lx) + (j-ly)*(j-ly) <= self.radius * self.radius then
                    local originColor = self.texture2d:GetPixel(i, j)
                    if originColor.a ~= 0 then
                        self:CalcuAlphaNum(i,j)
                        originColor.a = 0
                        self.texture2d:SetPixel(i, j, originColor)
                    end
                end
            else
                if (i-lx)*(i-lx) + (j-ly)*(j-ly) - scale * scale * length * length <= self.radius * self.radius then
                    -- 1 - sin平方 = cos平方
                    -- (i-lx)*(i-lx) + (j-ly)*(j-ly) 点与起始点的距离
                    local originColor = self.texture2d:GetPixel(i, j)
                    if originColor.a ~= 0 then
                        self:CalcuAlphaNum(i,j)
                        originColor.a = 0
                        self.texture2d:SetPixel(i, j, originColor)
                    end
                end
            end
        end
    end
    self.texture2d:Apply()
end

function ScratchCardPanel:SetShowIcon()
    local showIconId = DataItem.data_get[self.model.preStoreId].icon
    self.iconLoader:SetSprite(SingleIconType.Item, showIconId)
end

function ScratchCardPanel:SetTimes()
    local baseData = DataCampaign.data_list[self.campId]
    local endTime = baseData.cli_end_time[1]
    local startTime = baseData.cli_start_time[1]
    self.timeText.text = string.format("活动时间：%s-%s",
        string.format("%s月%s日", tostring(startTime[2]),tostring(startTime[3])),
        string.format("%s月%s日", tostring(endTime[2]),tostring(endTime[3])))
end

function ScratchCardPanel:SetOwnerItem()
    local baseData = DataCampaign.data_list[self.campId]
    self.consumeId = baseData.loss_items[1][1]
    self.ownerNum.text = BackpackManager.Instance:GetItemCount(self.consumeId)
    self.ownerSingleLoader:SetSprite(SingleIconType.Item, DataItem.data_get[self.consumeId].icon)
end

function ScratchCardPanel:CheckHasItem()
    if BackpackManager.Instance:GetItemCount(self.consumeId) > 0 then
        return true
    else
        return false
    end
end


