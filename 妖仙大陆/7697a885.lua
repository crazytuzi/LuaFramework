local _M = {}
_M.__index = _M

local Util              = require "Zeus.Logic.Util"
local ChatUtil          = require "Zeus.UI.Chat.ChatUtil"
local PetModel          = require 'Zeus.Model.Pet'

local self = {
	menu = nil,
}

local function OnCloseMenu(displayNode)
	
	if self ~= nil and self.menu ~= nil then
		self.menu:Close()
	end
end










local function OnClickYes(displayNode)
    
    self.newName = string.gsub(self.ti_name.Input.text, " ", "")
    if self.callback ~= nil and self.newName ~= self.oldName and self.newName ~=  "" then
        self.callback(self.newName)
        OnCloseMenu(displayNode)
    end
   
end

function _M.setNameInfo(curName, callback)
    self.callback = callback
    self.newName = curName
    self.oldName = curName
    if curName ~= nil then
        self.ti_name.Input.text = curName
    end

end

local function OnExit()
    
end

local function OnEnter()
	
end

local function InitUI(ui, node)
	local UIName = {
        
        "btn_close",
        "lb_costnum",
        "btn_yes",
        "btn_no",
        "ti_name",
        "ib_icon",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end

    local cost = GlobalHooks.DB.Find("PetConfig", { ParamName = "Rename.Cost" })[1].ParamValue
    self.lb_costnum.Text = cost;

    local code = GlobalHooks.DB.Find("PetConfig", { ParamName = "Rename.Cost.ItemCode" })[1].ParamValue
    local item = GlobalHooks.DB.Find("Items", code)
    Util.ShowItemShow(self.ib_icon, item.Icon, -1)
end

local function HandleTxtInput(displayNode)
    
end

local function HandleInputFinishCallBack(displayNode)
    self.newName = string.gsub(self.ti_name.Input.text, " ", "")
end

local function InitCompnent(params)

    self.menu.mRoot.IsInteractive = true
    self.menu.mRoot.Enable = true
    self.menu.mRoot.EnableChildren = true
    LuaUIBinding.HZPointerEventHandler({node = self.menu.mRoot, click = OnCloseMenu})

	InitUI(self, self.menu)

    self.btn_close.TouchClick = OnCloseMenu
    self.btn_no.TouchClick = OnCloseMenu
    
    self.btn_yes.TouchClick = OnClickYes

    self.ti_name.Input.characterLimit = 6
    self.ti_name.Input.text = " "
    self.ti_name.InputTouchClick = HandleTxtInput
    self.ti_name.event_endEdit = LuaUIBinding.InputValueChangedHandler(HandleInputFinishCallBack)


	self.menu:SubscribOnEnter(OnEnter)
	self.menu:SubscribOnExit(OnExit)
	self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
	
	self.menu = LuaMenuU.Create("xmds_ui/pet/pet_changename.gui.xml", GlobalHooks.UITAG.GameUIPetRename)
	
	InitCompnent(params)
	return self.menu
end

local function Create(params)
	self = {}
	setmetatable(self, _M)
	local node = Init(params)
	return self
end


local function initial()
	
end

return {Create = Create, initial = initial}
