-- 作者:jia
-- 6/19/2017 11:53:56 AM
-- 功能:星座驾照荣誉一览窗口

ConstellationHonorWindow = ConstellationHonorWindow or BaseClass(BaseWindow)
function ConstellationHonorWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.constellation_honor_window
    self.resList = {
        { file = AssetConfig.constellationhonorwindow, type = AssetType.Main }
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    -- self.OnHideEvent:Add(function() self:OnHide() end)

    self.ItemList = { }
    self.hasInit = false
end

function ConstellationHonorWindow:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function ConstellationHonorWindow:OnHide()

end

function ConstellationHonorWindow:OnOpen()
    self:UpdateInfo()
end

function ConstellationHonorWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.constellationhonorwindow))
    self.gameObject.name = "ConstellationHonorWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.Main = self.transform:Find("Main")
    self.subPanel = self.transform:Find("Main/PanelCon/Panel").gameObject

    self.subContainer = self.subPanel.transform:FindChild("Container")
    self.subItem = self.subContainer.transform:FindChild("1").gameObject
    self.subContainer_vScroll = self.subPanel.transform:GetComponent(ScrollRect)
    self.subContainer_vScroll.onValueChanged:AddListener(
    function()
        BaseUtils.on_value_change(self.setting_data)
    end )

    for i = 1, 8 do
        local go = self.subContainer.transform:FindChild(tostring(i)).gameObject
        local item = ConstellationHonorItem.New(go, self)
        table.insert(self.ItemList, item)
    end
    self.item_height = self.subItem.transform:GetComponent(RectTransform).sizeDelta.y
    self.scroll_con_height = self.subContainer:GetComponent(RectTransform).sizeDelta.y
    self.item_con_last_y = self.subContainer:GetComponent(RectTransform).anchoredPosition.y

    self.setting_data = {
        item_list = self.ItemList-- 放了 item类对象的列表
        ,
        data_list = { }-- 数据列表
        ,
        item_con = self.subContainer-- item列表的父容器
        ,
        single_item_height = self.item_height-- 一条item的高度
        ,
        item_con_last_y = self.item_con_last_y-- 父容器改变时上一次的y坐标
        ,
        scroll_con_height = self.scroll_con_height-- 显示区域的高度
        ,
        item_con_height = 0-- item列表的父容器高度
        ,
        scroll_change_count = 0-- 父容器滚动累计改变值
        ,
        data_head_index = 0-- 数据头指针
        ,
        data_tail_index = 0-- 数据尾指针
        ,
        item_head_index = 0-- item列表头指针
        ,
        item_tail_index = 0-- item列表尾指针
    }

    self.Tips = self.transform:Find("Main/PanelCon/Panel/Tips")
    self.Tips.gameObject:SetActive(false)
    self.CloseButton = self.transform:Find("Main/CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener( function() self.model:CloseHonorWindow() end)
end

function ConstellationHonorWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


function ConstellationHonorWindow:OnValueChanged(type)
    for i = 1, #self.ItemList do
        local item = self.ItemList[i]
        local outY = - item.transform.anchoredPosition.y < self.item_con_last_y or
        - item.transform.anchoredPosition.y + item.transform.sizeDelta.y > self.item_con_last_y + self.scroll_con_height
        item.getRewardButton:SetActive(not outY)
    end
end

function ConstellationHonorWindow:UpdateInfo()
    local list = { }
    local datalist = AchievementManager.Instance.model:getAchievementByType(7, 6)
    BaseUtils.dump(datalist, "datalist")
    if datalist ~= nil then
        for _, item in pairs(datalist) do
            if item.finish == CampaignEumn.Status.Accepted or item.finish == CampaignEumn.Status.Finish then
                table.insert(list, item)
            end
        end
    end
    self.Tips.gameObject:SetActive(#list == 0)
    self.setting_data.data_list = list
    BaseUtils.refresh_circular_list(self.setting_data)
end