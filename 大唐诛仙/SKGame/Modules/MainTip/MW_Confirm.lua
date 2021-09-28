MW_Confirm =BaseClass(LuaMsgWin)

function MW_Confirm:__init( ... )
	local ui = UIPackage.CreateObject("MainTip","MW_Confirm")
	self.ui = ui
	self.title = ui:GetChild("title")
	self.rollContent = ui:GetChild("rollContent")
	self.btnEnter = ui:GetChild("btnEnter")
	self.btnExit = ui:GetChild("btnExit")
	self.btnClose = ui:GetChild("btnClose")

	self.btnConfirmText = self.btnEnter:GetChild("title")
	self.btnCancelText = self.btnExit:GetChild("title")
	self:InitEvent()
end

function MW_Confirm:SetData(title, explain, btnConfirmTxt, btnCancelTxt, confirmCallBack, cancelCallBack, isShowClose)
	if title ~= nil and title ~= "" then self.title.text = title end
	if explain ~= nil and explain ~= "" then self.rollContent.title = explain end
	if btnConfirmTxt ~= nil and btnConfirmTxt ~= "" then self.btnConfirmText.text = btnConfirmTxt end
	if btnCancelTxt ~= nil and btnCancelTxt ~= "" then self.btnCancelText.text = btnCancelTxt end
	self._confirmCallBack = confirmCallBack
	self._cancelCallBack = cancelCallBack
	self.btnClose.visible = isShowClose or false
end

function MW_Confirm:InitEvent()
	self.btnEnter.onClick:Add(function (  )
		self:ClickBtnConfirm()
	end)
	self.btnExit.onClick:Add(function (  )
		self:ClickBtnCancel()
	end)
	self.btnClose.onClick:Add(function (  )
		self:ClickCloseHandle()
	end)
end

function MW_Confirm:RemoveEvent()
	self.btnEnter.onClick:Clear()
	self.btnExit.onClick:Clear()
	self.btnClose.onClick:Clear()
end

function MW_Confirm:ClickBtnConfirm()
	if self._confirmCallBack ~= nil then
  	  pcall(self._confirmCallBack, self)
	end
	self:Destroy()
end

function MW_Confirm:ClickBtnCancel()
	if self._cancelCallBack ~= nil then
  	  pcall(self._cancelCallBack, self)
	end
	self:Destroy()
end

function MW_Confirm:ClickCloseHandle()
	self:Destroy()
end

function MW_Confirm:__delete()
	self:Close()
	self:RemoveEvent()
	self.bg = nil
	self.title = nil
	self.content = nil
	self.btnEnter = nil
	self.btnExit = nil
	self.btnClose = nil
end