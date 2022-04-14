-- @Author: lwj
-- @Date:   2018-11-13 19:07:19
-- @Last Modified time: 2018-11-13 19:07:21

OpenTipModel = OpenTipModel or class("OpenTipModel", BaseModel)
local OpenTipModel = OpenTipModel

function OpenTipModel:ctor()
    OpenTipModel.Instance = self
    self:Reset()
end

function OpenTipModel:Reset()
    self.systemList = {}
    self.needShowList = {}
    self.isOpenning = false
    self.isBeginGame = false
    self.SetOpenNextTipList = {}
    self.cur_open_sys = nil

end

function OpenTipModel:GetInstance()
    if OpenTipModel.Instance == nil then
        OpenTipModel()
    end
    return OpenTipModel.Instance
end

function OpenTipModel:AddNeedShowTip(data)
    local tbl = string.split(data.id, "@")
    data.f_id = tbl[1]
    data.sub_id = tbl[2]
    self.needShowList[#self.needShowList + 1] = data
    local function SortFunc(a, b)
        if a.f_id == b.f_id then
            return a.sub_id < b.sub_id
        else
            return a.f_id < b.f_id
        end
    end
    table.sort(self.needShowList, SortFunc)
end

function OpenTipModel:RemoveNeedShow()
    local list = self.needShowList
    local idx
    for i = 1, #list do
        local data = list[i]
        if data.id == self.cur_open_sys then
            idx = i
            break
        end
    end
    table.remove(self.needShowList, idx)
end

function OpenTipModel:GetNextNeedShow()
    if table.nums(self.needShowList) == 0 then
        return
    end
    local data = self.needShowList[1]
    return data
end

function OpenTipModel:GetNeedShowNums()
    local num = 0
    for i, v in pairs(self.needShowList) do
        if v ~= nil then
            num = num + 1
        end
    end
    return num
end

function OpenTipModel:AddSystemList(list)
    for k, v in pairs(list) do
        self.systemList[v] = true
    end
end

function OpenTipModel:AddSystem(key)
    self.systemList[key] = true
end

function OpenTipModel:IsOpenSystem(id, sub_id)

    if not id then
        return false
    end
    if id >= 10000 then
        return true
    end
    sub_id = sub_id or 1
    local key = id .. "@" .. sub_id
    return self.systemList[key]
end

function OpenTipModel:IsNeedMove(id, sub_id)
    local result = false
    local key = id .. "@" .. sub_id
    for i, v in pairs(self.needShowList) do
        if key == v.id then
            result = true
            break
        end
    end
    return result
end

function OpenTipModel:GetNextWillOpenSys()
    local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local con_tbl = Config.db_sysopen
    local temp_1
    --先找一遍比自己等级小的 未开放的
    for i, v in pairs(con_tbl) do
        if (not temp_1) and v.level <= cur_lv and v.announce == 1 and (not self:IsOpenSystem(v.id, v.sub_id)) then
            temp_1 = v
        elseif temp_1 and v.level <= temp_1.level and v.announce == 1 and (not self:IsOpenSystem(v.id, v.sub_id)) then
            temp_1 = v
        end
    end
    if temp_1 then
        return temp_1
    end
    local result = nil
    for i, v in pairs(con_tbl) do
        --if not result and v.level > cur_lv and v.activity == 0 and v.announce == 1 then
        if not result and v.level > cur_lv and v.announce == 1 then
            result = v
        else
            if result and v.level > cur_lv and v.level < result.level and v.announce == 1 then
                result = v
            end
        end
    end
    return result
end

function OpenTipModel:CheckIsWillPop(key)
    local cfg = Config.db_sysopen[key]
    if not cfg then
        return nil
    end
    local pop = cfg.pop
    if pop == 1 or pop == 2 then
        return true
    else
        return false
    end
end

function OpenTipModel:DumpSystemList()
    dump(self.systemList, "<color=#6ce19b>DumpSystemList   DumpSystemList  DumpSystemList  DumpSystemList</color>")
end