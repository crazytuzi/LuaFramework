-- --------------------------
-- 道具数据结构
-- hosr
-- --------------------------
ChildrenData = ChildrenData or BaseClass()

function ChildrenData:__init()
    -- 协议数据
    self.child_id = 0   -- "孩子ID"
    self.platform = 0  -- "平台标识"
    self.zone_id = 0    -- "区号"
    self.name = ""
    self.name_changed = 0 -- 改名次数
    self.lev = 0
    self.sex = 0
    self.classes = 0
    self.classes_type = 0 --
    self.status = 0 -- "状态:0:休息,1:出战"
    self.stage = 0 -- "发育阶段:1:胎儿,2:幼年,3成年"
    self.grade = 0 -- "进阶"
    self.base_id = 0
    self.embryo = 0 -- "孕育方式:1单人，2双人"
    self.growth = 0 -- "成长"
    self.health = 0 -- "健康度"
    self.hungry = 0 -- 饱食
    self.maturity = 0 -- 发育值
    self.add_point = 0 -- 额外增加属性点
    self.pregnant_time = 0 -- 受孕时间
    self.birth_time = 0 -- 出生时间
    self.talent = 0 -- 天资

    -- 课程学习情况
    self.study_easy = 0        -- "基础课程次数"}
    self.study_easy_time = 0   -- "基础课程学习时间"}
    self.day_easy = 0          -- "今日基础课程次数"}
    self.study_hard = 0        -- "高级课程次数"}
    self.study_hard_time = 0   -- "高级课程学习时间"}
    self.day_hard = 0          -- "今日高级课程次数"}

    self.follow_id = 0 -- 跟随信息
    self.f_platform = "" -- 跟随信息
    self.f_zone_id = 0-- 跟随信息

    self.hp = 0
    self.mp = 0
    self.hp_max        = 0 -- "生命上限"
    self.mp_max        = 0 -- "魔法上限"
    self.atk_speed     = 0 -- "攻击速度"
    self.phy_dmg       = 0 -- "物攻"
    self.magic_dmg     = 0 -- "魔攻"
    self.phy_def       = 0 -- "物防"
    self.magic_def     = 0 -- "魔防"

    self.hp_aptitude = 0         -- "生命资质"
    self.phy_aptitude = 0        -- "物攻资质"
    self.pdef_aptitude = 0       -- "物防资质"
    self.magic_aptitude = 0      -- "法力资质"
    self.aspd_aptitude = 0       -- "速度资质"
    self.max_hp_aptitude = 0     -- "生命资质上限"
    self.max_phy_aptitude = 0    -- "物攻资质上限"
    self.max_pdef_aptitude = 0   -- "物防资质上限"
    self.max_magic_aptitude = 0  -- "法力资质上限"
    self.max_aspd_aptitude = 0   -- "速度资质上限"

    -- 幼年期学习情况
    self.study_str = 0        -- "力"}
    self.study_con = 0       -- "体"}
    self.study_agi = 0       -- "敏"}
    self.study_mag = 0       -- "智"}
    self.study_end = 0       -- "德"}

    -- 加点方案
    self.pre_str = 0             -- "力量"}
    self.pre_con = 0             -- "体质"}
    self.pre_mag = 0             -- "智力"}
    self.pre_agi = 0             -- "敏捷"}
    self.pre_end = 0             -- "耐力"}

    -- 培养计划
    self.free_study = 0 -- 免费的基础次数
    self.is_init = 1 -- "是否可用"
    self.study_str_easy = 0 -- "力(基础)"
    self.study_con_easy = 0 -- "体(基础)"
    self.study_agi_easy = 0 -- "敏(基础)"
    self.study_mag_easy = 0 -- "智(基础)"
    self.study_end_easy = 0 -- "德(基础)"
    self.study_str_hard = 0 -- "力(高级)"
    self.study_con_hard = 0 -- "体(高级)"
    self.study_agi_hard = 0 -- "敏(高级)"
    self.study_mag_hard = 0 -- "智(高级)"
    self.study_end_hard = 0 -- "德(高级)"
    self.study_str_plan_easy = 0 -- "力(基础-计划)"
    self.study_con_plan_easy = 0 -- "体(基础-计划)"
    self.study_agi_plan_easy = 0 -- "敏(基础-计划)"
    self.study_mag_plan_easy = 0 -- "智(基础-计划)"
    self.study_end_plan_easy = 0 -- "德(基础-计划)"
    self.study_str_plan_hard = 0 -- "力(高级-计划)"
    self.study_con_plan_hard = 0 -- "体(高级-计划)"
    self.study_agi_plan_hard = 0 -- "敏(高级-计划)"
    self.study_mag_plan_hard = 0 -- "智(高级-计划)"
    self.study_end_plan_hard = 0 -- "德(高级-计划)"

    self.parents = {} -- 父母列表
    self.skills = {}
    self.stones = {}
    self.talent_skills = {}
end

-- 协议数据更新
function ChildrenData:SetProto(proto)
    for key,val in pairs(proto) do
        self[key] = val
    end
end

-- 配置数据初始化
function ChildrenData:SetBase(base)
    for key,val in pairs(base) do
        if key ~= "id" then
            self[key] = val
        else
            self.base_id = val
        end
    end
end

function ChildrenData:UpdataPointSetting(data)
    self.pre_str = data.pre_str
    self.pre_con = data.pre_con
    self.pre_mag = data.pre_mag
    self.pre_agi = data.pre_agi
    self.pre_end = data.pre_end
end

function ChildrenData:UpdateStudy(data)
    self.study_easy = data.study_easy
    self.study_easy_time = data.study_easy_time
    self.day_easy = data.day_easy
    self.study_hard = data.study_hard
    self.study_hard_time = data.study_hard_time
    self.day_hard = data.day_hard
    self.maturity = data.maturity

    self.study_str = data.study_str
    self.study_con = data.study_con
    self.study_agi = data.study_agi
    self.study_mag = data.study_mag
    self.study_end = data.study_end

    self.free_study = data.free_study
    self.is_init = data.is_init
    self.study_str_easy = data.study_str_easy
    self.study_con_easy = data.study_con_easy
    self.study_agi_easy = data.study_agi_easy
    self.study_mag_easy = data.study_mag_easy
    self.study_end_easy = data.study_end_easy
    self.study_str_hard = data.study_str_hard
    self.study_con_hard = data.study_con_hard
    self.study_agi_hard = data.study_agi_hard
    self.study_mag_hard = data.study_mag_hard
    self.study_end_hard = data.study_end_hard
    self.study_str_plan_easy = data.study_str_plan_easy
    self.study_con_plan_easy = data.study_con_plan_easy
    self.study_agi_plan_easy = data.study_agi_plan_easy
    self.study_mag_plan_easy = data.study_mag_plan_easy
    self.study_end_plan_easy = data.study_end_plan_easy
    self.study_str_plan_hard = data.study_str_plan_hard
    self.study_con_plan_hard = data.study_con_plan_hard
    self.study_agi_plan_hard = data.study_agi_plan_hard
    self.study_mag_plan_hard = data.study_mag_plan_hard
    self.study_end_plan_hard = data.study_end_plan_hard
end