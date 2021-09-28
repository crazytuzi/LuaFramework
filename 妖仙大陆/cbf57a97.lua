local Helper = require 'Zeus.Logic.Helper'
local Util   = require 'Zeus.Logic.Util'
local ArenaModel = require 'Zeus.Model.Arena'
local _M = {}
_M.__index = _M

local function Close(self)
  self.menu:Close()  
end


local iconList = {
    "#dynamic_n/arena/arena.xml|arena|2",
    "#dynamic_n/arena/arena.xml|arena|1",
    "#dynamic_n/arena/arena.xml|arena|0",
    "#dynamic_n/arena/arena.xml|arena|3",
}

local function FillListItem(node,ele)
	local lb_rank = node:FindChildByEditName('lb_rank',false)
	local ib_rank = node:FindChildByEditName('ib_rank',false)
	local lb_name = node:FindChildByEditName('lb_player_name',false)
	local lb_level = node:FindChildByEditName('lb_level',false)
	local lb_single = node:FindChildByEditName('lb_single',false)
	local lb_killnum = node:FindChildByEditName('lb_killnum',false)
	local ib_headicon = node:FindChildByEditName('ib_headicon',true)
	local lb_noneranking = node:FindChildByEditName('lb_noneranking',false)
	lb_name.Text = ele.playerName
	lb_name.FontColorRGBA = GameUtil.GetProColor(ele.pro)

    if ib_rank~= nil then
        local iconIndex = select_index > 4 and 4 or select_index
        ib_rank.Layout = XmdsUISystem.CreateLayoutFroXml(iconList[iconIndex],LayoutStyle.IMAGE_STYLE_BACK_4_CENTER,8)
    end

	
	
	

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

	lb_rank.Text = Util.CSharpStringformat(Util.GetText(TextConfig.Type.SOLO,'oneRank'),ele.index)
	if ele.upLevel > 0 then
		local txt,rgba = Util.GetUpLvTextAndColorRGBA(ele.upLevel)
		lb_level.Text = txt
		lb_level.FontColorRGBA = rgba
	else
		lb_level.Text = ele.level
	end
	
	lb_single.Text = tostring(ele.arenaSingleWinTimes or 0)
	lb_killnum.Text = tostring(ele.arenaMaxKillCount or 0)

	Util.HZSetImage(ib_headicon,"static_n/hud/target/"..ele.pro..".png", false, LayoutStyle.IMAGE_STYLE_BACK_4)
	
end

local function FillList(self)
	
	if self.data.s2c_lists then
		local s = self.cvs_playerinfo.Size2D
		self.sp_playerinfo:Initialize(s.x,s.y,#self.data.s2c_lists,1,self.cvs_playerinfo,
			function (gx,gy,node)
				FillListItem(node,self.data.s2c_lists[gy+1])
			end,function() end)  			
	end

	if not self.data.s2c_myData then
		self.data.s2c_myData = {
			playerName = DataMgr.Instance.UserData.Name,
			level = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL),
			upLevel = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.UPLEVEL),
			pro = DataMgr.Instance.UserData.Pro,
		}
	end
  if self.data.s2c_myData then
  	self.cvs_selfinfo.Visible = true
		
		FillListItem(self.cvs_selfinfo, self.data.s2c_myData)
  end

end

function _M:OnEnter()
  
  	self.cvs_selfinfo.Visible = false
	
	ArenaModel.RequestArenaRankList(function (data)
		self.data = data
		
		FillList(self)
	end)
end

function _M:OnExit()

end

local function OnDestory(self)
  
end

local ui_names = 
{
	{name = 'cvs_playerinfo'},
	{name = 'cvs_selfinfo'},
	{name = 'sp_playerinfo'},
}


local function InitComponent(self,tag)
	
	self.menu = LuaMenuU.Create('xmds_ui/arena/jjc_ranklist.gui.xml',tag)
	Util.CreateHZUICompsTable(self.menu,ui_names,self)
	self.menu.Enable = false
	self.cvs_playerinfo.Visible = false

end


local function Create(tag)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag)
  return ret
end

_M.Create = Create
_M.Close  = Close

return _M
