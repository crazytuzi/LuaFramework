function api_pay_processorder(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
        cmd = "msg.pay",
    }

    local uid = tonumber(request.uid)
    local odder_id = request.params.odder_id
    local gold_num = tonumber(request.params.gold_num) or 0
    local extra_gold_num = tonumber(request.params.extra_gold_num) or 0
    local platform = request.params.platform

    if uid == nil or odder_id==nil or platform == nil or type(request.params) ~= 'table' or gold_num < 0 or (gold_num == 0 and extra_gold_num <= 0)  then
        response.ret = -102
        return response
    end

    local function payLog(logInfo,filename)
        local log = ""
        log = log .. os.time() .. "|"
        log = log .. (logInfo.uid or ' ') .. "|"
        log = log .. (logInfo.msg or ' ') .. "|"
        log = log .. (logInfo.code or '-1')

        filename = filename or 'pay'
        writeLog(log,filename)
    end

    local function createTradeLog(tradelog)
        local db = getDbo()

        local ret = db:insert('tradelog',tradelog)
        local queryStr = db:getQueryString() or ''
        if not ret  then
            payLog({uid=uid,msg='insert failed: '..queryStr,code=-130})
        end
    end

    -- 获取订单
    local function getTradeLog(odder_id)
        local db = getDbo()
        local result = db:getRow("select * from tradelog where id = :id and status = 1",{id=odder_id})
        if type(result) == 'table' and next(result) then
            return true
        end
    end

    -- 订单已经成功处理过
    if getTradeLog(odder_id) then
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    local uobjs = getUserObjs(uid)
    local mUserinfo = uobjs.getModel('userinfo')
    local ts = getClientTs()
    local serverplatform = getClientPlat()

    -- 验证渠道号
    if request.params.channel_id and mUserinfo.channelid ~= "" then
        if serverplatform == "ship_3kwan" or serverplatform == "ship_3kwanios" or serverplatform == "ship_android" then
            local t = mUserinfo.channelid:split("_")
            if tonumber(t[1]) ~= tonumber(request.params.channel_id) then
                response.ret = -102
                response.err1 = 'channel_id invalid'
                response.user_channel_id = mUserinfo.channelid
                return response
            end
        end
    end

    -- 增加金币的标识
    local addGemRet = true

    local player = getConfig("player")
    local mflag = false  --购买月卡不算到任何活动金额
    if player.buymonthcard and player.buymonthcard>0 and (serverplatform=='5' or serverplatform=='def' or serverplatform=='kunlun_na' or serverplatform=='kunlun_france') then
        --ioskunlun 是北美ios的
        if gold_num==player.buymonthcard and (platform=='flappstore' or platform=='androidkunlun' or platform=='ioskunlun' or platform=='androidkunlunz' or platform=='ioskunlunfy' or platform=='androidklfy' ) then
            mflag=true
        end
    end
    local fistchargeflag=0--首充标识
    if mUserinfo.buygems == 0 then
        if not mflag and gold_num > 0 then
             fistchargeflag=1
            activity_setopt(uid,'firstRecharge',{num=gold_num})
        end
    else    -- 这是为了兼容中途上首冲活动的平台，其实可以删除了
        local uobjs = getUserObjs(uid)
        local mUseractive = uobjs.getModel('useractive')

        if mUseractive.info.firstRecharge and mUseractive.info.firstRecharge.c == 0 then
            if not mflag and gold_num > 0 then
                activity_setopt(uid,'firstRecharge',{num=gold_num})
            end
        end

        if (mUseractive.info.firstRecharge and (mUseractive.info.firstRecharge.c or 0) < 0) or (mUserinfo.buygems > 0 and not mUseractive.info.firstRecharge ) then
            if not mflag and gold_num > 0 then
                activity_setopt(uid,'rechargeDouble',{num=gold_num})
                --日本充值返利
                activity_setopt(uid,'customRechargeRebate',{num=gold_num})
                --战备军需
                activity_setopt(uid,'rechargeFight',{num=gold_num})                
            end
        end
    end

    -- 所有活动在这里触发
    if not mflag and gold_num > 0 then
        activity_setopt(uid,'dayRecharge',{num=gold_num})
        activity_setopt(uid,'bindDayRecharge',{num=gold_num})
        activity_setopt(uid,'totalRecharge',{num=gold_num})
        activity_setopt(uid,'bindTotalRecharge',{num=gold_num})
        activity_setopt(uid,'totalRecharge2',{num=gold_num})
        activity_setopt(uid,'dayRechargeForEquip',{num=gold_num})
        activity_setopt(uid,'rechargeRebate',{num=gold_num})

        --基金
        activity_setopt(uid,'userFund',{num=gold_num})

        --投资计划
        activity_setopt(uid,'investPlan',{num=gold_num})

        --VIP总动员活动
        activity_setopt(uid,'vipAction',{num=gold_num})

        -- 坦克轮盘
        activity_setopt(uid,'wheelFortune4',{recharge=gold_num})

        --连续充值送好礼活动
        activity_setopt(uid,'continueRecharge',{gems=gold_num})
        --绑定型 连续充值送好礼活动
        activity_setopt(uid,'bindcontinueRecharge',{gems=gold_num})
        -- 充值红包活动
        activity_setopt(uid,'rechargeredbag',{gems=gold_num})

        -- 真情回馈
        activity_setopt(uid,'zhenqinghuikui',{num=gold_num})

        --满载而归活动
        activity_setopt(uid,'rewardingBack',{gems=gold_num})
        --有福同享
        activity_setopt(uid,'shareHappiness',{
            num=gold_num,
            allianceId = mUserinfo.alliance,
            allianceName = mUserinfo.alliancename,
            username = mUserinfo.nickname,
        }, true)
        --百服大礼
        activity_setopt(uid,'baifudali',{gems=gold_num,type="add"})
        --圣诞狂欢
        activity_setopt(uid,'shengdankuanghuan',{num=gold_num,category="addGem"})
        --元旦献礼
        activity_setopt(uid,'yuandanxianli',{type="addGem"})
        --水晶回馈
        activity_setopt(uid,'shuijinghuikui',{num=gold_num})
        --充值有礼
        activity_setopt(uid,'chongzhiyouli',{num=gold_num})
        --连续充值送将领
        activity_setopt(uid,'songjiangling',{num=gold_num})
        --5.1钛矿丰收周
        activity_setopt(uid,'taibumperweek',{pay=gold_num})
        -- 月度将领
        activity_setopt(uid,'yuedujiangling',{action=2,num=gold_num})
        -- 卡夫卡馈赠
        activity_setopt(uid,'kafkagift',{gems=gold_num})
        -- 月度签到
        activity_setopt(uid,'monthlysign',{gems=gold_num})
        -- 复活节礼包
        activity_setopt(uid,'eastergift',{gems=gold_num})
        -- 充值红包 
        activity_setopt(uid,'rechargebag',{gems=gold_num}, true)
        -- 充值回馈 
        activity_setopt(uid,'rechargeFeedback',{gems=gold_num})
        -- 奔赴前线,充值金币
        activity_setopt(uid,'benfuqianxian',{tasks={t5=gold_num}})
        -- 周年庆充值
        activity_setopt(uid,'anniversary',{action='charge', gems=gold_num})
        -- 不给糖就捣蛋
        activity_setopt(uid,'halloween',{num=gold_num})
        -- 开年大吉
        activity_setopt(uid,'openyear',{action="gb", num=gold_num})
        -- 春节攀升
        activity_setopt(uid, 'chunjiepansheng', {action="gb", num=gold_num})
        -- 陨石冶炼
        activity_setopt(uid, 'yunshiyelian', {action="gb", num=gold_num})
        -- 猎杀潜航
        activity_setopt(uid,'silentHunter',{action="charge",num=gold_num})

        -- 粽子作战
        activity_setopt(uid, 'zongzizuozhan', {u=uid,e='a',num=gold_num})        

        -- 悬赏任务
        activity_setopt(uid,'xuanshangtask',{t='',e='gb',n=gold_num}) 
        -- 点亮铁塔
        activity_setopt(uid,'lighttower',{act='charge',num=gold_num})
        -- 啤酒节
        activity_setopt(uid,'beerfestival',{act='charge',num=gold_num})
        -- 武器研发
        activity_setopt(uid,'wqyf',{num=gold_num})
        -- 橙配馈赠
        activity_setopt(uid,'cpkz',{num=gold_num})
                                
        -- 军团分享
        activity_setopt(uid,'allianceshare',{
            num=gold_num,
            allianceId = mUserinfo.alliance,
            allianceName = mUserinfo.alliancename,
            username = mUserinfo.nickname,
        })
        -- 二周年
        activity_setopt(uid,'anniversary2',{act='charge',num=gold_num})
        -- 万圣节狂欢
        activity_setopt(uid,'wsjkh',{act='charge',num=gold_num})   
        -- 闪购商店
        activity_setopt(uid,'sgshop',{act='charge',num=gold_num})
        -- 双十一2018
        activity_setopt(uid,'double112018',{act='charge',num=gold_num})
        -- 感恩节2017
        activity_setopt(uid,'thanksgiving',{act='charge',num=gold_num})   
        -- 装扮圣诞树
        activity_setopt(uid,'dresstree',{act='charge',num=gold_num})
        -- 矩阵商店     
        activity_setopt(uid,'armorshop',{num=gold_num})    
        -- 跨年福袋
        activity_setopt(uid,'luckybag',{act=4,n=gold_num}) 
        -- 连续消费
        activity_setopt(uid,'lxxf',{act='charge',num=gold_num})    
         -- 红包回馈
        activity_setopt(uid,'redbagback',{num=gold_num})    
		-- 岁末回馈
        activity_setopt(uid,'feedback',{act='charge',num=gold_num}) 
        -- 合服大战
        activity_setopt(uid,'hfdz',{act='gb',num=gold_num})  
        -- 德国月卡
        activity_setopt(uid,'germancard',{num=gold_num})  
        -- 圣帕特里克
        activity_setopt(uid,'dresshat',{act='charge',num=gold_num})
        -- 召回付费礼包
        activity_setopt(uid,'recallpay',{num=gold_num})
        -- 愚人节大作战
        activity_setopt(uid,'foolday2018',{act='charge',num=gold_num})
        -- 钻石轮盘
        activity_setopt(uid,'gemwheel',{act='charge',num=gold_num})
        -- 累计充值2018
        activity_setopt(uid,'concharge',{act='charge',num=gold_num})
        -- 全民劳动
        activity_setopt(uid,'laborday',{act='task',t='gb',n=gold_num})

        -- 跨服战资比拼
        zzbpupdate(uid,{t='f3',n=gold_num})
        -- 芯片装配
        activity_setopt(uid,'xpzp',{act='charge',num=gold_num})
        -- 超装组件
        activity_setopt(uid,'czzj',{act='charge',num=gold_num})
        -- 重金打造
        activity_setopt(uid,'zjdz',{act='charge',num=gold_num})
        -- 累计天数充值(世界杯)
        activity_setopt(uid,'ljtscz',{act='charge',num=gold_num})
        -- 累计充值(世界杯)
        activity_setopt(uid,'ljczsjb',{act='charge',num=gold_num})

        -- 团结之力
        activity_setopt(uid,'unitepower',{id=5,aid=mUserinfo.alliance,num=gold_num})
         -- 德国首冲条件礼包
        activity_setopt(uid,'sctjgift',{act='charge',num=gold_num})

        -- 远洋征战 士气值
        activity_setopt(uid,'oceanmorale',{act='charge',num=gold_num})

        -- 德国召回
        activity_setopt(uid,'gerrecall',{act='charge',nickname=mUserinfo.nickname,level=mUserinfo.level,num=gold_num})
        -- 配件大回馈
        activity_setopt(uid,'pjdhk',{act='charge',num=gold_num})
        -- 新橙配馈赠
        activity_setopt(uid,'cpkznew',{act='charge',num=gold_num})
        -- 限时充值
        activity_setopt(uid,'xscz',{num=gold_num})
        
        --军团之光
        activity_setopt(uid,'jtzg',{act='charge',num=gold_num})
        -- 军火限购
        activity_setopt(uid,'jhxg',{act='charge',num=gold_num})  
        -- 军校优等生
        activity_setopt(uid,'jxyds',{num=gold_num})  
        --堆金如玉
        activity_setopt(uid,'djjy',{num=gold_num})
        -- 番茄大作战
        activity_setopt(uid,'fqdzz',{act='tk',type='gs',num=gold_num})   
        activity_setopt(uid,'fqdzz',{act='tk',type='gb',num=gold_num})  

        -- 通用充值商店
        activity_setopt(uid,'tyczsd',{num=gold_num}) 

        -- 三周年-充值返利
        activity_setopt(uid,'sznczfl',{num=gold_num})

        -- 金秋祈福
        activity_setopt(uid,'jqqf',{num=gold_num})
         -- VIP礼包
        activity_setopt(uid,'VIPlb',{num=gold_num})
        -- 节日花朵
        activity_setopt(uid,'jrhd',{act="tk",id="gb",num=gold_num})
        -- 军团折扣商店
        activity_setopt(uid,'jtzksd',{num=gold_num,aid=mUserinfo.alliance})
        -- 感恩节拼图
        activity_setopt(uid,'gejpt',{act='tk',type='gb',num=gold_num})
        --马力全开
        activity_setopt(uid,'mlqk',{act="tk",type="gb",num=gold_num})
        -- 幸运锦鲤
        activity_setopt(uid,'xyjl',{num=gold_num})
        -- 充值团购
        activity_setopt(uid,'cztg',{num=gold_num,aid=mUserinfo.alliance,tzid=request.zoneid})
        -- vip狂欢
        activity_setopt(uid,'vipkh',{num=gold_num})
    else --购买月卡计算一下时间

        if type (mUserinfo.mc)~='table' then mUserinfo.mc={}  end
        local weeTs = getWeeTs()
        local mend = mUserinfo.mc[1] or 0
        if mend >weeTs then
            mUserinfo.mc[1]=mend+30*86400
        else
            mUserinfo.mc[1]=weeTs+30*86400
        end

    end

    -- 如果有额外赠送的金币，不计入VIP
    if addGemRet and extra_gold_num and extra_gold_num > 0 then
        addGemRet = mUserinfo.addResource({gems=extra_gold_num})
    end

    -- 如果充值金额大于0（有可能只送额外赠送的金币，计入VIP的金币是0）
    if gold_num > 0 then
        if (not addGemRet) or (not mUserinfo.addGem(gold_num) ) then
            payLog({uid=uid,msg="pay failed(add Gem .. award)",code=-130})
            response.ret = -130
            sendMsgByUid(uid,json.encode(response))
            return response
        end
    end

    local costNum = tonumber(request.params.cost) or 0
    if costNum > 0 then
        mUserinfo.addCost(costNum)
    end

    local mDailyTask = uobjs.getModel('dailytask')
    --新的日常任务检测
    local dflag=mDailyTask.changeNewTaskNum('s403',1)
    -- 中秋赏月活动埋点
    activity_setopt(uid, 'midautumn', {action='gb',num=gold_num})

    if uobjs.save() then
        processEventsAfterSave()

        local tradelog = {
            id = odder_id,
            userid = uid,
            num = gold_num,
            cost = request.params.cost,
            trade_type = platform,
            status = 1,
            curType = request.params.curType,
            name = request.params.itemid,
            create_time = ts,
            updateTime = ts,
            datestr = request.params.datestr,
            extra_num = extra_gold_num,
            zoneid = getZoneId(),
            appid = mUserinfo.email,--渠道ID (var)
            platid =  mUserinfo.platid,-- 玩家账号ID (var)
            nickname = mUserinfo.nickname,--角色名称
            deviceid =  mUserinfo.deviceid,-- 设备标识码
            iffirstbuy = fistchargeflag,-- 是否首充 1：首充
            apporderid = request.params.apporderid or '',-- 订单号
            os = request.params.os or '',--系统            
        }

        if request.params.event_id and request.params.token then
            tradelog.comment = tostring(request.params.event_id) .. '-' .. tostring(request.params.token)
        end

        createTradeLog(tradelog)

        -- 发邮件
        local content = {gold=gold_num}
        content = json.encode(content)
        --mailLib:mailSent(uid,sender,receiver,mail_from,mail_to,subject,content,mail_type,isRead,gift,item)
        -- 邮件中 参数-1是用来区分充值邮件的标识
        MAIL:mailSent(uid,0,uid,'',mUserinfo.nickname,-1,content,1,0)

        response.data.userinfo = mUserinfo.toArray(true)
        response.data.userinfo.ip = mUserinfo.ip
        if dflag then
            response.data.dailytask = mDailyTask.toArray(true)
        end
        response.data.payment = {}
        response.data.payment.itemId = request.params.itemid
        response.data.payment.GoodsCount = 1
        response.data.payment.num = gold_num
        response.data.payment.orderId = odder_id
        response.data.payment.amount = request.params.cost
        response.data.channel_id = request.params.channel_id

        response.ret = 0
        response.msg = 'Success'
        --sendMsgByUid(uid,json.encode(response))
        return response
    end

    payLog({uid=uid,msg="pay failed(save userinfo)",code=-130})
    response.ret = -130
    sendMsgByUid(uid,json.encode(response))
    return response

end
