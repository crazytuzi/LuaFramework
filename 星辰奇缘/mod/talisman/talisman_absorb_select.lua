TalismanAbsorbSelect = TalismanAbsorbSelect or BaseClass(BasePanel)

function TalismanAbsorbSelect:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject

    self.itemList = {}
    self.clickCallback = nil

    self.imgLoader = {}
    
    self:InitPanel()
end

function TalismanAbsorbSelect:__delete()
    for k,v in pairs(self.imgLoader) do
        v:DeleteMe()
        v = nil
    end

    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self.gameObject = nil
end

function TalismanAbsorbSelect:InitPanel()
    self.transform = self.gameObject.transform
    self.layout = LuaBoxLayout.New(self.transform:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 10, border = 10})
    self.cloner = self.transform:Find("Scroll/Cloner").gameObject
end

function TalismanAbsorbSelect:SetData(datalist)
    datalist = datalist or {}

    self.layout:ReSet()
    self.cloner:SetActive(false)
    for i,v in ipairs(datalist) do
        local item = self.itemList[i]
        if item == nil then
            item = {}
            item.gameObject = GameObject.Instantiate(self.cloner)
            item.transform = item.gameObject.transform
            item.iconBgImg = item.transform:Find("IconBg"):GetComponent(Image)
            item.iconImg = item.transform:Find("Icon")
            item.nameText = item.transform:Find("Name"):GetComponent(Text)
            item.descText = item.transform:Find("Des"):GetComponent(Text)
            item.button = item.gameObject:GetComponent(Button)
            item.button.onClick:AddListener(function() self:OnClick(item.protoData) end)
            self.itemList[i] = item
        end
        self.layout:AddCell(item.gameObject)
        local cfgData = DataTalisman.data_get[v.base_id]
        
        if self.imgLoader[i] == nil then
            local go = item.iconImg.gameObject
            self.imgLoader[i] = SingleIconLoader.New(go)
        end
        self.imgLoader[i]:SetSprite(SingleIconType.Item, cfgData.icon)

        item.nameText.text = cfgData.name
        item.protoData = v
        item.descText.text = string.format(TI18N("评分:%s"), v.fc)
    end
    for i=#datalist + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
end

function TalismanAbsorbSelect:OnClick(data)
    if data == nil then
        return
    end
    if self.clickCallback ~= nil then
        self.clickCallback(data.id)
    end
end


