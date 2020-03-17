--[[
推荐好友面板
lizhuangzhuang
2014年10月17日22:54:16
]]

_G.UIFriendRecommend = BaseUI:new("UIFriendRecommend");

--已添加列表
UIFriendRecommend.hasAddList = {};

function UIFriendRecommend:Create()
	self:AddSWF("friendRecommend.swf",true,"center");
end

function UIFriendRecommend:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnAddAll.click = function() self:OnBtnAddAllClick(); end
	objSwf.btnNext.click = function() self:OnBtnNextClick(); end
	objSwf.list.itemAdd = function(e) self:OnListItemAdd(e); end
end

function UIFriendRecommend:OnShow()
	self:ShowList();
end

function UIFriendRecommend:ShowList()
	local objSwf = self:GetSWF("UIFriendRecommend");
	if not objSwf then return; end
	self.hasAddList = {};
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(FriendModel.recommendList) do
		if vo.iconID and vo.iconID >=1 and vo.iconID <= 4 then
			local listVO = {};
			listVO.roleId = vo.roleID;
			listVO.name = vo.roleName;
			listVO.lvl = string.format(StrConfig["friend101"],vo.level);
			listVO.vipLvl = vo.vipLevel;
			listVO.iconUrl = ResUtil:GetHeadIcon(vo.iconID);
			objSwf.list.dataProvider:push(UIData.encode(listVO));
		end
	end
	objSwf.list:invalidateData();
end

--添加一个
function UIFriendRecommend:OnListItemAdd(e)
	local roleId = e.item.roleId;
	FriendController:AddFriend(roleId);
	self.hasAddList[roleId] = 1;
	e.renderer.btnAdd.disabled = true;
end

--全部添加
function UIFriendRecommend:OnBtnAddAllClick()
	local list = {};
	for i,vo in ipairs(FriendModel.recommendList) do
		if not self.hasAddList[vo.roleID] then
			table.push(list,vo.roleID);
		end
	end
	FriendController:AddFriendList(list);
	self:Hide();
end

--换一批
function UIFriendRecommend:OnBtnNextClick()
	FriendController:ReqRecommendFriend();
end

function UIFriendRecommend:OnBtnCloseClick()
	self:Hide();
end