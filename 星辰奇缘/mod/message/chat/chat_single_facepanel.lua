SingleFacePanel = SingleFacePanel or BaseClass(BasePanel)

function SingleFacePanel:__init(ipf,parent)
    self.parent = parent
    self.name = "SingleFacePanel"

    self.resList = {
        {file = AssetConfig.chat_single_facepanel, type = AssetType.Main}
        -- ,{file  =  AssetConfig.dropicon, type  =  AssetType.Dep}
    }
    self.currInputField = ipf
    self:Show()
end


function SingleFacePanel:OnInitCompleted()

end

function SingleFacePanel:__delete()
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
    end
    self:AssetClearAll()
    self.parent:ResetPos()
end

function SingleFacePanel:InitPanel()
    self.talk_data = {}
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.chat_single_facepanel))
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
    self.gameObject.name = "SingleFacePanel"
    self.transform = self.gameObject.transform
    self.maincon = self.transform:Find("MainCon/RightCon/FaceCon").gameObject
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self.parent:ResetPos() self:Hiden() end)
    self.facepanel = ChatExtFaceSingle.New(self.maincon, self.currInputField)
    -- self.facepanel:Show()
end

function SingleFacePanel:SetInputField(ipf)
    self.currInputField = ipf
    self.facepanel.inputField = ipf
    self:Show()
end