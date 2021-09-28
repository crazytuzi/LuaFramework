FunctionConn =BaseClass(LuaUI)

function FunctionConn:__init( ... )
	self.URL = "ui://0tyncec1t5hdnfx";
	self:__property(...)
	self:Config()
	self:InitEvent()
end

function FunctionConn:SetProperty( ... )
	
end

function FunctionConn:Config()
	self.btnList = {}
	local offV = 100
	for i=1,#MainUIConst.functionConnItemId do
		--local funBtn = UIPackage.CreateObject("Main" , "FunctionBtn")
		local funBtn = UIPackage.CreateObject("Common" , "CustomBtn0")
		funBtn:SetSize(74, 73)
		funBtn:SetPivot(0.5 , 0.5)
		self.ui:AddChild(funBtn)
		funBtn:SetXY(0, (i-1)*offV)
		funBtn.data = i
		funBtn.icon = MainUIConst.functionConnItemId[i]
		funBtn.onClick:Add(function ( e ) 
			self:onClickFunctionBtn(e.sender.data)
		end)
		self.btnList[i] = funBtn
	end
end
---策划风格定下来再改为 动态加载这些功能按钮
function FunctionConn:InitEvent()

end
---------------------------------------------------------------------------------------
function FunctionConn:onClickFunctionBtn(id)
	if id == 1 then  --角色
		PlayerInfoController:GetInstance():Open()
	elseif id == 2 then --技能
		SkillController:GetInstance():OpenSkillPanel()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	elseif id == 3 then --神器
		GodFightRuneController:GetInstance():OpenGodFightRunePanel()
	-- elseif id == 4 then --帮会
	-- end
	elseif id == 4 then --好友
		FriendController:GetInstance():Open()
		MainUIModel:GetInstance().isClickPrivateChat = 1
		GlobalDispatcher:DispatchEvent(EventName.IsClickPrivate)
		--FriendController:GetInstance():OpenFriendPanel()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	elseif id == 5 then -- 设置
		SettingCtrl:GetInstance():Open()
	end
end
---------------------------------------------------------------------------------------
-- Register UI classes to lua
function FunctionConn:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common" , "CustomLayerN");
end

-- Combining existing UI generates a class
function FunctionConn.Create( ui, ...)
	return FunctionConn.New(ui, "#", {...})
end

-- Dispose use FunctionConn obj:Destroy()
function FunctionConn:__delete()
	if self.btnList then
		for _,btn in pairs(self.btnList) do
			btn:Destroy()
		end
	end
	self.btnList = {}
	self.null = nil
end


function FunctionConn:GetUIByType(typeData)
	local rtnUI = nil
	if typeData then
		if typeData == FunctionConst.FunEnum.playerInfo then
			rtnUI = self.btnList[1]
		elseif typeData == FunctionConst.FunEnum.skill then
			rtnUI = self.btnList[2]
		elseif typeData == FunctionConst.FunEnum.godFightRune then
			rtnUI = self.btnList[3]
		elseif typeData == FunctionConst.FunEnum.social then
			rtnUI = self.btnList[4]
		elseif typeData == FunctionConst.FunEnum.setting then
			rtnUI = self.btnList[5]
		end
	end
	return rtnUI
end
