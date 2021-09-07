FashionSuitItem = FashionSuitItem or BaseClass()

function FashionSuitItem:__init(parent, origin_item, index)
    self.index = index
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one

    self.timer_id = 0
    --根据index 设置gameObject的位置
    local new_x = 0
    local new_y = 0

    local index_x = index%3
    local index_y = math.ceil(index/3)
    new_x = index_x == 0 and 192 or (index_x == 1 and 4 or 98)
    new_y = -13 + (-100*(index_y - 1))
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(new_x, new_y)

    self.gameObject:SetActive(true)

    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.ConIcon = self.transform:FindChild("ConIcon").gameObject
    self.SlotCon = self.ConIcon.transform:FindChild("SlotCon"):GetComponent(Image)
    self.ImgHasGot = self.ConIcon.transform:FindChild("ImgHasGot").gameObject
    self.ImgHuali = self.transform:FindChild("ImgHuali").gameObject
    self.ClockCon = self.transform:FindChild("ClockCon")
    self.ImgBgTxtCloth = self.ClockCon:FindChild("ImgBg")
    self.TxtCloth = self.ImgBgTxtCloth:FindChild("TxtCloth"):GetComponent(Text)
    self.ImgSelected = self.transform:FindChild("ImgSelected"):GetComponent(Image)
    self.ImgSelected.gameObject:SetActive(true)
    self.ImgUnActive = self.ConIcon.transform:FindChild("ImgUnActive").gameObject
    self.ImgHasGot.transform:GetComponent(RectTransform).sizeDelta = Vector2(43, 21.6)
    self.ImgUnActive.transform:GetComponent(RectTransform).sizeDelta = Vector2(43, 21.6)
    self.ImgHuali:SetActive(false)
    self.hasAttr = self.transform:Find("HasAttr").gameObject
    self.specialMark100 = self.transform:Find("SpecialMark100").gameObject

    self.gameObject_btn = self.transform:GetComponent(Button)
    self.gameObject_btn.onClick:AddListener(function() self:ClickSelf() end)
    self.imgLoader = nil
end

function FashionSuitItem:Release()
    self:stop_timer()
    -- self.ConIcon.transform:FindChild("SlotCon"):GetComponent(Image).sprite = nil
end

function FashionSuitItem:Refresh(args)

end

function FashionSuitItem:InitPanel(_data)

end

function FashionSuitItem:set_item_data(data)
    self.data = data

    if self.data.special_mark == 100 then
        self.specialMark100:SetActive(true)
        self.hasAttr:SetActive(false)
    else
        self.specialMark100:SetActive(false)
        if self.data.attrs ~= nil and #self.data.attrs > 0 then
            self.hasAttr:SetActive(true)
        else
            self.hasAttr:SetActive(false)
        end
    end

    self.ImgHuali:SetActive(false)
    self.ImgSelected.gameObject:SetActive(true)
    if self.data.style == 2 then
        self.ImgHuali:SetActive(true)
    end

    self.ImgHasGot:SetActive(false)
    self.ImgUnActive:SetActive(false)
    if self.data.active == 1 then
        self.ImgHasGot:SetActive(true)
    else
        self.ImgUnActive:SetActive(true)
    end

    self.TxtName.text = self.data.name

    -- if self.data.icon_id < 52001 then
        if self.imgLoader == nil then
           local go =  self.ConIcon.transform:FindChild("SlotCon").gameObject
           self.imgLoader = SingleIconLoader.New(go)
        end
       self.imgLoader:SetSprite(SingleIconType.Item,self.data.icon_id)
    -- else
        -- self.ConIcon.transform:FindChild("SlotCon"):GetComponent(Image).sprite= self.parent.parent.assetWrapper:GetSprite(AssetConfig.fashion_big_icon2, tostring(self.data.icon_id))
    -- end


        self:set_select(false)


    -- if self:check_has_selected() then
    --     --已经有选中的
    --     self:set_select(true)
    -- else
        -- --还没有选中的，则选那个穿在身上的
        -- if self.data.is_wear == 1 then
        --     if self:checkout_wear_selected() then
        --         self:set_select(true)
        --     end
        -- else
        --     self:set_select(false)
        -- end
    -- end

    if self.data.active == 1 then
        --已激活
        self:start_timer()
    else
        --未激活
        self:stop_timer()
    end


end

--检查该时装是否已经被选中
function FashionSuitItem:check_has_selected()
    if self.parent.parent.model.current_head_data ~= nil and self.data.base_id == self.parent.parent.model.current_head_data.base_id then
        return true
    elseif self.parent.parent.model.current_cloth_data ~= nil and self.data.base_id == self.parent.parent.model.current_cloth_data.base_id then
        return true
    elseif self.parent.parent.model.current_waist_data ~= nil and self.data.base_id == self.parent.parent.model.current_waist_data.base_id then
        return true
    elseif self.parent.parent.model.current_ring_data ~= nil and self.data.base_id == self.parent.parent.model.current_ring_data.base_id then
        return true
    end
    return false
end

--检查当前时装是否和已穿上的时装先对应
function FashionSuitItem:checkout_wear_selected()
    if self.data.type == SceneConstData.looktype_hair and self.parent.parent.model.current_head_data == nil then
        return true
    elseif self.data.type == SceneConstData.looktype_dress and self.parent.parent.model.current_cloth_data == nil then
        return true
    elseif self.data.type == SceneConstData.lookstype_belt and self.parent.parent.model.current_waist_data == nil then
        return true
    elseif self.data.type == SceneConstData.lookstype_ring and self.parent.parent.model.current_ring_data == nil then
        return true
    end
    return false
end

--选中某个时装
function FashionSuitItem:on_select_item()
    self.parent:update_left(self)
end

-- 设置选中状态
function FashionSuitItem:set_select(state)
    local temp_color = self.ImgSelected.color
    self.selected = state
    if state == false then
        self.ImgSelected.color = Color(temp_color.r, temp_color.g, temp_color.b, 0)
    else
        self.parent.last_selected_item = self
        self.ImgSelected.color = Color(temp_color.r, temp_color.g, temp_color.b, 1)
    end
end

function FashionSuitItem:ClickSelf()
    self:ShowAttrTips()
    self:on_select_item()
end

function FashionSuitItem:ShowAttrTips()
    if self.data.attrs ~= nil and #self.data.attrs > 0 then
        self.parent.parent:ShowTips(self)
    end
end
-------------------计时器逻辑
--开始战斗倒计时
function FashionSuitItem:start_timer()
    self:stop_timer()

    self.ClockCon.gameObject:SetActive(true)
    self.TxtCloth.text = ""
    self.timer_id = LuaTimer.Add(0, 1000, function() self:timer_tick() end)
end

function FashionSuitItem:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
    self.ClockCon.gameObject:SetActive(false)
    self.TxtCloth.text = ""
end


function FashionSuitItem:DeleteMe()
      -- print("haha2")
    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
end

function FashionSuitItem:timer_tick()
    if self.data.expire_time - BaseUtils.BASE_TIME > 0 then
        local left_time = self.data.expire_time - BaseUtils.BASE_TIME
        self.TxtCloth.text = self.parent.parent.model:convert_left_time_str(left_time)
    else
        self:stop_timer()
    end
end
