ArenaFellowItem = ArenaFellowItem or BaseClass()

function ArenaFellowItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.assetWrapper = assetWrapper


    local t = gameObject.transform
    self.iconImage = t:Find("Icon/Image"):GetComponent(Image)
    self.infoText = t:Find("Info"):GetComponent(Text)
    self.scoreText = t:Find("ScoreBg/Text"):GetComponent(Text)
    self.scoreImage = t:Find("ScoreBg/Cup"):GetComponent(Image)
    self.battleBtn = t:Find("Battle"):GetComponent(Button)
    self.guardBtn = t:Find("ShowTips"):GetComponent(Button)
    self.star1 = t:Find("Star1").gameObject
    self.star2 = t:Find("Star2").gameObject
end

function ArenaFellowItem:SetData(data, index)
    self.star1:SetActive(false)
    self.star2:SetActive(false)

    if data == nil then
        self:SetActive(false)
        return
    end
    self.scoreImage.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon1001")

    if data.classes > 0 then
        self.iconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
        self.infoText.text = data.lev.. TI18N("级 ")..KvData.classes_name[data.classes]
        self.scoreText.text = tostring(data.cup)
    else
        self.iconImage.sprite = self.assetWrapper:GetSprite(AssetConfig.arena_textures, "Unknow")
        self.infoText.text = "??".. TI18N("级 <color=#EE00EE>神秘高手</color>")
        self.scoreText.text = "?????"
    end
    self.iconImage.gameObject:SetActive(true)

    self.battleBtn.onClick:RemoveAllListeners()
    self.battleBtn.onClick:AddListener(function()
        local fellow = self.model:GetFellow(index)
        if fellow ~= nil then
            if self.model.has_soul < self.model.max_soul then
                ArenaManager.Instance:send12201({order = index})
            else
                local confirmData = NoticeConfirmData.New()
                confirmData.type = ConfirmData.Style.Normal
                confirmData.content = TI18N("当前战魂已满，领取奖励之前将不能得到新战魂，是否继续挑战？")
                confirmData.sureLabel = TI18N("确 定")
                confirmData.cancelLabel = TI18N("取 消")
                confirmData.sureCallback = function() ArenaManager.Instance:send12201({order = index}) end
                NoticeManager.Instance:ConfirmTips(confirmData)
            end
        end
    end)
    self.guardBtn.onClick:RemoveAllListeners()
    -- self.guardBtn.onClick:AddListener(function() self.model:OpenGuardTips(index) end)

    for i=1,data.soul do
        self["star"..(3 - i)]:SetActive(true)
    end

    self:SetActive(true)
end

function ArenaFellowItem:__delete()
    self.iconImage.sprite = nil
    self.scoreImage.sprite = nil
    self.iconImage = nil
    self.scoreImage = nil
end

function ArenaFellowItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end
