-- @author 黄耀聪
-- @date 2017年8月28日, 星期一

FaceDrawPanel = FaceDrawPanel or BaseClass(BasePanel)

function FaceDrawPanel:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.name = "FaceDrawPanel"

    self.isInited = false
    self.texture2d = Texture2D(100, 100, TextureFormat.ARGB32, false)

    self.colorList = {}
    self.radius = 3
    self.maxX = nil
    self.minX = nil
    self.maxY = nil
    self.minY = nil

    self.baseId = 22453 -- 大表情包子
    self.drawColor = Color(255/255, 230/255, 131/255, 1)

    self.itemChangeListener = function()
        self:Update()
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function FaceDrawPanel:__delete()
    self.OnHideEvent:Fire()

    self.image.texture = nil
    self.texture2d = nil
    self.gameObject = nil
    self.model = nil
end

function FaceDrawPanel:InitPanel()
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t

    self.text = t:Find("Text"):GetComponent(Text)

    self.image = t:Find("Panel"):GetComponent(RawImage)
    self.image.color = Color(1, 1, 1, 1)
    -- self.image = t:Find("Panel")
    self.maxX = self.image.transform.sizeDelta.x
    self.minX = 0
    self.maxY = self.image.transform.sizeDelta.y
    self.minY = 0
    self.width = self.image.transform.sizeDelta.x
    self.height = self.image.transform.sizeDelta.y
    self.texture2d:Resize(self.width, self.height)

    -- self.image.gameObject:GetComponent(CustomDragButton).onClick:AddListener(function() print("=") self:OnDragStart() end)
    self.image.gameObject:GetComponent(CustomDragButton).onBeginDrag:AddListener(function() self:OnDragStart() end)
    self.image.gameObject:GetComponent(CustomDragButton).onDrag:AddListener(function() self:OnDrag() end)
    self.image.gameObject:GetComponent(CustomDragButton).onEndDrag:AddListener(function() self:OnDrawEnd() end)

    -- self.transform:Find("Man/Close"):GetComponent(Button).onClick:AddListener(function() self:InitDraw() end)
    self:InitEffect()
    self:InitDraw()
end

function FaceDrawPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FaceDrawPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemChangeListener)

    if not self.isInited then
        self:InitPanel()
        self.isInited = true
    end

    self:Update()
end

function FaceDrawPanel:OnHide()
    self:RemoveListeners()

    self.endEffect:SetActive(false)
end

function FaceDrawPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
end

function FaceDrawPanel:OnDrag()
    local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1, self.gameObject.transform.position.z) --执行改变位置

    local pos = self.image.transform:InverseTransformPoint(ctx.UICamera:ScreenToWorldPoint(curScreenSpace))

    if self.lastPos == nil then
        self:DrawPoint(pos.x + self.width / 2, pos.y + self.height / 2)
    else
        self:DrawLine(pos.x + self.width / 2, pos.y + self.height / 2, self.lastPos.x + self.width / 2, self.lastPos.y + self.height / 2)
    end
    -- if pos.x > -self.width/2 and pos.x < self.width/2 and pos.y > -self.height/2 and pos.y < self.height/2 then
        self.drawEffect.transform.localPosition = Vector3(pos.x, pos.y, -400)
    -- end
    self.lastPos = pos
end

function FaceDrawPanel:InitDraw()
    local width = self.image.transform.sizeDelta.x
    local height = self.image.transform.sizeDelta.y

    for i=1,width do
        self.colorList[i] = self.colorList[i] or {}
        for j=1,height do
            self.colorList[i][j] = Color(0, 0, 0, 0)
            self.texture2d:SetPixel(i, j, self.colorList[i][j])
        end
    end

    self.image.texture = self.texture2d
    self.texture2d:Apply()

    -- print(type(self.texture2d:GetPixels()))
end

function FaceDrawPanel:DrawPoint(x, y)
    local minX = x - self.radius
    if minX < self.minX then minX = self.minX end
    local minY = y - self.radius
    if minY < self.minY then minY = self.minY end
    local maxX = x + self.radius
    if maxX > self.maxX then maxX = self.maxX end
    local maxY = y + self.radius
    if maxY > self.maxY then maxY = self.maxY end

    for i=minX,maxX do
        for j=minY,maxY do
            if math.sqrt((i-x)*(i-x) + (j-y)*(j-y)) <= self.radius then
                self.texture2d:SetPixel(i, j, self.drawColor)
            end
        end
    end
    self.texture2d:Apply()
end

function FaceDrawPanel:DrawLine(x, y, lx, ly)
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
    local begin = Vector2(lx, ly)
    local direct = Vector2(x, y) - begin
    local length = direct.magnitude
    for i=minX,maxX do
        for j=minY,maxY do
            scale = Vector2.Dot((Vector2(i, j) - begin), direct) / Vector2.Dot(direct, direct)
            if scale >= 1 then
                if (i-x)*(i-x) + (j-y)*(j-y) <= self.radius * self.radius then
                    self.texture2d:SetPixel(i, j, self.drawColor)
                end
            elseif scale <= 0 then
                if (i-lx)*(i-lx) + (j-ly)*(j-ly) <= self.radius * self.radius then
                    self.texture2d:SetPixel(i, j, self.drawColor)
                end
            else
                if (i-lx)*(i-lx) + (j-ly)*(j-ly) - scale * scale * length * length <= self.radius * self.radius then
                    self.texture2d:SetPixel(i, j, self.drawColor)
                end
            end
        end
    end
    self.texture2d:Apply()
end

function FaceDrawPanel:OnDrawEnd()
    self:OnDrag()
    self.lastPos = nil

    local list = BackpackManager.Instance:GetItemByBaseid(self.baseId)
    if #list > 0 then
        -- LuaTimer.Add(1000, function() self:Cost(list[1].id) end)
        self.endEffect:SetActive(false)
        self.endEffect:SetActive(true)
        self:Cost(list[1].id)
    else
        NoticeManager.Instance:FloatTipsByString("物品不足")
    end
    self:Clean()
end

function FaceDrawPanel:OnDragStart()
    if self:CheckHasItem() then
        self:InitDraw()
        self:OnDrag()
        self.drawEffect:SetActive(true)
    end
end

function FaceDrawPanel:Cost(id)
    BackpackManager.Instance:Send10315(id, 1)
end

function FaceDrawPanel:Clean()
    self:InitDraw()
    self.lastPos = nil
    self.drawEffect:SetActive(false)
end

function FaceDrawPanel:InitEffect()
    local fun = function(effectView)
        if BaseUtils.isnull(self.gameObject) then
            return
        end

        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(self.transform:Find("EffectPanel"))
        effectObject.name = "Effect"
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -400)

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        self.drawEffect = effectView
        self.drawEffect:SetActive(false)
    end
    self.drawEffect = BaseEffectView.New({effectId = 20414, callback = fun})

    local fun2 = function(effectView)
        if BaseUtils.isnull(self.gameObject) then
            return
        end

        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(self.transform:Find("EffectPanel"))
        effectObject.name = "Effect"
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -400)

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        self.endEffect = effectView
        self.endEffect:SetActive(false)
    end
    self.endEffect = BaseEffectView.New({effectId = 20415, callback = fun2})
end

-- function FaceDrawPanel:OnDragStart()
--     self:OnDrag()
--     self.drawEffect:SetActive(true)
-- end

-- function FaceDrawPanel:OnDrag()
--     local curScreenSpace=Vector3(Input.mousePosition.x*1,Input.mousePosition.y*1, self.gameObject.transform.position.z) --执行改变位置

--     local pos = self.image.transform:InverseTransformPoint(ctx.UICamera:ScreenToWorldPoint(curScreenSpace))

--     self.drawEffect.transform.localPosition = Vector3(pos.x, pos.y, -400)
-- end

-- function FaceDrawPanel:Clean()
--     self.drawEffect:SetActive(false)
-- end

function FaceDrawPanel:Update()
    local baseData = BackpackManager.Instance:GetItemBase(self.baseId)
    local has = BackpackManager.Instance:GetItemCount(self.baseId)
    local color = "#00ff00"
    if has < 1 then
        color = "#ff0000"
    end
    self.text.text = string.format(TI18N("%s:<color='%s'>%s/1</color>"), baseData.name, color, has)
end

function FaceDrawPanel:CheckHasItem()
    if BackpackManager.Instance:GetItemCount(22453) > 1 then
        return true
    else
        local itemData = ItemData.New()
        local gameObject = self.text.gameObject
        itemData:SetBase(DataItem.data_get[22453])
        TipsManager.Instance:ShowItem({gameObject = gameObject, itemData = itemData})
    end
end