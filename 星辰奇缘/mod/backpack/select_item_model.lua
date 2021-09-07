-- --------------------------------
-- 选择物品
-- ljh 2016.6.4
-- --------------------------------
SelectItemModel = SelectItemModel or BaseClass(BaseModel)

function SelectItemModel:__init()
    self.window = nil
    self.index = 0
    self.type = 1
end

function SelectItemModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function SelectItemModel:OpenMain(args)
    if self.window == nil then
        self.window = SelectItemWindow.New(self)
    end
    self.window:Show(args)
end

function SelectItemModel:CloseMain()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function SelectItemModel:MakeItemList(type, itemIdList)
    local list = {}
    if type == 1 then
        for _,itembaseid in pairs(itemIdList) do 
            local itembase = BackpackManager.Instance:GetItemBase(itembaseid)
            local itemData = ItemData.New()
            itemData:SetBase(itembase)
            itemData.quantity = BackpackManager.Instance:GetItemCount(itembaseid)
            table.insert(list, itemData)
        end
    end
    return list
end