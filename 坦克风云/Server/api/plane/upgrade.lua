--抽出来的技能模块进行升级
local function api_plane_upgrade()
    local self = {
        response = {
            ret = -1,
            msg = 'error',
            data = {},
        },
    }


    function self.upbyid(eid, num, useGems,mPlane,mBag,mUserinfo,uid,plane)
        num = tonumber(num) or 1

        local equipcfg = getConfig('planeGrowCfg.grow')
       
        if not equipcfg[eid].lvTo then
            return false, -12108
        end
        local equipColor = equipcfg[eid].color
        if equipColor == 4 or equipColor == 5 then
            local versionCfg  =getVersionCfg()
            local levelLimit = versionCfg.unlockPlaneLevel1
            if equipColor == 5 then
                levelLimit = versionCfg.unlockPlaneLevel2
            end

            if equipcfg[eid].lv >= levelLimit then
                return false, -12108
            end
        end
        local gemCost = 0
        local itemlog = {} -- 消耗日志
        local propCfg = getConfig('prop')

        local consume = copyTab( equipcfg[eid].upCost)
        for k, v in pairs(consume) do
            consume[k] = v * num

            --钻石补充
            local haditem = mBag.getPropNums(k)
            local costcnt = consume[k]

            -- 战机补给点 飞机技能每次升一级
            activity_setopt(uid,'zjbjd',{type='xh',id=k,num=costcnt})
	    -- 战机商店  
            activity_setopt(uid,'zjsd',{type='jy',id=k,num=costcnt})

            if costcnt > haditem then
                gemCost = gemCost + propCfg[k].gemCost * ( costcnt - haditem) --不够钻石补
                costcnt = haditem --扣掉所以物品
            end

            if costcnt>0 and not mBag.use(k, costcnt) then
                return false, -1996
            end
            itemlog[k] = (itemlog[k] or 0 ) + costcnt
        end

        if gemCost > 0 and (not useGems or not mUserinfo.useGem(gemCost) ) then
            return false, -109
        end

        --消耗装备
        if  plane==nil  then
            if not mPlane.consumeSkill(eid, num) then 
                return false, -12103
            end
        end
        itemlog[eid] = (itemlog[eid] or 0 ) + num

        --获得高等级装备
        local new_eid = equipcfg[eid].lvTo
        if not equipcfg[new_eid] then
            return false, -12108
        end
        itemlog['plane']=plane
        if gemCost > 0 then
            regActionLogs(uid,1,{action=213,item=new_eid,value=gemCost,params=itemlog})
        end
        -- 飞机技能捕获计划
        activity_setopt(uid,'fjjnbhjh',{act='up',color=equipColor,num=1})

        return true,new_eid,num
    end
    -- 升级
    function self.action_levelup(request)
        local uid = request.uid
        if uid == nil then
            response.ret = -102
            return response
        end

        local response=self.response
        local weeTs = getWeeTs()
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "plane"})
        local mPlane = uobjs.getModel('plane')
        local mUserinfo = uobjs.getModel('userinfo')
        local mBag = uobjs.getModel('bag')
        local eid = request.params.sid
        local cnt = tonumber( request.params.count ) or 1
        local useGems = request.params.useGems
        local plane   =  tonumber(request.params.plane)
        local ret, code,num = nil, nil,nil
        
        local usableNum = mPlane.getUsableNum(eid,plane)
        if usableNum < cnt then
            response.ret = -12103
            return response  
        end        
        ret, code,num = self.upbyid(eid, cnt, useGems,mPlane,mBag,mUserinfo,uid,plane)
        if not ret then
            response.ret = code
            return response
        end
        -- 如果是飞机中的 要替换技能
        if plane~=nil  then
            ret=mPlane.changePlaneSkill(eid,code,plane)
        else
            ret=mPlane.levelupEquip(code,num)
        end
        if not ret then
            response.ret = -102
            return response
        end
        --平稳降落
        activity_setopt(uid,'safeend',{act='m5',num=1})
        -- 战机补给点 飞机技能每次升一级
        activity_setopt(uid,'zjbjd',{type='sj',num=1})

        regEventBeforeSave(uid,'e1')
        processEventsBeforeSave()
        if uobjs.save() then 
            processEventsAfterSave()
            response.data.plane = {}
            response.data.plane.plane = mPlane.plane
            response.data.plane.sinfo = mPlane.sinfo
            response.data.bag = mBag.toArray(true)
            response.ret = 0        
            response.msg = 'Success'
        end

        return response


    end

    return self
end

return api_plane_upgrade