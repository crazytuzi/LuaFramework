--[[
--每回合尝试可以使用的技能
--主动技能：客户端都法术文件
--其他的：服务器GS2CShowWarSkill
伙伴：主动技能（字）、被动技能（图）
主角：主动技能（字）、被动技能（图）
符文：图
装备套装：图
buff：字

]]
local CWarriorMagicHud = class("CWarriorMagicHud", CAsyncHud)
CWarriorMagicHud.DEFAULT_ALIVE_TIME = 1
function CWarriorMagicHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorMagicHud.prefab", cb, true)
end

function CWarriorMagicHud.OnCreateHud(self)
	self.m_SkillLabelBox = self:NewUI(1, CBox)
	self.m_SkillSpriteBox = self:NewUI(2, CBox)
	self.m_EquipSpriteBox = self:NewUI(3, CBox)
	self.m_PartnerEquipBox = self:NewUI(4, CBox)
	self.m_UseMagicBox = self:NewUI(5, CBox)

	self.m_ShowType = {
		["client_txt"] = 0,  			--客户端自己用
		["partnerskill_pic"] = 1,	--伙伴技能，服务器控制
		["heroskill_pic"] = 2, 		--主角技能，服务器控制
		["partnerequip_pic"] = 3,	--伙伴符文，服务器控制
		["heroequip_pic"] = 4, 		--主角套装，服务器控制
		["buff_txt"] = 5,				--buff,服务器控制
		["se_txt"] = 6,				--se,服务器控制
		["passive_txt"] = 7,			--被动技能，服务器控制
	}

	self:Recycle()
end

function CWarriorMagicHud.ShowWarSkillByClient(self, iMagic, alive_time)
	printc("客户端主动技能喊招：", iMagic)
	alive_time = alive_time or CWarriorMagicHud.DEFAULT_ALIVE_TIME
	self:InsertCmd(self.m_ShowType["client_txt"], iMagic, alive_time)
	self:UpdateMgr()
end

function CWarriorMagicHud.ShowWarSkillByServer(self, iMagic, iType)
	--type 1.伙伴,2.门派,3符文,4.装备,5.buff
	local alive_time = 0.5
	self:InsertCmd(iType, iMagic, alive_time)
	self:UpdateMgr()
end

function CWarriorMagicHud.UpdateMgr(self)
	if not self.m_TextTimer then
		local function updatetext()
			if Utils.IsNil(self) then
				return false
			end
			if self.m_LockText then
				return true
			end
			local oCmd = table.remove(self.m_TextCmds, 1)
			if oCmd then
				self.m_LockText = true
				self:ExcuteCmd(oCmd)
			end
			return true
		end
		self.m_TextTimer = Utils.AddTimer(updatetext, 0, 0)
	end
	if not self.m_PictureTimer then
		local function updatepicture()
			if Utils.IsNil(self) then
				return false
			end
			if self.m_LockPicture then
				return true
			end
			local oCmd = table.remove(self.m_PictureCmds, 1)
			if oCmd then
				self.m_LockPicture = true
				self:ExcuteCmd(oCmd)
			end
			return true
		end
		self.m_PictureTimer = Utils.AddTimer(updatepicture, 0, 0)		
	end
end

function CWarriorMagicHud.InsertCmd(self, iType, iMagic, alive_time)
	if iType == self.m_ShowType["client_txt"] then
		table.insert(self.m_TextCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["partnerskill_pic"] then
		table.insert(self.m_PictureCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["heroskill_pic"] then
		table.insert(self.m_PictureCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["partnerequip_pic"] then
		table.insert(self.m_PictureCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["heroequip_pic"] then
		table.insert(self.m_PictureCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["buff_txt"] then
		table.insert(self.m_TextCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["se_txt"] then
		table.insert(self.m_TextCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	elseif iType == self.m_ShowType["passive_txt"] then
		table.insert(self.m_TextCmds, {iType=iType, iMagic=iMagic, alive_time=alive_time, used = false})
	end
end

function CWarriorMagicHud.ExcuteCmd(self, oCmd)
	if oCmd.iType == self.m_ShowType["client_txt"] then
		self:AddSkillTxt(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["partnerskill_pic"] then
		self:AddSkillPic(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["heroskill_pic"] then
		self:AddSkillPic(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["partnerequip_pic"] then
		self:AddFuWenPic(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["heroequip_pic"] then
		self:AddEquipPic(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["buff_txt"] then
		self:AddBuffTxt(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["se_txt"] then
		self:AddSETxt(oCmd.iMagic, oCmd.alive_time)
	
	elseif oCmd.iType == self.m_ShowType["passive_txt"] then
		self:AddPassiveTxt(oCmd.iMagic, oCmd.alive_time)
	end
end

function CWarriorMagicHud.AutoDestroy(self, obj)
	if not obj or Utils.IsNil(obj) then
		return
	end
	if obj.m_AlphaAction then
		g_ActionCtrl:DelAction(obj.m_AlphaAction)
	end
	obj.m_AlphaAction = CActionFloat.New(obj, 0.5, "SetAlpha", 1, 0)
	obj.m_AlphaAction:SetEndCallback(function ()
		obj:Destroy()
	end)
	g_ActionCtrl:AddAction(obj.m_AlphaAction, 0.5)
end

function CWarriorMagicHud.ShowText(self, oBox, alive_time)
	oBox.m_Sequence = DOTween.Sequence(oBox.m_Transform)
	local tween = DOTween.DOLocalMove(oBox.m_Transform, Vector3.New(0, -10, 0), alive_time)
	DOTween.Append(oBox.m_Sequence, tween)
	DOTween.OnComplete(tween, function ()
		self.m_LockText = false
		oBox.m_Timer = Utils.AddTimer(callback(self, "AutoDestroy", oBox), 0, 0)
	end)
end

function CWarriorMagicHud.ShowPicture(self, oBox, alive_time)
	oBox.m_Sequence = DOTween.Sequence(oBox.m_Transform)
	local tween = DOTween.DOScale(oBox.m_Transform, Vector3.New(1, 1, 1), 2)	
	DOTween.Append(oBox.m_Sequence, tween)
	DOTween.OnComplete(tween, function ()
		self.m_LockPicture = false

		oBox.m_Timer = Utils.AddTimer(callback(self, "AutoDestroy", oBox), 0, 0)
	end)
end

function CWarriorMagicHud.AddSkillTxt(self, iMagic, alive_time)
	--策划的表太多了。。。
	local name
	if data.skilldata.INIT_SKILL[iMagic] then
		name = data.skilldata.INIT_SKILL[iMagic].skill_name
	elseif data.skilldata.DESC[iMagic] then
		name = data.skilldata.DESC[iMagic].skill_name
	elseif data.skilldata.PARTNERSKILL[iMagic] then
		name = data.skilldata.PARTNERSKILL[iMagic].name
	end

	if name then
		local oBox = self.m_SkillLabelBox:Clone()
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_Label:SetText(name)
		oBox:SetParent(self.m_Transform)
		oBox:SetLocalPos(Vector3.New(0, -100, 0))
		oBox:SetActive(true)
		self:ShowText(oBox, alive_time)
	else
		printc("请配表：", iMagic)
	end
end

function CWarriorMagicHud.AddSkillPic(self, iMagic, alive_time)
	printc("服务器被动技能图标：", iMagic)
	local dMagic = data.magicdata.DATA[iMagic]
	local oBox
	if dMagic then 
		oBox = self.m_SkillSpriteBox:Clone()
		oBox.m_Sprite = oBox:NewUI(1, CSprite)
		oBox.m_Sprite:SpriteMagic(dMagic.skill_icon)
	else
		local dSkill = data.skilldata.INIT_SKILL[iMagic]
		if dSkill then
			oBox = self.m_SkillSpriteBox:Clone()
			oBox.m_Sprite = oBox:NewUI(1, CSprite)
			oBox.m_Sprite:SpriteSkill(dSkill.icon)
		else
			dSkill = data.skilldata.PARTNERSKILL[iMagic]
			if dSkill then
				oBox = self.m_SkillSpriteBox:Clone()
				oBox.m_Sprite = oBox:NewUI(1, CSprite)
				oBox.m_Sprite:SpriteSkill(dSkill.icon)
			else
				return
			end
		end
	end
	if oBox then
		oBox:SetParent(self.m_Transform)
		oBox:SetLocalPos(Vector3.New(0, 70, 0))
		oBox:SetLocalScale(Vector3.New(0, 0, 0))
		oBox:SetActive(true)
		self:ShowPicture(oBox, alive_time)
	end
end

function CWarriorMagicHud.AddFuWenPic(self, iMagic, alive_time)
	printc("服务器符文图标：", iMagic)
	local oBox = self.m_PartnerEquipBox:Clone()
	oBox.m_Texture = oBox:NewUI(1, CTexture)
	oBox.m_BgSprite = oBox:NewUI(2, CSprite)

	oBox.m_BgSprite:SetActive(true)
	oBox:SetParent(self.m_Transform)
	local function cb()
		if Utils.IsNil(self) then
			if oBox and not Utils.IsNil(oBox) then
				oBox:Destroy()
			end
			return
		end
		oBox:SetLocalPos(Vector3.New(0, 100, 0))
		oBox:SetLocalScale(Vector3.New(0, 0, 0))
		oBox:SetActive(true)
		self:ShowPicture(oBox, alive_time)
	end
	oBox.m_Texture:LoadPartnerEquip(iMagic, cb)

end

function CWarriorMagicHud.AddEquipPic(self, iMagic, alive_time)
	printc("服务器装备图标：", iMagic)
	local oBox = self.m_EquipSpriteBox:Clone()
	local dEquipSkill = data.skilldata.EQUIP_SKILL[iMagic]
	oBox.m_Sprite = oBox:NewUI(1, CSprite)
	oBox.m_Sprite:SpriteItemShape(dEquipSkill.icon)
	oBox:SetParent(self.m_Transform)
	oBox:SetLocalPos(Vector3.New(0, 70, 0))
	oBox:SetLocalScale(Vector3.New(0, 0, 0))
	oBox:SetActive(true)
	self:ShowPicture(oBox, alive_time)
end

function CWarriorMagicHud.AddBuffTxt(self, iBuff, alive_time)
	printc("服务器buff名字", iBuff)
	local dBuff = data.buffdata.DATA[iBuff]
	if dBuff then
		local oBox = self.m_SkillLabelBox:Clone()
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_Label:SetText(dBuff.name)
		oBox:SetParent(self.m_Transform)
		oBox:SetLocalPos(Vector3.New(0, -100, 0))
		oBox:SetActive(true)
		self:ShowText(oBox, alive_time)
	end
end

function CWarriorMagicHud.AddSETxt(self, iBuff, alive_time)
	printc("服务器被动技能文字", iBuff)
	local dSkill = data.skilldata.SE[iBuff]
	if dSkill then
		local oBox = self.m_SkillLabelBox:Clone()
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_Label:SetText(dSkill.name)
		oBox:SetParent(self.m_Transform)
		oBox:SetLocalPos(Vector3.New(0, -100, 0))
		oBox:SetActive(true)
		self:ShowText(oBox, alive_time)
	end
end

function CWarriorMagicHud.AddPassiveTxt(self, iBuff, alive_time)
	printc("被动技能文字，通用读这个表", iBuff)
	local dSkill = data.passiveskilldata.DATA[iBuff]
	if dSkill then
		local oBox = self.m_SkillLabelBox:Clone()
		oBox.m_Label = oBox:NewUI(1, CLabel)
		oBox.m_Label:SetText(dSkill.skill_name)
		oBox:SetParent(self.m_Transform)
		oBox:SetLocalPos(Vector3.New(0, -100, 0))
		oBox:SetActive(true)
		self:ShowText(oBox, alive_time)
	end
end


function CWarriorMagicHud.SetUseMagic(self, magicid)
	local oBox = self.m_UseMagicBox
	if not magicid then
		oBox:SetActive(false)
		return
	end
	oBox:SetActive(true)
	oBox.m_IconSpr = oBox:NewUI(1, CSprite)
	oBox.m_SpSprite= oBox:NewUI(2, CSprite)

	oBox.m_IconSpr:SpriteMagic(magicid)
	local dData = DataTools.GetMagicData(magicid)
	if dData and dData.sp and dData.sp > 0 then
		oBox.m_SpSprite:SetActive(true)
	else
		oBox.m_SpSprite:SetActive(false)
	end
end

function CWarriorMagicHud.Recycle(self)
	self.m_TextCmds = {}		--文字队列	
	self.m_PictureCmds = {}	--图片队列(sprite, texture)
	self.m_SkillLabelBox:SetActive(false)
	self.m_SkillSpriteBox:SetActive(false)
	self.m_EquipSpriteBox:SetActive(false)
	self.m_PartnerEquipBox:SetActive(false)
	self.m_UseMagicBox:SetActive(false)
	self:ClearTimer()
end

function CWarriorMagicHud.ClearTimer(self)
	if self.m_TextTimer then
		Utils.DelTimer(self.m_TextTimer)
		self.m_TextTimer = nil
	end
	if self.m_PictureTimer then
		Utils.DelTimer(self.m_PictureTimer)
		self.m_PictureTimer = nil
	end
end

return CWarriorMagicHud