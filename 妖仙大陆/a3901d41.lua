

local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ArenaModel  = require 'Zeus.Model.Arena'
local _M = {}
_M.__index = _M

local function Close(self)
  ArenaModel.RequestLeaveArenaArea(function ()
  	self.menu:Close()
  end)
end

local iconList = {
    "#dynamic_n/arena/arena.xml|arena|2",
    "#dynamic_n/arena/arena.xml|arena|1",
    "#dynamic_n/arena/arena.xml|arena|0",
    "#dynamic_n/arena/arena.xml|arena|3",
}

local Text = {
  exitDesc = Util.GetText(TextConfig.Type.SOLO,'arenaEndDesc'),
}

local function OnUpdateItem(node,index,ele)
	node.Visible = true
	local lb_rank = node:FindChildByEditName('lb_rank',false)
	local ib_rank = node:FindChildByEditName('ib_rank',false)
	local lb_name = node:FindChildByEditName('lb_name',false)
	local ib_headicon = node:FindChildByEditName('ib_headicon',true)
	local lb_jifen = node:FindChildByEditName('lb_jifen',false)
	lb_name.Text = ele.name
	lb_name.FontColorRGBA = GameUtil.GetProColor(ele.pro)
	lb_jifen.Text = ele.score

  if ib_rank~= nil then
    local iconIndex = index > 4 and 4 or index
    ib_rank.Layout = XmdsUISystem.CreateLayoutFroXml(iconList[iconIndex],LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
  end

  lb_rank.Text = Util.CSharpStringformat(Util.GetText(TextConfig.Type.SOLO,'oneRank'),index)
	
	
	
	
	
	
	
	
	
	
	
	
	
	Util.HZSetImage(ib_headicon,"static_n/hud/target/"..ele.pro..".png", false, LayoutStyle.IMAGE_STYLE_BACK_4)  	
end

local function OnEnter(self)
  local listdata = ArenaModel.battleData.s2c_scores
  local myIndex = ArenaModel.battleData.s2c_index
  local function UpdateListItem(gx,gy,node)
  	OnUpdateItem(node,gy+1,listdata[gy+1])
  end
  
  if self.sp_playerinfo.Rows <= 0 then
  	local s = self.cvs_playerinfo.Size2D
  	self.sp_playerinfo:Initialize(s.x,s.y,#listdata,1,self.cvs_playerinfo,UpdateListItem,function() end)
  else
  	self.sp_playerinfo.Rows = #listdata
  end
  OnUpdateItem(self.cvs_self,myIndex,ArenaModel.battleData.s2c_scores[myIndex])
  self.countDown = ArenaModel.battleData.endTime and ArenaModel.battleData.endTime or 60
  local passTime = 0
  AddUpdateEvent("Event.UI.ArenaUIEnd.Update", function(deltatime)
    passTime = passTime + deltatime
    if passTime >= 1 then
      
      passTime = 0
      
      self.countDown = self.countDown - 1
      local countDown = (self.countDown < 0 and 0) or self.countDown
      
      self.lb_backtext.Text = string.format(Text.exitDesc,countDown)
      if self.countDown <= 0 then
      	Close(self)
      end
    end
  end)
end

local function OnExit(self)
  
  RemoveUpdateEvent("Event.UI.ArenaUIEnd.Update", true)
end

local function OnDestory(self)
  
end

local ui_names = 
{
	{name = 'ib_headicon'},
	{name = 'sp_playerinfo'},
	{name = 'tb_backtext'},
	{name = 'btn_back',click = Close},
	{name = 'lb_rank'},
	{name = 'lb_name'},
	{name = 'lb_jifen'},
	{name = 'lb_backtext'},
	{name = 'cvs_jjcover'},
	{name = 'cvs_self'},
	{name = 'cvs_playerinfo'},
}

local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/arena/jjc_over.gui.xml',tag)
	Util.CreateHZUICompsTable(self.menu,ui_names,self)
	self.lb_backtext.SupportRichtext = true
  self.menu:SubscribOnExit(function ()
    OnExit(self)
  end)
  self.menu:SubscribOnEnter(function ()
    OnEnter(self)
  end)
  self.menu:SubscribOnDestory(function ()
    OnDestory(self)
  end)
  self.cvs_playerinfo.Visible = false
end

local function OnShowArenaEnd(...)
	GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMultiPvpEnd)	
end



local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

local function initial()
	EventManager.Subscribe("Event.ShowArenaEnd", OnShowArenaEnd)
end

_M.Create = Create
_M.Close  = Close
_M.initial = initial

return _M
