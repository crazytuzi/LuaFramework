local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {menu = nil}

local function RecoveredRequest(ty,idx)
    local info = self.infoList[idx]
    local string = ""

    if ty == 0 then
        string = Util.GetText(TextConfig.Type.ACTIVITY, "RecoveredConfirm1", info.sourceName)
    else
        string = Util.GetText(TextConfig.Type.ACTIVITY, "RecoveredConfirm2", info.needDiamond, info.sourceName)
    end

    GameAlertManager.Instance:ShowAlertDialog(
        AlertDialog.PRIORITY_NORMAL, string,
        nil,nil,nil,nil,
        function()
            ActivityAPI.RecoveredRequest(info.id,ty,function(data)
                if self.menu then
                    info.state = 1
                    UpdateScrollPan()
                end
            end)
        end,
        nil
    )
end

local function UpdateCell(gx, gy, node)
    local idx = gy + 1
    local info = self.infoList[idx]
    if info and node then
        local lb_questname = node:FindChildByEditName("lb_questname", true)
        local lb_changenum = node:FindChildByEditName("lb_changenum", true)
        local ib_already = node:FindChildByEditName("ib_already", true)
        local btn_mianfei = node:FindChildByEditName("btn_mianfei", true)
        local btn_wanmei = node:FindChildByEditName("btn_wanmei", true)

        lb_questname.Text = info.sourceName
        lb_changenum.Text = "(" .. info.minDate .. "/" .. info.maxDate .. ")"

        ib_already.Visible = info.state == 1
        btn_mianfei.Visible = info.state == 0
        btn_wanmei.Visible = info.state == 0

        btn_mianfei.TouchClick = function ()
            RecoveredRequest(0,idx)
        end
        btn_wanmei.TouchClick = function ()
            RecoveredRequest(1,idx)
        end

        local itemCount = (info.recoveredItems and #info.recoveredItems) or 0
        for i=1,itemCount do
            if i <= 4 then
                local data = info.recoveredItems[i]
                local cvs_icon = node:FindChildByEditName("cvs_icon"..i, true)
                cvs_icon.Visible = true
                local detail = ItemModel.GetItemDetailByCode(data.code)
                local itshow = Util.ShowItemShow(cvs_icon,detail.static.Icon,detail.static.Qcolor,data.num,true)
                Util.NormalItemShowTouchClick(itshow,data.code,false)
            end
        end

        for i=1,4 do
            node:FindChildByEditName("cvs_icon"..i, true).Visible = i <= itemCount
        end
    end
end

function UpdateScrollPan()
    
    table.sort(self.infoList, function (aa,bb)
        return aa.state < bb.state
    end)

    if self.scrollPanInited then
        self.sp_see:ResetRowsAndColumns(#self.infoList, 1)
    else
        self.scrollPanInited = true
        
        self.sp_see:Initialize(self.cvs_single.Width, self.cvs_single.Height,
            #self.infoList, 1, self.cvs_single, 
            function (x, y, node)
                UpdateCell(x, y, node)
            end
          , 
          LuaUIBinding.HZTrusteeshipChildInit(function (node)
            
          end)
          )
    end

    self.lb_nores.Visible = #self.infoList == 0
end

local function updateTimeAndDesc(beginTime, endTime, describe)
    self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(beginTime, endTime, describe)
end

local function RequestInfo()
    if self.menu then
        ActivityAPI.RecoveredInfoRequest(function(data)
            if self.menu then
                self.infoList = data.recoveredSourceInfo or {}
                updateTimeAndDesc(data.beginTime, data.endTime, data.describe)
                UpdateScrollPan()
            end
        end)
    end
end

function  _M.OnEnter()
    RequestInfo()
end

function _M.OnExit()

end

local ui_names = 
{
    {name = 'tb_rule'},
    {name = 'cvs_single'},
    {name = 'sp_see'},
    {name = 'lb_nores'},
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

    self.infoList = nil
    self.cvs_single.Visible = false
    self.scrollPanInited = false

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
