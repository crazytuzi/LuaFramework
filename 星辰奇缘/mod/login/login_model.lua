LoginModel = LoginModel or BaseClass(BaseModel)

function LoginModel:__init()
    self.window = nil

    self.login_visable = false
    self.ListLoaded = false
end

function LoginModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
        self.login_visable = false
    end
end

function LoginModel:InitMainUI()
    if self.window == nil then
        self.window = LoginView.New(self)
        self.login_visable = true
        SoundManager.Instance:PlayBGM(SoundEumn.Background_MainCity)
    else
        self.window:SetAccountByCookie()
    end
end

function LoginModel:CloseMainUI()
    print(string.format("关闭登录界面 %s", tostring(self.window)))
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
        self.login_visable = false
    end
end

function LoginModel:clear_account_input()
    if self.window ~= nil then
        self.window:clear_account_input()
    end
end

function LoginModel:SetAccountByCookie()
    if self.window ~= nil then
        self.window:SetAccountByCookie()
    end
end

function LoginModel:CleanStartPage()
    if not BaseUtils.IsUseBaseCanvasBg() then
        local baseCanvasContainer = ctx.CanvasContainer.transform:Find("BaseCanvas/Container")
        if not BaseUtils.isnull(baseCanvasContainer) then
            local startPage = baseCanvasContainer:Find("StartPage")
            if not BaseUtils.isnull(startPage) then
                if not BaseUtils.IsNewIosVest() then -- ios新马甲包，由于LoginView要取这张图片，这里改为不释放
                    startPage:GetComponent(Image).sprite = nil
                    startPage:GetComponent(Image).enabled = false
                end

                local gameLogo = startPage:Find("GameLogo")
                if not BaseUtils.isnull(gameLogo) then
                    gameLogo:GetComponent(Image).sprite = nil
                    gameLogo:GetComponent(Image).enabled = false
                end
            end
        end
    end
end