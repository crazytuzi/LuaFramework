function api_map_get(request)
    local response = {}
    response.data={}
    
    --params: x1,y1,x2,y2
    --ret: map:[[id:0,x:0,y:0,type:1,level:2,oid:0,name:'沉船',power:10,alliance:'黑海舰队']]
    --
    local uid = request.uid
    local x1 = tonumber(request.params.x1) or 0;
    local x2 = tonumber(request.params.x2) or 0;
    local y1 = tonumber(request.params.y1) or 0;
    local y2 = tonumber(request.params.y2) or 0;

    local mapTable = 'map'
    if request.params.map == 2 then
        mapTable = 'alienmap'
    end

    local ts = getClientTs()
    local dayts = 86400
    local invalid = false -- 发送混淆数据 

    local tolog=false
    local logx=nil
    if (x2-x1)>13 then
        tolog=true
        logx=x2-x1
    end

    local logy=nil
    if (y2-y1)>20 then
        tolog=true
        logy=y2-y1
    end

    -- 验证
    if (x2-x1)>30 then
        x2 = x1 + 30
        invalid = true
    end
    
    if (y2-y1)>30 then
        y2 = y1 + 30
        invalid = true
    end

    --[[
        等级小于等于5级
        注册时间比当前时间差值超过24小时 等级小于8级 
        注册时间比当前时间差值超过48小时 等级小于10级 
        注册时间比当前时间差值超过72小时 等级小于12级 
        注册时间比当前时间差值超过96小时 等级小于15级 
    ]]
    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    
    if tonumber(mUserinfo.hwid) == 1 then
        response.ret = -133
        return response
    elseif type(mUserinfo.hwid) == 'table' then
        local bannedInfo = mUserinfo.hwid
        if (tonumber(bannedInfo[1]) or 0) <= getClientTs() and (tonumber(bannedInfo[2]) or 0) > getClientTs() then
            response.ret = -133
            response.bannedInfo = bannedInfo
            return response
        end
    end

    if mUserinfo.level < 5 then
        invalid = true
    elseif mUserinfo.level < 8 and ts - mUserinfo.regdate > dayts then
        invalid = true
    elseif mUserinfo.level < 10 and ts - mUserinfo.regdate > dayts*2 then
        invalid = true
    elseif mUserinfo.level < 12 and ts - mUserinfo.regdate > dayts*3 then
        invalid = true
    elseif mUserinfo.level < 15 and ts - mUserinfo.regdate > dayts*4 then
        invalid = true
    end

    setRandSeed()

    local db = getDbo()
    local result = db:getAllRows("select * from " .. mapTable .. " where type>0 and x>=:x1 and x<=:x2 and y>=:y1 and y<=:y2 ",{x1=x1,x2=x2,y1=y1,y2=y2})

    local maplist = {}
    local ts = getClientTs()

    local goldMineMap1 = {}
    local goldMineMap2 = {}
    if request.params.goldMine == 1 then
        local mGoldMine = require "model.goldmine"
        goldMineMap1 = mGoldMine.getGoldMineInfo()
    end
    
    -- -- 统计玩家扫矿次数
    -- local weeTs = getWeeTs()
    -- local uidkey = "z"..getZoneId()..".mapget."..uid .."weeTs".. weeTs
    -- local redis = getRedis()
    -- local timekey = "z"..getZoneId()..".mapget."..uid .."weeTs".. weeTs.."ts"
    -- local mc=redis:incr(uidkey)
    -- local time=tonumber(redis:get(timekey)) or 0
    -- if tonumber(time)<=ts then
    --     time=ts+60
    -- end
    -- redis:set(timekey,time)
    -- redis:expireat(uidkey,time)
    -- redis:expireat(timekey,time)
    -- if mc>=30 or tolog then
    --     local db = getDbo()
    --     local data={
    --         id = weeTs .. '-' .. uid, --每个玩家每天一条记录
    --         uid = uid,
    --         ip = request.client_ip,
    --         mcnt = mc,
    --         x=logx,
    --         y=logy,
    --         scoutdata = ts,
    --     }
    --     local rst = db:getRow("select uid,mcnt,cnt,x,y from scoutlog where id = :id",{id=data.id})
    --     if rst then 
    --         if tonumber(rst.mcnt)>mc then
    --             data.mcnt=nil
    --         end
    --         if logx~=nil and  tonumber(rst.x)>logx   then
    --             data.x=nil
    --         end
    --         if  logy~=nil and tonumber(rst.y)>logy   then
    --             data.y=nil
    --         end
    --         local rets= db:update("scoutlog", data, "id='" .. data.id .. "'")
    --     else
    --         db:insert("scoutlog", data)
    --     end
        
    -- end

    if type(result)=='table' then
	    for k,v in pairs (result) do
            local mRebel,heatInfo
            local oid = 0
            local baseskin = 0
            local nowtime = getClientTs()

            heatInfo = {}
            if v.data and #v.data > 0 then
                v.data = json.decode(v.data) or {}
                if type(v.data) == 'table' and v.data.heat then
                  heatInfo = v.data.heat
                end
                if type(v.data) == 'table' and type(v.data.skin) == 'table' and #v.data.skin == 4 and
                  v.data.skin[4] == 1 and (v.data.skin[2] <= nowtime and nowtime < v.data.skin[3]) then
                    baseskin = v.data.skin[1]
                end
            else
                v.data = {}
            end

            local HeatLevel=0
            v.oid = tonumber(v.oid)
            if v.oid==uid or tonumber(v.type) == 9 then
                oid=v.oid
            end
            if next(heatInfo) then
                local heatCfg = getConfig('mapHeat')
                if v.oid == 0  then
                    local upTime = ts - (heatInfo.ts or 0) 
                    if heatInfo.point > 0 or 1 then
                        local dePoint = math.floor(upTime / heatCfg.pointDecrSpeed)
                        heatInfo.point = (heatInfo.point or 0) - dePoint
                        if heatInfo.point < 0 then 
                            heatInfo.point = 0 
                        end
                    end
                end
                for k,v in ipairs(heatCfg.point4Lv) do
                    if heatInfo.point > v then
                        HeatLevel = k
                    else
                        break
                    end
                end

            end

            -- 叛军
            if tonumber(v.type) == 7 then
                if tonumber(v.protect) <= ts then
                    v = nil
                else
                    if not mRebel then 
                        mRebel = loadModel("model.rebelforces")
                    end

                    mRebel.formatMapData(v)
                end
            -- 将领试炼
            elseif tonumber(v.type) == 8 then
                if tonumber(v.protect) <= ts then
                    v=nil
                else
                    local mAnneal = loadModel("model.heroanneal", {uid=v.data.oid})
                    mAnneal.formatMapData(v)
                    oid = v.oid
                end
            end

            -- 混淆
            if invalid == true and v and v.oid ~= uid then
                v.oid = rand(1,100)%2
                heatInfo.ts = 0
                heatInfo.point = 0
                HeatLevel = 0
            end

            if v then
                local boompercent = 0 --非玩家(比如矿点) 默认0
                if tonumber(v.type)==6 then -- 玩家
                    boompercent = 100
                    if tonumber(v.boom_max)>0 and tonumber(v.boom_max)>tonumber(v.boom)  then
                        boompercent=math.floor(tonumber(v.boom)/tonumber(v.boom_max)*100)
                    end
                end

    	    	local item = {
    				v.id,
    				v.x,
    				v.y,
    				v.type,
    				v.level,
    				-- v.data,
    				0,
    				oid,--v.oid,
    				v.name,
    				v.power,
    				v.protect,
    				v.rank,
    				v.pic,
    				v.alliance,
    				0,
					0,
                    baseskin,
                	v.exp or 0,-- 17 矿点升级的经验
					HeatLevel, -- 18 富矿的等级
                    v.alliancelogo ~= '{}' and json.decode(v.alliancelogo) or {},-- 29 军团旗帜（logo）
                    boompercent,-- 当前的繁荣度百分比
                    v.bpic,--头像框
                    v.apic,--挂件
                }

                if goldMineMap1[v.id] then
                    goldMineMap2[v.id] = goldMineMap1[v.id]
                end

                table.insert(maplist,item)
            end
	    end
    end

    if next(goldMineMap2) then 
        response.data.goldMineMap = goldMineMap2
    end

    -- if request.params.goldMine == 1 then
    --     local mGoldMine = require "model.goldmine"
    --     local goldMineMap1 = mGoldMine.getGoldMineInfo()
    --     local getPosByMid = getPosByMid
    --     local pos
    --     for k,v in pairs(goldMineMap1) do
    --         pos = getPosByMid(tonumber(k))
    --         if pos.x < x1 or pos.x > x2 or pos.y < y1 or pos.y > y2 then
    --             goldMineMap1[k] = nil
    --         end

    --     response.data.goldMineMap = goldMineMap1
    -- end

    -- 鹰眼技能
    if request.params.eagleEye == 1 then
        local uid = request.uid
        local redis = getRedis()   
        local key = string.format("z%s.eagleEyeMap",getZoneId())

        local data = redis:hget(key,uid)
        if data then data = json.decode(data) end

        if type(data) ~= "table" then
            data = {0}
        end
        
        response.data.eagleEyeMap = data
    end

    if result then
        response.data.map = maplist 
        response.ret = 0	    
        response.msg = 'Success'
    else
        response.ret = -1
        response.msg = 'Failed'
    end
    
    return response
end
