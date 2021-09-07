-- @author 黄耀聪
-- @date 2017年6月22日, 星期四

GloryVideoItem = GloryVideoItem or BaseClass()

function GloryVideoItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform

    local t = self.transform

    self.bg = gameObject:GetComponent(Image)
    self.select = t:Find("Select").gameObject
    self.headImage = t:Find("Player/Head/Image"):GetComponent(Image)
    self.nameText = t:Find("Player/Name"):GetComponent(Text)
    self.turnText = t:Find("Turn"):GetComponent(Text)
    self.videoBtn = t:Find("Video"):GetComponent(Button)

    self.videoBtn.onClick:AddListener(function() self:OnClickVideo() end)
end

function GloryVideoItem:__delete()
    if self.headImage ~= nil then
        self.headImage.sprite = nil
    end
    self.gameObject = nil
    self.model.selectIndex = nil
    self.model.selectVideo = nil
    self.model = nil
end

function GloryVideoItem:update_my_self(data, index)
    self.index = index
    self.data = data

    self.headImage.sprite = PreloadManager.Instance:GetClassesHeadSprite(data.atk_classes, data.atk_sex)
    self.nameText.text = data.atk_name
    self.turnText.text = string.format(TI18N("%s回合"), data.round)

    self.select:SetActive(self.index == self.model.selectIndex)
    if index % 2 == 1 then
        self.bg.color = ColorHelper.ListItem1
    else
        self.bg.color = ColorHelper.ListItem2
    end
end

function GloryVideoItem:SetData(data, index)
    self:update_my_self(data, index)
end

function GloryVideoItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function GloryVideoItem:OnClick()
    if self.model.selectVideo ~= nil then
        self.model.selectVideo:SetActive(false)
    end
    self.select:SetActive(true)
    self.model.selectIndex = self.index
    self.model.selectVideo = self.select
end

function GloryVideoItem:OnClickVideo()
    if self.data ~= nil then
        CombatManager.Instance:Send10744(self.data.type, self.data.rec_id, self.data.platform, self.data.zone_id)
    end
end

