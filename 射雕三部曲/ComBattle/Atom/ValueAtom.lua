--[[
    filename: ComBattle.Atom.ValueAtom
    description: 战斗时 value-atom
    date: 2016.10.28

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local ValueAtom = {}

-- @
function ValueAtom.execute(params)
    local atom       = params.atom
    local battleData = params.battleData

    if atom.toPos then
        if atom.rp then
            battleData:fixRP({posId = atom.toPos, value = atom.rp})
        end

        if atom.orghp or atom.hp then
            battleData:fixHP({
                posId = atom.toPos,
                value = atom.hp,
                type  = atom.effect,
                ORGHP = atom.orghp,
            })
        end
    end

    params.callback()
end


-- @检查一些特殊的数值（不死、免致命、复活...）
--[[
params:
{
    <value>:
    <battleData>:
}
]]
function ValueAtom.checkSpecialValue(params)
    local value = params.value
    local callback = params.callback
    local battleData = params.battleData

    local key = {
        unDead  = true,
        zhiming = true,

        -- 取消重生的特殊处理，因为重生时，逻辑数据会返回buff-exec的数据
        -- 在StateAtom里面会有表现
        -- rebirth = true,
    }

    for k in pairs(key) do
        key[k] = value[k]
    end

    local node = battleData:getHeroNode(value.posId)
    if not node then
        return callback and callback()
    end

    for k in pairs(key) do
        bd.interface.newEffect({
            parent     = node,
            effectName = bd.ui_config.specialBuffEffect[k][1],
            animation  = bd.ui_config.specialBuffEffect[k][2],
            endRelease = true,
            position   = cc.p(0, 150),
            scale      = node:getScale(),
            zorder     = 1,
        })
    end
end

return ValueAtom
