-- --------------------------
-- 分享绑定和领取奖励界面每项元素
-- hosr
-- --------------------------
ShareBindItem = ShareBindItem or BaseClass()

function ShareBindItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self.hasGain = false
	self.isLimit = true

	self.itemList = {}

	self:InitPanel()
end

function ShareBindItem:__delete()
	if self.btnImg ~= nil then
		self.btnImg.sprite = nil
		self.btnImg = nil
	end

    for _, itemSlot in pairs(self.itemList) do
        itemSlot:DeleteMe()
    end
    self.itemList = {}
end

function ShareBindItem:InitPanel()
	self.transform = self.gameObject.transform

	self.title = self.transform:Find("Title/Text"):GetComponent(Text)
	self.btn = self.transform:Find("Button"):GetComponent(Button)
	self.btnTxt = self.transform:Find("Button/Text"):GetComponent(Text)
	self.btnImg = self.transform:Find("Button"):GetComponent(Image)
	self.desc = self.transform:Find("Desc"):GetComponent(Text)
	self.descObj = self.desc.gameObject

	local grid = self.transform:Find("Grid")
	local len = grid.childCount
	for i = 1, len do
		local obj = grid:GetChild(i - 1)
	    local slot = ItemSlot.New()
	    UIUtils.AddUIChild(obj.gameObject, slot.gameObject)
	    table.insert(self.itemList, slot)
	    slot.gameObject:SetActive(false)
	end

	self.btn.onClick:AddListener(function() self:ClickBtn() end)
end

function ShareBindItem:update_my_self(data)
	self.data = data

	self.hasGain = false
	self.isLimit = true
	if ShareManager.Instance.gainList[self.data.id] ~= nil then
		self.hasGain = true
	end

	self.title.text = self.data.desc

	if self.hasGain then
		self.btnTxt.text = TI18N("已领取")
		self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
	else
		if RoleManager.Instance.RoleData.lev >= self.data.need_lev and ShareManager.Instance.shareData.apply_key ~= "" then
			self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
			self.btnTxt.text = TI18N("领取奖励")
			self.isLimit = false

		else
			if self.data.id == 0 then
				self.btnTxt.text = TI18N("填写邀请码")
				self.isLimit = false
				self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
			else
				self.btnTxt.text = string.format(TI18N("%s级领取"), self.data.need_lev)
				self.btnImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
			end
		end
	end

	self.descObj:SetActive(false)
	if self.data.id == 0 and ShareManager.Instance.shareData ~= nil and ShareManager.Instance.shareData.apply_name ~= nil and ShareManager.Instance.shareData.apply_name ~= "" then
		-- 绑定奖励，显示推广员名称
		self.descObj:SetActive(true)
		self.desc.text = string.format(TI18N("推广员:<color='#d781f2'>%s</color>"), ShareManager.Instance.shareData.apply_name)
	end

	self:ShowReward()
end

function ShareBindItem:ShowReward()
	local list = {}
	local lev = RoleManager.Instance.RoleData.lev
	local sex = RoleManager.Instance.RoleData.sex
	local classes = RoleManager.Instance.RoleData.classex
	for i,v in ipairs(self.data.gain_list) do
		if (v[1] == 0 or v[1] == classes) and (v[2] == sex or v[2] == 2) then
			table.insert(list, {baseId = v[3], bind = v[4], num = v[5]})
		end
	end

	for i,v in ipairs(list) do
		local slot = self.itemList[i]
		local baseId = v.baseId
		local num = v.num
		local bind = v.bind
		local itemData = ItemData.New()
		itemData:SetBase(BaseUtils.copytab(DataItem.data_get[baseId]))
	    slot:SetAll(itemData)
	    slot:SetNum(num)
	    slot.gameObject:SetActive(true)
	end
end

function ShareBindItem:ClickBtn()
	if self.data ~= nil and not self.isLimit then
		if self.data.id == 0 then
			if RoleManager.Instance.RoleData.lev >= self.data.need_lev and ShareManager.Instance.shareData.apply_key ~= "" then
				ShareManager.Instance:Send17504(self.data.id)
			else
				ShareManager.Instance.model:OpenTipsPanel()
			end
		else
			ShareManager.Instance:Send17504(self.data.id)
		end
	end
end