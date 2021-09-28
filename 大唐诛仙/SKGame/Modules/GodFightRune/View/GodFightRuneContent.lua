GodFightRuneContent = BaseClass(LuaUI)

function GodFightRuneContent:__init(...)
	self.URL = "ui://s210esy7jci2l";
	self:__property(...)
	self:Config()
end

function GodFightRuneContent:SetProperty(...)
	
end

function GodFightRuneContent:Config()
	self:InitData()
	self:InitUI()
	self:InitEvent()
end

function GodFightRuneContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("GodFightRune","GodFightRuneContent");

	self.bg = self.ui:GetChild("bg")
	self.content = self.ui:GetChild("content")
end

function GodFightRuneContent.Create(ui, ...)
	return GodFightRuneContent.New(ui, "#", {...})
end

function GodFightRuneContent:__delete()
	self:DisposePkgCellList()
	self:CleanData()
end

function GodFightRuneContent:InitData()
	self.runeData = {}
	self.gridsCnt = PkgModel:GetInstance().bagGrid or 0
	self.pkgCellList = {}
	self.model = GodFightRuneModel:GetInstance()
	self.selectInstanceId = -1
	self.selectGid = -1
end

function GodFightRuneContent:SetData(data)
	self.runeData = data or {}
end

function GodFightRuneContent:CleanData()
	for index = 1 , #self.runeData do
		table.remove(self.runeData , index)
	end
	self.runeData = {}
end

function GodFightRuneContent:InitUI()
	self:InitGridsUI()
end

function GodFightRuneContent:InitEvent()
	self.eventHandler0 =  self.model:AddEventListener(GodFightRuneConst.DefaultSelectItem , function (defaultSelectItemIndex)
		self:SetDefaultSelectItem(defaultSelectItemIndex)
	end)
end

function GodFightRuneContent:CleanEvent()
	self.model:RemoveEventListener(self.eventHandler0)
end

function GodFightRuneContent:InitGridsUI()
	local function onCellItemClick(data)
		self:OnClickItem(data)
	end

	for index = 1 , self.gridsCnt do
		local pkgCellObj = PkgCell.New(self.content, nil , onCellItemClick)
		pkgCellObj:SetRare(0)
		pkgCellObj:OpenTips(false, false)
		pkgCellObj:SetupPressShowTips(true , 1)
		pkgCellObj.gid = index
		table.insert(self.pkgCellList, pkgCellObj)
	end
end

function GodFightRuneContent:SetUI()
	for index = 1, #self.pkgCellList do
		local curCellObj = self.pkgCellList[index]
		local curRuneData = self.runeData[index] or {}

		if not TableIsEmpty(curCellObj) then
			if not TableIsEmpty(curRuneData) then
				curCellObj:SetDataByCfg(GoodsVo.GoodType.item , curRuneData.itemId , curRuneData.cnt , curRuneData.isBinding)
				curCellObj:SetSelected(false)
				curCellObj.gid = index
				if self:IsSelected(curRuneData.playerBagId) == true then
					curCellObj:SetSelected(true)
					----选中某个
				end
			else
				curCellObj:SetSelected(false)
				curCellObj:SetData(nil)
			end
		end
	end
end

function GodFightRuneContent:OnClickItem(cellObj)
	if not TableIsEmpty(cellObj) then
		self:UnSelectAllCellObjList()
		cellObj:SetSelected(true)
		local gid = cellObj.gid
		local curRuneData = self.runeData[gid] or {}
		self:SetSelectedPkgCellData(curRuneData)
		self.model:DispatchEvent(GodFightRuneConst.SelectRuneItem , self.selectInstanceId)

		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	end
end

function GodFightRuneContent:UnSelectAllCellObjList()
	for index = 1, #self.pkgCellList do
		local curCellObj = self.pkgCellList[index]
		if not TableIsEmpty(curCellObj) then
			curCellObj:SetSelected(false)
		end
	end
end

function GodFightRuneContent:SetSelectedPkgCellData(data)
	self.selectInstanceId = data.playerBagId or -1
	self.selectGid = data.itemIndex or -1
end

function GodFightRuneContent:IsSelected(instanceId)
	local rtnIsHas = false
	if instanceId then
		if self.selectInstanceId == instanceId then
			rtnIsHas = true
		end
	end
	return rtnIsHas
end

function GodFightRuneContent:DisposePkgCellList()
	for index = 1, #self.pkgCellList do
		self.pkgCellList[index]:Destroy()
		self.pkgCellList[index] = nil
	end
	self.pkgCellList = {}
end

function GodFightRuneContent:SetDefaultSelectItem(defaultSelectIndex)
	if defaultSelectIndex then
		if self.selectGid == -1 then
			if self.pkgCellList[defaultSelectIndex] then
				local curSelectData = self.runeData[defaultSelectIndex] or {}
				if not TableIsEmpty(curSelectData) then
					
					self:OnClickItem(self.pkgCellList[defaultSelectIndex])
				else
					
				end
			end
		end
	end
end