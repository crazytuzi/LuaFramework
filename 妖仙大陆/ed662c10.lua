local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local ItemModel = require 'Zeus.Model.Item'
local FubenAPI = require "Zeus.Model.Fuben"
local FubenUtil = require "Zeus.UI.XmasterFuben.FubenUtil"


local self = {
    menu = nil,
}


local function RefreshBtnStatus()
    self.lb_num.Text = self.fubenInfo.lastTimes
    self.lb_num1.Text = self.fubenInfo.canBuyTimes
    self.lb_lv.Text = Util.GetText(TextConfig.Type.FUBEN, "enterDungeon")..self.fubenInfo.enterLevel
    local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)

    if lv >= self.fubenInfo.enterLevel then
        self.lb_lv.FontColor = Util.FontColorGreen
    else
        self.lb_lv.FontColor = Util.FontColorRed
    end

    if self.fubenInfo.lastTimes > 0 then
        self.lb_num.FontColor = Util.FontColorGreen
        
    else
        self.lb_num.FontColor = Util.FontColorRed
        
    end

    if self.fubenInfo.canBuyTimes > 0 then
        self.lb_num1.FontColor = Util.FontColorGreen
    else
        self.lb_num1.FontColor = Util.FontColorRed
    end
end

local function ReqBuyResFubenTime()
    if self.fubenInfo.canBuyTimes > 0 then
        local diamond = GlobalHooks.DB.Find("RechargeCost", self.fubenInfo.buyTimes+1).CostNum
        
        if diamond > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
            local content = Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan")
            local ok = Util.GetText(TextConfig.Type.SHOP, "OK")
            local cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
            local title = Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu")
            GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, ok, cancel, title, nil,  
            function()
                sendMsg()
            end, 
            function()
            end)
        else
            sendMsg()
        end
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.FUBEN, "resFubenBuyLimite"))
    end
end

local function ReqBuyResFubenTime()
    if self.fubenInfo.canBuyTimes > 0 then
        local function sendMsg()
            FubenAPI.reqBuyResFubenTime(self.fubenInfo.dungeonId, function()
                self.fubenInfo.lastTimes = self.fubenInfo.lastTimes + 1
                self.fubenInfo.canBuyTimes = self.fubenInfo.canBuyTimes - 1
                self.fubenInfo.buyTimes = self.fubenInfo.buyTimes + 1
                RefreshBtnStatus()
            end)
        end

        local diamond = GlobalHooks.DB.Find("RechargeCost", self.fubenInfo.buyTimes+1).CostNum
        local CostDiamond = Util.GetText(TextConfig.Type.FUBEN,'resFubenBuy')
        GameAlertManager.Instance:ShowAlertDialog(
            AlertDialog.PRIORITY_NORMAL, 
            string.format(CostDiamond,diamond),
            Util.GetText(TextConfig.Type.FUBEN, "ok"),
            Util.GetText(TextConfig.Type.FUBEN, "cancle"),
            nil,
            function()
                if diamond > DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.TICKET,0) then
                local content = Util.GetText(TextConfig.Type.SHOP, "notenouchbangyuan")
                local ok = Util.GetText(TextConfig.Type.SHOP, "OK")
                local cancel = Util.GetText(TextConfig.Type.SHOP, "Cancel")
                local title = Util.GetText(TextConfig.Type.SHOP, "bangyuanbuzu")
                GameAlertManager.Instance.AlertDialog:ShowAlertDialog(AlertDialog.PRIORITY_NORMAL, content, ok, cancel, title, nil, 
                    function()
                        sendMsg()
                    end, 
                    function()
                    end)
                else
                    sendMsg()
                end
            end,
            nil
        )
    else
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.FUBEN, "resFubenBuyLimite"))
    end
end

local function EnterFubenReq()
    if self.fubenInfo.lastTimes > 0 then
        FubenAPI.reqEnterResFubenTime(self.fubenInfo.dungeonId)
    else
        ReqBuyResFubenTime()
    end
end

local function SaodangFubenReq()
    if not self.fubenInfo.canSweep then
        GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.FUBEN, "connotSaodangRedFuben"))
    elseif self.fubenInfo.lastTimes > 0 then
        FubenAPI.resourceSweepRequest(self.fubenInfo.dungeonId, function (data)
            EventManager.Fire('Event.OnShowNewItems',{items = data})
            self.fubenInfo.lastTimes = self.fubenInfo.lastTimes - 1
            RefreshBtnStatus()
        end)
    else
        ReqBuyResFubenTime()
    end
end

local function InitDropCans(data)
    if data.awardItems ~= nil then
        local rewardList = string.split(data.awardItems,";")
        self.sp_iconList:Initialize(self.cvs_icon.Width+10, self.cvs_icon.Height, 1, #rewardList, self.cvs_icon,
          function(x, y, cell)
            local index = x + 1
            local rewardStr = string.split(rewardList[index],":")
            local detail = GlobalHooks.DB.Find("Items",rewardStr[1])
            local lb_numcount =  cell:FindChildByEditName("lb_numcount",true) 
            local ib_icon = cell:FindChildByEditName("ib_icon",true)
            lb_numcount.Text = rewardStr[2].."-"..rewardStr[3]
            ib_icon.Enable = true
            ib_icon.EnableChildren = true
            local itshow = Util.ShowItemShow(ib_icon,detail.Icon,detail.Qcolor)
            Util.NormalItemShowTouchClick(itshow,rewardStr[1],false)
            cell.Visible = true
          end,
          function()
    
          end
         )
    end
end

local function InitTitleAndDesc(data)
    self.lb_title.Text = data.Name
    self.tb_desc.UnityRichText = data.MapDesc
end










local function OnExit()

end

local function SwitchPage(sender)
    if sender == self.tbn_1 then
        self.pageIndex = 1
    elseif sender == self.tbn_2 then
        self.pageIndex = 2
    elseif sender == self.tbn_3 then
        self.pageIndex = 3
    end
    self.fubenInfo = self.infoDataList[self.pageIndex]
    local data = FubenAPI.getResFubenInfoById(self.fubenInfo.dungeonId)
    InitTitleAndDesc(data)
    InitDropCans(self.fubenInfo)
    RefreshBtnStatus()
end

local function OnEnter()
    self.infoDataList = {}
   
    local index = tonumber(self.menu.ExtParam)
    if index and index > 0 then
        FubenAPI.reqResFubenInfo(function(data)
            for i=1,#data do
                if index == data[i].playType then
                    table.insert(self.infoDataList,data[i])
                end
            end
            table.sort(self.infoDataList,function (a,b)
                return a.dungeonId < b.dungeonId
            end)
             Util.InitMultiToggleButton(function (sender)
                SwitchPage(sender)
            end,self.tbn_1,{self.tbn_1,self.tbn_2,self.tbn_3})
        end)
    end
end

local function InitCloneCans()

    self.btn_goto.TouchClick = function(sender)
        EnterFubenReq()
    end

    self.btn_saodang.TouchClick = function(sender)
        SaodangFubenReq()
    end
end

local function InitUI()
    local UIName = {
        "btn_close",
        "lb_title",
        "tb_desc",
        "lb_num",
        "lb_num1",
        "btn_goto",
        "btn_saodang",
        "tbn_1",
        "tbn_2",
        "tbn_3",
        "lb_lv",
        "cvs_icon",
        "sp_iconList",
    }

    for i = 1, #UIName do
        self[UIName[i]] = self.menu:GetComponent(UIName[i])
    end

    InitCloneCans()

    self.btn_close.TouchClick = function(sender)
        self.menu:Close()
        
    end
end

local function InitCompnent(params)
    InitUI()

    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/res/res_main.gui.xml", GlobalHooks.UITAG.GameUIResFubenSecondUI)
    InitCompnent(params)
    return self.menu
end

local function Create(params)
    setmetatable(self, _M)
    local node = Init(params)
    return self
end


local function initial()
    
end



return {Create = Create, initial = initial}
