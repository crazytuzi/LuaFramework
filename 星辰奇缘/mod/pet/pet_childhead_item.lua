-- -----------------------------
-- 子女头像
-- hosr
-- -----------------------------
PetChildHeadItem = PetChildHeadItem or BaseClass()

function PetChildHeadItem:__init(gameObject, parent, index)
	self.gameObject = gameObject
	self.parent = parent
	self.index = index

	self:InitPanel()
end

function PetChildHeadItem:__delete()
	if self.headImg ~= nil then
		self.headImg.sprite = nil
	end
	if self.classes ~= nil then
		self.classes.sprite = nil
	end
end

function PetChildHeadItem:InitPanel()
	self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickSelf() end)
	self.transform = self.gameObject.transform
	self.transform:SetParent(self.parent.container.transform)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero
	self.name = self.transform:Find("NameText"):GetComponent(Text)
	self.lev = self.transform:Find("LVText"):GetComponent(Text)
	self.levRect = self.lev.gameObject:GetComponent(RectTransform)
	self.headImg = self.transform:Find("Head_78/Head"):GetComponent(Image)
	self.headImgRect = self.headImg.gameObject:GetComponent(RectTransform)
	self.select = self.transform:Find("Select").gameObject
	self.fighting = self.transform:Find("Using").gameObject
	self.fighting:SetActive(false)
	self.classes = self.transform:Find("Classes"):GetComponent(Image)
	self.classesObj = self.classes.gameObject
	self.classesObj:SetActive(false)
	self.red = self.transform:Find("RedPointImage").gameObject
end

function PetChildHeadItem:SetData(data)
	if BaseUtils.isnull(self.gameObject) then
		return
	end
	self.data = data
	self.gameObject:SetActive(true)

	if self.data.stage == ChildrenEumn.Stage.Adult then
		self.baseData = DataChild.data_child[self.data.base_id]
		if self.baseData == nil then
			return
		end
		self.name.text = self.data.name
		self.lev.text = string.format(TI18N("等级:%s"), self.data.lev)
		self.headImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.childhead, string.format("%s%s", data.classes_type, data.sex))
		self.headImgRect.sizeDelta = Vector2(54, 54)
	elseif self.data.stage == ChildrenEumn.Stage.Fetus then
		self.name.text = string.format(TI18N("胎儿(孕育期)"))
		self.lev.text = string.format(TI18N("进度:%s/1000"), self.data.maturity)
		self.headImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.childhead, data.sex)
		self.headImgRect.sizeDelta = Vector2(54, 54)
	elseif self.data.stage == ChildrenEumn.Stage.Childhood then
		self.name.text = string.format(TI18N("%s(幼年期)"), self.data.name)
		self.lev.text = string.format(TI18N("进度:%s/100"), self.data.maturity)
		self.headImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.childhead, data.sex)
		self.headImgRect.sizeDelta = Vector2(54, 54)
	end

	if self.data.status == ChildrenEumn.Status.Follow then
		self.fighting:SetActive(true)
	else
		self.fighting:SetActive(false)
	end

	if self.data.classes == 0 then
		self.classesObj:SetActive(false)
		self.levRect.anchoredPosition = Vector3(30, -11, 0)
	else
		self.levRect.anchoredPosition = Vector3(56, -11, 0)
		self.classes.sprite = PreloadManager.Instance:GetClassesSprite(self.data.classes)
		self.classesObj:SetActive(true)
	end
end

function PetChildHeadItem:ClickSelf()
	if self.data == nil then
        if ChildrenManager.Instance:GetChildhood() ~= nil then
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_study_win)
        else
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_get_win)
        end
	else
		self:Select(true)
		self.parent:SelectOne(self, self.index)
	end
end

function PetChildHeadItem:Select(bool)
	if not BaseUtils.isnull(self.select) then
		self.select:SetActive(bool)
	end
end

function PetChildHeadItem:ShowAdd()
	self.data = nil
	if not BaseUtils.isnull(self.headImg) then
		self.headImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
		self.headImg:SetNativeSize()
	else
		return
	end
	self.name.text = ""
	self.lev.text = ""
	self.fighting:SetActive(false)
	self.classesObj:SetActive(false)
	self.select:SetActive(false)
	self.gameObject:SetActive(true)
end