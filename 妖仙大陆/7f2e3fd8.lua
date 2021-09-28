local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {menu = nil}

local function sortFunc(a, b)
    if a.state ~= b.state then
        if a.state == ActivityAPI.StateAlreadyGot then
            return false
        elseif b.state == ActivityAPI.StateAlreadyGot then
            return true
        end
    end
    return a.needNum < b.needNum
end

local function UpdateState(cell, state, idx)
    local ib_already = cell:FindChildByEditName("ib_already", true)
    ib_already.Visible = state == ActivityAPI.StateAlreadyGot

    local opBtn = cell:FindChildByEditName("btn_operation", true)
    opBtn.UserTag = idx
    opBtn.Visible = state ~= ActivityAPI.StateAlreadyGot
    opBtn.IsGray = state == ActivityAPI.StateAlreadyGot
    opBtn.TouchClick = OnOpDBCZBtnClick
    if state == ActivityAPI.StateCanGet then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "get")
    elseif state == ActivityAPI.StateCanNotGet then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "go")
    else
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "alreadyGot")
    end

    local effect = cell:FindChildByEditName("ib_effect", true)
    effect.Visible = state == ActivityAPI.StateCanGet
end

local function UpdateCell(gx, gy, node)
    local idx = gy + 1
    local info = self.infoList[idx]
    ActivityUtil.fillItemsStatic(info.item)
    ActivityUtil.fillItems(node, info.item, 4)
    UpdateState(node, info.state, idx)
    
    
    
    node:FindChildByEditName("tb_condition", true).UnityRichText = info.needNum .. Util.GetText(TextConfig.Type.SIGN, "yuan")
end

local function UpdateScrollPan()
    table.sort(self.infoList, sortFunc)

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
end

function OnOpDBCZBtnClick(sender)
    local info = self.infoList[sender.UserTag]
    if info.state == ActivityAPI.StateCanNotGet then
        EventManager.Fire('Event.Goto', {id = "Pay"})
    elseif info.state == ActivityAPI.StateCanGet then
        ActivityAPI.SingleRechargeAwardRequest(info.id, function()
            if self.menu then
                info.state = ActivityAPI.StateAlreadyGot
                UpdateScrollPan()
            end
        end)
    end
end

local function updateTimeAndDesc(beginTime, endTime, desc)
    self.tb_rule.XmlText = ActivityUtil.GetConfigTimeXml(beginTime, endTime, desc)
end

local function RequestInfo()
    if self.menu then
        local func = ActivityAPI.SingleRechargeGetInfoRequest(function ( data )
            if self.menu then
                self.infoList = data.singleRechargeAwardInfo or {}
                
                updateTimeAndDesc(data.beginTime, data.endTime, data.describe)
                UpdateScrollPan()
            end
        end)
    end
end

function  _M.OnEnter()
    self.activityData = GlobalHooks.DB.Find('Activity',self.ActivityID)

    RequestInfo()
    self.rechargeExt:start()
end
function _M.OnExit()
    self.rechargeExt:stop()
end

local ui_names = 
{
    {name = 'tb_rule'},
    {name = 'cvs_single'},
    {name = 'sp_see'},
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

    self.activityData = nil
    self.infoList = nil
    self.cvs_single.Visible = false
    self.scrollPanInited = false

    self.rechargeExt = UserDataValueExt.New(UserData.NotiFyStatus.DIAMOND,RequestInfo)
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
