--公会战中，战况显示面板
-- @author zgs
GuildfightScorePanel = GuildfightScorePanel or BaseClass(BasePanel)

function GuildfightScorePanel:__init(model)
    self.model = model
    self.name = "GuildfightScorePanel"

    self.buffItemObjList = {}

    self.resList = {
        {file = AssetConfig.guild_fight_score_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.guild_dep_res, type  =  AssetType.Dep}
        , {file = AssetConfig.guild_totem_icon, type = AssetType.Dep}
    }

    self.guildfightDataUpdateFun = function ()
        --更新任务追踪界面
        self:UpdatePanel()
    end
    self.timerIdBefore = 0
    -- self.countDataBefore = 0

    self.roleEventChange = function ( ... )
        self:on_role_event_change()
    end

    self.begin_fight = function ( ... )
        self:beginFight()
    end

    self.end_fight = function ( ... )
        self:endFight()
    end

    self.lastPCntObj = nil
    self.isInFighting = false

    self.isMainHide = false
end
function GuildfightScorePanel:beginFight()
    self.isInFighting = true

    self:ShowScoreBar(false)
end
function GuildfightScorePanel:endFight()
    self.isInFighting = false
    self:ShowScoreBar(true)
end

function GuildfightScorePanel:on_role_event_change()
    if RoleManager.Instance.RoleData.event ~= RoleEumn.Event.GuildFight then
        self.model:ExitScene()
    else
        MainUIManager.Instance:SetWorldLevVisible(false)
    end
end

function GuildfightScorePanel:RemoveTimer()
    if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
        LuaTimer.Delete(self.timerIdBefore)
    end
end

function GuildfightScorePanel:OnInitCompleted()
    --self.showType = self.openArgs[1]
    self:UpdatePanel()
end

function GuildfightScorePanel:__delete()
    self.lastPCntObj = nil
    if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
        LuaTimer.Delete(self.timerIdBefore)
    end
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.end_fight)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.begin_fight)
    EventMgr.Instance:RemoveListener(event_name.role_event_change, self.roleEventChange)
    EventMgr.Instance:RemoveListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)
    self.OnOpenEvent:RemoveAll()
    self.OnHideEvent:RemoveAll()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    -- self.model = nil
end

function GuildfightScorePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.guild_fight_score_panel))
    -- -- print("==========GuildfightScorePanel:InitPanel()========"..ctx.CanvasContainer.name)
	UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform
    self.transform.localPosition = Vector3(self.transform.localPosition.x,self.transform.localPosition.y,1000)

    self.timeText = self.transform:Find("Main/CountDown/Text"):GetComponent(Text)
    self.leftText = self.transform:Find("Main/Lname"):GetComponent(Text)
    self.leftScore = self.transform:Find("Main/LScore"):GetComponent(Text)
    self.righScore = self.transform:Find("Main/RScore"):GetComponent(Text)
    -- self.righScore.alignment = 1
    self.rightText = self.transform:Find("Main/Rname"):GetComponent(Text)

    self.descRole = {
        TI18N("该公会<color='#ffa500'>剩余人数</color>较多，优势较大"),
        TI18N("（公会剩余人数<color='#ffa500'>直接决定</color>公会战胜负结果）"),
    }

    self.leftPcntObj = self.transform:Find("Main2/LPCnt").gameObject
    self.rightPcntObj = self.transform:Find("Main2/RPCnt").gameObject
    self.leftPcntObj:GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.leftPcntObj, itemData = self.descRole})
    end)
    self.rightPcntObj:GetComponent(Button).onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.rightPcntObj, itemData = self.descRole})
    end)
    self.leftPcntObj:SetActive(false)
    self.rightPcntObj:SetActive(false)
    -- self.leftImage = self.transform:Find("Main/LImage"):GetComponent(Image)
    -- self.rightImage = self.transform:Find("Main/RImage"):GetComponent(Image)

    self.main_1 = self.transform:Find("Main").gameObject
    self.main_2 = self.transform:Find("Main2").gameObject

    self.dropDownBtn = self.transform:Find("Dropdown"):GetComponent(Button)
    self.dropDownRect = self.dropDownBtn.gameObject:GetComponent(RectTransform)
    self.dropDownTrans = self.dropDownBtn.gameObject.transform

    self.dropDownBtn.gameObject:SetActive(true)
    self.dropDownBtn.onClick:AddListener(function()
        if self.isMainHide == false then
            self:ShowScoreBar(false)
        else
            self:ShowScoreBar(true)
        end
    end)
    self.remainEnemyBtn = self.transform:Find("Main2/RemainEnemyFlag"):GetComponent(Button)
    self.remainEnemyBtn.onClick:AddListener(function()
        --发协议
        GuildfightManager.Instance:send15508()
    end)
    self.remainEnemyBtn.gameObject:SetActive(false)
    self.remainEnemyBtn.gameObject:GetComponent(TransitionButton).enabled = false
    self.remainEnemyBtn.gameObject:GetComponent(RectTransform).sizeDelta = Vector2(350,62)
    self.remainEnemyRect = self.transform:Find("Main2/RemainEnemyFlag/Img").gameObject:GetComponent(RectTransform)

    EventMgr.Instance:AddListener(event_name.begin_fight, self.begin_fight)
    EventMgr.Instance:AddListener(event_name.end_fight, self.end_fight)
    EventMgr.Instance:AddListener(event_name.role_event_change, self.roleEventChange)
    EventMgr.Instance:AddListener(event_name.guild_fight_data_update, self.guildfightDataUpdateFun)

    self.OnHideEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        MainUIManager.Instance:SetWorldLevVisible(true)
        self:RemoveTimer()
    end)
    self.OnOpenEvent:AddListener(function()
        --self.showType = self.openArgs[1]
        MainUIManager.Instance:SetWorldLevVisible(false)
        self:UpdatePanel()
    end)
end

function GuildfightScorePanel:ShowScoreBar(bool)
    self.main_1:SetActive(bool)
    self.main_2:SetActive(bool)
    self.isMainHide = not bool
    if bool then
        self.dropDownRect.anchoredPosition = Vector2(0, -90)
        self.dropDownTrans.localScale = Vector3.one
    else
        self.dropDownRect.anchoredPosition = Vector2(0, -16)
        self.dropDownTrans.localScale = Vector3(1, -1, 1)
    end
end

function GuildfightScorePanel:getGuildFightData()
    local myGuildFightData = {}
    local othenGuildFightData = {}
    local isCheck = false
    local isMy_side_1 = false
    for i,v in ipairs(GuildfightManager.Instance.myGuildFightList) do
        if v.side == 1 then
            table.insert(myGuildFightData,v)
            if isCheck == false then
                isCheck = true
                isMy_side_1 = false
                for j,vv in ipairs(v.gids) do
                    if vv.guild_id == GuildManager.Instance.model.my_guild_data.GuildId
                        and vv.platform == GuildManager.Instance.model.my_guild_data.PlatForm
                        and vv.zone_id == GuildManager.Instance.model.my_guild_data.ZoneId then
                        isMy_side_1 = true
                    end
                end
            end
        else
            table.insert(othenGuildFightData,v)
        end
    end
    if isMy_side_1 == true then
        return myGuildFightData,othenGuildFightData
    else
        return othenGuildFightData,myGuildFightData
    end
end

function GuildfightScorePanel:UpdatePanel()
    if self.leftText == nil then
        -- Log.Debug("GuildfightScorePanel:UpdatePanel()"..debug.traceback())
        return
    end
    local dataList = GuildfightManager.Instance.myGuildFightList
    if #dataList <= 0 then
        Log.Debug("没有自己公会的匹配信息")
        return
    end
    self.myGuildFightData, self.othenGuildFightData = self:getGuildFightData()
    local nameTxtDic = {}
    for i,v in ipairs(self.myGuildFightData[1].names) do
        table.insert(nameTxtDic,v.name)
    end
    self.leftText.text = table.concat(nameTxtDic,"\n")

    local nameTxtDic2 = {}
    for i,v in ipairs(self.othenGuildFightData[1].names) do
        table.insert(nameTxtDic2,v.name)
    end
    self.rightText.text = table.concat(nameTxtDic2,"\n")
    -- self.leftScore.text = string.format("<color='%s'>人数：</color><color='%s'>%s</color><color='%s'>/%s</color>",ColorHelper.color[5],ColorHelper.color[1],
    --     tostring(myGuildFightData.remain_num) ,ColorHelper.color[5], tostring(myGuildFightData.member_num))
    -- self.rightText.text = othenGuildFightData.name
    -- self.righScore.text = string.format("<color='%s'>人数：</color><color='%s'>%s</color><color='%s'>/%s</color>",ColorHelper.color[5],ColorHelper.color[1],
    --     tostring(othenGuildFightData.remain_num) ,ColorHelper.color[5], tostring(othenGuildFightData.member_num))

    -- self.leftImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(myGuildFightData.totem))
    -- self.rightImage.sprite = self.assetWrapper:GetSprite(AssetConfig.guild_totem_icon , tostring(othenGuildFightData.totem))
    self.remainEnemyBtn.gameObject:SetActive(false)

    self.timeText.text = ""
    if self.timerIdBefore ~= nil and self.timerIdBefore ~= 0 then
        LuaTimer.Delete(self.timerIdBefore)
    end
    local mgr = GuildfightManager.Instance
    if mgr.stateInfo == nil or mgr.stateInfo.timeout == nil then
        -- Log.Error("公会战，状态数据，异常，报空")
        return
    end
    -- self.countDataBefore = mgr.stateInfo.timeout
    -- -- print("-----===========GuildfightScorePanel:UpdatePanel()========timeout="..mgr.stateInfo.timeout)
    self.timerIdBefore = LuaTimer.Add(0, 1000, function()
        --print(self.clickInterval)
        if mgr.stateInfo.timeout > Time.time then
            -- if self.lastPCntObj ~= nil then
            --     self.lastPCntObj:SetActive(false)
            -- end
            if mgr.stateInfo.timeout  - Time.time < 3000 then --10分钟后
                -- if self.myGuildFightData[1].remain_num > self.othenGuildFightData[1].remain_num then
                --     if self.isInFighting == false then

                --         if self.isInFighting == false then
                --             self.lastPCntObj = self.leftPcntObj
                --             self.lastPCntObj:SetActive(true)
                --         end
                --     end
                -- elseif self.myGuildFightData[1].remain_num < self.othenGuildFightData[1].remain_num then
                --     if self.isInFighting == false then
                --         if self.isInFighting == false then
                --             self.lastPCntObj = self.rightPcntObj
                --             self.lastPCntObj:SetActive(true)
                --         end
                --     end
                -- end
                self.leftScore.text = string.format(TI18N("<color='%s'>人数：</color><color='%s'>%s</color><color='%s'>/%s</color>"), ColorHelper.color[5],ColorHelper.color[5],
                    tostring(self.myGuildFightData[1].remain_num) ,ColorHelper.color[5], tostring(self.myGuildFightData[1].member_num))
                -- self.rightText.text = othenGuildFightData.name
                self.righScore.text = string.format(TI18N("<color='%s'>人数：</color><color='%s'>%s</color><color='%s'>/%s</color>"), ColorHelper.color[5],ColorHelper.color[5],
                    tostring(self.othenGuildFightData[1].remain_num) ,ColorHelper.color[5], tostring(self.othenGuildFightData[1].member_num))

                if self.othenGuildFightData[1].remain_num < 11 then
                    self.remainEnemyBtn.gameObject:SetActive(true)
                    self.remainEnemyRect.anchoredPosition = Vector2(106 - self.righScore.preferredWidth / 2 - 16, -12)
                else
                    self.remainEnemyBtn.gameObject:SetActive(false)
                end
            else
                --10分钟前
                self.myOrgValue = 0
                if self.myGuildFightData[1].member_num > 0 then
                    self.myOrgValue = math.ceil(self.myGuildFightData[1].movability / self.myGuildFightData[1].member_num)
                end
                self.leftScore.text = string.format(TI18N("<color='%s'>平均行动力：</color><color='%s'>%s</color>"),ColorHelper.color[5],ColorHelper.color[5],
                    tostring(self.myOrgValue))

                self.otherOrgValue = 0
                if self.othenGuildFightData[1].member_num > 0 then
                    self.otherOrgValue = math.ceil(self.othenGuildFightData[1].movability / self.othenGuildFightData[1].member_num)
                end
                self.righScore.text = string.format(TI18N("<color='%s'>平均行动力：</color><color='%s'>%s</color>"),ColorHelper.color[5],ColorHelper.color[5],
                    tostring(self.otherOrgValue) )
            end

            local day,hour,min,second = BaseUtils.time_gap_to_timer(math.floor(mgr.stateInfo.timeout  - Time.time))
            min = min + hour * 60
            local timeStr = tostring(min)
            if min < 10 then
                timeStr = "0"..tostring(min)
            end
            if second < 10 then
                 timeStr = timeStr..":0"..second
            else
                timeStr = timeStr..":"..second
            end

            self.timeText.text = timeStr --BaseUtils.formate_time_gap(self.countDataBefore,":",0,BaseUtils.time_formate.MIN)
        else
            -- self.countDataBefore = 0
            LuaTimer.Delete(self.timerIdBefore)
        end
    end)

    -- self:UpdatePanelData()
end

-- function GuildfightScorePanel:UpdatePanelData()
--     -- self.righScore.text = ""
--     -- self.rightText.text = ""
-- end
