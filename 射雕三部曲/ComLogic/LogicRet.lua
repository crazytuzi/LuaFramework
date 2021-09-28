local LogicAtom = class("LogicAtom" , function()
    return {
        data = {},
    }
end)

function LogicAtom:getResult( ... )
    return self.data
end

function LogicAtom:addAtom(name)
    local atom = LogicAtom.new()
    if name then
        self.data[name] = atom:getResult()
    else
        table.insert(self.data, atom:getResult())
    end
    return atom
end

function LogicAtom:set(name , value)
    self.data[name] = value
end

---------------------------------------------------
--[[
    params:
        buffId
        uniqueId
        toPos
        fromPos
        type
        extend
    return:
        NULL
]]
function LogicAtom:addBuff(params)
    self.data["buffId"] = params.buffId
    self.data["uniqueId"] = params.uniqueId
    self.data["toPos"] = params.toPos
    self.data["fromPos"] = params.fromPos
    self.data["type"] = params.type
    self.data["atomType"] = ld.FightAtomType.eSTATE
    if params.extend then
        for i , v in ld.pairsByKeys(params.extend) do
            self.data[i] = v
        end
    end
end

function LogicAtom:addDead(params)
    self.data["dead"] = params
end

function LogicAtom:addCoreData(heroList , storage_teammate , storage_enemey)
    local tmpHeroList = clone(heroList)
    local tmp_teammate = clone(storage_teammate)
    local tmp_enemey = clone(storage_enemey)
    --还原
    for i = #tmp_teammate , 1 do
        if tmp_teammate[i] and tmp_teammate[i].switchIdx then
            local tmp = tmp_teammate[i].switchIdx
            local tmpNode = tmpHeroList[tmp]
            tmpHeroList[tmp] = tmp_teammate[i]
            tmp_teammate[i] = tmpNode
        end
    end
    for i = #tmp_enemey , 1 do
        if tmp_enemey[i] and tmp_enemey[i].switchIdx then
            local tmp = tmp_enemey[i].switchIdx
            local tmpNode = tmpHeroList[tmp]
            tmpHeroList[tmp] = tmp_enemey[i]
            tmp_enemey[i] = tmpNode
        end
    end
    --导出
    self.data["heroList"] = {}
    for i , v in ld.pairsByKeys(tmpHeroList) do
        local tmp = {
            hp = v.HP,
            rp = v.RP,
            mhp = v.MHP,
            dead = v.dead_state,
        }
        self.data["heroList"][i] = tmp
    end
    self.data["storageList"] = {}
    for i , v in ld.pairsByKeys(tmp_teammate) do
        local tmp = {
            hp = v.HP,
            rp = v.RP,
            mhp = v.MHP,
            dead = v.dead_state,
        }
        self.data["storageList"]["teammate"] = self.data["storageList"]["teammate"] or {}
        self.data["storageList"]["teammate"][i] = tmp
    end
    for i , v in ld.pairsByKeys(tmp_enemey) do
        local tmp = {
            hp = v.HP,
            rp = v.RP,
            mhp = v.MHP,
            dead = v.dead_state,
        }
        self.data["storageList"]["enemy"] = self.data["storageList"]["enemy"] or {}
        self.data["storageList"]["enemy"][i] = tmp
    end
end

return LogicAtom