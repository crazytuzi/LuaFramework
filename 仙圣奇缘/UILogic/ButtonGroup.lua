--------------------------------------------------------------------------------------
-- 文件名:	ButtonGroup.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	用按钮实现CheckBox组
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

module("ButtonGroup", package.seeall)

-- 把指定的Button设为一组，自动控制其selected,touch状?
-- cblist: { 
--	 { cb=cb_obj1, f=callback1 },
--	 ...
-- }

-- 优化Button 不需要遍?
local tinsert = table.insert

function New()
	local ret = {
		cblist = {},
	--	default = 0,
	--	inited = true,
		ButtonHit = nil,
		PanelHit = nil
	}
	setmetatable(ret, {__index=ButtonGroup})
	return ret
end

function ButtonGroup:create()
	local nButtonGroup = ButtonGroup:New()
	return nButtonGroup
end

function ButtonGroup:PushBack(Button, panel, callback, focus)
	tinsert(self.cblist, {cb=Button, p = panel ,f=callback})
	
	local idx = #self.cblist
	
	if Button and Button:isExsit() then
		Button:setBright(not focus)
		Button:setTouchEnabled(not focus)
	end
	if panel then
		panel:setVisible(false)
	end
	Button:addTouchEventListener(function(pSender, eventType)
    	if eventType == ccs.TouchEventType.ended then
			local WidgetName = pSender:getName()
			if g_CheckFuncCanOpenByWidgetName(WidgetName) then
				self:Click(idx, pSender, eventType)
			else
				local nOpenLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenLevel
				local strOpenFuncName = getFunctionOpenLevelCsvByStr(WidgetName).OpenFuncName
				local nOpenVipLevel = getFunctionOpenLevelCsvByStr(WidgetName).OpenVipLevel
				if nOpenLevel <= 200 then
					if nOpenVipLevel >= 1 then
						g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
					else
						g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
					end
				else
					g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
				end
			end
        end
    end)
	if(not self.ButtonHit)then
		self.ButtonHit = Button
	end
	if(not self.PanelHit)then
		self.PanelHit = panel
	end
	self.isCheckData = true
end
--点击 
function ButtonGroup:Click(idx, pSender, eventType)  
	local bRet = nil

	if self.cblist[idx].f then 
		bRet = self.cblist[idx].f(idx, pSender, eventType)
		if g_PlayerGuide:checkCurrentGuideSequenceNode("ButtonCheck", self.cblist[idx].cb:getName()) then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end
	if self.isCheckData then
		self:CheckWithoutCallBack(idx)
		if(bRet == false)then--为了窗口WJQ_EquipWorkFromCard.lua
			if self.ButtonHit and self.ButtonHit:isExsit() then
				self.ButtonHit:setTouchEnabled(true)
			end
		end
	end
end

function ButtonGroup:Check(idx)
	if self.cblist[idx].f then self.cblist[idx].f() end
	if self.isCheckData then
		self:CheckWithoutCallBack(idx)
	end
end
function ButtonGroup:setCheckData(isCheckData)
	self.isCheckData = isCheckData
end
function ButtonGroup:getCheckData(isCheckData)
	return self.isCheckData 
end
function ButtonGroup:getButtonCurIndex()
	for i =1, #self.cblist do
		local Button = self.cblist[i].cb
		if(not Button:isTouchEnabled() )then
			return i
		end
	end
	return 1
end
function ButtonGroup:getButtonTouchEnabled(is_Enabled,nIndex)
	for i =1, #self.cblist do
		local Button = self.cblist[i].cb
		if Button and Button:isExsit() then
			Button:setTouchEnabled(is_Enabled)
		end
		
		if is_Enabled == true then
			local nIndex = nIndex or 1
			if  i == nIndex then
				ButtonGroup:Check(nIndex)
			end
		end
	end
	return 1
end


function ButtonGroup:getButtonCurPanel()
	local Panel
	for i =1, #self.cblist do
		panel = self.cblist[i].p
		if(not panel:isVisible())then
			return Panel
		end
	end
	return 1
end

function ButtonGroup:CheckWithoutCallBack(idx)
	if self.ButtonHit and self.ButtonHit:isExsit() then
		self.ButtonHit:setTouchEnabled(true)
		self.ButtonHit:setBright(true)
	end
	
	if self.PanelHit and self.PanelHit:isExsit() then
		self.PanelHit:setVisible(false)
	end

	self.ButtonHit = self.cblist[idx].cb
	if self.ButtonHit and self.ButtonHit:isExsit() then
		self.ButtonHit:setBright(false)
		self.ButtonHit:setTouchEnabled(false)
	end
	
	if(self.cblist[idx].p)then
		self.PanelHit = self.cblist[idx].p
		if self.PanelHit and self.PanelHit:isExsit() then
			self.PanelHit:setVisible(true)
		end
	end
end

function ButtonGroup:resetCheckState()
	if self.ButtonHit and self.ButtonHit:isExsit() then
		self.ButtonHit:setTouchEnabled(false)
		self.ButtonHit:setBright(false)
	end
	
	if self.PanelHit and self.PanelHit:isExsit() then
		self.PanelHit:setVisible(false)
	end
	self.PanelHit = nil
	self.ButtonHit = nil
end

return ButtonGroup