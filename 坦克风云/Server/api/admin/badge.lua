-- 
-- 指挥官徽章GM管理
-- chenyunhe
-- 

local function api_admin_badge(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    -- 添加徽章
    function self.action_add(request)
        local response = self.response
        local uid =  request.uid
        local id = request.params.id
        local level = request.params.level or 1
        if not uid or not id then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local flag,ret= mBadge.add(id,1,level)
        if not flag then
            response.ret = ret
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 设置徽章的等级
    function self.action_setlevel(request)
        local response = self.response
        local uid =  request.uid
        local id = request.params.id
        local level = tonumber(request.params.level)
        if not uid or not id or not level or level<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')

        local ret= mBadge.setlevel(id,level)
        if ret~=0 then
            response.ret = ret
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 删除
    function self.action_delb(request)
        local response = self.response
        local uid =  request.uid
        local id = request.params.id
        if not uid or not id then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        
        if mBadge.info[id] then
            mBadge.info[id] = nil
        end

        for k,v in pairs(mBadge.used) do
            if v == id then
                mBadge.used[k] = 0
            end
        end
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 查询
    function self.action_view(request)
        local response = self.response
        local uid =  request.uid
      
        if not uid then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge') 

        response.data.badge = mBadge.toArray()
        response.data.badge.usedatt = mBadge.adminUsedAttribute()

        if next(response.data.badge.info) then
            local att2name = {"dmg","maxhp","accuracy","evade","crit","anticrit"}
            local itemListcfg = getConfig("badge.itemList")
            for k,v in pairs(response.data.badge.info) do
                local br = 0 -- 突破增加属性系数
                if v[3]>0 then
                    br = itemListcfg[v[1]].btGrow[v[3]]/100 or 0
                end
                local tmp = {}
                for k,attType in pairs(itemListcfg[v[1]].attType) do             
                    local attValue = itemListcfg[v[1]].att[k] + itemListcfg[v[1]].lvGrow[k] * (v[2]-1)
                    tmp[att2name[attType]] =  (tmp[att2name[attType]] or 0) + (attValue/100) *(1+br) 
                end

                response.data.badge.info[k][4] = tmp
            end
        end
        response.ret = 0
        response.msg = 'success'
        return response
    end

    -- 增加徽章碎片
    function self.action_addfragment(request)
        local response = self.response
        local uid =  request.uid
        local id = request.params.id
        local num = request.params.num or 0
        if not uid or not id or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local flag = mBadge.addFragment(id,num)
        if not flag then
            response.ret = -106
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 设置碎片数量
    function self.action_setfragment(request)
        local response = self.response
        local uid =  request.uid
        local ids = request.params
        if not uid or type(ids)~='table' then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local fragmentList = getConfig("badge.fragmentList")
        for k,v in pairs(ids) do
            if fragmentList[k] then
                mBadge.fragment[k] = tonumber(v)
            end
        end
        
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    function self.action_addexp(request)
        local response = self.response
        local uid =  request.uid
        local num = request.params.num or 0
        if not uid or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local flag = mBadge.addExp(num)
        if not flag then
            response.ret = -106
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 添加经验道具
    function self.action_addexpprop(request)
        local response = self.response
        local uid =  request.uid
        local id = request.params.id
        local num = request.params.num or 0
        if not uid or not id or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')

        local flag = mBadge.addExpPro(id,num)
        if not flag then
            response.ret = -106
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 设置经验道具数量
    function self.action_setexpprop(request)
        local response = self.response
        local uid =  request.uid
        local ids = request.params
        if not uid or type(ids)~='table' then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local expItemcfg = getConfig("badge.main.expItem")
        for k,v in pairs(ids) do
            if expItemcfg[k] then
                mBadge.expPro[k] = tonumber(v)
            end
        end
        
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 添加突破材料
    function self.action_addmaterial(request)
        local response = self.response
        local uid =  request.uid
        local id = request.params.id
        local num = request.params.num or 0
        if not uid or not id or num<=0 then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local flag = mBadge.addMaterial(id,num)
        if not flag then
            response.ret = -106
            return response
        end

        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    -- 设置突破道具数量
    function self.action_setmaterial(request)
        local response = self.response
        local uid =  request.uid
        local ids = request.params
        if not uid or type(ids)~='table' then
            response.ret = -102
            return response
        end

        local uobjs = getUserObjs(uid)
        uobjs.load({"badge"})
        local mBadge = uobjs.getModel('badge')
        local gadgetcfg = getConfig("badge.main.gadget")
        for k,v in pairs(ids) do
            if table.contains(gadgetcfg,k) then
                mBadge.material[k] = tonumber(v)
            end   
        end
        
        if uobjs.save() then
            response.ret = 0
            response.msg = 'success'
        else
            response.ret = -106
        end
        
        return response
    end

    return self
end

return api_admin_badge
