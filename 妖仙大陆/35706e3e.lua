local _M = {}
_M.__index = _M


local Util              = require "Zeus.Logic.Util"
local ActivityModel     = require 'Zeus.Model.Activity'
local ActivityUtil      = require "Zeus.UI.XmasterActivity.ActivityUtil"
local ExchangeUtil      = require "Zeus.UI.ExchangeUtil"


local self = {
    menu = nil,
}

local columns = 1

local function SortItemList(data)
    
    table.sort(data, function (aa,bb) 
        
        if bb.state == 2 then
            if aa.state ~= 2 then
                return true
            else
                if  aa.needValue < bb.needValue then
                    return true
                else
                    return false
                end
            end
        else
            if aa.state == 2 then
                return false
            else
                if  aa.needValue < bb.needValue then
                    return true
                else
                    return false
                end
            end
        end
    end)
end

local function InitItemUI(ui, node)
    
    local UIName = {
        "lb_lvnum",
        "cvs_icon1",
        "cvs_icon2",
        "cvs_icon3",
        "cvs_icon4",
        "cvs_icon5",
        "lb_lv",
        "btn_operation",
        "ib_effect",
        "ib_have",
    }

    for i = 1, #UIName do
        ui[UIName[i]] = node:FindChildByEditName(UIName[i], true)
    end

    if self.fontcolor == nil then
        self.fontcolor = ui.lb_lvnum.FontColorRGBA
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

    for i = 1, #data.awardItems do
        local item = Util.ShowItemShow(ui["cvs_icon" .. i],data.awardItems[i].icon,data.awardItems[i].qColor,data.awardItems[i].groupCount)
        Util.NormalItemShowTouchClick(item,data.awardItems[i].code,false)
        ui["cvs_icon" .. i].Visible = true
    end

    for i = #data.awardItems + 1, 5 do
        ui["cvs_icon" .. i].Visible = false
    end

    local activityData = self.activityDatas[self.ActivityID]              
    if activityData.ActivityTab == 5 then
        ui.lb_lv.Text = Util.GetText(TextConfig.Type.ACTIVITY,'level')
        ui.lb_lvnum.Text = data.needValue
        ui.lb_lvnum.FontColorRGBA = self.fontcolor
    else 
        ui.lb_lv.Text = Util.GetText(TextConfig.Type.ACTIVITY,'zhanli')
        ui.lb_lvnum.Text = data.needValue
        ui.lb_lvnum.FontColorRGBA = self.fontcolor
    end

    ui.btn_operation.Visible = true
    ui.ib_have.Visible = false
    if data.state == 2 then
        ui.btn_operation.IsGray = true
        ui.btn_operation.Text = Util.GetText(TextConfig.Type.ACTIVITY,'alreadyreceive')
        ui.btn_operation.Enable = false
        ui.btn_operation.Visible = false
        ui.ib_have.Visible = true
        ui.ib_effect.Visible = false
    elseif data.state == 1 then
        ui.btn_operation.IsGray = false
        ui.btn_operation.Text = Util.GetText(TextConfig.Type.ACTIVITY,'get')
        ui.btn_operation.Enable = true
        ui.ib_effect.Visible = true
    else
        ui.btn_operation.IsGray = false
        ui.btn_operation.Text = Util.GetText(TextConfig.Type.ACTIVITY,'notreached')
        ui.btn_operation.Enable = true
        ui.ib_effect.Visible = false
    end
end

local function InitItem(node)
    if node ~= nil then
        LuaUIBinding.HZPointerEventHandler({node = node:FindChildByEditName("btn_operation", true), click = function (displayNode, pos)
            local index = node.UserTag
            local data = self.m_Items[index + 1]
            if data.state == 2 then
                
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACTIVITY,'alreadyreceive'))
            else
                local activityData = self.activityDatas[self.ActivityID]   
                if activityData.ActivityTab == 5 then    
                    local value = tonumber(data.needValue)
                    if value > DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL) then
                        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACTIVITY,'need_lv') .. tonumber(data.needValue))
                        return
                    end
                else    
                    if tonumber(data.needValue) > DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.FIGHTPOWER) then
                        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.ACTIVITY,'need_zhanli').. tonumber(data.needValue))
                        return
                    end
                end    
                
                ActivityModel.requestAward(self.ActivityID ,data.awardId, function(params)
                
                    local kingdomStr = self.ActivityID
                    local phylumStr = activityData.Activity
                    local classfieldStr = data.awardId

                    local gainItem ={}
                    for i =1,#data.awardItems,1 do 
                        local code = data.awardItems[i].code
                        local num = data.awardItems[i].groupCount
                        local name = GlobalHooks.DB.Find("Items", code).Name
                        local nameStr = name .. "(" .. code .. ")"
                        gainItem[nameStr] = num

                    end
                    Util.SendBIData("ActivityReward","",kingdomStr,phylumStr,classfieldStr,gainItem,"")
                 
                    self.OnEnter()
                end)
            end
        end})
    end
end

function _M.InitItemList()
    local rows = 1
    if self.m_Items == nil then
        self.m_Items = {}
    else
        rows = math.ceil(#self.m_Items/columns)
    end
    self.sp_see.Scrollable:Reset(1,rows)



end

function _M.OnEnter()
    ActivityModel.activityLevelOrSwordRequest(self.ActivityID, function(params)
        

        self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(params.s2c_beginTime, params.s2c_endTime, params.s2c_content)

        self.m_Items = params.s2c_data
        SortItemList(self.m_Items)
        _M.InitItemList()
    end)
    
    
    
end

function _M.OnExit()

end
local ui_names = 
{
    {name = 'sp_see'},
    {name = 'cvs_single'},
    {name = 'btn_help'},
    {name = 'tb_rule'},
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
    tbl.cvs_single.Visible = false
end

local function InitComponent(self,xmlPath)
    self.activityDatas = GlobalHooks.DB.Find('Activity',{})
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)
    initControls(self.menu,ui_names,self)
    self.sp_see:Initialize(self.cvs_single.Width, self.cvs_single.Height,  0, 1, self.cvs_single, 
        LuaUIBinding.HZScrollPanUpdateHandler(RefreshItem), 
        LuaUIBinding.HZTrusteeshipChildInit(InitItem))
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
