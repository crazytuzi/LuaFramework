--
-- desc: 重置科技点数
-- user: chenyunhe
-- 只能从当前升级的最高级科技依次向下重置
local function api_alien_reset(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

   -- 重置科技点数
   function self.action_resettech(request)
        return false
        local response = self.response
        local uid = request.uid
        local tree = request.params.tree -- tree下面的下标
        local id = request.params.id --subtreeId 里面的下标

        if not uid or  not tree or not id  then
            response.ret=-102
            return response
        end
        
        if moduleIsEnabled('alien') == 0 then
            response.ret = -16000
            return response
        end

        if moduleIsEnabled('alienTreset') == 0 then
            response.ret = -180
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"alien","userinfo","bag","dailytask","troops"})
        local mUserinfo = uobjs.getModel('userinfo')
        local mAlien= uobjs.getModel('alien')
        local mTroop = uobjs.getModel('troops')
        local alienTechCfg = getConfig("alienTechCfg")

        if type(alienTechCfg.tree[tree]) ~= 'table' then
            response.ret = -102
            return response
        end
        -- 根据重置科技树的下标 获取相应的钻石消耗
        if not mUserinfo.useGem(alienTechCfg.tree[tree].cost[id]) then
            response.ret = -109
            return response
        end

        local subtreeId = alienTechCfg.tree[tree].subtreeId[id] -- 每种打分支下的子类之一
        -- 判断当前重置的科技是不是最高级的
        local cursubid = mAlien.getMaxSubtreeId(tree)
        if cursubid==0 or subtreeId~=cursubid then
            response.ret = -102
            return response
        end

        -- 最终返还的资源
        local function setResource(r,rate)
            local back = {}
            for k,v in pairs(r) do
                back[k] = (back[k] or 0) + math.floor(v*rate)
            end

            return back
        end
        -- 清理 已作用到的船
        -- tank 作用船的编号
        -- t 科技编号
        local function cleant(tank,t)
            if type(mAlien.used[tank])=='table' and next(mAlien.used[tank]) then
                for ek,rv in pairs(mAlien.used[tank]) do
                    if rv == t then
                        table.remove(mAlien.used[tank],ek)
                    end
                end
            end

        end

        -- 重置某个科技树技能点数
        local function resettree(subtreeId,cfg)
            local allpoint = 0 --该科技树总点数
            for _, v in pairs( alienTechCfg.subtree[subtreeId].tech ) do 
                if mAlien.info[v] and tonumber(mAlien.info[v]) > 0 then
                    allpoint = allpoint + tonumber(mAlien.info[v])
                end
            end

            local level = 0 --获取属性等级
            for k, v in pairs( cfg.subtree[subtreeId].point ) do  
                if allpoint >= v then
                    level = k
                else
                    break
                end 
            end

            if level>0 then
                ---- 删除生效的tank 
                if level > 0 and type(self.used1)=='table' and next(self.used1) then
                    for _, tankId in pairs( cfg.subtree[subtreeId].desc[level] ) do
                        if type(self.used1[tankId][tostring(subtreeId)]) == 'table' then
                            self.used1[tankId][tostring(subtreeId)] = nil
                        end
                    end
                end
            end


            local r = {}--异星资源
            local o = {}--船
            for _, v in pairs(cfg.subtree[subtreeId].tech) do 
                local lv = tonumber(mAlien.info[v]) or 0
                if lv > 0 then
                    local resourceConsume=cfg.talent[v][10]
                    for i=1,lv do
                        local resource =resourceConsume[i]
                        if resourceConsume[i]==nil then
                            return response
                        end

                        if resource.r ~= nil  then
                            for rk,rv in pairs(resource.r) do
                                r[rk] = (r[rk] or 0) + rv
                            end
                        end

                        if resource.o ~= nil then
                            for ok,ov in pairs(resource.o) do
                                o[ok] = (o[ok] or 0) + ov
                            end
                        end
                    end
                    -- 等级重置
                    mAlien.info[v] = nil
                    
                    local effecttank = cfg.talent[v][5]
                    if type(effecttank) == 'string' then
                        cleant(effecttank,v)
                    elseif type(effecttank)=='table' then
                        for ef,ev in pairs(effecttank) do
                            cleant(ev,v)
                        end
                    end
                end
            end

            return o,r
        end

        local o,r = resettree(subtreeId,alienTechCfg)
        local origenal = {}---暂时给客户端比较用 测完可删除
        origenal.o=o
        origenal.r=r

        local rate = alienTechCfg.reset.rate -- 返还比例
        if next(r) then
            local br = setResource(r,rate)
            for k,v in pairs(br) do
                if not mAlien.addMineProp(k,v) then
                    return response
                end
            end 
        end
       
        if next(o) then
            local br = setResource(o,rate)
            for k,v in pairs(br) do
                if not mTroop.incrTanks(k,v) then
                    return response
                end
            end
        end

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save() then 
            processEventsAfterSave()

            response.data.alien = {info=mAlien.info, used=mAlien.used, used1=mAlien.used1,prop=mAlien.prop }
            response.ret = 0        
            response.msg = 'Success'
            response.data.origenal = origenal
        end
        
        return response

   end

    return self
end

return api_alien_reset
