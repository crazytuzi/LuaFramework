--[[
	author:houxudong
	date: 2016年11月16日17:20:35
	function：剧情副本一键扫荡奖励获得界面预览
--]]

_G.UIDominateRouteQuickMopup = BaseUI:new("UIDominateRouteQuickMopup")
UIDominateRouteQuickMopup.rewardStr = nil    --奖励数据

function UIDominateRouteQuickMopup:Create()
	self:AddSWF('dominateRouteQuicklybattle.swf',true,'top')
end

function UIDominateRouteQuickMopup:OnLoaded(objSwf)
	objSwf.btnClose.click = function () self:Hide(); end
	objSwf.btnConfirm.click = function () self:OnQuicklyMopUp(); end
	objSwf.list.itemRollOver = function(e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.list.itemRollOut = function() TipsManager:Hide(); end
end

function UIDominateRouteQuickMopup:OnShow( )
	self:ShowPreReward()
end

-- 解析奖励
function UIDominateRouteQuickMopup:ShowPreReward()
	local objSwf = self.objSwf
	if not objSwf then return end
	if not self.rewardStr then return end
	local rewardItemList = RewardManager:Parse(self.rewardStr)
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push( unpack(rewardItemList) );
	objSwf.list:invalidateData();
end

function UIDominateRouteQuickMopup:OnQuicklyMopUp( )
	DominateRouteController:SendDominateQuicklySaodang( )
	self:Hide()
end

-- 外部调用接口
function UIDominateRouteQuickMopup:Open(str)
	self.rewardStr = str
	if self:IsShow() then
		self:OnShow()
	else
		self:Show()
	end
end

function UIDominateRouteQuickMopup:OnHide()
	self.rewardStr = nil
end


