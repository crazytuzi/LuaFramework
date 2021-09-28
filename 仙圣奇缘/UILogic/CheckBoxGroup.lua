module("CheckBoxGroup", package.seeall)

-- 把指定的checkbox设为一组，自动控制其selected,touch状态
-- cblist: { 
--	 { cb=cb_obj1, f=callback1 },
--	 ...
-- }

-- 优化checkbox 不需要遍历 

local tinsert = table.insert
function New()
	local ret = {
		cblist = {},
	--	default = 0,
	--	inited = true,
		checkboxHit = nil,
	}
	setmetatable(ret, {__index=CheckBoxGroup})
	return ret
end

function CheckBoxGroup:PushBack(checkbox, callback, focus)
	tinsert(self.cblist, {cb=checkbox, f=callback})
	
	local idx = #self.cblist
	checkbox:setSelectedState(focus)
	checkbox:setTouchEnabled(not focus)
	checkbox:addEventListenerCheckBox(function(pSender, eventType)
    	if eventType == ccs.CheckBoxEventType.selected then
			self:Click(idx, pSender, eventType)
        end
    end)
	
	if(not self.checkboxHit)then
		self.checkboxHit = checkbox
	end
end
--点击 
function CheckBoxGroup:Click(idx, pSender, eventType)  
	local bRet = nil
	if self.cblist and self.cblist[idx].f then 
        pSender = pSender or self.cblist[idx].cb
		bRet = self.cblist[idx].f(idx, pSender, eventType)
		if g_PlayerGuide:checkCurrentGuideSequenceNode("CheckBoxCheck", pSender:getName()) then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
	end

	self:CheckWithoutCallBack(idx)
	if(bRet == false)then--为了窗口WJQ_EquipWorkFromCard.lua
		self.checkboxHit:setTouchEnabled(true)
	end
end

function CheckBoxGroup:Check(idx)
	if self.cblist and self.cblist[idx] and self.cblist[idx].f then self.cblist[idx].f() end
	
	self:CheckWithoutCallBack(idx)
end

function CheckBoxGroup:getCheckIndex()
	if not self.cblist then return 1 end

	for i =1, #self.cblist do
		local checkbox = self.cblist[i].cb
		if(checkbox:getSelectedState() )then
			return i
		end
	end
	
	return 1
end

function CheckBoxGroup:getButtonTouchEnabled(is_Enabled,nIndex)
	if not self.cblist then return 1 end
	
	for i =1, #self.cblist do
		local Button = self.cblist[i].cb
		Button:setTouchEnabled(is_Enabled)
		if is_Enabled == true then
			local nIndex = nIndex or 1
			if  i == nIndex then
				self:Check(nIndex)
			end
		end
	end
	return 1
end


function CheckBoxGroup:CheckWithoutCallBack(idx)
	if(self.checkboxHit)then
		self.checkboxHit:setSelectedState(false)
		self.checkboxHit:setTouchEnabled(true)
	end
	
	self.checkboxHit = self.cblist[idx].cb
	self.checkboxHit:setSelectedState(true)
	self.checkboxHit:setTouchEnabled(false)
end

function CheckBoxGroup:CheckWithoutEvent(idx)
	if(self.checkboxHit)then
		self.checkboxHit:setSelectedState(false)
		self.checkboxHit:setTouchEnabled(false)
	end
	
	self.checkboxHit = self.cblist[idx].cb
	self.checkboxHit:setSelectedState(true)
	self.checkboxHit:setTouchEnabled(false)
end

function CheckBoxGroup:resetCheckState()
	if(self.checkboxHit)then
		self.checkboxHit:setSelectedState(false)
		self.checkboxHit:setTouchEnabled(true)
	end
	
	self.checkboxHit = nil
end
--[[
	设置复选框是否可以点击
]]
function CheckBoxGroup:setCheckBoxGroupEnadled(is_Enabled)
	for key,valeu in pairs(self.cblist) do
		local checkBoxGroup = valeu.cb
		checkBoxGroup:setTouchEnabled(is_Enabled)
	end
end

return CheckBoxGroup