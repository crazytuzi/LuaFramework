-- @Author: lwj
-- @Date:   2019-09-07 17:48:20
-- @Last Modified time: 2019-09-10 23:06:18

GodScoreDungeView = GodScoreDungeView or class("GodScoreDungeView", BaseItem)
local GodScoreDungeView = GodScoreDungeView

function GodScoreDungeView:ctor(parent_node, parent_panel, actID)
    self.abName = "sevenDayActive"
    self.assetName = "GodScoreDungeView"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.actID = actID
    --配置
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    --数据
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    self.model = GodCelebrationModel.GetInstance()
    self.is_need_update_times = false
    BaseItem.Load(self)
end

function GodScoreDungeView:dctor()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    for i, v in pairs(self.rewa_item_list) do
        if v then
            v:destroy()
        end
    end
    self.rewa_item_list = {}
    if self.countdowntext then
        self.countdowntext:destroy()
        self.countdowntext = nil
    end
end

function GodScoreDungeView:LoadCallBack()
    self.nodes = {
        "time_con", "time_con/countdowntext", "btn_go/pay_times", "btn_go/free_times", "btn_go", "btn_go/pay_times/price_icon", "remian_times", "btn_go/pay_times/price",
        "btn_go/btn_title", "btn_gray", "rewa_con", "ques_icon", "btn_go/red_con",
    }
    self:GetChildren(self.nodes)
    self.cd_text = GetText(self.countdowntext)
    self.free_times = GetText(self.free_times)
    self.price_icon = GetImage(self.price_icon)
    self.price = GetText(self.price)
    self.btn_title = GetText(self.btn_title)
    self.remian_times = GetText(self.remian_times)

    self:AddEvent()
    self:InitPanel()
end

function GodScoreDungeView:AddEvent()
    local function callback()
        ShowHelpTip(HelpConfig.GodCelebration.DungeDesc, true)
    end
    AddButtonEvent(self.ques_icon.gameObject, callback)

    local function callback()
        if self.is_paying then
            if self.model.is_check then
                self:EnterDunge()
            else
                local function ok_fun(is_check)
                    self.model.is_check = is_check
                    --do
                    self:EnterDunge()
                end
                local str = string.format(ConfigLanguage.GodCele.IsPayForEnterDunge, self.pay_tbl[2])
                Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, str, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
            end
        else
            self:EnterDunge()
        end
    end
    AddButtonEvent(self.btn_go.gameObject, callback)

    local function callback()
        Notify.ShowText(ConfigLanguage.GodCele.TimesNotEnough)
    end
    AddButtonEvent(self.btn_gray.gameObject, callback)
end

function GodScoreDungeView:InitPanel()
    self:StartCD()
    self:LoadRewa()
    self:UpdateTimes()
end

function GodScoreDungeView:StartCD()
    local end_time = OperateModel.GetInstance():GetActEndTimeByActId(self.actID)
    local param = {}
    param.isShowMin = true
    param.isShowHour = true
    param.isShowDay = true
    param.isChineseType = true
    param.formatText = "Event time left: %s"
    self.countdowntext = CountDownText(self.time_con, param)
    local function call_back()
        self.cd_text.text = ConfigLanguage.GodCele.AlreadyEnd
        self.countdowntext = nil
    end
    self.countdowntext:StartSechudle(end_time, call_back)
end

function GodScoreDungeView:UpdateTimes()
    local dunge_panel_data = self.model:GetDungePanelInfo()
    --按钮文本更新
    self.dunge_id = dunge_panel_data.id
    local dunge_cf = Config.db_dunge[self.dunge_id]
    local scene_id = dunge_cf.scene
    local scene_cf = Config.db_scene[scene_id]
    local cost_tbl = String2Table(scene_cf.cost)
    --免费次数的总数
    local free_time = cost_tbl[1][2]
    --当前剩余次数
    local rest_time = dunge_panel_data.info.max_times - dunge_panel_data.info.cur_times
    --付费次数的总数
    local pay_time = dunge_panel_data.info.max_times - free_time
    --剩余次数小于等于付费次数，需要开始付费
    self.pay_tbl = cost_tbl[2][3][1]
    --剩余次数文本
    local color_str = "0db420"
    local is_show_rd = false
    if rest_time <= 0 then
        --进入次数耗尽
        self:ShowGray()
        if rest_time <= 0 then
            rest_time = 0
            color_str = 'FF0000'
        end
    else
        if rest_time - pay_time <= 0 then
            self:ShowPayBtn()
            GoodIconUtil.GetInstance():CreateIcon(self, self.price_icon, self.pay_tbl[1], true)
            self.price.text = self.pay_tbl[2]
        else
            --免费
            self:ShowFreeBtn()
            local free_remain_times = rest_time - pay_time
            local str = string.format("（%d/%d）", free_remain_times, free_time)
            self.free_times.text = str
            is_show_rd = true
        end
        self.model.is_paying = rest_time - pay_time <= 0
    end
    self.remian_times.text = string.format(ConfigLanguage.GodCele.RemainDungeCount, color_str, rest_time, dunge_panel_data.info.max_times)
    self:SetRedDot(is_show_rd)
end

function GodScoreDungeView:ShowFreeBtn()
    SetVisible(self.free_times, true)
    SetVisible(self.pay_times, false)
    SetVisible(self.btn_gray, false)
    self.btn_title.text = ConfigLanguage.GodCele.FreeChallenge
end

function GodScoreDungeView:ShowPayBtn()
    SetVisible(self.free_times, false)
    SetVisible(self.pay_times, true)
    SetVisible(self.btn_gray, false)
    self.btn_title.text = ConfigLanguage.GodCele.PayChallenge
end

function GodScoreDungeView:ShowGray()
    SetVisible(self.free_times, false)
    SetVisible(self.pay_times, false)
    SetVisible(self.btn_gray, true)
end

function GodScoreDungeView:LoadRewa()
    self.yy_cf = OperateModel:GetInstance():GetConfig(self.actID)
    local list = String2Table(self.yy_cf.reward)
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
        local rewa_data = list[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = rewa_data[1]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 78, y = 78 }
        param["num"] = rewa_data[2]
        param.bind = rewa_data[3]
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

function GodScoreDungeView:EnterDunge()
    local dunge_panel_data = self.model:GetDungePanelInfo()
    --没有剩余次数
    local rest_time = dunge_panel_data.info.max_times - dunge_panel_data.info.cur_times
    if rest_time <= 0 then
        return
    end
    --如果需要付费，没有钱
    if self.model.is_paying and (not RoleInfoModel.GetInstance():CheckGold(self.pay_tbl[2], self.pay_tbl[1])) then
        return
    end
    DungeonCtrl.GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_TOWER, self.model.cur_floor, self.dunge_id)
    GlobalEvent:Brocast(GodCeleEvent.CloseGodCelePanel)
end

function GodScoreDungeView:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end