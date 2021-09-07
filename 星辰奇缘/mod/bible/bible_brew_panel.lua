BibleBrewPanel = BibleBrewPanel or BaseClass(BasePanel)

function BibleBrewPanel:__init(model,parent)
    self.model = model
    self.mgr = BibleManager.Instance
    self.parent = parent
    self.resList = {
        {file = AssetConfig.bible_brew_panel, type = AssetType.Main},
        {file = AssetConfig.bible_textures, type = AssetType.Dep},
        {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.lastSub = 1
    self.mainItemList = {}
    self.subItemList = {}
    self.lastSeeItemId = nil
    -- EventMgr.Instance:AddListener(event_name.backpack_item_change, self.listener)
    -- EventMgr.Instance:AddListener(event_name.role_level_change, self.listener)

    self.roleLevelChangeListener = function()
        -- if RoleManager.Instance.RoleData.lev <= self.model.warm_tips_lev then
        --     self.WarmTips.gameObject:SetActive(true)
        -- else
        --     self.WarmTips.gameObject:SetActive(false)
        -- end
    end

    EventMgr.Instance:AddListener(event_name.role_level_change, self.roleLevelChangeListener)

    self.OnOpenEvent:AddListener(function()
        local args = self.model.mainModel.openArgs
        args = args or {}

        if args[2] == nil then
            args[2] = 1
        end
        -- if args ~= nil and #args == 2 and args[1] == 3 then
        --     self.lastSub = tonumber(args[2])
        -- end
        -- self.lastSub = self.model.mainModel.currentSub
        self:ChangeTab(args[2])
    end)
end

function BibleBrewPanel:RemoveListener()
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.roleLevelChangeListener)
end

function BibleBrewPanel:InitPanel()
    --Log.endrror("BibleBrewPanel:InitPanel")
    local model = self.model
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.bible_brew_panel))
    NumberpadPanel.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.tabContainer = self.transform:Find("BrewListPanel")
    self.tabBtnTemplate = self.tabContainer:Find("TabItem").gameObject
    self.tabBtnTemplate:SetActive(false)

    self.tabObjList = {}
    self.redPointList = {}
    self.tabImageList = {}
    self.tabTextList = {}

    self.tabLayout = LuaBoxLayout.New(self.tabContainer.gameObject, {axis = BoxLayoutAxis.Y, spacing = 5})

    local mainPanel = self.transform:Find("MainPanel")
    for i=1,#model.leftTypeList do
        local v = model.leftTypeList[i]
        if v ~= nil then
            local obj = GameObject.Instantiate(self.tabBtnTemplate)
            obj.name = tostring(i)
            self.tabLayout:AddCell(obj)
            self.tabObjList[i] = obj
            obj:GetComponent(Button).onClick:AddListener(function()
                self:ChangeTab(i)
            end)

            self.tabImageList[i] = obj:GetComponent(Image)

            local t = obj.transform
            self.tabTextList[i] = t:Find("Text"):GetComponent(Text)
            self.tabTextList[i].text = v.name

            self.redPointList[i] = t:Find("RedPoint").gameObject
            self.redPointList[i]:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "RedPoint")
            self.redPointList[i]:SetActive(false)
            local iconTemp = t:Find("Icon"):GetComponent(Image)
            if i <4 then
                iconTemp.sprite = self.assetWrapper:GetSprite(AssetConfig.bible_textures, tostring(v.icon))
                iconTemp:SetNativeSize()
            else
                iconTemp.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, tostring(v.icon))
            end
        end
    end
    self.grid = mainPanel:Find("ConPanel/Grid")
    self.mainItem = self.grid:Find("MainItem").gameObject
    self.mainItem:SetActive(false)
    self.subItem = self.grid:Find("SubItem").gameObject
    self.subItem:SetActive(false)

    self.WarmTips = self.transform:Find("WarmTips")
    self.WarmTips_toggle = self.WarmTips:Find("Toggle1"):GetComponent(Toggle)
    self.WarmTips_look_btn = self.WarmTips:Find("ImgLookBtn"):GetComponent(Button)

    self.WarmTips.gameObject:SetActive(false)

    -- EventMgr.Instance:AddListener(event_name.role_level_change, function()
    --     if RoleManager.Instance.RoleData.lev <= self.model.warm_tips_lev then
    --         self.WarmTips.gameObject:SetActive(true)
    --     else
    --         self.WarmTips.gameObject:SetActive(false)
    --     end
    -- end)

    -- if RoleManager.Instance.RoleData.lev <= self.model.warm_tips_lev then
    --     self.WarmTips.gameObject:SetActive(true)
    -- end

    self.WarmTips_toggle.onValueChanged:RemoveAllListeners()
    self.WarmTips_toggle.isOn = self.model.is_warm_tips

    self.WarmTips_toggle.onValueChanged:AddListener(function(status)
        self.model.is_warm_tips = status
        if status then
            NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>开启</color>温馨提示气泡"))
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("已<color='#ffff00'>关闭</color>温馨提示气泡"))
        end
    end)


    self.WarmTips_look_btn.onClick:AddListener(function ()
        if #self.model:Get_Warm_Tips_List() == 0 then
            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有提示喔{face_1,9}"))
            return
        end
        self.model.warm_tips_type = 1
        self.model:InitWarmTipsUI()
    end)

    self.model.type = 0

    self.OnOpenEvent:AddListener(function() self:OnShow() end)
end

function BibleBrewPanel:EnableTab(sub)
    self.tabImageList[self.lastSub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
    self.tabTextList[self.lastSub].color = ColorHelper.DefaultButton8

    self.tabImageList[sub].sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
    self.tabTextList[sub].color = ColorHelper.DefaultButton9

    self.lastSub = sub
end

function BibleBrewPanel:OnInitCompleted()
    -- local args = self.model.mainModel.openArgs
    -- BaseUtils.dump(args,"---------------------")
    -- if args ~= nil and #args == 2 and args[1] == 3 then
    --     self.lastSub = tonumber(args[2])
    -- end
    -- print(self.lastSub .. "BibleBrewPanel:EnableTab(sub)----------"..debug.traceback())
    -- self.lastSub = self.model.mainModel.currentSub
    -- self:ChangeTab(self.model.mainModel.currentSub)

    self.OnOpenEvent:Fire()
end

function BibleBrewPanel:__delete()
    self.model:CloseWarmTipsUI()
    self:RemoveListener()

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self.transform = nil
    self.OnOpenEvent:RemoveAll()
end

function BibleBrewPanel:ChangeTab(left_type)
    self:EnableTab(left_type)
    -- if self.model.type ~= left_type then
        self.model.type = left_type
        self:UpdateData()
    -- end
end

function BibleBrewPanel:UpdateData()
    for k,v in pairs(self.mainItemList) do
        v.itemObj:SetActive(false)
    end
    self.model:loadData()
    for k,v in pairs(self.model.dataList) do
        local mainitemdata = self.mainItemList[v.id]
        local obj = nil
        if mainitemdata == nil then
            obj = GameObject.Instantiate(self.mainItem)
            obj.transform:SetParent(self.grid)
            obj.transform.localScale = Vector3.one
            obj.transform.localPosition = Vector3(obj.transform.localPosition.x,obj.transform.localPosition.y,0)
            obj.name = tostring(v.id)

            obj.transform:Find("Con/TitleText"):GetComponent(Text).text = v.first_title
            obj.transform:Find("Con/DescText"):GetComponent(Text).text = v.content
            if v.lev > 0 then
                obj.transform:Find("Con/LevText"):GetComponent(Text).text = string.format(TI18N("(%d级以上)"),v.lev)
            else
                obj.transform:Find("Con/LevText"):GetComponent(Text).text = ""
            end

            local img = obj.transform:Find("Con/ribg/Image"):GetComponent(Image)
            img.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(v.title_icon))
            -- local slot = ItemSlot.New()
            -- local itemdata = ItemData.New()
            -- local cell = DataItem.data_get[v.title_icon]
            -- itemdata:SetBase(cell)
            -- slot:SetAll(itemdata, {inbag = false, nobutton = true})
            -- NumberpadPanel.AddUIChild(img.gameObject, slot.gameObject)

            local btnDic = {
                 seebtn = obj.transform:Find("Con/SeeButton"):GetComponent(Button)
                ,gobtn = obj.transform:Find("Con/GoButton"):GetComponent(Button)
                ,packupbtn = obj.transform:Find("Con/PackupButton"):GetComponent(Button)
            }

            self.mainItemList[v.id] = {
                itemObj = obj
                ,data = v
                ,buttonDic = btnDic
            }

            if v.btn_type == 1 then --查看
                btnDic.seebtn.gameObject:SetActive(true)
                btnDic.gobtn.gameObject:SetActive(false)
                btnDic.packupbtn.gameObject:SetActive(false)

                btnDic.seebtn.onClick:AddListener(function ()
                    self:UpdateSubData(v.id,true)
                end)
                btnDic.packupbtn.onClick:AddListener(function ()
                    self:UpdateSubData(v.id,false)
                end)
            elseif v.btn_type == 2 then --前往
                btnDic.seebtn.gameObject:SetActive(false)
                btnDic.gobtn.gameObject:SetActive(true)
                btnDic.packupbtn.gameObject:SetActive(false)

                btnDic.gobtn.onClick:AddListener(function ()
                    self:OnclickGoButton(v)
                end)
            end
        else
            obj = mainitemdata.itemObj
            self:UpdateSubData(v.id,false)
        end
        obj:SetActive(true)

    end
end

function BibleBrewPanel:UpdateSubData(id,bo)
    local itemDataTemp = self.mainItemList[id]
    if bo == false then --收起
        if itemDataTemp.data.btn_type == 1 then
            itemDataTemp.buttonDic.seebtn.gameObject:SetActive(true)
            itemDataTemp.buttonDic.packupbtn.gameObject:SetActive(false)
        end

        for k,v in pairs(self.subItemList) do
            if v.data.group_id == id then
                v.itemObj:SetActive(false)
            end
        end
    else --展开
        if self.lastSeeItemId ~= nil then
            self:UpdateSubData(self.lastSeeItemId,false)
        end
        self.lastSeeItemId = id

        itemDataTemp.buttonDic.seebtn.gameObject:SetActive(false)
        itemDataTemp.buttonDic.packupbtn.gameObject:SetActive(true)
        local parent = itemDataTemp.itemObj.transform
        self.model:loadSubData(id)
        for k,v in pairs(self.model.subDataList) do
            local subitemdata = self.subItemList[v.id]
            local obj = nil
            if subitemdata == nil then
                obj = GameObject.Instantiate(self.subItem)
                obj.transform:SetParent(parent)
                obj.transform.localScale = Vector3.one
                obj.transform.localPosition = Vector3(obj.transform.localPosition.x,obj.transform.localPosition.y,0)
                obj.name = tostring(v.id)

                obj.transform:Find("TitleText"):GetComponent(Text).text = v.first_title
                obj.transform:Find("DescText"):GetComponent(Text).text = v.content
                -- obj.transform:Find("LevText"):GetComponent(Text).text = string.format("(%d级以上)",v.lev)
                if v.lev > 0 then
                    obj.transform:Find("LevText"):GetComponent(Text).text = string.format(TI18N("(%d级以上)"),v.lev)
                else
                    obj.transform:Find("LevText"):GetComponent(Text).text = ""
                end
                local img = obj.transform:Find("ribg/Image"):GetComponent(Image)
                img.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(v.title_icon))

                local gobtn = obj.transform:Find("Button"):GetComponent(Button)

                gobtn.onClick:AddListener(function ()
                    self:OnclickGoButton(v)
                end)

                self.subItemList[v.id] = {
                    itemObj = obj
                    ,data = v
                }
            else
                obj = subitemdata.itemObj
            end
            obj:SetActive(true)

        end
    end
end

function BibleBrewPanel:OnclickGoButton(data)
    if RoleManager.Instance.RoleData.lev >= data.lev then
        if data.panel_id ~= nil and data.panel_id ~= "" then
            --前往界面
            local args = StringHelper.Split(data.panel_id, "|")
            local panelId = tonumber(args[1])
            table.remove(args, 1)
            local tableTemp = {}
            for i,v in ipairs(args) do
                table.insert(tableTemp,tonumber(v))
            end
            WindowManager.Instance:OpenWindowById(panelId,tableTemp)

            self.mgr.type = self.model.type
            StrategyManager.Instance.brew = true
        elseif data.npc_id ~= nil and data.npc_id ~= "" then
            --前往NPC
            local args = StringHelper.Split(data.npc_id, "|")
            local npcId = BaseUtils.get_unique_npcid(args[2], args[1])
            -- Log.Error(npcId)
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(npcId,false)

            StrategyManager.Instance.model:CloseWindow()
            BibleManager.Instance.model:CloseWindow()

        end
    else
        NoticeManager.Instance:FloatTipsByString(string.format(TI18N("等级需要%d级以上"), data.lev))
    end
end

function BibleBrewPanel:OnShow()
        self:ChangeTab(self.mgr.type)
end