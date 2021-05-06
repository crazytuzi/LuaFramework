local CAttrSliderBox = class("CAttrSliderBox", CBox)

function CAttrSliderBox.ctor(self, obj, cb)
	CBox.ctor(self, obj)

	self.m_CallBack = cb
	self.m_SliderTimer = nil

	self.m_PointSlider = self:NewUI(1, CSlider)
	self.m_BaseSlider = self:NewUI(2, CSlider)
	self.m_ReduceBtn = self:NewUI(3, CButton)
	self.m_AddBtn = self:NewUI(4, CButton)
	self.m_AddPointLabel = self:NewUI(5, CLabel)
	self.m_PointLabel = self:NewUI(6, CLabel)
	self.m_NameLabel = self:NewUI(7, CLabel)
	self.m_WashBtn = self:NewUI(8, CButton)
	self.m_WashSlider = self:NewUI(9, CSlider)
	self.m_Thumb = self:NewUI(10, CSprite)

	self.m_Thumb:AddUIEvent("drag", callback(self, "OnDrag"))
	self.m_Thumb:AddUIEvent("dragend", callback(self, "OnDragEnd"))
	self.m_ReduceBtn:AddUIEvent("repeatpress", callback(self, "BtnCallBack", "Reduce"))
	self.m_AddBtn:AddUIEvent("repeatpress", callback(self, "BtnCallBack", "Add"))
	self.m_WashBtn:AddUIEvent("click", callback(self, "WashPoint"))

	self.m_Key = nil
	self.m_NowPoint = nil
	self.m_Index = 0
	self.m_Max = 0  		--滑动条的上限
	self.m_AddPointNum = 0
	self.m_OffsetNum = 0
	self.m_RemainPoint = 0
	self.m_PlayerInfoName = {"体质", "魔力", "力量", "耐力", "敏捷"}
	self.m_Keylist = {"physique", "magic", "strength", "endurance", "agility"}
end

function CAttrSliderBox.SetInfo(self, datalist)	
	self.m_Index = datalist[1]			
	self.m_BlueSlider = datalist[2]	or 0	--蓝条		 						  	
	self.m_RemainPoint = datalist[3] or 0	--潜力点
	local iBasepoint = datalist[4] or 0		--橙条
	local iAllWashallpoint = datalist[5] or 0	--可洗点之和
	self.m_PlanId = datalist[6]
	self.m_NowPoint = tonumber(iBasepoint + self.m_BlueSlider)			 ------属性显示点数

	--上限为 基本点数+可洗点之和+剩余潜力
	self.m_Max = iBasepoint + iAllWashallpoint + self.m_RemainPoint 

	self.m_Key = self.m_Keylist[self.m_Index]
	self.m_NameLabel:SetText(self.m_PlayerInfoName[self.m_Index])
	self.m_PointLabel:SetText(self.m_NowPoint)

	self.m_ChangePoint = 0
	self:RefreshSliderRound(self.m_RemainPoint)

	if not self:IsSelect(false) then
		self.m_Thumb:EnableTouch(false)
	else
		self.m_Thumb:EnableTouch(true)
	end

	self.m_BaseSlider:SetValue(iBasepoint / self.m_Max)				--黄条	
	self.m_WashSlider:SetValue((iBasepoint + self.m_BlueSlider) / self.m_Max)
	self.m_PointSlider:SetValue(self.m_NowPoint / self.m_Max)		--绿条
	self.m_AddPointLabel:SetActive(false)
end

--这个需要根据其他属性的进度条设置即时刷新
function CAttrSliderBox.RefreshSliderRound(self, remainpoint)
	local iPoint = tonumber(self.m_PointLabel:GetText())
	self.m_RemainPoint = remainpoint
	self.m_PointSlider:SetMinValue(self.m_NowPoint / self.m_Max)
	self.m_PointSlider:SetMaxValue((iPoint + remainpoint) / self.m_Max)
end


function CAttrSliderBox.OnDrag(self, obj, movedata)
	if not self:IsSelect(true) then
		return
	end

	if movedata.x > 0 then			--增加
		if self.m_PointSlider:GetValue() >= 1 or self.m_RemainPoint <= 0 then
			return
		end
	elseif movedata.x < 0 then		--减少
		if self.m_PointSlider:GetValue() <= self.m_WashSlider:GetValue() then
			self.m_AddPointLabel:SetActive(false)
			return
		end
	end

	if not self.m_SliderTimer then
		local function update()
			if Utils.IsNil(self) then
				return false
			end
			self:CalculateData()
			return true
		end
		self.m_SliderTimer = Utils.AddTimer(update, 0.1, 0.1)
	end

	self:CalculateData()
end

--是否为选择方案
function CAttrSliderBox.IsSelect(self, bool)
	if self.m_PlanId ~= g_AttrCtrl.g_SelectedPlan then
		if bool then
			g_NotifyCtrl:FloatMsg("======方案未启用不可操作======")
		end
		return false
	else
		return true
	end
end

function CAttrSliderBox.OnDragEnd(self)
	if self.m_SliderTimer then
		Utils.DelTimer(self.m_SliderTimer)
		self.m_SliderTimer = nil
	end

	if self.m_RemainPoint == 0 then
		return
	end
	self:CalculateData()
end

function CAttrSliderBox.CalculateData(self)
	self.m_AddPointNum = self:MathRound((self.m_PointSlider:GetValue() - self.m_WashSlider:GetValue()) * self.m_Max)
	self.m_ChangePoint = self.m_AddPointNum - self.m_OffsetNum
	self.m_OffsetNum = self.m_AddPointNum
	self.m_AddPointLabel:SetActive(self.m_AddPointNum >= 1)
	self.m_AddPointLabel:SetText("+"..self.m_AddPointNum)
	self.m_PointLabel:SetText(self.m_NowPoint + self.m_AddPointNum)
	self.m_RemainPoint = self.m_RemainPoint - self.m_ChangePoint
	self:EventCallBack()
end

function CAttrSliderBox.EventCallBack(self)
	if not self:IsSelect(true) then
		return
	end
	local datalist = {
		idx = self.m_Index,
		changepoint = self.m_ChangePoint,
		key = self.m_Key,
		addpoint = self.m_AddPointNum,
	}
	if self.m_CallBack then
		self.m_CallBack(datalist)
	end
end

function CAttrSliderBox.BtnCallBack(self, sType, oBtn, bPrees)
	if not self:IsSelect(true) then
		return
	end

	if bPrees then
		self:RefreshSlide(sType)
	end
end

function CAttrSliderBox.RefreshSlide(self, sType)
	if sType == "Add" then	
		if self.m_RemainPoint <= 0 then
			return
		end			
		self.m_RemainPoint = self.m_RemainPoint - 1
		self.m_AddPointNum = self.m_AddPointNum + 1

		if self.m_AddPointNum > 0 and self.m_AddPointLabel:GetActive() == false then
			self.m_AddPointLabel:SetActive(true)			
		end			
		self.m_ChangePoint = 1
		
	elseif sType == "Reduce" then			
		if self.m_AddPointNum <= 0 then
			return
		end		
		self.m_AddPointNum = self.m_AddPointNum - 1
		self.m_RemainPoint = self.m_RemainPoint + 1 	
		self.m_ChangePoint = -1

		if self.m_AddPointNum == 0 then
			self.m_AddPointLabel:SetActive(false)	
		end		
	end

	self.m_OffsetNum = self.m_AddPointNum
	self:SetSliderInfo()
end

function CAttrSliderBox.RefreshPoint(self, iPoint)
	self.m_PointLabel:SetText(iPoint)
	self.m_NowPoint = iPoint
end

function CAttrSliderBox.SetSliderInfo(self)
	self.m_PointLabel:SetText(tostring(self.m_NowPoint + self.m_AddPointNum))
	self.m_AddPointLabel:SetText("+"..self.m_AddPointNum)
	self.m_PointSlider:SetValue((self.m_NowPoint + self.m_AddPointNum) / self.m_Max)  --绿条

	self:EventCallBack()
end

function CAttrSliderBox.WashPoint(self)
	if not self:IsSelect(true) then
		return
	end

	local iItemNum = g_ItemCtrl:GetBagItemAmountBySid(10004)
	if iItemNum <= 0 then
		g_NotifyCtrl:FloatMsg("人物洗点丹不足")
		return
	end
	netplayer.C2GSWashPoint(self.m_Keylist[self.m_Index])
end

--切换方案时清空数据缓存
function CAttrSliderBox.DelateData(self)
	self.m_Key = nil
	self.m_NowPoint = 0
	self.m_Index = 0
	self.m_Max = 0  		
	self.m_AddPointNum = 0
	self.m_RemainPoint = 0
	self.m_ChangePoint = 0
	self.m_BlueSlider = 0
	self.m_NowPoint = 0
	self.m_OffsetNum = 0 
end

--数字四舍五入
function CAttrSliderBox.MathRound(self, data)	
	local num,modf = math.modf(data)
	num = (modf >= 0.5 and math.ceil(data)) or math.floor(data)
	return num 
end

return CAttrSliderBox