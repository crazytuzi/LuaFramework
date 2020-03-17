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
_G.enCreateRoleDefaultProf = 4		--默认职业


_G.fSpeed = 5 * 10;    --默认速度
_G.portalRange = 15; --传送门半径
_G.MaxZhenqiValue = 100000 --灵力最大值


_dofile (ClientConfigPath .. 'config/LightConfig.lua');

_G.Light = {};
_G.AnlyLightCommon = false;
function Light.GetEntityLight(enum,mapid)
	enum = enum or -1;
	local light = LightCommon[enum];
	if AnlyLightCommon then
		return light;
	end
	if not mapid then
		return light;
	end
	local map = SceneLight[mapid];
	if not map then
		return light;
	end
	light = map[enum] or light;
	return light;
end

function Light.GetSceneLight(mapid)
	local scene = LightCommon.scene;
	if AnlyLightCommon then
		return scene;
	end
	if not mapid then
		return scene;
	end
	local map = SceneLight[mapid];
	if not map then
		return scene;
	end
	scene = map.scene or scene;
	scene.fieldEffect = scene.fieldEffect == nil and true or scene.fieldEffect;
	scene.fieldShadow = scene.fieldShadow == nil and true or scene.fieldShadow;
	return scene;
end

function Light.GetHorseLight(mapid)
	local light = LightCommon.horse;
	if not mapid then
		return light;
	end
	local map  = SceneLight[mapid];
	if not map then
		return light;
	end
	light = map.horse or light;
	return light;
end

function Light.GetSceneFog(mapid)
	local fog = LightCommon.fog;
	if AnlyLightCommon then
		return fog;
	end
	if not mapid then
		return fog;
	end
	local map = SceneLight[mapid];
	if not map then
		return fog;
	end
	fog = map.fog or fog;
	return fog;
end

function Light.GetUILight()
	local light = LightCommon.ui;
	return light;
end

_G.dwSkyLightColor = 0xffffffff; --角色身上天空光颜色
_G.dwSkyLightPower = 2.0; --角色身上天空光强度

_G.dwSkyBackLightColor = 0xffffffff; --角色身上天空光颜色
_G.dwSkyBackLightPower = 2.0; --角色身上天空光强度


_G.ROLE_XIUXIAN_GAP = 20000
_G.MONSTER_XIUXIAN_GAP = 3000
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
	
	--adder:houxudong  date:2016/8/10 18:08:10   
	--reason:大摆筵席玩家吃饭状态
	landEat_san = "020";         --坐在地上吃饭
	zhuobianEat_san = "021";     --坐在桌边吃饭
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


