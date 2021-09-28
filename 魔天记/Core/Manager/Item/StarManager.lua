require "Core.Module.Star.StarNotes"

StarManager = { }
-- 命星背包[Item,...]命星装备栏[Item,...]
StarManager.bag = { }
StarManager.equip = { }
local debris = 0
local coin = 0
local setDtTime = 0
local divinationDt = 0
StarManager.currentDivinationConfig = nil -- 当前占星面板配置
local TYPE_BAB = ProductManager.ST_TYPE_IN_TRUMPBAG --3
local TYPE_EQUIP = ProductManager.ST_TYPE_IN_TRUMPEQUIPBAG --4
StarManager.STAR_ELITE_TYPE = 12 --命星精华
StarManager.STAR_BAG_MAX = 300 --命星背包最大数量

function StarManager._InitStarData(d)
    local pinfo = ProductManager.GetProductById(d.spId)
    if not d.level then d.level = pinfo.lev end
    if not d.quality then d.quality = pinfo.quality end
    if not d.kind then d.kind = pinfo.kind end
    if d.kind == StarManager.STAR_ELITE_TYPE then
        d.fusion_exp = tonumber(pinfo.fun_para[1])
    end
--    if not d.name then d.name = pinfo.name end
--    if not d.icon_id then d.icon_id = pinfo.icon_id end
end
function StarManager.SetData(d)
    StarManager.bag = d.star_bag or { }
    StarManager.equip = d.star_equip or { }
    local bag = StarManager.bag
    local equip = StarManager.equip
    for i = #bag, 1, -1 do StarManager._InitStarData(bag[i]) end
    for i = #equip, 1, -1 do StarManager._InitStarData(equip[i]) end
    -- StarManager.Test()
    MessageManager.Dispatch(StarNotes, StarNotes.STAR_DATA_CHANGE)
end
-- 命星碎片 --星辰精华
function StarManager.SetDebris(d)
    if d.star_debris then debris = d.star_debris end
    if d.star_coin then coin = d.star_coin end
    StarManager._SetDivinationDt(d.star_rt)
    MessageManager.Dispatch(StarNotes, StarNotes.STAR_DATA_CHANGE)
end
-- 命星占星倒计时
function StarManager.SetDivinationDt(dt)
    StarManager._SetDivinationDt(dt)
    MessageManager.Dispatch(StarNotes, StarNotes.STAR_DATA_CHANGE)
end
-- 命星碎片 --星辰精华
function StarManager._SetDivinationDt(dt)
    if not dt then return end
    setDtTime = GetTime()
    divinationDt = dt
end
function StarManager.Test()
    StarManager.equip = {
        { id = 1, spId = 310006, level = 1, idx = 0 },{ id = 2, spId = 310017, level = 2, idx = 1 }
        ,{ id = 4, spId = 310007, level = 1, idx = 2 },{ spId = 310022, id = 3, level = 2, idx = 3 }
        -- ,{id = 5,spId=310011,level=1,idx=4},{id = 7,spId=310023,level=2,idx=5}
        -- ,{id = 6,spId=310012,level=1,idx=6},{id = 8,spId=310021,level=100,idx=7}
    }
    StarManager.bag = {
        { id = 1, spId = 310006, level = 1, idx = 0 },{ id = 2, spId = 310017, level = 2, idx = 1 }
        ,{ id = 4, spId = 310007, level = 1, idx = 2 },{ spId = 310022, id = 3, level = 2, idx = 3 }
        ,{ id = 5, spId = 310011, level = 1, idx = 4 },{ id = 7, spId = 310023, level = 2, idx = 5 }
        ,{ id = 6, spId = 310012, level = 1, idx = 6 },{ id = 8, spId = 310021, level = 100, idx = 7 }
        ,{ id = 4, spId = 310007, level = 1, idx = 2 },{ spId = 310022, id = 3, level = 2, idx = 3 }
        ,{ id = 5, spId = 310011, level = 1, idx = 4 },{ id = 7, spId = 310023, level = 2, idx = 5 }
        ,{ id = 6, spId = 310012, level = 1, idx = 6 },{ id = 8, spId = 310021, level = 100, idx = 7 }
        ,{ id = 4, spId = 310007, level = 1, idx = 2 },{ spId = 310022, id = 3, level = 2, idx = 3 }
        ,{ id = 5, spId = 310011, level = 1, idx = 4 },{ id = 7, spId = 310023, level = 2, idx = 5 }
        ,{ id = 6, spId = 310012, level = 1, idx = 6 },{ id = 8, spId = 310021, level = 100, idx = 7 }
    }
end
function StarManager.GetDataById(id, new)
    local equip = StarManager.equip
    for i = #equip, 1, -1 do
        if equip[i].id == id then return equip[i] end
    end
    return new and { level = 1, exp = 0, id = id } or nil
end
--下标从0开始
function StarManager.GetDataBydIdx(idx)
    local equip = StarManager.equip
    for i = #equip, 1, -1 do
        if equip[i].idx == idx then return equip[i] end
    end
    return nil
end
function StarManager.UpgradeEquip(d)
    if not d then return end
    local id = d.id
    local equip = StarManager.equip
    for i = #equip, 1, -1 do
        local v = equip[i]
        if v.id == id then
            v.level = d.level
            break
        end
    end
    MessageManager.Dispatch(StarNotes, StarNotes.STAR_DATA_CHANGE)
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Star)
end
function StarManager.UpdateStars(d)
    StarManager.UpdateStar(d.u)
    StarManager.UpdateStar(d.a)
    StarManager.MoveStar(d.m)
    MessageManager.Dispatch(StarNotes, StarNotes.STAR_DATA_CHANGE)
    PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.Star)
end
function StarManager.UpdateStar(d)
    if not d then return end
    local bag = StarManager.bag
    for i = #d, 1, -1 do
        local v = d[i]
        local id = v.id
        if v.st == TYPE_BAB then
            for j = #bag, 1, -1 do
                local vv = bag[j]
                if vv.id == id then
                    table.remove(bag, j)
                    table.remove(d, i)
                    break
                end
            end
            if v.am > 0 then
                table.insert(bag, v)
                StarManager._InitStarData(v)
            end
        end
    end
    local equip = StarManager.equip
    for i = #d, 1, -1 do
        local v = d[i]
        local id = v.id
        if v.st == TYPE_EQUIP then
            for j = #equip, 1, -1 do
                local vv = equip[j]
                if vv.id == id then
                    table.remove(equip, j)
                    break
                end
            end
            if v.am > 0 then
                table.insert(equip, v)
                StarManager._InitStarData(v)
            end
        end
    end
end
function StarManager.MoveStar(d)
    if not d then return end
    local oid = d.idx
    local bag = StarManager.bag
    local equip = StarManager.equip
    for i = #d, 1, -1 do
        local v = d[i]
        local id = v.id
        local f = false
        for j = #bag, 1, -1 do
            local vv = bag[j]
            if vv.id == id then
                vv.st = v.st
                vv.idx = v.idx
                if v.st == TYPE_EQUIP then
                    table.insert(equip, vv)
                end
                if v.st ~= TYPE_BAB then
                    table.remove(bag, j)
                end
                f = true
                break
            end
        end
        if not f then
            for j = #equip, 1, -1 do
                local vv = equip[j]
                if vv.id == id then
                    vv.st = v.st
                    vv.idx = v.idx
                    if v.st == TYPE_BAB then
                        table.insert(bag, vv)
                    end
                    if v.st ~= TYPE_EQUIP then
                        table.remove(equip, j)
                    end
                    break
                end
            end
        end
    end
end
function StarManager.HasBetter(kind, quality)--有更好的命星
    local bag = StarManager.bag
    for j = #bag, 1, -1 do
        local vv = bag[j]
        if vv.kind == kind then
            if vv.quality > quality then return true end
        end
    end
    return false
end
function StarManager.HasUpgrade(v)--可以升级的命星
    local lev = v.level
    local quality = v.quality
    local ac = StarManager.GetAttConfig(quality, lev)
    if ac.up_exp <= coin and StarManager.GetAttConfig(quality, lev + 1) then return true end
    return false
end


local StoreId = 7 -- 商店id
local cfs -- star
local cfsAtt -- star_exp 
local cfsExpend -- star_exp 
local cfsOpen -- star_open
function StarManager.GetConfigs()
    if not cfs then cfs = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STAR) end
    return cfs
end
function StarManager.GetUnlockNumByType(t)
    local cs = StarManager.GetConfigs()
    for k, v in pairs(cs) do if v.type == t then return v.num end end
    return 0
end
function StarManager.GetUnlockStars(ceng)
    local cs = StarManager.GetConfigs()
    local res = { }
    for k, v in pairs(cs) do
        if v.num <= ceng then
            table.AddRange(res, v.star_gather)
        end
    end
    return res
end
-- 返回星命层数下一层的解锁星命{p = productInfo, c = nextceng}
function StarManager.GetUnLockStar(ceng)
    local cs = StarManager.GetConfigs()
    local c = nil
    local len = #cs
    for i = 1, len do
        local v = cs[i]
        if v.num > ceng then
            c = v
            break
        end
    end
    local nc = StarManager.GetNextStarCeng(ceng)
    if c == nil and nc == -1 then
        return nil
    elseif nc == -1 then
        return { p = ProductManager.GetProductInfoById(c.star_gather[1], 1), c = c.num }
    elseif c == nil then
        return { c = nc }
    else
        if nc < c.num then
            return { c = nc }
        else
            return { p = ProductManager.GetProductInfoById(c.star_gather[1], 1), c = c.num }
        end
    end
end

function StarManager.GetOpenConfigs()
    if not cfsOpen then cfsOpen = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STAR_OPEN) end
    return cfsOpen
end
function StarManager.GetOpenById(idx, ceng)
    local n = StarManager.GetOpenConfigs()[idx].num
    --Warning(idx .. '----' .. n .. ':' .. ceng)
    return n == 0 or n <= ceng
end
-- 返回星命层数的下一层,-1满了
function StarManager.GetNextStarCeng(ceng)
    local cs = StarManager.GetOpenConfigs()
    for i = 1, #cs do
        local c = cs[i]
        if c.num > ceng then
            return c.num
        end
    end
    return -1
end

function StarManager.GetExpendConfigs()
    if not cfsExpend then cfsExpend = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STAR_EXPEND) end
    return cfsExpend
end
function StarManager.GetExpendConfigById(id)
    return StarManager.GetExpendConfigs()[id]
end
function StarManager.GetAttConfigs()
    if not cfsAtt then cfsAtt = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_STAR_ATT) end
    return cfsAtt
end
function StarManager.GetAttConfig(quality, lev)
    quality = quality or 0
    lev = lev or 1
    local cs = StarManager.GetAttConfigs()
    for k, v in pairs(cs) do
        if v.quality == quality and v.star_lev == lev then
            return v
        end
    end
    return nil
end
function StarManager.GetAttForConfig(st, c, advance)
    if st == StarManager.STAR_ELITE_TYPE then return nil end
    local as = advance and BaseAdvanceAttrInfo:New() or { }
    local ass = c['att_' .. st]
    for i = #ass, 1, -1 do
        local ss = string.split(ass[i], '|')
        as[ss[1]] = tonumber(ss[2])
    end
    return as
end

function StarManager.GetExChangeProducts(ceng)
    return ShopDataManager.GetProductsForTShop(StoreId)
end


function StarManager.GetAllAttrs()
    local baseAttrInfo = BaseAdvanceAttrInfo:New()
    local equip = StarManager.equip
    for k, v in ipairs(equip) do
        local ac = StarManager.GetAttConfig(v.quality, v.level)
        local at = StarManager.GetAttForConfig(v.kind, ac)
        baseAttrInfo:Add(at)
    end
    return baseAttrInfo
end
function StarManager.GetPower()
    local ass = StarManager.GetAllAttrs()
    local p = CalculatePower(ass, false)
    return p
end
function StarManager.HasTips()
    return StarManager.HasDivinationTips() or StarManager.HasStarUpgradeTips()
end
function StarManager.HasDivinationTips()
    return StarManager.GetDivinationDt() <= 0
end
function StarManager.HasStarUpgradeTips()
    local equip = StarManager.equip
    local coin = coin
    for k, v in ipairs(equip) do
        local lev = v.level
        local quality = v.quality
        local ac = StarManager.GetAttConfig(quality, lev)
        if (ac.up_exp <= coin and StarManager.GetAttConfig(quality, lev + 1))--升级
            or StarManager.HasBetter(v.kind, quality) then --替换
            return true
        end
    end
    return false
end
function StarManager.GetStarUpgradeTips()
    local equip = StarManager.equip
    local coin = coin
    local es = {}
    for k, v in ipairs(equip) do
        local lev = v.level
        local quality = v.quality
        local ac = StarManager.GetAttConfig(quality, lev)
        if (ac.up_exp <= coin and StarManager.GetAttConfig(quality, lev + 1))--升级
            or StarManager.HasBetter(v.kind, quality) then --替换
            table.insert(es, v.idx) 
        end
    end
    return es
end

-- 返回星命碎片
function StarManager.GetDebris()
    return debris
end
-- 返回星命精华
function StarManager.GetCoin()
    return coin
end
-- 返回免费占星倒计时
function StarManager.GetDivinationDt()
    return divinationDt - (GetTime() - setDtTime)
end
function StarManager.GetStarCeng()
    return InstanceDataManager.GetXLTHasPassCen()
end

