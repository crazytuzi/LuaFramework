local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ActivityModel = require"Zeus.Model.Activity"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local ServerTime = require "Zeus.Logic.ServerTime"
local ItemModel = require 'Zeus.Model.Item'
local self = {dataList=nil,btnList=nil,_dataList=nil,
isbuy=nil,gotorecharge=nil,btnOK=nil,btnCancel=nil,isbuyed=nil}
local idStatleList={}

local function InitUI()
  
  local lrt = XmdsUISystem.CreateLayoutFromFile('static_n/shade.png',LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    self.menu:SetFullBackground(lrt)
  local UIName = {
    "btn_close",
    "btn_charge",
    "cvs_first",
    "ib_icon",
    "sp_list",
    "lb_time",
    "cvs_btn_list",
    "tbt_libao",
    "lb_price",
    "ib_desc1",
    "ib_desc2_num",
  }
  for i=1,#UIName do
    self[UIName[i]] = self.menu:GetComponent(UIName[i])
  end
  self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
          self.menu:Close()
      end
    end
end

local function InitText()
  self.isbuy = Util.GetText(TextConfig.Type.SIGN, "isbuy")
  self.gotorecharge = Util.GetText(TextConfig.Type.SIGN, "gotorecharge")
  self.btnOK = Util.GetText(TextConfig.Type.SIGN, "btnOK")
  self.btnCancel = Util.GetText(TextConfig.Type.SIGN, "btnCancel")
  self.isbuyed = Util.GetText(TextConfig.Type.SIGN, "isbuyed")
end

local function UpdateLimitTimeStr( timeSeq,label )
    local last = math.floor(timeSeq)
    local h = math.floor(last/3600)
    local m = math.floor(last/60)-h*60
    local s = last-m*60-3600*h
    if h == 0 then
        h = ""
    elseif h < 10 then
        h = "0"..h..":"
    else
        h = h..":"
    end
    if m == 0 then
        m = "00"..":"
    elseif m < 10 then
        m = "0"..m..":"
    else
        m = m..":"
    end
    if s == 0 then
        s = "00"
    elseif s < 10 then
        s = "0"..s
    end
    label.Text = h..m..s
    return  
end

local function stopCdLabel()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
end

local function UpdatePageRewards(sender)

 stopCdLabel()               
 local function format(cd,label)
     if cd <= 0 then 
      self.menu:Close()
    else
       UpdateLimitTimeStr(cd,label)
    end
  end
  self.CDLabelExt = CDLabelExt.New(self.lb_time,self._dataList[sender.UserTag].secondRemain,format,nil,1) 
  self.CDLabelExt:start()

  
    local data = string.split(self.datalist[sender.UserTag].RewardItem,";")
    self.lb_price.Text = self.datalist[sender.UserTag].Price
    
    
    local imageAtlas = self.datalist[sender.UserTag].AtlasRoute
    local atlasList = string.split(self.datalist[sender.UserTag].AtlasID,",")
    local layout = XmdsUISystem.CreateLayoutFroXml(imageAtlas..atlasList[3], LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
    self.ib_desc1.Layout = layout
    local layout2 = XmdsUISystem.CreateLayoutFroXml(imageAtlas..atlasList[4], LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
    self.ib_desc2_num.Layout = layout2

  local function GetStatus()
      if idStatleList ~= nil then
       for k,v in pairs(idStatleList) do
         if v == self._dataList[sender.UserTag].id then
            return true
           end
       end
    end
    return false
  end
    self.btn_charge.TouchClick = function()
      local diamond = ItemModel.GetDiamond()
      if GetStatus() then 
        GameAlertManager.Instance:ShowNotify(self.isbuy)
      else 
        if diamond < self.datalist[sender.UserTag].Price then 
           GameAlertManager.Instance:ShowAlertDialog(
                  AlertDialog.PRIORITY_NORMAL,
                  gotorecharge,btnOK,btnCancel,nil,
                  function()
                       GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIShop, -1,"pay")
                  end ,
                  nil
                  )
        else
           GameAlertManager.Instance:ShowAlertDialog(
                  AlertDialog.PRIORITY_NORMAL,
                  Util.GetText(TextConfig.Type.SIGN, "buyproduct",self.datalist[sender.UserTag].Price),self.btnOK,self.btnCancel,nil,
                  function()
                      ActivityModel.LimitTimeGiftBuyRequest(self._dataList[sender.UserTag].id,function(params)
                      if params.s2c_code == 200 then
                        stopCdLabel() 
                        table.insert(idStatleList,self._dataList[sender.UserTag].id)
                        self.lb_time.Text = self.isbuyed
                        self.btn_charge.IsGray = true
                        if #self._dataList <= 1 and self ~= nil and self.menu ~= nil then
                          self.menu:Close()
                        end
                      end
                    end)
                  end ,
                  nil
                  )
        end
      end
    end

  if GetStatus() then 
    stopCdLabel()
    self.lb_time.Text = self.isbuyed
    self.btn_charge.IsGray = true
  else
    self.btn_charge.IsGray = false
  end
   
    local rewardIcon={}
    local rewardNum={}
    for j=1,#data do
      local itemParame = string.split(data[j],":")
      table.insert(rewardIcon,itemParame[1])
      table.insert(rewardNum,itemParame[2]) 
    end
     self.sp_list:Initialize(self.ib_icon.Width+10, self.ib_icon.Height, 1, #rewardIcon, self.ib_icon, 
      function(x, y, cell)
          local index = x + 1
          local code = rewardIcon[index]
          local it = GlobalHooks.DB.Find("Items",code)
          cell.Enable = true
          cell.EnableChildren = true
          local itshow = Util.ShowItemShow(cell,it.Icon,it.Qcolor, rewardNum[index],true)
          Util.NormalItemShowTouchClick(itshow,code,false)
      end,
      function()
      end
  )
end

local function OnEnter()

  ActivityModel.LimitTimeGiftInfoRequest(function(data)
      
      self.datalist = {}
      self.btnList = {}
      self._dataList={}
      self.cvs_btn_list:RemoveAllChildren(true)
      local dataSource = data.limitTimeGiftInfo

      table.sort( dataSource, function (a,b)
        return a.secondRemain < b.secondRemain
      end )

      local  atlas = XmdsUISystem.CreateAtlas("dynamic_n/questgift/questgift.xml","questgift")
      for k,v in pairs(dataSource or {}) do
        local info = GlobalHooks.DB.Find("LimitTimeGift", {Id = v.id })[1]
        table.insert(self.datalist, info)
        table.insert(self._dataList,v)
        local btn = self.tbt_libao:Clone()
        btn.X = self.tbt_libao.X
        btn.Y = self.tbt_libao.Y + self.tbt_libao.Height*(k-1)
        local btnAtlasList = string.split(info.AtlasID,",")
        btn:SetAtlasImageText(atlas, tonumber(btnAtlasList[2]), atlas, tonumber(btnAtlasList[1]))
        btn.UserTag = k
        btn.Visible = true
        self.cvs_btn_list:AddChild(btn)
        table.insert(self.btnList, btn)
      end
       local serverTime = ServerTime.GetServerUnixTime()
       AddUpdateEvent("Event.Activity.UpdateLimitGift", function(deltatime)
              local newServerTime = ServerTime.GetServerUnixTime()
              for k,v in pairs(self._dataList) do
                v.secondRemain = v.secondRemain - (newServerTime - serverTime)
                if v.secondRemain < 0 then
                  v.secondRemain = 0
                end
              end
              serverTime = newServerTime
          end)

      Util.InitMultiToggleButton(function (sender)
        UpdatePageRewards(sender)
    end,self.btnList[#self.btnList],self.btnList) 
  end)
end

local function OnExit()
  stopCdLabel()
  RemoveUpdateEvent("Event.Activity.UpdateLimitGift", true)
  self.dataList=nil
  self.btnList=nil
  self._dataList=nil
  if idStatleList ~= nil then table.remove(idStatleList) end
end

local function  Init( params )
  self.m_Root = LuaMenuU.Create("xmds_ui/carnival/questgift.gui.xml", GlobalHooks.UITAG.GameUILimitGift)
  self.menu = self.m_Root
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  InitUI()
  InitText()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
  self.menu:SubscribOnDestory(function()
          self = nil
      end)
   
    return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
     Init(params)
    return self
end

return {Create = Create}
