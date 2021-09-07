--作者:hzf
--17-4-10 下02时34分49秒
--功能:雪球大战熊孩子展示

SnowBallShowPanel = SnowBallShowPanel or BaseClass(BasePanel)
function SnowBallShowPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.snowballshowpanel, type = AssetType.Main},
		{file = AssetConfig.snowballicon, type = AssetType.Dep},
		{file = AssetConfig.rolebgstand, type = AssetType.Dep},
	}
	self.babyList = {
		[1] = {npcid = 71152, skill1 = 82160, skill2 = 82159},
		[2] = {npcid = 71156, skill1 = 82161, skill2 = 82162},
		[3] = {npcid = 71155, skill1 = 82163, skill2 = 82164},
	}
	self.hasInit = false
end

function SnowBallShowPanel:__delete()
	if self.itemList ~= nil then
		for k,v in pairs(self.itemList) do
			if v.Slot1 ~= nil then
				v.Slot1:DeleteMe()
			end
			if v.Slot2 ~= nil then
				v.Slot2:DeleteMe()
			end
		end
		self.itemList = nil
	end
	if self.previewComp ~= nil then
		for k,v in pairs(self.previewComp) do
			v:DeleteMe()
		end
		self.previewComp = nil
	end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function SnowBallShowPanel:OnHide()

end

function SnowBallShowPanel:OnOpen()

end

function SnowBallShowPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.snowballshowpanel))
	self.gameObject.name = "SnowBallShowPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self:OnClose()
	end)
	self.transform:SetAsFirstSibling()

	self.Title = self.transform:Find("MainCon/Title")
	self.Text = self.transform:Find("MainCon/Title/Text"):GetComponent(Text)
	self.Con = self.transform:Find("MainCon/Con")
	self.MaskScroll = self.transform:Find("MainCon/Con/MaskScroll")
	self.List = self.transform:Find("MainCon/Con/MaskScroll/List")
	self.transform:Find("MainCon/Attention/Text"):GetComponent(Text).text = TI18N("开始后将变成<color='#ffff00'>随机</color>一个熊孩子参加游戏")
	self.transform:Find("MainCon/Attention").anchoredPosition3D = Vector3(-146, -180, 0)
	self.itemList = {}
	for i,v in ipairs(self.babyList) do
		local tab = {}
		tab.transform = self.List:GetChild(i-1)
		if tab.transform == nil then
			local go = GameObject.Instantiate(self.List:GetChild(0).gameObject)
			tab.transform = go.transform
			go.transform:SetParent(self.List)
			go.transform.localScale = Vector3.one
			go.transform.anchorMax = Vector2(0, 0.5)
			go.transform.anchorMin = Vector2(0, 0.5)
			go.transform.pivot = Vector2(0, 0.5)
			go.transform.anchoredPosition3D = Vector2(182*(i-1), 0, 0)
		end
		tab.Preview = tab.transform:Find("Preview")
		tab.transform:Find("Preview/standbg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rolebgstand, "RoleStandBottom")
		tab.Name = tab.transform:Find("Name"):GetComponent(Text)
		tab.Slot1 = SkillSlot.New()
		tab.Slot2 = SkillSlot.New()
		tab.SkillName1 = tab.transform:Find("SkillNamebg1/SkillNameText1"):GetComponent(Text)
		tab.SkillName2 = tab.transform:Find("SkillNamebg2/SkillNameText2"):GetComponent(Text)
		UIUtils.AddUIChild(tab.transform:Find("Slot1").gameObject, tab.Slot1.gameObject)
		UIUtils.AddUIChild(tab.transform:Find("Slot2").gameObject, tab.Slot2.gameObject)
		self.itemList[i] = tab
	end

	self:InitList()
	self.CloseButton = self.transform:Find("CloseButton"):GetComponent(Button)
	self.CloseButton.onClick:AddListener(function()
		self:OnClose()
	end)
end

function SnowBallShowPanel:OnClose()
	self.model:CloseShowPanel()
end


function SnowBallShowPanel:InitList()
	for i,v in ipairs(self.babyList) do
		local data = self.babyList[i]
		local item = self.itemList[i]
		local cfgdata = DataUnit.data_unit[data.npcid]
		item.Name.text = cfgdata.name
		item.Slot1:SetAll(Skilltype.endlessskill, DataSkill.data_skill_other[data.skill1])
        item.Slot1:ShowName(true)
        item.Slot1:ShowLevel(false)
        item.SkillName1.text = DataSkill.data_skill_other[data.skill1].name
        item.Slot2:SetAll(Skilltype.endlessskill, DataSkill.data_skill_other[data.skill2])
        item.Slot2:ShowName(true)
        item.Slot2:ShowLevel(false)
        item.SkillName2.text = DataSkill.data_skill_other[data.skill2].name

        local unit_data = DataUnit.data_unit[data.npcid]
	    local setting = {
	        name = "SnowBallShow"
	        ,orthographicSize = 0.3
	        ,width = 180
	        ,height = 163
	        ,offsetY = -0.24
	        ,noMaterial = true
	    }
	    local modelData = {type = PreViewType.Npc, skinId = unit_data.skin, modelId = unit_data.res, animationId = unit_data.animation_id, scale = 1}
	    if self.previewComp == nil then
	    	self.previewComp = {}
	    end
        self.previewComp[i] = PreviewComposite.New(function(com) self:PreviewLoaded(com, i) end, setting, modelData)
	end
end


function SnowBallShowPanel:PreviewLoaded(composite, index)
    local rawImage = composite.rawImage
    rawImage.gameObject:SetActive(true)
    rawImage.transform:SetParent(self.itemList[index].Preview)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    composite.tpose.transform.localRotation = Quaternion.identity
    -- composite.tpose.transform:Rotate(Vector3(0, SceneConstData.UnitFaceTo.RightForward, 0))
end