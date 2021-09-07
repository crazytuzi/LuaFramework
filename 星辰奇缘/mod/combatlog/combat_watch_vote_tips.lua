-- ----------------------------------------------------------
-- UI - 观战投票tips
-- @ljh 20180703
-- ----------------------------------------------------------
CombatWatchVoteTips = CombatWatchVoteTips or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function CombatWatchVoteTips:__init(model)
	self.model = model
    self.name = "CombatWatchVoteTips"

    self.resList = {
        {file = AssetConfig.combatwatchvotetips, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
end


function CombatWatchVoteTips:__delete()
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end

function CombatWatchVoteTips:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.combatwatchvotetips))
    self.gameObject.name = "CombatWatchVoteTips"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseCombatWatchVoteTips() end)
    self.transform:FindChild("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self.model:CloseCombatWatchVoteTips() end)

    self:Update()
end

function CombatWatchVoteTips:Update()
    local data = CombatManager.Instance.voteData
    if data ~= nil then
        local data_combat_vote = DataCombatUtil.data_combat_vote[data.boss_id]
        if data_combat_vote ~= nil then
            if data.totla_num == nil or data.totla_num == 0 then
                self.transform:FindChild("Main/Text1"):GetComponent(Text).text = string.format(TI18N("<color='#13fc60'>%s人</color>\n<color='#13fc60'>%.2f%%</color>\n<color='#eb6100'>%.2f%%</color>\n<color='#f39700'>%.2f%%</color>"), data.observer_num, 33, 33, 33)
            else
                self.transform:FindChild("Main/Text1"):GetComponent(Text).text = string.format(TI18N("<color='#13fc60'>%s人</color>\n<color='#13fc60'>%.2f%%</color>\n<color='#eb6100'>%.2f%%</color>\n<color='#f39700'>%.2f%%</color>"), data.observer_num, data.support_num / data.totla_num * 100, data.unsupport_num / data.totla_num * 100, data.unknow_num / data.totla_num * 100)
            end
            self.transform:FindChild("Main/Text2"):GetComponent(Text).text = TI18N("<color='#92c6fc'>正在观看战斗\n认为挑战将会成功\n认为挑战将会失败\n对战局走向持不明确态度</color>")
            self.transform:FindChild("Main/Text3"):GetComponent(Text).text = data_combat_vote.desc
        end
    end
end