local CCreateRoleMainPage = class("CCreateRoleMainPage", CPageBase)
CCreateRoleMainPage.RANDOMIDX = 0
function CCreateRoleMainPage.ctor(self, obj)
	CPageBase.ctor(self, obj)
end

function CCreateRoleMainPage.OnInitPage(self)
	self.m_LoginBtn = self:NewUI(1, CButton)
	self.m_BranchBtn = self:NewUI(2, CSpineTexture)
	self.m_CreateBtn = self:NewUI(3, CButton)
	self.m_SchoolSprite = self:NewUI(4, CSprite)
	self.m_SchoolTextSprite = self:NewUI(5, CSprite)
	self.m_BranchSprite1 = self:NewUI(6, CSprite)
	self.m_BranchSprite2 = self:NewUI(7, CSprite)
	self.m_BtnGrid = self:NewUI(8, CGrid)
	self.m_NameInput = self:NewUI(9, CInput)
	self.m_RandomNameBtn = self:NewUI(10, CButton)
	self.m_MountObj = self:NewUI(11, CObject)
	self.m_AvatarList = {
		{shape = 130, school = 2, branch = 1, sex = "male",},
		{shape = 140, school = 2, branch = 1, sex = "female",},
		{shape = 150, school = 3, branch = 1, sex = "male",},
		{shape = 160, school = 3, branch = 1, sex = "female",},
		{shape = 110, school = 1, branch = 1, sex = "male",},
		{shape = 120, school = 1, branch = 1, sex = "female",},
	}
	self:InitContent()
end

function CCreateRoleMainPage.InitContent(self)
	self.m_HasCheck = false
	g_MapCtrl:AddCtrlEvent(self:GetInstanceID(), callback(self, "OnMapEvent"))
	self.m_RandomNameBtn:AddUIEvent("click", callback(self, "RandomName"))
	self.m_BranchBtn:SetActive(false)

	self:CheckMap()
	self.m_LoginBtn:AddUIEvent("click", callback(self, "OnClickLogin"))
	self.m_BranchBtn:AddUIEvent("click", callback(self, "OnClickBranch"))
	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnClickCreate"))
	self.m_BtnGrid:InitChild(callback(self, "InitGrid"))
	local iRandon = Utils.RandomInt(1, self.m_BtnGrid:GetCount())
	self:OnSelect(self.m_BtnGrid:GetChild(iRandon))
	self:RandomName()
	self.m_BranchBtn:ShapeCreateRole("denglong", function()
			if Utils.IsExist(self.m_BranchBtn) then
				self.m_BranchBtn:SetAnimation(0, "doudong", false)
			end
		end)
end


function CCreateRoleMainPage.RandomName(self, oBtn)
	local oldName
	local oMaskTree = g_MaskWordCtrl:GetMaskWordTree()
	local function getone()
		local sName = ""
		local len = #oMaskTree:GetCharList(sName)
		local first,mid,last= "", "", ""
		local firstdata, randomvalue 
		while (len < 2) or (len > 6) or sName == oldName do
			math.randomseed(os.time()+CCreateRoleMainPage.RANDOMIDX)
			math.random()
			CCreateRoleMainPage.RANDOMIDX = CCreateRoleMainPage.RANDOMIDX + 1
			oldName = self.m_NameInput:GetText()
			firstdata = data.randomnamedata.FIRST[math.random(1, #data.randomnamedata.FIRST)]
			first = firstdata.first

			math.randomseed(os.time()+CCreateRoleMainPage.RANDOMIDX)
			math.random()
			CCreateRoleMainPage.RANDOMIDX = CCreateRoleMainPage.RANDOMIDX + 1
			mid = ""
			randomvalue = math.random(1, 100)
			if randomvalue <= 70 and firstdata.mid then
				randomvalue = math.random(1, #firstdata.mid)
				mid = firstdata.mid[randomvalue] or ""
			end

			math.randomseed(os.time()+CCreateRoleMainPage.RANDOMIDX)
			math.random()
			CCreateRoleMainPage.RANDOMIDX = CCreateRoleMainPage.RANDOMIDX + 1
			last = ""
			if g_CreateRoleCtrl:GetCreateData("sex") == "male" then
				last = data.randomnamedata.MALE[math.random(1, #data.randomnamedata.MALE)]
			else
				last = data.randomnamedata.FEMALE[math.random(1, #data.randomnamedata.FEMALE)]
			end
			sName = first..mid..last
			len = #oMaskTree:GetCharList(sName)
		end
		sName = string.gsub(sName, "^%s*(.-)%s*$", "%1")
		return sName
	end
	local sName = getone()
	if not sName then
		sName = "一个名字"
	end
	self.m_NameInput:SetText(sName)
	self.m_NameSex = g_CreateRoleCtrl:GetCreateData("sex")
	if oBtn then
		g_UploadDataCtrl:CreateRoleUpload({time=g_CreateRoleCtrl.m_ShowTime, click= "随机取名"})
	end
end

function CCreateRoleMainPage.OnMapEvent(self, oCtrl)
	if oCtrl.m_EventID == define.Map.Event.MapLoadDone then
		self:CheckMap()
	end
end

function CCreateRoleMainPage.CheckMap(self)
	if not self.m_HasCheck then
		local obj = g_MapCtrl:GetCurMapObj()
		if obj then
			local transform = obj:Find("Model/Model/Scene_6100_01/Scene_6100_ludeng/deng_long_guadian")
			if transform then
				local oHandler = self.m_MountObj:GetMissingComponent(classtype.HudHandler)
				oHandler.uiCamera = g_CameraCtrl:GetUICamera().m_Camera
				oHandler.gameCamera = g_CameraCtrl:GetCreateRoleCamera().m_Camera
				-- local newObj = UnityEngine.GameObject.New("banchnode")
				-- newObj.transform.parent = transform
				-- newObj.transform.localPosition = Vector3.New(0, 0, 0.33)
				-- newObj.layer = transform.gameObject.layer
				oHandler.target = transform
				oHandler.isAutoUpdate = true
				self.m_BranchBtn:SetActive(true)
				self.m_HasCheck = true
			end
		end
	end
end

function CCreateRoleMainPage.OnSelect(self, oBtn)
	if Utils.IsPlayingCG() then
		return
	end
	if self.m_CurrentBtn ~= nil then
		self.m_CurrentBtn.m_SelectMark:SetActive(false)
		self.m_CurrentBtn.m_RoleSprite:SetActive(true)
		self.m_CurrentBtn.m_BgSprite:SetSpriteName("pic_touxiangkuang_1")
		self.m_CurrentBtn.m_BgSprite:MakePixelPerfect()
		self.m_BranchBtn:SetAnimation(0, "doudong", false)
	end
	self.m_CurrentBtn = oBtn
	oBtn.m_SelectMark:SetActive(true)
	oBtn.m_RoleSprite:SetActive(false)
	g_CreateRoleCtrl:SetCreateData("sex", oBtn.m_Data.sex)
	g_CreateRoleCtrl:SetCreateData("school", oBtn.m_Data.school)
	self.m_CurrentBtn.m_BgSprite:SetSpriteName("pic_touxiangkuang_2")
	self.m_CurrentBtn.m_BgSprite:MakePixelPerfect()
	if self.m_NameSex and self.m_NameSex ~= oBtn.m_Data.sex then
		self:RandomName()
	end
	self.m_SchoolSprite:SetSpriteName("big_".. oBtn.m_Data.school)
	self.m_SchoolTextSprite:SetSpriteName("text_school_".. oBtn.m_Data.school)
	self.m_BranchSprite1:SetSpriteName(string.format("text_school_%s_1", oBtn.m_Data.school))
	self.m_BranchSprite2:SetSpriteName(string.format("text_school_%s_2", oBtn.m_Data.school))

end

function CCreateRoleMainPage.OnClickLogin(self)
	if Utils.IsPlayingCG() then
		return
	end
	if g_CreateRoleCtrl:IsInitDone() then
		CLoginView:ShowView()
		g_CreateRoleCtrl:EndCreateRole()
		g_UploadDataCtrl:CreateRoleUpload({time=g_CreateRoleCtrl.m_ShowTime, click= "返回登录界面"})
	end
end

function CCreateRoleMainPage.OnClickBranch(self)
	if Utils.IsPlayingCG() then
		return
	end
	g_CreateRoleCtrl:SetCreateData("mode", "branch")
	self.m_BranchBtn:AddAnimation(0, "tan", false)
	self.m_ParentView:HideAllPage()
end

function CCreateRoleMainPage.OnClickCreate(self)
	if Utils.IsPlayingCG() then
		return
	end
	g_UploadDataCtrl:CreateRoleUpload({time=g_CreateRoleCtrl.m_ShowTime, click= "创建按钮"})
	local sName = self.m_NameInput:GetText()
	local oMaskTree = g_MaskWordCtrl:GetMaskWordTree()
	local nameLen = #oMaskTree:GetCharList(sName)
	if (nameLen < 2) or (nameLen > 6) then
		g_NotifyCtrl:FloatMsg("角色名字为2-6个字")
		return
	end
	if g_MaskWordCtrl:IsContainMaskWord(sName) then
		g_NotifyCtrl:FloatMsg("名字中包含屏蔽字")
		return
	end
	if not string.isIllegal(sName) then
		g_NotifyCtrl:FloatMsg("含有特殊字符，请重新输入")
		return
	end
	g_CreateRoleCtrl:CreateRole(sName)
end

function CCreateRoleMainPage.InitGrid(self, obj, idx)
	local oBtn = CBox.New(obj)
	oBtn.m_SelectMark = oBtn:NewUI(1, CSprite)
	oBtn.m_RoleSprite = oBtn:NewUI(2, CSprite)
	oBtn.m_BgSprite = oBtn:NewUI(3, CSprite)
	oBtn.m_Data = self.m_AvatarList[idx]

	oBtn.m_RoleSprite:SetSpriteName("pic_role_" .. oBtn.m_Data.shape)
	oBtn.m_SelectMark:SetSpriteName("pic_selrole_" .. oBtn.m_Data.shape)
	-- oBtn.m_SelectMark:MakePixelPerfect()
	oBtn.m_SelectMark:SetActive(false)

	oBtn:AddUIEvent("click", callback(self, "OnSelect", oBtn))
	return oBtn
end

function CCreateRoleMainPage.Refresh(self)
	if self.m_CurrentBtn ~= nil then
		self:OnSelect(self.m_CurrentBtn)
	else
		self:OnSelect(self.m_BtnGrid:GetChild(1))
	end
end

return CCreateRoleMainPage