-- @author 黄耀聪
-- @date 2016年7月7日

StrategyListItem = StrategyListItem or BaseClass()

function StrategyListItem:__init(model, gameObject)
    self.model = model
    self.gameObject = gameObject
    self.transform = gameObject.transform
    self.mgr = StrategyManager.Instance

    local t = self.transform
    self.titleText = t:Find("Title"):GetComponent(Text)
    self.titleRect = self.titleText.gameObject:GetComponent(RectTransform)
    self.commentText = t:Find("Comment/Text"):GetComponent(Text)
    self.coolText = t:Find("Cool/Text"):GetComponent(Text)
    self.serverText = t:Find("Server"):GetComponent(Text)
    self.nameText = t:Find("Name"):GetComponent(Text)
    self.dateText = t:Find("Date"):GetComponent(Text)
    self.btn = gameObject:GetComponent(Button)
    self.labelObj = t:Find("Label").gameObject
    self.label = {
        t:Find("Label/Status1").gameObject,
        t:Find("Label/Status2").gameObject,
        t:Find("Label/Status3").gameObject,
        t:Find("Label/Status4").gameObject,
        t:Find("Label/Status5").gameObject,
    }

    self.no_label = false
    self.btn.onClick:AddListener(function() self:OnClick() end)
end

function StrategyListItem:__delete()
end

function StrategyListItem:update_my_self(data, index)
    self.data = data
    if data == nil then
        self.gameObject:SetActive(false)
        return
    end
    if data.name ~= nil then
        self.titleText.text = data.name -- BaseUtils.string_cut(data.name, 42, 39)]]
    else
        self.titleText.text = ""
    end
    self.nameText.text = data.role_name
    self.dateText.text = tostring(os.date("%Y/%m/%d", data.time))
    self.labelObj:SetActive(data.state ~= nil and data.state > 0)
    self.serverText.text = ""
    if data.gm == 1 then
        self.nameText.text = ""
    else
        -- self.serverText.text = string.format(TI18N("服务器:%s"), self.mgr.serverNameTab[BaseUtils.Key(data.zone_id, data.platform)])
    end
    -- status = 0 审核中，1 已通过，2 未通过
    if (data.isDraft or data.gm ~= nil or data.state ~= nil) and self.no_label ~= true then
        for i,v in ipairs(self.label) do
            v:SetActive(false)
        end
        self.labelObj:SetActive(true)
        if data.gm == 1 then
            -- self.label[4]:SetActive(true)    -- 官方
        elseif data.isDraft then
            self.label[2]:SetActive(true)
        elseif data.state == 0 then
            self.label[1]:SetActive(true)
        elseif data.state == 1 then
            self.label[3]:SetActive(true)
        elseif data.state == 2 then
            self.label[5]:SetActive(true)
        end
    else
        self.labelObj:SetActive(false)
    end

    if data.gm == 1 then
        self.titleRect.sizeDelta = Vector2(374.05, 30)
    else
        self.titleRect.sizeDelta = Vector2(242.6, 30)
    end
    self.gameObject:SetActive(true)
end

function StrategyListItem:SetActive(bool)
    self.gameObject:SetActive(bool)
end

function StrategyListItem:OnClick()
    if self.data.isDraft then
        self.mgr.onChangeTab:Fire(100, self.data)
    else
        self.mgr.onChangeTab:Fire(99, self.data)
    end
end

