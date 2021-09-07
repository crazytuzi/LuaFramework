-- ------------------------------
-- 孩子类型转换界面
-- hosr
-- ------------------------------
ChildrenChangeTypePanel = ChildrenChangeTypePanel or BaseClass(BasePanel)

function ChildrenChangeTypePanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.child_change_type, type = AssetType.Main}
	}

	self.previewList = {}
	self.btn1List = {}
	self.btn2List = {}
	self.btn2ValList = {}
	self.classesList = {}
	self.previewCompList = {}
	self.npcList = {
		{71152, 71154, 71156},
		{71151, 71153, 71155},
	}

    self.previewsetting = {
        name = "ChildrenChangeTypePanel"
        ,orthographicSize = 0.4
        ,width = 200
        ,height = 250
        ,offsetY = -0.2
    }

    self.typeList = {"物攻", "魔攻", "辅助"}
    self.detailList = {"狂剑、战弓", "魔导、月魂", "兽灵、秘言"}
    self.tips = {
    	TI18N("<color='#ffff00'>狂剑</color>\n擅长物理点杀，有极强大的爆发力\n\n<color='#ffff00'>职业技能：</color>\n<color='#00ff00'>破血锋刃、风暴连斩、死亡追击</color>"),
		TI18N("<color='#ffff00'>战弓</color>\n物理敏弓系，高速的物理群攻\n\n<color='#ffff00'>职业技能：</color>\n<color='#00ff00'>爆裂连射、陨落星群、蓄势一击</color>"),
		TI18N("<color='#ffff00'>魔导</color>\n魔法强攻系，精通法术群攻\n\n<color='#ffff00'>职业技能：</color>\n<color='#00ff00'>炎魔焚世、雷霆漩涡、湮灭风暴</color>"),
		TI18N("<color='#ffff00'>月魂</color>\n擅长魔法伤害，控场与攻击能力兼备\n\n<color='#ffff00'>职业技能：</color>\n<color='#00ff00'>月光惩罚、月火之怒、星月审判</color>"),
		TI18N("<color='#ffff00'>兽灵</color>\n强大的防御能力，守护队友以静制动\n\n<color='#ffff00'>职业技能：</color>\n<color='#00ff00'>龟之怒吼、龙威破甲、幻灵怒雷</color>"),
		TI18N("<color='#ffff00'>秘言</color>\n辅助控制系，担任封印控制与全队辅助\n\n<color='#ffff00'>职业技能：</color>\n<color='#00ff00'>回魂祷言、元素点燃、元素结界</color>")
	}
end

function ChildrenChangeTypePanel:__delete()
	for i,v in ipairs(self.previewCompList) do
		v:DeleteMe()
	end
	self.previewCompList = nil
end

function ChildrenChangeTypePanel:Close()
	self.model:CloseChangeType()
end

function ChildrenChangeTypePanel:OnShow()
	self.child = ChildrenManager.Instance:GetChildhood()
	self.sex = self.child.sex
	self.type = self.child.classes_type
	self:Update()
end

function ChildrenChangeTypePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.child_change_type))
	self.gameObject.name = "ChildrenChangeTypePanel"
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

	self.transform = self.gameObject.transform
	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
	self.transform:Find("Main/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

	for i = 1, 3 do
		local item = nil
		if i == 1 then
			item = self.transform:Find("Main/Item")
		else
			item = self.transform:Find("Main/Item" .. i)
		end
		table.insert(self.previewList, item:Find("Preview").gameObject)
		table.insert(self.btn1List, item:Find("Button1").gameObject)
		table.insert(self.btn2List, item:Find("Button2").gameObject)
		local index = i
		local btn = item:Find("Classes1"):GetComponent(Button)
		if btn == nil then
			btn = item:Find("Classes1").gameObject:AddComponent(Button)
		end
		btn.onClick:AddListener(function() self:ClickTips(index, 1) end)
		table.insert(self.classesList, btn)

		local btn = item:Find("Classes2"):GetComponent(Button)
		if btn == nil then
			btn = item:Find("Classes2").gameObject:AddComponent(Button)
		end
		btn.onClick:AddListener(function() self:ClickTips(index, 2) end)
		table.insert(self.classesList, btn)

		item:Find("Button2").gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickChange(index) end)
		table.insert(self.btn2ValList, item:Find("Button2/Val"):GetComponent(Text))
	end

	self:OnShow()
end

function ChildrenChangeTypePanel:ClickTips(index, subIndex)
	local i = (index - 1) * 2 + subIndex
	local str = self.tips[i]
	local btn = self.classesList[i]
	TipsManager.Instance:ShowText({gameObject = btn, itemData = {str}})
end

function ChildrenChangeTypePanel:Update()
	self:ShowPreview()
	self.btn2List[self.type]:SetActive(false)
end

function ChildrenChangeTypePanel:ShowPreview()
	local npcs = self.npcList[self.sex + 1]
	for i = 1, 3 do
		local index = i
	    local callback = function(composite)
		    self:SetRawImage(index, composite)
		end

		local npcData = DataUnit.data_unit[npcs[i]]
		local modelData = {type = PreViewType.Npc, skinId = npcData.skin, modelId = npcData.res, animationId = npcData.animation_id, scale = 1}
		local previewComp = self.previewCompList[i]
		if previewComp == nil then
	    	previewComp = PreviewComposite.New(callback, self.previewsetting, modelData)
	    	table.insert(self.previewCompList, previewComp)
	    else
	    	previewComp:Reload(modelData, callback)
		end
    	previewComp:Show()
	end
end

function ChildrenChangeTypePanel:SetRawImage(index, composite)
	local preview = self.previewList[index]
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    preview:SetActive(true)
    composite.tpose.transform:Rotate(Vector3(0, -30, 0))
end

function ChildrenChangeTypePanel:ClickChange(index)
	local func = function()
		ChildrenManager.Instance:Require18622(self.child.child_id, self.child.platform, self.child.zone_id, index)
		self:Close()
	end

    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = string.format(TI18N("将消耗50000{assets_2,90003}转换为%s子女，可选择%s职业，是否继续？"), self.typeList[index], self.detailList[index])
    data.sureLabel = TI18N("确定")
    data.cancelLabel = TI18N("取消")
    data.sureCallback = func
    NoticeManager.Instance:ConfirmTips(data)
end