-- 系统
collectgarbage('setpause',120)
collectgarbage('setstepmul',300)
if _sys:getGlobal'p1' then
    _sys.appLoader = _Loader.new( )
    _sys.appLoader.pause = true
    _sys.catchResError = false
end
_sys.skeletonPick = true

_G.isUseOldLogin = true--登录场景版本
_G.isEtitStoryTiao = false--编辑跳剧情

-- 职业
_G.enProfType =
{
    eProfType_Sickle 	= 1;		--萝莉
    eProfType_Sword 	= 2;		--男魔
    eProfType_Human 	= 3;		--人男
    eProfType_Woman     = 4;        --御姐
}
_G.enCreateRoleDefaultProf = 2		--默认职业


_G.fSpeed = 5 * 10;    --默认速度
_G.portalRange = 15; --传送门半径
_G.MaxZhenqiValue = 100000 --灵力最大值

---默认值, _G.mapLightConfig 中可对具体地图做配置
_G.dwPointColor = 0xffa1ba69;	--角色点光源颜色
--_G.dwPointColor = 0xffff0000;	--红光
_G.dwPointPower = 1.7;	--角色身上光源强度
_G.dwPointRange = 80;	--灯光照射的范围

---默认值, _G.mapLightConfig 中可对具体地图做配置
_G.dwSkyLightColor = 0xffffffff; --角色身上天空光颜色
_G.dwSkyLightPower = 2.0; --角色身上天空光强度
--默认值, _G.mapLightConfig 中可对具体地图做配置
_G.dwSkyBackLightColor = 0xffffffff; --角色身上天空光颜色
_G.dwSkyBackLightPower = 2.0; --角色身上天空光强度



_G.ROLE_XIUXIAN_GAP = 10000
_G.MONSTER_XIUXIAN_GAP = 5000
_G.NPC_XIUXIAN_GAP = 5000
_G.LS_XIUXIAN_GAP = 10000

_G.RoleConfig =
{
    ---
    ---角色
    idle_san = '01';           --非战斗待机
    move_san = '02';           --非战斗跑步
    attack_idle_san = '01';    --战斗待机
    attack_move_san = '02';    --战斗跑步

    dead_san = '001';           --死亡
    collect_san1 = '003';        --采集
	heti_san = '014';			--合体
    wuhun_san_1 = '010';        --直攻动作
    wuhun_san_2 = '013';        --召唤动作
    wuhun_san_3 = '011';        --下攻动作
    wuhun_san_4 = '012';        --防御动作
    xiuxian_san = '009';        --休闲--idle 10s then enter
    sit_san = '002';            --打坐
    lianhualu_san = "006";      --炼化炉动作
    rankList_san = "007";       --排行榜动作
    team_san = "008";           --组队动作
    superZuo_san = "015";       --荣耀座
    superZhan_san = "016";      --荣耀站
	collect_san2 = "017";       --切水果
    shenzhuang_san = "018";     --神装展示
    shenzhuangidle_san = "019";     --神装展示待机
    ---坐骑
    horse_idle_san = '101';           --非战斗待机
    horse_move_san = '102';           --非战斗跑步
    horse_attack_idle_san = '201';    --战斗待机
    horse_attack_move_san = '202';    --战斗跑步
    horse_dead_san = '700';           --死亡

    horse_san_map = {
        ['101'] = 'san_idle',
        ['102'] = 'san_move',
        ['201'] = 'san_attack_idle',
        ['202'] = 'san_attack_move',
        ['700'] = 'san_dead',
    };

    --职业配置
    ProfConfig =
    {
        [enProfType.eProfType_Sickle]= --萝莉
        {
            skl = 'v_zhujue_qn.skl'; --骨骼
            FlauntPfx    = 10001;
            --角色相关摄像机配置
            dwCameraHeight  = 1.2 * 10;			--最低点的时候的高度
            dwSoundId = 3012;
			dwSkillId = 1000001;
            dwRollSkillId = 1000000;
            moveMusic = 3011;
            moveMusicOnHorse = 3012;
        };
        [enProfType.eProfType_Sword]= --男魔
        {
            skl = 'v_zhujue_xyn.skl'; --骨骼
            FlauntPfx    = 10001;
            --角色相关摄像机配置
            dwCameraHeight  = 1.2 * 10;		--最低点的时候的高度
            dwSoundId = 3010;
			dwSkillId = 2000001;
            dwRollSkillId = 2000000;
            moveMusic = 4011;
            moveMusicOnHorse = 4012;
        };
		[enProfType.eProfType_Human]= --男人
        {
            skl = 'v_zhujue_xr.skl'; --骨骼
            FlauntPfx    = 10001;
            --角色相关摄像机配置
            dwCameraHeight  = 1.2 * 10;			--最低点的时候的高度
            dwSoundId = 3012;
			dwSkillId = 3000001;
            dwRollSkillId = 3000000;
            moveMusic = 5011;
            moveMusicOnHorse = 5012;

        };
        [enProfType.eProfType_Woman]= --御姐
        {
            skl = 'V_zhujue_ms.skl'; --骨骼
            FlauntPfx    = 10001;
            --角色相关摄像机配置
            dwCameraHeight  = 1.2 * 10;         --最低点的时候的高度
            dwSoundId = 3012;
            dwSkillId = 4000001;
            dwRollSkillId = 4000000;
            moveMusic = 6011;
            moveMusicOnHorse = 6012;
        };
    };
};
--选人创角相关
_G.firstEnterGame = {
    scene = 0,  --第一次进游戏场景ID
    mark = 'born'
}

--场景光照配置
_G.mapLightConfig = {
   --默认配置
    [1] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=0.5, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffced6f1, ["dwSkyLightPower"]=1.1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
	--新游戏遗迹
	[11000001]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.8, ["dwPointRange"]=200, ["dwSkyLightColor"]=0xffc6dceb, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xfff2ca9a, ["dwSkyBackLightPower"]=8, ["skyRange"] = 800,["dwFaceLightColor"]=0xffffe699, ["dwFaceLightPower"]=0.6, ["dwFaceLightRange"]=20},
	--新游戏变形副本
	[11300002]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.8, ["dwPointRange"]=200, ["dwSkyLightColor"]=0xffc6dceb, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xfff2ca9a, ["dwSkyBackLightPower"]=8, ["skyRange"] = 800,["dwFaceLightColor"]=0xffffe699, ["dwFaceLightPower"]=0.6, ["dwFaceLightRange"]=20},
    --死灵都
	[11000006]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.8, ["dwPointRange"]=200, ["dwSkyLightColor"]=0xffc6dceb, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xfff2ca9a, ["dwSkyBackLightPower"]=8, ["skyRange"] = 800,["dwFaceLightColor"]=0xffffe699, ["dwFaceLightPower"]=0.6, ["dwFaceLightRange"]=20},
    --临时野外场景1
	[11000003]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.8, ["dwPointRange"]=200, ["dwSkyLightColor"]=0xffc6dceb, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xfff2ca9a, ["dwSkyBackLightPower"]=8, ["skyRange"] = 800,["dwFaceLightColor"]=0xffffe699, ["dwFaceLightPower"]=0.6, ["dwFaceLightRange"]=20},
	--临时野外场景2
	[11000004]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.8, ["dwPointRange"]=200, ["dwSkyLightColor"]=0xffc6dceb, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xfff2ca9a, ["dwSkyBackLightPower"]=8, ["skyRange"] = 800,["dwFaceLightColor"]=0xffffe699, ["dwFaceLightPower"]=0.6, ["dwFaceLightRange"]=20},
	--临时野外场景3
	[11000005]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.8, ["dwPointRange"]=200, ["dwSkyLightColor"]=0xffc6dceb, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xfff2ca9a, ["dwSkyBackLightPower"]=8, ["skyRange"] = 800,["dwFaceLightColor"]=0xffffe699, ["dwFaceLightPower"]=0.6, ["dwFaceLightRange"]=20},
	--远古战场
    [10100000]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.5, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffecf1f9, ["dwSkyLightPower"]=1.5, ["dwSkyBackLightColor"]=0xfff2e5fb, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
    --北灵院
    [10100001]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.1, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.5, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffecf1f9, ["dwSkyLightPower"]=1.7, ["dwSkyBackLightColor"]=0xfff2e5fb, ["dwSkyBackLightPower"]=5, ["skyRange"] = 700},
    --主城
    [10200001]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.1, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.1, ["dwPointRange"]=10, ["dwSkyLightColor"]=0xffecf1f9, ["dwSkyLightPower"]=1.4, ["dwSkyBackLightColor"]=0xfff2e5fb, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
    --遗迹大陆
    [10100004]  = {["glowFactor"] = 0.4, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=0.1, ["dwPointRange"]=1,["dwSkyLightColor"]=0xfefddac, ["dwSkyLightPower"]=1.5, ["dwSkyBackLightColor"]=0xffb0b4eb, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    
	--白龙求
    [10100002]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.5, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1.8, ["dwSkyBackLightColor"]=0xffe9c8f1, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    --大罗天域
	[10100005]  = {["glowFactor"] = 0.4, ["lightFactor"] = 1.4, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1.6, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 500},
	
	--圣灵山
	[10100003]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.0, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=0, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffe7f5fa, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=3, ["skyRange"] = 500},
	--龙凤天
    [10100006]  = {["glowFactor"] = 0.4, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.1, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    --陨落战场
    [10100007]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.3, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=2.3, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=6, ["skyRange"] = 500},
    --大西天界
    [10100008]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.3, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    --无尽火域
    [10100009]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.3, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    --至尊武境
    [10100010]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.3, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=2, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    --不死之地
    [10100011]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.3, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=2, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
    --绝世剑域
    [10100012]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.3, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=2, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 500},
	--水果乐园副本
    [10400013]  = {["glowFactor"] = 0.2, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffc4dcfd, ["dwPointPower"]=0.1, ["dwPointRange"]=10,["dwSkyLightColor"]=0xfecf3fd, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffe2d6fe, ["dwSkyBackLightPower"]=4, ["skyRange"] = 800},
	
	--测试场景2
    [10110001]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=0.3, ["dwPointRange"]=10,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=4, ["skyRange"] = 800},
    --鬼龙洞窟
    [10310001]  = {["glowFactor"] = 0.5, ["lightFactor"] = 1.1, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 500},
	--熔岩牢狱
	[10310002]  = {["glowFactor"] = 0.4, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffff9f4, ["dwSkyLightPower"]=1.5, ["dwSkyBackLightColor"]=0xfffff9d9, ["dwSkyBackLightPower"]=6, ["skyRange"] = 500},
    --测试场景
    [10400001]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=0.5, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 800},
	--哭号废墟
    [10400003]  = {["glowFactor"] = 0.1, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 500},
    --午夜岛
    [10400007]  = {["glowFactor"] = 0.1, ["lightFactor"] = 1.5, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 500},
    --竞技场 
    [10400010]  = {["glowFactor"] = 0.1, ["lightFactor"] = 1.4, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 500},
    [10400011]  = {["glowFactor"] = 0.1, ["lightFactor"] = 1.5, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xffffffff, ["dwSkyLightPower"]=1, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 800},

    [10100005]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.1, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=1, ["dwPointRange"]=80,["dwSkyLightColor"]=0xfefddac, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=1.0, ["skyRange"] = 800},
	--斗破苍穹
    [10400017]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffeaedf2, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffecf1f9, ["dwSkyLightPower"]=2, ["dwSkyBackLightColor"]=0xfff2e5fb, ["dwSkyBackLightPower"]=5, ["skyRange"] = 500},
	--灵路试炼
	[10400025]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.2, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=2, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfe0e4f4, ["dwSkyLightPower"]=1.2, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=3, ["skyRange"] = 2800},
	--婚礼殿堂
	[10400039]  = {["glowFactor"] = 0.3, ["lightFactor"] = 1.4, ["dwPointColor"]=0xffa1ba69, ["dwPointPower"]=0.5, ["dwPointRange"]=50,["dwSkyLightColor"]=0xfe0e4f4, ["dwSkyLightPower"]=1.4, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=4, ["skyRange"] = 2800},
	
	--登录场景
    [10200002]  = {["glowFactor"] = 0.4, ["lightFactor"] = 1.5, ["dwPointColor"]=0xffdbe4f8, ["dwPointPower"]=0, ["dwPointRange"]=0,["dwSkyLightColor"]=0xffb0d9ec, ["dwSkyLightPower"]=0.8, ["dwSkyBackLightColor"]=0xffb8e2e6, ["dwSkyBackLightPower"]=18, ["skyRange"] = 2000},
	--登录场景旧
    [10200003]  = {["glowFactor"] = 0.1, ["lightFactor"] = 1.5, ["dwPointColor"]=0xffdbe4f8, ["dwPointPower"]=10, ["dwPointRange"]=50,["dwSkyLightColor"]=0xffe2e6ef, ["dwSkyLightPower"]=2.2, ["dwSkyBackLightColor"]=0xffd4ddf1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
	
   --死亡遗迹
    [10420001] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420002] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420003] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420004] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420005] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420006] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420007] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420008] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420009] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420010] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420011] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},
   --死亡遗迹
    [10420012] = {["glowFactor"] = 0.3, ["lightFactor"] = 1.3, ["dwPointColor"]=0xffe89543, ["dwPointPower"]=0.1, ["dwPointRange"]=80, ["dwSkyLightColor"]=0xffdee7f8, ["dwSkyLightPower"]=3, ["dwSkyBackLightColor"]=0xffced6f1, ["dwSkyBackLightPower"]=5, ["skyRange"] = 800},	
}

--自动战斗吃药配置
_G.AutoDefine = {
    hp_list1 = {
        110120001,
        110120002,
        110120003,
        110120004,
        110120005,
        110120006,
        110120007,
        110120008,
        110120009,
    },
    -- mp_list1 = {110120011, 110120012, 110120013,110120014, 
    --            110120015, 110120016, 110120017, 110120018, 110120019},
    hp_list2 = {
        110120009,
        110120008,
        110120007,
        110120006,
        110120005,
        110120004,
        110120003,
        110120002,
        110120001,
    },
    -- mp_list2 = {110120019, 110120018, 110120017, 110120016, 110120015, 110120014,
    --             110120013, 110120012, 110120011},
}

_G.SKILL_List =
{
    [enProfType.eProfType_Sickle] = --萝莉
    {
        1002, 1007, 1001, 1004, 1007, 1001, 1006, 1002, 1007, 1005,
    },

    [enProfType.eProfType_Sword] = --男魔
    {
        2003, 2011, 2001, 2005, 2002, 2011, 2006, 2011, 2007, 2011,
    },
    [enProfType.eProfType_Human] = --男魔
    {
        3002, 3007, 3001, 3004, 3007, 3001, 3006, 3002, 3007, 3005,
    },
    [enProfType.eProfType_Woman] = --男魔
    {
        4002, 4007, 4001, 4004, 4007, 4001, 4006, 4002, 4007, 4005,
    },
}

_G.Shop_Item_List_1 ={
    110120001,
    110120002,
    110120003,
    110120004,
    110120005,
    110120006,
    110120007,
    110120008,
    110120009,
} --生命药水
--_G.Shop_Item_List_2 = {110120011, 110120012, 110120013, 110120014, 110120015, 110120016, 110120017, 110120018, 110120019} --内力药水

--传送门配置
_G.portal_pfx = {
    [1] = 10012,
    [2] = 10013,
    [3] = 10014,
    [4] = 10014,
}


_G.profString = {
    [enProfType.eProfType_Sickle] = "qn",
    [enProfType.eProfType_Sword] = "xyn",
    [enProfType.eProfType_Human] = "xr",
    [enProfType.eProfType_Woman] = "ms",
}

---材质球
_G.mats = {
    -- 普通
    normal = {
		role = {3, 0.2},       -- 角色
		npc = {4, 0.2}, --npc
        others = { 3, 0.2 },     -- 其它
    },

 }
 
---怪物所受skylight,应用到所有地图
_G.dwMonsterSkyLightColor = 0xfff4f7fe
_G.dwMonsterSkyLightPower = 1
 ---怪物所受skyBacklight,应用到所有地图
_G.dwMonsterSkyBackLightColor = 0xfffaf4ea
_G.dwMonsterSkyBackLightPower = 0.5
---npc所受skylight，应用到所有地图
_G.dwNpcSkyLightColor = 0xffc9ddfd
_G.dwNpcSkyLightPower = 1
---npc所受skyBacklight，应用到所有地图
_G.dwNpcSkyBackLightColor = 0xffced6f1
_G.dwNpcSkyBackLightPower = 1

---掉落物品所受skylight，应用到所有地图
_G.dwDropItemSkyLightColor = 0xffced6f1
_G.dwDropItemSkyLightPower = 4
---采集物所受skyBacklight，应用到所有地图
_G.dwCollectSkyLightColor = 0xffced6f1
_G.dwCollectSkyLightPower = 3
---坐骑所受skylight，应用到所有地图
_G.dwHorseSkyLightColor = 0xfefddac
_G.dwHorseSkyLightColor = 0xfefddac
_G.dwHorseSkyLightPower = 0.5
---坐骑物所受skyBacklight，应用到所有地图
_G.dwHorseSkyBackLightColor = 0xffb0b4eb
_G.dwHorseSkyBackLightPower = 1
---小跟宠所受skylight，应用到所有地图
_G.dwPetSkyLightColor = 0xfefddac
_G.dwPetSkyLightPower = 2
---小跟宠物所受skyBacklight，应用到所有地图
_G.dwPetSkyBackLightColor = 0xffb0b4eb
_G.dwPetSkyBackLightPower = 3

---灵兽所受skylight，应用到所有地图
_G.dwLingShouSkyLightColor = 0xfefddac
_G.dwLingShouSkyLightPower = 1
---灵兽物所受skyBacklight，应用到所有地图
_G.dwLingShouSkyBackLightColor = 0xffb0b4eb
_G.dwLingShouSkyBackLightPower = 2


---婚车所受skylight，应用到所有地图
_G.dwHuncheSkyLightColor = 0xfefddac
_G.dwHuncheSkyLightPower = 3
---婚车物所受skyBacklight，应用到所有地图
_G.dwHuncheSkyBackLightColor = 0xffb0b4eb
_G.dwHuncheSkyBackLightPower = 2

--UI场景mesh所受的光
_G.dwUISkyLightColor = 0xffd7e7f6;
_G.dwUISkyLightPower = 4;
_G.dwUISkyBackLightColor = 0xffffffff;
_G.dwUISkyBackLightPower = 2;

----#############
_G.indicator = _Indicator.new();

--test
_G.drawAxis = false;
_G.drawMeshBBox = false;
_G.drawBone = false

_G.gameGlowFactor = 0

--引擎全屏光参数
_rd.glowFactor = 0.3;  --0为关闭泛光
_rd.lightFactor = 1.5; --默认为1
--_rd.shadowQuality = 0.7;
--_rd.mip;	--引擎默认值为true,false为高清效果
_G.hdMode = true
--光影效果，low, middle, high Quality; 默认3高品质
_G.lowQuality = 1
_G.midQuality = 2
_G.highQuality = 3
_G.lightShadowQuality = highQuality;
_G.lightShadowQualitys = {
	[lowQuality] = {
		openRealShadow = false,
		openDecalShadow = false,
		openSkyBackLight = false
	},
	[midQuality] = {
		openRealShadow = false,
		openDecalShadow = true,
		openSkyBackLight = false
	},
	[highQuality] = {
		openRealShadow = true,
		openDecalShadow = true,
		openSkyBackLight = true
	}
}

_G.safeAreaPfxWight = 10

--流光参数 对应模型编辑器的参数
--起始亮度#结束亮度#持续时间#X轴偏移#Y轴偏移
_G.FLOWLIGHT = {
    arm = {0.2, 0.5, 10000, 0.5, 0}
}

_G.footprint_pfx = {
    [1] = {
        [1] = {
            ["zuo"] = "pfx_jiaoyin_luoli.pfx",
            ["you"] = "pfx_youjiaoyin.pfx"
        },
        [2] = {
            ["zuo"] = "pfx_jiaoyin_mozu.pfx",
            ["you"] = "pfx_youjiaoyin.pfx"
        },
        [3] = {
            ["zuo"] = "pfx_jiaoyin_renzu.pfx",
            ["you"] = "pfx_youjiaoyin.pfx"
        },
        [4] = {
            ["zuo"] = "pfx_jiaoyin_yujie.pfx",
            ["you"] = "pfx_youjiaoyin.pfx"
        }
    }        
}

--guyingnan
_G.RolePlayPartActInterval = 8000;		--人物部件自动播放间隔
_G.RoleFaceLightDistance = 8;			--主角面前点光距离
--jianghaoran
_G.EquipStarFullMinQuality = 0;			--装备升星满足最小的品质   -- before:5 adder:houxudong date:2016/6/20