local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local Item = require "Zeus.Model.Item"
local DropDownExt = require "Zeus.Logic.DropDownExt"
local GdDepotRq = require 'Zeus.Model.GuildDepot'
local ItemModel = require 'Zeus.Model.Item'
local GuildUtil = require 'Zeus.UI.XmasterGuild.GuildUtil'

local self = {
    menu = nil,
}

local DEAFULT_INDEX = -1

local ITEM_OP_TYPE = 
{
  ITEM_CANCLE = 0,
  ITEM_DELETE = 1,
  ITEM_SAVE = 2,
  ITEM_GET = 3,
}

local Text = 
{
  Push = Util.GetText(TextConfig.Type.ITEM,'storeOpPush'),
  Pop = Util.GetText(TextConfig.Type.ITEM,'storeOpPop'),
}

local ProsIdx = 
{
    btn_alltype = 0,
    btn_warrio  = 1,
    btn_roger   = 2,
    btn_mage    = 3,
    btn_hunter  = 4,
    btn_priest  = 5,
}

local PositionIdx = 
{
  btn_buwei1 = 0,       
  btn_buwei2 = 1,       
  btn_buwei3 = 2,        
  btn_buwei4 = 3,        
  btn_buwei5 = 4,        
  btn_buwei6 = 8,          
  btn_buwei7 = 5,            
  btn_buwei8 = 7,          
  btn_buwei9 = 6,           
  btn_buwei10 = 12,          
}


local ClassifyTypeNames = {
          GlobalHooks.DB.Find('StoreFilter',{FilterType=0}),
          GlobalHooks.DB.Find('StoreFilter',{FilterType=1}),
          GlobalHooks.DB.Find('StoreFilter',{FilterType=3}),
        }

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function DisposeBagContainer()
  if self.containerLeft then
    self.containerLeft:Dispose()
    self.containerLeft = nil
  end
  if self.containerRight then
    self.containerRight:Dispose()
    self.containerRight = nil
  end
end

local function SetPepotItemShowNum()
  local depotlv = self.DepotInfo.level
  local MaxNum = self.retDepot[depotlv].Spece
  if self.containerRight then
    local CurNum = self.containerRight.Filter.ItemCount
    self.lb_warehouse1.Text = string.format(GetTextConfg("guild_Depot_num"),CurNum,MaxNum)
  end
end

local function GetCurUplvIndex(uplv)
  if self.retCond then
    for k,v in pairs(self.retCond) do
      if uplv == v.UpLevel then
        return k
      end
    end
    return 1
  end
  return 1
end

local function PushDepot(items)
  self.containerRight.ItemPack:UpdateItemWithNet(items.gridIndex,items.item)
  local it = self.containerRight:FindItemShow(items.item.id)
  local rows = math.floor(self.containerRight:GetIndex(it)/5)
  if self.containerRight:GetIndex(it) % 5 ~= 0 then
    rows = rows + 1
  end
  self.sp_see_right.Scrollable:LookAt(Vector2.New(0, (rows-1)*91),true)
end

local function GetToBag(id)
  local it = self.containerRight:FindItemShow(id)
  local rows = math.floor(self.containerRight:GetIndex(it)/5)
  if self.containerRight:GetIndex(it) % 5 ~= 0 then
    rows = rows + 1
  end
  self.sp_see_right.Scrollable:LookAt(Vector2.New(0, (rows-1)*91),true)
end

local function setWareHouseValue()
  local num = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.PAWNGOLD)
  self.lb_contributionnum.Text = num
end

local function ItemShowInit(self,con,itshow)
  if not itshow.LastItemData or not itshow.Parent then return end
end

local function ItemOPCallBack(obj,itshow,opType)
  if opType == ITEM_OP_TYPE.ITEM_CANCLE then
    obj:Close()
    return
  else
    local staticVo = GlobalHooks.DB.Find("Items", itshow.LastItemData.TemplateId)
    if not GuildUtil.GetItemIsDepotInterval(staticVo) then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_gdUtil_equipshort"))
      return
    end
    local Index_old = itshow.LastItemData.Index
    local index_id = itshow.LastItemData.Id
    if opType == ITEM_OP_TYPE.ITEM_DELETE then
      if self.Depot_deleteCont.cur == self.Depot_deleteCont.max then
        GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Depot_notremove"))
        return
      end
      GdDepotRq.deleteItemRequest(Index_old,function (deleteCont)
        self.containerRight.ItemPack:UpdateItemWithNet(Index_old,{})
        SetPepotItemShowNum()
        self.Depot_deleteCont.cur = deleteCont
        obj:Close()
      end)
    elseif opType == ITEM_OP_TYPE.ITEM_SAVE then
      GdDepotRq.depositItemRequest(itshow.LastItemData.Index,function (items,curnum)
        PushDepot(items)
        setWareHouseValue()
        obj:Close()
        SetPepotItemShowNum()
        self.curSaveInfo.curnum = curnum
      end)
    elseif opType == ITEM_OP_TYPE.ITEM_GET then
      local rolebag = DataMgr.Instance.UserData.RoleBag
      if rolebag.LimitSize <= rolebag.AllData.Count then
        EventManager.Fire('Event.OnShowFullBagTips',{})
        return
      end
      GdDepotRq.takeOutItemRequest(Index_old,function ()
        self.containerRight.ItemPack:UpdateItemWithNet(Index_old,{})
        GetToBag(index_id)
        setWareHouseValue()
        obj:Close()
        SetPepotItemShowNum()
      end)
    end
  end
end

local function IsClickBagItem(it,is_bag)
  it.IsSelected = true
  local menu,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIGuildWareHouseSave)
  if not menu then
    menu,obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIGuildWareHouseSave,0)
    local uiParent,_ = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIGuildWareHouse)
    uiParent:AddSubMenu(menu)
  end
  obj:SetItemData(it,is_bag,{savaData=self.curSaveInfo,deleteData=self.Depot_deleteCont})
  obj:SetExitCallback(function ()
    if it then
      it.IsSelected = false
    end
  end)
  
  obj.btn_cancel.TouchClick = function (sender)
    ItemOPCallBack(obj, it, ITEM_OP_TYPE.ITEM_CANCLE)
  end
  obj.btn_delete.TouchClick = function (sender)
    ItemOPCallBack(obj, it, ITEM_OP_TYPE.ITEM_DELETE)
  end
  obj.btn_deposit.TouchClick = function (sender)
    ItemOPCallBack(obj, it, ITEM_OP_TYPE.ITEM_SAVE)
  end
  obj.btn_take.TouchClick = function (sender)
    ItemOPCallBack(obj, it, ITEM_OP_TYPE.ITEM_GET)
  end
end

local function ShowLeftScroll()
  local filter = ItemPack.FilterInfo.New()
  filter.IsSequence = true
  filter.CheckHandle = function(it)
    local detail = Item.GetItemDetailById(it.Id)
    
    local staticVo = GlobalHooks.DB.Find("Items", detail.static.Code)
    
    return detail.equip ~= nil  and detail.canDepotGuild == 1 and GuildUtil.GetItemIsDepotInterval(staticVo)
  end
  local pack = DataMgr.Instance.UserData.RoleBag

  self.containerLeft = HZItemsContainer.New()
  self.containerLeft.CellSize = HZItemShow.SelectSizeToBodySize(self.cvs_item_lift.Size2D)
  self.containerLeft.Filter = filter
  self.containerLeft.ItemPack = pack
  self.containerLeft.IsShowStrengthenLv = true
  self.containerLeft.IsShowLockUnlock = true
  self.containerLeft:AddItemShowInitHandle('itshow',function ( con,it )
    local detail = nil
    local IsEquip = nil
    if it.LastItemData then
      detail = it.LastItemData.detail
      IsEquip = it.LastItemData.IsEquip
    end
    Util.ItemshowExt(it, detail, IsEquip)
  end)

  local s = self.cvs_item_lift.Size2D
  local rows = math.floor(pack.LimitSize / 4)
  if pack.LimitSize % 4 ~= 0 then
    rows = rows + 1
  end

  local function OnUpdate(gx,gy,node)
    self.containerLeft:SetItemShowParent(node, gy * 4 + gx + 1)
  end
  if rows<4 then rows = 4 end
  if self.sp_see_lift.Rows <= 0 then
    self.sp_see_lift:Initialize(s.x+10, s.y+5, rows, 4, self.cvs_item_lift, OnUpdate,function() end)
  else
    self.sp_see_lift.Rows = rows
  end

  self.containerLeft:OpenSelectMode(false,false,nil,function (con,it)
    if not it.LastItemData then return end
    IsClickBagItem(it,true)
  end)
end

local function InitDepotPack()
  local DepotBag = ItemPack.New()
  
  
  DepotBag:InitData(self.DepotGridInfo or {},self.retDepot[self.DepotInfo.level].Spece)
  DepotBag.MaxLimitSize = self.retDepot[#(self.retDepot)].Spece
  return DepotBag
end

local function ShowRightScroll()
  local filter = ItemPack.FilterInfo.New()
  filter.IsSequence = true
  self.containerRight = HZItemsContainer.New()
  self.containerRight.CellSize = HZItemShow.SelectSizeToBodySize(self.cvs_item_right.Size2D)
  self.containerRight.Filter = filter
  self.containerRight.ItemPack = InitDepotPack()
  self.containerRight.IsShowStrengthenLv = true
  self.containerRight.IsShowLockUnlock = true

  self.containerRight:AddItemShowInitHandle('itshow',function ( con,it )
    local detail = nil
    local IsEquip = nil
    if it.LastItemData then
      detail = it.LastItemData.detail
      IsEquip = it.LastItemData.IsEquip
    end
    Util.ItemshowExt(it, detail, IsEquip)
  end)
  local s = self.cvs_item_right.Size2D

  local maxNum = self.retDepot[self.DepotInfo.level].Spece
  local rows = math.floor(maxNum / 5)
  if maxNum % 5 ~= 0 then
    rows = rows + 1
  end

  local function OnUpdate(gx,gy,node)
    self.containerRight:SetItemShowParent(node, gy * 5 + gx + 1)
  end
  if rows<4 then rows = 4 end
  if self.sp_see_right.Rows <= 0 then
    self.sp_see_right:Initialize(s.x+10, s.y+5, rows, 5, self.cvs_item_right, OnUpdate,function() end)
  else
    self.sp_see_right.Rows = rows
  end

  self.containerRight:OpenSelectMode(false,false,nil,function (con,it)
    if not it.LastItemData then return end
    IsClickBagItem(it,false)
  end)
end

local function SubConditionXmlText()
  local conds = self.DepotInfo.depotCond
  local lv = 30
  lv = conds.useCond.upLevel==0 and conds.useCond.level or self.retCond[GetCurUplvIndex(conds.useCond.upLevel)].Condition
  local job = self.retJob[conds.useCond.job].position
  local clv = Util.GetQualityColorARGB(self.retCond[GetCurUplvIndex(conds.useCond.upLevel)].Qcolor)
  local jobc = Util.GetQualityColorARGB(self.retJob[conds.useCond.job].positionColor)
  local strBegin = string.format(GetTextConfg("guild_Depot_strBegin").."\n",clv,lv,jobc,job)
  local c1 = Util.GetQualityColorARGB(self.reticonColor[conds.minCond.qColor+1-2].ConditionCode)
  local minlv = 30

  minlv = conds.minCond.level..GetTextConfg("guild_Depot_lv")
  local minC = self.retCond[1].Qcolor
  local lvSet1 = string.format("<f color='%x'>%s</f> <f color='%x'>%s</f>",minC,minlv,c1,self.reticonColor[conds.minCond.qColor+1-2].ConditionName)
  local c2 = Util.GetQualityColorARGB(self.reticonColor[conds.maxCond.qColor+1-2].ConditionCode)
  local maxlv = 30
  local maxC = self.retCond[1].Qcolor
  maxlv = conds.maxCond.level..GetTextConfg("guild_Depot_lv")
  local lvSet2 = string.format("<f color='%x'>%s</f> <f color='%x'>%s</f>",maxC,maxlv,c2,self.reticonColor[conds.maxCond.qColor+1-2].ConditionName)
  return string.format(GetTextConfg("guild_Depot_strEnd"),strBegin,lvSet1,lvSet2)
end

local function rushUI()
  self.tbh_look.XmlText = GetTextConfg("guild_Depot_check")
  self.cvs_htmlp.event_PointerDown = function( ... )
    local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShowXmlTips, 1)

    obj.SetXmlStr(SubConditionXmlText())

    local cvs = obj.content_node
    cvs.Position2D = Vector2.New(self.cvs_htmlp.X,self.cvs_htmlp.Y-cvs.Height)
  end

  self.cvs_htmlp.event_PointerUp = function( ... )
    GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIShowXmlTips)
  end

  setWareHouseValue()
  local depotlv = self.DepotInfo.level
  if depotlv < 10 then
    self.tb_tips.Text = string.format(GetTextConfg("guild_Depot_upadd"),depotlv,
                                                                      depotlv+1,
                                                                      self.retDepot[depotlv+1].Spece-self.retDepot[depotlv].Spece)
  else
    self.tb_tips.Text = string.format(GetTextConfg("guild_Depot_maxadd"),self.retDepot[depotlv].Spece)
  end
end

local function ChangeGridFromPush(eventname,params)
  if params.type == 1 then
    PushDepot(params.msg)
    SetPepotItemShowNum()
  elseif params.type == 2 then
    self.containerLeft.ItemPack:UpdateItemWithNet(params.bagIndex,{})
    SetPepotItemShowNum()
  elseif params.type == 3 then
    self.DepotInfo.level = params.dopotlevel
    ShowRightScroll()
    rushUI()
  elseif params.type == 4 then
    self.DepotInfo.depotCond = params.condition
    rushUI()
  end
end

local function DepotUpLevelChange(eventname,params)
  self.DepotInfo = GdDepotRq.GetDepotInfo()
  self.DepotGridInfo = GdDepotRq.GetDepotBagInfo()
  ShowRightScroll()
  rushUI()
  SetPepotItemShowNum()
end

local function GetDataEnter()
  self.DepotInfo = GdDepotRq.GetDepotInfo()
  self.DepotGridInfo = GdDepotRq.GetDepotBagInfo()
  EventManager.Subscribe('Guild.DepotOneGridChange',ChangeGridFromPush)
  EventManager.Subscribe('Guild.DepotUpLevel',DepotUpLevelChange)
  
  ShowLeftScroll()
  ShowRightScroll()
  SetPepotItemShowNum()
  rushUI()
end

local function FindFilterName(type, value)
    for _,v in ipairs(ClassifyTypeNames[type]) do
        if v.FilterCode == value then
            return v 
        end
    end
end

local function FindTypeTable(type, value)
    for _,v in ipairs(ClassifyTypeNames[type]) do
        if v.FilterCode == value then
            return v 
        end
    end 
end

local function ClassifyChildChange(tag,value)
  if value == DEAFULT_INDEX then
    self.classifyBtn[tag].Text = FindTypeTable(tag, value).FilterName.."→"
  else
    self.classifyBtn[tag].Text = FindTypeTable(tag, value).FilterName
  end
  
  if tag == 1 then
    self.ProConditions = value
  elseif tag == 2 then
    self.QuaConditions = value
  elseif tag == 3 then
    self.LvConditions = value
  end

  self.classifyBtn[tag].IsChecked = false
  self.cvs_sort_single.Visible = false
end

local function SwitchClassify(sender)
  local tag = sender.UserTag
  self.sp_sort_single.Scrollable.Container:RemoveAllChildren(true)
  self.sp_sort_single.Scrollable.Container.Y = 0
  for i,v in ipairs(ClassifyTypeNames[tag]) do
    local node
    if v.FilterCode == DEAFULT_INDEX then
      node = self.btn_all_class:Clone()
      node.X = -2
      node.Y = (i - 1)*(node.Height+5)
    else
      node = self.btn_level_single:Clone()
      node.X = 3
      node.Y = (i - 1)*(node.Height+5)
    end
    node.Visible = true
    node.Text = v.FilterName
    self.sp_sort_single.Scrollable.Container:AddChild(node)
    node.TouchClick = function (sender)
      ClassifyChildChange(tag,v.FilterCode)
    end
  end
  self.cvs_sort_single.Visible = true
end

local function ResetClassifyBtnStatus()
    for i=1,3 do
      self.classifyBtn[i].Enable = true
      self.classifyBtn[i].IsChecked = false
    end
    self.cvs_sort_single.Visible = false
end

local function ResetClassify()
    for i=1,3 do
      self.classifyBtn[i].Text = FindTypeTable(i, DEAFULT_INDEX).FilterName.."→"
    end
    self.ProConditions = DEAFULT_INDEX
    self.QuaConditions = DEAFULT_INDEX
    self.LvConditions = DEAFULT_INDEX
    ResetClassifyBtnStatus()
end

local function ShowClassify(bool)
  self.cvs_sort.Visible = bool
  if bool == false then 
    self.tbt_variety.IsChecked = false
    return 
  end

  ResetClassifyBtnStatus()

  Util.InitMultiToggleButton(function (sender)
    SwitchClassify(sender)
  end,nil,self.classifyBtn)
end

local function ClassifyChange()
  
  
  
  if self.ProConditions==DEAFULT_INDEX and self.QuaConditions==DEAFULT_INDEX and self.LvConditions==DEAFULT_INDEX then
    self.containerRight.Filter.CheckHandle = nil
    self.containerRight.Filter.Type = ItemData.TYPE_ALL
  else
    self.containerRight.Filter.CheckHandle = function (it)
      local detail = Item.GetItemDetailById(it.Id)
      
      if self.ProConditions~=DEAFULT_INDEX and detail.equip.pro ~= self.ProConditions then
          return false
      end
      if self.QuaConditions~=DEAFULT_INDEX and detail.static.Qcolor~=self.QuaConditions then
        return false
      end
      if self.LvConditions~=DEAFULT_INDEX then
        local FilterName = FindFilterName(3,self.LvConditions).FilterName
        local index = string.find(FilterName, tostring(detail.static.LevelReq))
        if index == nil then
          return false
        end
      end
      return true
    end
  end
  self.containerRight.Filter = self.containerRight.Filter
  ShowClassify(false)
end

local function InitSortbtn()
  ResetClassify()

  self.cvs_sort.Visible = false
  self.tbt_variety.IsChecked = false

  self.cvs_variety.TouchClick = function (sender)
    self.tbt_variety.IsChecked = not self.tbt_variety.IsChecked
    ShowClassify(self.tbt_variety.IsChecked)
  end
  self.tbt_variety.TouchClick = function (sender)
    ShowClassify(self.tbt_variety.IsChecked)
  end
end

local function OnEnter()
  InitSortbtn()

  DisposeBagContainer()
  if self.DepotInfo then
    GetDataEnter()
  else
    GdDepotRq.getDepotInfoRequest(function ()
      GetDataEnter()
      self.DepotInfo = GdDepotRq.GetDepotInfo()
      self.Depot_deleteCont = {}
      self.Depot_deleteCont.cur = self.DepotInfo.deleteCount
      self.Depot_deleteCont.max = self.DepotInfo.deleteCountMax
    end)
    GDRQ.getGuildMoneyRequest(function (curnum,maxnum)
      self.curSaveInfo = {}
      self.curSaveInfo.curnum = curnum
      self.curSaveInfo.maxnum = maxnum
    end)
  end
end

local function OnExit()
  DisposeBagContainer()
  EventManager.Unsubscribe('Guild.DepotOneGridChange',ChangeGridFromPush)
  EventManager.Unsubscribe('Guild.DepotUpLevel',DepotUpLevelChange)
end

local function initUI()
  self.cvs_item_right.Visible = false
  self.cvs_item_lift.Visible = false

  self.retCond = GlobalHooks.DB.Find("WareHouseCondition", {})
  self.retJob = GlobalHooks.DB.Find("GuildPosition", {})
  self.reticonColor = GlobalHooks.DB.Find("WareHouseCondition2", {})
  self.retDepot = GlobalHooks.DB.Find("WareHouseLevel", {})

  self.btn_setup.TouchClick = function ()
    local myjobnum = GDRQ.GetMyInfoFromGuild().job
    if self.retJob[GDRQ.GetMyInfoFromGuild().job].right6 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWareHousePrivilege,0)
  end

  self.btn_up.TouchClick = function ()
    local myjobnum = GDRQ.GetMyInfoFromGuild().job
    if self.retJob[GDRQ.GetMyInfoFromGuild().job].right6 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end
    if self.DepotInfo.level==10 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Depot_maxlv"))
      return
    end
    local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWareHouseUpLv,0)
  end

  self.btn_dynamic.TouchClick = function ()
    local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWareHouseDynamic,0)
  end

  self.btn_arrange.TouchClick = function ()
    local userdata = DataMgr.Instance.UserData
    userdata:BagPackUp(userdata.RoleBag.PackType)
  end

  self.btn_reset.TouchClick = function ()
    ResetClassify()
  end

  self.btn_complete.TouchClick = function ()
    ClassifyChange()
  end

  self.btn_all_class.Visible = false
  self.btn_level_single.Visible = false
  self.tbt_job_all.UserTag = 1
  self.tbt_quality_all.UserTag = 2
  self.tbt_level_all.UserTag = 3
  self.classifyBtn = {self.tbt_job_all, self.tbt_quality_all, self.tbt_level_all}
end

local ui_names = 
{
  
  {name = 'cvs_variety'},
  {name = 'tbt_variety'},
  {name = 'lb_varietyname'},
  {name = 'cvs_sort'},
  {name = 'cvs_sort_single'},
  {name = 'btn_all_class'},
  {name = 'btn_level_single'},
  {name = 'sp_sort_single'},
  {name = 'tbt_job_all'},
  {name = 'tbt_quality_all'},
  {name = 'tbt_level_all'},
  {name = 'sp_see_right'},
  {name = 'cvs_item_right'},
  {name = 'sp_see_lift'},
  {name = 'cvs_item_lift'},
  {name = 'btn_reset'},
  {name = 'btn_complete'},
  {name = 'tb_tips'},
  {name = 'btn_up'},
  {name = 'lb_contributionnum'},
  {name = 'tbt_all'},
  {name = 'btn_dynamic'},
  {name = 'btn_setup'},
  {name = 'tbh_look'},
  {name = 'btn_arrange'},
  {name = 'cvs_htmlp'},
  
  {name = 'lb_warehouse1'},
  
  
  
  {name = 'btn_close',click = function ()
    self.menu:Close()
  end},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_cangku.gui.xml", GlobalHooks.UITAG.GameUIGuildWareHouse)
  self.menu.Enable = false
  self.menu.mRoot.Enable = false
  InitCompnent()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function ()
    self = nil
  end)
  return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
