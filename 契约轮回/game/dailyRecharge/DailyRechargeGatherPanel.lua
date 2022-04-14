-- @Author: lwj
-- @Date:   2019-03-29 19:04:05
-- @Last Modified time: 2019-03-29 19:04:47

DailyRechargeGatherPanel = DailyRechargeGatherPanel or class("DailyRechargeGatherPanel", BasePanel)
local DailyRechargeGatherPanel = DailyRechargeGatherPanel

function DailyRechargeGatherPanel:ctor()
    self.abName = "dailyRecharge"
    self.assetName = "DailyRechargeGatherPanel"
    self.layer = "UI"

    self.model = DailyRechargeModel.GetInstance()
    self.use_background = true
    self.click_bg_close = true

    self.grade_item_list = {}
    self.achi_item_list = {}

    self.panel_type = 2
    self.is_hide_other_panel = true
end

function DailyRechargeGatherPanel:dctor()
    if self.eft then
        self.eft:destroy()
        self.eft = nil
    end
end

function DailyRechargeGatherPanel:Open()
    DailyRechargeGatherPanel.super.Open(self)
end

function DailyRechargeGatherPanel:LoadCallBack()
    self.nodes = {
        "LeftContent/grade_content", "LeftContent/grade_content/DailyRechaGradeItem",
        "RightContent/acheive_content/DailyRechaAchiItem",
        "LeftContent/target_text_content/tartget_num",
        "RightContent/btn_close",
        "LeftContent/reward_content",
        "LeftContent/btn_Get/btn_get_text",
        "LeftContent/btn_Get",
        "RightContent/acheive_content",
        "LeftContent/show_name", "LeftContent/show_content",
        "LeftContent/red_con", "LeftContent/eft_con",
    }
    self:GetChildren(self.nodes)
    self.grade_item_obj = self.DailyRechaGradeItem.gameObject
    self.achi_item_obj = self.DailyRechaAchiItem.gameObject
    self.title_text = GetText(self.tartget_num)
    self.btn_text = GetText(self.btn_get_text)
    self.btn_img = GetImage(self.btn_Get)
    self.show_content = GetImage(self.show_content)
    self.show_name = GetText(self.show_name)

    self:AddEvent()
    self:GetAllConfig()
    self:InitPanel()
end

function DailyRechargeGatherPanel:GetAllConfig()
    --self.model.daily_cfg = OperateModel.GetInstance():GetConfig(act_id)
    self.model:GetDailyRewardCfg()
    --dump(self.model.daily_reward_cfg, "<color=#6ce19b>GetDailyRewardCfg   GetDailyRewardCfg  GetDailyRewardCfg  GetDailyRewardCfg</color>")

    --self.model.achi_cfg = OperateModel.GetInstance():GetConfig(301)
    self.model:GetAchiRewardCfg()
    --dump(self.model.achi_reward_cfg, "<color=#6ce19b>GetAchiRewardCfg   GetAchiRewardCfg  GetAchiRewardCfg  GetAchiRewardCfg</color>")
    self.model:GetCanGetRewardIndex()
    self.model:GetShowList()
end

function DailyRechargeGatherPanel:AddEvent()
    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))
    local function callback()
        if self.model.cur_btn_model == 0 then
            --未达标
            GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
            self:Close()
        elseif self.model.cur_btn_model == 1 then
            --可领
            GlobalEvent:Brocast(OperateEvent.REQUEST_GET_REWARD, self.model.cur_sel_data.act_id, self.model.cur_sel_data.id, self.model.cur_sel_data.level)
        elseif self.model.cur_btn_model == 2 then
            Notify.ShowText(ConfigLanguage.DailyRecharge.RewardedNotify)
        end
    end
    AddButtonEvent(self.btn_Get.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(DailyRechargeEvent.DailyRechargeGradeItemClick, handler(self, self.HandleGradeClick))
    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandleSuccessRewarded))
end

function DailyRechargeGatherPanel:InitPanel()
    self:LoadGradeItem()
    self:PlayAni()
    self:LoadEft()
end

function DailyRechargeGatherPanel:LoadEft()
    if self.eft ~= nil then
        self.eft:destroy()
        self.eft = nil
    end
    self.eft = UIEffect(self.eft_con, 10311, false, self.layer)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.show_content.transform, nil, true, nil, 1, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.reward_content.transform, nil, true, nil, 1, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.show_name.transform, nil, true, nil, 1, 4)
end

function DailyRechargeGatherPanel:OpenCallBack()
end

function DailyRechargeGatherPanel:PlayAni()
    local action = cc.MoveTo(1.5, 0, 70, 0)
    action = cc.Sequence(action, cc.MoveTo(1.5, 0, 30, 0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.show_content.transform)
end

function DailyRechargeGatherPanel:LoadGradeItem()
    local g_list = self.model.grade_list
    --dump(self.model.grade_list, "<color=#6ce19b>LoadGradeItem   LoadGradeItem  LoadGradeItem  LoadGradeItem</color>")
    for i = 1, #g_list do
        local item = self.grade_item_list[i]
        if not item then
            item = DailyRechaGradeItem(self.grade_item_obj, self.grade_content)
            self.grade_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local data = {}
        for ii, vv in pairs(g_list[i]) do
            data[ii] = vv
        end
        data.pos_index = i
        item:SetData(data)
    end
    for i = #g_list + 1, #self.grade_item_list do
        self.grade_item_list[i]:SetVisible(false)
    end

    local a_list = self.model.achi_list
    local len = #a_list
    for i = 1, len do
        local item = self.achi_item_list[i]
        if not item then
            item = DailyRechaAchiItem(self.achi_item_obj, self.acheive_content)
            self.achi_item_list[i] = item
        else
            item:SetVisible(true)
        end
        local data = {}
        for ii, vv in pairs(a_list[i]) do
            data[ii] = vv
        end
        data.pos_index = i
        item:SetData(data)
    end

    for i = len + 1, #self.achi_item_list do
        self.achi_item_list[i]:SetVisible(false)
    end
end

function DailyRechargeGatherPanel:HandleGradeClick(data, info_data)
    self:UpdateTitleShow(data.desc)
    local reward_tbl = String2Table(data.reward)
    self:UpdateRewardsShow(reward_tbl)
    self:UpdateBtnShow(info_data)
    self:UpdateBtnRD(data.id)
    self:UpdateShowImg(reward_tbl, data.pos_index)
end

function DailyRechargeGatherPanel:UpdateBtnRD(id)
    if self.model:CheckGradeRDById(id) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
end
function DailyRechargeGatherPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function DailyRechargeGatherPanel:UpdateTitleShow(target)
    self.title_text.text = target
end

function DailyRechargeGatherPanel:UpdateRewardsShow(rewa_tbl)
    rewa_tbl = self:CheckGiftList(rewa_tbl)
    self.rewa_item_list = self.rewa_item_list or {}
    local isTbl = false
    local final_len = 1
    if type(rewa_tbl[1]) == "table" then
        final_len = #rewa_tbl
        isTbl = true
    else
        isTbl = false
    end
    for i = 1, final_len do
        local item_id = nil
        local num = nil
        if isTbl then
            item_id = rewa_tbl[i][1]
            num = rewa_tbl[i][2]
        else
            item_id = rewa_tbl[1]
            num = rewa_tbl[2]
        end
        local param = {}
        local operate_param = {}
        local color = Config.db_item[item_id].color - 1
        param["cfg"] = Config.db_item[item_id]
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 60, y = 60 }
        param["num"] = GetShowNumber(num)
        param["is_dont_set_pos"] = true
        param["color_effect"] = color
        --param["effect_type"] = 2
        local item = self.rewa_item_list[i]
        if not item then
            item = GoodsIconSettorTwo(self.reward_content)
            self.rewa_item_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetIcon(param)
    end
    for i = final_len + 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        item:SetVisible(false)
    end
end

function DailyRechargeGatherPanel:UpdateBtnShow(info_data)
    if not info_data then
        return
    end
    local text = ""
    if info_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
        self.model.cur_btn_model = 0
        text = ConfigLanguage.DailyRecharge.GoToRecharge
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
    elseif info_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_FINISH then
        --未领取
        self.model.cur_btn_model = 1
        text = ConfigLanguage.DailyRecharge.CanGetReward
        ShaderManager:GetInstance():SetImageNormal(self.btn_img)
    elseif info_data.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
        --已经领取
        self.model.cur_btn_model = 2
        text = ConfigLanguage.DailyRecharge.AlreadyRewarded
        ShaderManager:GetInstance():SetImageGray(self.btn_img)
    end
    self.btn_text.text = text
end

function DailyRechargeGatherPanel:UpdateShowImg(rewa_tbl)
    if rewa_tbl[1] then
        SetVisible(self.show_name, true)
        self.show_name.text = Config.db_item[rewa_tbl[1][1]].name
        lua_resMgr:SetImageTexture(self, self.show_content, "iconasset/icon_dailyRecharge", rewa_tbl[1][1], false, nil, false)
    else
        SetVisible(self.show_name, false)
    end
end

function DailyRechargeGatherPanel:HandleSuccessRewarded(data)
    if not self.model.cur_sel_data then
        return
    end
    --if data.act_id ~= self.model.cur_sel_data.act_id or data.id ~= self.model.cur_sel_data.id then
    if data.act_id ~= self.model.cur_sel_data.act_id then
        return
    end

    local info_data = {}
    info_data.id = data.id
    info_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
    info_data.act_id = data.act_id
    self.model:UpdateRewarded(info_data)
    Notify.ShowText(ConfigLanguage.DailyRecharge.SuccessReward)
    if self.model.cur_sel_data.id == data.id then
        self:HandleGradeClick(self.model.cur_sel_data, info_data)
    end
    self:UpdateGradeItemData(data)
    self.model:RemoveGradeRdById(data.id)
    self.model:Brocast(DailyRechargeEvent.UpdateGradeItemRD)
    self:UpdateBtnRD(self.model.cur_sel_data.id)
    self.model:Brocast(DailyRechargeEvent.CheckRD)
end

function DailyRechargeGatherPanel:UpdateGradeItemData(data)
    for i = 1, #self.grade_item_list do
        if data.id == self.grade_item_list[i].info_data.id then
            self.grade_item_list[i].info_data.state = enum.YY_TASK_STATE.YY_TASK_STATE_REWARD
            break
        end
    end
end

function DailyRechargeGatherPanel:CheckGiftList(list)
    local final_list = {}
    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    for i = 1, #list do
        local cf = list[i]
        local item_id = cf[1]
        local item_cf = Config.db_item[item_id]
        if item_cf then
            if item_cf.type == 10 and item_cf.stype == 10083 then
                local gift_cf = Config.db_item_gift[item_id]
                if gift_cf then
                    local con = String2Table(gift_cf.reward)
                    for i = 1, #con do
                        local item_tbl = con[i][3][1]
                        if lv >= con[i][1] and lv <= con[i][2] then
                            final_list[#final_list + 1] = item_tbl
                        end
                    end
                end
            else
                final_list[#final_list + 1] = cf
            end
        end
    end
    return final_list
end

function DailyRechargeGatherPanel:CloseCallBack()
    self.model:ChangeRDShow()
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    self.model.default_sel_index = nil
    for i, v in pairs(self.grade_item_list) do
        if v then
            v:destroy()
        end
    end
    self.grade_item_list = {}
    for i, v in pairs(self.achi_item_list) do
        if v then
            v:destroy()
        end
    end
    self.achi_item_list = {}
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
    for i, v in pairs(self.global_event) do
        GlobalEvent:RemoveListener(v)
    end
    self.global_event = {}
    if self.rewa_item_list then
        for i, v in pairs(self.rewa_item_list) do
            if v then
                v:destroy()
            end
        end
        self.rewa_item_list = {}
    end
end

