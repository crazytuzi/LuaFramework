local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.guildAuction"
local ServerTime = require "Zeus.Logic.ServerTime"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"

local self = {
    menu = nil,
}

local function SetRecordLabel(label, data)
  local Targetstr = self.retRecord[data.id].RecordMsg

  local timestr = string.format("<f color='ff00d600'>%s</f>",data.time)
  local role = string.format("<f color='%x'>%s</f>",0xFF00FF00,data.role1)
  local num = string.format("<f color='%x'>%s</f>",0xFF00FF00,data.num)
  local itemStr = string.format("<f color='%x'>%s</f>",0xFF00FF00,data.item)

  local string = string.gsub('<b size="18">'..Targetstr..'</b>','{(%w+)}',{RecordTime=timestr,Role1=role,Num=num,item=itemStr})
  label.XmlText = string
end

local function ReqAuctionRecord()
  GDRQ.AuctionLogRequest(function(data)
    local recordlist = data.s2c_log or {}
    self.sp_record:Initialize(self.cvs_record_item.Width, self.cvs_record_item.Height+5, #recordlist, 1, self.cvs_record_item, 
      function(x, y, cell)
          local data = recordlist[y + 1]
          local tbx_wenben = cell:FindChildByEditName("tbx_wenben", true)
          SetRecordLabel(tbx_wenben, data)
      end,
      function()
      end
    )
  end)
end

local function CleanCdlabel()
  if self.cdUpdateList then
    for i,v in ipairs(self.cdUpdateList) do
      v:stop()
    end
  end
  self.cdUpdateList = {}
end

local function AddCdlabel(lb,time)
  local function format(cd,label)
      if cd <= 0 then
          cd = 0 
      end
      return ServerTime.GetTimeStr(cd)
  end
  local cdUpdate = CDLabelExt.New(lb,time,format)
  cdUpdate:start()
  table.insert(self.cdUpdateList, cdUpdate)
end

local function ReqJingPai(id, price)
    if price > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
          GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, 
              Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan"), 
              Util.GetText(TextConfig.Type.SHOP, "OK"), 
              Util.GetText(TextConfig.Type.SHOP, "Cancel"), 
              Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu"), 
              nil, 
              function()
                  GDRQ.AuctionRequest(id, price,function()
                  end)
              end, 
              function()
              end
          )
    else
          GDRQ.AuctionRequest(id, price,function()
          end)
    end
end

local function RefreshCellData(params, cell, data)
  local ib_icon = cell:FindChildByEditName("ib_icon", true)
  ib_icon.Enable = true
  ib_icon.EnableChildren = true
  local it = GlobalHooks.DB.Find("Items",data.detail.code)
  local itshow = Util.ShowItemShow(ib_icon,it.Icon,it.Qcolor,data.num or 1, true)
  Util.NormalItemShowTouchClick(itshow,data.detail.code)

  local lb_des = cell:FindChildByEditName("lb_des", true)
  lb_des.Text = data.source

  local lb_name = cell:FindChildByEditName("lb_name", true)
  lb_name.Text = it.Name

  local ib_time1 = cell:FindChildByEditName("ib_time1", true)
  local ib_time2 = cell:FindChildByEditName("ib_time2", true)
  ib_time1.Text = ServerTime.GetTimeStr(data.timeleft)
  ib_time2.Visible = data.state == 1
  AddCdlabel(ib_time1, data.timeleft)

  local lb_jingpai_price = cell:FindChildByEditName("lb_jingpai_price", true)
  local lb_yikou_price = cell:FindChildByEditName("lb_yikou_price", true)
  lb_jingpai_price.Text = data.curPrice
  lb_yikou_price.Text = data.maxPrice

  local btn_jingpai = cell:FindChildByEditName("btn_jingpai", true)
  local btn_yikou = cell:FindChildByEditName("btn_yikou", true)
  btn_jingpai.Enable = not data.self
  btn_jingpai.IsGray = data.self
  btn_yikou.Enable = not data.self
  btn_yikou.IsGray = data.self

  btn_jingpai.TouchClick = function ()
    ReqJingPai(data.id, data.curPrice)
  end

  btn_yikou.TouchClick = function ()
    ReqJingPai(data.id, data.maxPrice)
  end
end

local function InitItemList(index)
  CleanCdlabel()

  self.sp_items.Scrollable.Container:RemoveAllChildren(true)

  for i=1,#self.itemList do
      local cell = self.cvs_item:Clone()
      cell.Y = self.cvs_item.Y + self.cvs_item.Height*(i-1)
      RefreshCellData(index, cell, self.itemList[i])
      self.sp_items.Scrollable.Container:AddChild(cell)
  end

  
  
  
  
  
  
  
  
end

local function SortItemList()
  table.sort(self.itemList, function (aa,bb)
      local aaIt = GlobalHooks.DB.Find("Items",aa.detail.code)
      local bbIt = GlobalHooks.DB.Find("Items",bb.detail.code)
      if aa.state > bb.state then
          return true
      elseif aa.state == bb.state then
          if aaIt.Qcolor > bbIt.Qcolor then
              return true
          elseif aaIt.Qcolor == bbIt.Qcolor then
                if aa.num > bb.num then
                    return true
                elseif aa.num == bb.num then
                    return aa.timeleft < bb.timeleft
                end
          end
      end
      return false
  end)
end

local function SetGuildAuctionFlag()
  local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_AUCTION)
  MenuBaseU.SetVisibleUENode(self.menu,"lb_guild_paimai", num ~= 0)

  local num1 = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WORLD_AUCTION)
  MenuBaseU.SetVisibleUENode(self.menu,"lb_world_mine", num1 ~= 0)
end

local function SwitchAuctionList()
  local index = self.selectTag
  GDRQ.AuctionListRequest(index, function (data)
    
    self.itemList = data.s2c_data or {}
    SortItemList()
    InitItemList(index)
    self.cvs_bonus.Visible = index == 1
    self.lb_bonus_num.Text = data.s2c_bonus or 0
  end)

  SetGuildAuctionFlag()
end

local function UpdateItemList(eventname,params)
  if not self.itemList then 
    return 
  end

  local needSwitch = false
  if params.update == "Update" or params.update == "Remove"then
    local id = params.data.id or params.data.s2c_item.id
    for i,v in ipairs(self.itemList) do
      if v.id == id then
        needSwitch = true
        break
      end
    end
  end

  if needSwitch then
    SwitchAuctionList()
  end
end

local function OnEnter()
  self.cvs_record.Visible = false
  self.itemList = nil

  GDRQ.SyncAuctionInfoRequest(function ()
      self.tbt_guild_paimai.IsChecked = true
      
      EventManager.Subscribe("Event.GuildAuction.Update", UpdateItemList)
  end)
end

local function OnExit()
  GDRQ.CancelSyncAuctionInfoRequest()
  EventManager.Unsubscribe("Event.GuildAuction.Update", UpdateItemList)
  CleanCdlabel()
end

local ui_names = 
{
  
  {name = 'tbt_guild_paimai'},
  {name = 'tbt_world_mine'},
  {name = 'tbt_mine_paimai'},
  {name = 'cvs_item'},
  {name = 'sp_items'},

  {name = 'cvs_bonus'},
  {name = 'lb_bonus_num'},
  {name = 'btn_record'},

  {name = 'cvs_record'},
  {name = 'cvs_record_item'},
  {name = 'sp_record'},
  {name = 'btn_record_close'},

  {name = 'lb_guild_paimai'},
  {name = 'lb_world_mine'},
  {name = 'cvs_intrduce'},
  {name = 'lb_location'},
  {name = 'tb_intrduce'},
  {name = 'btn_instruction'},
  {name = 'btn_intrduce'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)

  self.cvs_item.Visible = false
  self.cvs_record_item.Visible = false
  self.cvs_record.Visible = false
  self.cvs_bonus.Visible = false


  self.tbt_guild_paimai.UserTag = 1
  self.tbt_world_mine.UserTag = 2
  self.tbt_mine_paimai.UserTag = 3

  self.cvs_record.TouchClick = function ()
    self.cvs_record.Visible = false
  end


  self.btn_record.TouchClick = function ()
    self.cvs_record.Visible = true
    ReqAuctionRecord()
  end

  local auction_title = Util.GetText(TextConfig.Type.GUILD, "auction_title")
  local auction_content = Util.GetText(TextConfig.Type.GUILD, "auction_notice")
    
  self.btn_instruction.TouchClick = function()
    self.lb_location.Text = auction_title
    self.lb_location.FontColorRGBA = 0xff00a0ff
    self.tb_intrduce.Text  = string.format(auction_content,"\n","\n","\n","\n","\n")
    if self.cvs_intrduce.Visible == false then
      self.cvs_intrduce.Visible = true
    end
  end
  self.btn_intrduce.TouchClick = function()
    if self.cvs_intrduce.Visible == true then
      self.cvs_intrduce.Visible = false
    end
  end 

  self.btn_record_close.TouchClick = function ()
    self.cvs_record.Visible = false
  end

  Util.InitMultiToggleButton(function (sender)
    self.selectTag = sender.UserTag
    SwitchAuctionList()
  end,nil,{self.tbt_guild_paimai,self.tbt_mine_paimai,self.tbt_world_mine})

  self.retRecord = GlobalHooks.DB.Find("AuctionRecord",{})
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_auction.gui.xml", GlobalHooks.UITAG.GameUIGuildAuction)
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
