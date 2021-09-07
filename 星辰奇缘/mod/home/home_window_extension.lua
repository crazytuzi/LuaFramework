-- ----------------------------------------------------------
-- UI - 家园扩建
-- ljh 20160803
-- ----------------------------------------------------------
HomeWindow_Extension = HomeWindow_Extension or BaseClass(BasePanel)

function HomeWindow_Extension:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "HomeWindow_Extension"
    self.resList = {
        {file = AssetConfig.home_view_extension, type = AssetType.Main}
        ,{file = AssetConfig.homeTexture, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.container = nil
    self.skillobject = nil
    self.scrollrect = nil

    self.itemlist = {}

    self.preButton = nil
    self.nextButton = nil

    self.openType = nil

    self.color = {
        "#3166ad"
        , "#248813"
        , "#225ee7"
        , "#b031d5"
        , "#c3692c"
        , "#c3692c"
        , "#c3692c"
	}
    ------------------------------------------------
    self._update = function()
        self:update()
    end

    self._updateBuildList = function()
        self:updateBuildList()
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function HomeWindow_Extension:__delete()
    self.OnHideEvent:Fire()
    if self.itemlist ~= nil then
        for _,v in pairs(self.itemlist) do
            if v ~= nil then
                if v.effect ~= nil then
                    v.effect:DeleteMe()
                    v.effect = nil
                end
                if v.buttonTextExt ~= nil then
                    v.buttonTextExt:DeleteMe()
                    v.buttonTextExt = nil
                end
            end
        end
        self.itemlist = nil
    end
    self:AssetClearAll()
end

function HomeWindow_Extension:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.home_view_extension))
    self.gameObject.name = "HomeWindow_Extension"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform
    self.container = transform:FindChild("BuildListPanel/Content").gameObject
    self.itemobject = self.container.transform:FindChild("Item").gameObject
    self.itemobject:SetActive(false)

    self.scrollrect = transform:FindChild("BuildListPanel"):GetComponent(ScrollRect)

    for i=1,#DataFamily.data_home_data do
        local tab = {}
        tab.gameObject = GameObject.Instantiate(self.itemobject)
        tab.transform = tab.gameObject.transform
        tab.gameObject:SetActive(true)
        tab.transform:SetParent(self.container.transform)
        tab.transform.localScale = Vector3(1, 1, 1)
        tab.buttonTextExt = MsgItemExt.New(tab.transform:Find("Button/Text"):GetComponent(Text), 140, 20, 23)
        tab.descBtn = tab.transform:Find("DescButton")
        tab.nameText = tab.transform:Find("NameText"):GetComponent(Text)
        tab.spaceText = tab.transform:Find("SpaceText"):GetComponent(Text)
        tab.descText = tab.transform:Find("DescText"):GetComponent(Text)
        tab.extensionImage = tab.transform:Find("ExtensionText"):GetComponent(Image)
        tab.extension = tab.transform:Find("Extension"):GetComponent(Image)
        tab.button = tab.transform:Find("Button"):GetComponent(Button)
        tab.evtText = tab.transform:Find("EnvText"):GetComponent(Text)
        tab.homeImage = tab.transform:Find("HomeImage"):GetComponent(Image)
    	table.insert(self.itemlist, tab)

    	tab.button.onClick:AddListener(function() self:buttonclick() end)
    	tab.transform:GetComponent(Button).onClick:AddListener(function() self:descbuttonclick(tab.descBtn, i) end)
    end

    self.preButton = self.transform:FindChild("PreButton").gameObject
    self.preButton:GetComponent(Button).onClick:AddListener(function() self:prebuttonclick() end)

    self.nextButton = self.transform:FindChild("NextButton").gameObject
    self.nextButton:GetComponent(Button).onClick:AddListener(function() self:nextbuttonclick() end)

    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function HomeWindow_Extension:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        self.openType = self.openArgs[2]
    else
        self.openType = nil
    end

    self:addevents()
    self:update()
end

function HomeWindow_Extension:OnHide()
    self:removeevents()
end

function HomeWindow_Extension:addevents()
    EventMgr.Instance:AddListener(event_name.home_base_update, self._update)
end

function HomeWindow_Extension:removeevents()
    EventMgr.Instance:RemoveListener(event_name.home_base_update, self._update)
end

function HomeWindow_Extension:update()
	for i=1,#DataFamily.data_home_data do
    	local item = self.itemlist[i]
    	local data = DataFamily.data_home_data[i]
    	item.nameText.text = string.format("<color='%s'>%s</color>", self.color[i], data.name2)
    	item.spaceText.text = string.format(TI18N("空间：<color='#13fc60'>%s㎡</color>"), data.total_space)
    	if i > 1 then
    		local last_data = DataFamily.data_home_data[i-1]
    		if data.map_id ~= last_data.map_id then -- 如果地图有更改
                item.descText.text = ""
                item.extensionImage.gameObject:SetActive(true)
            else
                item.descText.text = TI18N("点击查看说明")
                item.extensionImage.gameObject:SetActive(false)
    		end
        else
            item.descText.text = TI18N("点击查看说明")
            item.extensionImage.gameObject:SetActive(false)
    	end

    	item.homeImage.sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, string.format("home%s", data.lev))

        if i <= self.model.home_lev then
        	item.extension.gameObject:SetActive(true)
        	item.button.gameObject:SetActive(false)
        	item.evtText.gameObject:SetActive(false)

            if item.effect ~= nil then
                item.effect:SetActive(false)
            end
        elseif i > self.model:GetHomeMaxLev() then
        	item.extension.gameObject:SetActive(false)
        	item.button.gameObject:SetActive(false)
        	item.evtText.gameObject:SetActive(true)
        	item.evtText.text = string.format(TI18N("%s繁华度可升级"), data.min_env)

            if item.effect ~= nil then
                item.effect:SetActive(false)
            end
        else
        	item.extension.gameObject:SetActive(false)
        	item.button.gameObject:SetActive(true)
        	item.evtText.gameObject:SetActive(false)

            local upgrade_cost = DataFamily.data_upgrade_cost[i]
            if upgrade_cost ~= nil and upgrade_cost.upgrade_cost[1] ~= nil then
                -- item.transform:FindChild("Button/Text"):GetComponent(Text).text = string.format("%s%s", math.floor(upgrade_cost.upgrade_cost[1][2]/10000), TI18N("万  建造"))
                item.buttonTextExt:SetData(string.format(TI18N("%s{assets_2,90000}万建造"), math.floor(upgrade_cost.upgrade_cost[1][2]/10000)))
            else
                -- item.transform:FindChild("Button/Text"):GetComponent(Text).text = TI18N("建  造")
                item.buttonTextExt:SetData(TI18N("建  造"))
            end

            local size = item.buttonTextExt.contentTrans.sizeDelta
            item.buttonTextExt.contentTrans.anchoredPosition = Vector2(-size.x / 2, size.y / 2)

            if item.effect ~= nil then
                item.effect:SetActive(true)
            else
                item.effect = BaseUtils.ShowEffect(20118, item.button.transform, Vector3(1.3, 0.9, 1), Vector3(-658, 25, -2000))
            end
        end
    end

    local max_env_val = "Max"
    local home_data = DataFamily.data_home_data[HomeManager.Instance.model.home_lev]
    if home_data ~= nil then max_env_val = home_data.max_env+1 end
    self.transform:FindChild("EnvText"):GetComponent(Text).text = string.format(TI18N("当前繁华度：%s/%s"), self.model.env_val, max_env_val)
    self.transform:FindChild("DescText"):GetComponent(Text).text = TI18N("摆放家具可提升<color='#13fc60'>繁华度</color>，繁华度达到要求可扩建更高级的家园！")
end

function HomeWindow_Extension:buttonclick()
    HomeManager.Instance:Send11231()
end

function HomeWindow_Extension:prebuttonclick()
	local pageWith = 231
	local scrollrectWidth = self.scrollrect.gameObject:GetComponent(RectTransform).sizeDelta.x
	local pos = self.container.transform.localPosition
	local x = pos.x + 3 * pageWith
	if x > -scrollrectWidth/2 then
		x = -scrollrectWidth/2
	end
	-- self.container.transform.localPosition = Vector2(pos.x, pos.y)
	local time = math.abs(x - pos.x) / 1000
	Tween.Instance:MoveLocal(self.container, Vector3(x, pos.y, pos.z), time, nil, LeanTweenType.linear)
end

function HomeWindow_Extension:nextbuttonclick()
	local pageWith = 231
	local scrollrectWidth = self.scrollrect.gameObject:GetComponent(RectTransform).sizeDelta.x
	local max_x = 709 - pageWith * #DataFamily.data_home_data
	local pos = self.container.transform.localPosition
	local x = pos.x - 3 * pageWith
	if x < max_x - scrollrectWidth/2 then
		x = max_x - scrollrectWidth/2
	end
	-- self.container.transform.localPosition = Vector2(pos.x, pos.y)
	local time = math.abs(x - pos.x) / 1000
	Tween.Instance:MoveLocal(self.container, Vector3(x, pos.y, pos.z), time, nil, LeanTweenType.linear)
end

function HomeWindow_Extension:descbuttonclick(transform, lev)
	local tips_string = {}
	local home_data = DataFamily.data_home_data[lev]
	table.insert(tips_string, string.format("<color='%s'>[%s]</color>", self.color[lev], home_data.name2))
	table.insert(tips_string, TI18N("可容纳家具："))
	table.insert(tips_string, string.format("%s <color='#248813'>%s</color> %s <color='#248813'>%s</color> %s <color='#248813'>%s</color> %s <color='#248813'>%s</color>", TI18N("屏风"), self.model:get_limit(lev, 1)+self.model:get_limit(lev, 2), TI18N("沙发"), self.model:get_limit(lev, 3), TI18N("桌子"), self.model:get_limit(lev, 5)+self.model:get_limit(lev, 12), TI18N("椅子"), self.model:get_limit(lev, 6)))
	table.insert(tips_string, string.format("%s<color='#248813'>%s</color> %s <color='#248813'>%s</color> %s <color='#248813'>%s</color> %s <color='#248813'>%s</color>", TI18N("柜子") , self.model:get_limit(lev, 7)+self.model:get_limit(lev, 8), TI18N("窗帘"), self.model:get_limit(lev, 9), TI18N("床"), self.model:get_limit(lev, 10), TI18N("宠物室"), self.model:get_limit(lev, 11)))
	table.insert(tips_string, string.format("%s <color='#248813'>%s</color> %s <color='#248813'>%s</color> %s <color='#248813'>%s</color>", TI18N("地板"), 1, TI18N("地毯"), self.model:get_limit(lev, 16), TI18N("装饰"), self.model:get_limit(lev, 4)+self.model:get_limit(lev, 12)+self.model:get_limit(lev, 13)))
	table.insert(tips_string, "")
    table.insert(tips_string, TI18N("<color='#ffff00'>超过</color>可容纳数量放置的家具<color='#ffff00'>无法增加</color>家园的繁华度，仅具有观赏作用，请提升家园规模，放置更多更漂亮的家具吧！"))
	if lev == 4 then
		table.insert(tips_string, TI18N("<color='#ffff00'>★家园占地面积大幅扩大，可容纳更多家具！★</color>"))
	end
	TipsManager.Instance:ShowText({gameObject = transform.gameObject, itemData = tips_string})
end