--[[
	func: 封神乱斗排行榜奖励
	author:houxudong
	date:2016年11月23日 15:44:23
--]]

_G.ActivityBeicangjieRankView = BaseUI:new("ActivityBeicangjieRankView")

ActivityBeicangjieRankView.list = {}
function ActivityBeicangjieRankView:Create( )
	self:AddSWF("beicangjierank.swf", true, "center");
end

function ActivityBeicangjieRankView:OnLoaded(objSwf )
	objSwf.Closebtn.click = function() self:CloseClick() end
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,6 do
		local item = objSwf["item"..i];
		RewardManager:RegisterListTips(item.list);
	end
end

function ActivityBeicangjieRankView:OnShow( )
	local objSwf = self.objSwf
	if not objSwf then return end
	self.list = ActivityUtils:BeicangjieRankRewardData( )
	objSwf.scrollbar:setScrollProperties(6,0,#self.list-6);
	objSwf.scrollbar.trackScrollPageSize = 6;
	objSwf.scrollbar.position = 0;
	self:ShowList(1);
end

function ActivityBeicangjieRankView:CloseClick()
	self:Hide()
end

-- 滑动列表事件
function ActivityBeicangjieRankView:OnScrollBar( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local value = objSwf.scrollbar.position
	self:ShowList(value + 1)
end

-- 初始化list数据
function ActivityBeicangjieRankView:ShowList(value)
	local objSwf = self.objSwf
	if not objSwf then return end
	local index = 1
	index = value + 5
	local  curlist = {}
	if value == 0 then
		value = 1
	end
	for i = value,index do 
		local cvo = {};
		local vo = self.list[i]
		if not vo then return end;
		cvo.miniRank = split(self.list[i].rank_range,',')[1]
		cvo.maxRank = split(self.list[i].rank_range,',')[2]
		cvo.rewardOne = self.list[i].rewardOne
		table.push(curlist,cvo)
	end

	for i,info in ipairs(curlist) do 
		local item = objSwf["item"..i];
		item.textrank.text = string.format(StrConfig["beicangjie800"],info.miniRank,info.maxRank);
		if item then 
			local rewardList = RewardManager:Parse(info.rewardOne);
			item.list.dataProvider:cleanUp()
			item.list.dataProvider:push(unpack(rewardList));
			item.list:invalidateData();
		end
	end
end

function ActivityBeicangjieRankView:OnHide( )
	self.list = {}
end

