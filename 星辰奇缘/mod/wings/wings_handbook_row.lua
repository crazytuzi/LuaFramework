-- @author 黄耀聪
-- @date 2017年5月18日

WingHandbookRow = WingHandbookRow or BaseClass()

function WingHandbookRow:__init(model, gameObject, clickCallback)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform

    self.groupList = {}
    self.itemList = {}

    for i=1,3 do
        self.itemList[i] = WingHandbookItem.New(self.model, t:GetChild(i - 1).gameObject)
        self.itemList[i].clickCallback = clickCallback
    end
end

function WingHandbookRow:__delete()
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemList = nil
    end
    self.gameObject = nil
    self.model = nil
end

function WingHandbookRow:update_my_self(data, index)
    for i,v in ipairs(self.itemList) do
        v:SetData(self.groupList[i])
    end
end

function WingHandbookRow:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function WingHandbookRow:SetIds(group1, group2, group3)
    self.groupList[1] = group1
    self.groupList[2] = group2
    self.groupList[3] = group3
end


