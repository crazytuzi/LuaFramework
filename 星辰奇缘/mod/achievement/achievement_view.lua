-- ----------------------------------------------------------
-- UI - 成就窗口 主窗口
-- ----------------------------------------------------------
AchievementView = AchievementView or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function AchievementView:__init(parent)
    self.parent = parent
	self.model = AchievementManager.Instance.model
    self.name = "AchievementView"
    -- self.windowId = WindowConfig.WinID.achievement
    -- self.winLinkType = WinLinkType.Link
    -- self.cacheMode = CacheMode.Visible

    self.resList = {
        {file = AssetConfig.achievementpanel, type = AssetType.Main}
        , {file = AssetConfig.achievement_textures, type = AssetType.Dep}
        , {file = AssetConfig.rank_textures, type = AssetType.Dep}
        , {file = AssetConfig.attr_icon, type = AssetType.Dep}
        , {file = AssetConfig.half_length, type = AssetType.Dep}
    	, {file = AssetConfig.agenda_textures, type = AssetType.Dep}
        , {file = AssetConfig.badge_icon, type = AssetType.Dep}  --徽章
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
	self.barContainer = nil
	self.barRect = nil
	self.mainButtonTemplate = nil
	self.mainButtonHeight = nil
	self.subButtonTemplate = nil
	self.subButtonHeight = nil

	self.totalPanel = nil
	self.totalContainer = nil
	self.totalPanelLayout = nil
	self.totalPanel_AchievementItem = nil
	self.subPanel = nil
	self.subContainer = nil
	self.subPanelLayout = nil
	self.subPanel_AchievementItem = nil
    self.totalPanel2 = nil
    self.totalContainer2 = nil
    self.totalPanelLayout2 = nil
    self.totalPanel_AchievementItem2 = nil

    self.totalContainer2_item_list = {}
    self.totalContainer3_item_list = {}
    self.subContainer_item_list = {}

	self.totalCellObjList = {}
	self.subCellObjList = {}
    self.totalCellObjList2 = {}
    self.rewardItemList = {}
    self.rewardItemSlotList = {}

	self.sortType = 1
    self.sortType2 = 3

    self.lastType = nil
    self.lastType2 = nil

	self.tips = {TI18N("成就点可以获得时装喔，敬请期待吧!")}
    self.selectCell = nil
    self.selectId = nil

    self.totalPanelType = 1
    self.totalPanelTabGroupObj = nil
    self.totalPanelTabGroup = nil
    ------------------------------------------------
    self._update = function()
    	self:update()
	end
    self._onUpdateCompleteNumber = function()
        self:showCompleteNumber()
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end


function AchievementView:__delete()
    self.subContainer_item_list = nil
    self.subContainer_setting_data = nil
    self:OnHide()
    self:AssetClearAll()
end

function AchievementView:InitPanel()
	-- self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementwindow))
 --    self.gameObject.name = "AchievementView"
 --    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

 --    self.transform = self.gameObject.transform

    -- self.mainTransform = self.transform:FindChild("Main")

    -- self.closeBtn = self.mainTransform:FindChild("CloseButton"):GetComponent(Button)
    -- self.closeBtn.onClick:AddListener(function() self:OnClickClose() end)

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementpanel))
    self.gameObject.name = "AchievementView"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform
    self.mainTransform = self.transform
    ----------------------------
    self.barContainer = self.mainTransform:Find("Bar/Container").gameObject
    self.barRect = self.barContainer:GetComponent(RectTransform)
    self.mainButtonTemplate = self.barContainer.transform:Find("MainButton").gameObject
    self.mainButtonHeight = 60
    self.mainButtonTemplate:SetActive(false)
    self.subButtonTemplate = self.barContainer.transform:Find("SubButton").gameObject
    self.subButtonHeight = 50
    self.subButtonTemplate:SetActive(false)

    self.totalPanel = self.mainTransform:Find("TotalPanel").gameObject
    self.totalContainer = self.totalPanel.transform:FindChild("Panel/Container")
	self.totalPanelLayout = LuaBoxLayout.New(self.totalContainer, {axis = BoxLayoutAxis.Y, cspacing = 0, scrollRect = nil})
	self.totalPanel_AchievementItem = self.totalContainer.transform:FindChild("Item").gameObject
    self.totalPanel_AchievementItem:SetActive(false)

    -- self.subPanel = self.mainTransform:Find("SubPanel").gameObject
	-- self.subContainer = self.subPanel.transform:FindChild("Panel/Container")
	-- self.subPanelLayout = LuaBoxLayout.New(self.subContainer, {axis = BoxLayoutAxis.Y, cspacing = 0, scrollRect = nil})
	-- self.subPanel_AchievementItem = self.subContainer.transform:FindChild("Item").gameObject
    -- self.subPanel_AchievementItem:SetActive(false)

    self.subPanel = self.mainTransform:Find("SubPanel").gameObject
    self.subContainer = self.subPanel.transform:FindChild("Panel/Container")
    self.subPanel_AchievementItem = self.subContainer.transform:FindChild("1").gameObject
    self.subContainer_vScroll =  self.subPanel.transform:FindChild("Panel"):GetComponent(ScrollRect)
    self.subContainer_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.subContainer_setting_data)
        -- self:OnValueChanged(1)
    end)

    for i=1, 6 do
        local go = self.subContainer.transform:FindChild(tostring(i)).gameObject

        local item = AchievementMemberItem.New(go, self)
        table.insert(self.subContainer_item_list, item)
    end
    self.subContainer_single_item_height = self.subPanel_AchievementItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.subContainer_scroll_con_height = self.subPanel.transform:FindChild("Panel"):GetComponent(RectTransform).sizeDelta.y
    self.subContainer_item_con_last_y = self.subContainer:GetComponent(RectTransform).anchoredPosition.y

    self.subContainer_setting_data = {
       item_list = self.subContainer_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.subContainer  --item列表的父容器
       ,single_item_height = self.subContainer_single_item_height --一条item的高度
       ,item_con_last_y = self.subContainer_item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.subContainer_scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    -- self.totalPanel2 = self.mainTransform:Find("TotalPanel2").gameObject
    -- self.totalContainer2 = self.totalPanel2.transform:FindChild("Panel/Container")
    -- self.totalPanelLayout2 = LuaBoxLayout.New(self.totalContainer2, {axis = BoxLayoutAxis.Y, cspacing = 0, scrollRect = self.totalPanel2.gameObject:GetComponent(ScrollRect)})
    -- self.totalPanel_AchievementItem2 = self.totalContainer2.transform:FindChild("Item").gameObject
    -- self.totalPanel_AchievementItem2:SetActive(false)
    self.totalPanel2 = self.mainTransform:Find("TotalPanel2").gameObject
    self.totalContainer2 = self.totalPanel2.transform:FindChild("Panel/Container")
    self.totalPanel_AchievementItem2 = self.totalContainer2.transform:FindChild("1").gameObject
    self.totalContainer2_vScroll =  self.totalPanel2.transform:FindChild("Panel"):GetComponent(ScrollRect)
    self.totalContainer2_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.totalContainer2_setting_data)
        -- self:OnValueChanged(1)
    end)

    for i=1, 8 do
        local go = self.totalContainer2.transform:FindChild(tostring(i)).gameObject

        local item = AchievementMemberItem.New(go, self)
        table.insert(self.totalContainer2_item_list, item)
    end
    self.totalContainer2_single_item_height = self.totalPanel_AchievementItem2.transform:GetComponent(RectTransform).sizeDelta.y
    self.totalContainer2_scroll_con_height = self.totalPanel2.transform:FindChild("Panel"):GetComponent(RectTransform).sizeDelta.y
    self.totalContainer2_item_con_last_y = self.totalContainer2:GetComponent(RectTransform).anchoredPosition.y

    self.totalContainer2_setting_data = {
       item_list = self.totalContainer2_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.totalContainer2  --item列表的父容器
       ,single_item_height = self.totalContainer2_single_item_height --一条item的高度
       ,item_con_last_y = self.totalContainer2_item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.totalContainer2_scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.totalPanel3 = self.mainTransform:Find("TotalPanel").gameObject
    self.totalContainer3 = self.totalPanel3.transform:FindChild("Panel2/Container")
    self.totalPanel_AchievementItem3 = self.totalContainer3.transform:FindChild("1").gameObject
    self.totalContainer3_vScroll =  self.totalPanel3.transform:FindChild("Panel2"):GetComponent(ScrollRect)
    self.totalContainer3_vScroll.onValueChanged:AddListener(function()
        BaseUtils.on_value_change(self.totalContainer3_setting_data)
        -- self:OnValueChanged(2)
    end)

    for i=1, 6 do
        local go = self.totalContainer3.transform:FindChild(tostring(i)).gameObject
        -- local go = GameObject.Instantiate(self.totalPanel_AchievementItem3)
        -- local trans = go.transform
        -- trans:SetParent(self.totalContainer3.transform)
        -- trans.localScale = Vector3.one
        -- trans.localPosition = Vector3.zero
        -- trans.localRotation = Quaternion.identity
        -- go:SetActive(true)

        -- local rect = go:GetComponent(RectTransform)
        -- rect.anchorMax = Vector2(0.5, 1)
        -- rect.anchorMin = Vector2(0.5, 1)

        local item = AchievementMemberItem.New(go, self)
        table.insert(self.totalContainer3_item_list, item)
    end
    self.totalContainer3_single_item_height = self.totalPanel_AchievementItem3.transform:GetComponent(RectTransform).sizeDelta.y
    self.totalContainer3_scroll_con_height = self.totalPanel3.transform:FindChild("Panel2"):GetComponent(RectTransform).sizeDelta.y
    self.totalContainer3_item_con_last_y = self.totalContainer3:GetComponent(RectTransform).anchoredPosition.y

    self.totalContainer3_setting_data = {
       item_list = self.totalContainer3_item_list--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.totalContainer3  --item列表的父容器
       ,single_item_height = self.totalContainer3_single_item_height --一条item的高度
       ,item_con_last_y = self.totalContainer3_item_con_last_y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.totalContainer3_scroll_con_height--显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 0 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }

    self.rewardPanel = self.totalPanel.transform:FindChild("Panel3")
    self.rewardPanelContainer = self.rewardPanel.transform:FindChild("Container")
    self.rewardCloner = self.rewardPanelContainer:FindChild("Item").gameObject
    self.rewardCloner:SetActive(false)

    self.totalPanelTabGroupObj = self.totalPanel.transform:FindChild("TabButtonGroup").gameObject
    self.totalPanelTabGroup = TabGroup.New(self.totalPanelTabGroupObj, function(index) self:totalPanelChangeTab(index) end, { notAutoSelect = true })
    self.totalPanelTabGroup:ChangeTab(2)

    -- self.totalPanel.transform:FindChild("Desc"):GetComponent(Button).onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.totalPanel.transform:FindChild("Desc").gameObject, itemData = self.tips}) end)
    -- self.totalPanel.transform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:ShowTotalPanel2() end)
    self.totalPanel.transform:FindChild("Button2"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.achievementshopwindow, {1,1}) end)
    self.subPanel.transform:FindChild("SortButton"):GetComponent(Button).onClick:AddListener(function() self:OnClickSortButton() end)
    self.totalPanel2.transform:FindChild("Button"):GetComponent(Button).onClick:AddListener(function() self:ShowTotalPanel() end)
    self.totalPanel2.transform:FindChild("SortButton"):GetComponent(Button).onClick:AddListener(function() self:SortTotalPanel2() end)

    local btn = self.totalPanel.transform:FindChild("ToatlProgress").gameObject:AddComponent(Button)
    btn.onClick:AddListener(function() self:ShowTotalStar() end)

    -- btn = self.totalPanel.transform:FindChild("AchIconButton"):GetComponent(Button)
    -- btn.onClick:AddListener(function() self:ShowBadgeTips() end)
	----------------------------
    self:InitButtonList()

    ----------------------------

    self:OnShow()
    self:ClearMainAsset()
end

-- function AchievementView:OnClickClose()
--     WindowManager.Instance:CloseWindow(self)
-- end

function AchievementView:OnShow()
    if self.parent.openArgs ~= nil and self.parent.openArgs[1] == 2 then
        if #self.parent.openArgs > 1 then
            self.model.currentMain = self.parent.openArgs[2]
            if #self.parent.openArgs > 2 then
            	self.model.currentSub = self.parent.openArgs[3]
                if #self.parent.openArgs > 3 then
                    local paneltype = self.parent.openArgs[4]
                    if paneltype == 0 then
                        self.lastType = 0
                    else
                        self.totalPanelType = paneltype
                    end
                end
            end
        end
    end

    self:EnableMain(self.model.currentMain, true)
    if self.model.currentSub ~= nil then
        self:EnableSub(self.model.currentMain, self.model.currentSub, true)
        self:ShowSubButton(self.model.currentMain, true)
    end
    LuaTimer.Add(5, self._update)
    AchievementManager.Instance.OnUpdateList:Add(self._update)
    AchievementManager.Instance.onUpdateCompleteNumber:Add(self._onUpdateCompleteNumber)
end

function AchievementView:OnHide()
	AchievementManager.Instance.OnUpdateList:Remove(self._update)
    AchievementManager.Instance.onUpdateCompleteNumber:Remove(self._onUpdateCompleteNumber)
end

--------------------------------------------------------
function AchievementView:InitButtonList()
    local preload = PreloadManager.Instance
    local model = self.model
    self.mainButtonList = {}
    self.mainImageList = {}
    self.subButtonList = {}
    self.subImageList = {}
    self.mainTextList = {}
    self.subTextList = {}
    self.subOpenList = {}

    local mainBtn
    local subBtn
    local subList = nil
    local subObjList = nil
    local subImageList = nil
    local subTextList = nil

    for i=1,#model.classList do
        local data = model.classList[i]
        mainBtn = GameObject.Instantiate(self.mainButtonTemplate)
        mainBtn.name = tostring(i)
        mainBtn:SetActive(true)
        UIUtils.AddUIChild(self.barContainer, mainBtn)
        self.mainTextList[i] = mainBtn.transform:Find("Text"):GetComponent(Text)
        self.mainTextList[i].text = data.name

        mainBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.rank_textures, data.icon)

        mainBtn:GetComponent(Button).onClick:AddListener(function ()
            self:ClickMainButton(i)
        end)

        if i == 1 then
        	mainBtn.transform.transform:Find("Arrow").gameObject:SetActive(false)
        end

        subList = data.subList
        subObjList = {}
        subImageList = {}
        subTextList = {}
        for j=1,#subList do
            local subdata = subList[j]
            subBtn = GameObject.Instantiate(self.subButtonTemplate)
            subBtn:GetComponent(Button).onClick:AddListener(function ()
                self:ClickSubButton(i, j)
            end)
            subBtn.name = BaseUtils.Key(i, j)
            UIUtils.AddUIChild(self.barContainer, subBtn)
            subObjList[j] = subBtn
            subTextList[j] = subBtn.transform:Find("Text"):GetComponent(Text)
            subTextList[j].text = subdata.name
            subBtn.transform:Find("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, subdata.icon)
            subImageList[j] = subBtn:GetComponent(Image)
            subBtn:SetActive(false)
        end
        self.mainButtonList[i] = mainBtn
        self.subButtonList[i] = subObjList
        self.mainImageList[i] = mainBtn:GetComponent(Image)
        self.subImageList[i] = subImageList
        self.subTextList[i] = subTextList
        self.subOpenList[i] = false
    end
end

function AchievementView:ClickMainButton(selectMain)
    local model = self.model
    if selectMain ~= model.currentMain then
        self:EnableMain(model.currentMain, false)
        self:ShowSubButton(model.currentMain, false)
        model.currentSub = 1
        model.currentMain = selectMain
        self:EnableMain(model.currentMain, true)
        self:ShowSubButton(model.currentMain, true)
        self:update()
    else
        self:ShowSubButton(selectMain, not self.subOpenList[selectMain])
    end
end

function AchievementView:ClickSubButton(selectMain, selectSub)
    local model = self.model
    if selectMain ~= model.currentMain then
        self:EnableSub(model.currentMain, model.currentSub, false)
        self:EnableMain(selectMain, false)
        self:ShowSubButton(model.currentMain, false)
        model.currentMain = selectMain
        model.currentSub = selectSub
        self:ShowSubButton(model.currentMain, true)
        self:EnableMain(selectMain, true)
        self:EnableSub(model.currentMain, model.currentSub, true)
        self:update()
    elseif selectSub ~= model.currentSub then
        self:EnableSub(model.currentMain, model.currentSub, false)
        model.currentSub = selectSub
        self:EnableSub(model.currentMain, model.currentSub, true)
        self:update()
    end
end

function AchievementView:EnableMain(currentMain, bool)
    local preload = PreloadManager.Instance
    if bool then
        self.mainImageList[currentMain].sprite = preload:GetSprite(AssetConfig.base_textures, "DefaultButton9")
        self.mainTextList[currentMain].color = ColorHelper.DefaultButton9
        self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = preload:GetSprite(AssetConfig.base_textures, "Arrow3")
    else
        self.mainImageList[currentMain].sprite = preload:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        self.mainTextList[currentMain].color = ColorHelper.DefaultButton8
        self.mainButtonList[currentMain].transform:Find("Arrow"):GetComponent(Image).sprite = preload:GetSprite(AssetConfig.base_textures, "Arrow4")
    end
end

function AchievementView:EnableSub(currentMain, currentSub, bool)
    if bool then
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton11")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton11
        end
    else
        if self.subImageList[currentMain][currentSub] ~= nil then
            self.subImageList[currentMain][currentSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton10")
            self.subTextList[currentMain][currentSub].color = ColorHelper.DefaultButton10
        end
    end
end

function AchievementView:ShowSubButton(selectMain, bool)
    self.subOpenList[selectMain] = bool
    local model = self.model
    local h = self.mainButtonHeight * #self.model.classList
    for k,v in pairs(self.subButtonList[selectMain]) do
        local num = self.model.subTypeNumList[self.model:getAchievementType(model.currentMain, k)]
        if num ~= nil and num ~= 0 then
            v:SetActive(bool)
            if bool then
                h = h + self.subButtonHeight
            end
        else
            v:SetActive(false)
        end
    end
    self.barRect.sizeDelta = Vector2(self.barRect.sizeDelta.x, h)
    self:EnableSub(model.currentMain, model.currentSub, bool)
    if bool then
        self.mainButtonList[selectMain].transform:Find("Arrow").localScale = Vector3(-1, 1, 1)
    else
        self.mainButtonList[selectMain].transform:Find("Arrow").localScale = Vector3(1, 1, 1)
    end
end

function AchievementView:updateButton()
    local list = self.model:getAchievementTypeRedPoint()

    for key, value in pairs(self.mainButtonList) do
        if list[value.name] == true then
            value.transform:FindChild("RedPoint").gameObject:SetActive(true)
        else
            value.transform:FindChild("RedPoint").gameObject:SetActive(false)
        end
    end

    for key, value in pairs(self.subButtonList) do
        for key2, value2 in pairs(value) do
            if list[value2.name] == true then
                value2.transform:FindChild("RedPoint").gameObject:SetActive(true)
            else
                value2.transform:FindChild("RedPoint").gameObject:SetActive(false)
            end
        end
    end

    local rewardRedPoint = self.model:checkAchievementRewardRedPoint()
    if rewardRedPoint then
        self.mainButtonList[1].transform:FindChild("RedPoint").gameObject:SetActive(true)
        if self.rewardEffect == nil then
            local fun = function(effectView)
                local effectObject = effectView.gameObject
                effectObject.name = "Effect"
                effectObject.transform:SetParent(self.totalPanelTabGroup.buttonTab[3].transform)
                effectObject.transform.localScale = Vector3(1.45, 0.55, 1)
                effectObject.transform.localPosition = Vector3(-47, -13, -400)
                effectObject.transform.localRotation = Quaternion.identity

                Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                effectObject:SetActive(true)
            end
            self.rewardEffect = BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
        elseif BaseUtils.isnull(self.rewardEffect.gameObject) then 
            self.rewardEffect.gameObject:SetActive(true)
        end
    else
        self.mainButtonList[1].transform:FindChild("RedPoint").gameObject:SetActive(false)
        if self.rewardEffect ~= nil then
            self.rewardEffect.gameObject:SetActive(false)
        end
    end

    self.parent:ShowTabRedPoint()
end

-----------------------------------------
function AchievementView:update()
    self:updateButton()
	if self.model.currentMain == 1 then
		if self.lastType == 0 then
            self:ShowTotalPanel2()
        else
            self:ShowTotalPanel()
        end
	else
		self:ShowSubPanel()
	end
end

function AchievementView:ShowTotalPanel()
	self.totalPanel:SetActive(true)
	self.subPanel:SetActive(false)
    self.totalPanel2:SetActive(false)
	self:updateTotalPanel()
end

function AchievementView:ShowSubPanel()
	self.totalPanel:SetActive(false)
	self.subPanel:SetActive(true)
    self.totalPanel2:SetActive(false)
	self:updateSubPanel()
end

function AchievementView:ShowTotalPanel2()
    self.lastType = 0
    self.totalPanel:SetActive(false)
    self.subPanel:SetActive(false)
    self.totalPanel2:SetActive(true)
    self:updateTotalPanel2()
end

function AchievementView:updateTotalPanel()
    local badgeData = self.model:getBadgeData(self.model.achNum)
    local nextBadgeData = self.model:getNextBadgeData(self.model.achNum)

    if nextBadgeData == nil then
        self.totalPanel.transform:FindChild("ToatlProgress/Slider"):GetComponent(Slider).value = 1
        self.totalPanel.transform:FindChild("ToatlProgress/NumText"):GetComponent(Text).text = TI18N("敬请期待")
        self.totalPanel.transform:FindChild("ToatlProgress/PreLevelText"):GetComponent(Text).text = tostring(badgeData.num)
        self.totalPanel.transform:FindChild("ToatlProgress/NextLevelText"):GetComponent(Text).text = "9999"

        self.totalPanel.transform:FindChild("AchIconItem1").localPosition = Vector2(-259, 152)
        self.totalPanel.transform:FindChild("Arrow").gameObject:SetActive(false)
        self.totalPanel.transform:FindChild("AchIconItem2").gameObject:SetActive(false)
    else
    	self.totalPanel.transform:FindChild("ToatlProgress/Slider"):GetComponent(Slider).value = self.model.achNum / nextBadgeData.num
    	self.totalPanel.transform:FindChild("ToatlProgress/NumText"):GetComponent(Text).text = string.format("%s/%s", self.model.achNum, nextBadgeData.num)
        self.totalPanel.transform:FindChild("ToatlProgress/PreLevelText"):GetComponent(Text).text = tostring(badgeData.num)
        self.totalPanel.transform:FindChild("ToatlProgress/NextLevelText"):GetComponent(Text).text = tostring(nextBadgeData.num)

        self.totalPanel.transform:FindChild("AchIconItem1/AchIconButton").gameObject:SetActive(true)
        self.totalPanel.transform:FindChild("AchIconItem1/AchIconButton"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(badgeData.sourceId))
        self.totalPanel.transform:FindChild("AchIconItem1/NaneText"):GetComponent(Text).text = badgeData.name
        for i=1, 3 do
            self.totalPanel.transform:FindChild(string.format("AchIconItem1/StarPanel/Star%s", i)).gameObject:SetActive(badgeData.star >= i)
        end

        self.totalPanel.transform:FindChild("AchIconItem1").localPosition = Vector2(-342, 152)
        self.totalPanel.transform:FindChild("Arrow").gameObject:SetActive(true)
        self.totalPanel.transform:FindChild("AchIconItem2").gameObject:SetActive(true)

        self.totalPanel.transform:FindChild("AchIconItem2/AchIconButton").gameObject:SetActive(true)
        self.totalPanel.transform:FindChild("AchIconItem2/AchIconButton"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.badge_icon,tostring(nextBadgeData.sourceId))
        self.totalPanel.transform:FindChild("AchIconItem2/NaneText"):GetComponent(Text).text = nextBadgeData.name
        for i=1, 3 do
            self.totalPanel.transform:FindChild(string.format("AchIconItem2/StarPanel/Star%s", i)).gameObject:SetActive(nextBadgeData.star >= i)
        end
	end

    local datalist = self.model:getAchievementByType(self.model.currentMain, 0)
    self.totalPanel.transform:FindChild("DescText1"):GetComponent(Text).text = string.format("已完成：%s", #datalist)
    self.totalPanel.transform:FindChild("DescText2"):GetComponent(Text).text = string.format("完成度：%.2f%%", #datalist/DataAchievement.data_list_length*100)

    if self.lastType ~= self.model.currentMain or self.lastType2 ~= self.model.currentSub then
        self.selectCell = nil
        self.selectId = nil
    end

    if self.totalPanelType == 3 then
        self.totalPanel.transform:FindChild("DescText"):GetComponent(Text).text = ""
        local datalist = self.model:getAchievementReward()
        for i=1, #datalist do
            local data = datalist[i]
            local item = self.rewardItemList[i]
            local itemSlot = self.rewardItemSlotList[i]
            if item == nil then
                item = GameObject.Instantiate(self.rewardCloner)
                item.transform:SetParent(self.rewardPanelContainer)
                item.transform.localScale = Vector3(1, 1, 1)
                item:SetActive(true)
                self.rewardItemList[i] = item

                itemSlot = ItemSlot.New()
                UIUtils.AddUIChild(item.transform:Find("Icon"), itemSlot.gameObject)
                self.rewardItemSlotList[i] = itemSlot
            end
            item.transform:Find("Title/Text"):GetComponent(Text).text = string.format(TI18N("%s成就"), data.num)

            local itemBaseData = BackpackManager:GetItemBase(data.rewards_commit[1][1])
            local itemData = ItemData.New()
            itemData:SetBase(itemBaseData)
            itemData.quantity = data.rewards_commit[1][3]
            itemSlot:SetAll(itemData, { nobutton = true })
            item.transform:Find("NameText"):GetComponent(Text).text = itemData.name
            item.transform:Find("Task").gameObject:SetActive(data.finish == 2)
            item.transform:Find("Button").gameObject:SetActive(data.finish == 1)

            local effect = item.transform:Find("Icon/Effect")
            if data.finish == 1 then
                local button = item.transform:Find("Button"):GetComponent(Button)
                button.onClick:RemoveAllListeners()
                button.onClick:AddListener(function()
                        AchievementManager.Instance:Send10221(data.id)
                        LuaTimer.Add(500, function() AchievementManager.Instance.OnUpdateList:Fire() end)
                    end)

                if effect == nil then
                    local fun = function(effectView)
                        local effectObject = effectView.gameObject
                        effectObject.name = "Effect"
                        effectObject.transform:SetParent(item.transform:Find("Icon"))
                        effectObject.transform.localScale = Vector3.one
                        effectObject.transform.localPosition = Vector3(-32, -24, -400)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                        effectObject:SetActive(true)
                    end
                    BaseEffectView.New({effectId = 20053, time = nil, callback = fun})
                else
                    effect.gameObject:SetActive(true)
                end
            elseif effect ~= nil then
                effect.gameObject:SetActive(false)
            end
        end
    elseif self.totalPanelType == 2 then
    	local datalist = self.model:getAchievementByType(self.model.currentMain, 0)
    	local length = #datalist
        -- self.totalPanel.transform:FindChild("DescText"):GetComponent(Text).text = string.format(TI18N("近期达成:(已达成%s/%s)"), length, DataAchievement.data_list_length)
        self.totalPanel.transform:FindChild("DescText"):GetComponent(Text).text = ""
        datalist = self.model:sortAchievementData(datalist, 0)
    	if length > 10 then length = 10 end
        for i=1,length do
    	    if self.totalCellObjList[i] == nil then
    	        self.totalCellObjList[i] = GameObject.Instantiate(self.totalPanel_AchievementItem)
    	        self.totalPanelLayout:AddCell(self.totalCellObjList[i])
    	        self:ItemAddListener(self.totalCellObjList[i])
    	    end
    	    self:SetItem(self.totalCellObjList[i], i, datalist[i])
    	end

    	for i=length + 1, #self.totalCellObjList do
    	    self.totalCellObjList[i]:SetActive(false)
    	end

        if length == 0 then
            self.totalPanel.transform:FindChild("Panel/Tips").gameObject:SetActive(true)
        else
            self.totalPanel.transform:FindChild("Panel/Tips").gameObject:SetActive(false)
        end
        -- self.totalContainer.transform.localPosition = Vector3.zero

        if self.lastType ~= self.model.currentMain or self.lastType2 ~= self.model.currentSub then
            local rect = self.totalContainer:GetComponent(RectTransform)
            rect.sizeDelta = Vector2(560, 120 * length)
            rect.anchoredPosition = Vector2.zero
            self.totalPanelLayout:OnScroll(rect.sizeDelta, Vector2.zero)

            self.lastType = self.model.currentMain
            self.lastType2 = self.model.currentSub
        end
    else
        local datalist = self.model:getAchievementByType(self.model.currentMain, 1)
        datalist = self.model:removeHideAchievement(datalist)
        local length = #datalist
        -- self.totalPanel.transform:FindChild("DescText"):GetComponent(Text).text = string.format(TI18N("进行中:%s"), length)
        self.totalPanel.transform:FindChild("DescText"):GetComponent(Text).text = ""
        datalist = self.model:sortAchievementData(datalist, 5)
        datalist = self.model:sortAchievementDataAttention(datalist)

        self.totalContainer3_setting_data.data_list = datalist
        if self.lastType ~= self.model.currentMain or self.lastType2 ~= self.model.currentSub then
            BaseUtils.refresh_circular_list(self.totalContainer3_setting_data)

            self.lastType = self.model.currentMain
            self.lastType2 = self.model.currentSub
        else
            BaseUtils.refresh_circular_list(self.totalContainer3_setting_data)
        end
    end
end

function AchievementView:updateSubPanel()
	local data = self.model.classList[self.model.currentMain].subList[self.model.currentSub]
	if data ~= nil then
		local typeAchNum = self.model.typeAchNumList[data.type]
		local typeAchNumMax = self.model.typeAchNumMaxList[data.type]
		self.subPanel.transform:FindChild("ToatlProgress/NameText"):GetComponent(Text).text = data.name
		self.subPanel.transform:FindChild("ToatlProgress/NumText"):GetComponent(Text).text = string.format("%s/%s", typeAchNum, typeAchNumMax)
		if typeAchNum ~= nil and typeAchNumMax ~= nil then
			self.subPanel.transform:FindChild("ToatlProgress/Slider"):GetComponent(Slider).value = typeAchNum / typeAchNumMax
		end
		local typeNum = self.model.typeNumList[data.type]
		local typeNumMax = self.model.typeNumMaxList[data.type]
		self.subPanel.transform:FindChild("DescText"):GetComponent(Text).text = string.format(TI18N("%s (已达成%s/%s)"), data.name, typeNum, typeNumMax)
	end

    if self.lastType ~= self.model.currentMain or self.lastType2 ~= self.model.currentSub then
        self.selectCell = nil
        self.selectId = nil
    end

	local datalist = self.model:getAchievementByType(self.model.currentMain, self.model.currentSub)
    datalist = self.model:removeHideAchievement(datalist)
	datalist = self.model:hideByGroupId(datalist)
	datalist = self.model:sortAchievementData(datalist, self.sortType)
    datalist = self.model:sortAchievementDataHasReward(datalist)
	-- for i=1,#datalist do
	--     if self.subCellObjList[i] == nil then
	--         self.subCellObjList[i] = GameObject.Instantiate(self.subPanel_AchievementItem)
	--         self.subPanelLayout:AddCell(self.subCellObjList[i])
	--         self:ItemAddListener(self.subCellObjList[i])
	--     end
	--     self:SetItem(self.subCellObjList[i], i, datalist[i])
	-- end

	-- for i=#datalist + 1, #self.subCellObjList do
	--     self.subCellObjList[i]:SetActive(false)
	-- end

 --    -- self.subContainer.transform.localPosition = Vector3.zero
 --    if self.lastType ~= self.model.currentMain or self.lastType2 ~= self.model.currentSub then
 --        local rect = self.subContainer:GetComponent(RectTransform)
 --        rect.sizeDelta = Vector2(560, 120 * #datalist)
 --        rect.anchoredPosition = Vector2.zero
 --        self.subPanelLayout:OnScroll(rect.sizeDelta, Vector2.zero)

 --        self.lastType = self.model.currentMain
 --        self.lastType2 = self.model.currentSub
 --    end

    self.subContainer_setting_data.data_list = datalist
    if self.lastType ~= self.model.currentMain or self.lastType2 ~= self.model.currentSub then
        BaseUtils.refresh_circular_list(self.subContainer_setting_data)

        self.lastType = self.model.currentMain
        self.lastType2 = self.model.currentSub
    else
        BaseUtils.refresh_circular_list(self.subContainer_setting_data)
    end
end

function AchievementView:updateTotalPanel2()
    if self.lastType ~= 0 or self.lastType2 ~= 0 then
        self.selectCell = nil
        self.selectId = nil
    end

    self.totalPanel2.transform:FindChild("DescText"):GetComponent(Text).text = string.format(TI18N("奖励成就:"))

    local datalist = self.model:getAllAchievement()
    -- datalist = self.model:hideByGroupId(datalist)
    datalist = self.model:sortAchievementData(datalist, self.sortType2)
    datalist = self.model:sortAchievementDataHasReward(datalist)
    -- local index = 0
    -- for i=1,#datalist do
    --     if self.model:getHasRewardById(datalist[i].id) then
    --         index = index + 1
    --         if self.totalCellObjList2[index] == nil then
    --             self.totalCellObjList2[index] = GameObject.Instantiate(self.totalPanel_AchievementItem2)
    --             self.totalPanelLayout2:AddCell(self.totalCellObjList2[index])
    --             self:ItemAddListener(self.totalCellObjList2[index])
    --         end
    --         self:SetItem2(self.totalCellObjList2[index], i, datalist[i])
    --     end
    -- end

    -- for i=index+1, #self.totalCellObjList2 do
    --     self.totalCellObjList2[i]:SetActive(false)
    -- end

    -- -- self.totalPanel2.transform:FindChild("DescText"):GetComponent(Text).text = string.format("奖励成就:(已达成%s/%s)", index, self.model.achievement_num_of_hasreward)


    -- -- self.totalContainer2.transform.localPosition = Vector3.zero

    -- if self.lastType ~= 0 or self.lastType2 ~= 0 then
    --     local rect = self.totalContainer2:GetComponent(RectTransform)
    --     rect.sizeDelta = Vector2(560, 120 * index)
    --     rect.anchoredPosition = Vector2.zero
    --     self.totalPanelLayout:OnScroll(rect.sizeDelta, Vector2.zero)

    --     self.lastType = 0
    --     self.lastType2 = 0
    -- end

    local list = {}
    for i=1,#datalist do
        if self.model:getHasRewardById(datalist[i].id) then
            table.insert(list, datalist[i])
        end
    end

    self.totalContainer2_setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.totalContainer2_setting_data)
end

function AchievementView:ItemAddListener(cellObject)
	local btn = nil
    btn = cellObject:GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:CellClick(cellObject) end)

	btn = cellObject.transform:FindChild("ShareButton"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self:ShareButtonClick(cellObject) end)

	btn = cellObject.transform:FindChild("StarPanel"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self:StarPanelClick(cellObject) end)

	btn = cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Button)
	btn.onClick:RemoveAllListeners()
	btn.onClick:AddListener(function() self:RewardClick(cellObject) end)

    btn = cellObject.transform:FindChild("StarItem"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:StarItemClick(cellObject) end)

    btn = cellObject.transform:FindChild("GetRewardButton"):GetComponent(Button)
    btn.onClick:RemoveAllListeners()
    btn.onClick:AddListener(function() self:CellClick(cellObject) end)

    local toggle = cellObject.transform:FindChild("Toggle"):GetComponent(Toggle)
    toggle.onValueChanged:AddListener(function(on) self:ontogglechange(cellObject, on) end)
end

function AchievementView:SetItem(cellObject, i, data)
	cellObject.name = tostring(data.id)
	cellObject:SetActive(true)

	cellObject.transform:FindChild("NameText"):GetComponent(Text).text = data.name
	cellObject.transform:FindChild("DescText"):GetComponent(Text).text = data.desc
	local timeText = TI18N("未达成")
	if data.finish_time ~= 0 then
		local year = os.date("%y", data.finish_time)
		local month = os.date("%m", data.finish_time)
		local day = os.date("%d", data.finish_time)
		timeText = string.format("%s/%s/%s", year, month, day)
	end
	cellObject.transform:FindChild("TimeText"):GetComponent(Text).text = timeText
	cellObject.transform:FindChild("StarItem/DescText"):GetComponent(Text).text = data.ach_num

    local completeNumberData = self.model.achievementCompleteNumber[data.id]
    if completeNumberData ~= nil then
        local num = math.floor(completeNumberData.finish / self.model.achievementCompleteTotalNumber * 100)
        if num == 0 and completeNumberData.finish > 0 then num = 1 end

        cellObject.transform:FindChild("PercentText"):GetComponent(Text).text = string.format("%s%%", num)
    end

    local toggle = cellObject.transform:FindChild("Toggle"):GetComponent(Toggle)
    local attention = self.model.attentionList[data.id]
    self.offtogglechange = true
    if attention then
        toggle.isOn = true
        if data.finish ~= 1 and data.finish ~= 2 then
            toggle.gameObject:SetActive(true)
        else
            toggle.gameObject:SetActive(false)
        end
    else
        toggle.isOn = false
        if self.selectId ~= tonumber(cellObject.name) then
            toggle.gameObject:SetActive(false)
        else
            toggle.gameObject:SetActive(true)
        end
    end
    self.offtogglechange = false

	local star = data.star
	if data.finish ~= 1 and data.finish ~= 2 then
		star = star - 1
	end
	if star == 10 then star = 3 end -- 填10星的显示为3星
	if star == 9 then star = 0 end -- 填10星且未完成的显示为0星
	if star == 0 then
		cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(false)
		cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
		cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
	elseif star == 1 then
		cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
		cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
		cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
	elseif star == 2 then
		cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
		cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
		cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
	elseif star == 3 then
		cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
		cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
		cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(true)
	end

	if self.model:getHasRewardById(data.id) then
		cellObject.transform:FindChild("Reward").gameObject:SetActive(true)
		cellObject.transform:FindChild("gife").gameObject:SetActive(true)

		if data.honor ~= 0 then
			local honorData = DataHonor.data_get_honor_list[data.honor]
			if honorData == nil then
				cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = ""
			else
				cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = string.format(TI18N("称号<color='#225ee7'>[%s]</color>"), honorData.name)
			end
        elseif DataAchievement.data_attr[data.id] ~= nil then
            local attr = DataAchievement.data_attr[data.id].attr
            local attrText = ""
            for i, v in ipairs(attr) do
                attrText = string.format("%s %s", attrText, KvData.GetAttrString(v.key, v.val))
            end
            cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = attrText
		elseif #data.rewards_commit > 0 then
			local rewardData = data.rewards_commit[1]
			local itemBaseData = BackpackManager:GetItemBase(rewardData[1])
			if rewardData[3] > 0 then
				cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = string.format("%s×%s", ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name)), rewardData[3])
			else
				cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name))
			end

            -- local progress = self.model:getProgress(data.progress)
            -- if progress ~= nil then
            --     local progressString = string.format("<color='#ffff00'>%s</color>/%s", progress.value, progress.target_val)
            --     cellObject.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s<color='#ffffff'>(%s)</color>", data.desc, progressString)
            -- else
            --     cellObject.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s", data.desc)
            -- end
		end
	elseif data.finish == 0 then
		cellObject.transform:FindChild("Reward").gameObject:SetActive(false)
		cellObject.transform:FindChild("Progress").gameObject:SetActive(true)
        cellObject.transform:FindChild("Progress"):GetComponent(RectTransform).anchoredPosition = Vector2(-15, -30)
        cellObject.transform:FindChild("gife").gameObject:SetActive(false)
        if data.show_details == 0 then
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
        else
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(true)
        end

		local progress = self.model:getProgress(data.progress)
		cellObject.transform:FindChild("Progress/NumText"):GetComponent(Text).text = string.format("%s/%s", progress.value, progress.target_val)
		cellObject.transform:FindChild("Progress/Slider"):GetComponent(Slider).value = progress.value / progress.target_val
	else
		cellObject.transform:FindChild("Reward").gameObject:SetActive(false)
        cellObject.transform:FindChild("Progress").gameObject:SetActive(false)
        cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
		cellObject.transform:FindChild("gife").gameObject:SetActive(false)
	end

    if data.finish == 0 then
        cellObject.transform:FindChild("Progress").gameObject:SetActive(true)
        cellObject.transform:FindChild("Progress"):GetComponent(RectTransform).anchoredPosition = Vector2(-15, -41.5)
        if data.show_details == 0 then
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
        else
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(true)
        end

        local progress = self.model:getProgress(data.progress)
        cellObject.transform:FindChild("Progress/NumText"):GetComponent(Text).text = string.format("%s/%s", progress.value, progress.target_val)
        cellObject.transform:FindChild("Progress/Slider"):GetComponent(Slider).value = progress.value / progress.target_val
    else
        cellObject.transform:FindChild("Progress").gameObject:SetActive(false)
        cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
    end

	cellObject.transform:FindChild("Tag").gameObject:SetActive(data.finish == 1 or data.finish == 2)
    cellObject.transform:FindChild("RedPoint").gameObject:SetActive(data.finish == 1 and self.model:getHasRewardById(data.id))
    cellObject.transform:FindChild("Select").gameObject:SetActive(self.selectCell == cellObject)
    cellObject.transform:FindChild("GetRewardButton").gameObject:SetActive(data.finish == 1 and self.model:getHasRewardById(data.id))
end

-- 显示有奖励的成就的地方要求特殊处理
function AchievementView:SetItem2(cellObject, i, data)
    cellObject.name = tostring(data.id)
    cellObject:SetActive(true)

    cellObject.transform:FindChild("NameText"):GetComponent(Text).text = data.name
    cellObject.transform:FindChild("DescText"):GetComponent(Text).text = data.desc
    local timeText = TI18N("未达成")
    if data.finish_time ~= 0 then
        local year = os.date("%y", data.finish_time)
        local month = os.date("%m", data.finish_time)
        local day = os.date("%d", data.finish_time)
        timeText = string.format("%s/%s/%s", year, month, day)
    end
    cellObject.transform:FindChild("TimeText"):GetComponent(Text).text = timeText
    cellObject.transform:FindChild("StarItem/DescText"):GetComponent(Text).text = data.ach_num

    local completeNumberData = self.model.achievementCompleteNumber[data.id]
    if completeNumberData ~= nil then
        local num = math.floor(completeNumberData.finish / self.model.achievementCompleteTotalNumber * 100)
        if num == 0 and completeNumberData.finish > 0 then num = 1 end

        cellObject.transform:FindChild("PercentText"):GetComponent(Text).text = string.format("%s%%", num)
    end

    local toggle = cellObject.transform:FindChild("Toggle"):GetComponent(Toggle)
    local attention = self.model.attentionList[data.id]
    self.offtogglechange = true
    if attention then
        toggle.isOn = true
        if data.finish ~= 1 and data.finish ~= 2 then
            toggle.gameObject:SetActive(true)
        else
            toggle.gameObject:SetActive(false)
        end
    else
        toggle.isOn = false
        if self.selectId ~= tonumber(cellObject.name) then
            toggle.gameObject:SetActive(false)
        else
            toggle.gameObject:SetActive(true)
        end
    end
    self.offtogglechange = false

    local star = data.star
    if data.finish ~= 1 and data.finish ~= 2 then
        star = star - 1
    end
    if star == 10 then star = 3 end -- 填10星的显示为3星
    if star == 9 then star = 0 end -- 填10星且未完成的显示为0星
    if star == 0 then
        cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(false)
        cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
        cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 1 then
        cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
        cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 2 then
        cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
        cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 3 then
        cellObject.transform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        cellObject.transform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
        cellObject.transform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(true)
    end

    if self.model:getHasRewardById(data.id) then
        cellObject.transform:FindChild("Reward").gameObject:SetActive(true)
        cellObject.transform:FindChild("Progress").gameObject:SetActive(true)
        cellObject.transform:FindChild("Progress"):GetComponent(RectTransform).anchoredPosition = Vector2(-15, -41.5)
        cellObject.transform:FindChild("gife").gameObject:SetActive(true)
        if data.show_details == 0 then
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
        else
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(true)
        end

        if data.honor ~= 0 then
            local honorData = DataHonor.data_get_honor_list[data.honor]
            if honorData == nil then
                cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = ""
            else
                cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = string.format(TI18N("称号<color='#225ee7'>[%s]</color>"), honorData.name)
            end
        elseif DataAchievement.data_attr[data.id] ~= nil then
            local attr = DataAchievement.data_attr[data.id].attr
            local attrText = ""
            for i, v in ipairs(attr) do
                attrText = string.format("%s %s", attrText, KvData.GetAttrString(v.key, v.val))
            end
            cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = attrText
        elseif #data.rewards_commit > 0 then
            local rewardData = data.rewards_commit[1]
            local itemBaseData = BackpackManager:GetItemBase(rewardData[1])
            if rewardData[3] > 0 then
                cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = string.format("%s×%s", ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name)), rewardData[3])
            else
                cellObject.transform:FindChild("Reward/RewardText"):GetComponent(Text).text = ColorHelper.color_item_name(itemBaseData.quality , string.format("[%s]", itemBaseData.name))
            end

            -- local progress = self.model:getProgress(data.progress)
            -- if progress ~= nil then
            --     local progressString = string.format("<color='#ffff00'>%s</color>/%s", progress.value, progress.target_val)
            --     cellObject.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s<color='#ffffff'>(%s)</color>", data.desc, progressString)
            -- else
            --     cellObject.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s", data.desc)
            -- end
        end
    elseif data.finish == 0 then
        cellObject.transform:FindChild("Reward").gameObject:SetActive(false)
        cellObject.transform:FindChild("Progress").gameObject:SetActive(true)
        cellObject.transform:FindChild("Progress"):GetComponent(RectTransform).anchoredPosition = Vector2(-15, -30)
        cellObject.transform:FindChild("gife").gameObject:SetActive(false)
        if data.show_details == 0 then
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
        else
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(true)
        end

        local progress = self.model:getProgress(data.progress)
        cellObject.transform:FindChild("Progress/NumText"):GetComponent(Text).text = string.format("%s/%s", progress.value, progress.target_val)
        cellObject.transform:FindChild("Progress/Slider"):GetComponent(Slider).value = progress.value / progress.target_val
    else
        cellObject.transform:FindChild("Reward").gameObject:SetActive(false)
        cellObject.transform:FindChild("Progress").gameObject:SetActive(false)
        cellObject.transform:FindChild("gife").gameObject:SetActive(false)
        cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
    end

    if data.finish == 0 then
        cellObject.transform:FindChild("Progress").gameObject:SetActive(true)
        cellObject.transform:FindChild("Progress"):GetComponent(RectTransform).anchoredPosition = Vector2(-15, -41.5)
        if data.show_details == 0 then
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
        else
            cellObject.transform:FindChild("DescButton").gameObject:SetActive(true)
        end

        local progress = self.model:getProgress(data.progress)
        cellObject.transform:FindChild("Progress/NumText"):GetComponent(Text).text = string.format("%s/%s", progress.value, progress.target_val)
        cellObject.transform:FindChild("Progress/Slider"):GetComponent(Slider).value = progress.value / progress.target_val
    else
        cellObject.transform:FindChild("Progress").gameObject:SetActive(false)
        cellObject.transform:FindChild("DescButton").gameObject:SetActive(false)
    end

    cellObject.transform:FindChild("Tag").gameObject:SetActive(data.finish == 1 or data.finish == 2)
    cellObject.transform:FindChild("RedPoint").gameObject:SetActive(data.finish == 1 and self.model:getHasRewardById(data.id))
    cellObject.transform:FindChild("Select").gameObject:SetActive(self.selectCell == cellObject)
    cellObject.transform:FindChild("GetRewardButton").gameObject:SetActive(data.finish == 1 and self.model:getHasRewardById(data.id))
    ------------- 特殊处理的地方
    cellObject.transform:FindChild("ShareButton").gameObject:SetActive(false)
end

function AchievementView:totalPanelChangeTab(index)
    if self.totalPanelType == index then return end
    self.totalPanelType = index

    if self.totalPanelType == 1 then
        self.totalContainer3.parent.gameObject:SetActive(true)
        self.totalContainer.parent.gameObject:SetActive(false)
        self.rewardPanel.gameObject:SetActive(false)

        self:updateTotalPanel()
    elseif self.totalPanelType == 2 then
        self.totalContainer3.parent.gameObject:SetActive(false)
        self.totalContainer.parent.gameObject:SetActive(true)
        self.rewardPanel.gameObject:SetActive(false)

        self:updateTotalPanel()
    elseif self.totalPanelType == 3 then
        self.totalContainer3.parent.gameObject:SetActive(false)
        self.totalContainer.parent.gameObject:SetActive(false)
        self.rewardPanel.gameObject:SetActive(true)

        self:updateTotalPanel()
    end
end

function AchievementView:CellClick(cellObject)
    local data = self.model.achievementList[tonumber(cellObject.name)]
    if data == nil then data = self.model.allAchievementList[tonumber(cellObject.name)] end
    if data == nil then return end

    if data.finish == 1 and self.model:getHasRewardById(data.id) then
        AchievementManager.Instance:Send10221(data.id)
    end

    if self.selectCell ~= nil then
        self.selectCell.transform:FindChild("Select").gameObject:SetActive(false)
        if not self.model.attentionList[tonumber(self.selectCell.name)] then
            self.selectCell.transform:FindChild("Toggle").gameObject:SetActive(false)
        end
    end
    self.selectCell = cellObject
    self.selectId = tonumber(cellObject.name)
    self.selectCell.transform:FindChild("Select").gameObject:SetActive(true)
    if data.finish == 0 then self.selectCell.transform:FindChild("Toggle").gameObject:SetActive(true) end
end

function AchievementView:DetailsClick(cellObject)
    local data = self.model.achievementList[tonumber(cellObject.name)]
    if data == nil then data = self.model.allAchievementList[tonumber(cellObject.name)] end
    if data == nil then return end
BaseUtils.dump(data)
    self.model:OpenAchievementDetailsPanel(data)
end

function AchievementView:ShareButtonClick(cellObject)
    local data = self.model.achievementList[tonumber(cellObject.name)]
    if data == nil then return end

    if data.finish == 1 or data.finish == 2 then
        local btns = {{label = TI18N("分享好友"), callback = function() self:ShareToFriend(data) end}
                    , {label = TI18N("世界频道"), callback = function() self:ShareToWorld(data) end}
                    , {label = TI18N("公会频道"), callback = function() self:ShareToGuild(data) end}}
        TipsManager.Instance:ShowButton({gameObject = cellObject.transform:FindChild("ShareButton").gameObject, data = btns})
    else
        data = self.model:getMaxStarAndFinishInGroup(data.group_id)
        if data ~= nil then
            local btns = {{label = TI18N("分享好友"), callback = function() self:ShareToFriend(data) end}
                    , {label = TI18N("世界频道"), callback = function() self:ShareToWorld(data) end}
                    , {label = TI18N("公会频道"), callback = function() self:ShareToGuild(data) end}}
            TipsManager.Instance:ShowButton({gameObject = cellObject.transform:FindChild("ShareButton").gameObject, data = btns})
        else
        	NoticeManager.Instance:FloatTipsByString(TI18N("请达成后再分享吧{face_1,9}"))
        end
    end
end

function AchievementView:ShareToFriend(data)
    local callBack = function(_, friendData) self.model:ShareAchievement(MsgEumn.ExtPanelType.Friend, friendData, data.id) NoticeManager.Instance:FloatTipsByString(TI18N("分享成功")) end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack })
end

function AchievementView:ShareToWorld(data)
    -- local data = self.model.achievementList[tonumber(cellObject.name)]
    -- if data == nil then return end

    self.model:ShareAchievement(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.World, data.id)
end

function AchievementView:ShareToGuild(data)
    -- local data = self.model.achievementList[tonumber(cellObject.name)]
    -- if data == nil then return end

    if GuildManager.Instance.model:check_has_join_guild() then
        self.model:ShareAchievement(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.Guild, data.id)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
end

function AchievementView:StarPanelClick(cellObject)
    local data = self.model.allAchievementList[tonumber(cellObject.name)]

    if data.star == 10 then
        self.req_group = { data.id }
        self.req_cellObject = cellObject
        -- AchievementManager.Instance:Send10229(data.id)
        self:showCompleteNumber()
    else
        self.req_group = {}
        self.req_cellObject = cellObject

        for _,value in pairs(DataAchievement.data_list) do
            if value.group_id == data.group_id then
                table.insert(self.req_group, value.id)
                -- AchievementManager.Instance:Send10229(value.id)
            end
        end
        print(#self.req_group)
        self:showCompleteNumber()
    end
end

function AchievementView:showCompleteNumber()
    if not BaseUtils.isnull(self.req_cellObject) then
        local tipsText = {}
        table.sort(self.req_group)
        for _,value in ipairs(self.req_group) do
            local data = self.model.achievementCompleteNumber[value]
            if data == nil then
                data = { finish = 0 }
            end

            local achievementData = self.model.allAchievementList[value]
            local num = math.floor(data.finish / self.model.achievementCompleteTotalNumber * 100)
            if num == 0 and data.finish > 0 then num = 1 end

            local star = achievementData.star
            if star > 3 then star = 3 end
            local color = "#00ff00"
            if achievementData.finish == 0 then
                color = "#ffffff"
            end
            local text = string.format(TI18N("<color='%s'>%s星·<color='#ffff00'>%s%%</color> 玩家完成</color>"), color, BaseUtils.NumToChn(star), num)
            table.insert(tipsText, text)
        end

        if #tipsText == #self.req_group then
            TipsManager.Instance:ShowTitle({gameObject = self.req_cellObject.transform:FindChild("StarPanel").gameObject, itemData = tipsText, title = TI18N("全服进度")})
            self.req_group = {}
            self.req_cellObject = nil
        end
    end
end

function AchievementView:RewardClick(cellObject)
	local data = DataAchievement.data_list[tonumber(cellObject.name)]
	if data == nil then return end
	if data.honor ~= 0 then
		local honorData = DataHonor.data_get_honor_list[data.honor]
		HonorManager.Instance.model.current_data = honorData
    	HonorManager.Instance.model:InitMainUI()
	elseif #data.rewards_commit > 0 then
		local itemdata = ItemData.New()
	    itemdata:SetBase(BackpackManager.Instance:GetItemBase(data.rewards_commit[1][1]))
		TipsManager.Instance:ShowItem({["gameObject"] = cellObject.transform:FindChild("Reward").gameObject, ["itemData"] = itemdata, extra = { nobutton = true } })
	end
end

function AchievementView:StarItemClick(cellObject)
    local data = DataAchievement.data_list[tonumber(cellObject.name)]
    if data == nil then return end
    local tipsText = {string.format(TI18N("完成可获得<color='#ffff00'>%s</color>成就评分"), data.ach_num)}
    TipsManager.Instance:ShowText({gameObject = cellObject.transform:FindChild("StarItem").gameObject, itemData = tipsText})
end

function AchievementView:ShowTotalStar()
    local tipsText = {string.format(TI18N("当前成就评分：<color='#ffff00'>%s</color>"), self.model.achNum)}
    TipsManager.Instance:ShowText({gameObject = self.totalPanel.transform:FindChild("ToatlProgress").gameObject, itemData = tipsText})
end

function AchievementView:ShowBadgeTips()
    self.model:OpenAchievementBadgeTips()
end

function AchievementView:ontogglechange(cellObject, on)
    if self.offtogglechange then return end
    local id = tonumber(cellObject.name)
    if on then
        if self.model.attentionNum == 5 then
                self.offtogglechange = true
                cellObject.transform:FindChild("Toggle"):GetComponent(Toggle).isOn = false
                self.offtogglechange = false
                NoticeManager.Instance:FloatTipsByString(TI18N("最多关注5个成就，可取消已关注成就"))
        elseif not self.model.attentionList[id] then
            AchievementManager.Instance:Send10231(id)
        end
    elseif not on and self.model.attentionList[id] then
        AchievementManager.Instance:Send10234(id)
    end
end

function AchievementView:OnClickSortButton()
	if self.sortType == 1 then
		self.sortType = 2
		self.subPanel.transform:FindChild("SortButton/Image").localScale = Vector3(-1, 1, 1)
		self.subPanel.transform:FindChild("SortButton/Text"):GetComponent(Text).text = TI18N("已完成")
	else
		self.sortType = 1
		self.subPanel.transform:FindChild("SortButton/Image").localScale = Vector3(1, 1, 1)
		self.subPanel.transform:FindChild("SortButton/Text"):GetComponent(Text).text = TI18N("未完成")
	end

	self:updateSubPanel()
end

function AchievementView:SortTotalPanel2()
    if self.sortType2 == 3 then
        self.sortType2 = 4
        self.totalPanel2.transform:FindChild("SortButton/Image").localScale = Vector3(-1, 1, 1)
        self.totalPanel2.transform:FindChild("SortButton/Text"):GetComponent(Text).text = TI18N("已完成")
    else
        self.sortType2 = 3
        self.totalPanel2.transform:FindChild("SortButton/Image").localScale = Vector3(1, 1, 1)
        self.totalPanel2.transform:FindChild("SortButton/Text"):GetComponent(Text).text = TI18N("未完成")
    end

    self:updateTotalPanel2()
end

function AchievementView:OnValueChanged(type)
    local item_list
    local container
    local itemHeight
    local containerY
    local scrollContainerHeight

    if type == 1 then
        item_list = self.subContainer_item_list
        container = self.subContainer
        itemHeight = self.subContainer_single_item_height
        containerY = self.subContainer:GetComponent(RectTransform).anchoredPosition.y
        scrollContainerHeight = self.subContainer_scroll_con_height
    elseif type == 2 then
        -- item_list = self.totalContainer3_item_list

    end

    for i=1, #item_list do
        local item = item_list[i]
        -- item:OnValueChanged()

        local outY = -item.transform.anchoredPosition.y < containerY or -item.transform.anchoredPosition.y + item.transform.sizeDelta.y > containerY + scrollContainerHeight
        item.getRewardButton:SetActive(not outY)
    end
end
