-- 宠物炼化界面
-- ljh 20160923
PetArtificeWindow = PetArtificeWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function PetArtificeWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.petartificewindow
    self.name = "PetArtificeWindow"
    self.resList = {
        {file = AssetConfig.petartificewindow, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
    }

    -----------------------------------------
    self.mainPetData = nil
    self.subPetData = nil

	self.bar_list = {}
	self.bar_text_list = {}
	self.bar_slider_list = {}
	self.bar_slider2_list = {}

    self.sub_bar_list = {}
    self.sub_bar_text_list = {}
    self.sub_bar_slider_list = {}
    self.sub_bar_slider2_list = {}
    self.headLoaderList = {}
    -----------------------------------------
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self._Update = function() self:Update(true) end
    self._PetArtificeSuccess = function() self:PetArtificeSuccess() end
end

function PetArtificeWindow:__delete()
    self:OnHide()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end

    if self.headLoader2 ~= nil then
        self.headLoader2:DeleteMe()
        self.headLoader2 = nil
    end


    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
    self:ClearDepAsset()
end

function PetArtificeWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petartificewindow))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:Find("Main")

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.okButton = self.mainTransform:FindChild("OkButton").gameObject
    self.okButton:GetComponent(Button).onClick:AddListener(function() self:okButtonClick() end)

    self.mainHead = self.mainTransform:FindChild("MainHead/Head")
    self.mainNameText = self.mainTransform:FindChild("MainNameText"):GetComponent(Text)
    self.mainLevelText = self.mainTransform:FindChild("MainLevelText"):GetComponent(Text)
    self.mainChangeButton = self.mainTransform:FindChild("MainChangeButton")
    self.mainTipsText = self.mainTransform:FindChild("MainTipsText"):GetComponent(Text)

    self.subHead = self.mainTransform:FindChild("SubHead/Head")
    self.subNameText = self.mainTransform:FindChild("SubNameText"):GetComponent(Text)
    self.subLevelText = self.mainTransform:FindChild("SubLevelText"):GetComponent(Text)
    self.subChangeButton = self.mainTransform:FindChild("SubChangeButton")
    self.subTipsText = self.mainTransform:FindChild("SubTipsText"):GetComponent(Text)

    self.mainTransform:FindChild("MainHead"):GetComponent(Button).onClick:AddListener(
        function() self:OpenSelectMainPet() end)
    self.mainChangeButton:GetComponent(Button).onClick:AddListener(
        function() self:OpenSelectMainPet() end)
    self.mainTransform:FindChild("SubHead"):GetComponent(Button).onClick:AddListener(
        function() self:OpenSelectSubPet() end)
    self.subChangeButton:GetComponent(Button).onClick:AddListener(
        function() self:OpenSelectSubPet() end)

    local mainPanel = self.mainTransform:FindChild("MainPanel")
    self.expSlider = mainPanel:FindChild("ExpGroup/HappySlider"):GetComponent(Slider)
    self.expSlider2 = mainPanel:FindChild("ExpGroup/HappySlider2"):GetComponent(Slider)
    self.expText = mainPanel:FindChild("ExpGroup/HappyText"):GetComponent(Text)

    self.happyText = mainPanel:FindChild("HappyGroup/HappyText"):GetComponent(Text)

    for i = 1, 5 do
        local bar = mainPanel:FindChild("WashItem"..i)
        table.insert(self.bar_list, bar.gameObject)

        table.insert(self.bar_text_list, bar:FindChild("ValueSlider/Text"):GetComponent(Text))
        table.insert(self.bar_slider_list, bar:FindChild("ValueSlider/Slider"):GetComponent(Slider))
        table.insert(self.bar_slider2_list, bar:FindChild("ValueSlider/Slider2"):GetComponent(Slider))
    end

    local subPanel = self.mainTransform:FindChild("SubPanel")
    self.sub_expSlider = subPanel:FindChild("ExpGroup/HappySlider"):GetComponent(Slider)
    self.sub_expSlider2 = subPanel:FindChild("ExpGroup/HappySlider2"):GetComponent(Slider)
    self.sub_expText = subPanel:FindChild("ExpGroup/HappyText"):GetComponent(Text)

    self.sub_happyText = subPanel:FindChild("HappyGroup/HappyText"):GetComponent(Text)

    for i = 1, 5 do
        local bar = subPanel:FindChild("WashItem"..i)
        table.insert(self.sub_bar_list, bar.gameObject)

        table.insert(self.sub_bar_text_list, bar:FindChild("ValueSlider/Text"):GetComponent(Text))
        table.insert(self.sub_bar_slider_list, bar:FindChild("ValueSlider/Slider"):GetComponent(Slider))
        table.insert(self.sub_bar_slider2_list, bar:FindChild("ValueSlider/Slider2"):GetComponent(Slider))
    end

    self:OnShow()
end

function PetArtificeWindow:Close()
    self:OnHide()

    WindowManager.Instance:CloseWindow(self)
    -- self.model:ClosePetArtificeWindow()
end

function PetArtificeWindow:OnShow()
	if self.openArgs ~= nil and #self.openArgs > 0 then
        self.subPetData = self.openArgs[1]
    end

    self:Update(false)
    PetManager.Instance.OnPetArtificeUpdate:Add(self._PetArtificeSuccess)
    PetManager.Instance.OnPetUpdate:Add(self._Update)
end

function PetArtificeWindow:OnHide()
    PetManager.Instance.OnPetArtificeUpdate:Remove(self._PetArtificeSuccess)
    PetManager.Instance.OnPetUpdate:Remove(self._Update)
end

function PetArtificeWindow:Update(tween)
    self:Update_head()
    self:Update_info(tween)
    self:Update_sub_info()
end

function PetArtificeWindow:Update_head()
	if self.mainPetData == nil then

		self.mainHead:GetComponent(Image).sprite
	            = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
	    self.mainHead:GetComponent(Image):SetNativeSize()



	    self.mainNameText.text = TI18N("请选择主宠")
        self.mainLevelText.text = ""
        self.mainChangeButton.gameObject:SetActive(false)
        self.mainTipsText.gameObject:SetActive(true)
    else
		local headId = tostring(self.mainPetData.base.head_id)
         if self.headLoader2 == nil then
            self.headLoader2 = SingleIconLoader.New(self.mainHead.gameObject)
        end
        self.headLoader2:SetSprite(SingleIconType.Pet,headId)
	    -- self.mainHead:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
	    self.mainHead:GetComponent(Image).rectTransform.sizeDelta = Vector2(64, 64)

	    self.mainNameText.text = self.mainPetData.name
        self.mainLevelText.text = string.format("Lv.%s", self.mainPetData.lev)
        self.mainChangeButton.gameObject:SetActive(true)
        self.mainTipsText.gameObject:SetActive(false)
    end

    if self.subPetData == nil then
    	self.subHead:GetComponent(Image).sprite
	            = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "BidAddImage")
	    self.subHead:GetComponent(Image):SetNativeSize()

	    self.subNameText.text = TI18N("请选择副宠")
        self.subLevelText.text = ""
        self.subChangeButton.gameObject:SetActive(false)
        self.subTipsText.gameObject:SetActive(true)
    else
		local headId = tostring(self.subPetData.base.head_id)
         if self.headLoader == nil then
            self.headLoader = SingleIconLoader.New(self.subHead:GetComponent(Image).gameObject)
        end
        self.headLoader:SetSprite(SingleIconType.Pet, headId)

	    -- self.subHead:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
	    self.subHead:GetComponent(Image).rectTransform.sizeDelta = Vector2(64, 64)

	    self.subNameText.text = self.subPetData.name
        self.subLevelText.text = string.format("Lv.%s", self.subPetData.lev)
        self.subChangeButton.gameObject:SetActive(true)
        self.subTipsText.gameObject:SetActive(false)
    end
end

function PetArtificeWindow:Update_info(tween)
	if self.mainPetData == nil then
        self.expSlider.value = 0
        self.expSlider2.value = 0
        self.expText.text = TI18N("请放入宠物")
        self.happyText.text = TI18N("请放入宠物")

		for i = 1, 5 do
			self.bar_text_list[i].text = "--"
			self.bar_slider_list[i].value = 0
			self.bar_slider2_list[i].value = 0
	    end
	else
        self.mainPetData = self.model:getpet_byid(self.mainPetData.id)

		local petData = self.mainPetData
		if self.subPetData == nil then
            local exp = petData.exp
            if exp > 9999 then
                exp = string.format("%s万", math.floor(exp/10000 + 0.5))
            end
            local max_exp = petData.max_exp
            if max_exp > 9999 then
                max_exp = string.format("%s万", math.floor(max_exp/10000 + 0.5))
            end
            self.expText.text = string.format("%s/%s", exp, max_exp)
            self.expSlider2.value = 0
            if petData.genre == 2 or petData.genre == 4 then
                self.happyText.text = string.format("<color='#ffff00'>%s</color>", TI18N("永生"))
            else
                self.happyText.text = string.format("<color='#ffff00'>%s</color>", petData.happy)
            end

			if (petData.phy_aptitude / petData.base.phy_aptitude) > 0.97 then
    		    self.bar_text_list[1].text = string.format("<color='#ffffff'>%s/%s</color>", petData.phy_aptitude, petData.max_phy_aptitude)
    		else
    		    self.bar_text_list[1].text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
    		end
    		if (petData.pdef_aptitude / petData.base.pdef_aptitude) > 0.97 then
    		    self.bar_text_list[2].text = string.format("<color='#ffffff'>%s/%s</color>", petData.pdef_aptitude, petData.max_pdef_aptitude)
    		else
    		    self.bar_text_list[2].text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
    		end
    		if (petData.hp_aptitude / petData.base.hp_aptitude) > 0.97 then
    		    self.bar_text_list[3].text = string.format("<color='#ffffff'>%s/%s</color>", petData.hp_aptitude, petData.max_hp_aptitude)
    		else
    		    self.bar_text_list[3].text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
    		end
    		if (petData.magic_aptitude / petData.base.magic_aptitude) > 0.97 then
    		    self.bar_text_list[4].text = string.format("<color='#ffffff'>%s/%s</color>", petData.magic_aptitude, petData.max_magic_aptitude)
    		else
    		    self.bar_text_list[4].text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
    		end
    		if (petData.aspd_aptitude / petData.base.aspd_aptitude) > 0.97 then
    		    self.bar_text_list[5].text = string.format("<color='#ffffff'>%s/%s</color>", petData.aspd_aptitude, petData.max_aspd_aptitude)
    		else
    		    self.bar_text_list[5].text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)
    		end

            for i = 1, 5 do
			    self.bar_slider2_list[1].value = 0
            end
		else
            local exp = petData.exp
            if exp > 9999 then
                exp = string.format("%s万", math.floor(exp/10000 + 0.5))
            end
            local max_exp = petData.max_exp
            if max_exp > 9999 then
                max_exp = string.format("%s万", math.floor(max_exp/10000 + 0.5))
            end
            local addExp = self:GetExp()
            if addExp > 9999 then
                addExp = string.format("%s万", math.floor(addExp/10000 + 0.5))
            end
            self.expText.text = string.format("%s<color='#ffff00'>+%s</color>/%s", exp, addExp, max_exp)
            self.expSlider2.value = (petData.exp + self:GetExp()) / petData.max_exp
            if petData.genre == 2 or petData.genre == 4 then
                self.happyText.text = string.format("<color='#ffff00'>%s</color>", TI18N("永生"))
            else
                self.happyText.text = string.format("%s<color='#ffff00'>+%s</color>", petData.happy, self:GetHappy())
            end

            local aptiudeList = self:GetAptiude()
			if (petData.phy_aptitude / petData.base.phy_aptitude) > 0.97 then
                self.bar_text_list[1].text = string.format("<color='#ffffff'>%s<color='#ffff00'>+%s</color>/%s</color>", petData.phy_aptitude, aptiudeList[1], petData.max_phy_aptitude)
            else
                self.bar_text_list[1].text = string.format("%s<color='#ffff00'>+%s</color>/%s", petData.phy_aptitude, aptiudeList[1], petData.max_phy_aptitude)
            end
            if (petData.pdef_aptitude / petData.base.pdef_aptitude) > 0.97 then
                self.bar_text_list[2].text = string.format("<color='#ffffff'>%s<color='#ffff00'>+%s</color>/%s</color>", petData.pdef_aptitude, aptiudeList[2], petData.max_pdef_aptitude)
            else
                self.bar_text_list[2].text = string.format("%s<color='#ffff00'>+%s</color>/%s", petData.pdef_aptitude, aptiudeList[2], petData.max_pdef_aptitude)
            end
            if (petData.hp_aptitude / petData.base.hp_aptitude) > 0.97 then
                self.bar_text_list[3].text = string.format("<color='#ffffff'>%s<color='#ffff00'>+%s</color>/%s</color>", petData.hp_aptitude, aptiudeList[3], petData.max_hp_aptitude)
            else
                self.bar_text_list[3].text = string.format("%s<color='#ffff00'>+%s</color>/%s", petData.hp_aptitude, aptiudeList[3], petData.max_hp_aptitude)
            end
            if (petData.magic_aptitude / petData.base.magic_aptitude) > 0.97 then
                self.bar_text_list[4].text = string.format("<color='#ffffff'>%s<color='#ffff00'>+%s</color>/%s</color>", petData.magic_aptitude, aptiudeList[4], petData.max_magic_aptitude)
            else
                self.bar_text_list[4].text = string.format("%s<color='#ffff00'>+%s</color>/%s", petData.magic_aptitude, aptiudeList[4], petData.max_magic_aptitude)
            end
            if (petData.aspd_aptitude / petData.base.aspd_aptitude) > 0.97 then
                self.bar_text_list[5].text = string.format("<color='#ffffff'>%s<color='#ffff00'>+%s</color>/%s</color>", petData.aspd_aptitude, aptiudeList[5], petData.max_aspd_aptitude)
            else
                self.bar_text_list[5].text = string.format("%s<color='#ffff00'>+%s</color>/%s", petData.aspd_aptitude, aptiudeList[5], petData.max_aspd_aptitude)
            end

            self.bar_slider2_list[1].value = (aptiudeList[1] + petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider2_list[2].value = (aptiudeList[2] + petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider2_list[3].value = (aptiudeList[3] + petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider2_list[4].value = (aptiudeList[4] + petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider2_list[5].value = (aptiudeList[5] + petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2
		end

		if tween then
            local expSlider = self.expSlider
            BaseUtils.tweenDoSlider(expSlider, expSlider.value, petData.exp / petData.max_exp, 0.3)

            local slider1 = self.bar_slider_list[1]
            BaseUtils.tweenDoSlider(slider1, slider1.value, (petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2, 0.3)
            local slider2 = self.bar_slider_list[2]
            BaseUtils.tweenDoSlider(slider2, slider2.value, (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2, 0.3)
            local slider3 = self.bar_slider_list[3]
            BaseUtils.tweenDoSlider(slider3, slider3.value, (petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2, 0.3)
            local slider4 = self.bar_slider_list[4]
            BaseUtils.tweenDoSlider(slider4, slider4.value, (petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2, 0.3)
            local slider5 = self.bar_slider_list[5]
            BaseUtils.tweenDoSlider(slider5, slider5.value, (petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2, 0.3)
		else
            self.expSlider.value = petData.exp / petData.max_exp

			self.bar_slider_list[1].value = (petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider_list[2].value = (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider_list[3].value = (petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider_list[4].value = (petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2
            self.bar_slider_list[5].value = (petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2

            for i = 1, 5 do
                self.sub_bar_slider2_list[1].value = 0
            end
		end
	end
end

function PetArtificeWindow:Update_sub_info()
    if self.subPetData == nil then
        self.sub_expSlider.value = 0
        self.sub_expSlider2.value = 0
        self.sub_expText.text = TI18N("请放入宠物")
        self.sub_happyText.text = TI18N("请放入宠物")

        for i = 1, 5 do
            self.sub_bar_text_list[i].text = "--"
            self.sub_bar_slider_list[i].value = 0
            self.sub_bar_slider2_list[i].value = 0
        end
    else
        local petData = self.subPetData
        local exp = petData.exp
        if exp > 9999 then
            exp = string.format("%s万", math.floor(exp/10000 + 0.5))
        end
        local max_exp = petData.max_exp
        if max_exp > 9999 then
            max_exp = string.format("%s万", math.floor(max_exp/10000 + 0.5))
        end
        self.sub_expText.text = string.format("%s/%s", exp, max_exp)
        self.sub_expSlider.value = petData.exp / petData.max_exp
        if petData.genre == 2 or petData.genre == 4 then
            self.sub_happyText.text = string.format("<color='#ffff00'>%s</color>", TI18N("永生"))
        else
            self.sub_happyText.text = string.format("%s", petData.happy)
        end

        if (petData.phy_aptitude / petData.base.phy_aptitude) > 0.97 then
            self.sub_bar_text_list[1].text = string.format("<color='#ffffff'>%s/%s</color>", petData.phy_aptitude, petData.max_phy_aptitude)
        else
            self.sub_bar_text_list[1].text = string.format("%s/%s", petData.phy_aptitude, petData.max_phy_aptitude)
        end
        if (petData.pdef_aptitude / petData.base.pdef_aptitude) > 0.97 then
            self.sub_bar_text_list[2].text = string.format("<color='#ffffff'>%s/%s</color>", petData.pdef_aptitude, petData.max_pdef_aptitude)
        else
            self.sub_bar_text_list[2].text = string.format("%s/%s", petData.pdef_aptitude, petData.max_pdef_aptitude)
        end
        if (petData.hp_aptitude / petData.base.hp_aptitude) > 0.97 then
            self.sub_bar_text_list[3].text = string.format("<color='#ffffff'>%s/%s</color>", petData.hp_aptitude, petData.max_hp_aptitude)
        else
            self.sub_bar_text_list[3].text = string.format("%s/%s", petData.hp_aptitude, petData.max_hp_aptitude)
        end
        if (petData.magic_aptitude / petData.base.magic_aptitude) > 0.97 then
            self.sub_bar_text_list[4].text = string.format("<color='#ffffff'>%s/%s</color>", petData.magic_aptitude, petData.max_magic_aptitude)
        else
            self.sub_bar_text_list[4].text = string.format("%s/%s", petData.magic_aptitude, petData.max_magic_aptitude)
        end
        if (petData.aspd_aptitude / petData.base.aspd_aptitude) > 0.97 then
            self.sub_bar_text_list[5].text = string.format("<color='#ffffff'>%s/%s</color>", petData.aspd_aptitude, petData.max_aspd_aptitude)
        else
            self.sub_bar_text_list[5].text = string.format("%s/%s", petData.aspd_aptitude, petData.max_aspd_aptitude)
        end

        self.sub_bar_slider_list[1].value = (petData.phy_aptitude - petData.base.phy_aptitude * 0.8) / (petData.max_phy_aptitude - petData.base.phy_aptitude * 0.8) * 0.8 + 0.2
        self.sub_bar_slider_list[2].value = (petData.pdef_aptitude - petData.base.pdef_aptitude * 0.8) / (petData.max_pdef_aptitude - petData.base.pdef_aptitude * 0.8) * 0.8 + 0.2
        self.sub_bar_slider_list[3].value = (petData.hp_aptitude - petData.base.hp_aptitude * 0.8) / (petData.max_hp_aptitude - petData.base.hp_aptitude * 0.8) * 0.8 + 0.2
        self.sub_bar_slider_list[4].value = (petData.magic_aptitude - petData.base.magic_aptitude * 0.8) / (petData.max_magic_aptitude - petData.base.magic_aptitude * 0.8) * 0.8 + 0.2
        self.sub_bar_slider_list[5].value = (petData.aspd_aptitude - petData.base.aspd_aptitude * 0.8) / (petData.max_aspd_aptitude- petData.base.aspd_aptitude * 0.8) * 0.8 + 0.2

        for i = 1, 5 do
            self.sub_bar_slider2_list[1].value = 0
        end
    end
end

function PetArtificeWindow:okButtonClick()
    if self.mainPetData ~= nil and self.subPetData ~= nil then
        local confirmText = string.format(TI18N("确定要炼化<color='#ffff00'>[%s]</color>吗？炼化之后主宠将获得能力提升，副宠将彻底<color='#ffff00'>消失</color>"), self.subPetData.name)
        local fullMark = 0
        for i=1,5 do
            if self.bar_slider_list[i].value >= 1 then
                fullMark = fullMark + 1
            end
        end
        if fullMark == 5 then
            confirmText = TI18N("当前选择的主宠<color='#ffff00'>资质已满</color>，炼化将无法增加资质。确定要进行炼化吗？")
        elseif self.mainPetData.lev - RoleManager.Instance.RoleData.lev >= 5 then
            confirmText = TI18N("当前选择的主宠<color='#ffff00'>等级已达上限</color>，炼化将无法增加经验。确定要进行炼化吗？")
        end
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = confirmText
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() PetManager.Instance:Send10548(self.mainPetData.id, self.subPetData.id) end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function PetArtificeWindow:selectMainPet(data)
    if data ~= nil then
        -- if data.lock == 1 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("该宠物已锁定，无法进行炼化"))
        -- elseif data.status == 1 then
        --     NoticeManager.Instance:FloatTipsByString(TI18N("不能选择出战宠物"))
        -- else
            if data == self.subPetData then
            NoticeManager.Instance:FloatTipsByString(TI18N("不能与副宠相同"))
        elseif data.lev < 50 then
            NoticeManager.Instance:FloatTipsByString(TI18N("50级以上宠物才能进行炼化"))
        else
            self.mainPetData = data
            self:SendPetArtifice()
            self:Update(false)

            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("切换成功，当前主宠物切换为<color=#00FF00>%s</color>"), tostring(data.name)))
        end
    end
end

function PetArtificeWindow:selectSubPet(data)
    if data ~= nil then
        if data.lock == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("该宠物已锁定，无法进行炼化"))
        elseif data.genre == 2 or data.genre == 4 then
            NoticeManager.Instance:FloatTipsByString(TI18N("神兽、珍兽无法做为<color='#ffff00'>副宠</color>进行炼化"))
        elseif data.status == 1 then
            NoticeManager.Instance:FloatTipsByString(TI18N("不能选择出战宠物"))
        elseif data == self.mainPetData then
            NoticeManager.Instance:FloatTipsByString(TI18N("不能与主宠相同"))
        elseif data.lev < 50 then
            NoticeManager.Instance:FloatTipsByString(TI18N("50级以上宠物才能进行炼化"))
        else
            self.subPetData = data
            self:SendPetArtifice()
            self:Update(false)


            NoticeManager.Instance:FloatTipsByString(string.format(TI18N("切换成功，当前副宠物切换为<color=#00FF00>%s</color>"), tostring(data.name)))
        end
    end
end

function PetArtificeWindow:PetArtificeSuccess()
    self.model.cur_petdata = self.mainPetData
    self.subPetData = nil

    local fun = function(effectView)
        local effectObject = effectView.gameObject

        self.washEffect = effectObject

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        effectObject.transform:SetParent(self.mainHead)
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, -400)
        effectObject.transform.localRotation = Quaternion.identity
    end
    BaseEffectView.New({effectId = 20049, time = nil, callback = fun})
end

function PetArtificeWindow:GetExp()
    if self.subPetData ~= nil then
        local data_pet_artifice_exp = DataPet.data_pet_artifice_exp[self.mainPetData.lev]
        local data_pet_artifice_exp_sub = DataPet.data_pet_artifice_exp_sub[self.subPetData.lev]
        if data_pet_artifice_exp ~= nil and data_pet_artifice_exp_sub ~= nil then
            return data_pet_artifice_exp.ratio / 1000 * data_pet_artifice_exp_sub.ratio
        else
            return 0
        end
    else
        return 0
    end
end

function PetArtificeWindow:GetHappy()
    if self.subPetData ~= nil then
        return math.floor(math.max(self.subPetData.talent - 2500, 0) * 0.4 + 100 + 0.5)
    else
        return 0
    end
end

function PetArtificeWindow:GetAptiude()
    if self.subPetData ~= nil then
        if false then -- 屏蔽，数据由服务端发来
            local lev_args = 1
            for i=1, #DataPet.data_pet_artifice_lev do
                local data_pet_artifice_lev = DataPet.data_pet_artifice_lev[i]
                if self.subPetData.lev >= data_pet_artifice_lev.min_lev and self.subPetData.lev < data_pet_artifice_lev.max_lev then
                    lev_args = data_pet_artifice_lev.args / 1000
                    break
                end
            end

            local proportion = { 1, 1, 1, 1, 1 }
            proportion[1] = math.floor(self.subPetData.phy_aptitude / self.mainPetData.phy_aptitude * 1000 + 0.5)
            proportion[2] = math.floor(self.subPetData.pdef_aptitude / self.mainPetData.pdef_aptitude * 1000 + 0.5)
            proportion[3] = math.floor(self.subPetData.hp_aptitude / self.mainPetData.hp_aptitude * 1000 + 0.5)
            proportion[4] = math.floor(self.subPetData.magic_aptitude / self.mainPetData.magic_aptitude * 1000 + 0.5)
            proportion[5] = math.floor(self.subPetData.aspd_aptitude / self.mainPetData.aspd_aptitude * 1000 + 0.5)

            local apt_args = { 1, 1, 1, 1, 1 }
            for i=1, 5 do
                for j=1, #DataPet.data_pet_artifice_apt do
                    local data_pet_artifice_apt = DataPet.data_pet_artifice_apt[j]
                    if proportion[i] >= data_pet_artifice_apt.min_apt and proportion[i] < data_pet_artifice_apt.max_apt then
                        apt_args[i] = data_pet_artifice_apt.args / 1000
                        break
                    end
                end
            end

            local num = { lev_args * apt_args[1], lev_args * apt_args[2], lev_args * apt_args[3], lev_args * apt_args[4], lev_args * apt_args[5] }
            local quality_add = {}

            local percent = 1
            local quality_add = { 0, 0, 0, 0, 0 }
            local min_aptitude = 0
            local ceil_num = 0
            local petData = self.mainPetData
            local basedata = self.mainPetData.base
    -- print("------")
    -- print(num[1])
            --物攻
            local phy_aptitude = petData.phy_aptitude
            min_aptitude = basedata.phy_aptitude * 0.8
            ceil_num = math.ceil(num[1])
            for i = 1, ceil_num do
                if phy_aptitude > petData.max_phy_aptitude then
                    phy_aptitude = petData.max_phy_aptitude
                end
                percent = (phy_aptitude - min_aptitude) / (petData.max_phy_aptitude - min_aptitude)
                if percent < 0 then percent = 0 end
                local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
                local temp_add = (petData.max_phy_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
                temp_add = math.floor(temp_add + 0.5)
                if temp_add < 5 then temp_add = 5 end
                -- print(petData.max_phy_aptitude)
                -- print(min_aptitude)
                -- print(pet_quality_data.apt_ratio)
                -- print(pet_quality_data.apt_base)
                -- print(temp_add)
                -- if i == ceil_num and i - num[1] > 0 then
                --     temp_add = math.floor((num[1] - math.floor(num[1])) * temp_add + 0.5)
                -- end
                phy_aptitude = phy_aptitude + temp_add
                quality_add[1] = quality_add[1] + temp_add
            end

            if petData.phy_aptitude + quality_add[1] >= petData.max_phy_aptitude then
                quality_add[1] = petData.max_phy_aptitude - petData.phy_aptitude
            end
    -- print("------")
            --物防
            local pdef_aptitude = petData.pdef_aptitude
            min_aptitude = basedata.pdef_aptitude * 0.8
            ceil_num = math.ceil(num[2])
            for i = 1, ceil_num do
                if pdef_aptitude > petData.max_pdef_aptitude then
                    pdef_aptitude = petData.max_pdef_aptitude
                end
                percent = (pdef_aptitude - min_aptitude) / (petData.max_pdef_aptitude - min_aptitude)
                if percent < 0 then percent = 0 end
                local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
                local temp_add = (petData.max_pdef_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
                temp_add = math.floor(temp_add + 0.5)
                if temp_add < 5 then temp_add = 5 end
                -- if i == ceil_num and i - num[2] > 0 then
                --     temp_add = math.floor((num[2] - math.floor(num[2])) * temp_add + 0.5)
                -- end
                pdef_aptitude = pdef_aptitude + temp_add
                quality_add[2] = quality_add[2] + temp_add
            end

            if petData.pdef_aptitude + quality_add[2] >= petData.max_pdef_aptitude then
                quality_add[2] = petData.max_pdef_aptitude - petData.pdef_aptitude
            end

            --生命
            local hp_aptitude = petData.hp_aptitude
            min_aptitude = basedata.hp_aptitude * 0.8
            ceil_num = math.ceil(num[3])
            for i = 1, ceil_num do
                if hp_aptitude > petData.max_hp_aptitude then
                    hp_aptitude = petData.max_hp_aptitude
                end
                percent = (hp_aptitude - min_aptitude) / (petData.max_hp_aptitude - min_aptitude)
                if percent < 0 then percent = 0 end
                local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
                local temp_add = (petData.max_hp_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
                temp_add = math.floor(temp_add + 0.5)
                if temp_add < 5 then temp_add = 5 end
                -- if i == ceil_num and i - num[3] > 0 then
                --     temp_add = math.floor((num[3] - math.floor(num[3])) * temp_add + 0.5)
                -- end
                hp_aptitude = hp_aptitude + temp_add
                quality_add[3] = quality_add[3] + temp_add
            end

            if petData.hp_aptitude + quality_add[3] >= petData.max_hp_aptitude then
                quality_add[3] = petData.max_hp_aptitude - petData.hp_aptitude
            end

            --法力
            local magic_aptitude = petData.magic_aptitude
            min_aptitude = basedata.magic_aptitude * 0.8
            ceil_num = math.ceil(num[4])
            for i = 1, ceil_num do
                if magic_aptitude > petData.max_magic_aptitude then
                    magic_aptitude = petData.max_magic_aptitude
                end
                percent = (magic_aptitude - min_aptitude) / (petData.max_magic_aptitude - min_aptitude)
                if percent < 0 then percent = 0 end
                local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
                local temp_add = (petData.max_magic_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
                temp_add = math.floor(temp_add + 0.5)
                if temp_add < 5 then temp_add = 5 end

                -- if i == ceil_num and i - num[4] > 0 then
                --     temp_add = math.floor((num[4] - math.floor(num[4])) * temp_add + 0.5)
                -- end
                magic_aptitude = magic_aptitude + temp_add
                quality_add[4] = quality_add[4] + temp_add
            end

            if petData.magic_aptitude + quality_add[4] >= petData.max_magic_aptitude then
                quality_add[4] = petData.max_magic_aptitude - petData.magic_aptitude
            end

            --速度
            local aspd_aptitude = petData.aspd_aptitude
            min_aptitude = basedata.aspd_aptitude * 0.8
            ceil_num = math.ceil(num[5])
            for i = 1, ceil_num do
                if aspd_aptitude > petData.max_aspd_aptitude then
                    aspd_aptitude = petData.max_aspd_aptitude
                end
                percent = (aspd_aptitude - min_aptitude) / (petData.max_aspd_aptitude - min_aptitude)
                if percent < 0 then percent = 0 end
                local pet_quality_data = self.model:pet_aptitude_data(petData.base.id, percent)
                local temp_add = (petData.max_aspd_aptitude - min_aptitude) * pet_quality_data.apt_ratio / 100 + pet_quality_data.apt_base
                temp_add = math.floor(temp_add + 0.5)
                if temp_add < 5 then temp_add = 5 end
                -- if i == ceil_num and i - num[5] > 0 then
                --     temp_add = math.floor((num[5] - math.floor(num[5])) * temp_add + 0.5)
                -- end
                aspd_aptitude = aspd_aptitude + temp_add
                quality_add[5] = quality_add[5] + temp_add
            end

            if petData.aspd_aptitude + quality_add[5] >= petData.max_aspd_aptitude then
                quality_add[5] = petData.max_aspd_aptitude - petData.aspd_aptitude
            end
        end

        local quality_add = { 0, 0, 0, 0, 0 }
        local petData = self.mainPetData
        local basedata = self.mainPetData.base
        for i=1, #self.model.artificeAttrData do
            local attrData = self.model.artificeAttrData[i]
            if attrData.type == 1 then
                quality_add[3] = attrData.value
            elseif attrData.type == 2 then
                quality_add[1] = attrData.value
            elseif attrData.type == 3 then
                quality_add[2] = attrData.value
            elseif attrData.type == 4 then
                quality_add[4] = attrData.value
            elseif attrData.type == 5 then
                quality_add[5] = attrData.value
            end

        end
        if petData.phy_aptitude + quality_add[1] >= petData.max_phy_aptitude then
            quality_add[1] = petData.max_phy_aptitude - petData.phy_aptitude
        end
        if petData.pdef_aptitude + quality_add[2] >= petData.max_pdef_aptitude then
            quality_add[2] = petData.max_pdef_aptitude - petData.pdef_aptitude
        end
        if petData.hp_aptitude + quality_add[3] >= petData.max_hp_aptitude then
            quality_add[3] = petData.max_hp_aptitude - petData.hp_aptitude
        end
        if petData.magic_aptitude + quality_add[4] >= petData.max_magic_aptitude then
            quality_add[4] = petData.max_magic_aptitude - petData.magic_aptitude
        end
        if petData.aspd_aptitude + quality_add[5] >= petData.max_aspd_aptitude then
            quality_add[5] = petData.max_aspd_aptitude - petData.aspd_aptitude
        end
        -- BaseUtils.dump(quality_add, "quality_add")

        return quality_add
    else
        return 0
    end
end

function PetArtificeWindow:OpenSelectMainPet()
    local list = {}
    -- if self.model.battle_petdata ~= nil then
    --     table.insert(list, self.model.battle_petdata.id)
    -- end
    if self.subPetData ~= nil then
        table.insert(list, self.subPetData.id)
    end

    local tipsArgs = { text = TI18N("当前没有可炼化的宠物") }
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function(data) self:selectMainPet(data) end, nil, 1, list, tipsArgs})
end

function PetArtificeWindow:OpenSelectSubPet()
    local list = {}
    -- if self.model.battle_petdata ~= nil then
    --     table.insert(list, self.model.battle_petdata.id)
    -- end
    if self.mainPetData ~= nil then
        table.insert(list, self.mainPetData.id)
    end
    for k,v in ipairs(self.model.petlist) do
        if v.genre == 2 or v.genre == 4 then
            table.insert(list, v.id)
        end
    end
    local tipsArgs = { text = TI18N("当前没有可炼化的宠物") }
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petselect, { function(data) self:selectSubPet(data) end, nil, 1, list, tipsArgs})
end

function PetArtificeWindow:SendPetArtifice()
    self.model.artificeAttrData = {}

    if self.mainPetData ~= nil and self.subPetData ~= nil then
        PetManager.Instance:Send10566(self.mainPetData.id, self.subPetData.id)
    end
end