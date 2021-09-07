-- ----------------------------------------------------------
-- UI - 游戏登录
-- ----------------------------------------------------------
LoginView = LoginView or BaseClass(BaseView)


function LoginView:__init(model)
    self.model = model
    self.model.ListLoaded = false
    self.name = "LoginView"
    self.winLinkType = WinLinkType.Single
    self.logoName = "i18nlogo_" .. ctx.GameName
    self.logoPath = "textures/ui/startpage/" .. self.logoName .. ".unity3d"
    self.loadingPageBgPath = "textures/ui/startpage/" .. BaseUtils.GetLoadingPageBgPath() .. ".unity3d"

    self.resList = {
        {file = AssetConfig.login_window, type = AssetType.Main}
        , {file = AssetConfig.login_textures, type = AssetType.Dep}
    }

    if not BaseUtils.IsUseBaseCanvasBg() then -- 是否用C#里LoadingPagePatch的资源
        table.insert(self.resList, {file = self.loadingPageBgPath, type = AssetType.Dep})
    end

    if SdkManager.Instance:GetLogoShow() and not BaseUtils.IsUseBaseCanvasLogo() then
        table.insert(self.resList, {file = self.logoPath, type = AssetType.Dep})
    end

    self.name = "LoginView"

    self.gameObject = nil
    self.transform = nil

    ------------------------------------------------
    self.input_field = nil --帐号
    self.zone_con = nil
    self.txt_click_select = nil
    self.txt_cur_zone_name = nil
    self.btn_enter_game = nil
    self._server_name = ""
    self._server_index = 1
    self.has_input_self_name = false

    self.isLocalList = false

    self.zone_select_win = nil
    self.serverbarList = {}
    self.oldserverbarList = {}

    self.on_end_edit_callback = function(data)
        self:on_end_edit(data)
    end
    self.RemoteListLoaded = function(www, str)
        self:OnServerListLoaded(www, str)
    end
    self.currSelectData = nil
    self.isWhiteList = false
    self.isSpecial = false
    self.PermitList = {}

    self.reqname = nil

    self.lastReqTime = Time.time

    self.whiteTime = 172800
    self.showTime = 86400
    self.showTimeBeta = 86400

    self:LoadAssetBundleBatch()
end

function LoginView:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()

    ------------------------------------------------
    self.input_field.onEndEdit:RemoveListener(self.on_end_edit_callback)
end

function LoginView:InitPanel()
    ctx.LoadingPage:Hide()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.login_window))
    self.gameObject.name = "LoginView"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.model:CleanStartPage()

    self.transform = self.gameObject.transform

    local project_name = self.transform:Find("ImgProjectName"):GetComponent(Image)

    self.zone_con = self.transform:FindChild("ZoneCon").gameObject

    self.changeBtnObj = self.transform:Find("ChangeBtn").gameObject
    self.changeBtnObj:GetComponent(Button).onClick:AddListener(function() self:OnChangeAccount() end)
    if BaseUtils.GetLocation() == KvData.localtion_type.sg then
        self.changeBtnObj:SetActive(true)
    else
        self.changeBtnObj:SetActive(false)
    end

    local ImgBg = self.transform:Find("ImgBg"):GetComponent(Image)

    if BaseUtils.IsUseBaseCanvasBg() then -- 是否用C#里LoadingPagePatch的资源
        local baseCanvasContainer = ctx.CanvasContainer.transform:Find("BaseCanvas/Container")
        if not BaseUtils.isnull(baseCanvasContainer) then
            local startPage = baseCanvasContainer:Find("StartPage")
            if not BaseUtils.isnull(startPage) then
                ImgBg.sprite = startPage:GetComponent(Image).sprite
            end
        end
    else -- 否则按照原设置
        ImgBg.sprite = self.assetWrapper:GetSprite(self.loadingPageBgPath, BaseUtils.GetLoadingPageBgPath())
    end

    if BaseUtils.IsUseBaseCanvasLogo() then -- 是否用C#里LoadingPagePatch的资源
        local baseCanvasContainer = ctx.CanvasContainer.transform:Find("BaseCanvas/Container")
        if not BaseUtils.isnull(baseCanvasContainer) then
            local gameLogo = baseCanvasContainer:Find("StartPage/GameLogo")
            if not BaseUtils.isnull(gameLogo) then
                project_name.sprite = gameLogo:GetComponent(Image).sprite
            end
        end

        if project_name.sprite == nil then
            project_name.gameObject:SetActive(false)
        elseif BaseUtils.GetGameName() == "xcqy" then
            self.nameEffect = BaseUtils.ShowEffect(20428, project_name.transform, Vector3(0.74, 0.74, 1), Vector3(13.3, -5, -400))
        end
    else    
        if SdkManager.Instance:GetLogoShow() then
            project_name.sprite = self.assetWrapper:GetSprite(self.logoPath, self.logoName)
            if BaseUtils.GetGameName() == "xcqy" then
                self.nameEffect = BaseUtils.ShowEffect(20428, project_name.transform, Vector3(0.74, 0.74, 1), Vector3(13.3, -5, -400))
            end
        else
            project_name.gameObject:SetActive(false)
        end
    end

    self.input_field = self.transform:FindChild("InputCon"):FindChild("InputField"):GetComponent(InputField)
    self.input_field.textComponent = self.transform:FindChild("InputCon/InputField/Text"):GetComponent(Text)

    self.txt_click_select = self.zone_con.transform:FindChild("TxtClickSelect"):GetComponent(Text)
    self.txt_cur_zone_name = self.zone_con.transform:FindChild("TxtCurZoneName"):GetComponent(Text)
    self.txt_cur_zone_name.text = TI18N("服务器列表加载中")
    self.btn_enter_game = self.transform:FindChild("BtnEnterGame"):GetComponent(Button)
    self.tipsTxt = self.transform:FindChild("Tips/Text"):GetComponent(Text)
    self.tipsTxt.text = TI18N("本游戏适合16岁以上玩家进入。抵制不良游戏,拒绝盗版游戏。注意自我保护,谨防受骗上当。适度游戏益脑,沉迷游戏伤身。合理安排时间,享受健康生活。")

    self.toggle = self.transform:Find("Toggle"):GetComponent(Toggle)
    self.toggle.isOn = true

    self.last_account = self:GetPlayerPrefs("last_account")
    if self.last_account ~= "" then
        self.input_field.text = self.last_account
    else
        self.input_field.text = TI18N("请输入帐号")--TI18N("请输入帐号");
    end

    -- 玩家测试服
    if BaseUtils.IsExperienceSrv() then
        -- self.transform:FindChild("InputCon").gameObject:SetActive(false)
        self.transform:FindChild("InputCon").gameObject:SetActive(true)
        self.transform:FindChild("ZoneCon").gameObject:SetActive(false)
        local tmpAccount = self:GetPlayerPrefs("last_account")
        if tmpAccount == "" or tmpAccount == nil then
            self.input_field.text = self:GenTmpAccount()
         end
    end

    LoginManager.Instance.isWhiteList = false
    local _account = self.input_field.text
    local platformId = tostring(ctx.PlatformChanleId)
    if _account ~= nil then
        for _, data in ipairs(LoginConfig.WhiteList) do
            local waccount = data .. platformId
            if waccount == _account then
                self.isWhiteList = true
                LoginManager.Instance.isWhiteList = true
            end
        end
        local version = BaseUtils.GetClientVerion()
        for acc, data in pairs(LoginConfig.SpecialList) do
            if version == acc then
                self.isSpecial = true
                self.PermitList = data
            end
        end
    end

    self.zone_con:GetComponent(Button).onClick:AddListener(
        function()
            if self.model.ListLoaded then
                self:on_click_select()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请稍等正在加载服务器列表～"))
            end
        end)
    self.input_field.onEndEdit:AddListener(self.on_end_edit_callback)
    self.btn_enter_game.onClick:AddListener(function()
            self:on_submit()
        end)
    -- if IS_USE_SDK then
    --     self.hide_account_input()
    -- end

    self.zone_select_win = self.transform:FindChild("ZoneSelectWindow").gameObject
    self.zone_select_win:SetActive(false)

    self.server_content_panel = self.zone_select_win.transform:FindChild("ServerList/ContentPanel").gameObject

    self.ButtonList = {}
    for i=1,20 do
        local item = self.server_content_panel.transform:GetChild(i-1)
        local tab = {}
        tab.transform = item
        tab.name = item:Find("name"):GetComponent(Text)
        tab.Port =  item:Find("Port"):GetComponent(Text)
        tab.Platform = item:Find("Platform"):GetComponent(Text)
        tab.Headbg = item:Find("Headbg").gameObject
        tab.head = item:Find("Headbg/head"):GetComponent(Image)
        tab.lev = item:Find("Headbg/levbg/lev"):GetComponent(Text)
        tab.status = item:Find("status"):GetComponent(Image)
        tab.RecommendLabel = item:Find("newLabel").gameObject
        tab.newLabel = item:Find("Label").gameObject
        tab.openText = item:Find("openText"):GetComponent(Text)
        table.insert(self.ButtonList, tab)
    end
    self.roleBar = self.zone_select_win.transform:Find("ServerList/ContentPanel/RoleList")
    self.select_server_button = self.zone_select_win.transform:FindChild("LoginButton"):GetComponent(Button)
    self.zone_select_closebutton = self.zone_select_win.transform:FindChild("CloseButton"):GetComponent(Button)

    self.tabCon = self.zone_select_win.transform:Find("Tab/Con/")
    self.tabBtn = self.zone_select_win.transform:Find("Tab/Con/TabItem").gameObject
    -- self.select_server_button.gameObject:SetActive(true)

    self.close_zone_select_win_callback = function() self:close_zone_select_win() end
    self.select_server_button.onClick:AddListener(function() self.close_zone_select_win_callback() end)
    self.zone_select_closebutton.onClick:AddListener(self.close_zone_select_win_callback)

    if SdkManager.Instance:RunSdk() then
        -- wang 修改
        -- self.transform:FindChild("InputCon").gameObject:SetActive(false)

        if BaseUtils.IsExperienceSrv() then
            self.transform:FindChild("InputCon").gameObject:SetActive(true)
        end

        if BaseUtils.GetClientVerion() == "9.9.9" then
            self.transform:FindChild("InputCon").gameObject:SetActive(true)
        end
    end

    local versionRect = self.transform:Find("Version"):GetComponent(RectTransform)
    local versionTxt = self.transform:FindChild("Version/VerionText"):GetComponent(Text)
    local versionTxtRect = versionTxt.gameObject:GetComponent(RectTransform)
    local versionButton = self.transform:FindChild("Version/Button"):GetComponent(Button)
    local versionButton2 = self.transform:FindChild("Version/Button2"):GetComponent(Button)

    local resVerion = string.sub(tostring(ctx.ResVersion), string.len(tostring(ctx.ResVersion)) - 2, string.len(tostring(ctx.ResVersion)))

    if BaseUtils.GetGameName() == KvData.game_name.xcqy or BaseUtils.GetGameName() == KvData.game_name.xcqylxj then
        -- 添加星辰奇缘版号显示
        versionRect.sizeDelta = Vector2(295, 145)
        versionRect.anchoredPosition = Vector2(0, 32)
        versionTxtRect.anchorMax = Vector2.one
        versionTxtRect.anchorMin = Vector2.zero
        versionTxtRect.offsetMax = Vector2.zero
        versionTxtRect.offsetMin = Vector2(15, 0)
        versionTxt.alignment = TextAnchor.MiddleLeft
        versionTxt.text = TI18N("沪B2-20150038")..TI18N("\n新广出审[2016]955号")..TI18N("\n版本号:") .. BaseUtils.GetGameName() .. tostring(BaseUtils.GetClientVerion()) .. "." .. resVerion..TI18N("\n沪网文[2017]5602-438号").."\nISBN 978-7-89988-804-9"..TI18N("\n文网游备字[2016]M-RPG 0274号")..TI18N("\n著作权人：广州诗悦网络科技有限公司\n出版服务单位：北京艺术与科学电子出版社")

        if not BaseUtils.IsMixPlatformChanle() then
            versionButton.gameObject:SetActive(true)
            versionButton.onClick:AddListener(function() self:ShowCopyRightWebPage() end)
            versionButton:GetComponent(RectTransform).anchoredPosition = Vector2(90, -22)

            versionButton2.gameObject:SetActive(true)
            versionButton2.onClick:AddListener(function() self:ShowCopyRightWebPage2() end)
            versionButton2:GetComponent(RectTransform).anchoredPosition = Vector2(115, -22)
        end
    else
        versionRect.sizeDelta = Vector2(185, 30)
        versionRect.anchoredPosition = Vector2(0, 32)
        versionTxtRect.anchorMax = Vector2.one
        versionTxtRect.anchorMin = Vector2.zero
        versionTxtRect.offsetMax = Vector2.zero
        versionTxtRect.offsetMin = Vector2(15, 0)
        versionTxt.alignment = TextAnchor.MiddleLeft
        versionTxt.text = TI18N("版本号:") .. BaseUtils.GetGameName() .. tostring(BaseUtils.GetClientVerion()) .. "." .. resVerion

        versionButton.gameObject:SetActive(false)
        versionButton2.gameObject:SetActive(false)
    end
    local url = ctx.BaseSetting.ServerListPath
    local platformChanleId = ctx.PlatformChanleId
    local distId = ctx.KKKChanleId
    if IS_DEBUG then
        self:InitDevelopUI()
    end
    if url ~= nil and url ~= "" and self.model.ListLoaded == false and not BaseUtils.IsExperienceSrv() then
        -- if not self:CheckchanleIdLimit() then
            url = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s" , self.last_account, platformChanleId, distId)
            if platformChanleId == 0 and distId == "12467" then
                url = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s" , self.last_account, 13, "0")
            end
            if BaseUtils.IsVerify then
                url = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s" , self.last_account, "verify", distId)
            end
            ctx:GetRemoteTxt(url, self.RemoteListLoaded, 3)
            LuaTimer.Add(5000, function() self:ReTry() end)
        -- end
    elseif self.model.ListLoaded == false then
        self.isLocalList = true
    end
    if self.isLocalList or self.model.ListLoaded then
        self:SetLastServer()
    end
    if self.isLocalList or self.model.ListLoaded then
        self:InitTabPanel()
    end
end

function LoginView:on_click_input(g)
    print("on_click_input")
    if self.input_field.text == TI18N("请输入帐号") then
        self.input_field.text = ""
        self.input_field.textComponent.color = Color(199/255,249/255,1)
    end
end

function LoginView:on_end_edit(temp)
    print("on_end_edit")
    if temp == "" then
        self.input_field.text = TI18N("请输入帐号")
        self.input_field.textComponent.color = Color(199/255,249/255,1)
        self.has_input_self_name = false
    else
        self.has_input_self_name = true
    end
end

function LoginView:on_click_select()
    print("on_click_select")
    self:open_zone_select_win()
end

function LoginView:SetAccountByCookie()
    local last_account = self:GetPlayerPrefs("last_account")
    if last_account ~= "" and self.input_field ~= nil then
        self.input_field.text = last_account
    end
end

---选服逻辑
function LoginView:update_selected_server(server_name, index)
    if self.currSelectData ~= nil then
        self.txt_cur_zone_name.text = self.currSelectData.name
        local lastsvr = ServerConfig.servers[self._server_index]
        self:SavePlayerPrefs("last_account", self.input_field.text)
        self:SavePlayerPrefs("last_server", self.currSelectData.name)
        self:SavePlayerPrefs("last_isfirst", self.currSelectData.first_zone)
        if lastsvr.first_zone ~= self.currSelectData.first_zone then
            local zonename = lastsvr.name
            if lastsvr.first_zone ~= "1" then
                zonename = self.currSelectData.name
            end
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            data.content = string.format(TI18N("%s为<color='#ffff00'>优先体验服</color>，与其他服务器相互切换需要重新加载资源"), zonename)
            data.sureLabel = TI18N("确定")
            data.sureCallback = function() Application.Quit() end
            NoticeManager.Instance:ConfirmTips(data)
        end
        self._server_name = self.currSelectData.name
        self._server_index = self.currSelectData.index

        self.currSelectData = nil
    end
    -- local nowsvr = ServerConfig.servers[self._server_index]
end

--点击登录按钮
function LoginView:on_submit(serverData)
    if ctx.PlatformChanleId == 76 or ctx.PlatformChanleId == 123 or ctx.PlatformChanleId == 110 then -- 屏蔽渠道的登陆 76:搜狗, 123:芒果 110:乐视
        NoticeManager.Instance:FloatTipsByString(TI18N("已关服，转移请联系客服！"))
        return
    end
    if not self.model.ListLoaded then
        return
    end

    if not self.toggle.isOn then
        NoticeManager.Instance:FloatTipsByString(TI18N("请勾选下方<color='#ffff00'>接受游戏中存在PK玩法</color>，即可进入游戏哦"))
        return
    end

    local svr = nil
    if serverData ~= nil then
        svr = serverData
    else
        svr = ServerConfig.servers[self._server_index]
    end
    if svr == nil then
        Log.Error(string.format("当前服务器列表长度为%s，选择第%s个, 服务器列表为%s", #ServerConfig.servers, self._server_index, BaseUtils.serialize(ServerConfig.servers, "", false, 3)))
        svr = self.currSelectData
    end
    self:SavePlayerPrefs("last_isfirst", svr.first_zone)
    -- BaseUtils.dump(ServerConfig.servers)
    -- print(svr.name)
    local continue = true
    local nowtime = os.time()
    local msg = TI18N("亲，我们将在1月8日中午12点准时开测！建议您加入我们玩家交流QQ群：362325621，还会有礼包领取哦！")
    if svr.begin_time ~= nil and svr.begin_time ~= 0 and svr.begin_time > nowtime then
        -- msg = string.format(TI18N("本服在%s后开服，敬请留意, 建议您加入我们玩家交流QQ群：362325621，还会有礼包领取哦！"), os.date("%Y-%m-%d　%X", svr.begin_time))
        -- msg = string.format(TI18N("本服将在<color='#ffff00'>%s月%s日 %s</color>火爆开启，建议加入官方Q群<color='#ffff00'>362325621</color>可以与其他玩家交流！"), os.date("%m", svr.begin_time), os.date("%d", svr.begin_time), os.date("%H:%M", svr.begin_time))
        msg = string.format(TI18N("本服将在<color='#ffff00'>%s月%s日 %s</color>火爆开启"), os.date("%m", svr.begin_time), os.date("%d", svr.begin_time), os.date("%H:%M", svr.begin_time))
        continue = false
    elseif svr.end_time ~= nil and svr.end_time ~= 0 and svr.end_time < nowtime or svr.maintain == "1" or svr.maintain == 1 then
        msg = TI18N("本服正在维护更新中")
        continue = false
        if self.lastReqTime < Time.time - 2 then
            self.lastReqTime = Time.time
            local platformChanleId = ctx.PlatformChanleId
            local distId = ctx.KKKChanleId
            local url = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s" , self.last_account, platformChanleId, distId)
            if platformChanleId == 0 and distId == "12467" then
                url = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s" , self.last_account, 13, "0")
            end
            if BaseUtils.IsVerify then
                url = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s" , self.last_account, "verify", distId)
            end
            ctx:GetRemoteTxt(url, self.RemoteListLoaded, 3)
        end
    end
    local _account = self.input_field.text
    local platformId = tostring(ctx.PlatformChanleId)
    if _account ~= nil then
        for _, data in ipairs(LoginConfig.WhiteList) do
            local waccount = data .. platformId
            if waccount == _account then
                continue = true
            end
        end
    end

    if continue then
        ctx.LoadingPage:Hide()
        print("on_submit")
        if self.input_field.text == "" or self.input_field.text == TI18N("请输入帐号") then
            if SdkManager.Instance:RunSdk() then
                -- mod_notify.append_scroll_win(TI18N("请先登录！"))
                Log.Debug("wang==>   SdkManager.Instance:OnShowLoginView()")
                SdkManager.Instance:OnShowLoginView()
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("请输入帐号！"))
            end
            return
        end

        self:SavePlayerPrefs("last_account", self.input_field.text)
        self:SavePlayerPrefs("last_server", self._server_name)

        RoleManager.Instance.RoleData.account = self.input_field.text
        LoginManager.Instance:Do_Login(self._server_index, self.input_field.text)
    else
        NoticeManager.Instance:FloatTipsByString(msg)
    end
end

-- 隐藏
function LoginView:hide_account_input()
    -- wang 修改    self.transform:FindChild("InputCon").gameObject:SetActive(false)
end

-- 清除账号
function LoginView:clear_account_input()
    if self.input_field then
        self.input_field.text = ""
    end
    self:SavePlayerPrefs("last_account", "")
end

function LoginView:open_zone_select_win()
    local nowtime = os.time()
    self.zone_select_win:SetActive(true)
    if self.nameEffect ~= nil then
        self.nameEffect:SetActive(false)
    end
end

function LoginView:close_zone_select_win()
    self.zone_select_win:SetActive(false)
    if self.nameEffect ~= nil then
        self.nameEffect:SetActive(true)
    end
end

function LoginView:on_server_btn_click(item, btn, index)
    -- self.select_server_button.gameObject:SetActive(true)

    -- self:update_selected_server(item.name, index)
    local nowsvr = item
    nowsvr.index = index
    self.currSelectData = nowsvr
    -- self:UpdateRoleList(index)
    if self.currSelectData ~= nil then

        local lastsvr = ServerConfig.servers[self._server_index]
        if lastsvr.first_zone ~= self.currSelectData.first_zone then
            local zonename = lastsvr.name
            if lastsvr.first_zone ~= "1" then
                zonename = self.currSelectData.name
            end
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            -- data.content = TI18N("梦幻之旅为<color='#ffff00'>优先体验服</color>，与其他服务器相互切换需要重新加载资源")
            data.content = string.format(TI18N("%s为<color='#ffff00'>优先体验服</color>，与其他服务器相互切换需要重新加载资源"), zonename)
            data.sureLabel = TI18N("确定")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                self.txt_cur_zone_name.text = self.currSelectData.name
                local lastsvr = ServerConfig.servers[self._server_index]
                self:SavePlayerPrefs("last_account", self.input_field.text)
                self:SavePlayerPrefs("last_server", self.currSelectData.name)
                self:SavePlayerPrefs("last_isfirst", self.currSelectData.first_zone)
                self._server_name = self.currSelectData.name
                self._server_index = self.currSelectData.index
                Application.Quit()
            end
            NoticeManager.Instance:ConfirmTips(data)
            return
        end
        self.txt_cur_zone_name.text = self.currSelectData.name
        self:SavePlayerPrefs("last_account", self.input_field.text)
        self:SavePlayerPrefs("last_server", self.currSelectData.name)
        self:SavePlayerPrefs("last_isfirst", self.currSelectData.first_zone)
        self._server_name = self.currSelectData.name
        self._server_index = self.currSelectData.index
        self.currSelectData = nil
    end

    self:on_submit(nowsvr)
end

function LoginView:SavePlayerPrefs(key, val)
    local origin = WWW.EscapeURL(tostring(val))
    PlayerPrefs.SetString(key, origin)
end

function LoginView:GetPlayerPrefs(key)
    local str = PlayerPrefs.GetString(key)
    return WWW.UnEscapeURL(str)
end

function LoginView:UpdateRoleList(index)

end

function LoginView:GetRecomedList()
    local nowtime = os.time()
    local temp = {}
    local hasrole = false
    local showTime = self.isWhiteList and self.whiteTime or self.showTime
    for i,v in ipairs(ServerConfig.servers) do
        if v.recomed ~= nil and v.recomed == "1" then
            if self.isLocalList or self.isWhiteList or v.platform ~= "test" or self.isSpecial  then
                local svr = v
                svr.index = i
                showTime = self:GetShowTime(svr, self.isWhiteList)
                if self:PermitSpecial(svr) and not (svr.begin_time ~= nil and svr.begin_time ~= 0 and svr.begin_time > (nowtime + showTime)) then
                    table.insert(temp, svr)
                    if v.roles ~= nil and next(v.roles) ~= nil then
                        hasrole = true
                    end
                end
            end
        end
    end
    return temp, hasrole
end

function LoginView:GetHasRoleList()
    local nowtime = os.time()
    local temp = {}
    for i,v in ipairs(ServerConfig.servers) do
        if v.roles ~= nil and next(v.roles) ~= nil then
            if self.isLocalList or self.isWhiteList or v.platform ~= "test" or self.isSpecial then
                local svr = v
                svr.index = i
                if self:PermitSpecial(svr) then
                    table.insert(temp, svr)
                end
            end
        end
    end
    return temp
end

function LoginView:GetAreaNum()
    local nowtime = os.time()
    local num = 0
    -- num = math.ceil(#ServerConfig.servers/20)
    local servers_num = #ServerConfig.servers
    local showTime = self.isWhiteList and self.whiteTime or self.showTime
    for i=1, servers_num do
        local svr = ServerConfig.servers[i]
        if self.isLocalList or self.isWhiteList or svr.platform ~= "test" or self.isSpecial then
            if self:PermitSpecial(svr) and not (svr.begin_time ~= nil and svr.begin_time ~= 0 and svr.begin_time > (nowtime + showTime))then
                num = num + 1
            end
        end
    end
    num = math.ceil(num/20)
    return num
end

function LoginView:IsAreaHasRole(areanum)
    local nowtime = os.time()
    local hasrole = false
    local num = #ServerConfig.servers
    local showTime = self.isWhiteList and self.whiteTime or self.showTime
    for i=1, num do
        if i<=num-(areanum-1)*20 and i> num-areanum*20 then
            local svr = ServerConfig.servers[i]
            if self.isLocalList or self.isWhiteList or svr.platform ~= "test" or self.isSpecial then
                svr.index = i
                showTime = self:GetShowTime(svr, self.isWhiteList)
                if self:PermitSpecial(svr) and not (svr.begin_time ~= nil and svr.begin_time ~= 0 and svr.begin_time > (nowtime + showTime))then
                    if svr.roles ~= nil and next(svr.roles) ~= nil then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function LoginView:GetAreaList(areanum)
    local nowtime = os.time()
    local temp = {}
    local hasrole = false
    local num = #ServerConfig.servers
    -- for i,v in ipairs(ServerConfig.servers) do
    --     if i>(areanum-1)*20 and i<= areanum*20 then
    --         if self.isLocalList or self.isWhiteList or v.platform ~= "test" or self.isSpecial then
    --             local svr = v
    --             svr.index = i
    --             if self:PermitSpecial(svr) then
    --                 table.insert(temp, svr)
    --                 if v.roles ~= nil and #v.roles > 0 then
    --                     hasrole = true
    --                 end
    --             end
    --         end
    --     end
    -- end
    local showTime = self.isWhiteList and self.whiteTime or self.showTime
    for i=1, num do
        if i<=num-(areanum-1)*20 and i> num-areanum*20 then
            local svr = ServerConfig.servers[i]
            if self.isLocalList or self.isWhiteList or svr.platform ~= "test" or self.isSpecial then
                svr.index = i
                showTime = self:GetShowTime(svr, self.isWhiteList)
                if self:PermitSpecial(svr) and not (svr.begin_time ~= nil and svr.begin_time ~= 0 and svr.begin_time > (nowtime + showTime))then
                    table.insert(temp, svr)
                    if svr.roles ~= nil and next(svr.roles) ~= nil then
                        hasrole = true
                    end
                end
            end
        end
    end
    return temp, hasrole
end

function LoginView:InitTabPanel()
    if self.tabCon == nil then
        return
    end
    local hasList = self:GetHasRoleList()
    local recomedList, hasrole = self:GetRecomedList()
    local selected = false
    if #hasList > 0 and not self.model.ListLoaded then
        local btn = GameObject.Instantiate(self.tabBtn)
        btn.name = TI18N("已有角色")
        btn.transform:Find("Text"):GetComponent(Text).text = TI18N("已有角色")
        UIUtils.AddUIChild(self.tabCon.gameObject, btn)
        local func = function()
            self:UnselectAllTab()
            btn.transform:Find("Select").gameObject:SetActive(true)
            self:UpdateServerList(1)
        end
        btn.transform:GetComponent(Button).onClick:AddListener(func)
        btn.transform:Find("Icon").gameObject:SetActive(true)
        -- func()
        -- selected = true
    end
    if #recomedList > 0 and not self.model.ListLoaded then
        local btn = GameObject.Instantiate(self.tabBtn)
        btn.name = TI18N("推荐")
        btn.transform:Find("Text"):GetComponent(Text).text = TI18N("推 荐")
        UIUtils.AddUIChild(self.tabCon.gameObject, btn)
        local func = function()
            self:UnselectAllTab()
            btn.transform:Find("Select").gameObject:SetActive(true)
            self:UpdateServerList(2)
        end
        btn.transform:GetComponent(Button).onClick:AddListener(func)
        btn.transform:Find("Icon").gameObject:SetActive(hasrole)
        -- if not selected then
        --     func()
        --     selected = true
        -- end
    end
    local areanum, areahasrole = self:GetAreaNum()
    for i=areanum,1,-1 do
        if self.tabCon == nil then
            return
        end
        local btn = self.tabCon:Find(tostring(i))
        if btn == nil then
            btn = GameObject.Instantiate(self.tabBtn)
        else
            btn = btn.gameObject
        end
        btn.name = tostring(i)
        UIUtils.AddUIChild(self.tabCon.gameObject, btn)
        btn.transform:Find("Text"):GetComponent(Text).text = BaseUtils.NumToChn(i)..TI18N("区")
        local func = function()
            self:UnselectAllTab()
            btn.transform:Find("Select").gameObject:SetActive(true)
            self:UpdateServerList(3,i)
        end
        btn.transform:GetComponent(Button).onClick:AddListener(func)
        if i == areanum then
            func()
            selected = true
        end
        btn.transform:Find("Icon").gameObject:SetActive(self:IsAreaHasRole(i))
    end
    self.model.ListLoaded = true
end

function LoginView:UnselectAllTab()
    local num = self.tabCon.childCount
    for i=1,num do
        self.tabCon:GetChild(i-1):Find("Select").gameObject:SetActive(false)
    end
end

--type 1 有角色，2推荐，3区
function LoginView:UpdateServerList(type, num)
    self:HideAll()
    local dataList = ServerConfig.servers
    if type == 1 then
        dataList = self:GetHasRoleList()
    elseif type == 2 then
        dataList = self:GetRecomedList()
    elseif type == 3 then
        dataList = self:GetAreaList(num)
    end
    local serNum = #dataList
    local barnum = math.ceil(serNum/2)
    local nowtime = os.time()
    local selectfunc = nil
    local showTime = self.isWhiteList and self.whiteTime or self.showTime
    for i=1,#dataList do
        local item = dataList[i]
        local index = math.floor((i-1)/2)+1
        local subindex = ((i-1)%2)+1
        local server_btn = self.ButtonList[i]
        if server_btn == nil then
            return
        end
        -- server_btn.transform:SetParent(self.server_content_panel.transform)
        server_btn.name.text = item.name
        if IS_DEBUG then
            server_btn.name.text = string.format("%s-%s",item.name, item.zone_id)
        end
        server_btn.Port.text = tostring(item.port)
        server_btn.Platform.text = tostring(item.platform)
        server_btn.transform.gameObject.name = item.name
        server_btn.transform.gameObject:SetActive(true)
        local func = function ()
            local temp = item
            local bt = server_btn.transform.gameObject
            self:on_server_btn_click(temp, bt, item.index)
        end
        if item.roles ~= nil and next(item.roles) ~= nil then
            server_btn.Headbg:SetActive(true)
            server_btn.head.sprite = PreloadManager.Instance:GetSprite(AssetConfig.heads, item.roles.class.."_"..item.roles.sex)
            server_btn.lev.text = item.roles.lev
        else
            server_btn.Headbg:SetActive(false)
        end

        showTime = self:GetShowTime(item, self.isWhiteList)
        if item.begin_time ~= nil and item.begin_time ~= 0 and item.begin_time > (nowtime + showTime) then
            server_btn.transform.gameObject:SetActive(false)
        end
        server_btn.status.gameObject:SetActive(true)
        server_btn.RecommendLabel:SetActive(false)
        server_btn.newLabel:SetActive(false)
        server_btn.status.sprite = self.assetWrapper:GetSprite(AssetConfig.login_textures, "hotstatus")
        if item.isnew ~= nil and item.isnew == "1" then
            server_btn.newLabel:SetActive(true)
            server_btn.status.gameObject:SetActive(false)
        elseif item.recomed ~= nil and item.recomed == "1" then
            -- server_btn.RecommendLabel:SetActive(true)
            -- server_btn.status.gameObject:SetActive(false)
        elseif item.hot ~= nil and item.hot == "1" then
            -- server_btn.transform:Find("Label").gameObject:SetActive(false)
        else
            -- server_btn.transform:Find("Label").gameObject:SetActive(false)
        end
        server_btn.openText.gameObject:SetActive(false)
        if item.begin_time ~= nil and item.begin_time ~= 0 and item.begin_time > nowtime then
            server_btn.newLabel:SetActive(true)
            server_btn.openText.text = string.format(TI18N("%s月%s日\n%s:%s开启"), tostring(tonumber(os.date("%m", item.begin_time))), os.date("%d", item.begin_time), os.date("%H", item.begin_time), os.date("%M", item.begin_time))--[[os.date("%m月%d日\n%H%:%M开启", item.begin_time)]]
            server_btn.openText.gameObject:SetActive(true)
            server_btn.status.sprite = self.assetWrapper:GetSprite(AssetConfig.login_textures, "closestatus")
        elseif item.end_time ~= nil and item.end_time < nowtime then
            server_btn.openText.gameObject:SetActive(false)
        else
            server_btn.openText.gameObject:SetActive(false)
        end
        server_btn.transform:GetComponent(Button).onClick:RemoveAllListeners()
        server_btn.transform:GetComponent(Button).onClick:AddListener(func)

        server_btn.status.gameObject:SetActive(false)
    end
end

function LoginView:HideAll()
    for _,btn in ipairs(self.ButtonList) do
        btn.transform.gameObject:SetActive(false)
    end
end


function LoginView:OnServerListLoaded(www, str)
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    -- Log.Info(www)
    if IS_DEBUG or BaseUtils.IsExperienceSrv() then
        if DataServerList.data_list[self.reqname] ~= nil and DataServerList.data_list[self.reqname].loaded == true then
            self.reqname = nil
            return
        end
        xpcall(function() ctx.ServerListConfig = NormalJson(www) end,
            function()  Log.Error(string.format("ServerListPrase_Error：%s || %s", debug.traceback(), www)) end )
        for i,v in ipairs(ctx.ServerListConfig.table.msg.server_list) do
            ctx.ServerListConfig.table.msg.server_list[i].begin_time = tonumber(ctx.ServerListConfig.table.msg.server_list[i].begin_time)
            ctx.ServerListConfig.table.msg.server_list[i].end_time = tonumber(ctx.ServerListConfig.table.msg.server_list[i].end_time)
            ctx.ServerListConfig.table.msg.server_list[i].port = tonumber(ctx.ServerListConfig.table.msg.server_list[i].port)
            ctx.ServerListConfig.table.msg.server_list[i].zone_id = tonumber(ctx.ServerListConfig.table.msg.server_list[i].zone_id)
            table.insert(ServerConfig.servers, v)
        end
        if self.reqname ~= nil then
            self.devlayout:Find(self.reqname):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton2")
            DataServerList.data_list[self.reqname].loaded = true
        end
        self.reqname = nil
        NoticeManager.Instance:FloatTipsByString(TI18N("请求完成！重新打开选服面板！"))
    else
        xpcall(function()
            ctx.ServerListConfig = NormalJson(www) end,
            function() Log.Error(string.format("ServerListPrase_Error：%s || %s", debug.traceback(), www)) end )
        xpcall(function()
                if ServerConfig.GetServers ~= nil then
                    local func = ServerConfig.GetServers
                    local target = ServerConfig.target_server
                    ServerConfig = ServerConfig.GetServers()
                    ServerConfig.GetServers = func
                    ServerConfig.target_server = target
                end
            end,
            function() Log.Error(string.format("ServerListReload_Error：%s ", debug.traceback())) end )
    end
    -- BaseUtils.dump(ServerConfig.servers,"服务其列表")
    self:SetLastServer()
    self:InitTabPanel()
end

function LoginView:SetLastServer()
    local nowtime = os.time()
    self.last_server = self:GetPlayerPrefs("last_server")
    self._server_name = TI18N("点击选择服务器")
    self._server_index = 1

    if BaseUtils.IsExperienceSrv() then
        self.last_server = "玩家测试服"
    end

    if self.last_server ~= "" then
        for i=1,#ServerConfig.servers do
            local s = ServerConfig.servers[i]
            if s.name == self.last_server and self:PermitSpecial(s) then
                self._server_name = self.last_server
                self._server_index = i
                LoginManager.Instance.curPlatform = s.platform
            end
        end
        if self._server_name == TI18N("点击选择服务器") then
            self.last_server = ""
        end
    end
    local showTime = self.isWhiteList and self.whiteTime or self.showTime
    if self.last_server == nil or self.last_server == "" or self._server_name == TI18N("点击选择服务器") then
        showTime = self:GetShowTime(ServerConfig.default_zone, self.isWhiteList)
        if not self.isSpecial and next(ServerConfig.default_zone) ~= nil and ServerConfig.default_zone.platform ~= "test" and not (ServerConfig.default_zone.begin_time ~= nil and tonumber(ServerConfig.default_zone.begin_time) ~= 0 and tonumber(ServerConfig.default_zone.begin_time) > (nowtime + showTime))  then
            local srv = ServerConfig.default_zone
            for i, v in ipairs(ServerConfig.servers) do
                if ServerConfig.default_zone.name == v.name then
                    self._server_index = i
                end
            end
            LoginManager.Instance.curPlatform = srv.platform
            self.last_server = srv.name
            self._server_name = self.last_server
            self:SavePlayerPrefs("last_isfirst", srv.first_zone)
        else
            for i = 1, #ServerConfig.servers do
                local srv = ServerConfig.servers[i]
                if  (not self.isSpecial and (srv.recomed == "1" and srv.platform ~= "test" and (self.last_server == nil or self.last_server == "" or self._server_name == TI18N("点击选择服务器")))) or (self.isSpecial and self:PermitSpecial(srv) ) then

                    showTime = self:GetShowTime(srv, self.isWhiteList)
                    if srv.begin_time ~= nil and self:PermitSpecial(srv) and not (srv.begin_time ~= nil and srv.begin_time ~= 0 and srv.begin_time > (nowtime + showTime)) then
                        if srv.begin_time < nowtime then
                            self.last_server = srv.name
                            self._server_index = i
                            self._server_name = self.last_server
                            LoginManager.Instance.curPlatform = srv.platform
                        end
                    elseif self:PermitSpecial(srv) and not (srv.begin_time ~= nil and srv.begin_time ~= 0 and srv.begin_time > (nowtime + showTime)) then
                        self.last_server = srv.name
                        self._server_index = i
                        self._server_name = self.last_server
                        LoginManager.Instance.curPlatform = srv.platform
                    end
                    self:SavePlayerPrefs("last_isfirst", srv.first_zone)
                end
            end
            self._server_name = self.last_server
        end
    end
    --不符合筛选条件选最新一个非评审服
    if self.last_server == nil or self.last_server == "" or self._server_name == TI18N("点击选择服务器") then
        for i = 1, #ServerConfig.servers do
            local srv = ServerConfig.servers[i]
            if  (srv.platform ~= "test" and (self.last_server == nil or self.last_server == "" or self._server_name == TI18N("点击选择服务器"))) or self.isSpecial then
                if self:PermitSpecial(srv) then
                    self.last_server = srv.name
                    self._server_index = i
                    self._server_name = self.last_server
                    LoginManager.Instance.curPlatform = srv.platform
                    self:SavePlayerPrefs("last_isfirst", srv.first_zone)
                end
            end
        end
        self._server_name = self.last_server
    end
    -- BaseUtils.dump(ServerConfig.servers)
    self.txt_cur_zone_name.text = self._server_name

    BaseUtils.NewPlayerImport(KvData.newPlayerImportStepType.login, LoginManager.Instance.curPlatform)
    BaseUtils.ChannelBagDownLoadQRCodeURl()
end


function LoginView:PermitSpecial(svr)
    if not self.isSpecial or self.isWhiteList then
        return true
    else
        if (self.PermitList.zone_id == nil or svr.zone_id == self.PermitList.zone_id) and
            (self.PermitList.platform == nil or self.PermitList.platform == "" or svr.platform == self.PermitList.platform) then
            return true
        else
            return false
        end
    end
end


function LoginView:ReTry()
    if self.model ~= nil and self.model.ListLoaded == false then
        local distId = ctx.KKKChanleId
        local url = ctx.BaseSetting.ServerListPath
        local platformChanleId = ctx.PlatformChanleId
        url = string.format("%s?account=%s&chanleId=%s&distId=%s",url , self.last_account, platformChanleId, distId)
        if platformChanleId == 0 and distId == "12467" then
            url = string.format("%s?account=%s&chanleId=%s&distId=%s" , ctx.BaseSetting.ServerListPath, self.last_account, 13, "0")
        end
        if BaseUtils.IsVerify then
            url = string.format("%s?account=%s&chanleId=%s&distId=%s",url , self.last_account, "verify", distId)
        end
        ctx:GetRemoteTxt(url, self.RemoteListLoaded, 3)
        local data = NoticeConfirmData.New()
        data.type = ConfirmData.Style.Normal
        data.content = TI18N("你的网络有些缓慢，是否要重新加载")
        data.sureLabel = TI18N("确定")
        data.cancelLabel = TI18N("取消")
        data.sureCallback = function()
            ctx:GetRemoteTxt(url, self.RemoteListLoaded, 3)
            LuaTimer.Add(5000, function() self:ReTry() end)
        end
        NoticeManager.Instance:ConfirmTips(data)
    else
        return
    end
end

function LoginView:InitDevelopUI()
    self.Extbtn = self.transform:Find("ExtButton")
    self.baseSvrbtn = self.transform:Find("DevSvrListLoad/btn").gameObject
    self.devPanel = self.transform:Find("DevSvrListLoad")
    self.devlayout = self.transform:Find("DevSvrListLoad/Con/Layout")
    local distId = ctx.KKKChanleId
    for k,v in pairs(DataServerList.data_list) do
        local item = GameObject.Instantiate(self.baseSvrbtn)
        item.name = k
        item.transform:Find("Text"):GetComponent(Text).text = k
        item.transform:SetParent(self.devlayout)
        item.transform.localScale = Vector3.one
        item:SetActive(true)
        local url1 = string.format("http://register.xcqy.shiyuegame.com/index.php/server/lists?account=%s&chanleId=%s&distId=%s", self.last_account, v.cid, v.distId)
        item.transform:GetComponent(Button).onClick:AddListener(function()
            if self.reqname ~= nil then
                NoticeManager.Instance:FloatTipsByString(TI18N("别急啊，上个请求还没返回"))
                return
            end
            self.reqname = k
            ctx:GetRemoteTxt(url1, self.RemoteListLoaded, 3)
            NoticeManager.Instance:FloatTipsByString(TI18N("开始请求，稍等。。。。。。"))
            self.devPanel.gameObject:SetActive(false)
            self.Extbtn.gameObject:SetActive(true)
            LuaTimer.Add(5000, function() if self.reqname == nil then return end self.reqname = nil NoticeManager.Instance:FloatTipsByString(TI18N("等了好久都没返回，再点一下试试吧")) end)
        end)
    end
    self.Extbtn:GetComponent(Button).onClick:AddListener(function ()
        self.devPanel.gameObject:SetActive(true)
        self.Extbtn.gameObject:SetActive(false)
    end)
    self.devPanel.gameObject:SetActive(false)
    self.Extbtn.gameObject:SetActive(true)
end

function LoginView:CheckchanleIdLimit()
    local limitList = {
        [11] = true,
        [12] = true,
        [13] = true,
        [22] = true,
        [32] = true,
        [33] = 4,
        [51] = true,
        [8] = true,
        [110] = true,
    }
    if BaseUtils.GetPlatform() == "android" and BaseUtils.CSVersionToNum() < 10206 and (limitList[ctx.PlatformChanleId] == true or limitList[ctx.PlatformChanleId] == ctx.KKKChanleId) then
        return true
    else
        return false
    end
end

function LoginView:GetShowTime(srvInfo, isWhiteList)
    local showTime = self.showTime
    if isWhiteList then
        showTime = self.whiteTime
    else
        if srvInfo.platform ~= nil and srvInfo.platform == "beta" then
            showTime = self.showTimeBeta
        else
            showTime = self.showTime
        end
    end
    return showTime
end

-- 打开版权信息网页
function LoginView:ShowCopyRightWebPage()
    local url = "http://sq.ccm.gov.cn:80/ccnt/sczr/service/business/emark/gameNetTag/4028c08c528c872f0152f39c0ee54e6b"
    Application.OpenURL(url)
end

-- 打开版权信息网页2
function LoginView:ShowCopyRightWebPage2()
    local url = "http://sq.ccm.gov.cn/ccnt/sczr/service/business/emark/toDetail/4028c08e4acd2047014acdff453600b0"
    Application.OpenURL(url)
end

-- 玩家测试服自动账号
function LoginView:GenTmpAccount()
    local nowtime = os.date("TA%Y%m%d%H%M%S") .. math.random(1000) .. "_714"
    return nowtime
end

--- 切换账号
function LoginView:OnChangeAccount()
    SdkManager.Instance:ChangeAccount()
end
