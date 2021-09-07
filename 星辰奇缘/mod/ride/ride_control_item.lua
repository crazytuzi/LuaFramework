RideControlItem = RideControlItem or BaseClass()

function RideControlItem:__init(parent, origin_item, index)
    self.index = index
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one


    --根据index 设置gameObject的位置
    local new_x = 0
    local new_y = 0
    local index_x = index%2
    local index_y = math.floor(index/2)
    new_x = index_x > 0 and 12 or 254
    new_y = -13 + (-87*(index_y+index_x -1))
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(new_x, new_y)

    self.gameObject:SetActive(true)

    self.ImgHeadBg = self.transform:FindChild("ImgHeadBg")
    self.ImgHead = self.ImgHeadBg:FindChild("ImgHead"):GetComponent(Image)
    self.ImgHead.gameObject:SetActive(false)

    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtLev = self.transform:FindChild("TxtLev"):GetComponent(Text)
    self.ImgClose = self.transform:FindChild("ImgClose"):GetComponent("Button")

    self.ImgClose.gameObject:SetActive(false)

    self.item_btn = self.transform:GetComponent(Button)
    self.item_btn.onClick:AddListener(function()
        RideManager.Instance:Send16406(self.ride_data.index, self.pet_id)
    end)
    self.ImgClose.onClick:AddListener(function()
        RideManager.Instance:Send16406(self.ride_data.index, self.pet_id)
    end)
end


function RideControlItem:__delete()
    if self.headLoader ~= nil then
        self.headLoader:DeleteMe()
        self.headLoader = nil
    end
end

function RideControlItem:Release()
end

function RideControlItem:set_item_data(pet_id, ride_data, _type)
    self.type = _type
    self.pet_id = pet_id
    self.ride_data = ride_data

    local pet_data = nil
    for i=1,#PetManager.Instance.model.petlist do
        local temp_data = PetManager.Instance.model.petlist[i]
        if temp_data.base.id == pet_id then
            pet_data = temp_data
            break
        end
    end

    if _type == 1 then
        self.ImgClose.gameObject:SetActive(true)
    else
        self.ImgClose.gameObject:SetActive(false)
    end

    self.TxtName.text = pet_data.name
    self.TxtLev.text = string.format("Lv.%s", pet_data.lev)


    if self.headLoader == nil then
        self.headLoader = SingleIconLoader.New(self.ImgHead.gameObject)
    end
    self.headLoader:SetSprite(SingleIconType.Pet, pet_data.base.head_id)
    -- self.ImgHead.sprite = PreloadManager.Instance:GetSprite(BaseUtils.PetHeadPath(pet_data.base.head_id), tostring(pet_data.base.head_id))
    self.ImgHead.gameObject:SetActive(true)
end