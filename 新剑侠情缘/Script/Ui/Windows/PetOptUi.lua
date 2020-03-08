local tbUi = Ui:CreateClass("PetOptUi")
local RepresentMgr = luanet.import_type("RepresentMgr")

tbUi.tbPos =
{
	{{0, 48}},
	{{-85, 35}, {85, 35}, {0, 45}},
}

function tbUi:GetValidBtnInfo(szPetType)
	local tbRet = {}
	local tbSetting = Pet.tbInteractions[szPetType]
	if not tbSetting then
		return tbRet
	end
	for _, tb in ipairs(tbSetting) do
		local szName, fnDo, fnCan = unpack(tb)
		if fnCan(self) then
			table.insert(tbRet, {szName, fnDo})
		end
	end
	return tbRet
end

function tbUi:OnOpen(szPetType, nTemplateId, nNpcId)
	self.nTemplateId = nTemplateId
	self.nNpcId = nNpcId
	local tbBtnInfo = self:GetValidBtnInfo(szPetType)
	if not tbBtnInfo or not next(tbBtnInfo) then
		Log("[x] PetOptUi:OnOpen", nNpcId, szPetType)
		return 0
	end

	local pNpc = KNpc.GetById(nNpcId)
	local pRep = RepresentMgr.GetNpcRepresent(nNpcId)
	if not pRep then
		return 0
	end
	self.pPanel:SceneObj_SetFollow("Main", pRep.name)

	self.nNpcId = nNpcId
	self.tbBtnInfo = tbBtnInfo

	local tbPosInfo = self.tbPos[2]
	for i = 1, #tbPosInfo do
		self.pPanel:SetActive("BtnUse" .. i, i <= #tbBtnInfo)
		if i <= #tbBtnInfo then
			self.pPanel:Label_SetText("BtnLabel" .. i, tbBtnInfo[i][1])
			self.pPanel:ChangePosition("BtnUse" .. i, tbPosInfo[i][1], tbPosInfo[i][2])
		end
	end
end

function tbUi:OnScreenClick()
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

for i = 1, #tbUi.tbPos[2] do
	tbUi.tbOnClick["BtnUse" .. i] = function(self)
		if not self.tbBtnInfo or not self.tbBtnInfo[i] then
			return;
		end

		self.tbBtnInfo[i][2](self)
		Ui:CloseWindow(self.UI_NAME)
	end
end
