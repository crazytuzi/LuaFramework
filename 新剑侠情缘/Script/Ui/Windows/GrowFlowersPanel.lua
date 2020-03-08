local tbUi = Ui:CreateClass("GrowFlowersPanel")
function tbUi:OnOpen(tbIllType, nFlowersType)
	self:RefreshUi(tbIllType, nFlowersType)
end

function tbUi:RefreshUi(tbIllType, nFlowersType)
    local tbAct = nFlowersType == 0 and Activity.ArborDayCureAct or Activity.FathersDay
	local nSex = me.GetUserValue(tbAct.GROUP, tbAct.SEX_INACT)
	local szIllText = ""
	for _, nIll in ipairs(tbIllType or {}) do
        szIllText = string.format("%s%s", szIllText, tbAct.tbIllType[nSex][nIll][1])
    end
    szIllText = Lib:IsEmptyStr(szIllText) and "\n它枝叶青翠，十分健康，在风中轻轻舞动着，看起来像是在向你道谢" or szIllText
    self.pPanel:Label_SetText("State", string.format("[92D2FF]植物状态：[-][FF0000]%s[-]", szIllText))

    local szRefresh = tbAct:GetRefreshDesc()
    self.pPanel:Label_SetText("Time", szRefresh or "")

    local fnSetItem = function(itemObj, nIdx)
    	itemObj.pPanel:Label_SetText("Label", tbAct.tbIllType[nSex][nIdx][2])
    	itemObj.pPanel:Sprite_SetSprite("Icon", tbAct.tbIllType[nSex][nIdx][4]);
    	itemObj.pPanel.OnTouchEvent = function ()
            if Activity:__IsActInProcessByType("ArborDayCure") or Activity:__IsActInProcessByType("FathersDay") then
                RemoteServer.ArborDayTryCure(nIdx)
                return
            end
            me.CenterMsg("活动已经结束", true)
    	end
	end
    self.ScrollView:Update(#tbAct.tbIllType[nSex], fnSetItem)
end

tbUi.tbOnClick = {
	BtnClose = function (self)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
		{ UiNotify.emNOTIFY_ARBOR_CURE_OK,		self.RefreshUi };
	};

	return tbRegEvent;
end