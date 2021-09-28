local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GDRQ = require "Zeus.Model.Guild"
local GuildUtil = require 'Zeus.UI.XmasterGuild.GuildUtil'

local self = {
    menu = nil,
}

local retGuildRecord = GlobalHooks.DB.Find("GuildRecord", {})

local function GetTextConfg(key)
  return ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.GUILD, key)
end

local function ShowRecord(indexPage)
  self.tb_cell.Visible = false
  if self.GuildRecord[indexPage]==nil then
    self.GuildRecord[indexPage] = {}
    self.tb_cell.XmlText = ""
    return
  end
  local maxCellNum = #self.GuildRecord[indexPage]
  for i=1,maxCellNum do
    local lable = self.oldLables[indexPage][i]
    if not lable then
      lable = self.tb_cell:Clone()
      lable.Visible = true
      self.oldLables[indexPage][i] = lable
      self.tb_cell.Parent:AddChild(lable)
    end
    lable.XmlText = GuildUtil.SubHTML_str(self.GuildRecord[indexPage][i])
    local lableY = 40
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

local function OnEnter()
  remove50outRecord()
  self.sp_see.Scrollable.Container.Y = 0
  GDRQ.getGuildRecordRequest(1,function ()
    self.GuildRecord = GDRQ.getGuildRecord()
    ShowRecord(1)
  end)
end

local function OnExit()
  self.isRushRq = false
end

local function initUI()
  self.oldLables = {{},{},{},{},{}}
  self.NoticLastCells = {{},{},{},{},{}}
  self.sp_see.Scrollable.event_Scrolled = function ()
    if self.sp_see.Scrollable.Container.Y > -(24*50) then
      return
    end
    local size = -(self.sp_see.Scrollable.Container.Height-self.sp_see.Height+70)
    if not self.isRushRq and self.sp_see.Scrollable.Container.Y < size then
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
      GDRQ.getGuildRecordRequest(pagenum,function (indexPage)
        self.RqRecordTime = os.time()
        self.isRqRecording = false
        self.GuildRecord = GDRQ.getGuildRecord()
        ShowRecord(indexPage)
        self.isRushRq = false
      end)
    end
  end
end

local ui_names = 
{
  
  {name = 'sp_see'},
  {name = 'tb_cell'},
}

local function InitCompnent()
  local closebtn = self.menu:FindChildByEditName("btn_close",true)
  closebtn.TouchClick = function ()
    self.menu:Close()
  end
  Util.CreateHZUICompsTable(self.menu,ui_names,self)
  initUI()
end

local function Init(params)
  self.menu = LuaMenuU.Create("xmds_ui/guild/guild_dongtai.gui.xml", GlobalHooks.UITAG.GameUIGuildDynamic)
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
