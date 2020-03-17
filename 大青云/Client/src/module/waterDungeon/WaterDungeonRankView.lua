--[[
流水副本 排行榜
2015年6月24日15:50:21
haohu
]]

_G.UIWaterDungeonRank = BaseUI:new("UIWaterDungeonRank")

function UIWaterDungeonRank:Create()
	self:AddSWF( "dungeonRankPanel.swf", true, nil )
end

function UIWaterDungeonRank:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:OnBtnCloseClick() end
	objSwf.list.itemClick = function(e) self:OnRankItemClick(e) end
end

function UIWaterDungeonRank:OnShow()
	self:UpdateShow()
	WaterDungeonController:QueryWaterDungeonRank()
end

function UIWaterDungeonRank:UpdateShow()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.list
	list.dataProvider:cleanUp()
	local rankList = WaterDungeonModel:GetRankList()
	for rank, rankVO in ipairs(rankList) do
		local vo = {}
		local roleId = rankVO.roleId
		if roleId and roleId ~= "0_0" then
			vo.id      = roleId
			vo.rank    = rank
			vo.name    = rankVO.name
			vo.timeStr = string.format( StrConfig['waterDungeon201'], rankVO.wave )
			list.dataProvider:push( UIData.encode(vo) )
		end
	end
	list:invalidateData()
end

function UIWaterDungeonRank:OnBtnCloseClick()
	self:Hide()
end

function UIWaterDungeonRank:OnRankItemClick(e)
	-- todo
end

---------------------------------消息处理------------------------------------

--监听消息列表
function UIWaterDungeonRank:ListNotificationInterests()
	return { NotifyConsts.WaterDungeonRank }
end

--处理消息
function UIWaterDungeonRank:HandleNotification(name, body)
	if name == NotifyConsts.WaterDungeonRank then
		self:UpdateShow()
	end
end
