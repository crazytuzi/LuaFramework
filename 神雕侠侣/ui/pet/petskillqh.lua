require "ui.dialog"
require "utils.log"
require "ui.pet.petskilladd"
PetSkillQh = {}
setmetatable(PetSkillQh, Dialog)
PetSkillQh.__index = PetSkillQh

local _instance
function PetSkillQh.getSingleton()
	return _instance
end

function PetSkillQh.getSingletonDialog()
	if _instance == nil then
		_instance = PetSkillQh.new()
	end
	return _instance
end
function PetSkillQh.getSingletonDialogAndShow()
	if _instance == nil then
		_instance = PetSkillQh.new()
	else
		if not _instance:IsVisible() then
			_instance:SetVisible(true)
		end
	end

	return _instance
end

function PetSkillQh.new()
	local t = {}
	setmetatable(t, PetSkillQh)
	t.__index = PetSkillQh
	t.EffectStatus = {}
	t:OnCreate()
	t:GetWindow():setAlwaysOnTop(true)
	return t
end

function PetSkillQh:OnCreate()
	LogInsane("PetSkillQh:OnCreate")
	Dialog.OnCreate(self)
	self:InitUI()
	self:InitEvent()
	petSkillAdd = PetSkillAdd.getSingletonDialog(PetSkillQh.HandleBookItemSelected, self)
	local pos = self.m_pMainFrame:getPosition()
	local width = self.m_pMainFrame:getWidth()
	local newpos = CEGUI.UVector2(CEGUI.UDim(pos.x.scale, pos.x.offset + width.offset),pos.y)
	petSkillAdd.m_pMainFrame:setPosition(newpos)
	petSkillAdd.OkButton:setVisible(false)
	petSkillAdd.CancelButton:setVisible(false)
end

function PetSkillQh:InitUI()
	local winMgr = CEGUI.WindowManager:getSingleton()
	self.SkillIcon = CEGUI.toSkillBox(winMgr:getWindow("petskillqh/icon"))
	self.SkillName = winMgr:getWindow("petskillqh/name")
	self.SkillProgress = CEGUI.toProgressBar(winMgr:getWindow("petskillqh/barture"))
	self.SkillUpEffectWnd = winMgr:getWindow("petskillqh/effect")
	self.QhInfo = {}
	self.QhInfo.BeforeLevel = winMgr:getWindow("petskillqh/info/txt")
	self.QhInfo.BeforeValue = winMgr:getWindow("petskillqh/info/txt1")
	self.QhInfo.AfterLevel = winMgr:getWindow("petskillqh/info/txt2")
	self.QhInfo.AfterValue = winMgr:getWindow("petskillqh/info/txt3")
	self.QhItems = {}
	
	for i = 1, 5 do
		local idx = i - 1
		if idx ~= 0 then
			self.QhItems[i] = CEGUI.toItemCell(winMgr:getWindow("petskillqh/item"..idx))
		else
			self.QhItems[i] = CEGUI.toItemCell(winMgr:getWindow("petskillqh/item"))
		end
	end
	self.OkButton = CEGUI.toPushButton(winMgr:getWindow("petskillqh/ok"))
	self.CancelButton = CEGUI.toPushButton(winMgr:getWindow("petskillqh/cancel"))
end

function PetSkillQh:InitEvent()
--	for i = 1, 5 do
--		self.QhItems[i]:subscribeEvent("MouseClick", PetSkillQh.HandleItemClicked, self)
--	end
	self.OkButton:subscribeEvent("MouseClick", PetSkillQh.HandleOkBtnClicked, self)
	self.CancelButton:subscribeEvent("MouseClick", PetSkillQh.HandleCancelBtnClicked, self)
	self.m_hPetSkillChange = GetDataManager().EventPetSkillChange:InsertScriptFunctor(PetSkillQh.PetSkillChange)
end

--[[
function PetSkillQh:HandleItemClicked(e)
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local petSkillAdd = PetSkillAdd.getSingleton()
	if petSkillAdd == nil then
		petSkillAdd = PetSkillAdd.getSingletonDialog(PetSkillQh.HandleBookItemSelected, self)
		local pos = self.m_pMainFrame:getPosition()
		local width = self.m_pMainFrame:getWidth()
		local newpos = CEGUI.UVector2(CEGUI.UDim(pos.x.scale, pos.x.offset + width.offset),pos.y)
		petSkillAdd.m_pMainFrame:setPosition(newpos)
	end
	local moveMode = false
	local moveItemkey = 0
	local removeid = 0
	for i = 1, 5 do
		if self.QhItems[i]:getID() == 0 then
			break
		end
		if self.QhItems[i] == mouseArgs.window then
			moveItemkey = self.QhItems[i]:getID()
			removeid = i
			break
		end
	end
	if moveItemkey == 0 then
		return true
	end
	self:RemoveItem(removeid)
	for i = 1, #petSkillAdd.BookItems do
		if petSkillAdd.BookItems[i].Item:getID() == moveItemkey then
			petSkillAdd.BookItems[i].Item:SetSelected(false)
			petSkillAdd:SetBookSelected(petSkillAdd.BookItems[i].Frame, false)
			break
		end
	end
	self:RefreshPreview()
	self:RefreshEffects()
	return true
end
]]

function PetSkillQh:RefreshEffects()
	LogInsane("PetSkillQh:RefreshEffects")
	for i = 1, #self.QhItems do
		local itemkey = self.QhItems[i]:getID()
		LogInsane("itemkey ="..itemkey)
		if itemkey == 0 then
			if not self.EffectStatus[i] then
				GetGameUIManager():AddUIEffect(self.QhItems[i], MHSD_UTILS.get_effectpath(10374), true)
				self.EffectStatus[i] = true
			end
		else
			if self.EffectStatus[i] then
				GetGameUIManager():RemoveUIEffect(self.QhItems[i])
				self.EffectStatus[i] = false
			end
		end
	end
end

function PetSkillQh:HandleOkBtnClicked(e)
	LogInsane("PetSkillQh:HandleOkBtnClicked")
	require "protocoldef.knight.gsp.pet.crefinepetskill"
	local send = CRefinePetSkill.Create()
	for i = 1, 5 do
		local bookitemkey = self.QhItems[i]:getID()
		if bookitemkey == 0 then
			break
		end
		table.insert(send.bookitemkeys, bookitemkey)
	
	end
	if #send.bookitemkeys == 0 then
		LogInsane("Empty books")
		return true
	end
	send.petkey = self.petkey
	send.skillid = self.skillid
	LogInsane(string.format("send petkey=%d, skillid=%d", send.petkey, send.skillid))
	LuaProtocolManager.getInstance():send(send)
	--GetNetConnection():send(send)
--[[	if PetSkillAdd.getSingleton() then
		PetSkillAdd.getSingleton():DestroyDialog()
	end
--]]	
--	self:DestroyDialog()
	return true
end

function PetSkillQh:HandleCancelBtnClicked(e)
	LogInsane("PetSkillQh:HandleCancelBtnClicked")
	if PetSkillAdd.getSingleton() then
		PetSkillAdd.getSingleton():DestroyDialog()
	end
	self:DestroyDialog()
	return true
end

function PetSkillQh:HandleBookItemSelected(e)
	LogInsane("PetSkillQh:HandleBookItemSelected")
	
	local mouseArgs = CEGUI.toMouseEventArgs(e)
	local petSkillAdd = PetSkillAdd.getSingletonDialog()
	local additemkey = 0
	local skilladdid = 0
	for i = 1, #petSkillAdd.BookItems do
		if petSkillAdd.BookItems[i].Frame == mouseArgs.window or 
			petSkillAdd.BookItems[i].Item == mouseArgs.window then
			if petSkillAdd.BookItems[i].Item:getID() ~= 0 then
				additemkey = petSkillAdd.BookItems[i].Item:getID()
				skilladdid = i
			end
			break
		end
	end
	if additemkey == 0 then return true end
	for i = 1, 5 do
		if self.QhItems[i]:getID() == 0 then
			local item = GetRoleItemManager():FindItemByBagAndThisID(additemkey, knight.gsp.item.BagTypes.BAG)
			if item then
				self.QhItems[i]:setID(additemkey)
				self.QhItems[i]:SetImage(GetIconManager():GetItemIconByID(item:GetBaseObject().icon))
			end
			petSkillAdd:SetBookSelected(petSkillAdd.BookItems[skilladdid].Frame, true)
			break
		end
		if self.QhItems[i]:getID() == additemkey then
			self:RemoveItem(i)
			petSkillAdd.BookItems[skilladdid].Item:SetSelected(false)
			petSkillAdd:SetBookSelected(petSkillAdd.BookItems[skilladdid].Frame, false)
			break
		end
	end
	self:RefreshPreview()
	self:RefreshEffects()
end

function PetSkillQh.PetSkillChange(petkey)
	LogInsane(string.format("PetSkillQh.PetSkillChange(%d)", petkey))
	if _instance == nil then
		return
	end
	if petkey ~= _instance.petkey then
		return
	end
	local oldskillid = _instance.skillid
	local petinfo = GetDataManager():FindMyPetByID(petkey)
	if petinfo then
		local len = petinfo:getSkilllistlen()
		for i = 0, len do
			local skillinfo = petinfo:getSkill(i)
			if skillinfo then
				if math.floor(skillinfo.skillid/100) == math.floor(_instance.skillid/100) then
					_instance:setPetkeyAndSkillid(petkey, skillinfo.skillid)
					_instance:RefreshSkillid()
					_instance:RefreshPreview()
					for i = 1, #_instance.QhItems do
						_instance.QhItems[i]:setID(0)
						_instance.QhItems[i]:SetImage(nil)
					end
					_instance:RefreshEffects()
					break
				end
			end
		end
	end
--	local effectid = _instance.skillid ~= oldskillid and 10380 or 10385
	if _instance.skillid ~= oldskillid then
		GetGameUIManager():AddUIEffect(_instance.SkillUpEffectWnd, MHSD_UTILS.get_effectpath(10380), false)
	else
		GetGameUIManager():AddUIEffect(_instance.SkillIcon, MHSD_UTILS.get_effectpath(10385), false)
	end
	
end

function PetSkillQh:RemoveItem(i)
	LogInsane("PetSkillQh:RemoveItem"..i)
	self.QhItems[i]:setID(0)
	self.QhItems[i]:SetImage(nil)
	for j = i + 1, #self.QhItems do
		local moveidx = j - 1
		local id = self.QhItems[j]:getID()
		self.QhItems[moveidx]:setID(id)
		if id ~= 0 then
			local item = GetRoleItemManager():FindItemByBagAndThisID(id, knight.gsp.item.BagTypes.BAG)
			if item then
				self.QhItems[moveidx]:SetImage(GetIconManager():GetItemIconByID(item:GetBaseObject().icon))
			end
		else
			self.QhItems[moveidx]:SetImage(nil)
			break
		end
	end
end

function PetSkillQh:DestroyDialog()
	LogInsane("destory PetSkillQh dialog")
	if self == _instance then
		GetDataManager().EventPetSkillChange:RemoveScriptFunctor(_instance.m_hPetSkillChange)
		self:OnClose()
		_instance = nil
	else
		LogInsane("Something class instance?")
	end
end
function PetSkillQh:GetLayoutFileName()
	LogInsane("PetSkillQh:GetLayoutFileName")
	return "petskillqh.layout"
end

local function getCharacterDigit(d)
	assert(d > 0 and d < 10)
	if d > 0 and d <= 8 then
		return MHSD_UTILS.get_resstring(2722+d)
	end
	return MHSD_UTILS.get_resstring(2875)
end

local function makelevelstr(level)
	assert(level < 100 and level > 0)
	local a = math.floor(level / 10)
	local b = level % 10
	if a == 1 then
		return b ~= 0 and string.format("%s%s", MHSD_UTILS.get_resstring(2876), getCharacterDigit(b))
			or MHSD_UTILS.get_resstring(2876)
	elseif a == 0 then
		return getCharacterDigit(b)
	else
		return b ~= 0 and string.format("%s%s%s", getCharacterDigit(a), MHSD_UTILS.get_resstring(2876), getCharacterDigit(b))
			or string.format("%s%s", getCharacterDigit(a), MHSD_UTILS.get_resstring(2876))
	end
end
function PetSkillQh:RefreshSkillid()
	LogInsane("PetSkillQh.RefreshSkillid "..self.petkey)
	local petinfo = GetDataManager():FindMyPetByID(self.petkey)
	if petinfo then
		local progress = petinfo:getSkillexp(self.skillid)
		local upgradeConfig = knight.gsp.skill.GetCPetSkillupgradeTableInstance():getRecorder(self.skillid)
		local skillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(self.skillid)
		if skillconfig.id ~= -1 then
			self.QhInfo.BeforeValue:setText(skillconfig.littledes)
		end
		
		if upgradeConfig.id ~= -1 then
			local gradedescribe = string.format("%s%s", makelevelstr(upgradeConfig.skilllevel), MHSD_UTILS.get_resstring(3))
			self.QhInfo.BeforeLevel:setText(gradedescribe)
		--[[	local p = progress/upgradeConfig.needexp;
			self.SkillProgress:setText(string.format("%d/%d",progress, upgradeConfig.needexp))
			LogInsane("Set progress p="..p)
			self.SkillProgress:setProgress(p)
			--]]
		end
		
	end
end

function PetSkillQh:RefreshPreview()
	local petinfo = GetDataManager():FindMyPetByID(self.petkey)
	if petinfo == nil then
		return
	end
	local addexp = 0
	for i = 1, #self.QhItems do
		local petitem = GetRoleItemManager():FindItemByBagAndThisID(self.QhItems[i]:getID(), knight.gsp.item.BagTypes.BAG)
		if petitem then
			local petItemEffect = knight.gsp.item.GetCPetItemEffectTableInstance():getRecorder(petitem:GetBaseObject().id)
			if petItemEffect then
				local petItemSkillid = petItemEffect.petskillid
				local upgradeConfig = knight.gsp.skill.GetCPetSkillupgradeTableInstance():getRecorder(petItemSkillid)
				if upgradeConfig.id ~= -1 then
					LogInsane("addexp=%d"..upgradeConfig.offerbaseexp)
					addexp = addexp + upgradeConfig.offerbaseexp
					LogInsane(string.format("Book %d offer %d exp", i, upgradeConfig.offerbaseexp))
				end
			end
		end
	end
	local curprog = petinfo:getSkillexp(self.skillid) + addexp
	local progress = petinfo:getSkillexp(self.skillid)
	local curUpgradeConfig = knight.gsp.skill.GetCPetSkillupgradeTableInstance():getRecorder(self.skillid)
	local showstr
	if addexp == 0 then
		showstr = string.format("[colour='FFFFFFFF']%d/%d",progress, curUpgradeConfig.needexp)
	else
		showstr = string.format("[colour='FFFFFFFF']%d[colour='FF33FF33']+%d[colour='FFFFFFFF']/%d",progress, addexp, curUpgradeConfig.needexp)
	end
	self.SkillProgress:setText(showstr)
	local p = (progress + addexp)/curUpgradeConfig.needexp;
	self.SkillProgress:setProgress(p)
	
	local curskillid = self.skillid
	for i = 1, 999 do
		local upgradeConfig = knight.gsp.skill.GetCPetSkillupgradeTableInstance():getRecorder(curskillid)
		LogInsane("skill level up need exp "..upgradeConfig.needexp)
		if upgradeConfig.id == -1 then
			LogInsane("May be you are the highest")
			break
		end
		if curprog >= upgradeConfig.needexp then
			LogInsane(string.format("skill %d , next skill id is %d", curskillid, upgradeConfig.nextid))
			if upgradeConfig.nextid ~= 0 then
				curskillid = upgradeConfig.nextid
				curprog = curprog - upgradeConfig.needexp
			else
				LogInsane("May be you are the highest")
				curprog = upgradeConfig.needexp
				break
			end
		else
			break
		end
	end
	
--	self.QhInfo.AfterValue:setText("ÆøÑª"..curprog)
	if curskillid == self.skillid then
		local upgradeConfig = knight.gsp.skill.GetCPetSkillupgradeTableInstance():getRecorder(curskillid)
		if upgradeConfig.id ~= -1 then
			curskillid = upgradeConfig.nextid == 0 and self.skillid or upgradeConfig.nextid
		end
	end
	local upgradeConfig = knight.gsp.skill.GetCPetSkillupgradeTableInstance():getRecorder(curskillid)
	if upgradeConfig.id ~= -1 then
		local gradedescribe = string.format("%s%s", makelevelstr(upgradeConfig.skilllevel), MHSD_UTILS.get_resstring(3))
		self.QhInfo.AfterLevel:setText(gradedescribe)
	end
	local skillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(curskillid)
	if skillconfig.id ~= -1 then
		self.QhInfo.AfterValue:setText(skillconfig.littledes)
	end
end

function PetSkillQh:setPetkeyAndSkillid(petkey, skillid)
	LogInsane(string.format("PetSkillQh petkey = %d, skillid = %d", petkey, skillid))
	self.petkey = petkey
	self.skillid = skillid
	local skillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(self.skillid)
	self.SkillIcon:SetImage(GetIconManager():GetSkillIconByID(skillconfig.icon))
	self.SkillIcon:SetBackgroundDynamic(true)
    local skillconfig = knight.gsp.skill.GetCPetSkillConfigTableInstance():getRecorder(self.skillid)
     if skillconfig.id ~= -1 then
         local bkimageset = CEGUI.String("BaseControl"..(math.floor((skillconfig.color-1)/4)+1))
         local bkimage = CEGUI.String("SkillInCell"..skillconfig.color)
         self.SkillIcon:SetBackGroundImage(bkimageset, bkimage)
     end
	self.SkillName:setText(skillconfig.skillname)
	self:RefreshSkillid()
	self:RefreshPreview()
	self:RefreshEffects()
end
return PetSkillQh
