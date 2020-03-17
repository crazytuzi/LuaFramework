--[[
	author:  houxudong
	date:    2016/11/17 16:20:25
	funtion: 组队升级进入时提醒玩家使用1.5倍经验丹
--]]

_G.UIExpBuffUseView = BaseUI:new('UIExpBuffUseView');
UIExpBuffUseView.isUseAll = false     --是否全部使用改倍经验丹

function UIExpBuffUseView:Create()
	self:AddSWF("openUseExpPanel.swf",true,"bottomFloat")
end

function UIExpBuffUseView:OnLoaded(objSwf,name)
	objSwf.btnConfirm.click = function () self:OnUseExpPillClick(); end
	objSwf.btnClose.click = function () self:OnClose() end
	objSwf.btnConfirm.label = StrConfig['timeDungeon3002']
	objSwf.titleInfo.htmlText = StrConfig['timeDungeon3000']
	objSwf.tfContent.htmlText = StrConfig['timeDungeon3001']
end

function UIExpBuffUseView:OnShow( )
	self:StartUpdateTime()
end

-- 使用1.5倍经验丹
function UIExpBuffUseView:OnUseExpPillClick( )
	local isHaveExpBuff = DungeonUtils:TestIsHaveExpBuff( )
	if isHaveExpBuff == true then
		FloatManager:AddNormal(StrConfig['timeDungeon3003'])
		return
	end
	local itemId = BuffConsts.Type_Exp_One_Id
	local usePre = BagModel:GetItemNumInBag(itemId)
	local useLeftCount = DungeonUtils:UseItemId( itemId,false)
	if useLeftCount == 0 then
		FloatManager:AddNormal(StrConfig['timeDungeon3004'])
	elseif usePre ~= useLeftcount then
		FloatManager:AddNormal(StrConfig['timeDungeon3005'])
	end
	self:Hide()
end

function UIExpBuffUseView:OnClose( )
	self:Hide()
end

function UIExpBuffUseView:IsTween()
	return false;
end

function UIExpBuffUseView:OnHide( )
	self:UnRegisterTimes()
end

-- 开始计时
-- 如果玩家10s不使用经验丹，或者不关闭界面的话，自动关掉界面(是否在主动使用1.5倍经验丹(isUseAll))
UIExpBuffUseView.timeKey = nil;
function UIExpBuffUseView:StartUpdateTime( )
	local dealyCloseTime = 10
	local func = function ( )
		self:ShowLeftTimes(dealyCloseTime)
		dealyCloseTime = dealyCloseTime -1
		if dealyCloseTime <= 0 then 
			TimerManager:UnRegisterTimer(self.timeKey)
			self.timeKey = nil
			self:ShowLeftTimes(0)
			if isUseAll then
				self:OnUseExpPillClick()
			end
			self:Hide()
		end
	end
	self.timeKey = TimerManager:RegisterTimer(func,1000,0)
	func()
end

function UIExpBuffUseView:ShowLeftTimes(num )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.timeText.htmlText = string.format('<font color="#ff0000"><i>%s </i></font>后自动关闭',num) 
end

function UIExpBuffUseView:UnRegisterTimes( )
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey)
		self.timeKey = nil
	end
end