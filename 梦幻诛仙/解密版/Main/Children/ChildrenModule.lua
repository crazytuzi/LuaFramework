local Lplus = require("Lplus")
require("Main.module.ModuleId")
local ModuleBase = require("Main.module.ModuleBase")
local ChildrenModule = Lplus.Extend(ModuleBase, "ChildrenModule")
local BabyMgr = require("Main.Children.mgr.BabyMgr")
local ChildrenDataMgr = require("Main.Children.ChildrenDataMgr")
local ItemModule = require("Main.Item.ItemModule")
local GameUnitType = require("consts/mzm/gsp/common/confbean/GameUnitType")
local NPCServiceConst = require("Main.npc.NPCServiceConst")
local def = ChildrenModule.define
local instance
def.static("=>", ChildrenModule).Instance = function()
  if instance == nil then
    instance = ChildrenModule()
    instance.m_moduleId = ModuleId.CHILDREN
  end
  return instance
end
def.field("table").queryCallback = nil
def.field("table").locReqs = nil
def.override().Init = function(self)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SSyncChildrenInfo", ChildrenModule.OnSSyncChildrenInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SCarryChildSuccess", ChildrenModule.OnSCarryChildSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SMoveChildHomeSuccess", ChildrenModule.OnSMoveChildHomeSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildShowSuccess", ChildrenModule.OnSChildShowSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SCancelChildShowSuccess", ChildrenModule.OnSCancelChildShowSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChangeChildNameSuccess", ChildrenModule.OnSChangeChildNameSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SFreeChildSuccess", ChildrenModule.OnSFreeChildSuccess)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SRecallChildSuccess", ChildrenModule.OnSRecallChild)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SAddChild", ChildrenModule.OnSAddChild)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SQueryChildInfo", ChildrenModule.OnSQueryChildInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SGetChildLocationInfo", ChildrenModule.OnSGetChildLocationInfo)
  gmodule.network.registerProtocol("netio.protocol.mzm.gsp.Children.SChildNormalFail", ChildrenModule.OnSChildNormalFail)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.ENTER_WORLD, ChildrenModule.onEnterWorld)
  Event.RegisterEvent(ModuleId.LOGIN, gmodule.notifyId.Login.LEAVE_WORLD, ChildrenModule.onLeaveWorld)
  Event.RegisterEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.BABY_SLEEP_END, ChildrenModule.onBabySleepEnd)
  Event.RegisterEvent(ModuleId.FEATURE, gmodule.notifyId.Feature.FeatureOpenChange, ChildrenModule.OnFeatureOpenChange)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.SUMMON_PET, ChildrenModule.OnSummonChild)
  Event.RegisterEvent(ModuleId.FIGHT, gmodule.notifyId.Fight.LEAVE_FIGHT, ChildrenModule.OnLeaveFight)
  Event.RegisterEvent(ModuleId.NPC, gmodule.notifyId.NPC.NPC_SERVICE, ChildrenModule.OnAcceptNPCService)
  require("Main.Children.mgr.TeenMgr").Instance():Init()
  require("Main.Children.mgr.DeliveryMgr").Instance():Init()
  require("Main.Children.mgr.BabyMgr").Instance():Init()
  require("Main.Children.mgr.SongZiGuanYinMgr").Instance():Init()
  require("Main.Children.mgr.ChildrenFashionMgr").Instance():Init()
  require("Main.Children.mgr.GrowthMemoMgr").Instance():Init()
  require("Main.Children.mgr.YouthMgr").Instance():Init()
  require("Main.Children.mgr.RecallChildMgr").Instance():Init()
  ModuleBase.Init(self)
end
def.static("table").OnSSyncChildrenInfo = function(p)
  ChildrenDataMgr.Instance():Reset()
  local discardMap = {}
  for k, v in pairs(p.discard_child_map) do
    discardMap[k:tostring()] = v
  end
  for k, v in pairs(p.child_info_map) do
    if p.discard_child_map ~= nil and discardMap[k:tostring()] ~= nil then
      ChildrenDataMgr.Instance():AddDiscardChild(k, discardMap[k:tostring()])
      ChildrenDataMgr.Instance():AddDiscardContent(k, v)
    else
      ChildrenDataMgr.Instance():AddChild(k, v)
    end
  end
  ChildrenDataMgr.Instance():SetShowChildId(p.show_child_id, p.show_child_period or 1)
  for k, v in pairs(p.bag_child_id_list) do
    ChildrenDataMgr.Instance():AddBagChild(v)
  end
  if p.sync_type == p.DIVORCE or p.sync_type == p.MARRIAGE then
    Toast(textRes.Children[9])
  end
end
def.static("table", "table").OnAcceptNPCService = function(params)
  local serviceID = params[1]
  local npcID = params[2]
  if serviceID == NPCServiceConst.ChildrenWelfare then
    local ccDlg = require("Main.Children.ui.ChildrenWelfareDlg")
    ccDlg.Instance():ShowDlg()
  end
end
def.static("table").OnSCarryChildSuccess = function(p)
  local childId = p.child_id
  ChildrenDataMgr.Instance():AddBagChild(childId)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, nil)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local childName = child and child:GetName() or tostring(child)
  Toast(string.format(textRes.Children[4101], childName))
end
def.static("table").OnSMoveChildHomeSuccess = function(p)
  local childId = p.child_id
  ChildrenDataMgr.Instance():RemoveBagChild(childId)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, nil)
  if gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInCourtyardMap() then
    Toast(textRes.Children[21])
  else
    Toast(textRes.Children[22])
  end
end
def.static("table").OnSChildShowSuccess = function(p)
  local childId = p.child_id
  local period = p.child_period
  ChildrenDataMgr.Instance():SetShowChildId(childId, period)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Show_Update, nil)
  local child = ChildrenDataMgr.Instance():GetChildById(childId)
  local childName = child and child:GetName() or tostring(childId)
  local text = string.format(textRes.Children[4100], childName)
  Toast(text)
end
def.static("table").OnSCancelChildShowSuccess = function(p)
  local lastShowChildId = ChildrenDataMgr.Instance():GetShowChildId()
  ChildrenDataMgr.Instance():SetShowChildId(nil, 0)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Show_Update, nil)
  if lastShowChildId then
    local child = ChildrenDataMgr.Instance():GetChildById(lastShowChildId)
    local childName = child and child:GetName() or tostring(lastShowChildId)
    local text = string.format(textRes.Children[4101], childName)
    Toast(text)
  end
end
def.static("table").OnSChangeChildNameSuccess = function(p)
  local child = ChildrenDataMgr.Instance():GetChildById(p.child_id)
  if child then
    child:SetName(GetStringFromOcts(p.child_new_name))
  end
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Name_Update, {
    p.child_id
  })
  Toast(textRes.Children[10])
end
def.static("table").OnSFreeChildSuccess = function(p)
  ChildrenDataMgr.Instance():MoveToWelfare(p.child_id)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Update, nil)
  Toast(textRes.Children[4004])
end
def.static("table").OnSRecallChild = function(p)
  local childId = p.child_id
  local child = ChildrenDataMgr.Instance():GetDiscardContentById(childId)
  BabyMgr.Instance():PlayGetBabyEffect()
  Toast(string.format(textRes.Children[6001], child:GetName()))
  ChildrenDataMgr.Instance():MoveFromWelfare(childId)
end
def.static("table").OnSAddChild = function(p)
  ChildrenDataMgr.Instance():AddChild(p.child_id, p.child_info)
  Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Get_Baby, nil)
  Toast(string.format(textRes.Children[1039], GetStringFromOcts(p.child_info.child_name)))
end
def.static("table").OnSChildNormalFail = function(p)
  if IsCrossingServer() and p.result == p.ERROR_CHILDREN_NOT_EXIST then
    Toast(textRes.Children[36])
  elseif textRes.Children.SChildNormalFail[p.result] then
    Toast(textRes.Children.SChildNormalFail[p.result])
  end
end
def.static("table").OnSQueryChildInfo = function(p)
  local self = ChildrenModule.Instance()
  if self.queryCallback then
    local cbs = self.queryCallback[p.child_id:tostring()]
    if cbs then
      for k, v in ipairs(cbs) do
        v(p)
      end
      self.queryCallback[p.child_id:tostring()] = nil
    end
  end
end
def.static("table").OnSGetChildLocationInfo = function(p)
  local self = ChildrenModule.Instance()
  if self.locReqs then
    local cbs = self.locReqs[p.child_id:tostring()]
    if cbs then
      for i, v in ipairs(cbs) do
        v(p)
      end
      self.locReqs[p.child_id:tostring()] = nil
    end
  end
end
def.static("table", "table").OnSummonChild = function(p1, p2)
  if p1 ~= nil and p1.unit_type == GameUnitType.CHILDREN then
    local childId = p1.unit_id
    if ChildrenDataMgr.Instance():GetChildById(childId) then
      ChildrenDataMgr.Instance():SetInFightSceneChildId(childId)
      Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.In_Fight_Scene_Child_Change, nil)
    end
  end
end
def.static("table", "table").OnLeaveFight = function(param1, param2)
  ChildrenDataMgr.Instance():ClearInFightSceneChild()
end
def.static("table", "table").onEnterWorld = function(p1, p2)
  instance:ShowChildOnlineHello()
end
def.static("table", "table").onLeaveWorld = function(p1, p2)
  instance.queryCallback = nil
  instance.locReqs = nil
  ChildrenDataMgr.Instance():Reset()
  require("Main.Children.mgr.ChildrenFashionMgr").Instance():Reset()
end
def.static("table", "table").onBabySleepEnd = function(p1, p2)
  local childId = p1[1]
  local ChildFamilyLoveTipsEnum = require("consts.mzm.gsp.children.confbean.ChildFamilyLoveTipsEnum")
  instance:ShowChildSayHello(childId, ChildFamilyLoveTipsEnum.BABY_WAKU_UP)
end
def.static("table", "table").OnFeatureOpenChange = function(p1, p2)
  local featureType = p1.feature
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  if featureType == Feature.TYPE_CHILDREN then
    Event.DispatchEvent(ModuleId.CHILDREN, gmodule.notifyId.Children.Child_Featur_Openchange, {
      open = p1.open
    })
  end
end
def.method("=>", "boolean").HasChildren = function(self)
  return ChildrenDataMgr.Instance():HasChildren()
end
def.method("userdata").OpenGrowPanel = function(self, cid)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  local childData = ChildrenDataMgr.Instance():GetChildById(cid)
  if childData then
    if childData:IsBaby() then
      require("Main.Children.ui.BabyCarePanel").Instance():ShowPanel(cid)
    elseif childData:IsTeen() then
      if not require("Main.Children.ChildrenInterface").CheckChildhoodPhaseOpenAndToast() then
        return
      end
      require("Main.Children.ui.TeenMainPanel").Instance():ShowTeenGrow(cid)
    elseif childData:IsYouth() then
      self:QueryChild(cid, function(p)
        local data = ChildrenDataMgr.Instance():AddChild(p.child_id, p.child_bean)
        require("Main.Children.ui.YouthMainPanel").Instance():ShowDlg(cid)
      end)
    end
  end
end
def.method("userdata").PickUpChild = function(self, cid)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  local function carryChild()
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CCarryChild").new(cid))
  end
  local childData = ChildrenDataMgr.Instance():GetChildById(cid)
  if childData then
    if childData:IsMine() then
      carryChild()
    else
      local MarriageInterface = require("Main.Marriage.MarriageInterface")
      local mateInfo = MarriageInterface.GetMateInfo()
      if mateInfo == nil or not Int64.eq(mateInfo.mateId, childData:GetOwner()) then
        return
      end
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      local str = string.format(textRes.Children[33], mateInfo.mateName)
      CommonConfirm.ShowConfirm("", str, function(result)
        if result == 1 then
          carryChild()
        end
      end, nil)
    end
  end
end
def.method("userdata").PutDownChild = function(self, cid)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  if not gmodule.moduleMgr:GetModule(ModuleId.HOMELAND):IsInSelfHomeland() then
    Toast(textRes.Children[20])
    return
  end
  if cid == nil then
    return
  end
  if ChildrenDataMgr.Instance():IsInBag(cid) then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CMoveChildHome").new(cid))
  end
end
def.method("userdata", "number").ShowChild = function(self, cid, period)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  local showCid, showPeriod = ChildrenDataMgr.Instance():GetShowChildId()
  if showCid ~= cid or showPeriod ~= period then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CChildShow").new(cid, period))
  else
    print(string.format("child(cid=%s, period=%d) already show", tostring(cid), period))
  end
end
def.method().HideChild = function(self)
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  if ChildrenDataMgr.Instance():GetShowChildId() ~= nil then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CCancelChildShow").new())
  end
end
def.method("userdata").ChangeChildName = function(self, cid)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not require("Main.Children.ChildrenInterface").CheckFunctionOpenAndToast() then
    return
  end
  if cid == nil then
    return
  end
  local CommonRenamePanel = require("GUI.CommonRenamePanel").Instance()
  CommonRenamePanel:ShowPanel(textRes.Children[3], false, function(name, tag)
    if not self:ValidEnteredName(name) then
      return true
    elseif SensitiveWordsFilter.ContainsSensitiveWord(name) then
      Toast(textRes.Children[4])
      return true
    elseif SensitiveWordsFilter.ContainsSensitiveWord(name, "Name") then
      Toast(textRes.Children[5])
      return true
    elseif name == "" then
      Toast(textRes.Children[6])
      return true
    else
      local CommonConfirm = require("GUI.CommonConfirmDlg")
      local str = string.format(textRes.Children[2031], constant.CChildrenConsts.change_name_cost_gold_value)
      CommonConfirm.ShowConfirm(textRes.Children[2032], str, function(selection, tag)
        if selection == 1 then
          local count = ItemModule.Instance():GetMoney(ItemModule.MONEY_TYPE_GOLD)
          if count < Int64.new(constant.CChildrenConsts.change_name_cost_gold_value) then
            Toast(textRes.Children[2009])
            GoToBuyGold()
            return
          end
          local nameOctets = require("netio.Octets").rawFromString(name)
          gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CChangeChildName").new(cid, nameOctets))
        end
      end, nil)
      return false
    end
  end, self)
end
def.method("string", "=>", "boolean").ValidEnteredName = function(self, enteredName)
  local NameValidator = require("Main.Common.NameValidator")
  local isValid, reason, _ = NameValidator.Instance():IsValid(enteredName)
  if isValid then
    return true
  else
    if reason == NameValidator.InvalidReason.TooShort then
      Toast(textRes.Login[15])
    elseif reason == NameValidator.InvalidReason.TooLong then
      Toast(textRes.Login[14])
    elseif reason == NameValidator.InvalidReason.NotInSection then
      Toast(textRes.Pet[46])
    end
    return false
  end
end
def.method("userdata").ShowChildDiary = function(self, cid)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if cid == nil then
    return
  end
  require("Main.Children.mgr.GrowthMemoMgr").Instance():GetGrowthMemoAsync(cid, function(memo)
    if memo then
      require("Main.Children.ui.MemorialBookPanel").Instance():ShowPanel(memo)
    end
  end)
end
def.method("userdata").ShowChildFashion = function(self, cid)
  if _G.CheckCrossServerAndToast() then
    return
  end
  if not IsFeatureOpen(require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo").TYPE_CHILD_FASHION) then
    return
  end
  if cid == nil then
    return
  end
  local child = ChildrenDataMgr.Instance():GetChildById(cid)
  if child then
    local fashion = child:GetCurFashion()
    require("Main.Children.ui.ChildrenFashionPanel").ShowChildrenFashionPanel(cid, child:GetStatus(), fashion and fashion.fashionId or 0)
  end
end
def.method("userdata").ExileChild = function(self, cid)
  if cid == nil then
    return
  end
  local child = ChildrenDataMgr.Instance():GetChildById(cid)
  if child then
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CFreeChild").new(cid))
  end
end
def.method().ShowChildOnlineHello = function(self)
  local children = ChildrenDataMgr.Instance():GetAllChildren() or {}
  local sortedChildren = {}
  for k, v in pairs(children) do
    table.insert(sortedChildren, v.id)
  end
  if #sortedChildren > 0 then
    local idx = math.random(#sortedChildren)
    local ChildFamilyLoveTipsEnum = require("consts.mzm.gsp.children.confbean.ChildFamilyLoveTipsEnum")
    self:ShowChildSayHello(sortedChildren[idx], ChildFamilyLoveTipsEnum.ON_LINE)
  end
end
def.method("userdata", "number").ShowChildSayHello = function(self, childId, helloType)
  if not require("Main.Children.ChildrenInterface").IsFunctionOpen() then
    return
  end
  if _G.IsCrossingServer() then
    return
  end
  local wordId = require("Main.Children.ChildrenUtils").RandomAChildFamilyLoveWord(helloType)
  local content = require("Main.Common.TipsHelper").GetHoverTip(wordId)
  require("Main.Children.ui.ChildSayHelloPanel").Instance():ShowPanel(childId, content)
end
def.method("userdata").ChildComeToMe = function(self, childId)
  local MapEntityType = require("netio.protocol.mzm.gsp.map.MapEntityType")
  local entites = gmodule.moduleMgr:GetModule(ModuleId.MAP):GetMapEntitiesByType(MapEntityType.MET_CHILDREN)
  if entites == nil then
    print(string.format("ChildComeToMe: child(%s) not in view", tostring(childId)))
    return
  end
  local childEntity
  for k, v in pairs(entites) do
    local instanceid = v.instanceid
    if instanceid == childId then
      childEntity = v
      break
    end
  end
  if childEntity == nil then
    print(string.format("ChildComeToMe: child(%s) not in view", tostring(childId)))
    return
  end
  local heroPos = gmodule.moduleMgr:GetModule(ModuleId.HERO):GetPos()
  if heroPos == nil then
    print(string.format("ChildComeToMe: hero pos is nil"))
    return
  end
  local findpath = childEntity:FindPath(heroPos.x, heroPos.y, 0)
  if findpath == nil or #findpath == 0 then
    print(string.format("ChildComeToMe: no path found for childId = %s", tostring(childId)))
    return
  end
  local Location = require("netio.protocol.mzm.gsp.map.Location")
  local keyPointPath = {}
  for i = 0, #findpath do
    local lp = Location.new()
    lp.x = findpath[i].x
    lp.y = findpath[i].y
    table.insert(keyPointPath, lp)
  end
  self:CMoveChildReq(childId, keyPointPath)
end
def.method("userdata", "table").CMoveChildReq = function(self, cid, locations)
  gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CChildComeToMeReq").new(locations, cid))
end
def.method("userdata", "function").QueryChild = function(self, cid, cb)
  if self.queryCallback == nil then
    self.queryCallback = {}
  end
  if cid then
    local cbs = self.queryCallback[cid:tostring()]
    if cbs == nil then
      cbs = {}
      self.queryCallback[cid:tostring()] = cbs
    end
    table.insert(cbs, cb)
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CQueryChildReq").new(cid))
  end
end
def.method("userdata", "function").QueryChildLocation = function(self, cid, cb)
  if self.locReqs == nil then
    self.locReqs = {}
  end
  if cid then
    local cbs = self.locReqs[cid:tostring()]
    if cbs == nil then
      cbs = {}
      self.locReqs[cid:tostring()] = cbs
    end
    table.insert(cbs, cb)
    gmodule.network.sendProtocol(require("netio.protocol.mzm.gsp.children.CGetChildLocation").new(cid))
  end
end
def.method("=>", "boolean").IsNannyFeatureOpen = function(self)
  local Feature = require("netio.protocol.mzm.gsp.open.ModuleFunSwitchInfo")
  local bOpen, _ = require("Main.FeatureOpenList.FeatureOpenListModule").Instance():CheckFeatureOpen(Feature.TYPE_CHILDREN_AUTO_BREED)
  return bOpen
end
ChildrenModule.Commit()
return ChildrenModule
