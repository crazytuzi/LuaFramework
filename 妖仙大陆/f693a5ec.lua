local _M = {}
_M.__index = _M


local Util                  = require "Zeus.Logic.Util"


local self = {
	menu = nil,
}

local ChatUIFaceMenu = nil
local ChatUIFaceObj = nil

local ChatUICommonListMenu = nil
local ChatUICommonListObj = nil

local ChatUIActionMenu = nil
local ChatUIActionObj = nil

local ChatUIShowItemMenu = nil
local ChatUIShowItemObj = nil

local ChatMain = nil

local function InitDefaultExpression()
    self.tbt_expression.IsChecked = true
    OnClickWeiZhi(10)
end

local  function PlayEffect()
    
    self.action = true
    self.cvs_extend.Y = self.cvs_extend.Height
    local ma = MoveAction.New()
    ma.TargetX = 0
    ma.TargetY = 0
    ma.Duration = 0.15
    ma.ActionEaseType = EaseType.easeInOutQuad
    self.cvs_extend:AddAction(ma) 
    ma.ActionFinishCallBack = function (sender)
        self.action = false
    end
	
	if self.ChatMain.chat_speaker == nil then
		ma = MoveAction.New()
		ma.TargetX = 0
		ma.TargetY = -self.cvs_extend.Height
		ma.Duration = 0.15
		ma.ActionEaseType = EaseType.easeInOutQuad
		self.ChatMain.cvs_main:AddAction(ma)	
	end
end

function _M.PlayCloseEffect()
    
    self.action = true
    local ma = MoveAction.New()
    ma.TargetX = 0
    ma.TargetY = self.cvs_extend.Height
    ma.Duration = 0.15
    ma.ActionEaseType = EaseType.easeInOutQuad
    self.cvs_extend:AddAction(ma) 
    ma.ActionFinishCallBack = function (sender)
        self.action = false
        self.menu:Close()
    end
	
	if self.ChatMain.chat_speaker == nil then
		ma = MoveAction.New()
		ma.TargetX = 0
		ma.TargetY = 0
		ma.Duration = 0.15
		ma.ActionEaseType = EaseType.easeInOutQuad
		self.ChatMain.cvs_main:AddAction(ma) 
	end
end

local function OnClickBegin(displayNode)
    
    XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('buttonClose')
    self:PlayCloseEffect()
end

function OnClickWeiZhi(index)
    if self.callback ~= nil then
        self.callback(index)
        
    end
end

local  function OnExit()
    
end

function _M.SetCallBack(cb)
    self.callback = cb
    
    PlayEffect()    
    
    InitDefaultExpression()
end

function _M.RemoveAllChildren()
	if ChatUIFaceObj ~= nil then
		ChatUIFaceObj.Exit()
	end

	if ChatUICommonListObj ~= nil then
		ChatUICommonListObj.Exit()
	end	

	if ChatUIActionObj ~= nil then
		ChatUIActionObj.Exit()
	end	

	if ChatUIShowItemObj ~= nil then
		ChatUIShowItemObj.Exit()
	end	
	self.cvs_extend2:RemoveAllChildren(false)
end

local btnName = {
	"tbt_laba",
	"tbt_weizhi",
	"tbt_hongbao",
	"tbt_jieping",
	"tbt_niming",
	"tbt_zhanshi",
	"tbt_touzi",
	"tbt_act",
	"tbt_latest",
	"tbt_expression",
	"tbt_hongbao2",
}
	
local UIName = {
	"csv_bg",
	"cvs_extend",
	"cvs_extend2",
}	
	
local function OnEnter()
	for i = 1, #btnName do
		self[btnName[i]].IsChecked = false	
    end	
end

local function InitUI()
    
   

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    for i = 1, #btnName do
        self[btnName[i]] = self.menu:GetComponent(btnName[i])
		self[btnName[i]].IsChecked = false	

        self[btnName[i]].TouchClick = function( ... )
        	for j = 1, #btnName do
				if j == i then
					self[btnName[j]].IsChecked = true 
				else
					self[btnName[j]].IsChecked = false	 
				end
			end	
			OnClickWeiZhi(i)
        end
    end
end

local function InitCompnent()
    InitUI()
    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = OnClickBegin})

    
    
    
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
	
	self.menu = LuaMenuU.Create("xmds_ui/chat/chat_extend.gui.xml", GlobalHooks.UITAG.GameUIChatTabList)
    self.menu.ShowType = UIShowType.Cover
    HudManagerU.Instance:InitAnchorWithNode(self.menu, bit.bor(HudManagerU.HUD_BOTTOM))
	InitCompnent()
    
	return self.menu
end

local function Create(tag,params)
	self = {}
    
	setmetatable(self, _M)
	local node = Init(tag, params)
	return self
end

local function initial()
  print("DungeonMain.initial")
end

return {Create = Create, initial = initial}
