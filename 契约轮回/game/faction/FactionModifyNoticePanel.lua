--
-- @Author: chk
-- @Date:   2018-12-18 17:19:23
--
FactionModifyNoticePanel = FactionModifyNoticePanel or class("FactionModifyNoticePanel",WindowPanel)
local FactionModifyNoticePanel = FactionModifyNoticePanel

function FactionModifyNoticePanel:ctor()
	self.abName = "faction"
	self.assetName = "FactionModifyNoticePanel"
	self.layer = "UI"

	self.use_background = true
	self.change_scene_close = true
	self.panel_type = 4
	self.model = FactionModel:GetInstance()
end

function FactionModifyNoticePanel:dctor()
end

function FactionModifyNoticePanel:Open( )
	FactionModifyNoticePanel.super.Open(self)
end

function FactionModifyNoticePanel:LoadCallBack()
	self.nodes = {
		"saveBtn",
		"saveAndQuitBtn",
		"Count",
		"Scroll View/Viewport/Content/InputField",
		"stText"
	}
	self:GetChildren(self.nodes)
	self.InputFieldIpt = self.InputField:GetComponent('InputField')
	self.InputFieldIpt.text = self.model.selfFactionInfo.notice
	SetVisible(self.Count,false)
	SetVisible(self.stText,false)
	local leaveCount = 3 - self.model.selfFactionInfo.modify
	if leaveCount < 0 then
		leaveCount = 0
	end
	self.Count:GetComponent('Text').text = (leaveCount ) .. "/3"
	self:AddEvent()
	self:SetTileTextImage("faction_image", "faction_ref_title");

end

function FactionModifyNoticePanel:AddEvent()
	local function call_back(target,x,y)
		if FilterWords:GetInstance():isSafe(self.InputFieldIpt.text) then
			FactionController.GetInstance():RequestModifyNotice(self.InputFieldIpt.text,false)
			self:Close()
		else
			Notify.ShowText("Illegal character was found")
		end
	end
	AddClickEvent(self.saveBtn.gameObject,call_back)

	local function call_back(target,x,y)
		if self.model.selfFactionInfo.modify >= 3 then

			local function call_back()
				if FilterWords:GetInstance():isSafe(self.InputFieldIpt.text) then
					FactionController.GetInstance():RequestModifyNotice(self.InputFieldIpt.text,true)
					self:Close()
				else
					Notify.ShowText("Illegal character was found")
				end
			end

			local guildModifyCfg = Config.db_game["guild_modify"]
			local modifyTbl = String2Table(guildModifyCfg.val)
			Dialog.ShowTwo(ConfigLanguage.Faction.ModifyNotice, string.format(ConfigLanguage.Faction.ModifyNoticeNotCount,
					modifyTbl[1][2][1][2]) ,
					ConfigLanguage.Mix.Comfirm,call_back)
		else
			if FilterWords:GetInstance():isSafe(self.InputFieldIpt.text) then
				FactionController.GetInstance():RequestModifyNotice(self.InputFieldIpt.text,true)
				self:Close()
			else
				Notify.ShowText("Illegal character was found")
			end
		end

	end
	AddClickEvent(self.saveAndQuitBtn.gameObject,call_back)
end

function FactionModifyNoticePanel:OpenCallBack()
	self:UpdateView()
end

function FactionModifyNoticePanel:UpdateView( )

end

function FactionModifyNoticePanel:CloseCallBack(  )

end