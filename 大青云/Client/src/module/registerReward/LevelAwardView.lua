--[[
登陆奖励面板：等级奖励
zhangshuhui
2014年15月15日14:15:00
]]

_G.UILevelAward = BaseUI:new("UILevelAward");

UILevelAward.awardlist = {};
UILevelAward.awardlistgroup = {};
UILevelAward.awardlistcount = 5;--UI一页奖励总数
UILevelAward.curpageIndex = 0;--当前显示页数
UILevelAward.pagecount = 0;--总页数

function UILevelAward:Create()
	self:AddSWF("levelawardPanel.swf",true,"center");
end

function UILevelAward:OnLoaded(objSwf)
	--奖励列表
	self.awardlistgroup = {}
	for i=1,self.awardlistcount do
		self.awardlistgroup[i] = objSwf["awardlist"..i];
		
		self.awardlistgroup[i].btnget.click = function() self:OnBtnGetAwardClick(i) end
		
		objSwf["awardlist"..i].numlevel.loadComplete = function()
									-- objSwf["awardlist"..i].numlevel._x = 48 - objSwf["awardlist"..i].numlevel.width;
								end
								
		--特效播放完
		objSwf["awardlist"..i].effectyilingqu.complete = function() self:ShowImgState(i); end
		
		--TIP
		RewardManager:RegisterListTips(self.awardlistgroup[i].awardList);
	end
	
	--滚轮事件
	objSwf.scrollBar.scroll = function() self:OnScrollBarscrollClick(); end;
	
	objSwf.listscrollBar.scroll = function() self:OnListScrollBarscrollClick(); end;
	objSwf.listscrollBar._visible = false;
end

function UILevelAward:OnDelete()
	for k,_ in pairs(self.awardlistgroup) do
		self.awardlistgroup[k] = nil;
	end
end

function UILevelAward:OnShow()
	self:InitData();
	self:ShowList();
end

function UILevelAward:OnScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.scrollBar.position then
		return;
	end
	if not objSwf.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.scrollBar.position < 0 then
		objSwf.scrollBar.position = 0;
		objSwf.listscrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.scrollBar.position > self.pagecount then
		objSwf.scrollBar.position = self.pagecount;
		objSwf.listscrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.scrollBar.position then
		return;
	end
	
	objSwf.listscrollBar.position = objSwf.scrollBar.position;

	self.curpageIndex = objSwf.scrollBar.position;
	
	self:ShowList();
end

function UILevelAward:OnListScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.scrollBar.position then
		return;
	end
	if not objSwf.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.listscrollBar.position < 0 then
		objSwf.scrollBar.position = 0;
		objSwf.listscrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.listscrollBar.position > self.pagecount then
		objSwf.scrollBar.position = self.pagecount;
		objSwf.listscrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.listscrollBar.position then
		return;
	end
	objSwf.scrollBar.position = objSwf.listscrollBar.position;

	self.curpageIndex = objSwf.listscrollBar.position;
	
	self:ShowList();
end

function UILevelAward:OnBtnGetAwardClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local lvlIndex = self.curpageIndex + i;
	local vo = self.awardlist[lvlIndex];
	if not vo then return; end
	
	--已领奖
	if RegisterAwardUtil:GetIsRewarded(vo.lvl) then
		return;
	end
	
	RegisterAwardController:ReqGetLvlAward(vo.lvl);
end

---------------------------------消息处理------------------------------------
function UILevelAward:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.LevelAwardChange then
		self:UpdateLevelState(body);
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			self:InitData();
			self:ShowList();
		end
	end
end

function UILevelAward:ListNotificationInterests()
	return {NotifyConsts.LevelAwardChange,NotifyConsts.PlayerAttrChange};
end

function UILevelAward:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.awardlist = {};
	
	local PageCount = 0;
	for i,vo in pairs(t_lvreward) do
		if vo then
			table.insert(self.awardlist ,vo);
			PageCount = PageCount + 1;
		end
	end
	
	table.sort(self.awardlist,function(A,B)
		if A.lvl < B.lvl then
			return true;
		else
			return false;
		end
	end);
	
	self.curpageIndex = 0;
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	--是否有未领取的最低等级奖励，显示在最后一行
	for i,vo in pairs(self.awardlist) do
		if playerinfo.eaLevel >= vo.lvl then
			if RegisterAwardUtil:GetIsRewarded(vo.lvl) == false then
				if i > self.awardlistcount then
					self.curpageIndex = i - 1;
				end
				break;
			end
		end
	end
	
	self.pagecount = PageCount - self.awardlistcount;
	if self.pagecount < 0 then
		self.pagecount = 0;
	end
	objSwf.scrollBar.position = self.curpageIndex;
	objSwf.scrollBar.maxPosition = self.pagecount;
	objSwf.scrollBar.minPosition = 0;
	objSwf.scrollBar.pageSize = self.awardlistcount;
	
	--listscroll
	objSwf.listscrollBar.position = self.curpageIndex;
	objSwf.listscrollBar.maxPosition = self.pagecount;
	objSwf.listscrollBar.minPosition = 0;
	objSwf.listscrollBar.pageSize = self.awardlistcount;
end

--显示列表
function UILevelAward:ShowList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local playerinfo = MainPlayerModel.humanDetailInfo;
	
	for i=1,self.awardlistcount do
		self.awardlistgroup[i].imggetted._visible = false;
		self.awardlistgroup[i].btnnotlevel.visible = false;
		self.awardlistgroup[i].btnget.visible = false;
		objSwf["awardlist"..i].effectyilingqu.visible = false;
		objSwf["awardlist"..i].effectyilingqu:stopEffect();
		-- objSwf["awardlist"..i].effectsaoguang.visible = false;
		-- objSwf["awardlist"..i].effectsaoguang:stopEffect();
		self.awardlistgroup[i].btnget:clearEffect();
		
		local PageIndex = self.curpageIndex + i;
		local vo = self.awardlist[PageIndex];
		
		local awardList = {};
		--是否领奖
		if RegisterAwardUtil:GetIsRewarded(vo.lvl) then
			self.awardlistgroup[i].imggetted._visible = true;
			
			--已领取变黑
			awardList = RewardManager:ParseBlack(vo.itemreward);
		else
			--未领取
			if playerinfo.eaLevel >= vo.lvl then
				self.awardlistgroup[i].btnget.visible = true;
				-- objSwf["awardlist"..i].effectsaoguang.visible = true;
				-- objSwf["awardlist"..i].effectsaoguang:playEffect(0);
				self.awardlistgroup[i].btnget:showEffect(ResUtil:GetButtonEffect10());
			else
				self.awardlistgroup[i].btnnotlevel.visible = true;
				self.awardlistgroup[i].btnnotlevel.disabled = true;
			end
			
			awardList = RewardManager:Parse(vo.itemreward);
		end
			
		self.awardlistgroup[i].numlevel.num = vo.lvl;
		
		self.awardlistgroup[i].awardList.dataProvider:cleanUp();
		self.awardlistgroup[i].awardList.dataProvider:push(unpack(awardList));
		self.awardlistgroup[i].awardList:invalidateData();
	end
end

--更新状态
function UILevelAward:UpdateLevelState(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.awardlistcount do
		local PageIndex = self.curpageIndex + i;
		local vo = self.awardlist[PageIndex];
		
		if vo.lvl == body.lvl then
			self.awardlistgroup[i].btnnotlevel.visible = false;
			self.awardlistgroup[i].btnget.visible = false;
			self.awardlistgroup[i].btnget:clearEffect();
			-- objSwf["awardlist"..i].effectsaoguang.visible = false;
			-- objSwf["awardlist"..i].effectsaoguang:stopEffect();
			objSwf["awardlist"..i].effectyilingqu.visible = true;
			objSwf["awardlist"..i].effectyilingqu:playEffect(1);
			
			--已领取变黑
			local awardList = RewardManager:ParseBlack(vo.itemreward);
			self.awardlistgroup[i].awardList.dataProvider:cleanUp();
			self.awardlistgroup[i].awardList.dataProvider:push(unpack(awardList));
			self.awardlistgroup[i].awardList:invalidateData();
				
			--奖励
			local rewardList = RewardManager:ParseToVO(vo.itemreward);
			local startPos = UIManager:PosLtoG(self.awardlistgroup[i],70,17);
			RewardManager:FlyIcon(rewardList,startPos,5,true,60);
			break;
		end
	end
end

--刷新已完成图标
function UILevelAward:ShowImgState(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self.awardlistgroup[i].imggetted._visible = true;
end