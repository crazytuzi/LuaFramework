require "SKGame/Modules/Common/CommonConst"
require "SKGame/Modules/Common/CommonModel"
require "SKGame/Modules/Tips/EquipmentInfoTips"
require "SKGame/Modules/Tips/EquipmentInfoTipsTop"
require "SKGame/Modules/Tips/EquipmentInfoCompareTips"
require "SKGame/Modules/Tips/PowerTip/PowerTips"
require "SKGame/Modules/Tips/PowerTip/PowerTipEdition"
require "SKGame/Modules/Tips/AutoRunTips"
require "SKGame/Modules/Tips/AutoFightTips"

require "SKGame/Modules/Common/View/ReturnCDBar"

require "SKGame/Modules/Common/View/DescPanel"


CommonController = BaseClass(LuaController)
--单例模式
function CommonController:GetInstance()
	if CommonController.Instacne == nil then 
		CommonController.Instacne = CommonController.New()
	end
	return CommonController.Instacne
end
-- 初始化使用 .New(...)
function CommonController:__init( ... )
	self:Config()
	self:InitEvent()
end

function CommonController:Config()
	resMgr:AddUIAB("Common")
	resMgr:AddUIAB("Tips")
	self.popupRoot = nil
	self.handler_SCENE_LOAD_FINISH = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH,function ()
		self:LoadPowerTipsRoot()
	end)
	self.handler_StartReturnMainCity = GlobalDispatcher:AddEventListener(EventName.StartReturnMainCity,function (v)
		local scene = SceneController:GetInstance():GetScene()
		local player = scene:GetMainPlayer()
		if player then
			player:StopMove()
			self:LoadReturnCDBar(v)
		end
	end)
	self.handler_StopReturnMainCity = GlobalDispatcher:AddEventListener(EventName.StopReturnMainCity,function ()
		self:DestroyReturnCDBar()
	end)
	self.handler_UNLOAD_SCENE = GlobalDispatcher:AddEventListener(EventName.UNLOAD_SCENE,function ()
		self:DestroyReturnCDBar()
	end)
	self.handler_SocialTeam = GlobalDispatcher:AddEventListener(EventName.SocialTeam, function ()
		self:OpenSocialTeam()
	end)
end

function CommonController:InitEvent()
	
end

function CommonController:LoadPowerTipsRoot()
	if self.powerTips == nil then 
		self.powerTips = PowerTipEdition.New()
	end
end

function CommonController:OpenSocialTeam()
	 
end

--加载回城倒计时条
function CommonController:LoadReturnCDBar(data)
	SceneController:GetInstance():GetScene():StopAutoFight(true)
	if self.returnCDBar then
		self.returnCDBar:Destroy()
	end

	self.returnCDBar = ReturnCDBar.New(data)
	self.returnCDBar:AddTo(layerMgr:GetUILayer())
	self.returnCDBar:SetXY(500,500)
end
--销毁回城倒计时条
function CommonController:DestroyReturnCDBar()
	if self.returnCDBar then 
		self.returnCDBar:Destroy()
	end
	self.returnCDBar = nil
end

function CommonController:IsReturning()
	return self.returnCDBar ~= nil
end
	
--加载
function CommonController:Close()
end
function CommonController:__delete()
	if self.popupRoot then
		self.popupRoot:Destroy()
	end
	self.popupRoot = nil
	GlobalDispatcher:RemoveEventListener(self.handler_SCENE_LOAD_FINISH)
	GlobalDispatcher:RemoveEventListener(self.handler_StartReturnMainCity)
	GlobalDispatcher:RemoveEventListener(self.handler_StopReturnMainCity)
	GlobalDispatcher:RemoveEventListener(self.handler_UNLOAD_SCENE)
	GlobalDispatcher:RemoveEventListener(self.handler_SocialTeam)
	CommonController.Instacne = nil
end

