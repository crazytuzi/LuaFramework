
FightSkill.nSaveSkillPointGroup = 53;
FightSkill.nSaveCostSkillPoint  = 1;

FightSkill.MAGIC_INVALID		= 0;		-- 无效的魔法属性ID
FightSkill.MAGIC_VALUE_NUM		= 3;		-- 魔法属性参数个数
FightSkill.NORMAL_SKILL_COUNT	= 4;

FightSkill.SkillTypeDef = 
{
    skill_type_none = 0, --无
    skill_type_melee = 1,  --格斗技能
    skill_type_inst_single = 2, --立即单体
    skill_type_passivity = 3, --被动状态
    skill_type_inst_missile = 4, --立即子弹
    skill_type_missile = 5, --子弹
};

FightSkill.STATE_TIME_TYPE = 
{
    state_time_normal = 0,      --普通状态效果，状态效果的时间由技能设定决定。存档时不记录该状态。
    state_time_gametime = 1,    --状态效果的存在截止日期以玩家的游戏时间为准。如果还没过期，则存档时会记录下来。
    state_time_truetime = 2,    --状态效果的存在截止日期以真实时间为准。如果还没过期，则存档时会记录下来。
    state_time_leavemap = 3,    --普通状态效果，状态效果的时间由技能设定决定。存档时不记录该状态。离开地图不删除
};



FightSkill.nInitSkillPoint      = 20; --玩家初始技能点
FightSkill.nAddLeveUpSkillPoint = 1;  --玩家升级获得技能点
FightSkill.nCostGoldLevelResetSkill = 50; --需要消耗金币的等级
FightSkill.nCostGoldResetSkill = 50; --重设技能点消耗的金币

FightSkill.tbSkillConstant = {
    emKEHitParam0Pos          = 0,
    emKEHitParam1Pos          = 1,
    emKEMissParam0Pos         = 2,
    emKEMissParam1Pos         = 3,
    emKEDeadlyStrikeParam0Pos = 4,
    emKEDeadlyStrikeParam1Pos = 5,
    emKESeriesResistParam0Pos = 6,
    emKESeriesResistParam1Pos = 7,
    emKESeriesTrimParam0Pos   = 8,
    emKESeriesTrimParam1Pos   = 9,
    emKEStateBaseRateParamPos = 10,
    emKEStateBaseTimeParamPos = 11,
}