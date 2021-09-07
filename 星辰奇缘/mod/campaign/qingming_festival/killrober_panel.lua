-- 清明植树面板
KillRoberPanel = KillRoberPanel or BaseClass(BasePanel)

function KillRoberPanel:__init(main)
    self.main = main
    self.name = "KillRoberPanel"

    self.resList = {
        {file = AssetConfig.killrober_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.type = SpringFestivalEumn.Type.KillRober
    self.data = nil
end

function KillRoberPanel:OnInitCompleted()

end

function KillRoberPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function KillRoberPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.killrober_panel))
    UIUtils.AddUIChild(self.main.rightContainer, self.gameObject)
    self.gameObject.name = "KillRoberPanel"
    self.transform = self.gameObject.transform
    self.data = self.main:GetCampaignData(self.type)
    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnBtn() end)

    self.transform:Find("Content"):GetComponent(Text).text = self.data[1].cond_desc
    self.transform:Find("Time"):GetComponent(Text).text = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"),
        self.data[1].cli_start_time[1][1],
        self.data[1].cli_start_time[1][2],
        self.data[1].cli_start_time[1][3],
        self.data[1].cli_end_time[1][1],
        self.data[1].cli_end_time[1][2],
        self.data[1].cli_end_time[1][3]
         )
end
