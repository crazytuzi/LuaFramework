-- 修改个人的异星科技

function  api_admin_setalien(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local alien = request.params.alien
    local addres= request.params.addres
    if uid ==nil  then
        response.ret=-102
        return response
    end
    
    if moduleIsEnabled('alien') == 0 then
        response.ret = -16000
        return response
    end



    local uobjs = getUserObjs(uid)
    uobjs.load({"alien","userinfo"})
    
    local mAlien= uobjs.getModel('alien')
    if type(addres)=='table'  and next(addres) then
        for k,v in pairs(addres) do
            mAlien.prop[k]=v
        end
    end

    local alienTechCfg = getConfig("alienTechCfg")
    if type(alien)=='table'  and next(alien) then
        for k,v in pairs(alien) do
            -- local talentType=alienTechCfg.talent[k][3]
            -- if talentType==2 then
            --     local effectTroops=alienTechCfg.talent[k][5]
            --     if effectTroops==nil then
            --         return response
            --     end
            --     mAlien.useTech(effectTroops,k)
            -- end
            local maxLv=alienTechCfg.talent[k][8]
            if v>maxLv then
                v=maxLv
            end
            mAlien.info[k]=v

            mAlien.autoAppendTech(k)
            if alienTechCfg.talent[k][14] then -- 刷新科技树属性
                mAlien.refreshTechTreeAttr( alienTechCfg.talent[k][14] )
            end
        end
    end


    if uobjs.save() then 
       
        response.data.alien = {info=mAlien.info, used=mAlien.used, used1=mAlien.used1,prop=mAlien.prop }
        response.ret = 0        
        response.msg = 'Success'
    end
    
    return response



end