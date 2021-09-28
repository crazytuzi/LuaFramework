                  
require("src/layers/tuto/TutoDefine")
require("src/layers/newFunction/NewFunctionDefine")
require("src/layers/tuto/TutoFunction")

local Tutos=
{
  --引导任务按钮 ok ok
  {q_id=0, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10000}, stopHang=true, delayRemove=false, noPass=true, q_controls={ 
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK_GUIDE, tip="点击^c(yellow)任务面板^可自动追踪^c(yellow)任务。^", sound=5, effectScale=cc.p(1, 1)},
  --{showNode=SHOW_TASK_CHAT, touchNode=TOUCH_TASK_CHAT_FINISH, effect="button", delay=0.5}
  }},


  {q_id=1, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE,noPass=true, q_conditions={item={{id=2030501, num=1}, {id=2031501, num=1, tag="|"},{id=2020501, num=1, tag="|"},{id=2021501, num=1, tag="|"},{id=2010501, num=1, tag="|"},{id=2011501, num=1, tag="|"}}}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="点击背包按钮，进入背包界面", sound=71, delay=0.5}, 
  {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOTHES, tip="点击装备，弹出装备详情", delay=0.5, effect="button"}, 
  {showNode=SHOW_TIP, touchNode=TOUCH_TIP_DRESS, effect="button", delay=0.5},
  }},

  {q_id=3, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={item={{id=2020101, num=1}, {id=2030101, num=1, tag="|"},{id=2010101, num=1, tag="|"}},node=SHOW_AUTOCONFIG}, q_controls={
  -- {showNode=SHOW_AUTOCONFIG, tip="这里是快捷穿戴装备的提示框哦,点击快捷穿戴装备,就可以直接换上装备了", delayCheck=0.5, delay=0.5, zOrder=400}, 
  {showNode=SHOW_AUTOCONFIG, touchNode=TOUCH_AUTOCONFIG_USE, tip="点击快捷穿戴装备",zOrder=500,sound=72, delay=0.5}, 
  }},


  {q_id=4, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_delay=0.1,q_conditions={item={{id=1511, num=1}, {id=1514, num=1, tag="|"},{id=1519, num=1, tag="|"}}}, q_controls={
  -- {showNode=SHOW_AUTOCONFIG, tip="这里是快捷学习技能的提示框哦,点击快捷学习技能,就可以直接学会技能了", delayCheck=0.5, delay=0.5, zOrder=400}, 
  {showNode=SHOW_AUTOCONFIG, touchNode=TOUCH_AUTOCONFIG_USE, tip="点击快捷学习技能", zOrder=500,delay=0.5,delayCheck=1}, 
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来学习技能吧", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="点击背包按钮，进入背包界面",sound=12, delay=0.5}, 
  -- {showNode=SHOW_BAG, touchNode=TOUCH_BAG_BOOK, tip="点击技能书，弹出详情", delay=0.5, effect="button"}, 
  -- {showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, effect="button", delay=0.5,setShowNode=SHOW_BAG},
  -- {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE, effect="button", delay=0.5},

  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来学习配置技能吧", sound=6, delay=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL2, tip="首先，点击选择要配置的技能。", delay=0.5},
  {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON2, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  }},

  -- {q_id=4, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={item={{id=1511, num=1}, {id=1514, num=1, tag="|"},{id=1519, num=1, tag="|"}}}, q_controls={
  -- {showNode=SHOW_AUTOCONFIG, touchNode=TOUCH_AUTOCONFIG_USE, tip="点击快捷学习技能", zOrder=500,sound=12, delay=0.5}, 
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来学习配置技能吧", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL2, tip="首先，点击选择要配置的技能。", delay=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON2, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  -- }},

  -- {q_id=500, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来学习配置技能吧", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL2, tip="首先，点击选择要配置的技能。", delay=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON2, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  -- --{showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_CLOSE, delay=0.5}
  -- }},
  --
  {q_id=5, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10017}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TARGETAWORD, tip="我们来学习升级技能吧1", sound=74, delay=0.5,delayCheck=1},
  -- {showNode=SHOW_TARGETAWORD, touchNode=TOUCH_TARGET_BTN1, tip="我们来学习升级技能吧2", delay=0.5},
  -- {showNode=SHOW_TARGETAWORD, touchNode=TOUCH_TARGET_BTN2, tip="我们来学习升级技能吧3", delay=0.5,delayCheck=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来学习升级技能吧", sound=74, delay=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, tip="有一个技能的熟练度很高，可以升级技能了哦~", delay=0.5}, 
  {showNode=SHOW_SKILL, tip="可升级的技能右上角会有小红点标注哦~", delayCheck=0.5, delay=0.5, zOrder=400}, 
  {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_UPDATE_SKILL1, tip="首先，选择要升级的技能。", delayCheck=0.5}, 
  {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_UPDATE, tip="再点击升级即可~是不是很简单~",delayCheck=0.5}
  }},--, {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_CLOSE, tip="记得及时升级技能，让自己保持高战力哦~", delay=0.5}

   -- --开关界面 ok  
  {q_id=6, q_state=TUTO_STATE_OFF, q_step=1,noPass=true,q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10008}, q_controls={
  {showNode=SHOW_MAIN, sound=75, layerFunc=tutoAddMenuTutoAction,noTouch = true}
  }},



  --熔炉开启 ok ok
  {q_id=7, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FURNACE}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="^c(yellow)熔炉^开启！现在勇士多余装备现在可以回收啦！",sound=76,delay=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="点击背包按钮，进入背包界面",delay=0.5}, 
  {showNode=SHOW_BAG, touchNode=TOUCH_BAG_FURNACE, tip="熔炉系统在背包的左下角。", delay=0.5, effect="button"}, 
  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_1, tip="点击选择放入熔炉的物品。", delay=0.5,delayCheck=0.5, effct="button",layerFunc=tutoLayerFunc}, 
  -- {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_2, effct="button"},
  {showNode=SHOW_FURNACE, tip="你可以勾选快速选择相同品质", delay=0.5, layerFunc=addTeamShow,funcConditions={pos=cc.p(display.cx-125,120),scaleX=2.5,scaleY=2.0}},
  
  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_RESOLVE, mainStep=true, tip="然后，点击熔炼按钮就可以熔炼装备了，就是这么简单！", effct="button", delay=0.5}, 
  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_SHOP, tip="我们再来看看熔炼商城~"},
  {showNode=SHOW_FURNACE, delay=0.5, tip="熔炼得到的熔炼值可以在熔炼商城中购买物品哦~"},
  --{showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_CLOSE, effct="button", setShowNode=SHOW_BAG}, 
  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE, effct="button"}
  }},


  --组队 ok ok
  {q_id=8, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10025}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TEAM, delay=0.5, tip="组队让游戏变得更有乐趣。", sound=77, layerFunc=openTaskMenu}, 
  {showNode=SHOW_MAIN, tip="你可以选择创建或加入别人的队伍。", delay=0.5, layerFunc=addTeamShow,funcConditions={pos=cc.p(-15, display.cy+15),scaleX=1.3,scaleY=2.0}},
  }},



  --精英怪提示 ok ok map=2110  2130
  {q_id=9, q_state=TUTO_STATE_OFF,q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_delay=2, q_conditions={map=2110}, q_controls={
  {showNode=SHOW_MAIN, sound=78, layerFunc=addBossShow,funcConditions={1,9}},
  }},

  {q_id=99, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_delay=2, q_conditions={map=2130}, q_controls={
  {showNode=SHOW_MAIN, sound=78, layerFunc=addBossShow,funcConditions={2,99}},
  }},

  {q_id=10, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10034}, q_controls={
  {showNode=SHOW_AUTOCONFIG, touchNode=TOUCH_AUTOCONFIG_USE, tip="点击快捷学习技能", zOrder=500, delay=1}, 

  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来学习一下配置技能吧", sound=6, delay=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL3, tip="首先，点击选择要配置的技能。", delay=0.5},
  {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON3, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  }},


 --飞行靴 ok
  {q_id=11, q_state=TUTO_STATE_OFF, q_step=1,stop = true,time=3, q_type=TUTO_TYPE_COMPULSIVE,q_conditions={task=10038,touchnode=TOUCH_MAIN_FLY_SHOE}, q_controls={
  {showNode=SHOW_MAIN, sound=79, touchNode=TOUCH_MAIN_FLY_SHOE, effect="button",}
  }},

 --飞行靴 ok
  {q_id=14, q_state=TUTO_STATE_OFF, q_step=1,stop = true, time=3,q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10069,touchnode=TOUCH_MAIN_FLY_SHOE}, q_controls={
  {showNode=SHOW_MAIN, sound=79, touchNode=TOUCH_MAIN_FLY_SHOE, effect="button"}
  }},

  --坐骑引导 ok ok
  {q_id=12, q_state=TUTO_STATE_OFF, q_step=1,q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10040}, stopHang=true, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="^c(yellow)坐骑^功能开启！好马配勇士！", sound=16, delay=0.5},
  {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_RIDE, effect="button", delay=0.5, delayCheck=0.5},
  {showNode=SHOW_RIDE, tip="在这里可以查看坐骑的属性和进行操作。", delay=0.5, delayCheck=0.5,setShowNode=SHOW_ROLE},
  -- {showNode=SHOW_RIDE, touchNode=TOUCH_RIDE_SWITCH, mainStep=true, tip="点击这里切换骑乘状态，或者在主界面上手指上下滑也可快捷操作哦~", setShowNode=SHOW_ROLE},
  {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE,delay=0.5},
  {showNode=SHOW_ROLE,delay=0.5, sound=80, delayCheck=0.5,layerFunc=tutoaddRidingTutoAction,noTouch = true},
  }},

  {q_id=18, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={item={{id=1023, num=1}}}, q_controls={
  {showNode=SHOW_AUTOCONFIG, touchNode=TOUCH_AUTOCONFIG_USE, tip="点击使用密令", zOrder=500, sound=83, delay=0.5,delayCheck=0.5}, 
  {showNode=SHOW_MAIN,tip="滑动左侧任务栏就可以查看到密令任务", zOrder=500,delay=0.5}, 
  }},

  -- {q_id=400, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE,q_conditions={lv=19}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SOCIAL, tip="点击社交按钮,进入社交界面",sound=82, delay=0.5}, 
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_SUB_MASTER, tip="拜师可以更快的提升等级", delay=0.5, effect="button"}, 
  -- -- {showNode=SHOW_TIP, touchNode=TOUCH_TIP_DRESS, effect="button", delay=0.5},
  -- }},


  --行会引导 ok ok
  {q_id=401, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE,q_conditions={lv=19}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="行会功能已经开启", delay=0.5, sound=14},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SOCIAL, tip="行会就像家一样，热情团结会让行会更像家！",delay=0.5,delayCheck=0.5}, 
  {showNode=SHOW_SUB, touchNode=TOUCH_SUB_FACTION, delay=0.5,delayCheck=0.5},
  {showNode=SHOW_FACTION, tip="在这里可以选择已经创建好的行会加入。", sound=13},
  -- {showNode=SHOW_FACTION, touchNode=TOUCH_FACTION_CREATE_TAB, tip="勇士也可以选择自己创建行会。", delay=0.5, delayCheck=0.5},
  -- {showNode=SHOW_FACTION, tip="创建行会有两种消耗方式可供选择。"},
  }},  

  --通天塔
  {q_id=402, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10116}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)通天塔^开启！战个痛快！", sound=89, delay=0.5}, 
  {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_HONOR, delay=0.5, delayCheck=0.5},
  {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_TOWER, delay=0.5, delayCheck=0.5}, 
  }},

  -- --公平竞技
  -- {q_id=403, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)通天塔^开启！战个痛快！", delay=0.5}, 
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_TIME, delay=0.5, delayCheck=0.5},
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_TOWER, delay=0.5, delayCheck=0.5}, 
  -- }},

  -- --引导王城诏令升级 ok ok
  -- {q_id=408, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={},q_controls={ 
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK, tip="点击任务" , delay=0.5},
  -- {showNode=SHOW_TASK, touchNode=TOUCH_TASK_DAILY, tip="点击王城诏令"}, 
  -- {showNode=SHOW_TASK, touchNode=TOUCH_TASK_UP, tip="点击升星", delay=0.5,delayCheck=0.2}, 
  -- --{showNode=SHOW_TASK_CHAT, touchNode=TOUCH_TASK_CHAT_FINISH, effect="button", delay=0.5}
  -- }},

  --打造 ok ok
  {q_id=410, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={item={{id=1452, num=10}}}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_EQUIP, delay=0.5, tip="我们来试着打造一件装备吧~"}, 
  {showNode=SHOW_SUB, touchNode=TOUCH_SUB_MAKE, delay=0.5},
  {showNode=SHOW_MAKE, tip="这里就是打造装备的界面了~",delay=0.5}, 
  -- {showNode=SHOW_MAKE, touchNode=TOUCH_TAB_2, tip="点选打造的装备类别。"}, 
  -- {showNode=SHOW_MAKE, touchNode=TOUCH_MAKE, tip="试试看吧~注意消耗哦~"}, 
  }},


  --强化 ok ok
  {q_id=411, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10121}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_EQUIP, delay=0.5, tip="我们来试着强化一件装备吧~", sound=11}, 
  {showNode=SHOW_SUB, touchNode=TOUCH_SUB_QIANGHUA, delay=0.5},
  {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_STRENGTHEN_ADDWEAPON, tip="选择添加装备", delay=0.5}, 
  {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_EPUIP_SELECT_1, tip="选择装备", delay=0.5,delayCheck=0.5}, 
  {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_EPUIP_SELECT, tip="点击放入", delay=0.5}, 
  {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_STRENGTHEN_ADDTOOLS, tip="点击添加强化材料", delay=0.5}, 
  {showNode=SHOW_STRENGTHEN, tip="强化可大幅提高装备的基础属性。",delay=0.5}, 
  {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_STRENGTHEN_USE, tip="试试看吧~注意消耗哦~"}, 
  }},

  --洗练 ok ok
  {q_id=415, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10141}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_EQUIP, delay=0.5, tip="我们来试着洗炼一件装备吧~", sound=27}, 
  {showNode=SHOW_SUB, touchNode=TOUCH_SUB_XILIAN, delay=0.5},
  {showNode=SHOW_WASH, touchNode=TOUCH_WASH_ADDWEAPON, tip="选择添加装备", delay=0.5}, 

  {showNode=SHOW_WASH, touchNode=TOUCH_EPUIP_SELECT_1, tip="选择装备", delay=0.5,delayCheck=0.5}, 
  {showNode=SHOW_WASH, touchNode=TOUCH_EPUIP_SELECT, tip="点击放入", delay=0.5}, 

  {showNode=SHOW_WASH, touchNode=TOUCH_WASH_WASH, tip="点击洗练", sound=28, delay=0.5,delayCheck=0.5}, 
  {showNode=SHOW_WASH, tip="洗炼结果不满意，可以选择取消。", sound=29, delay=0.5}, 
  -- {showNode=SHOW_WASH, touchNode=TOUCH_STRENGTHEN_USE, tip="试试看吧~注意消耗哦~"}, 
  }},

  --祝福 ok ok
  {q_id=418, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10162}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_EQUIP, delay=0.5, tip="我们来试着祝福一件装备吧~"}, 
  {showNode=SHOW_SUB, touchNode=TOUCH_SUB_ZHUFU, delay=0.5},
  {showNode=SHOW_WISH, touchNode=TOUCH_WISH_ADDWEAPON, tip="选择添加装备", delay=0.5}, 

  {showNode=SHOW_WISH, touchNode=TOUCH_EPUIP_SELECT_1, tip="选择装备", delay=0.5,delayCheck=0.5}, 
  {showNode=SHOW_WISH, touchNode=TOUCH_EPUIP_SELECT, tip="点击放入", delay=0.5}, 
  {showNode=SHOW_WISH, tip="祝福成功会获得幸运，但也有失败的可能", delay=0.5}, 
  {showNode=SHOW_WISH, touchNode=TOUCH_WISH_WISH, tip="点击祝福", delay=0.5}, 
  -- {showNode=SHOW_WISH, tip="洗炼的属性出来了，你自己看着办把", delay=0.5}, 
  -- {showNode=SHOW_WASH, touchNode=TOUCH_STRENGTHEN_USE, tip="试试看吧~注意消耗哦~"}, 
  }},

  --勋章引导 ok
  {q_id=44, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={dress=12}, q_controls={--{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试^c(yellow)强化装备^吧!"},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="我们来看看^c(yellow)勋章^这个特殊的装备吧~", sound=19, delay=0.5},
  {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_MEDAL, tip="点击身上装备的勋章可以进入勋章系统", delay=0.5, delayCheck=0.5, effect="button"},
  --{showNode=SHOW_MEDAL, mainStep=true, tip="这里就是勋章界面。", delay=0.5, delayCheck=0.5, },
  {showNode=SHOW_MEDAL, touchNode=TOUCH_MEDAL_UPDATE, tip="声望可以升级勋章，等级越高，勋章的属性越强~", delay=0.5},
  -- {showNode=SHOW_MEDAL, touchNode=TOUCH_MEDAL_CLOSE, setShowNode=SHOW_ROLE},
  -- {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE},
  }},

    --王城诏令升星 ok ok
  {q_id=408, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=22}, q_controls={
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK, tip="^c(yellow)王城诏令^开启！完成它就能获得丰富的经验奖励喔！", sound=18, delay=0.5},
  {showNode=SHOW_TASK, touchNode=TOUCH_TASK_DAILY, delay=0.5},
  {showNode=SHOW_TASK, tip="星级越高，奖励越多！升星操作可将星级直接提高到最高星级，获得完美奖励。", delay=0.5}, 
  --{showNode=SHOW_TASK, tip="2222222222222222", delay=0.5}, 
  {showNode=SHOW_TASK, touchNode=TOUCH_TASK_UP, mainStep=true, posOffset=cc.p(0, 50), outBtnPos=cc.p(display.cx, display.height-70), tip="提升至五星可获得最高奖励哦~。", delayCheck=0.5},
  --{showNode=SHOW_TASK, touchNode=TOUCH_TASK_CLOSE, setShowNode=SHOW_MAIN}} 
  }},



  --悬赏任务接受引导
  {q_id=41122, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, closeChat=true,q_conditions={node=SHOW_NPC_CHAT,task=10106}, q_controls={
  {showNode=SHOW_NPC_CHAT, touchNode=TOUCH_NPC_BTN, tip="点击进入悬赏任务界面", sound=84, delay=0.5},
  {showNode=SHOW_REWARDTASK, touchNode=TOUCH_REWARDTASK_RECEIVE, tip="每一个任务都可以获得高额经验奖励",delay=0.5,delayCheck=0.5},
  -- {showNode=SHOW_SET, mainStep=true, tip="左右拖动这里，即可设置使用药品的最低血量百分比。", delay=0.5, callFunc=removeSetHpAction},
  --{showNode=SHOW_SET, touchNode=TOUCH_SET_CLOSE}
  }},

  --悬赏任务完成后的引导
  {q_id=41123, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE,q_conditions={node=SHOW_NPC_CHAT,task=10107}, q_controls={
  {showNode=SHOW_MAIN, tip="完成悬赏任务可以获得大量经验", sound=85, delayCheck=0.5},
  }},

  --悬赏任务发布引导
  {q_id=41126, q_state=TUTO_STATE_OFF, q_step=1,noPass=true, q_type=TUTO_TYPE_COMPULSIVE,closeChat=true, q_conditions={node=SHOW_NPC_CHAT,task=10108}, q_controls={
  {showNode=SHOW_NPC_CHAT, touchNode=TOUCH_NPC_BTN, tip="点击进入悬赏任务界面",delay=0.5},
  {showNode=SHOW_REWARDTASK, touchNode=TOUCH_REWARDTASK_REKEASE, tip="点击进入发布悬赏任务",delay=0.5,delayCheck=0.5},
  {showNode=SHOW_REWARDTASK, touchNode=TOUCH_REWARDTASK_RECEIVE, tip="点击发布高级悬赏任务", sound=86, delay=0.5,delayCheck=0.5},
  {showNode=SHOW_REWARDTASK, touchNode=TOUCH_REWARDTASK_CLOSE, tip="点击关闭发布悬赏界面",delay=0.5},
  {showNode=SHOW_REWARDTASK, touchNode=TOUCH_REWARDTASK_MY, tip="点击进入我的悬赏",delay=0.5},
  {showNode=SHOW_REWARDTASK, touchNode=TOUCH_REWARDTASK_RECEIVE, tip="点击领取悬赏任务奖励", sound=87, delay=0.5,delayCheck=0.5},
  -- {showNode=SHOW_SET, mainStep=true, tip="左右拖动这里，即可设置使用药品的最低血量百分比。", delay=0.5, callFunc=removeSetHpAction},
  --{showNode=SHOW_SET, touchNode=TOUCH_SET_CLOSE}
  }},

  --悬赏任务完成后的引导
  {q_id=41127, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10109}, q_controls={
  {showNode=SHOW_MAIN, tip="发布悬赏任务的奖励声望可以用来提升勋章属性", delayCheck=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="我们来看看^c(yellow)勋章^这个特殊的装备吧~",delay=0.5},
  {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_MEDAL, tip="点击身上装备的勋章可以进入勋章系统", delay=0.5, delayCheck=0.5, effect="button"},
  --{showNode=SHOW_MEDAL, mainStep=true, tip="这里就是勋章界面。", delay=0.5, delayCheck=0.5, },
  {showNode=SHOW_MEDAL, touchNode=TOUCH_MEDAL_UPDATE, tip="声望可以升级勋章，等级越高，勋章的属性越强~", delay=0.5},
  }},

  --   --勋章引导2 ok
  -- {q_id=44, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=100--[[dress=12]]}, q_controls={--{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试^c(yellow)强化装备^吧!"},

  -- -- {showNode=SHOW_MEDAL, touchNode=TOUCH_MEDAL_CLOSE, setShowNode=SHOW_ROLE},
  -- -- {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE},
  -- }},

  --3v3竞技
  -- {q_id=50522, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=30}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="点击日常活动", delay=0.5}, 
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_TIME, delay=0.5, delayCheck=0.5},
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_BATTLE, delay=0.5, delayCheck=0.5}, 
  -- }},


  {q_id=50562, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=6000}, q_controls={
  {showNode=SHOW_MAIN, tip="欢迎来到炼狱，你在炼狱地图中可获得持续的经验奖励", sound=91, delay=0.5,zOrder = 400}, 
  }},

  {q_id=50562, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=7000}, q_controls={
  {showNode=SHOW_MAIN, tip="宝地掉落丰厚，但是每天只有30分钟参与时间！", sound=92, delay=0.5,zOrder = 400}, 
  }},

  {q_id=50562, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE,closeChat=true, q_conditions={node=SHOW_NPC_CHAT_JIEYI,lv=40}, q_controls={
  {showNode=SHOW_MAIN, tip="义结金兰已经开放，组上队友，去商城购买金兰谱就可以结拜了", sound=93, delay=0.5,zOrder = 400}, 
  }},
  -- {q_id=502, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="我们来复习一下配置技能吧", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL3, tip="首先，点击选择要配置的技能。", delay=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON3, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  -- --{showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_CLOSE, delay=0.5}
  -- }},

  -----------------------------------------------------分割线-------------------------------------------------
 --  -- --使用药品 ok ok
 --  -- {q_id=1, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10011}, q_controls={
 --  -- --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="点击^c(yellow)角色头像^打开屏幕下方的^c(yellow)功能菜单^。"},
 --  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="我们来看看如何使用背包里面的道具。", delay=0.5},
 --  -- {showNode=SHOW_BAG, touchNode=TOUCH_BAG_HPMP_STONE, tip="点击道具可打开道具菜单，进行操作。", outBtnPos=cc.p(display.cx, display.height-70), effect="button", delay=0.5},
 --  -- {showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, mainStep=true, tip="使用金创药，可以让你恢复气血。", delay=0.5, setShowNode=SHOW_BAG},
 --  -- {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}}},

  -- --装备强化 ok ok
  -- {q_id=2, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=30}, q_controls={--{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试^c(yellow)强化装备^吧!"},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="点击^c(yellow)角色按钮^可查看角色穿戴的装备。", sound=11, delay=0.5},
  -- {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_EQUIPMENT, delay=0.5, effect="button"},
  -- {showNode=SHOW_TIP, touchNode=TOUCH_TIP_STRENGTHEN, effect="button", delay=0.5},
  -- -- {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_STRENGTHEN_USE, mainStep=true, effect="button", delay=0.5},
  -- -- {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_STRENGTHEN_CLOSE, delay=0.5, setShowNode=SHOW_TIP},
  -- -- {showNode=SHOW_TIP, touchNode=TOUCH_TIP_CLOSE, tip="强化可大幅提高装备的基础属性。", delay=0.5, setShowNode=SHOW_ROLE},
  -- -- {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE}
  -- }},--, {showNode=SHOW_STRENGTHEN, touchNode=TOUCH_STRENGTHEN_CLOSE, setShowNode=SHOW_EQUIPMENT}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_CLOSE, setShowNode=SHOW_ROLE}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE}

  --每日签到 ok ok
  -- {q_id=5000, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_SIGN_IN}, stopHang=true, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_GIFT, tip="^c(yellow)签到系统^开启啦~每天都有新福利哦!", sound=20, delay=0.5}, 
  -- --{showNode=SHOW_GIFT, touchNode=TOUCH_GIFT_SIGNIN, delay=0.5}, 
  -- {showNode=SHOW_SIGNIN, touchNode=TOUCH_SIGNIN_SIGIN, delay=0.5, delayCheck=0.5, delay=0.5, effect="button", tip="每日一点，福利轻松到手。"},
  --  --{showNode=SHOW_GIFT, touchNode=TOUCH_GIFT_CLOSE, delay=0.5}
  -- }},--, 
  
 --  -- --特戒激活 
 --  -- -- -- --{q_id=6, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_delay=4, q_conditions={task=10045, func=NF_RING}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_RING, tip="duang^c(yellow)特戒系统^开启", delay=0.5}, {showNode=SHOW_RING, touchNode=TOUCH_RING_FIRST, tip="选中特戒可查看到该特戒的详细信息。", delay=0.5}, {showNode=SHOW_RING, touchNode=TOUCH_RING_ACTIVE}, {showNode=SHOW_RING, tip="恭喜你激活了第一枚特戒！特戒有特殊的技能，只要满足每日签到条件，即可激活~"}, {showNode=SHOW_RING, touchNode=TOUCH_RING_CLOSE}}}, --, {showNode=SHOW_RING, touchNode=TOUCH_RING_ACTIVE}, {showNode=SHOW_RING_UPDATE, touchNode=TOUCH_RING_UPDATE_STONE_1, delay=1}

 --  --特戒升级 ok                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
 --  --{q_id=7, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10073,func=NF_RING, item={{id=1200, num=1}}}, q_controls={
 --  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)升级特戒等级可大幅提升特戒战斗属性^", delay=0.5}, 
 --  --{showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_AIDE, delay=0.5},
 -- ---{showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_RING, delay=0.5, delayCheck=0.5}, 
 --  --{showNode=SHOW_RING, touchNode=TOUCH_RING_FIRST, tip="首先，选择已经激活的特戒。", delay=0.5}, 
 --  --{showNode=SHOW_RING, touchNode=TOUCH_RING_ACTIVE, tip="其次，点击升级特戒按钮。"}, 
 --  --{showNode=SHOW_RING_UPDATE, touchNode=TOUCH_RING_UPDATE_STONE_2, mainStep=true, tip="最后，点击拥有的特戒碎片即可进行特戒升级！", delay=0.5}, 
 --  --{showNode=SHOW_RING_UPDATE, touchNode=TOUCH_RING_UPDATE_CLOSE, delay=0.5, setShowNode=SHOW_RING}, 
 --  --{showNode=SHOW_RING, touchNode=TOUCH_RING_CLOSE, delay=0.5, setShowNode=SHOW_BATTLE}, 
 --  --{showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_CLOSE, delay=0.5}}},

 --  -- --创建队伍 
 --  -- {q_id=701, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10033, func=NF_TEAM}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TEAM, tip="有人的地方就有江湖！组队可以让任务更加效率", delay=0.5}, {showNode=SHOW_TEAM, tip="这里就是组队功能界面。"}, {showNode=SHOW_TEAM, touchNode=TOUCH_TEAM_NEAR}, {showNode=SHOW_TEAM, tip="查看附近玩家的信息，可寻找到适合的队友"}, {showNode=SHOW_TEAM, touchNode=TOUCH_TEAM_TEAM, tip="试着创建一个属于自己的队伍吧。"}, {showNode=SHOW_TEAM, touchNode=TOUCH_TEAM_CREATE, delay=0.5}}},

  --副本开启 ok
  -- {q_id=8000, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FB_SINGLE}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE,  tip="^c(yellow)屠龙传说^开启！勇士的大刀早已饥渴难耐了吧！", sound=45, delay=0.5}, 
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_HONOR, delay=0.5, delayCheck=0.5},
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_INSTANCE, delay=0.5, delayCheck=0.5}, 
  -- }},

 --  -- --副本关闭 ok
 --  -- --{q_id=804, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10087, func=NF_FB_SINGLE}, q_controls={{showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_CLOSE, delay=0.5}} },

 --  -- --邮件引导 ok
 --  -- {q_id=802, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10051, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_MAILBOX, delay=0.5, tip="^c(yellow)邮箱^就是它！出现小红点就表示有新邮件。", posOffset=cc.p(-100, -100)}, {showNode=SHOW_MAILBOX, touchNode=TOUCH_MAILBOX_FIRST, delay=0.5}, {showNode=SHOW_MAILBOX, touchNode=TOUCH_MAILBOX_TAKE, delay=0.5, tip="邮件里的^c(yellow)附件^，千万不要忘记领取。", setShowNode=SHOW_MAILBOX}, {showNode=SHOW_MAILBOX, touchNode=TOUCH_MAILBOX_CLOSE, tip="出现小红点时，记得查收新邮件哦~"}} },--, {showNode=SHOW_MAIL, touchNode=TOUCH_MAIL_CLOSE, setShowNode=SHOW_MAILBOX}, {showNode=SHOW_MAILBOX, touchNode=TOUCH_MAILBOX_CLOSE, tip="tuto_tip_mailbox_close"}

 --  -- --副本战神试炼开启 
 --  -- -- --  {q_id=801, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FB_SINGLE_2}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)战神试炼^开启！勇士又有新的挑战了！", delay=0.5}, {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_INSTANCE, delay=0.5}, {showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_TAB2, tip="点击上方不同的标签可以切换到不同的副本类型。", delay=0.5}, {showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_LIST_1, delay=0.5}, {showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_TAB2_CHALLENGE1, tip="战神试炼会有不同的难度挑战难度，我们从最简单的开始吧~", delay=0.5}} },

 --  -- -- --副本关闭 
 --  -- -- --{q_id=805, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10067, func=NF_FB_SINGLE_2}, q_controls={{showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_CLOSE, delay=0.5}} },



 --  -- --副本守护战神开启 
 --  -- {q_id=808, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FB_PROTECT, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)守护战神^开启！来挑战极限吧！", delay=0.5}, {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_INSTANCE, delay=0.5}, {showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_TAB4, delay=0.5}, {showNode=SHOW_INSTANCE, touchNode=TOUCH_INSTANCE_TAB4_CHALLENGE, tip="这个副本一开始就根本停不下来，勇士可以选择坚持战斗或者适时退出。", delayCheck=0.5, posOffset=cc.p(0, 90)}} },

 --  --熔炉开启 ok ok
 --  {q_id=9, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FURNACE, item={{id=1920201, num=1}, {id=1920301, num=1, tag="&"}}}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="^c(yellow)熔炉^开启！现在勇士多余装备现在可以回收啦！", sound=12, delay=0.5}, 
 --  {showNode=SHOW_BAG, touchNode=TOUCH_BAG_FURNACE, tip="熔炉系统在背包的右下角。", delay=0.5, effect="button"}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_1, tip="点击选择放入熔炉的物品。", delay=0.5, effct="button"}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_2, effct="button"},
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_RESOLVE, mainStep=true, tip="然后，点击熔炼按钮就可以熔炼装备了，就是这么简单！", effct="button", delay=0.5}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_SHOP, tip="我们再来看看熔炼商城~"},
 --  {showNode=SHOW_FURNACE, delay=0.5, tip="熔炼得到的熔炼值可以在熔炼商城中购买物品哦~"},
 --  --{showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_CLOSE, effct="button", setShowNode=SHOW_BAG}, 
 --  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE, effct="button"}
 --  }},

 --  {q_id=9, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FURNACE, item={{id=1930201, num=1}, {id=1930301, num=1, tag="&"}}}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="^c(yellow)熔炉^开启！现在勇士多余装备现在可以回收啦！", sound=12, delay=0.5}, 
 --  {showNode=SHOW_BAG, touchNode=TOUCH_BAG_FURNACE, tip="熔炉系统在背包的右下角。", delay=0.5, effect="button"}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_3, tip="点击选择放入熔炉的物品。", delay=0.5, effct="button"}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_4, effct="button"},
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_RESOLVE, mainStep=true, tip="然后，点击熔炼按钮就可以熔炼装备了，就是这么简单！", effct="button", delay=0.5}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_SHOP, tip="我们再来看看熔炼商城~"},
 --  {showNode=SHOW_FURNACE, delay=0.5, tip="熔炼得到的熔炼值可以在熔炼商城中购买物品哦~"},
 -- -- {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_CLOSE, effct="button", setShowNode=SHOW_BAG}, 
 --  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE, effct="button"}
 --  }},

 --  {q_id=9, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FURNACE, item={{id=1910201, num=1}, {id=1910301, num=1, tag="&"}}}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="^c(yellow)熔炉^开启！现在勇士多余装备现在可以回收啦！", sound=12, delay=0.5}, 
 --  {showNode=SHOW_BAG, touchNode=TOUCH_BAG_FURNACE, tip="熔炉系统在背包的右下角。", delay=0.5, effect="button"}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_5, tip="点击选择放入熔炉的物品。", delay=0.5, effct="button"}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_ITEM_6, effct="button"},
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_RESOLVE, mainStep=true, tip="然后，点击熔炼按钮就可以熔炼装备了，就是这么简单！", effct="button", delay=0.5}, 
 --  {showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_SHOP, tip="我们再来看看熔炼商城~"},
 --  {showNode=SHOW_FURNACE, delay=0.5, tip="熔炼得到的熔炼值可以在熔炼商城中购买物品哦~"},
 --  --{showNode=SHOW_FURNACE, touchNode=TOUCH_FURNACE_CLOSE, effct="button", setShowNode=SHOW_BAG}, 
 --  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE, effct="button"}
 --  }},



 --  -- -- --飞行靴 
 --  -- -- {q_id=903, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10073}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_FLY_SHOE, effect="button", delay=0.5}}},

 --  -- -- --飞行靴 
 --  -- -- --{q_id=902, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10067}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_FLY_SHOE, tip="飞行靴可以快速传送到任务目的地喔", effect="button", delay=0.5}}},



  --支线任务 ok ok
  -- {q_id=101, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=28}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK, tip="^c(yellow)支线任务^开启！完成它就能获得丰富的经验奖励喔！", sound=22, delay=0.5},
  -- {showNode=SHOW_TASK, touchNode=TOUCH_TASK_BRANCH, delay=0.5},
  -- {showNode=SHOW_TASK, tip="丰富多彩的支线任务带你领略传奇世界的精彩。", delay=0.5}, 
  -- --{showNode=SHOW_TASK, tip="2222222222222222", delay=0.5}, 
  -- --{showNode=SHOW_TASK, touchNode=TOUCH_TASK_UP, mainStep=true, posOffset=cc.p(0, 100), outBtnPos=cc.p(display.cx, display.height-70), tip="点击这里，可以提高完成任务的奖励哦~。", delayCheck=0.5},
  -- {showNode=SHOW_TASK, touchNode=TOUCH_TASK_BRANCH_GO, setShowNode=SHOW_MAIN}} },

 --   --狩魔任务 ok ok
 --  {q_id=102, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=999}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK, tip="^c(yellow)狩魔任务^开启！完成它就能获得丰富的经验与声望奖励喔！", delay=0.5},
 --  {showNode=SHOW_TASK, touchNode=TOUCH_TASK_HUNT, delay=0.5},
 --  {showNode=SHOW_TASK, tip="狩魔任务每周200环，完成它就能获得大量声望。", delay=0.5}, 
 --  --{showNode=SHOW_TASK, tip="2222222222222222", delay=0.5}, 
 --  --{showNode=SHOW_TASK, touchNode=TOUCH_TASK_UP, mainStep=true, posOffset=cc.p(0, 100), outBtnPos=cc.p(display.cx, display.height-70), tip="点击这里，可以提高完成任务的奖励哦~。", delayCheck=0.5},
 --  {showNode=SHOW_TASK, touchNode=TOUCH_TASK_CLOSE, setShowNode=SHOW_MAIN}} },

 --  -- -- -- --王城诏令
 --  -- -- -- {q_id=101, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10084, func=NF_TASK_DAILY, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK_DAILY, tip="tuto_tip_daily_2"}} },

 --  -- -- -- --王城诏令
 --  -- -- -- --{q_id=101, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10087, func=NF_TASK_DAILY, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK_DAILY, tip="tuto_tip_daily_2"}} },

 --  --推演宝箱 ok ok
 --  {q_id=11, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_LOTTERY}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_LOTTERY, tip="^c(yellow)寻宝系统^开启！无数秘宝在等待机缘与你相遇！", delay=0.5}, 
 --  --{showNode=SHOW_WELFARE, touchNode=TOUCH_WELFARE_LOTTERY, delay=0.5, delayCheck=0.5}, 
 --  {showNode=SHOW_LOTTERY, touchNode=TOUCH_LOTTERY_SPECIAL_1, mainStep=true, tip="考验勇士人品的时刻到了！", delay=0.5}, 
 --  {showNode=SHOW_LOTTERY, touchNode=TOUCH_LOTTERY_CONFIRM, delayCheck=3}, 
 --  {showNode=SHOW_LOTTERY, touchNode=TOUCH_LOTTERY_CLOSE}, 
 --  }},

 --  -- --竞技场挑战 ok ok
 --  -- {q_id=12, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_BATTLE}, q_controls={
 --  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)竞技场^开启，考验勇士战力的时候到了！", delay=0.5},
 --  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_HONOR, delay=0.5, delayCheck=0.5},
 --  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_BATTLE, delay=0.5, delayCheck=0.5},  
 --  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_WEAK, tip="初来乍到，我们先从最简单^c(yellow)弱敌^开始挑战。准备好了么？", delay=0.5}}},

 --  -- --使用悬赏卷轴 ok
 --  -- {q_id=13, q_state=TUTO_STATE_HIDE, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10099}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="点击头像打开系统菜单，去背包中查看获得的悬赏卷轴吧！"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_AGAINST_REEL, tip="传说中的悬赏卷轴就在这里！", effect="button", delay=0.5}, {showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, tip="使用悬赏卷轴可获得悬赏任务，完成可以获丰富的额外经验。", delay=0.5, setShowNode=SHOW_BAG}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK_KILL, tip="悬赏任务就在里了。", delayCheck=0.5}}},



  --仙翼引导 ok ok
  -- {q_id=140, q_state=TUTO_STATE_HIDE, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="^c(yellow)仙翼^功能开启！战力飞一般的感觉！", sound=24, delay=0.5},
  -- {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_WING, effect="button", delay=0.5},
  -- {showNode=SHOW_WING, touchNode=TOUCH_WING_ADVANCE, tip="仙翼也可以进阶哦~点击^c(yellow)强化^按钮可以进入进阶界面。", delay=0.5},
  -- {showNode=SHOW_WING_ADVANCE, touchNode=TOUCH_WING_ADVANCE_ADVANCE, mainStep=true, tip="进阶需要消耗对应^c(yellow)进阶材料^或者直接消耗^c(yellow)元宝^，先试试。", sound=25, setShowNode=SHOW_ROLE},
  -- --{showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE}
  -- }},

 --  -- --背包整理引导 
 --  -- {q_id=15, q_state=TUTO_STATE_HIDE, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG_NOTICE, tip="tuto_tip_bag_notice"}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_REORDER, tip="tuto_tip_bag_reorder", delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}}},

  -- --社交 ok ok
  -- {q_id=16, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FRIEND, noRecord=true}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SOCIAL, tip="莫愁前路无知己，天下谁人不识君？让我们来看看社交吧！", sound=10}, 
  -- {showNode=SHOW_SUB, touchNode=TOUCH_SUB_FRIEND, delay=0.5},
  -- {showNode=SHOW_SOCIAL, touchNode=TOUCH_SOCIAL_ADD_FIREND, tip="在这里我们可以添加好友~", delay=0.5}, 
  -- {showNode=SHOW_SOCIAL, tip="添加指定好友，或添加系统推荐的好友都可以陪伴你一起共闯传奇世界喔。"}, 
  -- --{showNode=SHOW_SOCIAL, touchNode=TOUCH_SOCIAL_ADD_FIREND_QUICK, mainStep=true, tip="点击【一键添加】来试试缘分吧。", delayCheck=0.2}, 
  -- {showNode=SHOW_SOCIAL, touchNode=TOUCH_SOCIAL_ADD_FIREND_CLOSE}, 
  -- {showNode=SHOW_SOCIAL, tip="添加好友之后可以在此进行查看好友的相关信息"},
  -- --{showNode=SHOW_SOCIAL, posOffset=cc.p(-100, -80),  touchNode=TOUCH_SOCIAL_CLOSE}
  -- }},
  
 --  -- --好友 ok
 --  -- {q_id=160, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_FRIEND, task=10100, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SOCIAL, tip="寂寞空虚冷？是时候该加一波好友了！", delay=0.5}, {showNode=SHOW_SOCIAL, touchNode=TOUCH_SOCIAL_ADD_FIREND, tip="点击这里进入添加好友功能哦~", delay=0.5, outBtnPos=cc.p(display.cx, 70)}}},

 --  -- --元神挖矿 
 --  -- {q_id=17, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_SOUL, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_DAILY, tip="tuto_tip_mine"}, {showNode=SHOW_DAILY, touchNode=TOUCH_DAILY_SOUL, delay=0.5, effect="button", tip="tuto_tip_mine_touch_tip"}}},--, {showNode=SHOW_SOUL, touchNode=TOUCH_SOUL_GET, tip="tuto_tip_mine_get", delay=0.5, effect="button"}, {showNode=SHOW_SOUL, touchNode=TOUCH_SOUL_CLOSE}

 --  -- --攻击模式 
 --  -- --{q_id=18, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_MODE, tip="tuto_tip_mode"}}},

 --  -- --挖矿引导 
 --  -- --{q_id=19, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10064, map=2110, item={{id=53019, num=1}}, noRecord=false}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="这个地图有丰富的矿石哟，而矿石是非常非常宝贵的资源！来看看怎么挖矿吧~"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="挖矿需要使用矿锤，先打开背包看看。", delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_HOE, tip="就是这货！", effect="button", delay=0.5}, {showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, tip="使用矿锤可以获得一定时间的采矿buff。", delay=0.5, setShowNode=SHOW_BAG}, {showNode=SHOW_BAG, tip="矿石可以很抢手的哟，赶紧到地图上找矿吧~", touchNode=TOUCH_BAG_CLOSE}}},

 --  -- --升级快挖矿引导 
 --  -- {q_id=20, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true}, q_controls={{showNode=SHOW_QUICK, touchNode=TOUCH_QUICK_MINE, tip="tuto_tip_quick_mine", delay=0.5}, {showNode=SHOW_SEND, touchNode=TOUCH_SEND_MINE_1, tip="tuto_tip_send_mine", delay=0.5}, {showNode=SHOW_SEND, touchNode=TOUCH_SEND_FINDWAY, tip="tuto_tip_find_way", delay=0.5, delayCheck=0.5}}},

 --  -- --积分商城 
 --  -- {q_id=21, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={jifen=1, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SHOP, tip="恭喜您获得了积分，快来看看怎么使用积分吧！", effect="button", posOffset=cc.p(-150, 0)}, {showNode=SHOW_SHOP, touchNode=TOUCH_SHOP_JIFEN, delay=0.5, effect="button", tip="点击积分商城。", posOffset=cc.p(0, -80)}, {showNode=SHOW_SHOP, tip="积分可以在积分商城里购买商品哦~", delayCheck=0.5}}},  

  -- --装备称号 ok ok
  -- {q_id=22, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=9}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ACHIEVEMENT, tip="恭喜勇士已经获得了一个称号，我们来看看怎么显示这个称号吧！", sound=9, delay=0.5, delayCheck=0.5}, 
  -- {showNode=SHOW_ACHIEVEMENT, touchNode=TOUCH_ACHIEVEMENT_TITLE, delay=0.5}, 
  -- {showNode=SHOW_TITLE, touchNode=TOUCH_TITLE_FIRST_EQUIP, mainStep=true, tip="点击显示按钮即可显示称号啦！", delayCheck=0.5}, 
  -- {showNode=SHOW_TITLE, tip="赶紧回到游戏界面，看看人物身上发生了什么变化？", setShowNode=SHOW_ACHIEVEMENT}, 
  -- --{showNode=SHOW_ACHIEVEMENT, touchNode=TOUCH_ACHIEVEMENT_CLOSE, delayCheck=0.5}
  -- }},

 --  -- --元神引导 
 --  -- {q_id=23, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true, func=NF_BEAUTY}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="元神开启啦~从此与勇士结伴闯江湖！快去看看吧。", effect="button", delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_BEAUTY, delay=0.5, effect="button", tip="点击这里切换到元神界面。", posOffset=cc.p(0, -60)}, {showNode=SHOW_BEAUTY, tip="这里是元神界面，可以查看元神属性和对元神进行各种操作。", delayCheck=0.5, posOffset=cc.p(0, -150)}}},  

 --  -- --元神战刃引导 
 --  -- {q_id=230, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true, func=NF_WEAPON}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="元神战刃开启！元神战力提高！", effect="button", delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_BEAUTY, delay=0.5, effect="button", tip="元神战刃在元神界面。", posOffset=cc.p(0, -60)}, {showNode=SHOW_BEAUTY, touchNode=TOUCH_BEAUTY_WEAPON, delayCheck=0.5}, {showNode=SHOW_BEAUTY, tip="这里是元神战刃界面，可以查看元神属性和对元神进行各种操作。", delayCheck=0.5}}}, 

 --  -- --元神战甲引导 
 --  -- {q_id=231, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true, func=NF_ARM}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="元神战甲开启！元神战力再提高！", effect="button", delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_BEAUTY, delay=0.5, effect="button", tip="元神战甲在元神界面。", posOffset=cc.p(0, -60)}, {showNode=SHOW_BEAUTY, touchNode=TOUCH_BEAUTY_ARM, delayCheck=0.5}, {showNode=SHOW_BEAUTY, tip="这里是元神战甲界面，可以查看元神属性和对元神进行各种操作。", delayCheck=0.5}}}, 

 --  -- -- -- --元神附身引导 
 --  -- -- -- {q_id=24, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true, func=NF_BEAUTY}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="tuto_tip_beauty_body_role", effect="button", delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_BEAUTY, delay=0.5, effect="button"}, {showNode=SHOW_BEAUTY, touchNode=TOUCH_BEAUTY_BODY, tip="tuto_tip_beauty_body_touch"}}},  



 --  -- --挖矿任务引导 ok
 --  -- {q_id=26, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10065}, q_controls={{showNode=SHOW_MAIN, tip="刚接到的任务需要勇士进行采矿，请注意地图上的矿点哦~", callFunc=tutoAddMineAction}}},  

 --  -- --挖矿任务结束引导 ok
 --  -- {q_id=27, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10099}, q_controls={{showNode=SHOW_MAIN, tip="恭喜勇士学会了挖矿！挖矿奖励丰富，走过路过莫错过咯", callFunc=tutoRemoveMineAction}}},  

  -- --活跃度奖励 ok
  -- {q_id=28, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=24}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="活跃度系统开启啦，快去看看都有哪些奖励？", delay=0.5}, 
  -- {showNode=SHOW_BATTLE, tip="该系统会根据勇士的活跃度给予不同的奖励哦~"}, 
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_PRIZE, tip="点击第一个宝箱看看都有什么奖励吧！", delayCheck=0.5}, 
  -- -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_GET, delayCheck=0.5}, 
  -- -- {showNode=SHOW_BATTLE, tip="记得在达成条件的时候回来领取奖励哦~", touchNode=TOUCH_ACTIVE_CLOSE, delay=0.5}
  -- }},  

 --  -- --元神挖矿 
 --  -- {q_id=29, q_state=TUTO_STATE_HIDE, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_SOUL, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_MINE, tip="^c(yellow)离线挖矿^开启！走起！", delay=0.5}, {showNode=SHOW_MINE, touchNode=TOUCH_MINE_SOUL, delay=0.5, effect="button"}, {showNode=SHOW_SOUL, tip="玩家在离线后，元神会在离线矿洞挖矿。离线挖矿一定时间后则会产生收益。", delay=0.5}, {showNode=SHOW_SOUL, touchNode=TOUCH_SOUL_GET, tip="您已经达到收益的条件，所以已经有收益可以领取了哦~"}, {showNode=SHOW_SOUL, touchNode=TOUCH_SOUL_GO, tip="接下来，我们再去元神矿洞^c(yellow)血洗^一下吧！"}}},

 --  -- --元神矿洞
 --  -- {q_id=290, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=2123, noRecord=true}, q_controls={{showNode=SHOW_MAIN, tip="欢迎来到离线矿洞~", delay=0.5}, {showNode=SHOW_MAIN, tip="这里是别的玩家元神在挖矿，杀死他们就可能获得他们的收益哦~赶紧去试试。", delay=0.5}}},

  -- --技能引导 ok ok
  -- {q_id=30, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={skill=1002, noRecord=true}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="勇士学到了一个新的^c(yellow)强力技能^，我们来学习配置技能吧~", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL2, tip="首先，点击选择要配置的技能。", delay=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON2, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  -- --{showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_CLOSE, delay=0.5}
  -- }},

  -- {q_id=30, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={skill=2002, noRecord=true}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="勇士学到了一个新的^c(yellow)强力技能^，我们来学习配置技能吧~", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL2, tip="首先，点击选择要配置的技能。", delay=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON2, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  -- --{showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_CLOSE, delay=0.5}
  -- }},

  -- {q_id=30, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={skill=3002, noRecord=true}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true, tip="勇士学到了一个新的^c(yellow)强力技能^，我们来学习配置技能吧~", sound=6, delay=0.5},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, delay=0.5},
  -- {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_SET_TAB, delayCheck=0.3, delay=0.3, outBtnPos=cc.p(display.cx, 70)},
  -- {showNode=SHOW_SKILL_CONFIG, tip="这里是技能的配置界面，勇士可以在这里配置技能。", delayCheck=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_SKILL2, tip="首先，点击选择要配置的技能。", delay=0.5},
  -- {showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_BUTTON2, mainStep=true, tip="然后，再点击选择配置的快捷按钮即可，就是这么简单！", delay=0.5},
  -- --{showNode=SHOW_SKILL_CONFIG, touchNode=TOUCH_SKILL_CLOSE, delay=0.5}
  -- }},

 --  -- --vip礼包引导 
 --  -- {q_id=31, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={vip=1, noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_VIP_CHECK, tip="恭喜，勇士成功升到^c(yellow)VIP1^啦！快去看看您的VIP特权吧~", delay=0.5}, {showNode=SHOW_VIP, tip="这里是VIP界面，您可以在这里查看到不同VIP等级特权。", delay=0.5}, {showNode=SHOW_VIP, tip="每升一级VIP等级，就会有不同的礼包领取哦~", delay=0.5}, {showNode=SHOW_VIP, touchNode=TOUCH_VIP_GET, tip="您已经升级到VIP1了，快来领取VIP1的礼包吧！", delay=0.5, posOffset=cc.p(0, 80)}, {showNode=SHOW_VIP, tip="接着，我们去邮箱领取对应的礼包吧~", touchNode=TOUCH_VIP_CLOSE, delay=0.5}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_MAILBOX, delay=0.5, tip="^c(yellow)邮箱^就是它！出现小红点就表示有新邮件。", posOffset=cc.p(-100, -100)}, {showNode=SHOW_MAILBOX, tip="这就是我们的礼包邮件啦！", touchNode=TOUCH_MAILBOX_FIRST, delay=0.5}, {showNode=SHOW_MAIL, touchNode=TOUCH_MAIL_TAKE, delay=0.5, tip="礼品在邮件的^c(yellow)附件^，点击即可领取。", setShowNode=SHOW_MAILBOX}, {showNode=SHOW_MAILBOX, touchNode=TOUCH_MAILBOX_CLOSE, tip="下次VIP升级时，不要忘记领取礼包哦~"}}},

 --  -- -- 技能升级引导 ok
 --  -- {q_id=32, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={noRecord=true}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SKILL, tip="有一个技能的熟练度很高，可以升级技能了哦~", delay=0.5}, {showNode=SHOW_SKILL, tip="可升级的技能右上角会有小红点标注哦~", delayCheck=0.5, delay=0.5, zOrder=400}, {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_UPDATE_SKILL1, tip="首先，选择要升级的技能。", delayCheck=0.5}, {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_UPDATE, tip="再点击升级即可~是不是很简单~", delayCheck=0.5}}},--, {showNode=SHOW_SKILL, touchNode=TOUCH_SKILL_CLOSE, tip="记得及时升级技能，让自己保持高战力哦~", delay=0.5}

 --  -- -- --装备传承 
 --  -- -- -- {q_id=33, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10059, school=1}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试装备的^c(yellow)传承^功能吧!"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_WEAPON, delay=0.5, effect="button", tip="先选择一个已经^c(yellow)强化过的^装备。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT, effect="button", delay=0.5, delayCheck=0.5, tip="点击这里进入传承界面。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CHOSE, effect="button", delayCheck=0.5, tip="点击这里选择一个需要传承的道具。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_USE1, effect="button", delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CONFIRM, delayCheck=0.5}}},
 --  -- -- -- {q_id=33, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10059, school=2}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试装备的^c(yellow)传承^功能吧!"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_WEAPON, delay=0.5, effect="button", tip="先选择一个已经^c(yellow)强化过的^装备。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT, effect="button", delay=0.5, delayCheck=0.5, tip="点击这里进入传承界面。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CHOSE, effect="button", delayCheck=0.5, tip="点击这里选择一个需要传承的道具。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_USE2, effect="button", delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CONFIRM, delayCheck=0.5}}},
 --  -- -- -- {q_id=33, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10059, school=3}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试装备的^c(yellow)传承^功能吧!"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, delay=0.5}, {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_WEAPON, delay=0.5, effect="button", tip="先选择一个已经^c(yellow)强化过的^装备。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT, effect="button", delay=0.5, delayCheck=0.5, tip="点击这里进入传承界面。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CHOSE, effect="button", delayCheck=0.5, tip="点击这里选择一个需要传承的道具。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_USE3, effect="button", delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CONFIRM, delayCheck=0.5}}},
 --  -- {q_id=33, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10056, school=1, item={{id=5020802, num=1}}}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试装备的^c(yellow)传承^功能吧!"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_USE1, delay=0.5, effect="button", tip="先选择一个已经^c(yellow)强化过的^装备。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT, effect="button", delay=0.5, delayCheck=0.5, tip="点击这里进入传承界面。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CHOSE, effect="button", delayCheck=0.5, tip="点击这里选择一个需要传承的道具。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_USE1, effect="button", delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CONFIRM, delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_CLOSE, setShowNode=SHOW_BAG}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}}},--
 --  -- {q_id=33, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10056, school=2, item={{id=5030802, num=1}}}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试装备的^c(yellow)传承^功能吧!"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_USE2, delay=0.5, effect="button", tip="先选择一个已经^c(yellow)强化过的^装备。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT, effect="button", delay=0.5, delayCheck=0.5, tip="点击这里进入传承界面。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CHOSE, effect="button", delayCheck=0.5, tip="点击这里选择一个需要传承的道具。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_USE1, effect="button", delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CONFIRM, delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_CLOSE, setShowNode=SHOW_BAG}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}}},--
 --  -- {q_id=33, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10056, school=3, item={{id=5010802, num=1}}}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="来试试装备的^c(yellow)传承^功能吧!"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_USE3, delay=0.5, effect="button", tip="先选择一个已经^c(yellow)强化过的^装备。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT, effect="button", delay=0.5, delayCheck=0.5, tip="点击这里进入传承界面。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CHOSE, effect="button", delayCheck=0.5, tip="点击这里选择一个需要传承的道具。"}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_USE1, effect="button", delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_TRANSMIT_CONFIRM, delayCheck=0.5}, {showNode=SHOW_EQUIPMENT, touchNode=TOUCH_EQUIPMENT_CLOSE, setShowNode=SHOW_BAG}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}}},--

 --  -- --七天豪礼 
 --  -- {q_id=34, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10102}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TIME, effect="button", delay=0.5}, {showNode=SHOW_TIME, touchNode=TOUCH_TIME_7DAY, effect="button", delay=0.5, delayCheck=0.5}, {showNode=SHOW_7DAY, touchNode=TOUCH_7DAY_GET, effect="button", delay=0.5, delayCheck=0.5}}},

  --上下马 ok
  --{q_id=36, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10047}, callFunc=tutoaddRidingTutoAction},

 --  -- --移动 ok
 --  -- {q_id=37, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10000}, callFunc=tutoAddMoveTutoAction},

 --  -- --攻击 ok
 --  -- {q_id=38, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10000}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_MAINSKILL, tip="点击主技能按钮进行攻击。"}}},

  -- --设置挂机血量 ok ok
  -- {q_id=39, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=7}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SET, tip="点击【设置】，我们去设置血量保护吧！", sound=8, delay=0.5, posOffset=cc.p(-200, 100)},
  -- {showNode=SHOW_SET, tip="灵活设置血量保护可以应付不同的战斗情况", callFunc=tutoAddSetHpAction},
  -- {showNode=SHOW_SET, mainStep=true, tip="左右拖动这里，即可设置使用药品的最低血量百分比。", delay=0.5, callFunc=removeSetHpAction},
  -- --{showNode=SHOW_SET, touchNode=TOUCH_SET_CLOSE}
  -- }},

 --  ----新挖矿引导传送
 --  --{q_id=40, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=33}, q_controls={
 --  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="^c(yellow)在线挖矿^开启，赶快去体验一下吧！", delay=0.5}, 
 --  --{showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_MINE, delay=0.5, delayCheck=0.5}, 
 --  --{showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_MINE_ONLINE, delay=0.5, delayCheck=0.5}, 
 --  --{showNode=SHOW_MINE_ONLINE, touchNode=SHOW_MINE_ONLINE_FIRST, delay=0.5, delayCheck=0.5}, 
 --  --{showNode=SHOW_TRANSMIT_CONFIRM, touchNode=TOUCH_TRANSMIT_CONFIRM_TRANSMIT, delay=0.5, delayCheck=0.5, zOrder=400},}},

 --  ----新挖矿引导使用矿锄 ok
 --  --{q_id=401, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=2132, item={{id=1129, num=1}}}, q_controls={
 --  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="这个地图有丰富的矿石哟，而矿石是非常非常宝贵的资源！来看看怎么挖矿吧~"},
 --  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="挖矿需要使用矿锄，先打开背包看看。", delay=0.5}, 
 --  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_HOE, tip="就是这货！", effect="button", delay=0.5}, 
 --  --{showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, mainStep=true, tip="使用矿锄可以获得一定时间的采矿buff。", delay=0.5, setShowNode=SHOW_BAG}, 
 --  --{showNode=SHOW_BAG, tip="矿石可以很抢手的哟，赶紧到地图上找矿吧~", touchNode=TOUCH_BAG_CLOSE},
 --  --{showNode=SHOW_MAIN, tip="点击这里查看buff。", touchNode=TOUCH_MAIN_BUFF},
 --  --{showNode=SHOW_BUFF, tip="长按可以查看buff具体信息。", touchNode=TOUCH_BUFF_MINE, delayCheck=0.5, delay=0.5},
 --  --{showNode=SHOW_BUFF, tip="留意地图上的矿点，点击即可开始采矿了哦~", touchNode=TOUCH_BUFF_CLOSE, delayCheck=0.5, delay=0.5, callFunc=tutoAddMineAction},
 --  --}},

 --    -- --新挖矿引导使用矿锄
 --    -- {q_id=403, q_state=TUTO_STATE_OFF, q_step=1, q_delay=3, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=2132}, q_controls={
 --    -- {showNode=SHOW_MAIN, delayCheck=0.5, delay=0.5, callFunc=tutoAddMineAction},
 --    -- }},

 --    -- --新挖矿引导使用矿锄
 --    -- {q_id=403, q_state=TUTO_STATE_OFF, q_step=1, q_delay=3, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=2122}, q_controls={
 --    -- {showNode=SHOW_MAIN, delayCheck=0.5, delay=0.5, callFunc=tutoAddMineAction},
 --    -- }},

 --    -- --新挖矿引导使用矿锄
 --    -- {q_id=403, q_state=TUTO_STATE_OFF, q_step=1, q_delay=3, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=2113}, q_controls={
 --    -- {showNode=SHOW_MAIN, delayCheck=0.5, delay=0.5, callFunc=tutoAddMineAction},
 --    -- }},

    -- --新挖矿引导使用矿锄
    -- {q_id=403, q_state=TUTO_STATE_HIDE, q_step=1, q_delay=3, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={map=2127}, q_controls={
    -- {showNode=SHOW_MAIN,  tip="留意地图上的矿点，点击即可获得结晶哦~", callFunc=tutoAddMineAction},
    -- }},


 --  --合并悬赏卷轴 ok
 --  --{q_id=41, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={item={{id=9007, num=2}}, jb=10000}, q_controls={--{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="这个地图有丰富的矿石哟，而矿石是非常非常宝贵的资源！来看看怎么挖矿吧~"},
 --  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="来试试合并悬赏卷轴吧~", delay=0.5}, 
 --  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_AGAINST_REEL, tip="选择一个低级的悬赏卷轴。", effect="button", delay=0.5}, 
 --  --{showNode=SHOW_TIP, touchNode=TOUCH_TIP_MORE, tip="点击更多按钮展示别的选项。", delay=0.5}, 
 --  --{showNode=SHOW_TIP, touchNode=TOUCH_TIP_COMPOUND, mainStep=true, tip="点击合成进入合成界面。", delay=0.5, delayCheck=0.5}, 
 --  --{showNode=SHOW_COMPOUND, tip="这里就是合成界面，合成需要消耗金币哦~"},
 --  --{showNode=SHOW_COMPOUND, tip="点击合成即可。", touchNode=TOUCH_COMPOUND_COMPOUND},
 --  --{showNode=SHOW_COMPOUND, touchNode=TOUCH_COMPOUND_CLOSE, setShowNode=SHOW_BAG},
 --  --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE},
 --  --}},

 --  -- --使用 ok
 --  -- {q_id=1, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10009}, q_controls={{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="点击^c(yellow)角色头像^打开屏幕下方的^c(yellow)功能菜单^。"}, {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, delay=0.5}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_HPMP_STONE, tip="点击道具可打开道具菜单，进行操作。", effect="button", delay=0.5}, {showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, tip="使用金创药，可以让你恢复气血。", delay=0.5, setShowNode=SHOW_BAG}, {showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}}},

 --  --摇钱树 ok
 --  --{q_id=42, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=25}, q_controls={
 --  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_WELFARE, tip="来试试^c(yellow)摇钱树^吧~", delay=0.5}, 
 --  --{showNode=SHOW_WELFARE, touchNode=TOUCH_WELFARE_TREE, delay=0.5, delayCheck=0.5}, 
 --  --{showNode=SHOW_TREE, touchNode=TOUCH_TREE_BUTTON_1, posOffset=cc.p(0, 100), tip="黄金树可以增加财富。", delay=0.5, delayCheck=0.5},
 --  --{showNode=SHOW_TREE, touchNode=TOUCH_TREE_BUTTON_2, posOffset=cc.p(0, 100), tip="声望树可以增加声望。"},
 --  --{showNode=SHOW_TREE, touchNode=TOUCH_TREE_BUTTON_3, posOffset=cc.p(0, 100), tip="特戒树可以增加特戒升级材料。"}, 
 --  --{showNode=SHOW_TREE, touchNode=TOUCH_TREE_CLOSE, setShowNode=SHOW_WELFARE}, 
 --  --{showNode=SHOW_WELFARE, touchNode=TOUCH_WELFARE_CLOSE},
 --  --}},



 --  --祝福引导 ok
 --  {q_id=45, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10161, item={{id=1043, num=1}}}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_ROLE, tip="来试试装备的祝福功能。", sound=23, delay=0.5}, 
 --  {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_WEAPON, delay=0.5, effect="button", tip="先选择一个装备。"}, 
 --  {showNode=SHOW_TIP, touchNode=TOUCH_TIP_MORE, effect="button", delay=0.5},
 --  {showNode=SHOW_TIP, touchNode=TOUCH_TIP_WISH, effect="button", delay=0.5, delayCheck=0.5},
 --  {showNode=SHOW_WISH, touchNode=TOUCH_WISH_WISH, mainStep=true, posOffset=cc.p(0, 100), delay=0.5, delayCheck=0.5, effect="button", tip="点击祝福，消耗祝福油即可完成装备祝福。"},
 --  {showNode=SHOW_WISH, touchNode=TOUCH_WISH_CLOSE, setShowNode=SHOW_ROLE},
 --  {showNode=SHOW_ROLE, touchNode=TOUCH_ROLE_CLOSE},
 --  }},

  -- -- 拍卖行 ok ok
  -- {q_id=46, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={func=NF_AUCTION}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_SELL, tip="来看看拍卖行功能吧。", sound=15, delay=0.5}, 
  -- {showNode=SHOW_SELL, tip="这里是拍卖行界面，是非常重要的商业工具哦~"},
  -- --{showNode=SHOW_SELL, touchNode=TOUCH_SELL_BUY, tip="我们先来看看购买功能。", delay=0.5, delayCheck=0.5},
  -- {showNode=SHOW_SELL, tip="在这里可以购买别的玩家的拍卖品。"},
  -- -- {showNode=SHOW_SELL, touchNode=TOUCH_SELL_SELL, delay=0.5},
  -- -- {showNode=SHOW_SELL, tip="在这里出售你的物品。"},
  -- -- {showNode=SHOW_SELL, touchNode=TOUCH_SELL_SHOP, delay=0.5},
  -- -- {showNode=SHOW_SELL, tip="这里可以查看你上架的商品。"},
  -- {showNode=SHOW_SELL, touchNode=TOUCH_SELL_MONEY, delay=0.5},
  -- {showNode=SHOW_SELL, tip="这里可以查看你的拍卖收益哦~"},
  -- --{showNode=SHOW_SELL, touchNode=TOUCH_SELL_CLOSE},
  -- }},

  --背包满 ok ok
  {q_id=47, q_state=TUTO_STATE_HIDE, q_step=1,q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  --{showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_HEAD, tip="点击^c(yellow)角色头像^打开屏幕下方的^c(yellow)功能菜单^。"},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="背包满啦~我们来看看如何扩展背包空间吧。", sound=31, delay=0.5},
  {showNode=SHOW_BAG, touchNode=TOUCH_BAG_LOCK, tip="点击锁定的格子，即可确定要扩展到的空间。", sound=32, delay=0.5},
  }},


  --
  {q_id=429, q_state=TUTO_STATE_HIDE, q_step=1, stop=true,q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  {showNode=SHOW_MAIN, tip="两指从两侧向中间滑动，可重新显示界面", delay=0.5}, 

  }},

  --引导玩家点击主线任务并告知不能做主线，可以去做诏令任务
  {q_id=409, q_state=TUTO_STATE_HIDE, q_step=1,notsave=true, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK_GUIDE, tip="点击主线任务" , effectScale=cc.p(1, 1)},
  -- {showNode=SHOW_MAIN, tip="等级不够，无法领取主线任务，试试其他任务", sound=18, delay=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK, tip="没任务做了可以做诏令任务！完成它就能获得丰富的经验奖励喔！", delay=0.5},
  {showNode=SHOW_TASK, touchNode=TOUCH_TASK_DAILY, delay=0.5},
  {showNode=SHOW_TASK, tip="星级越高，奖励越多！升星操作可将星级直接提高到最高星级，获得完美奖励。", delay=0.5}, 
  --{showNode=SHOW_TASK, tip="2222222222222222", delay=0.5}, 
  -- {showNode=SHOW_TASK, touchNode=TOUCH_TASK_UP, mainStep=true, posOffset=cc.p(0, 50), outBtnPos=cc.p(display.cx, display.height-70), tip="提升至五星可获得最高奖励哦~。", delayCheck=0.5},
  --{showNode=SHOW_TASK, touchNode=TOUCH_TASK_CLOSE, setShowNode=SHOW_MAIN}} 
  }},


    --引导玩家点击主线任务并告知不能做主线，可以去做日常任务
  {q_id=419, q_state=TUTO_STATE_HIDE, q_step=1,notsave=true,  q_type=TUTO_TYPE_COMPULSIVE, q_conditions={}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TASK_GUIDE, tip="点击主线任务" , effectScale=cc.p(1, 1)},
  -- {showNode=SHOW_MAIN, tip="等级不够，无法领取主线任务，试试其他任务", sound=18, delay=0.5},
  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE, tip="没任务做了可以做日常任务！完成它就能获得丰富的经验奖励喔！", delay=0.5}, 
  {showNode=SHOW_BATTLE, tip="没任务做了可以做日常任务！完成它就能获得丰富的经验奖励喔！", sound=88, delay=0.5},
  }},

 --  --附近目标引导
 --  {q_id=48, q_state=TUTO_STATE_HIDE, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=37}, q_controls={
 --  {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_TARGET, touchOffset=cc.p(10, -5), delayCheck=0.5, delay=0.5},
 --  }},

  --  --使用新手礼包 ok ok
  -- {q_id=49, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={task=10011, item={{id=6200026, num=1}}}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BLOOD, closeMenu=true},
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BAG, tip="快打开背包看看有什么惊喜吧！",  sound=7,delay=0.5},
  -- {showNode=SHOW_BAG, touchNode=TOUCH_BAG_GIFT, tip="点击新手礼包可打开道具菜单进行操作。", outBtnPos=cc.p(display.cx, display.height-70), effect="button", delay=0.5},
  -- {showNode=SHOW_TIP, touchNode=TOUCH_TIP_USE, mainStep=true, tip="使用新手礼包，就可以获得里面的礼物啦。", delay=0.5, setShowNode=SHOW_BAG},
  -- --{showNode=SHOW_BAG, touchNode=TOUCH_BAG_CLOSE}
  -- }},

  -- --公平竞技场 ok
  -- {q_id=50, q_state=TUTO_STATE_OFF, q_step=1, q_type=TUTO_TYPE_COMPULSIVE, q_conditions={lv=40}, q_controls={
  -- {showNode=SHOW_MAIN, touchNode=TOUCH_MAIN_BATTLE,  tip="^c(yellow)公平竞技场^开启！不服来战！", delay=0.5}, 
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_FIGHT, delay=0.5, delayCheck=0.5},
  -- {showNode=SHOW_BATTLE, touchNode=TOUCH_BATTLE_BATTLE, delay=0.5, delayCheck=0.5}, 
  -- }},




}

return Tutos