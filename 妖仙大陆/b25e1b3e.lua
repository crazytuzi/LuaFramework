local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GardenApi = require "Zeus.Model.Garden"
local GardenUtil = require 'Zeus.UI.XMasterGarden.GardenUtil'

local self = {
    menu = nil,
}

local function RefreshFriendCellData(cell, data)
  local ib_player_icon = node:FindChildByEditName("ib_player_icon",true)
  Util.SetHeadImgByPro(ib_player_icon,data.pro)

  local ib_rank_num = node:FindChildByEditName("ib_rank_num",true)
  ib_rank_num.Text = data.lv

  local lb_player_name = cell:FindChildByEditName("lb_player_name",true)
  lb_player_name.Text = data.roleName
  lb_player_name.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(data.pro))

  local lb_union_name = node:FindChildByEditName("lb_union_name",true)
  lb_union_name.Text = data.guildName or ""

  local ib_picture1 = node:FindChildByEditName("ib_picture1",true)
  ib_picture1.Visible = data.canWater > 0

  local ib_picture2 = node:FindChildByEditName("ib_picture2",true)
  ib_picture2.Visible = data.canSteal > 0

  local btn_invite = node:FindChildByEditName("btn_invite",true)
  btn_invite.TouchClick = function (sender)
      GardenApi.ReqEnterMyfarm(data.playerId)
  end
end

local function RefreshRecordCellData(cell, data)
  cell.XmlText = GardenUtil.SubHTML_str(data)
end

local function RefreshFriendsUI()
    self.sp_playermove:Initialize(
        self.cvs_get_single.Width + 0, 
        self.cvs_get_single.Height + 0, 
        #self.myFriendsGardenData,
        1,
        self.cvs_get_single, 
        function(x, y, cell)
            local index = y + 1
            local data = self.myFriendsGardenData[index]
            RefreshFriendCellData(index, cell, data)
        end,
        function(cell)
            cell.Visible = true
        end
    )
end

local function RefreshMainUI()
    local row = 0
    if self.myGardenData.recordLs then
        row = #self.myGardenData.recordLs
    end
    self.sp_show:Initialize(
        self.tb_cell.Width + 0, 
        self.tb_cell.Height + 0, 
        row,
        1,
        self.tb_cell, 
        function(x, y, cell)
            local index = y + 1
            local data = self.myGardenData.recordLs[index]
            RefreshRecordCellData(cell, data)
        end,
        function(cell)
            cell.Visible = true
        end
    )

    self.lb_num.Text = self.myGardenData.curSeedNum .. "/" .. self.myGardenData.maxSeedNum
    self.lb_time.Text = self.myGardenData.minHarvestTime
    self.lb_num1.Text = self.myGardenData.friendsHelpNum
end

local function SwitchPage(sender)
  if sender == self.tbt_mine then
      self.cvs_wanjia.Visible = false
      GardenApi.ReqMyfarmInfo(function(data)
          self.cvs_main.Visible = true
          self.myGardenData = data
          RefreshMainUI()
      end)
  else
      self.cvs_main.Visible = false
      GardenApi.ReqFriendsfarmInfo(function(data)
          self.cvs_wanjia.Visible = true
          self.myFriendsGardenData = data
          RefreshFriendsUI()
      end)
  end
end

local function OnEnter()
  self.tbt_mine.IsChecked = true
end

local function OnExit()

end

local function initUI()
  Util.InitMultiToggleButton(
    function (sender)
      SwitchPage(sender)
    end, 
  nil, {self.tbt_mine,self.tbt_friends})

  self.cvs_main.Visible = false
  self.cvs_wanjia.Visible = false

  self.tb_cell.Visible = false
  self.cvs_wanjia.Visible = false
  self.cvs_single.Visible = false

  self.btn_go.TouchClick = function (sender)
      GardenApi.ReqEnterMyfarm("")
  end
end

local ui_names = 
{
  
  {name = 'btn_close',click = function ()
    self.menu:Close()
  end},
  {name = 'tbt_mine'},
  {name = 'tbt_friends'},
  {name = 'cvs_main'},
  {name = 'sp_show'},
  {name = 'tb_cell'},
  {name = 'cvs_wanjia'},
  {name = 'sp_playermove'},
  {name = 'cvs_single'},
  {name = 'lb_num'},
  {name = 'lb_time'},
  {name = 'lb_num1'},
  {name = 'btn_go'},
}

local function InitCompnent()
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/garden/guoyuan.gui.xml", GlobalHooks.UITAG.GameUIGardenMain)
  self.menu.Enable = true
  self.menu.mRoot.Enable = true
  self.menu.ShowType = UIShowType.HideBackHud
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
