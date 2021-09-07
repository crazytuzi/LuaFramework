-- ------------------------------------
-- 诸神之战 下拉选择
-- hosr
-- ------------------------------------

GodsWarFightSelectPanel = GodsWarFightSelectPanel or BaseClass(BasePanel)

function GodsWarFightSelectPanel:__init(model, parent, type)
	self.model = model
	self.parent = parent
    self.path = AssetConfig.godswarfightselect
    if type == 1 or type == 2 then
        self.path = AssetConfig.godswarfightselect1
    else if type == 3 then
        self.path = AssetConfig.godswarfightselect2
        end
    end
    self.resList = {
        {file = self.path, type = AssetType.Main},
    }

    self.btnList = { }
end

function GodsWarFightSelectPanel:__delete()
end

function GodsWarFightSelectPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "GodsWarFightSelectPanel"
    UIUtils.AddUIChild(self.parent.gameObject, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    -- local main = self.transform:Find("Main")
    -- for i = 1, 4 do
    -- 	local item = main:GetChild(i - 1).gameObject
    -- 	local index = i
    -- 	item:GetComponent(Button).onClick:AddListener(function() self:Click(index) end)
    -- end

    self.Main = self.transform:Find("Main"):GetComponent(RectTransform)
    self.scroll = self.transform:Find("Main/scroll") 
    self.scroll_content = self.transform:Find("Main/scroll/scroll_content")
    self.btn = self.transform:Find("Main/scroll/scroll_content/btn").gameObject
    self.btn:SetActive(false)
    if self.layout == nil then
        self.layout = LuaBoxLayout.New(self.scroll_content, { axis = BoxLayoutAxis.Y, scrollRect = self.scroll, border = 2 })
    end
    self:InitList()
end

function GodsWarFightSelectPanel:InitList()
    local groupNum = GodsWarEumn.GroupNum()
    for index = 1, groupNum do
        if  self.btnList[index] == nil then
            self.btnList[index] = GameObject.Instantiate(self.btn)
            self.btnList[index]:SetActive(true)
            self.btnList[index].name = tostring(index)
            self.layout:AddCell(self.btnList[index])
            local txt = self.btnList[index].transform:Find("Text").gameObject:GetComponent(Text)
            txt.text = GodsWarEumn.GroupName(index)
            self.btnList[index]:GetComponent(Button).onClick:AddListener( function() self:Click(index) end)
        end
    end
    
    local sizeDelta = self.Main.sizeDelta
    local mheight = 26 + groupNum * 44
    self.Main.sizeDelta = Vector2(sizeDelta.x, mheight)
end

function GodsWarFightSelectPanel:Close()
	GodsWarManager.Instance.model:CloseSelect()
end

function GodsWarFightSelectPanel:Click(index)
	EventMgr.Instance:Fire(event_name.godswar_select_update, index)
	self:Close()
end