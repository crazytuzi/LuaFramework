--[[
副本：神话难度通过排行榜
2015年3月11日11:24:40
haohu
]]

_G.UIDungeonRank = BaseUI:new("UIDungeonRank");

function UIDungeonRank:Create()
	self:AddSWF( "dungeonRankPanel.swf", true, nil );
end

function UIDungeonRank:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.list.itemClick = function(e) self:OnRankItemClick(e); end
end

function UIDungeonRank:OnShow()
	self:UpdateShow();
end

function UIDungeonRank:UpdateShow()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	local dungeonId = UIDungeon:GetCurrentShowDungeon();
	local rankInfo = DungeonModel:GetRank(dungeonId);
	local rankList = rankInfo and rankInfo.rankList or {};
	for rank, rankVO in ipairs(rankList) do
		local vo = {};
		local roleId = rankVO.id;
		if roleId and roleId ~= "0_0" then
			vo.id   = roleId;
			vo.rank = rank;
			vo.name = rankVO.name;
			vo.timeStr = string.format( StrConfig["dungeon801"], DungeonUtils:ParseTime( rankVO.time ) );
			list.dataProvider:push( UIData.encode(vo) );
		end
	end
	list:invalidateData();
end

function UIDungeonRank:OnBtnCloseClick()
	self:Hide();
end

function UIDungeonRank:OnRankItemClick(e)
	local data = e.item;
	if not data then return end;
	local rank = data.rank;
	local dungeonId = UIDungeon:GetCurrentShowDungeon();
	UIDungeonRankOper:Open(dungeonId, rank);
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIDungeonRank:ListNotificationInterests()
	return { NotifyConsts.DungeonRank };
end

--处理消息
function UIDungeonRank:HandleNotification(name, body)
	if name == NotifyConsts.DungeonRank then
		self:UpdateShow();
	end
end