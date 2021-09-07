Marry_NowWeddingView = Marry_NowWeddingView or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function Marry_NowWeddingView:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.marry_now_wedding_window
    self.name = "Marry_NowWeddingView"
    self.resList = {
        {file = AssetConfig.marry_now_wedding_window, type = AssetType.Main}
        , {file = AssetConfig.marry_textures, type = AssetType.Dep}
        , {file = AssetConfig.heads, type = AssetType.Dep}
    }

    -----------------------------------------
    self.weddingNameText = nil
    self.Button = nil

    self.maleHead = nil
    self.femaleHead = nil
    self.maleText = nil
    self.femaleText = nil

    self.timeText = nil

    self.timer_id = nil

    -----------------------------------------
end

function Marry_NowWeddingView:__delete()
    self:ClearDepAsset()

    if self.timer_id ~= nil then LuaTimer.Delete(self.timer_id) self.timer_id = nil end
end

function Marry_NowWeddingView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.marry_now_wedding_window))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.maleHead = self.transform:FindChild("Main/Panel/MaleHead/Head"):GetComponent(Image)
    self.femaleHead = self.transform:FindChild("Main/Panel/FemaleHead/Head"):GetComponent(Image)

    self.maleText = self.transform:FindChild("Main/Panel/MaleText"):GetComponent(Text)
    self.femaleText = self.transform:FindChild("Main/Panel/FemaleText"):GetComponent(Text)

    self.weddingNameText = self.transform:FindChild("Main/Panel/WeddingNameText"):GetComponent(Text)

    self.timeText = self.transform:FindChild("Main/Panel/TimeText"):GetComponent(Text)
    self.timeText.text = ""

    self.Button = self.transform:FindChild("Main/Panel/Button"):GetComponent(Button)
    self.Button.onClick:AddListener(function() self:ButtonClick() end)

    self.panel = self.transform:FindChild("Main/Panel").gameObject
    self.noWedding = self.transform:FindChild("Main/NoWedding").gameObject

    self:Update()

    local data = MarryManager.Instance.model
    if data.status ~= 0 then
        self.timer_id = LuaTimer.Add(0, 1000, function() self:Update_Time() end)
    end
end

function Marry_NowWeddingView:Close()
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.marry_now_wedding_window)
end

function Marry_NowWeddingView:Update()
    local data = MarryManager.Instance.model
    if data.status ~= 0 then
    	self.maleHead.sprite = self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_1", data.male_classes))
        self.femaleHead.sprite =  self.assetWrapper:GetSprite(AssetConfig.heads, string.format("%s_0", data.female_classes))

        self.maleText.text = data.male_name
        self.femaleText.text = data.female_name

        if data.type == 1 then
            self.weddingNameText.text = TI18N("挚爱典礼")
        else
            self.weddingNameText.text = TI18N("豪华典礼")
        end
    else
        self.panel:SetActive(false)
        self.noWedding:SetActive(true)
    end
end

function Marry_NowWeddingView:Update_Time()
    local marryModel = MarryManager.Instance.model
    local time = marryModel.end_time - os.time()
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(time)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)

    self.timeText.text = string.format(TI18N("距离典礼结束剩余 %s:%s"), my_minute, my_second)
end

function Marry_NowWeddingView:ButtonClick()
	self:Close()
    MarryManager.Instance:Send15009()
end

