FunctionView =BaseClass()

function FunctionView:__init()

end

function FunctionView:__delete()

end

--打开某个功能模块UI
function FunctionView:OpenModuleUI(data)
	
	if data then
		if data == FunctionConst.FunEnum.mingwenStore then
			--铭文商店尚未开发，暂时用这个测试
			TradingController:GetInstance():Open()
		elseif data == FunctionConst.FunEnum.drugStore then
			TradingController:GetInstance():Open()
		elseif data == FunctionConst.FunEnum.dailyTask then
			DailyTaskController:GetInstance():OpenDailyTaskPanel()
			if TaskModel:GetInstance():IsHasDailyTask() == false and DailyTaskModel:GetInstance():GetDailyListFlag() == false then
				
				DailyTaskController:GetInstance():GetDailyTaskList()
				DailyTaskModel:GetInstance():SetGetDailyListFlag(true)		
			else
				
			end
		elseif data == FunctionConst.FunEnum.cycleTask then
			--点击领取环任务按钮，发送领取环任务请求
			TaskController:GetInstance():AcceptCycleTask()
		elseif data == FunctionConst.FunEnum.activityCopy then
			
			ActivityController:GetInstance():OpenDayActivityPanel()
		elseif data == FunctionConst.FunEnum.playerInfo then
			
		elseif data == FunctionConst.FunEnum.skill then

		elseif data == FunctionConst.FunEnum.godFightRune then

		elseif data == FunctionConst.FunEnum.social then

		elseif data == FunctionConst.FunEnum.activity then

		elseif data == FunctionConst.FunEnum.welfare then

		elseif data == FunctionConst.FunEnum.rank then

		elseif data == FunctionConst.FunEnum.deal then

		elseif data == FunctionConst.FunEnum.store then

		elseif data == FunctionConst.FunEnum.ladder then

		elseif data == FunctionConst.FunEnum.copy then
			FBController:GetInstance():OpenFBPanel()
		elseif data == FunctionConst.FunEnum.shenjing then

		elseif data == FunctionConst.FunEnum.map then

		elseif data == FunctionConst.FunEnum.taskTeam then

		elseif data == FunctionConst.FunEnum.expBar then

		elseif data == FunctionConst.FunEnum.skillBtns then

		elseif data == FunctionConst.FunEnum.chat then

		elseif data == FunctionConst.FunEnum.pkSelect then

		elseif data == FunctionConst.FunEnum.switchBtn then

		elseif data == FunctionConst.FunEnum.buffContainer then

		elseif data == FunctionConst.FunEnum.vip then

		elseif data == FunctionConst.FunEnum.backToCity then

		elseif data == FunctionConst.FunEnum.bag then

		elseif data == FunctionConst.FunEnum.notice then
			
		elseif data == FunctionConst.FunEnum.furnace then

		elseif data == FunctionConst.FunEnum.ConsignForSale then
			TradingController:GetInstance():Open(TradingConst.tabType.stall , nil , nil , nil , nil , TradingConst.stallTabType.sell , nil)
		end
	end
end

