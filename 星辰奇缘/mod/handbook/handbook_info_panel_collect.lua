-- -----------------------------------
-- 幻化收藏册标签收集和升星
-- hosr
-- -----------------------------------
HandbookInfoCollect = HandbookInfoCollect or BaseClass()

function HandbookInfoCollect:__init(gameObject, parent)
	self.parent = parent
	self.gameObject = gameObject
	self.transform = self.gameObject.transform

	self.starList = {}
	self.attr1List = {}
	self.attr2List = {}

	self.listener = function() self:Update(true) end
	self.isShow = false
	self.isActive = false

	self.tipsText = {
		TI18N("1.消耗图鉴对应碎片或万能碎片可对图鉴进行<color='#00ff00'>升级</color>操作，升到<color='#00ff00'>星星</color>或<color='#00ff00'>月亮</color>后将获得属性加成"),
		TI18N("2.每天月亮级别将有<color='#00ff00'>极低概率</color>掉1点经验"),
	}
    self.needtipsText = {
        TI18N("勾选后<color='#ffff00'>市场、背包、仓库</color>中该图鉴碎片将获得<color='#00ff00'>需求</color>标记，以帮助筛选")
    }

	self.tweenId1 = nil
	self.tweenId2 = nil

	self.rewardPanel = nil
	self.mergePanel = nil

	self.noUp = false
    self.needId = 0

	self:InitPanel()
end

function HandbookInfoCollect:__delete()
	if self.rewardPanel ~= nil then
		  self.rewardPanel:DeleteMe()
		  self.rewardPanel = nil
	end

	if self.mergePanel ~= nil then
		  self.mergePanel:DeleteMe()
		  self.mergePanel = nil
	end

	

	if self.tweenId1 ~= nil then
		Tween.Instance:Cancel(self.tweenId1)
	end

	if self.tweenId2 ~= nil then
		Tween.Instance:Cancel(self.tweenId2)
	end

	EventMgr.Instance:RemoveListener(event_name.handbook_infoupdate, self.listener)

	if self.starList ~= nil then
		for i,v in ipairs(self.starList) do
			v.img.sprite = nil
			v.img = nil
			v.obj = nil
			v.rect = nil
			v.val = nil
		end
		self.starList = nil
	end

	if self.attr1List ~= nil then
		for i,v in ipairs(self.attr1List) do
			v.obj = nil
			v.txt = nil
			v.icon = nil
			v.btn = nil
		end
		self.attr1List = nil
	end

	if self.attr2List ~= nil then
		for i,v in ipairs(self.attr2List) do
			v.obj = nil
			v.txt = nil
			v.icon = nil
			v.btn = nil
			v.rect = nil
		end
		self.attr2List = nil
	end

	if self.slot ~= nil then
		self.slot:DeleteMe()
		self.slot = nil
	end

	self.suitImg.sprite = nil
	self.suitImg = nil

	self.gameObject = nil
	self.transform = nil
	self.parent = nil
end

function HandbookInfoCollect:Show()
	self.isShow = true
	self.gameObject:SetActive(true)
	EventMgr.Instance:AddListener(event_name.handbook_infoupdate, self.listener)
end

function HandbookInfoCollect:Hide()
	self.isShow = false
	self.gameObject:SetActive(false)
	EventMgr.Instance:RemoveListener(event_name.handbook_infoupdate, self.listener)
end

function HandbookInfoCollect:InitPanel()
	self.reward = self.transform:Find("Reward").gameObject
	self.reward:GetComponent(Button).onClick:AddListener(function() self:ShowReward() end)

	self.transform:Find("Suit"):GetComponent(Button).onClick:AddListener(function() self:Jump() end)
	self.suitTxt = self.transform:Find("Suit/Txt"):GetComponent(Text)
	self.suitImg = self.transform:Find("Suit/Img"):GetComponent(Image)
	self.suitTag = self.transform:Find("Suit/Tag").gameObject
	self.suitNo = self.transform:Find("Suit/No").gameObject

	self.name = self.transform:Find("Name"):GetComponent(Text)
	self.noActiveTxt = self.transform:Find("NoActiveTxt"):GetComponent(Text)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("Slot").gameObject, self.slot.gameObject)

    self.infoBtn = self.transform:Find("InfoBtn").gameObject
    self.infoBtn:GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.infoBtn, itemData = self.tipsText}) end)
    self.transform:Find("NeedInfoBtn"):GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.infoBtn, itemData = self.needtipsText}) end)

    self.NeedToggle = self.transform:Find("NeedToggle"):GetComponent(Toggle)
    self.NeedToggle.onValueChanged:AddListener(function(on) if self.toggleCallback ~= nil then self.toggleCallback(on) end end)
    self.title2 = self.transform:Find("Title2").gameObject

    self.scroll1 = self.transform:Find("Scroll1"):GetComponent(ScrollRect)
    local container = self.transform:Find("Scroll1/AttrContainer1")
    self.container1Rect = container:GetComponent(RectTransform)

    local len = container.childCount
   	for i = 1, len do
   		local item = container:GetChild(i - 1)
   		local icon = item:Find("Icon"):GetComponent(Image)
   		local iconRect = icon.gameObject:GetComponent(RectTransform)
   		local rect = item:GetComponent(RectTransform)
   		icon.gameObject:SetActive(true)
   		table.insert(self.attr1List, {obj = item.gameObject, txt = item:GetComponent(Text), icon = icon, rect = rect, iconRect = iconRect})
   	end

   	self.red = self.transform:Find("Red").gameObject
   	self.red:SetActive(false)

    -- ---------------
    -- 收藏
    -- ---------------
    self.collectBtn = self.transform:Find("CollectBtn").gameObject
    self.collectBtn:GetComponent(Button).onClick:AddListener(function() self:ClickCollect() end)

    self.sliderColObj = self.transform:Find("Slider1").gameObject
    self.sliderCol = self.sliderColObj:GetComponent(Slider)
    self.sliderCol.wholeNumbers = false
		self.sliderVal = self.sliderColObj.transform:Find("Val"):GetComponent(Text)
		self.descTrans = self.transform:Find("Desc")
    self.desc = self.transform:Find("Desc/Scroll/Text"):GetComponent(Text)
    self.descRect = self.desc.gameObject:GetComponent(RectTransform)
		self.nothing = self.transform:Find("Desc/Nothing").gameObject
		self.mergeIcon = self.transform:Find("MergeIcon")
		self.mergeIcon:GetComponent(Image).sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookMergeBtn")
		self.mergeIcon.gameObject:SetActive(false)
		self.mergeredIcon = self.mergeIcon:Find("Red")
		self.mergeBtn = self.mergeIcon:GetComponent(Button)
		self.mergeBtn.onClick:AddListener(function() self:ShowMergePanel() end)

    -- ---------------
    -- 升星
    -- ---------------
    self.upBtn = self.transform:Find("UpBtn").gameObject
    self.upBtn:GetComponent(Button).onClick:AddListener(function() self:ClickUp() end)

    self.sliderUpObj = self.transform:Find("Slider2").gameObject
    self.sliderUp = self.sliderUpObj:GetComponent(Slider)
    self.sliderUp.wholeNumbers = false

    container = self.sliderUpObj.transform:Find("StarContainer")
    local starBase = container:Find("Star").gameObject
    starBase:SetActive(false)
    for i = 1, 5 do
    	local star = GameObject.Instantiate(starBase)
    	star.transform:SetParent(container)
    	star.transform.localScale = Vector3.one
    	star.transform.localPosition = Vector3.zero
    	local rect = star:GetComponent(RectTransform)
    	local img = star:GetComponent(Image)
    	local val = star.transform:Find("Val"):GetComponent(Text)
    	table.insert(self.starList, {obj = star, rect = rect, img = img, val = val})
    	star:SetActive(false)
    end

    self.scroll2 = self.transform:Find("Scroll2"):GetComponent(ScrollRect)
   	container = self.transform:Find("Scroll2/AttrContainer2")
    self.container2 = container.gameObject
   	self.container2Rect = container:GetComponent(RectTransform)
   	len = container.childCount
   	for i = 1, len do
   		local item = container:GetChild(i - 1)
   		local transform = item.transform
   		local txt = item:GetComponent(Text)
   		local rect = item:GetComponent(RectTransform)
   		local icon = transform:Find("Icon"):GetComponent(Image)
   		table.insert(self.attr2List, {obj = item.gameObject, rect = rect, txt = txt, icon = icon})
   	end

   	self.gameObject:SetActive(false)
end

function HandbookInfoCollect:Update(isUpdate)
	self.data = self.parent.data
	self.handbook = HandbookManager.Instance:GetDataById(self.data.id)

	-- 是否激活
	-- 激活显示升星操作
	-- 未激活显示收藏操作
	self.isActive = false
	self.noUp = false
	if self.handbook ~= nil then
		self.isActive = (self.handbook.status == HandbookEumn.Status.Active)
	end

	self:UpdateInfo(isUpdate)
	self:UpdateItem()
	self:UpdateSuit()
	self:UpdateAttr()
	self:UpdateShowHide()
end

function HandbookInfoCollect:UpdateInfo(isUpdate)
	self.maxVal = 0
	self.posList = {}
	for i,v in ipairs(self.data.star_loss) do
		self.maxVal = self.maxVal + v[2]
		table.insert(self.posList, self.maxVal)
	end

	if self.isActive and not HandbookManager.Instance.isChange then
		self:UpdateSlider1(isUpdate)
	else
		self:UpdateSlider2(isUpdate)
	end
end

function HandbookInfoCollect:UpdateShowHide()
    self.name.gameObject:SetActive(true)
		self.collectBtn:SetActive(not self.isActive)
		self.sliderColObj:SetActive(not self.isActive)
		self.nothing:SetActive(not self.isActive)
		self.noActiveTxt.gameObject:SetActive(not self.isActive)
		self.reward:SetActive(not self.isActive)

		self.upBtn:SetActive(self.isActive)
		self.sliderUpObj:SetActive(self.isActive)
		self.desc.gameObject:SetActive(self.isActive)
		self.title2:SetActive(self.isActive)
		self.container2:SetActive(self.isActive)
		self.scroll2.gameObject:SetActive(self.isActive)

		self.slot.gameObject:SetActive(true)

		self.desc.text = self.data.desc
		self.descRect.sizeDelta = Vector2(395, self.desc.preferredHeight)
		
		if self.noUp then
				self.sliderUpObj:SetActive(false)
				self.title2:SetActive(false)
				self.infoBtn:SetActive(false)
				self.slot.gameObject:SetActive(false)
				self.name.gameObject:SetActive(false)
		end

		self.noActiveTxt.text = string.format(TI18N("（达到%s级可激活属性加成）"), DataHandbook.data_base[self.parent.data.id].level_limit)
		
		self:ShowMergeIcon()
		
end

function HandbookInfoCollect:ShowMergeIcon()
		--是否需要显示合成按钮
		local Querdata = DataHandbook.data_base[self.data.id]
		local hand = HandbookManager.Instance:GetDataById(self.data.id)
	  if hand ~= nil then
		    self.isActive = (hand.status == HandbookEumn.Status.Active)
	  end
		if self.isActive and Querdata.fuse_flag == 1 and hand.star_step >= 1 then
				self.descTrans.transform.anchoredPosition = Vector2(-36.5, -42.4)
				self.descTrans.transform.sizeDelta = Vector2(374, 76)
				self.desc.text = self.data.desc
				self.descRect.sizeDelta = Vector2(325, self.desc.preferredHeight)
				local height = self.desc.preferredHeight
				self.descRect.sizeDelta = Vector2(325, height)
				self.mergeIcon.gameObject:SetActive(true)
				self:CheckMergeRedpoint()
		else
				self.descTrans.transform.anchoredPosition = Vector2(-1, -42.4)
				self.descTrans.transform.sizeDelta = Vector2(445, 76)
				self.desc.text = self.data.desc
				self.descRect.sizeDelta = Vector2(395, self.desc.preferredHeight)
				local height2 = self.desc.preferredHeight
				self.descRect.sizeDelta = Vector2(395, height2)
				self.mergeIcon.gameObject:SetActive(false)
		end
end

function HandbookInfoCollect:CheckMergeRedpoint()
		local Querdata = DataHandbook.data_base[self.data.id]
		local illusionList = BackpackManager.Instance:GetFruitTimes(Querdata.illusion_id, Querdata.times)
		local fuse_Num = BackpackManager.Instance:GetItemCount(Querdata.fuse_id)
		if next(illusionList) ~= nil and fuse_Num >= Querdata.fuse_num1 then
				self.mergeredIcon.gameObject:SetActive(true)
		else
			  self.mergeredIcon.gameObject:SetActive(false)
		end
end

function HandbookInfoCollect:UpdateSlider1(isUpdate)
	local val = 0
	local show = false
	if self.handbook ~= nil then
		-- val = self.posList[self.handbook.star_step] or 0
		val = self.handbook.star_val
		if self.handbook.star_step >= 1 then
			val = val + self.posList[self.handbook.star_step]
		end
		if HandbookManager.Instance.needStarShowId == self.handbook.id then
			show = true
		end
	end
	self.sliderUp.maxValue = self.maxVal
	if show then
		local callback = function()
			self:ShowStar(isUpdate)
		end
		local updateCall = function(uval)
			self.sliderUp.value = uval
		end
		local form = self.sliderUp.value
		self.tweenId2 = Tween.Instance:ValueChange(form, val, 0.3, callback, LeanTweenType.linear, updateCall).id
	else
		self.sliderUp.value = val
		self:ShowStar(isUpdate)
	end
	self:UpdateShowHide()
	HandbookManager.Instance.isChange = false
end

function HandbookInfoCollect:UpdateSlider2(isUpdate)
	local val = 0
	local show = false
	if self.handbook ~= nil then
		val = self.handbook.active_step
		if HandbookManager.Instance.needStarShowId == self.handbook.id then
			show = true
		end
	end
	self.sliderCol.maxValue =  self.data.max_active_step
	self.sliderVal.text = string.format("<color='#ffff00'>%s/%s</color>", val, self.data.max_active_step)
	if show then
		local form = self.sliderCol.value
		local updateCall = function(uval)
			self.sliderCol.value = uval
		end
		local callback = function()
			self:UpdateShowHide()
			self:UpdateSlider1()
		end
		self.tweenId2 = Tween.Instance:ValueChange(form, val, 0.3, callback, LeanTweenType.linear, updateCall).id
	else
		self.sliderCol.value = val
		self:UpdateShowHide()
	end
end

function HandbookInfoCollect:ShowStar(isUpdate)
	local star = 0
	local show = false
	local obj = nil
	if self.handbook ~= nil then
		star = self.handbook.star_step
		if self.handbook.id == HandbookManager.Instance.needStarShowId then
			show = true
		end
	end
	for i,v in ipairs(self.starList) do
		if i <= self.data.max_star_step then
			v.rect.anchoredPosition = Vector2(340 * (self.posList[i] / self.maxVal), -15)
			v.obj:SetActive(true)
			if i == 1 then
				v.val.text = self.posList[i]
				if i <= star then
					v.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar1")
				else
					v.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar0")
				end
			else
				v.val.text = self.maxVal
				if i <= star then
					v.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookMoon1")
				else
					v.img.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookMoon0")
				end
			end
			v.img:SetNativeSize()
			if i == star then
				obj = v.obj
			end
		else
			v.obj:SetActive(false)
		end
	end

	if show and obj ~= nil then
		obj.transform.localScale = Vector3.one * 0.6
		obj:SetActive(true)
		self.tweenId1 = Tween.Instance:Scale(obj, Vector3.one, 0.7, nil, LeanTweenType.easeOutElastic).id
	end
	HandbookManager.Instance.needStarShowId = 0
end

-- 1.有正常，有万能，显示正常的图标和数量
-- 2.有正常，没万能，显示正常的图标和数量
-- 3.没正常，有万能，显示万能的图标和数量
function HandbookInfoCollect:UpdateItem()
	local val = 0
	local needNum = 0
	if self.isActive then
		if self.handbook ~= nil then
			if self.handbook.star_step < self.data.max_star_step then
				val = self.handbook.star_step + 1
				needNum = self.data.star_loss[val][2]
			end
		end
	else
		if self.handbook ~= nil then
			val = self.handbook.active_step
		end
		needNum = self.data.active_loss[val + 1][2]
	end
	local showNeedNum = needNum
	local needPrefect = false
	local hasPrefect = 0
	local hasNormal = 0

	self.list = {}
	self.baseId = 0
	for i,v in ipairs(self.data.allow_item) do
		if v ~= 28607 and v ~= 28608 then
			hasNormal = BackpackManager.Instance:GetItemCount(v)
			self.baseId = v
			if hasNormal > 0 and needNum > 0 then
				if hasNormal >= needNum then
					table.insert(self.list, {base_id = v, num = needNum})
					needNum = 0
				else
					table.insert(self.list, {base_id = v, num = hasNormal})
					needNum = needNum - hasNormal
				end
			end
		end

		if v == 28607 or v == 28608 then
			needPrefect = true
            self.needId = v
		end
	end

	-- if needPrefect then
	if hasNormal == 0 and needPrefect then
		hasPrefect = BackpackManager.Instance:GetItemCount(self.needId)
		if hasPrefect > 0 and needNum > 0 then
			if hasPrefect >= needNum then
				table.insert(self.list, {base_id = self.needId, num = needNum})
				needNum = 0
			else
				table.insert(self.list, {base_id = self.needId, num = hasPrefect})
				needNum = needNum - hasPrefect
			end
		end
	end

	local itemData = ItemData.New()
	if hasNormal == 0 and hasPrefect > 0 and needPrefect then
		itemData:SetBase(BaseUtils.copytab(DataItem.data_get[self.needId]))
	    self.slot:SetAll(itemData)
	    self.slot:SetNum(hasPrefect, showNeedNum)
	else
		itemData:SetBase(BaseUtils.copytab(DataItem.data_get[self.baseId]))
	    self.slot:SetAll(itemData)
	    self.slot:SetNum(hasNormal, showNeedNum)
	end
    self.name.text = itemData.name

    if self.handbook ~= nil and self.handbook.active_step == self.data.max_active_step then
    	self.red:SetActive(false)
    else
    	self.red:SetActive(hasNormal > 0)
    end
    local normal_itemid = 0
    for k,v in pairs(self.data.allow_item) do
        if v ~= 28607 and v ~= 28608 then
            normal_itemid = v
            break
        end
    end
    self.toggleCallback = nil
    self.NeedToggle.isOn = HandbookManager.Instance.model:GetIdNeed(normal_itemid)
    self.toggleCallback = function(isOn)
        self:OnToggle(normal_itemid, isOn)
    end
end

function HandbookInfoCollect:UpdateSuit()
	self.suitId = self.data.set_id[1]
	if self.suitId == nil then
		self.suitTxt.gameObject:SetActive(false)
		self.suitImg.gameObject:SetActive(false)
		self.suitTag:SetActive(false)
		self.suitNo:SetActive(true)
		return
	end

	self.suitTxt.gameObject:SetActive(true)
	self.suitImg.gameObject:SetActive(true)
	self.suitNo:SetActive(false)
	local suitData = DataHandbook.data_suit[self.suitId]
	self.suitImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbookmatch, tostring(suitData.set_id))
	local val = HandbookManager.Instance:GetMatchNumById(self.suitId)
	local stat = ""
	if val == suitData.max_num then
		self.suitTag:SetActive(true)
		self.suitTxt.text = suitData.name
	else
		self.suitTag:SetActive(false)
		stat = TI18N("<color='#ffdc5f'>(未达成)</color>")
		self.suitTxt.text = string.format("%s%s", suitData.name, stat)
	end
end

function HandbookInfoCollect:UpdateAttr()
	local active_val = 0 -- 收集进度
	local star_val = 0
	if self.handbook ~= nil then
		active_val = self.handbook.active_step
		star_val = self.handbook.star_step
	end
	local attrData = DataHandbook.data_attr[string.format("%s_%s", self.data.id, star_val)]

	for i,v in ipairs(self.attr1List) do
		v.obj:SetActive(false)
	end
	for i,v in ipairs(self.attr2List) do
		v.obj:SetActive(false)
	end

	if attrData == nil then
		return
	end

	local list = BaseUtils.split(attrData.active_desc) or {}
	if #list == 0 then
		table.insert(list, attrData.active_desc)
	end

	local count = 0
    for i,str in ipairs(list) do
    	count = count + 1
    	local item = self.attr1List[count]
    	-- if active_val >= i and active_val >= self.data.max_active_step / 2 then
    		item.txt.text = str
    		if self.isActive then
    			item.icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "greenpoint")
    			item.iconRect.sizeDelta = Vector2.one * 22
    		else
    			item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookRedpoint")
	    		item.icon:SetNativeSize()
    		end
    	-- else
    	-- 	item.txt.text = TI18N("属性+???")
    	-- 	item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookRedpoint")
    	-- 	item.icon:SetNativeSize()
    	-- end
    	item.rect.anchoredPosition = Vector2(0, -(count - 1) * 30)
    	item.obj:SetActive(true)
    end

    -- 补一条提示
    if attrData.ratio > 0 then
	    count = count + 1
	    local item = self.attr1List[count]
	    item.txt.text = string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("幻化有几率产生变异"))
	    if self.isActive then
	    	item.icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "greenpoint")
	    	item.iconRect.sizeDelta = Vector2.one * 22
	    else
	    	item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookRedpoint")
	    	item.icon:SetNativeSize()
	    end
	    item.rect.anchoredPosition = Vector2(0, -(count - 1) * 30)
	    item.obj:SetActive(true)
    end

    -- 等级
    count = count + 1
    local item = self.attr1List[count]
    item.txt.text = string.format(TI18N("人物等级达到<color='%s'>%s级</color>"), ColorHelper.color[1], DataHandbook.data_base[self.data.id].level_limit)
    if RoleManager.Instance.RoleData.lev >= DataHandbook.data_base[self.data.id].level_limit then
        item.icon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "greenpoint")
        item.iconRect.sizeDelta = Vector2.one * 22
    else
        item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookRedpoint")
        item.icon:SetNativeSize()
    end
    item.rect.anchoredPosition = Vector2(0, -(count - 1) * 30)
    item.obj:SetActive(true)

    self.scroll1.enabled = false
    self.container1Rect.sizeDelta = Vector2(200, count * 30)

    if self.isActive then
    	list = {}
		list = BaseUtils.split(attrData.star1_desc) or {}
		if #list == 0 and attrData.star1_desc ~= "" then
			table.insert(list, attrData.star1_desc)
		end

		count = 0
	    for i,str in ipairs(list) do
	    	count = count + 1
	    	local item = self.attr2List[count]
	    	item.txt.text = str
	    	if star_val >= 1 then
	    		item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar1")
	    	else
	    		item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar0")
	    	end
	    	item.icon:SetNativeSize()
	    	item.icon.gameObject:SetActive(true)
	    	item.rect.anchoredPosition = Vector2(0, (count - 1) * -25)
	    	item.obj:SetActive(true)
	    end

    	list = {}
		list = BaseUtils.split(attrData.star1_desc2) or {}
		if #list == 0 and attrData.star1_desc2 ~= "" then
			table.insert(list, attrData.star1_desc2)
		end
	    for i,str in ipairs(list) do
	    	count = count + 1
	    	local item = self.attr2List[count]
	    	item.txt.text = str
    		if star_val >= 1 then
    			item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar1")
    		else
    			item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookStar0")
    		end
	    	item.icon:SetNativeSize()
	    	item.icon.gameObject:SetActive(true)
	    	item.rect.anchoredPosition = Vector2(0, (count - 1) * -25)
	    	item.obj:SetActive(true)
	    end

    	list = {}
		list = BaseUtils.split(attrData.star2_desc) or {}
		if #list == 0 and attrData.star2_desc ~= "" then
			table.insert(list, attrData.star2_desc)
		end
	    for i,str in ipairs(list) do
	    	count = count + 1
	    	local item = self.attr2List[count]
	    	item.txt.text = str
    		if star_val >= 2 then
    			item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookMoon1")
    		else
    			item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.handbook_res, "HandbookMoon0")
    		end
	    	item.icon:SetNativeSize()
	    	item.icon.gameObject:SetActive(true)
	    	item.rect.anchoredPosition = Vector2(0, (count - 1) * -25)
	    	item.obj:SetActive(true)
	    end

	    self.scroll2.enabled = (count > 3)
	    self.container2Rect.sizeDelta = Vector2(200, count * 25)

	    if count == 0 then
	    	-- 无升星属性
	    	self.noUp = true
	    else
	    	self.noUp = false
	    end
    end
end

function HandbookInfoCollect:ClickInfo()
end

function HandbookInfoCollect:ClickLook()
end

function HandbookInfoCollect:ClickCollect()
	if self.data == nil then
		return
	end
	if self:CheckPrefect() then
		local item = DataItem.data_get[self.baseId]
		local prefect = DataItem.data_get[self.needId]
		local str = string.format(TI18N("您背包中没有相应道具，是否直接消耗%s?"),prefect.name)
		if item ~= nil then
			str = string.format(TI18N("您背包中%s不足，但有%s，是否直接消耗%s?"), ColorHelper.color_item_name(item.quality, item.name), ColorHelper.color_item_name(prefect.quality, prefect.name), ColorHelper.color_item_name(prefect.quality, prefect.name))
		end

		local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() HandbookManager.Instance:Send17101(self.data.id, self.list) end
        NoticeManager.Instance:ConfirmTips(data)
	else
		HandbookManager.Instance:Send17101(self.data.id, self.list)
	end
end

function HandbookInfoCollect:ClickUp()
	if self.data == nil then
		return
	end

	if self.noUp then
		NoticeManager.Instance:FloatTipsByString("该图鉴无需升星")
		return
	end

	if self:CheckPrefect() then
		local item = DataItem.data_get[self.baseId]
		local prefect = DataItem.data_get[self.needId]
        local str = nil
        if self.needId == 28607 then
		   str = TI18N("您背包中没有相应道具，是否直接消耗万能碎片?")
        elseif self.needId == 28608 then
           str = TI18N("您背包中没有相应道具，是否直接消耗稀有万能碎片?")
        end

		if item ~= nil then
			str = string.format(TI18N("您背包中没有%s，但有%s，是否直接消耗%s?"), ColorHelper.color_item_name(item.quality, item.name), ColorHelper.color_item_name(prefect.quality, prefect.name), ColorHelper.color_item_name(prefect.quality, prefect.name))
		end

		local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = str
        data.sureLabel = TI18N("确认")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function() HandbookManager.Instance:Send17103(self.data.id, self.list) end
        NoticeManager.Instance:ConfirmTips(data)
	else
		HandbookManager.Instance:Send17103(self.data.id, self.list)
	end
end

-- 检查是否要消耗万能
function HandbookInfoCollect:CheckPrefect()
	for i,data in ipairs(self.list) do
		if data.base_id == 28607 or data.base_id == 28608 then
			return true
		end
	end
	return false
end

function HandbookInfoCollect:ShowReward()
	local dataList = {}
	for i,v in ipairs(self.data.active_reward) do
		table.insert(dataList, v)
	end
	if self.rewardPanel == nil then
		self.rewardPanel = HandbookRewardPanel.New(self)
	end
	self.rewardPanel:Show(dataList)
	-- if self.giftPreview == nil then
	-- 	self.giftPreview = GiftPreview.New(self.parent.parent.gameObject)
	-- end
	-- self.giftPreview:Show({reward = dataList, autoMain = true, text = "<color='#ffff00'>收集图鉴后将<color='#ffff00'>额外获得</color>以下奖励</color>"})
end

function HandbookInfoCollect:Jump()
	if self.suitId ~= nil and self.suitId ~= 0 then
		HandbookManager.Instance.model.jumpMatchId = self.suitId
		self.parent.parent:JumpTo(3)
	end
end

function HandbookInfoCollect:OnToggle(id, isOn)
    HandbookManager.Instance.model:SetNeedId(id, isOn)
end

function HandbookInfoCollect:ShowMergePanel()
		--HandbookManager.Instance.model:OpenMerge(self.data.id)
		if self.mergePanel == nil then
			self.mergePanel = HandbookMergePanel.New(self)
		end
		self.mergePanel:Show(self.data.id)
end

function HandbookInfoCollect:HideMergePanel()
	  --HandbookManager.Instance.model:CloseMerge()
		if self.mergePanel ~= nil then
			  self.mergePanel:DeleteMe()
			  self.mergePanel = nil
		end
end

