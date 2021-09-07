-- --------------------------
-- 时装tips
-- hosr
-- --------------------------
FashionTips = FashionTips or BaseClass()

function FashionTips:__init(transform, parent)
	self.transform = transform
	self.gameObject = transform.gameObject
	self.parent = parent
	self.gameObject:SetActive(false)

	self.attrList = {}
	self:InitPanel()
end

function FashionTips:__delete()
	self.icon.sprite = nil
	for i,v in ipairs(self.attrList) do
		v.icon.sprite = nil
	end
	self.attrList = nil
end

function FashionTips:Close()
	self.icon.sprite = nil
	for i,v in ipairs(self.attrList) do
		v.icon.sprite = nil
	end
	self.gameObject:SetActive(false)
end

function FashionTips:InitPanel()
	self.main = self.transform:Find("Main")

	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
	self.transform:Find("Main"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
	self.transform:Find("Main/Bg"):GetComponent(Image).sprite = self.parent.assetWrapper:GetSprite(AssetConfig.effectbg, "EffectBg")

	self.title = self.transform:Find("Main/Title/Text"):GetComponent(Text)
	self.icon = self.transform:Find("Main/Icon"):GetComponent(Image)

	for i = 1, 3 do
		local item = self.transform:Find("Main/Text" .. i)
		table.insert(self.attrList, {obj = item.gameObject, txt = item:GetComponent(Text), icon = item:Find("Icon"):GetComponent(Image)})
	end
end

-- 传入时装配置数据
function FashionTips:Show(data)
	self.data = data.data
	self.title.text = self.data.name
    if self.data.base_id < 52001 then
        self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.fashion_big_icon, tostring(self.data.base_id))
    else
        self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.fashion_big_icon2, tostring(self.data.base_id))
    end

    for i,v in ipairs(self.attrList) do
    	v.obj:SetActive(false)
    end

    for i,v in ipairs(self.data.attrs) do
    	local item = self.attrList[i]
    	item.obj:SetActive(true)
    	item.txt.text = string.format("%s:<color='#00ff00'>%s</color>", KvData.attr_name[v.effect_type], v.val)
    	item.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon" .. v.effect_type)
    end

    self.main.position = data.transform.position
	self.gameObject:SetActive(true)
end
