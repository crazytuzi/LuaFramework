--[[
	author: houxudong
	date:   2016/12/12 16:02:26
	weather: 6℃,257重度污染
	func:   wan平台下通过指定渠道进入游戏领取特殊奖励
--]]

_G.wanChannelRewardView = BaseUI:new('wanChannelRewardView')
local desTitle = {"首日通过360安全卫士登录","第2天通过360安全卫士登录","付费用户3天通过360安全卫士登录",""}
wanChannelRewardView.columnCount = 4;      --显示4条奖励
wanChannelRewardView.rewardListData = {};  --奖励数据

function wanChannelRewardView:Create()
	self:AddSWF("operactivites360safe.swf",true,"center")
end

function wanChannelRewardView:OnLoaded(objSwf)
	objSwf.closebtn.click   = function() self:Hide()end;
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,self.columnCount do 
		local item = objSwf["rewarditem"..i]
		RewardManager:RegisterListTips( item.itemlist )
		item.getReward_btn.click = function() self:OnGetRewardClick(item.getReward_btn)end
	end
	objSwf.pageOne.label = "360卫士圣诞献礼"
end

function wanChannelRewardView:OnShow( )
	self:UpdateRewardData()
end

-- 刷新数据
function wanChannelRewardView:UpdateRewardData( )
	local objSwf = self.objSwf
	if not objSwf then return end
	self.rewardListData = Weishi360Model:GetWanChannelRewardData( )
	objSwf.scrollbar:setScrollProperties(self.columnCount,0,#self.rewardListData - self.columnCount)
	objSwf.scrollbar.trackScrollPageSize = self.columnCount
	objSwf.scrollbar.position = 0
	self:ShowList(1)
end

wanChannelRewardView.lastSendTime = 0;
function wanChannelRewardView:OnGetRewardClick(target)
	local cfg = t_weishilogin[target.id]
	if not cfg then
		Debug("not find cfg in t_weishilogin......")
		return
	end
	local canInLevel = cfg.level
	local playLv = MainPlayerModel.humanDetailInfo.eaLevel
	if playLv < canInLevel then
		FloatManager:AddNormal("等级不足")
		return
	end
	--点击间隔
	if GetCurTime() - self.lastSendTime < 3000 then
		FloatManager:AddNormal("3秒后尝试")
		return
	end
	self.lastSendTime = GetCurTime();
	WeishiController:ReqWanChannelReward(target.id)
end

-- 滑动列表事件
function wanChannelRewardView:OnScrollBar( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local value = objSwf.scrollbar.position
	self:ShowList(value + 1)
end

-- 奖励数据初始化
function wanChannelRewardView:ShowList( value )
	local objSwf = self.objSwf
	if not objSwf then return end
	local index = 1
	index = value + self.columnCount - 1
	if value == 0 then
		value = 1
	end
	local  curlist = {}
	for i = value,index do 
		local cvo = {};
		local vo = self.rewardListData[i]
		if vo then
			cvo.num       = vo.num
			cvo.rewardOne = vo.rewardOne
			cvo.state     = vo.state or 0
			table.push(curlist,cvo)
		end
	end
	for i,info in ipairs(curlist) do 
		local item = objSwf["rewarditem"..i]
		-- item.txt_title.htmlText = desTitle[i]
		item.getReward_btn.id = i;
		-- item.numFight.num = info.num
		local isShowRewardBtn = true
		if info.state == 0 then      --不可领取
			isShowRewardBtn = true
		elseif info.state == 1 then  --可领取
			isShowRewardBtn = true
		elseif info.state == 2 then  --已经领取
			isShowRewardBtn = false
		end
		item.getReward_btn._visible = isShowRewardBtn
		item.icondacheng._visible = not isShowRewardBtn
		if item then 
			local rewardList = RewardManager:Parse(info.rewardOne);
			item.itemlist.dataProvider:cleanUp()
			item.itemlist.dataProvider:push(unpack(rewardList))
			item.itemlist:invalidateData()
		end
	end
end

function wanChannelRewardView:OnHide(  )
	self.rewardListData = {}
end

function wanChannelRewardView:GetPanelType( )
	return 1
end

function wanChannelRewardView:IsTween()
	return true
end

function wanChannelRewardView:IsShowSound()
	return true;
end

function wanChannelRewardView:GetWidth()
	return 1146;
end

function wanChannelRewardView:GetHeight()
	return 703;
end

function wanChannelRewardView:HandleNotification(name,body)
	if name == NotifyConsts.wanChannelUpdata then
		self:UpdateRewardData()
	end
end

function wanChannelRewardView:ListNotificationInterests()
	return {NotifyConsts.wanChannelUpdata};
end