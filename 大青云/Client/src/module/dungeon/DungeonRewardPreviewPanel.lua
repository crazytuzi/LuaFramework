--[[
	author: houxudong
	date:   2016年12月9日 21:42:26
	weater: 晴, 3℃ 
	func:   预览单人副本等级奖励
--]]

_G.UIDungeonRewardPreView = BaseUI:new("UIDungeonRewardPreView")
UIDungeonRewardPreView.listLineCont = 4   --默认显示的行数
UIDungeonRewardPreView.list = {}
UIDungeonRewardPreView.dungeonIdNum = 1   --默认副本功能难度是1
UIDungeonRewardPreView.btnObjSwf = nil
function UIDungeonRewardPreView:Create( )
	self:AddSWF("dungeonRewardPreView.swf", true, "center");
end

function UIDungeonRewardPreView:OnLoaded(objSwf )
	objSwf.panel.Closebtn.click = function() self:CloseClick() end
	objSwf.panel.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,self.listLineCont do
		local item = objSwf.panel["item"..i];
		RewardManager:RegisterListTips(item.list);
	end
end

function UIDungeonRewardPreView:OnShow( )
	local objSwf = self.objSwf
	if not objSwf then return end
	self.list = DungeonUtils:GetPreViewReward( self.dungeonIdNum )
	objSwf.panel.scrollbar:setScrollProperties(self.listLineCont,0,#self.list-self.listLineCont);
	objSwf.panel.scrollbar.trackScrollPageSize = self.listLineCont;
	objSwf.panel.scrollbar.position = 0;
	self:ShowList(1);
end

function UIDungeonRewardPreView:CloseClick()
	self:Hide()
end

function UIDungeonRewardPreView:OnOpen( dungeonId,btn )
	self.dungeonIdNum = dungeonId
	self.btnObjSwf = btn
	if self:IsShow() then
		self:OnShow()
	else
		self:Show()
	end
end

-- 滑动列表事件
function UIDungeonRewardPreView:OnScrollBar( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local value = objSwf.panel.scrollbar.position
	self:ShowList(value + 1)
end

-- 初始化list数据
function UIDungeonRewardPreView:ShowList(value)
	local objSwf = self.objSwf
	if not objSwf then return end
	local index = 1
	index = value + 3
	local  curlist = {}
	if value == 0 then
		value = 1
	end
	for i = value,index do 
		local cvo = {};
		local vo = self.list[i]
		if vo then
			cvo.dungeonLv = self.list[i].dungeonLv
			cvo.roleMinLv = self.list[i].roleMinLv
			cvo.roleMaxLv = self.list[i].roleMaxLv
			cvo.rewardOne = self.list[i].rewardOne
			table.push(curlist,cvo)
		end
	end
	local groupMaxList = self:CheckMaxGroup()
	table.sort( groupMaxList, function ( A,B)
		return A.numCount > B.numCount
	end)
	local maxNumCount = groupMaxList[1].numCount or 100
	for i=1,maxNumCount do 
		local item = objSwf.panel["item"..i]
		if item then 
			item.textrank.htmlText = ''
			item.list.dataProvider:cleanUp()
			item.list:invalidateData();
		end
	end
	for i,info in ipairs(curlist) do 
		local item = objSwf.panel["item"..i];
		item.textrank.htmlText = string.format(StrConfig["dungeon245"],info.dungeonLv,info.roleMinLv,info.roleMaxLv);
		if item then 
			local rewardList = RewardManager:Parse(info.rewardOne);
			item.list.dataProvider:cleanUp()
			item.list.dataProvider:push(unpack(rewardList));
			item.list:invalidateData();
		end
	end
end

function UIDungeonRewardPreView:CheckMaxGroup( )
	if not t_dungeons then 
		Debug("not find table t_dungeons,Planning check table.......")
		return 
	end
	table.sort( t_dungeons,function ( A,B )
		return A.id < B.id
	end)
	local compareGroupId = 0
	local groupMaxList = {}
	for k,v in pairs(t_dungeons) do
		if v.id then
			if v.id ~= compareGroupId then
				compareGroupId = v.id
				local diffNum = 0
				for ko,vo in pairs(t_dungeons) do
					if math.floor(vo.id / 100)  == math.floor(v.id / 100) then
						diffNum = diffNum + 1
					end
				end
				local voo = {}
				voo.groupId  = math.floor(v.id / 100)
				voo.numCount = diffNum
				table.push(groupMaxList,voo)
			end
		end
	end
	return groupMaxList
end

function UIDungeonRewardPreView:InitPanel( )
end

-- 调整技能界面的位置
function UIDungeonRewardPreView:OnResize(dwWidth,dwHeight)
end 

function UIDungeonRewardPreView:OnHide( )
	self.list = {}
end