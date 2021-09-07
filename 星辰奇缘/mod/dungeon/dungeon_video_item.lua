-- @author 黄耀聪
-- @date 2016年7月11日

DungeonVideoItem = DungeonVideoItem or BaseClass()

function DungeonVideoItem:__init(model, gameObject, assetWrapper)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.assetWrapper = assetWrapper

    local t = self.transform
    self.bgObj = t:Find("Bg").gameObject
    self.rankImage = t:Find("Rank/Image"):GetComponent(Image)
    self.rankText = t:Find("Rank"):GetComponent(Text)
    self.iconImage = t:Find("Character/Icon/Image"):GetComponent(Image)
    self.nameText = t:Find("Character/Name"):GetComponent(Text)
    self.select = t:Find("Select").gameObject
    self.timeText = t:Find("Time/Text"):GetComponent(Text)
    self.videoBtn = t:Find("Video/Button"):GetComponent(Button)

    self.videoBtn.onClick:AddListener(function() self:OnVideo() end)
end

function DungeonVideoItem:__delete()
end

function DungeonVideoItem:update_my_self(data, index)
    self.data = data
    if data == nil then
        self.gameObject:SetActive(false)
        return
    end
    self.bgObj:SetActive(index % 2 == 1)
    self.gameObject:SetActive(true)
    self.nameText.text = data.name
    local h = 0
    local m = 0
    local s = 0
    _,h,m,s = BaseUtils.time_gap_to_timer(data.val1)
    if h > 0 then
        self.timeText.text = string.format(TI18N("%s时%s分%s秒"), tostring(h), tostring(m), tostring(s))
    else
        self.timeText.text = string.format(TI18N("%s分%s秒"), tostring(m), tostring(s))
    end
    if index < 4 then
        self.rankImage.sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, "place_"..index)
        self.rankImage.gameObject:SetActive(true)
        self.rankText.text = ""
    else
        self.rankImage.gameObject:SetActive(false)
        self.rankText.text = tostring(index)
    end
    self.iconImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, data.classes.."_"..data.sex)
end

function DungeonVideoItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function DungeonVideoItem:OnVideo()
    if self.data ~= nil then
        CombatManager.Instance:Send10744(11, self.data.val3, self.data.msg1, self.data.val4)
        self.model:CloseVideoWindow()
    end
end

