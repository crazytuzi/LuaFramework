-- @Author: lwj
-- @Date:   2019-09-25 16:49:50 
-- @Last Modified time: 2019-09-25 16:49:53

NationEggItem = NationEggItem or class("NationEggItem", BaseCloneItem)
local NationEggItem = NationEggItem

function NationEggItem:ctor(parent_node, layer)
    self.time = 0.5
    self.sprite_list = {}
    self.is_playing_anim = false
    NationEggItem.super.Load(self)
end

function NationEggItem:dctor()
    if self.action then
        self.action = nil
    end
    for i = 1, #self.sprite_list do
        self.sprite_list[i] = nil
    end
    self.sprite_list = nil
    if self.rewa_item then
        self.rewa_item:destroy()
        self.rewa_item = nil
    end
    for i, v in pairs(self.model_event) do
        self.model:RemoveListener(v)
    end
    self.model_event = {}
end

function NationEggItem:LoadCallBack()
    self.model = NationModel.GetInstance()
    self.nodes = {
        "bg", "rewa_con", "mask", 'cracked', "hammer",
    }
    self:GetChildren(self.nodes)
    self.bg = GetImage(self.bg)
    self.cracked = GetImage(self.cracked)
    self.hammer = GetImage(self.hammer)

    self:AddEvent()
    self:LoadSprite()
end

function NationEggItem:AddEvent()
    local function callback()
        if self.is_playing_anim then
            return
        end
        local cost_tbl = self.model.cost_tbl
        local cost_id = cost_tbl[1]
        local cost_num = cost_tbl[2]
        local is_can_crack = false
        local info = self.model:GetEggCrackInfo()
        local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_id, cost_num)
        if info.free_crack > 0 then
            is_can_crack = true
        elseif have_num >= cost_num then
            is_can_crack = true
        end
        if is_can_crack then
            self:PlayCrackAnimate()
        else
            --弹窗消费钻石提示
            local item_name = Config.db_item[cost_id].name
            local lack_num = cost_num - have_num
            local price = Config.db_voucher[cost_id].price * lack_num
            if not RoleInfoModel.GetInstance():CheckGold(price, Config.db_voucher[cost_id].type) then
                return
            end
            local message = string.format(ConfigLanguage.Nation.HammerNotEnough, item_name, price, item_name, lack_num)
            if self.model.is_check then
                self:PlayCrackAnimate()
            else
                local function ok_fun(is_check)
                    self.model.is_check = is_check
                    self:PlayCrackAnimate()
                end
                Dialog.ShowTwo(ConfigLanguage.SearchT.TipsTitle, message, nil, ok_fun, nil, nil, nil, nil, ConfigLanguage.SearchT.NoAlert, false)
            end
        end
    end
    AddClickEvent(self.mask.gameObject, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(NationEvent.SuccessCrackEgg, handler(self, self.HandleSuccessCrack))
end

function NationEggItem:SetData(data)
    self.data = data
    self:UpdateView()
end

--1是普通蛋，2是彩蛋
function NationEggItem:UpdateView()
    local img_title = 'egg_crack_img_'
    local is_complete = self.data.reward_id == 0
    SetVisible(self.cracked, not is_complete)
    SetVisible(self.bg, is_complete)
    local img_compo = is_complete and self.bg or self.cracked
    if is_complete then
        img_title = "egg_img_"
    end
    local asset_name = img_title .. self.data.group
    lua_resMgr:SetImageTexture(self, img_compo, "nation_image", asset_name, false, nil, false)
    SetVisible(self.mask, is_complete)

    if is_complete then
        if self.rewa_item then
            SetVisible(self.rewa_item, false)
        end
    else
        local cf = SearchTreasureModel.GetInstance():GetYYLotteryRewardsByKey(self.data.reward_id)
        if not self.rewa_item then
            self.rewa_item = GoodsIconSettorTwo(self.rewa_con)
        end
        local rewa_cf = String2Table(cf.rewards)[1]
        local item_id = rewa_cf[1]
        local param = {}
        local operate_param = {}
        param["item_id"] = item_id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 78, y = 78 }
        param["num"] = rewa_cf[2]
        param.bind = rewa_cf[3]
        local color = Config.db_item[item_id].color - 1
        param["color_effect"] = color
        param["effect_type"] = 2  --活动特效：2
        self.rewa_item:SetIcon(param)
        SetVisible(self.rewa_item, true)
    end

end

function NationEggItem:CrackEgg()
    GlobalEvent:Brocast(OperateEvent.REQUEST_CRACK_EGG, OperateModel.GetInstance():GetActIdByType(406), self.data.pos)
end

function NationEggItem:HandleSuccessCrack(data)
    local map = data.items
    for pos, value in pairs(map) do
        if pos == self.data.pos then
            self.data = value
            self.data.pos = pos
            self:UpdateView()
            break
        end
    end
end

function NationEggItem:LoadSprite()
    local arr_spirite = { "hammer_1", "hammer_2", "hammer_3", "hammer_4",
                          "hammer_5", "hammer_6", "hammer_7", "hammer_8", "hammer_9",
                          "hammer_11", "hammer_12", "hammer_13" }

    for i = 1, #arr_spirite do
        local function call_back(objs)
            self.sprite_list[i] = objs[0]
        end
        lua_resMgr:LoadSprite(self, 'anim_image', arr_spirite[i], call_back)
    end
end

function NationEggItem:PlayCrackAnimate(is_dont_send_data)
    self.is_playing_anim = true
    local last_sprite_index = 13
    local delayperunit = 0.047
    local loop_count = 13
    local function start_action()
        if self.action then
            cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.hammer)
            self.action = nil
        end
        local action = cc.Animate(self.sprite_list, self.time, self.hammer, last_sprite_index, delayperunit, loop_count)
        cc.ActionManager:GetInstance():addAction(action, self.hammer)
        self.action = action
    end

    start_action()
    local function call_back()
        if not is_dont_send_data then
            self:CrackEgg()
        end
        lua_resMgr:SetImageTexture(self, self.hammer, "system_image", "empty", true, nil, false)
    end
    GlobalSchedule:StartOnce(call_back, self.time + 0.2)
    local function call_back()
        self.is_playing_anim = false
    end
    GlobalSchedule:StartOnce(call_back, self.time + 1)
end