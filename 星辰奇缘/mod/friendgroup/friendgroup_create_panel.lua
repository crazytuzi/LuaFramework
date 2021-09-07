--作者:hzf
--17-2-23 下07时36分04秒
--功能:群组创建

FriendGroupCreatePanel = FriendGroupCreatePanel or BaseClass(BasePanel)
function FriendGroupCreatePanel:__init(model)
	self.model = model
	self.groupMgr = FriendGroupManager.Instance
	self.resList = {
		{file = AssetConfig.groupcreatepanel, type = AssetType.Main}
	}
	--self.OnOpenEvent:Add(function() self:OnOpen() end)
	--self.OnHideEvent:Add(function() self:OnHide() end)
	self.hasInit = false
end

function FriendGroupCreatePanel:__delete()
	if self.RemainEXT ~= nil then
		self.RemainEXT:DeleteMe()
		self.RemainEXT = nil
	end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function FriendGroupCreatePanel:OnHide()

end

function FriendGroupCreatePanel:OnOpen()

end

function FriendGroupCreatePanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.groupcreatepanel))
	self.gameObject.name = "FriendGroupCreatePanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas.gameObject, self.gameObject)
	self.transform:SetAsFirstSibling()

	self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseCreatePanel()
	end)
	self.MainCon = self.transform:Find("MainCon")
	self.bg = self.transform:Find("MainCon/bg")
	self.Title = self.transform:Find("MainCon/Title")
	self.transform:Find("MainCon/CancelButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseCreatePanel()
	end)
	self.OkButton = self.transform:Find("MainCon/OkButton"):GetComponent(Button)
	self.OkButton.onClick:AddListener(function()
		self:OnOk()
	end)

	self.NameInputField = self.transform:Find("MainCon/NameInputField"):GetComponent(InputField)
    local ipf = self.NameInputField
    local textcom = self.NameInputField.transform:Find("Text"):GetComponent(Text)
    local placeholder = self.NameInputField.transform:Find("Placeholder"):GetComponent(Text)
    ipf.textComponent = textcom
    ipf.placeholder = placeholder
	self.NameInputField.characterLimit = 50

	-- self.NameInputField = self.transform:Find("MainCon/NameInputField")
	self.RemainText = self.transform:Find("MainCon/RemainText"):GetComponent(Text)
	self.RemainEXT = MsgItemExt.New(self.RemainText, 279.9, 17, 19)
	self.TipsButton = self.transform:Find("MainCon/TipsButton"):GetComponent(Button)
	self.TipsButton.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.TipsButton.gameObject, itemData = {
            TI18N("1.玩家等级达到<color='#00ff00'>60</color>且等级≥<color='#00ff00>世界等级-10</color>可创建群组"),
            TI18N("2.一个群组最多可<color='#ffff00'>容纳10人</color>"),
            TI18N("3.玩家最多可加入<color='#00ff00'>3个</color>其他玩家创建的群组"),
            TI18N("4.解散群组后再次创建需要重新<color='#ffff00'>消耗</color>货币"),
            }})
        end)
	self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function()
		self.model:CloseCreatePanel()
	end)
	local freenum, nextdata = FriendGroupManager.Instance:CheckCreate()
	if FriendGroupManager.Instance.data19001 ~= nil then
		local costData = DataFriendGroup.data_get[FriendGroupManager.Instance.data19001.create + 1].cost
		self.RemainEXT:SetData(string.format(TI18N("花费{assets_1,%s,%s}可创建"), tostring(costData[1][1]), tostring(costData[1][2])))
		-- self.RemainText.text = string.format("当前剩余可免费创建群组：%s", tostring(freenum))
	else
		local costData = DataFriendGroup.data_get[1].cost
		self.RemainEXT:SetData(string.format(TI18N("花费{assets_1,%s,%s}可创建"), tostring(costData[1][1]), tostring(costData[1][2])))
	end
end

function FriendGroupCreatePanel:OnOk()
	if self.NameInputField.text ~= "" then
		if string.utf8len(self.NameInputField.text) > 6 then
			NoticeManager.Instance:FloatTipsByString(TI18N("群组名最多6个字"))
		else
			if FriendGroupManager.Instance.data19001 ~= nil then
				local costData = DataFriendGroup.data_get[FriendGroupManager.Instance.data19001.create + 1].cost
				local data = NoticeConfirmData.New()
			    data.type = ConfirmData.Style.Normal
			    data.content = string.format(TI18N("是否要花费{assets_1,%s,%s}创建群组？"), tostring(costData[1][1]), tostring(costData[1][2]))
			    data.sureLabel = TI18N("确定")
			    data.cancelLabel = TI18N("取消")
			    data.sureCallback = function()
						self.groupMgr:Require19002(self.NameInputField.text)
			        end
			    NoticeManager.Instance:ConfirmTips(data)
			else
				local costData = DataFriendGroup.data_get[1].cost
				local data = NoticeConfirmData.New()
			    data.type = ConfirmData.Style.Normal
			    data.content = string.format(TI18N("是否要花费{assets_1,%s,%s}创建群组？"), tostring(costData[1][1]), tostring(costData[1][2]))
			    data.sureLabel = TI18N("确定")
			    data.cancelLabel = TI18N("取消")
			    data.sureCallback = function()
						self.groupMgr:Require19002(self.NameInputField.text)
			        end
			    NoticeManager.Instance:ConfirmTips(data)
			end
		end
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("请输入您要创建的群组名字"))
	end
end