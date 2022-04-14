-- @Author: lwj
-- @Date:   2019-11-29 19:13:25
-- @Last Modified time: 2019-11-29 19:13:27

ChristmasHanabiView = ChristmasHanabiView or class("ChristmasHanabiView", BaseItem)
local ChristmasHanabiView = ChristmasHanabiView

function ChristmasHanabiView:ctor(parent_node, layer)
    self.abName = "nation"
    self.assetName = "ChristmasHanabiView"
    self.layer = layer
    self.act_id = OperateModel.GetInstance():GetActIdByType(730)
    self.openData = OperateModel:GetInstance():GetAct(self.act_id)
    self.model = NationModel.GetInstance()
    self.pos_list = {
        [1] = { 228, -35.3 },
        [2] = { 364, -35.3 },
        [3] = { 295.5, 77 },
        [4] = { 408, 77 },
        [5] = { 498, -34 },
        [6] = { 408, -140 },
        [7] = { 295.5, -140 },
        [8] = { 183, -140 },
        [9] = { 94, -34 },
        [10] = { 183, 77 },
    }
    self.global_event = {}
    self.rewa_item_list = {}
    self.normal_rewa_size = 75
    self.special_rewa_size = 90
    self.pos_y = 0
    self.pos_z = 750
    self.pos_x = -4011
    self.rota_y = 0

    ChristmasHanabiView.super.Load(self)
end

function ChristmasHanabiView:dctor()
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
    destroySingle(self.eft)
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    if not table.isempty(self.global_event) then
        for i, v in pairs(self.global_event) do
            GlobalEvent:RemoveListener(v)
        end
        self.global_event = {}
    end
    if self.cost_item then
        self.cost_item:destroy()
        self.cost_item = nil
    end
    if self.ui_model then
        self.ui_model:destroy()
        self.ui_model = nil
    end
    if not table.isempty(self.rewa_item_list) then
        for i, v in pairs(self.rewa_item_list) do
            v:destroy()
        end
    end
    self.rewa_item_list = {}
end

function ChristmasHanabiView:LoadCallBack()
    self.nodes = {
        "rtime", "left_text", "btn_fire_one", "middle_text", "rewa_con", "btn_fire_ten", "top_text", "settled_rewa_con", "settled_rewa_num",
        "model_con", "eft_con", "img_con", "btn_ques", "model_con/Camera", "tip_icon",
    }
    self:GetChildren(self.nodes)
    self.top_text = GetImage(self.top_text)
    self.left_text = GetImage(self.left_text)
    self.middle_text = GetImage(self.middle_text)
    self.rtime = GetText(self.rtime)
    self.settled_rewa_num = GetText(self.settled_rewa_num)
    self.img_con = GetImage(self.img_con)

    SetLocalPosition(self.eft_con, -240, -158)
    self.model_con_rect = GetRectTransform(self.model_con)
    SetLocalPosition(self.model_con, -236.6, 33.5)
    SetSizeDelta(self.model_con_rect, 500, 500)
    SetLocalPosition(self.Camera, -4010, 0, 4)
    SetVisible(self.btn_ques, false)

    self.texture = CreateRenderTexture()
    self.texture_cpn = self.model_con:GetComponent("RawImage")
    self.texture_cpn.texture = self.texture
    self.cam = self.Camera:GetComponent("Camera")
    self.cam.targetTexture = self.texture

    self:AddEvent()
    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);
    self.cf = self.model:GetThemeCfById(self.act_id)
    if not self.cf then
        return
    end
    self:InitPanel()
    self:LoadEft()
end

function ChristmasHanabiView:LoadEft()
    destroySingle(self.eft)
    local function cb()
    end
    self.eft = UIEffect(self.eft_con, 10311, false, self.layer, cb)
    --self.eft:SetOrderIndex(500)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.img_con.transform, nil, true, nil, false, 2)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.left_text.transform, nil, true, nil, false, 3)
    LayerManager.GetInstance():AddOrderIndexByCls(self, self.model_con, nil, true, nil, 1, 6)
end
function ChristmasHanabiView:PlayAni()
    local action = cc.MoveTo(1.5, -240, 45, 0)
    action = cc.Sequence(action, cc.MoveTo(1.5, -240, -45, 0))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, self.img_con.transform)
end

function ChristmasHanabiView:AddEvent()
    local function callback()
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(12)
    end
    AddButtonEvent(self.btn_ques.gameObject, callback)

    local function callback()
        self:ClickFun(1)
    end
    AddButtonEvent(self.btn_fire_one.gameObject, callback)

    local function callback()
        lua_panelMgr:GetPanelOrCreate(ProbaTipPanel):Open(12)
    end
    AddButtonEvent(self.tip_icon.gameObject, callback)

    local function callback()
        self:ClickFun(10)
    end
    AddButtonEvent(self.btn_fire_ten.gameObject, callback)
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self, self.UpdateCurHaveNum))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.AddItems, handler(self, self.UpdateCurHaveNum))
end

function ChristmasHanabiView:IsEnoughFire(times)
    local cost_id = self.tbl[1]
    local cost_num = self.tbl[2] * times
    local is_can_crack = false
    local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id)
    local is_have_enough_hammer = have_num >= cost_num
    if is_have_enough_hammer then
        is_can_crack = true
    end
    return is_can_crack, is_have_enough_hammer, have_num
end

function ChristmasHanabiView:InitPanel()
    local req = String2Table(self.cf.reqs)
    self.tbl = {}
    for _, tb in pairs(req) do
        if tb[1] == "cost" then
            self.tbl = tb[2][1]
            self.model.cur_hanabi_cost_tbl = self.tbl
            break
        end
    end
    self:InitResShow()
    self:LoadRewardShow()
    local param = {}
    local operate_param = {}
    param["item_id"] = self.tbl[1]
    param["can_click"] = true
    param["operate_param"] = operate_param
    param["size"] = { x = 78, y = 78 }
    param["num"] = self.tbl[2]
    param.bind = self.tbl[3]
    --local color = Config.db_item[id].color - 1
    --param["color_effect"] = color
    --param["effect_type"] = 2  --活动特效：2
    self.cost_item = GoodsIconSettorTwo(self.settled_rewa_con)
    self.cost_item:SetIcon(param)

    self:UpdateCurHaveNum()
end

function ChristmasHanabiView:UpdateCurHaveNum()
    local num = BagModel.Instance:GetItemNumByItemID(self.tbl[1])
    num = num == 0 and "" or num
    self.settled_rewa_num.text = num
end

function ChristmasHanabiView:LoadRewardShow()
    if not table.isempty(self.rewa_item_list) then
        for i=1,#self.rewa_item_list do
            local GItem=self.rewa_item_list[i]
            if GItem then
                GItem:destroy()
                GItem=nil
            end
        end
        self.rewa_item_list={}
    end
    local reward_tbl = self.rewa_tbl
    for i = 1, #reward_tbl do
        local size = i <= 2 and self.special_rewa_size or self.normal_rewa_size
        local data = reward_tbl[i]
        local param = {}
        local operate_param = {}
        param["item_id"] = data[1]
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = size, y = size }
        param["num"] = data[2]
        param.bind = data[3]
        local color = Config.db_item[data[1]].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2  --活动特效：2
        local itemIcon = GoodsIconSettorTwo(self.rewa_con)
        itemIcon:SetIcon(param)
        SetLocalPosition(itemIcon.transform, self.pos_list[i][1], self.pos_list[i][2])
        self.rewa_item_list[#self.rewa_item_list + 1] = itemIcon
    end
end

function ChristmasHanabiView:InitResShow()
    local tbl = String2Table(self.cf.sundries)

    local w_lv = RoleInfoModel.GetInstance().world_level
    self.rewa_tbl = {}
    self.res_tbl = {}
    local theme_str = ""
    for _, v in pairs(tbl) do
        if v[1] == "resource" then
            theme_str = v[2]
        elseif v[1] == "reward_show" then
            local lv_list = v[2]
            if w_lv >= lv_list[1] and w_lv <= lv_list[2] then
                self.res_tbl = v[3]
                self.rewa_tbl = v[4]
                break
            end
        end
    end
    if self.res_tbl[1] == "model" then
        self:LoadRoleModel(self.res_tbl[2])
        SetVisible(self.img_con, false)
        SetVisible(self.model_con, true)
    elseif self.res_tbl[1] == "texture" then
        lua_resMgr:SetImageTexture(self, self.img_con, "iconasset/icon_festival", self.res_tbl[2], false, nil, false)
        self:PlayAni()
        SetVisible(self.model_con, false)
        SetVisible(self.img_con, true)
    end
    local head_str = theme_str
    lua_resMgr:SetImageTexture(self, self.left_text, "iconasset/icon_festival", self.res_tbl[3], false, nil, false)
    self:LoadPanelRes(head_str)
end

function ChristmasHanabiView:LoadRoleModel(model_id)
    self:GetRightPos(model_id)
    self.ui_model = UIModelManager:GetInstance():InitModel(nil, model_id, self.model_con.transform, handler(self, self.model_cb), true)
end

function ChristmasHanabiView:GetRightPos(res_str)
    self.model_cb = handler(self, self.LoadMgrModelCallB)
    local tbl = string.split(res_str, "_")
    local type = tbl[2]
    if type == "fabao" then
        self.pos_y = -38
        self.pos_x = -4008.6
        self.pos_z = 131.3
        self.rota_y = 180
    elseif type == "monster" then
        self.pos_y = 0
    elseif type == "mount" then
        self.pos_y = -238
    elseif type == "npc" then
        self.pos_y = 0
    elseif type == "pet" then
        self.pos_y = -121.6
        self.pos_z = 477.1
        self.rota_y = 180
    elseif type == "role" then
        self.pos_y = 0
    elseif type == "wing" then
        self.pos_x = -4014.1
        self.pos_y = -47
        self.pos_z = 373
    elseif type == "weapon" then
        self.pos_y = -35
        self.pos_z = 483
        self.rota_y = 180
        self.model_cb = handler(self, self.WeaponCallBack)
    elseif type == "hand" then
        self.pos_y = -102
    end
end
function ChristmasHanabiView:Loadui_modelCallBack()
    SetLocalPosition(self.ui_model.transform, self.pos_x, -185, self.pos_z)
    --SetLocalRotation(self.ui_model.transform, 1, -124.5, 1)
    SetLocalRotation(self.ui_model.transform, 0, 225, 0)
    SetLocalScale(self.ui_model.transform, 100, 100, 100)
end
function ChristmasHanabiView:LoadMgrModelCallB()
    SetLocalPosition(self.ui_model.transform, self.pos_x, self.pos_y, self.pos_z)
    local v3 = self.ui_model.transform.localScale;
    SetLocalScale(self.ui_model.transform, 100, 100, 100);
    SetLocalRotation(self.ui_model.transform, 0, self.rota_y, 0);
end
function ChristmasHanabiView:WeaponCallBack()
    SetLocalPosition(self.ui_model.transform, self.pos_x, self.pos_y, self.pos_z)
    local v3 = self.ui_model.transform.localScale;
    SetLocalScale(self.ui_model.transform, 100, 100, 100);
    SetLocalRotation(self.ui_model.transform, 0, self.rota_y, 0);

    self.ui_model:AddAnimation({ "show", "idle2" }, false, "idle2", 0)--,"casual"
    self.ui_model.animator:CrossFade("idle2", 0)
end

function ChristmasHanabiView:LoadPanelRes(head_str)
    lua_resMgr:SetImageTexture(self, self.top_text, "iconasset/icon_festival", head_str .. "_top", false, nil, false)
    lua_resMgr:SetImageTexture(self, self.middle_text, "iconasset/icon_festival", head_str .. "_middle", false, nil, false)
end

function ChristmasHanabiView:FireTheHole(times)
    if self.act_id == 0 then
        logError("没有该id  ", self.act_id)
        return
    end
    GlobalEvent:Brocast(OperateEvent.REQUEST_FIRE, self.act_id, times)
end

function ChristmasHanabiView:ClickFun(times)
    local cost_id = self.tbl[1]
    local cost_num = self.tbl[2] * times
    if (not cost_num) or (not cost_id) then
        logError("ChristmasHanabiView: 没有消耗id")
        return
    end
    local is_can, _, have_num = self:IsEnoughFire(times)
    if is_can then
        self:FireTheHole(times)
    else
        --弹窗消费钻石提示
        local item_name = Config.db_item[cost_id].name
        local lack_num = cost_num - have_num
        local price = Config.db_voucher[cost_id].price * lack_num
        if not RoleInfoModel.GetInstance():CheckGold(price, Config.db_voucher[cost_id].type) then
            return
        end
        local message = string.format(ConfigLanguage.Nation.HammerNotEnough, item_name, price, item_name, lack_num)
        if self.model.is_hanabi_check then
            self:FireTheHole(times)
        else
            local function ok_fun(is_hanabi_check)
                self.model.is_hanabi_check = is_hanabi_check
                self:FireTheHole(times)
            end
            Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
        end
    end
end

function ChristmasHanabiView:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        -- Notify.ShowText("活动结束了");
        -- self.rtime.text = "活动剩余：已结束"
        self.rtime.text = string.format("<color=#%s>%s</color>", "ff0000", "Ended")
        GlobalSchedule.StopFun(self.schedules);
    else
        if timeTab.day then
            timestr = timestr .. string.format(formatTime, timeTab.day) .. "Days";
        end
        if timeTab.hour then
            timestr = timestr .. string.format(formatTime, timeTab.hour) .. "hr";
        end
        if timeTab.min then
            timestr = timestr .. string.format(formatTime, timeTab.min) .. "min";
        end
        if timeTab.sec and not timeTab.day and not timeTab.hour and not timeTab.min then
            timestr = "1 pts"
        end
        --if timeTab.sec then
        --    timestr = timestr .. string.format(formatTime, timeTab.sec);
        --end
        local color = "27C31F"
        if not timeTab.day then
            color = "ff0000"
        end
        self.rtime.text = string.format("<color=#%s>%s</color>", color, timestr)
        -- self.rtime.text = "活动剩余：" .. timestr;
    end

end
