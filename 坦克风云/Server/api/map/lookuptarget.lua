function api_map_lookuptarget(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
        
    local uid = request.uid or 0
    if uid == 0 then
        response.ret = -104
        response.msg = 'uid invalid'
        return response
    end

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo"})
    local mUserinfo = uobjs.getModel('userinfo')

    local db = getDbo()
    local mapData = nil
    local self = {}

    -- 搜索
    -- 查找5个资源点和5个玩家， 最多查找5次，没有玩家用资源点代替。
    function self.lookup()
        -- body
        local ret = {}
        setRandSeed()

        local userlist, ailist = {}, {}
        local adduser, addAi = 0, 0
        -- 找目标
        for ilookup=1, 5 do 
             
            if not self.checkUser(userlist) then
                userlist = self.findUser(adduser)
            end

            if not self.checkAi(ailist) then
                ailist = self.findAi(addAi)
            end

            if self.checkAi(ailist) and self.checkUser(userlist) then
                break
            end

            --扩大范围， 重来
            adduser = adduser + 1
            addAi = addAi + 4
        end

        local num = #userlist > 4 and 4 or #userlist --新增叛军坐标， 玩家只要4个
        local randList

        --玩家最多五个
        randList = self._randnum(#userlist, num)
        for k, vIdx in pairs(randList) do
            table.insert(ret, userlist[vIdx])
        end

        --资源点个1个
        local slots = {}
        for k, v in pairs(ailist) do
            slots[v.type] = slots[v.type] or {} 
            table.insert(slots[v.type], k)
        end
        local used_index = {}
        for k, v in pairs(slots) do
            local rand_index = rand(1, #slots[k])
            table.insert(used_index, slots[k][rand_index])
            table.insert(ret,  ailist[ slots[k][rand_index] ])
        end

        --不足的补充资源点
        num = #ret > 10 and 0 or 10 - #ret
        local get_index = 1
        while (#ret < 10 and get_index <= #ailist ) do
            if not self.inArray(used_index, get_index) then
                table.insert(ret, ailist[ get_index ])
            end
            get_index = get_index + 1
        end

        return ret
    end

    --存在数组中
    function self.inArray(arr, value)
        -- body
        for k, v in pairs(arr) do
            if v == value then
                return true
            end
        end

        return false
    end

    --数据合格
    function self.checkUser(userlist)
        -- body
        if #userlist >= 5 then return true end

        return false
    end

    --检测ai
    function self.checkAi(ailist )
        -- body
        if #ailist < 10 then return false end

        local slot = {}
        for k, v in pairs(ailist) do 
            slot[v.type] = slot[v.type] or 1
        end
        local all = 0
        for k, v in pairs(slot) do
            all = all + v
        end

        if all == 6 then return true end

        return false
    end

    --按等级搜索 user
    function self.findUser( add )
        -- body
        -- local x1 = mUserinfo.mapx - 9 
        -- local x2 = mUserinfo.mapx + 9 
        -- local y1 = mUserinfo.mapy - 9 
        -- local y2 = mUserinfo.mapy + 9 
        local lv1 = mUserinfo.level - 1 - add
        local lv2 = mUserinfo.level + 1 + add

        -- local result = db:getAllRows("select * from map where  x>=:x1 and x<=:x2 " .. 
        --     "and y>=:y1 and y<=:y2 and level>=:lv1 and level<=:lv2  " ..
        --     "and type=6 and oid<>:uid ",{x1=x1,x2=x2,y1=y1,y2=y2,lv1=lv1,lv2=lv2,uid=uid})
        local result = {}
        for k, v in pairs(mapData) do 
            if tonumber(v.type) == 6 and  tonumber(v.level) >= lv1 and tonumber(v.level) <= lv2 then
                table.insert(result, v)
            end
        end

        return result        
    end

    --按等级搜索 ai
    function self.findAi( add )
        -- body
        -- local x1 = mUserinfo.mapx - 9 
        -- local x2 = mUserinfo.mapx + 9 
        -- local y1 = mUserinfo.mapy - 9 
        -- local y2 = mUserinfo.mapy + 9 
        local lv1 = mUserinfo.level - 1 - add
        local lv2 = mUserinfo.level + 1 + add
        --print('findAi ------------------------------------- ', add)
        if lv2 > 50 then
            lv1 = 50 - add - 1
            lv2 = 50
        end
        -- local result = db:getAllRows("select * from map where  x>=:x1 and x<=:x2 " .. 
        --     "and y>=:y1 and y<=:y2 and level>=:lv1 and level<=:lv2  " ..
        --     "and type>0 and type<6 ",{x1=x1,x2=x2,y1=y1,y2=y2,lv1=lv1,lv2=lv2,uid=uid})
        local result = {}
        for k, v in pairs(mapData) do 
            --print(v.type, v.level, lv1, lv2, v.x, v.y)
            if (tonumber(v.type) < 6 or tonumber(v.type) ==7) and  tonumber(v.level) >= lv1 and tonumber(v.level) <= lv2 then
                table.insert(result, v)
            end
        end

        return result        
    end

    --组装玩家信息
    function self.toArray( datalist )
        -- body

        for k, v in pairs(datalist) do 
            if tonumber(v.type) == 6 then
                local playerobjs = getUserObjs(tonumber(v.oid) )
                playerobjs.load({"userinfo", 'boom'})
                local mBoom = playerobjs.getModel('boom')
                mBoom.update()
                datalist[k].boom = mBoom.boom     
            end

            -- 叛军
            if tonumber(v.type) == 7 then
                if not mRebel then 
                    mRebel = loadModel("model.rebelforces")
                end
                if type(v.data) == 'string' then
                    v.data = json.decode( v.data ) or {}
                end

                mRebel.formatMapData(v)
            end            

            v.data = nil
        end

        return datalist
    end

    -- 生成多个不同的随机索引
    function self._randnum(max, count)
        -- body
        if max < count then return {} end

        local mslot = {}
        for i=1, max do 
            mslot[i] = 1
        end

        local ret = {}
        for i=1, count do
            local randkey = rand(1, max)
            for k, v in pairs(mslot) do
                if randkey <= v then
                    mslot[k] = 0
                    table.insert(ret, k)
                    break
                else
                    randkey = randkey - v
                end
            end
            max = max - 1
        end

        return ret
    end

    --select db 查找该范围的所有数据
    function self.lookupMap( )
        -- body
        local x1 = mUserinfo.mapx - 9 
        local x2 = mUserinfo.mapx + 9 
        local y1 = mUserinfo.mapy - 9 
        local y2 = mUserinfo.mapy + 9
        local ts = getClientTs()   
        --print(mUserinfo.mapx, mUserinfo.mapy, x1, x2, y1, y2)      
        mapData = db:getAllRows("select * from map where  x>=:x1 and x<=:x2 " .. 
            "and y>=:y1 and y<=:y2 and (((type>0 and type<6 and oid=0 or type=6) and oid<>:uid and protect<:ts) or (type=7 and protect>:ts )) ",
            {x1=x1,x2=x2,y1=y1,y2=y2,uid=uid, ts=ts})

        return mapData
    end

    -----------------------------------------------
    mapData = self.lookupMap()

    local map = self.lookup()
    map = self.toArray( map )
    if type(map) ~= 'table' then
        return response
    end

    local weeTs = getWeeTs()
    local key = getZoneId() .. ".scanrebel." .. uid .. "." .. weeTs
    local cnt = getRedis():get(key) or 0

    if uobjs.save() then
        response.ret = 0
        response.data.near = map
        response.data.rebelcnt = cnt
        response.msg = "success"
    else
        response.ret = -106
        response.msg = "bind failed"        
    end
    
    return response
end
