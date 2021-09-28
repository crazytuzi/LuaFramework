


local Team = require "Zeus.Model.Team"
local Util = require "Zeus.Logic.Util"
local TeamUtil = require "Zeus.UI.XmasterTeam.TeamUtil"
local _M = {
    accordionData = nil,selectTitleIndex = nil,selectNodeIndex = nil,titleItems = nil,nodeItems = nil,selectData = nil,
    callbackConfirm = nil,leastLimit = nil,maxLimit = nil
}
_M.__index = _M

local ui_names = {
    {name = "sp_invite_all"},
    {name = "sp_invite_title"},
    {name = "cvs_title"},
    {name = "cvs_type"},
    {name = "tbt_check"},
    {name = "lb_simple"},
    {name = "btn_confirm",click = function(self)
         if self.callbackConfirm then
            local node = self.nodeItems[self.selectNodeIndex]
            local diff = 0
            if node then
                local cvs_type1 = node:FindChildByEditName("cvs_type1",false)   
                local cvs_type2 = node:FindChildByEditName("cvs_type2",false)   
                local cvs_type3 = node:FindChildByEditName("cvs_type3",false)   
                if cvs_type1.Visible == true then
                     local tbt_check_simple = cvs_type1:FindChildByEditName("tbt_check_simple",true)
                     if tbt_check_simple.IsChecked then
                         diff = 0
                     else
                         diff = 1
                     end
                elseif cvs_type2.Visible == true then
                    diff = nil
                elseif cvs_type3.Visible == true then
                    local tbt_check_simple = cvs_type3:FindChildByEditName("tbt_check_simple",true)
                    local tbt_check_diff = cvs_type3:FindChildByEditName("tbt_check_diff",true)
                    local tbt_check_hard = cvs_type3:FindChildByEditName("tbt_check_hard",true)
                    if tbt_check_diff.IsChecked then
                        diff = 1
                    elseif tbt_check_hard.IsChecked then
                        diff = 2
                    else
                        diff = 0
                    end
                    
                end
            end
            local autoAccept = 0
            if self.tbt_check.IsChecked and self.selectTitleIndex ~= 1 then
                autoAccept = 1
            end
            self.callbackConfirm(self.accordionData[self.selectTitleIndex],self.selectNodeIndex,diff,self.leastLimit,self.maxLimit,self.ti_enter.Text,autoAccept)
         end
         self.menu:Close() 
    end},
    {name = "cvs_enter_detail"},
    {name = "ti_enter"},
    {name = "btn_enter",click = function(self)
        self:OpenLvLimit()
    end}
}

function _M:refreshLvLimit()
    local info = self.accordionData[self.selectTitleIndex].items[self.selectNodeIndex]
    
    self.leastLimit = tonumber(info.data.OpenLv)
    self.maxLimit = tonumber(GlobalHooks.DB.Find("Parameters", { ParamName = "Role.LevelLimit" })[1].ParamValue)
    self:setTi_enterText()
end

function _M:OnEnter()

    
		self.accordionData = TeamUtil.makeTeamTargetList()
        self.titleItems = {}
        self.nodeItems = {}
        self.sp_invite_title.Scrollable:Reset(1,#self.accordionData)
	
    self:setSelectTitle(1)
    if string.len(self.menu.ExtParam) > 0 then
        local lb_level_limit = self.menu:FindChildByEditName("lb_level_limit",true)
        if self.menu.ExtParam == "single" then
            lb_level_limit.Visible = false
            self.ti_enter.Visible = false 
            self.btn_enter.Visible = false
            self.tbt_check.Visible = false
            self.lb_simple.Visible = false
        else
            lb_level_limit.Visible = true
            self.ti_enter.Visible = true 
            self.btn_enter.Visible = true
            self.tbt_check.Visible = false
            self.tbt_check.IsChecked = true
            self.lb_simple.Visible = false
        end
    end
    self:refreshLvLimit()
end

function _M:OnExit()

end

function _M:OnDestory()

end

local function clearAllTitleSelect(self)
    for k,v in pairs(self.titleItems) do
        local ib_selected = v:FindChildByEditName("ib_selected",true)
        ib_selected.Visible = false
    end
end

local function clearAllNodeSelect(self)
    for k,v in pairs(self.nodeItems) do
        local ib_selected = v:FindChildByEditName("ib_selected",true)
        ib_selected.Visible = false
        local cvs_type1 = v:FindChildByEditName("cvs_type1",true)   
        local cvs_type2 = v:FindChildByEditName("cvs_type2",true)
        local cvs_type3 = v:FindChildByEditName("cvs_type3",true)
        cvs_type2.Visible = true
        cvs_type1.Visible = false
        cvs_type3.Visible = false
    end
end

function _M:setSelectTitle(index)
    local node = self.titleItems[index]
    if node then
        local ib_selected = node:FindChildByEditName("ib_selected",true)
        if self.selectTitleIndex ~= index then
            self.selectTitleIndex = index
        end
        clearAllTitleSelect(self)
        ib_selected.Visible = true
        self:selectTitle()
    end
end

function _M:setSelectNode(index)
    local node = self.nodeItems[index]
    if node then
        local ib_selected = node:FindChildByEditName("ib_selected",true)
        if self.selectNodeIndex ~= index then
            self.selectNodeIndex = index
        end
        self:refreshLvLimit()
        clearAllNodeSelect(self)
        ib_selected.Visible = true
        local cvs_type1 = node:FindChildByEditName("cvs_type1",false)   
        local cvs_type2 = node:FindChildByEditName("cvs_type2",false)   
        local cvs_type3 = node:FindChildByEditName("cvs_type3",false)   
        if ib_selected.UserData == "0" then
            cvs_type2.Visible = true
            cvs_type1.Visible = false
            cvs_type3.Visible = false
        elseif ib_selected.UserData == "1" then
            cvs_type2.Visible = false
            cvs_type1.Visible = true
            cvs_type3.Visible = false
            local tbt_check_simple = cvs_type1:FindChildByEditName("tbt_check_simple", true)
            local tbt_check_diff = cvs_type1:FindChildByEditName("tbt_check_diff", true)
            if (tbt_check_diff.IsChecked == false) then
                tbt_check_simple.IsChecked = true
            end
        elseif ib_selected.UserData == "2" then
            cvs_type2.Visible = false
            cvs_type1.Visible = false
            cvs_type3.Visible = true
            local tbt_check_simple = cvs_type3:FindChildByEditName("tbt_check_simple", true)
            local tbt_check_diff = cvs_type3:FindChildByEditName("tbt_check_diff", true)
            local tbt_check_hard = cvs_type3:FindChildByEditName("tbt_check_hard", true)
            if (tbt_check_diff.IsChecked == false and tbt_check_hard.IsChecked == false) then
                tbt_check_simple.IsChecked = true
            end
        end
    end
end

function _M:selectTitle()
    local data = self.accordionData[self.selectTitleIndex]
    self.nodeItems = {}
    self.selectData = data
    local items = data.items
    self.selectNodeIndex = 0
    if items and #items > 0 then
        self.sp_invite_all.Scrollable:Reset(1,#items)
        self:setSelectNode(1)
    else
        self.sp_invite_all.Scrollable:Reset(1,0)
    end

    
    if self.selectTitleIndex== 1 or self.menu.ExtParam == "single" then
        self.tbt_check.Visible = false
        self.lb_simple.Visible = false
    else
        self.tbt_check.Visible = true
        self.lb_simple.Visible = true
    end
end

function _M:setCallbackConfirm(callback)
    self.callbackConfirm = callback
end

local function setTitle(self,index,node)
    local data = self.accordionData[index]
    local ib_selected = node:FindChildByEditName("ib_selected",true)
    local lb_type_all = node:FindChildByEditName("lb_type_all",true)
    lb_type_all.Text = data.name
    node.Enable = true
    node.IsInteractive = true
    node.event_PointerClick = function()
        if self.selectTitleIndex == index then
            return
        end
        self.selectTitleIndex = index
        clearAllTitleSelect(self)
        ib_selected.Visible = true
        local cvs_type1 = node:FindChildByEditName("cvs_type1",false)   
        local cvs_type2 = node:FindChildByEditName("cvs_type2",false)   
        local cvs_type3 = node:FindChildByEditName("cvs_type3",false)   
        if ib_selected.UserData == "0" then
            cvs_type2.Visible = true
            cvs_type1.Visible = false
            cvs_type3.Visible = false
        elseif ib_selected.UserData == "1" then
            cvs_type2.Visible = false
            cvs_type1.Visible = true
            cvs_type3.Visible = false
            local tbt_check_simple = cvs_type1:FindChildByEditName("tbt_check_simple", true)
            local tbt_check_diff = cvs_type1:FindChildByEditName("tbt_check_diff", true)
            if (tbt_check_diff.IsChecked == false) then
                tbt_check_simple.IsChecked = true
            end
        elseif ib_selected.UserData == "2" then
            cvs_type2.Visible = false
            cvs_type1.Visible = false
            cvs_type3.Visible = true
            local tbt_check_simple = cvs_type3:FindChildByEditName("tbt_check_simple", true)
            local tbt_check_diff = cvs_type3:FindChildByEditName("tbt_check_diff", true)
            local tbt_check_hard = cvs_type3:FindChildByEditName("tbt_check_hard", true)
            if (tbt_check_diff.IsChecked == false and tbt_check_hard.IsChecked == false) then
                tbt_check_simple.IsChecked = true
            end
        end
        self:selectTitle()
    end
end

local function setNode(self,index,node)
    local item = self.selectData.items[index]
    local cvs_type1 = node:FindChildByEditName("cvs_type1",false)   
    local cvs_type2 = node:FindChildByEditName("cvs_type2",false)   
    local cvs_type3 = node:FindChildByEditName("cvs_type3",false)   
    local ib_selected = node:FindChildByEditName("ib_selected",false)
    local ctrlName = nil
    if item.data.HardChange == 0 then
        
        cvs_type2.Visible = true
        cvs_type1.Visible = false
        cvs_type3.Visible = false
        ctrlName = cvs_type2:FindChildByEditName("lb_amis_infor",true)
        ib_selected.UserData = "0"
    else
        if item.data.HeroMapID > 0 then
            cvs_type1.Visible = false
            cvs_type2.Visible = false
            cvs_type3.Visible = true
            ib_selected.UserData = "2"
            ctrlName = cvs_type3:FindChildByEditName("lb_nest_infor",true)
            local tbt_check_simple = cvs_type3:FindChildByEditName("tbt_check_simple",true)
            local tbt_check_diff = cvs_type3:FindChildByEditName("tbt_check_diff",true)
            local tbt_check_hard = cvs_type3:FindChildByEditName("tbt_check_hard",true)
            tbt_check_simple.IsChecked = false
            tbt_check_diff.IsChecked = false
            tbt_check_simple.Selected = function(sender)
                if sender.IsChecked then
                    tbt_check_diff.IsChecked = false
                    tbt_check_hard.IsChecked = false
                end
                if self.selectNodeIndex == index then
                    return
                end
                if sender.IsChecked then
                    self.selectNodeIndex = index
                    clearAllNodeSelect(self)
                    ib_selected.Visible = true
                end
            end
            tbt_check_diff.Selected = function(sender)
                if sender.IsChecked then
                    tbt_check_simple.IsChecked = false
                    tbt_check_hard.IsChecked = false
                end
                if self.selectNodeIndex == index then
                    return
                end
                if sender.IsChecked then
                    self.selectNodeIndex = index
                    clearAllNodeSelect(self)
                    ib_selected.Visible = true
                end
            end
            tbt_check_hard.Selected = function(sender)
                if sender.IsChecked then
                    tbt_check_simple.IsChecked = false
                    tbt_check_diff.IsChecked = false
                end
                if self.selectNodeIndex == index then
                    return
                end
                if sender.IsChecked then
                    self.selectNodeIndex = index
                    clearAllNodeSelect(self)
                    ib_selected.Visible = true
                end
            end
        else 
            cvs_type1.Visible = true
            cvs_type2.Visible = false
            cvs_type3.Visible = false
            ib_selected.UserData = "1"
            ctrlName = cvs_type1:FindChildByEditName("lb_nest_infor",true)
            local tbt_check_simple = cvs_type1:FindChildByEditName("tbt_check_simple",true)
            local tbt_check_diff = cvs_type1:FindChildByEditName("tbt_check_diff",true)
            tbt_check_simple.IsChecked = false
            tbt_check_diff.IsChecked = false
            tbt_check_simple.Selected = function(sender)
                if sender.IsChecked then
                    tbt_check_diff.IsChecked = false
                end
                if self.selectNodeIndex == index then
                    return
                end
                if sender.IsChecked then
                    self.selectNodeIndex = index
                    clearAllNodeSelect(self)
                    ib_selected.Visible = true
                end
            end
            tbt_check_diff.Selected = function(sender)
                if sender.IsChecked then
                    tbt_check_simple.IsChecked = false
                end
                if self.selectNodeIndex == index then
                    return
                end
                if sender.IsChecked then
                    self.selectNodeIndex = index
                    clearAllNodeSelect(self)
                    ib_selected.Visible = true
                end
            end
        end
    end
    ctrlName.Text = item.data.TargetName
    local ctrlName2 = cvs_type2:FindChildByEditName("lb_amis_infor",true)
    ctrlName2.Text = item.data.TargetName
    if self.selectNodeIndex ~= index then
        cvs_type2.Visible = true
        cvs_type1.Visible = false
        cvs_type3.Visible = false

        ib_selected.Visible = false
    else
        ib_selected.Visible = true
    end
    node.Enable = true
    node.IsInteractive = true
    node.event_PointerClick = function()
        if self.selectNodeIndex == index then
            return
        end
        self.tbt_check.IsChecked = true
        self.selectNodeIndex = index
        self:refreshLvLimit()
        clearAllNodeSelect(self)
        ib_selected.Visible = true
        local cvs = nil
        if ib_selected.UserData == "0" then
            cvs_type2.Visible = true
            cvs_type1.Visible = false
            cvs_type3.Visible = false
            cvs = cvs_type2
        elseif ib_selected.UserData == "1" then
            cvs_type2.Visible = false
            cvs_type1.Visible = true
            cvs_type3.Visible = false
            cvs = cvs_type1
        elseif ib_selected.UserData == "2" then
            cvs_type2.Visible = false
            cvs_type1.Visible = false
            cvs_type3.Visible = true
            cvs = cvs_type3
        end
        if item.data.HardChange == 1 then
            if ib_selected.UserData == "1" then
                local tbt_check_simple = cvs_type1:FindChildByEditName("tbt_check_simple",true)
                local tbt_check_diff = cvs_type1:FindChildByEditName("tbt_check_diff",true)
                if(tbt_check_diff.IsChecked == false) then
                    tbt_check_simple.IsChecked = true
                end
            elseif ib_selected.UserData == "2" then
                local tbt_check_simple = cvs_type3:FindChildByEditName("tbt_check_simple",true)
                local tbt_check_diff = cvs_type3:FindChildByEditName("tbt_check_diff",true)
                local tbt_check_hard = cvs_type3:FindChildByEditName("tbt_check_hard",true)
                if(tbt_check_diff.IsChecked == false and tbt_check_hard.IsChecked == false) then
                    tbt_check_simple.IsChecked = true
                end
            end
        end
    end
end

function _M:SetLabelText(label,count)
    if count == 0 then
        label.Text = ""
    else
        label.Text = count
    end
end

local stringformat_least = Util.GetText(TextConfig.Type.TEAM, "lesslevel")
local stringformat_max = Util.GetText(TextConfig.Type.TEAM, "morelevel")
local stringformat_lv = Util.GetText(TextConfig.Type.TEAM, "levelLimit")
local stringformat_final = Util.GetText(TextConfig.Type.TEAM, "textLv")

function _M:setTi_enterText()
    local text = TeamUtil.getTargetLvText(self.leastLimit, self.maxLimit)
    self.ti_enter.Text = text
end

function _M:SetLvText(label,count,format)
    if count == 0 then
        label.Text = ""
    else
        label.Text = string.format(format,count)
    end
end

function _M:OpenNumInput(label, textLbl,type)
    local view, numInput = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUINumberInput, 0)
    local x = label.X + label.Parent.X 
    local y = label.Y + label.Parent.Y + label.Parent.Parent.Y 
    local pos = { X = x-30, Y = y - 320 }
    numInput:SetPos(pos)
    local function funcClickCallback(value)
        if type == "least" then
            self.leastLimit = value
            self:SetLabelText(label,value)
            self:SetLvText(textLbl,value,stringformat_least)
        else
            self:SetLabelText(label,value)
            self.maxLimit = value
            self:SetLvText(textLbl,value,stringformat_max)
        end
    end

    local info = self.accordionData[self.selectTitleIndex].items[self.selectNodeIndex]
    
    local minCount = tonumber(info.data.OpenLv)
    local maxCount = tonumber(GlobalHooks.DB.Find("Parameters", { ParamName = "Role.LevelLimit" })[1].ParamValue)
    local canCount = 0
    if type == "least" then
        canCount  = minCount
        numInput:SetValue(minCount,maxCount,minCount,funcClickCallback)
    else
        numInput:SetValue(minCount,maxCount,maxCount,funcClickCallback)
        canCount = maxCount
    end
    self:SetLabelText(label,canCount)
end

function _M:OpenLvLimit()
    






















    self.cvs_enter_detail.Visible = true
    self.ti_least_level = self.cvs_enter_detail:FindChildByEditName("ti_least_level",true)
    self.ti_max_level = self.cvs_enter_detail:FindChildByEditName("ti_max_level",true)
    self.lb_explain_least = self.cvs_enter_detail:FindChildByEditName("lb_explain_least",true)
    self.lb_explain_max = self.cvs_enter_detail:FindChildByEditName("lb_explain_max",true)
    self.ti_least_level.Enable = true
    self.ti_least_level.IsInteractive = true
    self.ti_max_level.Enable = true
    self.ti_max_level.IsInteractive = true
    self:SetLabelText(self.ti_least_level,self.leastLimit)
    self:SetLvText(self.lb_explain_least,self.leastLimit,stringformat_least)
    self:SetLabelText(self.ti_max_level,self.maxLimit)
    self:SetLvText(self.lb_explain_max,self.maxLimit,stringformat_max)
    self.ti_least_level.event_PointerClick = function()
        self:OpenNumInput(self.ti_least_level,self.lb_explain_least,"least")
    end
    self.ti_max_level.event_PointerClick = function()
        self:OpenNumInput(self.ti_max_level,self.lb_explain_max,"max")
    end
end

local function InitComponent(self,tag)
    self.menu = LuaMenuU.Create("xmds_ui/team/team_aims.gui.xml", GlobalHooks.UITAG.GameUITeamTargetSet)
    self.menu.Enable = true
    self.menu.IsInteractive = true
    self.menu.event_PointerClick = function()
        self.menu:Close()
    end
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu:SubscribOnExit( function()
        self:OnExit()
    end )
    self.menu:SubscribOnEnter( function()
        self:OnEnter()
    end )
    self.menu:SubscribOnDestory( function()
        self:OnDestory()
    end )
    self.cvs_title.Visible = false
    self.sp_invite_title:Initialize(self.cvs_title.Width,self.cvs_title.Height,0,1,self.cvs_title,
        function(gx,gy,node)
            self.titleItems[gy + 1] = node
            setTitle(self,gy + 1,node)
        end,
        function()

        end
    )
    self.cvs_type.Visible = false
    self.sp_invite_all:Initialize(self.cvs_type.Width,self.cvs_type.Height,0,1,self.cvs_type,
        function(gx,gy,node)
            self.nodeItems[gy + 1] = node
            setNode(self,gy + 1,node)
        end,
        function()

        end
    )
    self.cvs_enter_detail.Visible = false
    self.cvs_enter_detail.Enable = true
    self.cvs_enter_detail.IsInteractive = true
    self.cvs_enter_detail.event_PointerClick = function()
        self.cvs_enter_detail.Visible = false
        self:setTi_enterText()
    end
    self.ti_enter.Enable = true
    self.ti_enter.IsInteractive = true
    self.ti_enter.event_PointerClick = function()
        self:OpenLvLimit()
    end
    self.leastLimit = 0
    self.maxLimit = 0
end

function _M.Create(tag,param)
    local self = {}
    setmetatable(self,_M)
    InitComponent(self,tag)
    return self
end

return _M

