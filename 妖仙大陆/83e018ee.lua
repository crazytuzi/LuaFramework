


local Util = require 'Zeus.Logic.Util'
local Team = require "Zeus.Model.Team"
local PageTeamPlatform = require "Zeus.UI.XmasterTeam.PageUITeamPlatform"
local PageNearBy = require "Zeus.UI.XmasterTeam.PageUINearBy"
local PageMineTeam = require "Zeus.UI.XmasterTeam.PageUIMineTeam"
local _M = {
    operations = nil,selectTbtn = nil,listNearTeams = nil,targetInfo = nil
}
_M.__index = _M

local ui_names = {
    {name = "btn_close",},
    {name = "cvs_main"},
    {name = "tbt_team_platform"},
    {name = "tbt_nearby"},
    {name = "tbt_mineteam"},
}

_M.TargetDiffText = {
    Util.GetText(TextConfig.Type.FUBEN, "hardName_11"),
    Util.GetText(TextConfig.Type.FUBEN, "hardName_22"),
    Util.GetText(TextConfig.Type.FUBEN, "hardName_33"),
}

local function operateChecked(self,sender)

     self.selectTbtn = sender
     if sender == self.tbt_team_platform then
        self:openTeamPlatform()
     elseif sender == self.tbt_nearby then
        self:openNearBy()
     elseif sender == self.tbt_mineteam then
        self.tbt_mineteam.Visible = true
        self:openMineTeam()
     end
end

local function closeAllOperations(self)
    for k,v in pairs(self.operations) do
        v:Exit()
    end
end

function _M:openTeamPlatform()
    if self.operations.teamPlatform == nil then
        self.operations.teamPlatform = PageTeamPlatform.Create(self.cvs_main,self)
    end
    closeAllOperations(self)
    self.operations.teamPlatform:Open()
end

function _M:openNearBy()
    if self.operations.nearBy == nil then
        self.operations.nearBy = PageNearBy.Create(self.cvs_main,self)
    end
    closeAllOperations(self)
    self.operations.nearBy:Open()
end

function _M:openMineTeam()
    if self.operations.mineTeam == nil then
        self.operations.mineTeam = PageMineTeam.Create(self.cvs_main,self)
    end
    closeAllOperations(self)
    self.operations.mineTeam:Open(self.menu.ExtParam)
    self.menu.ExtParam = ""
end

function _M:Close()
    self.menu:Close()

    
    
    local node,obj = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIActivityHJBoss)
    local node_Fuben,obj_Fuben = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIFuben)
    local node_DemonTower,obj_DemonTower = GlobalHooks.FindUI(GlobalHooks.UITAG.GameUIDemonTower)
    if  obj ~= nil and obj_Fuben ~= nil then
        obj.SetVisible(true)
        obj_Fuben.SetVisible(true)
    elseif obj ~= nil and obj_DemonTower ~= nil then
        obj.SetVisible(true)
        obj_DemonTower.SetVisible(true)
    end
end

local function RefreshList(self)
    Team.RequestNearTeams(function(data)
        self.listNearTeams = data.s2c_teams
    end)
end

function _M:ChangeToMineTeam()
    if not DataMgr.Instance.TeamData.HasTeam then
        self.menu.ExtParam = "createTeam"
    end
    Util.ChangeMultiToggleButtonSelect(self.tbt_mineteam, self.tbt_menus)
end


function _M:OnEnter()
    self.IsEnter = true
    self.menu.Visible = true
    
    if DataMgr.Instance.TeamData.HasTeam then
        self.tbt_mineteam.Visible = true
    else
        self.tbt_mineteam.Visible = false
    end
    if string.len(self.menu.ExtParam) > 0 then
        if self.menu.ExtParam == "createTeam" then
            Util.ChangeMultiToggleButtonSelect(self.tbt_mineteam, self.tbt_menus)
        elseif self.menu.ExtParam == "nearby_team" then
            Util.ChangeMultiToggleButtonSelect(self.tbt_nearby, self.tbt_menus)
            self.menu.ExtParam = ""
        else
            local params = string.split(self.menu.ExtParam,"|")
            if(params[1] == "platform") then
                if(params[2] == "set") then
                    Util.ChangeMultiToggleButtonSelect(self.tbt_team_platform, self.tbt_menus)
                    self.operations.teamPlatform:openTeamSet()
                elseif(params[2] == "find") then
                    local ids = string.split(params[3],",")
                    local targetId = tonumber(ids[1])
                    local diff = tonumber(ids[2])

                    self.targetInfo = {}
                    self.targetInfo.targetId = targetId
                    self.targetInfo.difficulty = diff

                    Util.ChangeMultiToggleButtonSelect(self.tbt_team_platform, self.tbt_menus)
                    
                else
                    Util.ChangeMultiToggleButtonSelect(self.tbt_team_platform, self.tbt_menus)
                end
            elseif params[1] == "mineTeam" then
                if DataMgr.Instance.TeamData.HasTeam then
                    if(params[2] == "find") then
                        local ids = string.split(params[3],",")
                        local targetId = tonumber(ids[1])
                        local diff = tonumber(ids[2])
                        Team.RequestSetTarget(targetId, diff, 0, 0, 1, 0, function ()
                            Util.ChangeMultiToggleButtonSelect(self.tbt_mineteam, self.tbt_menus)
                        end)
                    end
                else
                    print("请使用参数 createTeam")
                end
            else
                Util.ChangeMultiToggleButtonSelect(self.tbt_team_platform, self.tbt_menus)
            end
            self.menu.ExtParam = ""
        end
    else
        if DataMgr.Instance.TeamData.HasTeam then
            Util.ChangeMultiToggleButtonSelect(self.tbt_mineteam, self.tbt_menus)
        else
            Util.ChangeMultiToggleButtonSelect(self.tbt_team_platform, self.tbt_menus)
        end
    end

    if self.joinTeam == nil and self.noTeam == nil then
        local function handler_noTeam(evtName,param)
            if not self.IsSwitchToMine then
                self.menu.ExtParam = " "
            end
            
        end

        local function handler_joinTeam(evtName,param)
            if not self.IsSwitchToMine then
                self.menu.ExtParam = " "
            end
            self:OnEnter()
        end

        self.noTeam = handler_noTeam
        self.joinTeam = handler_joinTeam
        EventManager.Subscribe("Event.noTeam",handler_noTeam)
        EventManager.Subscribe("Event.joinTeam",handler_joinTeam)
    end
end

function _M:setIsSwitchToMine(var)
    self.IsSwitchToMine = var
end

function _M:OnExit()
    self.menu.Visible = false
    if self.operations then
        closeAllOperations(self)
    end
    self.targetInfo = nil

    EventManager.Unsubscribe("Event.noTeam",self.noTeam)
    EventManager.Unsubscribe("Event.joinTeam",self.joinTeam)
    self.noTeam = nil
    self.joinTeam = nil
    self.IsEnter = false

    if self.operations.mineTeam ~= nil then
        self.operations.mineTeam:CloseMineTeam()
    end
end

function _M:OnDestory()

end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create('xmds_ui/team/main.gui.xml', tag)
    self.menu.Enable = false
    self.menu.ShowType = UIShowType.HideBackHud
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.IsSwitchToMine = true
    self.IsEnter = false
    self.btn_close.TouchClick= function (sender)
        self:Close()
    end

    self.operations = {}
    self.tbt_menus = {self.tbt_team_platform,self.tbt_nearby,self.tbt_mineteam}
    self.menu:SubscribOnExit( function()
        self:OnExit()
    end )
    self.menu:SubscribOnEnter( function()
        self:OnEnter()
    end )
    self.menu:SubscribOnDestory( function()
        self:OnDestory()
    end )

    Util.InitMultiToggleButton( function(sender)
        if self.IsEnter then
            operateChecked(self, sender)
        end
    end , self.tbt_team_platform, self.tbt_menus)
end

function _M.Create(tag,param)
    local ret = {}
    setmetatable(ret,_M)
    InitComponent(ret,tag)
    return ret
end

return _M

