-- @Author: lwj
-- @Date:   2019-06-04 14:34:53
-- @Last Modified time: 2019-06-04 14:35:03

GMModel = GMModel or class("GMModel", BaseModel)
local GMModel = GMModel

function GMModel:ctor()
    GMModel.Instance = self
    self:Reset()
end

function GMModel:Reset()
    self.histroy_list = {}
    self:SortItemCf()
end

function GMModel:SortItemCf()
    self.item_cf = {}
    local list = {}
    for i, v in pairs(Config.db_item) do
        list[v.gm_index] = v
    end
    local inter = table.pairsByKey(list)
    for i, v in inter do
        self.item_cf[#self.item_cf + 1] = v
    end
end

function GMModel:GetItemCf()
    return self.item_cf
end

function GMModel.GetInstance()
    if GMModel.Instance == nil then
        GMModel()
    end

    return GMModel.Instance
end

function GMModel:AddHistroy(str)
    local result = false
    local result_pos
    local list = self.histroy_list
    for i = 1, #list do
        if list[i] == str then
            result = true
            result_pos = i
            break
        end
    end
    if result then
        table.removebyindex(self.histroy_list, result_pos)
    end
    table.insert(self.histroy_list, 1, str)
end

function GMModel:GetHistroyList()
    return self.histroy_list
end