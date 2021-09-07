-- -------------------------------------------
-- 子女属性
-- hosr
-- -------------------------------------------
PetChildAttrView = PetChildAttrView or BaseClass(BasePanel)

function PetChildAttrView:__init(parent)
	self.parent = parent
    self.name = "PetView_Child"
    self.resList = {
        {file = AssetConfig.petwindow_childattrpanel, type = AssetType.Main}
        , {file = AssetConfig.pet_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.headride, type = AssetType.Dep}
    }

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currData = nil
    self.equipObjList = {}
    self.equipList = {}
    self.attrTab = {}

    self.attrListener = function() self:UpdateAttr() end
    self.infoListener = function() self:UpdateInfo() end
    self.equipListener = function() self:UpdateEquip() end
    self.pointListener = function() self:UpdatePoint() end
end

function PetChildAttrView:__delete()
	for k,v in pairs(self.equipList) do
	    v:DeleteMe()
	    v = nil
	end

	self.fullImg = nil
	self:OnHide()
end

function PetChildAttrView:OnShow()
    ChildrenManager.Instance.OnChildDataUpdate:Add(self.infoListener)
    ChildrenManager.Instance.OnChildAttrUpdate:Add(self.attrListener)
    ChildrenManager.Instance.OnChildEquipUpdate:Add(self.equipListener)
    ChildrenManager.Instance.OnChildPointUpdate:Add(self.pointListener)
	self:Update()
end

function PetChildAttrView:OnHide()
    ChildrenManager.Instance.OnChildDataUpdate:Remove(self.infoListener)
    ChildrenManager.Instance.OnChildAttrUpdate:Remove(self.attrListener)
    ChildrenManager.Instance.OnChildEquipUpdate:Remove(self.equipListener)
    ChildrenManager.Instance.OnChildPointUpdate:Remove(self.pointListener)
end

function PetChildAttrView:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petwindow_childattrpanel))
    self.gameObject.name = "PetView_ChildAttr"
    self.gameObject.transform:SetParent(self.parent.panelContainer)
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject.transform.localPosition = Vector3(-248, 180, 0)

    self.transform = self.gameObject.transform

    local info = self.transform:Find("InfoPanel")
    self.hpSlider = self.transform:Find("InfoPanel/HpGroup/HpSlider"):GetComponent(Slider)
    self.hpVal = self.transform:Find("InfoPanel/HpGroup/HpText"):GetComponent(Text)
    self.fullSlider = self.transform:Find("InfoPanel/ExpGroup/ExpSlider"):GetComponent(Slider)
    self.fullVal = self.transform:Find("InfoPanel/ExpGroup/ExpText"):GetComponent(Text)
    self.transform:Find("InfoPanel/ExpGroup/NameText"):GetComponent(Text).text = TI18N("心 情")
    self.fullBtn = self.transform:Find("InfoPanel/ExpGroup/Button"):GetComponent(Button)
    self.fullBtn.onClick:AddListener(function() self:ClickAddFull() end)
    self.fullImg = self.transform:Find("InfoPanel/ExpGroup/ExpSlider/Fill Area/Fill"):GetComponent(Image)
    --self.txt_status = self.transform:Find("InfoPanel/txt_status"):GetComponent(Text)
    local equip = self.transform:Find("EquipPanel")
    self.txtObj = equip:Find("Text").gameObject
    self.txt = self.txtObj:GetComponent(Text)
    self.upBtn = equip:Find("Button"):GetComponent(Button)
    self.upBtn.onClick:AddListener(function() self:ClickUp() end)
    self.txtObj:SetActive(false)
    self.upBtnObj = self.upBtn.gameObject
    self.upBtnObj:SetActive(true)
    self.upBtnTxt = equip:Find("Button/Text"):GetComponent(Text)
    -- self.upBtnTxt.text = TI18N("进 阶")

    for i = 1, 4 do
	    local slot = ItemSlot.New()
	    local obj = equip:Find("panel/gem" .. i).gameObject
	    table.insert(self.equipObjList, obj)
	    local index = i
	    obj:GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petchildgemwindow, {hold_id = index, replace = false}) end)
	    UIUtils.AddUIChild(obj, slot.gameObject)
	    slot.gameObject:SetActive(false)
	    table.insert(self.equipList, slot)
    end

    local attr = self.transform:Find("AttrPanel")
   	self.addPointBtn = attr:Find("PotentialButton"):GetComponent(Button)
   	self.addPointBtn.onClick:AddListener(function() self:ClickAddPoint() end)
   	self.red = attr:Find("PotentialButton/RedPointImage").gameObject
   	self.red:SetActive(false)

   	self.phyAtk = attr:Find("AttrObject1/ValueText"):GetComponent(Text)
   	self.magAtk = attr:Find("AttrObject2/ValueText"):GetComponent(Text)
   	self.phyDef = attr:Find("AttrObject3/ValueText"):GetComponent(Text)
   	self.magDef = attr:Find("AttrObject4/ValueText"):GetComponent(Text)
   	self.speed = attr:Find("AttrObject5/ValueText"):GetComponent(Text)
   	self.magic = attr:Find("AttrObject6/ValueText"):GetComponent(Text)

   	self:OnShow()
end

function PetChildAttrView:ClickAddFull()
	if self.currData == nil then
		return
	end

	if self.currData.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(self.currData.follow_id, self.currData.f_zone_id, self.currData.f_platform) == BaseUtils.get_self_id() then
            -- PetManager.Instance.model:OpenChildLearnSkill()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
    end

	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_child_feed, {PetManager.Instance.model.currChild,2})
end

function PetChildAttrView:ClickAddPoint()
	if self.currData == nil then
		return
	end

	if self.currData.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(self.currData.follow_id, self.currData.f_zone_id, self.currData.f_platform) == BaseUtils.get_self_id() then
            -- PetManager.Instance.model:OpenChildLearnSkill()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    else
    	if not PetManager.Instance.model:CheckChildCanFollow() then
	        NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
	    end
    end

	if PetManager.Instance.model.currChild ~= nil then
		AddPointManager.Instance:Open({3, PetManager.Instance.model.currChild})
	end
end

function PetChildAttrView:ClickUp()
	if self.currData == nil then
		return
	end

	if self.currData.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(self.currData.follow_id, self.currData.f_zone_id, self.currData.f_platform) == BaseUtils.get_self_id() then
            -- PetManager.Instance.model:OpenChildLearnSkill()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
    end

	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.pet_child_upgrade)
end

function PetChildAttrView:Update()
	self.currData = PetManager.Instance.model.currChild
	if self.currData == nil then
		return
	end
	self:UpdateInfo()
	self:UpdateAttr()
	self:UpdateEquip()
	self:UpdatePoint()
	self:UpdataHoleNum()
end

function PetChildAttrView:UpdateInfo()
	self.hpSlider.value = self.currData.hp / self.currData.hp_max
	self.hpVal.text = string.format("%s/%s", self.currData.hp, self.currData.hp_max)

    self.fullSlider.value = self.currData.hungry / 100
	self.fullVal.text = string.format("%s/100", self.currData.hungry)
    local  curHappData = ChildrenManager.Instance:GetHappinessByHugry(self.currData.hungry)
    if curHappData ~= nil then
        if curHappData.happiness < 4 then
           self.fullImg.sprite = self.assetWrapper:GetSprite(AssetConfig.pet_textures,"ProgressBarY")
        else
           self.fullImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "ProgressBar1")
        end
       self.fullVal.text  = string.format(TI18N("%s"), ChildrenEumn.ChildHappinessTitle[curHappData.happiness])
    end

	if self.currData.grade == 0 and self.currData.lev < 85 then
		self.upBtnTxt.text = TI18N("需85级")
	elseif self.currData.grade == 1 and self.currData.lev < 95 then
		self.upBtnTxt.text = TI18N("需95级")
	else
		self.upBtnTxt.text = TI18N("进 阶")
	end
end

function PetChildAttrView:UpdateAttr()
	self.phyAtk.text = self.currData.phy_dmg
	self.magAtk.text = self.currData.magic_dmg
	self.phyDef.text = self.currData.phy_def
	self.magDef.text = self.currData.magic_def
	self.speed.text = self.currData.atk_speed
	self.magic.text = self.currData.mp_max
end

function PetChildAttrView:UpdateEquip()
	for i = 1, #self.equipList do
		local slot = self.equipList[i]
		slot:SetAll(nil)
		slot.gameObject:SetActive(false)
	end

    local data = DataChild.data_upgrade[string.format("%s_%s", self.currData.base_id, self.currData.grade + 1)]
	for i,v in ipairs(self.currData.stones) do
		local slot = self.equipList[v.id]
		local baseData = ItemData.New()
		baseData:SetBase(DataItem.data_get[v.base_id])
		baseData.id = v.id
		baseData.attr = v.attr
		baseData.extra = v.extra
		baseData.reset_attr = v.reset_attr

		local cdata = {}
		cdata.child_id = self.currData.child_id
		cdata.platform = self.currData.platform
		cdata.zone_id = self.currData.zone_id
		cdata.child_name = self.currData.name
		local father = ChildrenManager.Instance:GetFather(self.currData)
		if father ~= nil then
			cdata.father_name = string.format(TI18N("父亲:%s"), father.name)
		else
			cdata.father_name = TI18N("父亲")
		end
		local mother = ChildrenManager.Instance:GetMother(self.currData)
		if mother ~= nil then
			cdata.mother_name = string.format(TI18N("母亲:%s"), mother.name)
		else
			cdata.mother_name = TI18N("母亲")
		end
		cdata.b_id = v.b_id
		cdata.b_platform = v.b_platform
		cdata.b_zone_id = v.b_zone_id
	    if data ~= nil then
	        slot:SetAll(baseData, {child = cdata, hole = v.id, nobutton = true, white_list = {{id = 12, show = true}}})
	    else
	        slot:SetAll(baseData, {child = cdata, hole = v.id, nobutton = true, white_list = {{id = 16, show = true}}})
	    end
		slot.gameObject:SetActive(true)
	end

	if data == nil then
		self.upBtnObj:SetActive(false)
		self.txtObj:SetActive(true)
	else
		self.upBtnObj:SetActive(true)
		self.txtObj:SetActive(false)
	end
end

function PetChildAttrView:UpdatePoint()
    self.red:SetActive(false)
    if self.currData.pre_str == 0 and self.currData.pre_con == 0 and self.currData.pre_mag == 0 and self.currData.pre_agi == 0 and self.currData.pre_end == 0 then
    	self.red:SetActive(true)
   	end
end

-- 更新孔数
function PetChildAttrView:UpdataHoleNum()
	local upgrade = DataChild.data_upgrade[string.format("%s_%s", self.currData.base_id, self.currData.grade + 1)]
	if upgrade == nil then
		upgrade = DataChild.data_upgrade[string.format("%s_%s", self.currData.base_id, self.currData.grade)]
	end

	if upgrade == nil then
		return
	end

	local num = upgrade.hole_num
	for i = 1, #self.equipObjList do
		if i > num then
			self.equipObjList[i]:SetActive(false)
		else
			self.equipObjList[i]:SetActive(true)
		end
	end
end