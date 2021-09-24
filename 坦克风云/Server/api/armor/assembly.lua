-- 一键装配+更换


function api_armor_assembly(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid  = request.uid
    local line = tonumber(request.params.line)
    local line2= tonumber(request.params.line2) or 0
    local armor= request.params.armors
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
    local mArmor = uobjs.getModel('armor')
    local mUserinfo = uobjs.getModel('userinfo')
    local oldfc = mUserinfo.fc
    -- 更换部队的装甲  
    if not next(mArmor.used) then
        mArmor.used={{},{},{},{},{},{}}
    end
    if mArmor.used[line]==nil then
        response.ret=-102
        return response
    end 
    if line2 >0  then
        if mArmor.used[line2]==nil then
            response.ret=-102
            return response
        end
        local armor2=  copyTab(mArmor.used[line2])
        local armor =  copyTab(mArmor.used[line])
        mArmor.used[line]=armor2
        mArmor.used[line2]=armor
    else-- 一件组装装甲
        if type(armor)~='table' then
            response.ret=-102
            return response
        end
        if #armor~=6 then
            response.ret=-102
            return response
        end
        local armorCfg=getConfig('armorCfg')
        for k,v in pairs (armor) do
            if (v~=0) then
                --检测是否存在
                 if mArmor.info[v]==nil   then
                    response.ret=-9055
                    return response
                end
                --检测是否别的使用
                if mArmor.checkUsed(v,line) then
                    response.ret=-102
                    return response
                end
                local maid =mArmor.info[v][1]
                local part=armorCfg.matrixList[maid]['part']
                -- 装配的位置不对
                if part~=k then
                    response.ret=-102
                    return response
                end
            end
        end
        mArmor.used[line]=armor

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