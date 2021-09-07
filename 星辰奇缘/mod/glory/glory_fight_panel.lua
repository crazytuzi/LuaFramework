-- @author 黄耀聪
-- @date 2017年6月26日, 星期一

GloryFightPanel = GloryFightPanel or BaseClass(BasePanel)

function GloryFightPanel:__init(model)
    self.model = model
    self.name = "GloryFightPanel"

    self.resList = {
        {file = AssetConfig.glory_fight, type = AssetType},
    }

    self.updateListener = function(data) self:Update(data) end
    self.starList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function GloryFightPanel:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function GloryFightPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.glory_fight))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(CombatManager.Instance.combatCanvas, self.gameObject)
    self.transform = t

    t:Find("Bg").sizeDelta = Vector2(155, 50)
    self.descText = t:Find("Text"):GetComponent(Text)
    self.descText.transform.sizeDelta = Vector2(145, 50)
end

function GloryFightPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function GloryFightPanel:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.fight_change, self.updateListener)

    self:Update()
end

function GloryFightPanel:OnHide()
    self:RemoveListeners()
end

function GloryFightPanel:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.fight_change, self.updateListener)
end

function GloryFightPanel:Update(data)
    local round = (data or CombatManager.Instance.enterData).round
    if round < 10 then
        self.descText.text = string.format(TI18N("<color='#ffff00'>----第%s关----</color>\n天雷剩余<color='#00ff00'>%s回合</color>掉落"), self.model.currentData.new_id + 1, 10 - round)
    else
        self.descText.text = string.format(TI18N("第<color='#00ff00'>%s</color>关\n天雷已经降临！"), self.model.currentData.new_id + 1)
    end
end


