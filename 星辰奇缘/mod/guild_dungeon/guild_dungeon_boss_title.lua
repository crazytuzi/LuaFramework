-- 主界面 副本Boss标题
-- ljh 2017032821

GuildDungeonBossTitle = GuildDungeonBossTitle or BaseClass(BaseView)

local Vector3 = UnityEngine.Vector3
function GuildDungeonBossTitle:__init(model)
    self.model = model
	self.resList = {
        {file = AssetConfig.guilddungeonbosstitle, type = AssetType.Main}
        ,{file = AssetConfig.guilddungeon_textures, type = AssetType.Dep}
        ,{file = AssetConfig.world_boss_head_icon, type = AssetType.Dep}
        ,{file = string.format(AssetConfig.effect, 20338), type = AssetType.Main}
    }

    self.name = "GuildDungeonBossTitle"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------

    ------------------------------------
    self._Update = function()
    	self:Update()
	end

	self:LoadAssetBundleBatch()
end

function GuildDungeonBossTitle:__delete()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    GuildDungeonManager.Instance.OnUpdateBoss:Remove(self._Update)
    self:AssetClearAll()
end

function GuildDungeonBossTitle:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guilddungeonbosstitle))
    self.gameObject.name = "GuildDungeonBossTitle"
    -- self.gameObject.transform:SetParent(MainUIManager.Instance.MainUICanvasView.transform)
    -- self.gameObject.transform.localPosition = Vector3.zero
    -- self.gameObject.transform.localScale = Vector3.one

    -- local rect = self.gameObject:GetComponent(RectTransform)
    -- rect.anchorMax = Vector2(1, 1)
    -- rect.anchorMin = Vector2(0, 0)
    -- rect.localPosition = Vector3(0, 0, 1)
    -- rect.offsetMin = Vector2(0, 0)
    -- rect.offsetMax = Vector2(0, 0)
    -- rect.localScale = Vector3.one

    UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)

    self.transform = self.gameObject.transform

	-----------------------------
    local transform = self.transform
    self.mainTransform = self.transform:FindChild("Main")

    self.mainTransform:GetComponent(Button).onClick:AddListener(function() self:OnGotoButtonClick() end)

	self.slider = self.mainTransform:FindChild("Slider"):GetComponent(Slider)
    self.sliderText = self.mainTransform:FindChild("Slider/ProgressTxt"):GetComponent(Text)
    self.slider2 = self.mainTransform:FindChild("Slider2"):GetComponent(Slider)
    self.slider3 = self.mainTransform:FindChild("Slider3"):GetComponent(Slider)
    self.nameText = self.mainTransform:FindChild("NameText"):GetComponent(Text)
    self.numText = self.mainTransform:FindChild("NumText"):GetComponent(Text)
    self.head = self.mainTransform:FindChild("Head/Image").gameObject

    local headEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20338)))
	headEffect.transform:SetParent(self.mainTransform:FindChild("Head"))
	headEffect.transform.localRotation = Quaternion.identity
	Utils.ChangeLayersRecursively(headEffect.transform, "UI")
	headEffect.transform.localScale = Vector3(1, 1, 1)
	headEffect.transform.localPosition = Vector3(0, -30, -400)

 	-----------------------------

    self:Show()

    self:ClearMainAsset()
end

function GuildDungeonBossTitle:Show()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(true)
        self:Update()
    end
    GuildDungeonManager.Instance.OnUpdateBoss:Add(self._Update)
end

function GuildDungeonBossTitle:Hide()
    if not BaseUtils.is_null(self.gameObject) then
        self.gameObject:SetActive(false)
    end
    GuildDungeonManager.Instance.OnUpdateBoss:Remove(self._Update)
end

function GuildDungeonBossTitle:Update()
    if not BaseUtils.is_null(self.gameObject) then
    	local bossMapData = GuildDungeonManager.Instance.model.bossMapData
		local bossData = GuildDungeonManager.Instance.model.bossData
		if bossMapData == nil or bossData == nil or bossMapData.head_id == nil or bossData.percent == nil then
			self.head.gameObject:SetActive(false)
			self.nameText.text = ""
			self.slider.value = 1
			self.slider2.value = 1
			self.slider3.value = 1
			self.sliderText.text = ""
			self.numText.text = "X3"
		else
			self.head.gameObject:SetActive(true)
			if bossMapData.head_type == 1 then
                    if self.headLoader == nil then
                        self.headLoader = SingleIconLoader.New(self.head:GetComponent(Image).gameObject)
                    end
                    self.headLoader:SetSprite(SingleIconType.Pet,bossMapData.head_id)

	           -- self.head:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(bossMapData.head_id), bossMapData.head_id)
	        elseif bossMapData.head_type == 2 then
	            self.head:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, bossMapData.head_id)
	        end
	        self.nameText.text = bossMapData.name
			self.slider.value = (bossData.percent - 667) / 333
			self.slider2.value = (bossData.percent - 334) / 333
			self.slider3.value = bossData.percent / 333
			self.sliderText.text = string.format("%s%%", bossData.percent / 10)
			if bossData.percent > 667 then
				self.numText.text = "X3"
			elseif bossData.percent > 334 then
				self.numText.text = "X2"
			elseif bossData.percent > 0 then
				self.numText.text = "X1"
			elseif bossData.percent == 0 then
				self.numText.text = "X0"
			end
		end
    end
end

function GuildDungeonBossTitle:OnGotoButtonClick()
    local bossData = GuildDungeonManager.Instance.model.bossData
    local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
    for key, value in ipairs(units) do
        if value.baseid == bossData.monster_id then
            SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(value.uniqueid)
            return
        end
    end
end