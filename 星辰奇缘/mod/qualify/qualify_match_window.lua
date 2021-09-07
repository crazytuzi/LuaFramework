QualifyMatchWindow  =  QualifyMatchWindow or BaseClass(BaseWindow)

function QualifyMatchWindow:__init(model)
    self.name  =  "QualifyMatchWindow"
    self.model  =  model


    self.windowId = WindowConfig.WinID.qualifying_match_window
    -- 缓存
    self.resList  =  {
        {file  =  AssetConfig.qualifying_match, type  =  AssetType.Main}
    }

    self.is_open = false

    self.item_list = nil
    self.match_timer_id = 0
    self.fight_timer_id = 0
    self.fight_total_time = 5
    return self
end

function QualifyMatchWindow:__delete()
    self.is_open = false
    self.item_list = nil

    self:stop_fight_timer()

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function QualifyMatchWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.qualifying_match))
    self.gameObject:SetActive(false)
    self.gameObject.name = "QualifyMatchWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")

    self.TopCon = self.MainCon:FindChild("TopCon")

    self.item_list = {}
    for i=1,6 do
        local temp_item = self.TopCon:FindChild(string.format("Item%s", i))
        table.insert(self.item_list, temp_item)
    end

    self.MidCon = self.TopCon:FindChild("MidCon")
    self.TxtMatching = self.MidCon:FindChild("TxtMatching"):GetComponent(Text)
    self.TxtCount = self.MidCon:FindChild("TxtCount"):GetComponent(Text)
    self.TxtPreTime = self.MidCon:FindChild("TxtPreTime"):GetComponent(Text)
    self.BtnCancel = self.MainCon:FindChild("BtnCancel"):GetComponent(Button)
    self.ImgVs = self.MainCon:FindChild("ImgVs")
    self.effect = self.ImgVs:FindChild("20067").gameObject

    self.TxtRandomDesc = self.TopCon:FindChild("TxtRandomDesc"):GetComponent(Text)

    Utils.ChangeLayersRecursively(self.effect.transform, "UI")

    self.effect:SetActive(true)

    self.CloseButton =  self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    self.CloseButton.onClick:AddListener(function() self.model:CloseQualifyMatchUI() end)

    self.BtnCancel.onClick:AddListener( function() QualifyManager.Instance:request13501() end)

    QualifyManager.Instance:request13504(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id)

    self:stop_fight_timer()
    self.is_open = true
    if self.model.match_data  == nil then
        self:match_timer_tick()
        self.model:start_match_timer()
        self:create_myself_head()
        self:create_team_head()
    else
        self:update_socket_back()
    end
end



-----------更新逻辑
function QualifyMatchWindow:update_socket_back()
    if self.is_open == false then
        return
    end
    local data = self.model.match_data
    self.model:stop_match_timer()
    -- --创建模型
    -- tpose_data_list = {}

    self:create_heads(data.teammate, 1)
    self:create_heads(data.enemy, 2)

    self:start_fight_timer()
    self.model.match_data = nil
end

--------------头像逻辑
--创建我的头像
function QualifyMatchWindow:create_myself_head()
    local data = {classes = RoleManager.Instance.RoleData.classes, sex = RoleManager.Instance.RoleData.sex, lev = RoleManager.Instance.RoleData.lev}
    self:set_head_data(self.item_list[1], data)
end

--创建队员头像
function QualifyMatchWindow:create_team_head()
    local index = 2
    for k, v in pairs(TeamManager.Instance.memberTab) do
        if v.status ~= RoleEumn.TeamStatus.Away and v.status ~= RoleEumn.TeamStatus.Offline then
            if v.zone_id ~= RoleManager.Instance.RoleData.zone_id or v.platform ~= RoleManager.Instance.RoleData.platform or v.rid ~= RoleManager.Instance.RoleData.id then
                local data = {classes = v.classes, sex = v.sex, lev = v.lev}
                self:set_head_data(self.item_list[index], data)
                index = index + 1
            end
        end
    end
end

--创建头像
function QualifyMatchWindow:create_heads(data_list, _type)
    if  self.is_open == false then
        return
    end
    if _type == 1 then --左边
        for i=1,#data_list do
            local d = data_list[i]
            if d ~= nil then
                self:set_head_data(self.item_list[i], d)
            end
        end
    else --右边

        for i=1,#data_list do
            local d = data_list[i]
            if d ~= nil then
                self:set_head_data(self.item_list[i+3], d)
            end
        end
    end
end

function QualifyMatchWindow:set_head_data(item, data)
    local ImgHead = item.transform:FindChild("ImgHeadBg"):FindChild("Image"):GetComponent(Image)
    local ImgKnife = item.transform:FindChild("ImgHeadBg"):FindChild("ImgKnife").gameObject
    local TxtLev = item.transform:FindChild("ImgLevBg"):FindChild("TxtLev"):GetComponent(Text)
    local ImgClasses = item.transform:FindChild("ImgLevBg"):FindChild("ImgClasses"):GetComponent(Image)
    ImgKnife:SetActive(false)
    ImgHead.gameObject:SetActive(true)
    ImgHead.sprite = PreloadManager.Instance.assetWrapper:GetSprite(AssetConfig.heads , string.format("%s_%s",tostring(data.classes),tostring(data.sex)))
    TxtLev.text = string.format("Lv.%s", data.lev)
    TxtLev.gameObject:SetActive(true)
    ImgClasses.sprite = PreloadManager.Instance:GetSprite(AssetConfig.basecompress_textures, "ClassesIcon_" ..  tostring(data.classes))
end



----------------------计时器逻辑
--计时回调
function QualifyMatchWindow:match_timer_tick()
    local my_minute = math.modf(self.model.total_time % 86400 % 3600 / 60)
    local my_second = math.modf(self.model.total_time % 86400 % 3600 % 60)
    my_minute = my_minute >= 10 and tostring(my_minute) or string.format("0%s", my_minute)
    my_second = my_second >= 10 and tostring(my_second) or string.format("0%s", my_second)
    self.TxtCount.text = string.format("%s:%s", my_minute, my_second)


    if self.model.total_time ~=0 and self.model.total_time%30 == 0 then
        local index = Random.Range(1, #DataQualifying.data_get_msg)
        local cfg_data = DataQualifying.data_get_msg[index]
        self.TxtRandomDesc.text = cfg_data.msg_list[1].msg
        LuaTimer.Add(5000, function()
            if self.is_open then
                self.TxtRandomDesc.text = ""
            end
        end )
    end
end

--开始战斗倒计时
function QualifyMatchWindow:start_fight_timer()
    self:stop_fight_timer()
    self.fight_timer_id = LuaTimer.Add(0, 1000, function() self:fight_timer_tick() end)
    self.TxtMatching.text = TI18N("匹配成功")
end

function QualifyMatchWindow:stop_fight_timer()
    if self.fight_timer_id ~= 0 then
        LuaTimer.Delete(self.fight_timer_id)
        self.fight_timer_id = 0
        self.fight_total_time = 5
    end
end

function QualifyMatchWindow:fight_timer_tick()
    if self.fight_total_time >= 0 then
        self.TxtCount.text = string.format("<color='%s'>%s</color>", ColorHelper.color[5], self.fight_total_time)
        self.fight_total_time = self.fight_total_time - 1
    else
        self.model:CloseQualifyMatchUI()
        self:stop_fight_timer()
    end
end
