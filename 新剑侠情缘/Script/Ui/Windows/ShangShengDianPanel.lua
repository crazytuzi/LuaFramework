local tbUi = Ui:CreateClass("CeremonyPartitionGoldPanel")
--我要上盛典活动展示界面

	-- 集齐我要上盛典，瓜分xxxxx元宝！
	-- 全服共提交盛典令xx个
	-- 大侠共提交盛典令x个
	-- 预计可获得xxx元宝


tbUi.REFRESH_TIME = 5 * 60 --界面打开状态下刷新间隔（秒）

function tbUi:OnOpenEnd()
	self:Ask4ActivityData()
	self.nRegisterId = Timer:Register(self.REFRESH_TIME * Env.GAME_FPS, self.Ask4ActivityData, self)
end

 
function tbUi:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_REFRESH_SHANGSHENGDIAN_DATA, self.RefreshActivityData, self},
	}
	return tbRegEvent
end

function tbUi:RefreshActivityData(tbInfo)

	local szServerTotalCount = string.format("全服共提交盛典令 [ffe955]%d[-] 个", tbInfo.nServerTotalCount)
	local szPlayerTotalCount = string.format("大侠共提交盛典令 [ffe955]%d[-] 个", tbInfo.nPlayerToalCount)
	local szRewardGoldCount = string.format("预计可获得 [ffe955]%d[-] 元宝", tbInfo.nRewardGoldCount)
	self.pPanel:Label_SetText("Txt1", szServerTotalCount)
	self.pPanel:Label_SetText("Txt2", szPlayerTotalCount)
	self.pPanel:Label_SetText("Txt3", szRewardGoldCount)
end

function tbUi:Ask4ActivityData()
	RemoteServer.OnSyncShangShengDianData()
	return true
end

function tbUi:OnClose()
	if self.nRegisterId then
		Timer:Close(self.nRegisterId)
	end
end

tbUi.tbOnClick = tbUi.tbOnClick or {}

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME)
end