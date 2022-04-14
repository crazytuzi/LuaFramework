RankModel = RankModel or class("RankModel", BaseModel)

function RankModel:ctor()
    RankModel.Instance = self
    self:Reset()

end

function RankModel:Reset()

end

function RankModel:GetInstance()
    if RankModel.Instance == nil then
        RankModel()
    end
    return RankModel.Instance
end



function RankModel:dctor()

end

function RankModel:GetRankById(id)
    local cfg = Config.db_rank
    for i, v in pairs(cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end

---得到单独的分组
function RankModel:GetOneRankGroup()
    local cfg = Config.db_rank
    for i = 1, #cfg do
        local item = cfgp[i]
        if item.group == 0 then

        end
    end
end


--通过ID得到坐骑阶数
function RankModel:GetMountNumByID(id)
    local Cfg = Config.db_mount
    for i, v in pairs(Cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end

--通过ID得到副手阶数
function RankModel:GetOffhandNumByID(id)
    local Cfg = Config.db_offhand
    for i, v in pairs(Cfg) do
        if v.id == id then
            return v
        end
    end
    return nil
end


