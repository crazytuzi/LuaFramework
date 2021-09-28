
local Helper 		= require 'Zeus.Logic.Helper'
local Util 			= require 'Zeus.Logic.Util'
local FriendModel 	= require "Zeus.Model.Friend"
local ChatModel 	= require "Zeus.Model.Chat"
local Team 			= require "Zeus.Model.Team"
local MapModel 		= require "Zeus.Model.Map"
local Transaction 	= require "Zeus.Model.Transaction"
local Guild 		= require "Zeus.Model.Guild"
local ChatUtil      = require "Zeus.UI.Chat.ChatUtil"
local PlayerModel   = require 'Zeus.Model.Player'


local cjson = require"cjson"  
local _M = {}
_M.__index = _M


local function Close(self)
	if self.player_info ~= nil and self.player_info.activeMenuCb ~= nil then
		
		self.player_info.activeMenuCb(-1, self.player_info)
	end
	for i=1,#self.btnList do
		self.btnList[i]:RemoveFromParent(true)
	end

  	self.menu:Close()  
end

local ui_names = 
{
	
	
	{name = 'btn_close', click = Close},
	{name = 'btn_number'},
	{name = 'tb_name'},
	{name = 'cvs_head'},
	{name = 'ib_head'},
	{name = 'lb_lv'},
	{name = 'lb_guild'},
	{name = 'lb_upLv'},
	{name = 'cvs_interactive'},
}

local function OnFuncClick(sender, self)
	local id = tonumber(sender.UserData)
	
	
	if id == 1 then
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSPlayer, 0, self.player_info.playerId)
		
	elseif id == 2 then 
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		EventManager.Fire('Event.SocialFriend.SetPrivateChatId', {id = self.player_info.playerId})
		self:Close()
	elseif id == 3 then 
		FriendModel.friendApplyRequest(self.player_info.playerId, function(params)
			local tips = ConfigMgr.Instance.TxtCfg:GetTextByKey(TextConfig.Type.PUBLICCFG, "friendAdd")
			GameAlertManager.Instance:ShowNotify(tips)
		end)
		if self.player_info.activeMenuCb ~= nil then
			self.player_info.activeMenuCb(id, self.player_info)
		end
		self:Close()
	elseif id == 4 then 
		Guild.joinGuildOfPlayerRequest(self.player_info.playerId,function ()end)
		self:Close()
	elseif id == 5 then 
		local inviteFun = function ()
			Team.RequestInviteTeam(self.player_info.playerId)
			if self.player_info.activeMenuCb ~= nil then
				self.player_info.activeMenuCb(id, self.player_info)
			end
	        self:Close()
		end
		
		
		
		
			inviteFun()
		
	elseif id == 6 then 
		Team.RequestApplyTeam(self.player_info.playerId)
		if self.player_info.activeMenuCb ~= nil then
			self.player_info.activeMenuCb(id, self.player_info)
		end
        self:Close()
	elseif id == 10 then 
		Team.RequestKickOutTeam(self.player_info.playerId)
		if self.player_info.activeMenuCb ~= nil then
			self.player_info.activeMenuCb(id, self.player_info)
		end
        self:Close()
	elseif id == 11 then 
		Team.RequestChangeLeader(self.player_info.playerId)
		if self.player_info.activeMenuCb ~= nil then
			self.player_info.activeMenuCb(id, self.player_info)
		end
        self:Close()
	elseif id == 13 then 
		FriendModel.friendDeleteRequest(self.player_info.playerId, function(params)
			
			self.player_info.activeMenuCb(id, self.player_info)
			self:Close()
		end)
	elseif id == 12 or id == 14 or id == 15 or id == 16 or id == 17 or id == 21 or id == 23 or id == 31 or id == 32 or id == 34 then
		if self.player_info.activeMenuCb ~= nil then
			self.player_info.activeMenuCb(id, self.player_info)
		end
        self:Close()
	elseif id == 18 then 
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSAttribute, 0, self.player_info.playerId)
		
	elseif id == 19 then
		MapModel.getPlayerPositionRequest(self.player_info.playerId, function(params)
		    
		    
		    if params.s2c_templateID ~= 0 then
		        local msg = Util.GetText(TextConfig.Type.FRIEND,'selected_mode')
		        local sdata = {}
		        local mapdata = GlobalHooks.DB.Find("Map", params.s2c_areaId) or {}
		        sdata[1] = string.format("%08X",  GameUtil.RGBA_To_ARGB(ChatUtil.PorColor["PorColor" .. self.player_info.pro]))
		        sdata[2] = self.player_info.name
		        sdata[3] = mapdata.Name .. "(" .. params.s2c_targetX .. "," .. params.s2c_targetY .. ")"
		        msg = ChatUtil.HandleString(msg, sdata)

		        GameAlertManager.Instance:ShowAlertDialog(
		        AlertDialog.PRIORITY_NORMAL, 
		        msg,
		        nil,
		        nil,
		        nil,
		        nil,
		        function()
		            
		            if params.s2c_areaId ~= DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.MAPID) then
				        
				        
				        
				        
				         
				        
				        
				        
		                PlayerModel.ChangeAreaXYRequest(params.s2c_areaId, params.s2c_targetX,  params.s2c_targetY, params.s2c_instanceId, function()
		                    
		                    DataMgr.Instance.UserData:StartSeekAfterChangeScene(tonumber(params.s2c_templateID), params.s2c_targetX,  params.s2c_targetY)
		                end)
				        
				        
				        
				    else
				        DataMgr.Instance.UserData:Seek(tonumber(params.s2c_templateID), params.s2c_targetX,  params.s2c_targetY)
		            	MenuMgrU.Instance:CloseAllMenu()
				    end
		        end,
		        nil
		        )
		    else
		        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.FRIEND,'friend_offline'))
		        
		    end
		    self:Close()
		end)
	elseif id == 20 then 
		FriendModel.concernFriendRequest(self.player_info.playerId, function(params)
            
            if self.player_info.activeMenuCb ~= nil then
	            self.player_info.activeMenuCb(id, self.player_info)
			end
            self:Close()
        end)
	elseif id == 22 or id == 30 then  
		FriendModel.addBlackListRequest(self.player_info.playerId, function()
	        
		    ChatModel.AddNewBlackRole(self.player_info.playerId)
	        if self.player_info.activeMenuCb ~= nil then
				self.player_info.activeMenuCb(id, self.player_info)
			end
            self:Close()
	    end)
	elseif id == 24 then
		local node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIChatMainSecond)
        if  lua_obj ~= nil then
			lua_obj.setPlayer(self.player_info)
		else
			node,lua_obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIChatMainSmall)
			if  lua_obj ~= nil then
				lua_obj.setPlayer(self.player_info)
			end
		end
		self:Close()
	elseif id == 25 or id == 26 or id == 27 or id == 28 then
		self.player_info.activeMenuCb(id, self.player_info)
		self:Close()
	elseif id == 29 then
		Transaction.requestInviteTransaction(self.player_info.playerId)
		self:Close()
	elseif id == 33 then
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIMail, 0, self.player_info.playerId)
		self:Close()
	elseif id == 35 then
		Guild.invitePlayerJoinMyGuildRequest(self.player_info.playerId)
		self:Close()
	elseif id == 36 then
		Team.RequestSummon(self.player_info.playerId, self.player_info.name, self.player_info.pro)
		self:Close()
	end

end

local function CreateFunctionBtn(self)
	self.btn_number.Visible = false
	self.btnList = {}

	local menus = self.config.menu
	local style = 2

	local rows = math.floor(#menus / style) + ((#menus % style == 0 and 0) or 1)
	local s_btn = self.btn_number.Size2D
	local p_btn = self.btn_number.Position2D

	local temp = #menus-1
	self.cvs_interactive.Size2D = Vector2.New(self.cvs_interactive.Size2D.x, 
		self.cvs_interactive.Size2D.y +(math.floor(temp/style)-2)*(s_btn.y+10))

	for i=1,#menus do
		local id = menus[i]
		local txt = Util.GetText(TextConfig.Type.INTERACTIVE,tostring(id))
		
		local btn = self.btn_number:Clone()
		btn.X = p_btn.x + ((i+1)%style)*(s_btn.x+25)
		btn.Y = p_btn.y + math.floor((i-1)/style)*(s_btn.y+10)
		btn.Visible = true
		self.cvs_interactive:AddChild(btn)
		btn.Text = txt
		if id == 9 then
			btn.FontColor = CommonUnity3D.UGUI.UIUtils.UInt32_ARGB_To_Color(0xff0000ff)
		end
		btn.UserData = id

		LuaUIBinding.HZPointerEventHandler({node = btn, click = function(sender)
			OnFuncClick(sender, self)
			end})
		self.btnList[i] = btn
	end
end

local function ResetPosition(self,x,y)
	if not x or not y then 
		
		CommonUnity3D.UGUI.UIUtils.AdjustAnchor(ImageAnchor.C_C,self.cvs_interactive.Parent,self.cvs_interactive,Vector2.zero)
	else
		local v1 = self.cvs_interactive.Parent:GlobalToLocal(Vector2.New(x,y),true) 
		if v1.x - self.cvs_interactive.Width > 15 then
            
    		self.cvs_interactive.X = v1.x - self.cvs_interactive.Width
  		else
    		self.cvs_interactive.X = v1.x
  		end

  		self.cvs_interactive.Y = 200
		
		
		
		
		
		
	end
end

local function InitComponent(self,tag)

	self.menu = LuaMenuU.Create('xmds_ui/common/commom_interactive.gui.xml',tag)
	self.menu.ShowType = UIShowType.Cover
	
	Util.CreateHZUICompsTable(self.menu,ui_names,self)
	self.menu.event_PointerClick = function (sender)
		Close(self)
	end

	self.tb_name.TextComponent.Anchor = TextAnchor.C_C
end

local function FillPlayerInfo(self)
	if self.player_info.name ~= nil then
		self.tb_name.Text = self.player_info.name
		self.tb_name.Visible = true
	else
		self.tb_name.Visible = false
	end

	if self.player_info.guildName ~= nil and string.len(self.player_info.guildName)>0 then
		self.lb_guild.Text = Util.GetText(TextConfig.Type.GUILD, "xianmeng")..self.player_info.guildName
	else
		self.lb_guild.Text = Util.GetText(TextConfig.Type.GUILD, "noxianmeng")
	end

	if self.player_info.upLv ~= nil then
		local vo = GlobalHooks.DB.Find("UpLevelExp", {UpOrder=self.player_info.upLv})[1]
    	if vo then
    	    self.lb_upLv.Text = Util.GetText(TextConfig.Type.GUILD, "jingjie")..vo.ClassName..vo.UPName
    	else
    		self.lb_upLv.Text = Util.GetText(TextConfig.Type.GUILD, "nojingjie")
    	end
	else
		self.lb_upLv.Text = Util.GetText(TextConfig.Type.GUILD, "nojingjie")
	end

	if self.player_info.pro ~= nil then
		Util.SetHeadImgByPro(self.ib_head,self.player_info.pro)
		self.cvs_head = true
		if self.player_info.lv ~= nil then
			self.lb_lv.Text = self.player_info.lv
			self.lb_lv.Visible = true
		else
			self.lb_lv.Visible = false
		end
		self.tb_name.FontColor = GameUtil.RGBA2Color(GameUtil.GetProColor(self.player_info.pro))
	else
		self.cvs_head.Visible = false
	end
end

local function SetPlayerInfo(self,info)
	self.player_info = info
	FillPlayerInfo(self)
end


local function Create(tag,type_str)
  local ret = {}
  setmetatable(ret, _M)
  InitComponent(ret,tag,type_str)
  return ret
end

local function SetType(self,typekey)
	local json = Util.GetJsonText(TextConfig.Type.INTERACTIVE,typekey)
	if not json then
		return 
	end
	self.config = cjson.decode(json)
	CreateFunctionBtn(self)
end


local function SetParams(self,params)
	SetType(self, params.type)
	SetPlayerInfo(self,params.player_info)
	ResetPosition(self,params.x,params.y)
end


local function OnShowInteractiveMenu(eventname,params)
	
	local menu,obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIInteractive,0)
	SetParams(obj,params)
end

local function initial()

	EventManager.Subscribe("Event.ShowInteractive", OnShowInteractiveMenu)
end


_M.Create = Create
_M.initial = initial

_M.TYPE_CHAT = 'cfg_chat'
_M.TYPE_CHAT_SELF = 'cfg_self'
_M.TYPE_CHAT_AT = 'cfg_call'

_M.TYPE_FRIEND = 'cfg_friend'	
_M.SOCIAL_ADDFRIEND = "cfg_social_addfriend" 




_M.SOCIAL_COMMON = "cfg_common"

_M.SOCIAL_COMMON_GUILDMASTER = "cfg_common_guildmaster"

_M.SOCIAL_FRIEND = "cfg_social_friend"

_M.SOCIAL_ENEMY = "cfg_social_enemy"

_M.SOCIAL_BLACKLIST = "cfg_social_blacklist"

_M.SOCIAL_RECENTYLY = "cfg_social_recently"

_M.TYPE_TEAM = 'cfg_team'

_M.TYPE_TEAM_LEADER = 'cfg_team_leader'

_M.TYPE_TARGET = 'cfg_target'

_M.TYPE_SYSTEMP = 'cfg_sysTeam'

_M.WHISPER_FRIENDS = "cfg_whisper_friends"

_M.WHISPER_STRANGERS = "cfg_whisper_strangers"

_M.Enemy_OFFER_REWARD = "cfg_enemy"

_M.ALLY_MASTER = "cfg_ally_Master"

_M.ALLY_MEMBER = "cfg_ally_member"

_M.ALLY_LEAVE = "cfg_ally_leave"


_M.DAOQUN_MASTER = "cfg_daoqun_master"

_M.DAOQUN_MEMBER = "cfg_daoqun_member"

_M.DAOQUN_LEAVE = "cfg_daoqun_leave"










_M.Close = Close
_M.SetParams = SetParams
_M.SetPlayerInfo = SetPlayerInfo
return _M
