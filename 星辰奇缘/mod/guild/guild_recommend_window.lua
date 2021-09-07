GuildRecommendWindow  =  GuildRecommendWindow or BaseClass(BaseWindow)

function GuildRecommendWindow:__init(model)
    self.name  =  "GuildRecommendWindow"
    self.model  =  model
    self.windowId = WindowConfig.WinID.guardian
    self.resList  =  {
        {file  =  AssetConfig.guild_recommend_win, type  =  AssetType.Main}
    }

    self.freshCdTime = 3
    self.timer_id = 0
end

function GuildRecommendWindow:__delete()
    self.is_open = false

    self:stop_timer()

    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end


function GuildRecommendWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_recommend_win))
    self.gameObject.name  =  "guild_recommend_win"

    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)


    self.main_con = self.gameObject.transform:FindChild("MainCon").gameObject
    self.closeBtn =self.main_con.transform:FindChild("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener( function() self.model:CloseRecommendUI() end)

    self.ConBtn = self.main_con.transform:FindChild("ConBtn")
    self.ConDesc = self.main_con.transform:FindChild("ConDesc")

    self.Btn1 = self.ConBtn:FindChild("Btn1"):GetComponent(Button)
    self.Btn2 = self.ConBtn:FindChild("Btn2"):GetComponent(Button)
    self.Btn3 = self.ConBtn:FindChild("Btn3"):GetComponent(Button)

    self.Btn1_txt = self.Btn1.transform:FindChild("Text"):GetComponent(Text)
    self.Btn2_txt = self.Btn2.transform:FindChild("Text"):GetComponent(Text)
    self.Btn3_txt = self.Btn3.transform:FindChild("Text"):GetComponent(Text)

    self.Btn1.onClick:AddListener(function() self:on_click(1) end)
    self.Btn2.onClick:AddListener(function() self:on_click(2) end)
    self.Btn3.onClick:AddListener(function() self:on_click(3) end)

    GuildManager.Instance:request11157()
end

function GuildRecommendWindow:update_recommend_list(list)
    self.current_list = list

    self.Btn1.gameObject:SetActive(false)
    self.Btn2.gameObject:SetActive(false)
    self.Btn3.gameObject:SetActive(false)
    self.ConBtn.gameObject:SetActive(false)
    self.ConDesc.gameObject:SetActive(false)

    local state = false
    if self.current_list[1] ~= nil then
        self.Btn1.gameObject:SetActive(true)
        self.Btn1_txt.text = ""
        state = true
    end

    if self.current_list[2] ~= nil then
        self.Btn2.gameObject:SetActive(true)
        self.Btn2_txt.text = ""
        state = true
    end


    if self.current_list[3] ~= nil then
        self.Btn3.gameObject:SetActive(true)
        self.Btn3_txt.text = ""
        state = true
    end

    if state then
        self.ConBtn.gameObject:SetActive(true)
    else
        self.ConDesc.gameObject:SetActive(true)

    end

    self:stop_timer()
    self:start_timer()

    self:tick_timer(0)
end

function GuildRecommendWindow:start_timer()
    LuaTimer.Add(0, 1000, function(id) self:tick_timer(id) end)
end

function GuildRecommendWindow:stop_timer()
    if self.timer_id ~= 0 then
        LuaTimer.Delete(self.timer_id)
        self.timer_id = 0
    end
end

function GuildRecommendWindow:tick_timer(id)
    self.timer_id = id

    if self.current_list[1] ~= nil then
        self.current_list[1].ctime = self.current_list[1].ctime + 172800 - BaseUtils.BASE_TIME
        self.Btn1_txt.text = self:format_time(self.current_list[1].name, self.current_list[1].ctime)
    else
        self.Btn1.gameObject:SetActive(false)
    end

    if self.current_list[2] ~= nil then
        self.current_list[2].ctime = self.current_list[2].ctime + 172800 - BaseUtils.BASE_TIME
        self.Btn2_txt.text = self:format_time(self.current_list[2].name, self.current_list[2].ctime)
    else
        self.Btn2.gameObject:SetActive(false)
    end


    if self.current_list[3] ~= nil then
        if self.current_list[3].ctime >= 0 then
            self.current_list[3].ctime = self.current_list[3].ctime + 172800 - BaseUtils.BASE_TIME
            self.Btn3_txt.text = self:format_time(self.current_list[3].name, self.current_list[3].ctime)
        else
            self.Btn3.gameObject:SetActive(false)
        end
    end
end

function GuildRecommendWindow:format_time(name, ctime)
    local my_date, my_hour, my_minute, my_second = BaseUtils.time_gap_to_timer(ctime)
    if my_hour > 0 then
        return string.format("%s %s%s%s%s%s", name, TI18N("剩余:"), my_hour, TI18N("时"), my_minute, TI18N("分"))
    else
        return string.format("%s %s%s%s%s%s", name, TI18N("剩余:"), my_minute, TI18N("分"), my_second, TI18N("秒"))
    end
end


function GuildRecommendWindow:on_click(index)
    local data = self.current_list[index]
     GuildManager.Instance:request11159(data.rid, data.platform, data.zone_id)
end