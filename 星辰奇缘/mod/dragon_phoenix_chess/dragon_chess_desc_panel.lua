-- @author hze
-- @date 2018/06/26
--龙凤棋描述

DragonChessDescPanel = DragonChessDescPanel or BaseClass(BaseWindow)

function DragonChessDescPanel:__init(model)
    self.model = model
    self.name = "DragonChessDescPanel"

    self.typeList = {}

    self.resList = {
        {file = AssetConfig.dragon_chess_desc_panel, type = AssetType.Main},
        {file = AssetConfig.dragon_chess_textures, type = AssetType.Dep},
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function DragonChessDescPanel:__delete()
    self.OnHideEvent:Fire()
    self:AssetClearAll()
end

function DragonChessDescPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dragon_chess_desc_panel))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t

    t:Find("Main").localPosition = Vector3(0, 0, -1500)
    self.gameObject:GetComponent(Canvas).overrideSorting = true

    t:Find("Main/Title/Text"):GetComponent(Text).text = TI18N("规则说明")
    t:Find("Main/Close"):GetComponent(Button).onClick:AddListener(function() self.model:CloseDescPanel() end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseDescPanel() end)

end

function DragonChessDescPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function DragonChessDescPanel:OnOpen()
    self:RemoveListeners()

end

function DragonChessDescPanel:OnHide()
    self:RemoveListeners()
end


function DragonChessDescPanel:RemoveListeners()

end

