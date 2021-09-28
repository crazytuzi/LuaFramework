local _M = {}
_M.__index = _M
local Util = require "Zeus.Logic.Util"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"

local self = {menu = nil}

local function RefreshEffect(status, node)
    Util.clearAllEffect(node)
    if status == true then
        Util.showUIEffect(node,3)
    end
end

local function UpdateAwardList()
    local count = #self.infoList
    for i=1,3 do
        local node = self.AwardNodeList[i]
        local show = false
        if i <= count then
            local data = self.infoList[i]
            node.Visible = true
            local ib_box = node:FindChildByEditName("ib_box", true)
            local ib_boxopen = node:FindChildByEditName("ib_boxopen", true)
            local ib_point = node:FindChildByEditName("ib_point", true)
            local lb_jindu = node:FindChildByEditName("lb_jindu", true)

            ib_box.Visible = data.state == ActivityAPI.StateCanNotGet or data.state == ActivityAPI.StateCanGet
            ib_boxopen.Visible = data.state == ActivityAPI.StateAlreadyGot
            ib_point.Visible = data.state == ActivityAPI.StateCanGet
            lb_jindu.Text = data.needNum .. Util.GetText(TextConfig.Type.SIGN, "yuanbao")
            node.TouchClick = function (sender)
                if data.state == ActivityAPI.StateCanGet then
                    ActivityAPI.DailyRechargeGetAwardRequest(data.awardId, function()
                        if self.menu then
                            data.state = ActivityAPI.StateAlreadyGot
                            UpdateAwardList()
                            
                            local activityData = GlobalHooks.DB.Find('Activity',self.activityData.ActivityID)
                            
                            local kingdomStr = self.activityData.ActivityID
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
                        end
                    end)
                else
                    EventManager.Fire('Event.OnPreviewItems',{items = data.awardItems})
                end
            end

            show = data.state == ActivityAPI.StateCanGet
        else
            self.AwardNodeList[i].Visible = false
        end
        RefreshEffect(show,node)
    end
end

local function updateTimeAndDesc(beginTime, endTime, desc)
    self.tb_time.XmlText = ActivityUtil.GetConfigTimeXml(beginTime, endTime, desc)
end

local function updateRechargeJindu(data)
    self.lb_jinduzhi.Text = data.rechargeNum .. "/" .. data.rechargeMax .. Util.GetText(TextConfig.Type.SIGN, "yuanbao")
    local percentage =(data.rechargeNum / data.rechargeMax > 1) and 1 or(data.rechargeNum / data.rechargeMax)
    percentage = (percentage < 0 ) and 0 or percentage
    self.gg_pace2.Value = percentage * 100
end

local function RequestInfo()
    if self.menu then
        ActivityAPI.DailyRechargeGetInfoRequest(function(data)
            if self.menu then
                self.infoList = data.totalInfo.awards or {}
                updateTimeAndDesc(data.totalInfo.beginTime, data.totalInfo.endTime, data.totalInfo.describe)
                updateRechargeJindu(data)
                UpdateAwardList()
            end
        end)
    end
end

function  _M.OnEnter()
    self.activityData = GlobalHooks.DB.Find('Activity',self.ActivityID)
    RequestInfo()
    self.rechargeExt:start()

    self.btn_charge.TouchClick = function (sender)
        EventManager.Fire('Event.Goto', {id = "Pay"})
    end
end
function _M.OnExit()
    self.rechargeExt:stop()
end

local ui_names = 
{
    {name = 'tb_time'},
    {name = 'btn_charge'},
    {name = 'lb_jinduzhi'},
    {name = 'gg_pace2'},
    {name = 'cvs_1'},
    {name = 'cvs_2'},
    {name = 'cvs_3'},
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

    self.AwardNodeList = {self.cvs_1,self.cvs_2,self.cvs_3}
    self.activityData = nil
    self.infoList = nil

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
