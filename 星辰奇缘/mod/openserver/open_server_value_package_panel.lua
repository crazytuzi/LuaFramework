-- @author hze
-- @date #19/05/11#
-- @开服超值礼包2活动
OpenServerValuePackagePanel = OpenServerValuePackagePanel or BaseClass(BasePanel)

function OpenServerValuePackagePanel:__init(model, parent)
    self.model = model
    self.Mgr = OpenServerManager.Instance
    self.parent = parent
    self.name = "OpenServerValuePackagePanel"

    self.resList = {
        {file = AssetConfig.open_server_valuepackagepanel, type = AssetType.Main}
        ,{file = AssetConfig.open_server_valuepackagepanel_bg, type = AssetType.Main}
        ,{file = AssetConfig.open_server_valuepackagepanel_txt, type = AssetType.Main}
        ,{file = AssetConfig.open_server_textures2, type = AssetType.Dep}
    }

    self.timeFormat = TI18N("%s月%s日-%s月%s日")
    self.itemList = {}
    self.reloadListener = function(data) self:Reload(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function OpenServerValuePackagePanel:__delete()
    self.OnHideEvent:Fire()
    if self.rewardList ~= nil then
        for _,v in pairs(self.rewardList) do
            if v ~= nil then
                v.layout:DeleteMe()
                v.btnTextExt:DeleteMe()
                v.imageLoader:DeleteMe()
                for _,gift in pairs(v.itemList) do
                    if gift ~= nil then
                        gift.data:DeleteMe()
                        gift.slot:DeleteMe()
                    end
                end
            end
        end
        self.rewardList = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    self:AssetClearAll()
end

function OpenServerValuePackagePanel:OnOpen()
    self:RemoveListeners()
    self.Mgr.valuePackageUpdateEvent:AddListener(self.reloadListener)
    
    local campData = DataCampaign.data_list[self.campId]
    local start_time = CampaignManager.Instance.open_srv_time
    local open_time = start_time + campData.cli_start_time[1][2] * 24 * 3600 + campData.cli_start_time[1][3]
    local end_time = start_time + campData.cli_end_time[1][2] * 24 * 3600 + campData.cli_end_time[1][3]
    self.timeTxt.text = string.format( self.timeFormat, tonumber(os.date("%m", open_time)), tonumber(os.date("%d", open_time)), tonumber(os.date("%m", end_time)), tonumber(os.date("%d", end_time)))
    -- self.timeTxt.text = string.format(self.timeFormat, campData.cli_start_time[1][2], campData.cli_start_time[1][3], campData.cli_end_time[1][2], campData.cli_end_time[1][3])
    
    self.tipsData = {campData.content}  

    self.Mgr:send20475()
end

function OpenServerValuePackagePanel:OnHide()
    self:RemoveListeners()
end

function OpenServerValuePackagePanel:RemoveListeners()
    self.Mgr.valuePackageUpdateEvent:RemoveListener(self.reloadListener)
end

function OpenServerValuePackagePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_valuepackagepanel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent, self.gameObject)
    UIUtils.AddBigbg(t:Find("TopCon/ImgBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_valuepackagepanel_bg)))
    UIUtils.AddBigbg(t:Find("TopCon/TxtBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.open_server_valuepackagepanel_txt)))

    self.timeTxt = t:Find("TopCon/TimeTxt"):GetComponent(Text)
    self.containerRect = t:Find("Container")
    for i = 1, 3 do
        local tab = {}
        tab.obj = self.containerRect:Find(string.format("Item%s",i)).gameObject
        tab.trans = tab.obj.transform
        tab.nameTxt = tab.trans:Find("NameTxt"):GetComponent(Text)
        tab.countTxt = tab.trans:Find("CountTxt"):GetComponent(Text)
        tab.originTxt = tab.trans:Find("OriginTxt"):GetComponent(Text)
        tab.slotContainer = tab.trans:Find("SlotContainer")
        tab.buyed = tab.trans:Find("Buyed")
        tab.slotList = {}
        tab.slotListSlot = {}
        for j = 1, 4 do
            tab.slotList[j] =  tab.slotContainer:Find(string.format( "SlotCon%s", j))
        end
        tab.btn = tab.trans:Find("Button"):GetComponent(Button)
        tab.priceTxt = tab.btn.transform:Find("Text"):GetComponent(Text)
        self.itemList[i] = tab
    end

    local tipsBtn = self.transform:Find("TipsBtn"):GetComponent(Button)
    -- tipsBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = tipsBtn.gameObject, itemData = self.tipsData}) end)
end

function OpenServerValuePackagePanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function OpenServerValuePackagePanel:Reload(data)
    local protodata = BaseUtils.copytab(data)
    for k,v in ipairs(protodata.camp_info) do
        local tab = self.itemList[k]
        tab.nameTxt.text = v.title
        tab.countTxt.text = string.format(TI18N("限购%s/%s"), v.time, v.all_time)    
        tab.originTxt.text = v.origin_val
        tab.priceTxt.text = v.need_val
        tab.btn.onClick:RemoveAllListeners()
        tab.btn.onClick:AddListener(function() self.Mgr:send20476(v.group_id) end)
        for key, val in ipairs(v.reward) do
            local itemslot = tab.slotListSlot[key]
            if itemslot == nil then 
                itemslot = ItemSlot.New()
                UIUtils.AddUIChild(tab.slotList[key], itemslot.gameObject)
                tab.slotListSlot[key] = itemslot
            end 
            local itemData = ItemData.New()
            local baseData = DataItem.data_get[val.item_base_id]
            itemData:SetBase(baseData)
            itemslot:SetAll(itemData, {inbag = false, nobutton = true})
            itemslot:SetNum(val.num)
            itemslot:ShowEffect(val.client_effect == 1,20223)
        end

        tab.btn.gameObject:SetActive(v.time ~= 0)
        tab.buyed.gameObject:SetActive(v.time == 0)


        --简单布局
        local w = tab.slotContainer.sizeDelta.x * 0.5
        local h = tab.slotContainer.sizeDelta.y * 0.5
        if #v.reward ==  4 then 
            tab.slotList[1].anchoredPosition = Vector2(-w*0.5, h*0.5)
            tab.slotList[2].anchoredPosition = Vector2(w*0.5, h*0.5)
            tab.slotList[3].anchoredPosition = Vector2(-w*0.5, -h*0.5)
            tab.slotList[4].anchoredPosition = Vector2(w*0.5, -h*0.5)
        elseif #v.reward == 3 then 
            tab.slotList[1].anchoredPosition = Vector2(0, h*0.5)
            tab.slotList[2].anchoredPosition = Vector2(-w*0.5, -h*0.5)
            tab.slotList[3].anchoredPosition = Vector2(w*0.5, -h*0.5)
        elseif #v.reward == 2 then 
            tab.slotList[1].anchoredPosition = Vector2(-w*0.5,0)
            tab.slotList[2].anchoredPosition = Vector2(w*0.5,0)
        elseif #v.reward == 1 then 
            tab.slotList[1].anchoredPosition = Vector2(0,0)
        end
    end
end



