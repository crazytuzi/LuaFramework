SanJieLiLian = {}
SanJieLiLian.Type_Talk = 1
SanJieLiLian.Type_War = 2
SanJieLiLian.Type_Objs = 3
SanJieLiLian.Type_Question = 4
SanJieLiLian.Type_ZhuaChong = 5
SanJieLiLian.Limei_Times = 300
SanJieLiLian.UnionTime = 50
SanJieLiLian.AcceptMissionId = 90005
SanJieLiLian.MissionGuideId = 70012
SanJieLiLian.paramFlush = {}
SanJieLiLian.isDoingTask = false
SanJieLiLian.lastTalkNpcId = 0
SanJieLiLian.isNewTask = true
SanJieLiLian.questionPanel = nil
SanJieLiLian.questionFlush = nil
SanJieLiLian.MissionNPCId = 90016
SanJieLiLian.MissionDec = {}
LIFESKILL_PRODUCE_DRUG = 1
LIFESKILL_PRODUCE_RUNE = 2
LIFESKILL_PRODUCE_FOOD = 3
function SanJieLiLian.init()
  SanJieLiLian.doneLastTime = false
  SanJieLiLian.today_times = 0
  SanJieLiLian.isAccepted_ = false
  SanJieLiLian.taskid_ = -1
  SanJieLiLian.type_ = -1
  SanJieLiLian.dataid_ = -1
  SanJieLiLian.status_ = -1
  SanJieLiLian.item_progress_ = nil
  SanJieLiLian.missionId_ = -1
  SanJieLiLian.proSign = false
  SanJieLiLian.itempos = 1
  SanJieLiLian.isDoingTask = false
  SanJieLiLian.isAnswerWrong = false
  SanJieLiLian.tempMissionDes = {}
end
function SanJieLiLian.getCurMissionId()
  return SanJieLiLian.missionId_
end
function SanJieLiLian.getMissionState()
  return SanJieLiLian.status_
end
function SanJieLiLian.isTimesLevel()
  return SanJieLiLian.today_times < SanJieLiLian.Limei_Times
end
function SanJieLiLian.isAccepted()
  return SanJieLiLian.isAccepted_
end
function SanJieLiLian.addMissionToNPC(curCicle, iss)
  print("  SanJieLiLian.addMissionToNPC     ", curCicle, SanJieLiLian.today_times)
  if SanJieLiLian.today_times and SanJieLiLian.today_times >= curCicle + 1 then
    return
  end
  print("======>>>>>  ", curCicle + 1, SanJieLiLian.Limei_Times)
  if curCicle + 1 >= SanJieLiLian.Limei_Times then
    SanJieLiLian.today_times = curCicle + 1
    return
  end
  if curCicle and curCicle > 0 and (curCicle + 1) % SanJieLiLian.UnionTime == 0 then
    local pparam = {}
    pparam.taskid = 0
    pparam.type = SanJieLiLian.Type_Talk
    pparam.data_id = 10001
    pparam.circle = curCicle
    pparam.state = 1
    pparam.sp = true
    if iss ~= true then
      iss = false
    end
    SanJieLiLian.proSign = iss
    SanJieLiLian.dataUpdate(pparam)
  end
end
function SanJieLiLian.getcircleState()
  local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
  return isNpcCile and SanJieLiLian.type_ == SanJieLiLian.Type_Talk
end
function SanJieLiLian.GotoSanJieLiLianNpc()
  local NpcId = SanJieLiLian.MissionNPCId
  if NpcId then
    g_MapMgr:AutoRouteToNpc(NpcId, function(isSucceed)
      if isSucceed and CMainUIScene.Ins then
        CMainUIScene.Ins:ShowNormalNpcViewById(NpcId)
      end
    end)
  end
end
function SanJieLiLian.setAccept(isAccepted)
  SanJieLiLian.isAccepted_ = isAccepted
  g_MissionMgr:flushSanJieLiLianCanAccept()
end
function SanJieLiLian.dataUpdate(param)
  param = param or {}
  print(" *****   服务器刷新了 #三界历练 # 任务状态  ")
  for k, v in pairs(param) do
    print(k, v)
  end
  print(" ============================", SanJieLiLian.Type_Talk, SanJieLiLian.type_, SanJieLiLian.missionId_, SanJieLiLian.today_times)
  if SanJieLiLian.Type_Talk == SanJieLiLian.type_ then
    local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
    if isNpcCile and param.sp ~= true then
      SanJieLiLian.lastTalkNpcId = SanJieLiLian.MissionNPCId
      g_MissionMgr:delSanJieLiLian(SanJieLiLian.missionId_)
      g_MissionMgr:flushMissionStatusForNpc()
      SendMessage(MsgID_Mission_Common)
    end
  end
  SanJieLiLian.isnew = param.new or false
  local oldId = SanJieLiLian.taskid_
  if param.pos then
    SanJieLiLian.itempos = param.pos
  end
  if param.taskid then
    SanJieLiLian.taskid_ = param.taskid
  end
  if param.type then
    SanJieLiLian.type_ = param.type
  end
  if param.data_id then
    SanJieLiLian.dataid_ = param.data_id
  end
  local lastcicle = SanJieLiLian.today_times
  if param.circle then
    SanJieLiLian.today_times = param.circle
    if 1 <= param.circle then
      g_MissionMgr:GuideIdComplete(GuideId_SanJieLiLian)
    end
  end
  if param.item_progress then
    SanJieLiLian.item_progress_ = param.item_progress
  end
  if param.state then
    SanJieLiLian.status_ = param.state
  end
  if param.loc_id then
    SanJieLiLian.loc_id_ = param.loc_id
  end
  if param.questionid then
    SanJieLiLian.dataid_ = param.questionid
  end
  if param.war_data_id then
    SanJieLiLian.dataid_ = param.war_data_id
  end
  if param.loc_id then
    SanJieLiLian.loc_id_ = param.loc_id
  end
  if param.npcid then
    SanJieLiLian.npcid_ = param.npcid
  else
    SanJieLiLian.npcid_ = nil
  end
  if param.state ~= nil then
    if param.state == 1 or param.state == 2 then
      SanJieLiLian.setAccept(true)
      SanJieLiLian.flushAcceptedData()
      print("  是否建立新任务项   ======  ", oldId ~= param.taskid, SanJieLiLian.isDoingTask)
      local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
      if oldId ~= param.taskid and SanJieLiLian.isDoingTask == false then
        local lastid = SanJieLiLian.lastTalkNpcId
        if lastid and lastid ~= 0 and data_TempNpcForMission[lastid] and lastcicle ~= SanJieLiLian.today_times then
          g_MapMgr:ReqDeleteNpc(lastid)
        end
        print(" ==================== SanJieLiLian.getNextTalkId  ", SanJieLiLian.type_)
        local talkId = SanJieLiLian.getNextTalkId(SanJieLiLian.type_)
        if SanJieLiLian.proSign then
          SanJieLiLian.lastTalkNpcId = 0
        end
        if (not isNpcCile or param.type ~= SanJieLiLian.Type_Talk) and SanJieLiLian.proSign == false then
          print(" 建立对话 ID  ", talkId, SanJieLiLian.questionFlush, lastid)
          if SanJieLiLian.isnew == true and SanJieLiLian.isAnswerWrong ~= true then
            getCurSceneView():ShowTalkView(talkId, function()
            end, SanJieLiLian.missionId_)
          end
          SanJieLiLian.isDoingTask = true
          g_MissionMgr:NewMission(SanJieLiLian.missionId_)
        end
      end
    elseif param.state == 3 then
      SanJieLiLian.flushAcceptedData()
    elseif param.state == 0 then
      if SanJieLiLian.missionId_ and SanJieLiLian.missionId_ > -1 then
        g_MissionMgr:delSanJieLiLian(SanJieLiLian.missionId_)
        SanJieLiLian.init()
        g_MissionMgr:flushSanJieLiLianCanAccept()
      end
      SanJieLiLian.setAccept(false)
    end
    SanJieLiLian.proSign = false
  end
end
function SanJieLiLian.getDesTitle(missionId)
  local name = "三界历练"
  if missionId == 90001 then
    if SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0 then
      name = "除暴"
    else
      name = "寻人"
    end
  elseif missionId == 90002 then
    if SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0 then
      name = "除暴"
    else
      name = "除妖"
    end
  elseif missionId == 90003 then
    name = "寻物"
  elseif missionId == 90004 then
    name = "答题"
  elseif missionId == 90005 then
    name = "开启三界历练"
  elseif missionId == 90006 then
    name = "抓宠"
  end
  return name
end
function SanJieLiLian.isMissionId(mid)
  return mid == 90001 or mid == 90002 or mid == 90003 or mid == 90004 or mid == 90005 or mid == 90006
end
function SanJieLiLian.getMapNameByNpcId(npcId)
  local npcinfo = data_NpcInfo[npcId] or {}
  local mpos = npcinfo.pos or {}
  local map = data_MapInfo[mpos[1]] or {}
  return map.name
end
function SanJieLiLian.flushAcceptedData()
  local missionData, objs
  local mainHeroIns = g_LocalPlayer:getMainHero()
  if mainHeroIns == nil then
    print(" mainHeroIns == nil")
    return
  end
  local times = SanJieLiLian.today_times or 0
  local lv = mainHeroIns:getProperty(PROPERTY_ROLELEVEL)
  local reward = data_TaskExpRunRing[lv] or {}
  local rewardCoin = reward.BaseCoin or 0
  local rewardExp = reward.BaseExp or 0
  rewardCoin = math.floor(rewardCoin * 0.5 * (times + 1) / 45150 + rewardCoin * 0.5 / 300)
  rewardExp = math.floor(rewardExp * 0.5 * (times + 1) / 45150 + rewardExp * 0.5 / 300)
  if SanJieLiLian.type_ == SanJieLiLian.Type_Talk then
    SanJieLiLian.missionId_ = 90001
    local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
    print("建立对话 =========  SanJieLiLian.dataid_   ", SanJieLiLian.dataid_)
    local talkData = data_TaskRunRing_Talk[SanJieLiLian.dataid_]
    missionData = data_Mission_SanJieLiLian[SanJieLiLian.missionId_]
    local dst1 = missionData.dst1
    dst1.data = talkData.NpcId
    dst1.talkId = 0
    local _, name = data_getRoleShapeAndName(talkData.NpcId)
    if isNpcCile then
      dst1.data = SanJieLiLian.MissionNPCId
      dst1.des = string.format("去长安找到#<Y,>%s#", "范进士")
      SanJieLiLian.MissionDec[90001] = "继续历练，前往长安城找到范进士探明情况。"
    else
      dst1.des = string.format("找到#<Y,>%s#", name)
      local mapName = SanJieLiLian.getMapNameByNpcId(dst1.data)
      if mapName then
        SanJieLiLian.MissionDec[90001] = string.format("找到#<Y,>%s#的#<Y,>%s#,完成受托之事。", mapName, name)
      else
        SanJieLiLian.MissionDec[90001] = string.format("找到#<Y,>%s#,完成受托之事。", name)
      end
    end
    missionData.rewardExp = rewardExp
    missionData.rewardCoin = rewardCoin
    print("dst1.des-->", dst1.des)
  elseif SanJieLiLian.type_ == SanJieLiLian.Type_War then
    SanJieLiLian.missionId_ = 90002
    local mapData = data_CustomMapPos[SanJieLiLian.loc_id_]
    if mapData == nil then
      print(" 获取不到 导表数据  mapData   = data_CustomMapPos ", SanJieLiLian.loc_id_)
    end
    missionData = data_Mission_SanJieLiLian[SanJieLiLian.missionId_]
    local dst1 = missionData.dst1
    dst1.data = {
      SanJieLiLian.dataid_,
      SanJieLiLian.loc_id_
    }
    local mapData = data_MapInfo[mapData.SceneID] or {}
    local mapName = mapData.name or ""
    local _, masterName = data_getBossForWar(SanJieLiLian.dataid_)
    masterName = masterName or "怪物"
    local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
    local npc2 = SanJieLiLian.npcid_
    if SanJieLiLian.npcid_ then
      local d2 = missionData.dst2
      if d2 == nil then
        missionData.dst2 = {}
      end
      missionData.dst2.data = SanJieLiLian.npcid_
    end
    if isNpcCile then
      dst1.des = string.format("去%s消灭#<Y,>%s#（推荐组队）", mapName, masterName)
      SanJieLiLian.MissionDec[90002] = string.format(" 前去#<Y,>%s#击杀正在为非作歹的#<Y,>%s#（怪物难度较高，建议组队前往）  ", mapName, masterName)
    else
      dst1.des = string.format("去%s教训#<Y,>%s# ", mapName, masterName)
      if npc2 then
        local _, name2 = data_getRoleShapeAndName(SanJieLiLian.npcid_)
        SanJieLiLian.MissionDec[90002] = string.format("罪大恶极的#<Y,>%s#逃至#<Y,>%s#，帮助#<Y,>%s#除掉此妖。", masterName, mapName, name2)
      else
        SanJieLiLian.MissionDec[90002] = string.format("罪大恶极的#<Y,>%s#逃至#<Y,>%s#，请前往除掉此妖。", masterName, mapName)
      end
    end
    missionData.rewardExp = rewardExp
    missionData.rewardCoin = rewardCoin
    dump(missionData.dst2, "ResetDst2 >>>>>> ")
    if SanJieLiLian.status_ == 1 then
      missionData.dst2 = {}
    end
  elseif SanJieLiLian.type_ == SanJieLiLian.Type_Objs then
    SanJieLiLian.missionId_ = 90003
    local objData = data_TaskRunRing_GiveItem[SanJieLiLian.dataid_]
    print(" ================= ", SanJieLiLian.dataid_, objData == nil)
    if objData == nil then
      print("ERROR **************  找不到导表啦  ")
      objData = {}
    end
    missionData = data_Mission_SanJieLiLian[SanJieLiLian.missionId_]
    local dst1 = missionData.dst1
    local p = objData.RandomItems or {}
    p = p[SanJieLiLian.itempos] or {}
    dst1.param = {}
    local objstring
    local whereString = ""
    for mk, v in pairs(p) do
      local k, mname = SanJieLiLian.getTypeFirstItem(mk)
      print("**************  mitemk ", k, mname)
      if k ~= nil then
        dst1.param[#dst1.param + 1] = {k, v}
      else
        dst1.param[#dst1.param + 1] = {mk, v}
        k = mk
      end
      local itemNpcName = SanJieLiLian.getItemNpcName(k)
      whereString = string.format("向长安城%s购买", itemNpcName)
      local union = "个"
      union = string.format("%d%s", v, union)
      local itemName = data_getItemName(k) or ""
      if mname ~= nil then
        itemName = mname
      end
      local f_index, t_index = string.find(itemName, "★")
      if f_index ~= nil and t_index ~= nil then
        itemName = string.sub(itemName, t_index + 1, -1)
      end
      objstring = string.format("#<Y,>%s#x%s", itemName, v)
      union = ""
      dst1.des = string.format("找到%s#<Y,>%s#", union, itemName)
      print("dst1.des-->", dst1.des)
      break
    end
    dst1.data = SanJieLiLian.npcid_ or 0
    local objPro = SanJieLiLian.item_progress_
    if objPro then
      objs = {}
      for k, v in pairs(objPro) do
        objs[#objs + 1] = {
          tonumber(k),
          v
        }
      end
    end
    local mapname = SanJieLiLian.getMapNameByNpcId(dst1.data)
    local _, name2 = data_getRoleShapeAndName(SanJieLiLian.npcid_)
    if name2 == nil then
      name2 = "他人"
    else
    end
    if objstring == nil then
      print(" 三界历练寻物导表 找不到相关物品 ")
      objstring = "未知物品"
    end
    if mapname then
      SanJieLiLian.MissionDec[90003] = string.format("%s%s,交给#<Y,>%s#的#<Y,>%s#。", whereString, objstring, mapname, name2)
    else
      SanJieLiLian.MissionDec[90003] = string.format("%s%s,交给#<Y,>%s#。", whereString, objstring, name2)
    end
    missionData.rewardExp = rewardExp
    missionData.rewardCoin = rewardCoin
    if SanJieLiLian.status_ == 1 then
    elseif SanJieLiLian.status_ == 2 then
      g_MissionMgr:delSanJieLiLian(SanJieLiLian.missionId_)
    end
  elseif SanJieLiLian.type_ == SanJieLiLian.Type_Question then
    print(" 答题 =====》 SanJieLiLian.status_  ", SanJieLiLian.status_)
    SanJieLiLian.missionId_ = 90004
    if SanJieLiLian.status_ == 1 then
      missionData = data_Mission_SanJieLiLian[SanJieLiLian.missionId_]
      local dst1 = missionData.dst1
      local rannumItem = SanJieLiLian.dataid_
      local qItem = data_TaskRunRing_QuestionLib[rannumItem]
      print("================问题", rannumItem, "===================")
      print(qItem.Question)
      print("A:", qItem.A, "   B:", qItem.B, "   C:", qItem.C, "    D:", qItem.D)
      if SanJieLiLian.isNewTask or dst1.data == 0 then
        if SanJieLiLian.npcid_ then
          dst1.data = SanJieLiLian.npcid_
        else
          local npcList = qItem.NpcList or {}
          local rannum = math.random(1, #npcList)
          local npcId = npcList[rannum]
          if npcId == SanJieLiLian.lastTalkNpcId then
            if rannum + 1 <= #npcList then
              npcId = npcList[rannum + 1]
            elseif 0 < rannum - 1 then
              npcId = npcList[rannum - 1]
            end
          end
          dst1.data = npcId
        end
        SanJieLiLian.isNewTask = false
      end
      local _, name = data_getRoleShapeAndName(dst1.data)
      dst1.des = string.format("接受#<Y,>%s#的考验", name)
      print("   SanJieLiLian.questionFlush  == ", SanJieLiLian.questionFlush)
      if SanJieLiLian.questionFlush then
        SanJieLiLian.questionFlush(SanJieLiLian.dataid_)
      end
      local mapname = SanJieLiLian.getMapNameByNpcId(dst1.data)
      if mapname then
        SanJieLiLian.MissionDec[90004] = string.format("#<Y,>%s#的#<Y,>%s#要考考你的智力，做好充足的准备，去会一会他。", mapname, name)
      else
        SanJieLiLian.MissionDec[90004] = string.format(" #<Y,>%s#要考考你的智力，做好充足的准备，去会一会他。", name)
      end
      missionData.rewardExp = rewardExp
      missionData.rewardCoin = rewardCoin
      missionData.dst2 = {}
    elseif SanJieLiLian.status_ == 2 then
      SanJieLiLian.isNewTask = true
      g_MissionMgr:delSanJieLiLian(SanJieLiLian.missionId_)
      SanJieLiLian.questionFlush = nil
      if SanJieLiLian.questionPanel then
        SanJieLiLian.questionPanel.haveSelected = false
        SanJieLiLian.questionPanel:OnBtn_Close(nil, nil, true)
        SanJieLiLian.questionPanel = nil
      end
    end
    if SanJieLiLian.questionPanel then
      SanJieLiLian.questionPanel.haveSelected = false
    end
  elseif SanJieLiLian.type_ == SanJieLiLian.Type_ZhuaChong then
    print("三界历练抓宠 =======")
    SanJieLiLian.missionId_ = 90006
    missionData = data_Mission_SanJieLiLian[SanJieLiLian.missionId_]
    local dst1 = missionData.dst1 or {}
    local petData = data_TaskRunRing_GivePet[SanJieLiLian.dataid_]
    if petData == nil then
      print("=================>>>三界历练找不到抓宠的导表  id: ", SanJieLiLian.dataid_)
    end
    local needPetData = petData.NeedPet or {}
    dst1.param = {}
    SanJieLiLian.petid = nil
    for k, v in pairs(needPetData) do
      SanJieLiLian.petid = k
      dst1.param[#dst1.param + 1] = {k, v}
      local petData = data_getRoleData(k) or {}
      if petData.NAME ~= nil then
        dst1.des = string.format("购买或捕抓一只#<Y,>%s#", petData.NAME)
      else
        print("读取不到导表相关的数据************* ")
      end
    end
    local mapname = SanJieLiLian.getMapNameByNpcId(SanJieLiLian.npcid_)
    local _, name2 = data_getRoleShapeAndName(SanJieLiLian.npcid_)
    SanJieLiLian.MissionDec[90006] = string.format("%s，并交给#<Y,>%s#的#<Y,>%s#。", dst1.des, mapname, name2)
    SanJieLiLian.CheckMissionPet()
  end
  if SanJieLiLian.status_ == 2 then
    SanJieLiLian.getNextTalkId(SanJieLiLian.type_)
  end
  local missionPro = 0
  if SanJieLiLian.status_ == 2 and SanJieLiLian.type_ ~= SanJieLiLian.Type_Objs then
    missionPro = 1
  end
  g_MissionMgr:Server_MissionUpdated(SanJieLiLian.missionId_, missionPro, objs)
end
function SanJieLiLian.getTypeFirstItem(itemtype)
  if itemtype == nil then
    return
  end
  print(" ************************  SanJieLiLian.getTypeFirstItem  ", itemtype)
  local tabletype = math.floor(itemtype / 1000)
  local reminder = itemtype % 1000
  local maintype, subtype = math.floor(reminder / 100), reminder % 100
  local itemtb
  if tabletype == LIFESKILL_PRODUCE_DRUG then
    itemtb = data_LifeSkill_Drug
  elseif tabletype == LIFESKILL_PRODUCE_FOOD then
    itemtb = data_LifeSkill_Food
  elseif tabletype == LIFESKILL_PRODUCE_RUNE then
    itemtb = data_LifeSkill_Rune
  end
  if itemtb ~= nil then
    for itemk, itemv in pairs(itemtb) do
      if itemv.MainCategoryId == maintype and itemv.MinorCategoryId == subtype then
        local LifeItemType = GetLifeSkillItemType(itemk)
        local showBigType = false
        if LifeItemType == LIFESKILL_PRODUCE_RUNE then
          if itemv.MainCategoryId == 5 then
            showBigType = false
          elseif itemv.MainCategoryId == 1 or itemv.MainCategoryId == 2 or itemv.MainCategoryId == 3 or itemv.MainCategoryId == 4 or itemv.MainCategoryId == 6 then
            showBigType = true
          end
        elseif LifeItemType == LIFESKILL_PRODUCE_FOOD then
          if itemv.MainCategoryId == 2 or itemv.MainCategoryId == 3 or itemv.MainCategoryId == 4 or itemv.MainCategoryId == 5 then
            showBigType = true
          elseif itemv.MainCategoryId == 1 then
            showBigType = false
          end
        else
          showBigType = false
        end
        local mname = ""
        if showBigType then
          mname = itemv.MainCategoryName
        else
          mname = MinorCategoryName
        end
        return itemk, mname
      end
    end
  end
end
function SanJieLiLian.getLifeItemName(itemid)
  print(" ****************   SanJieLiLian.getLifeItemName    ", itemid)
  if GetItemTypeByItemTypeId(itemid) == ITEM_LARGE_TYPE_LIFEITEM then
    local itemTable = GetItemDataByItemTypeId(itemid)
    print(" **************////////////", itemTable == nil)
    if itemTable ~= nil and itemTable[itemid] ~= nil then
      local LifeItemType = GetLifeSkillItemType(itemid)
      local showBigType = false
      local itemv = itemTable[itemid]
      if LifeItemType == LIFESKILL_PRODUCE_RUNE then
        if itemv.MainCategoryId == 5 then
          showBigType = false
        elseif itemv.MainCategoryId == 1 or itemv.MainCategoryId == 2 or itemv.MainCategoryId == 3 or itemv.MainCategoryId == 4 or itemv.MainCategoryId == 6 then
          showBigType = true
        end
      elseif LifeItemType == LIFESKILL_PRODUCE_FOOD then
        if itemv.MainCategoryId == 2 or itemv.MainCategoryId == 3 or itemv.MainCategoryId == 5 then
          showBigType = true
        elseif itemv.MainCategoryId == 1 then
          showBigType = false
        end
      else
        showBigType = false
      end
      local mname = ""
      if showBigType then
        mname = itemv.MainCategoryName
      else
        mname = itemv.MinorCategoryName
      end
      return mname or "无分类物品"
    end
  end
end
function SanJieLiLian.getCircle()
  return SanJieLiLian.today_times + 1
end
function SanJieLiLian.trackTalk(missionId, dataTable, dst, missionPro)
  if SanJieLiLian.Type_Talk == SanJieLiLian.type_ then
    SanJieLiLian.reqFinish()
    getCurSceneView():ShowTalkView(dataTable.cmpTalkId, function()
    end, SanJieLiLian.missionId_)
  end
end
function SanJieLiLian.taskDel(delType, taskid)
  print("正在删除一个 三界任务 ", delType, taskid, SanJieLiLian.taskid_, SanJieLiLian.missionId_, SanJieLiLian.today_times)
  if SanJieLiLian.missionId_ == nil then
    return
  end
  if delType == 1 and SanJieLiLian.missionId_ ~= 90004 then
    AwardPrompt.ShowMissionCmp()
  end
  if SanJieLiLian.missionId_ > 0 then
    if SanJieLiLian.missionId_ == 90004 then
      SanJieLiLian.isDoingTask = false
    end
    g_MissionMgr:delSanJieLiLian(SanJieLiLian.missionId_)
    if SanJieLiLian.today_times == SanJieLiLian.Limei_Times - 1 and delType == 1 then
      ShowNotifyTips("恭喜你完成三界历练任务")
    end
  end
  local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
  if isNpcCile and delType == 1 then
    SanJieLiLian.addMissionToNPC(SanJieLiLian.today_times)
  end
  if delType == 2 then
    print("放弃的时候 触发  SanJieLiLian.missionId_ ")
    SanJieLiLian.setAccept(false)
    g_MissionMgr:Server_GiveUpMission(SanJieLiLian.missionId_)
    SanJieLiLian.init()
  end
  SendMessage(MsgID_Mission_Common)
  g_MissionMgr:flushMissionStatusForNpc()
  local circle = SanJieLiLian.getCircle()
  if circle and circle == SanJieLiLian.Limei_Times then
    SanJieLiLian.doneLastTime = true
  end
end
function SanJieLiLian.getDifNpc(curnpc, collect, key)
  if collect == nil or #collect <= 0 then
    return 0
  end
  local ranNum = math.random(1, #collect)
  local selectedItem = collect[ranNum]
  if not key or not selectedItem or selectedItem[key] then
  else
  end
end
function SanJieLiLian.getNextTalkId(kind)
  print(" ===============================>>>>  SanJieLiLian.getNextTalkId ")
  local result = 0
  local talkItem
  local missionData = data_Mission_SanJieLiLian[SanJieLiLian.missionId_] or {}
  local dst1 = missionData.dst1 or {}
  local dst2 = missionData.dst2 or {}
  local npcId = 0
  local masterName, mapName
  local word = ""
  if kind == SanJieLiLian.Type_Talk then
    npcId = dst1.data
    local _, name = data_getRoleShapeAndName(npcId)
    local rannum = math.random(1, 100)
    if rannum <= 50 then
      result = 701511
      word = string.format("大侠不愧为当世豪杰，就让#<Y,>%s#瞻仰一下大侠您玉树临风、英俊潇洒的身姿吧。", name)
    else
      result = 701521
      word = string.format("多年前曾得到#<Y,>%s#的相助，大侠代我前去表示一下谢意如何？", name)
    end
  elseif kind == SanJieLiLian.Type_War then
    if SanJieLiLian.npcid_ == nil then
      local npcList = data_TaskRunRing_WarTalk or {}
      local ranNum = math.random(1, #npcList)
      local dst2 = missionData.dst2 or {}
      local npcDataItem = npcList[ranNum] or {}
      if npcDataItem.NpcId ~= SanJieLiLian.lastTalkNpcId then
        npcDataItem = npcList[ranNum]
      elseif ranNum + 1 <= #npcList then
        npcDataItem = npcList[ranNum + 1]
      elseif 1 <= ranNum - 1 then
        npcDataItem = npcList[ranNum - 1]
      else
        npcDataItem = npcList[ranNum] or {}
      end
      dst2.data = npcDataItem.NpcId or SanJieLiLian.MissionNPCId
    else
      dst2.data = SanJieLiLian.npcid_
    end
    dst2.type = 101
    dst2.talkId = 0
    local _, name = data_getRoleShapeAndName(dst2.data)
    dst2.des = string.format("通知#<Y,>%s#", name)
    npcId = dst2.data
    print(" *************** ", dst2.des)
    local isNpcCile = SanJieLiLian.today_times and 0 < SanJieLiLian.today_times and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
    if isNpcCile then
      dst2.data = SanJieLiLian.MissionNPCId
      result = 701581
      word = nil
    else
      _, masterName = data_getBossForWar(SanJieLiLian.dataid_)
      local mapData = data_CustomMapPos[SanJieLiLian.loc_id_] or {}
      local mapDatainfo = data_MapInfo[mapData.SceneID] or {}
      mapName = mapDatainfo.name
      local _, name = data_getRoleShapeAndName(npcId)
      print(" ====================================== mapData.SceneID ", mapData.SceneID)
      local rannum = math.random(1, 100)
      if rannum <= 50 then
        result = 701551
        word = string.format("#<Y,>%s#正在寻找一个叫#<Y,>%s#的妖怪，我曾经在#<Y,>%s#看见过，你去将它杀了，然后告诉#<Y,>%s#，他会很高兴的。", name, masterName, mapName, name)
      else
        result = 701561
        word = string.format("大侠来的正巧，#<Y,>%s#不慎放走了被封印#<Y,>%s#，那妖怪已逃窜至#<Y,>%s#,还请少侠尽快除之。", name, masterName, mapName)
      end
    end
    print(" ==========================================  SanJieLiLian.dataid_", SanJieLiLian.dataid_, SanJieLiLian.loc_id_, dst2.type)
  elseif kind == SanJieLiLian.Type_Objs then
    if SanJieLiLian.npcid_ == nil then
      local objData = data_TaskRunRing_GiveItem[SanJieLiLian.dataid_]
      local npcList = objData.NpcList or {}
      local ranNum = math.random(1, #npcList)
      dst2.data = npcList[ranNum] or 0
      if npcList[ranNum] == SanJieLiLian.lastTalkNpcId then
        if ranNum + 1 <= #npcList then
          dst2.data = npcList[ranNum + 1] or 0
        elseif 1 <= ranNum - 1 then
          dst2.data = npcList[ranNum - 1] or 0
        end
      end
    else
      dst2.data = SanJieLiLian.npcid_
    end
    dst2.type = 0
    local _, name = data_getRoleShapeAndName(dst2.data)
    dst2.des = string.format("把物品交给#<Y,>%s#", name)
    print(" ======> ", dst2.des, missionData.dst2.des)
    dst1.data = dst2.data
    npcId = dst1.data
    local _, name = data_getRoleShapeAndName(npcId)
    local params = dst1.param
    if params and params[1] then
      local k = params[1][1]
      local v = params[1][2]
      local oname = data_getItemName(k)
      local mname = SanJieLiLian.getLifeItemName(k)
      if mname ~= nil then
        oname = mname
      end
      if oname and v then
        local objectName = oname
        local f_index, t_index = string.find(objectName, "★")
        if f_index ~= nil and t_index ~= nil then
          objectName = string.sub(objectName, t_index + 1, -1)
        end
        if SanJieLiLian.needToBuy(k) then
          result = 701541
          word = string.format("时不待人，好友#<Y,>%s#急需%s#<Y,>%s#，恳请大侠能帮助他解决此次的燃眉之急。", name, "", objectName)
        else
          result = 701531
          word = string.format("听说大侠好善乐施，我想送%s#<Y,>%s#给我好友#<Y,>%s#，劳烦您替我跑一趟吧。", "", objectName, name)
        end
      end
    end
  elseif kind == SanJieLiLian.Type_Question then
    npcId = dst1.data
    local _, name = data_getRoleShapeAndName(dst1.data)
    word = string.format("行走江湖，除了武艺超群，还需要头脑灵活才行。#<Y,>%s#听说大侠文武双全，誓要与大侠较量一番！", name)
    result = 701571
  elseif kind == SanJieLiLian.Type_ZhuaChong then
    local petName = "宠物"
    npcId = SanJieLiLian.npcid_
    dst2.data = SanJieLiLian.npcid_
    local petData = data_TaskRunRing_GivePet[SanJieLiLian.dataid_]
    if petData == nil then
      print("=================>>>三界历练找不到抓宠的导表  id: ", SanJieLiLian.dataid_)
    end
    local needPetData = petData.NeedPet or {}
    for k, v in pairs(needPetData) do
      local dpetData = data_getRoleData(k) or {}
      print(" ========>>>>>> SanJieLiLian.dataid_ :", SanJieLiLian.dataid_)
      if dpetData.NAME ~= nil then
        petName = dpetData.NAME
        break
      end
    end
    local _, name = data_getRoleShapeAndName(npcId)
    if name ~= nil then
      dst2.des = string.format("把#<Y,>%s#交给#<Y,>%s#", petName, name)
    else
      dst2.des = dst1.des
    end
    word = string.format("时不待人，好友#<Y,>%s#急需一只#<Y,>%s#，恳请大侠能帮助他解决此次的燃眉之急。", name, petName)
    result = 701591
  end
  print("  SanJieLiLian.getNextTalkId ====>. kind = ", kind, " npcId =", npcId, "  masterName = ", masterName, "  mapName = ", mapName)
  talkItem = data_MissionTalk[result]
  print("  talkItem == nil ", talkItem == nil)
  if talkItem and talkItem[1] then
    if SanJieLiLian.isnew == true and SanJieLiLian.today_times == 0 then
      SanJieLiLian.lastTalkNpcId = SanJieLiLian.MissionNPCId
    end
    talkItem[1][1] = SanJieLiLian.lastTalkNpcId
    SanJieLiLian.lastTalkNpcId = npcId
    if word ~= nil then
      talkItem[1][2] = word
    end
    print("===>   ", talkItem[1][2])
  end
  dump(dst2, " DST2    >>>")
  return result
end
function SanJieLiLian.getItemNpcName(objid)
  if data_Shop_NPC_Wuqi[objid] ~= nil then
    return "铁匠"
  elseif data_Shop_NPC_Yaopin[objid] ~= nil then
    return "药店老板"
  elseif data_Shop_NPC_XieziXianglian[objid] ~= nil or data_Shop_NPC_Maozi[objid] ~= nil or data_Shop_NPC_Yifu[objid] ~= nil then
    return "服装商人"
  elseif data_Shop_NPC_Zawu[objid] ~= nil then
    return "杂货商人"
  end
  return "市场总管"
end
function SanJieLiLian.needToBuy(objid)
  if objid == 72001 or objid == 72002 then
    return true
  end
  local upClose = data_Shop_NPC_Wuqi[objid] == nil
  return false, upClose
end
function SanJieLiLian.missionCmp()
  print("  任务 完成 一个状态  SanJieLiLian.missionCmp  ", SanJieLiLian.type_, SanJieLiLian.today_times)
  if SanJieLiLian.Type_Talk == SanJieLiLian.type_ then
    local isNpcCile = SanJieLiLian.today_times and SanJieLiLian.today_times > 0 and (SanJieLiLian.today_times + 1) % SanJieLiLian.UnionTime == 0
    if isNpcCile then
      SanJieLiLian.lastTalkNpcId = SanJieLiLian.MissionNPCId
      g_MissionMgr:delSanJieLiLian(SanJieLiLian.missionId_)
      netsend.netmission.reqAcceptByType(901)
      g_MissionMgr:flushMissionStatusForNpc()
      SendMessage(MsgID_Mission_Common)
    else
      SanJieLiLian.reqFinish()
    end
    SanJieLiLian.isDoingTask = false
    print("刷新后  SanJieLiLian.type_ ", SanJieLiLian.type_)
  elseif SanJieLiLian.Type_Objs == SanJieLiLian.type_ then
    local needtoShow = false
    if g_MissionMgr then
      local missionId = SanJieLiLian.missionId_
      local dataTable, missionKind = g_MissionMgr:getMissionData(missionId)
      local missionPro, curParam = g_MissionMgr:getMissionProgress(missionId)
      curParam = curParam or {}
      local dst = g_MissionMgr:getDstData(dataTable, missionPro)
      if dst then
        local objList = dst.param or {}
        for i, obj in ipairs(objList) do
          local objId, sum = obj[1], obj[2]
          if GetItemTypeByItemTypeId(objId) == ITEM_LARGE_TYPE_LIFEITEM then
            needtoShow = true
            break
          end
        end
      end
    end
    if needtoShow then
      OpenMissionCommitView({
        mid = SanJieLiLian.missionId_,
        commitlistener = function(itemlist)
          SanJieLiLian.reqCommit(itemlist)
        end
      })
    else
      SanJieLiLian.reqCommit()
    end
    SanJieLiLian.isDoingTask = false
  elseif SanJieLiLian.Type_War == SanJieLiLian.type_ then
    if SanJieLiLian.status_ == 1 then
      print(" 战斗一 ")
    elseif SanJieLiLian.status_ == 2 then
      print(" 战斗二 ")
      SanJieLiLian.reqCommit()
      SanJieLiLian.isDoingTask = false
    end
  elseif SanJieLiLian.type_ == SanJieLiLian.Type_Question then
  elseif SanJieLiLian.type_ == SanJieLiLian.Type_ZhuaChong then
    netsend.netmission.reqCommitPetList(901, SanJieLiLian.taskid_)
  end
end
function SanJieLiLian.startAnser()
  SanJieLiLian.questionPanel = DatiRoom.new(SanJieLiLian.dataid_)
  getCurSceneView():addSubView({
    subView = SanJieLiLian.questionPanel,
    zOrder = MainUISceneZOrder.menuView + 1
  })
end
function SanJieLiLian.reqAccept()
  print(" 开始请求三界历练200 任务 ", SanJieLiLian.isDoingTask, SanJieLiLian.AcceptMissionId, SanJieLiLian.missionId_)
  netsend.netmission.reqAcceptByType(901)
end
function SanJieLiLian.reqFinish()
  netsend.netmission.reqFinishByType(901, SanJieLiLian.taskid_)
end
function SanJieLiLian.reqCommit(list)
  print("请求交付三界历练任务  SanJieLiLian.taskid_ ", SanJieLiLian.taskid_, list)
  netsend.netmission.reqCommitByType(901, SanJieLiLian.taskid_, list)
end
function SanJieLiLian.reqCommitAnswer(manswer)
  netsend.netmission.commitAnser(manswer)
end
function SanJieLiLian.reqGiveup()
  print("请求放弃三界历练任务")
  netsend.netmission.reqGiveupByType(901, SanJieLiLian.taskid_)
end
function SanJieLiLian.FlushQuestionData(answer, funBack, ismistake)
  print(" 刷新 答题数据 funBack = ", funBack)
  SanJieLiLian.questionFlush = funBack
  SanJieLiLian.reqCommitAnswer(answer)
  SanJieLiLian.isAnswerWrong = ismistake
end
function SanJieLiLian.reqReSet()
  print(" 三界历练请求重置 *********** 23333 ")
  if SanJieLiLian.missionId_ > 0 and 0 < SanJieLiLian.taskid_ then
    local dlg = CPopWarning.new({
      title = "提示",
      text = "重置本环任务需要消耗5000#<IR7>#，你确定要重置本环任务吗？",
      align = CRichText_AlignType_Left,
      confirmFunc = function()
        netsend.netmission.reqReSetMissionSJLL(901, SanJieLiLian.taskid_)
      end,
      cancelText = "取消",
      confirmText = "确定"
    })
    dlg:ShowCloseBtn(false)
  else
    netsend.netmission.reqReSetMissionSJLL(901, SanJieLiLian.taskid_)
  end
end
function SanJieLiLian.CheckMissionPet()
  print("*****************   SanJieLiLian.CheckMissionPet ", SanJieLiLian.missionId_, SanJieLiLian.petid, SanJieLiLian.status_)
  if SanJieLiLian.missionId_ == 90006 and SanJieLiLian.petid ~= nil then
    if SanJieLiLian.status_ == 1 then
      g_MissionMgr:addShotageObj(SanJieLiLian.petid, SanJieLiLian.missionId_)
      SendMessage(MsgID_Stall_UpdateOneKindGoods, {
        goodId = SanJieLiLian.petid
      })
    else
      g_MissionMgr:removeShotageObj(SanJieLiLian.petid, SanJieLiLian.missionId_)
      SendMessage(MsgID_Stall_UpdateOneKindGoods, {
        goodId = SanJieLiLian.petid
      })
      SanJieLiLian.petid = nil
    end
  end
end
function SanJieLiLian.getTaskPetId()
  return SanJieLiLian.petid, SanJieLiLian.missionId_
end
function SanJieLiLian.setTaskPetId(value)
  SanJieLiLian.petid = value
end
SanJieLiLian.init()
gamereset.registerResetFunc(function()
  SanJieLiLian.init()
end)
