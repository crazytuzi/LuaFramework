local Location = require("netio.protocol.mzm.gsp.map.Location")
local ClientCmd = {}
function ClientCmd.DoNPC(argv)
  if table.maxn(argv) < 2 then
    return
  end
  local npcid = tonumber(argv[2])
  if npcid == 0 then
    return
  end
  require("Main.npc.NPCModule").OnDoNPC({npcID = npcid}, nil)
end
function ClientCmd.testNPCTalk(argv)
  local TaskInterface = require("Main.task.TaskInterface")
  local testTalk = TaskInterface.GetTaskTalkCfg(10000001)
  local nm = gmodule.moduleMgr:GetModule(ModuleId.NPC)
  local talk = testTalk.dlgs[1]
  if talk == nil then
    talk = testTalk.dlgs[2]
  end
  if talk == nil then
    talk = testTalk.dlgs[3]
  end
  if talk == nil then
    talk = testTalk.dlgs[4]
  end
  nm.ShowNPCText(talk.content, nm.ToDoFinishTalk_None, 0, 0)
end
function ClientCmd.CreateGang(argv)
  if table.maxn(argv) < 2 then
    return
  end
  local str1 = clone(argv[2])
  local str2 = clone(argv[3])
  GangMgr.C2SCreateGang(str1, str2)
end
function ClientCmd.QueryGangList(argv)
  GangMgr.C2SGetGangList()
end
function ClientCmd.QueryGangInfo(argv)
  GangMgr.C2SGetGangInfo()
end
function ClientCmd.QueryMemberList(argv)
  GangMgr.C2SGetGangMemberList()
end
function ClientCmd.ShowSkillUI()
  require("fight.ui.FightSkillListUI").Show()
end
function ClientCmd.ShowItemListUI()
  require("fight.ui.FightItemListUI").Show()
end
function ClientCmd.ShowMatchTimeUI()
  require("fight.ui.FightMatchTimeUI").Show()
  require("fight.ui.FightMatchTimeUI").UpdateTime(2, 1)
end
function ClientCmd.ShowGangUI()
  require("gang.ui.MainGangUI").Show()
end
function ClientCmd.ShowGangListUI(args)
  require("gang.ui.CreateGangUI").Show()
end
function ClientCmd.TestImgNum(argv)
  local startPos = {}
  local endPos = {}
  startPos.x = 400
  startPos.y = 400
  endPos.x = 400
  endPos.y = 50
  local num = clone(argv[2])
  require("common.CommonFightNum").AddNumImg(num, startPos, endPos)
end
function ClientCmd.TestGangMenu()
  require("commonMenu.MenuMgr").Show(1, 300, 100)
end
function ClientCmd.TestGangMailUI()
  require("gang.ui.GangMailUI").Show()
end
function ClientCmd.EnabletaskDebug()
  require("chat.Interface").AddSystemMessage("\228\187\187\229\138\161\232\176\131\232\175\149\228\191\161\230\129\175\229\183\178\229\188\128\229\144\175\239\188\129\239\188\129")
  TASK_DEBUG_ENABLED = true
end
function ClientCmd.ShowActivityMain()
  require("chat.Interface").AddSystemMessage("ShowActivityMain")
  GUI.ShowFrame("ActivityMain")
end
function ClientCmd.ShowSystemHandInFrame()
  require("commonui.HandInItemUI").Show()
end
function ClientCmd.StartQuestion()
  local questionModule = require("Main.Question.QuestionModule").Instance()
  questionModule:JoinQuestion()
end
function ClientCmd.SendTime()
  local cur = os.date("*t")
  local date = string.format("%d-%d-%d", cur.year, cur.month, cur.day)
  local time = os.date("%X")
  local ChatModule = require("Main.Chat.ChatModule")
  ChatModule.Instance():SendChannelMsg(date .. " " .. time, 4, false)
end
function ClientCmd.ToggleDebug()
  ToggleDebugConsole()
end
function ClientCmd.ShowTaskTips(argv)
  if table.maxn(argv) < 2 then
    return
  end
  local taskID = tonumber(argv[2])
  local TaskTips = require("Main.task.ui.TaskTips")
  TaskTips.Instance():ShowDlg(taskID)
end
function ClientCmd.ShowPetShop(argv)
  if argv[2] == "buy" then
    require("Main.Pet.ui.PetShopBuyPanel").Instance():ShowPanel()
  elseif argv[2] == "sell" then
    require("Main.Pet.ui.PetShopSellPanel").Instance():ShowPanel()
  end
end
function ClientCmd.RefreshTaskTrace(argv)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_InfoChanged, nil)
end
function ClientCmd.SearchItem(argv)
  local target = argv[2]
  if target == nil then
    return
  end
  local results = require("Main.Item.ItemUtils").DebugSearchItem(target)
  for i, v in ipairs(results) do
    warn(string.format("No.%03d %d [%s]", i, v.itemid, v.name))
  end
end
function ClientCmd.ShowAwardUI(argv)
  require("Main.Award.ui.AwardPanel").Instance():ShowPanel()
end
function ClientCmd.ShowTaskDramaUI(argv)
  require("Main.task.ui.TaskDrama").Instance():ShowDlg()
end
function ClientCmd.Lua(argv)
  local luaCode = table.concat(argv, " ", 2)
  assert(loadstring(luaCode))()
end
function ClientCmd.Unload(argv)
  local moduleName = argv[2]
  local rs, info = pcall(require, moduleName)
  if rs then
    local metaTable = getmetatable(info)
    if metaTable then
      local typeName = metaTable.typeName
      if typeName then
        require("Lplus").Unload(typeName)
      end
    end
  end
  _G.package.loaded[moduleName] = nil
  print("Unload (" .. moduleName .. ") success.")
end
function ClientCmd.loadStory(argv)
  local resn = "mengjingzhizhan"
  local reso = "Arts/CGPrefab/%s.prefab.u3dext"
  if argv[2] ~= nil then
    resn = argv[2]
  end
  local res = string.format(reso, resn)
  local OnLoaded = function(path)
    print("**************** ClientCmd.loadStory   load (", path, ") success.")
    local TaskInterface = require("Main.task.TaskInterface")
    TaskInterface.Instance()._playingOpera = path
  end
  local CG = require("CG.CG")
  CG.Instance():Play(res, res, OnLoaded)
  Event.DispatchEvent(ModuleId.TASK, gmodule.notifyId.task.Task_DramaStart, {path})
end
function ClientCmd.ShowTaskTalkNPC(argv)
  if table.maxn(argv) < 2 then
    return
  end
  local npcID = tonumber(argv[2])
  local NPCInterface = require("Main.npc.NPCInterface")
  local npcCfg = NPCInterface.GetNPCCfg(npcID)
  local taskModule = gmodule.moduleMgr:GetModule(ModuleId.TASK)
  taskModule._talkType = 0
  taskModule._FinishTalkTaskId = 0
  taskModule._FinishTalkGraphId = 0
  taskModule._talkIndex = -1
  local txt = string.format("NPCID = " .. tostring(npcID) .. " name = " .. npcCfg.npcName)
  local npcTalk = require("Main.task.ui.TaskTalk").Instance()
  npcTalk:SetTouchable(true)
  npcTalk:SetNPCID(npcID)
  npcTalk:SetText(txt)
  npcTalk:ShowDlg()
end
function ClientCmd.NewActivity(argv)
  if table.maxn(argv) < 2 then
    return
  end
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local ids = {}
  for i = 2, #argv do
    local activityID = tonumber(argv[i])
    table.insert(ids, activityID)
    activityInterface._newActivitiesSet[activityID] = activityID
    table.insert(activityInterface._newActivitiesVector, p.activityid)
  end
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Start, ids)
end
function ClientCmd.PlaySpecialEffect(argv)
  if table.maxn(argv) < 2 then
    return
  end
  local TaskModule = require("Main.task.TaskModule")
  local id = tonumber(argv[2])
  TaskModule.PlaySpecialEffectCfg(id)
end
function ClientCmd.RefreshMainUI(argv)
  require("Main.MainUI.MainUIModule").RefreshFunctions()
end
function ClientCmd.FiltrateItems(argv)
  local siftID = 210200305
  if argv[2] ~= nil then
    siftID = tonumber(argv[2])
  end
  local bagId = require("netio.protocol.mzm.gsp.item.BagInfo").BAG
  local itemData = require("Main.Item.ItemData").Instance()
  warn("*******************************  FiltrateItems(", siftID, ")")
  local res = itemData:FiltrateItems(bagId, siftID, -1)
  for k, v in pairs(res) do
    warn("*******************************  " .. v.itemBase.name)
  end
end
function ClientCmd.ShowPartnerNew(argv)
  local partnerID = 140100000
  if argv[2] ~= nil then
    siftID = tonumber(argv[2])
  end
  require("Main.partner.ui.PartnerNew").Instance():ShowDlg(partnerID)
end
function ClientCmd.OperateMainUI(argv)
  local mainui = require("Main.MainUI.ui.MainUIPanel").Instance()
  if argv[2] == "open" then
    mainui:ExpandAll(true)
  elseif argv[2] == "close" then
    mainui:ExpandAll(false)
  elseif argv[2] == "refresh" then
    mainui:Refresh()
  end
end
function ClientCmd.ShowBounty(argv)
  local bountyHunter = require("Main.activity.ui.BountyHunter").Instance()
  bountyHunter:ShowDlg()
end
function ClientCmd.UnitTest(argv)
  local name = string.gsub(argv[2], "%.", "/")
  local chunk, errorMsg = loadfile("Lua/UnitTest/" .. name .. ".lua")
  if chunk == nil then
    warn(errorMsg)
    return
  end
  table.remove(argv, 1)
  table.remove(argv, 1)
  chunk(unpack(argv))
end
function ClientCmd.ShowWorldBoss(argv)
  local WorldBossActivityId = require("Main.WorldBoss.WorldBossMgr").ACTIVITYID
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Todo, {WorldBossActivityId})
end
function ClientCmd._OnSisContinueZhenyao(argv)
  local protocols = require("Main.activity.ActivityProtocols")
  protocols.OnSisContinueZhenyao({})
end
function ClientCmd._TTime(argv)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local t = ActivityInterface.GetActivityBeginningAndEndingTime(350000014)
  warn("****************************** t", t)
end
function ClientCmd._testNewActivity(argv)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  local newDailyList = {350000009}
  activityInterface._newActivitiesSet[350000009] = 350000009
  activityInterface._newActivitiesVector = {350000009}
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_ListChanged, newDailyList)
end
function ClientCmd._testShowUI(argv)
  local ActivityMain = require("Main.activity.ui.ActivityMain")
  local ActivityWeekly = require("Main.activity.ui.ActivityWeekly")
  local UIBehaviorShowUI = require("Utility.UIBehaviorShowUI")
  local UIBehaviorWaitUIShowShowUI = require("Utility.UIBehaviorWaitUIShowShowUI")
  local UIBehaviorWaitUIShowClick = require("Utility.UIBehaviorWaitUIShowClick")
  local UIBehaviorMgr = require("Utility.UIBehaviorMgr")
  local mgr = UIBehaviorMgr.Instance()
  local activityMain = ActivityMain.Instance()
  local tsu = UIBehaviorShowUI.New(activityMain, ActivityMain.ShowDlg)
  local tssu = UIBehaviorWaitUIShowShowUI.New(ActivityWeekly.Instance(), ActivityWeekly.ShowDlg, "panel_activty")
  local tsc = UIBehaviorWaitUIShowClick.New(ActivityWeekly.Instance(), "panel_activityweekly", "Box_Activity_05_03")
  activityMain._targetActivityID = 350000008
  activityMain._targetTip = true
  mgr:AddBehavior(tsu)
  mgr:Do()
end
function ClientCmd._testGangNPC(argv)
  require("Main.Gang.GangBattleMgr").Instance():GotoGangMapNPC(150111302)
end
function ClientCmd._testPartnerFirstUnivited(argv)
  require("Main.partner.ui.PartnerMain").Instance():ShowDlgFirstUnivited()
end
function ClientCmd._testPartnerFirstJoined(argv)
  require("Main.partner.ui.PartnerMain").Instance():ShowDlgFirstJoined()
end
function ClientCmd.RefreshActivity(argv)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  activityInterface:RefreshActivityList()
end
function ClientCmd.DoNpcTalkShow(argv)
  ClientCmd.DoNPC(argv)
  ClientCmd.ShowTaskTalkNPC(argv)
end
function ClientCmd.testSendActivityStart(argv)
  local activityID = 350000016
  if argv[2] ~= nil then
    activityID = tonumber(argv[2])
  end
  local p = require("netio.protocol.mzm.gsp.activity.SynActivityStart").new(activityID)
  local protocols = require("Main.activity.ActivityProtocols")
  protocols.OnSynActivityStart(p)
end
function ClientCmd.testSendActivityEnd(argv)
  local activityID = 350000016
  if argv[2] ~= nil then
    activityID = tonumber(argv[2])
  end
  local p = require("netio.protocol.mzm.gsp.activity.SynActivityEnd").new(activityID)
  local protocols = require("Main.activity.ActivityProtocols")
  protocols.OnSynActivityEnd(p)
end
local _print = _G.print
local _warn = _G.warn
local log = function(logfunc, traceback, ...)
  if logfunc == nil then
    return
  end
  local argc = select("#", ...)
  local args = {
    ...
  }
  local strTable = {}
  for i = 1, argc do
    local v = args[i]
    table.insert(strTable, tostring(v))
  end
  local str = table.concat(strTable, " ")
  if traceback then
    str = string.format([[
%s
%s]], str, debug.traceback())
  end
  logfunc(str)
end
function ClientCmd.SetLogLevelNew(argv)
  local level = tonumber(argv[2])
  if level and level >= 0 and level <= 5 then
    GameUtil.SetLogLevel(level)
  end
end
function ClientCmd.SetLogLevel(argv)
  local function nolog(...)
    return log(nil, false, ...)
  end
  local function infolog(...)
    return log(Debug.LogInfo, false, ...)
  end
  local function warnlog(...)
    return log(Debug.LogWarning, false, ...)
  end
  local function warnlogTraceback(...)
    return log(Debug.LogWarning, true, ...)
  end
  local level = tonumber(argv[2]) or 2
  if level <= 0 then
    _G.print = nolog
    _G.warn = nolog
  elseif level == 1 then
    _G.print = nolog
    _G.warn = warnlog
  elseif level >= 2 then
    _G.print = infolog
    _G.warn = warnlog
    if level >= 100 then
      _G.warn = warnlogTraceback
    end
  end
end
function ClientCmd.SetProtocolLogLevel(argv)
  local level = tonumber(argv[2])
  _G.ProtoLogLevel = level
end
function ClientCmd.guidopenstatus(argv)
  local GuideModule = require("Main.Guide.GuideModule")
  for k, v in pairs(GuideModule.Instance().funcs) do
    print("functype", k, v and v.active or nil)
  end
end
function ClientCmd.OutputTaskInfos(argv)
  local TaskInterface = require("Main.task.TaskInterface")
  local taskInterface = TaskInterface.Instance()
  Debug.LogWarning("================================================= Begin TaskInfos")
  for taskId, graphIdValue in pairs(taskInterface._taskInfo) do
    local taskCfg = TaskInterface.GetTaskCfg(taskId)
    for graphId, info in pairs(graphIdValue) do
      local dispName = taskCfg.taskName
      Debug.LogWarning("=========== TaskID GraphID " .. tostring(taskCfg.taskName) .. " " .. tostring(taskId) .. " " .. tostring(graphId))
    end
  end
  Debug.LogWarning("================================================= End   TaskInfos")
end
function ClientCmd.OutputActivityInfos(argv)
  local ActivityInterface = require("Main.activity.ActivityInterface")
  local activityInterface = ActivityInterface.Instance()
  Debug.LogWarning("================================================= Begin ActivityInfos")
  for k, info in pairs(activityInterface._activityInfos) do
    local activityCfg = ActivityInterface.GetActivityCfgById(info.actvityId)
    Debug.LogWarning("=========== ActvityID " .. tostring(activityCfg.activityName) .. " " .. tostring(info.actvityId) .. " " .. tostring(info.count))
  end
  Debug.LogWarning("================================================= End   ActivityInfos")
end
function ClientCmd.ZLOpenUrl(argv)
  local url = argv[2]
  if url == nil or url == "" then
    Toast("url invalid!")
    return
  end
  require("Main.ECGame").Instance():OpenUrlByZLBrowserWithPayInfo(url)
end
function ClientCmd.ShowMultiOccupationDlg(argv)
  local dlgType = tonumber(argv[2]) or 1
  local npcId = constant.CMultiOccupConsts.npc
  if 1 == dlgType then
    require("Main.MultiOccupation.ui.ChangeCharacterPanel").Instance():Reset()
    require("Main.MultiOccupation.ui.ChooseCharacterPanel").Instance():ShowPanel(npcId)
  else
    require("Main.MultiOccupation.ui.ChooseCharacterPanel").Instance():Reset()
    require("Main.MultiOccupation.ui.ChangeCharacterPanel").Instance():ShowPanel(npcId)
  end
end
function ClientCmd.prof(cmds)
  local act = tonumber(cmds[2])
  if act == 0 then
    GameProfiler.stop()
  end
  if act == 1 then
    local call_time_threshold = tonumber(cmds[3]) or 0.3
    local high_state_threshold = tonumber(cmds[4]) or 3
    local stat_overhead_factor = tonumber(cmds[5]) or 0.9
    GameProfiler.start(call_time_threshold, high_state_threshold, stat_overhead_factor)
  end
  if act == 2 then
    GameProfiler.dump("lua")
  end
end
function ClientCmd.dumpmem(cmds)
  local name = cmds[2] or os.date("%Y-%m-%d-%H-%M-%S")
  if name then
    require("Utility.ECMemoryUtils").dump_memory(tostring(name))
  end
end
function ClientCmd.snapshot(cmds)
  local SnapshotHelper = require("Utility.SnapshotHelper")
  local act = cmds[2]
  if act == "1" or act == "start" then
    SnapshotHelper.start()
  elseif act == "2" or act == "diff" then
    SnapshotHelper.diff()
  elseif act == "lessdiff" then
    SnapshotHelper.lessdiff()
  elseif act == "leastdiff" then
    SnapshotHelper.leastdiff()
  elseif act == "3" or act == "all" then
    SnapshotHelper.all()
  else
    warn("usage: snapshot <start | diff | lessdiff | leastdiff | all>")
  end
end
function ClientCmd.bigtable(cmds)
  local SnapshotHelper = require("Utility.SnapshotHelper")
  local thredshold = tonumber(cmds[2])
  local subfix = cmds[3]
  if thredshold and subfix then
    SnapshotHelper.bigtable(thredshold, subfix)
  else
    warn("usage: bigtable <thredshold> <subfix>")
  end
end
function ClientCmd.reslog(cmds)
  local op = tonumber(cmds[2])
  local bPrint = cmds[3] and tonumber(cmds[3]) == 1
  if op == 0 or op == 1 then
    GameUtil.EnableResLog(op == 1, bPrint)
  elseif op == 2 then
    local content = GameUtil.GetResLog()
    WriteToFile(GameUtil.GetAssetsPath() .. "/reslog.txt", content)
    if #content < 500 then
      warn(GameUtil.GetResLog())
    else
      warn(content:sub(1, 5000), [[

... see reslog.txt]])
    end
  end
end
function ClientCmd.regtab(cmds)
  local registry_table_info = {}
  for k, v in pairs(debug.getregistry()) do
    if type(v) == "function" then
      registry_table_info[k] = FormatFunctionInfo(v)
    else
    end
  end
  Debug.LogWarning(require("Utility.malut").tableToString(registry_table_info, 1))
end
local _stat_timer = 0
function ClientCmd.stat(cmds)
  local bshow = tonumber(cmds[2])
  if bshow == 1 then
    if _stat_timer == 0 then
      GameUtil.ShowStat(true)
      _stat_timer = GameUtil.AddGlobalTimer(1, false, function()
        require("Main.ECGame").Instance():ShowStat()
      end)
    end
  elseif _stat_timer ~= 0 then
    GameUtil.ShowStat(false)
    GameUtil.RemoveGlobalTimer(_stat_timer)
    _stat_timer = 0
  end
end
function ClientCmd.statf(cmds)
  local bshow = tonumber(cmds[2])
  if bshow == 1 then
    if _stat_timer == 0 then
      _stat_timer = GameUtil.AddGlobalTimer(1, false, function()
        require("Main.ECGame").Instance():SaveStat()
      end)
    end
  elseif _stat_timer ~= 0 then
    GameUtil.RemoveGlobalTimer(_stat_timer)
    _stat_timer = 0
  end
end
function ClientCmd.fps(cmds)
  local bshow = tonumber(cmds[2])
  GameUtil.ShowFPS(bshow == 1)
  if #cmds >= 3 then
    Application.set_targetFrameRate(tonumber(cmds[3]))
  end
end
function ClientCmd.formation(cmds)
  if #cmds > 2 then
    local formationmodule = require("Main.Formation.FormationModule")
    print("formation", cmds[2], cmds[3])
    formationmodule.Instance():ShowFormationDlg(tonumber(cmds[2]), tonumber(cmds[3]), nil)
  end
end
function ClientCmd.gfx(cmds)
  local bshow = tonumber(cmds[2])
  local ECFxMan = require("Fx.ECFxMan")
  ECFxMan.Instance().HideAllGFX = bshow == 0
end
function ClientCmd.noplayer(cmds)
  local bshow = tonumber(cmds[2])
  _G.IsNoLoadObj = bshow == 0
end
function ClientCmd.yuanbao(cmds)
  local ItemModule = require("Main.Item.ItemModule")
  Toast("\228\189\160\229\189\147\229\137\141\230\156\137\229\133\131\229\174\157:" .. ItemModule.Instance():GetAllYuanBao():tostring())
end
function ClientCmd.wabao(cmds)
  require("Main.Wabao.WabaoModule").Instance():GotoWabao()
end
function ClientCmd.wings(cmds)
  require("Main.ECGame").Instance():DebugString(".levelto 90")
  require("Main.ECGame").Instance():DebugString(".additem 210104001 1")
  require("Main.ECGame").Instance():DebugString(".additem 210104002 30")
  require("Main.ECGame").Instance():DebugString(".additem 210104003 30")
  require("Main.ECGame").Instance():DebugString(".additem 210104004 30")
  require("Main.ECGame").Instance():DebugString(".additem 210104005 30")
  require("Main.ECGame").Instance():DebugString(".additem 213700000 100")
  require("Main.ECGame").Instance():DebugString(".additem 213800000 1")
  require("Main.ECGame").Instance():DebugString(".additem 213800001 1")
  require("Main.ECGame").Instance():DebugString(".addbuyyuanbao 142857")
end
function ClientCmd.kejustates(cmds)
  local KejuModule = require("Main.Keju.KejuModule")
  local KejuConst = require("Main.Keju.KejuConst")
  print("xiangshi state is: " .. tostring(KejuModule.Instance().data[KejuConst.ExamType.XIANG_SHI].enable))
  print("huishi state is: " .. tostring(KejuModule.Instance().data[KejuConst.ExamType.HUI_SHI].enable))
  print("dianshi state is: " .. tostring(KejuModule.Instance().data[KejuConst.ExamType.DIAN_SHI].enable))
end
function ClientCmd.npcmodel(cmds)
  if #cmds > 1 then
    local NPCInterface = require("Main.npc.NPCInterface")
    local cfg = NPCInterface.GetNpcFigureCfg(tonumber(cmds[2]))
    print("NPCMODELCFG:", cfg.id, cfg.weaponId, cfg.wingId, cfg.horseid, cfg.faBaoId, cfg.isShowDecorateItem)
  end
end
function ClientCmd.talk(cmds)
  if #cmds > 1 then
    local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
    heroModule.myRole:Talk(cmds[2], 0)
  end
end
function ClientCmd.idipswitch(cmds)
  if #cmds > 1 then
    local switchId = tonumber(cmds[2])
    local funcId = tonumber(cmds[3]) or 0
    if switchId then
      require("Main.FeatureOpenList.FeatureOpenListModule").Instance():OutputOne(switchId, funcId or 0)
    end
  else
    require("Main.FeatureOpenList.FeatureOpenListModule").Instance():Output()
  end
end
function ClientCmd.fightitem(cmds)
  local ItemModule = require("Main.Item.ItemModule")
  local Items = ItemModule.Instance():GetInFightItem()
  print("==========FightItem==========")
  for k, v in ipairs(Items) do
    print(string.format("%d: %s[%d]x%d", k, v.name, v.id, v.count))
  end
  print("==========FightItem==========")
end
function ClientCmd.wtf(cmds)
  require("Main.ECGame").Instance():DebugString(".levelto 99")
  require("Main.ECGame").Instance():DebugString(".addgold 999999999")
  require("Main.ECGame").Instance():DebugString(".addsilver 999999999")
  require("Main.ECGame").Instance():DebugString(".addbuyyuanbao 999999999")
  require("Main.ECGame").Instance():DebugString(".addvigor 999999999")
end
function ClientCmd.lt(cmds)
  require("Main.PVP.ui.DlgLeitai").Instance():ShowDlg()
end
function ClientCmd.cgplay(cmds)
  print("cgPlay !")
end
function ClientCmd.win(cmds)
  require("Main.ECGame").Instance():DebugString(".closefight 1")
end
function ClientCmd.lose(cmds)
  require("Main.ECGame").Instance():DebugString(".closefight 0")
end
function ClientCmd.guide(cmds)
  if #cmds > 1 then
    local index = tonumber(cmds[2])
    require("Main.Guide.GuideModule").onAddGuide({
      guideids = {index}
    })
  elseif #cmds > 2 then
    local index = tonumber(cmds[2])
    local index2 = tonumber(cmds[3])
    require("Main.Guide.GuideModule").onAddGuide({
      guideids = {index, index2}
    })
  end
end
function ClientCmd.guidestep(cmds)
  if #cmds > 1 then
    local index = tonumber(cmds[2])
    require("Main.Guide.GuideModule").Instance():StepOne(index, true)
  end
end
function ClientCmd.choosepet(cmds)
  require("Main.Guide.GuideModule").Instance():ChoosePet(0)
end
function ClientCmd.ghosteffect(cmds)
  local ecModel = require("Main.Hero.HeroModule").Instance().myRole
  local model = ecModel.m_model
  local eff = model:GetComponent("PlayerGhostEffect")
  if eff == nil then
    eff = model:AddComponent("PlayerGhostEffect")
  end
  local shadowType = tonumber(cmds[2])
  eff:set_mShadowMatType(shadowType)
  local color = Color.Color(0, 0, 0, 1)
  eff:set_mColor(color)
  eff:SetEffectArgs(0.9, 0, 0.3, 5, 10)
  eff:Begin()
  print("ghostEffect")
end
function ClientCmd.syncgc(cmds)
  local ECFxMan = require("Fx.ECFxMan")
  local EC = require("Types.Vector3")
  local fx = ECFxMan.Instance():Play("Models/Effects/FXs/Scenes/ChuanSongMen_Blue.prefab.u3dext", EC.Vector3.new(0, 0.5, 0), Quaternion.identity, -1, false, -1)
  local OnloadFinish = function(name, succ)
    warn("loadFx = ", name, " succ = ", succ)
  end
  FxCacheMan.RegLoadFinishFunc(OnloadFinish)
end
function ClientCmd.stranger(cmds)
  local ChatModule = require("Main.Chat.ChatModule")
  local list = ChatModule.Instance():GetStrangerChat()
  for k, v in pairs(list) do
    print(v.roleName)
  end
end
function ClientCmd.fixall(cmds)
  local ItemModule = require("Main.Item.ItemModule")
  ItemModule.Instance():FixAllEquip(false)
end
function ClientCmd.questionstart(cmds)
  local questionModule = require("Main.Question.QuestionModule")
  questionModule._onActivityStart({activityid = 350000009})
end
function ClientCmd.assetpath(cmds)
  local assetpath = GameUtil.GetAssetsPath()
  warn(assetpath)
end
function ClientCmd.speechon(cmds)
  local SpeechTip = require("Main.Chat.ui.SpeechTip")
  SpeechTip.Instance():Open()
end
function ClientCmd.speechoff(cmds)
  local SpeechTip = require("Main.Chat.ui.SpeechTip")
  SpeechTip.Instance():Close()
end
function ClientCmd.id(cmds)
  warn("RoleID: ", require("Main.ECGame").Instance().m_roleid)
end
function ClientCmd.sworn(cmds)
  local swornData = require("Main.Sworn.data.SwornData")
  local id = swornData.Instance():GetSwornID()
  if not id then
    warn("Sworn ID is nil ")
    return false
  end
  local name = swornData.Instance():GetSwornName()
  local member = swornData.Instance():GetSwornMember()
  warn(id, " ", name.name1, " ", name.name2, " ", #member)
  for _, v in pairs(member) do
    warn(v.roleid)
  end
end
function ClientCmd.speech(cmds)
  if #cmds > 1 then
    local index = tonumber(cmds[2])
    local SpeechTip = require("Main.Chat.ui.SpeechTip")
    SpeechTip.Instance():Voice(index)
  end
end
function ClientCmd.questionhelp(cmds)
  if #cmds > 2 then
    local questionId = tonumber(cmds[2])
    local pageId = tonumber(cmds[3])
    require("Main.Question.ui.QuestionHelpDlg").ShowHelp(questionId, pageId, function(qid, pid, answer)
      warn("Help!!!", qid, pid, answer)
    end)
  end
end
function ClientCmd.netiorecord(cmds)
  _G.IsRecordNetIO = true
  local ProtocolManager = require("netio.ProtocolManager")
  ProtocolManager.ClearOctets()
end
function ClientCmd.netiosave(cmds)
  _G.IsRecordNetIO = false
  local ProtocolManager = require("netio.ProtocolManager")
  ProtocolManager.SaveOctetsToFile()
end
function ClientCmd.netioplay(cmds)
  _G.IsReplayNetIO = true
  local ProtocolManager = require("netio.ProtocolManager")
  ProtocolManager.LoadOctetsFromFile(cmds[2])
  _G.IsRecordNetIO = false
  warn("play")
end
function ClientCmd.add(cmds)
  if #cmds > 1 then
    local name = cmds[2]
    local num = 1
    if cmds[3] then
      num = tonumber(cmds[3])
    end
    local searchItems = require("Main.Item.ItemUtils").DebugFindItem(name)
    for k, v in ipairs(searchItems) do
      warn(string.format(".additem %d %d", v.itemid, num))
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gm.CGMCommand").new(string.format("additem %d %d", v.itemid, num)))
    end
  end
end
function ClientCmd.resdelay(cmds)
  if #cmds > 1 then
    local on = cmds[2]
    if on == "on" then
      GameUtil.SetResDelay(2, true)
    elseif on == "off" then
      GameUtil.SetResDelay(0, false)
    end
  end
end
function ClientCmd.showpkui(cmds)
  local pkMain = require("Main.PK.ui.PKMainDlg")
  pkMain.Instance():ShowDlg()
end
function ClientCmd.showpkmatch(cmds)
  local pkMatchDlg = require("Main.PK.ui.PKMatchDlg")
  pkMatchDlg.Instance():ShowDlg()
end
function ClientCmd.showcgui(cmds)
  local ForceGuide = require("Main.Guide.ui.ForceGuide")
  ForceGuide.ShowForceGuide(1, nil)
end
function ClientCmd.huanyue(cmds)
  require("Main.PhantomCave.WatchAndGuessMgr").onReceiveModelInfo(nil)
end
function ClientCmd.keju(cmds)
  local ExamChoiceDlg = require("Main.Keju.ui.ExamChoiceDlg")
  require("Main.Keju.KejuModule").Instance():ShowKejuPanel()
end
function ClientCmd.toast(cmds)
  local count = 0
  GameUtil.AddGlobalTimer(0, false, function()
    count = count + 1
    Toast(string.format("\232\191\153\230\152\175\231\172\172%d\230\157\161", count))
  end)
end
function ClientCmd.announcement(cmds)
  local choice = 4
  if choice == 1 then
    require("GUI.AnnouncementTip").Announce("[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}")
  elseif choice == 2 then
    require("GUI.AnnouncementTip").Announce("\232\191\153\230\152\175\228\184\128\229\143\165\229\190\136\233\149\191\231\154\132\232\182\179\228\187\165\232\182\133\232\191\135\228\184\128\232\161\140\230\152\190\231\164\186\233\153\144\229\136\182\231\154\132\230\150\135\230\156\172,\229\166\130\230\158\156\230\156\137\228\184\164\232\161\140,\229\136\153\232\131\140\230\153\175\228\185\159\232\183\159\231\157\128\229\143\152\229\140\150,\229\185\182\228\184\148\228\184\128\228\184\139\228\184\128\232\161\140\230\150\135\230\156\172,\228\188\154\230\153\154\228\184\128\232\161\140\229\135\186\231\142\176,\228\184\141\231\159\165\233\129\147\232\191\153\228\185\136\229\164\154\229\164\159\228\184\141\229\164\159\229\149\138")
  elseif choice == 3 then
    require("GUI.AnnouncementTip").Announce("\232\191\153\230\152\175\228\184\128\229\143\165\229\190\136\233\149\191\231\154\132\232\182\179\228\187\165\232\182\133\232\191\135\228\184\128\232\161\140\230\152\190\231\164\186\233\153\144\229\136\182\231\154\132\230\150\135\230\156\172,\229\166\130\230\158\156\230\156\137\228\184\164\232\161\140,\229\136\153\232\131\140\230\153\175\228\185\159\232\183\159\231\157\128\229\143\152\229\140\150,\229\185\182\228\184\148\228\184\128\228\184\139\228\184\128\232\161\140\230\150\135\230\156\172,\228\188\154\230\153\154\228\184\128\232\161\140\229\135\186\231\142\176,\228\184\141\231\159\165\233\129\147\232\191\153\228\185\136\229\164\154\229\164\159\228\184\141\229\164\159\229\149\138\232\191\153\230\152\175\228\184\128\229\143\165\229\190\136\233\149\191\231\154\132\232\182\179\228\187\165\232\182\133\232\191\135\228\184\128\232\161\140\230\152\190\231\164\186\233\153\144\229\136\182\231\154\132\230\150\135\230\156\172,\229\166\130\230\158\156\230\156\137\228\184\164\232\161\140,\229\136\153\232\131\140\230\153\175\228\185\159\232\183\159\231\157\128\229\143\152\229\140\150,\229\185\182\228\184\148\228\184\128\228\184\139\228\184\128\232\161\140\230\150\135\230\156\172,\228\188\154\230\153\154\228\184\128\232\161\140\229\135\186\231\142\176,\228\184\141\231\159\165\233\129\147\232\191\153\228\185\136\229\164\154\229\164\159\228\184\141\229\164\159\229\149\138")
  elseif choice == 4 then
    require("GUI.AnnouncementTip").Announce("[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}")
  end
end
function ClientCmd.specialannounce(cmds)
  require("GUI.InteractiveAnnouncementTip").AnnounceWithModuleId("[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}[00ff00]\228\184\128\230\174\181{e:0222}\231\159\173\230\150\135{e:0225}\230\156\172[-]\229\147\136{e:0220}\229\147\136{e:0219}\229\147\136\229\147\136{e:0218}\229\147\136\229\149\138\229\147\136\229\147\136{e:0221}", 1)
end
function ClientCmd.rare(cmds)
  require("GUI.RareItemAnnouncementTip").AnnounceRareItem("{e:0222}\228\184\139\233\157\162\229\188\128\229\167\139\233\162\129\229\143\145\229\165\150\229\138\177")
  local roleId = Int64.new(0)
  local roleName = "\229\176\143\228\186\140\233\187\145"
  local itemid2count = {}
  itemid2count[213200201] = 1
  itemid2count[211000014] = 1
  local AnnouncementModule = require("Main.Announcement.AnnouncementModule")
  AnnouncementModule.onSBrocastShengXiaoItem(require("netio.protocol.mzm.gsp.activity.SBrocastShengXiaoItem").new(roleId, roleName, itemid2count))
  require("Main.PK.PKModule").OnSGainPreciousItemsBrd(require("netio.protocol.mzm.gsp.arena.SGainPreciousItemsBrd").new(roleId, roleName, itemid2count))
  require("Main.Gang.GangBattleMgr").OnSGainPreciousItemsBrd(require("netio.protocol.mzm.gsp.competition.SGainPreciousItemsBrd").new(roleId, roleName, "\233\165\186\229\173\144\233\151\168", itemid2count))
  require("Main.PVP.LeaderBattleModule").OnSGainPreciousItemsBrd(require("netio.protocol.mzm.gsp.menpaipvp.SGainPreciousItemsBrd").new(roleId, roleName, itemid2count))
  AnnouncementModule.onSBrocastYaoShouItem(require("netio.protocol.mzm.gsp.activity.SBrocastYaoShouItem").new(roleId, roleName, itemid2count))
  require("Main.PhantomCave.PhantomCaveModule").OnSGainPreciousItemBrd(require("netio.protocol.mzm.gsp.paraselene.SGainPreciousItemBrd").new(roleName, itemid2count))
  require("Main.Qimai.QimaiModule").OnSBrocastQMHWItem(require("netio.protocol.mzm.gsp.qmhw.SBrocastQMHWItem").new(roleId, roleName, itemid2count))
  local jiuxiao = require("netio.protocol.mzm.gsp.jiuxiao.SJiuXiaoPreciousItemBrd").new()
  jiuxiao.roleName = roleName
  jiuxiao.item2Num = itemid2count
  jiuxiao.npcid = 0
  jiuxiao.activityid = 0
  require("Main.activity.JueZhanJiuXiao.JZJXMgr")._SJiuXiaoPreciousItemBrd(jiuxiao)
  local ParamType = require("netio.protocol.mzm.gsp.bulletin.BulletinParamKey")
  local params = {}
  params[ParamType.ROLE_NAME1] = "\229\176\143\228\186\140\233\187\145"
  params[ParamType.LOTTERY_ID] = "212900000"
  params[ParamType.BAOTU_ID] = "210110002"
  params[ParamType.ITEM_ID] = "213200201"
  params[ParamType.ITEM_NUM] = "1"
  AnnouncementModule.onMibaoGetAward(params)
  AnnouncementModule.onLotteryAwardItem(params)
  AnnouncementModule.onBaoTuAwardItem(params)
  AnnouncementModule.onOnlineBoxAward(params)
end
function ClientCmd.gonglue(cmds)
  Event.DispatchEvent(ModuleId.GONGLUE, gmodule.notifyId.Gonglue.ViewGonglue, {""})
end
function ClientCmd.wordquestion(cmds)
  local ExamDlg = require("Main.Keju.ui.ExamDlg")
  ExamDlg.QuizeInTime(350600156, "test", nil, 5, 2, 3, 10, function(select)
    Toast("\231\173\148\233\162\152\230\181\139\232\175\149\233\128\137\230\139\169\228\186\134:" .. select)
  end)
end
function ClientCmd.test_xml(cmds)
  local SLAXML = require("Utility.SLAXML.slaxdom")
  local path = "D:/UZhuxian_New_Win/Output/Queen_Map.xml"
  local file = io.open(path)
  local xmlContent = file:read("*a")
  file:close()
  local xmlStr = xmlContent
  local getAttrValue = function(attrs, attrName)
    for i, v in ipairs(attrs) do
      if v.type == "attribute" and v.name == attrName then
        return v.value
      end
    end
    return nil
  end
  local dom = SLAXML:dom(xmlStr, {simple = true})
  for i, kid in ipairs(dom.root.kids) do
    if kid.type == "element" then
      for j, v in ipairs(kid.kids) do
        if v.type == "element" then
          for j2, v2 in ipairs(v.kids) do
            if v2.type == "element" then
              for j3, v3 in ipairs(v2.kids) do
                warn("v3 =", v2.name, v3.value)
              end
            end
          end
        end
      end
    end
  end
end
function ClientCmd.pintuwin(cmds)
  require("Main.PhantomCave.ui.PuzzlePanel").DebugWin()
end
function ClientCmd.paomadeng(cmds)
  require("GUI.ScrollNotice").Notice("[0000ff]\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157[-][00ff00]\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157[-]\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157[ff0000]\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157\228\184\128\229\143\165\232\175\157[-]")
end
function ClientCmd.lvup(cmds)
  local upLv = GetHeroProp().level + 1
  require("Main.ECGame").Instance():DebugString(".levelto " .. upLv)
end
function ClientCmd.sheep(cmds)
  local all = math.huge
  if #cmds > 1 then
    all = tonumber(cmds[2])
  end
  local num = 0
  local ChatConsts = require("netio.protocol.mzm.gsp.chat.ChatConsts")
  local ChatModule = require("Main.Chat.ChatModule")
  local tr = GameUtil.AddGlobalTimer(2, false, function()
    num = num + 1
    if num > all then
      GameUtil.RemoveGlobalTimer(tr)
    else
      ChatModule.Instance():SendChannelMsg(num .. "\229\143\170\231\187\181\231\190\138", ChatConsts.CHANNEL_WORLD, false)
    end
  end)
end
function ClientCmd.showtable(cmds)
  local count = DynamicDataTable.GetDynamicCount()
  warn("count = ", count)
end
function ClientCmd.zid(cmds)
  local network = require("netio.Network")
  warn("zonid :", network.m_zoneid)
end
function ClientCmd.showlockui(cmds)
  local lockUI = require("GUI.LockScreenUIPanel")
  lockUI.Instance():ShowPanel()
end
function ClientCmd.fightchannel(cmds)
  local ChatMsgData = require("Main.Chat.ChatMsgData")
  local ChatModule = require("Main.Chat.ChatModule")
  local HtmlHelper = require("Main.Chat.HtmlHelper")
  ChatModule.Instance():SendSystemMsg(ChatMsgData.System.FIGHT, HtmlHelper.Style.Fight, {
    content = "\230\136\152\230\150\151\229\144\167!\229\176\145\229\185\180!"
  })
end
function ClientCmd.isinblock(cmds)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local curX = heroModule.myRole.m_node2d.localPosition.x
  local curY = heroModule.myRole.m_node2d.localPosition.y
  warn("isinblock", gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curX, curY)
  if MapScene.IsBarrierXY(gmodule.moduleMgr:GetModule(ModuleId.MAP).scene, curX, curY) then
    Toast("Bad Point")
  end
end
function ClientCmd.dye(cmds)
  local data = require("Main.Dyeing.data.DyeData").Instance()
  warn("Index:", data.m_CurIndex, "ID:", data.m_CurID, "Count:", data.m_CurCount)
end
function ClientCmd.msdkinfo(cmds)
  local ECMSDK = require("ProxySDK.ECMSDK")
  local info = ECMSDK.GetMSDKInfo()
  for k, v in pairs(info) do
    warn(k, "  ", v)
  end
end
function ClientCmd.fly(cmds)
  Event.DispatchEvent(ModuleId.MAINUI, gmodule.notifyId.MainUI.BTN_FLY_CLICK, nil)
end
function ClientCmd.flydown(cmds)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.myRole:FlyDown(nil)
end
function ClientCmd.flyup(cmds)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.myRole:FlyUp(nil)
end
function ClientCmd.flyat(cmds)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  heroModule.myRole:ResetFly()
end
function ClientCmd.openurl(cmds)
  if cmds[2] then
    require("Main.ECGame").Instance():OpenUrl(cmds[2])
  end
end
function ClientCmd.stopmove(cmds)
  gmodule.moduleMgr:GetModule(ModuleId.HERO):Stop()
end
function ClientCmd.newfunction(cmds)
  if #cmds > 1 then
    local newfuntionid = tonumber(cmds[2])
    warn("NewFunction Call", Time.frameCount)
    require("Main.Guide.ui.NewFunction").ShowNewFunction(newfuntionid, function()
      require("Main.Guide.ui.NewFunction").Close()
      warn("NewFunction End", Time.frameCount)
    end)
  end
end
function ClientCmd.ProcessBatchCommand(fileName)
  local folder = GameUtil.GetAssetsPath()
  local batchCmdFilePah = folder .. "/BatchCommand/" .. fileName
  local file, err = io.open(batchCmdFilePah, "r")
  if file == nil then
    warn(string.format("batch file [%s] not exist", batchCmdFilePah))
    return false
  end
  warn("\230\137\167\232\161\140\230\140\135\228\187\164\230\150\135\228\187\182\239\188\154" .. batchCmdFilePah)
  for cmd in file:lines() do
    cmd = string.trim(cmd)
    if string.find(cmd, "#") ~= 1 and string.len(cmd) ~= 0 and not require("Main.ECGame").Instance():DebugString(cmd) then
      warn(string.format("batch file [%s] has bad cmd: %s", fileName, cmd))
    end
  end
  file:close()
  return true
end
function ClientCmd.batch(cmds)
  if #cmds < 2 then
    warn("need file path")
  else
    for i = 2, #cmds do
      if not ClientCmd.ProcessBatchCommand(cmds[i]) then
        break
      end
    end
  end
end
function ClientCmd.loadingp(cmds)
  local LoadingMgr = require("Main.Common.LoadingMgr")
  local progrosses = LoadingMgr.Instance():GetAllTaskProgresses()
  if progrosses then
    warn(string.format("[Loading Progrosses] loadingType=%d", LoadingMgr.Instance().loadingType))
    for k, v in pairs(progrosses) do
      warn(string.format("type=%d, val=%f", k, v))
    end
  else
    warn("not loading")
  end
end
function ClientCmd.wqtips(cmds)
  require("Main.WorldQuestion.WorldQuestionModule").OnSQuestionIsComingNotice({})
end
function ClientCmd.wqstart(cmds)
  require("Main.WorldQuestion.WorldQuestionModule").OnSQuestionContext({questionId = 359600000})
end
function ClientCmd.wqcorrect(cmds)
  local items = {}
  items[210104001] = 1
  local award = require("netio.protocol.mzm.gsp.activity.STopNGetNBAward").new(1, 1, "\229\176\143\228\186\140\233\187\145", items)
  require("Main.WorldQuestion.WorldQuestionModule").OnCorrectAnswer(award)
end
function ClientCmd.wqfail(cmds)
  require("Main.WorldQuestion.WorldQuestionModule").PublishWorldQuestionFailResult()
end
function ClientCmd.wqsuccess(cmds)
  local awards = {}
  for i = 1, 1 do
    local items = {}
    items[210104001] = 1
    local award = require("netio.protocol.mzm.gsp.activity.RoleAwardData").new(1, string.format("\229\176\143%d\233\187\145", i), items)
    table.insert(awards, award)
  end
  require("Main.WorldQuestion.WorldQuestionModule").PublishWorldQuestionResult({nbAwardInfo = awards})
end
function ClientCmd.watchmoon(cmds)
  require("Main.activity.WatchMoon.WatchMoonMgr").Instance():ShowWatchMoonList()
end
function ClientCmd.timer(cmds)
  require("Main.activity.ui.ActivityCountDown").Instance():StartActivityTimerWithCallback("\232\183\157\231\166\187\230\180\187\229\138\168\231\187\147\230\157\159", 50, function()
    warn("aaa")
  end)
end
function ClientCmd.timerdestroy(cmds)
  require("Main.activity.ui.ActivityCountDown").Instance():DestroyPanel()
end
function ClientCmd.shitu(cmds)
  local ShiTuRoleInfo = require("netio.protocol.mzm.gsp.shitu.ShiTuRoleInfo")
  local master = ShiTuRoleInfo.new(Int64.new(1), "\229\176\143\228\186\140\233\187\145", 1, 1)
  require("Main.Shitu.ShituModule").OnSyncShiTuInfo(require("netio.protocol.mzm.gsp.shitu.SSyncShiTuInfo").new(master, {}, 0, {}, 0, 0))
end
function ClientCmd.tudi(cmds)
  require("Main.Shitu.ShituModule").OnReceiveChuShiApprenticeList(require("netio.protocol.mzm.gsp.shitu.SGetChuShiApprenticeSuccess").new({}))
end
function ClientCmd.shoutu(cmds)
  require("Main.Shitu.ShituModule").OnStartShoutu(require("netio.protocol.mzm.gsp.shitu.SShouTuSuccess").new(0, "\230\136\145\230\152\175\232\176\129", 1))
end
function ClientCmd.qingan(cmds)
  require("Main.Shitu.ShituModule").OnReceiveQingAn(require("netio.protocol.mzm.gsp.shitu.SApprenticePayRespect").new("\228\189\160\229\165\189\229\149\138", Int64.new(1)))
end
function ClientCmd.weddingend(cmds)
  Event.DispatchEvent(ModuleId.MARRIAGE, gmodule.notifyId.Marriage.WeddingEnd, {101, 202})
end
function ClientCmd.weddingtour(cmds)
  local role1Info = require("netio.protocol.mzm.gsp.marriage.RoleInfo").new(Int64.new(0), "\229\188\160\229\176\143\229\135\161")
  local role2Info = require("netio.protocol.mzm.gsp.marriage.RoleInfo").new(Int64.new(1), "\231\162\167\231\145\182")
  local awardBean = require("netio.protocol.mzm.gsp.award.AwardBean").new(Int64.new(1), Int64.new(1), Int64.new(1), 1, 1, {}, {}, {}, {}, {})
  require("Main.WeddingTour.WeddingTourModule").OnBrocastStartParade(require("netio.protocol.mzm.gsp.marriage.SBrocastStartParade").new(role1Info, role2Info))
  require("Main.WeddingTour.WeddingTourModule").OnBrocastPauseParade(require("netio.protocol.mzm.gsp.marriage.SBrocastPauseParade").new(role1Info, role2Info))
  require("Main.WeddingTour.WeddingTourModule").OnBrocastEndParade(require("netio.protocol.mzm.gsp.marriage.SBrocastEndParade").new(role1Info, role2Info))
  require("Main.WeddingTour.WeddingTourModule").OnMarrigeParadeGetMoney(require("netio.protocol.mzm.gsp.marriage.SMarrigeParadeGetMoney").new(awardBean, role1Info, role2Info))
end
function ClientCmd.cp(cmds)
  local CoupleDailyNormalResult = require("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyNormalResult")
  local coupleArgs = {"\229\176\143\228\186\140\233\187\145"}
  local taskList = {
    356700000,
    356700001,
    356700002
  }
  local finishList = {}
  local BiYiLianZhiModule = require("Main.BiYiLianZhi.BiYiLianZhiModule")
  BiYiLianZhiModule.OnCheckConditionResult(require("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyNormalResult").new(CoupleDailyNormalResult.ACTIVITY_DONE_REFORE))
  BiYiLianZhiModule.OnCheckConditionResult(require("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyNormalResult").new(CoupleDailyNormalResult.PARTNER_ACTIVITY_DONE_REFORE, coupleArgs))
  BiYiLianZhiModule.OnShowActivityTasks(require("netio.protocol.mzm.gsp.coupledaily.SGetCoupleDailyInfo").new(taskList, finishList))
end
function ClientCmd.cpquiz(cmds)
  local CoupleDailyConst = require("netio.protocol.mzm.gsp.coupledaily.CoupleDailyConst")
  local BiYiLianZhiModule = require("Main.BiYiLianZhi.BiYiLianZhiModule")
  GameUtil.AddGlobalTimer(0, true, function()
    BiYiLianZhiModule.OnStartXinYouLingXiTask(require("netio.protocol.mzm.gsp.coupledaily.SXinYouLingXiStart").new())
  end)
  GameUtil.AddGlobalTimer(2, true, function()
    BiYiLianZhiModule.OnAgreeOrRefuseXinYouLingXi(require("netio.protocol.mzm.gsp.coupledaily.SAgreeOrRefuseXinYouLingXi").new(CoupleDailyConst.AGREE, Int64.new(100), "\229\176\143\228\186\140\233\187\145"))
  end)
  local questionId = {
    356800001,
    356800002,
    356800003
  }
  for i = 1, 3 do
    do
      local startTime = (i - 1) * 5 + 3
      GameUtil.AddGlobalTimer(startTime, true, function()
        BiYiLianZhiModule.OnXinYouLingXiQuestionInfo(require("netio.protocol.mzm.gsp.coupledaily.SXinYouLingXiQuestionInfo").new(questionId[i]))
      end)
      GameUtil.AddGlobalTimer(startTime + 4, true, function()
        BiYiLianZhiModule.OnAnswerXinYouLingXiResult(require("netio.protocol.mzm.gsp.coupledaily.SAnswerXinYouLingXiResult").new(true))
      end)
    end
  end
  GameUtil.AddGlobalTimer(19, true, function()
    local taskList = {
      356700000,
      356700001,
      356700002
    }
    local finishList = {
      356700000,
      356700001,
      356700002
    }
    BiYiLianZhiModule.OnRefreshCoupleDailyInfo(require("netio.protocol.mzm.gsp.coupledaily.SRefreshCoupleDailyInfo").new(taskList, finishList))
  end)
end
function ClientCmd.cppintu(cmds)
  local BiYiLianZhiModule = require("Main.BiYiLianZhi.BiYiLianZhiModule")
  local CoupleDailyConst = require("netio.protocol.mzm.gsp.coupledaily.CoupleDailyConst")
  BiYiLianZhiModule.OnCoupleDailyPinTuStart(require("netio.protocol.mzm.gsp.coupledaily.SCoupleDailyPinTuStart").new(100))
  GameUtil.AddGlobalTimer(2, true, function()
    BiYiLianZhiModule.OnAgreeOrRefusePinTu(require("netio.protocol.mzm.gsp.coupledaily.SAgreeOrRefusePinTu").new(CoupleDailyConst.REFUSE, Int64.new(100), "\229\176\143\228\186\140\233\187\145"))
  end)
end
function ClientCmd.cpend(cmds)
  local p = require("netio.protocol.mzm.gsp.activity.SynActivityEnd").new(constant.CoupleDailyActivityConst.COUPLE_DAILY_ACTIVITY_ID)
  local protocols = require("Main.activity.ActivityProtocols")
  protocols.OnSynActivityEnd(p)
end
function ClientCmd.wb1(cmds)
  require("Main.WorldBoss.ui.WorldBossDamagePanel").Instance():ShowDamage(0, 0, 0)
end
function ClientCmd.wb2(cmds)
  require("Main.WorldBoss.ui.WorldBossDamageCountPanel").Instance():ShowDamageCount(0, 0, 0)
end
function ClientCmd.paidui(cmds)
  GameUtil.AddGlobalTimer(1, false, function()
    require("GUI.AnnouncementTip").Announce("\230\136\145\230\152\175\230\173\163\229\184\184\230\142\146\233\152\159\231\154\132\239\188\140\233\132\153\232\167\134\230\143\146\233\152\159\231\154\132\239\188\129\239\188\129")
  end)
end
function ClientCmd.chadui(cmds)
  require("GUI.AnnouncementTip").AnnounceWithPriority("[ff0000]\230\136\145\230\143\146\233\152\159\230\136\145\233\170\132\229\130\178[-]", 0)
end
function ClientCmd.questiontest(cmds)
  local questionId = tonumber(cmds[2]) or 358600000
  if math.floor(questionId / 100000) == 3586 or math.floor(questionId / 100000) == 3587 then
    require("Main.Question.ui.EveryNightQuestionPanel").FakeShowQuestion(questionId)
  elseif math.floor(questionId / 100000) == 3506 then
    do
      local ExamDlg = require("Main.Keju.ui.ExamDlg")
      ExamDlg.QuizeInTime(questionId, "test", nil, 5, 2, 5, 10, function(select)
        GameUtil.AddGlobalTimer(0.5, true, function()
          ExamDlg.Close()
        end)
      end)
    end
  end
end
function ClientCmd.zxqy(cmds)
  local questionId = tonumber(cmds[2])
  local pageIndex = tonumber(cmds[3])
  require("Main.Question.QuestionModule").Instance():TextZXQY(questionId, pageIndex)
end
function ClientCmd.quicklaunch(cmds)
  local key = cmds[2] or ""
  require("Main.ECGame").Instance():Pause(true)
  require("Main.ECGame").Instance():SetShortcutMenuKey(key)
  require("Main.ECGame").Instance():Pause(false)
end
function ClientCmd.activity_tdbk(cmds)
  require("Main.activity.TianDiBaoKu.ui.TianDiBaoKuPanel").Instance():ShowPanel()
end
function ClientCmd.closedaygift(cmds)
  Event.DispatchEvent(ModuleId.ACTIVITY, gmodule.notifyId.activity.Activity_Close, {350000205})
end
function ClientCmd.idippet1(cmds)
  local petList = {}
  for i = 1, 3 do
    table.insert(petList, 130100005 + i * 2)
  end
  require("Main.Pet.PetModule").OnSSyncBanPetList(require("netio.protocol.mzm.gsp.pet.SSyncBanPetList").new(petList))
end
function ClientCmd.idippet2(cmds)
  local petList = {}
  require("Main.Pet.PetModule").OnSSyncBanPetList(require("netio.protocol.mzm.gsp.pet.SSyncBanPetList").new(petList))
end
function ClientCmd.sensitive_words(cmds)
  local mode = cmds[2]
  if mode == "off" then
    _G.not_filter_sensitive_words = true
    Toast("\229\133\179\233\151\173\229\174\162\230\136\183\231\171\175\233\147\173\230\132\159\232\175\141\232\191\135\230\187\164")
  else
    _G.not_filter_sensitive_words = false
    Toast("\229\188\128\229\144\175\229\174\162\230\136\183\231\171\175\233\147\173\230\132\159\232\175\141\232\191\135\230\187\164")
  end
end
function ClientCmd.reset6(cmds)
  local LuaPlayerPrefs = require("Main.Common.LuaPlayerPrefs")
  LuaPlayerPrefs.SetGlobalInt("PAYTIP", 1)
  LuaPlayerPrefs.Save()
end
function ClientCmd.flytest(cmds)
  local heroModule = gmodule.moduleMgr:GetModule(ModuleId.HERO)
  local role = heroModule.myRole
  local times = tonumber(cmds[2]) or 8
  local interval = tonumber(cmds[3]) or 0.5
  local count = 0
  local timerId = 0
  timerId = GameUtil.AddGlobalTimer(interval, false, function()
    count = count + 1
    local r = math.random(3)
    if r == 1 then
      role:ResetFly()
      warn("flyat")
    elseif r == 2 then
      role:FlyUp(nil)
      warn("flyup")
    elseif r == 3 then
      role:FlyDown(nil)
      warn("flydown")
    end
    if count >= times then
      GameUtil.RemoveGlobalTimer(timerId)
    end
  end)
end
function ClientCmd.client_date(cmds)
  local date = cmds[2]
  if date == nil then
    if _G.IsEnteredWorld() then
      local curTime = _G.GetServerTime()
      local AbsoluteTimer = require("Main.Common.AbsoluteTimer")
      local t = AbsoluteTimer.GetServerTimeTable(curTime)
      Toast(string.format("%d/%d/%d %d:%d:%d", t.year, t.month, t.day, t.hour, t.min, t.sec))
    else
      Toast("client_date yyyymmddhhMMss")
    end
  else
    local t = {}
    t.year = tonumber(string.sub(date, 1, 4))
    t.month = tonumber(string.sub(date, 5, 6))
    t.day = tonumber(string.sub(date, 7, 8))
    t.hour = tonumber(string.sub(date, 9, 10))
    t.min = tonumber(string.sub(date, 11, 12))
    t.sec = tonumber(string.sub(date, 13, -1))
    local timestamp = os.time(t)
    _G._debug_server_time = timestamp
    Toast("set client_date success, relogin to take effect")
  end
end
function ClientCmd.client_date_offset(cmds)
  local offset = tonumber(cmds[2])
  if offset == nil then
    offset = gmodule.moduleMgr:GetModule(ModuleId.SERVER):GetDebugTimeOffset()
    Toast("client_date_offset = " .. offset)
  else
    gmodule.moduleMgr:GetModule(ModuleId.SERVER):SetDebugTimeOffset(offset)
    Toast(string.format("set client_date_offset=%d success, relogin to take effect", offset))
  end
end
function ClientCmd.mounts(cmds)
  local mountsList = {}
  for i = 1, 6 do
    local id = Int64.new(i)
    local skills = {}
    for i = 1, 2 do
      local skill = require("netio.protocol.mzm.gsp.mounts.PassiveSkillInfo").new(110662610 + i, 0)
      table.insert(skills, skill)
    end
    local mounts = require("netio.protocol.mzm.gsp.mounts.MountsInfo").new(920100000 + i % 2, 2, 0, skills, Int64.new(-1), 0, 0)
    mountsList[id] = mounts
  end
  local battleMounts = {}
  for i = 1, 3 do
    local id = Int64.new(i)
    local mounts = require("netio.protocol.mzm.gsp.mounts.BattleMountsInfo").new(id, i == 2, {})
    battleMounts[i] = mounts
  end
  local resp = require("netio.protocol.mzm.gsp.mounts.SSyncMountsInfo").new(mountsList, battleMounts, Int64.new(1))
  require("Main.Mounts.MountsModule").OnSSyncMountsInfo(resp)
end
function ClientCmd.mountsrank(cmds)
  require("Main.Mounts.ui.MountsUpgradePanel").ShowPanel(require("Main.Mounts.mgr.MountsMgr").Instance():GetCurRideMountsId())
end
function ClientCmd.operatex(cmds)
  local operateId = tonumber(cmds[2])
  if operateId then
    Toast(string.format("operatex %d", operateId))
    local params = {}
    for i = 3, #cmds do
      table.insert(params, cmds[i])
    end
    require("Main.Grow.GrowUtils").ApplyOperationWithParams(operateId, params)
  end
end
function ClientCmd.tasktalk(cmds)
  local TaskTalk = function()
    local npcTalk = require("Main.task.ui.TaskTalk").Instance()
    npcTalk:SetTouchable(true)
    npcTalk:SetNPCID(150100253)
    npcTalk:SetText("\231\140\157\228\184\141\229\143\138\233\152\178\231\154\132\229\142\139\229\177\143\229\175\185\232\175\157")
    npcTalk:ShowDlg()
  end
  local EndTaskTalk = function()
    local npcTalk = require("Main.task.ui.TaskTalk").Instance()
    npcTalk:HideDlg()
  end
  GameUtil.AddGlobalTimer(4, true, TaskTalk)
  GameUtil.AddGlobalTimer(8, true, EndTaskTalk)
end
function ClientCmd.ridemounts(cmds)
  local mountsMgr = require("Main.Mounts.mgr.MountsMgr").Instance()
  local hasMounts = mountsMgr:GetSortedMountsList()
  if hasMounts ~= nil and #hasMounts > 0 then
    local curRideMountsId = mountsMgr:GetCurRideMountsId()
    local randomIndex = math.random(#hasMounts)
    while true do
      if curRideMountsId == nil or hasMounts[randomIndex].mounts_id ~= nil and not Int64.eq(curRideMountsId, hasMounts[randomIndex].mounts_id) then
        break
      end
      randomIndex = math.random(#hasMounts)
    end
    mountsMgr:RideMounts(hasMounts[randomIndex].mounts_id)
  else
    Toast("\229\189\147\229\137\141\230\151\160\229\157\144\233\170\145")
  end
end
function ClientCmd.unridemounts(cmds)
  require("Main.Mounts.mgr.MountsMgr").Instance():UnRideMounts()
end
function ClientCmd.noauthclogin(cmds)
  local isOn = tonumber(cmds[2]) ~= 0
  if isOn then
    gmodule.moduleMgr:GetModule(ModuleId.LOGIN):SetLoginNoAuthc(true)
    Toast("No authc login mode turn on")
  else
    gmodule.moduleMgr:GetModule(ModuleId.LOGIN):SetLoginNoAuthc(false)
    Toast("No authc login mode turn off")
  end
end
function ClientCmd.random(cmds)
  local seed = tonumber(cmds[2])
  local limit = tonumber(cmds[3])
  local length = tonumber(cmds[4])
  if seed and limit and length then
    warn("random", seed, limit, length)
    local randomer = require("Common.ServerRandomGenerator").make_srg(seed)
    local count = 0
    local rtimer
    local path = string.format("%s/random.log", Application.persistentDataPath)
    local fileHandle, errorMessage = io.open(path, "w")
    while true do
      count = count + 1
      if length < count then
        break
      end
      local r = randomer("int", limit)
      fileHandle:write(r)
      fileHandle:write("\n")
    end
    fileHandle:close()
  end
end
function ClientCmd.doudourandom(cmds)
  local sc = os.clock()
  local path = string.format("%s/doudou.log", Application.persistentDataPath)
  local fileHandle, errorMessage = io.open(path, "w")
  for i = 0, 99999 do
    local rettbl = require("Main.DoudouClear.DouDouClearUtils").GenDoudou(i, 15, 0, 0)
    local lines = {}
    for k, v in ipairs(rettbl) do
      table.insert(lines, v)
    end
    local linesStr = table.concat(lines, " ")
    fileHandle:write(linesStr)
    fileHandle:write("\n")
  end
  fileHandle:flush()
  fileHandle:close()
  local ec = os.clock()
  warn("CostTime:" .. ec - sc .. "'")
end
function ClientCmd.rd(cmds)
  local friendData = require("Main.RelationShipChain.RelationShipChainMgr").GetFriendData()
  for _, v in pairs(friendData) do
    local openid = GetStringFromOcts(v.openid)
    local ECMSDK = require("ProxySDK.ECMSDK")
    if ECMSDK.GetMSDKInfo().openId == GetStringFromOcts(v.openid) then
      warn(v.login_privilege, "~~~~~~~~~~~~~~~~~~~", GetStringFromOcts(v.openid))
    end
  end
end
function ClientCmd.listchildren(cmds)
  local children = require("Main.Children.ChildrenDataMgr").Instance():GetAllChildren()
  warn("Children>>>")
  for k, v in pairs(children or {}) do
    warn(k)
  end
  warn("<<<Children")
end
function ClientCmd.exitflower(cmds)
  require("Main.activity.WorldGoal.ValentineFlower.ValentineFlowerMgr").Instance():ExitFlowersActivity()
end
function ClientCmd.extractpetmodel(cmds)
  local PetMgr = require("Main.Pet.mgr.PetMgr")
  local petList = PetMgr.Instance():GetSortedPetList()
  if #petList == 0 then
    warn("no pet")
  else
    local usePet = petList[1]
    PetMgr.Instance():GetPetModelItemReq(usePet.id, true, 0)
  end
end
function ClientCmd.showhp(cmds)
  local mgr = require("Main.Fight.FightMgr").Instance()
  if mgr.fightUnits == nil then
    return
  end
  for k, v in pairs(mgr.fightUnits) do
    if v.model then
      v.model:SetHpVisible(true)
    end
  end
end
function ClientCmd.ShowFightInfo(cmds)
  local mgr = require("Main.Fight.Replayer").Instance()
  if not mgr.isInFight then
    mgr = require("Main.Fight.FightMgr").Instance()
  end
  if mgr.fightUnits == nil then
    return
  end
  for k, v in pairs(mgr.fightUnits) do
    warn(string.format("%s(pos:%d)  hp: %d/%d  mp: %d/%d ", v.name, v.pos, v.hp, v.hpmax, v.mp, v.mpmax))
  end
end
function ClientCmd.ClosePetFight(cmds)
  local dlg = require("Main.Fight.ui.DlgPetFight").Instance()
  dlg:StopCountDownToClose()
  dlg:UpdateClosingCountDown(0)
end
function ClientCmd.setregistermembernum(cmds)
  local num = tonumber(cmds[2])
  if num then
    constant.CrossBattleConsts.REGISTER_TEAM_MEMBER_LOWRT_LIMIT = num
    warn("----------set register member num success :", constant.CrossBattleConsts.REGISTER_TEAM_MEMBER_LOWRT_LIMIT)
  else
    warn("----set register error params")
  end
end
function ClientCmd.setroundrobinmembernum(cmds)
  local num = tonumber(cmds[2])
  if num then
    constant.CrossBattleConsts.ENTER_ROUND_ROBIN_MAP_TEAM_MEMBER_NUM = num
    warn(">>>>>>>>>set success curMember:", num)
  else
    warn("!!!!!!error params")
  end
end
function ClientCmd.onepersoncorps(cmds)
  constant.CorpsConsts.MIN_GUY_NUM = 1
  require("Main.ECGame").Instance():DebugString(".simplifycorpscreate 1")
end
function ClientCmd.playeff(cmds)
  local efftype = tonumber(cmds[2])
  local effId = tonumber(cmds[3])
  local effres = _G.GetEffectRes(effId)
  if effres == nil then
    warn("\230\137\190\228\184\141\229\136\176\231\137\185\230\149\136\233\133\141\231\189\174")
    return false
  end
  if efftype == 1 then
    do
      local fx = require("Fx.GUIFxMan").Instance():Play(effres.path, "test_ui_effect", 0, 0, -1, false)
      GameUtil.AddGlobalTimer(10, true, function()
        require("Fx.GUIFxMan").Instance():RemoveFx(fx)
      end)
    end
  elseif efftype == 2 then
    do
      local campos = require("Main.ECGame").Instance().m_2DWorldCamObj.localPosition
      local fx = require("Fx.ECFxMan").Instance():PlayEffectAt2DPos(effres.path, campos.x, campos.y)
      GameUtil.AddGlobalTimer(10, true, function()
        require("Fx.ECFxMan").Instance():Stop(fx)
      end)
    end
  elseif efftype == 3 then
    do
      local campos = require("Main.ECGame").Instance().m_2DWorldCamObj.localPosition
      local mapeffid = _G.MapEffect_RequireRes(campos.x, campos.y, 1, {
        effres.path
      })
      GameUtil.AddGlobalTimer(10, true, function()
        MapEffect_ReleaseRes(mapeffid)
      end)
    end
  else
    Toast("\233\148\153\232\175\175\231\154\132\231\137\185\230\149\136\231\177\187\229\158\139(1\228\184\186\229\177\143\229\185\149\231\137\185\230\149\136\239\188\1402\228\184\1863D\229\156\186\230\153\175\231\137\185\230\149\136\239\188\1403\228\184\186\229\156\176\229\155\190\231\137\185\230\149\136)")
    return false
  end
end
function ClientCmd.runcmds(cmds)
  local idx = tonumber(cmds[2])
  if idx then
    local GMText = require("textRes.GMText")
    local cmdList = GMText[idx]
    if cmdList then
      for i, v in ipairs(cmdList) do
        warn("-----runcmd:", v)
        require("Main.ECGame").Instance():DebugString(v)
      end
    else
      Toast(string.format("\230\156\170\229\174\154\228\185\137\231\154\132\230\140\135\228\187\164\231\180\162\229\188\149:%d", idx))
    end
  else
    Toast("\230\140\135\228\187\164\231\180\162\229\188\149\233\148\153\232\175\175")
  end
end
function ClientCmd.battlefieldgo(cmds)
  local choice = tonumber(cmds[2])
  local cbfMgr = require("Main.CrossBattlefield.CrossBattlefieldModule").Instance()
  if choice == 0 then
    cbfMgr:EnableClientCheck(true)
    Toast("CrossBattlefield::Client check turn on")
  else
    cbfMgr:EnableClientCheck(false)
    Toast("CrossBattlefield::Client check turn off")
  end
end
function ClientCmd.status(cmds)
  local roleid = cmds[2]
  if roleid == nil then
    roleid = gmodule.moduleMgr:GetModule(ModuleId.HERO).roleId:tostring()
  end
  local mydata = gmodule.moduleMgr:GetModule(ModuleId.PUBROLE).invisiblePlayers[roleid]
  Debug.LogWarning(string.format("role(%s) status(%d total):", mydata.modelInfo.string_props[0], #mydata.modelInfo.role_status_list))
  for k, v in pairs(mydata.modelInfo.role_status_list) do
    Debug.LogWarning(tostring(v))
  end
end
function ClientCmd.itemidipswitch(cmds)
  require("Main.IDIP.IDIPInterface").OutputItemIDIP()
end
function ClientCmd.enterspace(cmds)
  local roleId = cmds[2]
  if roleId then
    roleId = Int64.ParseString(roleId)
  else
    roleId = _G.GetMyRoleID()
  end
  gmodule.moduleMgr:GetModule(ModuleId.SOCIAL_SPACE):EnterSpace(roleId)
end
function ClientCmd.disconnect(cmds)
  require("netio.Authc").disConnect()
end
function ClientCmd.addallaircraft(cmds)
  local aircraftItemCfgs = require("Main.Aircraft.AircraftInterface").GetAllAircraftItemCfg()
  if aircraftItemCfgs then
    for itemId, cfg in pairs(aircraftItemCfgs) do
      gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.gm.CGMCommand").new("additem " .. itemId))
    end
  end
end
function ClientCmd.gmquery(cmds)
  local gmDlg = require("GUI.GMQueryDlg")
  gmDlg.Instance():ShowDlg()
end
function ClientCmd.SimplifyLadder(argv)
  local num = tonumber(argv[2]) or 1
  require("Main.CrossServer.CrossServerModule").TEAM_MEMBER_REQ = num
end
function ClientCmd.SetAsTGP(argv)
  local isTGP
  local state = tonumber(argv[2])
  if state == 1 then
    isTGP = true
  elseif state == 0 then
    isTGP = false
  else
    isTGP = nil
  end
  require("Utility.DeviceUtility").DebugSetAsTGP(isTGP)
end
function ClientCmd.init()
  ClientCmd.cmds = {}
  ClientCmd.Confidential = {}
  ClientCmd.cmds["@@"] = ClientCmd.Lua
  ClientCmd.cmds["@unload"] = ClientCmd.Unload
  ClientCmd.cmds["@donpc"] = ClientCmd.DoNPC
  ClientCmd.cmds["@testnpctalk"] = ClientCmd.testNPCTalk
  ClientCmd.cmds["@creategang"] = ClientCmd.CreateGang
  ClientCmd.cmds["@showganglistui"] = ClientCmd.ShowGangListUI
  ClientCmd.cmds["@queryganglist"] = ClientCmd.QueryGangList
  ClientCmd.cmds["@querymyganginfo"] = ClientCmd.QueryGangInfo
  ClientCmd.cmds["@querymymemberlist"] = ClientCmd.QueryMemberList
  ClientCmd.cmds["@showskillui"] = ClientCmd.ShowSkillUI
  ClientCmd.cmds["@showitemlistui"] = ClientCmd.ShowItemListUI
  ClientCmd.cmds["@showmatchtimeui"] = ClientCmd.ShowMatchTimeUI
  ClientCmd.cmds["@showgangui"] = ClientCmd.ShowGangUI
  ClientCmd.cmds["@testimgnum"] = ClientCmd.TestImgNum
  ClientCmd.cmds["@testgangmenu"] = ClientCmd.TestGangMenu
  ClientCmd.cmds["@testgangmailui"] = ClientCmd.TestGangMailUI
  ClientCmd.cmds["@enabletaskdebug"] = ClientCmd.EnabletaskDebug
  ClientCmd.cmds["@showactivitymain"] = ClientCmd.ShowActivityMain
  ClientCmd.cmds["@handin"] = ClientCmd.ShowSystemHandInFrame
  ClientCmd.cmds["@startquestion"] = ClientCmd.StartQuestion
  ClientCmd.cmds["@time"] = ClientCmd.SendTime
  ClientCmd.cmds["@debug"] = ClientCmd.ToggleDebug
  ClientCmd.cmds["@showtasktips"] = ClientCmd.ShowTaskTips
  ClientCmd.cmds["@showpetshop"] = ClientCmd.ShowPetShop
  ClientCmd.cmds["@rtt"] = ClientCmd.RefreshTaskTrace
  ClientCmd.cmds["@refreshactivity"] = ClientCmd.RefreshActivity
  ClientCmd.cmds["@searchitem"] = ClientCmd.SearchItem
  ClientCmd.cmds["@si"] = ClientCmd.SearchItem
  ClientCmd.cmds["@showawardui"] = ClientCmd.ShowAwardUI
  ClientCmd.cmds["@loadstory"] = ClientCmd.loadStory
  ClientCmd.cmds["@showdramaui"] = ClientCmd.ShowTaskDramaUI
  ClientCmd.cmds["@showttnpc"] = ClientCmd.ShowTaskTalkNPC
  ClientCmd.cmds["@newactivity"] = ClientCmd.NewActivity
  ClientCmd.cmds["@pse"] = ClientCmd.PlaySpecialEffect
  ClientCmd.cmds["@rmui"] = ClientCmd.RefreshMainUI
  ClientCmd.cmds["@tfitems"] = ClientCmd.FiltrateItems
  ClientCmd.cmds["@shownewpartner"] = ClientCmd.ShowPartnerNew
  ClientCmd.cmds["@mainui"] = ClientCmd.OperateMainUI
  ClientCmd.cmds["@showbounty"] = ClientCmd.ShowBounty
  ClientCmd.cmds["@ut"] = ClientCmd.UnitTest
  ClientCmd.cmds["@showworldboss"] = ClientCmd.ShowWorldBoss
  ClientCmd.cmds["@czhenyao"] = ClientCmd._OnSisContinueZhenyao
  ClientCmd.cmds["@ttime"] = ClientCmd._TTime
  ClientCmd.cmds["@tna"] = ClientCmd._testNewActivity
  ClientCmd.cmds["@tsu"] = ClientCmd._testShowUI
  ClientCmd.cmds["@tgn"] = ClientCmd._testGangNPC
  ClientCmd.cmds["@pfu"] = ClientCmd._testPartnerFirstUnivited
  ClientCmd.cmds["@pfj"] = ClientCmd._testPartnerFirstJoined
  ClientCmd.cmds["@donpctalk"] = ClientCmd.DoNpcTalkShow
  ClientCmd.cmds["@tsas"] = ClientCmd.testSendActivityStart
  ClientCmd.cmds["@tsae"] = ClientCmd.testSendActivityEnd
  ClientCmd.cmds["@guidopenstatus"] = ClientCmd.guidopenstatus
  ClientCmd.cmds["@setloglevel"] = ClientCmd.SetLogLevelNew
  ClientCmd.cmds["@setprotocolloglevel"] = ClientCmd.SetProtocolLogLevel
  ClientCmd.cmds["@outputtaskinfos"] = ClientCmd.OutputTaskInfos
  ClientCmd.cmds["@outputactivityinfos"] = ClientCmd.OutputActivityInfos
  ClientCmd.cmds["@zlopenurl"] = ClientCmd.ZLOpenUrl
  ClientCmd.cmds["@zhuanzhi"] = ClientCmd.ShowMultiOccupationDlg
  ClientCmd.cmds["@fight_info"] = ClientCmd.ShowFightInfo
  ClientCmd.cmds["@close_pet_fight"] = ClientCmd.ClosePetFight
  ClientCmd.cmds.script = ClientCmd.Lua
  ClientCmd.cmds.s = ClientCmd.Lua
  ClientCmd.cmds.prof = ClientCmd.prof
  ClientCmd.cmds.dumpmem = ClientCmd.dumpmem
  ClientCmd.cmds.snapshot = ClientCmd.snapshot
  ClientCmd.cmds.bigtable = ClientCmd.bigtable
  ClientCmd.cmds.reslog = ClientCmd.reslog
  ClientCmd.cmds.regtab = ClientCmd.regtab
  ClientCmd.cmds.stat = ClientCmd.stat
  ClientCmd.cmds.statf = ClientCmd.statf
  ClientCmd.cmds.formation = ClientCmd.formation
  ClientCmd.cmds.gfx = ClientCmd.gfx
  ClientCmd.cmds.noplayer = ClientCmd.noplayer
  ClientCmd.cmds.yuanbao = ClientCmd.yuanbao
  ClientCmd.cmds.wabao = ClientCmd.wabao
  ClientCmd.cmds.wings = ClientCmd.wings
  ClientCmd.cmds.kejustates = ClientCmd.kejustates
  ClientCmd.cmds.npcmodel = ClientCmd.npcmodel
  ClientCmd.cmds.talk = ClientCmd.talk
  ClientCmd.cmds.idipswitch = ClientCmd.idipswitch
  ClientCmd.cmds.fightitem = ClientCmd.fightitem
  ClientCmd.cmds.wtf = ClientCmd.wtf
  ClientCmd.cmds.lt = ClientCmd.lt
  ClientCmd.cmds.cgplay = ClientCmd.cgplay
  ClientCmd.cmds.win = ClientCmd.win
  ClientCmd.cmds.lose = ClientCmd.lose
  ClientCmd.cmds.guide = ClientCmd.guide
  ClientCmd.cmds.guidestep = ClientCmd.guidestep
  ClientCmd.cmds.choosepet = ClientCmd.choosepet
  ClientCmd.cmds.ghosteffect = ClientCmd.ghosteffect
  ClientCmd.cmds.syncgc = ClientCmd.syncgc
  ClientCmd.cmds.fx_test = ClientCmd.fx_test
  ClientCmd.cmds.stranger = ClientCmd.stranger
  ClientCmd.cmds.fixall = ClientCmd.fixall
  ClientCmd.cmds.questionstart = ClientCmd.questionstart
  ClientCmd.cmds.assetpath = ClientCmd.assetpath
  ClientCmd.cmds.speechon = ClientCmd.speechon
  ClientCmd.cmds.speechoff = ClientCmd.speechoff
  ClientCmd.cmds.id = ClientCmd.id
  ClientCmd.cmds.sworn = ClientCmd.sworn
  ClientCmd.cmds.speech = ClientCmd.speech
  ClientCmd.cmds.questionhelp = ClientCmd.questionhelp
  ClientCmd.cmds.netiorecord = ClientCmd.netiorecord
  ClientCmd.cmds.netiosave = ClientCmd.netiosave
  ClientCmd.cmds.netioplay = ClientCmd.netioplay
  ClientCmd.cmds.add = ClientCmd.add
  ClientCmd.cmds.resdelay = ClientCmd.resdelay
  ClientCmd.cmds.showpkui = ClientCmd.showpkui
  ClientCmd.cmds.showpkmatch = ClientCmd.showpkmatch
  ClientCmd.cmds.showcgui = ClientCmd.showcgui
  ClientCmd.cmds.huanyue = ClientCmd.huanyue
  ClientCmd.cmds.keju = ClientCmd.keju
  ClientCmd.cmds.toast = ClientCmd.toast
  ClientCmd.cmds.announcement = ClientCmd.announcement
  ClientCmd.cmds.specialannounce = ClientCmd.specialannounce
  ClientCmd.cmds.rare = ClientCmd.rare
  ClientCmd.cmds.gonglue = ClientCmd.gonglue
  ClientCmd.cmds.wordquestion = ClientCmd.wordquestion
  ClientCmd.cmds.test_xml = ClientCmd.test_xml
  ClientCmd.cmds.pintuwin = ClientCmd.pintuwin
  ClientCmd.cmds.paomadeng = ClientCmd.paomadeng
  ClientCmd.cmds.lvup = ClientCmd.lvup
  ClientCmd.cmds.sheep = ClientCmd.sheep
  ClientCmd.cmds.showtable = ClientCmd.showtable
  ClientCmd.cmds.showlockui = ClientCmd.showlockui
  ClientCmd.cmds.fightchannel = ClientCmd.fightchannel
  ClientCmd.cmds.isinblock = ClientCmd.isinblock
  ClientCmd.cmds.dye = ClientCmd.dye
  ClientCmd.cmds.msdkinfo = ClientCmd.msdkinfo
  ClientCmd.cmds.fly = ClientCmd.fly
  ClientCmd.cmds.flydown = ClientCmd.flydown
  ClientCmd.cmds.flyup = ClientCmd.flyup
  ClientCmd.cmds.flyat = ClientCmd.flyat
  ClientCmd.cmds.openurl = ClientCmd.openurl
  ClientCmd.cmds.stopmove = ClientCmd.stopmove
  ClientCmd.cmds.newfunction = ClientCmd.newfunction
  ClientCmd.cmds.batch = ClientCmd.batch
  ClientCmd.cmds.loadingp = ClientCmd.loadingp
  ClientCmd.cmds.wqtips = ClientCmd.wqtips
  ClientCmd.cmds.wqstart = ClientCmd.wqstart
  ClientCmd.cmds.wqcorrect = ClientCmd.wqcorrect
  ClientCmd.cmds.wqfail = ClientCmd.wqfail
  ClientCmd.cmds.wqsuccess = ClientCmd.wqsuccess
  ClientCmd.cmds.watchmoon = ClientCmd.watchmoon
  ClientCmd.cmds.timer = ClientCmd.timer
  ClientCmd.cmds.timerdestroy = ClientCmd.timerdestroy
  ClientCmd.cmds.shitu = ClientCmd.shitu
  ClientCmd.cmds.tudi = ClientCmd.tudi
  ClientCmd.cmds.shoutu = ClientCmd.shoutu
  ClientCmd.cmds.qingan = ClientCmd.qingan
  ClientCmd.cmds.weddingend = ClientCmd.weddingend
  ClientCmd.cmds.weddingtour = ClientCmd.weddingtour
  ClientCmd.cmds.cp = ClientCmd.cp
  ClientCmd.cmds.cpquiz = ClientCmd.cpquiz
  ClientCmd.cmds.cppintu = ClientCmd.cppintu
  ClientCmd.cmds.cpend = ClientCmd.cpend
  ClientCmd.cmds.wb1 = ClientCmd.wb1
  ClientCmd.cmds.wb2 = ClientCmd.wb2
  ClientCmd.cmds.paidui = ClientCmd.paidui
  ClientCmd.cmds.chadui = ClientCmd.chadui
  ClientCmd.cmds.questiontest = ClientCmd.questiontest
  ClientCmd.cmds.qt = ClientCmd.questiontest
  ClientCmd.cmds.zxqy = ClientCmd.zxqy
  ClientCmd.cmds.quicklaunch = ClientCmd.quicklaunch
  ClientCmd.cmds.activity_tdbk = ClientCmd.activity_tdbk
  ClientCmd.cmds.closedaygift = ClientCmd.closedaygift
  ClientCmd.cmds.idippet1 = ClientCmd.idippet1
  ClientCmd.cmds.idippet2 = ClientCmd.idippet2
  ClientCmd.cmds.sensitive_words = ClientCmd.sensitive_words
  ClientCmd.cmds.reset6 = ClientCmd.reset6
  ClientCmd.cmds.flytest = ClientCmd.flytest
  ClientCmd.cmds.client_date = ClientCmd.client_date
  ClientCmd.cmds.client_date_offset = ClientCmd.client_date_offset
  ClientCmd.cmds.mounts = ClientCmd.mounts
  ClientCmd.cmds.mountsrank = ClientCmd.mountsrank
  ClientCmd.cmds.operatex = ClientCmd.operatex
  ClientCmd.cmds.tasktalk = ClientCmd.tasktalk
  ClientCmd.cmds.ridemounts = ClientCmd.ridemounts
  ClientCmd.cmds.unridemounts = ClientCmd.unridemounts
  ClientCmd.cmds.noauthclogin = ClientCmd.noauthclogin
  ClientCmd.cmds.random = ClientCmd.random
  ClientCmd.cmds.doudourandom = ClientCmd.doudourandom
  ClientCmd.cmds.rd = ClientCmd.rd
  ClientCmd.cmds.listchildren = ClientCmd.listchildren
  ClientCmd.cmds.exitflower = ClientCmd.exitflower
  ClientCmd.cmds.extractpetmodel = ClientCmd.extractpetmodel
  ClientCmd.cmds.showhp = ClientCmd.showhp
  ClientCmd.cmds.setregistermembernum = ClientCmd.setregistermembernum
  ClientCmd.cmds.setroundrobinmembernum = ClientCmd.setroundrobinmembernum
  ClientCmd.cmds.onepersoncorps = ClientCmd.onepersoncorps
  ClientCmd.cmds.playeff = ClientCmd.playeff
  ClientCmd.cmds.runcmds = ClientCmd.runcmds
  ClientCmd.cmds.battlefieldgo = ClientCmd.battlefieldgo
  ClientCmd.cmds.status = ClientCmd.status
  ClientCmd.cmds.itemidipswitch = ClientCmd.itemidipswitch
  ClientCmd.cmds.enterspace = ClientCmd.enterspace
  ClientCmd.cmds.disconnect = ClientCmd.disconnect
  ClientCmd.cmds.addallaircraft = ClientCmd.addallaircraft
  ClientCmd.cmds.zid = ClientCmd.zid
  ClientCmd.cmds.gmquery = {
    func = ClientCmd.gmquery,
    params = {
      "param1_name(default)",
      "param2_name(default)"
    },
    desc = "this is cmdtype2 description for gmquery"
  }
  ClientCmd.Confidential.gmquery = true
  ClientCmd.cmds.setastgp = ClientCmd.SetAsTGP
  ClientCmd.ServerCmds = {}
  ClientCmd.ServerCmds[".simplifyladder"] = ClientCmd.SimplifyLadder
end
function ClientCmd.DoClientCmd(strCmd)
  local strs = string.split(strCmd, " ")
  local cmd = ClientCmd.cmds[strs[1]]
  if cmd == nil then
    return false
  end
  if not _G.IsGmOn and ClientCmd.Confidential[strs[1]] then
    return false
  end
  if type(cmd) == "table" then
    if cmd.func ~= nil then
      cmd.func(strs)
      return true
    else
      return false
    end
  elseif type(cmd) == "function" then
    cmd(strs)
    return true
  else
    return false
  end
end
function ClientCmd.DoServerCmd(strCmd)
  local strs = string.split(strCmd, " ")
  local func = ClientCmd.ServerCmds[strs[1]]
  if func == nil then
    return false
  end
  func(strs)
  return true
end
function ClientCmd.SearchCmd(word, isStrict)
  if word == nil then
    return nil
  end
  local content = {}
  if word == "" then
    for k, v in pairs(ClientCmd.cmds) do
      local tagTbl = {}
      if type(v) == "function" then
        tagTbl.name = k
      elseif type(v) == "table" then
        tagTbl = clone(v)
        tagTbl.name = k
      end
      content[#content + 1] = tagTbl
    end
    return content
  end
  if isStrict == nil then
    isStrict = true or isStrict
  end
  if isStrict then
    for k, v in pairs(ClientCmd.cmds) do
      if string.find(k, word, 1) == 1 then
        local tagTbl = {}
        if type(v) == "function" then
          tagTbl.name = k
        elseif type(v) == "table" then
          tagTbl = clone(v)
          tagTbl.name = k
        end
        content[#content + 1] = tagTbl
      end
    end
  else
    for k, v in pairs(ClientCmd.cmds) do
      if string.find(k, word, 1) then
        local tagTbl = {}
        if type(v) == "function" then
          tagTbl.name = k
        elseif type(v) == "table" then
          tagTbl = clone(v)
          tagTbl.name = k
        end
        content[#content + 1] = tagTbl
      elseif type(v) == "table" and v.desc ~= nil and string.find(v.desc, word, 1) then
        local tagTbl = clone(v)
        tagTbl.name = k
        content[#content + 1] = tagTbl
      end
    end
  end
  return content
end
ClientCmd.init()
return ClientCmd
