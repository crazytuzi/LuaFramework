require "ui.dialog"
require "utils.mhsdutils"

local ActWeekEntrance = {
	iconShow=0,
	actId=0
}
setmetatable(ActWeekEntrance, Dialog)
ActWeekEntrance.__index = ActWeekEntrance

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function ActWeekEntrance.getInstance()
    if not _instance then
        _instance = ActWeekEntrance:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function ActWeekEntrance.getInstanceAndShow()
    if not _instance then
        _instance = ActWeekEntrance:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function ActWeekEntrance.getInstanceNotCreate()
    return _instance
end

function ActWeekEntrance.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function ActWeekEntrance.ToggleOpenClose()
	if not _instance then 
		_instance = ActWeekEntrance:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

-- 这段代码时做什么的，搞笑么
function ActWeekEntrance:setVisible(b)
	if _instance then
		_instance:SetVisible(b)
	end
end

----/////////////////////////////////////////------

function ActWeekEntrance.GetLayoutFileName()
    return "huodongzhoubtn.layout"
end

function ActWeekEntrance:OnCreate()
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
    --get the actweek icon
    self.m_pBtn = CEGUI.Window.toPushButton(winMgr:getWindow("huodongzhoubtn/button"))

    -- subscribe event
    self.m_pBtn:subscribeEvent("Clicked", ActWeekEntrance.HandleBtnClicked, self) 

    
    if ActWeekEntrance.actId == 148 then
        self:HandleBtnClicked(nil)
    end

end

------------------- private: -----------------------------------

function ActWeekEntrance:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, ActWeekEntrance)
    return self
end

function ActWeekEntrance:HandleBtnClicked(args)
	local actInfo = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cactweek"):getRecorder(ActWeekEntrance.actId)
  	GetMessageManager():AddConfirmBox(eConfirmNormal,
  		MHSD_UTILS.get_msgtipstring(tonumber(actInfo.informationid)),
  		ActWeekEntrance.HandleTransferClicked,
  		self,
  		CMessageManager.HandleDefaultCancelEvent,
  		CMessageManager)
	return true
end

function ActWeekEntrance:HandleTransferClicked()

	local activityInfo = BeanConfigManager.getInstance():GetTableByName("knight.gsp.game.cactweek"):getRecorder(ActWeekEntrance.actId)
	GetMessageManager():CloseConfirmBox(eConfirmNormal, false);
	local roleLevel = GetDataManager():GetMainCharacterLevel()
	
	local sb = StringBuilder:new()
	sb:SetNum("parameter1", activityInfo.level)
	local tipMsg = sb:GetString(MHSD_UTILS.get_msgtipstring(145848))

	local actid = activityInfo.id
	if     actid == 144 then
		self:Act_144_Handler(roleLevel, activityInfo, tipMsg)
	elseif actid == 146 then
		self:Act_146_Handler(roleLevel, activityInfo, tipMsg)
    elseif actid == 148 then
		self:Act_148_Handler(roleLevel, activityInfo, tipMsg)
	elseif actid == 161 then
		self:Act_161_Handler(roleLevel, activityInfo, tipMsg)
	end

	sb:delete()

	return true 
end

-- Act 144 handle 
function ActWeekEntrance:Act_144_Handler(roleLevel,  actInfo,tips )
	local level = actInfo.level
	if roleLevel < level then
		GetGameUIManager():AddMessageTip(tips)
	else
		local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 5
		LuaProtocolManager.getInstance():send(req)
	end
end

-- Act 146 handle
function ActWeekEntrance:handle_146(rl, lvl, activityInfo,tips)
	if rl < lvl then
		GetGameUIManager():AddMessageTip(tips)
	else
		GetMainCharacter():FlyOrWarkToPos(activityInfo.mapid, activityInfo.xposid, activityInfo.yposid, -1)	
	end
end
function ActWeekEntrance:Act_146_Handler(roleLevel, actInfo, tips)
	local level = actInfo.level
	if GetTeamManager():IsOnTeam() then
		if GetTeamManager():IsMyselfLeader() then
			self:handle_146(roleLevel, level, actInfo, tips)
		elseif GetTeamManager():GetMemberSelf().eMemberState == 2 then
			self:handle_146(roleLevel, level, actInfo, tips)
		else 
			GetChatManager():AddTipsMsg(145817)
		end
	else
		self:handle_146(roleLevel, level, actInfo,tips)
	end
end

-- Act 148 handle
function ActWeekEntrance:Act_148_Handler(roleLevel,  actInfo,tips )
	local level = actInfo.level
	if roleLevel < level then
		GetGameUIManager():AddMessageTip(tips)
	else
		local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 7
		LuaProtocolManager.getInstance():send(req)
	end
end

function ActWeekEntrance:Act_161_Handler(roleLevel, actInfo, tips )
	if roleLevel < actInfo.level then
		GetGameUIManager():AddMessageTip(tips)
	else
		GetMainCharacter():FlyOrWarkToPos(actInfo.mapid, actInfo.xposid, actInfo.yposid, -1)
	end
end

return ActWeekEntrance
