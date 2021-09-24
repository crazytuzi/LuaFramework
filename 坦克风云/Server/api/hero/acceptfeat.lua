-- 接受授勋
function api_hero_acceptfeat(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local hid = request.params.hid 
    if uid == nil or  hid==nil  then
        response.ret = -102
        return response
    end

    if moduleIsEnabled('herofeat') == 0 then
        response.ret = -11020
        return response
    end
    
    local uobjs = getUserObjs(uid)
    uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings",'useractive',"hero"})
    local mHero = uobjs.getModel('hero')
    local mUserinfo = uobjs.getModel('userinfo')
    local mBag = uobjs.getModel('bag')

    if type (mHero.hero[hid]) ~='table' then

        response.ret=-11002
        return response
    end
    if next(mHero.feat) then
        response.ret=-11021
        return response
    end


    local heroinfo=mHero.hero[hid]
    --授勋任务( t1收集魂魄; t2携带该将领在16章及以后的关卡中获胜; t3携带此将领竞技场胜利n次; t4携带此将领击杀军团副本BOSS; t5携带此将领获得n军功 t6攻打n次补给线（包含扫荡）; t7通过远征军关卡n次 )
    local heroFeatCfg = getConfig('heroFeatCfg')
    local levelLimit  = heroFeatCfg.levelLimit
    local fusionLimit = heroFeatCfg.fusionLimit
    local heroQuest   = heroFeatCfg.heroQuest
    if heroinfo[1]<levelLimit then
        response.ret=-11022
        return response
    end
    if heroinfo[3]<fusionLimit then
        response.ret=-11022
        return response
    end

    -- 补充说明：
    -- heroinfo[3]达到fusionLimit时才能授勋，大于fusionLimit时二次授勋
    -- 所以一次授勋时nowfusion = 0，后边在取配置时要用 nowfusion + 1
    local nowfusion=heroinfo[3]-fusionLimit -- 二次受勋
    if heroinfo[3]>fusionLimit then
        if  heroFeatCfg.fusionLimit2[nowfusion]==nil  then
            response.ret=-11022
            return response
        end
        if heroinfo[1]<heroFeatCfg.levelLimit2[nowfusion] then
            response.ret=-11022
            return response
        end 
        if heroQuest[hid][nowfusion+1]==nil then
            response.ret=-11022
            return response
        end
    end
    if heroQuest[hid]==nil or type(heroQuest[hid])~='table' then
        response.ret=-102
        return response
    end

    --新增放弃 第5步任务（授勋），配置只有4步，检测第4步完成情况
    local task= heroQuest[hid][nowfusion+1]
    local tasknum = 0 -- 当前任务量
    local tid=1
    if task and mHero.hfeats[hid]~=nil and mHero.hfeats[hid]>1 then
        tid=tonumber(mHero.hfeats[hid])

        if tid > #task then --前4步都完成了
            tid = #task
            tasknum = task[#task][2]
        end
    end
    mHero.hfeats[hid]=nil
    mHero.feat = {hid,tid,tasknum}

    mHero.refreshFeat(heroQuest[hid][nowfusion+1][tid][1],0,0)
    if uobjs.save()  then 
        processEventsAfterSave()
        response.data.hero =mHero.toArray(true)
        response.ret = 0        
        response.msg = 'Success'
    end
    return response
    


end