
local Util 			= require 'Zeus.Logic.Util'
local _M = {}
_M.__index = _M

local function Close(self)
	if self.player_info ~= nil and self.player_info.activeMenuCb ~= nil then
		
		self.player_info.activeMenuCb(-1, self.player_info)
	end
  	self.menu:Close()  
end

local ui_names = 
{
	
	
	{name = 'btn_close', click = Close},	
	{name = 'cvs_head'},
	{name = 'ib_head'},
	{name = 'lb_name'},

	{name = 'cvs_main'},
	{name = 'btn_number1'},
	{name = 'cvs_buttons'}
}

local function OnShowPlayerDetail(playerId)
	print('TODO show Player   :   '.. playerId)
    local InteractiveMenu = require "Zeus.UI.InteractiveMenu"	
	local fromType = InteractiveMenu.SOCIAL_COMMON
    local job = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.GUILDJOB)
    if job == 1 or job == 2 then
    	fromType = InteractiveMenu.SOCIAL_COMMON_GUILDMASTER
    end

    local id = BattleClientBase.GetPlayerUUID(playerId)
    local info = {
		type = fromType,
		player_info = {
			playerId = id,
			name =  BattleClientBase.GetPlayerName(playerId),
			lv = BattleClientBase.GetPlayerLev(playerId),
			pro = BattleClientBase.GetPlayerPro(playerId),
			activeMenuCb = nil,
		}
	}

    local VSAPI = require "Zeus.Model.VS"
    VSAPI.requestPlayerInfo(id, function(data)
    	info.player_info.guildName = data.guildName
    	info.player_info.upLv = data.upOrder
    	EventManager.Fire("Event.ShowInteractive", info )
    end,
    function()
    	EventManager.Fire("Event.ShowInteractive", info )
    end)
end

local function InitComponent(self,tag)
	self.menu = LuaMenuU.Create('xmds_ui/common/common_interactive2.gui.xml',tag)
	self.menu.ShowType = UIShowType.Cover

	Util.CreateHZUICompsTable(self.menu,ui_names,self)
	self.menu.event_PointerClick = function (sender)
		Close(self)
	end

	Util.HZClick(self.cvs_head, function (sender)
		Close(self)
		OnShowPlayerDetail(sender.UserTag)
	end)
	
	self.playerBtnHeight = self.btn_number1.Height
	self.playerBtns = {}
	self.playerBtns[1] = self.btn_number1
	self.playerBtns[1].TouchClick = function(sender)
		Close(self)
		OnShowPlayerDetail(sender.UserTag)
	end
	
	local lg = self.cvs_buttons:AddComponent(typeof(UnityEngine.UI.VerticalLayoutGroup))
	lg.childForceExpandHeight = false
end


local function AddLayoutElementComponent(node)
	local ret = node.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
	if ret == nil then
		ret = node:AddComponent(typeof(UnityEngine.UI.LayoutElement))
	end
	return ret
end

local function ShowPlayerList(self,params)
	self.cvs_main.Visible = true
	self.cvs_head.Visible = false

	for i = 1,#params do 
		if self.playerBtns[i] == nil then
			self.playerBtns[i] = self.btn_number1:Clone()
			self.cvs_buttons:AddChild(self.playerBtns[i])	
			self.playerBtns[i].TouchClick = function(sender)
				Close(self)
				OnShowPlayerDetail(sender.UserTag)
			end
		end

		local le = AddLayoutElementComponent(self.playerBtns[i])
		le.preferredHeight = self.playerBtnHeight 
		
		self.playerBtns[i].UserTag = params[i]
		self.playerBtns[i].Text = BattleClientBase.GetPlayerName(params[i])
	end  
end


local function ShowPlayer(self,params)
	self.cvs_main.Visible = false
	self.cvs_head.Visible = true

	local playerId = params[1]
	self.cvs_head.UserTag = playerId
	
	local playerName = BattleClientBase.GetPlayerName(playerId)
	self.lb_name.Text = playerName
	
	local playerPro =  BattleClientBase.GetPlayerPro(playerId)
	Util.SetHeadImgByPro(self.ib_head , playerPro)
end

local function SetParams(self,params)
	if #params > 1 then
		ShowPlayerList(self,params)
	else
		ShowPlayer(self,params)
	end
	self.playersInfo = params
end

local function OnShowInteractive2Menu(eventname,params)
	
	local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)

    local isSolo = PublicConst.SceneType.SOLO == sceneType
    local isArena = PublicConst.SceneType.ARENA == sceneType
    
    
    
    
    
    
    
    
    local is5v5 = PublicConst.SceneType.FiveVSFive == sceneType
    
	if isSolo or isArena or is5v5 then
		return
	end
	local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIInteractive2,0)
	SetParams(obj,params)
end

local function initial()
	EventManager.Subscribe("Event.ShowInteractive2", OnShowInteractive2Menu)
end


local function Create(tag,type_str)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag,type_str)
  return ret
end


_M.Create = Create
_M.initial = initial
_M.Close = Close
_M.SetParams = SetParams
return _M
