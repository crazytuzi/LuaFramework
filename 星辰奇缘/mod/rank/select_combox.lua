SelectCombox = SelectCombox or BaseClass()

function SelectCombox:__init(gameObject, dataList, callback, setting)
    self.resPath = "prefabs/ui/rank/selectcombox.unity3d"
    self.gameObject = gameObject
    self.dataList = dataList
    self.transform = self.gameObject.transform

    if setting == nil then
        setting = {}
    end

    self.selectIndex = 1
    if setting.selectIndex ~= nil and setting.selectIndex > 0 and setting.selectIndex <= #dataList then
        self.selectIndex = setting.selectIndex  -- 默认选择的序号
    end

    self.callback = callback    -- 点击单项的回调

    self.itemlist = {}   -- 列表项
    self.isDrop = setting.isDrop or false         -- 是否默认展开
    self.maxHeight = setting.maxHeight
    self.mainString = setting.mainString

    self:InitPanel()
    self:OnClickMain(self.isDrop)
end

function SelectCombox:InitPanel()
    local t = self.transform

    self.parentRect = self.gameObject:GetComponent(RectTransform)
    self.mainText = t:Find("Main/Text"):GetComponent(Text)
    self.mainBtn = t:Find("Main"):GetComponent(Button)
    self.normal = t:Find("Main/Normal").gameObject
    self.select = t:Find("Main/Select").gameObject
    self.itemsBg = t:Find("SelectList")
    self.itemsBgRect = self.itemsBg:GetComponent(RectTransform)
    self.container = t:Find("SelectList/ScrollLayer/Container")
    self.cloner = t:Find("SelectList/ScrollLayer/Cloner").gameObject      -- item克隆体
    self.clonerRect = self.cloner:GetComponent(RectTransform)
    self.cloner:SetActive(false)

    self.mainBtn.onClick:AddListener(function() self:OnClickMain(self.isDrop) end)

    self.boxYLayout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})

    if self.mainString == nil then
        self.mainText.text = tostring(self.dataList[self.selectIndex].name)
    else
        self.mainText.text = self.mainString
    end
    self.itemsBg.gameObject:SetActive(false)
end

function SelectCombox:Layout()

    -- self.boxYLayout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 0})
    self.boxYLayout:ReSet()
    for i,v in ipairs(self.dataList) do
        local tab = self.itemlist[i]
        if tab == nil then
            tab = {}
            tab.obj = GameObject.Instantiate(self.cloner)
            tab.trans = tab.obj.transform
            tab.select = tab.trans:Find("Select").gameObject
            tab.select:SetActive(false)
            tab.text = tab.trans:Find("Text"):GetComponent(Text)
            tab.btn = tab.obj:GetComponent(Button)
            tab.btn.onClick:AddListener(function() self:ChangeTab(i) end)
            tab.obj.name = tostring(i)
            self.itemlist[i] = tab
        end
        tab.text.text = v.name
        tab.select:SetActive(self.selectIndex == i)
        self.boxYLayout:AddCell(tab.obj)
    end

    for i= #self.dataList + 1, #self.itemlist do
        sle.itemlist[i].obj:SetActive(false)
    end

    self.boxYLayout.panelRect.sizeDelta = Vector2(self.clonerRect.sizeDelta.x, self.clonerRect.sizeDelta.y * #self.dataList)
    -- self.itemsBgRect.sizeDelta = Vector2(self.clonerRect.sizeDelta.x, self.clonerRect.sizeDelta.y * #self.dataList)
end

function SelectCombox:__delete()
    if self.boxYLayout ~= nil then
        self.boxYLayout:DeleteMe()
        self.boxYLayout = nil
    end
end

function SelectCombox:SetData(dataList)
    self.dataList = dataList
    if self.isDrop then
        self:Layout()
    end
end

function SelectCombox:ChangeTab(index)
    self.itemlist[self.selectIndex].select:SetActive(false)
    self.itemlist[index].select:SetActive(false)
    self.selectIndex = index
    if self.mainString == nil then
        self.mainText.text = tostring(self.dataList[index].name)
    else
        self.mainText.text = self.mainString
    end

    if self.callback ~= nil then
        self.callback(index)
    end

    self:OnClickMain(false)
end

function SelectCombox:OnClickMain(isshow)
    self.itemsBg.gameObject:SetActive(isshow)
    self.normal:SetActive(not isshow)
    self.select:SetActive(isshow)
    if self.mainString == nil then
        self.mainText.text = tostring(self.dataList[self.selectIndex].name)
    else
        self.mainText.text = self.mainString
    end

    if isshow then
        self:Layout()
    end

    self.isDrop = not isshow
end
