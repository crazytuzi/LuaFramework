SequenceEventType = {};

SequenceEventType.NONE              = 0;
SequenceEventType.START             = 1;
SequenceEventType.UPDATE            = 2;
SequenceEventType.DELAY             = 3;
SequenceEventType.DELAY_FRAME       = 4;
SequenceEventType.FOREVER           = 5;

--SequenceManager.TriggerEvent(SequenceEventType, nil);

SequenceEventType.Base = {
      TASK_ACTION = 10;             --执行任务动作
      TASK_ACESS = 11;              --接受任务
      TASK_UPDATE = 12;             --任务状态改变
      TASK_FINISH = 13;             --任务完成
      TASK_END = 14;                --任务结束
      TASK_ACESS_DIALOG_END = 15;   --任务接取对话完毕
      TASK_ESCORT_START = 16;       --护送开始
      TASK_ACTION_UPDATE = 17;      --更新任务执行面板

      MOVE_TO_PATH_END = 20;        --寻路完毕
      MOVE_TO_NPC_END = 21;         --寻路NPC完毕
      MOVE_TO_SCENE = 22;           --切换场景完毕
      TRANSMIT_END = 23;            --同地图传送完毕

      TALK_TO_NPC_PRE = 29;         --打开NPC对话面板
      TALK_TO_NPC = 30;             --跟NPC对话
      TALK_END = 31;                --对话结束.
      
      VEHICLE_INIT = 40;            --载具加载完成
      VEHICLE_FLY_COMPLETE = 41;    --飞行载具完成.

      MANUALLY_MOVE = 101;          --手动移动
      MANUALLY_SKILL = 102;         --手动释放技能
}

SequenceEventType.Guide = {
    PANEL_INIT = 199;                 --界面初始化
    PANEL_START = 200;                --界面开始
    PANEL_OPENED = 201;               --界面打开
    PANEL_CLOSEED = 202;              --界面关闭
    PANEL_CLOSEBTN_CLICK = 203;       --界面的关闭按钮点击 (要在界面关闭前发送, Dispose时会把panel._name置空)
    PANEL_DATA_INITED = 204;          --界面数据初始化完成

    BLANK_CLICK = 205;                --点击空白

    PROPS_SHOW_TIPS = 206;            --显示物品tips
    SYS_EXPAND_OPEN = 207;           --扩展界面打开
    SYS_EXPAND_CLOSE = 208;           --扩展界面关闭

    MAINUI_HERO_HEAD_TOGGLE = 210;    --点击英雄头像
    MAINUI_SYSLIST_SHOW_START = 211;  --系统列表开始展开
    MAINUI_SYSLIST_SHOW = 212;        --系统列表展开
    MAINUI_SYSLIST_HIDE_START = 213;  --系统列表开始隐藏
    MAINUI_SYSLIST_HIDE = 214;        --系统列表隐藏
    MAINUI_ACTLIST_TOGGLE = 215;      --点击活动按钮
    MAINUI_ACTLIST_SHOW = 216;        --活动列表展开
    MAINUI_ACTLIST_HIDE = 217;        --活动列表隐藏
    MAINUI_ITEM_CLICK = 218;          --系统栏点击
    MAINUI_TASK_AUTO = 219;           --自动执行任务
    
    SKILL_UPGRADE = 220;              --技能升级

    AUTO_USE_DRUG = 222;              --设置自动使用药物
    PET_FIGHT = 223;                  --伙伴出战
    EQUIP_FL_SELECT = 224;            --选中附灵材料
    EQUIP_FL_OPT = 225;               --进行附灵    
    GUILD_REQ_LIST = 226;             --获取仙盟列表
    GUILD_REQ_JOIN = 227;             --申请加入仙盟

    GUIDE_MOVE_TO = 230;              --引导移动到某个地方.
    GUIDE_CLICK_TARGET = 231;         --引导点中某个东西.

    SIGNIN_TAB_CHG = 240;             --福利界面tab改变
    SIGNIN_SEVENDAY_GETAWARD = 241;   --福利点击七天签到

    MOUNT_ACITVITY = 245;             --坐骑激活.
    MOUNT_USE = 246;                  --坐骑使用.

    PET_LVUP_PANEL_SHOW = 250;        --宠物升级面板打开
    PET_LVUP_PANEL_HIDE = 251;        --宠物升级面板关闭
    PET_LVUP_CLICK = 252;             --宠物升级

    AUTO_FIGHT_TAB = 260;             --自动战斗面板标签切换
    AUTO_STRENGTH_QUALITY = 261;      --自动强化品质选择
    --AUTO_STRENGTH_EQ_SHOW = 262;      --自动强化部位显示
    --AUTO_STRENGTH_EQ_HIDE = 263;      --自动强化部位隐藏
    AUTO_STRENGTH_EQ_SELECT = 264;    --自动强化部位选择

    ARENA_DOFIGHT = 270;             --竞技场挑战
    
    TASK_ITEM_CLICK = 280;              --任务面板选择

    WILD_BOSS_TAB_CHG = 290;            --古魔面板切换
    WILD_BOSS_SELECT = 291;             --古魔选择
    WILD_BOSS_SHOW = 292;               --古魔显示
    WILD_BOSS_ITEM_CLICK = 293;         --古魔物品点击

    REWARD_TASK_ACC = 300;              --悬赏任务接取
    REWARD_TASK_UPDATE = 301;           --悬赏任务界面刷新
    REWARD_TASK_GO = 302;               --悬赏任务接取

    ZHENTU_SELECT = 320;                --阵图选择
    ZHENTU_TISHENG = 321;               --阵图提升

    XUANBAO_UPDATE = 330;               --玄宝界面更新
    XUANBAO_AWARD = 331;                --玄宝领取

    XLT_TIAOZHAN = 340;                 --虚灵塔挑战

    ROLE_TAB = 350;                     --角色面板tab切换

    REALM_CHANGE_PANEL = 1101;        --选择境界面板
    REALM_UPGRADE = 1104;              --境界提升
    REALM_COMPACT = 1105;              --境界凝练

    WING_CHANGE_PANEL = 1201;               --翅膀升星
    WING_UPGRADE = 1211;               --翅膀升星

    EQUIP_CHANGE_PANEL = 1301;          --选择装备面板
    EQUIP_DRESS = 1341;                 --装备穿戴
    EQUIP_REFINE = 1342;                --装备精炼
    EQUIP_INLAY = 1343;                 --装备镶嵌
    EQUIP_QH = 1344;                    --装备强化
    EQUIP_WEAR = 1345;                  --装备穿戴

    TRUMP_CHANGE_PANEL = 1401;        --选择法宝面板
    TRUMP_CHANGE = 1411;        --选择法宝
    TRUMP_ACTIVITY = 1412;        --法宝激活
    TRUMP_EQUIP = 1413;        --法宝佩戴
    TRUMP_REFINE_ACTIVITY = 1421;--法宝炼制激活
    TRUMP_REFINE = 1422;        --法宝炼制

    PET_CHANGE_PANEL = 1501;        --选择宠物面板
    PET_TOGGLE = 1541;        --宠物上阵

    SKILL_CHANGE_PANEL = 1601;        --选择技能面板
    SKILL_SETTING_TOUCH_BEGIN = 1621; --技能按钮点击开始
    SKILL_SETTING_TOUCH_CANCEL = 1622;--技能按钮点击取消
    SKILL_SETTING_TOUCH_END = 1623;   --技能按钮点击结束
    SKILL_TALENT_SKILL_CHANGE = 1632; --选择功法技能
    SKILL_TALENT_CONFIRM = 1633;   --确认使用功法

    ACTIVITY_CHANGE_PANEL = 1701;        --选择活动面板
    ACTIVITY_SELECTED = 1711;        --选择活动
    ACTIVITY_RCFB_SELECTED = 1712;        --选择日常副本
    ACTIVITY_SHOW_TIPS = 1713;       --显示活动tips
    ACTIVITY_OFFLINE_BTN = 1714;       --显示活动tips

    NOVICE_OPERATION_MOVE_START = 1801;        --新手操作移动开始
    NOVICE_OPERATION_MOVE_END = 1802;        --新手操作移动结束
    NOVICE_OPERATION_SELECT_TARGET = 1803;        --新手操作选择目标
    NOVICE_OPERATION_ATTACK = 1804;        --新手操作攻击目标
    NOVICE_OPERATION_ATTACK_COMPLETE = 1805; --新手操作攻击目标
    NOVICE_OPERATION_SKILL = 1806;        --新手操作释放技能
    --NOVICE_OPERATION_CLICK_SKILL = 1807;        --新手操作点击技能按钮

    INSTANCE_MATCH = 2000;    --副本匹配
    ZONGMEN_MATCH = 2001;     --宗门历练匹配
    ENDLESS_SINGLE_MATCH = 2002;
}




SequenceEvent = class("SequenceEvent");

function SequenceEvent:ctor(data)
    self:_Init(data);
end

--[[
    eventFilter = function(args) end
]]

function SequenceEvent:_Init(data)
    self.eventType = data.eventType or SequenceEventType.NONE;
    self.eventArgs = data.eventArgs or nil;
    self.eventFilter = data.eventFilter or nil;
    self.triggerCallBack = data.triggerCallBack or nil;
end


function SequenceEvent.Create(type, args, filter, onTrigger)
    return SequenceEvent.New( { eventType = type, eventFilter = filter, triggerCallBack = onTrigger});
end


