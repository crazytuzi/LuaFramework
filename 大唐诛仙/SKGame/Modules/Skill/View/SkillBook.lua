SkillBook = BaseClass(LuaUI)
function SkillBook:__init(...)
	self.URL = "ui://tv6313j0h394p";
	self:__property(...)
	self:Config()
end

function SkillBook:SetProperty(...)
	
end

function SkillBook:Config()
	self:InitData()
	self:InitEvent()
	self:Update()
end

function SkillBook:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Skill","SkillBook");

	self.bg = self.ui:GetChild("bg")
	self.content = self.ui:GetChild("content")
end

function SkillBook.Create(ui, ...)
	return SkillBook.New(ui, "#", {...})
end

function SkillBook:InitEvent()
	self.handler0 = self.model:AddEventListener(SkillConst.UpdateSkillBook , function ()
		self:Update()
	end)
end

-- Dispose use SkillBook obj:Destroy()
function SkillBook:__delete()
	self:DisposePkgCellList()
	self.model:RemoveEventListener(self.handler0)

end

function SkillBook:InitData()
	self.skillBookData = {}
	self.pkgCellList = {}
	self.model = SkillModel:GetInstance()
end

function SkillBook:Update()
	self:SetData()
	self:SetUI()
end

function SkillBook:SetData()
	self.skillBookData =  self.model:GetSkillBookData()
end

function SkillBook:SetUI()
	self:SetContentUI()
end

function SkillBook:SetContentUI()
	if not TableIsEmpty(self.skillBookData) then
		self:UnActiveAllPkgCell()

		local function OnPkgCellItemClick(pkgCellObj)
			self:OnClickSkillBookItem(pkgCellObj)
		end
		local itemIndex = 0 --从个数不为0的bookData进行累加
		for index = 1, #self.skillBookData do
			local bookData = self.skillBookData[index]
			if bookData.cnt ~= 0 then
				itemIndex = itemIndex + 1
				local oldObj = self:IsHasPkgCellByIndex(itemIndex)
				local curObj = {}
				if TableIsEmpty(oldObj) then
					curObj = PkgCell.New(self.content , nil , OnPkgCellItemClick)
					table.insert(self.pkgCellList , curObj)
				else
					curObj = oldObj
				end
				curObj:SetDataByCfg(GoodsVo.GoodType.item , bookData.id , bookData.cnt , 0)
				curObj:OpenTips(false , false)
				curObj:SetupPressShowTips(true , 1)
				curObj:SetVisible(true)
			end
		end
	end
end

function SkillBook:IsHasPkgCellByIndex(index)
	return self.pkgCellList[index] or {}
end

function SkillBook:DisposePkgCellList()
	for index = 1 , #self.pkgCellList do
		if self.pkgCellList[index] ~= nil then
			self.pkgCellList[index]:Destroy()
			self.pkgCellList[index] = nil
		end
	end
	self.pkgCellList = {}
end

function SkillBook:UnActiveAllPkgCell()
	for index = 1, #self.pkgCellList do
		self.pkgCellList[index]:SetVisible(false)
	end
end

function SkillBook:OnClickSkillBookItem(pkgCellObj)
	local pkgCellData = pkgCellObj:GetData()
	local skillData = self.model:GetSelectSkillData()
	local skillMsgVoList = self.model:GetSkillMsgVoList()

	if not TableIsEmpty(pkgCellData) and not TableIsEmpty(skillData) then
		
		local skillId = -1
		if self.model:IsMWSkill(skillData.skillId) == true then
			skillId = self.model:GetSkillIdByMWId(skillData.skillId)
		else
			skillId = skillData.skillId
		end
		
		if skillId ~= -1 then
			SkillController:GetInstance():C_AddSkillMastery(skillId , pkgCellData.bid)
		end

		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)

		if NewbieGuideModel:GetInstance():IsHasSkillUpgradeGuide() then
			self:SetVisible(false)
		end
	end
end