local _M = {}
_M.__index = _M


local Util              = require "Zeus.Logic.Util"
local ActivityModel     = require 'Zeus.Model.Activity'

local self = {
    menu = nil,

}

function _M.OnEnter()
    local activityData = GlobalHooks.DB.Find('Activity',self.ActivityID)
    if activityData.ActivityKey == "cdk" then
        self.tb_tips1.Visible = false
        self.tb_tips2.Visible = true
    else
        self.tb_tips1.Visible = true
        self.tb_tips2.Visible = false
    end
end

function _M.OnExit()
    
end

local function OnBtnYesClick( ... )
    
    if string.gsub(self.ti_code.Input.text, " ", "") ~= "" then
        local activityData = GlobalHooks.DB.Find('Activity',self.ActivityID)
        if activityData.ActivityKey == "cdk" then
            ActivityModel.cdkNotify(self.ti_code.Input.text, SDKWrapper.Instance:GetChannel())
            self.ti_code.Input.text = ""
        else
            ActivityModel.activityInviteCodeRequest(self.ti_code.Input.text, function(params)
                
                self.ti_code.Input.text = ""
            end)
        end
    end
end

local function HandleTxtInput(displayNode, self)
    
    
end

local function HandleInputFinishCallBack(displayNode, self)
    
end 

local ui_names = 
{
    {name = 'btn_yes'},
    {name = 'ti_code'},
    {name = 'tb_tips1'},
    {name = 'tb_tips2'},
}

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.event_PointerClick = function()
                ui.click(tbl)
                end
            end
        end
    end
end

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    initControls(self.menu,ui_names,self)

    self.btn_yes.TouchClick = OnBtnYesClick

    self.ti_code.Input.characterLimit = 30

    self.ti_code.InputTouchClick = function(displayNode)
        HandleTxtInput(displayNode, self)
    end
    self.ti_code.event_endEdit = LuaUIBinding.InputValueChangedHandler(function(displayNode)
        HandleInputFinishCallBack(displayNode, self)
    end)

    return self.menu
end

local function Create(ActivityID,xmlPath)
    self = {}
    self.ActivityID = ActivityID
    setmetatable(self, _M)
    local node = InitComponent(self,xmlPath)
    return self,node
end


return {Create = Create}
