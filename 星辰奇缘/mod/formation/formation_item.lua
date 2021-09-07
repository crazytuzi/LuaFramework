-- -------------------
-- 阵法左边想列表项
-- -------------------
FormationItem = FormationItem or BaseClass()

function FormationItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self.id = 0
	self.index = 0
    self.level_val = 1
    self.exp_val = 0
    self.has = false

	self:InitPanel()
end

function FormationItem:__delete()
end

function FormationItem:InitPanel()
	self.transform = self.gameObject.transform
    self.button = self.gameObject:GetComponent(Button)
    self.select = self.transform:Find("SelectImg").gameObject
    self.icon = self.transform:Find("IconImg"):GetComponent(Image)
    self.state = self.transform:Find("State").gameObject
    self.state_txt = self.transform:Find("State/Text"):GetComponent(Text)
    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.level = self.transform:Find("Level"):GetComponent(Text)
    self.red = self.transform:Find("Red").gameObject
    self.select:SetActive(false)
    self.icon.gameObject:SetActive(true)
    self.button.onClick:AddListener(function() self:ClickSelf() end)
end

function FormationItem:ClickSelf()
	self.parent:ClickLeft(self.id)
end

function FormationItem:SetData(protodata)
    local fdata = DataFormation.data_list[string.format("%s_%s", protodata.id, protodata.lev)]
	self.data = fdata
	self.id = protodata.id
	self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(protodata.id))
    self.name.text = fdata.name
    self.level.text = string.format(TI18N("%s级"), protodata.lev)
    self.level_val = protodata.lev
    self.exp_val = protodata.exp
    self.has = true
    if protodata.id == FormationManager.Instance.formationId then
        self.state:SetActive(true)
    else
        self.state:SetActive(false)
    end
    self:CanUp()
end

function FormationItem:SetNil(id)
    self.id = id
    local fdata = DataFormation.data_list[string.format("%s_%s", id, 1)]
    self.data = fdata
    self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.formation_icon, tostring(id))
    self.name.text = fdata.name
    self.level.text = TI18N("<color='#cc3333'>未学习</color>")
    self.state:SetActive(false)
    self.level_val = 1
    self.exp_val = 0
    self.has = false
    self:CanUp()
end

function FormationItem:CanUp()
    if FormationManager.Instance.enoughList[self.id] == true then
        self.red:SetActive(true)
        if self.has then
            self.level.text = TI18N("可提升")
        else
            self.level.text = TI18N("可学习")
        end
    else
        self.red:SetActive(false)
    end
end

function FormationItem:Select(bool)
	self.select:SetActive(bool)
end