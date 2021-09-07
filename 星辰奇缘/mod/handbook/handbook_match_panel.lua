-- -------------------------------
-- 幻化组合界面
-- hosr
-- -------------------------------
HandbookMatchPanel = HandbookMatchPanel or BaseClass(BasePanel)

function HandbookMatchPanel:__init(parent)
	self.parent = parent
	self.model = HandbookManager.Instance.model

	self.resList = {
		{file = AssetConfig.handbook_match, type = AssetType.Main},
		{file = AssetConfig.handbook_res, type = AssetType.Dep},
		{file = AssetConfig.handbookBg, type = AssetType.Dep},
		{file = AssetConfig.guard_head, type = AssetType.Dep},
		{file = AssetConfig.handbookmatch, type = AssetType.Dep},
		{file = AssetConfig.bigatlas_taskBg, type = AssetType.Main},
	}

	self.updateslowListener = function() 
		local mark = self.toggleTick.activeSelf
		self.toggleTick:SetActive(not mark) 
		self:UpdateInfo()
	end

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    self.currItem = nil

    self.itemList = {}
    self.headLoaderList = {}
    self.currPreviewId = 0
end

function HandbookMatchPanel:__delete()
    if self.headLoaderList ~= nil then
        for k,v in pairs(self.headLoaderList) do
            if v ~= nil then
                v:DeleteMe()
                v = nil
            end
        end
        self.headLoaderList = nil
    end
	if self.previewComp ~= nil then
		self.previewComp:DeleteMe()
		self.previewComp = nil
	end

	for i,v in ipairs(self.itemList) do
		v.bg.sprite = nil
		v.img.sprite = nil
		v.bg = nil
		v.img = nil
		v.btn = nil
		v.obj = nil
		v.txt = nil
	end
	self.itemList = nil
end

function HandbookMatchPanel:OnShow()
	HandbookManager.Instance.onUpdataSlowState:RemoveListener(self.updateslowListener)
	HandbookManager.Instance.onUpdataSlowState:AddListener(self.updateslowListener)
	self:Update()
	if self.previewComp ~= nil then
		self.previewComp:Show()
	end
end

function HandbookMatchPanel:OnHide()
	HandbookManager.Instance.onUpdataSlowState:RemoveListener(self.updateslowListener)
	if self.previewComp ~= nil then
		self.previewComp:Hide()
	end
end

function HandbookMatchPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.handbook_match))
    self.gameObject.name = "HandbookMatchPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.rect = self.gameObject:GetComponent(RectTransform)
    self.rect.anchoredPosition = Vector2(-15, 15)

    self.transform:Find("Right/Preview"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.handbookBg, "HandbookBg")
    -- local taskBg = GameObject.Instantiate(self:GetPrefab(AssetConfig.bigatlas_taskBg))
    -- UIUtils.AddBigbg(self.transform:Find("Right/Bg"), taskBg)
    -- taskBg.transform.localPosition = Vector2(-183, 71.5)
    self.previewName = self.transform:Find("Right/Preview/Name"):GetComponent(Text)
    self.preview = self.transform:Find("Right/Preview/View").gameObject

    self.callback = function(composite)
	    self:SetRawImage(composite)
	end
    self.previewsetting = {
        name = "HandbookMatchPanel"
        ,orthographicSize = 0.6
        ,width = 200
        ,height = 250
        ,offsetY = -0.3
    }

    self.title = self.transform:Find("Right/Titie1/Text"):GetComponent(Text)
    self.valTxt = self.transform:Find("Right/Val"):GetComponent(Text)
    self.valTxt2 = self.transform:Find("Right/Val2"):GetComponent(Text)
    self.desc = self.transform:Find("Right/Scroll/Desc"):GetComponent(Text)
	self.descRect = self.desc.gameObject:GetComponent(RectTransform)
	
	self.toggle = self.transform:Find("Right/SpeedToggle"):GetComponent(Button)
	self.toggleTick = self.transform:Find("Right/SpeedToggle/Tick").gameObject
	self.toggle.onClick:AddListener(function() self:OnSpeed() end)

    local container = self.transform:Find("Right/Container")
    local len = container.childCount
    for i = 1, len do
    	local item = container:GetChild(i - 1)
    	local bg = item:Find("Bg"):GetComponent(Image)
    	local img = item:Find("Img"):GetComponent(Image)
    	img.gameObject:SetActive(true)
    	local txt = item:Find("Text"):GetComponent(Text)
    	local selectObj = item:Find("Select").gameObject
    	table.insert(self.itemList, {obj = item.gameObject, bg = bg, img = img, txt = txt, btn = item:GetComponent(Button), select = selectObj})
    end

    self.Container = self.transform:Find("Left/Scroll/Container")
    self.ScrollCon = self.transform:Find("Left/Scroll")
    self.rank_item_list = {}
    local len = self.Container.childCount
    for i = 1, len do
        local go = self.Container:GetChild(i - 1).gameObject
        local item = HandbookHeamItem.New(go, self)
        go:SetActive(false)
        table.insert(self.rank_item_list, item)
    end
    self.single_item_height = self.rank_item_list[1].transform:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.Container:GetComponent(RectTransform).anchoredPosition.y
    self.scroll_con_height = self.ScrollCon:GetComponent(RectTransform).sizeDelta.y

    self.setting = {
       item_list = self.rank_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.Container  --item列表的父容器
       ,single_item_height = self.single_item_height --一条item的高度
       ,item_con_last_y = self.item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.vScroll = self.ScrollCon:GetComponent(ScrollRect)
    self.vScroll.onValueChanged:AddListener(function() BaseUtils.on_value_change(self.setting) end)

    self.fight = self.transform:Find("Right/Preview/Fight/Val")
    self.fightTxt = self.fight:GetComponent(Text)
    self.fightRect = self.fight:GetComponent(RectTransform)

    self:OnShow()
end

function HandbookMatchPanel:SelectOne(item)
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)

	self.data = self.currItem.data

	self.toggleTick:SetActive(HandbookManager.Instance.no_speed_list[self.data.set_id] or false)

	self:UpdateInfo()
end

function HandbookMatchPanel:Update()
	local list = {}
	for k,v in pairs(DataHandbook.data_suit) do
		local dat = BaseUtils.copytab(v)
		dat.num = self.model.matchTab[v.set_id] or 0
		table.insert(list, dat)
	end
	table.sort(list, function(a,b)
		-- if a.num == b.num then
		-- 	return a.set_id < b.set_id
		-- else
		-- 	return a.num > b.num
		-- end

        return a.index < b.index
	end)

	self.setting.data_list = list
	BaseUtils.refresh_circular_list(self.setting)

	if self.model.jumpMatchId == 0 then
		self.rank_item_list[1]:ClickSelf()
	else
		local item = self:SelectById()
		if item == nil then
			self.rank_item_list[1]:ClickSelf()
		else
			item:ClickSelf()
		end
	end
end

function HandbookMatchPanel:SelectById()
	for i,item in ipairs(self.rank_item_list) do
		if item.data.set_id == self.model.jumpMatchId then
			return item
		end
	end
	return nil
end

function HandbookMatchPanel:UpdateInfo()
	self.title.text = self.data.name

	self.desc.text = self.data.desc
	self.descRect.sizeDelta = Vector2(470, self.desc.preferredHeight)

	local books = self.data.book_list
	local max = #books
	local isAllActice = true
	local isAllOne = true
	for i,id in ipairs(books) do
		local base = DataHandbook.data_base[id]
		local item = self.itemList[i]
		item.txt.text = base.name
		if base.effect_type == HandbookEumn.EffectType.Pet then
			local pet = DataPet.data_pet[base.preview_id]
			if pet ~= nil then
                local loaderId = item.img.gameObject:GetInstanceID()
                if self.headLoaderList[loaderId] == nil then
                    self.headLoaderList[loaderId] = SingleIconLoader.New(item.img.gameObject)
                end
                self.headLoaderList[loaderId]:SetSprite(SingleIconType.Pet,pet.head_id)
				-- item.img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(pet.head_id), tostring(pet.head_id))
			end
		elseif base.effect_type == HandbookEumn.EffectType.Guard then
			local guard = DataShouhu.data_guard_base_cfg[base.preview_id]
			if guard ~= nil then
                local loaderId = item.img.gameObject:GetInstanceID()
                if self.headLoaderList[loaderId] == nil then
                    self.headLoaderList[loaderId] = SingleIconLoader.New(item.img.gameObject)
                end
                self.headLoaderList[loaderId]:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(guard.base_id)))
			end
		end
		item.bg.sprite = self.assetWrapper:GetSprite(AssetConfig.handbook_res, string.format("HandbookBg%s", base.grade_type))
		item.obj:SetActive(true)
		item.btn.onClick:RemoveAllListeners()
		-- item.btn.onClick:AddListener(function() self:UpdatePreview(base) end)
		item.btn.onClick:AddListener(function() self:ClickOneHead(base.id) end)
		if i == 1 then
			self:UpdatePreview(base)
			-- item.select:SetActive(true)
		end

		local handbook = HandbookManager.Instance:GetDataById(base.id)
		local isActive = false
		if handbook ~= nil then
			isActive = (handbook.status == HandbookEumn.Status.Active)
			if handbook.star_step >= 1 then
				item.txt.text = string.format("%s<color='#ffff00'>★</color>", base.name)
			end
			isAllOne = isAllOne and (handbook.star_step >= 1)
		end

		if isActive then
			item.img.color = Color.white
			item.bg.color = Color.white
		else
			item.img.color = Color.gray
			item.bg.color = Color.gray
		end

		isAllActice = isAllActice and isActive
	end

	for i = max + 1, #self.itemList do
		self.itemList[i].obj:SetActive(false)
	end

	local attrs = self.data.attr
	local str = ""
	local str2 = ""
	local count = 0

	local mark = false --图鉴组合是否有攻速加成
	for _, v in ipairs(attrs) do
		if v.attr_name == 3 then 
			mark = true
			break
		end
	end
	--有攻速加成且激活状态
	self.toggle.gameObject:SetActive(mark and isAllActice)

	for i,v in ipairs(attrs) do
		count = count + 1
		
		local val = KvData.GetAttrStringNoColor(v.attr_name, v.val)

		local one = self.data.star_attr[i]
		if isAllActice then
			if isAllOne then
				val = KvData.GetAttrStringNoColor(v.attr_name, v.val + one.val)
			else
				str2 = str2 .. string.format("<color='#ffff00'>+%s(★加成)</color>", one.val) .. "\n"
			end
		end
		--龟速流特殊处理
		if v.attr_name == 3 and self.toggleTick.activeSelf then--HandbookManager.Instance.no_speed_list[self.data.set_id] then 
			val = TI18N("攻速+0")
		end
		
		str = str .. val .. "\n"
	end

	if count < 3 then
		if isAllActice then
			str = str .. string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("组合图鉴都升★后可激活★加成"))
		else
			str = str .. string.format("<color='%s'>%s</color>", ColorHelper.color[1], TI18N("激活后永久加成角色属性"))
		end
	end
	self.valTxt.text = str
	self.valTxt2.text = str2

	if isAllActice and isAllOne then
		self.fightTxt.text = string.format(TI18N("一星战力:%s"), self.data.star_fc)
	else
		self.fightTxt.text = string.format(TI18N("战力:%s"), self.data.fc)
	end

	local w = self.fightTxt.preferredWidth
	local h = 30
	self.fightRect.sizeDelta = Vector2(w, h)
	self.fightRect.anchoredPosition = Vector2.one
end

function HandbookMatchPanel:UpdatePreview(base)
	if self.currPreviewId == base.preview_id then
		return
	end

	self.currPreviewId = base.preview_id
	local modelData = nil
	if base.effect_type == HandbookEumn.EffectType.Pet then
		local pet = DataPet.data_pet[base.preview_id]
		if pet ~= nil then
			self.previewName.text = pet.name
			modelData = {type = PreViewType.Pet, skinId = pet.skin_id_0, modelId = pet.model_id, animationId = pet.animation_id, effects = pet.effects_0, scale = pet.scale / 100}
		end
	elseif base.effect_type == HandbookEumn.EffectType.Guard then
		local guard = DataShouhu.data_guard_base_cfg[base.preview_id]
		if guard ~= nil then
			self.previewName.text = guard.name
			modelData = {type = PreViewType.Shouhu, skinId = guard.paste_id, modelId = guard.res_id, animationId = guard.animation_id, scale = guard.scale / 100}
		end
	end

	if modelData == nil then
		return
	end

    if self.previewComp == nil then
    	self.previewComp = PreviewComposite.New(self.callback, self.previewsetting, modelData)
    else
    	self.previewComp:Reload(modelData, self.callback)
    end
    self.previewComp:Show()
end

function HandbookMatchPanel:SetRawImage(composite)
    local rawImage = composite.rawImage
    rawImage.transform:SetParent(self.preview.transform)
    rawImage.transform.localPosition = Vector3(0, 0, 0)
    rawImage.transform.localScale = Vector3(1, 1, 1)
    self.preview:SetActive(true)
    composite.tpose.transform:Rotate(Vector3(0, -30, 0))
end

function HandbookMatchPanel:ClickOneHead(id)
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.handbook_main, {1, id})
end

-- 攻速选择
function HandbookMatchPanel:OnSpeed()
	local setId = self.data.set_id
    if HandbookManager.Instance.no_speed_list[setId] then
        HandbookManager.Instance:Send17112(setId,0)
    else
        local confirmData = NoticeConfirmData.New()
        confirmData.content = TI18N("该操作将会屏蔽图鉴加成的攻速，该操作适用于<color='#ffff00'>龟速流派</color>，是否继续（再次勾选可恢复）？")
        confirmData.sureCallback = function() HandbookManager.Instance:Send17112(setId,1) end
        NoticeManager.Instance:ConfirmTips(confirmData)
    end
end