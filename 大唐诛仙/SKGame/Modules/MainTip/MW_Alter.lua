MW_Alter =BaseClass(LuaMsgWin)

function MW_Alter:__init( ... )
	self.ui = ui or self.ui or UIPackage.CreateObject("MainTip","MW_Alter");

	self.bg = self.ui:GetChild("bg")
	self.titleTxt = self.ui:GetChild("titleTxt")
	self.titleExplain = self.ui:GetChild("titleExplain")
	self.btnConfirm = self.ui:GetChild("btnConfirm")
	self.btnText = self.btnConfirm:GetChild("title")
	self.alpha = self.ui:GetChild("alpha")

	self:InitEvent()
end

function MW_Alter:SetData(title, explain, btnTxt, callBack)
	if title ~= nil and title ~= "" then self.titleTxt.text = title end
	if explain ~= nil and explain ~= "" then self.titleExplain.text = explain end
	if btnTxt ~= nil and btnTxt ~= "" then self.btnText.text = btnTxt end
	self._callBack = callBack
end

function MW_Alter:InitEvent()
	self.btnConfirm.onClick:Add(function ()
		self:ClickBtnConfirm()
	end)
end

function MW_Alter:RemoveEvent()
	if not self.btnConfirm then return end
	self.btnConfirm.onClick:Clear()
end

function MW_Alter:ClickBtnConfirm()
	if self._callBack ~= nil then
  	  pcall(self._callBack, self)
	end
	self:Destroy()
end
function MW_Alter:Cancel()
	self:Destroy()
end
function MW_Alter:__delete()
	self:Close()
	self:RemoveEvent()
	self.bg = nil
	self.titleTxt = nil
	self.titleExplain = nil
	self.btnConfirm = nil
end