AgendaWeekRewardPanel = AgendaWeekRewardPanel or BaseClass(BasePanel)

local GameObject = UnityEngine.GameObject

function AgendaWeekRewardPanel:__init(model)
    self.model = model
    self.name = "AgendaWeekRewardPanel"
    self.resList = {
        {file = AssetConfig.agendaweekrewardpanel, type = AssetType.Main}
        , {file = AssetConfig.final_skill_bg, type = AssetType.Main}
        ,{file = "prefabs/effect/20419.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20477.unity3d", type = AssetType.Main}
        , {file = AssetConfig.wingsbookbg, type = AssetType.Main}
        , {file = AssetConfig.agendaweekreward_textures, type = AssetType.Dep}
    }

    -----------------------------------------
    self.effTimerId = {}
    self.tweenId = {}
    self.effectObject = {}
    self.floatTimerId = {}

    -----------------------------------------
    self._update = function() self:Update() end
end

function AgendaWeekRewardPanel:__delete()
	if self.effTimerId[1] ~= nil then
		LuaTimer.Delete(self.effTimerId[1])
	end

	if self.tweenId[1] ~= nil then
		Tween.Instance:Cancel(self.tweenId[1])
	end

	if self.floatTimerId[1] ~= nil then
		LuaTimer.Delete(self.floatTimerId[1])
	end

	if self.effTimerId[2] ~= nil then
		LuaTimer.Delete(self.effTimerId[2])
	end

	if self.tweenId[2] ~= nil then
		Tween.Instance:Cancel(self.tweenId[2])
	end

	if self.floatTimerId[2] ~= nil then
		LuaTimer.Delete(self.floatTimerId[2])
	end

    self:ClearDepAsset()
end

function AgendaWeekRewardPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.agendaweekrewardpanel))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.CloseButton = self.transform:Find("Main/CloseButton")
    self.CloseButton:GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Close() end)

    self.item1 = self.transform:Find("Main/Item1")
    self.item2 = self.transform:Find("Main/Item2")

    self.item1:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.final_skill_bg, "FinalSkillBg")
    self.item1:Find("BottomImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.item2:GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.final_skill_bg, "FinalSkillBg")
    self.item2:Find("BottomImage"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.wingsbookbg, "WingsBookBg")

    self.item1:GetComponent(Button).onClick:AddListener(function() self:ButtonClick(1) end)
    self.item2:GetComponent(Button).onClick:AddListener(function() self:ButtonClick(2) end)

    self:OnShow()
end

function AgendaWeekRewardPanel:Close()
    self.model:CloseWeekRewardPanel()
end

function AgendaWeekRewardPanel:OnShow()
	AgendaManager.Instance.OnUpdateAgendaWeekData:Add(self._update)
	self:Update()
end

function AgendaWeekRewardPanel:OnHide()
	AgendaManager.Instance.OnUpdateAgendaWeekData:Remove(self._update)
end

function AgendaWeekRewardPanel:Update()
    self.transform:Find("Main/Top/Text"):GetComponent(Text).text = tostring(self.model.week_activity)
    
    local moveMark = false
	if #self.model.week_rewards_info >= 2 then
		local activity_need = self.model.week_rewards_info[1].activity_need
		if self.model.week_rewards_info[1].flag == 0 then
			if activity_need > self.model.week_activity then
				self.item1:Find("Image/Text"):GetComponent(Text).text = string.format(TI18N("<color='#b1ddf6'>%s可领</color>"), activity_need)
				self:ShowMoveEffect(1, true)
				moveMark = true
				self:ShowDuangEffect(1, false)
				self:ShowEffect(1, false)
			else
				self.item1:Find("Image/Text"):GetComponent(Text).text = TI18N("<color='#00ff00'>点击领取</color>")
				self:ShowMoveEffect(1, false)
				moveMark = true
				self:ShowDuangEffect(1, true)
				self:ShowEffect(1, true)
			end
			BaseUtils.SetGrey(self.item1:Find("BoxImage"):GetComponent(Image), false)
		else
			self.item1:Find("Image/Text"):GetComponent(Text).text = TI18N("<color='#c3c3c3'>已领取</color>")
			BaseUtils.SetGrey(self.item1:Find("BoxImage"):GetComponent(Image), true)
			self:ShowMoveEffect(1, false)
			self:ShowDuangEffect(1, false)
			self:ShowEffect(1, false)
		end

		activity_need = self.model.week_rewards_info[2].activity_need
		if self.model.week_rewards_info[2].flag == 0 then
			if activity_need > self.model.week_activity then
				self.item2:Find("Image/Text"):GetComponent(Text).text = string.format(TI18N("<color='#b1ddf6'>%s可领</color>"), activity_need)
				if moveMark then
					self:ShowMoveEffect(2, false)
				else
					self:ShowMoveEffect(2, true)
				end
				self:ShowDuangEffect(2, false)
				self:ShowEffect(2, false)
			else
				self.item2:Find("Image/Text"):GetComponent(Text).text = TI18N("<color='#00ff00'>点击领取</color>")
				self:ShowMoveEffect(2, false)
				self:ShowDuangEffect(2, true)
				self:ShowEffect(2, true)
			end
			BaseUtils.SetGrey(self.item2:Find("BoxImage"):GetComponent(Image), false)
		else
			self.item2:Find("Image/Text"):GetComponent(Text).text = TI18N("<color='#c3c3c3'>已领取</color>")
			BaseUtils.SetGrey(self.item2:Find("BoxImage"):GetComponent(Image), true)
			self:ShowMoveEffect(2, false)
			self:ShowDuangEffect(2, false)
			self:ShowEffect(2, false)
		end
	end
end

function AgendaWeekRewardPanel:ButtonClick(index)
	if #self.model.week_rewards_info >= 2 then
		local activity_need = self.model.week_rewards_info[index].activity_need
		if self.model.week_rewards_info[index].flag == 0 then
			if activity_need > self.model.week_activity then
				self:ShowTips(index)
			else
				AgendaManager.Instance:Require12011(activity_need)
			end
		else
			self:ShowTips(index)
		end
	end
end

function AgendaWeekRewardPanel:ShowTips(index)
	local tipsObject = self.item1.gameObject
	if index == 2 then
		tipsObject = self.item2.gameObject
	end
	local itemData = BackpackManager.Instance:GetItemBase(27010)
	itemData.name = self.model.week_rewards_info[index].name
	itemData.icon = self.model.week_rewards_info[index].icon
	itemData.desc = self.model.week_rewards_info[index].desc
	TipsManager.Instance:ShowAllItemTips({gameObject = tipsObject, itemData = itemData, extra = {nobutton = true}})
end

function AgendaWeekRewardPanel:ShowEffect(index, show)
	local gameObject = self.item1.gameObject
	if index == 2 then
		gameObject = self.item2.gameObject
	end

	if show then
	    if self.effectObject[index] == nil then
	    	local effectGo = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20477.unity3d"))
            Utils.ChangeLayersRecursively(effectGo.transform, "UI")
            effectGo.transform:SetParent(gameObject.transform)
            effectGo.transform.localPosition = Vector3(0, 0, -400)
            effectGo.transform.localRotation = Quaternion.identity
            effectGo.transform.localScale = Vector3(0.7, 0.7, 1)

            self.effectObject[index] = effectGo
        else
        	self.effectObject[index]:SetActive(true)
	    end
	else
		if self.effectObject[index] ~= nil then
			self.effectObject[index]:SetActive(false)
		end
	end
end

function AgendaWeekRewardPanel:ShowDuangEffect(index, show)
	local gameObject = self.item1:Find("BoxImage").gameObject
	if index == 2 then
		gameObject = self.item2:Find("BoxImage").gameObject
	end

	if show then
	    if self.effTimerId[index] == nil then
	       self.effTimerId[index] = LuaTimer.Add(index * 1000, 3000, function()
	           gameObject.transform.localScale = Vector3(1.2,1.2,1)
	           if self.tweenId[index] == nil then
	             	self.tweenId[index] = Tween.Instance:Scale(gameObject, Vector3(1,1,1), 1.2, function() self.tweenId[index] = nil end, LeanTweenType.easeOutElastic).id
	           end
	       end)
	    end
	else
		gameObject.transform.localScale = Vector3(1,1,1)

		if self.effTimerId[index] ~= nil then
			LuaTimer.Delete(self.effTimerId[index])
		end

		if self.tweenId[index] ~= nil then
			Tween.Instance:Cancel(self.tweenId[index])
		end
	end
end

function AgendaWeekRewardPanel:ShowMoveEffect(index, show)
	local gameObject = self.item1:Find("BoxImage").gameObject
	if index == 2 then
		gameObject = self.item2:Find("BoxImage").gameObject
	end

		if show then
	    if self.floatTimerId[index] == nil then
	       	self.floatCounter = 0
	       	gameObject.transform.localPosition = Vector3(0,0,0)

            self.floatTimerId[index] = LuaTimer.Add(0, 16, function() 
            	self.floatCounter = self.floatCounter + 1
                local position = gameObject.transform.localPosition
                gameObject.transform.localPosition = Vector2(position.x, position.y + 0.5 * math.sin(self.floatCounter * math.pi / 90 * 1.5))
            end)
	    end
	else
		gameObject.transform.localPosition = Vector3(0,0,0)

		if self.floatTimerId[index] ~= nil then
			LuaTimer.Delete(self.floatTimerId[index])
		end
	end
end