local __Msg=_G.Msg
local __Const=_G.Const
local __CharacterManager=_G.CharacterManager

local StageMediator = classGc(mediator,function(self,_view)
    self.name="StageMediator"
    -- self.view=_view
    self.__stage=_G.g_Stage
end)

function StageMediator.registerProtocol(self, _sceneType)
    print("StageMediator.registerProtocol  _sceneType=",_sceneType)
    
    self.protocolsList={
        __Msg["ACK_SCENE_ENTER_OK"],       --进入场景 5030
        __Msg["ACK_SCENE_SET_PLAYER_XY"],  --强设玩家坐标 - 5100
        __Msg["ACK_ROLE_LOGIN_AG_ERR"], -- [1012]断线重连返回 -- 角色
        __Msg.ACK_COPY_TEAM_SKINS,-- [7970]组队开始前发送全部组员职业 -- 副本 
        __Msg.ACK_HONGBAO_SEND_ALL, -- [28301]通知 -- 抢红包 
    }
    
    if _sceneType == __Const.CONST_MAP_TYPE_CITY then  --地图类型-城镇
        if not _G.GSystemProxy:isHideOrtherOpen() then
            table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
            table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])     --行走数据(地图广播) - 5090
            table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])            --离开场景 - 5110
        end
        
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_CLAN"]) --场景广播-社团 - 5930
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_WUQI"]) --场景广播-武器 - 5921
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_MOUNT"]) --场景广播--改变坐骑 - 5960
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_FEATHER"]) -- [5922]场景广播-翅膀 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING"]) --场景广播--改变坐骑 - 5960
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANG_GUIDE"]) -- [5996]场景广播-新手指导员 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANG_MEIREN"])-- [5992]场景广播-美人 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_WAR_PLAYER_WAR"]) --[6010]战斗数据块
        
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANG_UNAME"])-- [5997]场景广播-改名 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_IS_OVER"])    -- [40565]是否已经阵亡 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHECK_DEATH"])-- [5630]切换场景前检查人物是否死亡 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_LINGYAO_ARENA_BATTLE_REPLY"])-- (25032手动) -- [25032]挑战返回 -- 灵妖竞技场 
        
    elseif _sceneType == __Const.CONST_MAP_TYPE_COPY_NORMAL or --普通副本
        _sceneType == __Const.CONST_MAP_TYPE_COPY_HERO  or  --精英副本
        _sceneType == __Const.CONST_MAP_TYPE_COPY_FIEND or
        _sceneType == __Const.CONST_MAP_TYPE_COPY_FIGHTERS or --魔王副本
        _sceneType == __Const.CONST_MAP_TYPE_COPY_ROAD or  -- 降魔之路 
        _sceneType == __Const.CONST_MAP_CLAN_DEF_TIME2 then  -- 道劫
        
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_OVER"]) --场景目标完成 - 7790 --下层副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_OVER"]) -- [7800]副本完成 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_FAIL"]) -- [7810]副本失败 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_TIME"]) -- [7060]场景时间同步(生存,限时类型) -- 副本
        table.insert(self.protocolsList,__Msg["ACK_FIGHTERS_NEXT_COPY_ID"]) -- [55840]下一层副本ID -- 拳皇生涯 
        table.insert(self.protocolsList,__Msg["ACK_COPY_STRONG_STATE"]) -- [7130]功能开放状态 
        table.insert(self.protocolsList,__Msg["ACK_XMZL_PLAYER_INFO"])        -- [18080]进入副本信息 -- 降魔之路 

    elseif _sceneType == __Const.CONST_MAP_TYPE_COPY_MONEY then
        table.insert(self.protocolsList,__Msg["ACK_COPY_MONEY_OVER_REPLY"]) --挑战结束返回 - 51640 节日活动-金钱副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_OVER"]) --场景目标完成 - 7790 --下层副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_TIME"]) -- [7060]场景时间同步(生存,限时类型) -- 副本

    elseif _sceneType == __Const.CONST_MAP_TYPE_BOSS or  --世界BOSS
        _sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS  then   --门派Boss
        
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER"])   --场景怪物数据 - 5065
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MONSTER_DATA"])   --怪物数据(刷新) - 5070
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])           --离开场景 - 5110
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PACKAGE"])  -- (5005手动) -- [5005]场景[行走,扣血,技能]打包 -- 场景
        
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_SELF_HP"]) -- [37053]玩家当前血量 -- 世界BOSS
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_DPS"]) -- [37060]DPS排行 -- 世界BOSS
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_VIP_RMB"]) -- [37051]是否开启鼓舞 -- 世界BOSS
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_WAR_RS"]) -- [37090]返回结果 -- 世界BOSS  返回复活时间和需要多少钱
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_REVIVE_OK"]) -- [37120]复活成功 -- 世界BOSS
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_MAP_DATA"])--[37020]返回世界boss时间
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_BOSS_LEVEL"])--[37190]移除boss ACK_WORLD_BOSS_BOSS_LEVEL
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_RMB_USE"])--[37205]鼓舞消耗
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_UP_ATTR"])--[37210]加成属性      
        table.insert(self.protocolsList,__Msg["ACK_WAR_HP_REPLY"]) --[6110]血量更新返回
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_NOW_HP"]) --[37230]boss的当前血量
        table.insert(self.protocolsList,__Msg["ACK_COPY_BOSS_NOTICE"]) -- [7120]妖王来袭通知 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"])       -- 玩家|伙伴|怪物 血量更新 - 5190
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_WUDI"])     -- [5920]场景广播-无敌 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"]) -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"]) -- [5610]恢复血量(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WORLD_BOSS_POS"])  -- [5086]世界boss移动位置 -- 场景 
        

    elseif _sceneType == __Const.CONST_MAP_TYPE_CHALLENGEPANEL  then --竞技场
        
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PARTNER_LIST"])   -- [5052]地图伙伴列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_WAR_PK_LOSE"]) -- [6080]PK结束死亡广播 -- 战斗
        table.insert(self.protocolsList,__Msg["ACK_ARENA_WAR_REWARD"]) -- [23835]挑战奖励 -- 逐鹿台
        
        table.insert(self.protocolsList,__Msg["ACK_ESCORT_OVER_BACK"])--美人护送打劫结果返回
        table.insert(self.protocolsList,__Msg["ACK_MOIL_CAPTRUE_BACK"])-- [35045]抓捕返回 -- 苦工 
        table.insert(self.protocolsList,__Msg["ACK_STRIDE_STRIDE_WAR_RS"])-- [43640]跨服战返回 
        table.insert(self.protocolsList,__Msg["ACK_STRIDE_SUPERIOR_RS"])-- [43637]巅峰战返回 
        table.insert(self.protocolsList,__Msg["ACK_EXPEDIT_FINISH_MSG"])-- [12252]群雄争霸返回 
        table.insert(self.protocolsList,__Msg["ACK_FIGHTERS_HERO_OVER_REP"])-- [56080]英雄塔挑战结束返回 -- 拳皇生涯 
        table.insert(self.protocolsList,__Msg["ACK_HILL_FINISH_BACK"])-- [64205]挑战结果 -- 第一门派 
        table.insert(self.protocolsList,__Msg["ACK_FUTU_OVER_REP"])-- [22190]浮屠静修挑战结束返回

        table.insert(self.protocolsList,__Msg["ACK_WAR_SELF_ADD"])-- [6015]自身战斗属性加成
        
    elseif _sceneType == __Const.CONST_MAP_TYPE_KOF  then  --天下第一 手动
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])     -- [5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PARTNER_LIST"])    -- [5052]地图伙伴列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"])       -- 玩家|伙伴|怪物 血量更新 - 5190
        table.insert(self.protocolsList,__Msg["ACK_WAR_PK_LOSE"])           -- [6080]PK结束死亡广播 -- 战斗
        table.insert(self.protocolsList,__Msg["ACK_WAR_PK_TIME"])           -- [6061]PK时间
        table.insert(self.protocolsList,__Msg["ACK_WAR_PLAYER_WAR"])        -- [6061]PK时间
        table.insert(self.protocolsList,__Msg["ACK_WRESTLE_WAR_STATE"])     -- [54950]战斗结束结算
        table.insert(self.protocolsList,__Msg["ACK_TXDY_SUPER_WAR_REPLY"])  -- [55100]战斗结束结算2
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])             -- 离开场景 - 5110
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"]) -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"]) -- [5610]恢复血量(真元技能) -- 场景 

        -- table.insert(self.protocolsList,__Msg["ACK_WAR_PVP_TIME_BACK"])
        -- table.insert(self.protocolsList,__Msg["ACK_WAR_PVP_SKILL_BACK"])
        -- table.insert(self.protocolsList,__Msg["ACK_WAR_PVP_STATE_BACK"])
        
        if _G.IS_PVP_NEW_DDX then
            table.insert(self.protocolsList,__Msg["ACK_WAR_PVP_FRAME_MSG"])
        else
            table.insert(self.protocolsList,__Msg["ACK_WAR_SKILL"])             -- [6030]释放技能广播 -- 战斗
            table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])       -- 行走数据(地图广播) - 5090
        end

    elseif _sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then  --多人副本
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER"])    --场景怪物数据 - 5065
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MONSTER_DATA"])   --怪物数据(刷新) - 5070
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])     --行走数据(地图广播) - 5090
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])           --离开场景 - 5110
        -- table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"]) --玩家|伙伴|怪物 血量更新 - 5190
        table.insert(self.protocolsList,__Msg["ACK_WAR_SKILL"]) -- [6030]释放技能广播 -- 战斗
        table.insert(self.protocolsList,__Msg["ACK_COPY_IDX_MONSTER"]) -- [7925]刷出第几波怪
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WAR_STATE_REPLY"])
        table.insert(self.protocolsList,__Msg["ACK_WAR_HP_REPLY"]) --[6110]血量更新返回
        table.insert(self.protocolsList,__Msg["ACK_WAR_HP_REPLY2"]) --[6110]血量更新返回
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_OVER"]) --场景目标完成 - 7790 --下层副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_OVER"]) -- [7800]副本完成 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_FAIL"]) -- [7810]副本失败 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE_ALL"])   -- [5185]血量更新(统一扣血) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_COPY_BOSS_NOTICE"]) -- [7120]妖王来袭通知 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"]) -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"]) -- [5610]恢复血量(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_COPY_TIME_UPDATE"]) -- [7050]时间同步 -- 副本 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHECK_DEATH"])-- [5630]切换场景前检查人物是否死亡 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_TEAM_HIRE"])    -- [5700]组队副本雇佣玩家 -- 场景 
        
    elseif _sceneType == __Const.CONST_MAP_CLAN_DEFENSE then  --门派守卫战
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER"])   --场景怪物数据 - 5065
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MONSTER_DATA"])   --怪物数据(刷新) - 5070
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])     --行走数据(地图广播) - 5090
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])           --离开场景 - 5110
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"]) --玩家|伙伴|怪物 血量更新 - 5190
        table.insert(self.protocolsList,__Msg["ACK_WAR_SKILL"]) -- [6030]释放技能广播 -- 战斗
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_INTER"])         --[63820]活动开始结束时间
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_SELF_HP"])       --[63840]自己当前血量
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_COMBAT_INFOR"])  --[64000]雕像血量
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_OVER"])          --[63990]结算
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_SELF_KILL"])     --[63890]个人击杀
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_CEN_BO"])        --[63830]层次
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_DIED_STATE"])    --[63930]返回复活时间
        table.insert(self.protocolsList,__Msg["ACK_DEFENSE_RESURREC_OK"])   --[64040]门派守卫场景刷出第几波怪
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER2"])    --[5072]门派守卫场景刷出第几波怪
        table.insert(self.protocolsList,__Msg["ACK_SCENE_NEXT_GATE"])       --[5360]门派守卫场景刷出第几波怪
        table.insert(self.protocolsList,__Msg["ACK_SCENE_REFRESH_NEXT"])    --[5362]30秒后刷新下一层怪物
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHOOSE_DOOR"])     --[5365]请选择正确的传送门进入下一层
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_OVER"]) --场景目标完成 - 7790 --下层副本
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PACKAGE"])  -- (5005手动) -- [5005]场景[行走,扣血,技能]打包 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_WUDI"])     -- [5920]场景广播-无敌 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"]) -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"]) -- [5610]恢复血量(真元技能) -- 场景 
        
    elseif _sceneType == __Const.CONST_MAP_CLAN_WAR then
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER"])   --场景怪物数据 - 5065
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MONSTER_DATA"])   --怪物数据(刷新) - 5070
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])           --离开场景 - 5110
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PACKAGE"])  -- (5005手动) -- [5005]场景[行走,扣血,技能]打包 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])     --行走数据(地图广播) - 5090
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_TIME"])     -- [40525]返回门派战基本信息 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_ONCE"])     -- [40530]门派战个人信息 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_LIVE"])     -- (40535手动) -- [40535]帮排战况信息 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_WAR_START"])-- [40541]比赛开始 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_DIE"])      -- [40545]死亡/复活协议 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_REC_SUCCESS"]) -- [40546]复活成功 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_C_FINISH"]) -- (40550手动) -- [40550]初赛战果 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_SELF_HP"]) -- [40542]self血量校正 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_WUDI"])     -- [5920]场景广播-无敌 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"]) -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_GANG_WARFARE_IS_OVER"])    -- [40565]是否已经阵亡 -- 门派战 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"]) -- [5610]恢复血量(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE_ALL"])   -- [5185]血量更新(统一扣血) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"])       -- 玩家|伙伴|怪物 血量更新 - 5190
        
    elseif  _sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS then
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER"])   --场景怪物数据 - 5065
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MONSTER_DATA"])   --怪物数据(刷新) - 5070
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])           --离开场景 - 5110
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"])       -- 玩家|伙伴|怪物 血量更新 - 5190
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])     --行走数据(地图广播) - 5090
        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_WUDI"])     -- [5920]场景广播-无敌 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_MAP_DATA"])--[37020]返回世界boss时间
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_BOSS_LEVEL"])--[37190]移除boss ACK_WORLD_BOSS_BOSS_LEVEL
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_REVIVE_OK"]) -- [37120]复活成功 -- 世界BOSS
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_SELF_HP"])
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PACKAGE"])  -- (5005手动) -- [5005]场景[行走,扣血,技能]打包 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_PLAYER_DIE"])  -- (37240手动) -- [37240]玩家死亡 -- 世界BOSS 
        table.insert(self.protocolsList,__Msg["ACK_WORLD_BOSS_DPS"]) -- [37060]DPS排行 -- 世界BOSS
        table.insert(self.protocolsList,__Msg["ACK_WAR_HP_REPLY"]) --[6110]血量更新返回
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"]) -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_COPY_BOSS_NOTICE"]) -- [7120]妖王来袭通知 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"]) -- [5610]恢复血量(真元技能) -- 场景 
    elseif _sceneType == __Const.CONST_MAP_TYPE_THOUSAND then  --一骑当千
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_OVER"]) --场景目标完成 - 7790 --下层副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_OVER"]) -- [7800]副本完成 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_FAIL"]) -- [7810]副本失败 -- 副本
        table.insert(self.protocolsList,__Msg["ACK_COPY_SCENE_TIME2"]) -- [7065]场景时间同步(生存,限时类型) 
        table.insert(self.protocolsList,__Msg["ACK_THOUSAND_NEW_RECORD"]) -- [7060]场景时间同步(生存,限时类型) 

    elseif _sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then -- 秘宝活动
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PLAYER_LIST"])    --[5045]玩家信息列表 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_IDX_MONSTER"])   --场景怪物数据 - 5065
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MONSTER_DATA"])   --怪物数据(刷新) - 5070
        table.insert(self.protocolsList,__Msg["ACK_SCENE_OUT"])           --离开场景 - 5110
        table.insert(self.protocolsList,__Msg["ACK_SCENE_PACKAGE"])  -- (5005手动) -- [5005]场景[行走,扣血,技能]打包 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_MOVE_RECE"])     --行走数据(地图广播) - 5090

        table.insert(self.protocolsList,__Msg["ACK_SCENE_CHANGE_WUDI"])     -- [5920]场景广播-无敌 -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_RELIVE"])     -- [5600]玩家或灵妖复活(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_WING_HP"])         -- [5610]恢复血量(真元技能) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE_ALL"])   -- [5185]血量更新(统一扣血) -- 场景 
        table.insert(self.protocolsList,__Msg["ACK_SCENE_HP_UPDATE"])       -- 玩家|伙伴|怪物 血量更新 - 5190

        table.insert(self.protocolsList,__Msg["ACK_MIBAO_BOX_REPLY"])       -- [65350]箱子返回 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_BOX_DATA"])        -- [65355]箱子信息块 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_BOX_DISAPPEAR"])   -- [65360]箱子消失 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_GOODS_LIST"])      -- [65365]物品信息块 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_GOODS_ALL"])       -- [65370]所有物品掉落信息 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_GOODS_DISAPPEAR"]) -- [65380]物品消失 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_PLAYER_HP"])       -- [65385]玩家当前血量 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_PLAYER_DIE"])          -- [65390]玩家死亡 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_REVIVE_REPLY"])    -- [65405]玩家复活返回 -- 秘宝活动 
        table.insert(self.protocolsList,__Msg["ACK_MIBAO_BOX_REFRESH_TIME"])-- [65410]下一次箱子刷新时间 -- 秘宝活动 

    elseif _sceneType == __Const.CONST_MAP_TYPE_PK_LY then --灵妖竞技场
        table.insert(self.protocolsList,__Msg["ACK_LINGYAO_ARENA_OVER_REPLY"]) -- (25155手动) -- [25155]挑战完成返回 -- 灵妖竞技场 
    end
    
    if _sceneType~=__Const.CONST_MAP_TYPE_CITY then  --地图类型-城镇
        table.insert(self.protocolsList,__Msg["ACK_SCENE_GOODS_REPLY_NEW"])-- [5310]物品掉落返回 -- 场景
        table.insert(self.protocolsList,__Msg["ACK_SCENE_UP_ATTR"]) --[5340]加成属性(吃物品)
    end
    
    for _,value in pairs(self.protocolsList) do
        print(__Msg[value],"=",value)
    end

    self:regSelf()
end

StageMediator.commandsList={
    CKeyBoardCommand.TYPE,
    CFlyItemCommand.TYPE,
    CCharacterPropertyACKCommand.TYPE,  -- 查看其他玩家信息
}

function StageMediator.processCommand(self, _command)
    --接收自己客户端,然后发给服务器端 请求
    if _command:getType() == CKeyBoardCommand.TYPE then --手柄按钮
        print("********************************************************")
        print(" start joyStick " )
        local skillId   = _command.skillId
        -- local skillType = _command.skillType
        local isAttack  = _command.isAttack
        
        local temp_play=self.__stage:getMainPlayer()
        if temp_play:getHP() <=0 or temp_play.m_lpContainer==nil then
            print("玩家死亡 end joyStick " )
            print("********************************************************")
            return
        end
        
        self.__stage:startBattleAI()
        if isAttack==true then
            print("释放普通攻击技能")
            skillId=temp_play:getAttackSkillID()
        end
        -- temp_play:enableAI(false)
        print("CKeyBoardCommand.TYPE selected skillId=",skillId)
        if skillId~=nil and skillId~=0 then
            temp_play:useSkill(skillId)
        end
        
        print(" end joyStick " )
        print("********************************************************")
        return
    elseif _command:getType()==CFlyItemCommand.TYPE then --飞物品
        if self.__stage.m_lpPlay~=nil and self.__stage.m_lpPlay:getHP()>0 then
            self.__stage.m_lpPlay:onGetItem( _command:getData(), 0, 0 )
        end
    elseif _command:getType()==CCharacterPropertyACKCommand.TYPE then  -- 查看其他玩家信息
        self:openCharacterView(_command.data,_command.pageno)
    end
    
    return false
end

----------------------
function StageMediator.REQ_SCENE_REQ_PLAYERS_NEW( self, _otherData ) -- [5042]请求场景玩家列表(new) -- 场景
    local msg = REQ_SCENE_REQ_PLAYERS_NEW()
    _G.Network : send(msg)
end

function StageMediator.REQ_WAR_PK( self, _otherData ) -- [6050]邀请PK -- 战斗
    local msg = REQ_WAR_PK()
    msg : setArgs( _otherData.uid )
    _G.Network : send(msg)
end

function StageMediator.REQ_WAR_PK_CANCEL( self, _otherData ) -- [6055]取消邀请 -- 战斗
    local msg = REQ_WAR_PK_CANCEL()
    _G.Network : send(msg)
end

function StageMediator.ACK_SCENE_ENTER_OK( self, _ackMsg )--进入场景 5030
    local property=_G.GPropertyProxy : getMainPlay()
    local isTeam=_ackMsg.team_id~=0
    property:setTeamID(_ackMsg.team_id)
    property:setIsTeam(isTeam)
    
    if property:getWarPartner()~=nil then
        local partnerProperty=property:getWarPartner()
        if partnerProperty~=nil then
            partnerProperty:setTeamID(property.team_id)
            partnerProperty:setIsTeam(isTeam)
        end
    end
    
    print("组队情况 _ackMsg.team_id=",_ackMsg.team_id,"property.team_id=",property.team_id,"isTeam=",isTeam)
    GCLOG("StageMediator.ACK_SCENE_ENTER_OK map_id=%d",_ackMsg.map_id)
    
    self:gotoScene(_ackMsg.map_id,_ackMsg.pos_x,_ackMsg.pos_y,_ackMsg.hp_now,_ackMsg.hp_max)
end

function StageMediator.ACK_SCENE_PLAYER_LIST( self, _ackMsg ) --[5045]玩家信息列表 -- 场景
    if _G.GSystemProxy:isHideOrtherOpen() then
        print("StageMediator.ACK_SCENE_PLAYER_LIST  __Const.CONST_SYS_SET_SHOW_ROLE) == 1")
        if self.__stage.m_isCity then
            print("return m_isCity=true")
            return
        end
    end

    local scenesType=self.__stage.m_sceneType
    print("StageMediator.ACK_SCENE_PLAYER_LIST count=%d",#_ackMsg.data)
    if scenesType == __Const.CONST_MAP_TYPE_CLAN_BOSS
        or scenesType == __Const.CONST_MAP_TYPE_BOSS  then
        
        if _G.g_BattleView.m_isShield==true then
            print("return scenesType=%d",scenesType)
            return
        end
    elseif scenesType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        local i=0
        if self.__stage:getMainPlayer().m_nHP==0 then
            i=-1
        end
        _G.g_BattleView:addZuDuiCondition(self.__stage.m_lpUIContainer,_G.g_BattleView.m_conditionTimes,_ackMsg.count+_G.g_BattleView.m_condSurplusRoleNum+i)
    end
    
    for _,data in pairs( _ackMsg.data ) do
        self : ACK_SCENE_ROLE_DATA(data)
    end

    if self.__stage.m_isCity then
        self.__stage:autoHideCharacter()
    end
end

function StageMediator.ACK_SCENE_PARTNER_LIST( self, _ackMsg ) --场景怪物数据 - 5055
    print("_ackMsg.data count=",#_ackMsg.data)
    
    if _G.GSystemProxy:isHideOrtherOpen() then
        local scenesType = self.__stage:getScenesType()
        if scenesType == __Const.CONST_MAP_TYPE_CITY
            or scenesType == __Const.CONST_MAP_TYPE_CLAN_BOSS
            or scenesType == __Const.CONST_MAP_TYPE_BOSS then
            return
        end
    end
    for _,data in pairs( _ackMsg.data ) do
        print("StageMediator.ACK_SCENE_PARTNER_LIST  self:ACK_SCENE_PARTNER_DATA(data)")
        self:ACK_SCENE_PARTNER_DATA(data)
    end
end

function StageMediator.ACK_WRESTLE_WAR_STATE( self, _ackMsg )
    print( "进入场景：StageMediator.ACK_WRESTLE_WAR_STATE" )

    local uid = _ackMsg.uid
    if uid == nil then
        print("ERROR WAR_STATE场景  uid为空")
        return
    end
    if uid==_G.GPropertyProxy:getMainPlay().uid then
        _ackMsg.res = 0 
    else
        _ackMsg.res = 1
    end
    print( "ACK_WRESTLE_WAR_STATE,_ackMsg.state = ", _ackMsg.state )
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
     
end

function StageMediator.ACK_TXDY_SUPER_WAR_REPLY( self, _ackMsg )
    print( "进入场景：StageMediator.ACK_TXDY_SUPER_WAR_REPLY" )

    local uid = _ackMsg.uid
    if uid == nil then
        print("ERROR WAR_STATE场景  uid为空")
        return
    end
    if uid==_G.GPropertyProxy:getMainPlay().uid then
        _ackMsg.res = 0 
    else
        _ackMsg.res = 1
    end
    print( "ACK_TXDY_SUPER_WAR_REPLY,_ackMsg.state = ", _ackMsg.state )
    self.__stage:showPKResult(_ackMsg)
end

function StageMediator.ACK_SCENE_ROLE_DATA( self, _ackMsg ) --场景内玩家数据 5050
    print(" ACK_SCENE_ROLE_DATA 场景人物加载 START")
    
    local uid = _ackMsg.uid
    local characterType = _ackMsg.type
    if uid == nil then
        print("ERROR 下发场景内玩家数据  uid为空")
        return
    end
    -- print("uid=",uid,"role uid=",_G.GPropertyProxy : getMainPlay().uid)
    
    if uid==_G.GPropertyProxy:getMainPlay().uid then
        print("玩家自身发送")
        return
    end
    -- print("ACK_SCENE_ROLE_DATA2222",characterType,_ackMsg.skin_armor)
    
    local _sceneType=self.__stage:getScenesType()

    if _sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        --多人副本
        if _ackMsg.hp_now==0 then
            local bigHpViewData = {}

            bigHpViewData.szName=_ackMsg.name or ""
            bigHpViewData.characterType=__Const.CONST_PLAYER
            bigHpViewData.lv=_ackMsg.lv or 0
            bigHpViewData.characterId = _ackMsg.pro or 1
            bigHpViewData.left=true
            bigHpViewData.hp=_ackMsg.hp_now or 0
            bigHpViewData.maxHp=_ackMsg.hp_max or 0.1
            bigHpViewData.sp=200
            bigHpViewData.maxSp=200
            bigHpViewData.isSmall=true
            local bigHp = require("mod.map.UIBigHp")()

            local bigHpView = bigHp:layer(bigHpViewData)
            bigHpView:setTag(tonumber(_ackMsg.uid))
            _G.g_BattleView:addHpView(bigHp,bigHpView,bigHpViewData.left)
            _G.g_BattleView:conditionSubRole()
            return
        end
    elseif _sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS 
        or _sceneType == __Const.CONST_MAP_TYPE_BOSS
        or _sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS 
        or _sceneType == __Const.CONST_MAP_CLAN_DEFENSE
        or _sceneType == __Const.CONST_MAP_CLAN_WAR
        or _sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then

        local character = __CharacterManager:getCorpseByID(uid)
        if character ~= nil then
            character.m_isCorpse=nil
            character:releaseResource()
            __CharacterManager:removeCorpseByID(uid)
        end

    end

    local property = _G.GPropertyProxy:getOneByUid(uid, __Const.CONST_PLAYER )
    if property == nil then
        property=require("mod.support.Property")()
        property:setUid( uid )
        _G.GPropertyProxy:addOne( property ,__Const.CONST_PLAYER )
    else
        print("5050 已经存在同一个场景了")
        local temp_play=__CharacterManager:getPlayerByID(uid)
        if temp_play~=nil then
            temp_play.m_isCorpse=nil
            temp_play:removeWing()
            temp_play:releaseResource()
            __CharacterManager:remove(temp_play)
            temp_play=nil
        end
    end
    
    property : updateProperty( __Const.CONST_ATTR_VIP , _ackMsg.vip )
    property : setPro( _ackMsg.pro )
    property : setTeamID(_ackMsg.team_id )
    -- print("ACK_SCENE_ROLE_DATA222233333333  team_id=",_ackMsg.team_id,"  name=",_ackMsg.name,"  is_guide=",_ackMsg.is_guide )
    property : setClan(_ackMsg.clan)
    property : setClanName(_ackMsg.clan_name)
    property : setIs_guide(_ackMsg.is_guide)
    property : setTitle_msg(_ackMsg.title_msg)
    property : setWingSkin( _ackMsg.skin_wing)
    property : setSkinFeather( _ackMsg.skin_feather )
    
    local temp_play = CPlayer(__Const.CONST_PLAYER)
    local szName = _ackMsg.name
    local pro = _ackMsg.pro
    local lv = _ackMsg.lv
    local x = _ackMsg.pos_x
    local y = _ackMsg.pos_y
    local skinID = _ackMsg.skin_armor
    local hp = _ackMsg.hp_now
    local hpMax = _ackMsg.hp_max
    local clanId = _ackMsg.clan
    local clanName = _ackMsg.clan_name
    local _fashionSkinId=0
    local magicSkinId   =0
    local petSkinID = _ackMsg.skin_meiren--10901
    local mountTX   = _ackMsg.mount_tx
    if skinID==0 or skinID==nil then
        --CCMessageBox("服务器下发皮肤ID为0,过去找服务器","皮肤错误")
        print("codeError!!!! 服务器下发皮肤ID为0,过去找服务器")
        return
    end
    -- print("玩家坐骑id=%d",_ackMsg.skin_mount, _ackMsg.mount_tx)
    -- print("玩家美人id=%d",_ackMsg.skin_meiren)
    temp_play : setProperty(property)
    temp_play : playerInit(uid,szName,pro,lv,skinID,_ackMsg.skin_mount,_ackMsg.skin_wing,_fashionSkinId,magicSkinId, mountTX)
    temp_play : init(uid,szName,hpMax,hp,200,200,x,y,skinID)
    temp_play : setPetId(petSkinID)
    temp_play : resetNamePos()

    temp_play.canSubSp=function() return true end
    --jun 2014.04.30
    -- print("玩家神器数量=%d",_ackMsg.count2)
    
    self.__stage:addCharacter( temp_play )
    
    print("<<<<<StageMediator.ACK_SCENE_ROLE_DATA>>>>>")
    print("=====================================")
    print("UID->"..uid)
    print("Name->"..temp_play:getName())
    print("LV--->"..temp_play:getLv())
    print("("..temp_play:getLocationX()..","..temp_play:getLocationY()..")")
    print("=====================================")
    
    if _sceneType==__Const.CONST_MAP_TYPE_CITY then
        temp_play:initTouchSelf()
    elseif  _sceneType == __Const.CONST_MAP_TYPE_KOF then
        temp_play:addBigHpView(false)
        temp_play.isMonsterBoss=true
        self.__stage.m_counterWorker=temp_play
    elseif _sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        --多人副本
        temp_play:addBigHpView(true,true)

    elseif _sceneType == __Const.CONST_MAP_TYPE_BOSS or 
        _sceneType == __Const.CONST_MAP_TYPE_CLAN_BOSS or
        _sceneType == __Const.CONST_MAP_CLAN_DEFENSE then
        
        local mainPlay=_G.GPropertyProxy:getMainPlay()
        property:setTeamID( mainPlay:getTeamID() )
        -- print("mainPlay : getTeamID()=",mainPlay : getTeamID())
    elseif _sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS
        or _sceneType == __Const.CONST_MAP_TYPE_COPY_BOX then
        -- print("lua show _ackMsg.clan=",_ackMsg.clan)

        if _sceneType == __Const.CONST_MAP_TYPE_CITY_BOSS or self.__stage.m_isCanAttackOrther then
            if self.__stage.m_isFreeFight==true then
                property.team_id=_ackMsg.uid
            elseif _ackMsg.clan==0 then
                property.team_id=-1
            else
                property.team_id=_ackMsg.clan
            end
        else
            local mainPlay=_G.GPropertyProxy:getMainPlay()
            property:setTeamID( mainPlay:getTeamID() )
        end

    elseif _sceneType == __Const.CONST_MAP_CLAN_WAR then
        print("CONST_MAP_CLAN_WAR-->>setTeamID  ")
        if self.m_clanFight_startGame==true then
            --战斗开始
            print("CONST_MAP_CLAN_WAR-->>setTeamID  战斗开始=",_ackMsg.clan)
            property : setTeamID( _ackMsg.clan )
        else
            --战斗未开始
            local mainPlay = _G.GPropertyProxy : getMainPlay()
            property : setTeamID( mainPlay:getTeamID() )
            print("CONST_MAP_CLAN_WAR-->>setTeamID  战斗未开始=",mainPlay:getTeamID())
        end
    end
    
    print(" ACK_SCENE_ROLE_DATA 场景人物加载 END")
end


--更新伙伴的名字和颜色
function StageMediator.getPartnerXMLInfo( self, _partnerid)
    if _partnerid==nil then
        return nil
    end
    local partnerinfo = _G.Cfg.partner_init[_partnerid]
    return partnerinfo
end


function StageMediator.ACK_SCENE_PARTNER_DATA( self, _ackMsg ) -- [5055]地图伙伴数据 -- 场景
    print("StageMediator.ACK_SCENE_PARTNER_DATA===> _ackMsg.uid=",_ackMsg.uid,"_ackMsg.hp_now=",_ackMsg.hp_now,"_ackMsg.hp_max=",_ackMsg.hp_max)
    
    local partnerinfo=self:getPartnerXMLInfo(_ackMsg.partner_id)
    if partnerinfo==nil then
        CCMessageBox(_ackMsg.partner_id.."伙伴 partner_init_cnf没有数据","ERROR")
        return
    end
    
    local index=tostring( _ackMsg.uid )..tostring( _ackMsg.partner_idx )
    local property=_G.GPropertyProxy:getOneByUid( index, __Const.CONST_PARTNER )
    if property==nil then
        property=require("mod.support.Property")()
        property:setUid( _ackMsg.uid )
        property:setPartnerId( _ackMsg.partner_id )
        property:setPartner_idx(_ackMsg.partner_idx)
        property:updateProperty( __Const.CONST_ATTR_NAME,  partnerinfo.name)
        property:updateProperty( __Const.CONST_ATTR_NAME_COLOR,  partnerinfo.name_color)
        property:setSkinArmor( partnerinfo.skin)
        _G.GPropertyProxy:addOne( property, __Const.CONST_PARTNER )
    end
    property:updateProperty( __Const.CONST_ATTR_LV,  _ackMsg.lv )
    property:setStata( __Const.CONST_INN_STATA2 ) --出战状态
    property:updateProperty( __Const.CONST_ATTR_HP,  _ackMsg.hp_max )
    property:setTeamID(_ackMsg.team_id==0 and _ackMsg.uid or _ackMsg.team_id)
    
    local playerCharacter = __CharacterManager:getPlayerByID(_ackMsg.uid)
    if playerCharacter==nil or playerCharacter.m_lpContainer==nil then
        print("StageMediator.ACK_SCENE_PARTNER_DATA  playerCharacter==nil")
        return
    end
    local temp_partner =  __CharacterManager:getCharacterByTypeAndID(__Const.CONST_PARTNER,index)
    if temp_partner~=nil then
        temp_partner:setMaxHp( _ackMsg.hp_max )
        temp_partner:setHP( _ackMsg.hp_now )
        return
    end
    local characterPartner=CPartner(__Const.CONST_PARTNER)
    characterPartner.m_boss=playerCharacter
    characterPartner:partnerInit(property)
    characterPartner:setMaxHp( _ackMsg.hp_max )
    characterPartner:setHP( _ackMsg.hp_now )
    self.__stage:addCharacter( characterPartner )
    
    characterPartner:setAI(partnerinfo.ai)
    
    if self.__stage:getScenesType()==__Const.CONST_MAP_TYPE_KOF then
        characterPartner:addBigHpView(false,true)
    end
end

function StageMediator.ACK_SCENE_IDX_MONSTER( self, _ackMsg ) --场景怪物数据 - 5065
    local addMonsterObject = nil
    local addMonsterObjectRank = 0
    -- local hpNum = 1
    
    print("StageMediator.ACK_SCENE_IDX_MONSTER  count=%d",#_ackMsg.data)
    
    for k,monsterData in pairs(_ackMsg.data) do
        local temp_play = __CharacterManager:getCharacterByTypeAndID(__Const.CONST_MONSTER, monsterData.monster_mid)
        print("monsterData.monster_mid=",monsterData.monster_mid)
        if temp_play==nil or temp_play.m_lpContainer==nil then
            print("StageMediator.ACK_SCENE_IDX_MONSTER 不存在，创建")
            local monsterObject,monsterXmlProperty=_G.StageXMLManager:addOneMonster(
            monsterData.monster_mid,
            nil,
            monsterData.monster_id,
            monsterData.pos_x,
            monsterData.pos_y,
            monsterData.dir==0 and -1 or 1,
            monsterData.hp,
            monsterData.hp_max)
            
            if monsterObject~=nil and monsterXmlProperty~=nil then
                local rank=monsterXmlProperty.steps
                monsterObject:setMonsterRank( rank )
                
                --遇到更高级的boss
                if rank >= __Const.CONST_MONSTER_RANK_ELITE and addMonsterObjectRank < rank then
                    addMonsterObject=monsterObject
                    addMonsterObjectRank=rank
                end
                --世界boss
                if rank == __Const.CONST_OVER_BOSS then
                    self.__stage:setBoss(monsterObject)
                    self.__stage:setBossHp(monsterObject:getHP())
                end
                
                --通关boss  CONST_MONSTER_RANK_BOSS_SUPER
                if rank>__Const.CONST_MONSTER_RANK_BOSS_SUPER then
                    self.__stage.isBossBattle=true
                end
            end
            
        else
            print("StageMediator.ACK_SCENE_IDX_MONSTER 存在，不需要创建创建")
        end
    end
    
    if addMonsterObject ~= nil then
        addMonsterObject.isMonsterBoss=true
        addMonsterObject:addBigHpView(false)
    end
end


function StageMediator.ACK_SCENE_IDX_MONSTER2( self, _ackMsg ) --场景怪物数据 - 5065
    local addMonsterObject = nil
    local addMonsterObjectRank = 0
    print("StageMediator.ACK_SCENE_IDX_MONSTER  count=%d",#_ackMsg.msg_monster_data)
    for k,monsterData in pairs(_ackMsg.msg_monster_data) do
        local temp_play = __CharacterManager:getCharacterByTypeAndID(__Const.CONST_MONSTER, monsterData.monster_mid)
        print("monsterData.monster_mid=",monsterData.monster_mid)
        if temp_play==nil or temp_play.m_lpContainer==nil then
            print("StageMediator.ACK_SCENE_IDX_MONSTER 不存在，创建")
            local monsterObject,monsterXmlProperty=_G.StageXMLManager:addOneMonster2(
            monsterData.monster_mid,
            monsterData.monster_id,
            monsterData.pos_x,
            monsterData.pos_y,
            monsterData.dir==0 and -1 or 1,
            monsterData.hp,
            monsterData.hp_max,
            _ackMsg.snow,
            _ackMsg.lv)
            
            if monsterObject~=nil and monsterXmlProperty~=nil then
                local rank =monsterXmlProperty.steps
                monsterObject : setMonsterRank( rank )
                
                --遇到更高级的boss
                if rank >= __Const.CONST_MONSTER_RANK_ELITE and addMonsterObjectRank < rank then
                    addMonsterObject = monsterObject
                    addMonsterObjectRank = rank
                end
                --世界boss
                if rank == __Const.CONST_OVER_BOSS then
                    self.__stage:setBoss( monsterObject )
                    self.__stage:setBossHp( monsterObject:getHP())
                end
                
                --通关boss  CONST_MONSTER_RANK_BOSS_SUPER
                if rank>__Const.CONST_MONSTER_RANK_BOSS_SUPER then
                    self.__stage.isBossBattle=true
                end
            end
            
        else
            print("StageMediator.ACK_SCENE_IDX_MONSTER 存在，不需要创建创建")
        end
    end
    
    self.__stage:setClanDefensePower( _ackMsg.snow )
    
    if addMonsterObject ~= nil then
        addMonsterObject.isMonsterBoss=true
        addMonsterObject:addBigHpView(false)
    end
end

function StageMediator.ACK_SCENE_MONSTER_DATA( self, _ackMsg ) --怪物数据(刷新)--5070
    local characterMonster = __CharacterManager:getCharacterByTypeAndID( __Const.CONST_MONSTER, _ackMsg.monster_mid)
    if characterMonster == nil or characterMonster.m_lpContainer==nil then
        return
    end
    print("已经发送怪物刷新")
    characterMonster : setHP(_ackMsg.hp)
end

--行走数据(地图广播) - 5090
function StageMediator.ACK_SCENE_MOVE_RECE(self, _ackMsg)
    local uid = _ackMsg.uid
    local characterType = _ackMsg.type
    if characterType==__Const.CONST_PARTNER then
        uid=tostring(_ackMsg.owner_uid)..tostring(_ackMsg.uid)
    end
    -- print("StageMediator.ACK_SCENE_MOVE_RECE uid=",uid,"characterType=",characterType,"_ackMsg.pos_x=",_ackMsg.pos_x,"_ackMsg.pos_y=",_ackMsg.pos_y)
    
    if self.__stage.m_lpPlay~=nil and  uid==self.__stage.m_lpPlay.m_nID then
        -- print(" uid == self.__stage.m_lpPlay.m_nID   ACK_SCENE_MOVE_RECE self.__stage:getPlay():getID()=",uid)
        -- if self.__stage.m_sceneType~=__Const.CONST_MAP_TYPE_KOF then
            return
        -- end
    end
    
    local temp_play = __CharacterManager:getCharacterByTypeAndID(characterType,uid)
    if temp_play == nil or temp_play.m_lpContainer==nil then
        print("StageMediator.ACK_SCENE_MOVE_RECE  玩家不在")
        return
    end
    if __Const.CONST_MAP_MOVE_STOP==_ackMsg.move_type and not self.__stage.m_isCity then
        temp_play:cancelMove()
        temp_play:setLocationXY(_ackMsg.pos_x,_ackMsg.pos_y)
        if _ackMsg.dir>0 then
            temp_play : setMoveClipContainerScalex(1)
        elseif _ackMsg.dir==0 then
            temp_play : setMoveClipContainerScalex(-1)
        end
        print("stop StageMediator.ACK_SCENE_MOVE_RECE, characterType=%d ,uid=%d, x=%f,y=%f",characterType,uid,_ackMsg.pos_x,_ackMsg.pos_y)
        return
    end
    temp_play:setMovePos(cc.p(_ackMsg.pos_x,_ackMsg.pos_y),true)
end

function StageMediator.ACK_SCENE_SET_PLAYER_XY( self, _ackMsg ) --强设玩家坐标 - 5100
    local uid = _ackMsg.uid
    local temp_play = __CharacterManager:getPlayerByID(uid)
    if temp_play==nil or temp_play.m_lpContainer==nil then
        return
    end
    temp_play : setLocationXY( _ackMsg.pos_x, _ackMsg.pos_y )
end

function StageMediator.ACK_SCENE_OUT( self, _ackMsg ) --离开场景 - 5110
    local uid = _ackMsg.uid
    local characterType = _ackMsg.id_type

    print("StageMediator.ACK_SCENE_OUT uid=",uid,"characterType=",characterType)

    if characterType==__Const.CONST_PARTNER then
        uid = tostring(_ackMsg.owner_uid)..tostring(uid)
    end

    print("_ackMsg.out_type=",_ackMsg.out_type)
    
    if self.__stage.m_isCity then
        if self.__stage.m_lpPlay.m_nID==uid then
            print("StageMediator.ACK_SCENE_OUT self.__stage.m_lpPlay.m_nID==uid 删除玩家")
            return
        end
    elseif _ackMsg.out_type==__Const.CONST_MAP_OUT_NULL then
        print("StageMediator.ACK_SCENE_OUT   移除头像")
        _G.g_BattleView:removeHpView(uid)
    end
    
    local character=__CharacterManager:getCorpseByID(uid)
    if character ~= nil then
        character.m_isCorpse=nil
        character:releaseResource()
        __CharacterManager:removeCorpseByID(uid)
    end

    local temp_play=__CharacterManager:getCharacterByTypeAndID( characterType, uid )
    if temp_play==nil or temp_play.m_lpContainer==nil then
        print("StageMediator.ACK_SCENE_OUT   temp_play == nil")
        return
    end
    
    if characterType==__Const.CONST_PARTNER or characterType==__Const.CONST_MONSTER or _ackMsg.out_type==__Const.CONST_MAP_OUT_DIE then
        temp_play:setHP(0)
        if _ackMsg.out_type==__Const.CONST_MAP_OUT_DIE and self.__stage.m_sceneType==__Const.CONST_MAP_CLAN_WAR then
            temp_play.m_isCorpse=nil
            __CharacterManager:remove(temp_play)
            temp_play:releaseResource()
        end
        print("StageMediator.ACK_SCENE_OUT  找到了。设置了。。。")
    else
        if self.__stage.m_sceneType==__Const.CONST_MAP_TYPE_KOF then
            temp_play:removeWing()
            self.__stage:removeCharacter(temp_play)
            local list = _G.CharacterManager:getCharacter()
            for k,character in pairs(list) do
                if character.setAI then
                    character:setAI(0)
                end
            end
        end
        temp_play.m_isCorpse=nil
        __CharacterManager:remove(temp_play)
        temp_play:releaseResource()
        print("StageMediator.ACK_SCENE_OUT 删除玩家",_ackMsg.out_type,__Const.CONST_MAP_OUT_DIE)
        if self.__stage.m_sceneType==__Const.CONST_MAP_TYPE_KOF then
            self.__stage.m_counterWorker=nil
        end

    end
end

-- [5185]血量更新(统一扣血) -- 场景 
function StageMediator.ACK_SCENE_HP_UPDATE_ALL(self, _ackMsg)
    for _,data in pairs(_ackMsg.msg_xxx) do
        self:ACK_SCENE_HP_UPDATE(data)
    end
end

function StageMediator.ACK_SCENE_HP_UPDATE( self, _ackMsg ) --玩家|伙伴|怪物 血量更新 - 5190
    local uid = _ackMsg.uid
    local characterType = _ackMsg.type
    if characterType == __Const.CONST_PARTNER or characterType == __Const.CONST_TEAM_HIRE then
        uid = tostring( _ackMsg.uid )..tostring( _ackMsg.partner_id )
    end
    local temp_play = __CharacterManager:getCharacterByTypeAndID( characterType, uid )
    if temp_play == nil or temp_play.m_lpContainer==nil then
        print("temp_play == nil  ACK_SCENE_HP_UPDATE BACK",characterType, uid)
        return
    end
    if _ackMsg.hp_now==0 and characterType == __Const.CONST_TEAM_HIRE then
        _G.g_BattleView:conditionSubRole()
    end
    -- print("StageMediator.ACK_SCENE_HP_UPDATE _ackMsg.stata=",_ackMsg.stata)
    
    if characterType == __Const.CONST_DEFENSE then
        if __Const.CONST_WAR_DISPLAY_CRIT==_ackMsg.stata then
            temp_play:showCritHurtNumber(-_ackMsg.hp_now)
        else
            temp_play:showNormalHurtNumber(-_ackMsg.hp_now)
        end
    elseif characterType==__Const.CONST_GOODS_MONSTER then
        local crit_fix=__Const.CONST_WAR_DISPLAY_CRIT==_ackMsg.stata and true or false
        if _ackMsg.hp_now==0 then return end
        local hurtHP = temp_play:getHP()-_ackMsg.hp_now
        if hurtHP>0 then
            temp_play:addHP(-hurtHP,crit_fix)
        end
    else
        if _ackMsg.stata==__Const.CONST_WAR_DISPLAY_DODGE then
            print("StageMediator.ACK_SCENE_HP_UPDATE  躲避========>>>")
            temp_play:showdodge()
            return
        end
        if temp_play:isHaveBuff(__Const.CONST_BATTLE_BUFF_INVINCIBLE) then return end
        local crit_fix=__Const.CONST_WAR_DISPLAY_CRIT==_ackMsg.stata and true or false
        local hurtHP = temp_play:getHP() - _ackMsg.hp_now
        print("temp_play:getHP() - _ackMsg.hp_now",temp_play:getHP(), _ackMsg.hp_now)
        print("StageMediator.ACK_SCENE_HP_UPDATE========>>>  hurtHP=",hurtHP,",crit_fix=",crit_fix,"temp_playhp=",temp_play:getHP(),"_ackMsg.uid=",_ackMsg.uid)
        if temp_play.isMainPlay and _ackMsg.hp_now==0 and self.__stage.m_sceneType==__Const.CONST_MAP_CLAN_WAR then return end
        if hurtHP>0 then
            temp_play:addHP(-hurtHP,crit_fix)
        end
        local hurtSkillId=_G.g_SkillDataManager:getHskillId(_ackMsg.skill)
        temp_play:onHurt(hurtSkillId)
    end
end

function StageMediator.ACK_SCENE_TEAM_HIRE( self, _ackMsg ) --组队副本雇佣玩家 -- 场景  - 5700
    if _ackMsg.hp_now==0 then
        local bigHpViewData = {}

        bigHpViewData.szName=_ackMsg.name or ""
        bigHpViewData.characterType=__Const.CONST_TEAM_HIRE
        bigHpViewData.lv=_ackMsg.lv or 0
        bigHpViewData.characterId = _ackMsg.pro or 1
        bigHpViewData.left=true
        bigHpViewData.hp=_ackMsg.hp_now or 0
        bigHpViewData.maxHp=_ackMsg.hp_max or 0.1
        bigHpViewData.sp=200
        bigHpViewData.maxSp=200
        bigHpViewData.isSmall=true
        local bigHp = require("mod.map.UIBigHp")()

        local bigHpView = bigHp:layer(bigHpViewData)
        bigHpView:setTag(tonumber(_ackMsg.uid))
        _G.g_BattleView:addHpView(bigHp,bigHpView,bigHpViewData.left)
        _G.g_BattleView:conditionSubRole()
        return
    end

    local mainplay=_G.GPropertyProxy:getMainPlay()
    local teamID=mainplay:getTeamID()

    local property = require("mod.support.Property")()
    property : setUid( _ackMsg.uid_own )
    _G.GPropertyProxy : addOne( property, __Const.CONST_TEAM_HIRE )
    
    property : updateProperty( __Const.CONST_ATTR_NAME, _ackMsg.name )
    property : setPro( _ackMsg.pro )
    
    property : updateProperty( __Const.CONST_ATTR_LV,  _ackMsg.lv )
    property : updateProperty( __Const.CONST_ATTR_ARMOR, tonumber(_ackMsg.pro+10000) )
    property : updateProperty( __Const.CONST_ATTR_RANK, _ackMsg.rank )
    property : setTeamID(teamID)
    property : setSkinFeather( _ackMsg.skin_feather )
    
    --attr 角色基本属性块2002
    local attr = _ackMsg.attr
    if attr.is_data == true then
        property.attr : setIsData( attr.is_data )
        property : updateProperty( __Const.CONST_ATTR_SP ,attr.sp )
        property : updateProperty( __Const.CONST_ATTR_HP ,attr.hp )
        property : updateProperty( __Const.CONST_ATTR_STRONG_ATT ,attr.att )
        property : updateProperty( __Const.CONST_ATTR_STRONG_DEF ,attr.def )
        property : updateProperty( __Const.CONST_ATTR_DEFEND_DOWN ,attr.wreck )
        property : updateProperty( __Const.CONST_ATTR_HIT , attr.hit)
        property : updateProperty( __Const.CONST_ATTR_DODGE , attr.dod)
        property : updateProperty( __Const.CONST_ATTR_CRIT ,attr.crit )
        property : updateProperty( __Const.CONST_ATTR_RES_CRIT ,attr.crit_res )
        property : updateProperty( __Const.CONST_ATTR_BONUS ,attr.bonus )
        property : updateProperty( __Const.CONST_ATTR_REDUCTION ,attr.reduction )
    end

    local attr=property:getAttr()
    local Player=CPlayer(__Const.CONST_TEAM_HIRE)
    Player : setProperty(property)
    Player : playerInit( property:getUid().._ackMsg.uid, property:getName(), property:getPro(), property:getLv(), property :getSkinArmor(),nil, nil )
    local x,y = _ackMsg.pos_x,_ackMsg.pos_y

    Player : init( property:getUid().._ackMsg.uid , property:getName(), attr.hp, attr.hp, attr.sp, attr.sp, x,y, property :getSkinArmor() )
    Player : resetNamePos()
    
    Player : addBigHpView(true,true)
    -- Player : setType(__Const.CONST_PARTNER)
    self.__stage : addCharacter( Player )
    
    Player : setHP(_ackMsg.hp_now)
    Player : setAI(property:getAI())
    Player.m_isCorpse=true
    Player.m_boss=self.__stage.m_lpPlay
    property:setPartnerId(_ackMsg.uid)
    Player.m_partnerId=_ackMsg.uid
    property:setPartner_idx(_ackMsg.uid)

    local roleSkillData=property:getSkillData()
    roleSkillData.skill_study_list={}

    for k,v in pairs(_ackMsg.skill) do
        local singleSkillData = {
            equip_pos = k,
            skill_id  = v.skill_id,
            skill_lv  = v.skill_lv,
        }
        roleSkillData       : addEquipSkillData(singleSkillData)
        roleSkillData.skill_study_list[v.skill_id]=singleSkillData
    end

    Player.m_enableBroadcastSkill=true
    Player.m_enableBroadcastAttack=true
    Player.m_enableBroadcastMove=true    
    _G.g_BattleView:addZuDuiCondition(self.__stage.m_lpUIContainer,_G.g_BattleView.m_conditionTimes,_G.g_BattleView.m_condSurplusRoleNum+1)

end

function StageMediator.ACK_SCENE_CHANGE_WUQI(self,_ackMsg)
    print("ACK_SCENE_CHANGE_WUQI-------->>>",_ackMsg.uid,_ackMsg.lv)
    local uid = _ackMsg.uid
    local temp_play = __CharacterManager:getPlayerByID(uid)
    if temp_play == nil or temp_play.m_lpContainer==nil then
        return
    end

    if uid==_G.GPropertyProxy:getMainPlay().uid then
        _G.SpineManager.resetPlayerWeaponRes(_ackMsg.lv)
    end
    
    local property = temp_play:getProperty()
    if property~=nil then
        property:setSkinWeapon(_ackMsg.lv)
        temp_play:resetWeaponSkin()
    end
end

function StageMediator.ACK_SCENE_CHANGE_FEATHER(self,_ackMsg)
    print("ACK_SCENE_CHANGE_FEATHER-------->>>",_ackMsg.uid,_ackMsg.feather)
    local uid = _ackMsg.uid
    local temp_play = __CharacterManager:getPlayerByID(uid)
    if temp_play == nil or temp_play.m_lpContainer==nil then
        return
    end

    if uid==_G.GPropertyProxy:getMainPlay().uid then
        _G.SpineManager.resetPlayerFeatherRes(_ackMsg.feather)
    end
    
    local property = temp_play:getProperty()
    if property~=nil then
        property:setSkinFeather(_ackMsg.feather)
        temp_play:resetFeatherSkin()
    end
end

function StageMediator.ACK_SCENE_CHANGE_CLAN( self, _ackMsg ) --场景广播-社团 - 5930
    print("ACK_SCENE_CHANGE_CLAN-------->>>",_ackMsg.clan_id,_ackMsg.clan_name)
    local uid = _ackMsg.uid
    local temp_play = __CharacterManager:getPlayerByID(uid)
    if temp_play == nil or temp_play.m_lpContainer==nil then
        return
    end
    
    local property = temp_play:getProperty()
    if property~=nil then
        property:setClan(_ackMsg.clan_id)
        property:setClanName(_ackMsg.clan_name)
    end
    
    temp_play:setClanName()
end

function StageMediator.ACK_SCENE_CHANGE_MOUNT( self, _ackMsg ) --场景广播--改变坐骑 - 5960
    local uid=_ackMsg.uid
    local temp_play=__CharacterManager:getPlayerByID(uid)
    if temp_play==nil or temp_play.m_lpContainer==nil then
        return
    elseif uid==_G.GPropertyProxy:getMainPlay().uid then
        _G.GPropertyProxy:getMainPlay():setMountId(_ackMsg.mount)
        _G.GPropertyProxy:getMainPlay():setMountTexiao(_ackMsg.mount_tx)
        _G.GPropertyProxy:getMainPlay():setMountLv(_ackMsg.plies)
        _G.SpineManager.resetPlayerMountRes(_ackMsg.mount)
    end
    print( "特效存在：", _ackMsg.mount_tx )
    temp_play:setMountSkinId( _ackMsg.mount, _ackMsg.mount_tx )
end
function StageMediator.ACK_SCENE_WORLD_BOSS_POS( self, _ackMsg )  -- [5086]世界boss移动位置 -- 场景 
    
    local lpCharacter=__CharacterManager:getCharacterByTypeAndID(__Const.CONST_MONSTER,_ackMsg.m_id)
    if lpCharacter~=nil then
        if _ackMsg.hide==2 then
            lpCharacter:hideMonster(_ackMsg.pos)
        -- else
        --     lpCharacter:showMonster(_ackMsg.pos)
        end
    end
end

function StageMediator.ACK_SCENE_WING_RELIVE(self, _ackMsg) -- [5600]玩家或灵妖复活(真元技能) -- 场景
    local ptype=_ackMsg.type
    local uid
    if ptype==__Const.CONST_PLAYER then
        uid=_ackMsg.uid
    else
        uid=_ackMsg.uid.._ackMsg.partner_id
    end
    local play=__CharacterManager:getCharacterByTypeAndID(ptype, uid)
    if play~=nil then
        play:reborn(_ackMsg.hp)
    end
    -- local property=_G.GPropertyProxy:getOneByUid(uid,__Const.CONST_PLAYER)
end
function StageMediator.ACK_SCENE_WING_HP(self, _ackMsg) -- [5610]玩家或灵妖复活(真元技能) -- 场景
    local ptype=_ackMsg.type
    local uid
    if ptype==__Const.CONST_PLAYER then
        uid=_ackMsg.uid
    else
        uid=_ackMsg.uid.._ackMsg.partner_id
    end
    local play=__CharacterManager:getCharacterByTypeAndID(ptype, uid)
    local hurtHP = play:getHP() - _ackMsg.hp
    play:addHP(-hurtHP,nil,true)
    -- local property=_G.GPropertyProxy:getOneByUid(uid,__Const.CONST_PLAYER)
end
function StageMediator.ACK_SCENE_CHECK_DEATH(self, _ackMsg)-- [5630]切换场景前检查人物是否死亡 -- 场景 
    if _ackMsg.flag==1 then
        local property = _G.GPropertyProxy:getMainPlay()
        if property~=nil then
            property.m_isDead=true
        end
    end
end
function StageMediator.ACK_SCENE_CHANGE_WUDI(self, _ackMsg)
    local uid = _ackMsg.uid
    local temp_play=__CharacterManager:getPlayerByID(uid)
    if temp_play==nil or temp_play.m_lpContainer==nil then
        return
    end
    if _ackMsg.state == 1 then
        local invBuff= _G.GBuffManager:getBuffNewObject(410, 0)
        temp_play:addBuff(invBuff)
    else
        temp_play:removeBuff(__Const.CONST_BATTLE_BUFF_INVINCIBLE)
    end
end

function StageMediator.ACK_GANG_WARFARE_IS_OVER(self, _ackMsg)
    if _ackMsg.state==1 then
        local property = _G.GPropertyProxy:getMainPlay()
        property.soulStatus=true
        -- local selfPlayCharacter = self.__stage:getMainPlayer()
        -- if selfPlayCharacter~=nil then
        --     selfPlayCharacter:showSoul()
        -- end
    end
end

function StageMediator.ACK_SCENE_WING( self, _ackMsg ) --场景广播--改变宠物 
    local uid=_ackMsg.uid
    local temp_play=__CharacterManager:getPlayerByID(uid)
    if temp_play==nil or temp_play.m_lpContainer==nil then
        return
    elseif uid==_G.GPropertyProxy:getMainPlay().uid then
        local player=_G.GPropertyProxy:getMainPlay()
        temp_play:setWingSkinId(_ackMsg.wing)
        player:setWingSkin(_ackMsg.wing)
        player:setWingLv(_ackMsg.plies)
        self.__stage.m_lpPlay:showStarSkill()
        return
    end
    temp_play:setWingSkinId(_ackMsg.wing)
end

function StageMediator.ACK_SCENE_CHANG_UNAME( self, _ackMsg ) -- [5997]场景广播-改名 -- 场景 
    local uid  = _ackMsg.uid
    local name = _ackMsg.uname
    local tempPlayer=__CharacterManager:getPlayerByID(uid)
    print("广播改名字===",uid,name,tempPlayer)
    if tempPlayer~=nil or tempPlayer.m_lpContainer==nil then
        tempPlayer:setNameString(name)
    end
end 

function StageMediator.ACK_SCENE_CHANG_MEIREN( self, _ackMsg ) -- [5994]场景广播-美人 -- 场景
    print("美人场景广播11111",_ackMsg.uid, _ackMsg.skin_id )
    local uid=_ackMsg.uid
    local temp_play=__CharacterManager:getPlayerByID(uid)
    if temp_play==nil or temp_play.m_lpContainer==nil then
        return
    end
    print("美人场景广播2222")
    if uid==_G.GPropertyProxy:getMainPlay().uid then
        print("美人场景广播2222",_G.GPropertyProxy:getMainPlay():getMeirenId())
        _G.GPropertyProxy:getMainPlay():setMeirenId(_ackMsg.skin_id)
    end
    temp_play:setPetId(_ackMsg.skin_id)
end

function StageMediator.ACK_SCENE_CHANG_GUIDE( self, _ackMsg ) -- [5996]场景广播-新手指导员 -- 场景 
    local uid=_ackMsg.uid
    local property=_G.GPropertyProxy:getOneByUid(uid,__Const.CONST_PLAYER)
    if property==nil then
        return
    end
    property:setIs_guide(_ackMsg.is_guide)
    local temp_play=__CharacterManager:getPlayerByID(uid)
    if temp_play==nil or temp_play.m_lpContainer==nil then
        return
    end
    temp_play:setTitleSpr()
end

function StageMediator.ACK_WAR_PK_LOSE( self, _ackMsg ) -- [6080]PK结束死亡广播 -- 战斗
    local property=_G.GPropertyProxy:getMainPlay()
    local uid=property:getUid()
    _ackMsg.res=1
    if uid==_ackMsg.uid then
        _ackMsg.res=0
    end
    print("StageMediator.ACK_WAR_PK_LOSE uid=",uid,"_ackMsg.uid=",_ackMsg.uid,"_ackMsg.res=",_ackMsg.res)
    
    self.__stage:showPKResult(_ackMsg)
end

function StageMediator.ACK_COPY_BOSS_NOTICE( self, _ackMsg )  -- [7120]妖王来袭通知 -- 副本
    _G.g_BattleView:addBossWaring(self.__stage.m_lpUIContainer)
end

function StageMediator.ACK_COPY_SCENE_OVER( self, _ackMsg )  --场景目标完成 - 7790 --下层副本
    local function waitingFunc()
        self.__stage:finishOneSceneInCopy()
    end
    _G.Scheduler:performWithDelay(__Const.CONST_FIGHTERS_DOOR_DELAY_TIME,waitingFunc)
end

function StageMediator.ACK_COPY_TIME_UPDATE( self, _ackMsg ) -- [7050]时间同步 -- 副本 
    self.__stage.m_battleViw:addZuDuiCondition(self.__stage.m_lpUIContainer,_ackMsg.time*1000,1)
end

-- [7800]副本完成 -- 副本
function StageMediator.ACK_COPY_OVER( self, _ackMsg )
    local view
    if self.__stage.m_sceneType==__Const.CONST_MAP_TYPE_COPY_ROAD then
        local tempMsg={}
        for i=1,_ackMsg.count do
            tempMsg.res=1
            tempMsg[i*2-1] = _ackMsg.data[i].goods_id
            tempMsg[i*2] = _ackMsg.data[i].count
        end
        view=require("mod.map.UIBattleResult")(tempMsg)
    else
        view=require("mod.map.UICopyPass")(_ackMsg)
    end
    local layer=view:create()
    self.__stage:addMessageView(layer)
end

-- [7810]副本失败 -- 副本
function StageMediator.ACK_COPY_FAIL( self, _ackMsg )
    self.__stage:failWar()
end

-- [7060]场景时间同步(生存,限时类型) -- 副本
function StageMediator.ACK_COPY_SCENE_TIME( self, _ackMsg )
    local remainingTime=_ackMsg.time-_G.TimeUtil:getServerTimeSeconds()
    print("lua show StageMediator.ACK_COPY_SCENE_TIME=========>>> remainingTime=",remainingTime)
    
    self.__stage:setRemainingTime(remainingTime,"剩余时间")
end

-- [6010]战斗数据块
function StageMediator.ACK_WAR_PLAYER_WAR(self, _ackMsg)
    local uid = _ackMsg.uid
    local property = _G.GPropertyProxy : getOneByUid( uid, __Const.CONST_PLAYER )
    if property == nil then
        property = require("mod.support.Property")()
        property : setUid( uid )
        _G.GPropertyProxy : addOne( property, __Const.CONST_PLAYER )
    end

    print("ACK_WAR_PLAYER_WAR=====>>>")
    for k,v in pairs(_ackMsg) do
        print(k,v)
    end
    
    property : updateProperty( __Const.CONST_ATTR_NAME, _ackMsg.name )
    property : setPro( _ackMsg.pro )
    property : setSex( _ackMsg.sex )
    property : setWingSkin(_ackMsg.wid)
    property : setWingLv(_ackMsg.wgrade)
    
    property : updateProperty( __Const.CONST_ATTR_LV,  _ackMsg.lv )
    property : updateProperty( __Const.CONST_ATTR_WEAPON, _ackMsg.skin_weapon )
    property : updateProperty( __Const.CONST_ATTR_ARMOR, _ackMsg.skin_armor )
    property : updateProperty( __Const.CONST_ATTR_RANK, _ackMsg.rank )
    
    --attr 角色基本属性块2002
    local attr = _ackMsg.attr
    if attr.is_data == true then
        property.attr : setIsData( attr.is_data )
        property : updateProperty( __Const.CONST_ATTR_SP ,attr.sp )
        property : updateProperty( __Const.CONST_ATTR_HP ,attr.hp )
        property : updateProperty( __Const.CONST_ATTR_STRONG_ATT ,attr.att )
        property : updateProperty( __Const.CONST_ATTR_STRONG_DEF ,attr.def )
        property : updateProperty( __Const.CONST_ATTR_DEFEND_DOWN ,attr.wreck )
        property : updateProperty( __Const.CONST_ATTR_HIT , attr.hit)
        property : updateProperty( __Const.CONST_ATTR_DODGE , attr.dod)
        property : updateProperty( __Const.CONST_ATTR_CRIT ,attr.crit )
        property : updateProperty( __Const.CONST_ATTR_RES_CRIT ,attr.crit_res )
        property : updateProperty( __Const.CONST_ATTR_BONUS ,attr.bonus )
        property : updateProperty( __Const.CONST_ATTR_REDUCTION ,attr.reduction )
    end
    local mainplay=_G.GPropertyProxy:getMainPlay()
    if mainplay~=nil then
        local teamID=mainplay:getTeamID()
        property:setTeamID(teamID+1086)
    end
    _G.GPropertyProxy:setChallengePanePlayInfo(property)
    
    
    local skillData = require("mod.support.SkillData")()
    local skillList = _ackMsg.skill_data
    for i=1,#skillList do
        local data=skillList[i]
        local singleSkillData={
            equip_pos =data.equip_pos,
            skill_id  =data.skill_id,
            skill_lv  =data.skill_lv
        }
        skillData:addEquipSkillData(singleSkillData)
    end
    property:setSkillData(skillData)
    
    for i=1,#_ackMsg.partner_data do
        _G.GPropertyProxy:mediatorFunction("ACK_ROLE_PARTNER_DATA",_ackMsg.partner_data[i])
    end
    
    local autoPKSceneId=_G.GPropertyProxy:getAutoPKSceneId()
    print("StageMediator.ACK_WAR_PLAYER_WAR  autoPKSceneId=",autoPKSceneId,self.__stage.m_sceneType,self.__stage.m_sceneId)
    
    if autoPKSceneId~=nil and self.__stage.m_sceneType~=__Const.CONST_MAP_TYPE_KOF then
        _G.GPropertyProxy:setAutoPKSceneId(nil)
        
        self:gotoScene(autoPKSceneId,nil,nil)
    end
end


-- [23835]挑战奖励 -- 逐鹿台
function StageMediator.ACK_ARENA_WAR_REWARD( self, _ackMsg )
    print("挑战奖励 -- 逐鹿台 StageMediator.ACK_ARENA_WAR_REWARD ",_ackMsg.rmb_band)
    if self.__stage.m_isCity then
        return
    end
    -- local res = _ackMsg.res
    -- local gold =_ackMsg.gold
    -- local renown = _ackMsg.renown --妖魂
    _ackMsg[1]="46200"
    _ackMsg[2]=_ackMsg.renown
    _ackMsg[3]="46000"
    _ackMsg[4]=_ackMsg.gold
    if _ackMsg.rmb_band>0 then
        _ackMsg[5]="46100"
        _ackMsg[6]=_ackMsg.rmb_band
    end
    
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
    
    self.__stage:removeKeyBoardAndJoyStick()
end

function StageMediator.ACK_ESCORT_OVER_BACK(self, ackMsg)   -- [60955]打劫结束返回 -- 押镖
    print("ACK_ESCORT_OVER_BACK 打劫结束返回 协议处理方法")

    local data = {}
    data.res   = ackMsg.type 
    
    data[1]="46200"
    data[2]=ackMsg.power 
    data[3]="46000"
    data[4]=ackMsg.gold
    
    local view=require("mod.map.UIBattleResult")(data)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_MOIL_CAPTRUE_BACK( self,ackMsg)
    local view=require("mod.map.UIBattleResult")(ackMsg)
    self.__stage:addMessageView(view:create())
end


-- [37053]自己的DPS伤害 -- 世界BOSS
function StageMediator.ACK_WORLD_BOSS_SELF_HP( self, _ackMsg )
    local selfPlayCharacter = self.__stage:getMainPlayer()
    
    -- if self.__stage:getScenesType() == __Const.CONST_MAP_TYPE_CITY_BOSS then
    --     selfPlayCharacter:setMaxHp(_ackMsg.hp)
    -- end
    if selfPlayCharacter.m_nHP==0 and _ackMsg.hp~=0 then
        self:ACK_WORLD_BOSS_REVIVE_OK()
    else
        selfPlayCharacter:setHP(_ackMsg.hp or 0,true)
    end
end

-- [37060]DPS排行 -- 世界BOSS
function StageMediator.ACK_WORLD_BOSS_DPS( self, _ackMsg )
    _G.g_BattleView:updateDps(_ackMsg)
end

-- [37051]是否开启鼓舞 -- 世界BOSS
function StageMediator.ACK_WORLD_BOSS_VIP_RMB( self, _ackMsg )
    self.__stage:setBossVipRmb(true)
end

-- [37090]返回结果 -- 世界BOSS  返回复活时间和需要多少钱
function StageMediator.ACK_WORLD_BOSS_WAR_RS( self, _ackMsg )
    _G.g_BattleView:showBossDeadView(_ackMsg.rmb)
    self.__stage:setBossDeadTime(_ackMsg.time)
    
    print("StageMediator.ACK_WORLD_BOSS_WAR_RS  _ackMsg.time=",_ackMsg.time,_ackMsg.rmb)
    
    local selfPlayCharacter=self.__stage:getMainPlayer()
    selfPlayCharacter:setHP(0)
    self.__stage:removeKeyBoardAndJoyStick()
end

-- [37120]复活成功 -- 世界BOSS
function StageMediator.ACK_WORLD_BOSS_REVIVE_OK( self, _ackMsg )
    print("1StageMediator.ACK_WORLD_BOSS_REVIVE_OK")
    
    _G.g_BattleView:hideBossDeadView()
    
    print("2StageMediator.ACK_WORLD_BOSS_REVIVE_OK")
    self.__stage:setBossDeadTime(nil)
    if _G.g_lpMainPlay:getHP()>0 then
        return
    end
    if self.__stage~=nil then
        self.__stage:removeCharacter(_G.g_lpMainPlay)
    end
    local property = _G.GPropertyProxy:getMainPlay()
    local uid = property:getUid()
    local name = property:getName()
    local pro = property:getPro()
    local hp = property:getAttr():getHp()
    local sp = property:getAttr():getSp()
    local lv = property:getLv()
    local skinId = property:getSkinArmor()
    local windId = property:getWingSkin()
    -- local locationX = _G.g_lpMainPlay:getLocationX()
    -- local locationY = _G.g_lpMainPlay:getLocationY()
    
    local myPlayer = CPlayer(__Const.CONST_PLAYER)
    _G.g_lpMainPlay = nil
    _G.g_lpMainPlay = myPlayer

    local character = __CharacterManager:getCorpseByID(uid)
    if character ~= nil then
        character.m_isCorpse=nil
        character:releaseResource()
        character:removeWing()
        __CharacterManager:removeCorpseByID(uid)
    end

    myPlayer.isMainPlay=true
    myPlayer:setProperty(property)
    myPlayer:playerInit( uid, name, pro, lv, skinId,nil,windId )

    local x = self.__stage:getMaplx() + 50
    local y = 100
    if _ackMsg~=nil then
        x=_ackMsg.pos_x
        y=_ackMsg.pos_y
    end
    if  self.__stage:getScenesType() == __Const.CONST_MAP_CLAN_DEFENSE then
        x= 1000
        y=200
    elseif self.__stage:getScenesType() == __Const.CONST_MAP_TYPE_CITY_BOSS then
        hp = hp * __Const.CONST_BATTLE_CITY_BOSS_HP
    elseif self.__stage:getScenesType() == __Const.CONST_MAP_CLAN_WAR then
        hp = hp * __Const.CONST_GANG_WARFARE_HP_ADD
    elseif self.__stage:getScenesType() == __Const.CONST_MAP_TYPE_COPY_BOX then
        hp = hp * __Const.CONST_BATTLE_MIBAO_BOSS_HP
    end
    myPlayer:init( uid , name, hp, hp, sp, sp, x, y, skinId )
    myPlayer:resetNamePos()
    
    self.__stage:addCharacter( myPlayer )
    self.__stage.m_lpPlay=myPlayer

    myPlayer:addBigHpView()
    local invBuff= _G.GBuffManager:getBuffNewObject(410, 0)
    myPlayer:addBuff(invBuff)
    self.__stage:addKeyBoard()
    self.__stage:addJoyStick()
    self.__stage:moveArea( x, y, nil, 1)
    -- self.__stage:loadFarMap(1)
    -- self.__stage:loadNearMap(1)
    
    
    if self.__stage.isAutoFightMode==true then
        self.__stage.m_lpPlay:enableAI(true)
        self.__stage:startAutoFight()
    end
    
    if self.__stage:isMultiStage() then
        
        myPlayer.m_enableBroadcastSkill=true
        myPlayer.m_enableBroadcastAttack=true
        myPlayer.m_enableBroadcastMove=true
        
        _G.SkillHurt.isNeedBroadcastHurt=true
        
        if property.soulStatus==true then
            myPlayer:removeBuff(__Const.CONST_BATTLE_BUFF_INVINCIBLE)
            myPlayer:showSoul()
        end
    end
    print("3StageMediator.ACK_WORLD_BOSS_REVIVE_OK")
end
----------------------------------------------------------------
function StageMediator.ACK_DEFENSE_INTER( self, _ackMsg )
    self.__stage.m_battleEndTime=_ackMsg.end_time
    
    if _ackMsg.is_start~=1 then
        local remainingStartTime = _ackMsg.start_time-_G.TimeUtil:getServerTimeSeconds()
        self.__stage:setRemainingTime(remainingStartTime,"准备时间倒计时")
    else
        local remainingBattleTime = _ackMsg.end_time-_G.TimeUtil:getServerTimeSeconds()
        self.__stage:setRemainingTime(remainingBattleTime,"结束时间倒计时")
    end
    print("收到 守卫战时间")
end

function StageMediator.ACK_DEFENSE_SELF_HP( self, _ackMsg )
    print("收到 守卫战 自己的 血量", _ackMsg.hp)
    local selfPlayCharacter = self.__stage:getMainPlayer()
    selfPlayCharacter : setHP( _ackMsg.hp or 0 )
end

function StageMediator.ACK_DEFENSE_COMBAT_INFOR( self, _ackMsg )
    self.__stage:setClanDefenseHp(_ackMsg)
--     print("收到 塔防BOSS的血量")
end

function StageMediator.ACK_DEFENSE_OVER( self, _ackMsg )
    -- 百鬼夜行坛 结算
    self.__stage:setGameOver(_ackMsg)
end

function StageMediator.ACK_DEFENSE_SELF_KILL( self, _ackMsg )
    self.__stage:setClanDefensekill( _ackMsg )
    print("收到 守卫战 自己的 击杀 数量")
end

function StageMediator.ACK_DEFENSE_CEN_BO( self, _ackMsg )
    self.__stage:setClanCenci( _ackMsg )
end

function StageMediator.ACK_SCENE_NEXT_GATE( self, _ackMsg )
    self.__stage:setClanDefenseLog( _ackMsg.boci, _ackMsg.time )
    print("收到 守卫战 下波 刷怪 提示")
end

function StageMediator.ACK_SCENE_REFRESH_NEXT( self )
    self.__stage:setNextDefenseLog()
end

function StageMediator.ACK_SCENE_CHOOSE_DOOR( self )
    self.__stage:setNextCengDefenseLog()
end

function StageMediator.ACK_DEFENSE_DIED_STATE( self, _ackMsg )
    if _ackMsg.type == 0 then
        return
    elseif _ackMsg.type == 1 then
        _G.g_BattleView:DefEnseDeadView()
        self.__stage:setBossDeadTime(_ackMsg.time)
        
        print("StageMediator.ACK_WORLD_BOSS_WAR_RS  _ackMsg.time=",_ackMsg.time)
        
        local selfPlayCharacter = self.__stage:getMainPlayer()
        selfPlayCharacter:setHP(0)
        self.__stage:removeKeyBoardAndJoyStick()
    end
    
    print("收到 守卫战 自己的 复活时间")
    -- body
end

function StageMediator.ACK_DEFENSE_RESURREC_OK( self, _ackMsg )
    -- local selfPlayCharacter = self.__stage:getMainPlayer()
    -- selfPlayCharacter:setHP(0)
    -- self.ACK_WORLD_BOSS_REVIVE_OK( _ackMsg )
    _G.g_BattleView:hideBossDeadView()
    self:ACK_WORLD_BOSS_REVIVE_OK()
    -- if _G.g_BattleView~=nil then
    --     _G.g_BattleView:removeClanFight_dieTips(true)
    -- end
end

-----------------------------------------------------------------

-- [1012]断线重连返回 -- 角色
function StageMediator.ACK_ROLE_LOGIN_AG_ERR(self, _ackMsg)
    if self.__stage.sendMsg~=nil then
        _G.Network:send(self.__stage.sendMsg)
    end
    local taskMsg=REQ_TASK_REQUEST_LIST()
    _G.Network:send(taskMsg)
    if self.__stage.m_sceneType==__Const.CONST_MAP_CLAN_DEFENSE then
        local msg = REQ_SCENE_ENTER_FLY()
        msg : setArgs( self.__stage.m_sceneId )
        _G.Network : send( msg )
    end
end

-- [6030]释放技能广播 -- 战斗
function StageMediator.ACK_WAR_SKILL( self, _ackMsg )
    local id = _ackMsg.id
    if _G.GPropertyProxy.m_lpMainPlay~=nil and id==_G.GPropertyProxy.m_lpMainPlay.uid then
        print("lua show StageMediator.ACK_WAR_SKILL 玩家自己")
        if self.__stage.m_sceneType~=__Const.CONST_MAP_TYPE_KOF then
            return
        end
    end
    if _ackMsg.type==__Const.CONST_PARTNER then
        id = tostring(_ackMsg.uid)..tostring(id)
    end
    local lpCharacter=__CharacterManager:getCharacterByTypeAndID(_ackMsg.type,id)
    if lpCharacter==nil or lpCharacter.m_lpContainer==nil then
        print("lpCharacter == nil  StageMediator.ACK_WAR_SKILL id=",id,"_ackMsg.type=",_ackMsg.type ,"_ackMsg.skill_id=",_ackMsg.skill_id)
        return
    end
    print("StageMediator.ACK_WAR_SKILL id=",id,"_ackMsg.type=",_ackMsg.type,"_ackMsg.skill_id=",_ackMsg.skill_id,"_ackMsg.dir=",_ackMsg.dir)
    -- if self.__stage.m_sceneType == __Const.CONST_MAP_TYPE_COPY_MULTIPLAYER then
        
    --     if not lpCharacter.m_attackSkillDatas then
    --         lpCharacter:getAllAttackSkill()
    --     end


    --     local _collider=lpCharacter.m_attackSkillDatas[_ackMsg.skill_id].attackCollider
    --     if _collider==nil then
    --         return
    --     end
    --     for _,player in pairs(__CharacterManager.m_lpPlayerArray) do
    --         if __CharacterManager:checkColliderByCharacter(lpCharacter,_collider,player) == true then

    --             lpCharacter:useSkill(_ackMsg.skill_id)
    --             print("#######")
    --         end
    --     end
    --     return
    -- end
    -- if lpCharacter:getType()==__Const.CONST_MONSTER and self.__stage.m_sceneType==__Const.CONST_MAP_TYPE_BOSS then
    --     lpCharacter:hideMonster(_ackMsg.dir)
    -- else
        lpCharacter.m_netScalex=true
        if _ackMsg.dir==1 then
            lpCharacter.m_nextScalex=1
            -- lpCharacter:setMoveClipContainerScalex(1)
        elseif _ackMsg.dir==2 then
            lpCharacter.m_nextScalex=-1
            -- lpCharacter:setMoveClipContainerScalex(-1)
        end
        if _ackMsg.skill_id%1000==900 then
            lpCharacter.m_cutSkill=true
        end
        if lpCharacter:getType()==__Const.CONST_PLAYER then
            lpCharacter:setLocationXY(_ackMsg.pos_x,_ackMsg.pos_y)
        end
    -- end
    lpCharacter:useSkill(_ackMsg.skill_id,true)
end

--清除转场景的Mediator
function StageMediator.cleanStage( self )
    _G.controller:unMediators()
    
    _G.GUIGMView=nil
    _G.TipsUtil:clearLayer()

    _G.Scheduler:unAllschedule()
    if ScenesManger.isLoading then
        ScenesManger.isLoading=nil
        print("cleanStage,stop pre res loading!!!!!!!")
    end
end

function StageMediator.gotoScene( self,  _ScenesID, _x, _y, _hp, _maxHp )
    if self.m_isEnterNewScene then return end
    self.m_isEnterNewScene=true

    gcprint("\n \n \n \n")
    gcprint("***********************************************")
    gcprint("收到进入场景协议返回,正在处理....")

    -- if self.m_timeScheduler ~= nil then
    --     _G.Scheduler:unschedule(self.m_timeScheduler)
    --     self.m_timeScheduler = nil 
    -- end
    --获取场景数据
    self.sceneData=_G.StageXMLManager:getXMLScenes(_ScenesID)
    
    if self.sceneData==nil or self.sceneData.material_id==nil then
        CCMessageBox("进入场景meaterialID为空","Error")
        print("进入场景meaterialID为空")
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
        return
    end
    
    cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    local mgscommand = CGotoSceneCommand()
    _G.controller:sendCommand(mgscommand)
    self:cleanStage()
    
    self.lastScenesData={
        lastScenesType=self.__stage:getScenesType(),
        lastScenesId=self.__stage.m_sceneId
    }
    
    self.sceneId=_ScenesID
    self.playerX=_x
    self.playerY=_y
    
    -- gcprint("self.__stage:getScenesType()=",self.__stage:getScenesType())
    -- gcprint("self.__stage.m_sceneId=",self.__stage.m_sceneId)
    
    local function lFun()
        gcprint("处理新、旧场景的资源问题 zzZZzz...")
        self.loading=require("mod.map.StageLoading")()
    end
    self.__stage:delayFadeOutStageScene(lFun)
end

function StageMediator.openCharacterView(self,_data,_pageno)
    if self.__stage.m_sceneType==__Const.CONST_MAP_TYPE_CITY then
        print( "请求打开其他玩家 UID:",_data,"=====no====",_pageno,_G.GLayerManager.m_isRole)
        if _G.GLayerManager.m_isArtifact then
        	_G.GLayerManager:openSubLayer(__Const.CONST_FUNC_OPEN_ARTIFACT,false,_pageno,_data)
        elseif _G.GLayerManager.m_isRole then
            print("进入元魄")
            _G.GLayerManager:openSubLayer(__Const.CONST_FUNC_OPEN_ROLE,false,3,_data)
        else
            print("mei进入元魄")
        	_G.GLayerManager:openSubLayer(__Const.CONST_FUNC_OPEN_ROLE,false,_pageno,_data)
        end
    end
end

function StageMediator.finishGotScene(self,enterSceneData)
    gcprint("准备新的场景 zzZZzz...")
    
    local sceneData = _G.StageXMLManager:getXMLScenes( self.sceneId)
    local nowSceneType =sceneData.scene_type
    
    local isAction = true
    --逐鹿台弹出
    if self.lastScenesData.lastScenesType == __Const.CONST_MAP_TYPE_CHALLENGEPANEL then
        isAction=false
    elseif self.lastScenesData.lastScenesType == __Const.CONST_MAP_TYPE_KOF then
        --发信息给服务器。请求格斗之王
        isAction=false
        
    elseif nowSceneType == __Const.CONST_MAP_TYPE_CITY then
        if _G.g_isPassTower == true then
            _G.GPropertyProxy : resetMainPlayHp()
            isAction=false
            --弹开我要变强
        elseif _G.g_WoYaoBianQiang == true then
            isAction=false
        end
    end
    
    gcprint("清理上个场景数据 zzZZzz...")
    _G.GPropertyProxy:cleanUp()
    
    gcprint("创建新的场景 zzZZzz...")
    local newStage=require("mod.map.Stage")()
    _G.g_Stage=newStage
    self.__stage=newStage
    
    local newScenes=newStage:create()
    newScenes:retain()
    
    gcprint("初始化新的场景数据 zzZZzz...")
    -- 每次都要初始一次角色管理
    __CharacterManager:init() 
    newStage:init(self.sceneId,self.playerX,self.playerY,enterSceneData.mbg)
    newStage:addStageMediator()

    gcprint("数据展示:")
    gcprint("this-> sceneId=",self.sceneId)
    gcprint("this-> SceneType=",nowSceneType)
    gcprint("pre-> sceneId=",self.lastScenesData.lastScenesId)
    gcprint("pre-> SceneType=",self.lastScenesData.lastScenesType)

    enterSceneData.isAction=isAction
    enterSceneData.newScenes=newScenes
    enterSceneData.currentSceneType=nowSceneType
    enterSceneData.currentSceneId=self.sceneId
    enterSceneData.lastScenesType=self.lastScenesData.lastScenesType
    enterSceneData.lastScenesId=self.lastScenesData.lastScenesId
end

function StageMediator.enterStageScene(self,enterSceneData)
    gcprint("真正进入新场景,replaceScene新场景 zzZZzz...")

    cc.Director:getInstance():popToRootScene()
    cc.Director:getInstance():replaceScene( enterSceneData.newScenes )
    enterSceneData.newScenes:release()
    self.__stage:enterStageCallback(enterSceneData.currentSceneType,enterSceneData.currentSceneId,enterSceneData.lastScenesType,enterSceneData.lastScenesId)

    _G.Util:initLog()
end


function StageMediator.ACK_SCENE_GOODS_REPLY_NEW(self, _ackMsg)
    print("StageMediator.ACK_SCENE_GOODS_REPLY_NEW")
    print("_ackMsg.pos_x=",_ackMsg.pos_x,"_ackMsg.pos_y=",_ackMsg.pos_y,"_ackMsg.goods_id=",_ackMsg.goods_id,"_ackMsg.count=",_ackMsg.count)
    local goods=CGoods(__Const.CONST_GOODS)
    local uid=_G.UniqueID : getNewID()
    goods:init(uid,_ackMsg)
    -- self.__stage:addGoods(goods)
    self.__stage:addCharacter(goods)
    
    -- _G.Util:playAudioEffect("wealth_money")
end

-- [7925]刷出第几波怪
function StageMediator.ACK_COPY_IDX_MONSTER(self, _ackMsg)
    local addMonsterObject = nil
    local addMonsterObjectRank = 0
    -- local hpNum = 1
    
    for k,monsterData in pairs(_ackMsg.monster_datas) do
        
        local temp_play = __CharacterManager:getCharacterByTypeAndID(__Const.CONST_MONSTER, monsterData.monster_mid)
        print("monsterData.monster_mid=%d",monsterData.monster_mid)
        if temp_play==nil then
            print("StageMediator.ACK_COPY_IDX_MONSTER 不存在，创建")
            local monsterObject,monsterXmlProperty=_G.StageXMLManager:addOneMonster(
            monsterData.monster_mid,
            nil,
            monsterData.monster_id,
            monsterData.pos_x,
            monsterData.pos_y,
            monsterData.dir==0 and -1 or 1,
            monsterData.hp,
            monsterData.hp_max)
            
            if monsterObject~=nil and monsterXmlProperty~=nil then
                local rank =monsterXmlProperty.steps
                monsterObject : setMonsterRank( rank )
                
                --遇到更高级的boss
                if rank >= __Const.CONST_MONSTER_RANK_ELITE and addMonsterObjectRank < rank then
                    addMonsterObject = monsterObject
                    addMonsterObjectRank = rank
                    -- hpNum = monsterXmlProperty.says1
                end
                --世界boss
                if rank == __Const.CONST_OVER_BOSS then
                    self.__stage:setBoss( monsterObject )
                    self.__stage:setBossHp( monsterObject:getHP())
                end
                
                --通关boss  CONST_MONSTER_RANK_BOSS_SUPER
                if rank>__Const.CONST_MONSTER_RANK_BOSS_SUPER then
                    self.__stage.isBossBattle=true
                end
            end
            
        else
            print("StageMediator.ACK_COPY_IDX_MONSTER 存在，不需要创建创建")
        end
    end
    
    if addMonsterObject ~= nil then
        addMonsterObject:addBigHpView(false)
    end
end

function StageMediator.ACK_WORLD_BOSS_MAP_DATA(self, _ackMsg)
    print("开始时间：",_ackMsg.time)
    print("结束时间：",_ackMsg.stime)
    print("是否开始：",_ackMsg.is_start)
    
    print("_G.TimeUtil:getServerTimeSeconds()=",_G.TimeUtil:getServerTimeSeconds())
    
    self.__stage.m_battleEndTime=_ackMsg.stime
    
    if _ackMsg.is_start~=1 then
        local remainingStartTime = _ackMsg.time-_G.TimeUtil:getServerTimeSeconds()
        self.__stage:setRemainingTime(remainingStartTime,"挑战开始倒计时")
    else
        if self.__stage.m_sceneType==_G.Const.CONST_MAP_TYPE_CITY_BOSS then return end
        local remainingBattleTime = _ackMsg.stime-_G.TimeUtil:getServerTimeSeconds()
        self.__stage:setRemainingTime(remainingBattleTime,"挑战结束倒计时")
    end
end


function StageMediator.ACK_WORLD_BOSS_BOSS_LEVEL(self, _ackMsg)
    if self.__stage.m_sceneType ~= __Const.CONST_MAP_TYPE_CITY_BOSS then
        self.__stage:setRemainingTime(0)
    end
    
    for _,monster in pairs(__CharacterManager.m_lpMonsterArray) do
        -- monster:setHP(0)
        __CharacterManager:remove(monster)
        monster:releaseResource()
    end
end

function StageMediator.ACK_WORLD_BOSS_UP_ATTR(self, _ackMsg)
    -- print("StageMediator.ACK_WORLD_BOSS_UP_ATTR count=",#_ackMsg.data)
    -- for _,value in pairs(_ackMsg.data) do
    --     if value.type==__Const.CONST_ATTR_STRONG_ATT then
    --         print("攻击力加成 value=",value.value)
    -- print(_ackMsg.value)
    self.__stage:updateBossAttackPlus(_ackMsg.value)                    
    --         return
    --     end
    -- end   
    -- if _ackMsg.count==0 then
    --     _G.g_BattleView:updateCurrentAttackPlus(0) -- 无攻击加成   
    -- end
    
end
function StageMediator.ACK_WORLD_BOSS_RMB_USE(self, _ackMsg)    
    _G.g_BattleView:updateCheckBox(_ackMsg) -- 提示框显示
end
function StageMediator.ACK_WAR_PK_TIME(self, _ackMsg)
    print("StageMediator.ACK_WAR_PK_TIME _ackMsg.endtime=",_ackMsg.endtime," ,_ackMsg.endtime2=",_ackMsg.endtime2,_G.TimeUtil:getServerTimeSeconds())
    
    local remainingBattleTime=_ackMsg.endtime-_G.TimeUtil:getServerTimeSeconds()
    if remainingBattleTime<=0 then
        remainingBattleTime=_ackMsg.endtime2-_G.TimeUtil:getServerTimeSeconds()
        self.__stage:setRemainingTime(remainingBattleTime,"PK结束倒计时")
        cc.Director:getInstance():getEventDispatcher():setEnabled(true)
        self.__stage.setStopAI(false)
        self.__stage.m_stopMove=nil
        self.__stage.m_lpPlay.m_isShowState=nil
        return
    end
    self.__stage:setRemainingTime(remainingBattleTime,"PK开始倒计时")
    
    self.__stage.endTime2=_ackMsg.endtime2
    cc.Director:getInstance():getEventDispatcher():setEnabled(false)
    self.__stage:setStopAI(true)
    -- self.endtime = reader:readInt32Unsigned() -- {准备时间倒计时}
    -- self.endtime2 = reader:readInt32Unsigned() -- {结束时间戳}
end

function StageMediator.ACK_WRESTLE_DAOJISHI(self, _ackMsg)
    print("StageMediator.ACK_WRESTLE_DAOJISHI _ackMsg.endtime=%d",_ackMsg.times)
    local remainingBattleTime=_ackMsg.times-_G.TimeUtil:getServerTimeSeconds()
    self.__stage:setRemainingTime(remainingBattleTime,"开始PK倒计时")
end

function StageMediator.ACK_WAR_HP_REPLY(self, _ackMsg)
    print("StageMediator.ACK_WAR_HP_REPLY  _ackMsg.hp=",_ackMsg.hp)
    if self.__stage.m_lpPlay~=nil then
        local hurtHP = self.__stage.m_lpPlay:getHP() - _ackMsg.hp
        if hurtHP>0 then
            self.__stage.m_lpPlay:addHP(-hurtHP,nil,true)
        end
    end
end
function StageMediator.ACK_WAR_HP_REPLY2(self, _ackMsg)
    if self.__stage.m_lpPlay~=nil then
        if _ackMsg.hp==0 then
            self.__stage.m_playHp=nil
        end
        self.__stage.m_lpPlay:setHP(_ackMsg.hp,true)
    end
end

function StageMediator.ACK_WORLD_BOSS_NOW_HP(self, _ackMsg)
    local monsterArray=__CharacterManager.m_lpMonsterArray
    for _,monsterBoss in pairs(monsterArray) do
        monsterBoss:setHP(_ackMsg.boss_hp-1)
        break
    end
end

function StageMediator.ACK_SCENE_UP_ATTR(self, _ackMsg)
    print("StageMediator.ACK_SCENE_UP_ATTR============  _ackMsg.value=",_ackMsg.value,",_ackMsg.type=",_ackMsg.type)
    
    if self.__stage.m_attributeAdds==nil then
        self.__stage.m_attributeAdds={}
    end
    
    local rolePlayer = self.__stage.m_lpPlay
    if _ackMsg.type==__Const.CONST_ATTR_S_HP then  --37血量(战斗中..)
        if rolePlayer~=nil then
            local addHp = rolePlayer.m_nMaxHP*_ackMsg.value/10000
            rolePlayer:addHP(addHp)
        end
        return
    elseif _ackMsg.type==__Const.CONST_ATTR_ANIMA then --39初始灵气值
        if rolePlayer~=nil then
            local addSp = rolePlayer.m_nMaxSP*_ackMsg.value/10000
            rolePlayer:addSP(addSp)
        end
        return
    elseif _ackMsg.type==__Const.CONST_ATTR_STRONG_ATT then  --42攻击
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="攻击",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_STRONG_DEF then     --43防御
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="防御",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_DEFEND_DOWN then    --44破甲
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="破甲",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_HIT then       --45命中
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="命中",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_DODGE then    --46闪避
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="闪避",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_CRIT then    --47暴击
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="暴击",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_RES_CRIT then    --48抗暴
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="抗暴",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_BONUS then   --49伤害率
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="伤害",
            labelValue=_ackMsg.value/10000,
        }
    elseif _ackMsg.type==__Const.CONST_ATTR_REDUCTION then   --50免伤率
        self.__stage.m_attributeAdds[_ackMsg.type]={
            labelName="免伤",
            labelValue=_ackMsg.value/10000,
        }
    end
    
    self.__stage:updatePlayerAttribute()
end

function StageMediator.ACK_COPY_COPY_OVER_SERVER(self, _ackMsg)
    self.__stage:slowMotion()
end

function StageMediator.ACK_SCENE_WAR_STATE_REPLY( self, _ackMsg)
    print("StageMediator.ACK_SCENE_WAR_STATE_REPLY  _ackMsg.state=",_ackMsg.state)
    if _ackMsg.state==1 then
        
        self.__stage.isAutoFightMode=true
        self.__stage:setStopAI(false)
        self.__stage.m_lpPlay:enableAI(true)
        _G.g_BattleView:addAutoFightTips(self.__stage.m_lpMessageContainer)
    end
end

function StageMediator.ACK_STRIDE_STRIDE_WAR_RS( self , _ackMsg )
    print("ACK_STRIDE_STRIDE_WAR_RS---->",_ackMsg.jf)
    _ackMsg.res=_ackMsg.rs
    _ackMsg[1] = "46980"
    _ackMsg[2] = _ackMsg.jf
    local index=2
    for i=1,_ackMsg.count do
        index=index+1
        _ackMsg[index]=_ackMsg.rewardMsg[i].goods_id
        index=index+1
        _ackMsg[index]=_ackMsg.rewardMsg[i].count2
    end
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_STRIDE_SUPERIOR_RS( self , _ackMsg )
    print("ACK_STRIDE_SUPERIOR_RS---->",_ackMsg.rs)
    _ackMsg.res=_ackMsg.rs
    _ackMsg[1] = "46000"
    _ackMsg[2] = _ackMsg.gold
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_EXPEDIT_FINISH_MSG( self , _ackMsg )
    print("ACK_STRIDE_STRIDE_WAR_RS----> _ackMsg.result=",_ackMsg.result,"_ackMsg.get_honor=",_ackMsg.get_honor)
    _ackMsg.res=_ackMsg.result
    _ackMsg[1] = "46970"
    _ackMsg[2] = _ackMsg.get_honor
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_FIGHTERS_HERO_OVER_REP( self, _ackMsg )
    print("ACK_FIGHTERS_HERO_OVER_REP---->",_ackMsg.result)
    _ackMsg.res=_ackMsg.result
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_HILL_FINISH_BACK( self, _ackMsg )
    _ackMsg[1] = "46900"
    _ackMsg[2] = _ackMsg.contribute
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_FUTU_OVER_REP( self, _ackMsg )
    _ackMsg.res = _ackMsg.result
    local view=require("mod.map.UIBattleResult")(_ackMsg)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_WAR_SELF_ADD( self, _ackMsg )
    print("ACK_WAR_SELF_ADD---->",_ackMsg.num)
    local uid = _G.GPropertyProxy:getChallengePanePlayInfo():getUid()
    print(uid,_ackMsg.sy_hp)
    local player = __CharacterManager:getPlayerByID(uid)
    player:setHP(_ackMsg.sy_hp)
    player.m_nowHp = _ackMsg.sy_hp
    local warAttr = self.__stage:getMainPlayer():getWarAttr()
    local attr = {"strong_att","strong_def","wreck","hit","dodge","crit","crit_res","bonus","reduction"}
    for _,attrData in pairs(_ackMsg.data) do
        local value = warAttr[attr[attrData.id-41]]
        value = value+attrData.value
        print(attrData.id,value)
        warAttr:updateProperty(attrData.id,value)
    end
end

-- [40525]返回门派战基本信息 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_TIME( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_TIME")
    for i,v in pairs(_ackMsg) do
        print("----"..i..":"..tostring(v))
    end
    
    local curTimes=_G.TimeUtil:getServerTimeSeconds()
    local sTime = _ackMsg.start_time-curTimes
    
    if self.m_clanFight_startGame==true then
        local eTime = _ackMsg.end_time-curTimes
        self.__stage:setRemainingTime(eTime,"剩余时间:",__Const.CONST_COLOR_PINK)
    elseif sTime > 0 then
        self.__stage:setRemainingTime(sTime,"距离开始时间:",__Const.CONST_COLOR_PINK)
    elseif _ackMsg.end_time > curTimes then 
        local eTime = _ackMsg.end_time-curTimes
        self.__stage:setRemainingTime(eTime,"剩余时间:",__Const.CONST_COLOR_PINK)
    end
    
    self.m_clanFight_timeData = _ackMsg
end

-- [40530]门派战个人信息 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_ONCE( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_ONCE")
    for i,v in pairs(_ackMsg) do
        print("----"..i..":"..tostring(v))
    end
    
    if _G.g_BattleView ~= nil then
        _G.g_BattleView:updateClanFight_myInfo(_ackMsg)
    end
end

-- (40535手动) -- [40535]帮排战况信息 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_LIVE( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_LIVE   %d",_ackMsg.count)
    
    for _,table in pairs(_ackMsg.data) do
        for k,v in pairs(table) do
            print("----"..k..":"..tostring(v))
        end
    end
    
    if _G.g_BattleView ~= nil then
        _G.g_BattleView:updateClanFight_clanInfo(_ackMsg.data)
    end
end

-- [40541]比赛开始 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_WAR_START( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_WAR_START")
    
    self.m_clanFight_startGame=true
    local playerList = __CharacterManager.m_lpPlayerArray or {}
    for _,player in pairs(playerList) do
        local property = player:getProperty()
        local roleName = player:getName()
        local clanId = property:getClan()
        local clanName = property:getClanName()
        
        print("[战斗开始],%s-%s-%d",roleName,clanName,clanId)
        property :setTeamID(clanId)
    end
    
    if self.m_clanFight_timeData~=nil then
        local curTimes=_G.TimeUtil:getServerTimeSeconds()
        local eTime = self.m_clanFight_timeData.end_time-curTimes
        self.__stage:setRemainingTime(eTime,"剩余时间:",__Const.CONST_COLOR_PINK)
    end
    
    --开始后再显示传送门
    local scenesID = self.__stage:getScenesID()
    _G.StageXMLManager : addTransport( scenesID )
end

-- [40545]死亡/复活协议 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_DIE( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_DIE")
    for i,v in pairs(_ackMsg) do
        print("----"..i..":"..tostring(v))
    end
    _G.g_BattleView:setClanFight_dieTips(_ackMsg)
    
    local selfPlayCharacter = self.__stage:getMainPlayer()
    selfPlayCharacter:setHP(0)
    self.__stage:removeKeyBoardAndJoyStick()
    self.__stage:removeClanWarDeadAction()
    -- local _type=_ackMsg.type
    -- local _time=_ackMsg.time
    -- if _type==__Const.CONST_GANG_WARFARE_TYPE0 then
    --     -- 死亡
    -- elseif _type==__Const.CONST_GANG_WARFARE_TYPE1 then
    --     -- 复活
    -- end
end

-- [40546]复活成功 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_REC_SUCCESS( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_REC_SUCCESS")
    self:ACK_WORLD_BOSS_REVIVE_OK()
    if _G.g_BattleView~=nil then
        _G.g_BattleView:removeClanFight_dieTips(true)
    end
    self.__stage:removeClanWarDeadAction()
end

-- (40550手动) -- [40550]初赛战果 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_C_FINISH( self, _ackMsg )
    print("\n[门派战 协议返回] -ACK_GANG_WARFARE_C_FINISH  ",_ackMsg.res)
    for i,v in pairs(_ackMsg.data) do
        print("----"..i..":"..tostring(v))
    end
    _G.g_BattleView:setClanFight_resultView(_ackMsg)
    
    --清空倒计时
    self.__stage:setRemainingTime()
    
    if _G.g_BattleView~=nil then
        _G.g_BattleView:removeClanFight_dieTips(true)
    end
end

-- [40542]self血量校正 -- 门派战 
function StageMediator.ACK_GANG_WARFARE_SELF_HP( self, _ackMsg )
    local curHp=_ackMsg.hp
    
    print("ACK_GANG_WARFARE_SELF_HP--->> hp=%d",curHp)
    self.__stage.m_lpPlay:setHP(curHp)
end

-- [7970]组队开始前发送全部组员职业 -- 副本 
function StageMediator.ACK_COPY_TEAM_SKINS(self, _ackMsg)
    self.m_playerResLoadDatas=_ackMsg
    
    for k,v in pairs(_ackMsg) do
        print(k,v)
        if type(v)=="table" then
            for sk,sv in pairs(v) do
                print(sk,sv)
            end
        end
    end
end

function StageMediator.ACK_SCENE_PACKAGE(self,_ackMsg)
    -- print("_ackMsg.moveMsgs count=",#_ackMsg.moveMsgs,"_ackMsg.updateUpMsgs count=",#_ackMsg.updateUpMsgs,"_ackMsg.skillMsgs count=",#_ackMsg.skillMsgs)
    for _,msg in pairs(_ackMsg.moveMsgs) do
        self:ACK_SCENE_MOVE_RECE(msg)
    end
    for _,msg in pairs(_ackMsg.updateUpMsgs) do
        self:ACK_SCENE_HP_UPDATE(msg)
    end
    for _,msg in pairs(_ackMsg.skillMsgs) do
        self:ACK_WAR_SKILL(msg)
    end
end

function StageMediator.ACK_WORLD_BOSS_PLAYER_DIE(self,_ackMsg)
    -- _G.g_BattleView:CityBossPlayerDeadView(_ackMsg)
    -- self.__stage:setBossDeadTime(_ackMsg.time)
    local string
    if _ackMsg.type == 1 then
        string = _ackMsg.player_name
    else
        local boss = _G.Cfg.scene_monster[_ackMsg.boss_id]
        if boss == nil then
            string = _G.Lang.LAB_N[938]
        else
            string = boss.monster_name
        end
    end
    _G.g_BattleView:showBossDeadView(_ackMsg.rmb,string)
    self.__stage:setBossDeadTime(_ackMsg.time)
    
    print("StageMediator.ACK_WORLD_BOSS_WAR_RS  _ackMsg.time=",_ackMsg.time,_ackMsg.rmb)
    
    local selfPlayCharacter = self.__stage:getMainPlayer()
    selfPlayCharacter:setHP(0)
    self.__stage:removeKeyBoardAndJoyStick()
end

function StageMediator.ACK_FIGHTERS_NEXT_COPY_ID(self,_ackMsg)
    self.__stage.nextCopyId=_ackMsg.copy_id
end

function StageMediator.ACK_COPY_STRONG_STATE( self, _ackMsg )
    self.__stage:setOpenId(_ackMsg.sub_id)
end

--一骑当千选择了的资源
function StageMediator.ACK_THOUSAND_WAR_REPLY( self,_ackMsg )
    print("一骑当千准备资源加载")
    local data = {}
    if _ackMsg.pro ~= nil then
        data.pro =  _ackMsg.pro
    end
    data.skilliddata = nil 
    if _ackMsg.msg_skill ~= nil then
        data.skilliddata =  _ackMsg.msg_skill
    end
    self.__stage : setIkkiTousenWarData(data)
end
function StageMediator.ACK_THOUSAND_NEW_RECORD( self,_ackMsg )
    print("一骑当千战斗结束返回",_ackMsg.harm,_ackMsg.time)

    self.__stage : IkkiTousen_setshowtime(nil)
    local data = _G.Cfg.thousand_jifen[_ackMsg.id]
    _ackMsg[1] = "54000"
    _ackMsg[2] = data.reward[1][2]
    local view=require("mod.map.UIBattleResult")(_ackMsg,_ackMsg.flag)
    self.__stage:addMessageView(view:create())
end

function StageMediator.ACK_COPY_SCENE_TIME2( self,_ackMsg )
    print("StageMediator.ACK_COPY_SCENE_TIME2",_ackMsg.time)
    if _ackMsg.time == nil then return end
    local time = _G.TimeUtil:getServerTimeSeconds() - _ackMsg.time
    print("------>",time)
    if time<0 then time=0 end
    self.__stage : IkkiTousen_setshowtime(time)
end
function StageMediator.ACK_XMZL_PLAYER_INFO( self,_ackMsg )  -- [18080]进入副本信息 -- 降魔之路 
    local warAttr = self.__stage:getMainPlayer():getWarAttr()
    local attr = {"strong_att","strong_def","wreck","hit","dodge","crit","crit_res","bonus","reduction"}
    for _,attrData in pairs(_ackMsg.msg_attr) do
        if attrData.type~=41 then
            local value = math.ceil(warAttr[attr[attrData.type-41]])
            value = value*(1+attrData.value*__Const.CONST_SURRENDER_PLUS_PERCENT/100)
            warAttr:updateProperty(attrData.type,value)
        end
    end
    self.__stage.m_lpPlay:setHP(_ackMsg.hp)
    print(_ackMsg.hp,"ACK_XMZL_PLAYER_INFO =====>>",self.__stage.m_lpPlay.m_nMaxHP)
    self.__stage.m_playPowerful=_ackMsg.powerful

    if _ackMsg.relive_times==1 then
        -- 已死亡过一次,即已经复活过一次了
        self.__stage.m_lpPlay.m_isRebornYet=true
    end
    for _,v in pairs(__CharacterManager:getMonster()) do
        v:updateWarAttr(_ackMsg.powerful)
    end
end
function StageMediator.ACK_HONGBAO_SEND_ALL(self,_ackMsg)
    self.__stage:addHongBaoView(_ackMsg)
end


-- [65350]箱子返回 -- 秘宝活动 
function StageMediator.ACK_MIBAO_BOX_REPLY(self,_ackMsg)
    print("ACK_MIBAO_BOX_REPLY===>>",_ackMsg.count)
    for i=1,_ackMsg.count do
        self:ACK_MIBAO_BOX_DATA(_ackMsg.box_xxx[i])
    end
end
-- [65355]箱子信息块 -- 秘宝活动 
function StageMediator.ACK_MIBAO_BOX_DATA(self,_ackMsg)
    -- _boxId,_skinID,_nowHp,_maxHp,_ownerUid,_ownerName,_posX,_posY,_type)
    if _ackMsg.hp_now==0 then
        print("ACK_MIBAO_BOX_DATA===>>  没血的宝箱。。。。。")
        return
    end

    for k,v in pairs(__CharacterManager.m_lpGoodsMonsterArray) do
        if v:getID()==_ackMsg.box_idx then
            v:resetName(_ackMsg.name)
            return
        end
    end
    _G.StageXMLManager:addGoodsMonster2(_ackMsg.box_idx,_ackMsg.box_id,_ackMsg.hp_now,_ackMsg.hp_max,_ackMsg.uid,_ackMsg.name,_ackMsg.pos_x,_ackMsg.pos_y)
end
-- [65360]箱子消失 -- 秘宝活动 
function StageMediator.ACK_MIBAO_BOX_DISAPPEAR(self,_ackMsg)
    local function tempFun()
        if not _ackMsg.count or _ackMsg.count==0 then return end

        if _ackMsg.type==2 then
            -- 箱子爆出物品
            for i=1,#_ackMsg.xxx do
                self:ACK_MIBAO_GOODS_LIST(_ackMsg.xxx[i])
            end
        elseif _ackMsg.type==3 then
            -- 箱子爆出怪物
            local tempMsg={data=_ackMsg.xxx}
            self:ACK_SCENE_IDX_MONSTER(tempMsg)
        end
    end

    for k,v in pairs(__CharacterManager.m_lpGoodsMonsterArray) do
        if v:getID()==_ackMsg.box_idx then
            if _ackMsg.type==1 then
                -- 箱子CD到，自动消失
                self.__stage:removeCharacter(v)
            elseif v:getHP()>0 then
                v:addHP(-v:getHP())
                v.deadCallBack=tempFun
            end
            break
        end
    end
end
-- [65365]物品信息块 -- 秘宝活动 
function StageMediator.ACK_MIBAO_GOODS_LIST(self,_ackMsg)
    local goodsArray=__CharacterManager:getGoods()
    for k,v in pairs(goodsArray) do
        if v:getID()==_ackMsg.goods_idx then
            v:setOwnerInfo(_ackMsg.uid,_ackMsg.name)
            return
        end
    end

    local tempData={
        goods_id=_ackMsg.goods_id,
        count=_ackMsg.goods_count,
        pos_x=_ackMsg.goods_x,
        pos_y=_ackMsg.goods_y,
    }
    local uid=_ackMsg.goods_idx
    local goods=CGoods(__Const.CONST_GOODS)
    goods:init(uid,tempData)
    goods:setOwnerInfo(_ackMsg.uid,_ackMsg.name)
    self.__stage:addCharacter(goods)
end
-- [65370]所有物品掉落信息 -- 秘宝活动 
function StageMediator.ACK_MIBAO_GOODS_ALL(self,_ackMsg)
    print("ACK_MIBAO_GOODS_ALL===>>",_ackMsg.count)
    for i=1,#_ackMsg.xxx_goods do
        self:ACK_MIBAO_GOODS_LIST(_ackMsg.xxx_goods[i])
    end
end
-- [65380]物品消失 -- 秘宝活动 
function StageMediator.ACK_MIBAO_GOODS_DISAPPEAR(self,_ackMsg)
    local goodsArray=__CharacterManager:getGoods()
    for k,v in pairs(goodsArray) do
        if v:getID()==_ackMsg.goods_idx then
            -- print("AAAAAAAAAAAAAAA===>>>",v:getOwnerUid(),_ackMsg.uid)
            local tempPlayer=__CharacterManager:getCharacterByTypeAndID(__Const.CONST_PLAYER,_ackMsg.uid)
            if tempPlayer then
                -- if tempPlayer.isMainPlay then
                --     v:showPickUpOkAction(tempPlayer,true)
                -- else
                    v:showPickUpOkAction(tempPlayer,false)
                -- end
            else
                self.__stage:removeCharacter(v)
            end
            return
        end
    end
end
-- [65385]玩家当前血量 -- 秘宝活动 
function StageMediator.ACK_MIBAO_PLAYER_HP(self,_ackMsg)
    self:ACK_WORLD_BOSS_SELF_HP(_ackMsg)
end
-- [65390]玩家死亡 -- 秘宝活动 
function StageMediator.ACK_MIBAO_PLAYER_DIE(self,_ackMsg)
    -- for k,v in pairs(_ackMsg) do
    --     print(k,v)
    -- end
    local string
    if _ackMsg.type == 1 then
        string = _ackMsg.player_name
    else
        local boss = _G.Cfg.scene_monster[_ackMsg.boss_id]
        if boss == nil then
            string = _G.Lang.LAB_N[938]
        else
            string = boss.monster_name
        end
    end
    _G.g_BattleView:showBossDeadView(_ackMsg.rmb,string)
    self.__stage:setBossDeadTime(_ackMsg.time)
    
    print("StageMediator.ACK_MIBAO_PLAYER_DIE  _ackMsg.time=",_ackMsg.time,_ackMsg.rmb)
    
    local selfPlayCharacter = self.__stage:getMainPlayer()
    selfPlayCharacter:setHP(0)
    self.__stage:removeKeyBoardAndJoyStick()
end
-- [65405]玩家复活返回 -- 秘宝活动 
function StageMediator.ACK_MIBAO_REVIVE_REPLY(self,_ackMsg)
    self:ACK_WORLD_BOSS_REVIVE_OK(_ackMsg)
end
-- [65410]下一次箱子刷新时间 -- 秘宝活动 
function StageMediator.ACK_MIBAO_BOX_REFRESH_TIME(self,_ackMsg)
    print("ACK_MIBAO_BOX_REFRESH_TIME====>>>",_ackMsg.state,_ackMsg.time,_G.TimeUtil:getTotalSeconds())

    local nextTimes=_ackMsg.time-_G.TimeUtil:getTotalSeconds()
    if nextTimes>0 then
        if _ackMsg.state==1 then
            -- 这波箱子消失的时间
            self.__stage:setRemainingTime(nextTimes,"箱子消失时间")
        else
            -- 下一波箱子刷新时间
            self.__stage:setRemainingTime(nextTimes,"下波刷新时间")
        end
    -- else
    --     local command=CErrorBoxCommand(string.format("时间不同步,当前%d,收到%d",_G.TimeUtil:getTotalSeconds(),_ackMsg.time))
    --     _G.controller:sendCommand(command)
    end
end



function StageMediator.ACK_COPY_MONEY_OVER_REPLY(self,_ackMsg)
    local tempMsg={}
    tempMsg.res= 1
    tempMsg.hurt = _ackMsg.harm
    tempMsg.gold = _ackMsg.money
    tempMsg[1] = "46000"
    tempMsg[2] = _ackMsg.money
    local view=require("mod.map.UIBattleResult")(tempMsg)
    self.__stage:addMessageView(view:create())
end





function StageMediator.ACK_WAR_PVP_TIME_BACK(self,_ackMsg)
    self.__stage:updatePVPTimes(_ackMsg.time)
end
function StageMediator.ACK_WAR_PVP_SKILL_BACK(self,_ackMsg)
    -- for k,v in pairs(_ackMsg.skill_group) do
    --     print(k,v)
    -- end
    for i=1,#_ackMsg.state_group do
        if _ackMsg.state_group[i].uid==_ackMsg.skill_group.id then
            table.remove(_ackMsg.state_group,i)
            break
        end
    end
    self.__stage:updatePVPPlayerState(_ackMsg.time,_ackMsg.state_group,true)
    self:ACK_WAR_SKILL(_ackMsg.skill_group)
end
function StageMediator.ACK_WAR_PVP_STATE_BACK(self,_ackMsg)
    self.__stage:updatePVPPlayerState(_ackMsg.time,_ackMsg.state_group)
end


function StageMediator.ACK_WAR_PVP_FRAME_MSG(self,_ackMsg)
    self.__stage:pushPVPFrameData(_ackMsg)
end





function StageMediator.ACK_LINGYAO_ARENA_BATTLE_REPLY(self,_ackMsg)
    print("ACK_LINGYAO_ARENA_BATTLE_REPLY====>>>>",_ackMsg.count,_ackMsg.count2)
    _G.g_lingYaoPkData=_ackMsg
    self:gotoScene(__Const.CONST_ARENA_JJC_LY_ID,nil,nil)
end

function StageMediator.ACK_LINGYAO_ARENA_OVER_REPLY(self,_ackMsg)
    -- self.result = r:readInt16Unsigned() -- { 最终结果 结果(1完胜:2胜利:3平局4:失败5:完败) }
    -- self.rank = r:readInt16Unsigned() -- { 挑战后的排名 }
    -- self.up = r:readInt16Unsigned() -- { 上升多少名 }
    -- self.count = r:readInt8Unsigned() -- { 数量 }
    -- self.goods_id = r:readInt16Unsigned() -- { 物品ID }
    -- self.goods_count = r:readInt16Unsigned() -- { 物品数量 }
    -- local resCount=0
    -- for i=1,#self.__stage.m_lingYaoResultArray do
    --     local res=self.__stage.m_lingYaoResultArray[i]
    --     if res==1 then
    --         resCount=resCount-1
    --     elseif res==4 then
    --         resCount=resCount+1
    --     end
    -- end

    local tempData={}
    tempData.res=_ackMsg.result
    tempData.up=_ackMsg.up
    tempData.rank=_ackMsg.rank
    -- if resCount<0 then
    --     tempData.res=0
    -- elseif resCount>0 then
    --     tempData.res=1
    -- else
    --     tempData.res=2
    -- end

    for i=1,#_ackMsg.goods_data do
        local idx=i*2
        tempData[idx-1]=_ackMsg.goods_data[i].goods_id
        tempData[idx]=_ackMsg.goods_data[i].goods_count
        print("IIIIIIIIIIIIIII=====>>>",_ackMsg.goods_data[i].goods_id)
    end

    local view=require("mod.map.UIBattleResult")(tempData)
    self.__stage:addMessageView(view:create())
end





return StageMediator