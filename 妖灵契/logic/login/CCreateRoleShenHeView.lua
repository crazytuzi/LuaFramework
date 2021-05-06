--
--审核版的创角逻辑都在这里
--
local CCreateRoleShenHeView = class("CCreateRoleShenHeView", CViewBase)
CCreateRoleShenHeView.RANDOMIDX = 0
function CCreateRoleShenHeView.ctor(self, cb)
	CViewBase.ctor(self, "UI/Login/CreateRoleShenHeView.prefab", cb)
	self.m_GroupName = "main"
	self.m_DepthType = "Menu"
end

function CCreateRoleShenHeView.OnCreateView(self)
	self.m_LoginBtn = self:NewUI(1, CButton)
	self.m_CreateBtn = self:NewUI(3, CButton)
	self.m_SchoolSprite = self:NewUI(4, CSprite)
	self.m_SchoolTextSprite = self:NewUI(5, CSprite)
	self.m_BranchSprite1 = self:NewUI(6, CSprite)
	self.m_BranchSprite2 = self:NewUI(7, CSprite)
	self.m_NameInput = self:NewUI(9, CInput)
	self.m_RandomNameBtn = self:NewUI(10, CButton)
	self.m_SchoolGrid = self:NewUI(12, CGrid)
	self.m_SexGrid = self:NewUI(13, CGrid)
	self.m_ActorTexture = self:NewUI(14, CActorTexture)
	self.m_Container = self:NewUI(15, CWidget)
	self.m_SchoolList = {2, 3, 1}
	self.m_SexList = {"male", "female"}
	self.m_AvatarList = {
		--school,sex
		[1] = { ["male"] = 110, ["female"] = 120, ["branch"] = 1, },
		[2] = { ["male"] = 130, ["female"] = 140, ["branch"] = 1, },
		[3] = { ["male"] = 150, ["female"] = 160, ["branch"] = 1, },
	}
	
	self.m_CreateData = {}

	self:InitContent()
	CLoginView:CloseView()
end

function CCreateRoleShenHeView.InitContent(self)
	UITools.ResizeToRootSize(self.m_Container)
	self.m_RandomNameBtn:AddUIEvent("click", callback(self, "RandomName"))
	self.m_LoginBtn:AddUIEvent("click", callback(self, "OnClickLogin"))
	self.m_CreateBtn:AddUIEvent("click", callback(self, "OnClickCreate"))
	self.m_SchoolGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_School = self.m_SchoolList[idx]
		oBox.m_SelectMark = oBox:NewUI(1, CSprite)
		oBox.m_SelectMark:SetActive(false)
		oBox:AddUIEvent("click", callback(self, "OnSelectSchool", oBox))
		return oBox
	end)
	self.m_SexGrid:InitChild(function (obj, idx)
		local oBox = CBox.New(obj)
		oBox.m_SelectMark = oBox:NewUI(1, CSprite)
		oBox.m_RoleSprite = oBox:NewUI(2, CSprite)
		oBox.m_BgSprite = oBox:NewUI(3, CSprite)
		oBox.m_Sex = self.m_SexList[idx]
		oBox.m_SelectMark:SetActive(false)
		oBox:AddUIEvent("click", callback(self, "OnSelectSex", oBox))
		return oBox		
	end)

	local school = Utils.RandomInt(1, self.m_SchoolGrid:GetCount())
	local sex = Utils.RandomInt(1, self.m_SexGrid:GetCount())
	self:OnSelectSchool(self.m_SchoolGrid:GetChild(school))
	self:OnSelectSex(self.m_SexGrid:GetChild(sex))
	self:RandomName()
end


function CCreateRoleShenHeView.RandomName(self, oBtn)
	local oldName
	local oMaskTree = g_MaskWordCtrl:GetMaskWordTree()
	local function getone()
		local sName = ""
		local len = #oMaskTree:GetCharList(sName)
		local first,mid,last= "", "", ""
		local firstdata, randomvalue 
		while (len < 2) or (len > 6) or sName == oldName do
			math.randomseed(os.time()+CCreateRoleShenHeView.RANDOMIDX)
			math.random()
			CCreateRoleShenHeView.RANDOMIDX = CCreateRoleShenHeView.RANDOMIDX + 1
			oldName = self.m_NameInput:GetText()
			firstdata = data.randomnamedata.FIRST[math.random(1, #data.randomnamedata.FIRST)]
			first = firstdata.first

			math.randomseed(os.time()+CCreateRoleShenHeView.RANDOMIDX)
			math.random()
			CCreateRoleShenHeView.RANDOMIDX = CCreateRoleShenHeView.RANDOMIDX + 1
			mid = ""
			randomvalue = math.random(1, 100)
			if randomvalue <= 70 and firstdata.mid then
				randomvalue = math.random(1, #firstdata.mid)
				mid = firstdata.mid[randomvalue] or ""
			end

			math.randomseed(os.time()+CCreateRoleShenHeView.RANDOMIDX)
			math.random()
			CCreateRoleShenHeView.RANDOMIDX = CCreateRoleShenHeView.RANDOMIDX + 1
			last = ""
			if self:GetCreateData("sex") == "male" then
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
	self.m_NameSex = self:GetCreateData("sex")
	if oBtn then
		g_UploadDataCtrl:CreateRoleUpload({time=g_CreateRoleCtrl.m_ShowTime, click= "随机取名"})
	end
end

function CCreateRoleShenHeView.OnSelectSchool(self, oBox)
	if self.m_CurSchoolBox ~= nil then
		self.m_CurSchoolBox.m_SelectMark:SetActive(false)
	end
	self.m_CurSchoolBox = oBox
	self.m_CurSchoolBox.m_SelectMark:SetActive(true)
	for i,obox in ipairs(self.m_SexGrid:GetChildList()) do
		obox.m_RoleSprite:SetSpriteName("pic_role_" .. self.m_AvatarList[oBox.m_School][obox.m_Sex])
		obox.m_SelectMark:SetSpriteName("pic_selrole_" .. self.m_AvatarList[oBox.m_School][obox.m_Sex])
	end
	self:OnSelect(oBox.m_School, nil)
end

function CCreateRoleShenHeView.OnSelectSex(self, oBox)
	if self.m_CurSexBox ~= nil then
		self.m_CurSexBox.m_SelectMark:SetActive(false)
	end
	self.m_CurSexBox = oBox
	self.m_CurSexBox.m_SelectMark:SetActive(true)
	self:OnSelect(nil, oBox.m_Sex)
end

function CCreateRoleShenHeView.OnSelect(self, school, sex)
	school = school or self.m_School
	sex = sex or self.m_Sex
	self.m_School = school
	self.m_Sex = sex
	if not self.m_School or not self.m_Sex then
		return
	end
	self:SetCreateData("sex", self.m_Sex)
	self:SetCreateData("school", self.m_School )

	if self.m_NameSex and self.m_NameSex ~= self.m_Sex then
		self:RandomName()
	end

	self.m_ActorTexture:ChangeShape(self.m_AvatarList[self.m_School][self.m_Sex])
end

function CCreateRoleShenHeView.OnClickLogin(self)
	CLoginView:ShowView()
	g_UploadDataCtrl:CreateRoleUpload({time=g_CreateRoleCtrl.m_ShowTime, click= "返回登录界面"})
	self:CloseView()
end

function CCreateRoleShenHeView.OnClickCreate(self)
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
	if g_LoginCtrl:HasLoginRole() then
		printerror("CreateRole err: HasLoginRole")
		return
	end
	
	local iSex = table.index(self.m_SexList, self.m_Sex)
	local iRoleType = data.roletypedata.MAP[iSex][self.m_School]
	if g_LoginCtrl:GetLoginInfo("account") then
		if not g_NetCtrl:IsValidSession(1003) then
			return 
		end
		netlogin.C2GSCreateRole(g_LoginCtrl:GetAccount(), iRoleType, sName) 
	else
		g_LoginCtrl:SetLoginAccountCb(function() netlogin.C2GSCreateRole(g_LoginCtrl:GetAccount(), iRoleType, sName) end)
		g_LoginCtrl:ConnectServer()
	end
end

function CCreateRoleShenHeView.SetCreateData(self, k, v)
	local oldv = self.m_CreateData[k]
	if oldv ~= v then
		self.m_CreateData[k] = v
	end
end

function CCreateRoleShenHeView.GetCreateData(self, k)
	return self.m_CreateData[k]
end

return CCreateRoleShenHeView