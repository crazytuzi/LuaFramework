-- 踏青祈福
PlantsSpritePanel = PlantsSpritePanel or BaseClass(BasePanel)

function PlantsSpritePanel:__init(main)
    self.main = main
    self.name = "PlantsSpritePanel"

    self.resList = {
        {file = AssetConfig.plantssprite_panel, type = AssetType.Main}
        ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.type = SpringFestivalEumn.Type.PlantsSprite
    self.data = nil
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)

end


function PlantsSpritePanel:OnOpen()
    self.data = DataCampaign.data_list[self.campId]
    self:ReLoad()
end

function PlantsSpritePanel:ReLoad()

    self.contentTxt.text = self.data.cond_desc
    self.transform:Find("Time"):GetComponent(Text).text = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"),
    self.data.cli_start_time[1][1],
    self.data.cli_start_time[1][2],
    self.data.cli_start_time[1][3],
    self.data.cli_end_time[1][1],
    self.data.cli_end_time[1][2],
    self.data.cli_end_time[1][3]
         )
    self.transform:Find("Bg/Title/Text"):GetComponent(Text).text = self.data.reward_title
end




function PlantsSpritePanel:OnInitCompleted()

end

function PlantsSpritePanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
end

function PlantsSpritePanel:InitPanel()

    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.plantssprite_panel))
    UIUtils.AddUIChild(self.main, self.gameObject)
    self.gameObject.name = "PlantsSpritePanel"
    self.transform = self.gameObject.transform

    self.button = self.transform:Find("Button"):GetComponent(Button)
    self.button.onClick:AddListener(function() self:OnBtn() end)
    self.timeTxt = self.transform:Find("Time"):GetComponent(Text)
    self.contentTxt = self.transform:Find("Content"):GetComponent(Text)

end

function PlantsSpritePanel:OnBtn()
    BibleManager.Instance.model:CloseWindow()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    SceneManager.Instance.sceneElementsModel:Self_PathToTarget(self.target)
end