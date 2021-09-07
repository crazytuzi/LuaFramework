-- 公告
-- @author zgs
UpdateNoticePanel = UpdateNoticePanel or BaseClass(BasePanel)

function UpdateNoticePanel:__init(model,parent)
    self.model = model
    self.parent = parent
    self.name = "UpdateNoticePanel"

    self.resList = {
        {file = AssetConfig.update_notice, type = AssetType.Main}
        --,{file  =  AssetConfig.FashionBg, type  =  AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function()
        self:UpdatePanel()
    end)
end

function UpdateNoticePanel:OnInitCompleted()
    self:UpdatePanel()
end

function UpdateNoticePanel:__delete()
    GameObject.DestroyImmediate(self.gameObject)
    self:AssetClearAll()
    self.gameObject = nil
    self.model = nil
end

function UpdateNoticePanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.update_notice))
	UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = self.gameObject.transform

    self.gridTran = self.transform:Find("Content/Grid"):GetComponent(RectTransform)
    self.textContent = self.transform:Find("Content/Grid/Text"):GetComponent(Text)

    self.noneNotice = self.transform:Find("NoneImage").gameObject
    self.noneNotice:SetActive(false)
end

function UpdateNoticePanel:UpdatePanel()
    -- local msg = {}
    -- for i,v in ipairs(self.model.boardList) do
    --     table.insert(msg,v.msg)
    -- end
    -- self.textContent.text = table.concat( msg, "\n")

    if #self.model.boardList > 0 then
        self.textContent.text = self.model.boardList[1].msg
        self.noneNotice:SetActive(false)
        AnnounceManager.Instance:send9923(self.model.boardList[1].id)
    else
        self.textContent.text = ""
        self.noneNotice:SetActive(true)
    end
    self.gridTran.sizeDelta = Vector2(self.gridTran.sizeDelta.x, self.textContent.preferredHeight)
end



