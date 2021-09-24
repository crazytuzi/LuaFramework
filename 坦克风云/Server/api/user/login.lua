function api_user_login(request)
    local response = {
        data = {},
        config = {},
        ret = 0,
        msg = 'Success'
    }
        
    local uid = tonumber(request.uid) or 0
    local luaV = tonumber(request.luaV) or 1
    local gameversion = tonumber(request.version) or 1
    if gameversion < 1 then gameversion = 1 end

    uid = userLogin(uid)
    
    if uid>0 then        
        
        local uobjs = getUserObjs(uid)
        uobjs.load({"userinfo", "techs", "troops", "props","bag","skills","buildings","bookmark","challenge","dailytask","task",'useractive','echallenge',"accessory","boom","jobs","areacrossinfo","badge"})

        local mUserinfo = uobjs.getModel('userinfo')
        local mBadge = uobjs.getModel('badge')
        -- GM聊天变色返回
        response.data.gu=getGmChat("GM-chat")
        --控制玩家等级是否达到功能整合要求
        response.data.checkfunmerge = false
        if mUserinfo.level>=50 then
            response.data.checkfunmerge = true
        end
        --初始化强更版本号
        if mUserinfo.flags.strongversion == nil or mUserinfo.flags.strongversion == 0 then
            mUserinfo.flags.strongversion = gameversion
        end
        local strongversion = mUserinfo.flags.strongversion or 0
        if gameversion > mUserinfo.newstrongversion then
            mUserinfo.newstrongversion = gameversion
        end
        --配置版本号
        local strongVersions = getConfig('base.GAME_STRONG_VERSION')
        local cfgstrongversion = strongVersions and strongVersions[tostring(request.appid)] or 0
        local giftcfg =getConfig('player.mandatoryUpdate')
        local versionlevel = giftcfg.level
        local reward = giftcfg.backReward.serverReward
        local versioncount = giftcfg.remindtimes
        local report = {}
        for k,v in pairs(reward) do
            table.insert(report, formatReward({[k]=v}))
        end
        if tonumber(mUserinfo.hwid) == 1 then
            response.ret = -133
            return response
		elseif type(mUserinfo.hwid) == 'table' then
			local hwidinfo = mUserinfo.hwid
			local ts = getClientTs()
			if (tonumber(hwidinfo[1]) or 0) <= ts and( tonumber(hwidinfo[2]) or 0) > ts and hwidinfo[3] then
				response.ret= -133
				response.bannedInfo = hwidinfo
				return response
			end
		end

        -- email 记录子渠道id，统计用
        if mUserinfo.email == "" and request.appid then
            mUserinfo.email = request.appid
        end
        if request.deviceid and mUserinfo.deviceid ~= request.deviceid then -- 设备id
            mUserinfo.deviceid = request.deviceid
        end
        if request.platid and mUserinfo.platid == "" then -- 平台id
            mUserinfo.platid = request.platid
        end
        if request.channelid and mUserinfo.channelid == "" then --渠道id
            mUserinfo.channelid = request.channelid
        end

        -- 3kios 发奖标记
        if getClientPlat() == 'ship_3kwanios' or getClientPlat() == 'ship_3kwan'  then
            if tonumber(mUserinfo.email) == 9002001 and tonumber(request.appid) == 9002002 then
                mUserinfo.flags.kios=1 -- 待发奖标记
                mUserinfo.email=request.appid
            end
        end
        
    	if tonumber(request.appid) == 10118 and getZoneId() ~= 1000 then 
    		if luaV < getConfig('base.CLIENT_SUB_VERSION_IOS') and mUserinfo.tutorial >= 10 then
                      response.ret = -132
                      return response
                    end
    	else
    		if luaV < getConfig('base.CLIENT_SUB_VERSION') and mUserinfo.tutorial >= 10 then
                       response.ret = -132
                       return response
                    end
    	end
        

        local guest = tonumber(request.isbind) or 0
        if guest == 1 and mUserinfo.guest == 0 then
            mUserinfo.guest = 1
            if mUserinfo.flags.bindAward ~= 1 then
                mUserinfo.flags.bindAward = 1
                mUserinfo.addResource{gems=20}
            end
        end
        
        if mUserinfo.alliance > 0 then
            regEventAfterSave(uid,'e4',{aid=mUserinfo.alliance,level=mUserinfo.level,name=mUserinfo.nickname,logined_at=mUserinfo.logindate})
        end

        mUserinfo.setAuditData{action="login",request=request}

        response.data.versionlevel = versionlevel
        response.data.versioncount = versioncount
        response.data.versionreward = report
        response.data.cfgstrongversion = cfgstrongversion
        response.data.userinfo = mUserinfo.toArray(true)

        local mTechs = uobjs.getModel('techs')
        mTechs.update()
        response.data.techs = mTechs.toArray(true)

        local mToops = uobjs.getModel('troops')        
        mToops.update()        
        response.data.troops = mToops.toArray(true)       

        local mProp = uobjs.getModel('props')
        mProp.update()
        mProp.updateUsePropCd()
        response.data.props = mProp.toArray(true)

        local mBag = uobjs.getModel('bag')
        -- 昆仑北美推广的时候，针对ios弄了个下载礼包，每个用户只要从ios登陆都送一个

        response.data.bag = mBag.toArray(true)
        
        local mSkills = uobjs.getModel('skills')
        response.data.skills = mSkills.toArray()
        
        local mBuildings = uobjs.getModel('buildings')
        local ts = getClientTs()
        if moduleIsEnabled("auto_build") == 1 then
            if mBuildings.auto ==1 and mBuildings.auto_expire > ts then
                mBuildings.autoUpgrade()
            else
                mBuildings.update()
            end
        else
            mBuildings.update()
        end
        response.data.buildings = mBuildings.toArray(true)

        local mBookmark = uobjs.getModel('bookmark')
        response.data.bookmark = mBookmark.toArray(true)        

        local mDailytask = uobjs.getModel('dailytask')
        response.data.dailytask = mDailytask.toArrayNew(true)
        --新的每日任务的标识
        response.data.dailytask.flag = mDailytask.getRewardFlag()

        local mChallenge = uobjs.getModel('challenge')
        response.data.challenge = mChallenge.getChallengeMaxSid()

        if moduleIsEnabled("sec") == 1 and moduleIsEnabled("hero") == 1  then
			local schallenge = uobjs.getModel('schallenge')
            response.data.schallenge = schallenge.getChallengeMaxSid()
        end

        local mAccessory = uobjs.getModel('accessory')
        response.data.accessory={}
        response.data.accessory.m_level=mAccessory.m_level
        response.data.accessory.succ_at=mAccessory.succ_at

        local mBoom = uobjs.getModel('boom')
        mBoom.update()
        response.data.boom = mBoom.toArray(true)

        if moduleIsEnabled("sequip") == 1 then
            local mSequip = uobjs.getModel('sequip')
            local olvl = mSequip.update( true )
            mSequip.checkAttackStats()
            response.data.sequip = mSequip.toArray(true)
            response.data.sequip.info['olvl'] = olvl --后端传开放等级
        end
        if moduleIsEnabled('alienweapon') == 1 then
            local mAweapon = uobjs.getModel('alienweapon')
            response.data.alienweapon = mAweapon.toArray(true)
            -- if moduleIsEnabled('jewelsys') == 1 then
            --     response.data.alienjewel = mAweapon.getlogindata()
            -- end
        end
        --每日中午领体力和每日下午领体力
        if moduleIsEnabled('drew1') ~= 0 or moduleIsEnabled("drew2") ~= 0 then
            local mDailyeneygy = uobjs.getModel("dailyenergy")
            response.data.dailyenergy = mDailyeneygy.genenalenergy()
        end

        --跨服战聊天称号
        local mCrossinfo = uobjs.getModel('crossinfo')
        local crossRanking, crossTime = mCrossinfo.getRecordRanking()
        if crossRanking > 0 then
            response.data.userinfo.crossranking = {crossRanking, crossTime}
        end
        --跨服战是否开启
        require "model.serverbattle"
        local mServerbattle = model_serverbattle()
        --1 个人战
        --缓存跨服战的基本信息
        local mMatchinfo, code = mServerbattle.getRoundInfo(1)
        if code == 0 and next(mMatchinfo) then
            response.data.crossinit = {st=tonumber(mMatchinfo.st), et=tonumber(mMatchinfo.et)}
        end
        --2 军团跨服战
        --缓存跨服战的基本信息
        local amMatchinfo, code = mServerbattle.getAcrossBattleInfo()

        if code == 0 and next(amMatchinfo) then
            response.data.acrossinit = {st=amMatchinfo.st, et=amMatchinfo.et}
        end
        -- 军团跨服战称号
        local aCrossinfo = uobjs.getModel('acrossinfo')
        response.data.acrossfirst = aCrossinfo.getFirst()
        
        --3 世界大战
        --缓存世界大战的基本信息
        local wMatchinfo,code = mServerbattle.getWorldWarBattleInfo()

        if code == 0 and next(wMatchinfo) then
            response.data.worldwarinit = {st=wMatchinfo.st, et=wMatchinfo.et}
        end

        -- 5 区域跨服战
        local anMatchinfo,code = mServerbattle.getserverareabattlecfg()
        if code == 0 and next(anMatchinfo) then
            response.data.areawarinit = {st=anMatchinfo.st, et=anMatchinfo.et}
        else
            local mAreacrossinfo = uobjs.getModel('areacrossinfo')
            if mAreacrossinfo.gems>0 then
                response.data.areawar={gems=mAreacrossinfo.gems}
            end
        end

        -- 远洋征战
        local oceaninfo,code = mServerbattle.getOceanExpeditionInfo(true)
        if code == 0 and next(oceaninfo) then
            response.data.oceanwar = {st=oceaninfo.st, et=oceaninfo.et}
        end

        -- 伟大航线
        local greatRouteInfo,code = mServerbattle.getGreatRouteInfo()
        if code == 0 and next(greatRouteInfo) then
            response.data.greatRouteTime = greatRouteInfo.st
        end
    
        --世界大战的称号
        local wCrossinfo = uobjs.getModel('wcrossinfo')
        response.data.worldfirst =wCrossinfo.getFirst()
        
        local mTask = uobjs.getModel('task')        
        mTask.check()
        -- 新增了任务，老用户需要检测一次是否已经完成了解锁新任务的上一个任务        
        if mUserinfo.flags.nTask ~= 6 then
            mTask.setNewTask()
            mUserinfo.flags.nTask = 6
        end

        response.data.task = mTask.toArray(true)
        --区域战职位
        local mJobs     = uobjs.getModel("jobs")
        local ts =getClientTs()
        if mJobs.end_at >ts then
            response.data.jobs={job=mJobs.job,end_at=mJobs.end_at}
        end        
        -- 用户是否被禁言
        local playerconfig = getConfig("player")
        if playerconfig.blacklist then
            local mBlackList = uobjs.getModel('blacklist')
            local limitTime = mBlackList.getBlackTime()
            if limitTime then
                response.data.nst = limitTime
            end
        end
        -- 公告
        local sysNotice = require "model.notice"

        if type(mUserinfo.flags.notice) ~= 'number' then
            mUserinfo.flags.notice = 0
        end
        local sys=request.system

        local _nil = 1
        _nil,response.data.newnotice,response.data.hasnotice = sysNotice:getUserNewNotice(mUserinfo,true,tonumber(request.appid),sys)
        _nil = nil
        -- local noticeid = sysNotice:publicNotice(mUserinfo)
        -- local disabledNotices = sysNotice:getDisabledNotices()
        -- mUserinfo.updateNotice(disabledNotices)
        -- for k,v in pairs(noticeid) do  
        --     table.insert(mUserinfo.flags.notice,v)
        -- end
        
        -- 活动列表
        require "model.active"
        local mActive = model_active()
        response.data.active = {mActive.getTitleList(mUserinfo.logindate,uid)}

        local mUseractive = uobjs.getModel("useractive")
        response.data.useractive = mUseractive.toArray(true)
        if type(response.data.useractive) == 'table' and not next(response.data.useractive) then
            mUseractive.init()
        end
        -- 5.1 钛矿丰收周
        activity_setopt(uid,'taibumperweek',{l=1})
        local germancard=activity_setopt(uid,'germancard',{num=0})
        if not germancard and type(response.data.active[1]['germancard'])=='table' then
            response.data.active[1]['germancard'] = nil
        end

        if response.data.active[1]['oceanmorale'] then
            response.data.active[1]['oceanmorale'] = nil
        end

        -- 判断平台
        -- 判断注册超过7天以后把钢铁之心干掉
        -- local platform = getConfig('base.AppPlatform')
        -- if platform == "kunlun_na" or  platform=="def"  then
        --     if type(mUseractive.info.heartOfIron)=="table" and next(mUseractive.info.heartOfIron) then
        --         local rsttime  = mUserinfo.regdate

        --         local ts =getClientTs()
        --         local firstweets = getWeeTs(rsttime+24*3600)
        --         --检测注册时间是都大余7天
        --         if  ts> (firstweets+7*86400) then
        --             mUseractive.info.heartOfIron.c=-1
        --         else
        --             --是第七天的时候把所有的重型加起来
        --             local day=mUseractive.info.heartOfIron.v.troops[2]
        --             if ts<(firstweets+day*86400) and ts>(firstweets+day*86400-86400) then
        --                 local cuut = 0
        --                 if type(mUseractive.info.heartOfIron.v.tank) ~='table' then mUseractive.info.heartOfIron.v.tank={} 
        --                     --算一下四种重型的累加数
        --                     mUseractive.info.heartOfIron.v.tank.a10003=(mToops.troops.a10003 ) or 0 
        --                     cuut=cuut+mUseractive.info.heartOfIron.v.tank.a10003
        --                     mUseractive.info.heartOfIron.v.tank.a10013=(mToops.troops.a10013 ) or 0 
        --                     cuut=cuut+mUseractive.info.heartOfIron.v.tank.a10013
        --                     mUseractive.info.heartOfIron.v.tank.a10023=(mToops.troops.a10023 ) or 0 
        --                     cuut=cuut+mUseractive.info.heartOfIron.v.tank.a10023
        --                     mUseractive.info.heartOfIron.v.tank.a10033=(mToops.troops.a10033 ) or 0    
        --                     cuut=cuut+mUseractive.info.heartOfIron.v.tank.a10033
        --                     mUseractive.info.heartOfIron.v.troops[3]=cuut
        --                 end
        --             end
        --         end

        --     end
        -- end
        -- 资金招募活动
        activity_setopt(uid,'fundsRecruit',{type=-1, name='login'})
        activity_setopt(uid,'shengdanbaozang',{})
        activity_setopt(uid,"oldUserReturn",{logindate=mUserinfo.logindate,level=mUserinfo.level})
        -- 老玩家回归（德国）
        activity_setopt(uid,"userreturn",{logindate=mUserinfo.logindate,regdate=mUserinfo.regdate,level=mUserinfo.level,vip=mUserinfo.vip})        
        -- 悬赏任务
        activity_setopt(uid,'xuanshangtask',{t=''})
         -- 召回付费礼包
        activity_setopt(uid,'recallpay',{act='login'})--注：这个要放在 response.data.useractive 前面
        -- 德国首冲条件礼包
        activity_setopt(uid,'sctjgift',{act='login'})--注：这个要放在 response.data.useractive 前面
        -- 德国召回
        activity_setopt(uid,'gerrecall',{act='login',nickname=mUserinfo.nickname,lt=mUserinfo.logindate,level=mUserinfo.level,vip=mUserinfo.vip})
        response.data.useractive = mUseractive.toArray(true)

        --二周年
        activity_setopt(uid,"anniversary2",{act='login',userLv=mUserinfo.level,lastLoginTs=mUserinfo.logindate})

        -- 德国七日狂欢
        activity_setopt(uid,'sevendays',{act='sd1',v=0,n=0})
        activity_setopt(uid,'sevendays',{act='addtank',v=0,n=mToops.troops})
        -- 版号申请，对小米用户不返活动数据
        -- if (tonumber(request.appid) == 10415 and mUserinfo.level <= 15) or uid == 6032013 or uid == 4000243 then
        --     response.data.useractive = nil
        -- end

       
        

        response.data.mail={unread = MAIL:mailHasUnread(uid)}    -- 未读邮件        
        MAIL:mailDelScout(uid)   -- 删除侦察邮件
        -- activity_daily(uid) -- 每日活动

        -- 全局配制
        --参数=true就是要兼容旧的格式
        response.config = getModuleIs( tostring(request.appid) ) -- getConfig("gameconfig")
        -- 新格式
        -- response.newconfig = getModuleIs()
        --ptb:p(response.config)
        -- 更新用户的登陆时间

        -- 如果是用户今日首次登陆，需要把所有Log记下来
        local dailyFirstLogin = mUserinfo.logindate < getWeeTs()
        -- 校对主城提升的额外体力上限值
        if dailyFirstLogin then
            local extraEnergy = mBuildings.getExtraEnergy()
            mUserinfo.setExtraEnergy(extraEnergy)
        end

        -- 登录间隔在15分钟以上的,注册一个检测地图的定时
        if ts - mUserinfo.logindate >= 900 then
            setGameCron({cmd ="admin.setusermap",params={uid=uid,action="checkUserMap"}},uid%10+5)
        end

        mUserinfo.logindate = getClientTs()
        local openTime = getConfig("alienMineCfg.openTime")
        local weekday=getDateByTimeZone(mUserinfo.logindate,"%w")
        if weekday~=openTime[1] or weekday==openTime[2] then
            local redis = getRedis()
            local weets =getWeeTs()
            local key = "z"..getZoneId()..".refAlienUserRank.ts."..weets
            response.data.alienreward=tonumber(redis:get(key))
        end
        if mUserinfo.mapx == -1 or mUserinfo.mapy == -1 then
            -- 注册3级分配地图事件
            regEventBeforeSave(uid,'e4',{})
        end

        -- 精英关卡今日未击杀的数量
        local mEchallenge = uobjs.getModel("echallenge")
        response.data.ecNum = mEchallenge.getDailyNotKillNum(mUserinfo.level)

        -- 版本中的等级配置
        local versionLvCfg =getVersionCfg()
        response.data.lv = versionLvCfg.clientVersionCfg

        -- 为了给日本下新包用户发道具临时加的一个东西
        -- if request.channelid == 'androidjapan4' then
        --     if not mUserinfo.flags.channelid then
        --         mBag.add('p55',1)
        --         mUserinfo.flags.channelid = 1
        --     end
        -- end

        -- tmp
        local checkDailyActionUids = getCheckDailyActionNumUids( uid )
        if checkDailyActionUids[tostring(uid)] then 
            response.data.isBH = 1
        end
        -- tmp
        -- 世界等级
        if moduleIsEnabled('wl')== 1 then
             response.data.wlvl=getWorldLevel()
             response.data.wexp=getWorldLevelExp()
             response.data.alien = {}
             local mAlien= uobjs.getModel('alien')
             response.data.alien.pinfo = mAlien.pinfo
        end
        
        if moduleIsEnabled('ladder') == 1 then
            require "model.skyladder"
            local skyladder = model_skyladder()
            local base = skyladder.getBase()
            local mUserexpand = uobjs.getModel('userexpand')
            local mySkyladder = mUserexpand.getMySkyladderData()
           
            if base and tonumber(base.over) == 1 and mySkyladder.cubid ~= base.cubid then
                local pstatus,myrank = skyladder.getOverPersonReward(uid)
                if pstatus then
                    mySkyladder.lsbid = mySkyladder.cubid
                    mySkyladder.lsrank = mySkyladder.curank
                    mySkyladder.cubid = base.cubid
                    mySkyladder.curank = myrank
                    mUserexpand.setMySkyladderData(mySkyladder)
                end
            end

            if base and tonumber(base.over) == 1 and tonumber(mUserinfo.alliance) > 0 then
                local myAllianceSkyladder = getAllianceSkyladderData(mUserinfo.alliance)
                if base and  myAllianceSkyladder.cubid ~= base.cubid then
                    local astatus,arank = skyladder.getOverAllianceReward(mUserinfo.alliance)
                    if astatus then
                        setAllianceSkyladderData(mUserinfo.alliance,base.cubid,arank)
                    end
                end
            end
            
            response.data.ladder = {champion=skyladder.getLastChampion(base.lsbid)}
        end

        -- 和谐版抽奖 奖励配置
        if moduleIsEnabled('harmonyversion') ==1 then
            response.data.harVersion=getHarFunsCfg("funcs")
        end

        --将老玩家的piclist放入picstore表中()
        mUserinfo.movepiclist()

        -- 击杀赛
        if moduleIsEnabled('kRace') ==1 then
            local libKillRace = loadModel("lib.killrace",{init=true})
            response.data.killRace = libKillRace.toArray(true)
        end
        
        -- 跨服战资比拼活动配置
        require "model.zzbp"
        local zzbp = model_zzbp()
        local  flag,zcfg = zzbp.check()
        if type(zcfg)=='table' and next(zcfg) then
            response.data.zzbp = {st=tonumber(zcfg.st),et=tonumber(zcfg.et),cfgid=tonumber(zcfg.cfgid)}
        end
        
        -- 成就系统
        if moduleIsEnabled('avt') == 1 then
            local mAchievement = uobjs.getModel('achievement')
            if not mAchievement.uinfo["a0"] then
                local atb = {}
                local achievementCfg = getConfig("achievement")
                if achievementCfg and achievementCfg.person then
                    for k,v in pairs(achievementCfg.person) do
                        table.insert(atb,k)
                    end
                end
                updatePersonAchievement(uid,atb)
                mAchievement.uinfo["a0"] = 1
            end
        end

        -- 远洋证战
        response.data.masterLabel = mUserinfo.getOceanExpeditionBuffEt()

        processEventsBeforeSave()
        if uobjs.save() then
            processEventsAfterSave()
            
            if mUserinfo.tutorial == 10 and mUserinfo.level >= 3 then
                setChallengeRanking(uid,mChallenge.star,mChallenge.star_at)
                setHonorsRanking(uid,mUserinfo.reputation)
                setFcRanking(uid,mUserinfo.fc)
            end
            if moduleIsEnabled('thirdpay') == 1 then
                require 'model.gameconfig'
                local mGameconfig = model_gameconfig()
                response.data.thirdPayLimit = mGameconfig.getgameconfigpay()
            end

            response.timezone = getConfig('base.TIMEZONE')        

            -- 北美登陆日志
            local clientPlat = getClientPlat()
            -- if clientPlat == "kunlun_na" or clientPlat == "1mobile" or clientPlat == "kunlun_france" then
            --     if (mUserinfo.logindate - mUserinfo.regdate) > 60 then
            --         local log = {request.rplatid,uid,request.pname,request.client_ip,getClientTs()}
            --         writeKunLunNALog(request.appid,1,log)
            --     end
            -- end

            -- 3k 登入登出统计
            if clientPlat == "ship_3kwan" or clientPlat == "ship_3kwanios" or clientPlat == "ship_android" or clientPlat == "ship_jap" then
                regLoginAndLogout(uid, request.client_ip or 0)
            end

            if moduleIsEnabled('rewardcenter') then
                require "lib.rewardcenter"
                local rewardcenter = model_rewardcenter()
                response.data.rewardcenter = {}
                response.data.rewardcenter.total = rewardcenter.getRewardNum(uid)
            end
            
            -- 首次登陆log
            if dailyFirstLogin then
                -- MAIL:mailDelAlienmine()
                local firstLoginLog = {
                    uid = uid,
                    userinfo = response.data.userinfo,
                    troops = response.data.troops,
                    useractive = response.data.useractive,
                    bag = response.data.bag,
                    accessory = response.data.accessory,
                    props = response.data.props,
                }
                writeLog(firstLoginLog,'firstLoginLog')
            end

            return response
        end
        
    end

    response.ret = -1
    return response
end
