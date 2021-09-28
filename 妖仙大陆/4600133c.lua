
local _M = {}
_M.__index = _M

local cjson = require "cjson"
local Util = require 'Zeus.Logic.Util'

local isHideReliveUI = false

_M.ReliveData = {
	costStr = ""
}

_M.SceneType = {
	Normal = 1,		
	Dungeon = 2,	
	Solo = 3,		
	Arena = 4,		
	AllyWar = 6,
	GuildDungeon = 7,
	BossHomeFight = 8,
	Story = 9,        
	FiveVSFive = 10,  
	DemonTower = 11,  
    ResourceDungeon = 12,    
    Haoyuejing = 13,    
    GuildBoss = 14,   
}

_M.AutoOpenFeatureId = nil

function _M.setHideReliveUI(hide)
	isHideReliveUI = hide
	local menu,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIDeadCommon)
	if menu then
		menu.Visible = not hide
	end
end

function _M.RequestRelive(type, showTip, cb)
	
	Pomelo.PlayerHandler.reliveRequest(type, showTip, function( ex, sjson )
		
		if ex == nil then
			if cb ~= nil then
				cb()
				MenuMgrU.Instance:CloseMenuByTag(GlobalHooks.UITAG.GameUIDeadCommon)
			end
		else
		end
	end, nil)
end

function _M.RequestReliveSendPos(cb)
	
	Pomelo.PlayerHandler.reliveSendPosRequest(_M.ReliveData.serverMsg, function( ex, sjson )
		
		if ex == nil then
			if cb ~= nil then
				cb()
			end
		end
	end, nil)
end

function _M.AgreeRebirthRequest(cb)
	Pomelo.PlayerHandler.agreeRebirthRequest(function (ex, sjson)
		if not ex and cb then
			cb()
		end
	end)
end

function GlobalHooks.DynamicPushs.OnRelivePush(ex, json)
    
	if ex == nil then
		local param = json:ToData()
		local relive = param
		_M.ReliveData.reliveType = relive.type
		_M.ReliveData.btnSafe = relive.btnSafe or 0
		_M.ReliveData.btnCity = relive.btnCity or 0
		_M.ReliveData.btnCurr = relive.btnCurr or 0
		_M.ReliveData.btnShow = relive.btn
		_M.ReliveData.btnText = relive.content
		_M.ReliveData.countDown = relive.countDown
		_M.ReliveData.btnEnable = relive.op
		_M.ReliveData.cbType = relive.cbType
		_M.ReliveData.currCount = relive.currCount or 0
		_M.ReliveData.totalCount = relive.totalCount or 0
		_M.ReliveData.cooltime = relive.cooltime or 0
		_M.ReliveData.costStr = relive.costStr or ""
		_M.ReliveData.payConfirm = relive.payConfirm

		
        EventManager.Fire("Event.Delivery.Close",{})
        EventManager.Fire("Event.CloseNpcTalk",{})
		
		
		if isHideReliveUI then
			if relive.countDown <= 0 then
				_M.RequestRelive(0,0,function()
					
				end)
			else
				HudManagerU.Instance:showAutoAnimi(8,relive.countDown) 
				local timer
				timer = Timer.New(function( ... )
					_M.RequestRelive(0,0,function()
					
					end)
				end, relive.countDown)
    			timer:Start()
			end
		else
			local reliveMenu = MenuMgrU.Instance:CreateUIByTag(GlobalHooks.UITAG.GameUIDeadCommon, 0)
			MenuMgrU.Instance:AddMsgBox(reliveMenu)
		end
	end
end

function GlobalHooks.DynamicPushs.OnSaverRebirthPush(ex,json)
	if not ex then
		local param = json:ToData()
		
		local function VisibleReliveMsgBox(visible)
			local menu = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIDeadCommon)
			if menu then
				menu.Visible = visible
			end
		end

		local function RebirthOk()
			_M.AgreeRebirthRequest(function ()
				local menu = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIDeadCommon)
				if menu then
					menu.Visible = true
					menu:Close()
				end
			end)
		end

		local function RebirthCancel()
			local AD = GameAlertManager.Instance.AlertDialog
			if AD:GetPriorityDialogCount(AlertDialog.PRIORITY_RELIVE) <= 1 then
				VisibleReliveMsgBox(true)
			end
		end

		VisibleReliveMsgBox(false)
        EventManager.Fire("Event.Delivery.Close",{})
        EventManager.Fire("Event.CloseNpcTalk",{})
		local txt = Util.GetText(TextConfig.Type.PUBLICCFG,'relive_tips',param.saverName)

		GameAlertManager.Instance:ShowAlertDialog(
			AlertDialog.PRIORITY_RELIVE,
			txt,
			Util.GetText(TextConfig.Type.PUBLICCFG,'btn_accept'),
			Util.GetText(TextConfig.Type.PUBLICCFG,'btn_refuse'),
			Util.GetText(TextConfig.Type.PUBLICCFG,'relive_confirm'),
			nil,
			RebirthOk,
			RebirthCancel
		)
	end
end

function _M.initial()

end

function _M.fin()

end

function _M.InitNetWork()
	
	Pomelo.GameSocket.playerRelivePush(GlobalHooks.DynamicPushs.OnRelivePush)
	Pomelo.GameSocket.playerSaverRebirthPush(GlobalHooks.DynamicPushs.OnSaverRebirthPush)
end

return _M
