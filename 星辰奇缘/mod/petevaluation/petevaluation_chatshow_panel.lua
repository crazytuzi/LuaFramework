PetEvaluationChatShowPanel = PetEvaluationChatShowPanel or BaseClass(BasePanel)


function PetEvaluationChatShowPanel:__init(mainWindow,type,otherOption)
    self.mainWindow = mainWindow
    self.otherOption = otherOption
    -- otherOption用于简单的表情接入，{parent 依附界面lua对象，sendcallback 发送回调}

    self.resList = {
       {file = AssetConfig.petevalution_chashow_panel,type = AssetType.Main}
      ,{file = AssetConfig.guard_head, type = AssetType.Dep}
      ,{file = AssetConfig.childhead,type = AssetType.Dep}
      ,{file = AssetConfig.face_textures, type = AssetType.Dep}
    }

    self.type = MsgEumn.ExtPanelType.PetEvaluation or type
    self.toggleObjTab = {}
    self.toggleTab = {}
    self.initShowTabIndex = 1

     self.OnOpenEvent:Add(function() self:OnOpen() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
end

function PetEvaluationChatShowPanel:__delete()

	 if self.face ~= nil then
        self.face:DeleteMe()
        self.face = nil
    end

     if self.pet ~= nil then
        self.pet:DeleteMe()
        self.pet = nil
    end

    if self.guard ~= nil then
    	self.guard:DeleteMe()
    	self.guard = nil
    end

    if self.gameObject ~= nil then
    	GameObject.DestroyImmediate(self.gameObject)
    	self.gameObject = nil
    end
    self:AssetClearAll()
end

function PetEvaluationChatShowPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.petevalution_chashow_panel))
	UIUtils.AddUIChild(ctx.CanvasContainer,self.gameObject)
	self.gameObject.name = "PetEvaluationChatShowPanel"
	self.transform = self.gameObject.transform

    self.transform.parent = self.mainWindow.transform

	self:InitToggle()


	local left = self.transform:Find("MainCon/LeftCon")
	self.petBtn = left:Find("btnPet")
	self.guardBtn = left:Find("btnGuard")


    local right = self.transform:Find("MainCon/RightCon")
    self.face = ChatExtFace.New(right:Find("FaceCon").gameObject, self.type, self.otherOption,false)
    self.pet = PetEvaluationChatExtPet.New(right:Find("PetCon").gameObject, self.type, self.otherOption)
    self.guard = PetEvaluationChatExtGuard.New(right:Find("GuardCon").gameObject, self.type,self.otherOption)

    self.face.mainPanel = self
    self.pet.mainPanel = self
    self.guard.mainPanel = self

    self.tab = {self.face,self.pet,self.guard}
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Hiden() end)
    self.tabGroup = TabGroup.New(self.transform:Find("MainCon/LeftCon").gameObject,function(index) self:ChangeTab(index) end)

    self:SetStatus()

end

function PetEvaluationChatShowPanel:SetStatus()
	if self.openArgs ~= nil then
		if self.openArgs[1] == EvaluationTypeEumn.Type.Pet then
            self.pet:SetList(self.openArgs[2])
			self.petBtn.gameObject:SetActive(true)
			self.guardBtn.gameObject:SetActive(false)
		elseif self.openArgs[1] == EvaluationTypeEumn.Type.ShouHu then
			self.guard:SetList(self.openArgs[2])
			self.guardBtn.gameObject:SetActive(true)
			self.petBtn.gameObject:SetActive(false)
		end
	end
end

function PetEvaluationChatShowPanel:InitToggle()
	local toggle = self.transform:Find("MainCon/RightCon/ToggleGroup")
	local len = toggle.childCount
	for i = 1,len do
		local obj = toggle:GetChild(i-1).gameObject
		obj:GetComponent(RectTransform).anchoredPosition = Vector2((i-1) * 20,0)
        obj:SetActive(true)
        table.insert(self.toggleObjTab,obj)
        table.insert(self.toggleTab,obj:GetComponent(Toggle))
    end
end


function PetEvaluationChatShowPanel:UpdateToggleShow(count)
    for i, v in ipairs(self.toggleObjTab) do
        if i > count then
            v:SetActive(false)
            if self.toggleTab[i] ~= nil then
                self.toggleTab[i].isOn = false
            end
        else
            v:SetActive(true)
        end
    end
end

function PetEvaluationChatShowPanel:ChangeTab(index)
	if self.currentTab ~= nil and self.currentTab.index ~= index then
		self.currentTab:Hiden()
	end
	self.currentTab = self.tab[index]
	self.currentTab:Show()
end

-- 更新选中
function PetEvaluationChatShowPanel:UpdateToggleIndex(index)
    if self.toggleTab[index] ~= nil then
        self.toggleTab[index].isOn = true
    end
end


function PetEvaluationChatShowPanel:OnHide()
	ChatManager.Instance:ResetElementCount()
     if self.face ~= nil then
        self.face:Hiden()
    end

     if self.pet ~= nil then
        self.pet:Hiden()
    end

    if self.guard ~= nil then
        self.guard:Hiden()
    end
end

function PetEvaluationChatShowPanel:OnOpen()
    self:SetStatus()

	if self.initShowTabIndex ~=nil then
		self.tabGroup:ChangeTab(self.initShowTabIndex)
        self:ChangeTab(self.initShowTabIndex)
	end
end


