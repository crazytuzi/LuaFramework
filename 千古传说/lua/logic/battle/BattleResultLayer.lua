
local BattleResultLayer = class("BattleResultLayer", BaseLayer)

TipsList    = require("lua.table.t_s_help_tips")

function BattleResultLayer:ctor(data)
    self.super.ctor(self,data)
    self:init("lua.uiconfig_mango_new.zhenbashai.Jiesuan")
end

function BattleResultLayer:initUI(ui)
	self.super.initUI(self,ui)

	self.fightResultInfo = FightManager.fightResultInfo

	self.replayBtn = TFDirector:getChildByPath(ui, 'btn_fanhui')
	self.leaveBtn = TFDirector:getChildByPath(ui, 'btn_jixu')
	self.btn_shtj = TFDirector:getChildByPath(ui, 'btn_shtj')

	self.rolePanel = {}
	for i=1,2 do
		self.rolePanel[i] = TFDirector:getChildByPath(ui, 'Panel_role'..i)
	end

	self:PlaySoundEffect()


	self.roleInfo = {}
	if self.fightResultInfo.win then --self.fightResultInfo.atkHurt >= self.fightResultInfo.defHurt then
		self.roleInfo[1] = {}
		self.roleInfo[1].name = self.fightResultInfo.atkName
		self.roleInfo[1].hurt = self.fightResultInfo.atkHurt
		self.roleInfo[1].headPicFrame = self.fightResultInfo.atkHeadPicFrame------------------TempFrameId         --pck change head icon and head icon frame
		self.roleInfo[1].profession = self.fightResultInfo.atkProfession
		self.roleInfo[1].iconId = self.fightResultInfo.atkIcon

		self.roleInfo[2] = {}
		self.roleInfo[2].name = self.fightResultInfo.defName
		self.roleInfo[2].hurt = self.fightResultInfo.defHurt
		self.roleInfo[2].headPicFrame = self.fightResultInfo.defHeadPicFrame------------------TempFrameId
		self.roleInfo[2].profession = self.fightResultInfo.defProfession
		self.roleInfo[2].iconId = self.fightResultInfo.defIcon
	else
		self.roleInfo[1] = {}
		self.roleInfo[1].name = self.fightResultInfo.defName
		self.roleInfo[1].hurt = self.fightResultInfo.defHurt
		self.roleInfo[1].headPicFrame = self.fightResultInfo.defHeadPicFrame------------------TempFrameId
		self.roleInfo[1].profession = self.fightResultInfo.defProfession
		self.roleInfo[1].iconId = self.fightResultInfo.defIcon

		self.roleInfo[2] = {}
		self.roleInfo[2].name = self.fightResultInfo.atkName
		self.roleInfo[2].hurt = self.fightResultInfo.atkHurt
		self.roleInfo[2].headPicFrame = self.fightResultInfo.atkHeadPicFrame------------------TempFrameId
		self.roleInfo[2].profession = self.fightResultInfo.atkProfession
		self.roleInfo[2].iconId = self.fightResultInfo.atkIcon											--end
	end

	self:PlayResultEffect()
end

function BattleResultLayer:removeUI()
	if self.updateTimerID ~= nil then
		TFDirector:removeTimer(self.updateTimerID)
	end


	self.super.removeUI(self)
end

function BattleResultLayer:registerEvents(ui)	
	self.super.registerEvents(self)

	self.replayBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.relayClickHandle),1)
	self.leaveBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(self.leaveBtnHandle),1)
	self.btn_shtj:addMEListener(TFWIDGET_CLICK, audioClickfun(self.hurtCountClickHandle),1)


	ADD_KEYBOARD_CLOSE_LISTENER(self, self.ui)
end

function BattleResultLayer:PlaySoundEffect()
	local nResult = self.fightResultInfo.result
	if nResult == 0 then
		TFAudio.playEffect("sound/effect/fight_fail.mp3", false)
	else
		TFAudio.playEffect("sound/effect/fight_win.mp3", false)
	end
end

function BattleResultLayer:PlayResultEffect()
	for i=1,2 do
		local img_head = TFDirector:getChildByPath(self.rolePanel[i],"img_head")
		local txt_shanghai = TFDirector:getChildByPath(self.rolePanel[i],"txt_shanghai")
		local txt_name = TFDirector:getChildByPath(self.rolePanel[i],"txt_name")
		local img_Frame = TFDirector:getChildByPath(self.rolePanel[i],"img_tou")
		if i == 2 then
			img_head:setFlipX(false)
		end
		txt_name:setText(self.roleInfo[i].name)
		txt_shanghai:setText(self.roleInfo[i].hurt)
		if nil == self.roleInfo[i].iconId or self.roleInfo[i].iconId <= 0 then         --pck change head icon and head icon frame
			self.roleInfo[i].iconId = self.roleInfo[i].profession
		end
		local role_info = RoleData:objectByID(self.roleInfo[i].iconId)
		if role_info then
			img_head:setTexture(role_info:getIconPath())
		end
		Public:addFrameImg(img_head,self.roleInfo[i].headPicFrame)                    --end
	end
end

function BattleResultLayer.relayClickHandle(btn)
	FightManager:ReplayBattle()
end

function BattleResultLayer.leaveBtnHandle(btn)
	FightManager:LeaveFight()
end

function BattleResultLayer.hurtCountClickHandle(btn)
	FightManager:openBattleHurtCount()
end

return BattleResultLayer
