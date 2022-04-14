ProbaTipModel = ProbaTipModel or class("ProbaTipModel", BaseModel)
local ProbaTipModel = ProbaTipModel

function ProbaTipModel:ctor()
    ProbaTipModel.Instance = self
    self:Reset()
    self.tips = {}
end

function ProbaTipModel:Reset()

end

function ProbaTipModel.GetInstance()
    if ProbaTipModel.Instance == nil then
        ProbaTipModel()
    end
    return ProbaTipModel.Instance
end

function ProbaTipModel:InitList()
    if table.nums(self.tips) == 0 then
        for _, v in pairs(Config.db_proba_tip) do
            self.tips[v.sys] = self.tips[v.sys] or {}
            table.insert(self.tips[v.sys], v)
        end
        local function sort_list(a, b)
            return a.id < b.id
        end
        for _, list in pairs(self.tips) do
            table.sort(list, sort_list)
        end
    end
end

--sys:系统id
function ProbaTipModel:GetTipList(sys)
    local list = self.tips[sys]
    if list and (not table.isempty(list)) then
        if list[1].world_lv ~= [[0]] then
            --有世界等级限制
            local final_list = {}
            local cur_lv = RoleInfoModel.GetInstance().world_level
            for i = 1, #list do
                local tbl = list[i]
                local lv_tbl = String2Table(tbl.world_lv)
                if cur_lv >= lv_tbl[1] and cur_lv <= lv_tbl[2] then
                    final_list[#final_list + 1] = tbl
                end
            end
            return final_list
        else
            return list
        end
    end
end

