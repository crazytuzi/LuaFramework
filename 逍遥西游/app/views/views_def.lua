KANG_TTF_FONT = "Arial-BoldMT"
FONT_NAME_MISSION = "Arial-BoldMT"
ITEM_NUM_FONT = "Arial-BoldMT"
REPLACECHAR_FOR_INVALIDNAME = "?"
REPLACECHAR_FOR_INVALIDTIP = "?"
REPLACECHAR_FOR_INVALIDMSG = "?"
VIEW_DEF_NORMAL_COLOR = ccc3(255, 255, 255)
VIEW_DEF_WARNING_COLOR = ccc3(255, 0, 0)
VIEW_DEF_PGREEN_COLOR = ccc3(0, 200, 0)
VIEW_DEF_DarkText_COLOR = ccc3(147, 73, 63)
VIEW_DEF_DarkText_COLORStr = "r:147,g:76,b:63"
VIP_LELVEL_ZHUBO = 10000
VIP_LELVEL_XSZDY = 10002
VIP_LELVEL_YaoHuang = 20001
VIP_LELVEL_YaoHou = 20002
LoginDlgRolePosition = ccp(328, -191)
Def_Show_PROPERTY_PACC_DelValue = 0.85
Def_Show_PROPERTY_XiXueKuangBaoChengDu_DelValue = 0.5
Def_Show_PROPERTY_AiHaoKuangBaoChengDu_DelValue = 0.5
SCROLLVIEW_EVENT_SCROLL_TO_TOP = 0
SCROLLVIEW_EVENT_SCROLL_TO_BOTTOM = 1
SCROLLVIEW_EVENT_SCROLL_TO_LEFT = 2
SCROLLVIEW_EVENT_SCROLL_TO_RIGHT = 3
SCROLLVIEW_EVENT_SCROLLING = 4
SCROLLVIEW_EVENT_BOUNCE_TOP = 5
SCROLLVIEW_EVENT_BOUNCE_BOTTOM = 6
SCROLLVIEW_EVENT_BOUNCE_LEFT = 7
SCROLLVIEW_EVENT_BOUNCE_RIGHT = 8
TMZZ_Time_Page = 1
TMZZ_Team_Page1 = 2
TMZZ_Team_Page2 = 3
TMZZ_MyTeam_Page = 4
JIFEN_RANK_VIEW = 1
JIFEN_SHOP_VIEW = 2
MainRole_Beibao_Page = 1
MainRole_Cangku_Page = 2
Fabao_ZhuDong_Page = 1
Fabao_BeiDong_Page = 2
Fabao_BD_ShuXing_Page = 1
Fabao_BD_JiNeng_Page = 2
Fabao_BD_FaYin_Page = 3
FabaoXiuLian_ShengLevel_Page = 1
FabaoXiuLian_ShengStar_Page = 2
FabaoShop_ZhuDong_Page = 1
FabaoShop_BeiDong_Page = 2
FabaoShop_CaiLiao_Page = 3
Shop_Equip_Page = 1
Shop_Drug_Page = 2
Shop_Daoju_Page = 3
Shop_Smsd_Page = 4
Shop_Honour_Tool_Page = 5
Shop_Honour_Nd_Page = 6
Shop_NPC_Yifu_Page = 7
Shop_NPC_Maozi_Page = 8
Shop_NPC_XieziXianglian_Page = 9
Shop_NPC_Yaopin_Page = 10
Shop_NPC_Zawu_Page = 11
Shop_NPC_Wuqi_Page = 12
Shop_Xiayi_Page = 13
Shop_ReChargeGold_Page = 21
Shop_ReChargeTeMai_Page = 22
Shop_ReChargeSilver_Page = 23
Shop_ReChargeCoin_Page = 24
Shop_SHOP_HuoDong_HuoLang1 = 101
Shop_SHOP_HuoDong_HuoLang2 = 102
Shop_SHOP_HuoDong_HuoLang3 = 103
Shop_SHOP_HuoDong_HuoLang4 = 104
KaiFuJiJin_KFJJ_Page = 1
KaiFuJiJin_QMFL_Page = 2
KaiFuJiJin_JJFL_Page = 3
Priority_Btn = 0
Priority_Swallow = Priority_Btn - 100000
Def_Role_Name = {
  [RACE_REN] = "人",
  [RACE_MO] = "魔",
  [RACE_XIAN] = "仙",
  [RACE_GUI] = "鬼"
}
Def_Gender_Name = {
  [HERO_MALE] = "男",
  [HERO_FEMALE] = "女",
  [HERO_ANY] = ""
}
Def_Race_Res_Para_Dict = {
  [RACE_REN] = "ren",
  [RACE_MO] = "mo",
  [RACE_XIAN] = "xian",
  [RACE_GUI] = "gui"
}
Def_Pro_Name = {
  [PROPERTY_KFENG] = "抗风",
  [PROPERTY_KHUO] = "抗火",
  [PROPERTY_KSHUI] = "抗水",
  [PROPERTY_KLEI] = "抗雷",
  [PROPERTY_KHUNLUAN] = "抗混乱",
  [PROPERTY_KFENGYIN] = "抗封印",
  [PROPERTY_KHUNSHUI] = "抗昏睡",
  [PROPERTY_KZHONGDU] = "抗中毒",
  [PROPERTY_KZHENSHE] = "抗虹吸",
  [PROPERTY_KSHUAIRUO] = "抗衰弱",
  [PROPERTY_KXIXUE] = "抗吸血",
  [PROPERTY_KAIHAO] = "抗哀嚎",
  [PROPERTY_KYIWANG] = "抗遗忘",
  [PROPERTY_PDEFEND] = "物理吸收率",
  [PROPERTY_PACC] = "命中率",
  [PROPERTY_ADDFENLIE] = "分裂",
  [PROPERTY_PSBL] = "闪避率",
  [PROPERTY_QHSH] = "加强物理伤害",
  [PROPERTY_PCRIT] = "致命几率",
  [PROPERTY_PKUANGBAO] = "狂暴几率",
  [PROPERTY_PLJPRO] = "连击率",
  [PROPERTY_PLJTIMES] = "连击次数",
  [PROPERTY_PWLFJPRO] = "物理反击几率",
  [PROPERTY_PWLFJTIMES] = "物理反击次数",
  [PROPERTY_PASSIVE_PHYSICAL_RATE] = "忽视防御几率",
  [PROPERTY_PASSIVE_PHYSICAL] = "忽视防御程度",
  [PROPERTY_PASSIVE_USEMAGIC_GONG_RATE] = string.format("被攻击时释放%s", data_getSkillName(30050)),
  [PROPERTY_PASSIVE_USEMAGIC_SU_RATE] = string.format("被攻击时释放%s", data_getSkillName(30055)),
  [PROPERTY_PASSIVE_USEMAGIC_FANG_RATE] = string.format("被攻击时释放%s", data_getSkillName(30045)),
  [PROPERTY_PASSIVE_USEMAGIC_SHUI_RATE] = "附水攻击",
  [PROPERTY_PASSIVE_USEMAGIC_HUO_RATE] = "附火攻击",
  [PROPERTY_PASSIVE_USEMAGIC_FENG_RATE] = "附风攻击",
  [PROPERTY_PASSIVE_USEMAGIC_LEI_RATE] = "附雷攻击",
  [PROPERTY_PFYL] = "防御",
  [PROPERTY_WXJIN] = "金",
  [PROPERTY_WXMU] = "木",
  [PROPERTY_WXSHUI] = "水",
  [PROPERTY_WXHUO] = "火",
  [PROPERTY_WXTU] = "土",
  [PROPERTY_KE_WXJIN] = "强克金",
  [PROPERTY_KE_WXMU] = "强克木",
  [PROPERTY_KE_WXTU] = "强克土",
  [PROPERTY_KE_WXSHUI] = "强克水",
  [PROPERTY_KE_WXHUO] = "强克火",
  [PROPERTY_STRENGTHEN_MAGIC_SHUI] = "加强水",
  [PROPERTY_STRENGTHEN_MAGIC_FENG] = "加强风",
  [PROPERTY_STRENGTHEN_MAGIC_HUO] = "加强火",
  [PROPERTY_STRENGTHEN_MAGIC_LEI] = "加强雷",
  [PROPERTY_STRENGTHEN_MAGIC_HUNLUAN_RATE] = "加强混乱",
  [PROPERTY_STRENGTHEN_MAGIC_HUNSHUI_RATE] = "加强昏睡",
  [PROPERTY_STRENGTHEN_MAGIC_FENGYIN_RATE] = "加强封印",
  [PROPERTY_STRENGTHEN_MAGIC_DU_RATE] = "加强中毒",
  [PROPERTY_STRENGTHEN_MAGIC_DU] = "加强中毒伤害",
  [PROPERTY_STRENGTHEN_MAGIC_GONG] = "加强加攻法术效果",
  [PROPERTY_STRENGTHEN_MAGIC_SU] = "加强加速法术效果",
  [PROPERTY_STRENGTHEN_MAGIC_FANG] = "加强加防法术效果",
  [PROPERTY_STRENGTHEN_MAGIC_ZHEN] = "加强虹吸",
  [PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO_RATE] = "加强衰弱几率",
  [PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO] = "加强衰弱",
  [PROPERTY_STRENGTHEN_MAGIC_XIXUE_RATE] = "加强吸血几率",
  [PROPERTY_STRENGTHEN_MAGIC_XIXUE] = "加强吸血",
  [PROPERTY_STRENGTHEN_MAGIC_AIHAO_RATE] = "加强哀嚎几率",
  [PROPERTY_STRENGTHEN_MAGIC_AIHAO] = "加强哀嚎",
  [PROPERTY_STRENGTHEN_MAGIC_YIWANG_RATE] = "加强遗忘",
  [PROPERTY_STRENGTHEN_MAGIC_YIWANG] = "加强遗忘程度",
  [PROPERTY_MAGICKUANGBAO_SHUI_RATE] = "水系狂暴几率",
  [PROPERTY_MAGICKUANGBAO_FENG_RATE] = "风系狂暴几率",
  [PROPERTY_MAGICKUANGBAO_HUO_RATE] = "火系狂暴几率",
  [PROPERTY_MAGICKUANGBAO_LEI_RATE] = "雷系狂暴几率",
  [PROPERTY_MAGICKUANGBAO_XIXUE_RATE] = "吸血狂暴几率",
  [PROPERTY_MAGICKUANGBAO_XIXUE] = "吸血狂暴程度",
  [PROPERTY_MAGICKUANGBAO_AIHAO_RATE] = "哀嚎狂暴几率",
  [PROPERTY_MAGICKUANGBAO_AIHAO] = "哀嚎狂暴程度",
  [PROPERTY_FKFENG] = "忽视抗风",
  [PROPERTY_FKHUO] = "忽视抗火",
  [PROPERTY_FKSHUI] = "忽视抗水",
  [PROPERTY_FKLEI] = "忽视抗雷",
  [PROPERTY_FKHUNLUAN] = "忽视抗混",
  [PROPERTY_FKFENGYIN] = "忽视抗封印",
  [PROPERTY_FKHUNSHUI] = "忽视抗昏睡",
  [PROPERTY_FKZHONGDU] = "忽视抗中毒",
  [PROPERTY_FKZHENSHE] = "忽视抗虹吸",
  [PROPERTY_FPDEFEND] = "忽视物理吸收率",
  [PROPERTY_FPCRIT] = "抗致命几率",
  [PROPERTY_PKFTLV] = "抗反震程度",
  [PROPERTY_PFSBL] = "忽视躲闪率",
  [PROPERTY_PFWLFJPRO] = "忽视物理反击",
  [PROPERTY_FKSHUAIRUO] = "忽视抗衰弱",
  [PROPERTY_FKXIXUE] = "忽视抗吸血",
  [PROPERTY_FKAIHAO] = "忽视抗哀嚎",
  [PROPERTY_FKYIWANG] = "忽视抗遗忘",
  [PROPERTY_DEL_DU] = "抗毒伤",
  [PROPERTY_KANGNEIDAN_CALD] = "抗隔山打牛",
  [PROPERTY_KANGNEIDAN_HXWB] = "抗天魔解体",
  [PROPERTY_KANGNEIDAN_SSRS] = "抗浩然正气",
  [PROPERTY_KANGNEIDAN_LXYD] = "抗分光化影",
  [PROPERTY_KANGNEIDAN_MZYL] = "抗青面獠牙",
  [PROPERTY_KANGNEIDAN_MRCM] = "抗小楼夜哭",
  [PROPERTY_GROWUP] = "成长率",
  [PROPERTY_FTPRO] = "反震率",
  [PROPERTY_FTLV] = "反震程度",
  [PROPERTY_DEL_ZHEN] = "抵消反震伤害",
  [PROPERTY_ADD_XIXUEHUIXUE] = "加强吸血回血"
}
ZQSKILL_ADDPRO_DESC_DICT = {
  [PROPERTY_HP] = "增加气血",
  [PROPERTY_MP] = "增加法力",
  [PROPERTY_AP] = "增加攻击",
  [PROPERTY_SP] = "增加速度",
  [PROPERTY_PACC] = "增加命中率",
  [PROPERTY_PLJPRO] = "增加连击率",
  [PROPERTY_PKUANGBAO] = "增加狂暴几率",
  [PROPERTY_PCRIT] = "增加致命几率",
  [PROPERTY_PASSIVE_PHYSICAL_RATE] = "增加忽视防御几率",
  [PROPERTY_PASSIVE_PHYSICAL] = "增加忽视防御程度",
  [PROPERTY_STRENGTHEN_MAGIC_HUO] = "增加火系杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_FENG] = "增加风系杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_LEI] = "增加雷系杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_SHUI] = "增加水系杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO_RATE] = "增加衰弱几率",
  [PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO] = "增加衰弱杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_XIXUE_RATE] = "增加吸血几率",
  [PROPERTY_STRENGTHEN_MAGIC_XIXUE] = "增加吸血杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_AIHAO_RATE] = "增加哀嚎几率",
  [PROPERTY_STRENGTHEN_MAGIC_AIHAO] = "增加哀嚎杀伤力",
  [PROPERTY_STRENGTHEN_MAGIC_YIWANG_RATE] = "增加遗忘几率",
  [PROPERTY_STRENGTHEN_MAGIC_YIWANG] = "增加遗忘杀伤力",
  [PROPERTY_PDEFEND] = "增加抗物理",
  [PROPERTY_KZHENSHE] = "增加抗虹吸",
  [PROPERTY_KHUO] = "增加抗火",
  [PROPERTY_KSHUI] = "增加抗水",
  [PROPERTY_KLEI] = "增加抗雷",
  [PROPERTY_KFENG] = "增加抗风",
  [PROPERTY_KHUNLUAN] = "增加抗混乱",
  [PROPERTY_KHUNSHUI] = "增加抗昏睡",
  [PROPERTY_KFENGYIN] = "增加抗封印",
  [PROPERTY_KZHONGDU] = "增加抗中毒",
  [PROPERTY_KSHUAIRUO] = "增加抗衰弱",
  [PROPERTY_KXIXUE] = "增加抗吸血",
  [PROPERTY_KAIHAO] = "增加抗哀嚎",
  [PROPERTY_KYIWANG] = "增加抗遗忘"
}
Def_Pro_ValueType = {
  [PROPERTY_HP] = Pro_Value_NUM_TYPE,
  [PROPERTY_MP] = Pro_Value_NUM_TYPE,
  [PROPERTY_AP] = Pro_Value_NUM_TYPE,
  [PROPERTY_SP] = Pro_Value_NUM_TYPE,
  [PROPERTY_KFENG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KHUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KSHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KLEI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KHUNLUAN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KFENGYIN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KHUNSHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KZHONGDU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KZHENSHE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KSHUAIRUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KXIXUE] = Pro_Value_NUM_TYPE,
  [PROPERTY_KAIHAO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KYIWANG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PDEFEND] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PACC] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_ADDFENLIE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PSBL] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_QHSH] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PCRIT] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PKUANGBAO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PLJPRO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PLJTIMES] = Pro_Value_NUM_TYPE,
  [PROPERTY_PWLFJPRO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PWLFJTIMES] = Pro_Value_NUM_TYPE,
  [PROPERTY_PASSIVE_PHYSICAL_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_PHYSICAL] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_GONG_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_SU_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_FANG_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_SHUI_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_HUO_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_FENG_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PASSIVE_USEMAGIC_LEI_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PFYL] = Pro_Value_NUM_TYPE,
  [PROPERTY_WXJIN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_WXMU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_WXSHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_WXHUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_WXTU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KE_WXJIN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KE_WXMU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KE_WXTU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KE_WXSHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_KE_WXHUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_SHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_FENG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_HUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_LEI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_HUNLUAN_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_HUNSHUI_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_FENGYIN_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_DU_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_DU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_GONG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_SU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_FANG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_ZHEN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_XIXUE_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_XIXUE] = Pro_Value_NUM_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_AIHAO_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_AIHAO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_YIWANG_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_STRENGTHEN_MAGIC_YIWANG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_SHUI_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_FENG_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_HUO_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_LEI_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_XIXUE_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_XIXUE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_AIHAO_RATE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_MAGICKUANGBAO_AIHAO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKFENG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKHUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKSHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKLEI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKHUNLUAN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKFENGYIN] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKHUNSHUI] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKZHONGDU] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKZHENSHE] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FPDEFEND] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FPCRIT] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PKFTLV] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PFSBL] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_PFWLFJPRO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKSHUAIRUO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKXIXUE] = Pro_Value_NUM_TYPE,
  [PROPERTY_FKAIHAO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FKYIWANG] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_DEL_DU] = Pro_Value_NUM_TYPE,
  [PROPERTY_KANGNEIDAN_CALD] = Pro_Value_NUM_TYPE,
  [PROPERTY_KANGNEIDAN_HXWB] = Pro_Value_NUM_TYPE,
  [PROPERTY_KANGNEIDAN_SSRS] = Pro_Value_NUM_TYPE,
  [PROPERTY_KANGNEIDAN_LXYD] = Pro_Value_NUM_TYPE,
  [PROPERTY_KANGNEIDAN_MZYL] = Pro_Value_NUM_TYPE,
  [PROPERTY_KANGNEIDAN_MRCM] = Pro_Value_NUM_TYPE,
  [PROPERTY_GROWUP] = Pro_Value_CZL_TYPE,
  [PROPERTY_FTPRO] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_FTLV] = Pro_Value_PERCENT_TYPE,
  [PROPERTY_DEL_ZHEN] = Pro_Value_NUM_TYPE,
  [PROPERTY_ADD_XIXUEHUIXUE] = Pro_Value_PERCENT_TYPE
}
Def_KangViewShowSeq = {
  {
    name = "法术抗性",
    lineNum = 2,
    pro = {
      PROPERTY_KFENG,
      PROPERTY_KHUO,
      PROPERTY_KSHUI,
      PROPERTY_KLEI,
      PROPERTY_KHUNLUAN,
      PROPERTY_KFENGYIN,
      PROPERTY_KHUNSHUI,
      PROPERTY_KZHONGDU,
      PROPERTY_KZHENSHE,
      PROPERTY_KSHUAIRUO,
      PROPERTY_KXIXUE,
      PROPERTY_KAIHAO,
      PROPERTY_KYIWANG
    }
  },
  {
    name = "物理属性",
    lineNum = 1,
    pro = {
      PROPERTY_PDEFEND,
      PROPERTY_PACC,
      PROPERTY_PSBL,
      PROPERTY_ADDFENLIE,
      PROPERTY_QHSH,
      PROPERTY_PCRIT,
      PROPERTY_PKUANGBAO,
      PROPERTY_PLJPRO,
      PROPERTY_PLJTIMES,
      PROPERTY_PWLFJPRO,
      PROPERTY_PWLFJTIMES,
      PROPERTY_PASSIVE_PHYSICAL_RATE,
      PROPERTY_PASSIVE_PHYSICAL,
      PROPERTY_PASSIVE_USEMAGIC_GONG_RATE,
      PROPERTY_PASSIVE_USEMAGIC_SU_RATE,
      PROPERTY_PASSIVE_USEMAGIC_FANG_RATE,
      PROPERTY_PASSIVE_USEMAGIC_SHUI_RATE,
      PROPERTY_PASSIVE_USEMAGIC_HUO_RATE,
      PROPERTY_PASSIVE_USEMAGIC_FENG_RATE,
      PROPERTY_PASSIVE_USEMAGIC_LEI_RATE,
      PROPERTY_PFYL
    }
  },
  {
    name = "五行属性",
    lineNum = 2,
    pro = {
      PROPERTY_WXJIN,
      PROPERTY_WXMU,
      PROPERTY_WXSHUI,
      PROPERTY_WXHUO,
      PROPERTY_WXTU,
      PROPERTY_KE_WXJIN,
      PROPERTY_KE_WXMU,
      PROPERTY_KE_WXTU,
      PROPERTY_KE_WXSHUI,
      PROPERTY_KE_WXHUO
    }
  },
  {
    name = "法术增强",
    lineNum = 1,
    pro = {
      PROPERTY_STRENGTHEN_MAGIC_SHUI,
      PROPERTY_STRENGTHEN_MAGIC_FENG,
      PROPERTY_STRENGTHEN_MAGIC_HUO,
      PROPERTY_STRENGTHEN_MAGIC_LEI,
      PROPERTY_STRENGTHEN_MAGIC_HUNLUAN_RATE,
      PROPERTY_STRENGTHEN_MAGIC_HUNSHUI_RATE,
      PROPERTY_STRENGTHEN_MAGIC_FENGYIN_RATE,
      PROPERTY_STRENGTHEN_MAGIC_DU_RATE,
      PROPERTY_STRENGTHEN_MAGIC_DU,
      PROPERTY_STRENGTHEN_MAGIC_GONG,
      PROPERTY_STRENGTHEN_MAGIC_SU,
      PROPERTY_STRENGTHEN_MAGIC_FANG,
      PROPERTY_STRENGTHEN_MAGIC_ZHEN,
      PROPERTY_STRENGTHEN_MAGIC_AIHAO_RATE,
      PROPERTY_STRENGTHEN_MAGIC_AIHAO,
      PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO_RATE,
      PROPERTY_STRENGTHEN_MAGIC_SHUAIRUO,
      PROPERTY_STRENGTHEN_MAGIC_XIXUE_RATE,
      PROPERTY_STRENGTHEN_MAGIC_XIXUE,
      PROPERTY_ADD_XIXUEHUIXUE,
      PROPERTY_STRENGTHEN_MAGIC_YIWANG_RATE,
      PROPERTY_STRENGTHEN_MAGIC_YIWANG,
      PROPERTY_MAGICKUANGBAO_SHUI_RATE,
      PROPERTY_MAGICKUANGBAO_FENG_RATE,
      PROPERTY_MAGICKUANGBAO_HUO_RATE,
      PROPERTY_MAGICKUANGBAO_LEI_RATE,
      PROPERTY_MAGICKUANGBAO_AIHAO_RATE,
      PROPERTY_MAGICKUANGBAO_AIHAO,
      PROPERTY_MAGICKUANGBAO_XIXUE_RATE,
      PROPERTY_MAGICKUANGBAO_XIXUE,
      PROPERTY_FKFENG,
      PROPERTY_FKHUO,
      PROPERTY_FKSHUI,
      PROPERTY_FKLEI,
      PROPERTY_FKHUNLUAN,
      PROPERTY_FKFENGYIN,
      PROPERTY_FKHUNSHUI,
      PROPERTY_FKZHONGDU,
      PROPERTY_FKZHENSHE,
      PROPERTY_FPDEFEND,
      PROPERTY_FPCRIT,
      PROPERTY_PKFTLV,
      PROPERTY_PFSBL,
      PROPERTY_PFWLFJPRO,
      PROPERTY_FKSHUAIRUO,
      PROPERTY_FKXIXUE,
      PROPERTY_FKAIHAO,
      PROPERTY_FKYIWANG
    }
  },
  {
    name = "其他",
    lineNum = 1,
    pro = {
      PROPERTY_DEL_DU,
      PROPERTY_KANGNEIDAN_CALD,
      PROPERTY_KANGNEIDAN_HXWB,
      PROPERTY_KANGNEIDAN_SSRS,
      PROPERTY_KANGNEIDAN_LXYD,
      PROPERTY_KANGNEIDAN_MZYL,
      PROPERTY_KANGNEIDAN_MRCM,
      PROPERTY_FTPRO,
      PROPERTY_FTLV,
      PROPERTY_DEL_ZHEN
    }
  }
}
AdviceAddPointKeys = {
  [PROPERTY_GenGu] = "TJJDGG",
  [PROPERTY_Lingxing] = "TJJDLX",
  [PROPERTY_LiLiang] = "TJJDLL",
  [PROPERTY_MinJie] = "TJJDMJ"
}
MainUISceneZOrder = {
  map = 20,
  mainMenu = 100,
  progressBarPrompt = 101,
  mainmenuQuickUseView = 102,
  warScene = 200,
  popView = 200,
  menuView = 200,
  warResultView = 200,
  fubenView = 200,
  fubenQuickUseView = 200,
  fubenEnemyView = 200,
  popDetailView = 204,
  kejuEntrance = 205,
  GuideSwallowMessage = 208,
  popZView = 210,
  popSafetylock = 211,
  cdView = 250,
  downTipsView = 2500,
  storyView = 3000,
  swallowMessage = 9999
}
MissionKind_Des = {
  [MissionKind_Main] = "主线",
  [MissionKind_Branch] = "支线",
  [MissionKind_Shimen] = "师门",
  [MissionKind_Faction] = "帮派",
  [MissionKind_Activity] = "日常",
  [MissionKind_Jingying] = "精英",
  [MissionKind_Guide] = "指引",
  [MissionKind_Shilian] = "试炼",
  [MissionKind_SanJieLiLian] = "历练",
  [MissionKind_Jiehun] = "结婚",
  [MissionKind_Jieqi] = "结契"
}
MarketShow_InitShow_SilverView = 1
MarketShow_InitShow_CoinView = 2
BaitanShow_InitShow_ShoppingView = 1
BaitanShow_InitShow_StallView = 2
HeroShow_InitShow_SkillView = 1
HeroShow_InitShow_JinhuaView = 2
HeroShow_InitShow_ProView = 3
HeroShow_InitShow_KangView = 4
HeroShow_InitShow_EquipView = 5
HeroShow_InitShow_PetChooseView = 6
PetShow_InitShow_PropertyView = 1
PetShow_InitShow_Potential = 2
PetShow_InitShow_SkillView = 3
PetShow_InitShow_SkillLearnView = 4
PetShow_InitShow_ItemView = 5
PetShow_InitShow_NeidanView = 6
PetShow_InitShow_XiChongView = 7
PetShow_InitShow_LianYaoView = 8
PetShow_InitShow_TuJianView = 9
HuobanShow_ShowHuobanView = 1
HuobanShow_GetHuobanView = 2
HuobanShow_InitShow_PackageView = 1
HuobanShow_InitShow_SkillView = 2
ZuoqiShow_SkillView = 1
ZuoqiShow_UpgradeView = 2
ZuoqiShow_GuanzhiView = 3
ZuoqiShow_ItemView = 4
CatchPetShow_BaseView = 1
CatchPetShow_DetailView = 2
StoreShow_ShopView = 1
StoreShow_RechargeView = 2
StoreShow_FanLiView = 3
HuodongShow_EventView = 1
HuodongShow_GiftView = 2
HuodongShow_ScheduleView = 3
MeiRiHuoDongShow_rchdView = 1
MeiRiHuoDongShow_xshdView = 2
MeiRiHuoDongShow_jjkqView = 3
SkillShow_ShiMenView = 1
SkillShow_LifeView = 2
SkillShow_CloseView = 3
SkillShow_CloseIndex_ZhuDong = 1
SkillShow_CloseIndex_BeiDong = 2
MapRoleStatus_AutoRoute = 1
MapRoleStatus_Captain = 2
MapRoleStatus_InBattle = 3
MapRoleStatus_CaptainNotFull = 4
MapRoleStatus_TaskCanAccept = 5
MapRoleStatus_TaskCanCommit = 6
MapRoleStatus_TaskNotComplete = 7
MapRoleStatus_AutoXunluo = 8
KejuTypeDes = {
  [KejuType_1] = "乡试",
  [KejuType_2] = "省试",
  [KejuType_3] = "殿试"
}
NameColor_MainHero = {
  [0] = ccc3(119, 216, 40),
  [1] = ccc3(255, 163, 32),
  [2] = ccc3(35, 201, 243),
  [3] = ccc3(254, 59, 59),
  [4] = ccc3(255, 0, 120)
}
NameColor_Pet = {
  [0] = ccc3(255, 150, 0),
  [1] = ccc3(233, 155, 241),
  [2] = ccc3(198, 0, 255),
  [3] = ccc3(0, 190, 255),
  [4] = ccc3(255, 0, 120)
}
NameColor_Item = {
  [0] = ccc3(255, 204, 0),
  [1] = ccc3(255, 204, 0),
  [2] = ccc3(68, 187, 255),
  [3] = ccc3(222, 123, 255),
  [4] = ccc3(250, 71, 0)
}
BpNameColor = ccc3(25, 209, 255)
BpNameColorOfBpWarAttacker = ccc3(255, 0, 0)
BpNameColorOfBpWarDefender = ccc3(0, 255, 234)
MsgColor_WolrdChannel = ccc3(212, 160, 254)
MsgColor_LocalChannel = ccc3(0, 229, 184)
MsgColor_TeamChannel = ccc3(230, 201, 41)
MsgColor_SysChannel = ccc3(255, 37, 26)
MsgColor_HelpChannel = ccc3(106, 211, 83)
MsgColor_BpChannel = ccc3(25, 209, 255)
MsgColor_KuaixunChannel = ccc3(255, 148, 9)
MsgColor_XinxiChannel = ccc3(233, 233, 233)
MsgColor_WolrdChannel_s = ccc3(248, 240, 208)
MsgColor_TeamChannel_s = ccc3(248, 240, 208)
MsgColor_SysChannel_s = ccc3(248, 240, 208)
MsgColor_HelpChannel_s = ccc3(248, 240, 208)
MsgColor_BpChannel_s = ccc3(248, 240, 208)
MsgColor_KuaixunChannel_s = ccc3(248, 240, 208)
MsgColor_XinxiChannel_s = ccc3(248, 240, 208)
MsgColor_LocalSysChannel_s = ccc3(248, 240, 208)
HEAD_OFF_X = 0
HEAD_OFF_Y = 8
AUREOLE_OFF_X = -20
AUREOLE_OFF_Y = 110
LIANYAOSHI_SHOWList = {
  [PROPERTY_PDEFEND] = 1,
  [PROPERTY_KHUO] = 2,
  [PROPERTY_KSHUI] = 3,
  [PROPERTY_KLEI] = 4,
  [PROPERTY_KFENG] = 5,
  [PROPERTY_KHUNLUAN] = 6,
  [PROPERTY_KHUNSHUI] = 7,
  [PROPERTY_KZHONGDU] = 8,
  [PROPERTY_KFENGYIN] = 9,
  [PROPERTY_KZHENSHE] = 10,
  [PROPERTY_KYIWANG] = 11,
  [PROPERTY_KAIHAO] = 12
}
TipsShow_Up_Dir = 0
TipsShow_LeftTop_Dir = 1
TipsShow_Left_Dir = 2
TipsShow_RightTop_Dir = 3
TipsShow_Right_Dir = 4
TipsShow_LeftDown_Dir = 5
TipsShow_RightDown_Dir = 6
TipsShow_Down_Dir = 7
Item_Source_JumpTo_Shop_Daoju = 1
Item_Source_JumpTo_Shop_Smsd = 4
Item_Source_JumpTo_Shop_Drug = 5
Item_Source_JumpTo_PvpShop_Neidan = 7
Item_Source_JumpTo_PvpShop_Daoju = 8
Item_Source_JumpTo_Dayanta = 9
Item_Source_JumpTo_Market = 10
Item_Source_JumpTo_Shop_NPC = 11
Item_Source_JumpTo_GuajiMap = 12
Item_Source_JumpTo_Baitan = 13
Item_Source_JumpTo_TTHJ = 14
Item_Source_JumpTo_CangBaoTu = 15
Item_Source_JumpTo_HuoLiView = 16
Item_Source_JumpTo_TianDiQiShu = 17
Item_Source_MoveMapList = {
  Item_Source_JumpTo_Dayanta,
  Item_Source_JumpTo_Shop_NPC,
  Item_Source_JumpTo_GuajiMap,
  Item_Source_JumpTo_TTHJ,
  Item_Source_JumpTo_CangBaoTu,
  Item_Source_JumpTo_TianDiQiShu
}
AttrTipExtra = {
  [PROPERTY_GenGu] = {
    [RACE_REN] = "人族成长\n+20%",
    [RACE_MO] = "魔族成长\n+10%",
    [RACE_GUI] = "鬼族成长\n+20%"
  },
  [PROPERTY_Lingxing] = {
    [RACE_XIAN] = "仙族成长\n+30%",
    [RACE_MO] = "魔族成长\n-40%"
  },
  [PROPERTY_LiLiang] = {
    [RACE_XIAN] = "仙族成长\n-30%",
    [RACE_MO] = "魔族成长\n+30%",
    [RACE_GUI] = "鬼族成长\n-5%"
  },
  [PROPERTY_MinJie] = {
    [RACE_REN] = "人族成长\n-20%",
    [RACE_GUI] = "鬼族成长\n-15%"
  }
}
DynamicLoadTexturePriority_MapBg = 99
Define_EmotionSY = 54
Define_EmotionMoMo = 68
PHB_DEF_ZhuangBei = 1
PHB_DEF_BingQi = 2
PHB_DEF_CaiFu = 3
PHB_DEF_BangPai = 4
PHB_DEF_ChongJi = 5
PHB_DEF_BiWu = 6
PHB_DEF_ZhuangBei_ZB = 10
PHB_DEF_ZhuangBei_RZ = 11
PHB_DEF_ZhuangBei_MZ = 12
PHB_DEF_ZhuangBei_XZ = 13
PHB_DEF_ZhuangBei_GZ = 14
PHB_DEF_BingQi_WQ = 20
PHB_DEF_BingQi_YF = 21
PHB_DEF_BingQi_MZ = 22
PHB_DEF_BingQi_XZ = 23
PHB_DEF_BingQi_XL = 24
PHB_DEF_BingQi_MJ = 25
PHB_DEF_BingQi_PF = 26
PHB_DEF_BingQi_YD = 27
PHB_DEF_BingQi_GJ = 28
PHB_DEF_BingQi_CB = 29
PHB_DEF_CaiFu_YB = 30
PHB_DEF_CaiFu_TQ = 31
PHB_DEF_BangPai_BP = 40
PHB_DEF_ChongJi_CJ = 50
PHB_DEF_BiWu_BW = 60
PHB_DEF_BiWu_XZ = 61
PHB_DEF_RANGE_ALL = 1
PHB_DEF_RANGE_FRIEND = 2
PHB_DEF_RANGE_CITY = 3
PHB_DEF_Data = {
  {
    PHB_DEF_ZhuangBei,
    "装备评价榜",
    PHB_DEF_ZhuangBei_ZB,
    "总榜"
  },
  {
    PHB_DEF_ZhuangBei,
    "装备评价榜",
    PHB_DEF_ZhuangBei_RZ,
    "人族"
  },
  {
    PHB_DEF_ZhuangBei,
    "装备评价榜",
    PHB_DEF_ZhuangBei_MZ,
    "魔族"
  },
  {
    PHB_DEF_ZhuangBei,
    "装备评价榜",
    PHB_DEF_ZhuangBei_XZ,
    "仙族"
  },
  {
    PHB_DEF_ZhuangBei,
    "装备评价榜",
    PHB_DEF_ZhuangBei_GZ,
    "鬼族"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_WQ,
    "武器"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_YF,
    "衣服"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_MZ,
    "帽子"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_XZ,
    "鞋子"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_XL,
    "项链"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_MJ,
    "面具"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_PF,
    "披风"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_YD,
    "腰带"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_GJ,
    "挂件"
  },
  {
    PHB_DEF_BingQi,
    "兵器排行榜",
    PHB_DEF_BingQi_CB,
    "翅膀"
  },
  {
    PHB_DEF_ChongJi,
    "冲级排行榜",
    PHB_DEF_ChongJi_CJ,
    "冲级排行"
  },
  {
    PHB_DEF_BangPai,
    "帮派排行榜",
    PHB_DEF_BangPai_BP,
    "帮派排行"
  },
  {
    PHB_DEF_BiWu,
    "比武排行榜",
    PHB_DEF_BiWu_BW,
    "比武排行"
  },
  {
    PHB_DEF_BiWu,
    "比武排行榜",
    PHB_DEF_BiWu_XZ,
    "血战排行"
  },
  {
    PHB_DEF_CaiFu,
    "财富排行榜",
    PHB_DEF_CaiFu_YB,
    "银币"
  },
  {
    PHB_DEF_CaiFu,
    "财富排行榜",
    PHB_DEF_CaiFu_TQ,
    "铜钱"
  }
}
PHB_DEF_Title_Data = {
  {
    [PHB_DEF_ZhuangBei_ZB] = {
      "名次",
      "昵称",
      "性别种族",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_ZhuangBei_RZ] = {
      "名次",
      "昵称",
      "等级",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_ZhuangBei_MZ] = {
      "名次",
      "昵称",
      "等级",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_ZhuangBei_XZ] = {
      "名次",
      "昵称",
      "等级",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_ZhuangBei_GZ] = {
      "名次",
      "昵称",
      "等级",
      "帮派",
      "装备评价"
    }
  },
  {
    [PHB_DEF_BingQi_WQ] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_YF] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_MZ] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_XZ] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_XL] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_MJ] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_PF] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_YD] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_GJ] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    },
    [PHB_DEF_BingQi_CB] = {
      "名次",
      "昵称",
      "装备名称",
      "帮派",
      "装备评价"
    }
  },
  {
    [PHB_DEF_CaiFu_YB] = {
      "名次",
      "昵称",
      "等级",
      "帮派",
      "银币"
    },
    [PHB_DEF_CaiFu_TQ] = {
      "名次",
      "昵称",
      "等级",
      "帮派",
      "铜钱"
    }
  },
  {
    [PHB_DEF_BangPai_BP] = {
      "名次",
      "帮派名称",
      "帮派等级",
      "帮主",
      "威望"
    }
  },
  {
    [PHB_DEF_ChongJi_CJ] = {
      "名次",
      "昵称",
      "性别种族",
      "帮派",
      "等级"
    }
  },
  {
    [PHB_DEF_BiWu_BW] = {
      "名次",
      "昵称",
      "性别种族",
      "帮派",
      "等级"
    },
    [PHB_DEF_BiWu_XZ] = {
      "名次",
      "昵称",
      "性别种族",
      "帮派",
      "等级",
      "星星数"
    }
  }
}
PHB_DEF_ALL_TYPE_DATA = {
  PHB_DEF_ZhuangBei_ZB,
  PHB_DEF_ZhuangBei_RZ,
  PHB_DEF_ZhuangBei_MZ,
  PHB_DEF_ZhuangBei_XZ,
  PHB_DEF_ZhuangBei_GZ,
  PHB_DEF_BingQi_WQ,
  PHB_DEF_BingQi_YF,
  PHB_DEF_BingQi_MZ,
  PHB_DEF_BingQi_XZ,
  PHB_DEF_BingQi_XL,
  PHB_DEF_BingQi_MJ,
  PHB_DEF_BingQi_PF,
  PHB_DEF_BingQi_YD,
  PHB_DEF_BingQi_GJ,
  PHB_DEF_BingQi_CB,
  PHB_DEF_CaiFu_YB,
  PHB_DEF_CaiFu_TQ,
  PHB_DEF_BangPai_BP,
  PHB_DEF_ChongJi_CJ,
  PHB_DEF_BiWu_BW,
  PHB_DEF_BiWu_XZ
}
