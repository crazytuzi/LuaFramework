require "Core.Module.Pattern.Proxy"
require "net/CmdType"
require "net/SocketClientLua"
PetProxy = Proxy:New();

local insert = table.insert

-- local function AddNewPetSkill(cmd, data)
-- 	if(data and data.errCode == nil) then		
-- 		PetManager.AddNewPetSkill(data)
-- 		ModuleManager.SendNotification(PetNotes.UPDATE_PETCHANGESKILLPANEL1)
-- 	end
-- end
local function GetPetCallBack(cmd, data)
	if(data and data.errCode == nil) then		
		PetManager.AddPet(data)
		local pet = PetManager.GetCurrentPetdata()
		local fashionData = PetManager.GetPetAdvanceFashionDataById(pet:GetCurRankFashionId())
		fashionData:SetRankLevel(pet:GetRank())
		-- fashionData:SetActive(true)
		local attr = BaseAdvanceAttrInfo:New()
		attr:Init(PetManager.GetPetAdvanceConfig(PetManager.MAXSTAR))--获取第一阶满星的属性
		ModuleManager.SendNotification(PetNotes.OPEN_PETACTIVEPANEL, {fashionData, attr})
	end
end

local function UpdatePetLevelCallBack(cmd, data)
	if(data and data.errCode == nil) then	
		local curPet = PetManager.GetCurrentPetdata()
		local updateLevel = curPet:GetLevel() ~= data.lev
		PetManager.UpdatePetLevel(data)
		
		if(updateLevel) then
			ModuleManager.SendNotification(PetNotes.UPDATE_SUBPETINFOLEVEL)	
			ModuleManager.SendNotification(PetNotes.SHOW_PETUPDATELEVELEFFECT)
			UISoundManager.PlayUISound(UISoundManager.ui_role_upgrade)			
		else			
			ModuleManager.SendNotification(PetNotes.UPDATE_SUBPETINFOEXP)
		end
	end
end

local function UpdatePetRankCallBack(cmd, data)
	if(data and data.errCode == nil) then	
		local curPet = PetManager.GetCurrentPetdata()
		local updateLevel = curPet:GetRank() ~= data.star		
		
		PetManager.UpdatePetRank(data)
		
		local hero = HeroController.GetInstance()
		if(hero) then
			local pet = hero:GetPet()
			if(pet) then
				pet:UpdatePetRank(data)
			end
		end
		ModuleManager.SendNotification(PetNotes.SHOW_PETUPDATELEVELLABEL, data.crit_exp)			
		
		if(updateLevel) then			
			if(data.star % 10 == 0 and(data.star ~= PetManager.MAXRANK)) then
				ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
				local index = curPet:GetRankLevel() * PetManager.MAXSTAR
				local pet = PetManager.GetCurrentPetdata()
				
				local fashionData = PetManager.GetPetAdvanceFashionDataById(pet:GetCurRankFashionId())
				fashionData:SetRankLevel(pet:GetRank())			
				local attr = BaseAdvanceAttrInfo:New()
				attr:Init(PetManager.GetPetAdvanceConfig(index))
				
				ModuleManager.SendNotification(PetNotes.OPEN_PETACTIVEPANEL, {fashionData, attr})
				PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.PetAdvance)
			else	
				PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.PetAdvance)
				ModuleManager.SendNotification(PetNotes.UPDATE_SUBPETADVENCELEVEL)		
			end	
			ModuleManager.SendNotification(PetNotes.SHOW_PETUPDATERANKEFFECT)
			UISoundManager.PlayUISound(UISoundManager.ui_skill_upgrade)			
			
		else
			ModuleManager.SendNotification(PetNotes.UPDATE_SUBPETADVENCEEXP)			
		end
		
		
	end
end

local function ActivePetBodyCallBack(cmd, data)
	if(data and data.errCode == nil) then		
		PetManager.SetPetFashionActive(data.id)
		local pet = PetManager.GetPetFashionDataById(data.id)
		ModuleManager.SendNotification(PetNotes.OPEN_PETACTIVEPANEL, {pet})
		
		PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.PetFashion)
		ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
		ModuleManager.SendNotification(PetNotes.SHOW_PETFASHIONEFFECT)
		
	end
end

local function UpdatePetBodyCallBack(cmd, data)
	if(data and data.errCode == nil) then		
		PetManager.SetPetFashionLevel(data.id, data.lev)
		PlayerManager.CalculatePlayerAttribute(HeroController.CalculateAttrType.PetFashion)
		ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
		ModuleManager.SendNotification(PetNotes.SHOW_PETFASHIONEFFECT)
		UISoundManager.PlayUISound(UISoundManager.ui_skill_upgrade)			
		
	end
end

local function ChangePetBodyCallBack(cmd, data)
	if(data and data.errCode == nil) then		
		PetManager.SetCurUsePetId(data.id)
		PetManager.SortPet()
		local pet = PetManager.GetPetAdvanceFashionDataById(data.id)	
		--如果是出战进阶的宠物的话 那更新那个界面的数据
		if(pet) then
			ModuleManager.SendNotification(PetNotes.UPDATE_PETADVANCEFASHIONDATA,pet)			
		else
			ModuleManager.SendNotification(PetNotes.UPDATE_PETPANEL)
		end
		
	end
end

function PetProxy:OnRegister()	
	--20170803新宠物协议
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GetPet, GetPetCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UpdatePetLevel, UpdatePetLevelCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UpdatePetRank, UpdatePetRankCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ActivePetBody, ActivePetBodyCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.UpdatePetBody, UpdatePetBodyCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangePetBody, ChangePetBodyCallBack);		
end

function PetProxy:OnRemove()	
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GetPet, GetPetCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UpdatePetLevel, UpdatePetLevelCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UpdatePetRank, UpdatePetRankCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ActivePetBody, ActivePetBodyCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.UpdatePetBody, UpdatePetBodyCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChangePetBody, ChangePetBodyCallBack);
end

function PetProxy.SendPetAdvance()
	SocketClientLua.Get_ins():SendMessage(CmdType.UpdatePetRank);
end

function PetProxy.SendPetUpdateLevel(id, count)
	return	SocketClientLua.Get_ins():SendMessage(CmdType.UpdatePetLevel, {spId = id, num = count});
end

function PetProxy.SendPetFight(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.ChangePetBody, {id = id});
end

function PetProxy.SendActivePet(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.ActivePetBody, {id = id});
end

function PetProxy.SendUpdateFashionPet(id)
	SocketClientLua.Get_ins():SendMessage(CmdType.UpdatePetBody, {id = id});
end

