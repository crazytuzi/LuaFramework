--作者:hzf
--09/12/2016 21:18:54
--功能:冠军联赛追踪

MainuiTracePumpkinReady = MainuiTracePumpkinReady or BaseClass(BaseTracePanel)
function MainuiTracePumpkinReady:__init(parent)
	self.parent = parent
	self.name = "MainuiTracePumpkinReady"
	self.resList = {
		{file = AssetConfig.halloween_pumpkin_ready, type = AssetType.Main},
		{file = AssetConfig.halloween_textures, type = AssetType.Dep},
	}

	self.descString = TI18N("1.成功识破对手可<color='#ffff00'>+1</color>积分\n2.率先获得<color='#ffff00'>20分</color>一方<color='#ffff00'>获胜</color>\n3.获胜方<color='#ffff00'>最高分</color>可获<color='#ffff00'>MVP奖励</color>\n4.若活动结束时得分相同则<color='#ffff00'>率先到达</color>的一方获胜")
	self.titleString = TI18N("淘气南瓜")
	self.exitString = TI18N("退出场景")
	self.extString = TI18N("请点击<color='#ffff00'>开始匹配</color>")
	self.extString1 = TI18N("<color='#00ff00'>匹配中请稍候...</color>")
	self.extString2 = TI18N("匹配成功")

	self.updateListener = function(status) self:OnStatusChange(status) end

	self.isInit = true
end

function MainuiTracePumpkinReady:__delete()
	if self.descExt ~= nil then
		self.descExt:DeleteMe()
		self.descExt = nil
	end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function MainuiTracePumpkinReady:OnHide()
	self:RemoveListeners()
end

function MainuiTracePumpkinReady:RemoveListeners()
	EventMgr.Instance:RemoveListener(event_name.role_event_change, self.updateListener)
end

function MainuiTracePumpkinReady:OnOpen()
	self:RemoveListeners()
	EventMgr.Instance:AddListener(event_name.role_event_change, self.updateListener)

	self:OnStatusChange()
end

function MainuiTracePumpkinReady:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.halloween_pumpkin_ready))
	self.gameObject.name = "MainuiTracePumpkinReady"

	self.transform = self.gameObject.transform

	local t = self.transform
	t:SetParent(self.parent.mainObj.transform)
	t.localScale = Vector3.one
	t.anchoredPosition = Vector2(0, -47)

	self.titleText = t:Find("Panel/Title/Text"):GetComponent(Text)
	self.panel = t:Find("Panel")
	self.descExt = MsgItemExt.New(t:Find("Panel/Desc"):GetComponent(Text), 215.45, 18, 21)
	self.descExt.contentRect.anchoredPosition = Vector2(-108,-27)

	self.titleText.text = self.titleString
	self.extText = t:Find("Panel/Tips/Text"):GetComponent(Text)
	self.descExt:SetData(self.descString)

	t:Find("Panel/Button/Text"):GetComponent(Text).text = self.exitString
	t:Find("Panel/Button"):GetComponent(Button).onClick:AddListener(function() self:OnClick() end)

	self.panel.sizeDelta = Vector2(230, 27 + self.descExt.contentRect.sizeDelta.y + 50)

	self:OnOpen()
end

function MainuiTracePumpkinReady:OnClick()
	-- HalloweenManager.Instance:Send17802()
	
	if RoleManager.Instance:CanConnectCenter() then
        if RoleManager.Instance.RoleData.cross_type == 1 then
            SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
        else
            RoleManager.Instance:CheckQuitCenter()
        end
    else
        SceneManager.Instance.sceneElementsModel:Self_Transport(10001, 0, 0)
    end
end

function MainuiTracePumpkinReady:OnStatusChange(status)
	local mapid = SceneManager.Instance:CurrentMapId()
	local role_event = RoleManager.Instance.RoleData.event
	if role_event == RoleEumn.Event.Camp_halloween_pre then
		self.extText.text = self.extString1
	elseif role_event == RoleEumn.Event.camp_halloween_pre_enter then
		self.extText.text = self.extString2
	else
		self.extText.text = self.extString
	end
end

