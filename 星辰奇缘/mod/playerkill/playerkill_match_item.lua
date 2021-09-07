-- ---------------------------
-- 英雄擂台匹配展示项
-- hosr
-- ---------------------------
PlayerkillMatchItem = PlayerkillMatchItem or BaseClass()

function PlayerkillMatchItem:__init(transform, parent)
	self.transform = transform
	self.parent = parent
	self.gameObject = self.transform.gameObject

	self:InitPanel()
end

function PlayerkillMatchItem:__delete()
	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end

	if self.classes ~= nil then
		self.classes.sprite = nil
		self.classes = nil
	end
end

function PlayerkillMatchItem:InitPanel()
	self.preview = self.transform:Find("Preview").gameObject
	self.info = self.transform:Find("Info/Text"):GetComponent(Text)
	self.name = self.transform:Find("Name/Text"):GetComponent(Text)
	self.classes = self.transform:Find("Name/Classes"):GetComponent(Image)
end

function PlayerkillMatchItem:SetMyData()
	self.data = BaseUtils.copytab(PlayerkillManager.Instance.myData)
	local role = RoleManager.Instance.RoleData
	self.data.classes = role.classes
	self.data.sex = role.sex
	self.data.looks = {}
    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        self.data.looks = mySceneData.looks
    end
	self.name.text = role.name
	self.classes.gameObject:SetActive(true)
	self.classes.sprite = PreloadManager.Instance:GetClassesSprite(role.classes)

	local baseData = DataRencounter.data_info[self.data.rank_lev]
	self.info.text = string.format("%s-%s", baseData.rencounter, baseData.title)

	self:UpdatePreview()
end

function PlayerkillMatchItem:SetOtherData()
	self.data = {}
	self.data.classes = 0
	self.data.sex = 0
	self.data.looks = {}
	self.name.text = "?????"
	self.classes.gameObject:SetActive(false)
	self.info.text = "?????"
    self.preview:SetActive(false)
end

function PlayerkillMatchItem:SetData(data)
	self.data = data
	self.name.text = self.data.name
	self.classes.gameObject:SetActive(true)
	self.classes.sprite = PreloadManager.Instance:GetClassesSprite(self.data.classes)
	local baseData = DataRencounter.data_info[self.data.rank_lev]
	if baseData == nil then
		self.info.text = TI18N("未知")
	else
		self.info.text = string.format("%s-%s", baseData.rencounter, baseData.title)
	end

	self:UpdatePreview()
end

function PlayerkillMatchItem:UpdatePreview()
    local callback = function(composite)
        self:SetRawImage(composite)
    end
    local setting = {
        name = "PlayerkillMatchRole"
        ,orthographicSize = 0.6
        ,width = 300
        ,height = 300
        ,offsetY = -0.4
    }
    local modelData = {type = PreViewType.Role, classes = self.data.classes, sex = self.data.sex, looks = self.data.looks}
    if self.previewComp == nil then
        self.previewComp = PreviewComposite.New(callback, setting, modelData)
    else
        self.previewComp:Reload(modelData, callback)
    end
    self.previewComp:Show()
end

function PlayerkillMatchItem:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
end
