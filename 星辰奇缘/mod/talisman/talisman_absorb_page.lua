TalismanAbsorbPage = TalismanAbsorbPage or BaseClass()

function TalismanAbsorbPage:__init(model, gameObject, type, assetWrapper)
    -- 1：身上的  2：选中要吃掉的
    self.type = type
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper

    self.attrList = {}

    self.maxSelectNum = 1
    self.selectList = {}
    self.minStar = 1

    self:InitPanel()
end

function TalismanAbsorbPage:__delete()
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
    if self.setImage ~= nil then
        self.setImage.sprite = nil
    end

    self.assetWrapper = nil
    self.gameObject = nil
end

function TalismanAbsorbPage:InitPanel()
    self.transform = self.gameObject.transform

    local t = self.transform
    self.iconBgImg = t:Find("IconBg"):GetComponent(Image)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.descText = t:Find("Des"):GetComponent(Text)
    self.minusBtn = t:Find("Minus"):GetComponent(Button)
    self.setImage = t:Find("Set"):GetComponent(Image)
    self.text = t:Find("Text"):GetComponent(Text)

    self.layout = LuaBoxLayout.New(t:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 10})
    self.cloner = t:Find("Scroll/Cloner").gameObject

    self.minusBtn.onClick:AddListener(function() self:OnMinus() end)
end

function TalismanAbsorbPage:SetData(data, maxSelectNum, minStar)
    self.maxSelectNum = maxSelectNum
    self.minStar = minStar
    self.selectList = {}
    local cfgData = DataTalisman.data_get[data.base_id]
    self.nameText.text = string.format("<color='%s'>%s</color>", ColorHelper.color[cfgData.quality], TalismanEumn.FormatQualifyName(cfgData.quality, cfgData.name))
    self.descText.text = string.format(TI18N("评分:%s"), data.fc)
    self.setImage.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfgData.set_id))
    if self.imgLoader == nil then
        local go = self.transform:Find("Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, cfgData.icon)

    if self.type == 2 then
        self.text.text = string.format(TI18N("最多可选择%s条属性进行吸收"), maxSelectNum)
    end

    local datalist = {}
    for i,v in ipairs(data.attr) do
        if v.type == 9 then
            table.insert(datalist, v)
        end
    end
    table.sort(datalist, function(a,b) return TalismanEumn.DecodeFlag(a.flag, 2) > TalismanEumn.DecodeFlag(b.flag, 2) end)

    self.cloner:SetActive(false)
    self.layout:ReSet()
    for i,v in ipairs(datalist) do
        local item = self.attrList[i]
        if item == nil then
            item = TalismanAborbItem.New(self.model, GameObject.Instantiate(self.cloner), self.type)
            self.attrList[i] = item
            local j = i
            item.clickCallback = function() self:OnClick(j) end
        end
        self.layout:AddCell(item.gameObject)
        item:SetData(v)
    end
    for i=#datalist + 1, #self.attrList do
        self.attrList[i].gameObject:SetActive(false)
    end

    self.layout.panelRect.anchoredPosition = Vector2.zero

    self:DefaultSelect()
end

function TalismanAbsorbPage:DefaultSelect()
    local itemList = self:GetItemByNum(self.maxSelectNum)
    for index, item in ipairs(itemList) do
        if item ~= nil then
            item:OnClick()
        end
    end
end

function TalismanAbsorbPage:GetItemByNum(num)
    local list = {}
    local listLength = 0
    for i,v in ipairs(self.attrList) do
        if listLength < num then
            if self.type == 1 then
                if v.canEat then
                    table.insert(list, v)
                    listLength = listLength + 1
                end
            else
                if v.hasAttr then
                    table.insert(list, v)
                    listLength = listLength + 1
                end
            end
        else
            break
        end
    end
    return list
end

function TalismanAbsorbPage:OnMinus()
    if self.minusCallback ~= nil then
        self.minusCallback()
    end
end

function TalismanAbsorbPage:OnClick(index)
    if self.minStar ~= nil then
        local star = TalismanEumn.DecodeFlag((self.attrList[index] or {}).data.flag, 2)
        if star < self.minStar then
            NoticeManager.Instance:FloatTipsByString(TI18N("低于三星的低级宝物属性不可进行洗练"))
            return
        end
    end

    local popIndex = self:AddSelect(index)
    if popIndex ~= nil then
        self.attrList[popIndex]:Select(false)
    end

    if popIndex ~= index then
        self.attrList[index]:Select(true)
    end

    if self.clickCallback ~= nil then
        local attrList = {}
        for i, v in ipairs(self.selectList) do
            table.insert(attrList, (self.attrList[v] or {}).data)
        end
        self.clickCallback(attrList)
    end
end

function TalismanAbsorbPage:GetAttr()
    local list = {}
    for i, v in ipairs(self.selectList) do
        if self.attrList[v] ~= nil and self.attrList[v].data ~= nil and self.attrList[v].data.flag ~= nil then
            table.insert(list, TalismanEumn.DecodeFlag(self.attrList[v].data.flag, 1))
        end
    end
    return list
end

function TalismanAbsorbPage:AddSelect(index)
    for i, v in ipairs(self.selectList) do
        if v == index then
            return table.remove(self.selectList, i)
        end
    end

    table.insert(self.selectList, index)
    if #self.selectList > self.maxSelectNum then
        return table.remove(self.selectList, 1)
    end
end