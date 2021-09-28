DailyTaskContent = BaseClass(LuaUI)
function DailyTaskContent:__init(...)
	self.URL = "ui://1m5molo6kftjf";
	self:__property(...)
	self:Config()
end

function DailyTaskContent:SetProperty(...)
	
end

function DailyTaskContent:Config()
	self.model = DailyTaskModel:GetInstance()
	self.taskItemUIList = {}
	self.buttonRefersh.onClick:Add(self.OnRefershBtnClick, self)
end

function DailyTaskContent:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("DailyTaskUI","DailyTaskContent")
	self.bg = self.ui:GetChild("bg")
	self.labelRefershTime = self.ui:GetChild("labelRefershTime")
	self.labelCycleNum = self.ui:GetChild("labelCycleNum")
	self.buttonRefersh = self.ui:GetChild("buttonRefersh")
	self.loaderConsume = self.ui:GetChild("loaderConsume")

end

function DailyTaskContent.Create(ui, ...)
	return DailyTaskContent.New(ui, "#", {...})
end

function DailyTaskContent:__delete()
	for index = 1, #self.taskItemUIList do
		self.taskItemUIList[index]:Destroy()
	end
	self.taskItemUIList = {}
end

function DailyTaskContent:SetUI()
	local strFormatCycleNum = StringFormat("剩余环数:{0}/{1}", self.model:GetMaxCnt() - self.model:GetHasGetNum() , self.model:GetMaxCnt())
	local remainingRefershCnt = self.model:GetHasRefershNum()
	local strFormatRefershTime = StringFormat("免费刷新({0})", remainingRefershCnt)
	local taskIdList = self.model:GetTaskIdList()
	self.labelCycleNum.text = strFormatCycleNum
	

	if remainingRefershCnt <= 0 then
		self.labelRefershTime.text = StringFormat("每次[Color=#C60202]{0}[/Color]" , DailyTaskModel:GetInstance():GetRefershByDiamondCnt())
		self.loaderConsume.url = "Icon/Goods/diamond"
	else
		self.labelRefershTime.text = strFormatRefershTime
		self.loaderConsume.url = ""
	end

	for index = 1, #taskIdList do
		if index <= DailyTaskConst.MaxTaskItemNum then
			local oldTaskItemObj = self:GetTaskItemObjByIndex(index)
			local curTaskItemObj = {}
			if not TableIsEmpty(oldTaskItemObj) then
				curTaskItemObj = oldTaskItemObj
			else
				curTaskItemObj = DailyTaskItem.New()
				curTaskItemObj:SetXY(8 + 266 * (index -1), 68)
				self:AddChild(curTaskItemObj.ui)
			end

			if not TableIsEmpty(curTaskItemObj) then
				curTaskItemObj:SetData(taskIdList[index])
				curTaskItemObj:SetUI()
			end

			table.insert(self.taskItemUIList, curTaskItemObj)
		end
	end
end

function DailyTaskContent:GetTaskItemObjByIndex(index)
	if index then
		return self.taskItemUIList[index] or {}
	end
end

function DailyTaskContent:OnRefershBtnClick()
	local remainingRefershCnt = self.model:GetHasRefershNum()

	if remainingRefershCnt <= 0 then
		local function okFun()
			local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
			if mainPlayerVo and mainPlayerVo.diamond and mainPlayerVo.diamond >= DailyTaskModel:GetRefershByDiamondCnt() then
				DailyTaskController:GetInstance():RefrshDailyTask(DailyTaskConst.RefershType.Diamond)
			else
				UIMgr.Win_Confirm("温馨提示" , "元宝不足，是否前往充值" , "确认" , "取消" , 
					function() 
						MallController:GetInstance():OpenMallPanel(nil , 2 , nil , function() end)
					end , 
				function() 

				end)
			end
		end

		local function cancelFun()

		end

		UIMgr.Win_Confirm("提示" , "是否刷新？" , "确认" , "取消" , function()
			--等后端改动协议C_RefrshDailyTask
			okFun()
		end , function() 
			cancelFun()
		end)
	else
		DailyTaskController:GetInstance():RefrshDailyTask(DailyTaskConst.RefershType.Free)
	end
end



