
Item.tbFakeItem = {};
Item.tbAllFakeItems  = {}
local tbFakeItem = Item.tbFakeItem
Item.nFakeItemIdInit = 0

function tbFakeItem:Init(dwTemplateId)
    self.dwTemplateId = dwTemplateId;

    Item.nFakeItemIdInit = Item.nFakeItemIdInit + 1
    self.dwId = Item.nFakeItemIdInit;

    local tbBaseInfo = KItem.GetItemBaseProp(dwTemplateId)
    self.nItemType = tbBaseInfo.nItemType
    self.nLevel = tbBaseInfo.nLevel;
    self.nEquipPos = KItem.GetEquipPos(dwTemplateId)
    local szName,nIconImage, nViewImage = Item:GetItemTemplateShowInfo(dwTemplateId, me.nFaction, me.nSex)
    self.szName = szName
    
    return self.dwId
end

function tbFakeItem:GetIntValue(index)
    if self.tbIntValue then
        return self.tbIntValue[index] or 0
    end
    return 0
end

function tbFakeItem:SetIntValue(index, val)
    if not self.tbIntValue then
        self.tbIntValue = {}
    end
    self.tbIntValue[index] = val
end

function tbFakeItem.ReInit()
end


function Item:AddFakeItem(dwTemplateId)
    local tbBaseInfo = KItem.GetItemBaseProp(dwTemplateId)
    assert(tbBaseInfo)
    local tbNewItem = Lib:NewClass(tbFakeItem)
    local dwId = tbNewItem:Init(dwTemplateId)
    self.tbAllFakeItems[dwId] = tbNewItem
    return tbNewItem
end

function Item:RemoveFakeItem(dwId)
    self.tbAllFakeItems[dwId] = nil
end 

function Item:GetFakeItem(dwId)
    return self.tbAllFakeItems[dwId]
end