function api_troop_back(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }
    
    local uid = request.uid
    local cid = request.params.cid
    local huid = request.params.huid -- 以此区分是否送走协防部队

    if huid then uid = huid end

    if uid == nil or cid == nil then
        response.ret = -1988
        response.msg = 'params invalid'
        return response
    end

    cid = 'c'.. cid

    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops","hero","props","bag","skills","buildings","dailytask","task"})
    local mTroop = uobjs.getModel('troops')
    local mHero = uobjs.getModel('hero')

    if mTroop.attack[cid] and mTroop.attack[cid].seaWarFlag then
        response.ret = -102
        return response
    end

    -- 自动返回
    if request.params.auto == 1 then
        if mTroop.attack[cid] and type(mTroop.attack[cid].goldMine) == 'table' then
            local df = mTroop.attack[cid].goldMine[2] - getClientTs()
            if df > 15 then
                response.ret = 0
                response.msg = 'Success'
                return response
            end
        end
    end

    local ret = mTroop.fleetBack(cid)
    if not ret and not huid then
        response.data.troops = mTroop.toArray(true)
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 岛屿被释放
    if type(mTroop.attack[cid]) == 'table' then

        if mTroop.attack[cid].type == 9 then
            local mUserinfo = uobjs.getModel('userinfo')
            if mUserinfo.alliance > 0 then
                local mTerritory = getModelObjs("aterritory",mUserinfo.alliance,false,true)
                if mTerritory and mTerritory.isNormal() then
                    mTerritory.addResource(mTroop.attack[cid].res)
                    local territoryR6=mTroop.attack[cid].res.r6 or 0
                    local territoryR7=mTroop.attack[cid].res.r7 or 0
                    local mAtmember = uobjs.getModel('atmember')
                    if territoryR6>0 then--铀
                        mTerritory.uptask({act=2,num=territoryR6,u=mUserinfo.uid})
                        mAtmember.uptask({act=2,num=territoryR6,aid=mUserinfo.alliance})
                    end
                    if territoryR7>0 then-- 天然气
                        mTerritory.uptask({act=1,num=territoryR7,u=mUserinfo.uid})
                        mAtmember.uptask({act=1,num=territoryR7,aid=mUserinfo.alliance})
                    end
                    regEventAfterSave(uid,'e10',{aid=mUserinfo.alliance})

                    -- 团结之力
                    activity_setopt(uid,'unitepower',{id=3,aid=mUserinfo.alliance,num=0,res=mTroop.attack[cid].res})
                end
            end
            
        elseif mTroop.attack[cid].type ~= 6 then
            local mid = getMidByPos(mTroop.attack[cid].targetid[1],mTroop.attack[cid].targetid[2])
            local mMap = require "lib.map"
		    mMap:refreshHeat(mid)
            mMap:decrHeatPoint(mid)

            local troopInfoByTurkeyActive =  activity_setopt(uid,'jidongbudui',
                {setMapTroops=true,mlv=mTroop.attack[cid].level,index={mTroop.attack[cid].targetid[1],mTroop.attack[cid].targetid[2]}})
            if type(troopInfoByTurkeyActive) == 'table' then
                if not mMap.data[mid].data then mMap.data[mid].data = {} end
                mMap.data[mid].data.troops=troopInfoByTurkeyActive.troop
            end

            -- 地图占领者的ID是撤退的用户ID,才更新地图
            if tonumber(mMap.data[mid].oid) == uid then
                mMap:changeOwner(mid,0,true)
            end

            -- 解除舰队来袭
            mTroop.clearAlarm(0,mTroop.attack[cid].targetid[1],mTroop.attack[cid].targetid[2])

        elseif mTroop.attack[cid].isHelp == 1 and mTroop.attack[cid].tUid then
            local memberuobjs = getUserObjs(mTroop.attack[cid].tUid)
            memberuobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","dailytask","task"})

            local memberMTroop = memberuobjs.getModel('troops')
            local memeMUserinfo = memberuobjs.getModel('userinfo')

            memberMTroop.clearHelpDefence(cid) 

            if memberuobjs.save() then
                local mail_title =  "3-6"
                local mail_content={
                    type = 3,
                    info = {
                        place = target,
                        name  = '',
                        islandType = targetType,
                        level = maplevel,
                        rettype = 8,
                    }
                }

                MAIL:mailSent(memeMUserinfo.uid,1,memeMUserinfo.uid,'',memeMUserinfo.nickname,mail_title,mail_content,2,0)
                memberMTroop.sendHelpDefenseMsgByUid()
            end
        end
    end

    if type(mTroop.attack[cid].res)=='table' then
         --德国七日狂欢 
        activity_setopt(uid,'sevendays',{act='sd15',v=0,n=mTroop.attack[cid].res}) 
        -- 跨服战资比拼
        zzbpupdate(uid,{t='f1',n=mTroop.attack[cid].res})

        -- 全民劳动
        activity_setopt(uid,'laborday',{act='task',t='cj',n=mTroop.attack[cid].res}) 

        -- 番茄大作战
        activity_setopt(uid,'fqdzz',{act='tk',type='cj',num=mTroop.attack[cid].res}) 

        -- 远洋征战 士气值
        activity_setopt(uid,'oceanmorale',{act='res',num=mTroop.attack[cid].res})
    end
     

    local mTask = uobjs.getModel('task')
    mTask.check()
    processEventsBeforeSave()

    if ret and uobjs.save() then
        processEventsAfterSave()

        if huid then
            mTroop.sendAttackTroopsMsgByUid(cid)
        else
            response.data.troops = mTroop.toArray(true)
        end

        response.ret = 0
        response.msg = 'Success'
    end
    
    return response
end	
