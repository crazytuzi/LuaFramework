--
-- desc: 异星宝石gem工具
-- user: chenyunhe
--
local function api_admin_alienjewel(request)
    local self = {
        response = {
            ret = -1,
            msg ='error',
            data = {},
        },
    }

    -- 查看玩家的宝石
    function self.action_view(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        if uid < 1 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        local mAweapon = uobjs.getModel('alienweapon')

        local skillcfg = getConfig("alienjewel.skill")
        local maincfg = getConfig("alienjewel.main")
        local equip = {} -- 装配中的
        for k,v in pairs(mAweapon.used) do
            local eq = {}
            if string.find(v,"aw") then
                if mAweapon.jewelused[v] then
                    for key,val in pairs(mAweapon.jewelused[v]) do
                        local jid = mAweapon.getJewelidCfg(val)
                        local jewelCfg = maincfg[jid]
                        if type(jewelCfg)~='table' then
                            table.insert(eq,{})
                        else
                            if jewelCfg.level == 10 then
                                local sid = mAweapon.jewelinfo2[val][2]
                                local atttype = skillcfg[sid].attr
                                table.insert(eq,{jewelCfg.level,jewelCfg.color,atttype,mAweapon.jewelinfo2[val][3]})-- 宝石等级、宝石颜色
                            else
                                table.insert(eq,{jewelCfg.level,jewelCfg.color,0,0})-- 宝石等级、宝石颜色、附加属性类型 、附加属性数值
                            end
                            
                        end 
                    end
                end
            end

            table.insert(equip,eq)
        end

        response.data.equipjewel = equip -- 装配上的宝石
        response.data.stive = mAweapon.stive -- 粉尘
        response.data.crystal = mAweapon.crystal -- 结晶

        local jewelinfo1 = {}
        local avoidtb = {10,20,30,40,50,60}
        for i=1,60 do
            if not table.contains(avoidtb,i) then
                local jid = 'j'..i
                local jcfg = maincfg[jid]
                local num = mAweapon.jewelinfo1[jid] or 0
               
                table.insert(jewelinfo1,{jcfg.level,jcfg.color,num,jid})
            end
        end
        response.data.jewelinfo1 = jewelinfo1 -- 1-9级宝石

        local jewelinfo2 = {}
        for k,v in pairs(mAweapon.jewelinfo2) do
            local jid = mAweapon.getJewelidCfg(k)
            local jcfg = maincfg[jid]
            local sid = v[2]
            local atttype = 0
            if type(skillcfg[sid])=='table' then
                atttype = skillcfg[sid].attr
            end
            

            table.insert(jewelinfo2,{jcfg.level,jcfg.color,atttype,v[3],k})-- 等级 颜色 附加属性类型 附加属性值 编号
        end
        response.data.jewelinfo2 = jewelinfo2-- 10级宝石

        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 添加/减少宝石1-9级 k=>v  其中v可正、可负
    function self.action_addjewel(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        local j = request.params.j
        
        if uid < 1 or type(j)~='table' then
            response.ret = -102
            return response
        end
        local uobjs = getUserObjs(uid)       
        uobjs.load({"userinfo","alienweapon"})      
        local mUserinfo = uobjs.getModel('userinfo') 
        local mAweapon = uobjs.getModel('alienweapon')

        for k,v in pairs(j) do
            local cur = (mAweapon.jewelinfo1[k] or 0) + v
            if cur<0 then
                mAweapon.jewelinfo1[k] = 0
            else
                mAweapon.jewelinfo1[k] = cur
            end
            
        end   

        if not uobjs.save() then
            response.ret = -1
            return response
        end

        response.ret = 0
        response.msg = 'Success'

        return response
    end

    -- 删除10级宝石
    function self.action_deljewel(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        local j = request.params.j
        
        if uid < 1 or type(j)~='table' then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo","alienweapon"})
        local mAweapon = uobjs.getModel('alienweapon')

        local flag = false
        for jk,jv in pairs(j) do
            -- 判断被删除的宝石是否被装备
            for k,v in pairs(mAweapon.jewelused) do
                if type(v)=='table' then
                    for key,val in pairs(v) do
                        if val == jv then
                            flag = true
                            break
                        end
                    end
                end
            end

            if flag then
                response.ret = -1000 -- 不能删除已装配的
                return response
            end

            mAweapon.jewelinfo2[jv] = nil 
        end

    
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -1
        end
        return response
    end

    -- 添加10级宝石
    function self.action_addlvten(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        local color = request.params.c --颜色
        local sid = request.params.s --技能编号
        local val = request.params.v or 0 -- 属性值

        
        if uid < 1 or not sid then
            response.ret = -102
            return response
        end
        local jid = "j"..(color*10)

        local uobjs = getUserObjs(uid)       
        uobjs.load({"alienweapon"})      
        local mAweapon = uobjs.getModel('alienweapon')

        local flag,re = mAweapon.addjewel(jid,1)
        if flag then
            for k,v in pairs(re) do
                mAweapon.jewelinfo2[k][2] = sid
                mAweapon.jewelinfo2[k][3] = val
            end
        end

        if not uobjs.save() then
            response.ret = -1
            return response
        end

        response.ret = 0
        response.msg = 'success'

        return response
    end

    -- 添加/减少宝石粉尘
    function self.action_addsc(request)
        local response = self.response
        local uid = tonumber(request.uid) or userGetUidByNickname(self.nickname) or 0
        local stive = request.params.s
        local crystal = request.params.c
        
        if uid < 1  then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)       
        uobjs.load({"alienweapon"})      
        local mAweapon = uobjs.getModel('alienweapon')

        mAweapon.stive = mAweapon.stive + stive
        mAweapon.crystal = mAweapon.crystal + crystal

        if mAweapon.stive<0 then
            mAweapon.stive = 0
        end

        if mAweapon.crystal<0 then
            mAweapon.crystal = 0
        end

        if not uobjs.save() then
            response.ret = -1
            return response
        end

        response.msg = 'success'
        response.ret = 0

        return response

    end

    return self
end

return api_admin_alienjewel
