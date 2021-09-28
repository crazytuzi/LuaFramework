GuideType_PointObj = 1
GuideType_PointScene = 2
GuideAnimitionTyPe_Hand = 1
GuideAnimitionTyPe_Ret = 2
GuideAnimitionTyPe_Arrow = 3
GuideData_Mission = {
  [10001] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 10001,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  点击这里进行任务追踪  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10001  点击这里进行任务追踪 ")
        g_MissionMgr:TraceMission(10001)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "FunctionItem",
        needMissionId = 10001,
        objName = "m_BtnSprite",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  点击这里进行任务追踪  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(10001)
      end
    },
    {
      guideType = GuideType_PointScene,
      aniType = GuideAnimitionTyPe_Hand,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionTalkView",
        needMissionId = 10001,
        pos = {
          display.width - 60,
          70
        },
        dir = Guide_Dir_Down
      },
      txtparam = {
        txt = "  点击这里继续对话  ",
        txtalign = Guide_Dir_Up,
        ofx = -100,
        ofy = -30
      },
      clickfun = function()
        print(" clickfun======>>>>    g_CurShowTalkView === ", g_CurShowTalkView == nil)
        if g_CurShowTalkView then
          g_CurShowTalkView:ShowNextTalk()
        end
      end
    }
  },
  [10002] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 10002,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  点击这里进行任务追踪  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10002")
        g_MissionMgr:TraceMission(10002)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "FunctionItem",
        needMissionId = 10002,
        objName = "m_BtnSprite",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  点击这里进行任务追踪  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10002")
        if g_CurShowTalkView then
          g_CurShowTalkView:ShowNextTalk()
        end
      end
    },
    {
      guideType = GuideType_PointScene,
      aniType = GuideAnimitionTyPe_Hand,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionTalkView",
        needMissionId = 10002,
        pos = {
          display.width - 60,
          70
        },
        dir = Guide_Dir_Down
      },
      txtparam = {
        txt = "  点击这里进行继续对话  ",
        txtalign = Guide_Dir_Up,
        ofx = -100,
        ofy = -30
      },
      clickfun = function()
        print(" clickfun======>>>>   10002")
        if g_CurShowTalkView then
          g_CurShowTalkView:ShowNextTalk()
        end
      end
    }
  },
  [10003] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      mustShow = true,
      completeType = 1,
      showOnce = true,
      priority = 100,
      param = {
        pro = MissionPro_0,
        className = "warui",
        objName = "m_Btn_Attack",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  点击这里进行物理攻击  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        print(" clickfun======>>>>   10003  点击这里进行物理攻击 ")
        if g_WarScene then
          local waruiIns = g_WarScene.m_WaruiObj
          if waruiIns then
            print(" 233333 ")
            waruiIns:Btn_Attack(obj)
          end
        end
      end
    },
    {
      guideType = GuideType_PointScene,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      deltaPos = {-2, 20},
      mustShow = true,
      showOnce = true,
      priority = 80,
      param = {
        pro = MissionPro_0,
        className = "warScene",
        pos = function()
          if g_WarScene then
            local p = g_WarScene:getRoleXYByPos(10003)
            return {
              p.x,
              p.y
            }
          end
        end,
        dir = Guide_Dir_Down
      },
      txtparam = {
        txt = "  点击这里选择目标  ",
        txtalign = Guide_Dir_Right,
        ofx = 10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10003  000 ")
        if g_WarScene then
          local p = g_WarScene:getRoleViewByPos(10003)
          if p then
            p:SetSelected(true)
            p:TouchOnRole(TOUCH_EVENT_ENDED)
          end
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      mustShow = true,
      completeType = 1,
      showOnce = true,
      priority = 60,
      delayShowTime = 0.8,
      param = {
        pro = MissionPro_0,
        className = "warui",
        objName = "m_Btn_Magic",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  点击这里展开法术  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        print(" clickfun======>>>>   10003 000000")
        if g_WarScene == nil then
          return
        end
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          waruiIns:Btn_Magic(obj)
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      deltaPos = {40, 40},
      priority = 50,
      param = {
        pro = MissionPro_0,
        className = "selectHeroSkill",
        objName = function()
          local mainHeroType = g_LocalPlayer:getObjProperty(1, PROPERTY_RACE)
          if mainHeroType == RACE_MO then
            return "pos_33"
          elseif mainHeroType == RACE_GUI then
            return "pos_23"
          end
          return "pos_13"
        end,
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  点击这里选择法术  ",
        txtalign = Guide_Dir_Right,
        ofx = 10,
        ofy = 0
      },
      clickfun = function(viewObj)
        print(" ***********  点击这里选择法术 ")
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns and viewObj ~= nil then
          viewObj:ShowWarSelectView(false)
          local mainHeroType = g_LocalPlayer:getObjProperty(1, PROPERTY_RACE)
          local skillTypeList = g_LocalPlayer:getMainHero():getSkillTypeList()
          local skillAttr = skillTypeList[1]
          if mainHeroType == RACE_MO then
            skillAttr = skillTypeList[3]
          elseif mainHeroType == RACE_GUI then
            skillAttr = skillTypeList[2]
          end
          local skillList = data_getSkillListByAttr(skillAttr)
          dump(skillList, "2222")
          if skillList then
            waruiIns:SelectSkill(skillList[3])
          end
        end
      end
    },
    {
      guideType = GuideType_PointScene,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      deltaPos = {-2, 20},
      priority = 40,
      delayShowTime = 0.2,
      param = {
        pro = MissionPro_0,
        className = "warScene",
        pos = function()
          if g_WarScene then
            local p = g_WarScene:getRoleXYByPos(10003)
            return {
              p.x,
              p.y
            }
          end
        end,
        dir = Guide_Dir_Down
      },
      txtparam = {
        txt = "  点击这里选择目标  ",
        txtalign = Guide_Dir_Right,
        ofx = 0,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10003")
        if g_WarScene then
          local p = g_WarScene:getRoleViewByPos(10003)
          if p then
            p:SetSelected(true)
            p:TouchOnRole(TOUCH_EVENT_ENDED)
          end
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      priority = 30,
      delayShowTime = 3,
      param = {
        pro = MissionPro_0,
        className = "warui",
        objName = "m_Btn_Auto",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  点击这里选择自动战斗  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        print(" clickfun======>>>>   10003")
        if g_WarScene then
          local waruiIns = g_WarScene.m_WaruiObj
          if waruiIns then
            print(" 233333 ")
            waruiIns:Btn_Auto(obj)
          end
        end
      end
    }
  },
  [10005] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {43, 28},
      completeType = 1,
      priority = 100,
      showOnce = true,
      isUnfocus = true,
      itemKind = ITEM_LARGE_TYPE_GIFT,
      itemKindId = 30001,
      mustShow = true,
      param = {
        pro = MissionPro_0,
        className = "CQuickUseBoard",
        objName = "btn_use",
        dir = Guide_Dir_Left,
        needMissionId = 10005
      },
      txtparam = {
        txt = "  点击这里打开礼包  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        if objView ~= nil then
          objView:OnBtn_Use(obj)
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {43, 28},
      completeType = 1,
      priority = 90,
      showOnce = true,
      isUnfocus = true,
      itemKind = ITEM_LARGE_TYPE_EQPT,
      param = {
        pro = MissionPro_0,
        className = "CQuickUseBoard",
        objName = "btn_use",
        dir = Guide_Dir_Left,
        needMissionId = 10005
      },
      txtparam = {
        txt = "  点击这里穿上装备  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        if objView ~= nil then
          objView:OnBtn_Use(obj)
        end
      end
    }
  },
  [10010] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMainMenu",
        objName = "btn_menu_pet",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  选择召唤兽  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        if objView ~= nil then
          objView:OnBtn_Menu_Pet(obj)
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_0,
        className = ".CPetListDisplay",
        objName = "btn_get",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  获取召唤兽  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        local mainHero = g_LocalPlayer:getMainHero()
        if mainHero == nil then
          return
        end
        local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
        local petIds = g_LocalPlayer:getAllRoleIds(LOGICTYPE_PET) or {}
        local petNumLimit = data_getMaxPetNum(zs) + g_LocalPlayer:GetPetLimitNum()
        if petNumLimit <= #petIds then
          if zs <= 0 then
            ShowNotifyTips(string.format("召唤兽超过上限%d个,1转后上限增加至%d个", petNumLimit, data_getMaxPetNum(1) + g_LocalPlayer:GetPetLimitNum()))
          else
            ShowNotifyTips(string.format("召唤兽超过上限%d个,无法获得", petNumLimit))
          end
          return
        end
        local petData = data_Pet[20001]
        if petData == nil then
          ShowNotifyTips("此召唤兽不存在")
          return
        end
        local openlv = petData.OPENLV
        if zs <= 0 and mainHero:getProperty(PROPERTY_ROLELEVEL) < petData.OPENLV then
          ShowNotifyTips(string.format("需要等级%d", petData.OPENLV))
          return
        end
        if g_CanGetNewPetFlag == false then
          return
        end
        g_CanGetNewPetFlag = false
        netsend.netbaseptc.requestNewPet(20001)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      delayShowTime = 0,
      showOnce = true,
      param = {
        pro = MissionPro_1,
        className = "CNewPetAnimation",
        objName = "btn_confirm",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  点击这里查看召唤兽  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          print("  点击这里查看召唤兽 ")
          scheduler.performWithDelayGlobal(function()
            objView:OnBtn_Confirm()
          end, 0.5)
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      delayShowTime = 0,
      showOnce = true,
      param = {
        pro = MissionPro_1,
        className = ".CPetList",
        objName = "btn_war",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  让召唤兽参战  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_War()
        end
      end
    }
  },
  [10017] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_0,
        className = "CMainMenu",
        objName = "btn_menu_huoban",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  查看可招募的伙伴  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView, obj)
        if objView ~= nil then
          objView:OnBtn_Menu_HuoBan(obj)
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_0,
        className = "CJiuguanOneHero",
        verifyParam = 1,
        objName = "btn_get",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  招募你的第一位伙伴  ",
        txtalign = Guide_Dir_Right,
        ofx = 10,
        ofy = 0
      },
      clickfun = function(objView)
        print(" clickfun======>>>>    10")
        if objView then
          objView:OnBtn_Get()
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      param = {
        pro = MissionPro_1,
        className = "CNewHuobanAnimation",
        objName = "btn_confirm",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  点击这里查看伙伴  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        if objView then
          scheduler.performWithDelayGlobal(function()
            objView:OnBtn_Confirm()
          end, 0.5)
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      delayShowTime = 0,
      showOnce = true,
      param = {
        pro = MissionPro_1,
        className = "CHuobanList",
        objName = "btn_war",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  让伙伴参战  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        print(" clickfun======>>>>    10")
        if objView ~= nil then
          objView:OnBtn_War()
        end
      end
    }
  },
  [70011] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70011,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  向师傅学习技能  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10001  点击这里进行任务追踪 ")
        g_MissionMgr:TraceMission(70011)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_1,
        className = "CMissionItemInMainView",
        needMissionId = 70011,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  点击查看可学习的技能  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10001  点击这里进行任务追踪 ")
        g_MissionMgr:TraceMission(70011)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {22, 26},
      param = {
        pro = MissionPro_1,
        className = "MainUISkillBar",
        verifyParam = 1,
        objName = "btn_addP",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  点击提升技能熟练度  ",
        txtalign = Guide_Dir_Up,
        ofx = 0,
        ofy = 3,
        reOffset = -20
      },
      clickfun = function(objView)
        print(" clickfun======>>>>    10")
        if objView then
          objView:OnBtn_AddP()
        end
      end
    }
  },
  [70010] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70010,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  师门任务开启了，点击追踪  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70012)
      end
    }
  },
  [70013] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70013,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  学习生活技能  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10001  点击这里进行任务追踪 ")
        g_MissionMgr:TraceMission(70013)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      deltaPos = {0, 0},
      param = {
        pro = MissionPro_1,
        className = "CMissionItemInMainView",
        needMissionId = 70013,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  查看生活技能  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        print(" clickfun======>>>>   10001  点击这里进行任务追踪 ")
        g_MissionMgr:TraceMission(70013)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = 0,
      completeType = 1,
      showOnce = true,
      deltaPos = {0, 0},
      mustShow = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CLifeSkill",
        objName = "bg1",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  选择学习4个生活技能其中1个（左下方有各技能作用的描述）  ",
        txtalign = Guide_Dir_Down,
        ofx = 0,
        ofy = -5
      },
      clickfun = function(objView)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      completeType = 1,
      showOnce = true,
      deltaPos = {0, 0},
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CLifeSkill",
        objName = "btn_learn",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  点击这里学习你已选择的生活技能(左边可查看技能作用)  ",
        txtalign = Guide_Dir_Up,
        ofx = 0,
        ofy = 2
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_Learn()
        end
      end
    }
  },
  [70020] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70020,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  向铁匠请教炼化装备的方法  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70020)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {43, 28},
      completeType = 1,
      priority = 100,
      showOnce = true,
      isUnfocus = true,
      itemKind = ITEM_LARGE_TYPE_GIFT,
      itemKindId = 30016,
      param = {
        pro = MissionPro_1,
        className = "CQuickUseBoard",
        objName = "btn_use",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  点击这里打开礼包  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_Use()
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CMissionItemInMainView",
        needMissionId = 70020,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  尝试炼化你的第一件装备  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70020)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CZhuangbeiShow",
        objName = "btn_upgrade",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  点击炼化后装备将会附上新的附加属性  ",
        txtalign = Guide_Dir_Left,
        ofx = 0,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_Upgrade()
          scheduler.performWithDelayGlobal(function()
            objView:OnBtn_Close()
          end, 0.3)
        end
      end
    }
  },
  [70021] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70021,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  向铁匠请教镶嵌宝石到装备的方法  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70021)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CMissionItemInMainView",
        needMissionId = 70021,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  尝试镶嵌宝石到装备中  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70021)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CZhuangbeiShow",
        objName = "btn_upgrade",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  点击强化，装备强化值+1、基础属性+2%  ",
        txtalign = Guide_Dir_Left,
        ofx = -3,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_Upgrade()
          scheduler.performWithDelayGlobal(function()
            objView:OnBtn_Close()
          end, 0.5)
        end
      end
    }
  },
  [70022] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70022,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  向铁匠请教如何打造高级装备  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70022)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {43, 28},
      completeType = 1,
      priority = 100,
      showOnce = true,
      isUnfocus = true,
      itemKind = ITEM_LARGE_TYPE_GIFT,
      itemKindId = 30017,
      param = {
        pro = MissionPro_1,
        className = "CQuickUseBoard",
        objName = "btn_use",
        dir = Guide_Dir_Left
      },
      txtparam = {
        txt = "  点击这里打开礼包  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_Use()
        end
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CMissionItemInMainView",
        needMissionId = 70022,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  尝试打造1件高级装备  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70022)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_1,
        className = "CCreateZhuangbei",
        objName = "btn_upgrade",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  记得在上方挑选一件和你的人物配点吻合的高级装备，然后点击合成  ",
        txtalign = Guide_Dir_Left,
        ofx = 0,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:Btn_Upgrade()
        end
      end
    }
  },
  [70040] = {
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = "CMissionItemInMainView",
        needMissionId = 70040,
        objName = "m_BgPic",
        dir = Guide_Dir_Right
      },
      txtparam = {
        txt = "  获取坐骑并管制你参战的召唤兽，让你的召唤兽强大起来  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function()
        g_MissionMgr:TraceMission(70040)
      end
    },
    {
      guideType = GuideType_PointObj,
      aniType = GuideAnimitionTyPe_Ret,
      deltaPos = {0, 0},
      completeType = 1,
      showOnce = true,
      isUnfocus = true,
      param = {
        pro = MissionPro_0,
        className = ".CZuoqiShow",
        objName = "btn_getzuoqi",
        dir = Guide_Dir_Up
      },
      txtparam = {
        txt = "  点击免费获取坐骑（别忘了管制参战的召唤兽哟）  ",
        txtalign = Guide_Dir_Left,
        ofx = -10,
        ofy = 0
      },
      clickfun = function(objView)
        if objView ~= nil then
          objView:OnBtn_GetZuoqi()
        end
      end
    }
  }
}
GuideData_Pet = {
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 100,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Attack",
      dir = Guide_Dir_Left
    },
    txtparam = {
      txt = "  点击这里进行物理攻击  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003  点击这里进行物理攻击 ")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Attack(obj)
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    deltaPos = {-2, 20},
    mustShow = true,
    showOnce = true,
    priority = 80,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003  000 ")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 100,
    delayShowTime = 0.8,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Attack",
      dir = Guide_Dir_Left
    },
    txtparam = {
      txt = "  点击这里进行物理攻击  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003  点击这里进行物理攻击 ")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Attack(obj)
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    deltaPos = {-2, 20},
    mustShow = true,
    showOnce = true,
    priority = 80,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003  000 ")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 60,
    delayShowTime = 0.8,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Magic",
      dir = Guide_Dir_Up
    },
    txtparam = {
      txt = "  点击这里展开法术  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003 000000")
      if g_WarScene == nil then
        return
      end
      local waruiIns = g_WarScene.m_WaruiObj
      if waruiIns then
        waruiIns:Btn_Magic(obj)
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {40, 40},
    priority = 50,
    param = {
      pro = MissionPro_0,
      className = "selectHeroSkill",
      objName = function()
        local mainHeroType = g_LocalPlayer:getObjProperty(1, PROPERTY_RACE)
        if mainHeroType == RACE_MO then
          return "pos_33"
        elseif mainHeroType == RACE_GUI then
          return "pos_23"
        end
        return "pos_13"
      end,
      dir = Guide_Dir_Right
    },
    txtparam = {
      txt = "  点击这里选择法术  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function(viewObj)
      print(" ***********  点击这里选择法术 ")
      local waruiIns = g_WarScene.m_WaruiObj
      if waruiIns and viewObj ~= nil then
        viewObj:ShowWarSelectView(false)
        local mainHeroType = g_LocalPlayer:getObjProperty(1, PROPERTY_RACE)
        local skillTypeList = g_LocalPlayer:getMainHero():getSkillTypeList()
        local skillAttr = skillTypeList[1]
        if mainHeroType == RACE_MO then
          skillAttr = skillTypeList[3]
        elseif mainHeroType == RACE_GUI then
          skillAttr = skillTypeList[2]
        end
        local skillList = data_getSkillListByAttr(skillAttr)
        dump(skillList, "2222")
        if skillList then
          waruiIns:SelectSkill(skillList[3])
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {-2, 20},
    priority = 40,
    delayShowTime = 0.2,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 0,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 60,
    delayShowTime = 0.8,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Magic",
      dir = Guide_Dir_Up
    },
    txtparam = {
      txt = "  点击这里展开法术  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003 000000")
      if g_WarScene == nil then
        return
      end
      local waruiIns = g_WarScene.m_WaruiObj
      if waruiIns then
        waruiIns:Btn_Magic(obj)
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {40, 40},
    priority = 50,
    param = {
      pro = MissionPro_0,
      className = "selectPetSkill",
      objName = function()
        return "pos_11"
      end,
      dir = Guide_Dir_Right
    },
    txtparam = {
      txt = "  点击这里选择法术  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function(viewObj)
      print(" ***********  点击这里选择法术 ")
      local waruiIns = g_WarScene.m_WaruiObj
      if waruiIns and viewObj ~= nil then
        viewObj:ShowWarSelectView(false)
        local mainHeroIns = g_LocalPlayer:getMainHero()
        if mainHeroIns ~= nil then
          local mainHeroPetId = mainHeroIns:getProperty(PROPERTY_PETID)
          if mainHeroPetId > 0 then
            local petObj = g_LocalPlayer:getObjById(mainHeroPetId)
            if petObj ~= nil then
              local data_table = data_Pet[petObj:getTypeId()]
              if data_table ~= nil and data_table.skills ~= nil and data_table.skills[1] ~= nil and data_table.skills[1] ~= 0 then
                waruiIns:SelectSkill(data_table.skills[1])
              end
            end
          end
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {-2, 20},
    priority = 40,
    delayShowTime = 0.2,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 0,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    priority = 30,
    delayShowTime = 4.5,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Auto",
      dir = Guide_Dir_Up
    },
    txtparam = {
      txt = "  点击这里选择自动战斗  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Auto(obj)
        end
      end
    end
  }
}
GuideData_Pet_2 = {
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 100,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Attack",
      dir = Guide_Dir_Left
    },
    txtparam = {
      txt = "  点击这里进行物理攻击  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003  点击这里进行物理攻击 ")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Attack(obj)
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    deltaPos = {-2, 20},
    mustShow = true,
    showOnce = true,
    priority = 80,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003  000 ")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 100,
    delayShowTime = 0.8,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Attack",
      dir = Guide_Dir_Left
    },
    txtparam = {
      txt = "  点击这里进行物理攻击  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003  点击这里进行物理攻击 ")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Attack(obj)
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    deltaPos = {-2, 20},
    mustShow = true,
    showOnce = true,
    priority = 80,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003  000 ")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 60,
    delayShowTime = 0.8,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Magic",
      dir = Guide_Dir_Up
    },
    txtparam = {
      txt = "  点击这里展开法术  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003 000000")
      if g_WarScene == nil then
        return
      end
      local waruiIns = g_WarScene.m_WaruiObj
      if waruiIns then
        waruiIns:Btn_Magic(obj)
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {40, 40},
    priority = 50,
    param = {
      pro = MissionPro_0,
      className = "selectHeroSkill",
      objName = function()
        local mainHeroType = g_LocalPlayer:getObjProperty(1, PROPERTY_RACE)
        if mainHeroType == RACE_MO then
          return "pos_33"
        elseif mainHeroType == RACE_GUI then
          return "pos_23"
        end
        return "pos_13"
      end,
      dir = Guide_Dir_Right
    },
    txtparam = {
      txt = "  点击这里选择法术  ",
      txtalign = Guide_Dir_Right,
      ofx = 10,
      ofy = 0
    },
    clickfun = function(viewObj)
      print(" ***********  点击这里选择法术 ")
      local waruiIns = g_WarScene.m_WaruiObj
      if waruiIns and viewObj ~= nil then
        viewObj:ShowWarSelectView(false)
        local mainHeroType = g_LocalPlayer:getObjProperty(1, PROPERTY_RACE)
        local skillTypeList = g_LocalPlayer:getMainHero():getSkillTypeList()
        local skillAttr = skillTypeList[1]
        if mainHeroType == RACE_MO then
          skillAttr = skillTypeList[3]
        elseif mainHeroType == RACE_GUI then
          skillAttr = skillTypeList[2]
        end
        local skillList = data_getSkillListByAttr(skillAttr)
        dump(skillList, "2222")
        if skillList then
          waruiIns:SelectSkill(skillList[3])
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {-2, 20},
    priority = 40,
    delayShowTime = 0.2,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 0,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    mustShow = true,
    completeType = 1,
    showOnce = true,
    priority = 100,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Attack",
      dir = Guide_Dir_Left
    },
    txtparam = {
      txt = "  点击这里进行物理攻击  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003  点击这里进行物理攻击 ")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Attack(obj)
        end
      end
    end
  },
  {
    guideType = GuideType_PointScene,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    deltaPos = {-2, 20},
    priority = 40,
    delayShowTime = 0.2,
    param = {
      pro = MissionPro_0,
      className = "warScene",
      pos = function()
        if g_WarScene then
          local p = g_WarScene:getRoleXYByPos(10003)
          return {
            p.x,
            p.y
          }
        end
      end,
      dir = Guide_Dir_Down
    },
    txtparam = {
      txt = "  点击这里选择目标  ",
      txtalign = Guide_Dir_Right,
      ofx = 0,
      ofy = 0
    },
    clickfun = function()
      print(" clickfun======>>>>   10003")
      if g_WarScene then
        local p = g_WarScene:getRoleViewByPos(10003)
        if p then
          p:SetSelected(true)
          p:TouchOnRole(TOUCH_EVENT_ENDED)
        end
      end
    end
  },
  {
    guideType = GuideType_PointObj,
    aniType = GuideAnimitionTyPe_Ret,
    completeType = 1,
    showOnce = true,
    priority = 30,
    delayShowTime = 4.5,
    param = {
      pro = MissionPro_0,
      className = "warui",
      objName = "m_Btn_Auto",
      dir = Guide_Dir_Up
    },
    txtparam = {
      txt = "  点击这里选择自动战斗  ",
      txtalign = Guide_Dir_Left,
      ofx = -10,
      ofy = 0
    },
    clickfun = function(objView, obj)
      print(" clickfun======>>>>   10003")
      if g_WarScene then
        local waruiIns = g_WarScene.m_WaruiObj
        if waruiIns then
          print(" 233333 ")
          waruiIns:Btn_Auto(obj)
        end
      end
    end
  }
}
GuideData_ClassName = {}
for k, guideDatas in pairs(GuideData_Mission) do
  for i, guideData in ipairs(guideDatas) do
    local className = guideData.param.className
    if GuideData_ClassName[className] == nil then
      GuideData_ClassName[className] = {k}
    else
      GuideData_ClassName[className][#GuideData_ClassName[className] + 1] = k
    end
  end
end
for i, guideData in ipairs(GuideData_Pet) do
  local className = guideData.param.className
  if GuideData_ClassName[className] == nil then
    GuideData_ClassName[className] = {10003}
  else
    GuideData_ClassName[className][#GuideData_ClassName[className] + 1] = 10003
  end
end
