--[[
任务面板:主线任务
郝户
2014年9月21日19:17:20
]]

_G.UIQuestTrunk = BaseUI:new("UIQuestTrunk");

--当前查看的任务Id
UIQuestTrunk.currShowQuestId = 0;
--当前任务Id
UIQuestTrunk.currQuestId = 0;
--当前查看的章节
UIQuestTrunk.currShowChapter = 0;
--当前进行中的章节
UIQuestTrunk.curChapterIndex = 0;
--章节奖励textField数组
UIQuestTrunk.chapterRewardTxts = {};

function UIQuestTrunk:Create()
	self:AddSWF("taskTrunkPanel.swf", true, "center");
end

function UIQuestTrunk:OnLoaded(objSwf,name)
	--按钮增加动作
	objSwf.btnPre.click				= function() self:OnBtnPreClick();        end
	objSwf.btnNext.click			= function() self:OnBtnNextClick();       end
	objSwf.btnNext2.click			= function() self:OnBtnNextClick();       end
	objSwf.chapterList.itemClick	= function(e) self:OnChapterItemClick(e); end
	objSwf.btnReturn.click			= function() self:OnBtnReturnClick();     end
	objSwf.goalList.itemClick		= function(e) self:OnGoalClick(e);        end
	
	RewardManager:RegisterListTips( objSwf.rewardList );
	--添加章节奖励textField到数组
	self.chapterRewardTxts = {
		objSwf.rewardTxt1,
		objSwf.rewardTxt2,
		objSwf.rewardTxt3,
		objSwf.rewardTxt4,
		objSwf.rewardTxt5,
		objSwf.rewardTxt6
	}
	--添加章节
	for chapterIndex, chapter in ipairs(t_questChapter) do
		local chapterVO = {};
		chapterVO.chapterIndex = chapterIndex;
		chapterVO.iconURL = ResUtil:GetChapterIconURL(chapterIndex);
		objSwf.chapterList.dataProvider:push( UIData.encode(chapterVO) );
	end
	objSwf.chapterList:invalidateData();
end

function UIQuestTrunk:OnDelete()
	self.chapterRewardTxts = {}
end

function UIQuestTrunk:OnShow(name)
	local trunkQuest = QuestModel:GetTrunkQuest();
	if not trunkQuest then
		self:ShowAllQuestFinish();
		return;
	end
	self.currQuestId = trunkQuest:GetId();
	self:ResetChapter();
end


---------------------------点击事件--------------------------------------------

function UIQuestTrunk:OnBtnPreClick()
	local chapterIndex = math.max(self.currShowChapter - 1, 1);
	self:ShowChapter( chapterIndex );
end

function UIQuestTrunk:OnBtnNextClick()
	local chapterIndex = math.min(self.currShowChapter + 1, #t_questChapter);
	self:ShowChapter( chapterIndex );
end

function UIQuestTrunk:OnChapterItemClick(e)
	local chapterIndex = e.item.chapterIndex;
	if chapterIndex and self.currShowChapter ~= chapterIndex then
		self:ShowChapter( e.item.chapterIndex );
	end
end

function UIQuestTrunk:OnBtnReturnClick()
	self:ResetChapter();
end

function UIQuestTrunk:OnGoalClick(e)
	local goal = e and e.item
	if not goal then return end
	QuestController:DoGuide( goal.id );
end


--------------------------------------显示相关--------------------------------------

--显示所有任务已完成
function UIQuestTrunk:ShowAllQuestFinish()

end

--重置左侧章节
function UIQuestTrunk:ResetChapter()
	self.curChapterIndex = QuestConsts:GetChapter( self.currQuestId );
	self:ShowChapter( self.curChapterIndex );
end

--查看某章节
function UIQuestTrunk:ShowChapter( chapterIndex )
	-- if self.currShowChapter == chapterIndex then return; end
	self.currShowChapter = chapterIndex;
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--加载章节图标、标题图片
	self:ShowChapterTitle( objSwf, chapterIndex );
	--高亮章节图标
	self:HighLightIcon( objSwf, chapterIndex );
	--显示章节任务进度
	self:ShowProgress( objSwf, chapterIndex );
	--显示章节描述文本
	self:ShowChapterDes( objSwf, chapterIndex );
	--显示任务信息
	self:ShowQuest();
end

--加载章节图标、标题图片
function UIQuestTrunk:ShowChapterTitle(objSwf, chapterIndex)
	local chapterIconURL = ResUtil:GetChapterIconURL(chapterIndex);
	if chapterIconURL then
		objSwf.chapterIconLoader.source = chapterIconURL
	end
	local chapterTitleURL = ResUtil:GetChapterTitleImgURL(chapterIndex);
	if chapterTitleURL then
		objSwf.chapterTitleLoader.source = chapterTitleURL;
	end
end

--高亮图标
function UIQuestTrunk:HighLightIcon(objSwf, chapterIndex)
	objSwf.chapterList.chapterIndex = chapterIndex;
end

--显示章节任务进度
function UIQuestTrunk:ShowProgress(objSwf, chapterIndex)
	local questTotalCount = QuestConsts:GetChapterQuestCount( chapterIndex );
	local questDoneCount = 0;
	if chapterIndex == self.curChapterIndex then
		--当前进行中的章节
		questDoneCount = QuestConsts:GetQuestIndex( self.currQuestId ) - 1;
		self.currShowQuestId = self.currQuestId;
	elseif chapterIndex > self.curChapterIndex then
		--未到的章节
		questDoneCount = 0;
		self.currShowQuestId = QuestConsts:GetChapter1stQuest( chapterIndex );
	else--(隐含)if chapterIndex < self.curChapterIndex then
		--已完成的章节
		questDoneCount = questTotalCount;
		self.currShowQuestId = QuestConsts:GetChapter1stQuest( chapterIndex );
	end
	objSwf.siProQuest.maximum = questTotalCount;
	objSwf.siProQuest.value = questDoneCount;
	if questTotalCount ~= 0 then
		objSwf.lblPercent.text = toint( questDoneCount / questTotalCount * 100, 0.5 ) .. "%";
	else
		objSwf.lblPercent.text = "任务待配";
	end
	objSwf.lblProQuest.text = questDoneCount.."/"..questTotalCount;
end

--显示章节描述文本
function UIQuestTrunk:ShowChapterDes(objSwf, chapterIndex)
	objSwf.chapterDes.htmlText = t_questChapter[ chapterIndex ].des;
end

--获取任务章节奖励描述 reward : {type = enAttrType.eaGongJi, val = 100}
function UIQuestTrunk:GetChapterRewardHtmlText( reward )
	local rewardName = enAttrTypeName[ reward.type ];
	local format = "<font color='#29cc00'>%s</font><font color='#fffd33'>+%s</font>"
	return string.format( format, rewardName, reward.val );
end

--查看任务
function UIQuestTrunk:ShowQuest()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local questId = self.currShowQuestId;
	if not questId then return; end
	local questCfg = t_quest[questId]
	if not questCfg then return end
	
	self:ShowQuestDes(objSwf, questCfg);
	self:ShowQuestGoals(objSwf, questId);
	self:ShowQuestRewards(objSwf, questCfg);
end

--任务名称与任务描述
function UIQuestTrunk:ShowQuestDes(objSwf, questCfg)
	objSwf.LblQuestName.text = questCfg.name; 
	objSwf.TxtQuestDes.text = questCfg.des;
end

--任务目标列表
function UIQuestTrunk:ShowQuestGoals(objSwf, questId)
	-- todo
end

--显示任务奖励
function UIQuestTrunk:ShowQuestRewards(objSwf, questCfg)
	local rewardList = RewardManager:Parse(enAttrType.eaExp..","..questCfg.expReward, questCfg.profReward, questCfg.otherReward);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push( unpack(rewardList) );
	objSwf.rewardList:invalidateData();
end

--消息处理
function UIQuestTrunk:HandleNotification( name, body )
	if not ( self.bShowState and self.objSwf ) then
		return;
	end
	if name == NotifyConsts.QuestAdd then
		--如果新加的任务是主线任务,更新
		local quest = QuestModel:GetQuest(body.id);
		if not quest then return; end
		if quest:GetType() == QuestConsts.Type_Trunk then
			self.currQuestId = body.id;
			self:ResetChapter();
		end
	elseif name == NotifyConsts.QuestUpdate then
		--如果当前任务状态改变,更新
		if body.id == self.currQuestId then
			self:ResetChapter();
		end
	end
end

--监听消息
function UIQuestTrunk:ListNotificationInterests()
	return { NotifyConsts.QuestAdd, NotifyConsts.QuestUpdate };
end