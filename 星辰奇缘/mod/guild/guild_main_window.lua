GuildMainWindow  =  GuildMainWindow or BaseClass(BaseWindow)

function GuildMainWindow:__init(model)
    self.name  =  "GuildMainWindow"
    self.model  =  model
    -- 缓存
    self.cacheMode = CacheMode.Visible

    self.windowId = WindowConfig.WinID.guildwindow

    self.resList  =  {
        {file  =  AssetConfig.guild_main_win, type  =  AssetType.Main}
        , {file = AssetConfig.guild_dep_res, type = AssetType.Dep}
        ,{file = AssetConfig.guild_activity_icon, type = AssetType.Dep}
        -- , {file = AssetConfig.base_textures, type = AssetType.Dep}
        -- , {file = AssetConfig.font, type = AssetType.Dep}
    }



    self.subFirst = nil
    self.subSecond = nil
    self.subThree = nil
    self.mainObj = nil

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)

    return self
end

function GuildMainWindow:OnHide()

end

function GuildMainWindow:OnInitCompleted()
     GuildManager.Instance:request11177()
     GuildManager.Instance:request11180()
end

function GuildMainWindow:OnShow()

    self:Set_red_point_state(3)
    if self.model.reset_info == false then
        GuildManager.Instance:request11100()
    else
        self.model.reset_info = false
        GuildManager.Instance:request11101()
    end
    GuildManager.Instance:request11177()
    GuildManager.Instance:request11180()
    if self.openArgs ~= nil then
        self.current_index = self.openArgs[1]
    end
    if BaseUtils.IsVerify == true and (self.current_index == 1 or self.current_index == nil) then
        self.current_index = 2
    end
    if self.current_index == nil then
        self:TabChange(1)
    else
        self:TabChange(self.current_index)
    end
end

function GuildMainWindow:__delete()
    self.is_open  =  false

    EventMgr.Instance:RemoveAllListener(event_name.guild_member_update)

     if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end
    if self.subSecond ~= nil then
        self.subSecond:DeleteMe()
        self.subSecond = nil
    end
    if self.subThree ~= nil then
        self.subThree:DeleteMe()
        self.subThree = nil
    end

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end


function GuildMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_main_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "GuildMainWindow"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.mainObj = self.gameObject.transform:Find("MainCon").gameObject

    local closeBtn = self.gameObject.transform:Find("MainCon/CloseButton"):GetComponent(Button)
    closeBtn.onClick:AddListener(function()
        self.model:CloseMainUI()
    end)


    local tabGroup = self.gameObject.transform:Find("MainCon/TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:TabChange(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:TabChange(2) end)
    self.tab_btn3 = tabGroup.transform:GetChild(2):GetComponent(Button)
    self.tab_btn3 .onClick:AddListener(function() self:TabChange(3) end)

    self.gameObject:SetActive(true)
    self:TabChange(1)

    if BaseUtils.IsVerify == true then
        tabGroup.transform:GetChild(0).gameObject:SetActive(false)
        tabGroup.transform:GetChild(1):GetComponent(RectTransform).anchoredPosition = Vector2(0, -50)
        tabGroup.transform:GetChild(2):GetComponent(RectTransform).anchoredPosition = Vector2(0, -151)
    end

    -- 非依赖资源，UI创建完就可以卸载
    self:ClearMainAsset()

    GuildManager.Instance:request11175()
    self:Set_red_point_state(3)

    self:OnShow()
end

--设置tab红点显示状态
function GuildMainWindow:Set_red_point_state(index)
    local state = false
    local point = nil
    if index == 1 then
        point = self.tab_btn1.transform:Find("NotifyPoint").gameObject

    elseif index == 2 then
        if self.tab_btn2 ~= nil then
            point = self.tab_btn2.transform:Find("NotifyPoint").gameObject
            state = self.model:check_can_get_pay()
            if state == false then
                state = self.model.guild_store_has_refresh
            end
        end
    elseif index == 3 then
        point = self.tab_btn3.transform:Find("NotifyPoint").gameObject
        state = GuildfightManager.Instance:IsGuildFightStart() --公会战

        if state == false then
            --公会精英战
            state = GuildFightEliteManager.Instance:checkRedPoint()
        end

        if state ~= true then
            state = GuildLeagueManager.Instance:CheckRed()   -- 冠军联赛
        end

        if state ~= true then
            state = GuildSiegeManager.Instance.model.status ~= GuildSiegeEumn.Status.Disactive and GuildSiegeManager.Instance:IsMyGuildIn()
        end
        if state ~= true then
            state = GuildAuctionManager.Instance:CheckRedPonint()
        end
        if state ~= true then
            state = (TruthordareManager.Instance.model.openState == 1 )
        end

        if RoleManager.Instance.RoleData.lev < 65 then
            state = false
        end
    end
    if point ~= nil then
        point:SetActive(state)
    end
end

function GuildMainWindow:TabChange(index)
    self.current_index = index
    if index == 1 then
        self:Switch_tab_btn(self.tab_btn1)
        self:ShowFirst(true)
        self:ShowSecond(false)
        self:ShowThree(false)
    elseif index == 2 then
        self:Switch_tab_btn(self.tab_btn2)
        self:ShowFirst(false)
        self:ShowSecond(true)
        self:ShowThree(false)
    elseif index == 3 then
        self:Switch_tab_btn(self.tab_btn3)
        self:ShowFirst(false)
        self:ShowSecond(false)
        self:ShowThree(true)
    end
end

function GuildMainWindow:Switch_tab_btn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn3.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn3.transform:FindChild("Normal").gameObject:SetActive(true)

    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

function GuildMainWindow:ShowFirst(IsShow)
    if BaseUtils.IsVerify == true then
        return
    end
    if IsShow then
        if self.subFirst == nil then
            self.subFirst = GuildMainTabFirst.New(self)
        end
        self.subFirst:Show()
    else
        if self.subFirst ~= nil then
            self.subFirst:Hiden()
        end
    end
end

function GuildMainWindow:ShowSecond(IsShow)
    if IsShow then
        if self.subSecond == nil then
            self.subSecond = GuildMainTabSecond.New(self)
        end
        self.subSecond:Show()
    else
        if self.subSecond ~= nil then
            self.subSecond:Hiden()
        end
    end
end

function GuildMainWindow:ShowThree(IsShow)
    if IsShow then
        if self.subThree == nil then
            self.subThree = GuildMainTabThree.New(self)
        end
        self.subThree:Show()
    else
        if self.subThree ~= nil then
            self.subThree:Hiden()
        end
    end
end
