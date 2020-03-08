_G.ZL_GAMEID = 205
_G.bit = require("bit")
_G.ClientDef_Layer = {
  Default = 0,
  TransparentFX = 1,
  IgnoreRaycast = 2,
  UI = 5,
  FIGHT_UI = 8,
  Building = 9,
  Player = 10,
  NPC = 11,
  UI_Camera = 12,
  Matter = 13,
  SmallBuilding = 14,
  FX = 15,
  FXCG = 16,
  HostPlayer = 17,
  UI_Forever = 18,
  UI_Model1 = 19,
  UI2 = 20,
  Cloud = 21,
  UIFX = 22,
  Fight = 23,
  FightPlayer = 24,
  FlyPlayer = 25,
  PateTextDepth = 26,
  FlyNpc = 27,
  UICG = 29,
  PateText = 30,
  Invisible = 31
}
function _G.get_cull_mask(b)
  return bit.lshift(1, b)
end
_G.default_cull_mask_pre = get_cull_mask(ClientDef_Layer.Default) + get_cull_mask(ClientDef_Layer.Building) + get_cull_mask(ClientDef_Layer.SmallBuilding)
_G.default_cull_mask_post = get_cull_mask(ClientDef_Layer.TransparentFX) + get_cull_mask(ClientDef_Layer.Player) + get_cull_mask(ClientDef_Layer.HostPlayer) + get_cull_mask(ClientDef_Layer.NPC) + get_cull_mask(ClientDef_Layer.Matter) + get_cull_mask(ClientDef_Layer.FX)
_G.default_cull_mask = default_cull_mask_pre + default_cull_mask_post
_G.ui_default_cull_mask = get_cull_mask(ClientDef_Layer.UI) + get_cull_mask(ClientDef_Layer.UI_Forever)
_G.ui_topmost_cull_mask = get_cull_mask(ClientDef_Layer.UI_Forever)
_G.ui_fight_cull_mask = get_cull_mask(ClientDef_Layer.FIGHT_UI)
_G.CameraShakeType = {
  Normal = "cameraShake",
  Small = "cameraShakeSmall",
  Tiny = "cameraShakeTiny"
}
_G.player_model_path = {
  [1] = {
    male = RESPATH.PLAYER_MALE_SWRODMAN,
    female = RESPATH.PLAYER_FEMALE_SWRODMAN
  },
  [2] = {
    male = RESPATH.PLAYER_MALE_SPEARMAN,
    female = RESPATH.PLAYER_FEMALE_SPEARMAN
  },
  [3] = {
    male = RESPATH.PLAYER_MALE_MAGE,
    female = RESPATH.PLAYER_FEMALE_MAGE
  },
  [4] = {
    male = RESPATH.PLAYER_MALE_ARCHER,
    female = RESPATH.PLAYER_FEMALE_ARCHER
  }
}
local mask_to_index_func = function()
  local c = 1
  local t = {}
  for i = 0, 31 do
    t[c] = i
    c = c * 2
  end
  return t
end
function _G.BLANK_TABLE_INIT()
  return {}
end
_G.mask_to_index = mask_to_index_func()
_G.pause_protocol = false
_G.show_render_info = false
_G.log_file_flag = false
_G.unload_unused_func_call = false
_G.Platform = {
  win = 0,
  ios = 1,
  android = 2
}
_G.platform = 0
if Application.platform == RuntimePlatform.IPhonePlayer then
  platform = Platform.ios
elseif Application.platform == RuntimePlatform.Android then
  platform = Platform.android
end
_G.ui_use_global_notify = true
_G.cur_quality_level = 3
_G.max_frame_rate = 30
_G.max_show_players = 20
_G.max_visible_player_high = 35
_G.max_visible_player_mid = 20
_G.max_visible_player_low = 15
_G.max_visible_player = max_visible_player_high
_G.max_visible_player_origin = max_visible_player
_G.max_visible_inner_ratio = 0.4
_G.max_visible_player_inner = 0
_G.max_visible_player_outer = 0
_G.show_nationwar_friend_player = false
_G.show_nationwar_enemy_player = true
_G.max_fx_count = 64
_G.def_far_clip = 600
_G.world_width = 960
_G.world_height = 640
_G.cam_3d_degree = 20
_G.cam_3d_rad = cam_3d_degree / 180 * math.pi
_G.cam_2d_to_3d_scale = 0.013888888888888888
_G.Model_Default_Scale = require("Types.Vector3").Vector3.one * 0.95
_G.Default_Role_Dir = 225
_G.Team_Max_Size = 5
_G.fly_up_time = 0.73
_G.fly_up_ani_time = 1.16
_G.fly_down_time = 0.56
_G.fly_down_ani_time = 0.83
_G.fly_y_min = 400
_G.fly_sidebyside_distance = 64
_G.skyScale = 1.5
_G.LATE_UPDATE_EVENT = 32767
_G.link_defalut_color = "00ff00"
_G.default_name_offset = -0.4
_G.TIAN_YIN_NV_MODEL_ID = 700300007
_G.WAN_DU_NV_MODEL_ID = 700300019
_G.GUIDEPTH = {
  BOTTOMMOST = 1,
  BOTTOM = 2,
  NORMAL = 3,
  TOP = 4,
  TOPMOST = 5,
  TOPMOST2 = 6,
  DEBUG = 7
}
_G.GUI_MAX_DEPTH = 4294967295
_G.GUILEVEL = {
  NON = -1,
  NORMAL = 0,
  MUTEX = 1,
  DEPENDEND = 2
}
_G.StringTable = require("Data.StringTable")
_G.ClientCfg = require("Configs.ClientCfg")
_G.ActionName = {
  Attack = "Attack_c",
  Attack1 = "Attack1_c",
  BeHit = "Hit_c",
  BeHitUp = "HitUp_c",
  BeHitDown = "HitDown_c",
  Defend = "Defend_c",
  Stand = "Stand_c",
  FightStand = "FightStand_c",
  Run = "Run_c",
  FightRun = "FightRun_c",
  SitStand = "Sit_Stand_c",
  SitRun = "Sit_Run_c",
  Magic = "Magic_c",
  Skill1 = "Skill1_c",
  Skill2 = "Skill2_c",
  Death1 = "Death1_c",
  Death2 = "Death2_c",
  Idle1 = "Idle1_c",
  Idle2 = "Idle2_c",
  DeadOnGround = "Hit_Idle2_c",
  Death3 = "Death3_c",
  Revive = "Hit_Idle3_c",
  Ride_Stand = "Sit_Stand_c",
  Ride_Run = "Sit_Run_c",
  Magic_State = "ShiFa_c"
}
function _G.BitOr(...)
  local BitMap = require("Common.BitMap")
  local count = select("#", ...)
  local paramList = {
    ...
  }
  local ret = BitMap.new()
  for i = 1, count do
    ret.Set(paramList[i])
  end
  return ret
end
_G.RoleState = {
  RUN = 1,
  FLY = 2,
  PVP = 3,
  PATROL = 4,
  ESCORT = 5,
  BATTLE = 6,
  TXHW = 7,
  WATCH = 8,
  SXZB = 9,
  JZJX = 10,
  GANGBATTLE = 11,
  PHANTOMCAVE = 12,
  PROTECTED = 13,
  FOLLOW = 14,
  SOLODUNGEON = 15,
  TEAMDUNGEON = 16,
  HUG = 17,
  BEHUG = 18,
  TRANSFORM = 19,
  QMHW = 20,
  WEDDING = 21,
  HULA = 22,
  ZHUXIANJIANZHEN = 23,
  GANG_DUNGEON = 24,
  CROSS_BATTLE = 25,
  GANGCROSS_BATTLE = 26,
  SINGLEBATTLE = 27,
  SINGLEBATTLE_DEATH = 28,
  SINGLEBATTLE_PROTECT = 29,
  PLAYER_PK_ON = 30,
  PLAYER_PK_PROTECTION = 31,
  PLAYER_PK_FORCE_PROTECTION = 32,
  PASSENGER = 33,
  PRISON = 34,
  ROOTS = 35,
  BALL_ARENA = 36,
  GANG_WAR = 37,
  GANG_WAR_ATTACK = 38,
  GANG_WAR_DEFEND = 39,
  GANG_WAR_PROTECT = 40,
  PUPPET = 41
}
_G.RoleState.UNTRANPORTABLE = BitOr(RoleState.ESCORT, RoleState.TXHW, RoleState.SXZB, RoleState.JZJX, RoleState.GANGBATTLE, RoleState.GANGCROSS_BATTLE, RoleState.PHANTOMCAVE, RoleState.QMHW, RoleState.BEHUG, RoleState.WEDDING, RoleState.HULA, RoleState.ZHUXIANJIANZHEN, RoleState.CROSS_BATTLE, RoleState.SINGLEBATTLE, RoleState.PRISON)
_G.RoleState.UNMOVABLE = BitOr(RoleState.ESCORT, RoleState.FOLLOW, RoleState.BEHUG, RoleState.SINGLEBATTLE_DEATH)
_G.RoleType = {
  ROLE = 1,
  NPC = 2,
  PET = 3,
  COMPANION = 4,
  MONSTER = 5,
  ITEM = 6,
  UI = 7,
  DOUDOU = 8,
  CHILD = 9,
  POKEMON = 10,
  GANGWAR_TOWER = 11,
  GANGWAR_GATE = 12,
  GANGWAR_CASTLE = 13
}
_G.BODY_PART = {
  NONE = 0,
  FEET = 1,
  BODY = 2,
  HEAD = 3,
  BONE = 4
}
_G.ModelStatus = {
  NONE = -1,
  NORMAL = 0,
  LOADING = 1,
  DESTROY = 2
}
_G.MoveType = {
  AUTO = 0,
  RUN = 1,
  FLY = 2
}
_G.MSDK_LOGIN_PLATFORM = {
  NON = 0,
  WX = 1,
  QQ = 2,
  WX_GAMECENTER = 3,
  QQHALL = 4,
  GUEST = 5
}
_G.LoginPlatform = 0
_G.MSDK_LOGIN_ERROR_CODE = {
  Succ = 0,
  QQ_UserCancel = 1001,
  WX_NotInstall = 2000,
  WX_NotSupportApi = 2001,
  WX_UserCancel = 2002,
  WX_LoginFail = 2004,
  Local_Invalid = -2,
  Need_Login = 3001,
  Need_Select_Accout = 3003,
  Net_Work_Err = 1003,
  Not_Support_Api = 1005,
  WX_AccessTokenExpired = 2007,
  WX_RefreshTokenExpired = 2008,
  UrlLogin = 3002,
  AccountRefresh = 3004,
  Guest_LoginError = 4002,
  Need_Realname_Auth = 3005
}
_G.MSDK_PAY_CODE = {
  PAY_SUCCESS = 0,
  PAY_ERROR = 1,
  PAY_CANCEL = 2,
  PAY_PARAMERROR = 3,
  PAY_WARNING1 = 1139,
  PAY_WARNING2 = 1140,
  PAY_WARNING3 = 1141
}
_G.MSDK_SHARE_SCENE = {SINGEL = 1, SPACE = 2}
_G.TX_VIP_TYPE = {
  NORMAL = 0,
  QQVIP = 1,
  QQSUPERVIP = 2,
  WXVIP = 3
}
_G.EnterWorldType = {NORMAL = 1, RECONNECT = 2}
_G.LeaveWorldReason = {
  None = 0,
  CHANGE_ROLE = 1,
  CHANGE_ACCOUNT = 2,
  RECONNECT = 3,
  BACK2LOGIN = 4
}
_G.leaveWorldReason = 0
_G.GameState = {
  None = 0,
  LoginAccount = 1,
  LoginMain = 2,
  ChooseRole = 3,
  CreateRole = 4,
  ChooseServer = 5,
  LeavingGameWorld = 98,
  LoadingGameWorld = 99,
  GameWorld = 100
}
_G.CameraDepth = {
  MAP = 0,
  BATTLEMAP = 1,
  UP_BATTLEMAP = 2,
  CLOUD_DOWN = 3,
  SKY_BATTLE_MAP = 4,
  Main3D = 5,
  CREATE_ROLE = 6,
  CLOUD_UP = 7,
  FLY = 8,
  HUD = 9,
  HUD2 = 10,
  FIGHT_DAMAGE = 11,
  UI = 20,
  UIMODEL = 30,
  UI2 = 40,
  GUI = 50,
  UIFX = 60
}
_G.TextEffectStyle = {
  None = 0,
  Shadow = 1,
  Outline = 2,
  Entirely_Shift_Color = 3,
  Single_Char_Shift_Color = 4,
  Entirely_Shift_Bright = 5,
  Gradient = 6,
  GradientOutline = 7
}
_G.TLOGTYPE = {
  NON = "NON",
  WXGROUP = "JoinGangWechatGroup",
  ADDQQFRIEND = "AddQQFriend",
  GROUP = "GameGroupOrCircleHitStatis",
  GUIDE = "GuideStatis",
  STRONG = "StrongStatis",
  FIRSTCHARGE = "FirstRechargeIconHitStatis",
  CHARGERETURN = "RechargeRebateStatis",
  HALFMONTH = "HalfMonthCard",
  GROWFUND = "GrowthFund",
  NEWFUCNTION = "NewFunctionOpen",
  REWARD = "RewardStatis",
  PANELNAME = "ClickUI",
  AUTOADDPOINT = "AutoAddPointSetting",
  JOINACTIVITY = "ClickJoinActivity",
  REMINDORCALENDAR = "ClickActivityRemindOrCalendar",
  DAILYSIGN = "DailySign",
  ONLINEAWARD = "OnlineAward",
  LEVELAWARD = "LevelUpAward",
  RECHARGEAWARD = "RechargeAward",
  JOINGANGACTIVITY = "ClickJoinGangActivity",
  CHATSETTING = "ChatSetting",
  CHATCHANNEL = "ClickChatChannel",
  CHATAREASTATUS = "ChatAreaStatusInMainUI",
  APOLLOSTATUS = "ApolloStatus",
  RANKPAGE = "ClickRankPage",
  GANGSIGNTODAY = "ClickGangSign",
  GANGEXCHANGE = "ClickBuyBangGong",
  PATROL = "BeginOrEndPatrol",
  FORMATION = "UseZhenFa",
  SYSTEMSETTINGSTATUS = "SystemSetting",
  BAOKU = "BaoKuClick",
  MALL = "ShoppingMallIconClick",
  EXCHANGE = "TradeIconClick",
  AWARD = "AwardIconClick",
  FEEDBACK = "TimeLimitRewardIconClick",
  DAILGIFT = "DailyGiftClick",
  TIMELIMITGIFT = "TimeLimitGiftClick",
  ACCUMULATERECHARGE = "RechargeSendGiftClick",
  RECHARGEORRECEIVEAWARD = "ToRechargeOrReceiveAwardClick",
  SHAREINVITECODE = "ShareInviteCodeFrom",
  CLICKTHROWONFACE = "ClickThrowOnFaceNotice",
  VIEWNOTICE = "ViewNotice",
  CLICKNOTICECLINK = "ClickNoticeLink",
  LUCKYSTAR = "LuckyStarClickStatis",
  GC = "GC",
  SHAREACHIEVEMENT = "AchievementShare",
  SNAPSHOT_OPEN_PANEL = "TakePhotoesOpen",
  SNAPSHOT_TAKE_PHTO = "TakePhotoesAction",
  SNAPSHOT_SHARE = "TakePhotoesShare"
}
_G.LoginArg = {}
LoginArg.PLAT_IOS = 0
LoginArg.PLAT_ANDROID = 1
LoginArg.PLAT_PC = 100
LoginArg.UNKNOW = 0
LoginArg.CMCC = 1
LoginArg.CUCC = 2
LoginArg.CTC = 3
LoginArg.KEY_CLIENT_VERSION = 0
LoginArg.KEY_SYSTEM_SOFTWARD = 1
LoginArg.KEY_SYSTEM_HARDWARD = 2
LoginArg.KEY_NETWORK = 3
LoginArg.KEY_SCREEN_WIDTH = 4
LoginArg.KEY_SCREEN_HIGHT = 5
LoginArg.KEY_DENSITY = 6
LoginArg.KEY_CPU_HARDWARD = 7
LoginArg.KEY_MEMORY = 8
LoginArg.KEY_GLRENDER = 9
LoginArg.KEY_GL_VERSION = 10
LoginArg.KEY_DEVICEID = 11
LoginArg.KEY_LOGIN_PRIVILEGE_TYPE = 12
_G.EFunLoginPlat = {}
EFunLoginPlat.EFUN_PLAT_IOS = 2
EFunLoginPlat.EFUN_PLAT_ANDROID = 3
EFunLoginPlat.PLAT_PC = 4
_G.NUMBER_WAN = 10000
_G.ONE_DAY_SECONDS = 86400
_G.DAYS_OF_WEEK = 7
_G.Zero_Int64 = Int64.new(0)
function _G.Zero_Int64_Init()
  return Zero_Int64
end
_G.ShortcutMenuKeys = {
  message = "com.zulong.message",
  jiangli = "com.zulong.jiangli",
  zhouli = "com.zulong.zhouli",
  radio = "com.zulong.radio"
}
_G.use_idip_notice = true
_G.CUR_CODE_VERSION = GameUtil.GetCurCodeVersion and GameUtil.GetCurCodeVersion() or 0
_G.COS_EX_CODE_VERSION = 1
_G.RSA_CODE_VERSION = 2
_G.SAFE_AREA_CODE_VERSION = 3
_G.SAFE_GH_CODE_VERSION = 5
