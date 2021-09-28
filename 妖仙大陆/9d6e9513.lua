local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"

local GuildUtil = require 'Zeus.UI.XmasterGuild.GuildUtil'
local GdPray = require 'Zeus.Model.guildBless'
local ItemModel = require 'Zeus.Model.Item'
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {
    menu = nil,
}

local giftGetState = {
  CannotGet = 0,
  CanGet = 1,
  HasGet = 2,
}
local retGuildBless = GlobalHooks.DB.Find("BlessLevel", {})
local retAttrs = GlobalHooks.DB.Find("Attribute", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function clearAllAwardEffect()
  Util.clearAllEffect(self.cvs_50)
  Util.clearAllEffect(self.cvs_100)
  Util.clearAllEffect(self.cvs_300)
end

local function SplicingMsgg(Ostr,isFormat,value)
  local str = Ostr
  local strr = ""
  if str == nil then
    return ""
  end

  local colorValue = "</f><f color='ff00d600'>"..value.."</f><f color='ffc5a13f'>"
  if isFormat==1 then
    colorValue = "</f><f color='ff00d600'>"..(value/100).."%%</f><f color='ffc5a13f'>"
    strr = string.gsub(str,"{A}%%",colorValue)
  else
    colorValue = "</f><f color='ff00d600'>"..value.."</f><f color='ffc5a13f'>"
    strr = string.gsub(str,"{A}",colorValue)
  end

  return "<f color='ffc5a13f'>"..strr.."</f>"
end

local function GetItemNum(templateId)
  local bag_data = DataMgr.Instance.UserData.RoleBag  
  local vItem = bag_data:MergerTemplateItem(templateId)
  local cur_num = (vItem and vItem.Num) or 0
  return cur_num
end

local function SubAttrsStr(hasPrayed)
  local msg = self.myPrayInfo.guildInfo
  local attrStr = GetTextConfg("guild_Pray_prayadd")
  if msg.blessAttrs then
    for i=1,#msg.blessAttrs do
      local castr = retAttrs[msg.blessAttrs[i].id].attDesc
      local curattrvalue = msg.blessAttrs[i].value
      attrStr = attrStr..SplicingMsgg(castr,msg.blessAttrs[i].isFormat,curattrvalue)
    end
  end

  if hasPrayed == false then
    return attrStr.."<br/><br/><br/>"..GetTextConfg("guild_Pray_prayaddNO")
  else
    return attrStr.."<br/><br/><br/>"..GetTextConfg("guild_Pray_prayaddYes")
  end
end

local function ShowRecord(indexPage)
  self.tbh_cell.Visible = false
  if self.GuildRecord[indexPage]==nil then
    self.GuildRecord[indexPage] = {}
    self.tbh_cell.XmlText = ""
    return
  end
  local maxCellNum = #self.GuildRecord[indexPage]
  for i=1,maxCellNum do
    local lable = self.oldLables[indexPage][i]
    if not lable then
      lable = self.tbh_cell:Clone()
      lable.Visible = true
      self.oldLables[indexPage][i] = lable
      self.tbh_cell.Parent:AddChild(lable)
    end
    lable.XmlText = GuildUtil.SubHTML_str(self.GuildRecord[indexPage][i])
    local lableY = 60
    local se2d = lable.Size2D
    se2d.y = lableY
    lable.Size2D = se2d
    local pos = Vector2.New()
    if indexPage>1 then
      local addHeight = 0
      if i > 1 then
        pos.y = self.oldLables[indexPage][i - 1].Position2D.y + self.oldLables[indexPage][i - 1].Size2D.y
      else
        addHeight = self.NoticLastCells[indexPage-1].Y + self.NoticLastCells[indexPage-1].Height
        pos.y = addHeight
      end 
    else
      if i > 1 then
        pos.y = self.oldLables[indexPage][i - 1].Position2D.y + self.oldLables[indexPage][i - 1].Size2D.y
      end
    end

    lable.Position2D = pos
    self.NoticLastCells[indexPage] = lable
  end
end

local function remove50outRecord()
  for indexPage=2,5 do
    for i=1,50 do
      if not self.oldLables[indexPage][i] then
        self.oldLables[indexPage] = {}
        return 
      end
      self.oldLables[indexPage][i]:RemoveFromParent(true)
      if i==50 then
        self.oldLables[indexPage] = {}
      end
    end
  end
end

local function rushDynamic()
  remove50outRecord()
  GdPray.getBlessRecordRequest(1,function ()
      self.GuildRecord = GdPray.GetPrayDynamic()
      ShowRecord(1)
    end)
end

local function addFilter()
  local data = self.myPrayInfo.guildInfo.itemList
  if self.filter then 
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter)
    self.filter = nil
  end
  local filter = ItemPack.FilterInfo.New()
  self.filter = filter
  filter.MergerSameTemplateID = true
  filter.CheckHandle = function(item)
    for i,v in ipairs(data) do
      if item.TemplateId == v.item.code then
        return true
      end
    end
    return false
  end
  filter.NofityCB = function(pack, type, index)
    if self.canFilter == true then
      EventManager.Fire('Guild.PrayItemChange',{})
    end
  end
  DataMgr.Instance.UserData.RoleBag:AddFilter(filter)
end

local function update_pray_List(x, y, node)
  local index = y + 1
  node.UserTag = index
  node.Visible = true
  local msg = self.myPrayInfo.guildInfo
  local prayData = msg.itemList[index]

  local prayNum = #msg.itemList
  if index <= prayNum then
    node:FindChildByEditName("cvs_bless",true).Visible = true
    node:FindChildByEditName("lb_detail",true).Visible = false

    local icon = node:FindChildByEditName("cvs_icon",true)
    local item = Util.ShowItemShow(icon, prayData.item.icon, prayData.item.qColor, 1)
    local detail = ItemModel.GetItemDetailByCode(prayData.item.code)
    Util.ItemshowExt(item, detail, detail.equip ~= nil)
    local name = node:FindChildByEditName("lb_name",true)
    name.Text = prayData.item.name
    name.FontColorRGBA = Util.GetQualityColorRGBA(prayData.item.qColor)
    local needNum = node:FindChildByEditName("lb_neednum",true)
    local x = GetItemNum(prayData.item.code)
    needNum.Text = x
    needNum.FontColor = GameUtil.RGBA2Color(x==0 and 0xf43a1cff or 0x00d600ff)
    Util.NormalItemShowTouchClick(item,prayData.item.code,x==0)
    local expgg = node:FindChildByEditName("gg_pace",true)
    expgg.Value = prayData.finishNum/prayData.item.groupCount*100>100 and 100 or prayData.finishNum/prayData.item.groupCount*100
    local tb_experience_num = node:FindChildByEditName("tb_experience_num",true)
    tb_experience_num.Text = prayData.finishNum.."/"..prayData.item.groupCount
    local qifu = node:FindChildByEditName("btn_qifu",true)
    qifu.TouchClick = function ()
      GdPray.blessActionRequest(prayData.id,function ()
        
        local ret = retGuildBless[self.myPrayInfo.guildInfo.level]
        local tips = string.format(GetTextConfg("guild_Pray_paryAddFund"),ret.AddGuildFunds,ret.AddGuildPoints)
        GameAlertManager.Instance:ShowNotify(tips)
        
        
        EventManager.Fire('Guild.PushChangPray',{})
      end)
    end
  else
    node:FindChildByEditName("cvs_bless",true).Visible = false
    local label = node:FindChildByEditName("lb_detail",true)
    label.Text = GetTextConfg("guild_PrayLimit_"..index)
    label.Visible = true
  end
end

local function giftBtnClick(index, state, itemList)
  if state == 0 then
    
    EventManager.Fire('Event.OnPreviewItems',{items = itemList})
  elseif state == 1 then
    GdPray.receiveBlessGiftRequest(index, function ()
      EventManager.Fire('Guild.PushChangPray',{})
    end)
  elseif state == 2 then
    GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_Pray_prayAlreadyTip"))
  end
end

local function RefreshEffect(status1, status2, status3)
  clearAllAwardEffect()

  if status1 == true then
    Util.showUIEffect(self.cvs_50,3)
  end
  self.ib_point1.Visible = status1 == true

  if status2 == true then
    Util.showUIEffect(self.cvs_100,3)
  end
  self.ib_point2.Visible = status2 == true

  if status3 == true then
    Util.showUIEffect(self.cvs_300,3)
  end
  self.ib_point3.Visible = status3 == true

  EventManager.Fire("Event.UI.ChangePrayFlag",{visible = status1 == true or status2 == true or status3 == true})
end

function rushUI()
  local msg = self.myPrayInfo.guildInfo
  
  local hasPrayed = self.myPrayInfo.myInfo.buffTime > 0

  self.lb_lv.Text = GetTextConfg("guild_build_Lv")..msg.level
  self.lb_todaynum.Text = (msg.blessCountMax - self.myPrayInfo.myInfo.blessCount).."/"..msg.blessCountMax
  self.lb_todaynum.FontColor = GameUtil.RGBA2Color(msg.blessCountMax-self.myPrayInfo.myInfo.blessCount==0 and 0xf43a1cff or 0x00d600ff)

  self.gg_pace2.Text = ""--msg.blessValue.."/"..msg.blessValueMax

  self.lb_guildqifu.Text = msg.blessValue.."/"..msg.blessValueMax
  self.gg_pace2.Value = msg.blessValue/msg.blessValueMax*100>100 and 100 or msg.blessValue/msg.blessValueMax*100

  self.sp_single:Initialize(
      self.cvs_single1.Width, 
      self.cvs_single1.Height+5, 
      3,
      1,
      self.cvs_single1, 
      LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        update_pray_List(x, y, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
    )
  local state1 = self.myPrayInfo.myInfo.receiveState[1]
  local state2 = self.myPrayInfo.myInfo.receiveState[2]
  local state3 = self.myPrayInfo.myInfo.receiveState[3]
  self.ib_50box.Visible = state1 == giftGetState.CannotGet or state1 == giftGetState.CanGet
  self.ib_50boxopen.Visible = state1 == giftGetState.HasGet
  self.ib_100box.Visible = state2 == giftGetState.CannotGet or state2 == giftGetState.CanGet
  self.ib_100boxopen.Visible = state2 == giftGetState.HasGet
  self.ib_300box.Visible = state3 == giftGetState.CannotGet or state3 == giftGetState.CanGet
  self.ib_300boxopen.Visible = state3 == giftGetState.HasGet
  self.cvs_50.TouchClick = function ()
    giftBtnClick(0, state1, self.myPrayInfo.myInfo.itemList[1].item)
  end
  self.cvs_100.TouchClick = function ()
    giftBtnClick(1, state2, self.myPrayInfo.myInfo.itemList[2].item)
  end
  self.cvs_300.TouchClick = function ()
    giftBtnClick(2, state3, self.myPrayInfo.myInfo.itemList[3].item)
  end
  RefreshEffect(state1 == giftGetState.CanGet, state2 == giftGetState.CanGet, state3 == giftGetState.CanGet)

  self.lb_nobuff.Visible = not hasPrayed
  self.lb_buff.Visible = hasPrayed
  self.lb_buff_time.Visible = hasPrayed
  self.lb_time.Visible = hasPrayed

  if hasPrayed then
    if self.cdLabelExt then
      self.cdLabelExt:stop()
      self.cdLabelExt = nil
    end
    
    local function callback()
        self.lb_nobuff.Visible = true
        self.lb_buff.Visible = false
        self.lb_buff_time.Visible = false
        self.lb_time.Visible = false
    end
    local function format(cd,label)
        local string = ServerTime.GetTimeStr(cd)
        return string
    end
    self.cdLabelExt = CDLabelExt.New(self.lb_time,self.myPrayInfo.myInfo.buffTime,format,callback)
    self.cdLabelExt:start()
    
    local msg = self.myPrayInfo.myInfo
    local attrStr = GetTextConfg("guild_Pray_prayadd")
    if msg.blessAttrs then
      for i=1,#msg.blessAttrs do
        local castr = retAttrs[msg.blessAttrs[i].id].attDesc
        local curattrvalue = msg.blessAttrs[i].value
        attrStr = attrStr.."<br/>"..SplicingMsgg(castr,msg.blessAttrs[i].isFormat,curattrvalue)
      end
    end
    self.lb_buff.XmlText = "<f size= '22'>" .. attrStr .. "</f>"
  end
  
  
  
  
  
  
  
  
  
  
  

  
  
  
end

local function PushChangPray(eventname,params)
  GdPray.getMyBlessInfoRequest(function ()
    GdPray.getBlessInfoRequest(function ()
      self.myPrayInfo = GdPray.GetMyPrayInfo()
      rushUI()
      rushDynamic()
    end)
  end)
end

local function ChangeNumFromShop()
  self.myPrayInfo = GdPray.GetMyPrayInfo()
  rushUI()
end

local function OnEnter()
  self.canFilter = false
  EventManager.Subscribe('Guild.PushChangPray',PushChangPray)
  EventManager.Subscribe('Guild.PrayItemChange',ChangeNumFromShop)
  GdPray.getMyBlessInfoRequest(function ()
    GdPray.getBlessInfoRequest(function ()
      self.myPrayInfo = GdPray.GetMyPrayInfo()
      
      rushUI()
      rushDynamic()
      addFilter()
      self.canFilter = true
    end)
  end)
end

local function OnExit()
  EventManager.Unsubscribe('Guild.PushChangPray',PushChangPray)
  EventManager.Unsubscribe('Guild.PrayItemChange',ChangeNumFromShop)
  self.isRushRq = false
  if self.filter then
    DataMgr.Instance.UserData.RoleBag:RemoveFilter(self.filter)
    self.filter = nil
  end
  if self.cdLabelExt then
    self.cdLabelExt:stop()
    self.cdLabelExt = nil
  end

  clearAllAwardEffect()
end

function _M.SetCall(callfunc)
  self.callfunc = callfunc
end

local function initDynamic()
  self.oldLables = {{},{},{},{},{}}
  self.NoticLastCells = {{},{},{},{},{}}
  
  self.sp_dynamic.Scrollable.event_Scrolled = function ()
    if self.sp_dynamic.Scrollable.Container.Y > -(24*50) then
      return
    end
    local size = -(self.sp_dynamic.Scrollable.Container.Height-self.sp_dynamic.Height+70)
    if not self.isRushRq and self.sp_dynamic.Scrollable.Container.Y < size then
      if self.isRqRecording then
        return 
      end
      if self.RqRecordTime == nil then self.RqRecordTime = 0 end
      if os.time() - self.RqRecordTime < 2 then
        return 
      end
      local pagenum = 2
      for i=2,5 do
        if self.GuildRecord[i]==nil then
          pagenum = i
          break
        else
          if self.GuildRecord[i][1] == nil then
            pagenum = i
            break
          else
            if self.GuildRecord[i][50] ==nil then
              pagenum = i
              break
            end
          end
        end
      end
      
      self.isRqRecording = true
      self.isRushRq = true
      GdPray.getBlessRecordRequest(pagenum,function (indexPage)
        self.RqRecordTime = os.time()
        self.isRqRecording = false
        self.GuildRecord = GdPray.GetPrayDynamic()
        ShowRecord(indexPage)
        self.isRushRq = false
      end)
    end
  end
end

local function initElseBtn()
  self.btn_write2.TouchClick = function ()
    local myjobnum = GDRQ.GetMyInfoFromGuild().job
    if self.retJob[GDRQ.GetMyInfoFromGuild().job].right7 ~= 1 then
      GameAlertManager.Instance:ShowNotify(GetTextConfg("guild_public_noPrivilege"))
      return
    end

    local node,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildPrayUpLv,0)
    obj.SetCall(function (lvnum)
      self.lb_lv.Text = GetTextConfg("guild_build_Lv")..lvnum
    end)
  end
end

local function initUI()
  self.cvs_single1.Visible = false
  self.cvs_htmlp.Visible = false
  self.retJob = GlobalHooks.DB.Find("GuildPosition", {})
  initDynamic()
  initElseBtn()
end

local ui_names = 
{
  
  {name = 'sp_single'},
  {name = 'cvs_single1'},
  {name = 'btn_write2'},
  {name = 'lb_lv'},
  {name = 'lb_todaynum'},
  {name = 'sp_dynamic'},
  {name = 'gg_pace2'},
  {name = 'sp_dynamic'},
  {name = 'tb_jiacheng'},
  {name = 'tbh_cell'},
  {name = 'cvs_htmlp'},
  {name = 'ib_50box'},
  {name = 'ib_50boxopen'},
  {name = 'ib_point1'},
  {name = 'ib_100box'},
  {name = 'ib_100boxopen'},
  {name = 'ib_point2'},
  {name = 'ib_300box'},
  {name = 'ib_300boxopen'},
  {name = 'ib_point3'},
  {name = 'cvs_50'},
  {name = 'cvs_100'},
  {name = 'cvs_300'},
  {name = 'lb_nobuff'},
  {name = 'lb_buff'},
  {name = 'lb_buff_time'},
  {name = 'lb_time'},
  {name = 'lb_guildqifu'},

  
  
  
  {name = 'btn_close',click = function ()
    self.menu:Close()
  end},
  
  
  
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_qifu.gui.xml", GlobalHooks.UITAG.GameUIGuildPray)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  
  
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
