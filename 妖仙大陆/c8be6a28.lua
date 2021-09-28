local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local GuildWarAPI = require "Zeus.Model.GuildWar"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {
    menu = nil,
}

local function Callback()
    EventManager.Fire("Event.GuildWar.RefreshMapList", {})
end

local function StopCdLabel()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
end

local function ShowApplyUI()
    self.cvs_apply.Visible = true
    GuildWarAPI.ApplyGuildFundRequest(function(data)
        self.fund = data
        self.lb_apply_fund.Text = self.fund
    end)
end

local function ShowApplyAddUI()
    self.cvs_apply_add.Visible = true
    GuildWarAPI.ApplyGuildFundRequest(function(data)
        self.fund = data
        self.lb_apply_fund_add.Text = self.fund
    end)
end

local function ShowApplyListUI()
    self.cvs_apply.Visible = false
    self.cvs_apply_result.Visible = true

    GuildWarAPI.GetGuildAreaApplyListRequest(tonumber(self.areaId), function(data)
        local applylist = data.applyList or {}
        self.sp_apply_list:Initialize(self.cvs_result.Width,self.cvs_result.Height+5,#applylist,1,self.cvs_result,
        function (gx,gy,node)
            local info = applylist[gy + 1]
            local ib_sucess = node:FindChildByEditName("ib_sucess", false)
            ib_sucess.Visible = info.isWinner

            local lb_guild = node:FindChildByEditName("lb_guild", false)
            lb_guild.Text = info.guildName

            local lb_level = node:FindChildByEditName("lb_level", false)
            lb_level.Text = info.guildLevel

            local lb_num = node:FindChildByEditName("lb_num", false)
            lb_num.Text = info.guildNumberCount

            local lb_leader = node:FindChildByEditName("lb_leader", false)
            lb_leader.Text = info.guildLeaderName

            local lb_fund = node:FindChildByEditName("lb_fund", false)
            if info.applyFund == 0 then
                lb_fund.Text = "－"
            else
                lb_fund.Text = info.applyFund
            end

            local btn_cancel = node:FindChildByEditName("btn_cancel", false)
            btn_cancel.TouchClick = function ()
                GameAlertManager.Instance:ShowAlertDialog(
                    AlertDialog.PRIORITY_NORMAL, 
                    Util.GetText(TextConfig.Type.GUILDWAR, "cancelFundTips"),
                    Util.GetText(TextConfig.Type.FUBEN, "ok"),
                    Util.GetText(TextConfig.Type.FUBEN, "cancle"),
                    nil,
                    function()
                        GuildWarAPI.ApplyCancelFundRequest(tonumber(self.areaId), function()
                            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "cancelFundSuccess"))
                            self.menu:Close()
                            Callback()
                        end)
                    end,
                    nil
                )
            end
            btn_cancel.Visible = data.countDown and data.countDown > 0 and info.applyFund > 0
        end,function () end)

        StopCdLabel()
        if data.countDown and data.countDown > 0 then
            local function format(cd,label)
                if cd <= 0 then
                    StopCdLabel()
                    self.lb_result_time.Visible = false
                    ShowApplyListUI()
                    return
                else
                    self.lb_result_time.Visible = true
                    return ServerTime.GetCDStrCut(cd) .. Util.GetText(TextConfig.Type.GUILDWAR, "gongbu")
                end
            end
            self.CDLabelExt = CDLabelExt.New(self.lb_result_time,data.countDown,format)
            self.CDLabelExt:start()
        else
            self.lb_result_time.Visible = false
        end
    end)
end

local function OnEnter()
    self.fund = 0
    self.applyFund = self.MinApplyFun
    self.input_apply.Input.Text = self.MinApplyFun

    self.cvs_apply.Visible = false
    self.cvs_apply_add.Visible = false
    self.cvs_apply_result.Visible = false

    if self.menu.ExtParam then
        local params = string.split(self.menu.ExtParam, "|")
        self.areaId = params[2]
        if params[1] == "apply" then
            ShowApplyUI()
        elseif params[1] == "applyAdd" then
            ShowApplyAddUI()
        elseif params[1] == "applylist" then
            ShowApplyListUI()
        end
    end
end

local function OnExit()
    StopCdLabel()
end

local ui_names = 
{
  
    {name = 'btn_close'},

    {name = 'cvs_apply'},
    {name = 'lb_apply_fund'},
    {name = 'input_apply'},
    {name = 'bt_apply_cancel'},
    {name = 'bt_apply_confirm'},

    {name = 'cvs_apply_add'},
    {name = 'lb_apply_fund_add'},
    {name = 'input_apply_add'},
    {name = 'bt_apply_cancel_add'},
    {name = 'bt_apply_confirm_add'},

    {name = 'cvs_apply_result'},
    {name = 'cvs_result'},
    {name = 'sp_apply_list'},
    {name = 'lb_result_time'},
}

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)

    self.MinApplyFun = tonumber(GlobalHooks.DB.Find("Parameters", {ParamName = "GuildFort.MinBetMoney"})[1].ParamValue)

    self.cvs_result.Visible = false

    self.btn_close.TouchClick = function ()
        self.menu:Close()
    end

    self.cvs_apply.TouchClick = function ()
        self.menu:Close()
    end

    self.cvs_apply_add.TouchClick = function ()
        self.menu:Close()
    end

    self.bt_apply_cancel.TouchClick = function ()
        self.menu:Close()
    end

    self.bt_apply_cancel_add.TouchClick = function ()
        self.menu:Close()
    end

    self.input_apply.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self.input_apply.TextSprite.Anchor = TextAnchor.L_C
    self.input_apply.event_endEdit = function (sender,txt)
        if txt == nil then
          return
        end
        if tonumber(txt) > 0 then
            self.input_apply.Input.Text = tostring(txt)
            self.applyFund = tonumber(txt)
        end
    end

    self.bt_apply_confirm.TouchClick = function ()
        if self.applyFund > self.fund then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "fundOverflow"))
        elseif self.applyFund < self.MinApplyFun then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "fundApplyMin", self.MinApplyFun))
        else
            GuildWarAPI.ApplyFundRequest(tonumber(self.areaId), self.applyFund, function()
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "fundSuccess"))
                ShowApplyListUI()
                Callback()
            end)
        end
    end

    self.input_apply_add.Input.contentType = UnityEngine.UI.InputField.ContentType.IntegerNumber
    self.input_apply_add.TextSprite.Anchor = TextAnchor.L_C
    self.input_apply_add.event_endEdit = function (sender,txt)
        if txt == nil then
          return
        end
        if tonumber(txt) > 0 then
            self.input_apply_add.Input.Text = tostring(txt)
            self.applyFund = tonumber(txt)
        end
    end

    self.bt_apply_confirm_add.TouchClick = function ()
        if self.applyFund > self.fund then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "fundOverflow"))
        elseif self.applyFund < self.MinApplyFun then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "fundApplyMin", self.MinApplyFun))
        else
            GuildWarAPI.ApplyFundRequest(tonumber(self.areaId), self.applyFund, function()
                GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "fundAddSuccess"))
                ShowApplyListUI()
                Callback()
            end)
        end
    end
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/guild/guild_judian_apply.gui.xml", GlobalHooks.UITAG.GameUIGuildWarApply)
    self.menu.Enable = true
    self.menu.mRoot.Enable = true
    self.menu.ShowType = UIShowType.HideBackHud
  
    InitCompnent()
    self.menu:SubscribOnEnter(OnEnter)
    self.menu:SubscribOnExit(OnExit)
    self.menu:SubscribOnDestory(function ()
        self = nil
    end)
    return self.menu
end

local function Create(params)
    self = {}
    setmetatable(self, _M)
    local node = Init(params)
    return self
end

return {Create = Create}
