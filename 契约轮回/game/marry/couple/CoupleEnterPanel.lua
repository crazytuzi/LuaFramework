-- @Author: lwj
-- @Date:   2019-08-22 20:03:09  
-- @Last Modified time: 2019-08-22 20:03:17

CoupleEnterPanel = CoupleEnterPanel or class("CoupleEnterPanel", BaseItem)
local CoupleEnterPanel = CoupleEnterPanel

function CoupleEnterPanel:ctor(parent_node, layer, cd)
    self.abName = "marry"
    self.assetName = "CoupleEnterPanel"
    self.layer = layer
    self.dungeon_id = 30103

    self.model = CoupleModel.GetInstance()
    self.model.remind_cd = cd
    BaseItem.Load(self)
end

function CoupleEnterPanel:dctor()
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
    if table.isempty(self.rewa_item_list) then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end

    if self.model.remind_cd and self.model.remind_cd > 0 then
        GlobalEvent:Brocast(CoupleEvent.ContinueCD)
    end
    self:StopMySchedule()
end

function CoupleEnterPanel:LoadCallBack()
    self.nodes = {
        "btn_enter", "request_link", "des", "can_buy", "btn_buy", "cost", "cost_icon", "remain", "rewa_con", "btn_quick",
    }
    self:GetChildren(self.nodes)
    self.remain = GetText(self.remain)
    self.can_buy = GetText(self.can_buy)
    self.des = GetText(self.des)
    self.cost = GetText(self.cost)
    self.cost_icon = GetImage(self.cost_icon)
    self.request_link = GetImage(self.request_link)

    self:AddEvent()
    self:InitPanel()
end

function CoupleEnterPanel:AddEvent()
    ---进入
    local function callback()
        if self:CheckIsCanEnter() then
            TeamController.GetInstance():DungeEnterAsk(self.dungeon_id, 1)
        end
    end
    AddButtonEvent(self.btn_enter.gameObject, callback)

    --购买次数
    local function callback()
        local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
        if role_data.marry == 0 then
            Notify.ShowText(ConfigLanguage.CoupleDungeon.PleaseBuyAfterMarry)
            return
        end
        if not self.dunge_cf then
            logError("CoupleEnterPanel:没有该副本配置")
            return
        end
        local cost_tbl = String2Table(self.dunge_cf.enter_buy)
        if RoleInfoModel.GetInstance():CheckGold(cost_tbl[2], cost_tbl[1]) then
            DungeonCtrl.GetInstance():RequestBuyTimes(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE)
        end
    end
    AddButtonEvent(self.btn_buy.gameObject, callback)

    ---发送提醒
    local function callback()
        local role_data = RoleInfoModel.GetInstance():GetMainRoleData()
        if role_data.marry == 0 then
            Notify.ShowText(ConfigLanguage.CoupleDungeon.PleaseBuyAfterMarry)
            return
        end
        if self.model.is_remind_cd then
            Notify.ShowText(ConfigLanguage.CoupleDungeon.PleaseHaveARest)
            return
        end
        DungeonCtrl.GetInstance():ReqeustBuyTimes(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE)
        Notify.ShowText(ConfigLanguage.CoupleDungeon.RemindSended)
        self.model.is_remind_cd = true
        self:StopMySchedule()
        self.model.remind_cd = 5
        self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
    end
    AddClickEvent(self.request_link.gameObject, callback)

    self.global_event = {}
    --次数更新
    local function callback(stype, tbl)
        if stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE then
            self.dunge_info.info = tbl
            self:UpdateTimes()
        end
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(DungeonEvent.UpdateDungeonTime, callback)

    local function callback()
        self.dunge_info = DungeonModel.GetInstance():GetDungeonInfoByStype(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE)
        self:UpdateTimes()
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(MarryEvent.UpdateCoupleTimes, callback)

    AddButtonEvent(self.btn_quick.gameObject, handler(self, self.HandleQuickTeam))
end

function CoupleEnterPanel:InitPanel()
    --数据初始化
    self.dunge_info = DungeonModel.GetInstance():GetDungeonInfoByStype(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_COUPLE)
    self.dunge_cf = Config.db_dunge[self.dungeon_id]
    if not self.dunge_cf then
        logError("CoupleEnterPanel,没有副本配置")
        return
    end
    if not self.dunge_info then
        logError("CoupleEnterPanel,没有副本信息")
        return
    end
    self.des.text = ConfigLanguage.CoupleDungeon.DungeonDesc
    self:LoadRewa()

    self:UpdateTimes()

    local cost_tbl = String2Table(self.dunge_cf.enter_buy)
    GoodIconUtil.GetInstance():CreateIcon(self, self.cost_icon, tostring(cost_tbl[1]), true)
    self.cost.text = cost_tbl[2]
end

function CoupleEnterPanel:CheckIsCanEnter()
    --队伍
    local team_info = TeamModel.GetInstance():GetTeamInfo()
    --dump(team_info, "<color=#6ce19b>CoupleEnterPanel   CoupleEnterPanel  CoupleEnterPanel  CoupleEnterPanel</color>")
    if not team_info then
        Notify.ShowText(ConfigLanguage.CoupleDungeon.DoNotHaveTeam)
        return false
    end
    --副本信息
    if not self.dunge_info then
        logError("CoupleEnterPanel,没有副本信息")
        return false
    end
    --在线
    local my_role_id = RoleInfoModel.GetInstance():GetMainRoleId()
    local is_online = true
    local member_list = team_info.members
    local outline_name = ""
    for i = 1, #member_list do
        local info = member_list[i]
        if info.role_id ~= my_role_id and info.is_online == 0 then
            outline_name = info.role.name
            is_online = false
            break
        end
    end
    if not is_online then
        Notify.ShowText(string.format(ConfigLanguage.CoupleDungeon.MemberOutline, outline_name))
        return false
    end
    return true
end

function CoupleEnterPanel:LoadRewa()
    local list = String2Table(self.dunge_cf.reward_show)
    self.rewa_item_list = self.rewa_item_list or {}
    local len = #list
    for i = 1, len do
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.rewa_con)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local param = {}
        local operate_param = {}
        param["item_id"] = list[i][1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 76, y = 76 }
        param["num"] = list[i][2]
        param.bind = list[i][3]
        --local color = Config.db_item[id].color - 1
        --param["color_effect"] = color
        --param["effect_type"] = 2  --活动特效：2
        item:SetIcon(param)
    end
    for i = len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function CoupleEnterPanel:UpdateTimes()
    local color = "24971e"
    local count = self.dunge_info.info.rest_times
    if count <= 0 then
        color = "FF0000"
    end
    self.remain.text = string.format(ConfigLanguage.CoupleDungeon.RemainEnterCount, color, count)
    local max_can_buy = String2Table(Config.db_dunge_couple.buy_times.val)[1]
    local can_buy_num = max_can_buy - self.dunge_info.info.buy_times
    local can_buy_color = "24971e"
    if can_buy_num <= 0 then
        can_buy_color = "FF0000"
    end
    self.can_buy.text = string.format(ConfigLanguage.CoupleDungeon.RemainBuyCount, can_buy_color, can_buy_num)
end

function CoupleEnterPanel:StopMySchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
        self.schedule = nil
    end
end

function CoupleEnterPanel:BeginningCD()
    if self.model.remind_cd > 0 then
        self.model.remind_cd = self.model.remind_cd - 1
    else
        self:StopMySchedule()
        self.model.is_remind_cd = false
    end
end

function CoupleEnterPanel:CheckRemindCD()
    if self.model.is_remind_cd then
        self:StopMySchedule()
        self.schedule = GlobalSchedule.StartFun(handler(self, self.BeginningCD), 1, -1)
    end
end

function CoupleEnterPanel:HandleQuickTeam()
    local dunge_id = 30103
    local subtab = TeamModel:GetInstance():GetSubIDByDungeID(dunge_id)
    if TeamModel:GetInstance():GetTeamInfo() then
        lua_panelMgr:GetPanelOrCreate(MyTeamPanel):Open(subtab.id)
        return ;
    end
    lua_panelMgr:GetPanelOrCreate(TeamListPanel):Open(subtab.id)
end