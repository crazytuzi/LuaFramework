-- ----------------------------
-- 春节活动-- 猴王闹春节
-- hosr
-- ----------------------------
MonkeyCome = MonkeyCome or BaseClass(BasePanel)

function MonkeyCome:__init(main)
    self.main = main
    self.path = "prefabs/ui/springfestival/monkeycome.unity3d"
    self.resList = {
        {file = self.path, type = AssetType.Main},
        {file = AssetConfig.springfestival_texture, type = AssetType.Dep},
    }
    self.type = SpringFestivalEumn.Type.MonkeyCome
    self.index = 1
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnOpenEvent:Add(function() self:OnShow() end)

    self.npcId = 45
    self.npcBaseId = 76000
    self.npcBase = nil
end

function MonkeyCome:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
end

function MonkeyCome:InitPanel()
    self.npcBase = DataUnit.data_unit[self.npcBaseId]

    self.gameObject = GameObject.Instantiate(self:GetPrefab(self.path))
    self.gameObject.name = "MonkeyCome"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.main.rightTransform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.timeTxt = self.transform:Find("Time"):GetComponent(Text)
    self.contextTxt = self.transform:Find("Content"):GetComponent(Text)
    self.descTxt = self.transform:Find("Desc"):GetComponent(Text)
    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.txt1 = self.transform:Find("Txt1"):GetComponent(Text)
    self.txt2 = self.transform:Find("Txt2"):GetComponent(Text)

    self.timeTxt.text = ""
    self.contextTxt.text = ""
    if self.npcBase ~= nil then
        self.descTxt.text = string.format(TI18N("注:寻找<color='#ffff00'>%s</color>可查看玩法详情"), self.npcBase.name)
    else
        self.descTxt.text = TI18N("注:寻找<color='#ffff00'>齐天大圣</color>可查看玩法详情")
    end
    self.txt1.text = TI18N("活动时间:")
    self.txt2.text = TI18N("活动内容:")
    self.button.onClick:AddListener(function() self:ClickButton() end)

    self:OnShow()
end

function MonkeyCome:OnShow()
    self.campaignData = self.main:GetCampaignData(self.type)[1]

    self.contextTxt.text = self.campaignData.cond_desc
    self:ShowTime()
end

function MonkeyCome:ShowTime()
    local start = self.campaignData.cli_start_time[1]
    local over = self.campaignData.cli_end_time[1]
    local str = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"), start[1], start[2], start[3], over[1], over[2], over[3])
    self.timeTxt.text = str
end

function MonkeyCome:OnHide()
end

function MonkeyCome:ClickButton()
    local key = BaseUtils.get_unique_npcid(self.npcId, 1)
    QuestManager.Instance.model:FindNpc(key)
    WindowManager.Instance:CloseWindowById(WindowConfig.WinID.biblemain)
end
