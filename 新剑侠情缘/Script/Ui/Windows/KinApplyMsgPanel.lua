local tbUi = Ui:CreateClass("KinApplyMsgPanel")

local tbMsgs = {
	"强力打手，值得信赖！",
	"骨灰玩家，长期在线！",
	"萌妹子一枚，求收留！",
	"自定义留言",
}

tbUi.tbOnClick =
{
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnSure = function(self)
		self:Confirm()
	end,

	Select1 = function(self)
		self.nSelected = 1
	end,
	Select2 = function(self)
		self.nSelected = 2
	end,
	Select3 = function(self)
		self.nSelected = 3
	end,
	Select4 = function(self)
		Ui:OpenWindow("KinApplyCustomMsgPanel", self.nKinId)
		Ui:CloseWindow(self.UI_NAME)
	end,
}

function tbUi:OnOpen(nKinId)
	self.nKinId = nKinId

	for i, szMsg in ipairs(tbMsgs) do
		self.pPanel:Label_SetText("Txt"..i, szMsg)
	end
end

function tbUi:Confirm()
	local szMsg = tbMsgs[self.nSelected or 0]
	if not szMsg then
		me.CenterMsg("请选择留言")
		return
	end
	local bSuccess = Kin:ApplyKin(self.nKinId, szMsg)
	if bSuccess then
		if Ui:WindowVisible("KinJoinPanel")==1 then
			Ui("KinJoinPanel"):OnApplied(self.nKinId)
		end
	end
	Ui:CloseWindow(self.UI_NAME)
end