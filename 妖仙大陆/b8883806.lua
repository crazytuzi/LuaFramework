local _M = {}
_M.__index = _M

local Util = require "Zeus.Logic.Util"
local TreeView = require "Zeus.Logic.TreeView"
local ItemModel = require 'Zeus.Model.Item'
local GuildWarAPI = require "Zeus.Model.GuildWar"
local CDLabelExt = require "Zeus.Logic.CDLabelExt"
local ServerTime = require "Zeus.Logic.ServerTime"

local self = {
    menu = nil,
}

local function SetGuildWarDailyAwardFlag()
    self.ib_dailyAward.Visible = DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_AWARD) > 0
end

local function SetGuildWarFlag()
    self.ib_reward.Visible = false
    self.ib_apply.Visible = self.btn_apply.Visible and DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_APPLY) > 0
    self.ib_tiaozhan.Visible = self.btn_tiaozhan.Visible and DataMgr.Instance.FlagPushData:GetFlagState(FlagPushData.FLAG_GUILD_WAR_ACCESS) > 0
end

local function ShowStatisticsDetail(date, areaId, guildId)
    GuildWarAPI.ApplyReportStatisticsRequest(date, areaId, guildId, function(data)
        local node,lua_obj = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarStatistics, 0)
        lua_obj.SetStatisticsDetail(data)
    end)
end

local function UpdateGuildCell(can, date, areaId, data)
    local lb_report_guild = can:FindChildByEditName("lb_report_guild", true)
    local ib_report_sucess = can:FindChildByEditName("ib_report_sucess", true)
    local ib_report_failed = can:FindChildByEditName("ib_report_failed", true)
    local lb_report_collect = can:FindChildByEditName("lb_report_collect", true)
    local lb_report_collect_attr = can:FindChildByEditName("lb_report_collect_attr", true)
    local lb_report_soul = can:FindChildByEditName("lb_report_soul", true)
    local lb_report_soul_attr = can:FindChildByEditName("lb_report_soul_attr", true)
    local lb_report_kill = can:FindChildByEditName("lb_report_kill", true)
    local lb_report_kill_attr = can:FindChildByEditName("lb_report_kill_attr", true)
    local lb_report_flag = can:FindChildByEditName("lb_report_flag", true)
    local lb_report_flag_attr = can:FindChildByEditName("lb_report_flag_attr", true)
    local lb_report_rate = can:FindChildByEditName("lb_report_rate", true)
    local btn_report_detail = can:FindChildByEditName("btn_report_detail", true)
    if data == nil or data.guildName == "" then
        lb_report_guild.Text = Util.GetText(TextConfig.Type.GUILDWAR, "wu")
        ib_report_sucess.Visible = false
        lb_report_collect.Text = "-"
        lb_report_collect_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "fangyuzhi") .. "-"
        lb_report_soul.Text = "-"
        lb_report_soul_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "gongjili") .. "-"
        lb_report_kill.Text = "-"
        lb_report_kill_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "jifen") .. "-"
        lb_report_flag.Text = "-"
        lb_report_flag_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "jifen") .. "-"
        lb_report_rate.Text = "-"
        btn_report_detail.Visible = false
    else
        if data.isWinner == 1 then
            ib_report_sucess.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|25", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
        else
            ib_report_sucess.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|24", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
        end
        ib_report_sucess.Visible = true
        lb_report_guild.Text = data.guildName
        lb_report_collect.Text = data.collect
        lb_report_collect_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "fangyuzhi") .. data.defense
        lb_report_soul.Text = data.soul
        lb_report_soul_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "gongjili") .. data.attack
        lb_report_kill.Text = data.kill
        lb_report_kill_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "jifen") .. data.killScore
        lb_report_flag.Text = data.destroyFlag
        lb_report_flag_attr.Text = Util.GetText(TextConfig.Type.GUILDWAR, "jifen") .. data.destroyFlagScore
        lb_report_rate.Text = data.totalScore
        btn_report_detail.Visible = true
        btn_report_detail.TouchClick = function ()
            ShowStatisticsDetail(date, areaId, data.guildId)
        end
    end
end

local function ShowReportDetail(date, areaId)
    GuildWarAPI.ApplyReportDetailRequest(date, areaId, function(data)
        self.cvs_report_info.Visible = true

        local ret = GlobalHooks.DB.Find('GuildFort',areaId)
        local lb_report_info = self.cvs_report_info:FindChildByEditName("lb_report_info", true)
        lb_report_info.Text = ret.Name

        local cvs_report_info1 = self.cvs_report_info:FindChildByEditName("cvs_report_info1", true)
        local cvs_report_info2 = self.cvs_report_info:FindChildByEditName("cvs_report_info2", true)
        UpdateGuildCell(cvs_report_info1, date, areaId, data.reportDetail.detail1)
        UpdateGuildCell(cvs_report_info2, date, areaId, data.reportDetail.detail2)
    end)
end

local function RefreshReportList(reportList)
    if self.treeView and self.treeView.view then
        self.sp_report_list:RemoveNormalChild(self.treeView.view, true)
    end

    local subValues = {}
    local subValueChild = {}
    if reportList and #reportList > 0 then
        for i,v in ipairs(reportList) do
            local count = 0
            if v.reportListInfo and #v.reportListInfo > 0 then
                count = #v.reportListInfo
            end
            table.insert(subValueChild, count)
        end
    end

    local cvs_typename = self.cvs_report_item:FindChildByEditName("cvs_typename", true)
    local tbt_subtype = self.cvs_report_item:FindChildByEditName("tbt_subtype", true)

    self.treeView = TreeView.Create(#subValueChild,0,self.sp_report_list.Size2D,TreeView.MODE_SINGLE)
    local function rootCreateCallBack(index,node)
        node.Enable = true
        local lb_title = node:FindChildByEditName("lb_typename", false)
        lb_title.Text = reportList[index].date
    end
    local function rootClickCallBack(node,visible)
        local tbt_open = node:FindChildByEditName("tbt_open",false)
        tbt_open.IsChecked = visible
        if visible == true then
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey('zuobiaoqian')
        end
    end
    local rootValue = TreeView.CreateRootValue(cvs_typename,#subValueChild,rootCreateCallBack,rootClickCallBack)

    local function subClickCallback(rootIndex,subIndex,node)

    end
    local function subCreateCallback(rootIndex,subIndex,node)
        local data = reportList[rootIndex].reportListInfo[subIndex]
        if data then
            local ret = GlobalHooks.DB.Find('GuildFort',data.areaId)
            local lb_judian_name = node:FindChildByEditName("lb_judian_name", false)
            local ib_defguild_identify = node:FindChildByEditName("ib_defguild_identify", false)
            local lb_defguild_name = node:FindChildByEditName("lb_defguild_name", false)
            local ib_atkguild_identify = node:FindChildByEditName("ib_atkguild_identify", false)
            local lb_atkguild_name = node:FindChildByEditName("lb_atkguild_name", false)
            local btn_tiaozhan = node:FindChildByEditName("btn_tiaozhan", false)
            lb_judian_name.Text = ret.Name 
            if data.result == 0 then
                ib_defguild_identify.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|25", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                ib_atkguild_identify.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|24", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
            elseif data.result == 1 then
                ib_defguild_identify.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|24", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                ib_atkguild_identify.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|25", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
            else
                ib_defguild_identify.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|24", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
                ib_atkguild_identify.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/solo.xml|solo|24", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
            end
            
            if not data.defenseGuildName or data.defenseGuildName == "" then
                lb_defguild_name.Text = Util.GetText(TextConfig.Type.GUILDWAR, "wu")
            else
                lb_defguild_name.Text = data.defenseGuildName
            end

            if not data.attackGuildName or data.attackGuildName == "" then
                lb_atkguild_name.Text = Util.GetText(TextConfig.Type.GUILDWAR, "wu")
            else
                lb_atkguild_name.Text = data.attackGuildName
            end

            btn_tiaozhan.TouchClick = function ()
                ShowReportDetail(reportList[rootIndex].date, data.areaId)
            end
        end
    end

    for i=1,#subValueChild do
        subValues[i] = TreeView.CreateSubValue(i,tbt_subtype,subValueChild[i], subClickCallback, subCreateCallback)
    end
    self.treeView:setValues(rootValue,subValues)
    self.sp_report_list:AddNormalChild(self.treeView.view)

    if reportList and #reportList > 0 then
        self.treeView:selectNode(1,1,true)
    end
end

local function UpdateItemCell(cell, data)
    if data == nil then
        cell.Visible = false
        return
    end
    cell.Visible = true
    local detail = ItemModel.GetItemDetailByCode(data.code)
    local itshow = Util.ShowItemShow(cell,detail.static.Icon,detail.static.Qcolor,data.groupCount,true)
    Util.NormalItemShowTouchClick(itshow,data.code,false)
end

local function CreatItemShowList(sp, can, itemList)
    sp:Initialize(can.Width+10, can.Height, 1, #itemList, can, 
        LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
            local itemData = itemList[x+1]
            UpdateItemCell(node, itemData)
        end),
        LuaUIBinding.HZTrusteeshipChildInit(function (node)

        end)
    )
end

local function RefreshDailyAwardCell(node, data)
    local lb_reward_area = node:FindChildByEditName("lb_reward_area",true)
    local ret = GlobalHooks.DB.Find('GuildFort',data.areaId)
    lb_reward_area.Text = ret.Name

    local lb_reward_guild = node:FindChildByEditName("lb_reward_guild",true)
    if data == nil or data.guildName == "" then
        lb_reward_guild.Text = Util.GetText(TextConfig.Type.GUILDWAR, "lunkong")
        lb_reward_guild.FontColor = Util.FontColorRed
    else
        lb_reward_guild.Text = data.guildName
        lb_reward_guild.FontColor = Util.FontColorWhite
    end

    local sp_dailyAward_list1 = node:FindChildByEditName("sp_dailyAward_list1",true)
    sp_dailyAward_list1.Scrollable.IsInteractive = true
    CreatItemShowList(sp_dailyAward_list1, self.cvs_item, data.dailyAwardList or {})

    local btn_dailyAward = node:FindChildByEditName("btn_dailyAward",true)
    local ib_flag_dailyAward = node:FindChildByEditName("ib_flag_dailyAward",true)
    local ib_have = node:FindChildByEditName("ib_have",true)

    btn_dailyAward.Visible = data.status == 1
    ib_flag_dailyAward.Visible = data.status == 1
    ib_have.Visible = data.status == 2
    btn_dailyAward.TouchClick = function ()
        GuildWarAPI.ApplyDailyAwardRequest(data.areaId, function()
            data.status = 2
            RefreshDailyAwardCell(node, data)
            SetGuildWarDailyAwardFlag()
        end)
    end
end

local function RefreshDailyAwardList(awardList)
    local count = #awardList
    self.lb_reward_tips.Visible = count <= 0

    self.sp_dailyAward:Initialize(self.cvs_dailyAward1.Width, self.cvs_dailyAward1.Height+10, count, 1, self.cvs_dailyAward1, 
        LuaUIBinding.HZScrollPanUpdateHandler(function (x, y, node)
            local data = awardList[y+1]
            RefreshDailyAwardCell(node, data)
        end),
        LuaUIBinding.HZTrusteeshipChildInit(function (node)

        end)
    )
end

local function StopCdLabel()
    if self.CDLabelExt ~= nil then
        self.CDLabelExt:stop()
        self.CDLabelExt = nil
    end
end

local function RefreshMapDetail(id, detail)
    local ret = GlobalHooks.DB.Find('GuildFort',id)
    if not detail or not ret then
        return
    end
    self.cvs_map_info.Visible = true

    self.lb_map_info.Text = ret.Name

    if detail.guildId and detail.guildId ~= "" then
        self.lb_info_guild.Text = detail.guildName
        self.lb_info_leader.Text = detail.guildLeaderName
        self.lb_info_mumber.Text = detail.guildNumberCount .. "/" .. detail.guildNumberTotalCount
        self.btn_leader_look.Visible = true
        self.btn_leader_look.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIVSPlayer, 0, detail.guildLeaderId)
        end
    else
        self.lb_info_guild.Text = Util.GetText(TextConfig.Type.GUILDWAR, "nozhanling")
        self.lb_info_leader.Text = Util.GetText(TextConfig.Type.GUILDWAR, "wu")
        self.lb_info_mumber.Text = Util.GetText(TextConfig.Type.GUILDWAR, "wu")
        self.btn_leader_look.Visible = false
    end

    CreatItemShowList(self.sp_award_list1, self.cvs_item, detail.winnerAwardList)
    CreatItemShowList(self.sp_award_list2, self.cvs_item, detail.dailyAwardList)

    self.btn_reward.Visible = false
    self.ib_over.Visible = false 
    
    
    
    
    
    
    
    

    if detail.areaStatus == 0 then
        self.btn_apply_list.Visible = false
        self.btn_tiaozhan.Visible = false
        self.btn_apply_add.Visible = false
        self.btn_apply.Visible = true
        self.btn_apply.IsGray = true
        self.btn_apply.Enable = false
    elseif detail.areaStatus == 1 then
        self.btn_apply_list.Visible = true
        self.btn_tiaozhan.Visible = false
        self.btn_apply_add.Visible = false
        self.btn_apply.Visible = true
        self.btn_apply.IsGray = false
        self.btn_apply.Enable = true
        self.btn_apply.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarApply, 0, "apply|"..id)
            DataMgr.Instance.FlagPushData:SetAttribute(FlagPushData.FLAG_GUILD_WAR_APPLY, 0, true)
            SetGuildWarFlag()
        end
        self.btn_apply_list.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarApply, 0, "applylist|"..id)
        end
    elseif detail.areaStatus == 5 then
        self.btn_apply_list.Visible = true
        self.btn_tiaozhan.Visible = false
        self.btn_apply.Visible = false
        self.btn_apply_add.Visible = true
        self.btn_apply_add.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarApply, 0, "applyAdd|"..id)
        end
        self.btn_apply_list.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarApply, 0, "applylist|"..id)
        end
    elseif detail.areaStatus == 2 then
        self.btn_apply_list.Visible = true
        self.btn_tiaozhan.Visible = true
        self.btn_apply.Visible = false
        self.btn_apply_add.Visible = false
        self.btn_tiaozhan.TouchClick = function ()
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.GUILDWAR, "notBegin"))
        end
        self.btn_apply_list.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarApply, 0, "applylist|"..id)
        end
    else
        self.btn_apply_list.Visible = true
        self.btn_tiaozhan.Visible = true
        self.btn_apply.Visible = false
        self.btn_apply_add.Visible = false
        self.btn_tiaozhan.TouchClick = function ()
            GuildWarAPI.ApplyAccessRequest(id, function(data)
            end)
        end
        self.btn_apply_list.TouchClick = function ()
            GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildWarApply, 0, "applylist|"..id)
        end
    end

    StopCdLabel()
    if (detail.areaStatus == 0 or detail.areaStatus == 1 or detail.areaStatus == 5 or detail.areaStatus == 2) and detail.countDown > 0 then
        local function format(cd,label)
            if cd <= 0 then
                StopCdLabel()
                self.lb_countDown.Visible = false
                GuildWarAPI.GetGuildAreaDetailRequest(id,function(data)
                    
                    EventManager.Fire("Event.GuildWar.RefreshMapList", {})
                end)
                return
            else
                self.lb_countDown.Visible = true
                if detail.areaStatus == 0 then
                    return ServerTime.GetCDStrCut(cd) .. Util.GetText(TextConfig.Type.GUILDWAR, "kaiqi")
                elseif detail.areaStatus == 2 then
                    return ServerTime.GetCDStrCut(cd) .. Util.GetText(TextConfig.Type.GUILDWAR, "kaiqiduizhan")
                else
                    return ServerTime.GetCDStrCut(cd) .. Util.GetText(TextConfig.Type.GUILDWAR, "jiezhi")
                end
            end
        end
        self.CDLabelExt = CDLabelExt.New(self.lb_countDown,detail.countDown + 3,format)
        self.CDLabelExt:start()
    else
        self.lb_countDown.Visible = false
    end

    SetGuildWarFlag()
end

local function RefreshMapList(areaList)
    for i,v in ipairs(areaList) do
        if v.areaId == tonumber(self.mapList[i][1].UserData) then
            local statusIcon = self.mapList[i][2]
            local statuslabel = self.mapList[i][3]

            if v.guildId and v.guildId ~= "" and DataMgr.Instance.UserData.Guild and DataMgr.Instance.UserData.Guild == v.guildId then
                statusIcon.Layout = XmdsUISystem.CreateLayoutFroXml("#static_n/func/common2.xml|common2|92", LayoutStyle.IMAGE_STYLE_BACK_4_CENTER, 8)
            else
                statusIcon.Layout = nil
            end

            if self.curStatus == 0 then
                if v.guildId and v.guildId ~= "" and v.guildName ~= "" then
                    statuslabel.Text = v.guildName
                else
                    statuslabel.Text = Util.GetText(TextConfig.Type.GUILDWAR, "zhanling")
                end
            elseif self.curStatus == 1 then
                if v.applied == 1 then
                    statuslabel.Text = Util.GetText(TextConfig.Type.GUILDWAR, "applied")
                else
                    statuslabel.Text = Util.GetText(TextConfig.Type.GUILDWAR, "zhanling")
                end
            else
                if v.guildName1 ~= "" or v.guildName2 ~= "" then
                    local string1 = Util.GetText(TextConfig.Type.GUILDWAR, "shouweijun")
                    if v.guildName1 ~= "" then
                        string1 = v.guildName1
                    end
                    local string2 = Util.GetText(TextConfig.Type.GUILDWAR, "shouweijun")
                    if v.guildName2 ~= "" then
                        string2 = v.guildName2
                    end
                    statuslabel.Text = string1 .. " VS " .. string2
                else
                    statuslabel.Text = Util.GetText(TextConfig.Type.GUILDWAR, "lunkong")
                end
            end
        end
    end

    if self.selectBtn then
        self.selectBtn.IsChecked = true
    end
end

local function SwitchPage(sender)
    StopCdLabel()

    self.cvs_map.Visible = false
    self.cvs_map_info.Visible = false
    self.cvs_dailyAward.Visible = false
    self.cvs_dailyAward_info.Visible = false
    self.cvs_report.Visible = false
    self.cvs_report_info.Visible = false
    self.cvs_guize.Visible = false

    self.curStatus = 0
    if sender == self.tbt_judian then
        GuildWarAPI.GetGuildAreaListRequest(function(data)
            self.curStatus = data.curStatus
            RefreshMapList(data.areaList or {})
            self.cvs_map.Visible = true
        end)
    elseif sender == self.tbt_zhanbao then
        GuildWarAPI.ApplyAllReportListRequest(function(data)
            RefreshReportList(data)
            self.cvs_report.Visible = true
        end)
    elseif sender == self.tbt_guize then
        self.cvs_guize.Visible = true
    elseif sender == self.tbt_dailyAward then
        GuildWarAPI.ApplyDailyAwardListRequest(function(data)
            RefreshDailyAwardList(data)
            self.cvs_dailyAward.Visible = true
            self.cvs_dailyAward_info.Visible = true
            SetGuildWarDailyAwardFlag()
        end)
    end
end

local function NeedRefreshMapList(eventname,params)
    SwitchPage(self.tbt_judian)
end

local function OnEnter()
    self.tbt_judian.IsChecked = true
    SetGuildWarDailyAwardFlag()
    EventManager.Subscribe("Event.GuildWar.RefreshMapList", NeedRefreshMapList)
end

local function OnExit()
    StopCdLabel()
    EventManager.Unsubscribe("Event.GuildWar.RefreshMapList", NeedRefreshMapList)
end

local ui_names = 
{
  
    {name = 'btn_close'},

    {name = 'cvs_lab'},
    {name = 'tbt_judian'},
    {name = 'tbt_zhanbao'},
    {name = 'tbt_guize'},
    {name = 'tbt_dailyAward'},
    {name = 'ib_dailyAward'},

    {name = 'cvs_map'},
    {name = 'cvs_map_info'},
    {name = 'lb_map_info'},
    {name = 'lb_info_guild'},
    {name = 'lb_info_leader'},
    {name = 'lb_info_mumber'},
    {name = 'btn_leader_look'},
    {name = 'cvs_item'},
    {name = 'sp_award_list1'},
    {name = 'sp_award_list2'},
    {name = 'btn_apply_list'},
    {name = 'btn_reward'},
    {name = 'ib_over'},
    {name = 'btn_tiaozhan'},
    {name = 'btn_apply'},
    {name = 'btn_apply_add'},
    {name = 'lb_countDown'},

    {name = 'cvs_report'},
    {name = 'cvs_report_info'},

    {name = 'cvs_dailyAward'},
    {name = 'sp_dailyAward'},
    {name = 'cvs_dailyAward1'},
    {name = 'lb_reward_tips'},
    {name = 'cvs_dailyAward_info'},

    {name = 'cvs_guize'},

    {name = 'ib_reward'},
    {name = 'ib_apply'},
    {name = 'ib_tiaozhan'},

    {name = 'cvs_report'},
    {name = 'sp_report_list'},
    {name = 'cvs_report_item'},
}

local function InitCompnent()
    Util.CreateHZUICompsTable(self.menu,ui_names,self)
    
    self.mapList = {}
    self.btnList = {}
    for i=1,5 do
        local mapBtn = self.menu:GetComponent("bt_map_"..i)
        local nameLabel = self.menu:GetComponent("lb_map_"..i)
        local guildLabel = self.menu:GetComponent("lb_guild_"..i)
        table.insert(self.mapList,{mapBtn, nameLabel, guildLabel})
        table.insert(self.btnList,mapBtn)
    end

    self.selectBtn = self.btnList[1]
    
    Util.InitMultiToggleButton(function(sender)
        local id = tonumber(sender.UserData)
        self.selectBtn = sender
        GuildWarAPI.GetGuildAreaDetailRequest(id,function(data)
            RefreshMapDetail(id, data)
        end)
    end, nil, self.btnList)

    self.btn_close.TouchClick = function ()
        self.menu:Close()
        GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIGuildHall,0)
    end

    self.cvs_map.Visible = false
    self.cvs_map_info.Visible = false
    self.cvs_report.Visible = false
    self.cvs_report_info.Visible = false
    self.cvs_report_item.Visible = false
    self.cvs_item.Visible = false
    self.cvs_dailyAward1.Visible = false
    self.cvs_dailyAward_info.Visible = false

    Util.InitMultiToggleButton(function(sender)
        SwitchPage(sender)
    end, nil, {self.tbt_judian,self.tbt_zhanbao,self.tbt_dailyAward,self.tbt_guize})
end

local function Init(params)
    self.menu = LuaMenuU.Create("xmds_ui/guild/guild_judian.gui.xml", GlobalHooks.UITAG.GameUIGuildWarMain)
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
