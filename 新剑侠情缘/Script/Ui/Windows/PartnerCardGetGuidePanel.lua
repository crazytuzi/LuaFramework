local tbUi = Ui:CreateClass("PartnerCardGetGuidePanel");
function tbUi:OnOpen()
	self:Update()
end

function tbUi:Update()
	local bRunningAct = Activity:__IsActInProcessByType("PartnerCardPickAct")
	-- self.pPanel:Button_SetEnabled("BtnGet1", bRunningAct and true or false);
	-- self.pPanel:Sprite_SetGray("BtnGet1", not bRunningAct);
	local szTips = bRunningAct and string.format("每日[FFFE0D]前%d次[-]元宝十连抽有概率获取([FFFE0D]活动[-])", PartnerCard.nMaxPickCard) or "元宝招募，是获取甲、地级门客的快捷途径"
	self.pPanel:Label_SetText("TextInfo1", szTips)
end
tbUi.tbOnClick = {}
tbUi.tbOnClick.BtnClose = function (self)
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnGet1 = function (self)
	-- local bRunningAct = Activity:__IsActInProcessByType("PartnerCardPickAct")
	-- if not bRunningAct then
	-- 	me.CenterMsg("活动已经结束", true)
	-- 	return
	-- end
	Ui:OpenWindow("Partner", "CardPickingPanel")
	Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnGet2 = function (self)
	Ui:OpenWindow("Partner", "PartnerGralleryPanel")
	Ui:CloseWindow(self.UI_NAME)
	UiNotify.OnNotify(UiNotify.emNOTIFY_REFRESH_PARTNER_GRALLERY, 4)
end