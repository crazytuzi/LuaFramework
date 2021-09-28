RoleSelectPanel = BaseClass(BaseView)

function RoleSelectPanel:__init( ... )
	self.id = "RoleSelectPanel"
	self.ui = UIPackage.CreateObject("RoleCreateSelect","RoleSelectPanel")
	self.c1 = self.ui:GetController("c1")
	self.button_role0 = self.ui:GetChild("button_role0")
	self.button_role1 = self.ui:GetChild("button_role1")
	self.button_role2 = self.ui:GetChild("button_role2")
	self.button_delete = self.ui:GetChild("button_delete")
	self.button_back = self.ui:GetChild("button_back")
	self.button_start_game = self.ui:GetChild("button_start_game")
	-- self.image_3D_role_model = self.ui:GetChild("image_3D_role_model")
	self.label_cur_role_name = self.ui:GetChild("label_cur_role_name")
	self.model_touch = self.ui:GetChild("model_touch")
	self.button_role0 = ButtonRole.Create(self.button_role0)
	self.button_role1 = ButtonRole.Create(self.button_role1)
	self.button_role2 = ButtonRole.Create(self.button_role2)
	self.ctrl = LoginController:GetInstance()
	self:InitData()
	self:InitEvent()
	self:InitUI()
end

function RoleSelectPanel:InitEvent()
	self.closeCallback = function () 
		-- RenderMgr.Realse("RoleSelectPanel_LoadRoleModel")
	end
	self.openCallback  = function () 
		LoginModel:GetInstance():SetRoleSelectPanelOpenFlag(true)
 	end
	self.model_touch.onTouchBegin:Add(self.RotationPlayerModel,self)
	self.button_delete.onClick:Add(self.OnBtnDeleteClick, self)

	self.button_back.onClick:Add(self.OnBtnBackClick, self)

	ButtonToDelayClick(self.button_start_game, function ()
		self:OnBtnStartGameClick()
	end, 3)
	for index = 1, LoginConst.ROLE_SELECT_MAX_CNT do
		if not TableIsEmpty(self.buttonRoleList[index]) then
			self.buttonRoleList[index].ui.onClick:Add(function()
				self:OnProfessionItemClick(index)
				end)
		end
	end
	self.eventHandler0 = GlobalDispatcher:AddEventListener(EventName.DELETE_ROLE, function (data)
		self:DeleteRoleHandler(data)
	end)
end

function RoleSelectPanel:InitData()
	self.model = LoginModel:GetInstance()
	self.roles = self.model:GetRoles()
	self.defaultSelectedIndex = 0

	local lastRoleRecord = self.model:GetLastRole()
	if TableIsEmpty(lastRoleRecord) then
		self.curRoleInfo = self.roles[self.defaultSelectedIndex + 1] or {}
		self:SetLastRoleRecord()
	else
		local lastAccount = self.model:GetLastAccount()
		if not TableIsEmpty(lastAccount) then
			if lastAccount.userId == lastRoleRecord.userId then
				local roleInfo ,roleIndex = self.model:GetRoleByPlayerId(lastRoleRecord.playerId)
				if roleInfo then
					self.curRoleInfo = roleInfo
					self.defaultSelectedIndex = roleIndex - 1
				else
					self.curRoleInfo = self.roles[self.defaultSelectedIndex + 1] or {}
					self:SetLastRoleRecord()
				end
			else
				self.curRoleInfo = self.roles[self.defaultSelectedIndex + 1] or {}
				self:SetLastRoleRecord()
			end
		end
	end


	self.roleModel = nil
	self.touchId = -1
	self.lastTouchX = 0

	self.lastSelectedIndex = self.defaultSelectedIndex
	self.openBySource = LoginConst.PANEL_OPEN_SOURCE.NONE
	self.startBtnIconURL = UIPackage.GetItemURL("RoleCreateSelect" , "ksyx")


	self.buttonRoleList = {}
	self.buttonRoleList[1] = self.button_role0
	self.buttonRoleList[2] = self.button_role1
	self.buttonRoleList[3] = self.button_role2

	self:InitButtonRoleListData()
end

function RoleSelectPanel:InitButtonRoleListData()
	for index = 1, #self.buttonRoleList do
		local isHas = false
		if self.roles[index] ~= nil then
			isHas = true
		end
		if not TableIsEmpty(self.buttonRoleList[index]) then
			self.buttonRoleList[index]:SetData(index,  self.roles[index] or {}, LoginConst.ROLE_PANEL_TYPE.SELECT_ROLE, isHas)
		end
	end
end

function RoleSelectPanel:UpdateData()
	self.roles = self.model:GetRoles()
	self:InitButtonRoleListData()
	self.defaultSelectedIndex = 0
	self.curRoleInfo = self.roles[self.defaultSelectedIndex + 1] or {}
	-- if not TableIsEmpty(self.curRoleInfo) then
	-- 	self.model:SetLastRole(self.curRoleInfo.playerId)
	-- end
	self:SetLastRoleRecord()
end

function RoleSelectPanel:SetLastRoleRecord()
	if not TableIsEmpty(self.curRoleInfo) then
		self.model:SetLastRole(self.curRoleInfo.playerId)
	end
end

function RoleSelectPanel:InitUI()
	for index =1, #self.buttonRoleList do
		if not TableIsEmpty(self.buttonRoleList[index]) then
			self.buttonRoleList[index]:SetUI()
		end
	end
	if not TableIsEmpty(self.buttonRoleList[self.defaultSelectedIndex + 1]) then
		self.buttonRoleList[self.defaultSelectedIndex + 1]:SetSelectedStateUI()
		self.c1.selectedIndex = self.defaultSelectedIndex
	end
	self.lastSelectedIndex = self.defaultSelectedIndex + 1

	self:SetUI()
	
	self:SetButtonStartUI()
end

function RoleSelectPanel:UpdateUI()
	self:InitUI()
	if self.buttonRoleList[self.lastSelectedIndex] ~= nil then
		local isSelected = true
		self.buttonRoleList[self.lastSelectedIndex]:SetButtonController(isSelected)
	end
end

function RoleSelectPanel:SetOpenSource(sourceType)
	self.openBySource = sourceType
end

function RoleSelectPanel:OnProfessionItemClick(eventContent)
	EffectMgr.PlaySound("731001")
	local curIndex = eventContent
	if self.lastSelectedIndex ~= curIndex then
		self.lastSelectedIndex = curIndex
		local curRoleInfo = self.roles[self.lastSelectedIndex] or {}
		local isHas = false
		local hasRoleInfo = {}
		if curRoleInfo ~= nil and curRoleInfo.career ~= nil then
			isHas , hasRoleInfo = self.model:IsHasRole(self.lastSelectedIndex)
		end

		if isHas == false then
			self:Close()
			self.ctrl:OpenRoleCreatePanel()
			if self.ctrl.view.curPanel ~= nil then
				self.ctrl.view.curPanel:SetOpenSource(LoginConst.PANEL_OPEN_SOURCE.SELECT_PANEL)
			end
		else
			self:SetData()
			if not TableIsEmpty(self.buttonRoleList[self.lastSelectedIndex]) then
				self.buttonRoleList[self.lastSelectedIndex]:SetSelectedStateUI()
				self.c1.selectedIndex = self.lastSelectedIndex - 1
			end
			self:SetButtonRoleUnSelectUI()
			self:SetUI()


		end
	end
end

function RoleSelectPanel:SetButtonRoleUnSelectUI()
	for index = 1, #self.buttonRoleList do
		if self.lastSelectedIndex ~= index then
			if not TableIsEmpty(self.buttonRoleList[index]) then
				self.buttonRoleList[index]:SetUnSelectedStateUI()
			end
		end
	end
end
function RoleSelectPanel:SetData()
	self.roles = self.model:GetRoles()
	self.curRoleInfo = self.roles[self.lastSelectedIndex] or {}
	self:SetLastRoleRecord()
end

function RoleSelectPanel:SetUI()
	-- RenderMgr.Add(function () 
	-- 	local roleNode = GameObject.Find("RoleNode")
	-- 	if roleNode ~= nil then
	-- 		self:LoadRoleModel()
	-- 	end
	-- end, "RoleSelectPanel_LoadRoleModel")

	self.layerOutTimer = nil
	self.layerOutTimer= Timer.New(function () 
		local roleNode = GameObject.Find("RoleNode")
		if roleNode ~= nil and self.layerOutTimer ~= nil then
			self:LoadRoleModel()
			self.layerOutTimer:Stop()
			self.layerOutTimer=nil
		end
	end, 0.2, -1, 1)
	self.layerOutTimer:Start()
end
function RoleSelectPanel:LoadRoleModel()
	if self.weapon then
		destroyImmediate(self.weapon) 
	end
	if self.weaponEft then
		destroyImmediate(self.weaponEft) 
	end
	if self.wingEntity then
		destroyImmediate(self.wingEntity)
	end

	if self.curRoleInfo ~= nil and self.curRoleInfo.career ~= nil then
		local modelResName = self.curRoleInfo.dressStyle
		self:DestroyRoleModel()
		self:LockBtn(false)
		local roleNode = GameObject.Find("RoleNode").transform
		roleNode:Find("Camera").gameObject:SetActive(true)
		LoadPlayer(modelResName, function ( modelObj )
			if modelObj ==nil then self:LockBtn(true) return end
			local model = GameObject.Instantiate(modelObj)
			local tf = model.transform
			tf.localPosition = Vector3.New(0, 0, 0)
			tf.localScale = Vector3.New(1, 1, 1)
			tf.localRotation = Quaternion.Euler(0, 0, 0)
			tf:SetParent(roleNode, false)
			self.roleModel = model
			LuaBindSceneObj.Add(self.roleModel, self)
			self.animator = model:GetComponent("Animator")
			self.cur = nil
			self:Play("showidle")
			self:LockBtn(true)
			local weaponId = self.curRoleInfo.weaponStyle or LoginConst.DefaultWeapon[self.curRoleInfo.career]
			self:TakeOnWeapon(weaponId)
			self:SetWing(self.curRoleInfo.wingStyle)

		end)
	end
end

--旋转角色模型
function RoleSelectPanel:RotationPlayerModel( context )
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.onTouchMove, self )
		Stage.inst.onTouchEnd:Add( self.onTouchEnd, self )
	end
end
--touchmove
function RoleSelectPanel:onTouchMove(context)
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		if self.lastTouchX ~= 0 and self.roleModel ~= nil then
			local tf = self.roleModel.transform
			local rotY = tf.localEulerAngles.y - (evt.x - self.lastTouchX)
			tf.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lastTouchX = evt.x
end
--touchend
function RoleSelectPanel:onTouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lastTouchX = 0
		Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	end
end

function RoleSelectPanel:TakeOnWeapon(creatureID)
	LoadWeapon(creatureID, function ( prefab )
		if prefab == nil then return end
		if ToLuaIsNull(self.roleModel) then  return end
		local parentTran = self.roleModel.transform:Find("weapon01")--获取节点
		if ToLuaIsNull(parentTran) then return end
		local wp = GameObject.Instantiate(prefab)
		local wptf = wp.transform
		self.weapon = wp
		wp.name = creatureID
		wptf.parent = parentTran
		wptf.localPosition = Vector3.zero
		wptf.localRotation = Quaternion.identity
		wptf.localScale = Vector3.one
		self.weaponIsInited = true

		self:SetWeaponLight(parentTran)
	end)
end

function RoleSelectPanel:SetWeaponLight(parentTran)
	local weaponEquipmentId = self.curRoleInfo.weaponEquipmentId
	local cfg = GetCfgData("equipment"):Get(weaponEquipmentId)
	if cfg and cfg.effect ~= 0 then
		EffectMgr.LoadEffect(cfg.effect, function(eft)
			if ToLuaIsNull(parentTran) then return end
			if ToLuaIsNull(eft) then return end
			local tf = eft.transform
		 	tf.parent = parentTran
			tf.localPosition = Vector3.zero
			tf.localRotation = Quaternion.identity
			tf.localScale = Vector3.one
		 	self.weaponEft = eft
		end)
	end
end

--穿上翅膀
function RoleSelectPanel:SetWing(wingStyle)
	if wingStyle == nil or wingStyle == 0 then return end 
	if ToLuaIsNull(self.roleModel)  then return end
	local parentTran = Util.GetChild(self.roleModel.transform, "wing")
	if ToLuaIsNull(parentTran) then return end
	LoadWing(wingStyle, function ( prefab )
		if prefab == nil or ToLuaIsNull(parentTran) then return end
		local we = GameObject.Instantiate(prefab)
		self.wingEntity = we
		if (not ToLuaIsNull(we)) and (not ToLuaIsNull(we.transform)) and ToLuaIsNull(we.transform.parent) then
			local tf = we.transform
			we.name = StringFormat("{0}", wingStyle)
			tf.parent = parentTran
			tf.localPosition = Vector3.zero
			tf.localRotation = Quaternion.identity
			tf.localScale = Vector3.one
			self.wingEntityIsInited = true
		end
	end)
end

function RoleSelectPanel:Update(dt)
	if self.animator then 
		local normalized = self.animator:GetCurrentAnimatorStateInfo(0).normalizedTime
		if normalized >=1 then
			--简单写
			if self.cur == "showidle" then
				return
			end
			self:Play("showidle")
			self.cur = "showidle"
		end
	end
end

function RoleSelectPanel:Play(clip)
	local modelId = LoginConst.ROLE_MODEL_RES[self.curRoleInfo.career]
	local res = LoginConst.Effect[modelId][clip]
	if self.animator then self.animator:Play(clip) end
end

--创建模型的时候锁住按钮
function RoleSelectPanel:LockBtn(bool)
	for index = 1, #self.buttonRoleList do
		if not TableIsEmpty(self.buttonRoleList[index]) then
			self.buttonRoleList[index].ui.enabled = bool
		end
	end
end

function RoleSelectPanel:OnBtnDeleteClick()
	--等后端提供接口
	--UIMgr.Win_FloatTip("功能正在开发中")
	--“确定要删除角色？删除角色后将永久不能使用此角色” “确定”“取消” (家哥提的需求)
	local isHas , hasRoleInfo = self.model:IsHasRole(self.lastSelectedIndex)
	if isHas == true then
		if hasRoleInfo.level >= LoginConst.RoleDeleteLimitLev then
			local strTips = StringFormat("{0}级及以上的角色不能被删除" , LoginConst.RoleDeleteLimitLev)
			UIMgr.Win_FloatTip(strTips)
			return
		end
	end

	EffectMgr.PlaySound("731001")
	if self.model:GetRolesCnt() > 1 then
		UIMgr.Win_Confirm("提示", "确定要删除角色？", "确认", "取消", 
		function ()
			local isHas, hasRoleInfo =  self.model:IsHasRole(self.lastSelectedIndex)
			if isHas == true then
				self.ctrl:C_DeletePlayer(hasRoleInfo.playerId)
			end
		end,
		function()
		end)
	elseif self.model:GetRolesCnt() == 1 then
		UIMgr.Win_Alter("提示", "请至少保留一个角色", "确认",  function() end)
	elseif self.model:GetRolesCnt() == 0 then
		UIMgr.Win_Alter("提示", "当前无角色可删除", "确认", function() end)
	end
end

function RoleSelectPanel:OnBtnBackClick()
	--关闭当前界面，打开登录选服界面
	EffectMgr.PlaySound("731001")
	self:Close()
	self.ctrl.kickState=true
	Network.ResetLinkTimes()
	Network.CloseSocket()
	if isSDKPlat then
		SceneLoader.Show(true, false, 100, 100, "", "")
		SceneLoader.ShowProgress(false)
		SceneLoader.ShowIcon("loader")
		sdkToIOS:OpenLogin()
	else
		self.ctrl:OpenLoginPanel()
	end 
	
end

function RoleSelectPanel:OnBtnStartGameClick()
	EffectMgr.PlaySound("731001")
	-- RenderMgr.Realse("RoleSelectPanel_LoadRoleModel")
	if table.nums(self.curRoleInfo) > 0 then
		local isHas, hasRoleInfo =  self.model:IsHasRole(self.lastSelectedIndex);
		if isHas == true then
			self.ctrl:C_EnterGame(hasRoleInfo.playerId);
		end
	end
end

function RoleSelectPanel:SetButtonStartUI()
	if self.button_start_game then
		self.button_start_game.icon = self.startBtnIconURL
	end
end

function RoleSelectPanel:CleanEvent()
	-- RenderMgr.Realse("RoleSelectPanel_LoadRoleModel")
	GlobalDispatcher:RemoveEventListener(self.eventHandler0)
end

function RoleSelectPanel:DeleteRoleHandler(data)
	self:UpdateData()
	self:UpdateUI()
end

function RoleSelectPanel:DestroyRoleModel()
	-- RenderMgr.Realse("RoleSelectPanel_LoadRoleModel")
	if self.roleModel ~= nil then
		if self.effectId then
			EffectMgr.RealseEffect(self.effectId)
		end
		self.effectId = nil

		if self.curRoleInfo and self.curRoleInfo.dressStyle then
			UnLoadPlayer(self.curRoleInfo.dressStyle , false)
		end
		destroyImmediate(self.roleModel)
	end
end

function RoleSelectPanel:CleanData()
	if self.button_role0 then
		self.button_role0:Destroy()
	end
	if self.button_role1 then
		self.button_role1:Destroy()
	end
	if self.button_role2 then
		self.button_role2:Destroy()
	end

	self.roles = {}
	self.defaultSelectedIndex = 0
	self.curRoleInfo = {}
	self.lastSelectedIndex = 0
	self.buttonRoleList = {}
end

function RoleSelectPanel:__delete()
	if self.layerOutTimer then
		self.layerOutTimer:Stop()
		self.layerOutTimer=nil
	end
	if isSDKPlat then
		SceneLoader.Show(false)
	end
	self:CleanEvent()
	self:DestroyRoleModel()
	self:CleanData()

	self.animator = nil
	self.roleModel = nil
	self.button_delete = nil
	self.button_back = nil
	self.button_start_game = nil
	-- self.image_3D_role_model = nil
	self.label_cur_role_name = nil
	self.button_role0 = nil
	self.button_role1 = nil
	self.button_role2 = nil
end