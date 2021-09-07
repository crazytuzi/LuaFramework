-- ----------------------------------------------------------
-- UI - 元素副本 地图面板
-- ljh 20161215
-- ----------------------------------------------------------
ElementDungeonMapPanel = ElementDungeonMapPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function ElementDungeonMapPanel:__init(index, parent)
	self.index = index
	self.parent = parent
    self.model = parent.model

	self.mainPath = string.format(AssetConfig.elementdungeon_map, index)
	self.subPath = string.format(AssetConfig.elementdungeon_map_bigatlas, index)
	self.resList = {
        {file = self.mainPath, type = AssetType.Main}
        , {file = self.subPath, type = AssetType.Main}
        , {file = AssetConfig.elementdungeon_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

	------------------------------------------------
	self.lineList = {}
	self.itemList = {}

	self.modelImageList = {}
	self.nameItemList = {}
	self.nameTextList = {}
	self.stateList = {}
	self.stateTextList = {}

    ------------------------------------------------

	self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function ElementDungeonMapPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(self.mainPath))
    self.gameObject.name = "ElementDungeonMapPanel"
    self.gameObject.transform:SetParent(self.parent.mapContainer.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    local bg = GameObject.Instantiate(self:GetPrefab(self.subPath))
    bg.transform:SetParent(self.transform)
    bg.transform.localPosition = Vector3(0, 0, 0)
    bg.transform.localScale = Vector3(1, 1, 1)
    bg.transform:SetAsFirstSibling()

    local bgRect = bg:GetComponent(RectTransform)
    self.transform:GetComponent(RectTransform).sizeDelta = Vector2(bgRect.sizeDelta.x, bgRect.sizeDelta.y)
    self.parent.mapContainer:GetComponent(RectTransform).sizeDelta = Vector2(bgRect.sizeDelta.x, bgRect.sizeDelta.y)

    self.linePanel = self.transform:Find("LinePanel")
    local len = self.linePanel.childCount
    for i=0, len-1 do
    	local line = self.linePanel.transform:GetChild(i).gameObject
    	line:SetActive(false)
    	table.insert(self.lineList, line)
    end

    self.itemPanel = self.transform:Find("ItemPanel")
	len = self.itemPanel.childCount
    for i=0, len-1 do
    	local item = self.itemPanel.transform:GetChild(i).gameObject
    	item:SetActive(false)
    	table.insert(self.itemList, item)

    	local enemyItem = GameObject.Instantiate(self.parent.cloneItem_MapPanel)
		enemyItem:SetActive(true)
		enemyItem.transform:SetParent(item.transform)
		enemyItem:GetComponent(RectTransform).localScale = Vector3.one
		enemyItem:GetComponent(RectTransform).localPosition = Vector3.zero
		local index = i + 1
		enemyItem:GetComponent(Button).onClick:AddListener(function() self:OnEnemyItemClick(index) end)

		table.insert(self.modelImageList, enemyItem.transform:Find("ModelImage").gameObject)
		local nameItem = enemyItem.transform:Find("NameItem").gameObject
		table.insert(self.nameItemList, nameItem)
		table.insert(self.nameTextList, nameItem.transform:Find("Text"):GetComponent(Text))
		local state = enemyItem.transform:Find("State").gameObject
		table.insert(self.stateList, state)
		table.insert(self.stateTextList, state.transform:Find("Text"):GetComponent(Text))
    end

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function ElementDungeonMapPanel:__delete()
    self:OnHide()

    if self.gameObject ~= nil then
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ElementDungeonMapPanel:OnShow()
    self:Update()
end

function ElementDungeonMapPanel:OnHide()
    
end

function ElementDungeonMapPanel:Update()
    if not self.init then
    	return 
    end

    self:UpdateLine()
    self:UpdateItem()
end

function ElementDungeonMapPanel:UpdateLine()
	if not self.init then
    	return 
    end
end

function ElementDungeonMapPanel:UpdateItem()
	if not self.init then
    	return 
    end

    local dataList = { 
    	{id = 1, state = 1}
    	, {id = 2, state = 1}
    	, {id = 3, state = 0}
    	, {id = 4, state = 0}
    }

    for i=1,#dataList do
	    local item = self.itemList[i]
	    local data = dataList[i]
	    if data.state == 0 then
	    	item:SetActive(false)
	    else
	    	item:SetActive(true)
	    end
	end
end

function ElementDungeonMapPanel:OnEnemyItemClick(index)
	print(index)
	local id = 1
	
	self.parent:ShowEnemyPanel(id)
end