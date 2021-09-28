local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local NumLabelExt = require "Zeus.Logic.NumLabelExt"
local UserDataValueExt = require "Zeus.Logic.UserDataValueExt"
local ActivityAPI = require "Zeus.Model.Activity"
local ActivityUtil = require "Zeus.UI.XmasterActivity.ActivityUtil"
local DisplayUtil = require "Zeus.Logic.DisplayUtil"

local self = {menu = nil,}

function onTabChange(tab)
    if not self.menu then return end

    self.tabIdx = table.indexOf(self.tabs, tab)
    if self.twoDataList then
        updateUI()
    else
        requestInfo()
    end
end

function updateUI()
    self.peopleCountExt:setValue(self.peopleCount)
    self.needVipLabel.Text = Util.GetText(TextConfig.Type.VIP, "VIPN", self.needVip)
    self.moneyLabel.Text = tostring(self.needMoney)
    self.buyBtn.Enable = self.buyState == 1 
    self.buyBtn.IsGray = self.buyState ~= 1 

    updateScrollPan()
end

function lookAtCanUseItem()
    local idx = nil
    for i,v in ipairs(self.twoDataList[self.tabIdx]) do
        if v.award.state == ActivityAPI.StateCanGet then
            idx = i
            break
        end
    end

    if idx then
        ActivityUtil.lookAtItemIdx(self.scrollPan, self.cell, idx)
    end
end

local function sortFunc(a, b)
    if a.award.state ~= b.award.state then
        if a.award.state == ActivityAPI.StateAlreadyGot then
            return false
        elseif b.award.state == ActivityAPI.StateAlreadyGot then
            return true
        end
    end
    return a.value < b.value
end

function updateScrollPan()

    local list = self.twoDataList[self.tabIdx]
    table.sort(list, sortFunc)

    if self.scrollPanInited then
        self.scrollPan:ResetRowsAndColumns(#list, 1)
    else
        self.scrollPan:Initialize(self.cell.Width, self.cell.Height,
            #list, 1, self.cell, updateCell, emptyFunc)
        self.scrollPanInited = true
    end

    lookAtCanUseItem()
end

function updateCell(gx, gy, cell)
    local idx = gy + 1

    local info = self.twoDataList[self.tabIdx][idx]

    cell:FindChildByEditName("lb_rewardnum", true).Text = tostring(info.diamond)
    local text = nil
    if self.tabIdx == 1 then
        if info.value > 10000 then
            text = DisplayUtil.upLvOrLvHtmlName(info.value - 10000)
            text = Util.GetText(TextConfig.Type.ACTIVITY, "fundConditionUpLv", text)
        else
            text = Util.GetText(TextConfig.Type.ACTIVITY, "fundCondition", info.value)
        end
    else
        text = Util.GetText(TextConfig.Type.ACTIVITY, "welfareCondition", info.value)
    end
    cell:FindChildByEditName("tb_condition", true).UnityRichText = string.format("<f>%s</f>", text)

    updateState(cell, info.award.state, idx, self.tabIdx == 1)
end

function updateState(cell, state, idx, checkBuyStatus)
    local bought = not checkBuyStatus and true or self.buyState == 2
    local opBtn = cell:FindChildByEditName("btn_operation", true)
    local ib_have = cell:FindChildByEditName("ib_have", true)
    ib_have.Visible = false
    opBtn.Visible = true
    opBtn.UserTag = idx
    opBtn.Enable = false
    opBtn.IsGray = true
    opBtn.TouchClick = onOpBtnClick
    if not bought then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "notbuy")
    elseif state == ActivityAPI.StateCanGet then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "get")
        opBtn.Enable = true
        opBtn.IsGray = false
    elseif state == ActivityAPI.StateCanNotGet then
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "notreached")
    else
        opBtn.Text = Util.GetText(TextConfig.Type.ACTIVITY, "alreadyGot")
        ib_have.Visible = true
        opBtn.Visible = false
    end

    local effect = cell:FindChildByEditName("ib_effect", true)
    effect.Visible = state == ActivityAPI.StateCanGet and bought
end

function onOpBtnClick(sender)
    local info = self.twoDataList[self.tabIdx][sender.UserTag]

    ActivityAPI.requestAward(self.activityData.ActivityID, info.award.awardId, function()
        if self.menu then
            info.award.state = ActivityAPI.StateAlreadyGot
            updateScrollPan()

            updateRedPoints()
            
            local activityData = GlobalHooks.DB.Find('Activity',self.activityData.ActivityID)


            
           local kingdomStr = self.activityData.ActivityID
           local phylumStr = activityData.Activity
           local classfieldStr = info.award.awardId

            local gainItem ={}
            for i =1,#info.award.awardItems,1 do 
                 local code = info.award.awardItems[i].code
                 local num = info.award.awardItems[i].groupCount
                 local name = GlobalHooks.DB.Find("Items", code).Name
                 local nameStr = name .. "(" .. code .. ")"
                 gainItem[nameStr] = num

            end
            Util.SendBIData("ActivityReward","",kingdomStr,phylumStr,classfieldStr,gainItem,"")
            
        end
    end)
end

function updateRedPoints()
    if not self.twoDataList then return end

    for i = 1, 2 do
        local hasRedPoint = false
        for _,v in ipairs(self.twoDataList[i]) do
            if v.award.state == ActivityAPI.StateCanGet and (i ~= 1 or self.buyState == 2) then
                hasRedPoint = true
                break
            end
        end
        self.redPoints[i].Visible = hasRedPoint
    end
end

function onBuyBtnClick(sender)
    if self.buyState ~= 1 then return end
    Util.checkRecharge(self.needMoney, function()
        ActivityAPI.requestBuyFund(function()
            self.buyBtn.Enable = false
            self.buyBtn.IsGray = true
            if self.menu then
                requestInfo()
            end
        end)
    end)
end

function requestInfo()
    ActivityAPI.requestFund(function(twoDataList, peopleCount, needMoney, needVip, buyState)
        if self.menu then
            self.peopleCount = peopleCount
            self.needMoney = needMoney
            self.needVip = needVip
            self.buyState = buyState

            self.twoDataList = {{}, {}}
            for i,v in ipairs(twoDataList or {}) do
                table.insert(self.twoDataList[v.type], v)
            end
            updateScrollPan()
            updateUI()
            updateRedPoints()
        end
    end)
end

function updateVip()
    self.currVipLabel.Text = tostring(DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.VIP))
end

function _M.OnEnter()
    self.activityData = GlobalHooks.DB.Find('Activity',self.ActivityID)
    self.descLabel.UnityRichText = self.activityData.ActivityRule

    updateVip()

    if not self.tabIdx then self.tabIdx = 1 end
    self.tabs[self.tabIdx].IsChecked = true

    self.vipExt:start()
end
function _M.OnExit()
    self.vipExt:stop()
    self.twoDataList = nil
end

local function InitComponent(self,xmlPath)
    self.menu = XmdsUISystem.CreateFromFile(xmlPath)

    self.descLabel = self.menu:FindChildByEditName("tb_prompt",true)
    self.needVipLabel = self.menu:FindChildByEditName("lb_needvip",true)
    self.currVipLabel = self.menu:FindChildByEditName("lb_vipnum",true)
    self.moneyLabel = self.menu:FindChildByEditName("lb_costnum",true)
    self.buyBtn = self.menu:FindChildByEditName("btn_buy",true)
    self.buyBtn.TouchClick = onBuyBtnClick

    local labels = {
        self.menu:FindChildByEditName("lb_num1",true),
        self.menu:FindChildByEditName("lb_num2",true),
        self.menu:FindChildByEditName("lb_num3",true),
        self.menu:FindChildByEditName("lb_num4",true),
    }
    self.peopleCountExt = NumLabelExt.New(labels)

    self.activityData = nil
    self.twoDataList = nil
    self.needVip = nil
    self.needMoney = nil
    self.peopleCount = nil
    self.buyState = nil

    self.vipExt = UserDataValueExt.New(UserData.NotiFyStatus.VIP, nil, nil, updateVip)

    self.cell = self.menu:FindChildByEditName("cvs_single",true)
    self.scrollPan = self.menu:FindChildByEditName("sp_see",true)
    self.cell.Visible = false
    self.scrollPanInited = false


    self.tabs = {
        self.menu:FindChildByEditName("tbt_fund",true),
        self.menu:FindChildByEditName("tbt_welfare",true),
    }
    self.redPoints = {
        self.menu:FindChildByEditName("ib_1",true),
        self.menu:FindChildByEditName("ib_2",true),
    }

    self.tabIdx = nil
    Util.InitMultiToggleButton(onTabChange,self.tabs[1], self.tabs)

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
