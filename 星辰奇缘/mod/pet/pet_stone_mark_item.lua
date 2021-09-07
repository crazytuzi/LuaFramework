--2016/7/21
--zzl
--宠物符石刻印
PetStoneMarkItem = PetStoneMarkItem or BaseClass()

function PetStoneMarkItem:__init(gameObject, parent)
    self.gameObject = gameObject
    self.data = nil
    self.parent = parent

    -- self.gameObject:SetActive(true)
    self.transform = self.gameObject.transform

    self.index = index
    self.gameObject = gameObject
    self.Img = gameObject.transform:Find("ImgHead"):Find("Img"):GetComponent(Image)
    self.TxtPetName = gameObject.transform:Find("TxtPetName"):GetComponent(Text)
    self.TxtStoneName = gameObject.transform:Find("TxtStoneName"):GetComponent(Text)

    self.ImgSelected = gameObject.transform:Find("ImgSelected").gameObject
    self.ImgSelected:SetActive(false)

    gameObject.transform:GetComponent(Button).onClick:AddListener(function()
        self:OnClickLeftItem(self)
    end)

end

function PetStoneMarkItem:Release()
    self.Img.sprite = nil
end

function PetStoneMarkItem:__delete()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
end


function PetStoneMarkItem:update_my_self(data)
    self.data = data
    self.petData = BaseUtils.copytab(data.petData)
    self.stoneData = BaseUtils.copytab(data.stoneData)

    local baseData = DataItem.data_get[self.stoneData.base_id]
    local petNameStr = self.petData.name
    local stoneNameStr = ColorHelper.color_item_name(baseData.quality , baseData.name)
    self.TxtPetName.text = petNameStr
    self.TxtStoneName.text = stoneNameStr

    --设置头像
    local headId = tostring(self.petData.base.head_id)
    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.Img.gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet,headId)

    -- self.Img.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(headId), headId)
    self.Img.gameObject:SetActive(true)

    self.ImgSelected:SetActive(false)

    if self.parent.model.curPetStoneMarkData ~= nil then
        if self.parent.model.curPetStoneMarkData.petData.id == self.petData.id and self.parent.model.curPetStoneMarkData.stoneData.id == self.stoneData.id then
            self.parent:UpdateRight(self)
        end
    end
end

function PetStoneMarkItem:OnClickLeftItem(item)
    self.parent:UpdateRight(item)
end