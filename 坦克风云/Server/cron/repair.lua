--
-- 跨服军团战出问题时返还金币
-- User: luoning
-- Date: 15-3-20
-- Time: 下午5:08
--
function api_test_repair(request)

    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local function writeMessLog(message,path)
        path = path or ''
        message = message or ''
        local zoneid = tonumber(getZoneId()) or 0
        local logpath = "/tmp/"
        local fileName = logpath .. "server"..zoneid..'.log'

        if type(message) == 'table' then
            message = (json.encode(message) or '') .. '\r\n'
        else
            message = message .. '\r\n'
        end
        local ts = getClientTs()
        local f = io.open(fileName, "a+")
        if f then
            f:write(message)
            f:close()
        end
    end

    --[[   手动从跨服机器查出来的  select uid, gems, carrygems from....
    +----------+------+-----------+
    | uid      | gems | carrygems |
    +----------+------+-----------+
    |  1009200 |    0 |        18 |
    |  2004571 |    0 |       100 |
    |  4014399 |    0 |      1000 |
    |  3002880 |    0 |       100 |
    |  3002660 |    0 |       200 |
    |  4025840 |    0 |       724 |
    | 11000124 |    0 |        10 |
    |  5004757 |    0 |       100 |
    | 10009551 |    0 |       200 |
    | 10000822 |   30 |        30 |
    | 10018876 |   50 |        50 |
    |  8016906 |    1 |         1 |
    |  5001131 |    0 |        20 |
    | 10000104 |  200 |       200 |
    | 10012936 |   67 |        67 |
    |  8005151 |    0 |       200 |
    |  7001420 |    0 |       100 |
    |  3004952 |    0 |       170 |
    | 11000206 |    0 |        50 |
    |  2008744 |  532 |       532 |
    |  6000119 |   20 |        20 |
    |  9015165 |   20 |        20 |
    |  3000537 |  100 |       100 |
    |  2004201 |  800 |       800 |
    |  5007229 |   20 |        20 |
    |  7009812 |   65 |        65 |
    +----------+------+-----------+
    --]]

    local kuafuCarryGems = {
        {1009200, 0,  18},
        {2004571, 0,  100},
        {4014399, 0,  1000},
        {3002880, 0,       100},
        {3002660, 0,       200},
        {4025840, 0,       724},
        {11000124,        0,       10},
        {5004757, 0,       100,},
        {10009551,        0,       200},
        {10000822,        30,      30},
        {10018876,        50,      50},
        {8016906, 1,       1,},
        {5001131, 0,       20,},
        {10000104,        200,     200,},
        {10012936,        67,      67,},
        {8005151, 0,       200,},
        {7001420, 0,       100,},
        {3004952, 0,       170},
        {11000206,        0,       50},
        {2008744, 532,     532},
        {6000119, 20,      20},
        {9015165, 20,      20},
        {3000537, 100,     100},
        {2004201, 800,     800},
        {5007229, 20,      20},
        {7009812, 65,      65},
    }
    --修复跨服金币 需要注意手动提取过的用户
    local zoneid = getZoneId()
    for i,v in pairs(kuafuCarryGems) do
        local uid = v[1]
        local tmpUid = tostring(uid)
        local ttUid = string.sub(tmpUid,-6)
        local tmpZoneid = string.gsub(tmpUid,ttUid,"")
        if tonumber(tmpZoneid) == tonumber(zoneid) then
            local uobjs = getUserObjs(uid)
            uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
            local mUserinfo = uobjs.getModel('userinfo')
            local oldGems = mUserinfo.gems
            if takeReward(uid, {userinfo_gems=v[3]}) then
                mUserinfo.usegems=0
            end
            local newGems = mUserinfo.gems
            if uobjs.save() then
                writeMessLog("kuafu__"..uid.."__"..v[3].."__"..oldGems.."__"..newGems)
            end
        end
    end


    --返还鲜花的金币
    local config = getConfig("serverWarTeamCfg")
    local gemConfig1 = config.betGem_1
    local gemConfig2 = config.betGem_2

    local function getGemsCost(gems, ggConfig)
        local result = 0
        for _,gemItem in pairs(ggConfig) do
            if gemItem <= gems then
                result = gemItem + result
            end
        end
        return result
    end

    local db = getDbo()
    local result = db:getAllRows('select uid,bet from acrossinfo where bet like "%count%"')
    for i,v in pairs(result) do
        local uid = tonumber(v['uid'])
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
        local mUserinfo = uobjs.getModel('userinfo')
        local acrossinfo = uobjs.getModel('acrossinfo')
        local addGems = 0
        local count = 0
        for ii,vv in pairs(acrossinfo.bet) do
            if type(vv) == "table" then
                for mmm, vvv in pairs(vv) do
                    if type(vvv) == "table" then
                        if vvv.type == 1 then
                            addGems = addGems + getGemsCost(gemConfig1[vvv.count], gemConfig1)
                        else
                            addGems = addGems + getGemsCost(gemConfig2[vvv.count], gemConfig2)
                        end
                        count = vvv.count
                    end
                end
            end
        end
        local oldGems = mUserinfo.gems
        if takeReward(uid, {userinfo_gems=addGems}) then
        end
        local newGems = mUserinfo.gems
        if addGems > 0 and uobjs.save() then
            writeMessLog("yazhu__"..uid.."__"..addGems.."__"..oldGems.."__"..newGems.."__"..count)
        end
    end

    --重置押注数据
    --[[
    local db = getDbo()
    local result = db:getAllRows('select uid from acrossinfo')
    for i,v in pairs(result) do
        local uid = tonumber(v['uid'])
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","hero",'useractive'})
        local acrossinfo = uobjs.getModel('acrossinfo')
        acrossinfo.point = {}
        acrossinfo.bet = {}
        acrossinfo.rank = {}
        if uobjs.save() then
        end
    end
    --]]

    return response
end


