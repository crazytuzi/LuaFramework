MiningTargetView = MiningTargetView or BaseClass(BaseView)

function MiningTargetView:__init()
    self.ui_config = {"uis/views/mining","MiningTargetView"}
    self.view_data = {}
    self.view_tpye = MINING_VIEW_TYPE.MINE
    self.index = MINING_TARGET_TYPE.QIANG_DUO
end

function MiningTargetView:_delete()

end

function MiningTargetView:ReleaseCallBack()

    for k,v in pairs(self.reward_list) do
        v:DeleteMe()
        v = nil
    end
    self.reward_list = {}

	self.text_title_name = nil
    self.text_player_name = nil
    self.text_player_zhanli = nil
    self.text_item1_info = nil
    self.text_item2_info = nil
    self.text_revange_btn_name = nil
    self.text_cancel_btn_name = nil
    self.text_tip = nil
    self.image_player = nil
    self.text_mining_reward_tip = nil
    self.view_tpye = nil
    self.is_show_item0 = nil
    self.is_show_item1 = nil
    self.index = nil
end

function MiningTargetView:OpenCallBack()
    self:Flush()
end

-- 刷新面板
function MiningTargetView:OnFlush()
    self.text_title_name:SetValue(Language.Mining.TargetType[self.index])
    self.text_revange_btn_name:SetValue(Language.Mining.TargetBtnText[self.index])
    self.text_mining_reward_tip:SetValue(Language.Mining.TargetTitleType[self.index])
    self:SetTargetPanel()
end

function MiningTargetView:LoadCallBack()
    -- 获取变量
    self.text_title_name = self:FindVariable("text_title_name")
    self.text_player_name = self:FindVariable("text_player_name")
    self.text_player_zhanli = self:FindVariable("text_player_zhanli")
    self.text_item1_info = self:FindVariable("text_item1_info")
    self.text_item2_info = self:FindVariable("text_item2_info")
    self.text_revange_btn_name = self:FindVariable("text_revange_btn_name")
    self.text_cancel_btn_name = self:FindVariable("text_cancel_btn_name")
    self.text_tip = self:FindVariable("text_tip")
    self.image_player = self:FindVariable("image_player")
    self.text_mining_reward_tip = self:FindVariable("text_mining_reward_tip")
    self.is_show_item0 = self:FindVariable("is_show_item0")
    self.is_show_item1 = self:FindVariable("is_show_item1")

    self.reward_list = {}
    for i = 0, 1 do
        self.reward_list[i] = ItemCell.New()
        self.reward_list[i]:SetInstanceParent(self:FindObj("item_" .. i))
        self.reward_list[i]:IgnoreArrow(true)
    end

    -- 监听事件
    self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow,self))
    self:ListenEvent("OnChooseTypeBtnClick",BindTool.Bind(self.OnChooseTypeBtnClick,self))
end

function MiningTargetView:CloseWindow()
    self:Close()
end

function MiningTargetView:SetIndexAndType(view_type,index)
    if nil ~= index and nil ~= view_type then
        self.view_tpye = view_type
        self.index = index
    end
end

function MiningTargetView:SetViewData(view_data)
    self.view_data = view_data
end

function MiningTargetView:OnChooseTypeBtnClick()
    if self.view_data == nil then return end
    if MINING_VIEW_TYPE.MINE == self.view_tpye then                         
        if MINING_TARGET_TYPE.QIANG_DUO == self.index then                     -- 挖矿--> 抢夺
            if self.view_data.random_index >= 0 and self.view_data.owner_uid == 0 then
                MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_ROB_ROBOT, self.view_data.robot_index)
            else
                MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_ROB_MINE, 0, self.view_data.owner_uid)
            end
            
        elseif MINING_TARGET_TYPE.FU_CHOU == self.index then                                       -- 挖矿--> 复仇
            MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_REVENGE, self.view_data.real_index)
        end
    else
        if MINING_TARGET_TYPE.QIANG_DUO == self.index then                     -- 挖矿--> 抢夺
            if self.view_data.random_index >= 0 and self.view_data.owner_uid == 0 then
                MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_ROB_ROBOT, self.view_data.robot_index)
            else
                MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_ROB_MINE, 0, self.view_data.owner_uid)
            end
            
        elseif MINING_TARGET_TYPE.FU_CHOU == self.index then                                       -- 挖矿--> 复仇
            MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_SEA_REVENGE, self.view_data.real_index)
        end
    end
end

function MiningTargetView:SetTargetPanel()
    if self.view_data == nil then
        return 
    end

    local name = self.view_data.owner_name

    local level = 1

    if MINING_TARGET_TYPE.FU_CHOU ~= self.index then
        if self.view_data.random_index >= 0 and self.view_data.owner_uid == 0 then
            name = MiningData.Instance:GetRandomNameByRandNum(self.view_data.random_index)
        end
        level = self.view_data.rob_level or 1
    else
        level = PlayerData.Instance.role_vo.level
    end
    self.text_player_name:SetValue(string.format(Language.Mining.TargetPlayNameText, name))
    self.text_player_zhanli:SetValue(string.format(Language.Mining.TargetPlayCapabilityText, self.view_data.capability))

    self.text_item1_info:SetValue(self.view_data.item1_info)
    self.text_item2_info:SetValue(self.view_data.item2_info)

    local item_1, item_2, rate = MiningData.Instance:GetMiningRewardByViewType(self.view_tpye, self.index, self.view_data.cur_type, level)

    if self.reward_list[0] ~= nil then
        self.reward_list[0]:SetData(item_1)
         if item_1 ~= nil and item_1.num > 0 then
            self.is_show_item0:SetValue(true)
            local item_name = ItemData.Instance:GetItemName(item_1.item_id)
            self.reward_list[0].root_node:SetActive(true)
            self.text_item1_info:SetValue(string.format(Language.Mining.RedewardExp, item_name, item_1.num))
        else
            self.is_show_item0:SetValue(false)
            self.reward_list[0].root_node:SetActive(false)
            self.text_item1_info:SetValue("")
        end
    end

    if self.reward_list[1] ~= nil then
        self.reward_list[1]:SetData(item_2)
        if item_2 ~= nil and item_2.num > 0 then
            self.is_show_item1:SetValue(true)
            self.reward_list[1].root_node:SetActive(true)
            self.text_item2_info:SetValue(string.format(Language.Mining.RedewardExp, Language.Common.JingYan, item_2.num))
        else
            self.is_show_item1:SetValue(false)
            self.reward_list[1].root_node:SetActive(false)
            self.text_item2_info:SetValue("")
        end
    end

    local player_bundle, player_asset = ResPath.GetRoleHeadBig(self.view_data.prof, self.view_data.sex)
    self.image_player:SetAsset(player_bundle, player_asset)
end