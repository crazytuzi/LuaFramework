local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local ChatUtil          = require "Zeus.UI.Chat.ChatUtil"
local GDRQ 				= require "Zeus.Model.Guild"
local Skill 			= require "Zeus.Model.Skill"
local FuncOpen 			= require "Zeus.Model.FunctionOpen"

local landscape_pos = {}
local portrait_pos = {}

local self = {
	lua_menu = nil,
}

local btnName = {
	{"btn_achievement", "btn_guild", "btn_ally"},
	{"btn_skill","btn_rework","btn_wing","btn_mount","btn_pet","btn_magic","btn_xuemai"},
	{"cvs_landscape","cvs_portrait ","cvs_portraitbg","cvs_landscapebg",},
	{"cvs_guild"},
	{"cvs_skill","cvs_rework","cvs_wing","cvs_mount","cvs_pet","cvs_magic", "cvs_xuemai"},
}

local function OpenDungeonMenu(eventname, params)
	

end






local function OnClickBtnAlly(eventname, params)
	
	
end

local function OnClickRanking(eventname, params)
	MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUILeaderboard, 0)
end

local function OpenSkillMenu(eventname, params)
	MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISkillMain, 0)
end














local function OpenPetMenu(displayNode)
	
	MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUIPetMain, 0, 1)
    FuncOpen.SetPlayedFunctionByName('Pet')
end

local function OpenXuemaiMenu(displayNode)
	
	MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUIBloodMain, 0, 1)
    
end

local function OnClickMastery(displayNode)
	
	
	

end

local function OnClickChenjiu(displayNode)
	
end

local function OnClickSociality(displayNode)
	
	
	local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUISocialMain, 0)
	
end

local function OnClickMount(displayNode)
    if GlobalHooks.CheckRindingIsOpenByName("Ride",true) then
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIRideMain, 0)
    end
    FuncOpen.SetPlayedFunctionByName('Ride')
end

local function OnClickRoleMedal(displayNode)
	
	
	
	MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUIPetMain, 0, 1)
end

local function OnClickWings(displayNode)
	
	
  
  
end

local function OnClickBtnDungeon(displayNode)
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
end

local function CheckHasWaitToPlay(compname)
	if not compname or compname == '' then
		return false
	end
	local ret = GlobalHooks.DB.Find("OpenLv",{RedDot=compname})
	for _,v in ipairs(ret) do
		local show = GlobalHooks.CheckFuncWaitToPlay(v.Fun)
		if show then 
			return true
		end
	end
	return false
end

local function SetHeroFlagShow(status)
	if status==FlagPushData.FLAG_MASTERY or
		status == FlagPushData.FLAG_ATTRIBUTE or
		status == FlagPushData.FLAG_ACHIEVEMENT or
		status == FlagPushData.FLAG_GUILD or
		status == FlagPushData.FLAG_GUILD_BOSS or
		status == FlagPushData.FLAG_ALLY or 
		status == FlagPushData.FLAG_WING or 
		status == FlagPushData.FLAG_MOUNT or
		status == FlagPushData.FLAG_SKILL or
		status == FlagPushData.FLAG_MASTERY_RING or
		status == FlagPushData.FLAG_MEDAL or 
		status == FlagPushData.FLAG_REWORK_REWORK
	then
		local nums = {
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MASTERY),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ATTRIBUTE),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACHIEVEMENT),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_BOSS),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ALLY),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_WING),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MOUNT),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SKILL),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MASTERY_RING),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MEDAL),
			DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_REWORK),

		}
		local total = 0
		for _,v in ipairs(nums) do
			
			if v > 0 then
				total = 1
				break;
			end
		end
		if total == 0 then 
			local comps = {
				'lb_bj_magic',
		
				'lb_bj_achievement',
				'lb_bj_guild',
				
				'lb_bj_wing',
				'lb_bj_mount',
				'lb_bj_skill',
				
			}
			for _,v in ipairs(comps) do
				if CheckHasWaitToPlay(v) then
					total = 1
					break;
				end
			end
		end
		EventManager.Fire('Event.HeroFlagShow', {visible = total>0})
	end
end

local function SetMenuBtnShow()

			local comps = {
				'lb_bj_pet',
				'lb_bj_mount',
				'lb_bj_rework',
				'lb_bj_skill',
				'lb_bj_guild',
				
			}
	local bool = self.lua_menu:FindChildByEditName("lb_bj_pet", true).Visible or
					self.lua_menu:FindChildByEditName("lb_bj_mount", true).Visible or
					self.lua_menu:FindChildByEditName("lb_bj_rework", true).Visible or
					self.lua_menu:FindChildByEditName("lb_bj_skill", true).Visible or
					self.lua_menu:FindChildByEditName("lb_bj_guild", true).Visible
					
	EventManager.Fire('Event.MainMenu.MenuTtnShow', {show = bool})
end

local function SetMasteryFlag()
	local num1 = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MASTERY)
	local num2 = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MASTERY_RING)
	local num = math.abs(num1)+math.abs(num2)
	self.lb_bj_magic = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_magic') and (num + 1) or num
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_magic", num ~= 0)
	MenuBaseU.SetLabelText(self.lua_menu,"lb_bj_magic", num>1 and tostring(num) or "",0,0)
end

local function SetAttribute()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ATTRIBUTE) + DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MEDAL)
	self.lb_bj_character = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_character') and (num + 1) or num
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_character", num ~= 0)
	
end

local function SetAchievement()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_ACHIEVEMENT)
	self.lb_bj_achievement = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_achievement') and (num + 1) or num
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_achievement", num ~= 0)
	
end

local function SetGuild()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD)
	self.lb_bj_guild = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_guild') and (num + 1) or num
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_guild", num ~= 0)
	
end

local function SetAlly()
	
	
	
	
	
end

local function SetMount()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_MOUNT)
	
	
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_mount", num ~= 0)
	
end

local function SetWing()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_WING)
	self.lb_bj_wing = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_wing') and (num + 1) or num
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_wing", num ~= 0)
	MenuBaseU.SetLabelText(self.lua_menu,"lb_bj_wing", num>1 and tostring(num) or "",0,0)
end

local function SetSkill()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_SKILL)
	self.lb_bj_skill = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_skill') and (num + 1) or num
	
	MenuBaseU.SetVisibleUENode(self.lua_menu, "lb_bj_skill", num ~= 0)
end

local function SetPet()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_PET)
	self.lb_bj_pet = num ~= 0
	num = CheckHasWaitToPlay('lb_bj_pet') and (num + 1) or num
    
    local myLv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL, 0)
    local openLvData = GlobalHooks.DB.Find("OpenLv",{Fun="Pet"})
    local openLv = openLvData ~= nil and openLvData.OpenLv or 0
    if myLv < openLv then
    	    MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_pet", false)
    else
        	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_pet", num ~= 0)
    end
	
end

local function SetEquipPlus()
	local num = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_REWORK_REWORK)
	
	
	MenuBaseU.SetVisibleUENode(self.lua_menu,"lb_bj_rework", num ~= 0)
	
end

local function OnClickBtnSetZhi(displayNode)
	MenuMgrU.Instance:OpenUIByTag(GlobalHooks.UITAG.GameUISetMain, 0)
end

local function OnClickGuild(sender)
	if DataMgr.Instance.UserData.Guild then
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
	else
		GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIApplyGuild,0)
	end
end

local function CloseAction()
	
	for j = 4, 5 do
		for i = 1, #btnName[j] do
		    local ma = MoveAction.New()
			if j == 4 then 
				ma.TargetX = landscape_pos[1]
				ma.TargetY = landscape_pos[2]
			end
			if j == 5 then 
				ma.TargetX = portrait_pos[1]
				ma.TargetY = portrait_pos[2]
			end
			
		    ma.Duration = 0.1
		    ma.ActionEaseType = EaseType.linear
		    self[btnName[j][i]]:AddAction(ma) 
		    if j == 5 and i ==  #btnName[j] then
			    ma.ActionFinishCallBack = function (sender)
			        self.actionfinish = true
			        self.lua_menu.Visible = false
			        EventManager.Fire("Event.Menu.CloseFuncEntryMenuCb",{})
			    end
			end
		end
	end
end

local function OnCloseMenu(eventname, params)
	
	if self ~= nil and self.lua_menu ~= nil then
		CloseAction()
	end
end

local function OpenAction()
	
	self.lua_menu.Visible = true
	for j = 4, 5 do
		for i = 1, #btnName[j] do
			if j == 4 then 
				self[btnName[j][i]].X = landscape_pos[1]
				self[btnName[j][i]].Y = landscape_pos[2]
			end
			if j == 5 then
				self[btnName[j][i]].X = portrait_pos[1]				
				self[btnName[j][i]].Y = portrait_pos[2]
			end
		    
		    
		    local ma = MoveAction.New()
		    ma.TargetX = self.actionPos[btnName[j][i]].x
		    ma.TargetY = self.actionPos[btnName[j][i]].y
		    ma.Duration = 0.3
		    ma.ActionEaseType = EaseType.easeOutBack
		    self[btnName[j][i]]:AddAction(ma) 
		    ma.ActionFinishCallBack = function (sender)
		        self.actionfinish = true
		    end
		end
	end
end

local function OnShowHudMenu( eventname, params )
	if self ~= nil and self.lua_menu ~= nil then
		OpenAction()
		EventManager.Fire('Event.HeroFlagShow', {visible = false})
	end
end

local function InitUI()
    
    for j = 1, #btnName do
	    for i = 1, #btnName[j] do
	        self[btnName[j][i]] = self.lua_menu:FindChildByEditName(btnName[j][i], true)
	    end
	    if j == 4 or j == 5 then
	    	for i = 1, #btnName[j] do
	        	self.actionPos[btnName[j][i]] = self[btnName[j][i]].Position2D
	        	self[btnName[j][i]].Position2D = Vector2.New(0,0)
	    	end
	    end
	end
    
    table.insert(landscape_pos,209) 
    table.insert(landscape_pos,110)
         
    table.insert(portrait_pos,7) 
    table.insert(portrait_pos,380) 
end

local function OpenUIChangeFlag(eventname, params)
	local oplv = GlobalHooks.DB.Find("OpenLv",params.name)
	local flagNode = self.lua_menu:FindChildByEditName(oplv.RedDot,true)
	if oplv and flagNode then
		if params.waitToPlay then
			flagNode.Visible = true
			EventManager.Fire('Event.HeroFlagShow', {visible = true})
		else
			if not self[oplv.RedDot] and not CheckHasWaitToPlay(oplv.RedDot) then 
				flagNode.Visible = false 
				SetHeroFlagShow()
			end
		end
	end
	SetMenuBtnShow()
end

local function Init(tag, params)
	
	self.actionfinish = true
	self.actionPos = {}
	
	
	
	InitUI()
	LuaUIBinding.HZPointerEventHandler({node = self.lua_menu, click = OnCloseMenu})

    self.btn_pet:SetSound("buttonClick")
	self.btn_pet.TouchClick = OpenPetMenu

    self.btn_xuemai:SetSound("buttonClick")
	self.btn_xuemai.TouchClick = OpenXuemaiMenu

	HudManagerU.Instance:InitAnchorWithNode(self.cvs_landscapebg, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
	HudManagerU.Instance:InitAnchorWithNode(self.cvs_portraitbg, bit.bor(HudManagerU.HUD_LEFT, HudManagerU.HUD_TOP))
	self.cvs_landscapebg.UnityObject:AddComponent(typeof(UnityEngine.UI.Mask)).showMaskGraphic = false
   	self.cvs_portraitbg.UnityObject:AddComponent(typeof(UnityEngine.UI.Mask)).showMaskGraphic = false

	
	self.btn_skill:SetSound("buttonClick")
	self.btn_skill.TouchClick = OpenSkillMenu
	self.btn_magic.TouchClick = OnClickMastery
	self.btn_achievement.TouchClick = OnClickChenjiu
	self.btn_mount:SetSound("buttonClick")
	self.btn_mount.TouchClick = OnClickMount
	self.btn_wing.TouchClick = OnClickWings
	
	
	
	self.btn_ally.TouchClick = OnClickBtnAlly
	
	
	self.btn_rework:SetSound("buttonClick")
	self.btn_rework.TouchClick = function (sender)
		
        
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIEquipReworkMain,0,GlobalHooks.UITAG.GameUIEquipReworkScurbing)
	end
	self.btn_guild:SetSound("buttonClick")
	self.btn_guild.TouchClick = OnClickGuild
    local cvs1 = self.lua_menu:FindChildByEditName("cvs_portrait",true)
    
    cvs1.IsInteractive = true
    
    cvs1.event_PointerDown = function(sender)  end
    


	





	return self.lua_menu
end 

local function OnInit(eventname, params)
	
	
	self.lua_menu = HudManagerU.Instance.CreateHudUIFromFile("xmds_ui/hud/newplatform.gui.xml")
	self.lua_menu.Visible = false
	Init(eventname, params)
	HudManagerU.Instance:AddHudUI(self.lua_menu, "FuncEntry")
    HudManagerU.Instance:InitAnchorWithNode(self.lua_menu, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_BOTTOM))
    HudManagerU.Instance:InitAnchorWithNode(self.cvs_landscapebg, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_BOTTOM))
    HudManagerU.Instance:InitAnchorWithNode(self.cvs_portraitbg, bit.bor(HudManagerU.HUD_RIGHT, HudManagerU.HUD_BOTTOM))

	
	SetGuild()
	SetMount()
	SetSkill()
	SetPet()
	SetEquipPlus()
	SetHeroFlagShow(FlagPushData.FLAG_GUILD)
	SetMenuBtnShow()
end

local notify = {}
function notify.Notify(status, flagData)
	if self ~= nil and self.lua_menu ~= nil then
		if status == FlagPushData.FLAG_MASTERY or status == FlagPushData.FLAG_MASTERY_RING then
			SetMasteryFlag()
		elseif status == FlagPushData.FLAG_ATTRIBUTE or status == FlagPushData.FLAG_MEDAL then
			SetAttribute()
		elseif status == FlagPushData.FLAG_ACHIEVEMENT then
			SetAchievement()
		elseif status == FlagPushData.FLAG_GUILD then
			SetGuild()
		elseif status == FlagPushData.FLAG_ALLY then
			SetAlly()
		elseif status == FlagPushData.FLAG_MOUNT then
			SetMount()
		elseif status == FlagPushData.FLAG_WING then
			SetWing()
		elseif status == FlagPushData.FLAG_SKILL then
			SetSkill()
		elseif status == FlagPushData.FLAG_PET then
			SetPet()
		elseif status == FlagPushData.FLAG_REWORK_REWORK then
			SetEquipPlus()
		end
		SetHeroFlagShow(status)
		SetMenuBtnShow()
 	end
end

local function Create(tag,params)
	self = {}
	setmetatable(self, _M)
	local node = Init(tag, params)
	return node
end

local function fin(relogin)
	if not relogin then
		OnCloseMenu(nil, nil)
	end
	DataMgr.Instance.FlagPushData:DetachLuaObserver(9998)
end

local function CheckSkillRedPoint()
    	Skill.GetSkillList( function(skilldata)
		self.skillList = skilldata.skillList
		if self.skillList == nil then
			return
		end
        local index_can = 0
        local index_no = 0
	     for i=1,#self.skillList - 1 do
                
                if self.skillList[i+1].canUpgrade[1] == 1 then
					index_can =index_can+1
                end
                if self.skillList[i+1].canUpgrade[1] == 0 then
                   index_no=index_no+1
                end
         end
         if index_no >= #self.skillList -1 then
            self.lua_menu:FindChildByEditName("lb_bj_skill", true).Visible = false
         elseif index_can>=1 then 
            self.lua_menu:FindChildByEditName("lb_bj_skill", true).Visible = true
         end
         SetMenuBtnShow()
     end)
end
local function initial()
  
  EventManager.Subscribe("Event.UI.Hud.LuaHudInit", OnInit)
  EventManager.Subscribe("Event.Menu.OpenFuncEntryMenu", OnShowHudMenu)
  EventManager.Subscribe("Event.Menu.CloseFuncEntryMenu", OnCloseMenu)
  EventManager.Subscribe("Event.FunctionOpen.WaitToPlay", OpenUIChangeFlag)
  DataMgr.Instance.FlagPushData:AttachLuaObserver(9998, notify)
  EventManager.Subscribe("Event.FuncEntryMenu.SkillRedPoint", CheckSkillRedPoint)
end
return {Create = Create, initial = initial, fin = fin, dont_destroy = true}
