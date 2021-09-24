-- 使用科技 
-- 装配科技到tank上,废弃 （现在自动装配生效）
function api_alien_use(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    if true then --接口废弃
        return response
    end
    
    local uid = request.uid
    local pid = request.params.id
    local tank= request.params.ttype
    local p   = tonumber(request.params.p)
    if uid ==nil or  pid==nil or tank==nil or p==nil then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alien') == 0 then
        response.ret = -16000
        return response
    end


    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo","bag","troops"})
    local mUserinfo = uobjs.getModel('userinfo')
    local mAlien= uobjs.getModel('alien')
    local mBag  = uobjs.getModel('bag')
    local mTroops  = uobjs.getModel('troops')
    local alienTechCfg = getConfig("alienTechCfg")

    if mTroops.troops[tank]==nil then
        response.ret=-102
        return response
    end

    if alienTechCfg.talent[pid]==nil then
        response.ret=-16001
        return response
    end 
    if mAlien.info[pid]==nil  then
        response.ret=-16005
        return response
    end
    local flag=table.contains(alienTechCfg.talent[pid][5], tank)
    --检测改科技能装此坦克
    if not flag then
        response.ret=-16007
        return response
    end
    if type(mAlien.used[tank])~='table' then  mAlien.used[tank]={} end
    local flag=table.contains(mAlien.used[tank], pid)
    if flag then
        response.ret=-16006
        return response
    end
    local attributeType=alienTechCfg.talent[pid][4]
    local tankCfg=getConfig('tank.' .. tank)
    local slot,fixed=mAlien.getOpenSolt(tank,alienTechCfg.talent,tankCfg)
    -- 检测位置数是否够
    if slot<p then
        response.ret=-16009
        return response
    end

    if mAlien.used[tank][p]~=nil and mAlien.used[tank][p]~=0 then
        if alienTechCfg.talent[mAlien.used[tank][p]][3] ==2 then
            response.ret=-16010
            return response
        end
    end
    --检测此坦克是否装配过该类的科技
    local flag= mAlien.checkTalentType(tank,attributeType,alienTechCfg.talent,p)
    if not flag then
        response.ret=-16008
        return response
    end

    local ret =mAlien.updateUsed(tank,pid,p,slot)
    if not ret then
        return response
    end
    regEventBeforeSave(uid,'e1')
    if uobjs.save() then 
        response.data.alien = mAlien.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
        processEventsAfterSave()
    end
    
    return response

end