function api_admin_getplayerstats(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    local zid = getZoneId()

    local db = getDbo()        
    local rs = db:getAllRows("select uid from userinfo where level>=30 and logindate >1487260800 order by vip desc")

    local ret = {}
    for k, v in pairs(rs) do
        table.insert(ret, m_detail(tonumber(v.uid) ))
    end

    local line = "ZID\tVIP\tUID\t技能数\t科技数\t带兵量\t统率等级\t通用碎片数\t铁矿(数量-平均等级)\t油井(数量-平均等级)\t铅矿(数量-平均等级)\t钛矿(数量-平均等级)"
    line = line .. "\n"

    for k, v in pairs(ret) do
        line = line .. string.format("%3d\t", zid)
        for _, r in pairs(v) do
            line = line .. string.format("%s\t", r)
        end
        line = line .. "\n"
    end

    local fileName = string.format("/tmp/userinfo_z%d.txt", zid)
    local f = io.open(fileName,"a+")
    if f then
        f:write(line)
        f:close()
    end
    response.ret = 0
    response.msg = 'Success'

    return response
end


function m_detail(uid)
    local uobjs = getUserObjs(uid, true)
    local mUserinfo = uobjs.getModel('userinfo')
    local mSkill = uobjs.getModel('skills')
    local skillLv = 0
    for k, v in pairs(mSkill.toArray(true) ) do
        skillLv = skillLv + v
    end
    local mTech = uobjs.getModel('techs')
    local techLv = 0
    for i=1, 32  do
        local tid = "t" .. i
        if tonumber(mTech[tid]) then
            techLv = techLv + tonumber(mTech[tid])
        end
    end

    local mTroop = uobjs.getModel('troops')
    local mSequip = uobjs.getModel('sequip')
    local maxNumByTeam = mTroop.getMaxBattleTroops( mSequip.maxstrong() )

    local mAcc = uobjs.getModel('accessory')
    local f0 = mAcc.fragment['f0'] or 0

    local mBuilding = uobjs.getModel('buildings')
    -- 铁矿=1  油井=4  铅矿=2  钛矿=3
    local build = {}
    local buildLv = {}
    for i=1, 51 do
        local bid = "b" .. i 
        if type(mBuilding[bid])=='table' and next(mBuilding[bid]) and tonumber(mBuilding[bid][1])>=1 and tonumber(mBuilding[bid][1])<=4 then
            mBuilding[bid][1] = tonumber(mBuilding[bid][1])
             build[mBuilding[bid][1]] = (build[mBuilding[bid][1]] or 0) + 1
             buildLv[mBuilding[bid][1]] = (buildLv[mBuilding[bid][1]] or 0) + tonumber(mBuilding[bid][2])
        end
    end

    local binfo = {}
    for i=1, 4 do
        if not buildLv[i] or not build[i] then
            binfo[i] = "0-0"
        else
            binfo[i] = build[i] .. "-" .. (math.ceil(buildLv[i] / build[i]))
        end
    end

    local ret = {}
    table.insert(ret, mUserinfo.vip)
    table.insert(ret, uid)
    table.insert(ret, skillLv)
    table.insert(ret, techLv)
    table.insert(ret, maxNumByTeam)
    table.insert(ret, mUserinfo.troops)
    table.insert(ret, f0)
    table.insert(ret, binfo[1])
    table.insert(ret, binfo[4] )
    table.insert(ret, binfo[2] )
    table.insert(ret, binfo[3] )

    return ret
end
