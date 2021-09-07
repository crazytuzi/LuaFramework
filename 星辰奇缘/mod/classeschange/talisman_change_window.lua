--------------------------------------------------------
-- UI - 宝物转换
-- pwj 2018.10.24
--------------------------------------------------------
TalismanChangeWindow = TalismanChangeWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TalismanChangeWindow:__init(model)
    self.model = model
    self.name = "TalismanChangeWindow"
    self.windowId = WindowConfig.WinID.talismanchangewindow
    self.winLinkType = WinLinkType.Link
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.TalismanChangeWindow, type = AssetType.Main}
        , {file = AssetConfig.createrole_texture, type = AssetType.Dep}
		, {file = AssetConfig.stongbg, type = AssetType.Dep}
		, {file = AssetConfig.talisman_textures, type = AssetType.Dep}
		, {file = AssetConfig.talisman_set, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil

	self.mainTransform = nil

	------------------------------------------------

    -- self.descString = TI18N("1、成功转职可以进行装备宝石切换\n2、成功转职7天内可进行16次转换\n3、英雄宝石无法进行转换")
	self.descString = TI18N("1.成功转职后，宝物将根据转职进行<color='#ffff00'>免费自动转换</color>\n2.若转换的宝物不符合预期，可在<color='#ffff00'>7天内手动</color>转换\n3.通用宝物、转职后获得的宝物，将不能转换")
	self.descString2 = TI18N("1.成功转职后，宝物将根据转职进行免费自动转换\n2.若转换的宝物不符合预期，可在7天内手动转换\n<color='#ffff00'>3.通用宝物、转职后获得的宝物，将不能转换</color>")

	------------------------------------------------
    self.okButtonText = nil
    self.timesText = nil

    self.container = nil
    self.talisitemobject = nil
    self.noitemtips = nil

    self.talislist = {}
    self.talisItemSlotList = {}

    self.itemSlot1 = nil
    self.itemSlot2 = nil
    self.itemNameText1 = nil
    self.itemNameText2 = nil

    self.i18NText2 = nil
	self.tipsText = nil

    self.selectItem_container = nil
	self.selectItem_itemobject = nil
    self.selectItem_itemlist = {}
    self.selectItem_itemSlotList = {}

    self.select_item = nil
	self.select_data = nil

	self.effect = nil
	self.base_id_dic = {}

    self.talisSlotList = {}
    self.selectItemSlotList = {}
    ------------------------------------------------
    self._update = function() self:update() end
	self._ChangeSuccess = function() self:ChangeSuccess() end
	self._onTalisData = function() self:update() end

	--self.talis_data_list_cli = TalismanManager.Instance.model.itemDic
	self.selectMaskType = 1   --默认选中可转换宝物
	

    self.OnOpenEvent:Add(function() self:OnShow() end)
	self.OnHideEvent:Add(function() self:OnHide() end)
end

function TalismanChangeWindow:__delete()
    if self.itemSlot1 ~= nil then
        self.itemSlot1:DeleteMe()
        self.itemSlot1 = nil
    end

    if self.itemSlot2 ~= nil then
        self.itemSlot2:DeleteMe()
        self.itemSlot2 = nil
	end
	
	if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end

    self.talisSlotList = {}

    for _, slot in pairs(self.selectItemSlotList) do
        slot:DeleteMe()
    end
    self.selectItemSlotList = {}

    self:OnHide()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end

	self:AssetClearAll()
	
end

function TalismanChangeWindow:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.TalismanChangeWindow))
    self.gameObject.name = "TalismanChangeWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.mainTransform = self.transform:FindChild("Main")

    self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
	self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)
	
	local transform = self.transform
	
    self.mainPanel = transform:FindChild("Main").gameObject
    self.selectItemPanel = transform:FindChild("ItemSelect").gameObject

	--top
	self.topArea = transform:Find("Main/ItemPanel/TopArea")

	self.topArea:Find("ItemBg1"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
	self.topArea:Find("ItemBg1").gameObject:SetActive(true)
	self.topArea:Find("ItemBg2"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
	self.topArea:Find("ItemBg2").gameObject:SetActive(true)

	self.name2 = self.topArea:FindChild("Name2").gameObject
    self.itemNameText1 = self.topArea:FindChild("Name1/Text"):GetComponent(Text)
    self.itemNameText2 = self.topArea:FindChild("Name2/Text"):GetComponent(Text)

	self.i18NText2 = self.topArea:FindChild("I18NText2").gameObject
	self.tipsText = self.topArea:FindChild("TipsText").gameObject

    --TipsManager.Instance:ShowTalisman({itemData = v , extra = {nobutton = true}})
	self.item1 = self.topArea:FindChild("Item1")
	self.item1_bg = self.item1:Find("Bg"):GetComponent(Image)
	self.item1_icon_loader = SingleIconLoader.New(self.item1:Find("Icon").gameObject)
	self.item1_set = self.item1:Find("Set"):GetComponent(Image)
	self.item1btn = self.item1:GetComponent(Button)

	self.item2 = self.topArea:FindChild("Item2")
	self.item2_bg = self.item2:Find("Bg"):GetComponent(Image)
	self.item2_icon_loader = SingleIconLoader.New(self.item2:Find("Icon").gameObject)
	self.item2_set = self.item2:Find("Set"):GetComponent(Image)
	self.item2btn = self.item2:GetComponent(Button)

	--self.item2.gameObject:GetComponent(Button).onClick:AddListener(function() self:Select_Changetalis() end)
    self.ChangeButton = self.topArea:FindChild("ChangeButton")
	self.ChangeButton:GetComponent(Button).onClick:AddListener(function() self:Select_Changetalis() end)

    --center
	self.centerArea = transform:Find("Main/ItemPanel/CenterArea")
	self.DescText = self.centerArea:FindChild("DescText"):GetComponent(Text)
	self.DescText.text = self.descString

	self.centerArea:FindChild("I18NText"):GetComponent(Text).text = TI18N("<color='#3166ad'>转换说明</color>")

	--down
	self.downArea = transform:Find("Main/ItemPanel/DownArea")

    self.okButton = self.downArea:FindChild("OkButton")
	self.okButton:GetComponent(Button).onClick:AddListener(function() self:OnOkButton() end)
	self.frozen = FrozenButton.New(self.okButton.gameObject,{timeout = 3})

    self.okButtonText = self.downArea:FindChild("OkButton/Text"):GetComponent(Text)
	self.timesText = self.downArea:FindChild("TimesText"):GetComponent(Text)

	self.needprice = self.downArea:FindChild("NeedAsset")
	self.needpriceLoader = SingleIconLoader.New(self.downArea:FindChild("NeedAsset/Price1/Currency").gameObject)
	self.needpriceText = self.downArea:FindChild("NeedAsset/Price1/Price"):GetComponent(Text)   --需要的数量
	--self.needpriceType = self.downArea:FindChild("NeedAsset/Price1/Currency"):GetComponent(Image)  --需要的货币类型
    self.goldprice = self.downArea:FindChild("OwnAsset")
	self.goldpriceText = self.downArea:FindChild("OwnAsset/Price1/Price"):GetComponent(Text)   --金币数/蓝钻数
	self.goldpriceLoader = SingleIconLoader.New(self.downArea:FindChild("OwnAsset/Price1/Currency").gameObject)
	--self.goldpriceType = self.downArea:FindChild("OwnAsset/Price1/Currency"):GetComponent(Image)  --金币数/蓝钻数类型
	self.diared = self.downArea:FindChild("OwnAsset2")
	self.diared.gameObject:SetActive(false)
	self.diaredpriceText = self.downArea:FindChild("OwnAsset2/Price1/Price"):GetComponent(Text)   --红钻数

	--gempanel
    self.container = transform:FindChild("Main/GemPanel/Mask/Container").gameObject
	self.talisitemobject = self.container.transform:FindChild("Item").gameObject
	self.talisitemobject.gameObject:SetActive(false)

    self.noitemtips = self.transform:FindChild("Main/GemPanel/NoItemTips").gameObject
    GameObject.Destroy(self.noitemtips:GetComponent(Button))
    
    --itemselect
	transform:FindChild("ItemSelect/Panel"):GetComponent(Button).onClick:AddListener(function() self:CloseSelectItemPanel() end)
	transform:FindChild("ItemSelect/CloseButton"):GetComponent(Button).onClick:AddListener(function() self:CloseSelectItemPanel() end)

	self.selectItem_container = transform:FindChild("ItemSelect/MainCon/Con/Layout").gameObject
	self.selectItem_itemobject = self.selectItem_container.transform:FindChild("Item").gameObject
	self.selectItem_itemobject:SetActive(false)

	transform:FindChild("ItemSelect/MainCon/Title/Text"):GetComponent(Text).text = TI18N("选择宝物")

    ----------------------------
    self:OnShow()
    self:ClearMainAsset()
end

function TalismanChangeWindow:OnClickClose()
    WindowManager.Instance:CloseWindow(self)
end

function TalismanChangeWindow:OnShow()

	EventMgr.Instance:AddListener(event_name.talis_change_success, self._ChangeSuccess)
    ClassesChangeManager.Instance.onTalisDataEvent:AddListener(self._onTalisData)
	ClassesChangeManager.Instance:Send10627()
	--self.model:SetTailsChangeData()
    --BaseUtils.dump(TalismanManager.Instance.model.itemDic,"TalismanManager.Instance.model.itemDic")
	--self:update()
end

function TalismanChangeWindow:OnHide()
	EventMgr.Instance:RemoveListener(event_name.talis_change_success, self._ChangeSuccess)
	ClassesChangeManager.Instance.onTalisDataEvent:RemoveListener(self._onTalisData)
end

function TalismanChangeWindow:update()
	self:update_talislist()
end

function TalismanChangeWindow:update_talislist()
	--local talismanModel = TalismanManager.Instance.model
	local talisdatalist = self.model.talisman_list_change
    local talislist = self.talislist
    local talisItemSlotList = self.talisItemSlotList
    local talisitemobject = self.talisitemobject
	local container = self.container

	local function sortfun(a,b)
		if a.canChange ~= b.canChange then
			return a.canChange > b.canChange
		elseif DataTalisman.data_get[a.base_id].quality ~= DataTalisman.data_get[b.base_id].quality then
			return DataTalisman.data_get[a.base_id].quality > DataTalisman.data_get[b.base_id].quality
		elseif DataTalisman.data_get[a.base_id].set_id ~= DataTalisman.data_get[b.base_id].set_id then
			return DataTalisman.data_get[a.base_id].set_id > DataTalisman.data_get[b.base_id].set_id
		end
	end
	table.sort(talisdatalist, sortfun)

	--BaseUtils.dump(talisdatalist,"talisdatalist")
	
	
	--talislist
    local selectItem = nil
	local selectData = nil
    for i = 1, #talisdatalist do
		local data = talisdatalist[i]
		local cfg_data = DataTalisman.data_get[data.base_id]
        local talisitem = talislist[i]
		if talisitem == nil then
			talisitem = {}
			local item = GameObject.Instantiate(talisitemobject)
			item:SetActive(true)
			item.transform:SetParent(container.transform)
			item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
			talisitem.gameObject = item

			--local itemGrid = TalismanGridItem.New(item:Find("AddItem"), self.assetWrapper)
			talisitem.itemGrid = item.transform:Find("AddItem")
            talisitem.itembg = talisitem.itemGrid:Find("Bg"):GetComponent(Image)
			talisitem.imgloader = SingleIconLoader.New(talisitem.itemGrid:Find("Icon").gameObject)
			talisitem.itemset = talisitem.itemGrid:Find("Set"):GetComponent(Image)
			talisitem.itemmask = talisitem.itemGrid:Find("Mask")

			talislist[i] = talisitem
		end
		
		talisitem.itembg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfg_data.quality)
		talisitem.imgloader:SetSprite(SingleIconType.Item, cfg_data.icon)
		talisitem.itemset.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfg_data.set_id))
		talisitem.itemset.transform.gameObject:SetActive(true)
		talisitem.itemmask.gameObject:SetActive(data.canChange == 0)
		local button = talisitem.itemGrid:GetComponent(Button)
        button.onClick:RemoveAllListeners()
		button.onClick:AddListener(function() 
			local sdata = self:GetTipsDataById(data.id) 
			if sdata ~= nil then
				TipsManager.Instance:ShowTalisman({itemData = sdata, extra = {nobutton = true}}) 
			end
		end)

        talisitem.gameObject.transform:FindChild("NameText"):GetComponent(Text).text = ColorHelper.color_item_name(cfg_data.quality, TalismanEumn.FormatQualifyName(cfg_data.quality, cfg_data.name))

        local button = talisitem.gameObject:GetComponent(Button)
        button.onClick:RemoveAllListeners()
        button.onClick:AddListener(function() self:OntalisItemClick(talisitem.gameObject, data) end)

        if selectItem == nil then
        	selectItem = talisitem.gameObject
        	selectData = data
        end
    end

    if #talisdatalist == 0 then
		self.noitemtips:SetActive(true)
		self.select_data = nil
		self:update_price()
	else
		self.noitemtips:SetActive(false)
	end

    if selectItem ~= nil and selectData ~= nil then
    	self:OntalisItemClick(selectItem, selectData)
    end
end

function TalismanChangeWindow:OntalisItemClick(item, data)
	--BaseUtils.dump(data, "OntalisItemClick")
	if self.select_item ~= nil then
		self.select_item.transform:FindChild("Select").gameObject:SetActive(false)
	end
	self.select_item = item
	self.select_data = data
	self.targetData = nil

	self.select_item.transform:FindChild("Select").gameObject:SetActive(true)

	self:update_talisinfo()
end

--更新右侧上方第一个宝物数据
function TalismanChangeWindow:update_talisinfo()
	local cfg_data = nil
	if self.select_data ~= nil then
		cfg_data = DataTalisman.data_get[self.select_data.base_id]
	end
    --local cfg_data = self.select_data
	self.itemNameText1.text = ColorHelper.color_item_name(cfg_data.quality, TalismanEumn.FormatQualifyName(cfg_data.quality, cfg_data.name))

	self.item1_bg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfg_data.quality)
	self.item1_icon_loader:SetSprite(SingleIconType.Item, cfg_data.icon)
	self.item1_set.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfg_data.set_id))
	self.item1_set.transform.gameObject:SetActive(true)
	--设置第二个展示格
	local targetData = nil
	if next(self.select_data.canChangeList) ~= nil then
		local targetId = self.select_data.canChangeList[1]
		--targetData 取表数据，因为协议数据里面不存在
		targetData = DataTalisman.data_get[targetId]
	end
	self:Select_Changetalis_CallBack(targetData)
end


function TalismanChangeWindow:Select_Changetalis()
	if self.select_data == nil or self.select_data.canChange == 0 then
		NoticeManager.Instance:FloatTipsByString("当前宝物没有可转换的目标宝物")
	else
		self.mainPanel:SetActive(false)
		self.selectItemPanel:SetActive(true)
		if self.effect ~= nil then
			self.effect:SetActive(false)
		end

		local base_id_dic = self.select_data.canChangeList

		-- 刷新显示列表
	    for i = 1, #base_id_dic do
	        local cfg_data = DataTalisman.data_get[base_id_dic[i]]
	        local item = self.selectItem_itemlist[i]
			if item == nil then
				item = {}
				local tempItem = GameObject.Instantiate(self.selectItem_itemobject)
				tempItem:SetActive(true)
				tempItem.transform:SetParent(self.selectItem_container.transform)
				tempItem:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
				item.gameObject = tempItem

				item.itemGrid = item.gameObject.transform:Find("AddItem")
                item.itembg = item.itemGrid:Find("Bg"):GetComponent(Image)
			    item.imgloader = SingleIconLoader.New(item.itemGrid:Find("Icon").gameObject)
			    item.itemset = item.itemGrid:Find("Set"):GetComponent(Image)
			    item.itemmask = item.itemGrid:Find("Mask")

			    self.selectItem_itemlist[i] = item
		    end
		
			item.itembg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. cfg_data.quality)
			item.imgloader:SetSprite(SingleIconType.Item, cfg_data.icon)
			item.itemset.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(cfg_data.set_id))
			item.itemset.transform.gameObject:SetActive(true)
			item.itemmask.gameObject:SetActive(cfg_data.canChange == 0)
			

			local curTipsData = self:GetVirtualData(cfg_data)
			local button = item.itemGrid:GetComponent(Button)
			button.onClick:RemoveAllListeners()
			button.onClick:AddListener(function() 
				if curTipsData ~= nil then
					TipsManager.Instance:ShowTalisman({itemData = curTipsData , extra = {nobutton = true}})
				end
			end)

			item.gameObject.transform:FindChild("name"):GetComponent(Text).text = ColorHelper.color_item_name(cfg_data.quality, TalismanEumn.FormatQualifyName(cfg_data.quality, cfg_data.name))

	        local button = item.gameObject:GetComponent(Button)
	        button.onClick:RemoveAllListeners()
	        button.onClick:AddListener(function() self:Select_Changetalis_CallBack(cfg_data) end)
	    end

	    if #base_id_dic+1 <= #self.selectItem_itemlist then
		    for i=#base_id_dic+1, #self.selectItem_itemlist do
		    	local item = self.selectItem_itemlist[i].gameObject
		    	item.gameObject:SetActive(false)
		    end
		end
	end
end

function TalismanChangeWindow:CloseSelectItemPanel()
	self.mainPanel:SetActive(true)
	self.selectItemPanel:SetActive(false)
end

function TalismanChangeWindow:Select_Changetalis_CallBack(data)
	--根据目标宝物 data 读表读出属性构造 Tipsdata
	-- curTipsData  转换后tips数据
	--sourceTipsData  转换前tips数据
	local sourceTipsData = nil   --转换前tips
	local curTipsData = nil      --转换后tips
	sourceTipsData = self:GetTipsDataById(self.select_data.id)
	self.item1btn.onClick:RemoveAllListeners()
	self.item1btn.onClick:AddListener(function() TipsManager.Instance:ShowTalisman({itemData = sourceTipsData , extra = {nobutton = true}}) end)
	
	curTipsData = self:GetVirtualData(data)
	self.item2btn.onClick:RemoveAllListeners()
	self.item2btn.onClick:AddListener(function()
		if curTipsData ~= nil then
			TipsManager.Instance:ShowTalisman({itemData = curTipsData , extra = {nobutton = true}})
		end
	end)
	--根据第一宝物数据 得到第二宝物数据(表数据)
	local canChange = false
	if data ~= nil then
		self.targetData = data
        canChange = true
		self.itemNameText2.text = ColorHelper.color_item_name(data.quality, TalismanEumn.FormatQualifyName(data.quality, data.name))
		self.name2:SetActive(true)

		self.item2_bg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level" .. data.quality)
		self.item2_icon_loader:SetSprite(SingleIconType.Item, data.icon)
		self.item2:Find("Icon").gameObject:SetActive(true)

		self.item2_set.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_set, tostring(data.set_id))
		self.item2_set.gameObject:SetActive(true)

		self.tipsText:SetActive(false)
		self.ChangeButton.gameObject:SetActive(true)
		self.i18NText2:SetActive(true)
	else
		self.name2:SetActive(false)
		self.item2_bg.sprite = self.assetWrapper:GetSprite(AssetConfig.talisman_textures, "Level2")

		self.item2:Find("Icon").gameObject:SetActive(false)
		self.item2_set.gameObject:SetActive(false)

		self.tipsText:SetActive(true)
		self.ChangeButton.gameObject:SetActive(false)
		self.i18NText2:SetActive(false)
	end
	if canChange then
		self:ChangeDescText(1)
		self:update_price(1)
	else
		self:ChangeDescText(2)
		self:update_price(2)
	end
	self:CloseSelectItemPanel()
end

function TalismanChangeWindow:ChangeDescText(index)
	if index == 1 and self.selectMaskType == 2 then
		self.DescText.text = self.descString
	elseif index == 2 and self.selectMaskType == 1 then
		self.DescText.text = self.descString2
	end
	self.selectMaskType = index
end

function TalismanChangeWindow:update_price(index)
	--设置价格
	self.timesText.text = ""
	self.needpriceLoader.gameObject.transform.sizeDelta = Vector2(32, 32)
	local roledata = RoleManager.Instance.RoleData
	if index == 1 then
		self.okButtonText.text = TI18N("转换")
		self.okButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")

		local selectQuality = DataTalisman.data_get[self.select_data.base_id].quality
		local costData = DataTalisman.data_get_covert_cost[selectQuality]
		local costType = costData.pay_type
		local costNum = costData.num
		if costType == 90003 then
            self.needpriceText.text = tostring(costNum)
			self.goldpriceText.text = tostring(roledata.gold_bind)
			self.needpriceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[costType].icon)
			self.goldpriceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[costType].icon)

			self.needprice.anchoredPosition = Vector2(-82, 20.5)
			self.goldprice.anchoredPosition = Vector2(-82, -18.4)

            self.diared.gameObject:SetActive(false)
		elseif costType == 29255 then
			self.needpriceLoader.gameObject.transform.sizeDelta = Vector2(40, 40)
			--self.totalCurrencyLoader:SetSprite(SingleIconType.Item, DataItem.data_get[model.infoCurrencyType].icon)
			self.needpriceText.text = tostring(costNum)
			self.goldpriceText.text = tostring(roledata.gold)
			self.diaredpriceText.text = tostring(roledata.star_gold)

			self.needpriceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[costType].icon)
			self.goldpriceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[90002].icon)
			self.needprice.anchoredPosition = Vector2(-82, 31.8)
			self.goldprice.anchoredPosition = Vector2(-82, 0.1)
			self.diared.anchoredPosition = Vector2(-82, -31.7)
			self.diared.gameObject:SetActive(true)
		end
	elseif index == 2 then
		self.okButtonText.text = TI18N("无法转换")
		self.okButton:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
		self.needpriceText.text = "0"
		self.goldpriceText.text = tostring(roledata.gold_bind)
		self.needpriceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[90003].icon)
		self.goldpriceLoader:SetSprite(SingleIconType.Item, DataItem.data_get[90003].icon)
        self.needprice.anchoredPosition = Vector2(-82, 20.5)
		self.goldprice.anchoredPosition = Vector2(-82, -18.4)

        self.diared.gameObject:SetActive(false)
	end
end

function TalismanChangeWindow:OnOkButton()
	if self.select_data == nil then
		NoticeManager.Instance:FloatTipsByString("你没有选择要转换的宝物")
		return
	end
	if self.targetData == nil then
		NoticeManager.Instance:FloatTipsByString("不符合转换条件")
		return
	end
	--发送协议
	ClassesChangeManager.Instance:Send10628(self.select_data.id, self.select_data.base_id, self.targetData.base_id)
	self.frozen:OnClick()
end

--转换成功处理
function TalismanChangeWindow:ChangeSuccess()
	print("ChangeSuccess")
	if self.effect == nil then
	    local fun = function(effectView)
	        local effectObject = effectView.gameObject

	        self.washEffect = effectObject

	        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

	        effectObject.transform:SetParent(self.transform:FindChild("Main/ItemPanel/TopArea/Item1"))
	        effectObject.transform.localScale = Vector3(1, 1, 1)
	        effectObject.transform.localPosition = Vector3(0, 0, -400)
	        effectObject.transform.localRotation = Quaternion.identity

	        self.effect = effectView
	    end
	    self.effect = BaseEffectView.New({effectId = 20049, time = nil, callback = fun})
	else
		self.effect:SetActive(false)
		self.effect:SetActive(true)
	end
end

--根据唯一id取宝物数据
function TalismanChangeWindow:GetTipsDataById(id)
	local targetData = nil
	for i,v in pairs(TalismanManager.Instance.model.itemDic) do
		if v.id == id then
            targetData = v
		end
	end
	return targetData
end

--废弃，基础id会取重复数据
function TalismanChangeWindow:GetTipsDataByBaseId(baseId)
	local targetData = nil
	for i,v in pairs(TalismanManager.Instance.model.itemDic) do
		if v.base_id == baseId then
            targetData = v
		end
	end
	return targetData
end

function TalismanChangeWindow:GetVirtualData(data)
	local sourceTipsData = nil   --转换前tips
	local curTipsData = nil      --转换后tips
	local baseAttr = {}
	if self.select_data ~= nil and data ~= nil then
		sourceTipsData = self:GetTipsDataById(self.select_data.id)
		baseAttr = DataTalisman.data_get[data.base_id].base_attr
		if sourceTipsData ~= nil then
			curTipsData = BaseUtils.copytab(sourceTipsData)
			curTipsData.base_id = data.base_id
			for i = #curTipsData.attr, 1, -1 do
				if curTipsData.attr[i].type == 7 then
					--基础属性
					table.remove(curTipsData.attr, i)
				end
			end
			for i = #baseAttr, 1, -1 do
				local tempData = {
					type = 7,
					val = baseAttr[i].val,
					name = baseAttr[i].key,
					flag = 10000,
				}
				table.insert(curTipsData.attr, tempData)
			end
			-- for _ , j in pairs(baseAttr) do
			-- 	local tempData = {
			-- 		type = 7,
			-- 		val = j.val,
			-- 		name = j.key,
			-- 		flag = 10000,
			-- 	}
			-- 	table.insert(curTipsData.attr, tempData)
			-- end
		end
	end
	return curTipsData
end
