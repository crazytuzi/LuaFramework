g_SettingDlg = nil
local PannelName_SafetyLock = "safetylock"
settingDlg = class("settingDlg", CcsSubView)
function settingDlg:ctor(param, closeFunc)
  settingDlg.super.ctor(self, "views/setting.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_playerinfo = {
      listener = function(obj, t)
        self:OnBtn_ShowInFo(obj, t)
      end,
      variName = "btn_playerinfo"
    },
    btn_faq = {
      listener = function(obj, t)
        self:OnBtn_ShowKeFu(obj, t)
      end,
      variName = "btn_faq"
    },
    btn_syssetting = {
      listener = function(obj, t)
        self:OnBtn_ShowSySSetting(obj, t)
      end,
      variName = "btn_syssetting"
    },
    btn_safetylock = {
      listener = function(obj, t)
        self:OnBtn_ShowSafetylock(obj, t)
      end,
      variName = "btn_safetylock"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self:addBtnSigleSelectGroup({
    {
      self.btn_playerinfo,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_syssetting,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_safetylock,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    },
    {
      self.btn_faq,
      nil,
      ccc3(251, 248, 145),
      ccp(-2, 0)
    }
  })
  self.btn_playerinfo:setTitleText("个\n人\n信\n息")
  self.btn_syssetting:setTitleText("系\n统\n设\n置")
  self.btn_faq:setTitleText("客\n服")
  self.btn_safetylock:setTitleText("安\n全\n锁")
  self.m_LastSelectedTagBtnExceptSafetylock = nil
  self.txt_title_p1 = self:getNode("title")
  self.txt_title_p2 = self:getNode("title_0")
  self.m_curShowViewName = nil
  self.m_isReqSetPwd = false
  local px, py = self.txt_title_p1:getPosition()
  local dpx, dpy = self.txt_title_p2:getPosition()
  self.uperPosition = ccp(px, py)
  self.midPosition = ccp((px + dpx) / 2, (py + dpy) / 2)
  self.m_Param = param
  self.m_CloseFunc = closeFunc
  if channel.showSettingFAQ == false and channel.showUserCenterOnly ~= true then
    self.btn_faq:setVisible(false)
    self.btn_faq:setTouchEnabled(false)
  end
  self.contentPanel = self:getNode("panel_content")
  if self.contentPanel then
    self.contentPanel:setVisible(false)
  end
  self:OnBtn_ShowInFo()
  if g_SettingDlg then
    g_SettingDlg:CloseSelf()
  end
  g_SettingDlg = self
  self:ListenMessage(MsgID_PlayerInfo)
end
function settingDlg:OnMessage(msgSID, ...)
  if msgSID == MsgID_SafetySetPwdViewCancel then
    self.m_isReqSetPwd = false
    if self.m_LastSelectedTagBtnExceptSafetylock ~= nil then
      self:setGroupBtnSelected(self.m_LastSelectedTagBtnExceptSafetylock)
    end
  elseif msgSID == MsgID_SafetylockDataUpdate then
    if g_LocalPlayer == nil then
      return
    end
    if g_LocalPlayer:getSafetyLockIsSetPwd() then
      self:showSafetylockView()
    else
      self:CloseSelf()
    end
  end
end
function settingDlg:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function settingDlg:addChildObjByControl(obj, ctrObj)
  print(" addChildObjByControl  ")
  local parent = ctrObj:getParent()
  local x, y = ctrObj:getPosition()
  local zOrder = ctrObj:getZOrder()
  parent:addChild(obj.m_UINode, zOrder)
  obj:setPosition(ccp(x, y))
end
function settingDlg:OnBtn_ShowInFo(obj, t)
  self.m_LastSelectedTagBtnExceptSafetylock = self.btn_playerinfo
  print(" OnBtn_ShowInFo  ", self.PanelPlayerInfo)
  if self.PanelPlayerInfo == nil then
    self.PanelPlayerInfo = settingDlg_PlayerInfo.new(self.m_Param)
    self:addChildObjByControl(self.PanelPlayerInfo, self.contentPanel)
  else
  end
  self.txt_title_p1:setPosition(self.uperPosition)
  self.txt_title_p1:setText("个人")
  self.txt_title_p2:setText("信息")
  self:showCurPanel("info")
end
function settingDlg:ShowSetPoint()
  self:OnBtn_ShowInFo()
  if self.PanelPlayerInfo then
    self.PanelPlayerInfo:OnBtn_SetPoint()
  end
end
function settingDlg:OnBtn_ShowSySSetting(obj, t)
  self.m_LastSelectedTagBtnExceptSafetylock = self.btn_syssetting
  print(" OnBtn_ShowSySSetting  ")
  if self.PanelSysSetting == nil then
    self.PanelSysSetting = settingDlg_SysSetting.new()
    self:addChildObjByControl(self.PanelSysSetting, self.contentPanel)
  end
  self.txt_title_p1:setPosition(self.uperPosition)
  self.txt_title_p1:setText("系统")
  self.txt_title_p2:setText("设置")
  self:showCurPanel("sys")
end
function settingDlg:OnBtn_ShowKeFu(obj, t)
  self.m_LastSelectedTagBtnExceptSafetylock = self.btn_faq
  print(" OnBtn_ShowKeFu  ")
  if self.PanelKeFu == nil then
    self.PanelKeFu = settingDlg_KeFu.new()
    self:addChildObjByControl(self.PanelKeFu, self.contentPanel)
  end
  self.txt_title_p1:setPosition(self.midPosition)
  self.txt_title_p1:setText("客服")
  self.txt_title_p2:setText("")
  self:showCurPanel("kefu")
end
function settingDlg:OnBtn_ShowSafetylock(obj, t)
  self:flushShowSafetylock()
end
function settingDlg:flushShowSafetylock()
  print("flushShowSafetylock:")
  if g_LocalPlayer == nil then
    if self.m_LastSelectedTagBtnExceptSafetylock ~= nil then
      self:setGroupBtnSelected(self.m_LastSelectedTagBtnExceptSafetylock)
    end
    return
  end
  local isForceCancelTimeEnd = false
  local unlockExceedTime = g_LocalPlayer:getSafetyLockForceUnlockTime()
  if unlockExceedTime ~= nil then
    local serverTime = g_DataMgr:getServerTime()
    if unlockExceedTime <= serverTime then
      isForceCancelTimeEnd = true
    end
  end
  print("g_LocalPlayer:getSafetyLockIsSetPwd():", g_LocalPlayer:getSafetyLockIsSetPwd())
  if g_LocalPlayer:getSafetyLockIsSetPwd() and isForceCancelTimeEnd == false then
    self:showSafetylockView()
  else
    self.m_isReqSetPwd = true
    ShowSafetylockSetPwdView()
  end
end
function settingDlg:showSafetylockView()
  print(" showSafetylockView  ")
  if self.PanelSafetylock == nil then
    self.PanelSafetylock = settingDlg_Safetylock.new()
    self:addChildObjByControl(self.PanelSafetylock, self.contentPanel)
  end
  self.txt_title_p1:setPosition(self.midPosition)
  self.txt_title_p1:setText("安全锁")
  self.txt_title_p2:setText("")
  self:showCurPanel(PannelName_SafetyLock)
end
function settingDlg:showCurPanel(obj)
  if obj == nil then
    self:OnBtn_ShowInFo()
    return
  end
  self.m_curShowViewName = obj
  if self.m_isReqSetPwd then
    self.m_isReqSetPwd = false
  end
  if self.PanelPlayerInfo then
    self.PanelPlayerInfo:setEnabled(obj == "info")
    self.PanelPlayerInfo:setVisible(obj == "info")
    local zorser = 0
    if obj == "info" then
      zorser = 20
    else
      zorser = 0
    end
    self.PanelPlayerInfo:getParent():reorderChild(self.PanelPlayerInfo.m_UINode, zorser)
  end
  if self.PanelSysSetting then
    self.PanelSysSetting:setEnabled("sys" == obj)
    self.PanelSysSetting:setVisible("sys" == obj)
    local zorser = 0
    if obj == "sys" then
      zorser = 20
    else
      zorser = 0
    end
    self.PanelSysSetting:getParent():reorderChild(self.PanelSysSetting.m_UINode, zorser)
  end
  if self.PanelKeFu then
    self.PanelKeFu:setEnabled("kefu" == obj)
    self.PanelKeFu:setVisible("kefu" == obj)
    local zorser = 0
    if obj == "kefu" then
      zorser = 20
    else
      zorser = 0
    end
    self.PanelKeFu:getParent():reorderChild(self.PanelKeFu.m_UINode, zorser)
  end
  if self.PanelSafetylock then
    self.PanelSafetylock:setEnabled(PannelName_SafetyLock == obj)
    self.PanelSafetylock:setVisible(PannelName_SafetyLock == obj)
    local zorser = 0
    if obj == PannelName_SafetyLock then
      zorser = 20
    else
      zorser = 0
    end
    self.PanelSafetylock:getParent():reorderChild(self.PanelSafetylock.m_UINode, zorser)
  end
end
function settingDlg:Clear()
  if self.PanelSysSetting ~= nil then
    self.PanelSysSetting:removeFromParentAndCleanup(true)
    self.PanelSysSetting = nil
  end
  if self.PanelPlayerInfo ~= nil then
    self.PanelPlayerInfo:removeFromParentAndCleanup(true)
    self.PanelPlayerInfo = nil
  end
  if self.m_CloseFunc then
    self.m_CloseFunc()
    self.m_CloseFunc = nil
  end
  if g_SettingDlg == self then
    g_SettingDlg = nil
  end
  self.m_LastSelectedTagBtnExceptSafetylock = nil
end
settingDlg_ReName = class("settingDlg_ReName", CcsSubView)
function settingDlg_ReName:ctor()
  settingDlg_ReName.super.ctor(self, "views/setting_rename.json", {
    isAutoCenter = true,
    opacityBg = 100,
    clickOutSideToClose = false
  })
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_cancel = {
      listener = handler(self, self.OnBtn_Cancel),
      variName = "btn_cancel"
    },
    btn_confirm = {
      listener = handler(self, self.OnBtn_Confirm),
      variName = "btn_confirm"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_NameInput = self:getNode("input_box")
  local size = self.m_NameInput:getContentSize()
  TextFieldEmoteExtend.extend(self.m_NameInput, nil, {
    width = size.width,
    align = CRichText_AlignType_Center
  })
  self.m_NameInput:SetFieldText("")
  self.m_CharNumMinLimit = MinLengthOfName
  self.m_CharNumMaxLimit = MaxLengthOfName
  self.m_NameInput:setMaxLength(self.m_CharNumMaxLimit)
  self:ListenMessage(MsgID_PlayerInfo)
end
function settingDlg_ReName:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.pid == g_LocalPlayer:getPlayerId() and d.pro ~= nil and d.pro[PROPERTY_NAME] ~= nil then
      self:CloseSelf()
    end
  end
end
function settingDlg_ReName:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function settingDlg_ReName:OnBtn_Cancel(obj, t)
  self:CloseSelf()
end
function settingDlg_ReName:OnBtn_Confirm(obj, t)
  local text = self.m_NameInput:GetFieldText()
  if string.len(text) < self.m_CharNumMinLimit then
    ShowNotifyTips(string.format("名字不能少于%d个字", self.m_CharNumMinLimit))
  else
    if string.find(text, " ") ~= nil then
      ShowNotifyTips("名字不能包含空格")
      return
    end
    if string.find(text, "#") ~= nil then
      ShowNotifyTips("名字不能包含#")
      return
    end
    if checkText_DFAFilter(text) then
      local mainHeroId = g_LocalPlayer:getMainHeroId()
      if mainHeroId ~= nil then
        netsend.netbaseptc.setheroname(mainHeroId, text)
      else
        print("改名时主英雄不存在?!")
        self:CloseSelf()
      end
    else
      ShowNotifyTips("名字不合法")
    end
  end
end
function settingDlg_ReName:Clear()
  self.m_NameInput:CloseTheKeyBoard()
  self.m_NameInput:ClearTextFieldExtend()
end
settingDlg_Sys = class("settingDlg_Sys", CcsSubView)
function settingDlg_Sys:ctor()
  settingDlg_Sys.super.ctor(self, "views/setting_sys.json", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close",
      param = {3}
    },
    btn_music = {
      listener = handler(self, self.OnBtn_Music),
      variName = "btn_music"
    },
    btn_sound = {
      listener = handler(self, self.OnBtn_Sound),
      variName = "btn_sound"
    },
    btn_ts_tilifull = {
      listener = handler(self, self.OnBtn_TiliFull),
      variName = "btn_ts_tilifull"
    },
    btn_ts_jiuguan = {
      listener = handler(self, self.OnBtn_JiuGuan),
      variName = "btn_ts_jiuguan"
    },
    btn_ts_gift = {
      listener = handler(self, self.OnBtn_Gift),
      variName = "btn_ts_gift"
    },
    btn_ts_zuoqi = {
      listener = handler(self, self.OnBtn_ZuoQi),
      variName = "btn_ts_zuoqi"
    },
    btn_ts_tili = {
      listener = handler(self, self.OnBtn_TiLi),
      variName = "btn_ts_tili"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.sel_music = self:getNode("sel_music")
  self.sel_sound = self:getNode("sel_sound")
  self.sel_tilifull = self:getNode("sel_tilifull")
  self.sel_jiuguan = self:getNode("sel_jiuguan")
  self.sel_gift = self:getNode("sel_gift")
  self.sel_zuoqi = self:getNode("sel_zuoqi")
  self.sel_tili = self:getNode("sel_tili")
  local initSysSetting = g_LocalPlayer:getSysSetting()
  self.sel_music:setVisible(sysIsMusicOn())
  self.sel_sound:setVisible(sysIsSoundOn())
  self.sel_tilifull:setVisible(initSysSetting.tilifull ~= false)
  self.sel_jiuguan:setVisible(initSysSetting.jiuguan ~= false)
  self.sel_gift:setVisible(initSysSetting.gift ~= false)
  self.sel_zuoqi:setVisible(initSysSetting.zuoqi ~= false)
  self.sel_tili:setVisible(initSysSetting.tili ~= false)
end
function settingDlg_Sys:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function settingDlg_Sys:OnBtn_Music(obj, t)
  self.sel_music:setVisible(not self.sel_music:isVisible())
  if self.sel_music:isVisible() then
    soundManager.EnabledMusic()
  else
    soundManager.DisabledMusic()
  end
end
function settingDlg_Sys:OnBtn_Sound(obj, t)
  self.sel_sound:setVisible(not self.sel_sound:isVisible())
  if self.sel_sound:isVisible() then
    soundManager.EnabledSound()
  else
    soundManager.DisabledSound()
  end
end
function settingDlg_Sys:OnBtn_TiliFull(obj, t)
  self.sel_tilifull:setVisible(not self.sel_tilifull:isVisible())
end
function settingDlg_Sys:OnBtn_JiuGuan(obj, t)
  self.sel_jiuguan:setVisible(not self.sel_jiuguan:isVisible())
end
function settingDlg_Sys:OnBtn_Gift(obj, t)
  self.sel_gift:setVisible(not self.sel_gift:isVisible())
end
function settingDlg_Sys:OnBtn_ZuoQi(obj, t)
  self.sel_zuoqi:setVisible(not self.sel_zuoqi:isVisible())
end
function settingDlg_Sys:OnBtn_TiLi(obj, t)
  self.sel_tili:setVisible(not self.sel_tili:isVisible())
end
function settingDlg_Sys:Clear()
  local music = self.sel_music:isVisible()
  local sound = self.sel_sound:isVisible()
  local tilifull = self.sel_tilifull:isVisible()
  local jiuguan = self.sel_jiuguan:isVisible()
  local gift = self.sel_gift:isVisible()
  local zuoqi = self.sel_zuoqi:isVisible()
  local tili = self.sel_tili:isVisible()
  g_LocalPlayer:recordPushSetting(tilifull, jiuguan, gift, zuoqi, tili)
  g_LocalPlayer:SaveArchive()
  saveMusicAndSound(music, sound)
end
settingDlg_HelpContent = class("settingDlg_HelpContent", CcsSubView)
function settingDlg_HelpContent:ctor(obj, clickpos, clicksize)
  settingDlg_HelpContent.super.ctor(self, "views/setting_helpdlg.json")
  self.m_PreObj = obj
  tipssetposExtend.extend(self, {
    x = clickpos.x,
    y = clickpos.y,
    w = clicksize.width,
    h = clicksize.height
  })
  self.m_UINode:setTouchEnabled(true)
  self.m_UINode:addTouchEventListener(function(touchObj, t)
    if (t == TOUCH_EVENT_ENDED or t == TOUCH_EVENT_CANCELED) and self.m_PreObj then
      self.m_PreObj:CloseHelpDlg()
    end
  end)
end
function settingDlg_HelpContent:setOpenInfo(openLevel, openTime)
  local txt1 = string.format("当前服务器等级:#<G>%d#", openLevel)
  local txt2 = ""
  if openTime ~= nil and openTime ~= 0 then
    txt2 = os.date("下次服务器开放等级时间:#<G>%Y年%m月%d日%H:%M#", openTime)
  end
  local txt3 = "1、低于服务器等级的玩家，根据离线时间可以获得一定量的储备经验。"
  local txt4 = "2、低于服务器等级的玩家，完成任务与活动时，储备经验会按一定比例转化为角色经验。"
  local txt45 = "3、高于服务器等级的玩家，获得经验收益减半。"
  local txt5 = ""
  local curId, endTime, isHide = g_LocalPlayer:getCurChengwei()
  if curId ~= nil then
    local d = data_Title[curId]
    if d ~= nil then
      local hasExpFlag = false
      for _, _ in pairs(d.ExpAdden or {}) do
        hasExpFlag = true
        break
      end
      if hasExpFlag then
        local title = d.Title or "称谓标题"
        local tips = d.Tips or "称谓描述"
        txt5 = string.format("4、称谓#<G>%s#%s", title, tips)
      end
    end
  end
  local allTxt
  if txt5 == "" then
    allTxt = string.format([[
%s
%s
%s
%s
%s]], txt1, txt2, txt3, txt4, txt45)
  else
    allTxt = string.format([[
%s
%s
%s
%s
%s
%s]], txt1, txt2, txt3, txt4, txt45, txt5)
  end
  local bgSize = self:getNode("bg"):getSize()
  local delW = 10
  local delH = 20
  if self.m_RichText == nil then
    local titleTxt = CRichText.new({
      width = bgSize.width - delW,
      verticalSpace = 1,
      font = KANG_TTF_FONT,
      fontSize = 20,
      color = ccc3(255, 255, 255)
    })
    self.m_RichText = titleTxt
    self:addChild(titleTxt, 10)
  else
    self.m_RichText:clearAll()
  end
  self.m_RichText:addRichText(allTxt)
  local x = delW / 2 + 5
  local rSize = self.m_RichText:getContentSize()
  local y = delH / 2
  self.m_RichText:setPosition(ccp(x, y))
  self:getNode("bg"):setSize(CCSize(bgSize.width, rSize.height + delH))
end
function settingDlg_HelpContent:getViewSize()
  return self:getContentSize()
end
function settingDlg_HelpContent:Clear()
  self.m_PreObj = nil
end
settingDlg_PlayerInfo = class("settingDlg_PlayerInfo", CcsSubView)
function settingDlg_PlayerInfo:ctor(param)
  settingDlg_PlayerInfo.super.ctor(self, "views/setting_playerinfo.csb")
  self.rootLayer = self:getNode("panel_info")
  clickArea_check.extend(self)
  local btnBatchListener = {
    btn_rename = {
      listener = handler(self, self.OnBtn_ReName),
      variName = "btn_rename"
    },
    btn_recw = {
      listener = handler(self, self.OnBtn_ReCW),
      variName = "btn_recw"
    },
    btn_bind = {
      listener = handler(self, self.OnBtn_Bind),
      variName = "btn_bind"
    },
    btn_usehl = {
      listener = handler(self, self.OnBtn_HuoLi),
      variName = "btn_usehl"
    },
    btn_kangxingview = {
      listener = handler(self, self.OnBtn_Kang),
      variName = "btn_kangxingview"
    },
    btn_zhuanshengxiuzheng = {
      listener = handler(self, self.OnBtn_ZSXZ),
      variName = "btn_zhuanshengxiuzheng"
    },
    btn_setpoint = {
      listener = handler(self, self.OnBtn_SetPoint),
      variName = "btn_setpoint"
    },
    btn_usebs = {
      listener = handler(self, self.OnBtn_BaoShi),
      variName = "btn_usebs"
    },
    btn_changerole = {
      listener = handler(self, self.OnBtn_ChangeRole),
      variName = "btn_changerole"
    },
    btn_loginout = {
      listener = handler(self, self.OnBtn_LoginOut),
      variName = "btn_loginout"
    },
    btn_kaji = {
      listener = handler(self, self.OnBtn_KaJi),
      variName = "btn_kaji"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.m_Param = param
  local pid = g_LocalPlayer:getPlayerId()
  local txt_id_num = self:getNode("txt_id_num")
  txt_id_num:setText(tostring(pid))
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  self:setRoleShape(mainHero)
  self:SetChiBangInfo(mainHero)
  self.txt_heroname = self:getNode("txt_heroname")
  local _, heroName = data_getRoleShapeAndName(mainHero:getTypeId())
  self.txt_heroname:setText(heroName)
  self.txt_cw = self:getNode("txt_cw")
  local txt_storeexp_num = self:getNode("txt_storeexp_num")
  local storeExp = g_LocalPlayer:getStoreExp()
  txt_storeexp_num:setText(tostring(storeExp))
  AutoLimitObjSize(txt_storeexp_num, 110)
  self:setBangPai()
  self:setHuoLi()
  self:SetHeroProData()
  self:setBaoshiDu()
  self.btn_help_pos = self:getNode("btn_help_pos")
  self.btn_help_pos:setVisible(false)
  local parent = self.btn_help_pos:getParent()
  local x, y = self.btn_help_pos:getPosition()
  local z = self.btn_help_pos:getZOrder()
  local size = self.btn_help_pos:getContentSize()
  self.m_HelpDlg = nil
  local function ClickListener()
    if self.m_HelpDlg == nil then
      self.m_HelpDlg = self:createHelpDlg()
    end
    self.m_HelpDlg:stopAllActions()
    self.m_HelpDlg:runAction(transition.sequence({
      CCDelayTime:create(3),
      CCCallFunc:create(function()
        if self.m_HelpDlg then
          self.m_HelpDlg:removeFromParentAndCleanup(true)
          self.m_HelpDlg = nil
        end
      end)
    }))
  end
  local function LongPressListener()
    if self.m_HelpDlg == nil then
      self.m_HelpDlg = self:createHelpDlg()
    else
      self.m_HelpDlg:stopAllActions()
    end
  end
  local function LongPressEndListner()
    if self.m_HelpDlg ~= nil then
      self.m_HelpDlg:removeFromParentAndCleanup(true)
      self.m_HelpDlg = nil
    end
  end
  local helpBtn = createOneClickObj({
    path = "views/common/btn/btn_help.png",
    bgPath = nil,
    autoSize = nil,
    clickDel = nil,
    LongPressTime = 0.01,
    clickListener = ClickListener,
    LongPressListener = LongPressListener,
    LongPressEndListner = LongPressEndListner,
    clickSoundType = nil,
    grayFlag = nil
  })
  parent:addChild(helpBtn, z)
  helpBtn:ignoreContentAdaptWithSize(false)
  local w, h = 80, 80
  helpBtn:setSize(CCSize(w, h))
  local iSize = helpBtn._Icon:getContentSize()
  helpBtn._Icon:setPosition(ccp((w - iSize.width) / 2, (h - iSize.height) / 2))
  helpBtn:setPosition(ccp(x - w / 2, y - h / 2))
  self.m_HeldBtn = helpBtn
  self:flushLocalPlayerChengwei()
  self:SetAttrTips()
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_WarScene)
  self:ListenMessage(MsgID_Scene)
end
function settingDlg_PlayerInfo:SetAttrTips()
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_HP"), PROPERTY_HP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_hp"), PROPERTY_HP, self:getNode("txt_des_HP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_MP"), PROPERTY_MP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_mp"), PROPERTY_MP, self:getNode("txt_des_MP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_AP"), PROPERTY_AP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_ap"), PROPERTY_AP, self:getNode("txt_des_AP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_des_SP"), PROPERTY_SP)
  self:attrclick_check_withWidgetObj(self:getNode("pro_bg_sp"), PROPERTY_SP, self:getNode("txt_des_SP"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_gg_name"), PROPERTY_GenGu, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_gg"), PROPERTY_GenGu, self:getNode("txt_gg_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_lx_name"), PROPERTY_Lingxing, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_lx"), PROPERTY_Lingxing, self:getNode("txt_lx_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_ll_name"), PROPERTY_LiLiang, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_ll"), PROPERTY_LiLiang, self:getNode("txt_ll_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_mj_name"), PROPERTY_MinJie, nil, handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("addpro_bg_mj"), PROPERTY_MinJie, self:getNode("txt_mj_name"), handler(self, self.getRoleRace))
  self:attrclick_check_withWidgetObj(self:getNode("txt_hl"), "reshuoli")
  self:attrclick_check_withWidgetObj(self:getNode("bg_hl"), "reshuoli", self:getNode("txt_hl"))
  self:attrclick_check_withWidgetObj(self:getNode("txt_bp"), "bpdesc_0")
  self:attrclick_check_withWidgetObj(self:getNode("bg_bp"), "bpdesc_0", self:getNode("txt_bp"))
end
function settingDlg_PlayerInfo:getRoleRace()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return RACE_REN
  else
    return mainHero:getProperty(PROPERTY_RACE)
  end
end
function settingDlg_PlayerInfo:setLevel()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local txt_level_num = self:getNode("txt_level_num")
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  txt_level_num:setText(string.format("%d转%d级", zs, lv))
end
function settingDlg_PlayerInfo:setRoleShape(mainHero)
  local race = mainHero:getProperty(PROPERTY_RACE)
  local shape = mainHero:getProperty(PROPERTY_SHAPE)
  self.role_aureole = self:getNode("role_aureole")
  self.poslayer_race = self:getNode("poslayer_race")
  self.role_aureole:setVisible(false)
  self.poslayer_race:setVisible(false)
  local x, y = self.role_aureole:getPosition()
  local parent = self.role_aureole:getParent()
  local z = self.role_aureole:getZOrder()
  local offx, offy = 0, 0
  local colorList = mainHero:getProperty(PROPERTY_RANCOLOR)
  if colorList == nil or colorList == 0 or type(colorList) == "table" and #colorList == 0 then
    colorList = {
      0,
      0,
      0
    }
  end
  self.m_RoleAni, offx, offy = createBodyByShapeForDlg(shape, colorList)
  parent:addNode(self.m_RoleAni, z + 10)
  self.m_RoleAni:setPosition(x + offx, y + offy)
  self:addclickAniForHeroAni(self.m_RoleAni, self.role_aureole, nil, nil, nil, handler(self, self.onRoleAniSetVisible))
  self.m_RoleAni:setVisible(false)
  if self.m_ChibangAni then
    self.m_ChibangAni:SetActAndDir("stand", 4)
    self.m_ChibangAni:setVisible(false)
  end
  local act1 = CCDelayTime:create(0.01)
  local act2 = CCCallFunc:create(function()
    self.m_RoleAni:setVisible(true)
    if self.m_ChibangAni then
      self.m_ChibangAni:setVisible(true)
    end
  end)
  self.m_RoleAni:runAction(transition.sequence({act1, act2}))
  if self.m_RoleAureole == nil then
    self.m_RoleAureole = CreateSeqAnimation("xiyou/ani/role_aureole.plist", -1, nil, nil, nil, 6)
    parent:addNode(self.m_RoleAureole, z + 9)
    self.m_RoleAureole:setPosition(x + AUREOLE_OFF_X, y + AUREOLE_OFF_Y)
  end
  if self.m_RoleShadow == nil then
    self.m_RoleShadow = display.newSprite("xiyou/pic/pic_shapeShadow.png")
    parent:addNode(self.m_RoleShadow, z + 9)
    self.m_RoleShadow:setPosition(x, y)
  end
  if race ~= self.m_LastRaceShow then
    if self.m_RaceImage ~= nil then
      self.m_RaceImage:removeFromParentAndCleanup(true)
      self.m_RaceImage = nil
    end
    if self.m_RaceBg ~= nil then
      self.m_RaceBg:removeFromParentAndCleanup(true)
      self.m_RaceBg = nil
    end
    self.m_LastRaceShow = race
    local raceTxt = Def_Race_Res_Para_Dict[race] or Def_Race_Res_Para_Dict[RACE_REN]
    self.m_RaceImage = display.newSprite(string.format("views/rolelist/pic_roleicon_%s_unselect.png", raceTxt))
    self.m_RaceImage:setAnchorPoint(ccp(1, 0.5))
    self.m_RaceImage:setScale(0.7)
    local x, y = self.poslayer_race:getPosition()
    local size = self.poslayer_race:getContentSize()
    parent:addNode(self.m_RaceImage)
    self.m_RaceImage:setPosition(x + size.width + 5, y + size.height / 2 - 5)
  end
end
function settingDlg_PlayerInfo:onRoleAniSetVisible(v)
  if self.m_ChibangAni then
    self.m_ChibangAni:setVisible(v)
  end
end
function settingDlg_PlayerInfo:addChibangAni(typeId)
  if self.m_ChibangAni ~= nil and self.m_ChibangAni.__typeId == typeId then
    return
  end
  self:removeChibangAni()
  if self.m_RoleAni then
    local p = self.m_RoleAni:getParent()
    local z = self.m_RoleAni:getZOrder()
    local x, y = self.role_aureole:getPosition()
    setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444)
    self.m_ChibangAni = CChiBang.new(self.m_RoleAni._shape, 10001, self.m_RoleAni)
    resetDefaultAlphaPixelFormat()
    self.m_ChibangAni.__typeId = typeId
    local v = self.m_RoleAni:isVisible()
    self.m_ChibangAni:setVisible(v)
    self.m_ChibangAni:SetActAndDir("stand", 4)
    local off = data_getChiBangOffInfo(self.m_RoleAni._shape, "stand_4")
    self.m_ChibangAni:setPosition(ccp(x + off[1], y + off[2]))
    self.m_RoleAni:playAniFromStart(-1)
    local color = data_getWingColor(typeId)
    self.m_ChibangAni:setColor(color)
  end
end
function settingDlg_PlayerInfo:removeChibangAni()
  if self.m_ChibangAni ~= nil then
    self.m_ChibangAni:Clear()
    self.m_ChibangAni = nil
  end
end
function settingDlg_PlayerInfo:SetChiBangInfo(mainHero)
  local itemIns = mainHero:GetEqptByPos(ITEM_DEF_EQPT_POS_CHIBANG)
  if itemIns == nil then
    self:removeChibangAni()
  else
    local itemTypeId = itemIns:getTypeId()
    self:addChibangAni(itemTypeId)
  end
end
function settingDlg_PlayerInfo:SetHeroProData()
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  self.txt_rolename = self:getNode("txt_rolename")
  local roleName = mainHero:getProperty(PROPERTY_NAME)
  self.txt_rolename:setText(roleName)
  AutoLimitObjSize(self.txt_rolename, 132)
  local txt_level_num = self:getNode("txt_level_num")
  local zs = mainHero:getProperty(PROPERTY_ZHUANSHENG)
  local lv = mainHero:getProperty(PROPERTY_ROLELEVEL)
  txt_level_num:setText(string.format("%d转%d级", zs, lv))
  local curExp = mainHero:getProperty(PROPERTY_EXP)
  local maxExp = CalculateHeroLevelupExp(lv, zs)
  if maxExp == nil or maxExp == 0 then
    if curExp == 0 then
      maxExp = 1
    else
      maxExp = curExp
    end
  end
  local p = math.round(curExp / maxExp * 100)
  if p < 0 then
    p = 0
  elseif p > 100 then
    p = 100
  end
  local pro_exp = self:getNode("pro_exp")
  pro_exp:setPercent(p)
  local txt_exp_num = self:getNode("txt_exp_num")
  txt_exp_num:setText(string.format("%d/%d", curExp, maxExp))
  if lv >= data_getMaxHeroLevel(zs) and curExp >= 0 then
    txt_exp_num:setText("(满)")
    pro_exp:setPercent(100)
  end
  local size = pro_exp:getContentSize()
  AutoLimitObjSize(txt_exp_num, size.width - 20)
  local max_hp = mainHero:getMaxProperty(PROPERTY_HP)
  local cur_hp = mainHero:getProperty(PROPERTY_HP)
  local max_mp = mainHero:getMaxProperty(PROPERTY_MP)
  local cur_mp = mainHero:getProperty(PROPERTY_MP)
  if g_WarScene then
    local tempHp, tempMaxHp, tempMp, tempMaxMp = g_WarScene:getMyRoleHpMpData(g_LocalPlayer:getMainHeroId())
    if tempHp ~= nil then
      max_hp = tempMaxHp
      cur_hp = tempHp
      max_mp = tempMaxMp
      cur_mp = tempMp
    end
  end
  self:getNode("txt_value_HP"):setText(string.format("%d/%d", cur_hp, max_hp))
  local tempHpLimit = self:getNode("pro_bg_hp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_HP"), tempHpLimit - 10)
  self:getNode("txt_value_MP"):setText(string.format("%d/%d", cur_mp, max_mp))
  local tempMpLimit = self:getNode("pro_bg_mp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_MP"), tempMpLimit - 10)
  local cur_ap = mainHero:getProperty(PROPERTY_AP)
  self:getNode("txt_value_AP"):setText(string.format("%d", cur_ap))
  local tempApLimit = self:getNode("pro_bg_ap"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_AP"), tempApLimit - 10)
  local cur_sp = mainHero:getProperty(PROPERTY_SP)
  self:getNode("txt_value_SP"):setText(string.format("%d", cur_sp))
  local tempSpLimit = self:getNode("pro_bg_sp"):getContentSize().width
  AutoLimitObjSize(self:getNode("txt_value_SP"), tempSpLimit - 10)
  local tempPointTextObj = {
    [PROPERTY_GenGu] = self:getNode("txt_gg_point"),
    [PROPERTY_LiLiang] = self:getNode("txt_ll_point"),
    [PROPERTY_MinJie] = self:getNode("txt_mj_point"),
    [PROPERTY_Lingxing] = self:getNode("txt_lx_point")
  }
  local tempAddTextObj = {
    [PROPERTY_GenGu] = self:getNode("txt_gg_point_add"),
    [PROPERTY_LiLiang] = self:getNode("txt_ll_point_add"),
    [PROPERTY_MinJie] = self:getNode("txt_mj_point_add"),
    [PROPERTY_Lingxing] = self:getNode("txt_lx_point_add")
  }
  local tempOProName = {
    [PROPERTY_GenGu] = PROPERTY_OGenGu,
    [PROPERTY_LiLiang] = PROPERTY_OLiLiang,
    [PROPERTY_MinJie] = PROPERTY_OMinJie,
    [PROPERTY_Lingxing] = PROPERTY_OLingxing
  }
  for i, proType in ipairs({
    PROPERTY_GenGu,
    PROPERTY_Lingxing,
    PROPERTY_LiLiang,
    PROPERTY_MinJie
  }) do
    local points = mainHero:getProperty(tempOProName[proType])
    local addNum = mainHero:getProperty(proType) - points
    local txtIns = tempPointTextObj[proType]
    local addObj = tempAddTextObj[proType]
    txtIns:setText(string.format("%d", points))
    local tempX, _ = self:getNode("addpro_bg_gg"):getPosition()
    local _, tempY = txtIns:getPosition()
    if addNum == 0 then
      txtIns:setPosition(ccp(tempX, tempY))
      addObj:setVisible(false)
      txtIns:setScale(1)
      addObj:setScale(1)
    else
      if addNum > 0 then
        addNum = math.floor(math.abs(addNum))
        addObj:setText(string.format("+%d", addNum))
        addObj:setColor(VIEW_DEF_PGREEN_COLOR)
      else
        addNum = math.floor(math.abs(addNum))
        addObj:setText(string.format("-%d", addNum))
        addObj:setColor(VIEW_DEF_WARNING_COLOR)
      end
      addObj:setVisible(true)
      local vSize = txtIns:getContentSize()
      local aSize = addObj:getContentSize()
      local vW = vSize.width
      local aW = aSize.width
      local sumW = vW + aW
      local scale = 1
      if sumW > 80 then
        scale = 80 / sumW
      end
      txtIns:setScale(scale)
      addObj:setScale(scale)
      txtIns:setPosition(ccp(tempX + (-sumW / 2 + vW / 2) * scale, tempY))
      addObj:setPosition(ccp(tempX + (sumW / 2 - aW / 2) * scale, tempY))
    end
  end
  local freeP = mainHero:getProperty(PROPERTY_FREEPOINT)
  self:getNode("txt_point"):setText(tostring(freeP))
  if freeP > 0 then
    self:getNode("freepoint_tip"):setVisible(true)
  else
    self:getNode("freepoint_tip"):setVisible(false)
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:ReSetHeroData(mainHero:getObjId())
  end
end
function settingDlg_PlayerInfo:setVisible(v)
  self.m_UINode:setVisible(v)
  if not v then
    self:CloseHelpDlg()
  end
end
function settingDlg_PlayerInfo:setHuoLi()
  local huoli = g_LocalPlayer:getHuoli()
  local limit = data_Variables.Player_Max_Huoli_Value or 1000
  self:getNode("txt_hl_num"):setText(string.format("%d/%d", huoli, limit))
end
function settingDlg_PlayerInfo:setBangPai()
  self.txt_bpname = self:getNode("txt_bpname")
  self.txt_bpname:setText(g_BpMgr:getLocalBpName())
end
function settingDlg_PlayerInfo:setBaoshiDu()
  local baoshidu = g_LocalPlayer:getLifeSkillBSD()
  local limit = LIFESKILL_MAX_BSD
  self:getNode("txt_bs_num"):setText(string.format("%d/%d", baoshidu, limit))
end
function settingDlg_PlayerInfo:OnBtn_ReName(obj, t)
  getCurSceneView():addSubView({
    subView = settingDlg_ReName.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function settingDlg_PlayerInfo:OnBtn_ReCW(obj, t)
  getCurSceneView():addSubView({
    subView = settingDlg_CW.new(),
    zOrder = MainUISceneZOrder.menuView
  })
end
function settingDlg_PlayerInfo:OnBtn_Bind(obj, t)
  ShowNotifyTips("绑定功能暂未开放")
end
function settingDlg_PlayerInfo:OnBtn_HuoLi()
  if g_LocalPlayer then
    local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_HuoLi)
    print("======================>>>>>>>   openFlag, noOpenType, tips ", openFlag, noOpenType, tips)
    if openFlag then
      openUseEnergyView()
    else
      ShowNotifyTips(tips)
    end
  end
end
function settingDlg_PlayerInfo:OnBtn_BaoShi()
  ShowLifeSkillDetail()
end
function settingDlg_PlayerInfo:OnBtn_Kang()
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
  end
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local midPos = self:getUINode():convertToNodeSpace(ccp(display.width / 2, display.height / 2))
  local function closeFunc()
    self.m_KangXingViewObj = nil
  end
  local tempView = CHuobanKangView.new({closeFunc = closeFunc})
  local bSize = tempView:getBoxSize()
  getCurSceneView():addSubView({
    subView = tempView,
    zOrder = MainUISceneZOrder.popView
  })
  local bSize = tempView:getBoxSize()
  tempView:setPosition(ccp(display.width / 2 - bSize.width / 2, display.height / 2 - bSize.height / 2))
  tempView:ReSetHeroData(mainHero:getObjId())
  self.m_KangXingViewObj = tempView
end
function settingDlg_PlayerInfo:OnBtn_ZSXZ()
  ShowZSXZDetail()
end
function settingDlg_PlayerInfo:OnBtn_SetPoint()
  if self.m_KangXingViewObj then
    self.m_KangXingViewObj:CloseSelf()
    self.m_KangXingViewObj = nil
  end
  if self.m_AddPointDlg then
    self.m_AddPointDlg:CloseSelf()
    self.m_AddPointDlg = nil
    return
  end
  local mainHero = g_LocalPlayer:getMainHero()
  if mainHero == nil then
    return
  end
  local openFlag, noOpenType, tips = g_LocalPlayer:isFunctionUnlock(OPEN_Func_RolePoint)
  if not openFlag then
    ShowNotifyTips(tips)
    return
  end
  local spId
  if self.m_Param ~= nil then
    spId = self.m_Param.spId
    self.m_Param = nil
  end
  self.m_AddPointDlg = CAddPoint.new(handler(self, self.OnAddPointClose), spId)
  getCurSceneView():addSubView({
    subView = self.m_AddPointDlg,
    zOrder = MainUISceneZOrder.popView
  })
  local bSize = self.m_AddPointDlg:getContentSize()
  self.m_AddPointDlg:setPosition(ccp(display.width / 2 - bSize.width / 2, display.height / 2 - bSize.height / 2))
  self.m_AddPointDlg:LoadProperties(mainHero)
  if spId ~= nil then
    self.m_AddPointDlg:OnBtn_Auto()
    self.m_AddPointDlg:setAppointLable(spId)
  end
end
function settingDlg_PlayerInfo:OnAddPointClose()
  self.m_AddPointDlg = nil
end
function settingDlg_PlayerInfo:OnBtn_ChangeRole(obj, t)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中无法此操作")
    return
  end
  g_DataMgr:LogoutAndShowServerRoleListView()
end
function settingDlg_PlayerInfo:OnBtn_LoginOut(obj, t)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中无法此操作")
    return
  end
  if not g_DataMgr:IsInGame() then
    return
  end
  local confirmBoxDlg = CPopWarning.new({
    text = "确定要退出游戏，切换账号?",
    confirmFunc = function()
      if g_DataMgr:IsInGame() then
        g_ChannelMgr:Logout()
        g_DataMgr:returnToLoginView()
      end
    end,
    cancelText = "取消",
    confirmText = "确定"
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function settingDlg_PlayerInfo:OnBtn_KaJi(obj, t)
  local warId
  if JudgeIsInWar() then
    warId = g_WarScene:getWarID()
  end
  netsend.netwar.tellSerToKillWar(warId)
end
function settingDlg_PlayerInfo:createHelpDlg()
  local x, y = self.m_HeldBtn:getPosition()
  local parent = self.m_HeldBtn:getParent()
  local pos = parent:convertToWorldSpace(ccp(x, y))
  local size = self.m_HeldBtn:getSize()
  local helpDlg = settingDlg_HelpContent.new(self, pos, size)
  if self.m_SvrOpenLevelInfo ~= nil then
    helpDlg:setOpenInfo(self.m_SvrOpenLevelInfo[1], self.m_SvrOpenLevelInfo[2])
  else
    netsend.netbaseptc.requestSvrOpenLevelInfo()
  end
  return helpDlg
end
function settingDlg_PlayerInfo:CloseHelpDlg()
  if self.m_HelpDlg then
    self.m_HelpDlg:removeFromParentAndCleanup(true)
    self.m_HelpDlg = nil
  end
end
function settingDlg_PlayerInfo:OnMessage(msgSID, ...)
  if msgSID == MsgID_HeroUpdate then
    local arg = {
      ...
    }
    local d = arg[1]
    if d.heroId == g_LocalPlayer:getMainHeroId() then
      self:SetHeroProData()
    end
  elseif msgSID == MsgID_HouliUpdate then
    self:setHuoLi()
  elseif msgSID == MsgID_SvrOpenLevelInfo then
    local arg = {
      ...
    }
    local openLevel = arg[1]
    local openTime = arg[2]
    self.m_SvrOpenLevelInfo = {openLevel, openTime}
    if self.m_HelpDlg then
      self.m_HelpDlg:setOpenInfo(openLevel, openTime)
    end
  elseif msgSID == MsgID_ChengWeiChanged then
    local arg = {
      ...
    }
    print("---->> MsgID_ChengWeiChanged msg:", arg[1], g_LocalPlayer:getPlayerId())
    if arg[1] == g_LocalPlayer:getPlayerId() then
      self:flushLocalPlayerChengwei()
    end
  elseif msgSID == MsgID_LocalBpAndJob then
    self:setBangPai()
  elseif msgSID == MsgID_WarScene_ViewHpMpChanged then
    local arg = {
      ...
    }
    if arg[1] == g_LocalPlayer:getPlayerId() and arg[2] == g_LocalPlayer:getMainHeroId() then
      self:SetHeroProData()
    end
  elseif msgSID == MsgID_Scene_War_Exit then
    self:SetHeroProData()
  elseif msgSID == MsgID_LifeSkillBSDUpdate then
    self:setBaoshiDu()
  end
end
function settingDlg_PlayerInfo:flushLocalPlayerChengwei()
  local curId, endTime, isHide = g_LocalPlayer:getCurChengwei()
  print("flushLocalPlayerChengwei:", curId, endTime, isHide)
  local curShowTxt = "暂无称谓"
  if curId ~= 0 and isHide ~= true and (endTime == nil or endTime > g_DataMgr:getServerTime()) then
    local d = data_Title[curId]
    if d then
      curShowTxt = d.Title
    end
  end
  self.txt_cw:setText(curShowTxt)
  AutoLimitObjSize(self.txt_cw, 130)
end
function settingDlg_PlayerInfo:Clear()
  if self.m_HelpDlg ~= nil then
    self.m_HelpDlg:removeFromParentAndCleanup(true)
    self.m_HelpDlg = nil
  end
end
settingDlg_CW = class("settingDlg_CW", CcsSubView)
function settingDlg_CW:ctor()
  settingDlg_CW.super.ctor(self, "views/setting_recw.csb", {isAutoCenter = true, opacityBg = 100})
  local btnBatchListener = {
    btn_changeCW = {
      listener = handler(self, self.OnBtn_ChangeChengwei),
      variName = "btn_changeCW"
    },
    btn_hideCW = {
      listener = handler(self, self.OnBtn_HideChengwei),
      variName = "btn_hideCW"
    },
    btn_close = {
      listener = handler(self, self.OnBtn_Close),
      variName = "btn_close"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt_title = self:getNode("txt_title")
  self.scroller_cw = self:getNode("scroller_cw")
  self.m_Items = {}
  self.m_TouchStartItem = nil
  self.m_LastSelectedItem = nil
  self.scroller_cw:addTouchItemListenerListView(handler(self, self.selecetd), handler(self, self.scrollerTouched))
  self:ListenMessage(MsgID_PlayerInfo)
  self:ListenMessage(MsgID_ReConnect)
  netsend.netbaseptc.getAllChengwei()
end
function settingDlg_CW:onEnterEvent()
  self:HideSelf()
end
function settingDlg_CW:setShowForGetting(isGetting)
  self.txt_title:setVisible(not isGetting)
  self.btn_hideCW:setEnabled(not isGetting)
  self.btn_changeCW:setEnabled(not isGetting)
end
function settingDlg_CW:ShowSelf()
  self:setVisible(true)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(true)
  end
end
function settingDlg_CW:HideSelf()
  self:setVisible(false)
  if self._auto_create_opacity_bg_ins then
    self._auto_create_opacity_bg_ins:setVisible(false)
  end
end
function settingDlg_CW:selecetd(item, index, listObj)
end
function settingDlg_CW:scrollerTouched(item, index, listObj, status)
end
function settingDlg_CW:OnMessage(msgSID, ...)
  if msgSID == MsgID_ServerSendAllChengWei then
    self:loadAllChengwei()
  elseif msgSID == MsgID_ReConnect_Ready_ReLogin then
    self:CloseSelf()
  elseif msgSID == MsgID_ChengWeiTimeChanged then
    local arg = {
      ...
    }
    local cwId = arg[1]
    for i, item in pairs(self.m_Items) do
      local item = self.m_Items[i]
      if cwId == item:getId() then
        item:setTextAndState()
        break
      end
    end
  elseif msgSID == MsgID_DeleteOneChengWei then
    local arg = {
      ...
    }
    local cwId = arg[1]
    print("     == MsgID_DeleteOneChengWei:", cwId)
    for i, item in pairs(self.m_Items) do
      local item = self.m_Items[i]
      if cwId == item:getId() then
        print("     ==删除一个称谓:", cwId)
        if self.m_LastSelectedItem == item then
          self:itemSelected(nil)
        end
        self.scroller_cw:removeItem(i)
        table.remove(self.m_Items, i)
        break
      end
    end
  end
end
function settingDlg_CW:itemSelected(item)
  if self.m_LastSelectedItem then
    self.m_LastSelectedItem:setSelected(false)
  end
  self.m_LastSelectedItem = item
  if self.m_LastSelectedItem then
    self.m_LastSelectedItem:setSelected(true)
    self.m_LastSelectedItem:askForXuFei()
  end
end
function settingDlg_CW:loadAllChengwei()
  local cws, num = g_LocalPlayer:getAllChengwei()
  if num == 0 then
    AwardPrompt.addPrompt("暂无称谓")
    self:CloseSelf()
    return
  end
  self:ShowSelf()
  local ids = {}
  for k, v in pairs(cws) do
    ids[#ids + 1] = k
  end
  table.sort(ids)
  self.m_Items = {}
  for i, v in ipairs(ids) do
    local item = settingDlg_CW_Item.new(v, cws[v], handler(self, self.itemSelected))
    self.scroller_cw:pushBackCustomItem(item:getUINode())
    self.m_Items[i - 1] = item
  end
end
function settingDlg_CW:OnBtn_ChangeChengwei(obj, t)
  print("OnBtn_ChangeChengwei")
  if self.m_LastSelectedItem == nil then
    AwardPrompt.addPrompt("请先选中需要显示的称号")
    return
  end
  local id = self.m_LastSelectedItem:getId()
  netsend.netbaseptc.setAllChengwei(id)
end
function settingDlg_CW:OnBtn_HideChengwei(obj, t)
  print("OnBtn_HideChengwei")
  netsend.netbaseptc.HideChengwei()
end
function settingDlg_CW:OnBtn_Close(obj, t)
  self:CloseSelf()
end
function settingDlg_CW:Clear()
end
settingDlg_CW_Item = class("settingDlg_CW_Item", CcsSubView)
function settingDlg_CW_Item:ctor(id, data, selectListener)
  settingDlg_CW_Item.super.ctor(self, "views/setting_recw_item.csb")
  local btnBatchListener = {
    btn_help = {
      listener = handler(self, self.OnBtn_Help),
      variName = "btn_help"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.txt = self:getNode("txt")
  self.panel_sel = self:getNode("panel_sel")
  self.pic_bg = self:getNode("pic_bg")
  self.pic_bg:setTouchEnabled(true)
  self.pic_bg:addTouchEventListener(handler(self, self.TouchBg))
  self:setSelected(false)
  self.m_Id = id
  self.m_EndTime = data.endTime
  local title = "[未知称谓]"
  local d = data_Title[id]
  if d then
    title = d.Title
    if d.Category == "marry" then
      local banlvId = g_FriendsMgr:getBanLvId()
      local banlvName = g_FriendsMgr:getFriendName(banlvId)
      if banlvName == "" or banlvName == 0 and banlvName == nil then
        banlvName = "某人"
      end
      if g_FriendsMgr:getIsBanLv(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_FEMALE then
        title = banlvName .. "的娘子"
      elseif g_FriendsMgr:getIsBanLv(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_MALE then
        title = banlvName .. "的夫君"
      elseif g_FriendsMgr:getIsJiYou(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_FEMALE then
        title = banlvName .. "的姐妹"
      elseif g_FriendsMgr:getIsJiYou(banlvId) and g_LocalPlayer:getObjProperty(1, PROPERTY_GENDER) == HERO_MALE then
        title = banlvName .. "的兄弟"
      end
    end
  end
  self.txt:setText(title)
  self:setTextAndState()
  self.m_SelectedListener = selectListener
  if self.m_EndTime ~= nil then
    self.m_DetectEndTime = scheduler.scheduleGlobal(handler(self, self.DetectEndTime), 1)
  end
end
function settingDlg_CW_Item:DetectEndTime(dt)
  self:setTextAndState()
end
function settingDlg_CW_Item:setTextAndState()
  local cws, num = g_LocalPlayer:getAllChengwei()
  local temp = cws[self.m_Id] or {}
  self.m_EndTime = temp.endTime
  local serverTime = g_DataMgr:getServerTime()
  if self.m_EndTime ~= nil and serverTime > 0 then
    if serverTime > self.m_EndTime then
      if self.m_TimeOutImg ~= nil then
        self.m_TimeOutImg:setVisible(true)
      else
        self.m_TimeOutImg = display.newSprite("views/pic/pic_timeout.png")
        self.m_TimeOutImg:setAnchorPoint(ccp(1, 0))
        self.m_TimeOutImg:setPosition(ccp(300, 50))
        self:addNode(self.m_TimeOutImg, 999)
      end
      if self.m_TimeTxt ~= nil then
        self.m_TimeTxt:setVisible(false)
      end
    else
      if self.m_TimeOutImg ~= nil then
        self.m_TimeOutImg:setVisible(false)
      end
      local restTime = self.m_EndTime - serverTime
      local d = math.floor(restTime / 3600 / 24)
      local h = math.floor(restTime / 3600 % 24)
      local m = math.floor(restTime % 3600 / 60)
      local s = math.floor(restTime % 60)
      local txt = "有效期:"
      if d > 0 then
        txt = string.format("%s%d天", txt, d)
      end
      if h > 0 then
        txt = string.format("%s%d小时", txt, h)
      end
      if s > 0 then
        m = m + 1
        if m == 60 then
          m = 59
        end
      end
      if m > 0 then
        txt = string.format("%s%d分", txt, m)
      end
      if self.m_TimeTxt ~= nil then
        self.m_TimeTxt:setVisible(true)
        self.m_TimeTxt:setString(txt)
      else
        self.m_TimeTxt = ui.newTTFLabel({
          text = txt,
          font = KANG_TTF_FONT,
          size = 22,
          color = ccc3(188, 125, 41)
        })
        self.m_TimeTxt:setAnchorPoint(ccp(0, 0))
        self.m_TimeTxt:setPosition(ccp(25, 20))
        self:addNode(self.m_TimeTxt)
      end
    end
  end
end
function settingDlg_CW_Item:TouchBg(touchObj, t)
  if t == TOUCH_EVENT_BEGAN then
    self:setTouchStatus(true)
  elseif t == TOUCH_EVENT_ENDED then
    self:setTouchStatus(false)
    if self.m_SelectedListener then
      self.m_SelectedListener(self)
    end
  elseif t == TOUCH_EVENT_CANCELED then
    self:setTouchStatus(false)
  end
end
function settingDlg_CW_Item:OnBtn_Help(obj, t)
  print("OnBtn_Help")
  getCurSceneView():addSubView({
    subView = settingDlg_CW_Info.new(self.m_Id),
    zOrder = MainUISceneZOrder.popDetailView
  })
end
function settingDlg_CW_Item:setSelected(isSel)
  self.panel_sel:setVisible(isSel)
end
function settingDlg_CW_Item:askForXuFei()
  local serverTime = g_DataMgr:getServerTime()
  if self.m_EndTime ~= nil and serverTime > 0 and serverTime > self.m_EndTime and data_Title[self.m_Id] and data_Title[self.m_Id].CostGold ~= 0 then
    do
      local title = data_Title[self.m_Id].Title
      local cost = data_Title[self.m_Id].CostGold
      local temp = CPopWarning.new
      local dlg = CPopWarning.new({
        title = "提示",
        text = string.format("#<G>%s#已过有效期,\n是否确定花费%d#<IR2>#\n进行续费?", title, cost),
        confirmFunc = function()
          if g_LocalPlayer:getGold() >= cost then
            netsend.netbaseptc.ChengweiXuFei(self.m_Id)
          else
            ShowNotifyTips("元宝不足")
            ShowRechargeView()
          end
        end,
        cancelText = "取消",
        confirmText = "确定",
        align = CRichText_AlignType_Left
      })
      dlg:ShowCloseBtn(false)
    end
  end
end
function settingDlg_CW_Item:getId()
  return self.m_Id
end
function settingDlg_CW_Item:setTouchStatus(isTouch)
  if self.pic_bg then
    self.pic_bg:stopAllActions()
    if isTouch then
      self.pic_bg:setScaleX(0.95)
      self.pic_bg:setScaleY(0.95)
    else
      self.pic_bg:setScaleX(1)
      self.pic_bg:setScaleY(1)
      self.pic_bg:runAction(transition.sequence({
        CCScaleTo:create(0.1, 1.05, 1.05),
        CCScaleTo:create(0.1, 1, 1)
      }))
    end
  end
end
function settingDlg_CW_Item:Clear()
  self.m_SelectedListener = nil
  if self.m_DetectEndTime ~= nil then
    scheduler.unscheduleGlobal(self.m_DetectEndTime)
    self.m_DetectEndTime = nil
  end
end
settingDlg_CW_Info = class("settingDlg_CW_Info", function()
  local widget = Widget:create()
  widget:setAnchorPoint(ccp(0, 0))
  widget:ignoreContentAdaptWithSize(false)
  widget:setSize(CCSize(display.width, display.height))
  return widget
end)
function settingDlg_CW_Info:ctor(cwId)
  self:setTouchEnabled(true)
  self:addTouchEventListener(handler(self, self.Touch))
  local d = data_Title[cwId] or {}
  local title = d.Title or "称谓标题"
  local des = d.Desc or "称谓描述"
  self.m_TxtX = 255
  local blackH = 130
  local layerC = display.newColorLayer(ccc4(0, 0, 0, 200))
  layerC:setContentSize(CCSize(display.width, blackH))
  self:addNode(layerC, 5)
  layerC:setPosition(ccp(0, 0))
  local sharedFileUtils = CCFileUtils:sharedFileUtils()
  self.m_HeadImg = display.newSprite("xiyou/head/head20034_big.png")
  self:addNode(self.m_HeadImg, 10)
  local size = self.m_HeadImg:getContentSize()
  self.m_HeadImg:setPosition(ccp(self.m_TxtX / 2, size.height / 2))
  local titleW = display.width - self.m_TxtX - 30
  local titleColor = ccc3(255, 196, 98)
  local titleTxt = CRichText.new({
    width = titleW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 24,
    color = titleColor
  })
  self:addChild(titleTxt, 10)
  titleTxt:addRichText(string.format("%s", title))
  local titleTxtSize = titleTxt:getRichTextSize()
  local titleY = blackH - titleTxtSize.height - 15
  titleTxt:setPosition(ccp(self.m_TxtX, titleY))
  titleY = titleY - titleTxtSize.height
  local desColor = ccc3(255, 255, 255)
  local desTxt = CRichText.new({
    width = titleW,
    verticalSpace = 1,
    font = KANG_TTF_FONT,
    fontSize = 22,
    color = desColor
  })
  self:addChild(desTxt, 10)
  desTxt:addRichText(string.format("%s", des))
  local desTxtSize = desTxt:getRichTextSize()
  local s = desTxt:getRichTextSize()
  titleY = blackH - 50 - desTxtSize.height
  desTxt:setPosition(ccp(self.m_TxtX, titleY))
end
function settingDlg_CW_Info:Touch(touchObj, t)
  if t == TOUCH_EVENT_ENDED then
    self:removeSelf()
  end
end
settingDlg_SysSetting = class("settingDlg_SysSetting", CcsSubView)
function settingDlg_SysSetting:ctor()
  settingDlg_SysSetting.super.ctor(self, "views/setting_select.csb")
  local btnBatchListener = {
    btn_music = {
      listener = handler(self, self.OnBtn_Music),
      variName = "btn_music"
    },
    btn_sound = {
      listener = handler(self, self.OnBtn_Sound),
      variName = "btn_sound"
    },
    btn_fbfriend = {
      listener = handler(self, self.OnBtn_FbFriend),
      variName = "btn_fbfriend"
    },
    btn_curplayernun = {
      listener = handler(self, self.OnBtn_CurPlayerNun),
      variName = "btn_curplayernun"
    },
    btn_getdy = {
      listener = handler(self, self.OnBtn_TiLi),
      variName = "btn_getdy"
    },
    btn_recoverfull = {
      listener = handler(self, self.OnBtn_TiliFull),
      variName = "btn_recoverfull"
    },
    btn_flushshop = {
      listener = handler(self, self.OnBtn_FlushShop),
      variName = "btn_flushshop"
    },
    btn_openactivity = {
      listener = handler(self, self.OnBtn_OpenActivity),
      variName = "btn_openactivity"
    },
    btn_changerole = {
      listener = handler(self, self.OnBtn_ChangeRole),
      variName = "btn_changerole"
    },
    btn_loginout = {
      listener = handler(self, self.OnBtn_LoginOut),
      variName = "btn_loginout"
    },
    btn_kaji = {
      listener = handler(self, self.OnBtn_KaJi),
      variName = "btn_kaji"
    }
  }
  for i = 1, 3 do
    do
      local btnVarName = string.format("btn_curplayernun_%d", i)
      btnBatchListener[btnVarName] = {
        listener = function()
          self:OnBtn_CurPlayerSyncName(i)
        end,
        variName = btnVarName
      }
      local txtVarName = string.format("txt_curplayernun_%d", i)
      self[txtVarName] = self:getNode(txtVarName)
      local selPicVarName = string.format("sel_curplayernun_%d", i)
      self[selPicVarName] = self:getNode(selPicVarName)
    end
  end
  self:addBatchBtnListener(btnBatchListener)
  self.sel_music = self:getNode("sel_music")
  self.sel_sound = self:getNode("sel_sound")
  self.sel_fbfriend = self:getNode("sel_fbfriend")
  self.sel_flushshop = self:getNode("sel_flushshop")
  self.sel_openactivity = self:getNode("sel_openactivity")
  local initSysSetting = g_LocalPlayer:getSysSetting()
  self.sel_music:setVisible(sysIsMusicOn())
  self.sel_sound:setVisible(sysIsSoundOn())
  self.sel_fbfriend:setVisible(initSysSetting.fbfriend ~= false)
  self.sel_flushshop:setVisible(initSysSetting.flushshop ~= false)
  self.sel_openactivity:setVisible(initSysSetting.openactivity ~= false)
  self.btn_fbfriend:setEnabled(false)
  self.btn_fbfriend:setVisible(false)
  self.sel_fbfriend:setVisible(false)
  self:getNode("txt_fbfriend"):setVisible(false)
  self.btn_fbfriend:setTouchEnabled(false)
  local scoller = self:getNode("ScrollView_9")
  scoller:setInnerContainerSize(self:getNode("Panel_10"):getSize())
  self.m_SyncPlayerNumType = SyncPlayerType_Min
  local syncType = getSyncPlayerTypeFromConfig()
  if syncType then
    self.m_SyncPlayerNumType = syncType
  end
  self.m_SyncPlayerNumType_Init = self.m_SyncPlayerNumType
  self:flushSyncPlayerNumShow()
  g_SettingDlg_SysSetting = self
end
function settingDlg_SysSetting:OnBtn_Music(obj, t)
  self.sel_music:setVisible(not self.sel_music:isVisible())
  if self.sel_music:isVisible() then
    ShowNotifyTips("设置成功")
    soundManager.EnabledMusic()
  else
    soundManager.DisabledMusic()
    ShowNotifyTips("取消成功")
  end
end
function settingDlg_SysSetting:OnBtn_Sound(obj, t)
  self.sel_sound:setVisible(not self.sel_sound:isVisible())
  if self.sel_sound:isVisible() then
    soundManager.EnabledSound()
    ShowNotifyTips("设置成功")
  else
    soundManager.DisabledSound()
    ShowNotifyTips("取消成功")
  end
end
function settingDlg_SysSetting:OnBtn_FbFriend(obj, t)
  self.sel_fbfriend:setVisible(not self.sel_fbfriend:isVisible())
  if self.sel_fbfriend:isVisible() then
    ShowNotifyTips("设置成功")
  else
    ShowNotifyTips("取消成功")
  end
end
function settingDlg_SysSetting:OnBtn_CurPlayerNun(obj, t)
end
function settingDlg_SysSetting:OnBtn_TiLi(obj, t)
end
function settingDlg_SysSetting:OnBtn_TiliFull(obj, t)
end
function settingDlg_SysSetting:OnBtn_FlushShop(obj, t)
  self.sel_flushshop:setVisible(not self.sel_flushshop:isVisible())
  if self.sel_flushshop:isVisible() then
    ShowNotifyTips("设置成功")
  else
    ShowNotifyTips("取消成功")
  end
end
function settingDlg_SysSetting:OnBtn_OpenActivity(obj, t)
  self.sel_openactivity:setVisible(not self.sel_openactivity:isVisible())
  if self.sel_openactivity:isVisible() then
    ShowNotifyTips("设置成功")
  else
    ShowNotifyTips("取消成功")
  end
end
function settingDlg_SysSetting:OnBtn_CurPlayerSyncName(index)
  self.m_SyncPlayerNumType = index
  self:flushSyncPlayerNumShow()
  local temp = self:getNode(string.format("sel_curplayernun_%d", index))
  if temp then
    ShowNotifyTips("设置成功")
  end
end
function settingDlg_SysSetting:flushSyncPlayerNumShow()
  for i = 1, 3 do
    self[string.format("sel_curplayernun_%d", i)]:setVisible(i == self.m_SyncPlayerNumType)
  end
end
function settingDlg_SysSetting:SaveData()
  local music = self.sel_music:isVisible()
  local sound = self.sel_sound:isVisible()
  local fbfriend = self.sel_fbfriend:isVisible()
  local flushshop = self.sel_flushshop:isVisible()
  local openactivity = self.sel_openactivity:isVisible()
  if g_LocalPlayer then
    local tb = g_LocalPlayer:getSysSetting()
    tb.fbfriend = fbfriend
    tb.curplayernun = curplayernun
    tb.tilifull = tilifull
    tb.tili = tili
    tb.flushshop = flushshop
    tb.openactivity = openactivity
    g_LocalPlayer:recordPushSetting(tb)
    g_LocalPlayer:SaveArchive()
    startClientService()
    if self.m_SyncPlayerNumType ~= self.m_SyncPlayerNumType_Init then
      print("-->> 同屏人数设置改变了")
      netsend.netbaseptc.setSyncPlayerType(self.m_SyncPlayerNumType)
    end
  end
  saveMusicAndSound(music, sound)
end
function settingDlg_SysSetting:OnBtn_ChangeRole(obj, t)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中无法此操作")
    return
  end
  g_DataMgr:LogoutAndShowServerRoleListView()
end
function settingDlg_SysSetting:OnBtn_LoginOut(obj, t)
  if g_HunyinMgr and g_HunyinMgr:IsLocalRoleInHuaChe() then
    ShowNotifyTips("你正在进行婚礼巡游,无法进行此项操作")
    return
  end
  if JudgeIsInWar() then
    ShowNotifyTips("战斗中无法此操作")
    return
  end
  if not g_DataMgr:IsInGame() then
    return
  end
  local confirmBoxDlg = CPopWarning.new({
    text = "确定要退出游戏，切换账号?",
    confirmFunc = function()
      if g_DataMgr:IsInGame() then
        g_ChannelMgr:Logout()
        g_DataMgr:returnToLoginView()
      end
    end,
    cancelText = "取消",
    confirmText = "确定"
  })
  confirmBoxDlg:ShowCloseBtn(false)
end
function settingDlg_SysSetting:OnBtn_KaJi(obj, t)
  local warId
  if JudgeIsInWar() then
    warId = g_WarScene:getWarID()
  end
  netsend.netwar.tellSerToKillWar(warId)
end
function settingDlg_SysSetting:Clear()
  self:SaveData()
  if g_SettingDlg_SysSetting == self then
    g_SettingDlg_SysSetting = nil
  end
end
settingDlg_KeFu = class("settingDlg_KeFu", CcsSubView)
function settingDlg_KeFu:ctor()
  settingDlg_KeFu.super.ctor(self, "views/setting_kefu.csb")
  local btnBatchListener = {
    btn_momoba = {
      listener = handler(self, self.OnBtn_momoba),
      variName = "btn_momoba"
    },
    btn_userCeter = {
      listener = handler(self, self.OnBtn_userceter),
      variName = "btn_userCeter"
    },
    btn_userProposal = {
      listener = handler(self, self.OnBtn_userProposal),
      variName = "btn_userProposal"
    },
    btn_notice = {
      listener = handler(self, self.OnBtn_LoginNotice),
      variName = "btn_notice"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
  self.btn_momoba:setVisible(false)
  self.btn_momoba:setTouchEnabled(false)
  print("channel.showUserCenterOnly:", channel.showUserCenterOnly)
  if channel.showUserCenterOnly == true then
    for i, v in ipairs({
      self.btn_momoba,
      self.btn_userProposal
    }) do
      print("i, v:", i, v)
      v:setVisible(false)
      v:setTouchEnabled(false)
    end
  end
end
function settingDlg_KeFu:OnBtn_momoba(obj, t)
end
function settingDlg_KeFu:OnBtn_userceter(obj, t)
  g_ChannelMgr:enterPersonCenter()
end
function settingDlg_KeFu:OnBtn_userProposal(obj, t)
  g_ChannelMgr:showFAQView()
end
function settingDlg_KeFu:OnBtn_LoginNotice(obj, t)
  if g_SettingDlg then
    g_SettingDlg:CloseSelf()
    g_SettingDlg = nil
  end
  ShowLoginNoticeInGame()
end
settingDlg_Safetylock = class("settingDlg_Safetylock", CcsSubView)
function settingDlg_Safetylock:ctor()
  settingDlg_Safetylock.super.ctor(self, "views/setting_safetylock.csb")
  local btnBatchListener = {
    btn_unlock = {
      listener = handler(self, self.OnBtn_Unlock),
      variName = "btn_unlock"
    },
    btn_cancelLock = {
      listener = handler(self, self.OnBtn_CancelLock),
      variName = "btn_cancelLock"
    },
    btn_unlockForce = {
      listener = handler(self, self.OnBtn_ForceLock),
      variName = "btn_unlockForce"
    },
    btn_resetPwd = {
      listener = handler(self, self.OnBtn_resetPwd),
      variName = "btn_resetPwd"
    }
  }
  self:addBatchBtnListener(btnBatchListener)
end
function settingDlg_Safetylock:OnBtn_Unlock(obj, t)
  ShowSafetylockUnlockView()
end
function settingDlg_Safetylock:OnBtn_ForceLock(obj, t)
  if g_LocalPlayer == nil then
    return
  end
  local unlockExceedTime = g_LocalPlayer:getSafetyLockForceUnlockTime()
  if unlockExceedTime == nil then
    local unlockWaitDay = checkint(data_Variables.ForceUnlockWaitDay)
    local confirmBoxDlg = CPopWarning.new({
      title = "强行解除",
      text = string.format("  强行解锁需要等待%d天，%d天后自动解除密码。%d天内若记起密码可通过再次输入立刻解除密码。", unlockWaitDay, unlockWaitDay, unlockWaitDay),
      align = CRichText_AlignType_Left,
      confirmFunc = function()
        netsend.netsafetylock.forceUnlock()
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
    confirmBoxDlg:ShowCloseBtn(false)
  else
    ShowSafetylockForceUnlockView()
  end
end
function settingDlg_Safetylock:OnBtn_CancelLock(obj, t)
  ShowSafetylockCancelView()
end
function settingDlg_Safetylock:OnBtn_resetPwd(obj, t)
  ShowSafetylockResetPwdView()
end
