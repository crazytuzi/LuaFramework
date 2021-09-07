TalismanAborbItem = TalismanAborbItem or BaseClass()

function TalismanAborbItem:__init(model, gameObject, type)
    -- 1：身上的  2：选中要吃掉的
    self.type = type
    self.model = model
    self.gameObject = gameObject

    self.canEat = false
    self.hasAttr = false

    self:InitPanel()
end

function TalismanAborbItem:__delete()
    self.model = nil
    self.gameObject = nil
end

function TalismanAborbItem:InitPanel()
    self.transform = self.gameObject.transform
    local t = self.transform
    self.selectObj = t:Find("Select").gameObject
    self.selectObj:SetActive(false)
    self.tick = t:Find("Toggle/Tick").gameObject
    self.text = t:Find("Toggle/Bg/Text"):GetComponent(Text)
    self.desc = t:Find("Toggle/Bg/Desc"):GetComponent(Text)
    self.desc.text = ""
    self.lock = t:Find("Toggle/Lock").gameObject
    t:GetComponent(Button).onClick:AddListener(function() self:OnClick() end)
end

function TalismanAborbItem:SetData(data)
    self.data = data
    self.canEat = false
    self.hasAttr = false
    self.gameObject:SetActive(true)
    if data.name == nil then
        self.text.text = TI18N("升星后可开启")
        self.tick:SetActive(false)
        self.lock:SetActive(true)
    else
        if KvData.attr_name_show[data.name] == nil then
            if self.type == 1 then
                self.canEat = true
                self.text.text = TI18N("可洗炼")
            else
                self.gameObject:SetActive(false)
            end
        else
            self.hasAttr = true
            local lev = TalismanEumn.DecodeFlag(data.flag, 2)
            local mark = TalismanEumn.DecodeFlag(data.flag, 3)
            if lev == 6 then
                self.text.text = string.format("<color='#dc83f5'>%s</color>", KvData.GetAttrStringNoColor(data.name, data.val, mark))
                self.desc.text = TI18N("<color='#dc83f5'>完美</color>")
            else
                self.text.text = string.format("<color='#00ffff'>%s</color>", KvData.GetAttrStringNoColor(data.name, data.val, mark))
                self.desc.text = string.format(TI18N("<color='#00ffff'>%s星</color>"), lev)
            end
        end
        self.lock:SetActive(false)
        self.tick:SetActive(false)
    end
end

function TalismanAborbItem:Select(bool)
    self.tick:SetActive(bool)
    self.selectObj:SetActive(bool)
end

function TalismanAborbItem:OnClick()
    if self.clickCallback ~= nil and self.data ~= nil and self.data.name ~= nil then
        self.clickCallback()
    end
end

