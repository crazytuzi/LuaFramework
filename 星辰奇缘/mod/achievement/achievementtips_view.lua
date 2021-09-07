-- ----------------------------------------------------------
-- UI - 成就窗口 主窗口
-- ----------------------------------------------------------
AchievementTips = AchievementTips or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function AchievementTips:__init(model)
	self.model = model
    self.name = "AchievementTips"
    self.windowId = WindowConfig.WinID.newAchievement

    self.resList = {
        {file = AssetConfig.achievementtips, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

    self.mainTransform = nil
	self.subTransform = nil
	------------------------------------------------
end


function AchievementTips:__delete()
    self.is_open = false
    if self.gameObject ~=  nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject  =  nil
    end

    self:AssetClearAll()
end

function AchievementTips:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementtips))
    self.gameObject.name = "AchievementTips"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseAchievementTips() end)

    self.mainTransform = self.transform:FindChild("Main")
    self.subTransform = self.transform:FindChild("Sub")

    self.is_open = true

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self:update(self.openArgs[1])
    end

    self.transform:SetAsLastSibling()

    LuaTimer.Add(100, function() self.transform:SetAsLastSibling() end)
end

function AchievementTips:update(data)
    local achievementData = BaseUtils.copytab(DataAchievement.data_list[data.achievement_id])

    if achievementData ~= nil then
        achievementData.role_name = data.achievement_role_name
        achievementData.progress = data.progress
        achievementData.progress_max = data.progress_max
        achievementData.finish_time = data.time

        local myData = self.model.achievementList[data.achievement_id]

        local roleData = RoleManager.Instance.RoleData
    	if roleData.id == data.achievement_rid and roleData.platform == data.achievement_platform and roleData.zone_id == data.achievement_zoneId then
            self:update_main(myData)
    	else
    		self.mainTransform.localPosition = Vector3(92, 0, 0)
    		self.subTransform.gameObject:SetActive(true)
    		if myData == nil then
                -- self.mainTransform.gameObject:SetActive(false)
                myData = BaseUtils.copytab(DataAchievement.data_list[data.achievement_id])
                if myData ~= nil then
                    myData.finish = 0
                    myData.end_time = 0
                    myData.finish_time = 0
                    myData.progress = { id = 0
                                    , finish = 0
                                    , target = 0
                                    , target_val = 0
                                    , value = 0}
                    self:update_main(myData)
                end
            else
                self:update_main(myData)
            end
    		self:update_sub(achievementData)

            self.mainTransform:FindChild("ShareButton").gameObject:SetActive(true)
            if myData.finish == 0 then
                self.mainTransform:FindChild("ShareButton/Text"):GetComponent(Text).text = TI18N("尚未达成")
                self.mainTransform:FindChild("ShareButton"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton4")
            end
            local btn = self.mainTransform:FindChild("ShareButton"):GetComponent(Button)
            btn.onClick:RemoveAllListeners()
            btn.onClick:AddListener(function() self:ShareButtonClick(myData.id) end)
            self.mainTransform:FindChild("TimeText2"):GetComponent(Text).text = ""
    	end
    end
end

function AchievementTips:update_main(data)
	self.mainTransform:FindChild("NameText"):GetComponent(Text).text = data.name
    self.mainTransform:FindChild("DescText"):GetComponent(Text).text = data.desc

    local timeText = TI18N("正在为达成该成就而努力")
	if data.finish_time ~= 0 then
		local year = os.date("%y", data.finish_time)
		local month = os.date("%m", data.finish_time)
		local day = os.date("%d", data.finish_time)
		timeText = string.format(TI18N("我在%s年%s月%s日达成该成就"), year, month, day)
	end
    self.mainTransform:FindChild("TimeText"):GetComponent(Text).text = timeText

	local star = data.star
    if data.finish ~= 1 and data.finish ~= 2 then
        star = star - 1
    end
    if star == 10 then star = 3 end -- 填10星的显示为3星
    if star == 9 then star = 0 end -- 填10星且未完成的显示为0星
    if star == 0 then
        self.mainTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(false)
        self.mainTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
        self.mainTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 1 then
        self.mainTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        self.mainTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
        self.mainTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 2 then
        self.mainTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        self.mainTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
        self.mainTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 3 then
        self.mainTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        self.mainTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
        self.mainTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(true)
    end

    local achievementCompleteData = self.model.achievementCompleteNumber[data.id]
    if achievementCompleteData == nil then
        achievementCompleteData = { finish = 0 }
    end

    local achievementData = self.model.allAchievementList[data.id]
    local num = math.floor(achievementCompleteData.finish / self.model.achievementCompleteTotalNumber * 100)
    if num == 0 and achievementCompleteData.finish > 0 then num = 1 end

    self.mainTransform:FindChild("TimeText2"):GetComponent(Text).text = string.format(TI18N("本服获得<color='#ffff00'>%s</color>的人数比例为<color='#ffff00'>%s%%</color>"), data.name, num)
end

function AchievementTips:update_sub(data)
	self.subTransform:FindChild("NameText"):GetComponent(Text).text = data.name
    self.subTransform:FindChild("DescText"):GetComponent(Text).text = data.desc

    local timeText = string.format(TI18N("%s正在为达成该成就而努力"), data.role_name)
	if data.finish_time ~= 0 then
		local year = os.date("%y", data.finish_time)
		local month = os.date("%m", data.finish_time)
		local day = os.date("%d", data.finish_time)
		timeText = string.format(TI18N("%s在%s年%s月%s日达成该成就"), data.role_name, year, month, day)
	end
    self.subTransform:FindChild("TimeText"):GetComponent(Text).text = timeText

	local star = data.star
    if data.progress < data.progress_max then
        star = star - 1
    end
    if star == 10 then star = 3 end -- 填10星的显示为3星
    if star == 9 then star = 0 end -- 填10星且未完成的显示为0星
    if star == 0 then
        self.subTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(false)
        self.subTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
        self.subTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 1 then
        self.subTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        self.subTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(false)
        self.subTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 2 then
        self.subTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        self.subTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
        self.subTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(false)
    elseif star == 3 then
        self.subTransform:FindChild("StarPanel/Star1/Image").gameObject:SetActive(true)
        self.subTransform:FindChild("StarPanel/Star2/Image").gameObject:SetActive(true)
        self.subTransform:FindChild("StarPanel/Star3/Image").gameObject:SetActive(true)
    end
    
    local achievementCompleteData = self.model.achievementCompleteNumber[data.id]
    if achievementCompleteData == nil then
        achievementCompleteData = { finish = 0 }
    end

    local achievementData = self.model.allAchievementList[data.id]
    local num = math.floor(achievementCompleteData.finish / self.model.achievementCompleteTotalNumber * 100)
    if num == 0 and achievementCompleteData.finish > 0 then num = 1 end

    self.subTransform:FindChild("TimeText2"):GetComponent(Text).text = string.format(TI18N("本服获得<color='#ffff00'>%s</color>的人数比例为<color='#ffff00'>%s%%</color>"), data.name, num)
end

function AchievementTips:ShareButtonClick(id)
    local data = self.model.achievementList[id]
    if data == nil then return end

    if data.finish == 1 or data.finish == 2 then
        local btns = {{label = TI18N("分享好友"), callback = function() self:ShareToFriend(data) end}
                    , {label = TI18N("世界频道"), callback = function() self:ShareToWorld(data) end}
                    , {label = TI18N("公会频道"), callback = function() self:ShareToGuild(data) end}}
        TipsManager.Instance:ShowButton({gameObject = self.mainTransform:FindChild("ShareButton").gameObject, data = btns})
    else
        data = self.model:getMaxStarAndFinishInGroup(data.group_id)
        if data ~= nil then
            local btns = {{label = TI18N("分享好友"), callback = function() self:ShareToFriend(data) end}
                    , {label = TI18N("世界频道"), callback = function() self:ShareToWorld(data) end}
                    , {label = TI18N("公会频道"), callback = function() self:ShareToGuild(data) end}}
            TipsManager.Instance:ShowButton({gameObject = self.mainTransform:FindChild("ShareButton").gameObject, data = btns})
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("请达成后再分享吧{face_1,9}"))
        end
    end
end

function AchievementTips:ShareToFriend(data)
    local callBack = function(_, friendData) self.model:ShareAchievement(MsgEumn.ExtPanelType.Friend, friendData, data.id) NoticeManager.Instance:FloatTipsByString(TI18N("分享成功")) end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, { callBack })
end

function AchievementTips:ShareToWorld(data)
    -- local data = self.model.achievementList[tonumber(cellObject.name)]
    -- if data == nil then return end

    self.model:ShareAchievement(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.World, data.id)
end

function AchievementTips:ShareToGuild(data)
    -- local data = self.model.achievementList[tonumber(cellObject.name)]
    -- if data == nil then return end

    if GuildManager.Instance.model:check_has_join_guild() then
        self.model:ShareAchievement(MsgEumn.ExtPanelType.Chat, MsgEumn.ChatChannel.Guild, data.id)
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
end
