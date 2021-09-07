-------------------------------------------------------
-- UI - 真心话大冒险 引导界面
------------------------------------------------------
TruthordareGuidePanel = TruthordareGuidePanel or BaseClass(BaseView)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function TruthordareGuidePanel:__init(parent)
    self.parent = parent
    self.name = "TruthordareGuidePanel"

    self.resList = {
        {file = AssetConfig.truthordareguidepanel, type = AssetType.Main}
        , {file = AssetConfig.truthordare_textures, type = AssetType.Dep}
        , {file = AssetConfig.TruthordareTI18NChoose1, type = AssetType.Dep}
        , {file = AssetConfig.TruthordareTI18NChoose2, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.transform = nil
    
    self.stepPanelList = {}
    self.currStep = 1

    --self.OnOpenEvent:Add(function() self:OnShow() end)
    --self.OnHideEvent:Add(function() self:OnHide() end)

    self:LoadAssetBundleBatch()
end

function TruthordareGuidePanel:__delete()
    self.isDelete = true
    self:SetActive(false)
    TruthordareManager.Instance.model.isBeenGuide = false
    if self.image_1 ~= nil then
        BaseUtils.ReleaseImage(self.image_1)
    end
    if self.image_2 ~= nil then
        BaseUtils.ReleaseImage(self.image_2)
    end

    if self.miniTweenId ~= nil then
        Tween.Instance:Cancel(self.miniTweenId)
        self.miniTweenId = nil
    end

    self:AssetClearAll()
end

function TruthordareGuidePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.truthordareguidepanel))
    self.gameObject.name = "TruthordareGuidePanel"
    self.transform = self.gameObject.transform
    
    self.transform:SetParent(self.parent.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero
    self.transform:GetComponent(RectTransform).anchoredPosition = Vector2(355, 15)

    --self.transform:Find("ExitButton"):GetComponent(Button).onClick:AddListener(function() self.parent:SetData(data) end)
    self.transform:Find("MiniButton"):GetComponent(Button).onClick:AddListener(function() self.parent:MiniPanel(true) end)
    
    for i = 1,3 do
        if self.stepPanelList[i] == nil then
            local panel = {}
            panel.go = self.transform:Find("PanelStep_"..i)
            panel.leftArea = panel.go:Find("LeftButton")
            panel.left = panel.go:Find("LeftButton"):GetComponent(Button)
            panel.left.onClick:AddListener(function() 
                self:SwitchPreOrNextPanel(-1)
            end)
            panel.rightArea = panel.go:Find("RightButton")
            panel.right = panel.go:Find("RightButton"):GetComponent(Button)
            panel.right.onClick:AddListener(function() 
                self:SwitchPreOrNextPanel(1)
            end)
            panel.centerArea = panel.go:Find("JoinButton")
            panel.center = panel.go:Find("JoinButton"):GetComponent(Button)
            panel.center.onClick:AddListener(function()
                --返回原来的界面
                self.parent:SetData(data)
            end)
            panel.downText = panel.go:Find("JoinText"):GetComponent(Text)
            self.stepPanelList[i] = panel
            if i == 1 then
                self.stepPanelList[i].go.gameObject:SetActive(true)
            else
                self.stepPanelList[i].go.gameObject:SetActive(false)
            end
        end
    end
    self:SetData(self.data)
    self:ClearMainAsset()
end

function TruthordareGuidePanel:MiniPanel(andCloseChatPanel)
    if self.miniTweenId == nil then
        self.miniTweenId = Tween.Instance:Scale(self.gameObject, Vector3.zero, 0.2, 
            function() 
                self.miniMark = true 
                self:SetActive(false) 
                self.miniTweenId = nil 
                if andCloseChatPanel then
                    if ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.transform) then
                        ChatManager.Instance.model.chatWindow:ClickShow()
                    end
                end
            end, LeanTweenType.easeOutQuart).id
    end
end

function TruthordareGuidePanel:SetData(data)
    self.data = data
    if BaseUtils.isnull(self.gameObject) then
        return
    end
    self:SetActive(true)
end

function TruthordareGuidePanel:SetActive(active)
    self.isActive = true
    if not BaseUtils.isnull(self.gameObject) then
        self.gameObject:SetActive(active)
        if active then
            TruthordareManager.Instance.model.isBeenGuide = true
            if self.stepPanelList[3] ~= nil then
                self.image_1 = self.stepPanelList[3].go:Find("Image1"):GetComponent(Image)
                self.image_1.sprite = self.assetWrapper:GetSprite(AssetConfig.TruthordareTI18NChoose2, "TruthordareTI18NChoose2")

                self.image_2 = self.stepPanelList[3].go:Find("Image2"):GetComponent(Image)
                self.image_2.sprite = self.assetWrapper:GetSprite(AssetConfig.TruthordareTI18NChoose1, "TruthordareTI18NChoose1")
            end
            if self.stepPanelList[1] ~= nil then
                local panel = self.stepPanelList[1]
                panel.leftArea.gameObject:SetActive(false)
                panel.centerArea.gameObject:SetActive(false)
                panel.rightArea.gameObject:SetActive(true)
            end
        else
            TruthordareManager.Instance.model.isBeenGuide = false
        end
    end
end

function TruthordareGuidePanel:SwitchPreOrNextPanel(dir)

    if self.currStep + dir > 0 and self.currStep + dir < 4 then
        self.currStep = self.currStep + dir
        local panel = self.stepPanelList[self.currStep]
        if self.currStep == 1 then
            panel.leftArea.gameObject:SetActive(false)
            panel.centerArea.gameObject:SetActive(false)
            panel.rightArea.gameObject:SetActive(true)
        elseif self.currStep == 2 then
            panel.leftArea.gameObject:SetActive(true)
            panel.centerArea.gameObject:SetActive(false)
            panel.rightArea.gameObject:SetActive(true)
        elseif self.currStep == 3 then
            panel.leftArea.gameObject:SetActive(true)
            panel.centerArea.gameObject:SetActive(true)
            panel.rightArea.gameObject:SetActive(false)
        end
    else
        if self.currStep == 1 then
            NoticeManager.Instance:FloatTipsByString("已经是第一页了")
        elseif self.currStep == 3 then
            NoticeManager.Instance:FloatTipsByString("已经是最后一页了")
        end
    end
    for i =1,#self.stepPanelList do
        if self.currStep == i then
            self.stepPanelList[i].go.gameObject:SetActive(true)
        else
            self.stepPanelList[i].go.gameObject:SetActive(false)
        end
    end
end