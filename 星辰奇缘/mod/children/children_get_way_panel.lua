--作者:hzf
--01/05/2017 19:41:07
--功能:子女获取方式

ChildrenGetWayPanel = ChildrenGetWayPanel or BaseClass(BasePanel)
function ChildrenGetWayPanel:__init(parent)
	self.parent = parent
	self.resList = {
		{file = AssetConfig.childrengetwaypanel, type = AssetType.Main},
		{file = AssetConfig.childrentextures, type = AssetType.Dep}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
end

function ChildrenGetWayPanel:__delete()
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function ChildrenGetWayPanel:OnHide()

end

function ChildrenGetWayPanel:OnOpen()

end

function ChildrenGetWayPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.childrengetwaypanel))
	self.gameObject.name = "ChildrenGetWayPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.Tips = self.transform:Find("Tips")
	self.Title = self.transform:Find("Tips/Title")
	self.Text = self.transform:Find("Tips/Title/Text"):GetComponent(Text)
	self.descText = self.transform:Find("Tips/descText"):GetComponent(Text)
	self.LButton = self.transform:Find("Tips/LButton"):GetComponent(Button)
	self.LButton.onClick:AddListener(function()
		self:OnLeft()
	end)
	self.Text = self.transform:Find("Tips/LButton/Text"):GetComponent(Text)
	self.RButton = self.transform:Find("Tips/RButton"):GetComponent(Button)
	self.RButton.onClick:AddListener(function()
		self:OnRight()
	end)
	self.Text = self.transform:Find("Tips/RButton/Text"):GetComponent(Text)
	self.LdescText = self.transform:Find("Tips/LdescText"):GetComponent(Text)
	self.RdescText = self.transform:Find("Tips/RdescText"):GetComponent(Text)
	self.RdescText.text = TI18N("消耗<color='#248813'>300活力</color>领取<color='#248813'>天地灵种</color>孕育任务")
	self.CloseButton = self.transform:Find("CloseButton"):GetComponent(Button)
	self.CloseButton.onClick:AddListener(function()
		ChildrenManager.Instance.model:CloseGetWayPanel()
	end)
	self:InitStatus()
end

function ChildrenGetWayPanel:InitStatus()
	BaseUtils.dump(MarryManager.Instance.loverData, "伴侣信息")
	if MarryManager.Instance.loverData ~= nil and MarryManager.Instance.loverData.status == 3 and (QuestManager.Instance.childPlantData == nil or QuestManager.Instance.childPlantData.unit_id == 0) then
		self.LButton.transform.anchoredPosition = Vector2(0, 38.7)
		self.LdescText.transform.anchoredPosition = Vector2(0, -52.2)
		self.RButton.gameObject:SetActive(false)
		self.RdescText.gameObject:SetActive(false)
		self.LButton.gameObject:SetActive(true)
		self.LdescText.gameObject:SetActive(true)
		self.transform:Find("Tips/OKButton"):GetComponent(Button).onClick:AddListener(function() self:OnLeft() end)
	else
		self.RButton.transform.anchoredPosition = Vector2(0, 38.7)
		self.RdescText.transform.anchoredPosition = Vector2(0, -52.2)
		self.LButton.gameObject:SetActive(false)
		self.LdescText.gameObject:SetActive(false)
		self.RButton.gameObject:SetActive(true)
		self.RdescText.gameObject:SetActive(true)
		self.transform:Find("Tips/OKButton"):GetComponent(Button).onClick:AddListener(function() self:OnRight() end)
		self.transform:Find("Tips/OKButton/Text"):GetComponent(Text).text = TI18N("领取任务")

	end
end

function ChildrenGetWayPanel:OnLeft()
	if TeamManager.Instance:HasTeam() then
		local uniqueroleid = BaseUtils.get_unique_roleid(RoleManager.Instance.RoleData.lover_id, RoleManager.Instance.RoleData.lover_zone_id, RoleManager.Instance.RoleData.lover_platform)
		-- print(uniqueroleid)
		-- BaseUtils.dump(TeamManager.Instance:GetMemberOrderList())
        if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
			if TeamManager.Instance:MemberCount() > 2 then
				-- 队伍有第三者
				NoticeManager.Instance:FloatTipsByString(TI18N("队伍中有第三者"))
			else
				local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.child)
	            if questData ~= nil then
	                QuestManager.Instance:DoQuest(questData)
	            else
	                QuestManager.Instance:Send10211(QuestEumn.TaskType.child)
	            end
				-- 开始
			end
		else
			NoticeManager.Instance:FloatTipsByString(TI18N("你的另一半不在队伍中"))
			-- 没伴侣
		end
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("请带上你的另一半"))
		--没组伴侣
	end
	ChildrenManager.Instance.model:CloseGetWayPanel()
end

function ChildrenGetWayPanel:OnRight()
	local questData = QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.child)
    if questData ~= nil then
        QuestManager.Instance:DoQuest(questData)
    else
        QuestManager.Instance:Send10211(QuestEumn.TaskType.child)
    end
	ChildrenManager.Instance.model:CloseGetWayPanel()
end