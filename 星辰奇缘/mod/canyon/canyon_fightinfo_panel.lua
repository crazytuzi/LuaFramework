-- 峡谷之巅对战信息辅助界面
-- @author hze
-- @date 2018/07/25

CanYonFightInfoPanel = CanYonFightInfoPanel or BaseClass(BasePanel)
function CanYonFightInfoPanel:__init(model)
	self.model = model
	self.resList = {
		{file = AssetConfig.canyon_fight_info_panel, type = AssetType.Main}
		,{file = AssetConfig.guildleague_texture, type = AssetType.Dep}
		,{file = AssetConfig.hero_textures, type = AssetType.Dep}
	}

	self.hasInit = false
	self.unit_data = nil
	self.currBtn = nil
	self.timer = nil
	self.towerBroken = {}

	self.fireTimer = nil
	self.fireCd = 0
	self.attackTimer = nil
	self.attackCd = 0
	self.isdefending = false
	self.animating = false
    self.ishide = false

	self.beginFcallback = function()
		self:Hiden()
	end
	self.endFcallback = function()
		self:Show()
	end
	self.update_tower_info = function()
		self:UpdateTowerInfo()
	end
	self.totem_update = function()
		self:InitTotem()
		self:ChangeTimeTxt()
	end
	self.timetxt_update = function()
		self:ChangeTimeTxt()
	end

	self.AreaEffect = {}

	self.OnOpenEvent:AddListener(function() self:OnOpen() end)
	self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function CanYonFightInfoPanel:__delete()
	self.OnHideEvent:Fire()
	
	self:RemoveListeners()
	if self.timer ~= nil then
		LuaTimer.Delete(self.timer)
		self.timer = nil
	end

	if self.fireTimer ~= nil then
		LuaTimer.Delete(self.fireTimer)
		self.fireTimer = nil
	end

	if self.attackTimer ~= nil then
		LuaTimer.Delete(self.attackTimer)
		self.attackTimer = nil
	end
	
	self.bh = nil
	self.rh = nil

	if self.AreaEffect ~= nil then 
		for k,v in pairs(self.AreaEffect) do
			if v ~= nil then 
				v:DeleteMe()
			end
		end
		self.AreaEffect = {}  
	end

	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function CanYonFightInfoPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.canyon_fight_info_panel))
	self.gameObject.name = "CanYonFightInfoPanel"

	self.transform = self.gameObject.transform
	UIUtils.AddUIChild(MainUIManager.Instance.MainUICanvasView.gameObject, self.gameObject)
	self.transform:Find("_topbg"):GetComponent(Button).onClick:AddListener(function()
		CanYonManager.Instance.model:OpenMapWindow()
	end)

	self.myFlag = self.transform:Find("_topbg/MyFlag")
	self._clock = self.transform:Find("_topbg/_clock")
	self.prepartxt = self.transform:Find("_topbg/PreparTxt"):GetComponent(Text)



	self.IconImage1 = self.transform:Find("_topbg/IconImage1"):GetComponent(Image)
	self.IconImage2 = self.transform:Find("_topbg/IconImage2"):GetComponent(Image)
	self.BarImage1 = self.transform:Find("_topbg/BarImage1").gameObject
	self.BarImage2 = self.transform:Find("_topbg/BarImage2").gameObject
	self.TextName1 = self.transform:Find("_topbg/TextName1"):GetComponent(Text)
	self.TextName2 = self.transform:Find("_topbg/TextName2"):GetComponent(Text)
	self.TextNum1 = self.transform:Find("_topbg/BarImage1/TextNum1"):GetComponent(Text)
	self.TextNum2 = self.transform:Find("_topbg/BarImage2/TextNum2"):GetComponent(Text)
	self.TextTime = self.transform:Find("_topbg/TextTime"):GetComponent(Text)

	self.LCrystal1 = self.transform:Find("_topbg/_Icon1/blue1"):GetComponent(Image)
	self.LCrystal2 = self.transform:Find("_topbg/_Icon1/blue2"):GetComponent(Image)
	self.LCrystal3 = self.transform:Find("_topbg/_Icon1/blue3"):GetComponent(Image)

	self.RCrystal1 = self.transform:Find("_topbg/_Icon2/blue1"):GetComponent(Image)
	self.RCrystal2 = self.transform:Find("_topbg/_Icon2/blue2"):GetComponent(Image)
	self.RCrystal3 = self.transform:Find("_topbg/_Icon2/blue3"):GetComponent(Image)
	self.crystalList = {
		[1] = self.LCrystal1,
		[2] = self.LCrystal2,
		[3] = self.LCrystal3,
		[4] = self.RCrystal3,
		[5] = self.RCrystal2,
		[6] = self.RCrystal1,
	}

	self.notice_btn = self.transform:Find("_topbg/Notice"):GetComponent(Button)
	self.notice_btn.onClick:AddListener(function() CanYonManager.Instance.model:OpenDescPanel() end)

	self.FireLock = self.transform:Find("ButtonFire/Lock")
	self.FireTexttime = self.transform:Find("ButtonFire/Lock/Textatktime"):GetComponent(Text)
	self.AttackLock = self.transform:Find("ButtonAttackTower/Lock")
	self.AttackTexttime = self.transform:Find("ButtonAttackTower/Lock/Textatktime"):GetComponent(Text)

	self.HideButton = self.transform:Find("HideButton"):GetComponent(Button)
    self.HideButton.onClick:AddListener(function()
        self:OnDoHide()
    end)
    self.HideArrow = self.transform:Find("HideButton/arrow")

	self.ButtonFire = self.transform:Find("ButtonFire"):GetComponent(Button)
	self.ButtonFireImage = self.transform:Find("ButtonFire"):GetComponent(Image)
	self.ButtonFire.onClick:AddListener(function()
		self:AttackFire()
	end)
	self.ButtonDefendIMG = self.transform:Find("ButtonDefend"):GetComponent(Image)
	self.ButtonDefend = self.transform:Find("ButtonDefend"):GetComponent(Button)
	self.ButtonDefend.onClick:AddListener(function()
		self:Defend()
	end)
	self.ButtonAttackTower = self.transform:Find("ButtonAttackTower"):GetComponent(Button)
	self.ButtonAttackTowerImage = self.transform:Find("ButtonAttackTower"):GetComponent(Image)
	self.ButtonAttackTower.onClick:AddListener(function()
		self:AttackFire()
	end)
	-- self.Textatktime = self.transform:Find("ButtonAttackTower/Textatktime"):GetComponent(Text)
	self.ButtonFire.gameObject:SetActive(false)
	self.ButtonDefend.gameObject:SetActive(false)
	self.ButtonAttackTower.gameObject:SetActive(false)
	self.hasInit = true

	self.bh = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "bh")
    self.rh = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "rh")
	self.broken = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "broken")
end

function CanYonFightInfoPanel:OnInitCompleted()
    self.assetWrapper:ClearMainAsset()
    self.OnOpenEvent:Fire()
end

function CanYonFightInfoPanel:OnOpen()
	self:RemoveListeners()

	EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFcallback)
	EventMgr.Instance:AddListener(event_name.end_fight, self.endFcallback)
	CanYonManager.Instance.CanYonTowerChange:AddListener(self.update_tower_info)
	CanYonManager.Instance.CanYonFightInfoUpdate:AddListener(self.totem_update)
	CanYonManager.Instance.CanYonUpdateStatus:AddListener(self.timetxt_update)

	if MainUIManager.Instance.MainUIIconView ~= nil then
		MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {17})
	end

	self:InitTotem()
	self:StartTimer()
	self:UpdateTowerInfo()
end

function CanYonFightInfoPanel:OnHide()

end

function CanYonFightInfoPanel:RemoveListeners()
	CanYonManager.Instance.CanYonTowerChange:RemoveListener(self.update_tower_info)
	CanYonManager.Instance.CanYonFightInfoUpdate:RemoveListener(self.totem_update)
	CanYonManager.Instance.CanYonUpdateStatus:RemoveListener(self.timetxt_update)
	EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
	EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFcallback)
end

function CanYonFightInfoPanel:OnEnterArea(data)
	self.unit_data = data
	self:HideIcon()
	if not self.hasInit or data == nil then
		return
	end
	if CanYonManager.Instance.towerData ~= nil then
		for k,v in pairs(CanYonManager.Instance.towerData) do
			if data.id == v.unit_id and v.duration <= 0 then
				return
			end
		end
	end
	if data.unitytype == CanYonEumn.UnitType.Tower then
		if data.side == CanYonManager.Instance.self_side then
			self.ButtonDefend.gameObject:SetActive(true)
			self.currBtn = self.ButtonDefend
		else
			self.ButtonAttackTower.gameObject:SetActive(true)
			self.currBtn = self.ButtonAttackTower
		end
	elseif data.unitytype == CanYonEumn.UnitType.Cannon then
		self.ButtonFire.gameObject:SetActive(true)
		self.currBtn = self.ButtonFire
	else

	end
	if data.id <= 7 then
		if self.AreaEffect[data.id] == nil and self.towerBroken[data.id] ~= true then
			local unit = nil
			for _,view in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do

	            if view.data.unittype == 1 and data.id == view.data.id then
	                unit = view
	            end
	        end
	        if unit == nil or BaseUtils.isnull(unit.gameObject) == true then
	        	return
	        end
			local callback = function(effectview)
                if BaseUtils.isnull(unit.gameObject) then
		            self.AreaEffect[data.id]:DeleteMe()
		            self.AreaEffect[data.id] = nil
		            return
		        end
		        local trans = unit:GetCachedTransform()
		        effectview.transform:SetParent(trans)
		        effectview.transform.localScale = Vector3.one
		        if data.id %3 == 0 then
		        	effectview.transform.localScale = Vector3.one*1.5
		        end
		        effectview.transform.localPosition = Vector3(0, 0.2, 0)
		        effectview.transform.rotation = Quaternion.identity
		        effectview.transform:Rotate(Vector3(335, 0, 0))
		        Utils.ChangeLayersRecursively(effectview.transform, "Model")
			end
			if data.side == 0 or data.side == CanYonManager.Instance.self_side then
				self.AreaEffect[data.id] = BaseEffectView.New({ effectId = 30151, callback = callback })
			else
				self.AreaEffect[data.id] = BaseEffectView.New({ effectId = 30152, callback = callback })
			end
		elseif self.AreaEffect[data.id] ~= nil then
			if self.towerBroken[data.id] == true then
				self.AreaEffect[data.id]:SetActive(false)
			else
				self.AreaEffect[data.id]:SetActive(true)
			end
		end
	end
end

function CanYonFightInfoPanel:HideIcon()
	if self.currBtn == nil then
		self.unit_data = nil
		return
	end
	for k,v in pairs(self.AreaEffect) do
		if self.unit_data == nil or k ~= self.unit_data.id then
			v:SetActive(false)
		end
	end
	self.ButtonFire.gameObject:SetActive(false)
	self.ButtonDefend.gameObject:SetActive(false)
	self.ButtonAttackTower.gameObject:SetActive(false)
end

function CanYonFightInfoPanel:AttackFire()
	if self.unit_data == nil then
		return
	end
	CanYonManager.Instance:Send21110(10001, self.unit_data.id)
end

function CanYonFightInfoPanel:Defend()
	if self.unit_data == nil or self.isdefending then
		return
	end
	CanYonManager.Instance:Send21111(10001, self.unit_data.id)
end

function CanYonFightInfoPanel:AttackCD()
	-- body
end

function CanYonFightInfoPanel:StartTimer()
	if self.timer ~= nil then
		LuaTimer.Delete(self.timer)
		self.timer = nil
	end
	self.timer = LuaTimer.Add(0, 500, function()
		if CanYonManager.Instance.activity_time - BaseUtils.BASE_TIME <= 50*60 then
			if self.BarImage1.gameObject.activeSelf == false then
				self.BarImage1.gameObject:SetActive(true)
				self.BarImage2.gameObject:SetActive(true)
			end
		else
			if self.BarImage1.gameObject.activeSelf == true then
				self.BarImage1.gameObject:SetActive(false)
				self.BarImage2.gameObject:SetActive(false)
			end
		end
		if BaseUtils.isnull(self.TextTime) then
			if self.timer ~= nil then
				LuaTimer.Delete(self.timer)
				self.timer = nil
			end
			a.b = c
			return
		end
		-- if MainUIManager.Instance.MainUIIconView.isiconshow3 == true then
		-- 	MainUIManager.Instance.MainUIIconView:hidebaseicon3()
		-- 	MainUIManager.Instance.MainUIIconView:hidebaseicon5()
		-- 	MainUIManager.Instance.MainUIIconView:Set_ShowTop(false, {107})
		-- end
		if CanYonManager.Instance.activity_time == nil then
			-- CanYonManager.Instance:Send21100()
		else
			self.TextTime.text = BaseUtils.formate_time_gap(CanYonManager.Instance.activity_time - BaseUtils.BASE_TIME,":",0,BaseUtils.time_formate.MIN)
		end
	end)
end

function CanYonFightInfoPanel:LockBtn(id)
	if id == 7 then
		if self.fireTimer ~= nil then
			LuaTimer.Delete(self.fireTimer)
			self.fireTimer = nil
		end
		self.FireLock.gameObject:SetActive(true)
		BaseUtils.SetGrey(self.ButtonFireImage, true)
		self.ButtonFire.enabled = false
		self.fireCd = 30 + BaseUtils.BASE_TIME
		self.fireTimer = LuaTimer.Add(0, 500, function()
			if BaseUtils.isnull(self.FireTexttime) then
				if self.fireTimer ~= nil then
					LuaTimer.Delete(self.fireTimer)
					self.fireTimer = nil
				end
				return
			end
			local remain = math.floor(self.fireCd - BaseUtils.BASE_TIME)
			self.FireTexttime.text = string.format("%ss", tostring(remain))
			if remain <= 0 then
				if self.fireTimer ~= nil then
					LuaTimer.Delete(self.fireTimer)
					self.fireTimer = nil
				end
				self.ButtonFire.enabled = true
				BaseUtils.SetGrey(self.ButtonFireImage, false)
				self.FireLock.gameObject:SetActive(false)
			end
		end)
	else
		if self.attackTimer ~= nil then
			LuaTimer.Delete(self.attackTimer)
			self.attackTimer = nil
		end
		self.AttackLock.gameObject:SetActive(true)
		BaseUtils.SetGrey(self.ButtonAttackTowerImage, true)
		self.ButtonAttackTower.enabled = false
		self.attackCd = 20 + BaseUtils.BASE_TIME
		self.attackTimer = LuaTimer.Add(0, 500, function()
			if BaseUtils.isnull(self.FireTexttime) then
				if self.timer ~= nil then
					LuaTimer.Delete(self.attackTimer)
					self.timer = nil
				end
				return
			end
			local remain = math.floor(self.attackCd - BaseUtils.BASE_TIME)
			self.AttackTexttime.text = string.format("%ss", tostring(remain))
			if remain <= 0 then
				if self.attackTimer ~= nil then
					LuaTimer.Delete(self.attackTimer)
					self.attackTimer = nil
				end
				self.ButtonAttackTower.enabled = true
				BaseUtils.SetGrey(self.ButtonAttackTowerImage, false)
				self.AttackLock.gameObject:SetActive(false)
			end
		end)
	end
end

function CanYonFightInfoPanel:UpdateTowerInfo()
	if CanYonManager.Instance.towerData ~= nil then
		for k,v in pairs(CanYonManager.Instance.towerData) do
			if self.crystalList[v.unit_id] ~= nil then
				if v.unit_id > 3 then
					if v.duration > 0 and v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration <= 0.5 then
						self.crystalList[v.unit_id].sprite = self.rh
					elseif v.duration <= 0 then
						self.crystalList[v.unit_id].sprite = self.broken
						self.towerBroken[v.unit_id] = true
					end
				else
					if v.duration > 0 and v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration < 0.5 then
						self.crystalList[v.unit_id].sprite = self.bh
					elseif v.duration <= 0 then
						self.crystalList[v.unit_id].sprite = self.broken
						self.towerBroken[v.unit_id] = true
					end
				end
				-- self.crystalList[v.unit_id].fillAmount = v.duration/1000
			end
		end
	end
end

function CanYonFightInfoPanel:InitTotem()
	self.myFlag.gameObject:SetActive(true)
	if CanYonManager.Instance.self_side == 1 then
		self.myFlag.anchoredPosition = Vector2(-167,-10.6)
	elseif CanYonManager.Instance.self_side == 2 then
		self.myFlag.anchoredPosition = Vector2(167,-10.6)
	else
		self.myFlag.gameObject:SetActive(false)
	end

	for _,v in ipairs(CanYonManager.Instance.fightinfolist) do
		if v.side_id == 1 then 
			self.TextNum1.text = string.format("%s人", tostring(v.remain_num))
		elseif v.side_id == 2 then 
			self.TextNum2.text = string.format("%s人", tostring(v.remain_num))

		end
	end


end

function CanYonFightInfoPanel:ChangeDefendIcon(open)
	if open then
		self.isdefending = true
		self.ButtonDefendIMG.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "I18NDefending")
	else
		self.isdefending = false
		self.ButtonDefendIMG.sprite = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "I18NDefendTower")
	end
	self.ButtonDefendIMG:SetNativeSize()
end

function CanYonFightInfoPanel:OnDoHide()
    if self.animating then
        return
    end
    self.animating = true
    if self.ishide then
    	self.transform:Find("_topbg").gameObject:SetActive(true)
    	local t = self.transform:Find("_topbg").localPosition.y-78.9
    	local t2 = self.HideButton.gameObject.transform.localPosition.y-78.9
    	Tween.Instance:MoveLocalY(self.transform:Find("_topbg").gameObject, t, 0.2, function() self.ishide = false self.animating = false self.HideArrow.localRotation = Quaternion.Euler(0 , 0, 0) end, LeanTweenType.linear)
    	Tween.Instance:MoveLocalY(self.HideButton.gameObject, t2, 0.2, function() end, LeanTweenType.linear)
    else
    	local t = self.transform:Find("_topbg").localPosition.y+78.9
    	local t2 = self.HideButton.gameObject.transform.localPosition.y+78.9
    	Tween.Instance:MoveLocalY(self.transform:Find("_topbg").gameObject, t, 0.2, function() self.ishide = true self.animating = false self.HideArrow.localRotation = Quaternion.Euler(0 , 0, 180) end, LeanTweenType.linear)
    	Tween.Instance:MoveLocalY(self.HideButton.gameObject, t2, 0.2, function() self.transform:Find("_topbg").gameObject:SetActive(false) end, LeanTweenType.linear)

    end
end

function CanYonFightInfoPanel:ChangeTimeTxt()
	if CanYonManager.Instance.is_win == 1 then 
		self.prepartxt.text = TI18N("结束退场")
	elseif CanYonManager.Instance.currstatus == CanYonEumn.Status.Preparing then 	
		self.prepartxt.text = TI18N("即将开始")
		-- self._clock.transform.anchoredPosition = Vector2(-52,-27)
		-- self.TextTime.transform.anchoredPosition = Vector2(31,-29)
	elseif CanYonManager.Instance.currstatus == CanYonEumn.Status.Playing then
		self.prepartxt.text = TI18N("距离结束")
		-- self._clock.transform.anchoredPosition = Vector2(-22,-27)
		-- self.TextTime.transform.anchoredPosition = Vector2(9,-29)
	end
end