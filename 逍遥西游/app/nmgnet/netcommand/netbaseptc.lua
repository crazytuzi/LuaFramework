local netbaseptc = {}
function netbaseptc.allHeroInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.allHeroInfo:", param, ptc_main, ptc_sub)
  local mainHeroId = param.i_mid
  local player = g_DataMgr:getPlayer()
  if mainHeroId then
    player:setMainHeroId(mainHeroId)
  end
  for k, v in pairs(param.t_heros) do
    local heroId = v.i_hid
    v.s_name = CheckStringIsLegal(v.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    local hero = player:getObjById(heroId)
    if hero then
      player:setSvrproToHero(hero, v, true)
    else
      player:newHeroWithServerPro(heroId, v.i_type, v)
    end
  end
end
function netbaseptc.updateHeroInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.updateHeroInfo:", param, ptc_main, ptc_sub)
  param.s_name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  local player = g_DataMgr:getPlayer()
  local hero = player:getObjById(param.i_hid)
  if hero then
    player:setSvrproToHero(hero, param)
  else
    local newHeroFlag = true
    player:newHeroWithServerPro(param.i_hid, param.i_type, param, newHeroFlag)
  end
end
function netbaseptc.allPetInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.allPetInfo:", param, ptc_main, ptc_sub)
  local player = g_DataMgr:getPlayer()
  for k, v in pairs(param.t_pets) do
    local petId = v.i_pid
    v.s_name = CheckStringIsLegal(v.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
    local pet = player:getObjById(petId)
    if pet then
      player:setSvrproToPet(pet, v)
    else
      player:newPetWithServerPro(petId, v.i_type, v)
    end
  end
end
function netbaseptc.updatePetInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.updatePetInfo:", param, ptc_main, ptc_sub)
  param.s_name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  local player = g_DataMgr:getPlayer()
  local pet = player:getObjById(param.i_pid)
  if pet then
    player:setSvrproToPet(pet, param)
  else
    local newPetFlag = true
    player:newPetWithServerPro(param.i_pid, param.i_type, param, newPetFlag)
  end
end
function netbaseptc.skillProficiencyInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.skillProficiencyInfo:", param, ptc_main, ptc_sub)
  local num = 0
  local t_skill = param.t_skill
  for _, _ in pairs(t_skill) do
    num = num + 1
  end
  if num > 0 then
    local player = g_DataMgr:getPlayer()
    player:updateSkillProficiency(t_skill)
  end
  local t_cskill = param.t_cskill or {}
  for _, _ in pairs(t_cskill) do
    num = num + 1
  end
  if num > 0 then
    local player = g_DataMgr:getPlayer()
    player:updateMarrySkillProficiency(t_cskill)
  end
end
function netbaseptc.deleteHero(param, ptc_main, ptc_sub)
  print("netbaseptc.deleteHero:", param, ptc_main, ptc_sub)
  local heroId = param.i_hid
  local player = g_DataMgr:getPlayer()
  player:DeleteHero(heroId)
end
function netbaseptc.deletePet(param, ptc_main, ptc_sub)
  print("netbaseptc.deletePet:", param, ptc_main, ptc_sub)
  local petId = param.i_pid
  local player = g_DataMgr:getPlayer()
  player:DeletePet(petId)
end
function netbaseptc.updatePlayerResInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.updatePlayerResInfo:", param, ptc_main, ptc_sub)
  if param.i_gold ~= nil then
    g_LocalPlayer:setGold(param.i_gold)
  end
  if param.i_coin ~= nil then
    g_LocalPlayer:setCoin(param.i_coin)
  end
  if param.i_arch ~= nil then
    g_LocalPlayer:setArch(param.i_arch)
  end
  if param.i_honour ~= nil then
    g_LocalPlayer:setHonour(param.i_honour)
  end
  if param.i_silver ~= nil then
    g_LocalPlayer:setSilver(param.i_silver)
  end
  if param.i_huoli ~= nil then
    g_LocalPlayer:setHuoli(param.i_huoli)
  end
  if param.i_storeexp ~= nil then
    g_LocalPlayer:setStoreExp(param.i_storeexp)
  end
  if param.i_xiayi ~= nil then
    g_LocalPlayer:setXiaYiValue(param.i_xiayi)
  end
end
function netbaseptc.OnLianYaoSuccess(param, ptc_main, ptc_sub)
  print("netbaseptc.OnLianYaoSuccess:", param, ptc_main, ptc_sub)
  local petId = param.i_pid
  SendMessage(MsgID_LianYaoSuccess, {petId = petId})
end
function netbaseptc.setSeverTime(param, ptc_main, ptc_sub)
  print("netbaseptc.setSeverTime:", param, ptc_main, ptc_sub)
  local svrtime = param.i_svrtime
  g_DataMgr:setServerTime(svrtime)
end
function netbaseptc.allZuoqiInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.allZuoqiInfo:", param, ptc_main, ptc_sub)
  local player = g_DataMgr:getPlayer()
  for k, v in pairs(param.t_zqs) do
    local zqId = v.i_zid
    local zqIns = player:getObjById(zqId)
    if zqIns then
      player:setSvrproToZuoqi(zqIns, v)
    else
      player:newZuoqiWithServerPro(zqId, v.i_type, v)
    end
  end
end
function netbaseptc.updateZuoqiInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.updateZuoqiInfo:", param, ptc_main, ptc_sub)
  local player = g_DataMgr:getPlayer()
  local zqIns = player:getObjById(param.i_zid)
  if zqIns then
    player:setSvrproToZuoqi(zqIns, param)
  else
    player:newZuoqiWithServerPro(param.i_zid, param.i_type, param)
  end
end
function netbaseptc.updatePlayerInfo(param, ptc_main, ptc_sub)
  if param == nil then
    return
  end
  local today = param.today
  if today ~= nil then
    activity.tianting:UpdateCount(today.tianting_cnt)
    Shimen.flushTodayTimes(today.shimen_circle)
    local guiwang_cle = today["ghostking.circle"]
    if guiwang_cle ~= nil then
      GuiWang.CountUpdated(guiwang_cle)
    end
    local function judgeType()
      local counter = 0
      for k, v in pairs(today) do
        counter = counter + 1
      end
      return counter
    end
    dump(today, "Today param ")
    local ChuMoState = today.canaccept_chumo
    if ChuMoState ~= nil then
      BangPaiChuMo.flushServiceState(ChuMoState == 1)
    end
    print("  *****************   org.anzhan.bonus    ", today["org.anzhan.bonus"])
    local AnZhanState = today["org.anzhan.bonus"]
    if judgeType() ~= 1 or AnZhanState ~= nil then
      if AnZhanState == true then
        BangPaiAnZhan.hadDone = true
      else
        BangPaiAnZhan.hadDone = false
      end
    end
    print("  BangPaiAnZhan.hadDone ", BangPaiAnZhan.hadDone)
    local runring_circle = today.runring_circle
    if judgeType() ~= 1 or runring_circle ~= nil then
      SanJieLiLian.addMissionToNPC(runring_circle - 1, true)
    end
    local hasRunCircle = today["paoshang.cnt"]
    if hasRunCircle ~= nil then
      BangPaiPaoShang.setTodayCanRun(hasRunCircle)
    end
    local dayantaCicle = today["dayanta.cnt"]
    if dayantaCicle ~= nil then
      activity.dayanta.todayCicle = dayantaCicle
    end
    print(" *****  dayantaCicle  ", dayantaCicle)
    local shimenGUTime = today["shimen.giveuptime"]
    if shimenGUTime ~= nil then
      Shimen.flushGiveUpTime(shimenGUTime)
    end
    print("********** ", shimenGUTime)
    local zhuagui_circle = today["catchghost.circle"]
    if zhuagui_circle ~= nil then
      ZhuaGui.CountUpdated(zhuagui_circle)
    end
    local xiuluo_cnt = today["xiuluo.cnt"]
    local xiuluo_circle = today.xiuluo_circle
    if xiuluo_cnt ~= nil or xiuluo_circle ~= nil then
      XiuLuo.CountUpdated(xiuluo_cnt, xiuluo_circle)
    end
    local baotu_cnt = today.baotu_cnt
    if baotu_cnt ~= nil then
      CDaTingCangBaoTu.flushTodayCanAccpte(baotu_cnt)
    end
    local labacount = today.horn_cnt
    if labacount ~= nil and g_LBMgr ~= nil then
      g_LBMgr:flushLocalCount(labacount)
    end
    local donateTimes = today["friend.itemcnt"]
    g_MissionMgr:setDonateDaoJuTimes(donateTimes)
    SendMessage(MsgID_Friends_FlushUseDaoJuTimes)
  end
  local basicattr = param.basicattr
  if basicattr then
  end
  local other = param.other
  if other then
    local dayanta_num = other.dayanta_num
    if dayanta_num ~= nil then
      activity.dayanta.TodayLimit = dayanta_num
    end
  end
end
function netbaseptc.addSkillExpTips(param, ptc_main, ptc_sub)
  local skillNo = param.i_i
  local skillType = param.i_type
  print("netbaseptc.addSkillExpTips", skillType, skillNo)
  if skillType == Skill_AddSkill_Marry then
    if skillNo then
      local skillId = ACTIVE_MARRYSKILLLIST[skillNo]
      if skillId ~= nil then
        local skillName = data_getSkillName(skillId)
        ShowNotifyTips(string.format("#<Y>%s#提升%d点熟练度", skillName, data_Variables.BE_skillExp or 50))
      end
    end
  elseif skillNo then
    local mainHero = g_LocalPlayer:getMainHero()
    local skillTypeList = mainHero:getSkillTypeList()
    local row = math.floor(skillNo / 5) + 1
    local step = skillNo % 5
    if step == 0 then
      step = 5
      row = row - 1
    end
    local skillAttr = skillTypeList[row]
    local skillId = data_getSkillListByAttr(skillAttr)[step]
    if skillId ~= nil then
      local skillName = data_getSkillName(skillId)
      ShowNotifyTips(string.format("#<Y>%s#提升%d点熟练度", skillName, data_Variables.BE_skillExp or 50))
      g_MissionMgr:GuideIdComplete(GuideId_Skill)
    end
  end
end
function netbaseptc.setAddRolePointInfo(param, ptc_main, ptc_sub)
  local player = g_DataMgr:getPlayer()
  local role = player:getObjById(param.i_id)
  if role then
    local pInfo = {
      gg = param.i_gg,
      lx = param.i_lx,
      ll = param.i_ll,
      mj = param.i_mj
    }
    role:setProperty(PROPERTY_AUTOADDPOINT, pInfo)
    SendMessage(MsgID_RoleAutoAddPointInfo, {
      roleId = param.i_id,
      pointInfo = pInfo
    })
  end
end
function netbaseptc.addSkillExpByPantaoTips(param, ptc_main, ptc_sub)
  local skillNo = param.i_i
  local num = param.i_num
  print("netbaseptc.addSkillExpByPantaoTips", skillNo, num)
  if skillNo then
    local mainHero = g_LocalPlayer:getMainHero()
    local skillTypeList = mainHero:getSkillTypeList()
    local row = math.floor(skillNo / 5) + 1
    local step = skillNo % 5
    if step == 0 then
      step = 5
      row = row - 1
    end
    local skillAttr = skillTypeList[row]
    local skillId = data_getSkillListByAttr(skillAttr)[step]
    if skillId ~= nil then
      local skillName = data_getSkillName(skillId)
      ShowNotifyTips(string.format("#<Y>%s#提升%d点熟练度", skillName, num))
    end
  end
end
function netbaseptc.heroZSSuccess(param, ptc_main, ptc_sub)
  print("netbaseptc.heroZSSuccess")
  local tempPop = CPopWarning.new({
    title = "提示",
    text = "恭喜您转生成功，需要重新登录游戏！",
    confirmFunc = function()
      g_DataMgr:returnToLoginView()
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定"
  })
  tempPop:ShowCloseBtn(false)
  tempPop:OnlyShowConfirmBtn()
end
function netbaseptc.petZSSuccess(param, ptc_main, ptc_sub)
  local petID = param.i_p
  local petIns = g_LocalPlayer:getObjById(petID)
  if petIns ~= nil then
    local petName = petIns:getProperty(PROPERTY_NAME)
    ShowNotifyTips(string.format("恭喜您,召唤兽%s已成功转生", petName))
  end
end
function netbaseptc.deleteZuoqi(param, ptc_main, ptc_sub)
  print("netbaseptc.deleteZuoqi:", param, ptc_main, ptc_sub)
  local zqId = param.i_zqid
  local player = g_DataMgr:getPlayer()
  player:DeleteZuoQi(zqId)
end
function netbaseptc.heroChangeRaceSuccess(param, ptc_main, ptc_sub)
  print("netbaseptc.heroChangeRaceSuccess")
  local tempPop = CPopWarning.new({
    title = "提示",
    text = "恭喜您成功更换种族，需要重新登录游戏！",
    confirmFunc = function()
      g_DataMgr:returnToLoginView()
    end,
    align = CRichText_AlignType_Left,
    confirmText = "确定"
  })
  tempPop:ShowCloseBtn(false)
  tempPop:OnlyShowConfirmBtn()
end
function netbaseptc.getPlayerPetInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.getPlayerPetInfo:", param, ptc_main, ptc_sub)
  param.s_name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  ShowChatDetail_Pet_WithSvrData(param.i_playerid, param.i_pid, param)
end
function netbaseptc.getPlayerPetSkillInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.getPlayerPetSkillInfo:", param, ptc_main, ptc_sub)
  local petTypeId = param.i_type
  local playerId = param.i_playerid
  local petId = param.i_pid
  local neidanList = param.t_items
  param.s_name = CheckStringIsLegal(param.s_name, true, REPLACECHAR_FOR_INVALIDNAME)
  if g_LocalPlayer:getPlayerId() == playerId then
  else
    local player = g_DataMgr:getPlayer(playerId)
    if player == nil then
      player = g_DataMgr:CreatePlayer(playerId, false)
    end
    local petIns = player:getObjById(petId)
    if petIns ~= nil then
      player:setSvrproToPet(petIns, param)
    else
      petIns = player:newPetWithServerPro(petId, petTypeId, param, false)
    end
    if player ~= g_LocalPlayer and petId ~= nil then
      petIns:setPetNeidanDataForOtherPlayer(neidanList)
    end
  end
  SendMessage(MsgID_Message_KuaiXunPetSkill, param)
end
function netbaseptc.getSvrOpenLevelInfo(param, ptc_main, ptc_sub)
  print("netbaseptc.getServerOpenLevelInfo:", param, ptc_main, ptc_sub)
  SendMessage(MsgID_SvrOpenLevelInfo, param.i_level, param.i_time)
end
function netbaseptc.exchangeByGoldSucceed(param, ptc_main, ptc_sub)
  print("netbaseptc.exchangeByGoldSucceed:", param, ptc_main, ptc_sub)
  if param then
    local reason = param.reason
  end
end
function netbaseptc.serverDailyUpdated(param, ptc_main, ptc_sub)
  print("netbaseptc.serverDailyUpdated:", param, ptc_main, ptc_sub)
  SendMessage(MsgID_ServerDailyClean)
end
function netbaseptc.setVIPData(param, ptc_main, ptc_sub)
  print("netbaseptc.setVIPData:", param, ptc_main, ptc_sub)
  g_LocalPlayer:setVipLv(param.i_lv)
  g_LocalPlayer:setVipAddGold(param.i_n)
end
function netbaseptc.setMainHeroRanColor(param, ptc_main, ptc_sub)
  print("netbaseptc.setMainHeroRanColor:", param, ptc_main, ptc_sub)
  local mainRole = g_LocalPlayer:getMainHero()
  local tempRanColor = {
    0,
    0,
    0
  }
  if param.t_r then
    tempRanColor = DeepCopyTable(param.t_r)
  end
  if mainRole then
    mainRole:setProperty(PROPERTY_RANCOLOR, tempRanColor)
    local proTable = {
      [PROPERTY_RANCOLOR] = tempRanColor
    }
    SendMessage(MsgID_HeroUpdate, {
      pid = g_LocalPlayer:getPlayerId(),
      heroId = mainRole:getObjId(),
      pro = proTable
    })
  end
end
function netbaseptc.learnNewPetSkill(param, ptc_main, ptc_sub)
  if param then
    ShowNewPetSkillAnimation(param.i_pid, param.i_skill)
  end
end
function netbaseptc.setSyncPlayerType(param, ptc_main, ptc_sub)
  if param then
    local t = param.i_i
    if t ~= nil then
      g_DataMgr:SyncPlayerTypeFlushed(t)
    end
  end
end
function netbaseptc.allChengwei(param, ptc_main, ptc_sub)
  if param then
    g_LocalPlayer:reciveAllChengwei(param.titles)
  end
end
function netbaseptc.delChengwei(param, ptc_main, ptc_sub)
  if param then
    local cwId = param.id
    if cwId then
      g_LocalPlayer:delChengwei(cwId)
    end
  end
end
function netbaseptc.curChengwei(param, ptc_main, ptc_sub)
  if param then
    g_LocalPlayer:reciveCurChengwei(param.id, param.lefttime, param.hide)
  end
end
function netbaseptc.showNewPetAnimation(param, ptc_main, ptc_sub)
  if param then
    ShowNewPetAnimation(param.id)
  end
end
function netbaseptc.canGetNewPetFromSvr(param, ptc_main, ptc_sub)
  g_CanGetNewPetFlag = true
end
function netbaseptc.addSkillOneKeyExpTips(param, ptc_main, ptc_sub)
  local skillNo = param.i_i
  local skillType = param.i_type
  print("netbaseptc.addSkillOneKeyExpTips", skillNo)
  if i_type == Skill_AddSkill_Marry then
  elseif skillNo then
    g_MissionMgr:GuideIdComplete(GuideId_Skill)
  end
end
function netbaseptc.setChongZhiFanliAwardData(param, ptc_main, ptc_sub)
  local awardId = param.id
  local state = param.state
  print("netbaseptc.setChongZhiFanliAwardData", awardId, state)
  g_LocalPlayer:updateFanliData(awardId, state)
end
function netbaseptc.updateChengWei(param, ptc_main, ptc_sub)
  local cwId = param.id
  local lefttime = param.lefttime
  print("netbaseptc.updateChengWei", cwId, lefttime)
  g_LocalPlayer:updateChengweiTime(cwId, lefttime)
end
function netbaseptc.updateCertainSetting(param, ptc_main, ptc_sub)
  local id = param.id
  local val = param.val or 0
  if id == 1 then
    g_TeamMgr:setAutoAgreeCaptainRequest(val)
  end
end
function netbaseptc.extraPetLimitNum(param, ptc_main, ptc_sub)
  if g_LocalPlayer then
    g_LocalPlayer:SetExtraPetLimitNum(param.num)
  end
end
function netbaseptc.extraExpFlag(param, ptc_main, ptc_sub)
  print("netbaseptc.extraExpFlag", param.flag)
  if g_LocalPlayer then
    g_LocalPlayer:SetExtraExpFlag(param.flag)
  end
end
function netbaseptc.setWuXingPro(param, ptc_main, ptc_sub)
  print("netbaseptc.setWuXingPro")
  if param.i_num and g_LocalPlayer then
    g_LocalPlayer.m_ChangeWuxingNum = param.i_num
  end
  if param.t_wx and g_LocalPlayer then
    local hIdList = g_LocalPlayer:getAllRoleIds(LOGICTYPE_HERO) or {}
    for _, hId in pairs(hIdList) do
      local hero = g_LocalPlayer:getObjById(hId)
      for index, proName in ipairs(PROPERTY_LEVEL_WUXING) do
        local value = param.t_wx[index] / 100
        hero:setProperty(proName, value)
      end
    end
  end
  SendMessage(MsgID_ChangeWuxingNum)
end
function netbaseptc.setItemAddExtraExp(param, ptc_main, ptc_sub)
  print("netbaseptc.setItemAddExtraExp")
  local t_item = param.t_item or {}
  if g_LocalPlayer then
    g_LocalPlayer:SetExtraExpItemList(t_item)
  end
end
function netbaseptc.setDataChengZhangDan(param, ptc_main, ptc_sub)
  SendMessage(MsgID_ItemInfo_UseChengZhangDan, param)
end
function netbaseptc.juBaoSucceed()
  SendMessage(MsgID_Message_JuBaoWanJia)
end
function netbaseptc.flushPingBiList(param)
  dump(param, "netbaseptc.flushPingBiList")
  if param and g_MessageMgr then
    g_MessageMgr:flushPingBiList(param)
  end
end
function netbaseptc.addOnePingBiName(param)
  dump(param, "netbaseptc.addOnePingBiName")
  if g_MessageMgr and param then
    g_MessageMgr:addOnePingBiName(param)
  end
end
function netbaseptc.removeOnePingBiName(param)
  if g_MessageMgr and param then
    g_MessageMgr:removeOnePingBiName(param.pid)
  end
end
function netbaseptc.updateLoginNotice(param)
  if param then
    local issue = param.i_i
    local title = param.title
    local notice = param.s_t
    if g_LoginNoticeIns then
      g_LoginNoticeIns:loadLoginNotice(issue, title, notice)
    end
    _saveLoginNoticeCache(issue, title, notice)
  end
end
function netbaseptc.updateJiaYiWanData(param)
  print("netbaseptc.updateJiaYiWanData")
  if param then
    local petid = param.petid
    local lefttime = param.lefttime
    if g_LocalPlayer and g_DataMgr then
      local endPoint
      if lefttime then
        endPoint = g_DataMgr:getServerTime() + lefttime
      end
      g_LocalPlayer:SetJiaYiWanData(petid, endPoint)
    end
  end
end
return netbaseptc
