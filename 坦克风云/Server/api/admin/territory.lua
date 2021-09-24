local function api_admin_territory(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    -- 查看领地信息
    function self.action_view(request)
        local response = self.response
        local aid =  request.params.aid
        local aname = request.params.aname
    
        if not aid and not aname then
            response.ret = -1
            return response
        end

        local mAterritory 
        
        local allianceName = ''
        -- 优先使军团编号 再使用军团名
        if aid and aid>0 then
            mAterritory = getModelObjs("aterritory",aid,true)

            if mAterritory.isEmpty() then
                response.ret = -1
                response.msg = 'territory not exist'
                return response
            end
      
            local aidlist = {}
            table.insert(aidlist,aid)
            local setRet,code=M_alliance.getalliancesname{aids=json.encode(aidlist)}
            if type(setRet['data'])=='table' and next(setRet['data']) then     
                for k,v in pairs(setRet['data']) do
                    allianceName = v.name
                    break
                end
            else
                response.ret = -1
                response.msg = 'alliance not exist'
                return response
            end
        else
             local ret = M_alliance.getalliance{aname=aname}
             if type(ret['data'])=='table' and next(ret['data']) then
                allianceName = ret['data']['alliance']['name']
             else
                response.ret = -1
                response.msg = 'alliance not exist'
                return response
             end

             aid = tonumber(ret['data']['alliance']['aid'])
    
             mAterritory = getModelObjs("aterritory",aid,true)

            if mAterritory.isEmpty() then
                response.ret = -1
                response.msg = 'territory not exist'
                return response
            end
        end

        local ts= getClientTs()
        local weeTs = getWeeTs()
        local allianceBuidCfg = getConfig('allianceCity')

        local weekday=tonumber(getDateByTimeZone(ts,"%w"))
        if weekday == 0 then weekday =7  end

        -- 以上周结束时为标识
        local lastInit = weeTs-weekday*86400-2*3600
        if mAterritory.kill_at~=lastInit then
            mAterritory.killcount = 0
        end
               
        local territory = {
            aid = mAterritory.aid,-- 军团ID
            name = allianceName,-- 军团名字
            b1 = mAterritory.b1,-- 基地
            b2 = mAterritory.b2,-- 仓库
            b3 = mAterritory.b3,-- 控制台
            b4 = mAterritory.b4,-- 铀矿
            b5 = mAterritory.b5,-- 天然气矿
            dev_point = mAterritory.dev_point, -- 发展值
            main_power = mAterritory.main_power, -- 发展值费维护费用
            status = mAterritory.status, -- 是否挂起 0挂起 1正常 2摧毁
            power = mAterritory.power,-- 能量
            r1 = mAterritory.r1, -- 仓库钢铁
            r2 = mAterritory.r2, -- 仓库铝
            r3 = mAterritory.r3, -- 仓库钛
            r4 = mAterritory.r4, -- 仓库石油
            r6 = mAterritory.r6, -- 仓库铀
            r7 = mAterritory.r7, -- 仓库天然气
            mapx = mAterritory.mapx,-- 领地X坐标
            mapy = mAterritory.mapy,-- 领地Y坐标
            killcount = mAterritory.killcount, --击杀海盗总数
        }

        -- 军团任务每个成员的贡献度
        local atcontrilist = mAterritory.atcontrilist()
        local newList = {}
        if type(atcontrilist)~='table' or not next(atcontrilist) then
            newList = {}
        else
            for k,v in pairs(atcontrilist) do
                newList['u'..v[1]] = v[3]
            end
        end

        local member = {}
        local db = getDbo()
        local result = db:getAllRows(string.format("select uid,aid,killcount,kill_at from atmember where aid="..aid))
        if type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local uobjs = getUserObjs(tonumber(v.uid))
                uobjs.load({"userinfo"})
                local mUserinfo = uobjs.getModel('userinfo')
                local killcount = v.killcount
                if v.kill_at~=lastInit then
                    killcount = 0
                end

                local percent = newList['u'..v.uid] or 0
                local mem = {
                    uid = v.uid,
                    nickname = mUserinfo.nickname,
                    seacoin = v.seacoin,
                    percent = percent,
                    killcount = killcount
                }

                table.insert(member,mem)     
            end 
        end
        response.data.territory =  territory
        response.data.member = member
        response.msg = 'success'
        response.ret = 0
      

        return response
    end

    -- load领地资源
    function self.action_getResource(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            response.msg = 'alliance not exist'
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,true)

       if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        response.data.aid = mUserinfo.alliance -- 军团id
        response.data.alliancename = mUserinfo.alliancename -- 军团名称
        response.data.r1 = mAterritory.r1 or 0 -- 铁
        response.data.r2 = mAterritory.r2 or 0 -- 铝
        response.data.r3 = mAterritory.r3 or 0 -- 钛
        response.data.r4 = mAterritory.r4 or 0 -- 石油
        response.data.r6 = mAterritory.r6 or 0 -- 铀
        response.data.r7 = mAterritory.r7 or 0 -- 天然气
        response.data.power = mAterritory.power or 0 -- 能量
        response.data.uid = mUserinfo.uid
        response.data.nickname = mUserinfo.nickname

        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 更改领地资源
    function self.action_setResource(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
       
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        local res = {}
        res['r1'] = request.params.r1 or 0 -- 铁
        res['r2'] = request.params.r2 or 0 -- 铝
        res['r3'] = request.params.r3 or 0 -- 钛
        res['r4'] = request.params.r4 or 0 -- 石油
        res['r6'] = request.params.r6 or 0 -- 铀
        res['r7'] = request.params.r7 or 0 -- 天然气

          
        if not mAterritory.addResource(res) then
            response.ret = -106
            response.msg = 'add error'
            return response
        end

        local power = request.params.power or 0 -- 能量
        if power>0 then
            mAterritory.addPower(power)
        end

        if mAterritory.saveData() then
            response.ret = 0
            response.msg = 'success'
            response.data.uid = mUserinfo.uid
            response.data.nickname = mUserinfo.nickname
        else
            response.ret = -106
        end
        
        return response
    end

    -- 获取海域的建筑等级
    function self.action_getbuild(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            response.msg = 'alliance not exist'
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,true)
        if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        response.data.aid = mUserinfo.alliance -- 军团id
        response.data.alliancename = mUserinfo.alliancename -- 军团名称
        response.data.b1_lv = mAterritory.b1.lv or 0 -- 基地等级
        response.data.b2_lv = mAterritory.b2.lv or 0 -- 仓库等级
        response.data.b3_lv = mAterritory.b3.lv or 0 -- 控制台等级
        response.data.dev_point = mAterritory.dev_point or 0 -- 发展值
        response.data.nickname = mUserinfo.nickname
        response.data.uid = mUserinfo.uid
        response.data.status = mAterritory.status -- 0挂起 1正常 2摧毁
        
        -- 领地迁移cd
        local allianceCityCfg = getConfig("allianceCity")

        local ts = getClientTs()
        if ts > mAterritory.mt+allianceCityCfg.moveTime then
            response.data.cd =  0 --冷却时间
        else
            response.data.cd = mAterritory.mt+allianceCityCfg.moveTime - ts
        end

        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 设置建筑等级
    function self.action_setbuild(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            response.msg = 'alliance not exist'
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
    
        if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        local cfg = getConfig('allianceBuid')
        -- 主基地
        local b1_lv = request.params.b1_lv or 0
        if b1_lv>0 then
            local currLevel = mAterritory.b1.lv or 0
            -- 最大等级限制
            if currLevel + b1_lv >= cfg.buildType[1].maxLevel then
               mAterritory.b1.lv = cfg.buildType[1].maxLevel
            else
                mAterritory.b1.lv = currLevel + b1_lv
            end

            local flag = mAterritory.updateTerritoryMapLevel('b1',mAterritory.b1.lv)
            if not flag then
                response.ret = -1
                response.msg = 'b1 up error'
                return response
            end
            mAterritory.level = mAterritory.b1.lv
        end

        -- 仓库
        local b2_lv = request.params.b2_lv or 0
        if b2_lv>0 then
            local currLevel = mAterritory.b2.lv or 0
            -- 最大等级限制
            if currLevel + b2_lv >= cfg.buildType[2].maxLevel then
               mAterritory.b2.lv = cfg.buildType[2].maxLevel
            else
                mAterritory.b2.lv = currLevel + b2_lv
            end

            local flag = mAterritory.updateTerritoryMapLevel('b2',mAterritory.b2.lv)
            if not flag then
                response.ret = -1
                response.msg = 'b2 up error'
                return response
            end
        end
        -- 控制台
        local b3_lv = request.params.b3_lv or 0
        if b3_lv>0 then
            local currLevel = mAterritory.b3.lv or 0
            -- 最大等级限制
            if currLevel + b3_lv >= cfg.buildType[3].maxLevel then
               mAterritory.b3.lv = cfg.buildType[3].maxLevel
            else
                mAterritory.b3.lv = currLevel + b3_lv
            end

            local flag = mAterritory.updateTerritoryMapLevel('b3',mAterritory.b3.lv)
            if not flag then
                response.ret = -1
                response.msg = 'b3 up error'
                return response
            end

            mAterritory.b4.lv = mAterritory.b3.lv
            mAterritory.b5.lv = mAterritory.b3.lv

            flag = mAterritory.updateTerritoryMapLevel('b4',mAterritory.b4.lv)
            if not flag then
                response.ret = -1
                response.msg = 'b4 up error'
                return response
            end

            flag = mAterritory.updateTerritoryMapLevel('b5',mAterritory.b5.lv)
            if not flag then
                response.ret = -1
                response.msg = 'b5 up error'
                return response
            end
        end
        
        -- 发展值
        local dev_point = request.params.dev_point or 0
        mAterritory.dev_point = mAterritory.dev_point + dev_point

        -- 领地迁移CD时间
        local cd = request.params.cd or 0
        local allianceCityCfg = getConfig("allianceCity")

        local ts = getClientTs()
        if ts > mAterritory.mt+allianceCityCfg.moveTime then
            mAterritory.mt = ts
        end
        mAterritory.mt = mAterritory.mt + cd

        if mAterritory.saveData() then
            response.data.nickname = mUserinfo.nickname
            response.data.uid = mUserinfo.uid
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -1
        end

        return response
    end

    -- 查看挂起军团
    function self.action_locked(request)
        local response = self.response
        local list = {}

        local db = getDbo()
        local result = db:getAllRows(string.format("select aid,dev_point from territory where  status=0"))
        if type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local aid = tonumber(v.aid)
                local setRet,code=M_alliance.getalliance{aid=aid}
                if type(setRet['data'])=='table' and next(setRet['data']) then
                     table.insert(list,{aid,tonumber(setRet['data']['alliance']['num']) or 1,tonumber(v.dev_point)})
                end
            end
        end

        response.ret = 0
        response.msg = 'success'
        response.data.list = list

        return response
    end

    -- 领地等级排行  军团id  军团名  军团成员数量 军团等级 领地等级  领地创建时间
    function self.action_terank(request)
        local response = self.response
        local limit  = tonumber(request.params.limit) or 0
        local sql = "select aid,level,ct from territory order by level desc,ct desc"
        if tonumber(limit) > 0 then
            sql = sql..' limit '..limit
        end

        local list = {}
        local db = getDbo()
        local result = db:getAllRows(string.format(sql))
        if type(result)=='table' and next(result) then
            for k,v in pairs(result) do
                local aid = tonumber(v.aid)
                local setRet,code=M_alliance.getalliance{aid=aid}
                if type(setRet['data'])=='table' and next(setRet['data']) then
                    table.insert(list,{aid,setRet['data']['alliance']['name'],tonumber(setRet['data']['alliance']['num']) or 1,tonumber(setRet['data']['alliance']['level']),v.level,v.ct})
                end
            end
        end

        response.data.list = list
        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 领地挂起
    function self.action_telock(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            response.msg = 'alliance not exist'
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        if mAterritory.status~=1 then
            response.ret = -1
            response.msg = 'status!=1'
            return response
        end
        if mAterritory.lock() then
            if mAterritory.saveData() then
                response.data.nickname = mUserinfo.nickname
                response.data.uid = mUserinfo.uid
                response.ret = 0
                response.msg = 'success'
            else
                response.ret = -1
            end
        else  
            response.ret = -1
        end

        return response
    end

    -- 查看领地成员数据
    function self.action_viewm(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            response.msg = 'alliance not exist'
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        local mAtmember = uobjs.getModel('atmember')
        response.data.aid = mUserinfo.alliance -- 军团id
        response.data.alliancename = mUserinfo.alliancename -- 军团名称
        response.data.seacoin = mAtmember.seacoin or 0
        response.data.nickname = mUserinfo.nickname
        response.data.uid = mUserinfo.uid
        response.ret = 0
        response.msg = 'success'

        return response
    end


    -- 查看领地成员数据
    function self.action_setmem(request)
        local response = self.response
        local nickname = tostring(request.nickname) 
        local uid = tonumber(request.uid) or (nickname and userGetUidByNickname(nickname)) or 0
        if not uid or uid < 1 then
            response.ret = -102
            response.msg = 'params error'
            return response
        end

        if userLogin(uid) <= 0 then
            response.ret = -104
            return response
        end
        
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            response.msg = 'alliance not exist'
            return response
        end

        local mAterritory = getModelObjs("aterritory",mUserinfo.alliance,false)
        if mAterritory.isEmpty() then
            response.ret = -1
            response.msg = 'territory not exist'
            return response
        end

        local seacoin = request.params.seacoin or 0
        if seacoin > 0 then
            local mAtmember = uobjs.getModel('atmember')
            mAtmember.addSeacoin(seacoin)
            uobjs.save()
        end

        response.data.nickname = mUserinfo.nickname
        response.data.uid = mUserinfo.uid
        response.ret = 0
        response.msg = 'success'

        return response
    end

    return self
end

return api_admin_territory
