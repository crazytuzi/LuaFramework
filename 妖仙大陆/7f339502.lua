local _M = {}
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local ActivityModel     = require 'Zeus.Model.Activity' 
local DisplayUtil = require "Zeus.Logic.DisplayUtil"

local self = {}

local function FindEquipListItem(self,controlName)
    local child_list = self.sp_show.Scrollable.Container:GetAllChild()
    local children = Util.List2Luatable(child_list)
    for _,v in ipairs(children) do
        if v.Name == controlName then
            return v
        end
    end
    return nil
end

local function GetWelfareInfo(activityId)
    
    if self.welfareLst == nil then
        return { 
        ["id"] = activityId,
    }
    
    end

    for i=1,#self.welfareLst do
        if self.welfareLst[i].id == activityId then
            return self.welfareLst[i]
        end
    end
    return nil
end

local function InitUI()
    local UIName = {
    	"btn_close",
        "cvs_main",
        "cvs_control",
        "sp_show",
        "lb_title",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end
    self.cvs_control.Visible = false
end

local function SwitchPage(sender)
    if self.showView ~= nil then
        self.showView.Visible = false
    end
    local script_table = self.scriptData[sender.Name]
    if script_table ~= nil then
        if script_table["menu"] ~= nil and script_table["menu"].isLoad then
            script_table["menu"]:OnEnter()
        else
            local lua_script = require (script_table["script"])
            script_table["menu"],script_table["node"] = lua_script.Create(script_table["ActivityID"],script_table["xmlPath"])
            self.cvs_main:AddChild(script_table["node"])

            script_table["menu"]:OnEnter()
            script_table["menu"].isLoad = true
        end 
        self.showView = script_table["node"]
        self.showView.Visible = true
    end
    self.lb_title.Text = sender.Text

    if self.selectName then
        local node = FindEquipListItem(self,self.selectName)
        if node then
            local btn = node:FindChildByEditName("tbt_name",false)
            if btn then
                btn.IsChecked = false
                btn.Enable = true
            end
        end
    end

    self.selectName = sender.Parent.Name
    
    sender.IsChecked = true
    sender.Enable = false
end

local function findWelfareScript(self,id)
    for i = 1,#self.script,1 do
        if(self.script[i].controlName == id) then
            return self.script[i]
        end
    end
    return nil
end

local function initWelfareScript(self)
    if self.script == nil then
        self.script = GlobalHooks.DB.Find('Welfare',{})
        table.sort(self.script, function (a,b)
            return a.id<b.id
        end )
    end
end

local function setNode(self,controlName,node)
    local info = findWelfareScript(self, controlName)
    
    local tbt_name = node:FindChildByEditName('tbt_name', false)
    tbt_name.Text = info.btnText
    tbt_name.Name = info.controlName
    node.Name = info.controlName
    table.insert(self.controlData, tbt_name)

    tbt_name.TouchClick = function(sender)
        SwitchPage(sender)
    end

    local lb_bj_name = node:FindChildByEditName('lb_bj_name', false)
    local num = DataMgr.Instance.FlagPushData:GetFlagState(info.FlagStatus)
    lb_bj_name.Visible =(num ~= nil and num > 0)

    local lb_name = node:FindChildByEditName('lb_name', false)
    lb_name.Visible = false

    local ib_pic = node:FindChildByEditName('ib_pic', false)
    Util.HZSetImage(ib_pic, info.Pic2d)
    if self.selectName then
        tbt_name.IsChecked = self.selectName == node.Name
        tbt_name.Enable = self.selectName ~= node.Name
    end
end


local function initScript(self)
    
    self.controlData = {} 
    self.controlNameData = {} 
    
    initWelfareScript(self)

    for i = 1, #self.script do
        if GetWelfareInfo(self.script[i].ActivityID) ~= nil then
            table.insert(self.controlNameData, self.script[i].controlName)
            if self.script[i].logicScript ~= "" then
                if self.scriptData[self.script[i].controlName] == nil then
                    local lua_script = require(self.script[i].logicScript)
                    local tempTab = {
                        ["menu"] = nil,
                        ["node"] = nil,
                        ["script"] = nil,
                        ["ActivityID"] = nil,
                        ["xmlPath"] = nil,
                    }
                    tempTab["script"] = self.script[i].logicScript
                    tempTab["ActivityID"] = self.script[i].ActivityID
                    tempTab["xmlPath"] = self.script[i].xmlPath
                    self.scriptData[self.script[i].controlName] = tempTab
                end
            end
        end
    end 

    
    local item_counts = #self.controlNameData
    self.sp_show.Scrollable:ClearGrid()
    if self.sp_show.Rows <= 0 then
        self.sp_show.Visible = true
        self.sp_show.Scrollable:Reset(1,item_counts)
    else
        self.sp_show.Rows = item_counts
    end 

    local index = 1
    if self.menu.ExtParam and self.menu.ExtParam ~= "" then
        for i,v in ipairs(self.controlNameData) do
            if v == self.menu.ExtParam then
                index = i
            end
        end
    end

    DisplayUtil.lookAt(self.sp_show,index,false)
    
    self.sp_show.Scrollable.event_Scrolled = function(sender,pos)
        local btn = self.controlData[index]
        if btn then
            SwitchPage(btn)
        end
        self.sp_show.Scrollable.event_Scrolled = function(sender)
        end
    end
    self.menu.ExtParam = nil
end

local function OnEnter()
    ActivityModel.ActivityLsRequest(function(params) 
       self.welfareLst = params.s2c_welfareLs
       initScript(self)   
        DataMgr.Instance.FlagPushData:AttachLuaObserver(self.menu.Tag, self)
    end) 
end

local function OnExit()
	self.showView = nil
    if self.scriptData ~= nil then 
        for _,v in pairs(self.scriptData) do
            if v["menu"] ~= nil then
                v["node"].Visible = false
                v["menu"]:OnExit()
            end
        end
    end
    DataMgr.Instance.FlagPushData:DetachLuaObserver(self.menu.Tag)
    

    self.selectName = nil
end


local function InitComponent(tag,params)
    self.menu = LuaMenuU.Create('xmds_ui/welfare/welfare_frame.gui.xml',tag)
    self.menu.ShowType = UIShowType.HideBackHud
    
    InitUI()
    initWelfareScript(self)
    self.scriptData = {} 
    local cs = self.cvs_control.Size2D
    self.sp_show:Initialize(cs.x, cs.y, 0, 1, self.cvs_control,
    function(gx, gy, node)
        setNode(self,self.controlNameData[gy + 1],node)
    end , function() end)
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)

    self.menu:SubscribOnDestory(function()
        
    end)

    self.btn_close.TouchClick = function()
        if self ~= nil and self.menu ~= nil then
        	self.menu:Close()
    	end
    end
    return self.menu
end

local function OnUpdateRedPoint(self,status)
    local script = GlobalHooks.DB.Find('Welfare',{})
    local controlName = ""
    for i=1,#script do
       if script[i].FlagStatus == status then 
            controlName = script[i].controlName
       end
    end 

    local node = FindEquipListItem(self,controlName)
    if node ~= nil then
        local lb_bj_name = node:FindChildByEditName('lb_bj_name',false)
        local num = DataMgr.Instance.FlagPushData:GetFlagState(status)
        lb_bj_name.Visible = (num ~= nil and num > 0)
    end
end

function _M.Notify(status, flagData)
    
    if self ~= nil and self.menu ~= nil then
        OnUpdateRedPoint(self,status)
    end
end


local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    InitComponent(tag, params)
    return self
end

return {Create = Create}
