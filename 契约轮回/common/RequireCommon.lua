--
-- Author: LaoY
-- Date: 2018-06-28 21:02:18
--

--游戏开始就要加载的文件，热更新之后
--常用字段枚举
require("game/config/auto/enum")
require "common/functions"
require "common/Constant"
--
require('common.BitState')
require "common/tool"
require "common/PowerConfig"

-- 这个单独处理
-- require "common/define"
require "common/CtrlManager"
require "common/Event"
require "common/EventName"
require "common/Schedule"
require "common/UIUtil"
require "common/TimeManager"
require('common/EventManager')
require('common.UtilManager')

require "common/ProtoStruct"

-- 状态机
require "common/machine/MachineManager"
require "common/machine/Machine"
require "common/machine/MachineState"

-- action
require('common.action.ActionManager')
require('common.action.ActionNodeWrapper')
require('common.action.ActionTweenFunction')
require('common.action.Action')
require('common.action.ActionInstant')
require('common.action.ActionInterval')
require('common.action.ActionEase')
require('common.action.ActionExtend')
require('common.action.ActionModel')

--动作
require('common.animation.AnimationManager')
--UI模型
require('common.model.UIModel')
require('common.model.UIRoleModel')
require('common.model.CreateRoleModel')
require('common.model.UINpcModel')
require('common.model.UIPetModel')
require('common.model.UIGodModel')


--特效
require('common.effect.EffectManager')
require('common.effect.BaseEffect')
require('common.effect.UIEffect')
require('common.effect.SceneEffect')
require('common.effect.ScenePositionEffect')
require('common.effect.SceneTargetEffect')
require('common.effect.SceneShootEffect')

-- 模型资源
require('common.effect.ModelEffect')

--场景管理器
require('common.LayerManager')

--input
require('common.input.InputManager')
require('common.input.GMPanel')
require('common.input.GMModel')
require('common.input.GMHistroyPanel')
require('common.input.HistroyItem')

--
require('common.DebugManager')

require('common.ColorUtil')
require "common.model.UIMonsterModel";

require "common.VoiceManager";

--require "common.TalkingDataManager";

require "common.CacheManager";

require "common.ui.ScrollView"
require "common.GoodIconUtil"
require "common.ui.ScrollViewUtil"
require "common.ui.LoopScrollView"

require "common.ui.LuaLinkImageText"

require "common.ui.vipValue.VipValueItemSettor"

require "common.FilterWords"
require "common.model.UIFairyModel"

require("common/ui/RedDot")

require("common/Tree")
require("common/TreeNode")

require("common.timeline.TimelineConfig")
require("common.timeline.TimelineManager")
require("common.SeparateFrameUtil")

require('platform.PlatformManager')

local function InitCommonManager()
    -- 全局事件
    GlobalEvent = Event()
    -- 全局定时器
    GlobalSchedule = Schedule()

    -- 资源、界面
    lua_resMgr = LuaResourceManager:GetInstance()
    lua_panelMgr = LuaPanelManager:GetInstance()

    -- http
    httpMgr = HttpManager:GetInstance()

    -- 状态机
    MachineManager()
    -- action
    cc.ActionManager:GetInstance()
    -- 特效
    EffectManager()
    -- 层级
    LayerManager()
    -- 输入
    InputManager()

    --
    DebugManager()

    TimeManager()
    EventManager()

    VoiceManager()

    CacheManager()

    --时间轴管理器
    TimelineManager()

    --平台相关
    PlatformManager()

    --事件跳转优化
    GlobalEvent.BrocastEvent = function(event, ...)
        GlobalEvent:Brocast(event, ...);
    end
    GlobalEvent.AddEventListener = function(event, handler)
        return GlobalEvent:AddListener(event, handler);
    end
    GlobalEvent.AddEventListenerInTab = function(event, handler, tab)
        tab[#tab + 1] = GlobalEvent:AddListener(event, handler);
    end
    GlobalEvent.RemoveTabEventListener = function(tab)
        return GlobalEvent:RemoveTabListener(tab);
    end

    --定时器跳转优化
    GlobalSchedule.StartFun = function(func, duration, loop, scale)
        return GlobalSchedule:Start(func, duration, loop, scale)
    end
    GlobalSchedule.StartFunOnce = function(func, duration, scale)
        return GlobalSchedule:StartOnce(func, duration, scale)
    end
    GlobalSchedule.StopFun = function(id)
        return GlobalSchedule:Stop(id);
    end

end

InitCommonManager()