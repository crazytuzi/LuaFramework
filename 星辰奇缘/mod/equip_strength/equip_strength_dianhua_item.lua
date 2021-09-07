EquipStrengthDianhuaItem = EquipStrengthDianhuaItem or BaseClass()

function EquipStrengthDianhuaItem:__init(parent, origin_item, data, _index)
    self.parent = parent
    self.gameObject = GameObject.Instantiate(origin_item)
    self.transform = self.gameObject.transform
    self.transform:SetParent(origin_item.transform.parent)
    self.transform.localScale = Vector3.one


    self.ImgNormal = self.transform:FindChild("ImgNormal").gameObject
    self.ImgSelect = self.transform:FindChild("ImgSelect").gameObject
    self.TxtDesc = self.transform:FindChild("TxtDesc"):GetComponent(Text)
    self.TxtVal = self.transform:FindChild("TxtVal"):GetComponent(Text)
    self.ImgProg = self.transform:FindChild("ImgProg")
    self.ImgShenqi = self.transform:FindChild("ImgShenqi").gameObject
    self.ImgProgBar_rect = self.ImgProg:FindChild("ImgProgBar"):GetComponent(RectTransform)

    self.ImgPoint = self.transform:FindChild("ImgPoint").gameObject

    self.ImgPoint:SetActive(false)

    self.ImgShenqi:SetActive(false)
    local newY = -4.5+(_index - 1)*-58
    local rect = self.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(94, newY)

    self.transform:GetComponent(Button).onClick:AddListener(function() self:on_click_item() end) --item

    -- 是否激活精炼
    self.isActive = false
end

function EquipStrengthDianhuaItem:Release()

end

function EquipStrengthDianhuaItem:set_data(data)
    self.data = data

    local name_str = EquipStrengthManager.Instance.model.dianhua_name[data.craft]
    local name_color = EquipStrengthManager.Instance.model.dianhua_color[data.craft]
    self.TxtDesc.text = string.format("<color='%s'>%s</color>", name_color, name_str)

    self.ImgShenqi:SetActive(false)

    ---设置居中
    self.TxtDesc.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-47.75, 0)
    self.TxtVal.transform:GetComponent(RectTransform).anchoredPosition = Vector2(26.2, 0)

    self.ImgProg.gameObject:SetActive(false)
    self.ImgProgBar_rect.sizeDelta = Vector2(0, self.ImgProgBar_rect.rect.height)

    self.has_dianhua = false
    self.fenzi = 0
    -- 分母是最大值，不管有没精炼过，最大值都可以从表里面拿到
    self.fenmu = self.data.max_val
    local val_str = ""

    if data.lev <= RoleManager.Instance.RoleData.lev or (RoleManager.Instance.RoleData.lev_break_times ~= 0 and data.lev >= 95 and data.lev <= 100 ) then
        self.isActive = true
        self.has_dianhua = false
        --检查下已经精炼过了没
        for i=1,#self.parent.cur_selected_data.attr do
            local attr_data = self.parent.cur_selected_data.attr[i]
            if attr_data.type == 5 then
                if attr_data.flag == data.craft then
                    --已经精炼过
                    self.fenzi = math.min(attr_data.val, self.fenmu)
                    self.ImgProgBar_rect.sizeDelta = Vector2(160 * (self.fenzi / self.fenmu), self.ImgProgBar_rect.rect.height)
                    self.ImgProg.gameObject:SetActive(true)
                    val_str = string.format("<color='%s'>%s+%s</color>(+%s)", name_color, KvData.attr_name[attr_data.name] ,attr_data.val, self.data.max_val)
                    self.has_dianhua = true

                    --设置不居中
                    self.TxtDesc.transform:GetComponent(RectTransform).anchoredPosition = Vector2(-47.75, 10)
                    self.TxtVal.transform:GetComponent(RectTransform).anchoredPosition = Vector2(26.2, 10)
                    break
                end
            end
        end
        if self.has_dianhua == false then
            --还没有精炼
            self.ImgProg.gameObject:SetActive(false)
            val_str = string.format("%s<color='#248813'>(+%s~%s)</color>", TI18N("可精炼"), self.data.min_val, self.data.max_val)
        end
    else
        val_str = string.format("%s%s", data.lev, TI18N("级开启"))
        self.isActive = false
    end
    self.TxtVal.text = val_str

    -- if EquipStrengthManager.Instance.model:check_is_shenqi_craf(self.parent.cur_selected_data, self.data.craft) and data.lev <= RoleManager.Instance.RoleData.lev and self.has_dianhua then
    if self.data.looks_active_val > 0 then
        self.ImgShenqi:SetActive(true)
    else
        self.ImgShenqi:SetActive(false)
    end

    self:set_img_point(false)
end

-- 上级未精炼，所以未开放
function EquipStrengthDianhuaItem:UnOpen()
    local str = ""
    if self.data.lev > RoleManager.Instance.RoleData.lev then
        if RoleManager.Instance.RoleData.lev_break_times ~= 0 and self.data.lev >= 95 and self.data.lev <= 100 then
            --已经突破过
            local currCraft = self.data.craft - 1
            local name_str = EquipStrengthManager.Instance.model.dianhua_name[currCraft]
            local name_color = EquipStrengthManager.Instance.model.dianhua_color[currCraft]
            str = string.format(TI18N("精炼至<color='%s'>%s</color>开启"), name_color, name_str)
        else
            str = string.format("%s%s", self.data.lev, TI18N("级开启"))
        end
    else
        local currCraft = self.data.craft - 1
        local name_str = EquipStrengthManager.Instance.model.dianhua_name[currCraft]
        local name_color = EquipStrengthManager.Instance.model.dianhua_color[currCraft]
        str = string.format(TI18N("精炼至<color='%s'>%s</color>开启"), name_color, name_str)
    end
    self.TxtVal.text = str
    self.gameObject:SetActive(true)
end

function EquipStrengthDianhuaItem:change_txt(str)
end

function EquipStrengthDianhuaItem:on_click_item()
    self.parent:update_right(self)
end

--设置选中状态
function EquipStrengthDianhuaItem:set_selected_state(state)
    if state then
        self.ImgNormal.gameObject:SetActive(false)
        self.ImgSelect.gameObject:SetActive(true)
    else
        self.ImgNormal.gameObject:SetActive(true)
        self.ImgSelect.gameObject:SetActive(false)
    end
end

--设置红色点显示状态
function EquipStrengthDianhuaItem:set_img_point(state)
    self.ImgPoint:SetActive(state)
end
