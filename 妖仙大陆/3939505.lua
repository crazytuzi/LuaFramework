local _M = {}
_M.__index = _M


local Util              = require "Zeus.Logic.Util"
local ActivityModel     = require 'Zeus.Model.Activity'
local ActivityUtil      = require "Zeus.UI.XmasterActivity.ActivityUtil"
local ExchangeUtil      = require "Zeus.UI.ExchangeUtil"
local ItemModel         = require 'Zeus.Model.Item'
local DisplayUtil = require "Zeus.Logic.DisplayUtil"


local self = {
    menu = nil,
}

local columns = 1
local exchangeIndex = 1

local function SortItemList(data)
    
    table.sort(data, function (aa,bb) 
        
        if aa.changeSate == 1 then
            if bb.changeSate ~= 1 then
                return true
            end
        end
    end)
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "cvs_icon1",
        "cvs_icon2",
        "cvs_icon3",
        "cvs_icon4",
        "ib_plus1",
        "ib_plus2",
        "btn_operation",
        "lb_changenum",
        "ib_not",
        "lb_num1",
        "lb_num2",
        "lb_num3",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end
end

local function RefreshItem(x, y, node)
    local index = y * columns + x
    local ui = {}
    if index >= #self.m_Items then
        node.Visible = false
        return
    end
    node.Visible = true
    local data = self.m_Items[index + 1]
    node.UserTag = index
    InitItemUI(ui, node)

    for i = 1, 3 do
        if data.costItem[i] ~= nil then
            local detail = ItemModel.GetItemDetailByCode(data.costItem[i].itemCode)
            
            ui["cvs_icon" .. i].Visible = true
            ui["lb_num" .. i].Visible = true
            local vItem = DataMgr.Instance.UserData.RoleBag:MergerTemplateItem(data.costItem[i].itemCode)
            local cur_num = (vItem and vItem.Num) or 0
            if cur_num >= data.costItem[i].itemNum then
                ui["lb_num" .. i].FontColor = Util.FontColorGreen
            else
                ui["lb_num" .. i].FontColor = Util.FontColorRed
            end
            ui["lb_num" .. i].Text = cur_num .. "/" .. data.costItem[i].itemNum

            
            local m_it = Util.ShowItemShow(ui["cvs_icon" .. i],detail.static.Icon,detail.static.Qcolor,1)
            Util.NormalItemShowTouchClick(m_it,data.costItem[i].itemCode,cur_num < data.costItem[i].itemNum)

        else
            ui["cvs_icon" .. i].Visible = false
            ui["lb_num" .. i].Visible = false
        end
    end

    ui.ib_plus2.Visible = #data.costItem >= 3
    ui.ib_plus1.Visible = #data.costItem >= 2

    if data.changeMax ~= nil then
        ui.lb_changenum.Visible = true
        ui.lb_changenum.Text = Util.GetText(TextConfig.Type.ACTIVITY, "changenum") .. (data.changeMax - data.changeNum) .. "/" .. data.changeMax
    else
        ui.lb_changenum.Visible = false
    end
    
    if data.changeMax - data.changeNum <= 0 then 
        ui.lb_changenum.FontColor = Util.FontColorRed
    else
        ui.lb_changenum.FontColor = Util.FontColorGreen
    end

    if data.rewardItem ~= nil then
        local detail = ItemModel.GetItemDetailByCode(data.rewardItem[1].itemCode)
        local m_it = Util.ShowItemShow(ui["cvs_icon4"],detail.static.Icon,detail.static.Qcolor,data.rewardItem[1].itemNum)
        Util.NormalItemShowTouchClick(m_it,detail.static.Code,false)

        
    end

    if data.changeSate == 1 then
        ui.btn_operation.IsGray = false
        ui.btn_operation.Enable = true
        ui.btn_operation.Text = Util.GetText(TextConfig.Type.ACTIVITY,'change')
    elseif data.changeSate == 0 then
        ui.btn_operation.IsGray = false
        ui.btn_operation.Enable = true
        ui.btn_operation.Text = Util.GetText(TextConfig.Type.ACTIVITY,'notreached')
    else
        ui.btn_operation.IsGray = true
        ui.btn_operation.Enable = false
        ui.btn_operation.Text = Util.GetText(TextConfig.Type.ACTIVITY,'change')
    end
    
    ui.ib_not.Visible = false
end

local function InitItem(node)
    if node ~= nil then
        LuaUIBinding.HZPointerEventHandler({node = node:FindChildByEditName("btn_operation", true), click = function (displayNode, pos)
            local index = node.UserTag
            local data = self.m_Items[index + 1]
            if data.changeSate ~= 2 then
                ActivityModel.requestAward(self.params.ActivityID ,data.changeId, function(params)
                    exchangeIndex = exchangeIndex + 1
                    ActivityModel.openChangeRequest(function(params)
                        self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(params.s2c_beginTime, params.s2c_endTime, params.s2c_content)
                        self.m_Items = params.s2c_changeInfo
                        for i = 1,#self.m_Items,1 do
                            local node = self.sp_see.Scrollable:GetCell(0,i-1)
                            if node ~= nil then
                                RefreshItem(i-1,0,node)
                            end
                        end
                    end)
                end)
            end
        end})
    end
end

local function InitItemList()
    local rows = 1
    if self.m_Items == nil then
        self.m_Items = {}
    else
        rows = math.ceil(#self.m_Items/columns)
    end

    local scrollable = self.sp_see.Scrollable
    local selectMakeSpPos2D = scrollable:GetScrollPos()
    scrollable:Reset(1,rows)
    scrollable:LookAt(-selectMakeSpPos2D)
end

function _M.GetData()
    
    ActivityModel.openChangeRequest(function(params)
        
        
        self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(params.s2c_beginTime, params.s2c_endTime, params.s2c_content)
        self.m_Items = params.s2c_changeInfo
        
        
    end)
end

function _M.OnEnter()
    self.params = GlobalHooks.DB.Find('Activity',self.ActivityID)
    exchangeIndex = 1
    ActivityModel.openChangeRequest(function(params)
        
        
        self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(params.s2c_beginTime, params.s2c_endTime, params.s2c_content)
        self.m_Items = params.s2c_changeInfo
        
        InitItemList()
    end)
end

function _M.OnExit()
    
end

local function InitUI()
    
    local UIName = {
        "sp_see",
        "cvs_single",
        "tb_rule",
    }
    for i = 1, #UIName do
        self[UIName[i]] = self.menu:FindChildByEditName(UIName[i],true)
    end
end

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    InitUI()
    self.sp_see:Initialize(self.cvs_single.Width, self.cvs_single.Height,  0, 1, self.cvs_single, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitItem))
    self.cvs_single.Visible = false
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
