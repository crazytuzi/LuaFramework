--作者:hzf
--01/15/2017 00:55:15
--功能:获取成长期

ChildrenGetBoyPanel = ChildrenGetBoyPanel or BaseClass(BasePanel)
function ChildrenGetBoyPanel:__init(model)
	self.model = model
    self.effectPath = "prefabs/effect/20014.unity3d"
	self.ShowEffet = "prefabs/effect/20267.unity3d"
	self.texture = AssetConfig.getpet_textures
	self.resList = {
		{file = AssetConfig.getchildrenafterbirth, type = AssetType.Main},
        {file = self.effectPath, type = AssetType.Main},
		{file = self.ShowEffet, type = AssetType.Main},
		{file = self.texture, type = AssetType.Dep},
        {file = AssetConfig.pet_textures, type = AssetType.Dep},
        {file = AssetConfig.getpetbtn, type = AssetType.Dep},
        {file = AssetConfig.getpethalo1, type = AssetType.Dep},
        {file = AssetConfig.getpetlight1, type = AssetType.Dep},
        {file = AssetConfig.childrentextures, type = AssetType.Dep},
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
    self.attrList = {
        [1] = {[1] = TI18N("成年物攻资质:"), [2] = TI18N("物攻资质:")},
        [2] = {[1] = TI18N("成年物防资质:"), [2] = TI18N("物防资质:")},
        [3] = {[1] = TI18N("成年生命资质:"), [2] = TI18N("生命资质:")},
        [4] = {[1] = TI18N("成年法力资质:"), [2] = TI18N("法力资质:")},
        [5] = {[1] = TI18N("成年速度资质:"), [2] = TI18N("速度资质:")},
    }
    self.last = false
end

function ChildrenGetBoyPanel:__delete()
    if self.previewComposite1 ~= nil then
        self.previewComposite1:DeleteMe()
        self.previewComposite1 = nil
    end

    if self.previewComposite2 ~= nil then
        self.previewComposite2:DeleteMe()
        self.previewComposite2 = nil
    end


	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenGetBoyPanel:OnHide()

end

function ChildrenGetBoyPanel:OnOpen()

end

function ChildrenGetBoyPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.getchildrenafterbirth))
	self.gameObject.name = "ChildrenGetBoyPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(DramaManager.Instance.model.dramaCanvas, self.gameObject)
	self.Panel = self.transform:Find("Panel")
	self.Main = self.transform:Find("Main")
	self.Halo = self.transform:Find("Main/Halo")
	self.Light = self.transform:Find("Main/Light")

    self.Halo.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpethalo1,"GetPetHalo1")
    self.Light.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetlight1,"GetPetLight1")


	self.Title = self.transform:Find("Main/Title")
	self.RawImage = self.transform:Find("Main/RawImage")
	self.Button = self.transform:Find("Main/Button"):GetComponent(Button)
    self.Button.transform:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.getpetbtn,"GetPetBtn")
	self.Button.onClick:AddListener(function()
        self:OnClickBtn()
	end)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effect.transform:SetParent(self.transform)
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect.transform.localScale = Vector3.one
    self.effect.transform.localPosition = Vector3(0, -211, -400)
    self.effect:SetActive(false)

	self.Text = self.transform:Find("Main/Button/Text"):GetComponent(Text)
	self.New = self.transform:Find("Main/New")
	self.Name = self.transform:Find("Main/Name"):GetComponent(Text)
	self.Head = self.transform:Find("Main/Head")
	self.Img = self.transform:Find("Main/Head/Img")
	self.Five = self.transform:Find("Main/Five")
    self.Text.text = TI18N("成年仪式")
	self.IconList = {}
	for i=1, 5 do
		self.IconList[i] = self.Five:Find(tostring(i))
		self.IconList[i].gameObject:SetActive(false)
	end
	self.data = self.openArgs
	self.sex = self.data.sex
	self.classes = self.data.classes
	self.base_id = self.data.base_id
	self.boyname = self.data.name
	self.setting = {
        name = "GetBoyPreview"
        ,orthographicSize = 0.45
        ,width = 341
        ,height = 341
        ,offsetY = -0.4
    }
    self.Main.gameObject:SetActive(false)
    self.Button.gameObject:SetActive(false)

    self.AttrItem = {}
    for i=1, 5 do
        local item = self.transform:Find("Main/Arttr/MaskCon/ScrollCon/Container/AttrItem"..tostring(i))
        self.AttrItem[i] = {}
        -- self.AttrItem[i].ImgIcon = item:Find("ImgIcon")
        self.AttrItem[i].AttrTxt = item:Find("AttrTxt"):GetComponent(Text)
        self.AttrItem[i].AttrTxt2 = item:Find("AttrTxt2"):GetComponent(Text)
    end
    self.growthicon = self.transform:Find("Main/Arttr/MaskCon/ScrollCon/Container/AttrItem6/icon"):GetComponent(Image)
    self.growthtext = self.transform:Find("Main/Arttr/MaskCon/ScrollCon/Container/AttrItem6/AttrTxt2"):GetComponent(Text)
    self.showEffectgo = GameObject.Instantiate(self:GetPrefab(self.ShowEffet))
    self.showEffectgo.transform:SetParent(self.Main)
    self.showEffectgo.transform.localScale = Vector3.one
    self.showEffectgo.transform.localPosition = Vector3(-154, 0, -400)
    Utils.ChangeLayersRecursively(self.showEffectgo.transform, "UI")
    self.showEffectgo:SetActive(false)

    BaseUtils.dump(self.data, "孩子属性？？")
    self.Button.gameObject:SetActive(false)
    self.effect:SetActive(false)
    self:LoadBaby()
end

function ChildrenGetBoyPanel:LoadBaby()
	local baby = DataUnit.data_unit[71159]
    if self.sex == 0 then
        baby = DataUnit.data_unit[71160]
    end
    self.Name.text = baby.name
    local modelData = {type = PreViewType.Pet, skinId = baby.skin, modelId = baby.res, animationId = baby.animation_id, scale = baby.scale/100, effects = {}}
    if self.previewComposite1 ~= nil then  self.previewComposite1:DeleteMe() end
	self.previewComposite1 = PreviewComposite.New(function(PreView) self:BabyLoaded(PreView) end, self.setting, modelData)
    -- self:LoadPreview(modelData)
end


function ChildrenGetBoyPanel:BabyLoaded(PreView)
	self.BabypreviewComp = PreView
    local image = PreView.rawImage
    image.transform:SetParent(self.RawImage.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3(0, 90, 0)
    -- self:SetPosition()
    self.BabypreviewComp.tpose:SetActive(false)
    self.BabypreviewComp.tpose.transform:Rotate(Vector3(0, -30, 0))
    -- self.RawImage:SetActive(true)
    self.Babyanimator = PreView.tpose:GetComponent(Animator)
    -- self.RawImage:GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    -- self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    self:LoadBoy()
end

function ChildrenGetBoyPanel:LoadBoy()
	local boyData = nil
	if self.base_id == nil then
		for k,v in pairs(DataChild.data_child) do
			if self.sex == v.sex and self.classes == v.classes then
				boyData = v
			end
		end
	else
		boyData = DataChild.data_child[self.base_id]
	end

	if self.boyname ~= nil and self.boyname ~= "" then
		self.Name.text = self.boyname
	else
		self.Name.text = boyData.name
	end

	if boyData ~= nil then
    	local modelData = {type = PreViewType.Pet, skinId = boyData.skin_id_0, modelId = boyData.model_id, animationId = boyData.animation_id, scale = 1, effects = {}}
        if self.previewComposite2 ~= nil then self.previewComposite2:DeleteMe() end
		self.previewComposite2 = PreviewComposite.New(function(PreView) self:BoyLoaded(PreView) end, self.setting, modelData)
	end
end

function ChildrenGetBoyPanel:BoyLoaded(PreView)
	self.BoypreviewComp = PreView
    local image = PreView.rawImage
    image.transform:SetParent(self.RawImage.transform)
    image.transform.localScale = Vector3.one
    image.transform.localPosition = Vector3(0, 90, 0)
    -- self:SetPosition()
    self.BoypreviewComp.tpose:SetActive(false)
    self.BoypreviewComp.tpose.transform:Rotate(Vector3(0, -30, 0))
    -- self.RawImage:SetActive(true)
    self.Boyanimator = PreView.tpose:GetComponent(Animator)
    -- self.RawImage:GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    -- self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:PlayAction() end)
    -- self:Start()
    self:ShowBaby()
    self:ShowBook()
    self:ShowBeginAttr()
end

function ChildrenGetBoyPanel:Start()
	self.Main.gameObject:SetActive(true)
	self.RawImage.gameObject:SetActive(true)
	self.BabypreviewComp.tpose:SetActive(true)
	-- self.BabypreviewComp:PlayAction("Idle1")
	self.Five.gameObject:SetActive(true)
	local index = 0
	LuaTimer.Add(0, 400, function()
		index = index + 1
		if index > 5 then
			Tween.Instance:RotateZ(self.Five.gameObject, -2080, 4, function() self:ShowBoy() end, LeanTweenType.linear)
			LuaTimer.Add(2000, function()
				Tween.Instance:Scale(self.Five.gameObject, Vector3.zero, 3, nil, LeanTweenType.easeOutExpo)
			end)
			return false
		end
		self.IconList[index].gameObject:SetActive(true)
	end)
end

function ChildrenGetBoyPanel:ShowBaby()
    self.Main.gameObject:SetActive(true)
    self.RawImage.gameObject:SetActive(true)
    self.BabypreviewComp.tpose:SetActive(true)
    self.Five.gameObject:SetActive(true)
end

function ChildrenGetBoyPanel:ShowBook()
    self.Five.gameObject:SetActive(true)

end

function ChildrenGetBoyPanel:ShowBeginAttr()
    self:GetGrowthIcon()
    local childBase = DataChild.data_child[self.base_id]
    for i=1, 5 do
        local ci = ChildrenEumn.PosToIndex[i]
        local val = 1
        local attr = 1
        if ci == 1 then
            val = self.data.childData.study_str
            attr = childBase.phy_aptitude
            -- assets = "AttrIcon4"
        elseif ci == 2 then
            val = self.data.childData.study_con
            attr = childBase.hp_aptitude
            -- assets = "AttrIcon1"
        elseif ci == 3 then
            val = self.data.childData.study_agi
            attr = childBase.aspd_aptitude
            -- assets = "AttrIcon3"
        elseif ci == 4 then
            val = self.data.childData.study_mag
            attr = childBase.magic_aptitude
            -- assets = "AttrIcon5"
        elseif ci == 5 then
            val = self.data.childData.study_end
            attr = childBase.pdef_aptitude
            -- assets = "AttrIcon6"
        end
        local min,max = ChildrenManager.Instance:GetAptRatio(val, attr)
        if val == 0 then
            -- self.fullNumText.text = TI18N("暂未学习")
        else
            self.AttrItem[i].AttrTxt.text = string.format(TI18N("成年%s资质:"), ChildrenEumn.StudyTypeName[ci])
            local fun1 = function(value)
                self.AttrItem[i].AttrTxt2.text = string.format(("%s~%s"), math.ceil(min*value), math.ceil(max*value))
            end
            local endfunc = function()
                self.Button.gameObject:SetActive(true)
                self.effect:SetActive(true)
            end
            if i ~= 5 then
                Tween.Instance:ValueChange(0, 1, 0.6, nil, LeanTweenType.linear, fun1)
            else
                Tween.Instance:ValueChange(0, 1, 0.6, endfunc, LeanTweenType.linear, fun1)
            end
        end
    end
end

function ChildrenGetBoyPanel:onClickGet()
    self.effect:SetActive(false)
    local index = 0
    local endfun = function()
        Tween.Instance:RotateZ(self.Five.gameObject, -2080, 2, function()  end, LeanTweenType.easeInQuad)
        Tween.Instance:Scale(self.Five.gameObject, Vector3.zero, 1, nil, LeanTweenType.easeInExpo)
        LuaTimer.Add(800, function()
            self:ShowBoy()
        end)
    end
    LuaTimer.Add(0, 200, function()
        index = index + 1
        if index > 5 then
            endfun()
            return false
        end
        self.IconList[index].gameObject:SetActive(true)
    end)
end

function ChildrenGetBoyPanel:ShowBoy()
    self.Button.gameObject:SetActive(false)
    self.showEffectgo:SetActive(true)
    LuaTimer.Add(500, function()
        self.BoypreviewComp.tpose:SetActive(true)
        self.BabypreviewComp.tpose:SetActive(false)
    end)
    self.Name.text = self.data.name
    self:ShowEndVal()
end

function ChildrenGetBoyPanel:ShowEndVal()
    local childBase = DataChild.data_child[self.base_id]
    for i=1, 5 do
        local ci = ChildrenEumn.PosToIndex[i]
        local val = 1
        local attr = 1
        if ci == 1 then
            val = self.data.childData.study_str
            attr = self.data.data.phy_aptitude
            -- assets = "AttrIcon4"
        elseif ci == 2 then
            val = self.data.childData.study_con
            attr = self.data.data.hp_aptitude
            -- assets = "AttrIcon1"
        elseif ci == 3 then
            val = self.data.childData.study_agi
            attr = self.data.data.aspd_aptitude
            -- assets = "AttrIcon3"
        elseif ci == 4 then
            val = self.data.childData.study_mag
            attr = self.data.data.magic_aptitude
            -- assets = "AttrIcon5"
        elseif ci == 5 then
            val = self.data.childData.study_end
            attr = self.data.data.pdef_aptitude
            -- assets = "AttrIcon6"
        end
        -- local min,max = ChildrenManager.Instance:GetAptRatio(val, attr)
        if attr == 0 then
            -- self.fullNumText.text = TI18N("暂未学习")
        else
            self.AttrItem[i].AttrTxt.text = string.format(TI18N("%s资质:"), ChildrenEumn.StudyTypeName[ci])
            local fun1 = function(value)
                self.AttrItem[i].AttrTxt2.text = string.format(("%s"), math.ceil(attr*value))
            end
            local endfunc = function()
                self.Text.text = TI18N("确 定")
                self.Button.gameObject:SetActive(false)
                self.effect:SetActive(false)
            end
            if i ~= 5 then
                Tween.Instance:ValueChange(0, 1, 0.9, nil, LeanTweenType.linear, fun1)
            else
                Tween.Instance:ValueChange(0, 1, 0.9, endfunc, LeanTweenType.linear, fun1)
            end
        end
    end
end

function ChildrenGetBoyPanel:GetGrowthIcon()
    local temp = {}
    table.insert(temp, {self.data.childData.study_str, TI18N("力")})
    table.insert(temp, {self.data.childData.study_con, TI18N("体")})
    table.insert(temp, {self.data.childData.study_agi, TI18N("敏")})
    table.insert(temp, {self.data.childData.study_mag, TI18N("智")})
    table.insert(temp, {self.data.childData.study_end, TI18N("德")})
    local minimum = 0
    local minstr = ""
    for i=1, 5 do
        local curr = temp[i][1]
        local minnum = 0
        for j=1,5 do
            if temp[j][1] >= curr then
                minnum = minnum + 1
            else
                break
            end
        end
        if minnum == 5 then
            minimum = curr
            minstr = temp[i][2]
            break
        end
    end
    -- BaseUtils.dump(temp, "排序结果")
    local sprite = nil
    if minimum <= 39 then
        sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth2")
    elseif minimum <= 59 then
        sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth3")
    elseif minimum <= 74 then
        sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth4")
    else
        sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures, "PetGrowth5")
    end
    self.growthicon.sprite = sprite
end

function ChildrenGetBoyPanel:OnClickBtn()
    if self.last then
        self.model:CloseGetBoyPanel()
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet, {4})
    else
        self:onClickGet()
        self.Button.gameObject:SetActive(false)
        LuaTimer.Add(4000, function()
            self.Button.gameObject:SetActive(true)
        end)
        self.last = true
    end
end
