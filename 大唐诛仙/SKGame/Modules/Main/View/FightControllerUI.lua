FightControllerUI =BaseClass(LuaUI)

function FightControllerUI:__init( ... )
	self.URL = "ui://0042gniteg11an";
	self:__property(...)
	self:Config()
end

function FightControllerUI:SetProperty( ... )
end

function FightControllerUI:InitEvent()
	self.handler1=GlobalDispatcher:AddEventListener(EventName.AUTO_HPMP, function ( data )
		self:AutoAll(data)
	end)
	self.setHandler = self.stgModel:AddEventListener(StgConst.DATA_CHANGED, function ( type, state )
		self:SetAutoHPMPPos( type, state )
	end)
	self.sceneLoadFinishHandler=GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ()
		self:OnHpMpChange()
	end)
	self.mainPlayerDataChange = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE,  function (key, value, pre)
		if key == "hp" or key == "mp" then
			self:OnHpMpChange()
		end
	end)
	self.ttHandler1 = self.tiantiModel:AddEventListener(TiantiConst.E_PK_ITEM_INIT, function()
		--self:InitPkItem()
		self:UpdateAgentiaItemNumJJC()
	end)
	self.ttHandler2 = self.tiantiModel:AddEventListener(TiantiConst.E_PK_ITEM_CHANGE, function()
		self:UpdateAgentiaItemNumJJC()
	end)

	self:SetAutoHPMPPos( 0, self.stgModel.hpState )
	self:SetAutoHPMPPos( 1, self.stgModel.mpState )
end

function FightControllerUI:Config()
	self.model = PkgModel:GetInstance()
	self.stgModel = SettingModel:GetInstance()
	self.tiantiModel = TiantiModel:GetInstance()
	self.doubleHp = true
	self.doubleMp = true
	self.redCD = 6
	self.blueCD = 6
	self.redDelay = 0
	self.blueDelay = 0
	self.autoHp = 0.5
	self.autoMp = 0.5
	self.doubleHp_jjc = true
	self.doubleMp_jjc = true
	self.redCD_jjc = 6
	self.blueCD_jjc = 6
	self.redDelay_jjc = 0
	self.blueDelay_jjc = 0
	self.autoHp_jjc = 0.5
	self.autoMp_jjc = 0.5
end

function FightControllerUI:OnHpMpChange(isAutoFinish)
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	if not playerVo then return end
	if self.isAutoHp then
		if (playerVo.hpMax * self.autoHp) >= playerVo.hp then -- 实现自动后完全补到满，看策划需求加上 or (isAutoFinish and playerVo.hpMax ~= playerVo.hp) 
			self:OnClickAgentia(self.btnAgentiacdTxt01,self.btnAgentiaCdIcon01,self.hp)
		end
	end
	if self.isAutoMp then
		if (playerVo.mpMax * self.autoMp) >= playerVo.mp then -- 实现自动后完全补到满，看策划需求加上 or (isAutoFinish and playerVo.mpMax ~= playerVo.mp)
			self:OnClickAgentia(self.btnAgentiacdTxt02,self.btnAgentiaCdIcon02,self.mp)
		end
	end
end

function FightControllerUI:OnHpMpChangeJJC(isAutoFinish)
	local playerVo = SceneModel:GetInstance():GetMainPlayer()
	if not playerVo then return end
	if self.isAutoHp_jjc then
		if (playerVo.hpMax * self.autoHp_jjc) >= playerVo.hp then
			self:OnClickAgentia(self.btnAgentiacdTxt03,self.btnAgentiaCdIcon03,self.hp_jjc)
		else
			self.isAutoHp_jjc = false
			self:AutoHpJJC()
		end
	end
	if self.isAutoMp_jjc then
		if (playerVo.mpMax * self.autoMp_jjc) >= playerVo.mp then
			self:OnClickAgentia(self.btnAgentiacdTxt04,self.btnAgentiaCdIcon04,self.mp_jjc)
		else
			self.isAutoMp_jjc = false
			self:AutoMpJJC()
		end
	end
end

-- 封装HP、MP接口
function FightControllerUI:SetAutoHPMPPos( type, state )
	if type == 0 then
		self.autoHp = state or self.autoHp
		self.autoHp_jjc = state or self.autoHp_jjc
	else
		self.autoMp = state or self.autoMp
		self.autoMp_jjc = state or self.autoMp_jjc
	end
end

function FightControllerUI:InitBtnSkillView()
	if self.btnSkillView then 
		self.btnSkillView:Destroy()
	end
	self.btnSkillView = BtnSkillView.New(self.btnAttack, self.btnSkill01, self.btnSkill02, self.btnSkill03, self.btnSkill04,self.btnAgentia01,self.btnAgentia02)
	self.btnSkillView:Reset() --技能按钮可能被锁定，执行一次重置
	self:InitDataUi()
end
function FightControllerUI:InitDataUi()
	self:UpdateAgentia()
	self:InitEvent()
end

function FightControllerUI:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Main","FightController");

	self.btnSkill01 = self.ui:GetChild("BtnSkill01")
	self.btnSkill02 = self.ui:GetChild("BtnSkill02")
	self.btnSkill03 = self.ui:GetChild("BtnSkill03")
	self.btnSkill04 = self.ui:GetChild("BtnSkill04")
	self.btnAttack = self.ui:GetChild("BtnAttack")
	self.btnAgentia01 = self.ui:GetChild("BtnAgentia01")
	self.btnAgentia02 = self.ui:GetChild("BtnAgentia02")
	self.btnAgentia03 = self.ui:GetChild("BtnAgentia03")
	self.btnAgentia04 = self.ui:GetChild("BtnAgentia04")

	self.btnAgentiaIcon01 = self.btnAgentia01:GetChild("BtnAgentiaIcon")
	self.btnAgentiaCdIcon01 = self.btnAgentia01:GetChild("BtnAgentiaCdIcon")
	self.btnAgentiacdTxt01 = self.btnAgentia01:GetChild("BtnAgentiacdTxt")
	self.btnAgentianumTxt01 = self.btnAgentia01:GetChild("BtnAgentianumTxt")
	self.btnAutoHpTxt = self.btnAgentia01:GetChild("BtnAutoTxt")
	self.shadowHp = self.btnAgentia01:GetChild("Shadow")
	self.hpLock = self.btnAgentia01:GetChild("lock")
	self.shadowHp.url = UIPackage.GetItemURL("Pkg", "sy_hp")
	self.btnAutoHpTxt.visible = false
	self.itemIdHp = 0
	self.isActivateHp = false
	self.isNilHp = false
	self.hp = "hp"
	self.isAutoHp = false

	self.btnAgentiaIcon02 = self.btnAgentia02:GetChild("BtnAgentiaIcon")
	self.btnAgentiaCdIcon02 = self.btnAgentia02:GetChild("BtnAgentiaCdIcon")
	self.btnAgentiacdTxt02 = self.btnAgentia02:GetChild("BtnAgentiacdTxt")
	self.btnAgentianumTxt02 = self.btnAgentia02:GetChild("BtnAgentianumTxt")
	self.btnAutoMpTxt = self.btnAgentia02:GetChild("BtnAutoTxt")
	self.shadowMp = self.btnAgentia02:GetChild("Shadow")
	self.mpLock = self.btnAgentia02:GetChild("lock")
	self.shadowMp.url = UIPackage.GetItemURL("Pkg", "sy_mp")
	self.btnAutoMpTxt.visible = false
	self.itemIdMp = 0
	self.isActivateMp = false
	self.isNilMp = false
	self.mp = "mp"
	self.isAutoMp = false

	-- 竞技场(jjc)part ===>>>
	--红药小瓶图标(亮)
	self.btnAgentiaIcon03 = self.btnAgentia03:GetChild("BtnAgentiaIcon")
	--遮罩圆圈(360度转)
	self.btnAgentiaCdIcon03 = self.btnAgentia03:GetChild("BtnAgentiaCdIcon")
	--红药数量
	self.btnAgentianumTxt03 = self.btnAgentia03:GetChild("BtnAgentianumTxt")
	--自动txt
	self.btnAutoHpTxt_jjc = self.btnAgentia03:GetChild("BtnAutoTxt")
	--红药小瓶图标(暗)
	self.shadowHp_jjc = self.btnAgentia03:GetChild("Shadow")
	self.shadowHp_jjc.url = UIPackage.GetItemURL("Pkg", "sy_hp")
	self.btnAutoHpTxt_jjc.visible = false
	self.itemIdHp_jjc = 0
	self.isActivateHp_jjc = false
	self.isNilHp_jjc = false
	self.hp_jjc = "hp_jjc"
	self.isAutoHp_jjc = false

	self.btnAgentiaIcon04 = self.btnAgentia04:GetChild("BtnAgentiaIcon")
	self.btnAgentiaCdIcon04 = self.btnAgentia04:GetChild("BtnAgentiaCdIcon")
	self.btnAgentianumTxt04 = self.btnAgentia04:GetChild("BtnAgentianumTxt")
	self.btnAutoMpTxt_jjc = self.btnAgentia04:GetChild("BtnAutoTxt")
	self.shadowMp_jjc = self.btnAgentia04:GetChild("Shadow")
	self.shadowMp_jjc.url = UIPackage.GetItemURL("Pkg", "sy_mp")
	self.btnAutoMpTxt_jjc.visible = false
	self.itemIdMp_jjc = 0
	self.isActivateMp_jjc = false
	self.isNilMp_jjc = false
	self.mp_jjc = "mp_jjc"
	self.isAutoMp_jjc = false
	-- <<<===

	self.btnAgentia01.onClick:Clear()
	self.btnAgentia02.onClick:Clear()
	self.btnAgentia03.onClick:Clear()
	self.btnAgentia04.onClick:Clear()
	self.btnAgentia01.onClick:Add(self.OnClickHp,self)
	self.btnAgentia02.onClick:Add(self.OnClickMp,self)
	self.btnAgentia03.onClick:Add(self.OnClickHpTianti,self)
	self.btnAgentia04.onClick:Add(self.OnClickMpTianti,self)

	self.handler2=GlobalDispatcher:AddEventListener(EventName.MEDICINE_CHANGE, function ()
		self:UpdateAgentiaItemNum()
	end) -- 属性更新变化事件

	self.handler3=GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function ()
		self:UpdateAgentiaItemNum()
	end)

	self.isUse = true
	self.isHpClick = false -- 是否双击了Hp
	self.isMpClick = false -- 是否双击了Mp
end
function FightControllerUI:UpdateAgentiaItemNum()
	self.isActivateHp = false
	self.isActivateMp = false
	self:UpdateAgentia()
	self:OnHpMpChange()
end
function FightControllerUI:UpdateAgentiaItemNumJJC()
	self.isActivateHp_jjc = false
	self.isActivateMp_jjc = false
	self:UpdateAgentiaJJC()
	self:OnHpMpChangeJJC()
end

function FightControllerUI:UpdateAgentia()
	local list = self.model:ReSetByMedicineTable(self.model.wearMpTable)
	local isEnter = true
	local num = 0
	for i,v in ipairs(list) do
		if v ~= 0 then
			num = self.model:GetTotalByBid(v)
			if num ~= 0 then
				isEnter = false
				if i == 1 then
					self:SetItemNum(self.btnAgentianumTxt02,self.btnAgentiaIcon02,self.btnAgentiaCdIcon02,self.btnAgentiacdTxt02,v,self.mp, num)
					break
				elseif i == 2 then
					self:SetItemNum(self.btnAgentianumTxt02,self.btnAgentiaIcon02,self.btnAgentiaCdIcon02,self.btnAgentiacdTxt02,v,self.mp, num)
					break
				elseif i == 3 then
					self:SetItemNum(self.btnAgentianumTxt02,self.btnAgentiaIcon02,self.btnAgentiaCdIcon02,self.btnAgentiacdTxt02,v,self.mp, num)
					break
				end
			end
		end
	end
	self.isNilMp = false
	if isEnter then
		self:InitItemData(self.btnAgentianumTxt02,self.btnAgentiaIcon02,self.btnAgentiaCdIcon02,self.btnAgentiacdTxt02,false,self.mp)
		self.shadowMp.visible = true
	else
		self.shadowMp.visible = false
	end

	list = self.model:ReSetByMedicineTable(self.model.wearHpTable)
	isEnter = true
	for i,v in ipairs(list) do
		if v ~= 0 then
			num = self.model:GetTotalByBid(v)
			if num ~= 0 then
				isEnter = false
				if i == 1 then
					self:SetItemNum(self.btnAgentianumTxt01,self.btnAgentiaIcon01,self.btnAgentiaCdIcon01,self.btnAgentiacdTxt01,v,self.hp, num)
					break
				elseif i == 2 then
					self:SetItemNum(self.btnAgentianumTxt01,self.btnAgentiaIcon01,self.btnAgentiaCdIcon01,self.btnAgentiacdTxt01,v,self.hp, num)
					break
				elseif i == 3 then
					self:SetItemNum(self.btnAgentianumTxt01,self.btnAgentiaIcon01,self.btnAgentiaCdIcon01,self.btnAgentiacdTxt01,v,self.hp, num)
					break
				end
			end
		end
	end
	self.isNilHp = false
	if isEnter then
		self:InitItemData(self.btnAgentianumTxt01,self.btnAgentiaIcon01,self.btnAgentiaCdIcon01,self.btnAgentiacdTxt01,false,self.hp)
		self.shadowHp.visible = true
	else
		self.shadowHp.visible = false
	end
end

function FightControllerUI:UpdateAgentiaJJC()
	local listTotal = self.tiantiModel:GetPkItemInfo()
	local list = listTotal[2]
	local isEnter = true
	local num = list[3] or 0
	if num ~= 0 then
		isEnter = false
		self:SetItemNum(self.btnAgentianumTxt04,self.btnAgentiaIcon04,self.btnAgentiaCdIcon04,self.btnAgentiacdTxt04,list[2],self.mp_jjc, num)
	end
	self.isNilMp_jjc = false
	if isEnter then
		self:InitItemData(self.btnAgentianumTxt04,self.btnAgentiaIcon04,self.btnAgentiaCdIcon04,self.btnAgentiacdTxt04,false,self.mp_jjc)
		self.shadowMp_jjc.visible = true
	else
		self.shadowMp_jjc.visible = false
	end

	list = listTotal[1]
	isEnter = true
	num = list[3] or 0
	if num ~= 0 then
		isEnter = false
		self:SetItemNum(self.btnAgentianumTxt03,self.btnAgentiaIcon03,self.btnAgentiaCdIcon03,self.btnAgentiacdTxt03,list[2],self.hp_jjc, num)
	end
	self.isNilHp_jjc = false
	if isEnter then
		self:InitItemData(self.btnAgentianumTxt03,self.btnAgentiaIcon03,self.btnAgentiaCdIcon03,self.btnAgentiacdTxt03,false,self.hp_jjc)
		self.shadowHp_jjc.visible = true
	else
		self.shadowHp_jjc.visible = false
	end
end

function FightControllerUI:InitItemData( txt,icon,cdIcon,cdTxt,isOff,pAgentia )
	txt.visible = isOff
	icon.visible = isOff
	cdIcon.visible = isOff
	if cdTxt then
		cdTxt.visible = isOff
	end
	if pAgentia == "hp" then
		self.isActivateHp = true
		self.isNilHp = true
	elseif pAgentia == "mp" then
		self.isActivateMp = true
		self.isNilMp = true
	elseif pAgentia == "hp_jjc" then
		self.isActivateHp_jjc = true
		self.isNilHp_jjc = true
	elseif pAgentia == "mp_jjc" then
		self.isActivateMp_jjc = true
		self.isNilMp_jjc = true
	end
end
function FightControllerUI:SetItemNum(txt,icon,cdIcon,cdTxt,pItemId,pType, num)
	local v = self.model:GetGoodsVoByBid(pItemId)
	local isjjc = false
	if pType == "hp" then
		if v then
			self.itemIdHp = v.id
		else
			self:InitItemData(txt,icon,cdIcon,cdTxt,false,self.hp)
		end
	elseif pType == "mp" then
		if v then
			self.itemIdMp = v.id
		else
			self:InitItemData(txt,icon,cdIcon,cdTxt,false,self.mp)
		end
	elseif pType == "hp_jjc" then
		isjjc = true
		v = pItemId
		if v then
			self.itemIdHp_jjc = v
		else
			self:InitItemData(txt,icon,cdIcon,cdTxt,false,self.hp_jjc)
		end
	elseif pType == "mp_jjc" then
		isjjc = true
		v = pItemId
		if v then
			self.itemIdMp_jjc = v
		else
			self:InitItemData(txt,icon,cdIcon,cdTxt,false,self.mp_jjc)
		end
	end
	if v ~= nil then
		txt.visible = true
		txt.text = math.min(num or 0, 999)
		icon.visible = true
		if isjjc then
			local cfg = GetCfgData("item"):Get(pItemId)
			icon.url = StringFormat("Icon/Goods/{0}", cfg.icon)
		else
			if v:GetCfgData() then
				icon.url = StringFormat("Icon/Goods/{0}",v:GetCfgData().icon)
			end
		end
		cdIcon.visible = false
		if cdTxt then
			cdTxt.visible = false
		end
	else
		txt.visible = false
		icon.visible = false
	end
end
function FightControllerUI:OnClickAgentia(pCdText,pCdIcon,pAgentia)
	if pAgentia == "hp" then
		if self.isActivateHp then return end
		if self.isNilHp then return end
		if self.redDelay and self.redDelay == 0 then
			PkgCtrl:GetInstance():C_UseItem(self.itemIdHp,1)
		end
		self.isActivateHp = true
		self:ExecuteTimer(pCdText,pCdIcon,timer,pAgentia, self.redCD, "auto_drink_hp_key")
	elseif pAgentia == "mp" then
		if self.isActivateMp  then return end
		if self.isNilMp then return end
		if self.blueDelay and self.blueDelay == 0 then
			PkgCtrl:GetInstance():C_UseItem(self.itemIdMp,1)
		end
		self.isActivateMp = true
		self:ExecuteTimer(pCdText,pCdIcon,timer,pAgentia, self.blueCD, "auto_drink_mp_key")
	elseif pAgentia == "hp_jjc" then
		if self.isActivateHp_jjc then return end
		if self.isNilHp_jjc then return end
		if self.redDelay_jjc and self.redDelay_jjc == 0 then
			TiantiController:GetInstance():C_UseTiantiItem(self.itemIdHp_jjc, 1)
		end
		self.isActivateHp_jjc = true
		self:ExecuteTimer(pCdText,pCdIcon,timer,pAgentia, self.redCD_jjc, "auto_drink_hp_key_jjc")
	elseif pAgentia == "mp_jjc" then
		if self.isActivateMp_jjc then return end
		if self.isNilMp_jjc then return end
		if self.blueDelay_jjc and self.blueDelay_jjc == 0 then
			TiantiController:GetInstance():C_UseTiantiItem(self.itemIdMp_jjc, 1)
		end
		self.isActivateMp_jjc = true
		self:ExecuteTimer(pCdText,pCdIcon,timer,pAgentia, self.blueCD_jjc, "auto_drink_mp_key_jjc")
	end
	EffectMgr.PlaySound("731011")
end

function FightControllerUI:ExecuteTimer(pCdText,pCdIcon,timer,pAgentia, cd, id)
	if pCdText then
		pCdText.visible = true
	end
	pCdIcon.visible = false
	RenderMgr.Add(function () self:ResetInit(pCdText,pCdIcon,pIsActivate,id,pAgentia, cd) end, id)
end

function FightControllerUI:ResetInit(pCdText,pCdIcon,pIsActivate,id,pAgentia, cd)
	local finish = false
	local delay = 0
	local isjjc = false
	if pAgentia == "hp" then
		self.redDelay = self.redDelay + Time.deltaTime
		delay = self.redDelay
		self.isActivateHp = cd - delay > 0
	elseif pAgentia == "mp" then
		self.blueDelay = self.blueDelay + Time.deltaTime
		delay = self.blueDelay
		self.isActivateMp = cd - delay > 0
	elseif pAgentia == "hp_jjc" then
		isjjc = true
		self.redDelay_jjc = self.redDelay_jjc + Time.deltaTime
		delay = self.redDelay_jjc
		self.isActivateHp_jjc = cd - delay > 0
	elseif pAgentia == "mp_jjc" then
		isjjc = true
		self.blueDelay_jjc = self.blueDelay_jjc + Time.deltaTime
		delay = self.blueDelay_jjc
		self.isActivateMp_jjc = cd - delay > 0
	end
	if cd - delay <= 0 then
		if pAgentia == "hp" then
			self.redDelay = 0
		elseif pAgentia == "mp" then
			self.blueDelay = 0
		elseif pAgentia == "hp_jjc" then
			self.redDelay_jjc = 0
		elseif pAgentia == "mp_jjc" then
			self.blueDelay_jjc = 0
		end
		if pCdText then
			pCdText.visible = false
		end
		pCdIcon.visible = false
		RenderMgr.Realse(id)
		if isjjc then
			self:OnHpMpChangeJJC(true)
		else
			self:OnHpMpChange(true)
		end
	else
		if pCdText then
			pCdText.visible = false
		end
		pCdIcon.visible = true
		pCdIcon.fillAmount = (cd - delay) / cd
	end
end

function FightControllerUI:IsFinish( cd, delay )
	
end

function FightControllerUI:AutoAll(data)
	self.isAutoMp = (data == true) or self.isMpClick
	self.isAutoHp = (data == true) or self.isHpClick
	self:AutoHp()
	self:AutoMp()
	self:OnHpMpChange()
end

function FightControllerUI:AutoMp()
	self.btnAutoMpTxt.text = self.isAutoMp and "自动" or self.isMpClick and "自动" or ""
	self.btnAutoMpTxt.visible = self.isMpClick or self.isAutoMp
	self.mpLock.visible = self.isMpClick
end

function FightControllerUI:AutoHp()
	self.btnAutoHpTxt.text = self.isAutoHp and "自动" or self.isHpClick and "自动" or ""
	self.btnAutoHpTxt.visible = self.isHpClick or self.isAutoHp
	self.hpLock.visible = self.isHpClick
end

function FightControllerUI:AutoMpJJC()
	self.btnAutoMpTxt_jjc.visible = self.isAutoMp_jjc
	self.btnAutoMpTxt_jjc.text = self.isAutoMp_jjc and "自动" or ""
end

function FightControllerUI:AutoHpJJC()
	self.btnAutoHpTxt_jjc.visible = self.isAutoHp_jjc
	self.btnAutoHpTxt_jjc.text = self.isAutoHp_jjc and "自动" or ""
end

function FightControllerUI:IsMedicineCanUse()
	local sCtrl = SceneController:GetInstance()
	if sCtrl and sCtrl:IsMainPlayerDizzy() then
		return false
	end
	return true
end

function FightControllerUI:OnClickMp()
	if not self:IsMedicineCanUse() then return end
	self.doubleMp = not self.doubleMp
	if self.doubleMp then
		self.isMpClick = not self.isMpClick
		-- self.isAutoMp = not self.isAutoMp
		self.isAutoMp = self.isMpClick
		self:AutoMp()
	else
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		if playerVo.mpMax  > playerVo.mp then
			self:OnClickAgentia(self.btnAgentiacdTxt02,self.btnAgentiaCdIcon02,self.mp)
		end
	end
	--模拟双击
	DelayCall(function () self.doubleMp = true end, 0.3)
	self.stgModel:SetCB( StgConst.KeyType.AutoMp, self.isMpClick )
end

function FightControllerUI:OnClickHp()
	if not self:IsMedicineCanUse() then return end
	self.doubleHp = not self.doubleHp
	if self.doubleHp then
		self.isHpClick = not self.isHpClick
		-- self.isAutoHp = not self.isAutoHp
		self.isAutoHp = self.isHpClick
		self:AutoHp()
	else
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		if playerVo.hpMax  > playerVo.hp then
			self:OnClickAgentia(self.btnAgentiacdTxt01,self.btnAgentiaCdIcon01,self.hp)
		end
	end
	--模拟双击
	DelayCall(function () self.doubleHp = true end, 0.3)
	self.stgModel:SetCB( StgConst.KeyType.AutoHp, self.isHpClick )
end

function FightControllerUI:OnClickHpTianti()
	if not self:IsMedicineCanUse() then return end
	self.doubleHp_jjc = not self.doubleHp_jjc
	if self.doubleHp_jjc then
		self.isAutoHp_jjc = not self.isAutoHp_jjc
		self:AutoHpJJC()
	else
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		if playerVo.hpMax  > playerVo.hp then
			self:OnClickAgentia(self.btnAgentiacdTxt03,self.btnAgentiaCdIcon03,self.hp_jjc)
		end
	end
	--模拟双击
	DelayCall(function () self.doubleHp_jjc = true end, 0.3)
end

function FightControllerUI:OnClickMpTianti()
	if not self:IsMedicineCanUse() then return end
	self.doubleMp_jjc = not self.doubleMp_jjc
	if self.doubleMp_jjc then
		self.isAutoMp_jjc = not self.isAutoMp_jjc
		self:AutoMpJJC()
	else
		local playerVo = SceneModel:GetInstance():GetMainPlayer()
		if playerVo.mpMax  > playerVo.mp then
			self:OnClickAgentia(self.btnAgentiacdTxt04,self.btnAgentiaCdIcon04,self.mp_jjc)
		end
	end
	--模拟双击
	DelayCall(function () self.doubleMp_jjc = true end, 0.3)
end

function FightControllerUI.Create( ui, ...)
	return FightControllerUI.New(ui, "#", {...})
end
function FightControllerUI:__delete()
	-- RenderMgr.Realse("player_hpmp_checking")
	RenderMgr.Realse("auto_drink_hp_key")
	RenderMgr.Realse("auto_drink_mp_key")
	RenderMgr.Realse("auto_drink_hp_key_jjc")
	RenderMgr.Realse("auto_drink_mp_key_jjc")
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	self.stgModel:RemoveEventListener(self.setHandler)
	GlobalDispatcher:RemoveEventListener(self.sceneLoadFinishHandler)
	GlobalDispatcher:RemoveEventListener(self.mainPlayerDataChange)
	if self.tiantiModel then
		self.tiantiModel:RemoveEventListener(ttHandler1)
		self.tiantiModel:RemoveEventListener(ttHandler2)
	end
	if self.btnSkillView then
		self.btnSkillView:Destroy()
	end
	self.btnSkillView=nil
end

function FightControllerUI:SetIsTianti(bool)
	self.btnAgentia01.visible = not bool
	self.btnAgentia02.visible = not bool
	self.btnAgentia03.visible = bool
	self.btnAgentia04.visible = bool
end
--初始化pk物品ui
function FightControllerUI:InitPkItem()
	local itemTab = self.tiantiModel:GetPkItemInfo()
	if (not itemTab) or #itemTab == 0 then return end
	self:SetItemNum(self.btnAgentianumTxt03,self.btnAgentiaIcon03,self.btnAgentiaCdIcon03,nil,itemTab[1][2],self.hp_jjc,itemTab[1][3])
	self:SetItemNum(self.btnAgentianumTxt04,self.btnAgentiaIcon04,self.btnAgentiaCdIcon04,nil,itemTab[2][2],self.mp_jjc,itemTab[2][3])
end