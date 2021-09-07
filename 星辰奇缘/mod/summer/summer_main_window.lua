--2016/7/14
--zzl
SummerMainWindow  =  SummerMainWindow or BaseClass(BaseWindow)

function SummerMainWindow:__init(model)
    self.name  =  "SummerMainWindow"
    self.model  =  model
    -- 缓存
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end

    self.resList  =  {
        {file  =  AssetConfig.summer_main_window, type  =  AssetType.Main}
        ,{file  =  AssetConfig.summer_res, type  =  AssetType.Dep}
    }




    self.holdTime = 3

    self.windowId = WindowConfig.WinID.summer_activity_window


    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.result_time_str = ""
    self.result_reward_str = ""

    self.tab_btn_list = {}
    self.tab_panel_list = {}

    self.update_point = function()
        self:updateRedPoint()
    end

    self.last_panel = nil

    self.is_init = false

    self.selectIndex = 1

    return self
end

function SummerMainWindow:OnHide()

end

function SummerMainWindow:OnShow()
    -- BaseUtils.dump(self.openArgs,"self.openArgs == ")
    if self.openArgs ~= nil then
        self.selectIndex = self.openArgs[1]
    end
    self:update_tab_list()
end

function SummerMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.summer_fruit_plant_update, self.update_point)
    EventMgr.Instance:RemoveListener(event_name.summer_login_update, self.update_point)

    self.OnOpenEvent:RemoveAll()
    for k,v in pairs(self.tab_panel_list) do
        if v ~= nil then
            v:DeleteMe()
        end
    end

    self.tab_btn_list = nil
    self.tab_panel_list = nil
    self.last_panel = nil
    self.is_init = false
    self.has_init = false
    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function SummerMainWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SummerMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.summer_main_window))
    self.gameObject:SetActive(false)
    self.gameObject.name = "SummerMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.transform:GetComponent(RectTransform).localPosition = Vector3.zero


    self.MainCon = self.transform:Find("MainCon")

    local closeBtn = self.MainCon:Find("CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseMainUI()
    end)

    self.RightCon = self.MainCon:Find("RightCon")

    self.LeftCon = self.MainCon:Find("LeftCon")
    self.MaskCon = self.LeftCon:Find("MaskCon")
    self.ScrollCon = self.MaskCon:Find("ScrollCon")
    self.Container = self.ScrollCon:Find("Container")
    self.Origin_TabBtn = self.Container:Find("TabBtn")
    self.Origin_TabBtn.gameObject:SetActive(false)

    self.is_init = true

    EventMgr.Instance:AddListener(event_name.summer_fruit_plant_update, self.update_point)
    EventMgr.Instance:AddListener(event_name.summer_login_update, self.update_point)

    -- self:update_tab_list()
end


--更新显示tab,根据对应的一些过滤来显示tab
function SummerMainWindow:update_tab_list()
    if self.is_init == false then
        return
    end

    local tab_data_list = BaseUtils.copytab(self.model.tab_data_list)

    --排序
    table.sort(tab_data_list, function(a,b)
        return a.sortIndex < b.sortIndex
    end)

    for k, v in pairs(self.tab_btn_list) do
        v.gameObject:SetActive(false)
    end

    local index = 1
    for i=1,#tab_data_list do
        local tab_data = tab_data_list[i]
        if tab_data.endTime > BaseUtils.BASE_TIME or tab_data.endTime == 0 then
            local tab_btn = self.tab_btn_list[index]
            if tab_btn == nil then
                tab_btn = self:create_tab_btn(index)
                table.insert(self.tab_btn_list, tab_btn)
            end
            tab_btn.ImgSelected.gameObject:SetActive(false)
            tab_btn.ImgUnSelected.gameObject:SetActive(false)
            self:set_tab_btn(tab_btn, tab_data)
            tab_btn.gameObject:SetActive(true)
            index = index + 1
        end
    end

    if self.tab_btn_list[self.selectIndex] == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("活动已结束"))
        self.selectIndex = 1
    end
    self:on_click_tab_btn(self.tab_btn_list[self.selectIndex], self.selectIndex)
end


----------------------------------tabBtn创建逻辑
--创建一个tab_btn的表
function SummerMainWindow:create_tab_btn(index)
    local tab_btn = {}
    tab_btn.gameObject = GameObject.Instantiate(self.Origin_TabBtn.gameObject)
    tab_btn.gameObject:SetActive(true)
    tab_btn.transform = tab_btn.gameObject.transform
    tab_btn.transform:SetParent(self.Origin_TabBtn.parent)

    tab_btn.ImgSelected = tab_btn.transform:Find("ImgSelected")
    tab_btn.ImgSelected_txt = tab_btn.ImgSelected:Find("TxtSelectedBtn"):GetComponent(Text)
    tab_btn.ImgUnSelected = tab_btn.transform:Find("ImgUnSelected")
    tab_btn.ImgUnSelected_txt = tab_btn.ImgUnSelected:Find("TxtUnSelectedBtn"):GetComponent(Text)
    tab_btn.ImgIcon = tab_btn.transform:Find("ImgIcon"):GetComponent(Image)
    tab_btn.redPointObj = tab_btn.transform:Find("RedPointImage").gameObject
    tab_btn.transform.localPosition = Vector3.one
    tab_btn.transform.localScale = Vector3.one


    tab_btn.transform:GetComponent(Button).onClick:AddListener(function()
        self:on_click_tab_btn(tab_btn, index)
    end)
    local newY = (index - 1)*-60
    local rect = tab_btn.transform:GetComponent(RectTransform)
    rect.anchoredPosition = Vector2(0, newY)

    return tab_btn
end

--对tab_btn进行数据填充
function SummerMainWindow:set_tab_btn(tab_btn, _data)
    tab_btn.data = _data
    tab_btn.ImgSelected_txt.text = _data.btn_str
    tab_btn.ImgUnSelected_txt.text = _data.btn_str
    tab_btn.ImgIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.summer_res, _data.iconName)
    tab_btn.ImgIcon.transform:GetComponent(RectTransform).sizeDelta = Vector2(_data.iconW, _data.iconH)
end

--切换按钮选中状态
function SummerMainWindow:switch_tab_btn(tab_btn, state)
    tab_btn.ImgSelected.gameObject:SetActive(state)
    tab_btn.ImgUnSelected.gameObject:SetActive(not state)
end

--按钮点击逻辑
function SummerMainWindow:on_click_tab_btn(tab_btn, index)
    self.selectIndex = index
    for i=1,#self.tab_btn_list do
        local temp = self.tab_btn_list[i]
        self:switch_tab_btn(temp, false)
    end

    self:switch_tab_btn(tab_btn, true)

    --更新右边
    self:update_right(tab_btn)
end

function SummerMainWindow:updateRedPoint()
    local tab_data_list = BaseUtils.copytab(self.model.tab_data_list)

    --排序
    table.sort(tab_data_list, function(a,b)
        return a.sortIndex < b.sortIndex
    end)

    for i=1,#tab_data_list do
        local tab_data = tab_data_list[i]
        local tab_btn = self.tab_btn_list[i]
        if tab_btn ~= nil and SummerManager.Instance.redPointDataDic[tab_data.id] ~= nil then
            tab_btn.redPointObj:SetActive(SummerManager.Instance.redPointDataDic[tab_data.id])
        end
    end
end

-----------------------------------------------右边逻辑
function SummerMainWindow:update_right(tab_btn)
    self.cur_tab_btn= tab_btn
    local selected_panel = nil

    if tab_btn.data.id == 1 then
        --水果种植
        if self.tab_panel_list[tab_btn.data.id] == nil then
            self.tab_panel_list[tab_btn.data.id] = SummerFruitPlantPanel.New(self)
        end
        selected_panel = self.tab_panel_list[tab_btn.data.id]
    elseif tab_btn.data.id == 2 then
        if self.tab_panel_list[tab_btn.data.id] == nil then
            self.tab_panel_list[tab_btn.data.id] = SummerLossChildPanel.New(self)
        end
        selected_panel = self.tab_panel_list[tab_btn.data.id]
    elseif tab_btn.data.id == 3 then
        if self.tab_panel_list[tab_btn.data.id] == nil then
            self.tab_panel_list[tab_btn.data.id] = SummerLoginDayPanel.New(self.model,self.RightCon)
        end
        selected_panel = self.tab_panel_list[tab_btn.data.id]
    elseif tab_btn.data.id == 4 then
        if self.tab_panel_list[tab_btn.data.id] == nil then
            self.tab_panel_list[tab_btn.data.id] = SeekChildrenPanel.New(self.model,self.RightCon)
        end
        selected_panel = self.tab_panel_list[tab_btn.data.id]
    end

    self:updateRedPoint()

    if selected_panel == self.last_panel then
        --选中的是同一个
        return
    end

    if self.last_panel ~= nil then
        self.last_panel:Hiden()
    end

    if selected_panel ~= nil then
        selected_panel:Show()
        self.last_panel = selected_panel
    end
end
