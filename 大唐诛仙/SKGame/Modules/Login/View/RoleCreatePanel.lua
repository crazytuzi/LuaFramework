RoleCreatePanel = BaseClass(BaseView)
function RoleCreatePanel:__init( ... )
	self.ui = UIPackage.CreateObject("RoleCreateSelect","RoleCreatePanel")
	self.c1 = self.ui:GetController("c1")
	self.image_skill_preview_bg = self.ui:GetChild("image_skill_preview_bg")
	-- self.loader_skill_shade = self.ui:GetChild("loader_skill_shade")
	self.button_role0 = self.ui:GetChild("button_role0")
	self.button_role1 = self.ui:GetChild("button_role1")
	self.button_role2 = self.ui:GetChild("button_role2")
	self.button_role3 = self.ui:GetChild("button_role3")
	self.label_career_desc = self.ui:GetChild("label_career_desc")

	self.button_back = self.ui:GetChild("button_back")
	self.label_name_input = self.ui:GetChild("label_name_input")
	self.button_random = self.ui:GetChild("button_random")
	self.skill_preview_list = self.ui:GetChild("skill_preview_list")
	self.image_role_name = self.ui:GetChild("image_role_name")
	self.image_attrbution_bg = self.ui:GetChild("image_attrbution_bg")
	self.label_profession_attr = self.ui:GetChild("label_profession_attr")
	self.image_role_3D_model = self.ui:GetChild("image_role_3D_model")
	self.button_role_create = self.ui:GetChild("button_role_create")
	self.model_touch = self.ui:GetChild("model_touch")
	
	self.button_role0 = ButtonRole.Create(self.button_role0)
	self.button_role1 = ButtonRole.Create(self.button_role1)
	self.button_role2 = ButtonRole.Create(self.button_role2)
	self.button_role3 = ButtonRole.Create(self.button_role3)
	self.ctrl = LoginController:GetInstance()
	self:InitData()
	self:InitEvent()
	self:InitUI()
end
function RoleCreatePanel:InitEvent()
	self.closeCallback = function ()
		RenderMgr.Realse("RoleSelectPanel_LoadRoleModel2")
		if self.effectId then
			EffectMgr.RealseEffect(self.effectId)
		end
	end

	self.button_back.onClick:Add(self.OnButtonBackClick, self)
	self.button_back.enabled=not isSDKPlat
	self.button_back.visible=not isSDKPlat


	self.button_random.onClick:Add(self.OnButtonRandomClick, self)

	ButtonToDelayClick(self.button_role_create, function ()
		self:OnButtonCreateRoleClick()
	end, 3)

	for index = 1, LoginConst.ROLE_CREATE_MAX_CNT do
		if self.buttonRoleList[index] then
			self.buttonRoleList[index].ui.onClick:Add(function()
				self:OnButtonProfessionItemClick(index)
			end)
		end
	end
end

function RoleCreatePanel:ClearEvent()
	self.button_back.onClick:Remove(self.OnButtonBackClick, self)
	self.button_random.onClick:Remove(self.OnButtonRandomClick, self)
	self.button_role_create.onClick:Remove(self.OnButtonCreateRoleClick, self)
end


function RoleCreatePanel:InitData()
	self.model = LoginModel:GetInstance()
	self.allRoleInfo = self.model:GetAllRolesInfo() or {}
	self.defaultSelectedIndex = 0
	self.touchId = -1
	self.lastTouchX = 0

	self.curRoleInfo = self.allRoleInfo[self.defaultSelectedIndex + 1] or {}
	
	self.lastSelectedIndex = self.defaultSelectedIndex + 1
	self.curPanelType = LoginConst.ROLE_PANEL_TYPE.CREATE_ROLE
	self.openBySource = LoginConst.PANEL_OPEN_SOURCE.NONE
	self.roleModel = nil
	self.roleEffect = nil
	self.createBtnIconURL = UIPackage.GetItemURL("RoleCreateSelect" , "cjjs")

	-- self.roleCareerShadeURL = {}
	-- self.roleCareerShadeURL[1] = UIPackage.GetItemURL("RoleCreateSelect", "战士底纹")
	-- self.roleCareerShadeURL[2] = UIPackage.GetItemURL("RoleCreateSelect", "法师底纹")
	-- self.roleCareerShadeURL[3] = UIPackage.GetItemURL("RoleCreateSelect", "暗巫底纹")

	self.buttonRoleList = {}
	self.buttonRoleList[1] = self.button_role0
	self.buttonRoleList[2] = self.button_role1
	self.buttonRoleList[3] = self.button_role2
	self.buttonRoleList[4] = self.button_role3

	for index = 1, #self.buttonRoleList do
		local isHas = false
		if self.allRoleInfo[index] ~= nil then
			isHas = true
		end
		self.buttonRoleList[index]:SetData(index,  self.allRoleInfo[index] or {}, LoginConst.ROLE_PANEL_TYPE.CREATE_ROLE, isHas)
	end
end

function RoleCreatePanel:ClearData()
	self.model = nil
	if not ToLuaIsNull(self.roleModel) then
		destroyImmediate(self.roleModel)
	end
	self.roleModel = nil
	self.allRoleInfo = {}
	self.defaultSelectedIndex = 0
	self.curRoleInfo = {}
	self.lastSelectedIndex = 0
	self.curPanelType = nil
	self.openBySource = nil
end

function RoleCreatePanel:SetData()
	self.allRoleInfo = self.model:GetAllRolesInfo()
	self.curRoleInfo = self.allRoleInfo[self.lastSelectedIndex] or {}
end

function RoleCreatePanel:InitUI()
	for index = 1, #self.buttonRoleList do
		self.buttonRoleList[index]:SetUI()
	end
	self.buttonRoleList[self.defaultSelectedIndex + 1]:SetSelectedStateUI()
	if #self.allRoleInfo < LoginConst.ROLE_CREATE_MAX_CNT then
		self.buttonRoleList[LoginConst.ROLE_CREATE_MAX_CNT].ui.touchable = false
	end

	self.skill_preview_list = ListSkillPreview.Create(self.skill_preview_list)
	self:SetSkillPreviewUI()
	self.label_name_input = LabelNameInput.Create(self.label_name_input, self.curRoleInfo)
	-- RenderMgr.Add(function () 
		-- local roleNode = GameObject.Find("RoleNode")
		-- if roleNode ~= nil then
		-- 	self.roleEffect = GameObject.New("roleEffect")
		-- 	self.label_name_input:SetUI()
		-- 	self:LoadRoleModel()
		-- 	self:SetRoleDescUI()
		-- 	self:SetButtonCreateRoleUI()
			-- RenderMgr.Realse("render_roleNode")
		-- end
	-- end, "render_roleNode")

	self.layerOutTimer = nil
	self.layerOutTimer= Timer.New(function () 
		local roleNode = GameObject.Find("RoleNode")
		if roleNode ~= nil then
			self.roleEffect = GameObject.New("roleEffect")
			self.label_name_input:SetUI()
			self:LoadRoleModel()
			self:SetRoleDescUI()
			self:SetButtonCreateRoleUI()
			self.layerOutTimer:Stop()
			self.layerOutTimer=nil
		end
	end, 0.2, -1, 1)
	self.layerOutTimer:Start()
end

function RoleCreatePanel:ClearUI()
	self.skill_preview_list:Destroy()
	self.label_name_input:Destroy()
	if self.effectId then
		EffectMgr.RealseEffect(self.effectId)
	end
	self.effectId = nil
end

function RoleCreatePanel:SetOpenSource(sourceType)
	self.openBySource = sourceType
end

function RoleCreatePanel:SetUI()
	self:LoadRoleModel()
	self:SetRoleDescUI()
	self:SetSkillPreviewUI()
	self.buttonRoleList[self.lastSelectedIndex]:SetSelectedStateUI()
end


--旋转角色模型
function RoleCreatePanel:RotationPlayerModel( context )
	if self.touchId == -1 then
		local evt = context.data
		self.touchId = evt.touchId
		Stage.inst.onTouchMove:Add( self.onTouchMove, self )
		Stage.inst.onTouchEnd:Add( self.onTouchEnd, self )
	end
end
--touchmove
function RoleCreatePanel:onTouchMove(context)
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		local evt = context.data
		local tf = self.roleModel.transform
		if self.lastTouchX ~= 0 then
			local rotY = tf.localEulerAngles.y - (evt.x - self.lastTouchX)
			tf.localEulerAngles = Vector3.New(0, rotY, 0)
		end
	end
	self.lastTouchX = evt.x
end
--touchend
function RoleCreatePanel:onTouchEnd( context )
	local evt = context.data
	if evt and self.touchId ~= -1 and evt.touchId == self.touchId then
		self.touchId = -1
		self.lastTouchX = 0
		Stage.inst.onTouchMove:Remove(self.onTouchMove, self)
		Stage.inst.onTouchEnd:Remove(self.onTouchEnd,self)
	end
end


function RoleCreatePanel:SetSkillPreviewUI()
	self.skill_preview_list:SetUI(self.curRoleInfo.skillDisplay or {})
end


function RoleCreatePanel:OnButtonBackClick()
	soundMgr:StopEffect()
	EffectMgr.PlaySound("731001")
	if self.openBySource == LoginConst.PANEL_OPEN_SOURCE.LOGIN_PANEL then
		self.ctrl:OpenLoginPanel()
	elseif self.openBySource == LoginConst.PANEL_OPEN_SOURCE.SELECT_PANEL then
		self.ctrl:OpenRoleSelectPanel()
		if self.ctrl.view.curPanel ~= nil then
			self.ctrl.view.curPanel:SetOpenSource(LoginConst.PANEL_OPEN_SOURCE.CREATE_PANEL)
		end
	end
end

function RoleCreatePanel:OnButtonRandomClick()
	--EffectMgr.PlaySound("731001")
	self.label_name_input:SetUI()
end


function RoleCreatePanel:OnButtonCreateRoleClick()
	--EffectMgr.PlaySound("731001")
	self:CreateRole()
end

function RoleCreatePanel:CreateRole()
	local curRandomName = self.label_name_input:GetRandomName()
	if curRandomName ~= nil and table.nums(self.curRoleInfo) > 0 then
		if string.utf8len(string.trim(curRandomName)) < 2  or string.utf8len(string.trim(curRandomName)) > 7 then
			UIMgr.Win_FloatTip("角色昵称为2-7字");
			return;
		end

		if isExistSensitive(curRandomName) then
			UIMgr.Win_FloatTip("角色昵称包含敏感字或特殊字符")
			return
		end
		
		RenderMgr.Realse("RoleSelectPanel_LoadRoleModel2")
		self.ctrl:C_CreatePlayer(self.curRoleInfo.career, curRandomName);
	end
end

function RoleCreatePanel:OnButtonProfessionItemClick(index)
	--EffectMgr.PlaySound("731001")

	local curIndex = index
	if self.lastSelectedIndex ~= curIndex then
		self.lastSelectedIndex = curIndex
		if self.lastSelectedIndex  > #self.model:GetAllRolesInfo() then
			self.buttonRoleList[self.lastSelectedIndex]:SetUnSelectedStateUI()
		else
			self:SetData()
			if self.label_name_input then
				self.label_name_input:UpdateRoleInfo(self.curRoleInfo)
			end
			
			self:SetRoleButtonListUnSelectUI()
			self:SetUI()
		end
	end
end

function RoleCreatePanel:SetRoleButtonListUnSelectUI()
	for index = 1, #self.buttonRoleList do
		if index ~= self.lastSelectedIndex then
			self.buttonRoleList[index]:SetUnSelectedStateUI()
		end
	end
end

function RoleCreatePanel:LoadRoleModel()
	self:DestroyRoleModel()
	if self.curRoleInfo and self.curRoleInfo.career then
		local roleNode = GameObject.Find("RoleNode").transform
		roleNode:Find("Camera").gameObject:SetActive(true)
		local modelResName = self:GetCurRoleModelName()
		if modelResName ~= "" then
			LoadPlayer(modelResName, function ( modelObj )
				if ToLuaIsNull(modelObj) then self:LockBtn(false) return end
				local model = GameObject.Instantiate(modelObj)
				local tf = model.transform
				tf.localPosition = Vector3.New(0, 0, 0)
				tf.localScale = Vector3.New(1, 1, 1)
				tf.localRotation = Quaternion.Euler(0, 0, 0)
				tf:SetParent(roleNode, false)
				self.roleModel = model
				LuaBindSceneObj.Add(self.roleModel, self)
				local weaponStyle = LoginConst.ShowWeapon[self.curRoleInfo.career];
				self:TakeOnWeapon(weaponStyle)
				local wingStyle = LoginConst.ShowWing[self.curRoleInfo.career];
				self:TakeOnWing(wingStyle)
				self.animator = model:GetComponent("Animator")
				self.cur = nil 
				RenderMgr.Realse("RoleSelectPanel_LoadRoleModel2")
				RenderMgr.Add(function () self:Update() end, "RoleSelectPanel_LoadRoleModel2")
				self:Play("appear")
				self:PlayRoleCreateShowEffectSound()
				self:LockBtn(true)
			end)
		end
	end
end

function RoleCreatePanel:GetCurRoleModelName()
	local rtnModelName = ""
	if self.curRoleInfo and self.curRoleInfo.career then
		rtnModelName = LoginConst.ShowFashion[self.curRoleInfo.career]
	end
	return rtnModelName
end

function RoleCreatePanel:PlayRoleCreateShowEffectSound()
	if self.curRoleInfo and self.curRoleInfo.career then
		local soundId = LoginConst.RoleCreateShowSound[self.curRoleInfo.career] or 0
		if soundId ~= 0 then
			soundMgr:StopEffect()
			EffectMgr.PlaySound(soundId)
		end
	end
end

function RoleCreatePanel:TakeOnWeapon(creatureID)
	LoadWeapon(creatureID, function ( prefab )
		if prefab == nil then return end
		if not ToLuaIsNull(self.roleModel) then
			local parentTran = self.roleModel.transform:Find("weapon01") -- 获取节点
			self.weapon = GameObject.Instantiate(prefab)
			self.weapon.name = creatureID
			local tf = self.weapon.transform
			tf.parent = parentTran
			tf.localPosition = Vector3.zero
			tf.localRotation = Quaternion.identity
			tf.localScale = Vector3.one
			self.weaponIsInited = true
		end
	end)
end

--穿上翅膀
function RoleCreatePanel:TakeOnWing(wingStyle)
	if wingStyle == nil or wingStyle == 0 then return end 
	if ToLuaIsNull(self.roleModel)  then return end
	local parentTran = Util.GetChild(self.roleModel.transform, "wing")
	if ToLuaIsNull(parentTran) then return end
	LoadWing(wingStyle, function ( prefab )
		if prefab == nil or ToLuaIsNull(parentTran) then return end
		local wp = GameObject.Instantiate(prefab)
		self.wingEntity = wp
		local wptf = wp.transform
		if (not ToLuaIsNull(wp)) and (not ToLuaIsNull(wptf)) and ToLuaIsNull(wptf.parent) then
			wp.name = StringFormat("{0}", wingStyle)
			wptf.parent = parentTran
			wptf.localPosition = Vector3.zero
			wptf.localRotation = Quaternion.identity
			wptf.localScale = Vector3.one
			self.wingEntityIsInited = true
		end
	end)
end

function RoleCreatePanel:Update()
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

function RoleCreatePanel:Play(clip)	
	local modelId = LoginConst.ROLE_MODEL_RES[self.curRoleInfo.career]
	if modelId  and LoginConst.Effect[modelId][clip] then
		self:LoadEffect(LoginConst.Effect[modelId][clip], function ()
			if self.roleModel and self.animator then
				self.animator:Play(clip)
			end
		end)
	end
end

function RoleCreatePanel:LoadEffect(res, loadCB)
	if not res then return end
	if self.effectId then
		EffectMgr.RealseEffect(self.effectId)
	end
	if self.roleEffect then
		local callback = function (id)
			local effectGo = EffectMgr.GetEffectById(id)
			local tf = effectGo.transform
			tf.localScale = Vector3.New(1,1,1)
			local roleNode = GameObject.Find("RoleNode")
			if roleNode then
				tf:SetParent(roleNode.transform, false)
				tf.localPosition=Vector3.New(-3, 0, -2)
			end
			if loadCB then loadCB() end
		end
		self.effectId = EffectMgr.BindTo(res, self.roleEffect,nil,nil,nil,nil,callback,nil,1,nil,nil)
	end
end

function RoleCreatePanel:LockBtn(bool)
	for index = 1, #self.buttonRoleList do
		self.buttonRoleList[index].ui.enabled = bool
	end
end
function RoleCreatePanel:SetRoleDescUI()
	if self.curRoleInfo ~= nil and self.curRoleInfo.career ~= nil then
		-- self.loader_skill_shade.url = self.roleCareerShadeURL[self.curRoleInfo.career] or ""
		self.image_role_name.url = self:GetRoleNameURL()
		self.label_profession_attr.text = LoginConst.ROLE_ATTR_DESC[self.curRoleInfo.career]
		local careerDescList = self:GetRoleCareerDesc()
		if not TableIsEmpty(careerDescList) then
			self.label_career_desc.text = StringFormat("{0}\n    {1}", careerDescList[1] , careerDescList[2])
		end
	end
end

function RoleCreatePanel:GetRoleCareerDesc()
	if self.curRoleInfo and self.curRoleInfo.career then
		local careerDefaultInfo = GetCfgData("newroleDefaultvalue"):Get(self.curRoleInfo.career)
		if careerDefaultInfo and careerDefaultInfo.careerDesc then
			local strList = StringSplit(careerDefaultInfo.careerDesc , "|")
			if #strList ~= 0 then
				return strList
			end
		end
	end
	return {}
end

function RoleCreatePanel:GetRoleNameURL()
	local rtnURL = ""
	if self.curRoleInfo and self.curRoleInfo.career then
		local career = self.curRoleInfo.career or 0
		if career == 1 then
			rtnURL = UIPackage.GetItemURL("RoleCreateSelect" , "cb1")
		elseif career == 2 then
			rtnURL = UIPackage.GetItemURL("RoleCreateSelect" , "cb2")
		elseif career == 3 then
			rtnURL = UIPackage.GetItemURL("RoleCreateSelect" , "cb3")
		end
	end
	return rtnURL
end

function RoleCreatePanel:SetButtonCreateRoleUI()
	self.button_role_create.icon = self.createBtnIconURL
end

function RoleCreatePanel:DestroyRoleModel()
	-- RenderMgr.Realse("render_roleNode")
	RenderMgr.Realse("RoleSelectPanel_LoadRoleModel2")
	if self.effectId then
		EffectMgr.RealseEffect(self.effectId)
	end
	self.effectId = nil
	if not ToLuaIsNull(self.roleModel) then
		local modelResName = self:GetCurRoleModelName()
		if modelResName ~= "" then  UnLoadPlayer(modelResName , false) end
		destroyImmediate(self.roleModel)
	end
	self.roleModel = nil
	self.animator = nil
end

function RoleCreatePanel:DestroyRoleEffect()
	if self.roleEffect ~= nil then
		destroyImmediate(self.roleEffect)
	end
end

function RoleCreatePanel:__delete()
	if self.layerOutTimer then
		self.layerOutTimer:Stop()
		 self.layerOutTimer=nil
	end
	self.animator = nil
	self:DestroyRoleModel()
	self:DestroyRoleEffect()
	self:ClearData()
	if self.button_role0 then self.button_role0:Destroy() end
	if self.button_role1 then self.button_role1:Destroy() end
	if self.button_role2 then self.button_role2:Destroy() end
	if self.button_role3 then self.button_role3:Destroy() end
	if self.skill_preview_list then
		self.skill_preview_list:Destroy()
	end
	if self.label_name_input then
		self.label_name_input:Destroy()
	end
end