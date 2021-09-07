-- --------------------------------------
-- 好声音支持记录项
-- hosr
-- --------------------------------------
SingSupportItem = SingSupportItem or BaseClass()

function SingSupportItem:__init(gameObject, parent)
	self.gameObject = gameObject
	self.parent = parent

	self:InitPanel()
end

function SingSupportItem:__delete()
	self.gameObject = nil
	self.parent = nil
	self.icon.sprite = nil
end

function SingSupportItem:InitPanel()
	self.transform = self.gameObject.transform
	self.icon = self.transform:Find("Icon"):GetComponent(Image)
	self.content = self.transform:Find("Content"):GetComponent(Text)
end

function SingSupportItem:update_my_self(data)
    if data.type == 1 then
        -- 投票
        self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.sing_res, "SingBtnIcon4")
        self.content.text = string.format(TI18N("<color='#00ff00'>%s</color>给予了<color='#00ff00'>%s点</color>好评"), data.name, data.val)
    elseif data.type == 2 then
        -- 送花
        self.icon.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.sing_res, "SingBtnIcon3")
        self.content.text = string.format(TI18N("<color='#00ff00'>%s</color>送来一束鲜花，增加了<color='#00ff00'>%s点</color>好评"), data.name, data.val)
    end
    self.icon:SetNativeSize()
end