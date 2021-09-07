-- 图片组
ImageSpriteGroup = ImageSpriteGroup or BaseClass()

function ImageSpriteGroup:__init(parent, prefix, prefixList, suffixList)
    self.combatMgr = CombatManager.Instance
    self.assetWrapper = self.combatMgr.assetWrapper
    self.parent = parent
    self.prefix = prefix
    self.prefixList = {}
    self.numstrList = {}
    if prefixList ~= nil then
        self.prefixList = prefixList
    end
    self.suffixList = {}
    if suffixList ~= nil then
        self.suffixList = suffixList
    end

    self.span = -4
    if prefix == "Num4_" then
        self.span = -5
    elseif prefix == "Num8_" then
        self.span = 0
    end
    self.list = {}
    self.dict = {}
    self.container = parent.transform:Find("DigitContainer")
    if self.container == nil then
        self.container = GameObject("DigitContainer")
        self.container:AddComponent(RectTransform)
        self.container.transform:SetParent(parent.transform)
    end
    self.container.transform.localScale = Vector3(1, 1, 1)

    self:InitGameObject(self.container)
    self.needRelease = false
end

function ImageSpriteGroup:InitGameObject(gameObject)
    -- print("加载初始化num")
    local rect = gameObject:GetComponent(RectTransform)
    rect.localPosition = Vector3(0, 0, 0)
    rect.localScale = Vector3(1, 1, 1)
end


function ImageSpriteGroup:SetNum(num)
    if self.needRelease then
        self:Release()
    end
    self.needRelease = true

    local total = 0
    for _, prefxObj in ipairs(self.prefixList) do
        table.insert(self.list, prefxObj)
        prefxObj.transform:SetParent(self.container.transform)
        prefxObj.transform.localScale = Vector3(1, 1, 1)
        -- total = total + prefxObj:GetComponent(Image).sprite.textureRect.width
        total = total + prefxObj.transform.sizeDelta.x
        total = total + self.span
    end
    if num ~= nil then
        num = math.ceil(num)
        local numstr = tostring(num)
        for file in string.gmatch(numstr, "%d") do
            local number = self:CreateNum(self.prefix, file)
            number.transform:SetParent(self.container.transform)
            number.transform.localScale = Vector3(1, 1, 1)
            table.insert(self.list, number)
            local sSprite = number:GetComponent(Image).sprite
            total = total + sSprite.textureRect.width
            total = total + self.span
        end
    end
    for _, suffix in ipairs(self.suffixList) do
        table.insert(self.list, suffix)
        if BaseUtils.isnull(self.container) or BaseUtils.isnull(suffix) then
        else
            suffix.transform:SetParent(self.container.transform)
            total = total + suffix:GetComponent(Image).sprite.textureRect.width
            total = total + self.span
        end
    end
    if total > 0 then
        total = total - self.span
    end

    local middle = total / 2
    local offset = 0
    local isFirst = true
    if #self.list == 2 then
        local fGame = self.list[1]
        local sGame = self.list[2]
        local fw = fGame:GetComponent(Image).sprite.textureRect.width
        local sw = sGame:GetComponent(Image).sprite.textureRect.width
        fGame:GetComponent(RectTransform).localPosition = Vector3((0 - (fw + self.span) / 2), 0, 0)
        sGame:GetComponent(RectTransform).localPosition = Vector3((sw + self.span) / 2, 0, 0)
    else
        for _, item in ipairs(self.list) do
            -- local width = item:GetComponent(Image).sprite.textureRect.width
            local width = item.transform.sizeDelta.x
            local rect = item:GetComponent(RectTransform)
            if isFirst then
                offset = offset + width / 2
                rect.localPosition = Vector3(offset - middle, 0, 0)
                offset = offset + width / 2
                isFirst = false
            else
                offset = offset + width / 2 + self.span
                rect.localPosition = Vector3(offset - middle, 0, 0)
                offset = offset + width / 2
            end
        end
    end
end

function ImageSpriteGroup:CreateNum(prefix, file)
    local key = prefix..tostring(file)
    -- local number  = CombatManager.Instance.objPool:Pop(key)
    local number  = GoPoolManager.Instance:Borrow(key, GoPoolType.Number)
    if number == nil then
        number  = GameObject("Number" .. file)
        number.transform:SetParent(self.container.transform)
        local rect = number:AddComponent(RectTransform)
        local IMG = number:AddComponent(Image)
        local sSprite = self:GetSprite(prefix, file)
        IMG.sprite = sSprite
        IMG:SetNativeSize()
        if rect.sizeDelta.x > 100 then
            rect.sizeDelta = Vector2(rect.sizeDelta.x/100, rect.sizeDelta.y/100)
        end
    else
        number:GetComponent(Image).color = Color.white
        number.transform:SetParent(self.container.transform)
    end
    -- local IMG = number:GetComponent(Image)
    table.insert(self.numstrList, {id = key, go = number})
    self:InitGameObject(number)
    return number
end

function ImageSpriteGroup:GetSprite(prefix, number)
    if self.dict[numstr] ~= nil then
        return self.dict[number]
    else
        local index = 3
        local resPath = "textures/bignum/maxnum%s.unity3d"
        if prefix == "Num3_" then
            resPath = string.format(resPath, "3")
            index = 3
        elseif prefix == "Num4_" then
            resPath = string.format(resPath, "4")
            index = 4
            -- resPath = AssetConfig.number_icon_4
        elseif prefix == "Num5_" then
            index = 5
            resPath = string.format(resPath, "5")
            -- resPath = AssetConfig.number_icon_5
        elseif prefix == "Num6_" then
            index = 6
            resPath = string.format(resPath, "6")
            -- resPath = AssetConfig.number_icon_6
        elseif prefix == "Num7_" then
            index = 7
            resPath = string.format(resPath, "7")
            -- resPath = AssetConfig.number_icon_7
        elseif prefix == "Num8_" then
            index = 8
            resPath = string.format(resPath, "8")
            -- resPath = AssetConfig.number_icon_8
        elseif prefix == "Num9_" then
            index = 9
            resPath = string.format(resPath, "9")
            -- resPath = AssetConfig.number_icon_9
        elseif prefix == "Num14_" then
            index = 14
            resPath = string.format(resPath, "14")
            -- resPath = AssetConfig.number_icon_14
        end
        -- local sprites = self.assetWrapper:GetTextures(resPath)
        -- BaseUtils.dump(sprites,"(-(工)-)!!!!!!!!!!!!!!!!")
        -- print(sprites)
        -- print(sprites[2].name)
        -- local sprite
        local strindex = prefix .. tostring(number)
        -- for i,v in ipairs(sprites) do
        --     if strindex == v.name then
        --         sprite = v
        --     end
        -- end
        -- local sprite = self.assetWrapper:GetSprite(resPath, prefix .. tostring(number))
        -- local sprite = nil
        if self.assetWrapper ~= nil then
            self.dict[number] = PreloadManager.Instance:GetTextures(resPath, strindex)
        else
            self.dict[number] =  Sprite.Create(Texture2D.blackTexture, Rect(0, 0, 4, 4), Vector2(0.5, 0.5), 1)
        end
        -- sprites = nil
        return self.dict[number]
    end
end

function ImageSpriteGroup:Release()
    for i,v in ipairs(self.numstrList) do
        -- CombatManager.Instance.objPool:Push(v.go, v.id)
        GoPoolManager.Instance:Return(v.go, v.id, GoPoolType.Number)
    end
    -- for _, val in ipairs(self.list) do
    --     GameObject.DestroyImmediate(val)
    -- end
    self.numstrList = {}
    self.list = {}
end
