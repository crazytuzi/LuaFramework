FormationManager = { }
local data
--[{id:图阵id,lev:等级,exp:经验}] 图阵信息
function FormationManager.SetData(d)
    data = d
    --FormationManager.Test()
    if not data then data = {} end
end
function FormationManager.Test()
    data = {{id=1,lev=0,exp=1},{id=2,lev=1,exp=1},{id=3,lev=30,exp=100},{id=4,lev=500,exp=10000}}
end
function FormationManager.UpdateData(d)
    if not d then return end
    local od
    local id = d.id
    for k,v in pairs(data) do
        if v.id == id then
            d.upgrade = v.lev < d.lev
            od = v
            od.lev = d.lev
            od.exp = d.exp
            break
        end
    end
    if not od then 
        od = d
        d.upgrade = true
        table.insert(data, od)
    end
    if d.upgrade then
        PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Formation)
    end
    MessageManager.Dispatch(FormationNotes, FormationNotes.FORMATION_CHANGE, d)
    --MessageManager.Dispatch(MainUINotes, MainUINotes.ARTIFACT_CHANGE, d)
end
function FormationManager.GetDataById(id, new)
    for i = #data, 1, -1 do 
        if data[i].id == id then return data[i] end
    end
    return new and { lev = 0, exp = 0, id = id} or nil
end


local cfs --graphic
local cfsAtt --graphic_attr 
local cfsSkill --graphic_skill
function FormationManager.GetConfigs()
    if not cfs then cfs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FORMATION) end
    return cfs
end

function FormationManager.GetConfigById(id)
    return FormationManager.GetConfigs()[id]
end

function FormationManager.GetAttForConfig(c)
    local t = c.type
    local at
    if #t > 1 then
        local phy = PlayerManager.GetMyCareerDmgType() == 1
        local phy1 = string.find(t[1], 'phy')
        if phy then at = phy1 and t[1] or t[2]
        else at = phy1 and t[2] or t[1] end
    else at = t[1]
    end
    local as = string.split(at, '|')
    return as 
end

function FormationManager.GetAttAdd(at, c)
    local as = BaseAdvanceAttrInfo:New()
    if not c then return as end
    for k,v in pairs(at) do as[v] = c[v] end
    return as 
end

function FormationManager.GetFidByPid(pid)
    local cs = FormationManager.GetConfigs()
    for i = 1, #cs do
        local ps = cs[i].need_item 
        for j = 1, #ps do
            if ps[j] == pid then return cs[i].id end
        end
    end
    return nil
end

function FormationManager.GetAttConfigs()
    if not cfsAtt then cfsAtt = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FORMATION_ATT) end
    return cfsAtt
end

function FormationManager.GetAttForLev(lev)
    local c = FormationManager.GetAttConfigs()[lev]
    return c
end

function FormationManager.GetMaxLev()
    local cs = FormationManager.GetAttConfigs()
    return #cs - 1 -- 减0级
end

function FormationManager.GetAttGap(at)
    local cs = FormationManager.GetAttConfigs()
    local as = BaseAdvanceAttrInfo:New()
    for k,v in pairs(at) do as[v] = cs[3][v] - cs[2][v] end
    return as 
end

function FormationManager.GetSkillConfigs()
    if not cfsSkill then cfsSkill = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_FORMATION_SKILL) end
    return cfsSkill
end
function FormationManager.GetSkillForId(id)
    local cs = FormationManager.GetSkillConfigs()
    local res = {}
    for k, v in pairs(cs) do
        if v.id == id then table.insert(res, v) end
    end
    table.sort(res, function(a,b) return a.level < b.level end)
    return res
end

function FormationManager.GetAllAttrs()
    local ass = BaseAdvanceAttrInfo:New()
    local lev = PlayerManager.GetPlayerLevel()  
    for i = #data, 1, -1 do 
        local d = data[i]
        local c = FormationManager.GetConfigById(d.id)
        local c2 = FormationManager.GetAttForLev(d.lev)
        local at = FormationManager.GetAttForConfig(c)
        local ad = FormationManager.GetAttAdd(at, c2)
        for k,v in pairs(ad) do ass[k] = ass[k] and ass[k] + v or v end
    end
    --for k,v in pairs(ass) do Warning(k ..'---'.. tostring(v)) end
    return ass
end

function FormationManager.GetPower()
    local ass = FormationManager.GetAllAttrs()
    local p = CalculatePower(ass, false)
    return p
end
function FormationManager.GetSkillPower()
    if not data then return 0 end
    local p = 0
	for i = #data, 1, -1 do 
        local d = data[i]
        local sks = FormationManager.GetSkillForId(d.id)
        for k, v in pairs(sks) do
            if v.level >= d.lev then
                local sk = SkillManager:GetSkillById(v.skill_id)
			    p = p + sk.zdl_value
            end
        end
    end
	return p
end

function FormationManager.HasTips()
    if not SystemManager.IsOpen(SystemConst.Id.Artifact) then return false end
    local cs = FormationManager.GetConfigs()
    local ml = FormationManager.GetMaxLev()
    for i = 1, #cs do
        local c = cs[i]
        local id = c.id
        local ps = c.need_item
        local d = FormationManager.GetDataById(id)
        if not d or d.lev < ml then
            for j = 1, #ps do
                if BackpackDataManager.GetProductTotalNumBySpid(ps[j]) > 0 then
                    return true
                end
            end
        end
    end
    return false
end

function FormationManager.GetHasTips()
    local res = { }
    local cs = FormationManager.GetConfigs()
    local ml = FormationManager.GetMaxLev()
    for i = 1, #cs do
        local c = cs[i]
        local id = c.id
        local ps = c.need_item
        local d = FormationManager.GetDataById(id)
        if not d or d.lev < ml then
            for k, v in pairs(ps) do
                --Warning(i ..'___'.. v .. '='..BackpackDataManager.GetProductTotalNumBySpid(v))
                if BackpackDataManager.GetProductTotalNumBySpid(v) > 0 then
                    table.insert(res, i)
                    break
                end
            end
        end
    end
    return res
end

