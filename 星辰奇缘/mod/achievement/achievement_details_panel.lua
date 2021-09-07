-- ----------------------------------------------------------
-- UI - 成就窗口 成就细节
-- ljh 20180821
-- ----------------------------------------------------------
AchievementDetailsPanel = AchievementDetailsPanel or BaseClass(BasePanel)

function AchievementDetailsPanel:__init(model)
	self.model = model
    self.name = "AchievementDetailsPanel"

    self.resList = {
        {file = AssetConfig.achievementdetailspanel, type = AssetType.Main}
    }

    self.gameObject = nil
    self.transform = nil

	------------------------------------------------
end


function AchievementDetailsPanel:__delete()
    self.is_open = false

    self:AssetClearAll()
end

function AchievementDetailsPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.achievementdetailspanel))
    self.gameObject.name = "AchievementDetailsPanel"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    self.transform:FindChild("Panel"):GetComponent(Button).onClick:AddListener(function() self.model:CloseAchievementDetailsPanel() end)

    -- self.closeBtn = self.transform:FindChild("Main/CloseButton"):GetComponent(Button)
    -- self.closeBtn.onClick:AddListener(function() self.model:CloseAchievementDetailsPanel() end)

    self.detailsText = self.transform:FindChild("Main/DetailsText/Text"):GetComponent(Text)

    self.is_open = true

    if self.openArgs ~= nil then
        self:Update(self.openArgs)
    end
end

function AchievementDetailsPanel:Update(data)
    self.transform:FindChild("Main/Text"):GetComponent(Text).text = string.format("<color='#F7FFB7'>%s</color>", data.desc)
    local detailsString = ""
    local data_details = DataAchievement.data_details[data.id]

    if data_details == nil then
        self.model:CloseAchievementDetailsPanel()
        Log.Error(string.format("获取成就详情时出错，id = %s, desc = %s", data.id, data.desc))
        return
    end
    
    for index, data_details_progress in ipairs(data_details.progress) do
        local mark = false

        if data_details.target_from_ohter == 0 then
            for _,data_progress in ipairs(data.progress) do
                if data_progress.target == data_details_progress.target and data_progress.finish > 0 then
                    mark = true
                    break
                end
            end
        else
            local achievementData = self.model.achievementList[data_details_progress.target]
            if achievementData ~= nil and achievementData.finish > 0 then
                mark = true
            end
        end

        if mark then
            detailsString = string.format("%s<color='#31F670'>%s</color>", detailsString, data_details_progress.target_name)
        else
            detailsString = string.format("%s<color='#e0e0e0'>%s</color>", detailsString, data_details_progress.target_name)
        end

        if index ~= #data_details.progress then
            detailsString = string.format("%s  ", detailsString)
        end
    end
    self.detailsText.text = detailsString

    -- print(self.detailsText.preferredHeight)
    -- self.detailsText.text = "这是一行文字\n这是一行文字\n这是一行文字\n这是一行文字"
    -- print(self.detailsText.preferredHeight)

    -- print(self.transform:FindChild("Main/DetailsText"):GetComponent(RectTransform).sizeDelta)

    if self.detailsText.preferredHeight > 52 then
        self.transform:FindChild("Main/DetailsText"):GetComponent(RectTransform).sizeDelta = Vector2(270, 60 + self.detailsText.preferredHeight - 52)
        self.transform:FindChild("Main"):GetComponent(RectTransform).sizeDelta = Vector2(380, 215 + self.detailsText.preferredHeight - 52)
    end
end