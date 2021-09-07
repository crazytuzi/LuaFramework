ShouhuTransferItem = ShouhuTransferItem or BaseClass()

function ShouhuTransferItem:__init(parent, origin_item, index)
    self.index = index
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.gameObject.transform.localScale = Vector3.one
    self.gameObject:SetActive(true)

    local go = self.gameObject
    self.HeadImg = go.transform:Find("ItemSlot1/ItemImg"):GetComponent(Image)
    --self.HeadLoader = SingleIconLoader.New(tab.HeadImg.gameObject)
    self.ClassesImg = go.transform:Find("ClassesIcon"):GetComponent(Image)
    self.Name = go.transform:Find("Name"):GetComponent(Text)
    self.ScoreImg = go.transform:Find("Score/Image"):GetComponent(Image)
    self.ScoreNum = go.transform:Find("Score/ScoreNum"):GetComponent(Text)
    self.GemsLevel = go.transform:Find("GemsLevel"):GetComponent(Text)
    self.StatusText = go.transform:Find("StatusText"):GetComponent(Text)
    self.lock = go.transform:Find("ItemSlot1/Lock")

    self.ImgSelected = go.transform:FindChild("ImgSelected"):GetComponent(Image)
    self.ImgSelected.gameObject:SetActive(false)

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self:ClickItem(index) end)
end


function ShouhuTransferItem:SetData(data)
    self.HeadImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.guard_head, tostring(data.avatar_id))
    self.ClassesImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" .. data.classes)
    self.Name.text = data.name
    self.ScoreImg.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.shouhu_texture, string.format("WakeUpStartIcon%s", data.quality))
    self.ScoreNum.text = data.score or 0
    self.GemsLevel.text = self.parent.model:GetLowerGemsLevel(data)  --model里检测该守护的最低的宝石等级
    local colorChange = false
    local status = ""
    if data.quality >= 4 then
       --model 里检测是否每个宝石都大于1级
        if self.parent.model:CheckAllGemsBiggerOne(data) then
            status = TI18N("<color='#239901'>可转换</color>")
        else
            colorChange = true
            status = TI18N("<color='#F4191D'>宝石需≥1级</color>")
        end
    else
        colorChange = true
        status = TI18N("<color='#F4191D'>需橙色品阶</color>")
    end
    self.StatusText.text = status

    if colorChange == true then
        self.lock.gameObject:SetActive(true)
        self.Name.color = Color(139/255, 141/255, 142/255, 1)
        self.ScoreNum.color = Color(139/255, 141/255, 142/255, 1)
        self.GemsLevel.color = Color(139/255, 141/255, 142/255, 1)
    else
        self.lock.gameObject:SetActive(false)
        self.Name.color = Color(12/255, 82/255, 176/255, 1)
        self.ScoreNum.color = Color(12/255, 82/255, 176/255, 1)
        self.GemsLevel.color = Color(12/255, 82/255, 176/255, 1)
    end

end


--设置显示状态
function ShouhuTransferItem:SetActive(state)
    --self.showState = state
    --self.gameObject:SetActive(state)
end

function ShouhuTransferItem:ClickItem(index)
    self.parent:ClickItem(index)
end

function ShouhuTransferItem:ClickcallBack(status)
    self.ImgSelected.gameObject:SetActive(status)
end