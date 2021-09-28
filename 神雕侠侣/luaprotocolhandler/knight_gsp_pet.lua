local m = require "protocoldef.knight.gsp.pet.spetchips"

function m:process()
	print("enter spetchips process")
	require "ui.pet.petchipdlg"
	for i,v in pairs(self.chips) do
		print(i, v)
	end
		
	PetChipDlg.setChipsInfo(self.chips)
end

m = require "protocoldef.knight.gsp.pet.spetpractise"
function m:process()
	LogInsane("protocoldef.knight.gsp.pet.spetpractise")
	local petinfo = GetDataManager():FindMyPetByID(self.petkey)
	if petinfo == nil then 
		return
	end
	for k,v in pairs(self.zizhi) do
		petinfo:setZizhi(k, v)
	end
	petinfo.genguadd = self.wuxing
	require "ui.pet.pettraindlg"
	local pettraindlg = PetTrainDlg.getInstanceNotCreate()
	if pettraindlg and pettraindlg.m_iSelectID and pettraindlg.m_iSelectID ~= 0 then
		pettraindlg:RefreshZizhi(petinfo)
		pettraindlg.WuxingResult:setText(self.wuxing)
	end
end

m = require "protocoldef.knight.gsp.pet.sremainpractisetimes"
function m:process()
	LogInsane("protocoldef.knight.gsp.pet.sremainpractisetimes")
	local petinfo = GetDataManager():FindMyPetByID(self.petkey)
	if petinfo == nil then 
		return
	end
	petinfo.practiseTimes = self.practisetimes
	if self.flag == 0 then
		petinfo:clearZizhi()
	end
	require "ui.pet.pettraindlg"
	local pettraindlg = PetTrainDlg.getInstanceNotCreate()
	if pettraindlg and pettraindlg.m_iSelectID and pettraindlg.m_iSelectID ~= 0 then
		pettraindlg.LeftNumber:setText(tostring(self.practisetimes))
		pettraindlg:RefreshZizhi(petinfo)
	end
end

m = require "protocoldef.knight.gsp.pet.supdatepetgrids"
function m:process()
	local petinfo = GetDataManager():FindMyPetByID(self.petkey)
	if petinfo then
		petinfo.skill_grid = self.skillgrids
	end
	local dlg = require "ui.pet.petpropertydlg".getInstanceNotCreate()
	if dlg and dlg.m_iSelectID then
		if dlg.m_iSelectID == self.petkey then
			dlg:RefreshSkillInfo()
		end
	end
end

m = require "protocoldef.knight.gsp.pet.snotifyuseyuanbao"
confirmAddPetSkillType = nil
local function confirmAddPetSkillPos()
     if confirmAddPetSkillType then
         GetMessageManager():CloseConfirmBox(confirmAddPetSkillType, false)
     end
     confirmAddPetSkillType = nil
     local self = require "ui.pet.petpropertydlg".getInstanceNotCreate()
     if not self or self.m_iSelectID == 0 then
         return
     end
     local p = require "protocoldef.knight.gsp.pet.cextendskillgrid".new()
     p.petkey = self.m_iSelectID
     p.flag = 1
     require "manager.luaprotocolmanager":send(p)
 end
function m:process()
	local msg = knight.gsp.message.GetCMessageTipTableInstance():getRecorder(145156).msg
    local t = require "utils.mhsdutils"
    local sb = require "utils.stringbuilder":new()
	local needyuanbao = self.yuanbaonum
    sb:SetNum("parameter1", needyuanbao)
    confirmAddPetSkillType = t.addConfirmDialog(sb:GetString(msg), confirmAddPetSkillPos)
    sb:delete()
end

local spetgotfreexuemailist = require "protocoldef.knight.gsp.pet.spetgotfreexuemailist"
function spetgotfreexuemailist:process()
    LogInfo("____spetgotfreexuemailist:process")
    
	require "ui.pet.petchipdlg"
    local dlgPetChip = PetChipDlg.getInstanceNotCreate()
    
    if dlgPetChip then
        dlgPetChip:RefreshGotFreeXieMaiList(self.result)
    end
end

local sexchangeshenshou = require "protocoldef.knight.gsp.pet.sexchangeshenshou"
function sexchangeshenshou:process()
	local PetExchangeDlg = require "ui.pet.petexchangedlg"
	if PetExchangeDlg.getInstanceNotCreate() then
		PetExchangeDlg.getInstanceNotCreate():RefreshShenShouJingPo()
	end
end

local sendpetamulets = require "protocoldef.knight.gsp.pet.sendpetamulets"
function sendpetamulets:process()
	print("protocoldef.knight.gsp.pet.sendpetamulets")
	if PetPropertyDlg:getInstanceNotCreate() then
		PetPropertyDlg:getInstance():SetCurrAmulets(self.petkey, self.petamulets)
	end
end

local spetamuletchange = require "protocoldef.knight.gsp.pet.spetamuletchange"
function spetamuletchange:process()
	print("protocoldef.knight.gsp.pet.spetamuletchange")
	PetAmuletCompositeDlg:getInstance():OnMainAmuletChanged(self.petamulets)
	if PetPropertyDlg:getInstanceNotCreate() then
		PetPropertyDlg:getInstanceNotCreate():RefreshAmuletInfo()
	end
end