WorldChampionTalkBubble = WorldChampionTalkBubble or BaseClass()

function WorldChampionTalkBubble:__init(go)
    self.gameObject = go
    self.bubble = self.gameObject
    self.BubbleID = 0
    self.TextEXT = MsgItemExt.New(self.bubble.transform:FindChild("Content"):GetComponent(Text), 135, 17, 20)
end

function WorldChampionTalkBubble:__delete()
    -- self.bubble.transform:Find("1"):GetComponent(Image).sprite = nil
    -- self.bubble.transform:Find("2"):GetComponent(Image).sprite = nil
    if self.TextEXT ~= nil then
        self.TextEXT:DeleteMe()
    end
end

function WorldChampionTalkBubble:ShowMsg(msg, BubbleID)
    self.BubbleID = BubbleID
    if DataAchieveShop.data_list[self.BubbleID] ~= nil then
        self:SetIcon(DataAchieveShop.data_list[self.BubbleID].source_id)
    end
    if BaseUtils.is_null(self.bubble) then
        return
    end
    self.TextEXT:SetData(msg)
    local PH = self.bubble.transform:FindChild("Content"):GetComponent(Text).preferredHeight
    local addHeight = (PH-37.408)>0 and (PH-37.408) or 0
    self.bubble.transform.sizeDelta = Vector2(164.1, 83.21952+addHeight)
    if BaseUtils.is_null(self.bubble) then
        return
    end
    self.bubble:SetActive(true)
    self.bubble.transform.localScale = Vector3(1, 1, 1)
    LuaTimer.Add(3000, function() if not BaseUtils.is_null(self.bubble) then self.bubble:SetActive(false) end end)
end

function WorldChampionTalkBubble:SetIcon(id)
    local cfg_data
    for i,v in ipairs(DataFriendZone.data_bubble) do
        if v.id == id then
            cfg_data = v
        end
    end
    if cfg_data ~= nil then
        local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.color)
        self.bubble:GetComponent(Image).color = Color(r/255,g/255,b/255)
        if cfg_data.outcolor ~= "" then
            local r,g,b = CombatUtil.TryParseHtmlString("#"..cfg_data.outcolor)
            local outline = self.bubble:GetComponent(Outline)
            if outline == nil then
                outline = self.bubble:AddComponent(Outline)
            end
            outline.effectDistance = Vector2(3, -3)
            self.bubble:GetComponent(Outline).effectColor = Color(r/255,g/255,b/255)
            self.bubble:GetComponent(Outline).enabled = true
        else
            local outline = self.bubble:GetComponent(Outline)
            if outline ~= nil then
                outline.enabled = false
            end
        end
        for i,v in ipairs(cfg_data.location) do
            local spriteid = tostring(v[1])
            local x = v[2]
            local y = v[3]
            local item = self.bubble.transform:Find(tostring(i))
            local sprite = PreloadManager.Instance:GetSprite(AssetConfig.bubble_icon, spriteid)
            local img = item.transform:GetComponent(Image)
            img.sprite = sprite
            img:SetNativeSize()
            item.transform.anchoredPosition = Vector2(x,y)
            item.transform.sizeDelta = Vector2(item.transform.sizeDelta.x, item.transform.sizeDelta.y)
            -- print(item.transform.sizeDelta)
            item.gameObject:SetActive(true)
            if cfg_data.id == 30016 and i == 1 then
                    item.transform.sizeDelta = Vector2(50,60)
                end
        end
    end
end