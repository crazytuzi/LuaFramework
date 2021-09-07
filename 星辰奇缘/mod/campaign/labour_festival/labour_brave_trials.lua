LabourBraveTrials = LabourBraveTrials or BaseClass(BasePanel)

function LabourBraveTrials:__init(model, parent, data, icon)
    self.model = model
    self.parent = parent
    self.data = data
    self.icon = data.sprite
    self.labourModel = CampaignManager.Instance.labourModel

    self.resList = {
        {file = AssetConfig.labour_brave_trials, type = AssetType.Main}
        -- , {file = AssetConfig.springfestival_texture, type = AssetType.Dep}
    }

    self.campaignName = nil
    self.descMsg = nil
    self.campaignId = nil
    self.openTime = ""
    self.endTime = ""

    local baseCampaignData = DataCampaign.data_list
    for k,v in pairs(data.datalist) do
        self.campaignId = v.id
        if v.id ~= nil then
            local basedata = baseCampaignData[v.id]
            self.campaignName = basedata.name
            self.descMsg = basedata.cond_desc
            self.openTime = string.format(TI18N("%s年%s月%s日"), tostring(basedata.cli_start_time[1][1]), tostring(basedata.cli_start_time[1][2]), tostring(basedata.cli_start_time[1][3]))
            self.endTime = string.format(TI18N("%s年%s月%s日"), tostring(basedata.cli_end_time[1][1]), tostring(basedata.cli_end_time[1][2]), tostring(basedata.cli_end_time[1][3]))
            break
        end
    end

    self.name = "LabourForeignTrials"
    if self.campaignId == 80 then
        self.name = "LabourBraveMonkey"
    end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function LabourBraveTrials:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function LabourBraveTrials:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.labour_brave_trials))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(self.parent, self.gameObject)
    local t = self.gameObject.transform
    self.transform = t

    self.nameText = t:Find("Bg/Title/Text"):GetComponent(Text)
    self.iconImage = t:Find("Bg/Title/Icon"):GetComponent(Image)
    self.descText = t:Find("Content"):GetComponent(Text)
    self.findPathBtn = t:Find("Button"):GetComponent(Button)
    self.timeText = t:Find("Time"):GetComponent(Text)

    self.nameText.text = self.campaignName
    self.descText.text = self.descMsg
    self.iconImage.gameObject:SetActive(self.icon ~= nil)
    if self.icon ~= nil then
        self.iconImage.sprite = self.icon
    end
    self.timeText.text = TI18N("活动时间:")..self.openTime.."-"..self.endTime

    if self.campaignId == 80 then
        self.findPathBtn.onClick:AddListener(function() self.labourModel:OnTrackMonkeyNpc() self.model:CloseWindow() end)
    else
        self.findPathBtn.onClick:AddListener(function() self.labourModel:OnTrackTrialsNpc() self.model:CloseWindow() end)
    end
end

function LabourBraveTrials:OnOpen()
end

function LabourBraveTrials:OnHide()
end

function LabourBraveTrials:OnInitCompleted()
    self.OnOpenEvent:Fire()
end


