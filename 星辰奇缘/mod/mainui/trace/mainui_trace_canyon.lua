-- 峡谷之巅-追踪
-- @author hze
-- @date 2018/07/20

MainuiTraceCanYon = MainuiTraceCanYon or BaseClass(BaseTracePanel)
function MainuiTraceCanYon:__init(parent)
	self.parent = parent
	self.Mgr = CanYonManager.Instance
	self.resList = {
		{file = AssetConfig.trace_canyon_panel, type = AssetType.Main},
		{file = AssetConfig.guildleague_texture, type = AssetType.Dep},
	}

	self.on_role_event_change = function()
		self:RoleEventChange()
	end
	self.update_ready_info = function()
		self:SetMenberNum()
		self:CheckResult()
	end

	self.cannontimer = nil
	self.readytimer = nil
	self.defaultHidePlayerSetting = nil

	self.lastSelected = 2 
end

function MainuiTraceCanYon:__delete()
	self.OnToggle(self.defaultHidePlayerSetting)

	BaseUtils.ReleaseImage(self.blue1)
	BaseUtils.ReleaseImage(self.blue2)
	BaseUtils.ReleaseImage(self.blue3)
	BaseUtils.ReleaseImage(self.Targetblue)
	
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function MainuiTraceCanYon:OnHide()
	self:StopReadyTimer()
	self:StopCannonTimer()

	self:RemoveListeners()
end

function MainuiTraceCanYon:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.trace_canyon_panel))
	self.gameObject.name = "MainuiTraceCanYon"

	self.transform = self.gameObject.transform
	self.transform:SetParent(self.parent.mainObj.transform)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3(-115, -47, 0)

	self.Before = self.transform:Find("Before").gameObject
	self.Starting = self.transform:Find("_Starting").gameObject

	self.ImgBgT = self.Starting.transform:Find("_ImgBg")

	self.startObj = self.Starting.transform:Find("_ImgBg/Start").gameObject
	self.readyObj = self.Starting.transform:Find("_ImgBg/Ready").gameObject

	self.descRuleBtnBeforeStarting = self.Starting.transform:Find("_ImgBg/Start/RuleDescBtn").gameObject
    self.descRuleBtnBeforeStarting:GetComponent(Button).onClick:AddListener(function()
    	self.descRole = {
	        TI18N("1.个人行动力初始为<color='#ffff00'>1000</color>\n2.攻塔、守塔、开炮、战斗均<color='#ffff00'>消耗</color>行动力\n3.队伍<color='#ffff00'>人数越多</color>，攻击时消耗行动力越低\n4.守塔时战败，只会扣除<color='#ffff00'>少量行动力</color>"),
	    }
	    TipsManager.Instance:ShowText({gameObject = self.descRuleBtnBeforeStarting, itemData = self.descRole})
    end)

	self.Title = self.transform:Find("_Level/_Text"):GetComponent(Text)
	self.Title.text = TI18N("峡谷之巅")

	self.Toggle = self.transform:Find("Toggle"):GetComponent(Toggle)
	self.MapButton = self.transform:Find("_Starting/_ImgBg/MapButton"):GetComponent(Button)
	self._iconObj = self.transform:Find("_Starting/_ImgBg/Start/_Icon").gameObject
	self._iconObj.transform:GetComponent(Button).onClick:AddListener(function() self:IndexBtn(2) end)
	self.blue1 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button1/blue1"):GetComponent(Image)
	self.blue2 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button2/blue2"):GetComponent(Image)
	self.blue3 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button3/blue3"):GetComponent(Image)
	self.ExitButton = self.transform:Find("_Starting/_ImgBg/ExitButton"):GetComponent(Button)
	self.TeamButton = self.transform:Find("_Starting/_ImgBg/TeamButton"):GetComponent(Button)
	self.PowerText = self.transform:Find("_Starting/_ImgBg/Start/PowerText"):GetComponent(Text)
	self.RateText1 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button1/RateText1"):GetComponent(Text)
	self.RateText2 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button2/RateText2"):GetComponent(Text)
	self.RateText3 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button3/RateText3"):GetComponent(Text)
	self.GotoBtn1 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button1"):GetComponent(Button)
	self.GotoBtn2 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button2"):GetComponent(Button)
	self.GotoBtn3 = self.transform:Find("_Starting/_ImgBg/Start/_Icon/Button3"):GetComponent(Button)

	self.FightingInfo = self.transform:Find("_Starting/_ImgBg/Start/FightingInfo").gameObject
	self.FightingInfo.transform:GetComponent(Button).onClick:AddListener(function() self:IndexBtn(1) end)
	self.DescText = self.FightingInfo.transform:Find("DescText"):GetComponent(Text)
	self.TargetButton = self.FightingInfo.transform:Find("TargetButton"):GetComponent(Button)
	self.TargetRateText = self.FightingInfo.transform:Find("TargetButton/RateText1"):GetComponent(Text)
	self.Targetblue = self.FightingInfo.transform:Find("TargetButton/blue1"):GetComponent(Image)

	self.CannonButtonObj = self.transform:Find("_Starting/_ImgBg/Start/_CannonIcon").gameObject
	self.CannonButtonObj.transform:GetComponent(Button).onClick:AddListener(function() self:IndexBtn(3) end)
	self.OpenText = self.CannonButtonObj.transform:Find("CannonButton/I18NCannonOpenText"):GetComponent(Text)
	self.UnOpenText = self.CannonButtonObj.transform:Find("CannonButton/UnOpenText"):GetComponent(Text)
	self.CannonButton = self.CannonButtonObj.transform:Find("CannonButton"):GetComponent(Button)

	self.EndText = self.transform:Find("_Starting/_ImgBg/EndText").gameObject
	self.RuleButton = self.transform:Find("_Starting/_ImgBg/RuleButton"):GetComponent(Button)

	self.TeamButton.onClick:AddListener(function()
		CanYonManager.Instance.model:OpenMemberFightInfoRankPanel()
	end)
	self.ExitButton.onClick:AddListener(function()
		CanYonManager.Instance:Send21103()
	end)
	self.MapButton.onClick:AddListener(function()
		self.MapButton.transform:Find("_Red").gameObject:SetActive(false)
		CanYonManager.Instance.model:OpenMapWindow()
	end)
	self.CannonButton.onClick:AddListener(function()
		self:ToCannon()
	end)
	self.TargetButton.onClick:AddListener(function()
		self:ToTarget()
	end)
	self.RuleButton.onClick:AddListener(function()
		self.RuleButton.transform:Find("_Red").gameObject:SetActive(false)
  		CanYonManager.Instance.model:OpenDescPanel()
	end)

	self.readyTxt = self.Starting.transform:Find("_ImgBg/Ready/Text"):GetComponent(Text)
	self.readyTxt.text =TI18N("1、需按照<color='#ffff00'>顺序</color>进攻水晶塔\n2、摧毁对方3座水晶塔则<color='#ffff00'>全胜</color>\n3、<color='#ffff00'>大炮</color>开场<color='#ffff00'>8分钟</color>后启动\n4、合理安排<color='#7FFF00'>进攻</color>和<color='#7FFF00'>防守</color>，运用策略才更容易取得<color='#ffff00'>胜利！</color>")

	self.GotoBtn1.onClick:AddListener(function() self:Goto(1) end)
	self.GotoBtn2.onClick:AddListener(function() self:Goto(2) end)
	self.GotoBtn3.onClick:AddListener(function() self:Goto(3) end)

	-- self.transform:Find("_Starting/_ImgBg"):GetComponent(Button).onClick:AddListener(function()
  	-- 	CanYonManager.Instance.model:OpenDescPanel()
	-- end)

	self.Before.transform:Find("DescText_2"):GetComponent(Text).text = TI18N("1、自由组队，<color='#ffff00'>3人以上</color>才可参与峡谷之巅，推荐<color='#ffff00'>组满5人</color>哦\n2、队伍<color='#ffff00'>人数越多</color>，发起战斗时消耗行动力越低，<color='#ffff00'>奖励越好</color>\n3、摧毁对方3座<color='#ffff00'>水晶塔</color>则全胜")
	self.group_name = self.transform:Find("Before/conbg/guild1"):GetComponent(Text)
	self.ActiveTimeText = self.transform:Find("Before/ActiveText"):GetComponent(Text)
	self.TeamRed = self.transform:Find("Before/Button/red").gameObject
	self.RuleUpButton = self.transform:Find("Before/Hide/Button"):GetComponent(Button)
	self.RuleUpImg = self.transform:Find("Before/Hide/Button"):GetComponent(Image)
	self.RuleUpText = self.transform:Find("Before/Hide/Button/Text"):GetComponent(Text)
	self.GiveUPButton = self.transform:Find("Before/GiveUP/Button"):GetComponent(Button)




	self.NumText = self.transform:Find("Before/NumText"):GetComponent(Text)
	self.transform:Find("Before/NumText/Button"):GetComponent(Button).onClick:AddListener(function()
		TipsManager.Instance:ShowText({gameObject = self.transform:Find("Before/NumText/Button").gameObject, itemData = {
            TI18N("双方参战人数<color='#ffff00'>上限</color>均为<color='#ffff00'>100人</color>，请合理安排参战人员"),
            }})
	end)
	self.RuleUpButton.onClick:AddListener(function()
		CanYonManager.Instance.model:OpenDescPanel()
	end)

	self.GiveUPButton.onClick:AddListener(function()
    	CanYonManager.Instance:Send21102()
	end)

	self.defaultHidePlayerSetting = SettingManager.Instance:GetResult(SettingManager.Instance.THidePerson)
	self.Toggle.isOn = self.defaultHidePlayerSetting
	self:OnToggle(self.defaultHidePlayerSetting)
	self.Toggle.onValueChanged:AddListener( function(isOn) self:OnToggle(isOn) end)

	
	if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
		CanYonManager.Instance.model:OpenDescPanel()
	end

	self:OnOpen()
end

function MainuiTraceCanYon:RemoveListeners()
	EventMgr.Instance:RemoveListener(event_name.role_event_change, self.on_role_event_change)

	CanYonManager.Instance.CanYonUpdateStatus:RemoveListener(function() self:ChangeReadyOrPlay() end)
	CanYonManager.Instance.CanYonUpdateGroupName:RemoveListener(function() self:UpdateGroupName() end)
	CanYonManager.Instance.CanYonMovabilityChange:RemoveListener(function() self:MovabilityChange() end)
	CanYonManager.Instance.CanYonTowerChange:RemoveListener(function()	self:UpdateTowerInfo() end)
	CanYonManager.Instance.CanYonFightInfoUpdate:RemoveListener(self.update_ready_info)
end


function MainuiTraceCanYon:OnOpen()
	self.b = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture, "b")
    self.bh = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "bh")
    self.rh = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "rh")
    self.r = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "r")
    self.broken = self.assetWrapper:GetSprite(AssetConfig.guildleague_texture , "broken")


    self:RemoveListeners()
	EventMgr.Instance:AddListener(event_name.role_event_change, self.on_role_event_change)
	
	CanYonManager.Instance.CanYonUpdateStatus:AddListener(function() self:ChangeReadyOrPlay() end)
	CanYonManager.Instance.CanYonUpdateGroupName:AddListener(function() self:UpdateGroupName() end)
	CanYonManager.Instance.CanYonMovabilityChange:AddListener(function() self:MovabilityChange() end)
	CanYonManager.Instance.CanYonTowerChange:AddListener(function()	self:UpdateTowerInfo() end)
	CanYonManager.Instance.CanYonFightInfoUpdate:AddListener(self.update_ready_info)

	self:SetMenberNum()
	self:ChangeReadyOrPlay()
	self:RoleEventChange()
	self:UpdateInfo()

end


function MainuiTraceCanYon:RoleEventChange()
	if RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYonReady then
		self.Toggle.transform.anchoredPosition = Vector2(0,-220)
		self.Before:SetActive(true)
		self.Starting:SetActive(false)
		self:StartReadyTimer()
	elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then
		self.Toggle.transform.anchoredPosition = Vector2(0,-270)
		self.Before:SetActive(false)
		self.Starting:SetActive(true)
		self:StopReadyTimer()
	end
end

function MainuiTraceCanYon:UpdateInfo()
	self:UpdateGroupName()
	self:MovabilityChange()
	self:UpdateTowerInfo()
end

function MainuiTraceCanYon:StartReadyTimer()
	self:StopReadyTimer()

	self.readytimer = LuaTimer.Add(0, 500, function()
		self.ActiveTimeText.text = BaseUtils.formate_time_gap(CanYonManager.Instance.activity_time_ready - BaseUtils.BASE_TIME,":",0,BaseUtils.time_formate.MIN)
		if CanYonManager.Instance.activity_time_ready - BaseUtils.BASE_TIME <= 0 then 
			self.ActiveTimeText.text = "00:00"
			-- self:StopReadyTimer()
		end
	end)
end

function MainuiTraceCanYon:StopReadyTimer()
	if self.readytimer ~= nil then
		LuaTimer.Delete(self.readytimer)
		self.readytimer = nil
	end
end

function MainuiTraceCanYon:UpdateGroupName()
	if CanYonManager.Instance.group_id ~= nil then
		local name_txt = DataCanyonSummit.data_group_info[CanYonManager.Instance.group_id].group_name
		local lev_min = DataCanyonSummit.data_group_info[CanYonManager.Instance.group_id].lev_min
		local lev_max = DataCanyonSummit.data_group_info[CanYonManager.Instance.group_id].lev_max
		local lev_txt = ""
		local break_txt =""
		if lev_min == 120 then
			lev_txt = "+"
		else
			lev_txt = string.format("-%d",lev_max)
		end
		if DataCanyonSummit.data_group_info[CanYonManager.Instance.group_id].min_bk_times > 0 then
			break_txt = TI18N("突破")
		end
		local group_name = string.format("%s(%s%d%s)",name_txt,break_txt,lev_min,lev_txt)
		self.group_name.text = string.format("<color='#26E9F3'>%s</color>", group_name)
	end
end


function MainuiTraceCanYon:MovabilityChange()
	if CanYonManager.Instance.currData ~= nil then
		self.PowerText.text = CanYonManager.Instance.currData.movability
	end
end

function MainuiTraceCanYon:OnToggle(isOn)
	SceneManager.Instance.sceneElementsModel:Set_LimitRoleNum(isOn)
end

function MainuiTraceCanYon:UpdateTowerInfo()
	self.FightingInfo:SetActive(self.Mgr.is_win ~= 1)
	self._iconObj:SetActive(self.Mgr.is_win ~= 1)
	self.CannonButtonObj:SetActive(self.Mgr.is_win ~= 1)

	self.EndText:SetActive(self.Mgr.is_win == 1)
	if self.Mgr.towerData ~= nil then
		local index = 99
		local val = 9999999
		for k,v in pairs(self.Mgr.towerData) do
			if self.Mgr.self_side == 1 then
				-- print("我在蓝方")
				if v.unit_id == 1 then
					if v.duration > 0 and v.duration <= (DataCanyonSummit.data_tower_info[v.unit_id].duration/2) then
						self.blue1.sprite = self.bh
					elseif v.duration <= 0 then
						self.blue1.sprite = self.broken
					else
						self.blue1.sprite = self.b
					end
					local color = self:GetColor(v.duration, DataCanyonSummit.data_tower_info[v.unit_id].duration)
					self.RateText1.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration*100))
				elseif v.unit_id == 2 then
					-- self.blue2.fillAmount = v.duration/1000
					if v.duration > 0 and v.duration <= (DataCanyonSummit.data_tower_info[v.unit_id].duration/2) then
						self.blue2.sprite = self.bh
					elseif v.duration <= 0 then
						self.blue2.sprite = self.broken
					else
						self.blue2.sprite = self.b
					end
					local color = self:GetColor(v.duration, DataCanyonSummit.data_tower_info[v.unit_id].duration)
					self.RateText2.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration*100))
				elseif v.unit_id == 3 then
					if v.duration > 0 and v.duration <= (DataCanyonSummit.data_tower_info[v.unit_id].duration/2) then
						self.blue3.sprite = self.bh
					elseif v.duration <= 0 then
						self.blue3.sprite = self.broken
					else
						self.blue3.sprite = self.b
					end
					local color = self:GetColor(v.duration, DataCanyonSummit.data_tower_info[v.unit_id].duration)
					self.RateText3.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration*100))
				else
					if v.duration > 0 then
						if v.unit_id < index then
							index = v.unit_id
							val = v.duration
						end
					end
				end
			else
				-- print("我在红方")
				if v.unit_id == 4 then
					if v.duration > 0 and v.duration <= (DataCanyonSummit.data_tower_info[v.unit_id].duration/2) then
						self.blue1.sprite = self.rh
					elseif v.duration <= 0 then
						self.blue1.sprite = self.broken
					else
						self.blue1.sprite = self.r
					end
					local color = self:GetColor(v.duration, DataCanyonSummit.data_tower_info[v.unit_id].duration)
					self.RateText1.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration*100))
				elseif v.unit_id == 5 then
					if v.duration > 0 and v.duration <= (DataCanyonSummit.data_tower_info[v.unit_id].duration/2) then
						self.blue2.sprite = self.rh
					elseif v.duration <= 0 then
						self.blue2.sprite = self.broken
					else
						self.blue2.sprite = self.r
					end
					local color = self:GetColor(v.duration, DataCanyonSummit.data_tower_info[v.unit_id].duration)
					self.RateText2.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration*100))
				elseif v.unit_id == 6 then
					if v.duration > 0 and v.duration <= (DataCanyonSummit.data_tower_info[v.unit_id].duration/2) then
						self.blue3.sprite = self.rh
					elseif v.duration <= 0 then
						self.blue3.sprite = self.broken
					else
						self.blue3.sprite = self.r
					end
					local color = self:GetColor(v.duration, DataCanyonSummit.data_tower_info[v.unit_id].duration)
					self.RateText3.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(v.duration/DataCanyonSummit.data_tower_info[v.unit_id].duration*100))
				else
					if v.duration > 0 then
						if v.unit_id < index then
							index = v.unit_id
							val = v.duration
						end
					end
				end
			end
		end

		if index ~= 99 then
			local target = (index-1)%3+1
			self.DescText.text = string.format(TI18N("<color='#ffff00'>%s号水晶塔</color>"), tostring(target))
			local color = self:GetColor(val, DataCanyonSummit.data_tower_info[index].duration)
			self.TargetRateText.text = string.format("<color='#%s'>%s%%</color>", color, math.ceil(val/DataCanyonSummit.data_tower_info[index].duration*100))
			if self.Mgr.self_side == 1 then
				if val > 0 and val <= (DataCanyonSummit.data_tower_info[index].duration/2) then
					self.Targetblue.sprite = self.rh
				elseif val <= 0 then
					self.Targetblue.sprite = self.broken
				else
					self.Targetblue.sprite = self.r
				end
			else
				if val > 0 and val <= (DataCanyonSummit.data_tower_info[index].duration/2) then
					self.Targetblue.sprite = self.bh
				elseif val <= 0 then
					self.Targetblue.sprite = self.broken
				else
					self.Targetblue.sprite = self.b
				end
			end
		end
	end
end

function MainuiTraceCanYon:GetColor(duration, max)
	if duration == max then
		return "00ff00"
	elseif duration ~= 0 then
		return "ffff00"
	else
		return "ff0000"
	end
end

function MainuiTraceCanYon:Goto(index)
	EventMgr.Instance:Fire(event_name.cancel_colletion)
	local id = (self.Mgr.self_side -1) * 3 + index
	local battleid = 10000
	local unit_view = nil
	for _,unit in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if unit.data.unittype == 1 and unit.data.id < 7 and id == unit.data.id then
            battleid = unit.data.battleid
            unit_view = unit
        end
    end
	local posi = SceneManager.Instance.sceneModel:transport_small_pos(unit_view.data.x,  unit_view.data.y)
	SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(posi.x, posi.y)
end


function MainuiTraceCanYon:ToTarget(mark)
	EventMgr.Instance:Fire(event_name.cancel_colletion)
	if self.Mgr.towerData ~= nil then
		local index = 99
		local val = mark and 2 or 1  
		for k,v in pairs(self.Mgr.towerData) do
			if self.Mgr.self_side == val then
				if v.unit_id > 3 then
					if v.duration > 0 then
						if v.unit_id < index then
							index = v.unit_id
						end
					end
				end
			else
				if v.unit_id <= 3 then
					if v.duration > 0 then
						if v.unit_id < index then
							index = v.unit_id
						end
					end
				end
			end
		end
		if index ~= 99 then
			local unit_view = nil
			for _,unit in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
		        if unit.data.unittype == 1 and unit.data.id < 7 and index == unit.data.id then
		            unit_view = unit
		        end
		    end
			local posi = SceneManager.Instance.sceneModel:transport_small_pos(unit_view.data.x,  unit_view.data.y)
			SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(posi.x, posi.y)
		end
	end
end

function MainuiTraceCanYon:ToCannon()
	EventMgr.Instance:Fire(event_name.cancel_colletion)
	local unit_view = nil
	for _,unit in pairs(SceneManager.Instance.sceneElementsModel.NpcView_List) do
        if unit.data.unittype == 1 and unit.data.id == 7 then
            unit_view = unit
        end
    end
    if unit_view == nil then
    	return
    end
	local posi = SceneManager.Instance.sceneModel:transport_small_pos(unit_view.data.x,  unit_view.data.y)
	SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(posi.x, posi.y)
end

function MainuiTraceCanYon:CannonTextTick()
	if self.Mgr.cannonCd ~= 0 and self.Mgr.cannonCd <= Time.time then
		self.UnOpenText.gameObject:SetActive(false)
        self.OpenText.gameObject:SetActive(true)
    else
    	local timestr = BaseUtils.formate_time_gap(self.Mgr.cannonCd - Time.time,":",0,BaseUtils.time_formate.MIN)
    	self.UnOpenText.text = string.format(TI18N("<color='#ffff00'>%s</color>后启动"), timestr)
        self.UnOpenText.gameObject:SetActive(true)
        self.OpenText.gameObject:SetActive(false)
    end
end

function MainuiTraceCanYon:StartCannonTimer()
	if self.cannontimer ~= nil then
		LuaTimer.Delete(self.cannontimer)
		self.cannontimer = nil
	end
	self.cannontimer = LuaTimer.Add(0, 500, function() self:CannonTextTick() end)
end

function MainuiTraceCanYon:StopCannonTimer()
	if self.cannontimer ~= nil then
		LuaTimer.Delete(self.cannontimer)
		self.cannontimer = nil
	end
end

function MainuiTraceCanYon:CheckResult()
	self.FightingInfo:SetActive(self.Mgr.is_win ~= 1)
	self._iconObj:SetActive(self.Mgr.is_win ~= 1)
	self.CannonButtonObj:SetActive(self.Mgr.is_win ~= 1)

	self.EndText:SetActive(self.Mgr.is_win == 1)
end

function MainuiTraceCanYon:SetMenberNum()
	local color = "#00ff00"
	if self.Mgr.self_member_num ~= nil and self.Mgr.self_member_num >= 100 then
		color = "#ff0000"
	end
	if self.Mgr.self_member_num == nil then
		self.Mgr.self_member_num = 1
		print("没有参与人数数据")
	end
	self.NumText.text = string.format(TI18N("参战人数限制：<color='%s'>%s/100</color>"), color, self.Mgr.self_member_num)
	self.NumText.gameObject:SetActive(self.Mgr.self_member_num >= 60)
end

function MainuiTraceCanYon:ChangeReadyOrPlay()
	if CanYonManager.Instance.currstatus == CanYonEumn.Status.Playing then 
		self:StartCannonTimer()
	end

	self.readyObj:SetActive(CanYonManager.Instance.currstatus == CanYonEumn.Status.Preparing)
	self.startObj:SetActive(CanYonManager.Instance.currstatus == CanYonEumn.Status.Playing)

	if CanYonManager.Instance.currstatus == CanYonEumn.Status.Preparing then 
		self.MapButton.gameObject:SetActive(true)
		self.RuleButton.gameObject:SetActive(true)
		-- self.ImgBgT:GetComponent(RectTransform).sizeDelta = Vector2(226,243)
		-- self.Toggle.transform.anchoredPosition = Vector2(0,-250)
	end

	if CanYonManager.Instance.currstatus == CanYonEumn.Status.Playing then 
		self.MapButton.gameObject:SetActive(false)
		self.RuleButton.gameObject:SetActive(false)
		-- self.ImgBgT:GetComponent(RectTransform).sizeDelta = Vector2(226,276)
		-- self.Toggle.transform.anchoredPosition = Vector2(0,-287)
	end
end

function MainuiTraceCanYon:IndexBtn(type)
	if type ==  1 then 
		self:ToTarget()
	elseif type == 2 then 
		self:ToTarget(true)
	elseif type == 3 then 
		self:ToCannon()
	end

	self:SameStatus(type)
end

function MainuiTraceCanYon:SameStatus(type)
	if self.lastSelected == type then return end
	self.FightingInfo.transform:GetComponent(Image).enabled = (1 == type)
	self._iconObj.transform:GetComponent(Image).enabled = (2 == type)
	self.CannonButtonObj.transform:GetComponent(Image).enabled = (3 == type)
	self.lastSelected = type
end