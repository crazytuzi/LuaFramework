Activites =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function Activites:__init( ... )
	self.URL = "ui://0tyncec1t5hdnfx";
	self:__property(...)
	self:Config()
end

-- Set self property
function Activites:SetProperty( ... )
	
end

-- Logic Starting
function Activites:Config()
	self.btnList = {}
	local offV = 80
	local offH = 80
	local activityData = MainUIModel:GetInstance():GetActivitesPushNotice()
	for i = 1 , #activityData do
		local curData = activityData[i]
		if not TableIsEmpty(curData) then
			local pos = curData.apper or -1
			if pos == -1 then print("Activites activityData 数据有误") break end
			local funBtn = UIPackage.CreateObject("Common" , "CustomBtn0")
			funBtn:SetSize(74, 73)
			funBtn:SetPivot(0.5, 0.5)
			self.ui:AddChild(funBtn)

			local x =  500 - (( pos -1 ) % 6) * offV
			local y = math.floor((i -1) / 6 ) * offH

			funBtn:SetXY(x , y)

			funBtn.data = curData.moduleId
			funBtn.icon = MainUIConst.ActivityItemIcon[curData.moduleId] or ""
			funBtn.onClick:Add(function ( e ) 
				self:OnClickFunctionBtn(e.sender.data)
			end)
			funBtn.name = StringFormat("{0}{1}" , curData.moduleId or "-1" , curData.apper or "-1")
			self.btnList[pos] = funBtn

		end
	end
end

function Activites:OnClickFunctionBtn(id)
	if SceneModel:GetInstance():IsInNewBeeScene() and 
		id ~= FunctionConst.FunEnum.store and 
		id ~= FunctionConst.FunEnum.firstRecharge and 
		id ~= FunctionConst.FunEnum.OpenGift then -- 商城入口在新手村就打开
			UIMgr.Win_FloatTip("通关彼岸村后可使用")
			return
	end

	if id == FunctionConst.FunEnum.deal then  --交易
		TradingController:GetInstance():Open()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	elseif id == FunctionConst.FunEnum.rank then --排行
		RankController:GetInstance():OpenRankPanel()
	elseif id == FunctionConst.FunEnum.welfare then --福利
		WelfareController:GetInstance():OpenWelfarePanel()
	elseif id == FunctionConst.FunEnum.activity then --活动
		ActivityController:GetInstance():OpenDayActivityPanel()
		GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
	elseif id == FunctionConst.FunEnum.shenjing then --神镜
		ShenJingController:GetInstance():OpenShenJingPanel()
	elseif id == FunctionConst.FunEnum.copy then --副本
		GuideController:GetInstance():GotoFB()
	elseif id == FunctionConst.FunEnum.ladder then --侍魂
		TiantiController:GetInstance():Open()
	elseif id == FunctionConst.FunEnum.store then --商城
		MallController:GetInstance():OpenMallPanel()
	elseif id == FunctionConst.FunEnum.carnival then --充值
		RechargeController:GetInstance():Open()
	elseif id == FunctionConst.FunEnum.firstRecharge then -- 首充
		FirstRechargeCtrl:GetInstance():Open()
	elseif id == FunctionConst.FunEnum.SevenLogin then --七天
		SevenLoginController:GetInstance():Open()
	elseif id == FunctionConst.FunEnum.OpenGift then -- 特惠
		OpenGiftCtrl:GetInstance():Open()
	elseif id == FunctionConst.FunEnum.furnace then -- 熔炉
		FurnaceCtrl:GetInstance():Open()
	end
end

-- Register UI classes to lua
function Activites:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Common" , "CustomLayerN")
end

-- Combining existing UI generates a class
function Activites.Create( ui, ...)
	return Activites.New(ui, "#", {...})
end

-- Dispose use Activites obj:Destroy()
function Activites:__delete()
	
	self.null = nil
end

function Activites:GetUIByType(typeData)
	local rtnUI = nil
	
	if typeData then
		for k , v in pairs(self.btnList) do
			if self.btnList[k] and self.btnList[k].data == typeData then
				rtnUI = self.btnList[k]
				break
			end
		end
	end

	return rtnUI
end


