-- 使用单独装甲和卸下

function api_armor_used(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local line= tonumber(request.params.line)
    local pos = request.params.pos or 0
    local mid= request.params.mid
    if uid == nil then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('armor') == 0 then
        response.ret = -11000
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero","armor"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mArmor = uobjs.getModel('armor')
    local armorCfg=getConfig('armorCfg')

    local oldfc = mUserinfo.fc
    if not next(mArmor.used) then
        mArmor.used={{},{},{},{},{},{}}
    end
    -- 卸掉装甲
    if pos>0 then
        if mArmor.used[line]==nil then
            response.ret=-102
            return response
        end

        if mArmor.used[line][pos]==0 then
            response.ret=-9054
            return response
        end
        if mArmor.getInfoCount()+1>mArmor.count then
            response.ret=-9050
            return response
        end
        mArmor.used[line][pos]=0

    else    
        
        if mArmor.info[mid]==nil   then
            response.ret=-9055
            return response
        end

        local armor=mArmor.info[mid]
        local pos  =armorCfg.matrixList[armor[1]]['part']
        if mArmor.checkUsed(mid) then
            response.ret=-102
            return response
        end
        local linfo=mArmor.used[line]
        if not next (linfo) then
            linfo={0,0,0,0,0,0}
        end
        linfo[pos]=mid
        mArmor.used[line]=linfo

        -- 成就数据
        updatePersonAchievement(uid,{'a1','a2'})
    end

    regEventBeforeSave(uid,'e1')    
    processEventsBeforeSave()
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.armor={}
        response.data.armor.used =mArmor.used
        response.ret = 0  
        response.data.oldfc =oldfc
        response.data.newfc=mUserinfo.fc      
        response.msg = 'Success'
    end
    return response












end