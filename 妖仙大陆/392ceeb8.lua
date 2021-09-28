local _M = {}
_M.__index = _M

local Util          = require 'Zeus.Logic.Util'
local Buy           = require 'Zeus.UI.XmasterConsignment.ConsignmentUIBuy'
local Auction       = require 'Zeus.UI.XmasterConsignment.ConsignmentUIAuction'
local self = {}

local function InitUI()
    local UIName = {
    	"btn_close",
        "tbt_buy",
		"tbt_sale",

        "cvs_combine",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
end


local function SwitchPage(sender)
	if sender == self.tbt_buy then
		self.buy:setVisible(true)
		self.auction:setVisible(false)
		self.auction:OnExit()
	else
		self.buy:setVisible(false)
		self.auction:OnEnter()
		self.auction:setVisible(true)
	end
end

local function openSell(...)
    
    local node,lua_obj = GlobalHooks.CreateUI(GlobalHooks.UITAG.GameUIConsignmentSell)
    self.menu:AddSubMenu(node)
    print("======================openSell==========================")
end

local function OnEnter()
	self.buy:OnEnter()
    EventManager.Subscribe("Event.UI.ConsignmentUIMain.Sell", openSell)
	Util.InitMultiToggleButton(function (sender)
      	SwitchPage(sender)
    end,self.tbt_buy,{self.tbt_buy,self.tbt_sale})
end

local function OnExit()
    EventManager.Unsubscribe("Event.UI.ConsignmentUIMain.Sell", openSell)
	self.buy:OnExit()
	self.auction:OnExit()
end



local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/consignment/main.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
    
    InitUI()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end

    self.buy = Buy.Create(GlobalHooks.UITAG.GameUIConsignmentBuy,self.cvs_combine)
    self.buy:setVisible(false)
    self.auction = Auction.Create(GlobalHooks.UITAG.GameUIConsignmentAuction,self.cvs_combine)
    self.auction:setVisible(false)

    
    return self.menu
end

function _M:Start(global)

end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
