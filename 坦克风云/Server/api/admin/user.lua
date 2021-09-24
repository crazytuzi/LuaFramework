function api_admin_user(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
        uid = 0,
    }
    
    self.nickname = tostring(request.nickname)

    if self.action == 1003 then
        local db = getDbo()
        local result = db:getRow("select * from userinfo where username like '%:uname%'",{uname=username})
        
        self.response.data = result or {}
        self.response.ret = 0
        self.response.msg = 'Success'
        return self.response
    end

    self.uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
    self.action = tonumber(request.action)
    self.request = request

    if self.uid < 1 or self.request == nil then
        self.response.ret = -102
        return self.response
    end
    
     -- 改变用户属性
    function self.changeUserAttribute()
        local nums = math.floor(tonumber(request.params.num) or 0)
        local attributeName = request.params.attributeName
        if nums < 0 then 
            self.response.msg = 'num invalid'
            return false 
        end
        
        local uobjs = getUserObjs(self.uid)
        mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo[attributeName] then            
            -- 增加经验
            if attributeName == 'exp' then
                mUserinfo.exp = nums
                mUserinfo.updateLevel()
                -- mUserinfo.addExp(nums)
            -- 增加等级
            elseif attributeName == 'level' then
                local tPlayerExpsCfg = getConfig('player.level_exps')
                local iLevel = nums
                local iLevelXp = tPlayerExpsCfg[iLevel] or 0 

                if iLevelXp >= 0 then
                    mUserinfo.level = iLevel
                    mUserinfo.exp = iLevelXp
                end
            -- 增加声望
            elseif attributeName == 'honor' then
                -- mUserinfo.addHonor(nums)
                mUserinfo.honors = nums
            -- 增加宝石
            elseif attributeName == 'gems' then
                local oldGems = mUserinfo.gems
                mUserinfo.gems = nums

                regActionLogs(uid,6,{action=602,item="gm",value=num,params={oldGems=oldGems,gems=mUserinfo.gems}})
                -- mUserinfo.addResource({[attributeName]=nums})
                --mUserinfo.addGem(nums)
            elseif attributeName == 'regdate' then
                mUserinfo[attributeName] = nums
            elseif attributeName == 'hwid' then
                if tonumber(mUserinfo.hwid) == nums then
                    return true
                end

                if (not tonumber(mUserinfo.hwid) or tonumber(mUserinfo.hwid) == 0 ) and nums == 1 then
                    local redis = getRedis()
                    local key = "z"..getZoneId()..".login."..mUserinfo.uid
                    redis:del(key)    
                end

                mUserinfo.hwid = nums
            else
                mUserinfo[attributeName] = nums
                -- mUserinfo.addResource({[attributeName]=nums})
            end
            
            processEventsBeforeSave()
            
            if uobjs.save() then
                processEventsAfterSave()
                return true
            end
        end
    end

    function self.getUserData()
        local uobjs = getUserObjs(self.uid,true)
        local model = uobjs.getModel(self.request.params.data_name)
        if model then
            self.response.data[self.request.params.data_name] = model.toArray()
            if self.request.params.data_name == 'userinfo' then
                local mBuildings = uobjs.getModel('buildings')
                self.response.data.buildings = mBuildings.toArray(true)
            end
        end
    end


    --修改用户属性
    if self.action == 1001 then
        if self.changeUserAttribute() then        
            self.response.data.userinfo = mUserinfo.toArray(true)
            self.response.ret = 0
            self.response.msg = 'Success'
        end
    end

    -- 获取用户数据
    if self.action == 1002 then
        self.getUserData()
        self.response.ret = 0
        self.response.msg = 'Success'
    end

    return self.response
end