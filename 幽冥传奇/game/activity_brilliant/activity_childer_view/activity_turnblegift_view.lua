TurnbleGiftPage = TurnbleGiftPage or BaseClass(ActTurnbleBaseView)
local DZP_COUNT = 8

function TurnbleGiftPage:__init(view, parent, act_id)
    self:LoadView(parent)
end

function TurnbleGiftPage:__delete()
    if self.zp_86_list then
        self.zp_86_list:DeleteMe()
        self.zp_86_list = nil
    end
    if self.table_86_reward_t then 
        for k,v in pairs(self.table_86_reward_t) do
            v:DeleteMe()
        end
        self.table_86_reward_t = {}
    end

    if self.spare_86_time ~= nil then
        GlobalTimerQuest:CancelQuest(self.spare_86_time)
        self.spare_86_time = nil
    end

    if RoleData.Instance then
        RoleData.Instance:RemoveEventListener(self.gold_listener)
    end
end

function TurnbleGiftPage:InitView()
    self.node_t_list.layout_check_auto_draw.node:setVisible(false)
    self.node_t_list.btn_86_draw.node:addClickEventListener(BindTool.Bind(self.OnClickTurntableHandler, self))
    self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, 0.5)
    local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZPHL)
    self.node_t_list.btn_86_tip.node:addClickEventListener(function () 
        DescTip.Instance:SetContent(act_cfg.act_desc, act_cfg.act_name)
    end)

    self.gold_listener = RoleData.Instance:AddEventListener(OBJ_ATTR.ACTOR_GOLD, function ()
        ActivityBrilliantCtrl.ActivityReq(3, self.act_id)
    end)

    EventProxy.New(ShenDingData.Instance, self):AddEventListener(ShenDingData.TASK_DATA_CHANGE, function ()
        self:RefreshView(param_list)
    end)

    self.node_t_list.img_item_icon.node:loadTexture(ResPath.GetItem(act_cfg.config.item_icon))
    self.node_t_list.img_item_icon.node:setScale(0.4)
    self.node_t_list.img_item_icon.node:setPositionX(self.node_t_list.img_item_icon.node:getPositionX()-5)

    self:CreateZPHLReward()
    self:CreateZPHLRewardLog()
    self:CreateSpareFFTimer()
    self:InitTurnbel()
end

function TurnbleGiftPage:RefreshView(param_list)
    local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZPHL)

    self.node_t_list.lbl_have_score.node:setString(ActivityBrilliantData.Instance:GetZPHLScore())
    self.zp_86_list:SetDataList(ActivityBrilliantData.Instance:GetZPHLList())
    
    if nil == act_cfg or param_list == nil then return end
    for k,v in pairs(param_list) do
        if k == "flush_view" and v.result and v.act_id == act_cfg.act_id and not self:GetIsIgnoreAction() then
            self.node_t_list.layout_dzp_point.node:stopAllActions()
            local rotate = self.node_t_list.layout_dzp_point.node:getRotation() % 360
            local to_rotate =720 - rotate + 360 / DZP_COUNT / 2 + 360 / DZP_COUNT * (v.result - 1) - (v.result == 1 and 18 or 18)
            local rotate_by = cc.RotateBy:create(1, to_rotate)
            local callback = cc.CallFunc:create(function ()
                self.node_t_list.btn_86_draw.node:setEnabled(true)
                ItemData.Instance:SetDaley(false)
                self.zp_86_list:SetDataList(ActivityBrilliantData.Instance:GetZPHLList())
                self:FlushRewardCell()
            end)
            local sequence = cc.Sequence:create(rotate_by, callback)
            self.node_t_list.layout_dzp_point.node:runAction(sequence)
        else
            if self.node_t_list.btn_86_draw.node:isEnabled() then
                self.zp_86_list:SetDataList(ActivityBrilliantData.Instance:GetZPHLList())
                self:FlushRewardCell()
            end
        end
    end
end

function TurnbleGiftPage:CreateZPHLReward()
    self.table_86_reward_t = {}
    local r = 130
    local x, y = self.node_t_list.layout_dzp_point.node:getPosition()
    for i = 1, DZP_COUNT do
        local ph = self.ph_list["ph_cell_86_"..i]
        local cell = ActBaseCell.New()
        cell:SetPosition(ph.x,ph.y)
        cell:SetCellBg()
        cell:SetIndex(i)
        cell:GetView():setScale(0.8)
        cell:SetAnchorPoint(0, 0)
        self.node_t_list.layout_act_zphl.node:addChild(cell:GetView(), 5)
        table.insert(self.table_86_reward_t, cell)
    end
    local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZPHL)
    if act_cfg and act_cfg.config.award_pool then   
        for i,v in ipairs(self.table_86_reward_t) do
            local data =  act_cfg.config.award_pool[i].awards[1]
            if data then
                if data.type == tagAwardType.qatEquipment then
                    v:SetData({["item_id"] = data.id, ["num"] = data.count, is_bind = data.bind, effectId = data.effectId})
                else
                    local virtual_item_id = ItemData.GetVirtualItemId(data.type)
                    if virtual_item_id then
                        v:SetData({["item_id"] = virtual_item_id, ["num"] = data.count, is_bind = data.bind or 0})
                    end
                end
            else
                v:SetData()
            end
        end
    end
    self:FlushRewardCell()
end

function TurnbleGiftPage:CreateZPHLRewardLog()
    local ph = self.ph_list.ph_task_86_list
    self.zp_86_list = ListView.New()
    self.zp_86_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActivityZPHLRender, nil, nil, self.ph_list.ph_item_86)
    self.zp_86_list:GetView():setAnchorPoint(0, 0)
    self.zp_86_list:SetJumpDirection(ListView.Top)
    self.zp_86_list:SetItemsInterval(8)
    self.node_t_list.layout_act_zphl.node:addChild(self.zp_86_list:GetView(), 100)
end

function TurnbleGiftPage:UpdateSpareFFTime()
    local cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.ZPHL)
    if nil == cfg then return end
    local now_time =TimeCtrl.Instance:GetServerTime()
    local end_time = cfg.end_time 
    local spare_time = end_time - now_time 
    self.node_t_list.layout_act_zphl.lbl_activity_spare_time.node:setString(TimeUtil.FormatSecond2Str(spare_time))
end

function TurnbleGiftPage:CreateSpareFFTimer()
    self.spare_86_time = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.UpdateSpareFFTime, self), 1)
end

function TurnbleGiftPage:OnClickTurntableHandler()
    local have_score = ActivityBrilliantData.Instance:GetZPHLScore()
    local cost_score = ActivityBrilliantData.Instance:GetIndexCostScore()

    if have_score < cost_score then
        SysMsgCtrl.Instance:FloatingTopRightText(Language.ActivityBrilliant.ZPHLTip)
        return 
    end

    -- local act_cfg = ActivityBrilliantData.Instance:GetActCfgByIndex(ACT_ID.TSMB)
    -- local can_draw = ActivityBrilliantData.Instance:GetTSMBData().draw_num == 0 
    self:UpdateAutoDrawTimer(6, have_score > cost_score) --每隔1秒抽一次

    if self:TryDrawIgnoreAction() then
        self.node_t_list.btn_86_draw.node:setEnabled(true)
        ItemData.Instance:SetDaley(false)
        return
    end --成功则跳过动画

    self:OnClickTSMBHandler()
end

-- 格子变灰显示
function TurnbleGiftPage:FlushRewardCell()
    local reward = ActivityBrilliantData.Instance:GetZPHLRewardSign()
    if self.table_86_reward_t then
        for k, v in pairs(self.table_86_reward_t) do
            v:MakeGray(reward[k] == 1)
            v:SetIsChoiceVisible(reward[k] == 1)
        end
    end
end

function TurnbleGiftPage:InitTurnbel()
    local a_y = 1 - ((180 -48) / 2 + 48) / 180
    self.node_t_list.layout_dzp_point.node:setAnchorPoint(0.5, a_y)
    self.node_t_list.layout_dzp_point.node:setPositionY(self.node_t_list.layout_dzp_point.node:getPositionY() - 180 * (0.5 - a_y))
end

function TurnbleGiftPage:OnClickTSMBHandler()
    local act_id = ACT_ID.ZPHL

    local rotate_by1 = cc.RotateBy:create(1, 360 * 2)
    local rotate_by2 = cc.RotateBy:create(2, 360 * 5)
    local callback = cc.CallFunc:create(function ()
        ItemData.Instance:SetDaley(true)
        ActivityBrilliantCtrl.Instance.ActivityReq(4, act_id)
    end)
    local callback2 = cc.CallFunc:create(function ()
        self.node_t_list.btn_86_draw.node:setEnabled(true)
    end)
    local sequence = cc.Sequence:create(rotate_by1, callback, rotate_by2, callback2)
    self.node_t_list.btn_86_draw.node:setEnabled(false)
    self.node_t_list.layout_dzp_point.node:runAction(sequence)
end

----------------------------------------
-- TaskItem渲染
----------------------------------------
local name_cfg = {
    [1] = "每日签到",
    [2] = "羽毛副本",
    [3] = "魂珠副本",
    [4] = "护盾副本",
    [5] = "宝石副本",
    [6] = "经验副本",
    [7] = "每日充值",
    [8] = "每日寻宝",
    [9] = "降妖除魔",
    [10] = "参与任意活动",
    [11] = "击杀敌人",
    [12] = "膜拜城主",
    [13] = "试练关卡",
    [14] = "护送镖车",
    [15] = "消灭专属boss",
    [16] = "使用屠魔令",
    [17] = "挖掘BOSS",
    [18] = "消灭运势boss",
    [19] = "回收装备",
    [20] = "投入蚩尤神石",
    [21] = "矿洞挖掘",
    [22] = "矿洞掠夺",
    [23] = "元宝祈福",
    [24] = "等级祈福",
}

local config = {
    [1] = {view = ViewDef.Welfare.DailyRignIn, cs_id = nil},
    [2] = {view = nil, cs_id = 48},
    [3] = {view = nil, cs_id = 48},
    [4] = {view = nil, cs_id = 48},
    [5] = {view = nil, cs_id = 48},
    [6] = {view = nil, cs_id = 48},
    [7] = {view = ViewDef.ZsVip.Recharge, cs_id = nil},
    [8] = {view = ViewDef.Explore.Xunbao, cs_id = nil},
    [9] = {view = nil, cs_id = 51},
    [10] = {view = ViewDef.Activity.Activity, cs_id = nil},
    [11] = {view = ViewDef.NewlyBossView.Wild, cs_id = nil},
    [12] = {view = nil, cs_id = 3},
    [13] = {view = ViewDef.ShiLian, cs_id = nil},
    [14] = {view = nil, cs_id = 20},
    [15] = {view = ViewDef.NewlyBossView.Wild.Specially, cs_id = nil},
    [16] = {view = ViewDef.NewlyBossView.Wild.CircleBoss, cs_id = nil},
    [17] = {view = ViewDef.NewlyBossView.Wild, cs_id = nil},
    [18] = {view = ViewDef.NewlyBossView.Rare.FortureBoss, cs_id = nil},
    [19] = {view = ViewDef.Recycle, cs_id = nil},
    [20] = {view = ViewDef.NewlyBossView.Rare.Chiyou, cs_id = nil},
    [21] = {view = ViewDef.Experiment.DigOre, cs_id = nil},
    [22] = {view = ViewDef.Experiment.DigOre, cs_id = nil},
    [23] = {view = ViewDef.Investment.Blessing, cs_id = nil},
    [24] = {view = ViewDef.Investment.Blessing, cs_id = nil},
}

ActivityZPHLRender = ActivityZPHLRender or BaseClass(BaseRender)
function ActivityZPHLRender:__init()    
end

function ActivityZPHLRender:__delete()  
end

function ActivityZPHLRender:CreateChild()
    BaseRender.CreateChild(self)

    local text = RichTextUtil.CreateLinkText("前往", 18, COLOR3B.GREEN, nil, true)
    text:setAnchorPoint(cc.p(0, 0))
    self.node_tree.layout_operation1.node:addChild(text, 20)
    XUI.AddClickEventListener(self.node_tree.layout_operation1.node, BindTool.Bind(self.OnClickOperationText, self), true)
end

function ActivityZPHLRender:OnFlush()
    if self.data == nil then return end
    
    -- PrintTable(self.data)
    local index = self.data.index
    local bool = self.data.can_receive == 1
    local color = bool and COLORSTR.GREEN or COLORSTR.RED
    local text = string.format("{color;%s;%d/%d}", color, self.data.time, self.data.max_tms) -- 只能领取一次
    self.node_tree.lbl_task_name.node:setString(name_cfg[index])
    self.node_tree.lbl_rew_num.node:setString(self.data.score)
    RichTextUtil.ParseRichText(self.node_tree.rich_task_time.node, text, 20, COLOR3B.GREEN)
    XUI.RichTextSetCenter(self.node_tree.rich_task_time.node)

    self.node_tree.layout_operation1.node:setVisible(not bool)
    self.node_tree.lbl_operation2.node:setVisible(bool)

    self.node_tree.img_item_icon.node:loadTexture(ResPath.GetItem(self.data.item_icon))
    self.node_tree.img_item_icon.node:setScale(0.4)
    self.node_tree.img_item_icon.node:setPositionX(self.node_tree.img_item_icon.node:getPositionX()-5)
end

function ActivityZPHLRender:OnClickOperationText() 
    local cfg = config[self.data.index]
    if cfg.view == nil then
        ViewManager.Instance:CloseAllView()
        GuajiCtrl.Instance:FlyByIndex(cfg.cs_id)
    else
        ViewManager.Instance:OpenViewByDef(cfg.view)
    end
end

function ActivityZPHLRender:CreateSelectEffect()
end
