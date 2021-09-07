MiningRewardView = MiningRewardView or BaseClass(BaseView)

function MiningRewardView:__init()
    self.ui_config = {"uis/views/mining","MiningRewardView"}
    self.view_type = MINING_VIEW_TYPE.MINE
end

function MiningRewardView:_delete()

end

function MiningRewardView:ReleaseCallBack()
	self.text_title_name = nil
    self.image_shanggu = nil
    self.image_ship = nil
    self.text_reward_amount = nil
    self.text_reward_score = nil
    self.text_reward_amount2 = nil
    self.text_reward_score2 = nil
end

function MiningRewardView:OpenCallBack()
    self:Flush()
end

-- 刷新面板
function MiningRewardView:OnFlush()
    local info_data = MiningData.Instance:GetMiningMineMyInfo()
    self.image_shanggu:SetAsset(ResPath.GetMiningRes("mine_text_" .. info_data.mining_type))
    self.image_ship:SetAsset(ResPath.GetMiningRes("mining_k_" .. info_data.mining_type))

    local reward_data = MiningData.Instance:GetMiningMineCfg(info_data.mining_type)
    if reward_data == nil then return end

    local other_cfg = MiningData.Instance:GetOtherCfg()
    local dm_rob_reward_rate = (other_cfg and other_cfg.dm_rob_reward_rate) and other_cfg.dm_rob_reward_rate or 20

    local role_exp = MiningData.Instance:GetMiningExpValue(reward_data.reward_exp, PlayerData.Instance.role_vo.level)

    self.text_reward_amount2:SetValue(string.format(Language.Mining.RedewardExp, Language.Common.JingYan, role_exp))
    if info_data.mining_been_rob_times > 0 then
        local show_exp = math.floor(dm_rob_reward_rate * info_data.mining_been_rob_times * role_exp / 100.0)
        self.text_reward_score2:SetValue("-" .. show_exp)
    else
        self.text_reward_score2:SetValue("")
    end
    local item = reward_data.reward_item[0] or nil 
    local rob_get_item_count = reward_data.rob_get_item_count or 1
    if item then
        local item_name = ItemData.Instance:GetItemName(item.item_id)
        self.text_reward_amount:SetValue(string.format(Language.Mining.RedewardExp, item_name, item.num))
        if info_data.mining_been_rob_times > 0 then
            local show_num = rob_get_item_count * info_data.mining_been_rob_times --math.floor(dm_rob_reward_rate * info_data.mining_been_rob_times * item.num / 100.0)
            self.text_reward_score:SetValue("-" .. show_num)
        else
            self.text_reward_score:SetValue("")
        end
    end
end

function MiningRewardView:LoadCallBack()
    -- 获取变量
    self.text_title_name = self:FindVariable("text_title_name")
    self.image_shanggu = self:FindVariable("image_shanggu")
    self.image_ship = self:FindVariable("image_ship")
    self.text_reward_amount = self:FindVariable("text_reward_amount")
    self.text_reward_score = self:FindVariable("text_reward_score")
    self.text_reward_amount2 = self:FindVariable("text_reward_amount2")
    self.text_reward_score2 = self:FindVariable("text_reward_score2")

    -- 监听事件
    self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow,self))
    self:ListenEvent("OnSailingRecordBtn",BindTool.Bind(self.OnSailingRecordBtn,self))
    self:ListenEvent("OnRewardBtn",BindTool.Bind(self.OnRewardBtn,self))
end

function MiningRewardView:CloseWindow()
    self:Close()
end

function MiningRewardView:OnSailingRecordBtn()
    MiningController.Instance:OpenMiningRecordListView(self.view_type)
end

function MiningRewardView:OnRewardBtn()
    MiningController.Instance:SendCSFightingMiningReq(MINING_MINE_REQ_TYPE.REQ_TYPE_FETCH_REWARD)
end
