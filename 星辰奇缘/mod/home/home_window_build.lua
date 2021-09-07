-- ----------------------------------------------------------
-- UI - 家园建筑管理
-- ljh 20160713
-- ----------------------------------------------------------
HomeWindow_Build = HomeWindow_Build or BaseClass(BasePanel)

function HomeWindow_Build:__init(parent)
	self.parent = parent
    self.model = parent.model
    self.name = "HomeWindow_Build"
    self.resList = {
        {file = AssetConfig.home_view_build, type = AssetType.Main}
        ,{file = AssetConfig.homeTexture, type = AssetType.Dep}
        ,{file = AssetConfig.stongbg, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    self.init = false

    ------------------------------------------------
    self.container = nil
    self.skillobject = nil
    self.scrollrect = nil

    self.itemlist = {}
    self.selectbtn = nil
    self.builddata = nil
    self.select_builddata = nil

    self.openType = nil

    self.buildlist_click_enable = true

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

function HomeWindow_Build:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.home_view_build))
    self.gameObject.name = "HomeWindow_Build"
    self.gameObject.transform:SetParent(self.parent.mainTransform)
    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    self.transform = self.gameObject.transform

    --------------------------------------------
    local transform = self.transform
    self.container = transform:FindChild("BuildListPanel/Content").gameObject
    self.itemobject = self.container.transform:FindChild("Item").gameObject

    -- self.scrollrect = transform:FindChild("BuildListPanel"):GetComponent(ScrollRect)

    self.descText = MsgItemExt.New(self.transform:FindChild("InfoPanel/DescText"):GetComponent(Text), 240, 18, 23)
    self.nextDescText = MsgItemExt.New(self.transform:FindChild("InfoPanel/NextDescText"):GetComponent(Text), 240, 18, 23)

    -- 按钮功能绑定
    local btn
    btn = transform:FindChild("OkButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:okbuttonclick() end)
    self.okButton = btn

    btn = transform:FindChild("CancelButton"):GetComponent(Button)
    btn.onClick:AddListener(function() self:cancelbuttonclick() end)

    btn = transform:FindChild("kuojian"):GetComponent(Button)
    btn.onClick:AddListener(function() self:kuojianclick() end)

    transform:FindChild("kuojian/Text"):GetComponent(Text).color = Color.white
    --------------------------------------------
    self.init = true
    self:OnShow()
    self:ClearMainAsset()
end

function HomeWindow_Build:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 1 then
        self.openType = self.openArgs[2]
    else
        self.openType = nil
    end

    self:addevents()
    self:update()

    self.buildlist_click_enable = true
    self:CheckGuild()
end

function HomeWindow_Build:OnHide()
    self:removeevents()
end

function HomeWindow_Build:addevents()
    EventMgr.Instance:AddListener(event_name.home_build_update, self._update)
end

function HomeWindow_Build:removeevents()
    EventMgr.Instance:RemoveListener(event_name.home_build_update, self._update)
end

function HomeWindow_Build:update()
    self:updateBuildList()
    self:updateHomeInfo()
end

function HomeWindow_Build:updateHomeInfo()
    local now_home_data = DataFamily.data_home_data[self.model.home_lev]
    self.transform:FindChild("LevelText"):GetComponent(Text).text = string.format("<color='#3166ad'><color='%s'>%s</color>:%s㎡</color>", self.color[self.model.home_lev], now_home_data.name2, now_home_data.total_space)
    local next_home_data = DataFamily.data_home_data[self.model.home_lev + 1]
    if next_home_data ~= nil then
        self.transform:FindChild("NextLevelText"):GetComponent(Text).text = string.format("<color='#3166ad'>%s<color='%s'>(%s)</color>:%s㎡</color>", TI18N("下一级"), self.color[self.model.home_lev], next_home_data.name2, next_home_data.total_space)
    else
        self.transform:FindChild("NextLevelText"):GetComponent(Text).text = TI18N("<color='#3166ad'>已到最高级</color>")
    end
    local space = self.model:gettotalbuildspace()
    self.transform:FindChild("ExpGroup/ExpText"):GetComponent(Text).text = string.format("%s/%s㎡", space, now_home_data.total_space)
    self.transform:FindChild("ExpGroup/ExpSlider"):GetComponent(Slider).value = space / now_home_data.total_space
end

-- 更新技能列表 Mark
function HomeWindow_Build:updateBuildList()
    local build_list = self.model.build_list

    local builditem
    local data

    local roleData = RoleManager.Instance.RoleData
    for i = 1, #build_list do
        data = build_list[i]
        builditem = self.itemlist[i]

        if builditem == nil then
            local item = GameObject.Instantiate(self.itemobject)
            item:SetActive(true)
            item.transform:SetParent(self.container.transform)
            item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            local fun = function() self:onitemclick(item) end
            item:GetComponent(Button).onClick:AddListener(fun)
            self.itemlist[i] = item
            builditem = item
        end

        local builddata = self.model:getbuilddata(data.type, data.lev)
        if builddata ~= nil then
            builditem.name = tostring(data.type)

            builditem.transform:FindChild("Icon"):GetComponent(Image).sprite
                = self.assetWrapper:GetSprite(AssetConfig.homeTexture, tostring(builddata.icon))
            builditem.transform:FindChild("NameText"):GetComponent(Text).text = builddata.name
            if data.lev == 0 then
                builditem.transform:FindChild("DescText"):GetComponent(Text).text = ""
            else
                builditem.transform:FindChild("DescText"):GetComponent(Text).text = string.format("%s<color='#248813'>%s㎡</color>", TI18N("占地"), builddata.use_space)
            end
        end

        if nil ~= self.openType then
            if self.openType == data.type then
                if self.selectbtn ~= nil then 
                    self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) 
                end
                self.selectbtn = builditem
                self.openType = nil
            end
        else
            if nil ~= self.builddata and self.builddata.type == data.type then
                if self.selectbtn ~= nil then 
                    self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) 
                end
                self.selectbtn = builditem
            end
        end
    end

    for i = #build_list + 1, #self.itemlist do
        builditem = self.itemlist[i]
        builditem:SetActive(false)
    end

    if #build_list > 0 then
        if self.selectbtn == nil then
            self:onitemclick(self.itemlist[1])
        else
            self:onitemclick(self.selectbtn)
        end
    end
end

-- 选中技能 Mark
function HomeWindow_Build:onitemclick(item)
    if self.buildlist_click_enable then
        self.select_builddata = self.model:getbuild(item.name)
        if self.select_builddata == nil then return end
        self.builddata = self.model:getbuilddata(item.name, self.select_builddata.lev)

        self:updateInfo()

        if self.selectbtn ~= nil then self.selectbtn.transform:FindChild("Select").gameObject:SetActive(false) end
        item.transform:FindChild("Select").gameObject:SetActive(true)
        self.selectbtn = item
    end
end

-- 更新技能信息 Mark
function HomeWindow_Build:updateInfo()
    local builddata = self.builddata
    local transform = self.transform

    if nil == builddata then return end
    local info_panel = transform:FindChild("InfoPanel").gameObject

    -- 大图 hosr
    info_panel.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.stongbg, "StoneBg")
    info_panel.transform:FindChild("Title/Text"):GetComponent(Text).text = builddata.name

    -- self.descText:SetData(string.format("<color='#66ccff'>%s:</color>%s", TI18N("效果"), builddata.desc))
    -- self.nextDescText:SetData(string.format("<color='#66ccff'>%s:</color>%s", TI18N("下级效果"), builddata.next_lev_desc))
    self.descText:SetData(string.format("%s:%s", TI18N("效果"), builddata.desc))
    self.nextDescText:SetData(string.format("%s:%s", TI18N("下级效果"), builddata.next_lev_desc))

    info_panel.transform:FindChild("Icon"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.homeTexture, tostring(builddata.icon))

    local nextlev_builddata = self.model:getbuilddata(builddata.type, builddata.lev + 1)
    if nextlev_builddata ~= nil then
        -- info_panel.transform:FindChild("NextAreaText"):GetComponent(Text).text = string.format("<color='#66ccff'>下级占地:</color>%s占用<color='#00ff66'>%s㎡</color>", nextlev_builddata.name, nextlev_builddata.use_space)
        info_panel.transform:FindChild("NextAreaText"):GetComponent(Text).text = ""

        local cost = builddata.upgrade_cost[1][2]
        local coin = RoleManager.Instance.RoleData.coin
        local costItemText = info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text)
        local needAreaText = info_panel.transform:Find("NeedItem/NumText"):GetComponent(Text)

        local need = nextlev_builddata.use_space - self.model:getbuilddata(builddata.type, self.select_builddata.lev).use_space
        local now_home_data = DataFamily.data_home_data[self.model.home_lev]
        if need > now_home_data.total_space - self.model:gettotalbuildspace() then
            needAreaText.text = string.format("<color='#df3435'>%s㎡</color>", tostring(need))
        else
            needAreaText.text = string.format("%s㎡", tostring(need))
        end

        costItemText.text = tostring(cost)
        if cost > coin then
            costItemText.text = string.format("<color='#df3435'>%s</color>", tostring(cost))
            -- costItemText.color = Color(1, 0, 0, 1)
        else
            costItemText.text = tostring(cost)
            -- costItemText.color = Color(0, 1, 0, 1)
        end
        if cost == 0 then
            costItemText.text = TI18N("<color='#ffff00'>免费</color>")
            -- costItemText.color = Color(1, 1, 0, 1)
        end
        -- info_panel.transform:FindChild("CostItem2/NumText"):GetComponent(Text).text = tostring(coin)
    else
        info_panel.transform:FindChild("NextDescText"):GetComponent(Text).text = TI18N("已到最高级")
        -- info_panel.transform:FindChild("NextAreaText"):GetComponent(Text).text = "已到最高级"
        info_panel.transform:FindChild("NextAreaText"):GetComponent(Text).text = ""
        info_panel.transform:FindChild("CostItem/NumText"):GetComponent(Text).text = "0"
        -- info_panel.transform:FindChild("CostItem2/NumText"):GetComponent(Text).text = "0"
    end
end

function HomeWindow_Build:okbuttonclick()
    local builddata = self.model:getbuilddata(self.select_builddata.type, self.select_builddata.lev)
    local nextbuilddata = self.model:getbuilddata(self.select_builddata.type, self.select_builddata.lev+1)
    local now_home_data = DataFamily.data_home_data[self.model.home_lev]

    if nextbuilddata == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("已达最高等级{face_1,3}"))
    elseif nextbuilddata.use_space - builddata.use_space > now_home_data.total_space - self.model:gettotalbuildspace() then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("当前家园空间已用完，可扩建家园来增加空间")
        data.cancelLabel = TI18N("前往扩建")
        data.sureLabel = TI18N("取消")
        data.blueSure = true
        data.greenCancel = true
        data.cancelCallback = function()
            WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {4})
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        if self.effect ~= nil then
            return
        end

        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.transform:SetParent(ctx.CanvasContainer.transform)
            effectObject.transform.localScale = Vector3(1, 1, 1)
            effectObject.transform.localPosition = Vector3(0, 0, -2000)
            effectObject.transform.localRotation = Quaternion.identity

            Utils.ChangeLayersRecursively(effectObject.transform, "UI")

            SoundManager.Instance:Play(240)
        end
        self.effect = BaseEffectView.New({effectId = 20165, time = 2000, callback = fun})
        self.okButton.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
        self.buildlist_click_enable = false

        LuaTimer.Add(2000, function()
            if self.effect ~= nil then
                self.effect:DeleteMe()
            end
            self.effect = nil
            self.okButton.image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            HomeManager.Instance:Send11209(self.select_builddata.type)
            self.buildlist_click_enable = true
        end)
    end
end

function HomeWindow_Build:cancelbuttonclick()
    if 0 == self.select_builddata.lev then
        NoticeManager.Instance:FloatTipsByString(TI18N("已到最低等级"))
        return
    end

    local builddata = self.model:getbuilddata(self.select_builddata.type, self.select_builddata.lev)
    local lastbuilddata = self.model:getbuilddata(self.select_builddata.type, self.select_builddata.lev-1)
    if builddata ~= nil then
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        -- data.content = string.format("是否拆除<color='#ffff00'>%s</color>，拆除后<color='#ffff00'>%s</color>会降级，对应功能效果也会随之降低，且不会返还升级消耗。"
        --     , builddata.name, builddata.name)
        data.content = string.format("%s<color='#ffff00'>%s%s</color>%s<color='#ffff00'>%s㎡</color>%s？", TI18N("拆除")
            , builddata.name, TI18N("室"), TI18N("后将会返还"), builddata.use_space - lastbuilddata.use_space, TI18N("占用空间，但对应的功能也将随之降低，是否确定"))

        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            HomeManager.Instance:Send11210(self.select_builddata.type)
        end
        NoticeManager.Instance:ConfirmTips(data)
    end
end

function HomeWindow_Build:kuojianclick()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.home_window, {4})
end

function HomeWindow_Build:CheckGuild()
    local homeModel = HomeManager.Instance.model
    local hasBuild = homeModel.is_upgrade_bdg == nil or #homeModel.is_upgrade_bdg ~= 0
    if not hasBuild and homeModel:CanEditHome() then
    -- if true then
        if self.guideScript == nil then
            self.guideScript = GuideHomeFurniture.New(self)
        end
        self.guideScript:Show()
    end
end

function HomeWindow_Build:__delete()
    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end
end


