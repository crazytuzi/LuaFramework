local function model_alliance(uid)
    local self = {
        allianceSkills = {},
    }

    local function formPostData(reqbody)
        if type(reqbody) == 'table' then
            local postdata = ''
            for k,v in pairs(reqbody) do
                if v then
                    postdata = postdata .. k .. '=' .. v .. '&'
                end
            end
            
            return postdata
        end
    end

    -- 获取数据
    local function allianceFetch(cmd,params)
        
        if moduleIsEnabled('alliance') == 0 then
            return {ret=-1}
        end

        local postdata = formPostData(params)
        local zoneid = getZoneId()
        postdata = (postdata or '') .. 'zoneid=' .. (zoneid or 0)
        if cmd then
            local http = require("socket.http")
            http.TIMEOUT= 3
            -- local URL = require("lib.url")
            -- postdata = postdata and URL:url_escape(postdata)            
            local allianceCenterUrl = getConfig("config.z".. zoneid ..".AllianceCenterUrl") .. cmd
            local respbody, code = http.request(allianceCenterUrl,postdata)

             if sysDebug() then
                ptb:p(allianceCenterUrl .. '?' .. (postdata or ''))
            end

            if tonumber(code) == 200 then     
                local result = json.decode(respbody)
                if not result then       
                    writeLog('alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'),'allianceFaild')
                    return false              
                    --error('alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'))
                end

                if sysDebug() then
                    ptb:p(result)
                end

                return result
            else
                writeLog(allianceCenterUrl .. '?' .. (postdata or ''), 'allianceFaild')
                writeLog('alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody') .. '|code:' .. (tostring(code) or 'no code'),'allianceFaild')
                return false
                --error('alliance_fetch failed:' .. (postdata or 'no postdata') .. '|respbody:' .. (tostring(respbody) or 'no respbody'))
            end
        end
    end  

    function self.bind()
        local data = alliance_fetch('bind',{aid=self.aid})
         
        if type(data) == 'table' then 
            for k,v in pairs(data) do
                self[k] = v
            end
        else
            error('alliance bind failed:' .. (self.alliance or 'no aid'))
        end
    end

    function self.toArray()
        local data = {}

        for k,v in pairs (self) do
            if type(v)~="function" then                
                data[k] = v
            end
        end

        return data
    end

    function self.get(params)
        local response = allianceFetch('get',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            local allianceRequests = arrayGet(response.data,'alliance>requests')                    
            if type(allianceRequests) == 'table' and (next(allianceRequests)) then
                for k,v in ipairs(allianceRequests) do
                    local memobjs = getUserObjs(v,true)
                    local meminfo = memobjs.getModel('userinfo')
                    local rInfo = {}
                    rInfo.uid = v
                    rInfo.nickname = meminfo.nickname
                    rInfo.level = meminfo.level
                    rInfo.fight = meminfo.fc

                    allianceRequests[k] = rInfo
                end
            end
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.getalliance(params)
        local response = allianceFetch('getalliance',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            local allianceRequests = arrayGet(response.data,'alliance>requests')                    
            if type(allianceRequests) == 'table' and (next(allianceRequests)) then
                for k,v in ipairs(allianceRequests) do
                    local memobjs = getUserObjs(v,true)
                    local meminfo = memobjs.getModel('userinfo')
                    local rInfo = {}
                    rInfo.uid = v
                    rInfo.nickname = meminfo.nickname
                    rInfo.level = meminfo.level
                    rInfo.fight = meminfo.fc

                    allianceRequests[k] = rInfo
                end
            end
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.getuseralliance(params)
        params.getuser = 1
        
        local response = allianceFetch('getalliance',params)

         if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    --后台修改用户名称	
    function self.admin(params)
    	local response = allianceFetch('admin',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            local allianceRequests = arrayGet(response.data,'alliance>requests')
            if type(allianceRequests) == 'table' and (next(allianceRequests)) then
                for k,v in ipairs(allianceRequests) do
                    local memobjs = getUserObjs(v,true)
                    local meminfo = memobjs.getModel('userinfo')
                    local rInfo = {}
                    rInfo.uid = v
                    rInfo.nickname = meminfo.nickname
                    rInfo.level = meminfo.level
                    rInfo.fight = meminfo.fc

                    allianceRequests[k] = rInfo
                end
            end
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.setMemberAuth(params)
        local response = allianceFetch('setMemberAuth',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 管理员权限，团长副团长
    -- param int uid 用户Id
    -- return boolean
    function self.getAdminAuthority(uid)

    end

    -- 批准申请
    -- parma int memberId 新成员的id
    -- return boolean
    function self.acceptJoin(params)
        local response = allianceFetch('accept',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取城员列表
    -- return table
    function self.getMemberList(params)
        local response = allianceFetch('memberlist',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取工会的Id
    -- param int uid 用户Id
    -- return int 
    function self.getaid(uid)

    end

    -- 获取用户的申请列表/数量
    -- param int uid 用户id
    -- return table
    function self.getUserApplyList(uid)

    end

    -- 申请列表是否已满
    -- return boolean
    function self.applyListIsFull()

    end

    -- 成员是否已满
    -- return boolean
    function self.memberIsFull()

    end

    -- 加入的类型
    -- return int 1是自由加入 2是需要批准
    function self.getJoinType()

    end

    -- 增加成员
    -- return boolean
    function self.addMember()

    end

    -- 增加申请人
    -- return boolean
    function self.join(params)
        local response = allianceFetch('join',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 增加申请人
    -- return boolean
    function self.updateFight(params)
        local response = allianceFetch('updateFight',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 返回军团当前的申请人列表
    -- return table
    function self.getApplyList()

    end

    -- 当前角色是否是军团的成员
    -- param int uid 用户id
    -- return boolean
    function self.isMember(uid)

    end

    -- 取消申请
    -- param int uid 用户id
    -- return boolean
    function self.canceljoin(params)

    end

    -- 检测名称
    -- param string name 军团名字
    -- return boolean
    function self.checkName(name)

    end

    -- 获取当前所有军团的数量，总的军团数量有上限
    -- return int
    function self.getAllianceNums()

    end

    -- 创建军团
    -- param table allianceInfo 军团信息
    -- return mixed 创建成功返回军团id|否则返回false 
    function self.create(allianceInfo)
        local response = allianceFetch('create',allianceInfo)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    -- 修改军团名字

    function self.setname(params)
        local response = allianceFetch('setalliancename',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取军团详细信息
    -- return table
    function self.getDetails(params)
        local response = allianceFetch('getdetails',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取军团成员的信息
    -- param int uid 成员的id
    -- return table
    function self.getMemberDetails(uid)

    end

    -- 用户是否是军团的成员
    -- param int uid 
    -- return boolean
    function self.isAllianceMember(uid)

    end

    -- 返回用户在军团中的职位标识，1军团长，2副团，3群众
    -- param uid 
    -- return int
    function self.getPosition(uid)

    end

    -- 设置用户在军团中的职位标识，1军团长，2副团，3群众
    -- param int uid
    -- param int role 职位标识
    -- return boolean
    function self.setRole(params)
        local response = allianceFetch('setRole',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 退出军团
    -- param int uid
    -- return boolean
    function self.quit(params) 
        local response = allianceFetch('quit',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end 

    -- 按名字检索军团，返回匹配的军团列表
    -- param string name 检索名
    -- return table
    function self.search(params)
        local response = allianceFetch('search',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取军团列表
    -- params  {fbrank=1,rerank=1} 副本关卡解锁排行，rerank是荣誉排行,空，是正常列表，
    -- return table
    function self.getList(params)
        local response = allianceFetch('ranklist',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        end
    end

    -- 获取推荐的军团列表
    -- 排序方式：1、加入方式；2、人数未达到上限；3、至少有1名成员在最近2天内登录过游戏
    -- return table
    function self.getRecommendList(params)
        local response = allianceFetch('list',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        end
    end

    -- 拒绝用户的申请
    -- param int uid
    -- return boolead
    function self.deny(params)
        local response = allianceFetch('deny',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 拒绝所有用户的申请
    -- return boolean
    function self.refuseAllApply()
    end

    -- 设置成员签名
    -- param string notice
    -- return boolean  
    function self.setMemNotice(notice)
    end

    -- 更新军团设置
    -- param table settings 配置详情
    -- return boolean
    function self.updateSettings(params)
        local response = allianceFetch('edit',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 更新成员设置
    -- param table settings 配置详情
    -- 参数：
    -- int aid 军团id 
    -- string signature 成员签名
    -- int memuid=1000333 成员id
    -- int role=1 权限标识
    -- return boolean
    function self.editMember(params)
        local response = allianceFetch('editMember',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 是否是申请的会员
    -- int uid 用户的uid
    -- return boolean
    function self.isApplyMember(uid)

    end

    -- 军团等级提升
    function self.levelUp()
    end

    -- 捐献列表
    function self.getContributeList()
    end

    -- 捐献
    -- return boolean
    function self.donate(params)
        local response = allianceFetch('raising',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 军团技能
    -- return boolean
    function self.getAllianceSkills(params)
        
        if moduleIsEnabled('allianceskills') == 0 or not params.aid then
            return {}
        end

        local allianceSkills = getUserAllianceSkills(params.aid)

        if type(allianceSkills) == 'table' then
            return allianceSkills
        end

        local response = allianceFetch('getskill',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 and type(response.data.skills) == 'table' then           
            for k,v in pairs(response.data.skills) do 
                    response.data.skills[k] = tonumber(v) or 0
            end

            setUserAllianceSkills(params.aid,response.data.skills)

            return response.data.skills
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 军团事件
    -- params={type,ts,playername,攻击者名字,损失资源数量,攻击者军团的名字}
    function self.setEvents(params)
        local response = allianceFetch('setevents',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取军团事件
    -- params={type,ts,playername,攻击者名字,损失资源数量,攻击者军团的名字}
    function self.getEvents(params)
        local response = allianceFetch('getevents',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取军团关卡数据
    -- params={aid=1,uid=uid,}
    function self.getChallenge(params)
        local response = allianceFetch('getbarrier',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response.data
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 设置军团关卡数据
    -- params={aid=1,sid=1,troops={a1001=10},isvictory=1}
    function self.setChallenge(params)
        local response = allianceFetch('setbarrier',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.addPoint(params)    
        local response = allianceFetch('addpoint',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 军团商店 -----------------------------------------

    -- 获取军团商店珍品
    function self.refreshShop(pool)        
        local shops = getRewardByPool(pool)

        return shops
    end

    -- 军团珍品已购买量
    function self.alliancestoreinfo(params)
        local response = allianceFetch('alliancestoreinfo',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return {}
        end
    end

    -- 重置军团珍品量
    function self.resetStore()
        local response = allianceFetch('resetStore')

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --[[
        获取商店最后一次刷新时间
        珍品的获取时间分为三段，6/18/24，如果当前是7点，那么返回值应该是6，如果当前是19点，返回值应该是18
    ]]
    function self.getShopLastRefreshTs(aShopRefreshTime,ts)
        local lastTs,nextTs
        local weets = getWeeTs(ts)

        for _,v in ipairs(aShopRefreshTime) do
            nextTs = weets + v[1] * 3600 + v[2] * 60 

            if ts < nextTs then
                return lastTs
            end 

            lastTs = nextTs
        end

        return lastTs
    end

    -- 军团商店购买
    -- 会扣贡献，会累加珍品购买数，只有在购买珍品的时候，会把产品id传给军团
    -- params.item 购买的珍品，如果有此字段，传最近一次刷新珍品的时候给军团，否则没有必要做珍品刷新检测
    function self.alliancestore(params)
        local response = allianceFetch('alliancestore',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取
    function self.getShop(lastRefreshTs)
        local seedTableRefreshFlag = true   -- 刷新道具库
        local refreshFlag = true -- 是否刷新，如果刷新后，不需要获取军团当前已购买的信息，因为已购买的记录肯定会被清空
        local shops,oldShops,newShops,boughtInfo
        local ts = getClientTs()
        local cfg = getConfig('allianceShopCfg')
        lastRefreshTs = lastRefreshTs or self.getShopLastRefreshTs(cfg.aShopRefreshTime,ts)
        -- print(os.date("%x %X", lastRefreshTs))

        local cacheKey = "z"..getZoneId()..".md.alliance.shop"
        local redis = getRedis() 
        redis:watch(cacheKey)
        local result = redis:get(cacheKey)

        if result then
            oldShops = json.decode(result)
        end

        -- 如果缓存没有旧数据，直接从整个库刷新
        if type(oldShops) ~= 'table' then
            newShops = M_alliance.refreshShop(cfg.aShopPool)
            oldShops = {}
        else
            local refreshAt = oldShops.refreshAt or 0
            if refreshAt < lastRefreshTs then
                oldShops.sold = oldShops.sold or {}                
                local pool = {cfg.aShopPool[1],{},{}}
                -- oldShops.sold = {i6=100,i3=100,i4=100,i5=100,i2=18,i1=9}
                
                for k,v in pairs(cfg.aShopItems) do
                    if oldShops.sold[k] then
                        local weight = v.weight - oldShops.sold[k]
                        if weight > 0 then
                            table.insert(pool[2],weight)
                            table.insert(pool[3],cfg.aShopPool[3][v.index])
                        end
                    else
                        table.insert(pool[2],cfg.aShopPool[2][v.index])
                        table.insert(pool[3],cfg.aShopPool[3][v.index])
                    end
                end
                
                local seedNum = #pool[2]    -- 剩余道具种类基数
                local needNum = #pool[1]    -- 需要产出道具种类基数

                -- 如果剩余坦克种类为0,重新读配置
                if seedNum <= 0 then
                    newShops = M_alliance.refreshShop(cfg.aShopPool)
                    oldShops.sold = {}

                -- 如果当前剩余道具种类小于必需产出的道具种类
                -- 直接取当前剩余的坦克，并且从完整的库中取出差的道具种类
                elseif seedNum < needNum then
                    newShops = pool[3]
                    pool = copyTable(cfg.aShopPool) 
                    pool[1] = {}

                    local diffNum = needNum-seedNum
                    for i=1, diffNum do
                        if i == diffNum then
                            table.insert(pool[1],100)
                        else
                            table.insert(pool[1],0)
                        end
                    end

                    local diffShops = M_alliance.refreshShop(pool)
                    
                    for _,v in pairs(diffShops or {}) do 
                        table.insert(newShops,v)
                    end

                    oldShops.sold = {}
                    seedTableRefreshFlag = false
                else
                    newShops = M_alliance.refreshShop(pool)
                end
            end
        end

        if newShops then
            local data = {
                shops = newShops,
                sold = oldShops.sold or {},
                refreshAt = ts,
            }

            if seedTableRefreshFlag then
                for _,item in ipairs(newShops) do
                    data.sold[item] = (data.sold[item] or 0) + 1
                end
            end

            redis:multi()
            redis:set(cacheKey,json.encode(data))
            local execret = redis:exec()

            if not execret then
                return response
            else
                -- M_alliance.resetStore()                
            end

            shops = newShops
        else
            shops = oldShops.shops
            refreshFlag = false
        end

        return shops,refreshFlag
    end

    ---------------------------------------------------------




    -- 弹劾军团长或者副团
    -- return table
    function self.impeach(params)
        local response = allianceFetch('impeach',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end



    --自己晋升自己
    function self.promotion(params)    
        local response = allianceFetch('promotion',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end


    --报名参加军团战
    function self.apply(params)    
        local response = allianceFetch('apply',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    
   --报名军团的排行榜
    function self.applyrank(params)    
        local response = allianceFetch('applyrank',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --获取报名信息
    function self.getapply(params)    
        local response = allianceFetch('getapply',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end





    --集合了
    function self.joinline(params)    
        local response = allianceFetch('joinline',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --获取上阵队列和集合的成员
    --参数  aid  
    function self.getqueue(params)    
        local response = allianceFetch('getqueue',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end


 --获取上阵队列和集合的成员type =1 是上阵   =2 下阵
 --参数 aid   type   q位置 (q1-q15)  memuid
    function self.updatequeue(params)    
        local response = allianceFetch('updatequeue',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

     --设置军团战的个人获得贡献值
     --参数  uid    warid    raising 
    function self.setuserraising(params)    
        local response = allianceFetch('setuserraising',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

     --获取军团战的战报
     --参数 uid  aid  warid
    function self.getbattlelog(params)    
        local response = allianceFetch('getbattlelog',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --设置军团战的战报 method =1 是军团的 =2 是个人的战报
    --参数  method    data json格式 和数据库的字段保持一致
    function self.addbattlelog(params)    
        local response = allianceFetch('addbattlelog',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --设置阵地被哪个军团掳了
    --参数  aid   placeid   open_at
    function self.setplace(params)    
        local response = allianceFetch('setplace',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

     --获取阵地的状态
     --参数 无
    function self.getplaces(params)    
        local response = allianceFetch('getplaces',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --获取军团战某个成员的上阵状态 
    --参数  aid  uid
    function self.getmembequeue(params)    
        local response = allianceFetch('getmembequeue',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --军团战结算
    function self.endbattle(params)
       require 'model.active'
       local mActive = model_active()
       local actives = mActive.toArray(true)
       local ts = getClientTs()    
       local activeCfg = getConfig("active")
       if type(actives) == 'table' then
            for k,v in pairs(actives) do
                if activeCfg[k] and tostring(k)=="harvestDay" then
                    if tonumber(v.st)<=ts and tonumber(v.et)>ts then
                        params.acst=v.st
                        params.acet=v.et    
                    end
                end
            end
        end    

        local response = allianceFetch('endbattle',params)
      
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            -- 每日捷报设置军团站胜利的军团
            if type(response.data)=="table" and next(response.data) then
                local ninfo=response.data
                local newsdata={ninfo.aname,ninfo.level,ninfo.commander,ninfo.fight,ninfo.amaxnum,ninfo.memberNum,ninfo.type,ninfo.level_limit,ninfo.fight_limit,ninfo.notice,ninfo.aid}
                local news={title="d20",content={
                    allianceinfo={
                        newsdata
                    }
                }}
                setDayNews(news)
            end
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --军团战参战玩家奖励结算
    function self.endbattleuser(params)
        local response = allianceFetch('endbattleuser',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取军团战参战人员
    function self.getwarmembers(params)    
        local response = allianceFetch('getwarmembers',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    --获取地块前两名里的成员邮件推送
    function self.sendbattlemsg(params)

        local response = allianceFetch('sendbattlemsg',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

    end

    -- 军团活跃  协防
    function self.setDefance(params)
        local response = allianceFetch('setdefance',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end


    -- 军团活跃  资源
    function self.setResource(params)
        local response = allianceFetch('setresource',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    -- 军团活跃 获取资源
    function self.getResource(params)
        local response = allianceFetch('getresource',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    -- 军团活跃奖励

    function self.getResourceReward(params)
        local response = allianceFetch('getresourcereward',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end



    -- 获取结算状态
    function self.getbattlestatus(params)

        local response = allianceFetch('getbattlestatus',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

    end    

    -- 军团战占据据点加成
    function self.getalliancebonus(params)

        local response = allianceFetch('getalliancebonus',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

    end
    -- 军团收获日活动
    function self.addacpoint(params)

        local response = allianceFetch('addacpoint',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

    end

    -- 军团战验证是否能打仗
    function self.getbattleflag(params)

        local response = allianceFetch('getbattleflag',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

    end
    -- 获取军团的name
    function self.getalliancesname(params)
        local response = allianceFetch('getalliancesname',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 区域站报名
    function self.applyarea(params)
        local response = allianceFetch('applyarea',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --跨服区域战报名
    function self.applyareawar(params)
        local response = allianceFetch('applyareawar',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return response,arrayGet(response,'ret',-1)
        end

    end

    -- 获取区域站的排行榜
    function self.applyrankarea(params)
        local response = allianceFetch('applyrankarea',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取跨服区域站的排行榜
    
    function self.applyrankareawar(params)
        local response = allianceFetch('applyrankareawar',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取自己报名的数据
    function  self.getapplyareawar(params)
        local response = allianceFetch('getapplyareawar',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取区域站的自己的信息
    function self.getapplyarea(params)
        local response = allianceFetch('getapplyarea',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    -- 设置叛军信息
    function self.setforces(params)
        local response = allianceFetch('setforces',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 获取叛军
    function self.getforces(params)
        local response = allianceFetch('getforces',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    -- 干死叛军
    -- aid  军团id
    -- mid  ＝叛军地图上的id
    -- ts   =叛军的过期时间
    -- lvl  =叛军的等级
    -- name =击杀叛军的玩家名字
    -- reward =击杀奖励
    -- rfname  = 叛军的名字编号
    -- uid     ＝ 击杀叛军的玩家的uid
    -- alliancename     ＝ 击杀叛军的玩家军团名字
    -- x       叛军的x
    -- y       叛军的y
    function self.killforces(aid,mid,exts,lvl,name,reward,rfname,uid,alliancename,x,y)
        local ts = getClientTs()
        local rebelCfg=getConfig('rebelCfg')
        local battlelogLib=require "lib.battlelog"
        local log={}
        log.aid=aid
        log.rfname=rfname
        log.name=name
        log.kill_at=ts
        log.lvl=lvl
        log.dieid=mid.."-"..exts
        log.alliancename=alliancename
        battlelogLib:allianceLogSend(log,uid,x,y)
        local redis = getRedis()
        local logkey = "z"..getZoneId()..".rebelforceslog."..aid
        redis:del(logkey)
        local overdue=rebelCfg.overdue
        local ret=self.getalliance{alliancebattle=1,method=1,aid=aid} 
        if ret.data~=nil then
            if ret.data.members ~=nil then
                local members=ret.data.members
                if type(members)=='table' and next(members) then
                    local title=50
                    local cronParams={cmd ="alliancerebel.killreward",params={members=members,lvl=lvl,reward=reward,overdue=overdue,ts=ts,count=count}}
                    local ret=setGameCron(cronParams,1)
                    if not ret then
                        setGameCron(cronParams,1)
                    end
                end
                
            end
        end
    end

    --区域站抓取前几
    function self.sendareabattlemsg(params)
        local response = allianceFetch('sendareabattlemsg',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    -- 区域站设置职位
    function self.setjob(params)
        local response = allianceFetch('setjob',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 区域站获取所有职位信息
    function self.getjobs(params)
        local response = allianceFetch('getjobs',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

        -- body
    end


    --  区域站获取可以战斗的军团
    function self.getAreaBattleAlliance(params)
        local params =params or {}
        local ts = getClientTs()
        local areaWarCfg = getConfig('areaWarCfg')
        
        local weeTs = getWeeTs()
        local weekday=tonumber(getDateByTimeZone(ts,"%w"))

        local date=weeTs
        if areaWarCfg.prepareTime<=weekday then
            if weekday-areaWarCfg.prepareTime>0 then
                date=weeTs-((weekday-areaWarCfg.prepareTime)*86400)
            end
        end
 
        local response = allianceFetch('getareabattle',{date=date,count=areaWarCfg.signupBattleNum})
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 区域站结算
    function self.endareabattle(params)
        local redis = getRedis()
        local weets = getWeeTs()
        local key = "z"..getZoneId()..".areaEndBattle."..weets
        local refret=redis:get(key)
        if  refret~=nil and  tonumber(refret) >=1  then
            return true
        end

        redis:incr(key)
        redis:expire(key,5*24*3600)
        local list=nil
        local tasks=nil
        if type(params.donateList)=='table' then  list=copyTab(params.donateList) end
        if params.aid==nil or params.aid<=0 then
            if params.aid==0 then
                self.sendArenRankReward(list)
            end
            return false,-102
        end
        if params.content~=nil then
            if type(params.content)=='table' then
                params.content=json.encode(params.content)
            end    
        end
        if params.aslave~=nil then
            if type(params.aslave)=='table' then
                params.aslave=json.encode(params.aslave)
            end
        end
        if params.tasks~=nil then
            tasks=copyTab(params.tasks)
        end
        writeLog(json.encode(params),'endAreaBattle')
        params.own_at=getAreaBuffEnd()
        params.donateList=nil
        params.tasks=nil     
        local response = allianceFetch('endarea',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            local uid=tonumber(response.data.commander_id)
            local uobjs = getUserObjs(uid,true)
            uobjs.load({"userinfo","jobs","userareawar"})
            local mUserinfo = uobjs.getModel("userinfo")
            local mJobs     = uobjs.getModel("jobs")
            mJobs.job=1
            mJobs.aid=params.aid
            mJobs.end_at=params.own_at
            local members=response.data.members
            self.sendAreaMailWin(members)
            self.sendAreaTaskReward(tasks,params.bid,uid)
            self.sendAreaWinReward(params.aid,params.bid)
            local key   ="z" .. getZoneId() .."arenBattleWinAlliance"
            local redis = getRedis()
            redis:del(key)
            self.allianceAreaWarSendMsg(params.aid,response.data.commander,response.data.aname)
            addAreaWarCity({date=getWeeTs(),aname=response.data.aname,commander=response.data.commander,pic=mUserinfo.pic,bpic=mUserinfo.bpic,apic=mUserinfo.apic})
            -- 每日捷报 区域站胜利的军团
            local ninfo=response.data
            local newsdata={ninfo.aname,ninfo.level,ninfo.commander,ninfo.fight,ninfo.amaxnum,ninfo.memberNum,ninfo.type,ninfo.level_limit,ninfo.fight_limit,ninfo.notice,params.aid}
            local news={title="d19",content={
                allianceinfo={
                    newsdata
                }
            }}
            setDayNews(news)
            if not uobjs.save() then
                -- 保存失败要处理王者的职位
                local db = getDbo()
                local result = db:query("update jobs set end_at="..params.own_at..",job=1,aid="..params.aid.."   where uid="..uid)
                if result then
                    local redis = getRedis()
                    key = "z"..getZoneId()..".udata."..uid
                    redis:hset(key,'jobs.end_at',params.own_at)
                    redis:hset(key,'jobs.aid',params.aid)
                    redis:hset(key,'jobs.job',1)
                    return true
                end
                return false,-1
            end
            return true
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    --  区域军团胜利邮件
    function self.sendAreaMailWin(members)
        -- body
        if type(members)~="table" then
            return false
        end
        local redis = getRedis()
        local weets = getWeeTs()
        local key = "z"..getZoneId()..".areaWinMail."..weets
        local refret=redis:get(key)
        if  refret~=nil and  tonumber(refret) >=1  then
            return true
        end

        redis:incr(key)
        redis:expire(key,5*24*3600)
        for k,v in pairs(members) do
            if type(v)=='table' and next(v) then
                local mid =tonumber(v.uid)
                if mid>0 then
                     local title=33
                    local content={type=33}
                    local ret = MAIL:mailSent(mid,1,mid,'','',title,content,1,0)
                end
            end
        end
    end

    -- 区域排名奖励
    function self.sendAreaRankReward(list) 

        if type(list)~="table" then
            return false
        end
        local redis = getRedis()
        local weets = getWeeTs()
        local key = "z"..getZoneId()..".areaRankReward."..weets
        local refret=redis:get(key)
        if  refret~=nil and  tonumber(refret) >=1  then
            return true
        end

        redis:incr(key)
        redis:expire(key,5*24*3600)
        local cfg=getConfig('areaWarCfg.rankReward')
        for k,v in pairs (list) do
            if type(v)=='table' and next(v) then
                local item={}
                local mid =tonumber(v[1])
                for rk,rv in pairs(cfg) do
                    if k>=rv["range"][1] and k<=rv["range"][2] then
                        item.q=rv.reward
                        item.h=rv.serverReward
                        break
                    end
                end
                if next(item) and mid>0 then
                    local title=32
                    local content={type=32,rank=k}
                    local ret = MAIL:mailSent(mid,1,mid,'','',title,content,1,0,2,item)

                end
            end
        end
    end


    -- 发送活跃奖励完成任务
    -- tasks  成员完成的任务 uid={t1=20}
    -- bid    战斗id
    -- 军团长的不保存
    function self.sendAreaTaskReward(tasks,bid,muid)
        local redis = getRedis()
        local key="z" .. getZoneId() ..".areawar.".."bid"..bid.."taskreward"
        local weet=getWeeTs()
        local db = getDbo()
        if type(tasks)=='table' and next(tasks) then
            local title=48
            local taskcfg=getConfig('areaWarCfg.task')
            local taskreward=getConfig('areaWarCfg.taskreward')
            local ret =redis:incr(key)
            if  ret==1  then
                for k,v in pairs (tasks) do
                    local task=v
                    local reward={}
                    if type(task)=='table' and next(task) then
                        local uid=tonumber(k)
                        if uid~=muid then
                            local uobjs = getUserObjs(uid,true)
                            uobjs.load({"userinfo","hero","troops","userareawar"})
                            local mUserareawar=uobjs.getModel('userareawar')
                            mUserareawar.task=task
                            uobjs.save()
                        else
                            local uobjs = getUserObjs(uid,true)
                            local mUserareawar=uobjs.getModel('userareawar')
                            mUserareawar.task=task  
                        end
                        for tk ,tv in pairs(task) do
                            if type(taskcfg[tk])=="table" then

                               if  (tk=='t7' or tk=='t8' or tk=='t9' ) then
                                    if taskcfg[tk][1]>=tv  then
                                        if type(taskreward[tk][2])=='table' then
                                            for ad,av in pairs (taskreward[tk][2]) do
                                                reward[ad]=(reward[ad] or 0)+av
                                            end
                                        end
                                    end
                               else
                                if taskcfg[tk][1]<=tv then   
                                   if type(taskreward[tk][2])=='table' then
                                        for ad,av in pairs (taskreward[tk][2]) do
                                            reward[ad]=(reward[ad] or 0)+av
                                        end
                                   end
                                end
                               end
                            end
                        end

                        if next(reward) then
                            if moduleIsEnabled('rewardcenter')==1 then
                                local ret = sendToRewardCenter(uid,'areawar',title,weet,nil,{type=title,bid=bid},reward)
                            else
                                local item={h=reward,q=formatReward(reward)}
                                local ret = MAIL:mailSent(uid,1,uid,'','',title,json.encode{type=title,bid=bid},1,0,2,item)
                            end

                        end


                    end
                end
            end
        end
        redis:expire(key,86400)
    end



    -- 发奖胜利调用
    -- aid 军团id
    -- bid 战斗id
    function self.sendAreaWinReward(aid,bid)
        local redis = getRedis()
        local key="z" .. getZoneId() ..".areawar.".."bid"..bid
        local ret =redis:incr(key)
        local title=47
        local winreward=getConfig('areaWarCfg.winreward')
        local weet=getWeeTs()
        if ret==1 then
            local users={}

            local db = getDbo()
            local result = db:getAllRows("select uid from  userareawar where bid=:bid  and aid=:aid ", {bid=bid,aid=aid})
            if result then
                users=result
            end
            local item={q=winreward.reward,h=winreward.serverReward}
            for k,v in pairs (users) do
                local uid=tonumber(v.uid)
                if moduleIsEnabled('rewardcenter')==1 then
                    local reward = item.h or {1,item.h}
                    local ret = sendToRewardCenter(uid,'areawar',title,weet,nil,{type=title,bid=bid},reward)
                else
                    local ret = MAIL:mailSent(uid,1,uid,'','',title,json.encode{type=title,bid=bid},1,0,2,item)
                end
            end
        end
        redis:expire(key,86400)
    end

    function self.allianceAreaWarSendMsg(aid,commander,aname)
        local ts = getClientTs()
        local msg={
                sender=0,
                reciver=0,
                channel=1,            
                sendername="",
                recivername="",
                type="chat",
                content={
                    isSystem=1,
                    message={
                        key="chatSystemMessage25",
                        param={aname,commander},
                    },
                    ts=ts,
                    contentType=3,
                    subType=4,
                },
            }
        
        local ret=sendMessage(msg)
        -- writeLog(json.encode(msg).."------"..ret,'sendAreaNotic')
        return ret
    end

    -- 设置军团副本boss
    function self.setBoss(params)
        local response = allianceFetch('setallianceboss',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    -- 消耗 军团贡献
    function self.useRaising(params)
        local response = allianceFetch('useraising',params)
        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end
    
    function self.checkLogo(logo)
        local status = 0 -- 默认0 代表检查失败 logo参数有问题
        local cost = 0
        local logoCfg = getConfig('allianceflag')
        
        if type(logo) ~= 'table' or not next(logo) then
            return status
        end
        
        if #logo < #logoCfg.list then
            return status
        end

        for i,v in pairs(logo) do
            local logoType = tonumber(i)
            local logoIndex = tonumber(v)
            
            if not logoType or not logoIndex then
                return status
            end
            
            if logoCfg.list[logoType] and logoCfg.list[logoType][logoIndex] then
                cost = cost + (logoCfg.list[logoType][logoIndex].gemCost or 0)
            else
                -- 任何一个索引找不到都属于异常 直接报错
                return -1
            end
        end
        
        -- 没有意外发生 说明状态正常
        status = 1
        -- 暂不开放付费logo功能 所以默认不收费
        cost = 0
        return status,cost,logo
    end

   -- 扣除军团资金
    function self.costacpoint(params)

        local response = allianceFetch('costacpoint',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end

    end

    -- 修改军团名字(通过命令 跑脚本修改军团名 注：平时不要用)
    function self.resetaname(params)
        local response = allianceFetch('resetaname',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end   

    --修改军团玩家名字
    function self.editname(params)    
        local response = allianceFetch('editname',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end 
    --修改军团科技等级
    function self.upallianceskill(params)    
        local response = allianceFetch('upallianceskill',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    function self.commendList(params)
        local response = allianceFetch('commend',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        end
    end 

    -- 通过gm设置军团成员职位
    -- param int uid
    -- param int role 职位标识
    -- param int aid 军团id
    function self.setRoleBygm(params)
        local response = allianceFetch('setrolebygm',params)

        if type(response) == 'table' and tonumber(response.ret) == 0 then
            return response
        else
            return false,arrayGet(response,'ret',-1)
        end
    end

    return self
end

return model_alliance()

