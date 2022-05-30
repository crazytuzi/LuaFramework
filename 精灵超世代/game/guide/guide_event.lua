GuideEvent = GuideEvent or {}

GuideEvent.Update_Guide_Status_Event = "GuideEvent.Update_Guide_Status_Event"

GuideEvent.Update_Guide_Open_Event = "GuideEvent.Update_Guide_Open_Event"

GuideConst = GuideConst or {}

GuideConst.special_id = {
    guild = 10212,          -- 公会剧情,这个剧情的时候不能关闭其他面板
    market = 10510,         -- 同公会剧情
    seerpalace = 10222, 	-- 先知殿剧情
    stronger = 10174, 		-- 变强剧情
    --adventure = 10310,      -- 冒险剧情

    quick_guide = 10120,    -- 快速作战
    hook_guide = 10165, 	-- 挂机收益引导
    --break_guide = 10072,    -- 突破引导的时候,不要弹出物品来源

    home_guide_1 = 10330,
    home_guide_2 = 10340,
    home_guide_3 = 10350,

    shop = 10199, -- 商业街购买引导
    elfin = 10382, -- 精灵引导

    planes = 10372, --位面引导
    -- arena_guide = 10000,    -- 竞技场引导
    holy_dial = 10400, --祈祷引导
    heaven_tips = 10412, --天界副本的挑战说明
    resonate = 10422, --原力水晶引导
    
}

GuideConst.Finger_Speed = 1500  -- 引导手指移动速度
GuideConst.Finger_Min_Time = 0.2 -- 引导手指移动的最低时间
