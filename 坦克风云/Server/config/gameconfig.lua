local function returnCfg(clientPlat)
    local commonCfg={
        --军团
        alliance = {
            skills = 1,--科技
            enable = 1,--军团开关
            achallenge = 1,--军团关卡
            war = 1, -- 军团战
            shop = 1, -- 军团商店
        },
        --好友
        friend = {
            enable = 0,
        },
        --签到
        sign = {
            enable = 1,
        },
        --激活码
        code = {
            enable = 1,
        },
        --精英关卡和配件
        ec = {
            enable = 1,
        },
        --次日风暴
        nd = {
            enable = 1,
        },
        --成长计划
        gw = {
            enable = 1,
        },
        --在线礼包
        ol = {
            enable = 1,
        },
        video = {
            enable = 0,
        },
        --军事演习
        military ={
            enable = 1,
        },
        -- 评论
        evaluate={
            enable = 0,
        },
        pay = {
            enable = 1,
        },
        -- landform 地形
        lf={
            enable = 1,
        },
        -- 自动升级
        auto_build =
        {
            enable = 1,
        },
        --繁荣度
        boom={
            enable=1, --总开关
            troops=1, --带兵量加成
            resource=0, --资源加成
        },        
        -- vip新特权

        -- vip 增加战斗经验 ok
        vax =1,
        --配件合成概率提高  ok
        vea =0,
        --创建军团不花金币  ok
        vca =1,
        --装置车间增加可制造物品 ok
        vap=1,
        -- 高级抽奖每日免费1次   ok
        vfn =1,
        -- 仓库保护资源量    ok
        vps =1,
        -- 每日捐献次数上限      o
        vdn =1,
        --精英副本扫荡
        vec=1,
        allianceskills = 1,--科技
        allianceenable = 1,--军团开关
        allianceachallenge = 1,--军团关卡
        alliancewar = 0, -- 军团战
	-- 军团战-2016版
        alliancewarnew=1,
        allianceshop = 1, -- 军团商店
        -- 月卡功能
        mc=0,
        -- 购买月卡
        bmc=0,
        -- 主线任务
        mt=1,

        -- troopsUP
        luck = 0,
        push=0,
        --英雄
        hero=1,
        --真实英雄
        truehero=1,
        -- 远征军
        expedition=1,
        -- 富矿热度
        heat=1,
        -- 配件商店
        ecshop=0,
        -- 军功商店
        rpshop=0,
        -- 军功商店前端永远开放
        rpshopopen=0,
        -- qq空间应用宝平台
        qq=0,
        -- 世界boss
        boss=1,
        -- 每日答题
        dailychoice=0,
		-- 每日领取奖励
        drew1=1,
        drew2=1,
        -- 异星科技
        alien=0,
        -- vip购买礼包
        vipshop=0,
        -- 洗练
        succinct=0,
        -- 协防的设置
        sethelp=0,
        -- 异星矿场地图,1是正常开启，2是表示前后端永久开放
        amap=0,
        -- 建筑优化
        byh=0,
        -- 将领授勋 version 必须开11版本
        herofeat=0,
        -- 屏蔽邮件
        mbl=0,
        pic =
        {
            --更换头像
            changepic=1,
            --真实头像
            truepic = 0,
        },
        -- 扫矿验证
        checkcode = 0,
        -- 漂浮物开关
        floater = 1,
        -- 区域战
        areawar=1,
        -- 实名认证
        auth = 1, 
        -- 关卡扫荡
        raid = 1,
        sec=1,
        -- 精英关卡扫荡
        sraid = 1,        
        -- 军团副本一键领取
        achallengeall=1,
        -- 世界等级
        wl=0, 
        -- 金矿系统
        goldmine=0,
        --矿点升级
        minellvl=0,
        -- 开放异星科技系统等级
        al=15,
        -- 异星商店
        alienshop =1,
        -- 开放将领装备系统等级
        hel=30,
        -- vip免费升级加速
        fs=0,
        -- 军团协助和新科技
        alliancehelp=0,
        -- 2016年10月版新任务
        ndtk=0,
        -- 购买体力开关，每次购买体力5点变为每次10点,对应价格也提升1倍
        uben=0,
        -- 指挥中心升级到指定等级提高玩家能量上限值加功能开关
        uel=0,
        -- 军团旗帜
        alogo=0,
        -- 和谐版抽奖开关
        harmonyversion = 0,
        -- 战力引导优化开关
        youhua=0,
        -- 聊天加密走http请求(前端用)
        chatHttp=0,
        -- 军团副本boss
        fbboss=0,
        -- 击杀赛(夺海骑兵)
        kRace=0,
        -- 馈赠红包
        redGift=0,
        -- 配件一键强化
        accessoryMUp=0,
        -- 天梯榜
        ladder = 0,
        -- 将领重生开关
        herorebirth = 0,
        -- 配件绑定
        ab=0,
        -- 配件科技
        at=0,
        -- 关卡前期优化
        chyh=0,
        --剧情对话
        chyhGuid =0,
        -- 绑定邮箱
        bindmail = 0,
        -- 公海领地
        allianceDomain = 0,
        -- 邮件优化开关
        ros=0,
        -- 宝石系统
        jewelsys = 0,
        -- 版本强更
        gameversion = 0,
        -- 绑定手机
        bindphone = 0,
        -- 异星科技重置
        alienTreset = 0,

        -- 指挥官新技能
        nbs = 0,    }

    local platCfg={

    }

    if clientPlat ~= 'def' then
        if platCfg and type(platCfg[clientPlat]) == 'table' then
            for k,v in pairs(platCfg[clientPlat]) do
                commonCfg[k] = v
            end
        end
    end

    return commonCfg
end

return returnCfg
