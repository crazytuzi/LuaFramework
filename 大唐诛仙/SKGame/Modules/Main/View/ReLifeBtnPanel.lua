ReLifeBtnPanel = BaseClass(LuaUI)

function ReLifeBtnPanel:__init( ... )
	self.ui = UIPackage.CreateObject("Main","ReLifeBtnPanel");

	self.reliftBtn = self.ui:GetChild("reliftBtn")
	self.bgName = self.ui:GetChild("bgName")
	self.txtName = self.ui:GetChild("txtName")
	self:SetNameShow(false)
	self:InitEvent()
end

function ReLifeBtnPanel:InitEvent()
	self.reliftBtn.onClick:Add(function()
		SceneController:GetInstance():RequireRevive(1) -- 玩家复活
		UIMgr.HidePopup()
	end, self)
end

function ReLifeBtnPanel:RefreshUI(dataTab)
	local fighterName = nil
	local isPlayerKill = nil
	if dataTab then
		self:SetNameShow(true)
		isPlayerKill = dataTab[2]
		if isPlayerKill then
			fighterName = dataTab[1]
			fighterName = fighterName or ""
			self.txtName.text = StringFormat( "{0}[color={1}]{2}[/color]{3}", "玩家", "#ff3737", fighterName, "将你击杀" )
		else
			self.txtName.text = StringFormat( "你在野外被打败了，将会在主城复活" )
		end
	else
		self:SetNameShow(false)
	end
end

function ReLifeBtnPanel:SetNameShow(bShow)
	self.bgName.visible = bShow
	self.txtName.visible = bShow
end

-- Dispose use ReLifeBtnPanel obj:Destroy()
function ReLifeBtnPanel:__delete()
end