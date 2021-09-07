-- 草木妖王
PlantsSpriteKingPanel = PlantsSpriteKingPanel or BaseClass(BasePanel)

function PlantsSpriteKingPanel:__init(main)
    self.main = main
    self.name = "PlantsSpriteKingPanel"

    self.resList = {
        {file = AssetConfig.plantssprite_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.type = SpringFestivalEumn.Type.PlantsSpriteKing
    self.data = nil
end

function PlantsSpriteKingPanel:OnInitCompleted()

end

function PlantsSpriteKingPanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function PlantsSpriteKingPanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.plantssprite_panel))
    UIUtils.AddUIChild(self.main.rightContainer, self.gameObject)
    self.gameObject.name = "PlantsSpriteKingPanel"
    self.transform = self.gameObject.transform

    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnBtn() end)
    self.timeTxt = self.transform:Find("Time"):GetComponent(Text)
    self.contentTxt = self.transform:Find("Content"):GetComponent(Text)
    self.data = self.main:GetCampaignData(self.type)

    self.contentTxt.text = self.data[1].cond_desc
    self.transform:Find("Time"):GetComponent(Text).text = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"),
        self.data[1].cli_start_time[1][1],
        self.data[1].cli_start_time[1][2],
        self.data[1].cli_start_time[1][3],
        self.data[1].cli_end_time[1][1],
        self.data[1].cli_end_time[1][2],
        self.data[1].cli_end_time[1][3]
         )
    self.transform:Find("Bg/Title/Text"):GetComponent(Text).text = self.data[1].reward_title
end

function PlantsSpriteKingPanel:OnBtn()
    BibleManager.Instance.model:CloseWindow()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget("46_1")
end
