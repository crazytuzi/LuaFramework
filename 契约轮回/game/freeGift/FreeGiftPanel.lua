-- @Author: lwj
-- @Date:   2019-04-23 17:02:25
-- @Last Modified time: 2019-04-23 17:02:25

FreeGiftPanel = FreeGiftPanel or class("FreeGiftPanel", BasePanel)
local FreeGiftPanel = FreeGiftPanel

function FreeGiftPanel:ctor()
    self.abName = "freeGift"
    self.assetName = "FreeGiftPanel"
    self.layer = "UI"

    self.model = FreeGiftModel.GetInstance()
    self.use_background = true
    self.side_item_list = {}
    self.left_model = nil
    self.right_model = nil
    self.rewa_item_list = {}
    self.panel_type = 2
end

function FreeGiftPanel:dctor()

end

function FreeGiftPanel:Open()
    FreeGiftPanel.super.Open(self)
end

function FreeGiftPanel:LoadCallBack()
    self.nodes = {
        "side_con", "side_con/FreeGiftSideItem",
        "btn_close",
        "text_img_con/left_img", "text_img_con/middle_img", "text_img_con/right/right_img", "text_img_con/right/money_icon",
        "left_pic", "left_con", "rewa_con", "right_pic", "right_con",
        "btn_get", "cd_con", "btn_get/btn_text",
        "lv_limi_img", "red_con",
        "btn_get/cost_icon", "left_eft_con", "Sundries_2/Right_Title",
        "left_not_cam_con", "left_con/Camera",
    }
    self:GetChildren(self.nodes)
    self.side_item_obj = self.FreeGiftSideItem.gameObject
    self.left_img = GetImage(self.left_img)
    self.middle_img = GetImage(self.middle_img)
    self.right_img = GetImage(self.right_img)
    self.left_pic = GetImage(self.left_pic)
    self.right_pic = GetImage(self.right_pic)
    self.mon_icon = GetImage(self.money_icon)
    self.btn_t = GetText(self.btn_text)
    self.btn_img = GetImage(self.btn_get)
    self.btn_outline = self.btn_text:GetComponent("Outline")
    self.money_icon = GetImage(self.money_icon)
    self.cost_icon = GetImage(self.cost_icon)
    self.left_con_rect = GetRectTransform(self.left_con)

    self.texture = CreateRenderTexture()
    self.texture_cpn = self.left_con:GetComponent("RawImage")
    self.texture_cpn.texture = self.texture
    self.cam = self.Camera:GetComponent("Camera")
    self.cam.targetTexture = self.texture

    local params = {
        formatText = "Confirm (%s sec)",
        formatTime = "%d",
        isChineseType = true,
    }
    self.countdowntext = CountDownText(self.cd_con, params)

    self:AddEvent()
    self:InitPanel()
end

function FreeGiftPanel:AddEvent()
    local function callback()
        local is_can_fetch = false
        if self.model.btn_mode == 2 or self.model.is_free then
            is_can_fetch = true
        else
            local cost = self.model.cur_cost
            local typeName = ShopModel:GetInstance():GetTypeNameById(cost[1][1])
            is_can_fetch = RoleInfoModel.GetInstance():CheckGold(cost[1][2], typeName)
        end
        if is_can_fetch then
            GlobalEvent:Brocast(OperateEvent.REQUEST_FREE_GIFT_REWARD_FETCH, self.model.cur_sel_act_id, self.model.btn_mode)
        end
    end
    AddClickEvent(self.btn_get.gameObject, callback)

    AddButtonEvent(self.btn_close.gameObject, handler(self, self.Close))

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(FreeGiftEvent.SideItemClick, handler(self, self.HandleSideClick))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FreeGiftEvent.UpdateSuccess, handler(self, self.UpdateBtnState))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FreeGiftEvent.CloseFreeGiftPanel, handler(self, self.Close))
end

function FreeGiftPanel:OpenCallBack()

end

function FreeGiftPanel:InitPanel()
    self:LoadEft()
    self:PlayAni()
    self:LoadSideItems()
end

function FreeGiftPanel:LoadEft()
    if self.l_magic_eft ~= nil then
        self.l_magic_eft:destroy()
        self.l_magic_eft = nil
    end
    self.l_magic_eft = UIEffect(self.left_eft_con, 10311, false, self.layer)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_pic.transform, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_img.transform, nil, true, nil, false, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_con.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_not_cam_con.transform, nil, true, nil, false, 5)

    LayerManager.GetInstance():AddOrderIndexByCls(self, self.right_pic.transform, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.right_img.transform, nil, true, nil, false, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.money_icon.transform, nil, true, nil, false, 4)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.Right_Title.transform, nil, true, nil, false, 5)
end

function FreeGiftPanel:PlayAni()
    local action = cc.MoveTo(1.5, -243, 30, 0)
    action = cc.Sequence(action, cc.MoveTo(1.5, -243, -20, 0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.left_pic.transform)
end

function FreeGiftPanel:LoadSideItems()
    self:DestroySideItems()
    local list = self.model:GetSideItemList()
    for i = 1, #list do
        local item = FreeGiftSideItem(self.side_item_obj, self.side_con)
        item:SetData(list[i])
        self.side_item_list[#self.side_item_list + 1] = item
    end
end
function FreeGiftPanel:DestroySideItems()
    for i = 1, #self.side_item_list do
        local item = self.side_item_list[i]
        if item then
            item:destroy()
        end
    end
    self.side_item_list = {}
end

function FreeGiftPanel:OpenCallBack()

end

function FreeGiftPanel:HandleSideClick(act_id)
    local gift_con = Config.db_yunying_gift[act_id]
    local key = "1@" .. act_id
    local rewa_con = Config.db_yunying_reward[key]
    local re_key = "2@" .. act_id
    local rebate_con = Config.db_yunying_reward[re_key]
    self.model.cur_sel_act_id = act_id
    self.model.cur_rewa_con = rewa_con
    self.model.cur_rebate_con = rebate_con
    lua_resMgr:SetImageTexture(self, self.left_img, "freeGift_image", "left_" .. act_id, false, nil, false)
    lua_resMgr:SetImageTexture(self, self.middle_img, "freeGift_image", "middle_" .. act_id, false, nil, false)
    lua_resMgr:SetImageTexture(self, self.right_img, "freeGift_image", "right_" .. act_id, false, nil, false)
    local id = String2Table(rebate_con.reward)[1][1]
    GoodIconUtil.GetInstance():CreateIcon(self, self.mon_icon, tostring(id), true)
    self:LoadResShow(true, gift_con)
    self:LoadResShow(false, gift_con)
    self:LoadGiftShow(String2Table(rewa_con.reward))
    self:UpdateBtnState(rewa_con, rebate_con)
end

function FreeGiftPanel:LoadResShow(is_left, cf)
    self:DestroyEft()
    local res_tbl
    if is_left then
        res_tbl = String2Table(cf.left)
    else
        res_tbl = String2Table(cf.right)
    end
    local con = nil
    local img = nil
    local ab_name = ""
    local res_id
    if is_left then
        self:DestroyLeftModel()
        con = self.left_con
        img = self.left_pic
        ab_name = string.split(res_tbl[2], ':')[1]
        res_id = string.split(res_tbl[2], ':')[2]
    else
        self:DestroyRightModel()
        con = self.right_con
        img = self.right_pic
        ab_name = "iconasset/icon_recharge"
        res_id = res_tbl[2]
    end
    if res_tbl[1] == "model" then
        if is_left then
            local pos_y
            SetVisible(self.left_pic, false)
            SetVisible(self.left_model, true)
            local config = {}
            if res_tbl[2] == enum.MODEL_TYPE.MODEL_TYPE_ROLE then
                self.scale_y = 165
                pos_y = 48.6
                con = self.left_not_cam_con
                SetVisible(self.left_con, false)
                SetVisible(self.left_not_cam_con, true)
                config.trans_x = 450
                config.trans_y = 450
            else
                self.scale_y = 400
                pos_y = -14.5
                SetVisible(self.left_con, true)
                SetVisible(self.left_not_cam_con, false)
            end
            self.left_model = UIModelManager:GetInstance():InitModel(res_tbl[2], res_tbl[3], con, handler(self, self.LoadLeftModelCB), nil, 2, model_data, nil, config)
            SetAnchoredPosition(self.left_con_rect, self.left_con_rect.anchoredPosition.x, pos_y)
        else
            SetVisible(self.right_pic, false)
            SetVisible(self.right_model, true)
            self.right_model = UIModelManager:GetInstance():InitModel(res_tbl[2], res_tbl[3], con, handler(self, self.LoadRightModelCB), nil, model_data)
        end
    elseif res_tbl[1] == "texture" then
        if is_left then
            SetVisible(self.left_model, false)
            SetVisible(self.left_pic, true)
        else
            SetVisible(self.right_model, false)
            SetVisible(self.right_pic, true)
            if self.eft ~= nil then
                self.eft:destroy()
                self.eft = nil
            end
            self.eft = UIEffect(self.right_pic.transform, 10601, false, self.layer)
        end
        lua_resMgr:SetImageTexture(self, img, ab_name, res_id, false, nil, false)
    end
end
function FreeGiftPanel:DestroyLeftModel()
    if self.left_model then
        self.left_model:destroy()
        self.left_model = nil
    end
end
function FreeGiftPanel:DestroyRightModel()
    if self.right_model then
        self.right_model:destroy()
        self.right_model = nil
    end
end
function FreeGiftPanel:LoadLeftModelCB()
    SetLocalPosition(self.left_model.transform, 8010, -110, 400)
    SetLocalRotation(self.left_model.transform, 10, 180, 0)
    SetLocalScale(self.left_model.transform, self.scale_y, self.scale_y, self.scale_y)
end
function FreeGiftPanel:LoadRightModelCB()
    SetLocalPosition(self.right_model.transform, 0, 0, 0)
    SetLocalRotation(self.right_model.transform, 0, 180, 0)
    SetLocalScale(self.right_model.transform, 500, 500, 500)
end
function FreeGiftPanel:DestroyEft()
    if self.eft then
        self.eft:destroy()
        self.eft = nil
    end
end

function FreeGiftPanel:LoadGiftShow(tbl)
    self:DestroyMiddleRewa()
    local gender = RoleInfoModel.GetInstance():GetSex()
    for i = 1, #tbl do
        local param = {}
        local id = tbl[i][1]
        if type(id) == "table" then
            id = tbl[i][1][gender]
        end
        local color = Config.db_item[id].color - 1
        param["model"] = self.model
        param["item_id"] = id
        param["num"] = tbl[i][2]
        param["can_click"] = true
        param["color_effect"] = color
        param["effect_type"] = 2
        local item = GoodsIconSettorTwo(self.rewa_con)
        item:SetIcon(param)
        self.rewa_item_list[#self.rewa_item_list + 1] = item
    end
end
function FreeGiftPanel:DestroyMiddleRewa()
    for i = 1, #self.rewa_item_list do
        local item = self.rewa_item_list[i]
        if item then
            item:destroy()
        end
    end
    self.rewa_item_list = {}
end

function FreeGiftPanel:UpdateBtnState(rewa_con, rebate_con)
    local info = self.model:GetSingleInfoByActId(self.model.cur_sel_act_id)
    local is_free = false
    if rewa_con.cost == "{}" then
        is_free = true
    else
        self.model.cur_cost = String2Table(rewa_con.cost)
    end
    local is_limit = false
    if rebate_con.reqs ~= "" then
        is_limit = true
    end
    self.model.is_free = is_free
    local refund_type_name = self.model:GetMoneyTypeNameByItemId(String2Table(rebate_con.reward)[1][1])
    local is_continue = true
    local is_still_judge_undone = true
    local is_over = self.model:IsActOver()
    if is_free then
        --白给
        local cur_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        local tar_lv = String2Table(rewa_con.reqs)[2]
        if cur_lv < tar_lv then
            --未达到等级
            ShaderManager.GetInstance():SetImageGray(self.btn_img)
            SetOutLineColor(self.btn_outline, 119, 119, 119, 255)
            if is_over then
                self:SetBtnOutDateShow()
                self.model.cur_state = 4
            else
                SetVisible(self.btn_t, false)
                SetVisible(self.lv_limi_img, true)
                self.model.cur_state = 1
            end
            self.btn_img.raycastTarget = false;
            is_continue = false
            is_still_judge_undone = false
        end
    end
    if is_still_judge_undone then
        --跳过等级限制之后 是否已领取
        if info.state == enum.YY_TASK_STATE.YY_TASK_STATE_UNDONE then
            if is_over then
                self:SetBtnOutDateShow()
                self.model.cur_state = 4
            else
                --未领取
                local tip
                if is_free then
                    tip = ConfigLanguage.FreeGift.FetchImmediately
                    SetVisible(self.cost_icon, false)
                else
                    SetVisible(self.cost_icon, true)
                    --lua_resMgr:SetImageTexture(self, self.cost_icon, "iconasset/icon_goods_900", tostring(self.model.cur_cost[1][1]), true, nil, false)
                    tip = string.format(ConfigLanguage.FreeGift.BuyImmediately, self.model.cur_cost[1][2])
                end
                ShaderManager.GetInstance():SetImageNormal(self.btn_img)
                SetOutLineColor(self.btn_outline, 193, 97, 48, 255)
                SetVisible(self.btn_t, true)
                SetVisible(self.lv_limi_img, false)
                self.btn_img.raycastTarget = true;
                self.model.btn_mode = 1
                self.btn_t.text = tip
                self.model.cur_state = 1
            end
            is_continue = false
        end
    end
    if is_continue then
        if info.state == enum.YY_TASK_STATE.YY_TASK_STATE_REWARD then
            local is_break_limit = true
            local req_tbl = String2Table(rebate_con.reqs)
            if type(req_tbl[1]) == "tbl" then
                for i, v in pairs(req_tbl) do
                    if v[1] == "level" then
                        local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                        if lv < v[2] then
                            is_break_limit = false
                            break
                        end
                    end
                end
            else
                if req_tbl[1] == "level" then
                    local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
                    if lv < req_tbl[2] then
                        is_break_limit = false
                    end
                end
            end

            if is_limit and is_break_limit == false then
                ShaderManager.GetInstance():SetImageGray(self.btn_img)
                SetOutLineColor(self.btn_outline, 119, 119, 119, 255)
                SetVisible(self.btn_t, false)
                SetVisible(self.lv_limi_img, true)
                SetVisible(self.cost_icon, false)
                self.model.cur_state = 2
                self.btn_img.raycastTarget = false;
                is_continue = false
            else
                --已领取、未返利
                self.btn_t.text = string.format(ConfigLanguage.FreeGift.FetchDiamond, refund_type_name)
                if os.time() < info.refund_time then
                    --时间未到
                    ShaderManager.GetInstance():SetImageGray(self.btn_img)
                    SetOutLineColor(self.btn_outline, 119, 119, 119, 255)
                    SetVisible(self.btn_t, true)
                    SetVisible(self.lv_limi_img, false)
                    self.btn_img.raycastTarget = false;
                    self.model.cur_state = 2
                else
                    --时间到了，可以返利
                    ShaderManager.GetInstance():SetImageNormal(self.btn_img)
                    SetOutLineColor(self.btn_outline, 193, 97, 48, 255)
                    SetVisible(self.btn_t, true)
                    SetVisible(self.lv_limi_img, false)
                    self.btn_img.raycastTarget = true;
                    self.model.btn_mode = 2
                    self.model.cur_state = 4
                end
            end
        elseif info.state == enum.YY_TASK_STATE.YY_TASK_STATE_REFUND then
            --已经返利
            ShaderManager.GetInstance():SetImageGray(self.btn_img)
            SetOutLineColor(self.btn_outline, 119, 119, 119, 255)
            SetVisible(self.btn_t, true)
            SetVisible(self.lv_limi_img, false)
            self.btn_img.raycastTarget = false;
            self.btn_t.text = ConfigLanguage.FreeGift.AlreadyFetched
            self.model.cur_state = 3
        end
    end

    if self.model.cur_state == 3 or self.model.cur_state == 4 then
        SetVisible(self.cd_con, false)
    else
        SetVisible(self.cd_con, true)
        local text = ""
        local time
        if self.model.cur_state == 1 then
            time = self.model:GetActEndTime()
            text = "Time left: %s"
        elseif self.model.cur_state == 2 then
            text = "Claim after %s" .. refund_type_name
            time = info.refund_time
        end
        if time < os.time() then
            SetVisible(self.cd_con, false)
            return
        end
        self.countdowntext:StopSchedule()
        local param = {
            isShowMin = true,
            isShowHour = true,
            isShowDay = true,
            formatText = text,
            formatTime = "%d",
        }
        self.countdowntext:ResetParam(param)
        local function callback()
            --重新申请信息
            GlobalEvent:Brocast(FreeGiftEvent.OpenFreeGiftPanel)
            self:InitPanel()
        end
        self.countdowntext:StartSechudle(time, callback)
    end
    if self.model:CheckIsShowRDByActId(nil, true) then
        self:SetRedDot(true)
    else
        self:SetRedDot(false)
    end
    GoodIconUtil.GetInstance():CreateIcon(self, self.cost_icon, self.model.cur_cost[1][1], true)
end

function FreeGiftPanel:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end

function FreeGiftPanel:SetBtnOutDateShow()
    --活动过期
    SetVisible(self.btn_t, true)
    ShaderManager.GetInstance():SetImageGray(self.btn_img)
    SetOutLineColor(self.btn_outline, 119, 119, 119, 255)
    self.btn_t.text = ConfigLanguage.FreeGift.AlreadyOutDate
    SetVisible(self.lv_limi_img, false)
    self.model.cur_state = 3
    self.btn_img.raycastTarget = false
end

function FreeGiftPanel:CloseCallBack()
    if self.texture_cpn then
        self.texture_cpn.texture = nil
    end
    if self.cam then
        self.cam.targetTexture = nil
    end
    if self.texture then
        ReleseRenderTexture(self.texture)
        self.texture = nil
    end
    if self.l_magic_eft ~= nil then
        self.l_magic_eft:destroy()
        self.l_magic_eft = nil
    end
    self:DestroyEft()
    if self.countdowntext then
        self.countdowntext:destroy();
    end
    self.countdowntext = nil
    self:DestroySideItems()
    self:DestroyLeftModel()
    self:DestroyMiddleRewa()
    for i, v in pairs(self.model_event) do
        if v then
            self.model:RemoveListener(v)
        end
    end
    self.model_event = {}

    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
end

