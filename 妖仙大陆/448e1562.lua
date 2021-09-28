local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local self = {}
local dataList={}
local PlayerSliver = 0
local isShowIcon = false


local function InitUI()
  local UIName = {
    "cvs_list",
    "lb_get",
    "ib_gold",
    "lb_goldnum",
    "sp_material",
    "cvs_icon",
  }

  for i=1,#UIName do
    self[UIName[i]] = self.menu:GetComponent(UIName[i])
  end

  HudManagerU.Instance:InitAnchorWithNode(self.cvs_list, bit.bor(HudManagerU.HUD_TOP))
end


local function IsIntable(list,code)
  for k,v in pairs(list) do
    if v.code == code then
      return k
    end
  end
  return nil
end

local function updateItemCell(data, node)
    if data == nil then
        node.Visible = false
        return
    end
    node.Visible = true
    local icon = node:FindChildByEditName("ib_icon", true)
    local it = GlobalHooks.DB.Find("Items",data.code)
    icon.Enable = true
    icon.EnableChildren = true
    local itshow = Util.ShowItemShow(icon,it.Icon,it.Qcolor, data.groupCount,true)
    Util.NormalItemShowTouchClick(itshow,data.code,false)
end

local function OnUpdateRewards(eventname,params)


  if params.data then
    for k,v in pairs(params.data) do
        local index =  IsIntable(dataList,v.code)
        if index then
          
          dataList[index].groupCount = dataList[index].groupCount + v.groupCount
        else
          table.insert(dataList,v)
        end
    end
  else
    return
  end
    local row = math.ceil(#dataList)
    local column = 5

  self.sp_material:Initialize(self.cvs_icon.Width+5, self.cvs_icon.Height+5, row,column , self.cvs_icon,
     LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
        local index = x+1+y*5
        local cellData = dataList[index]
        node.Enable = true
        node.EnableChildren = true
        updateItemCell(cellData, node)
      end
      ),
      LuaUIBinding.HZTrusteeshipChildInit(function (node)
        
      end)
  )
  self.sp_material.Visible = true

end

local function OnExit()
  EventManager.Unsubscribe("Event.UpdateLimitDungeonReards", OnUpdateRewards)
  DataMgr.Instance.UserData:DetachLuaObserver(self.menu.Tag)
  dataList = nil
  PlayerSliver = 0
  self.lb_goldnum.Text = ""
  self.lb_get.Visible = false
  self.ib_gold.Visible = false
  self.sp_material.Visible = false
  isShowIcon = false
end

function _M.Notify(status, subject,self)
  if subject:ContainsKey(status, UserData.NotiFyStatus.GOLD) then
      local nowSliver = math.floor(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD))
      local addSliver = math.floor(nowSliver - PlayerSliver)
      if addSliver > 0 then
        self.lb_goldnum.Text = addSliver
        if isShowIcon == false then
          self.lb_get.Visible = true
          self.ib_gold.Visible = true
          self.lb_goldnum.Visible = true
          isShowIcon = true
        end
      end
    end
end


local function OnEnter()
    dataList={}
    EventManager.Subscribe("Event.UpdateLimitDungeonReards", OnUpdateRewards)
    PlayerSliver = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GOLD)
    DataMgr.Instance.UserData:AttachLuaObserver(self.menu.Tag,self)
    self.Notify(UserData.NotiFyStatus.ALL, DataMgr.Instance.UserData,self)
end

local function  Init( params )
  self.m_Root = LuaMenuU.Create("xmds_ui/res/res_reward.gui.xml", GlobalHooks.UITAG.GameUIFightLimitReward)
  self.menu = self.m_Root
  self.menu.Enable = false
  self.menu.EnableChildren = true
  self.menu.mRoot.Enable = false
  InitUI()
  self.menu:SubscribOnEnter(OnEnter)
  self.menu:SubscribOnExit(OnExit)
    return self.menu
end

local function Create(params)
    self = { }
    setmetatable(self, _M)
     Init(params)
    return self
end

return {Create = Create}
