WorldBossItem = WorldBossItem or BaseClass()

function WorldBossItem:__init(parent, origin_item, data, index)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.index = index

    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one

    self.gameObject:SetActive(true)


    self.ImgHead = self.transform:FindChild("HeadCon"):FindChild("ImgHead"):GetComponent(Image)
    self.TxtLev = self.transform:FindChild("HeadCon"):FindChild("ImgLevBg"):FindChild("TxtLev"):GetComponent(Text)
    self.TxtName = self.transform:FindChild("TxtName"):GetComponent(Text)
    self.TxtScene = self.transform:FindChild("TxtScene"):GetComponent(Text)
    self.TxtKriller = self.transform:FindChild("TxtKriller"):GetComponent(Text)
    self.ImgClock = self.transform:FindChild("ImgClock").gameObject
    self.TxtClock = self.transform:FindChild("TxtClock"):GetComponent(Text)
    self.ImgSelected = self.transform:FindChild("ImgSelected").gameObject
    self.ImgSelected:SetActive(false)

    self.ImgIcon = self.transform:FindChild("ImgIcon").gameObject
    self.TxtUnOpen = self.transform:FindChild("TxtUnOpen").gameObject
    self.ImgIcon:SetActive(false)
    self.TxtUnOpen:SetActive(false)
    self.ImgHead.gameObject:SetActive(true)

    self.transform:GetComponent(Button).onClick:AddListener(function() self:on_click_boss_item() end) --BtnRest

    self:set_boss_item_data(data)

    local newY = (self.index - 1)*-100
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(10, newY)
end

function WorldBossItem:Release()
    self.ImgHead.sprite = nil
end

function WorldBossItem:InitPanel(_data)

end

function WorldBossItem:set_boss_item_data(data)
    self.data = data
    local cfg_data = DataBoss.data_base[data.id]
    local unit_data = DataUnit.data_unit[data.id]
    local last_kill_time = data.last_killed --最后击杀时间

    self.TxtKriller.text = string.format("%s", TI18N("上轮击杀：无"))
    for i=1,#data.round_first do
        local d = data.round_first[i]
        if d.is_leader == 1 then
            self.TxtKriller.text = string.format("%s%s", TI18N("上轮击杀："), d.name)
        end
    end

    self.TxtLev.text = tostring(cfg_data.lev)
    self.TxtName.text = unit_data.name

    self.TxtScene.text = DataMap.data_list[cfg_data.points[1].map_id].name

    local fresh_left_time = (data.last_killed + cfg_data.refresh_time) - BaseUtils.BASE_TIME
    self.fresh_left_time = fresh_left_time

    self.ImgHead.sprite = self.parent.assetWrapper:GetSprite(AssetConfig.world_boss_head_icon, tostring(data.id))
end

function WorldBossItem:tick_clock()
     if self.fresh_left_time >= 0 then
        self.fresh_left_time = self.fresh_left_time - 1
        self.ImgClock:SetActive(true)
        self.TxtClock.gameObject:SetActive(true)
        self.ImgIcon:SetActive(false)
        self.TxtUnOpen:SetActive(false)

        if self.fresh_left_time > 0 then
            local my_hour = math.modf(self.fresh_left_time % 86400 / 3600)
            local my_minute = math.modf(self.fresh_left_time % 86400 % 3600 / 60)
            local my_second = math.modf(self.fresh_left_time % 86400 % 3600 % 60)

            local hourStr = my_hour > 9 and my_hour or string.format("0%s",my_hour)
            local minStr = my_minute > 9 and my_minute or string.format("0%s",my_minute)
            local secStr = my_second > 9 and my_second or string.format("0%s",my_second)
            self.TxtClock.text = string.format(TI18N("%s时%s分%s秒"), hourStr, minStr, secStr)
        end
    else
        self.ImgClock:SetActive(false)
        self.TxtClock.gameObject:SetActive(false)
        self.ImgIcon:SetActive(true)
        self.TxtUnOpen:SetActive(true)
    end
end

function WorldBossItem:on_click_boss_item()
    self.parent:update_right_con(self)
end