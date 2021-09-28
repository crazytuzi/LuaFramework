local _M = {}
_M.__index = _M

local FuncOpen = require "Zeus.Model.FunctionOpen"
local Util = require "Zeus.Logic.Util"

local serial = 0

local function DoScaleAction(self, node, scale, duration, cb)
	local scaleAction = ScaleAction.New()
	scaleAction.ScaleX = scale
	scaleAction.ScaleY = scale
	scaleAction.Duration = duration
	node:AddAction(scaleAction)
	scaleAction.ActionFinishCallBack = cb
end

local function DoMoveAction(self, node, target, duration, cb)
	local v  = target:LocalToGlobal()
	local v1 = node.Parent:GlobalToLocal(v, true)
	local moveAction = MoveAction.New()
	moveAction.TargetX = v1.x
	moveAction.TargetY = v1.y
	moveAction.Duration = duration
	
	node:AddAction(moveAction)
	moveAction.ActionFinishCallBack = cb
end

local function DoFadeAction(self, node, duration, cb)
	local alphaAction = FadeAction.New()
	alphaAction.TargetAlpha = 0
	alphaAction.Duration = duration
	node:AddAction(alphaAction)
	alphaAction.ActionFinishCallBack = cb
end

local function DoDelayAction(self, node, duration, cb)
	local delayAction = DelayAction.New()
	delayAction.Duration = duration
	node:AddAction(delayAction)
	delayAction.ActionFinishCallBack = cb
end

local function SetData(self, funcInfo, finishCb)
	
	local fType = funcInfo.Type
	if fType==1 or fType==2 or fType==3 or fType==5 then
		self.menu:SetVisibleUENode("lb_name", true)
		self.menu:SetVisibleUENode("lb_only", false)
		
		self.menu:SetVisibleUENode("cvs_fun", true)
		self.menu:SetLabelText("lb_name", funcInfo.FunName, 0, 0)
		Util.HZSetImage(self.menu:FindChildByEditName("ib_fun", true), "dynamic_n/activity/"..funcInfo.Icon..".png")
	else
		self.menu:SetVisibleUENode("lb_name", false)
		self.menu:SetVisibleUENode("lb_only", true)
		
		self.menu:SetVisibleUENode("cvs_fun", true)
		self.menu:SetLabelText("lb_only", funcInfo.FunName, 0, 0)
        Util.HZSetImage(self.menu:FindChildByEditName("ib_fun", true), "dynamic_n/activity/"..funcInfo.Icon..".png")
	end

	
	
	
	
    
	local frame = self.menu:FindChildByEditName("cvs_newFun", true)
    
    local bgNode= frame:FindChildByEditName("ib_bg",true) 
	Util.showUIEffect(bgNode,43);
	if fType == 2 then 
		EventManager.Fire("Event.Menu.OpenFuncEntryMenu", {})
	
	
	
	end
	DoDelayAction(self, frame, 2, function()
		
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			

			
			
			
			
			
			
			
			
			
			
			
			
			
			
				if finishCb ~= nil then
					finishCb()
				end
				self.menu:Close()
			
		
	end)

    local isNormal = PublicConst.SceneType.Normal == PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
    local script_name = ""
	if funcInfo.ID == 32 then	
		
	
		
	elseif funcInfo.ID == 39 then	
		script_name = "guide_daoyou"
	elseif funcInfo.ID == 43 then	
		script_name = "guide_guild"
	end
	
	if string.len(script_name) > 0 then
		if isNormal and DramaUIManage.Instance:IsGuideHandActive() == false then
			GlobalHooks.Drama.Start(script_name, true)
		else
			DataMgr.Instance.UserData:SetClientConfig(script_name,"start",true)
		end
	end
end

local function OnExit(self)
	
end

local function OnEnter(self)
	
end

local function InitCompnent(self)
	


	self.menu:SubscribOnEnter(function()
		OnEnter(self)
	end)
	self.menu:SubscribOnExit(function()
		OnExit(self)
	end)
	self.menu:SubscribOnDestory(function()
		self = nil
	end)
end

local function Init(self)
	
	self.menu = LuaMenuU.Create("xmds_ui/hud/newfunction.gui.xml", GlobalHooks.UITAG.GameUIFuncOpen)
	self.menu.ShowType = UIShowType.Cover
    self.menu.Enable = false
	serial = serial + 1
	self.serial = serial
	InitCompnent(self)
	return self.menu
end

local function Create(params)
	local self = {}
	setmetatable(self, _M)
	self.params = params
	Init(self)
	return self
end

_M.SetData = SetData

return {Create = Create}
