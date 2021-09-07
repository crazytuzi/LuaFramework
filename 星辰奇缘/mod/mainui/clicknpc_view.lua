-- 主界面 选中玩家头像
ClicknpcView = ClicknpcView or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function ClicknpcView:__init()
    self.model = model
    self.resList = {
        {file = AssetConfig.clicknpcpanel, type = AssetType.Main}
    }

    self.name = "ClicknpcView"

    self.gameObject = nil
    self.transform = nil

    self.itemobject = nil
    self.itemcontainer = nil
    self.data = nil
    self.itemList = {}

    self:LoadAssetBundleBatch()
end

function ClicknpcView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ClicknpcView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.clicknpcpanel))
    self.gameObject.name = "ClicknpcView"
    self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 1)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.gameObject:SetActive(false)

    -- self.gameObject.transform:SetAsFirstSibling()

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    self.transform = self.gameObject.transform
    self.itemcontainer = self.transform:Find("mask/ItemContainer").gameObject
    self.itemobject = self.transform:Find("mask/ItemContainer/Item").gameObject

    self:ClearMainAsset()
end

function ClicknpcView:SetData(data)
    self.data = data
    self:update()
    self.gameObject:SetActive(true)
end

function ClicknpcView:update()
    for key,value in pairs(self.itemList) do
        GameObject.DestroyImmediate(value)
    end
    self.itemList = {}
    for key,value in pairs(self.data) do
        local itemdata = value
        local item = GameObject.Instantiate(self.itemobject)
        UIUtils.AddUIChild(self.itemcontainer, item)
        table.insert(self.itemList, item)
        local fun = function()
            self:Onclick(value)
        end
        item:GetComponent(Button).onClick:AddListener(fun)

        item.transform:Find("NameText"):GetComponent(Text).text = value.name
    end
end

function ClicknpcView:hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
    end
end

function ClicknpcView:Onclick(data)
    SceneManager.Instance.sceneElementsModel:ClickUnitObject_DoAction(data.npcuniqueid)
    self:hide()
end