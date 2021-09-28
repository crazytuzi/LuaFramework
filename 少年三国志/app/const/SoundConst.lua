local SoundConst = 
{
    BackGroundMusic = 
    {
        -- pvp背景音乐
        PVP = "audio/BGM_PVP.mp3",
        -- 游戏页面背景音乐
        MAIN = "audio/BGM_Main.mp3",
        PVE= "audio/BGM_PVE.mp3",
        FIGHT= "audio/BGM_Fight.mp3",
    },
    
    -- 游戏音效
    GameSound =
    {
        -- 战斗胜利音效
        BATTLE_WIN = "audio/BGM_Win.mp3",
        
        -- 战斗结束音效
        BATTLE_LOSE = "audio/BGM_Lose.mp3",

        -- -- 选择角色页面 虎卫，谋士，神射，乐师的音效
        -- CHOOSE_HUWEI = "audio/effect_huwei.mp3",
        -- CHOOSE_MOUSHI = "audio/effect_moushi.mp3",
        -- CHOOSE_SHENSHE = "audio/effect_shenshe.mp3",
        -- CHOOSE_YUESHI = "audio/effect_yueshi.mp3",

        -- 选择角色页面行走音效
        CHOOSE_WALK = "audio/effect_walk.mp3",

        --UI_普通按钮点击声效(重)
        BUTTON_NORMAL = "audio/Sound_buttondown.mp3",

        --点击反馈声(短)
        BUTTON_SHORT = "audio/Sound_down.mp3",

        --ui滑动声(长）
        UI_SLIDER = "audio/Sound_slid.mp3",

        --ui list滑动(短)
        LIST_SCROLL= "audio/Sound_slid2.mp3",

        --list 详情展开页
        LIST_UNFOLD = "audio/Sound_page.mp3",

        --开宝箱声音
        BOX_OPEN    = "audio/Sound_open.mp3",

        --数字跳动声音
        SCROLL_NUMBER_LONG = "audio/Sound_num.mp3",
        SCROLL_NUMBER_SHORT = "audio/Sound_num1.mp3",

        --盖章声音
        STAR_SOUND = "audio/Sound_star.mp3",

        --人物跳落 (战斗，阵容)
        KNIGHT_DOWN = "audio/Sound_move.mp3",

        --人物升级(武将强化升级 ，战斗后升级)
        KNIGHT_UPGRADE = "audio/Sound_level1.mp3",

        --人物现身(抽卡，装备精炼)
        KNIGHT_SHOW = "audio/zhuansheng_huoyan.mp3",

        --人物特殊展示(招到高级武将，突破到高级武将时)
        KNIGHT_SPECIAL = "audio/Atomsound_out.mp3",

        --强化突破音效(强化吸收材料，突破特效，战斗重用)
        KNIGHT_EAT_MATERIAL = "audio/Atomsound_shunjian_zhiliao.mp3",

        --武将强化升级音效
        KNIGHT_STRENGTH_UPGRADE = "audio/Atomsound_up.mp3",

        --武将洗炼音效(洗属性时和确认数值时特效同步声效, 战斗中的水系攻击重用)
        KNIGHT_TRAINING = "audio/Atomsound_shunjian_shanghai.mp3",

        --宝物碎片合成(宝物碎片合成时特效同步声效)
        TREASURE_COMPOSE = "audio/Atomsound_up.mp3",

        --竞技场滑动提示声效（竞技场刷新界面滑动时, 战斗中可重用）
        ARENA_SCROLL = "audio/Atomsound_shunjian_juejing.mp3",

        --装备强化（装备强化时特效同步特效）
        ARENA_SCROLL = "audio/zhuansheng_qianghua.mp3",
        
        -- 新章节副本胜利音效
        Dungeon_Hall = "audio/Sound_hail.mp3",
    },
    
    -- 战斗音效
    BattleSound = 
    {
        -- 适用：部队移动下落时声效，stopbg时播放
        BATTLE_MOVE = "audio/Sound_move.mp3",
        
        -- 适用：怪物出现特效同步声效
        BATTLE_APPEAR = "audio/zhuansheng_huoyan.mp3",
        
        -- 适用：技能发动特效时同步声效
        BATTLE_SKILL = "audio/Atomsound_up.mp3",
        
        -- 适用：合击技能启动拉幕时同步声效
        BATTLE_SUPER_SKILL = "audio/Atomsound_out.mp3",
        
        -- 适用：人物死亡特效时同步音效
        BATTLE_DEAD = "audio/Atomsound_shunjian_juejing.mp3",
        
        -- 适用：战斗中宝箱掉落声，掉一次响一次
        BATTLE_BOX = "audio/Sound_box.mp3",

        -- 组队pvp里碰撞
        BATTLE_BIGHURT = "Fsound_bighurtpound.mp3",
    }
}

return SoundConst

