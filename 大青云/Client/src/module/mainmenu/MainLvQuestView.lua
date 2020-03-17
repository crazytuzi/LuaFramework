--[[
主界面等级任务
2015年9月29日14:51:56
haohu
]]
------------------------------------------------------------------


_G.UIMainLvQuest = BaseUI:new("UIMainLvQuest");

function UIMainLvQuest:Create()
	self:AddSWF( "mainPageTaskLv.swf", true, nil );
end

function UIMainLvQuest:OnLoaded(objSwf)
	QuestNodeUtil:RegisterQuestTreeList( objSwf.list, self ) -- 对应handleNodeEvent方法
end

function UIMainLvQuest:NeverDeleteWhenHide()
	return true;
end

function UIMainLvQuest:GetWidth()
	return 243;
end

function UIMainLvQuest:OnShow()
	self:RefreshList()
end

-- 刷新列表
function UIMainLvQuest:RefreshList()
	local objSwf = self.objSwf
	if not objSwf then return end
	local treeData = QuestNodeUtil:GenerateLvQuestTree()
	local lvList = QuestModel:GetLevelQuests();
	if not treeData then return end
	local encodeFunc = function(vo)
		return vo.str
	end
	local list = objSwf.list
	UIData.cleanTreeData( list.dataProvider.rootNode);
	UIData.copyDataToTree( treeData, list.dataProvider.rootNode, encodeFunc )
	list.dataProvider:preProcessRoot()
	list:invalidateData()
	--如果有可领奖的,每次滚到开头
	for _, quest in pairs(lvList) do
		if quest:GetPlayRewardEffect() then
			list:scrollToIndex(0);
			break;
		end
	end
end

function UIMainLvQuest:HandleNodeEvent(e, nodeAction)
	local nodeUID = e.item and e.item.uid
	if not nodeUID then return end
	local node = QuestNodeUtil:FindLvNode( nodeUID )
	if node then
		local func = node[nodeAction]
		func( node, e )
	end
end

function UIMainLvQuest:HandleRedraw(e)
end

--播放任务完成特效
function UIMainLvQuest:PlayFinishEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not objSwf._visible then return; end
	local effPos = UIManager:PosLtoG( objSwf, -122, 20 );
	UIEffectManager:PlayEffect( ResUtil:GetQuestFinishEff(), effPos );
end
function UIMainLvQuest:PlayLvNewEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not objSwf._visible then return; end
	local effPos = UIManager:PosLtoG( objSwf, -175, -10 );
	UIEffectManager:PlayEffect( ResUtil:GetQuestLvFinishEff(), effPos );
end
function UIMainLvQuest:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestUpdate,
		NotifyConsts.QuestRefreshList,
	};
end

--消息处理
function UIMainLvQuest:HandleNotification( name, body )
	if name == NotifyConsts.QuestUpdate or name == NotifyConsts.QuestAdd then
		local quest = QuestModel:GetQuest(body.id)
		if quest and quest:GetType() == QuestConsts.Type_Level then
			self:RefreshList();
		end
	elseif name == NotifyConsts.QuestRemove then
		self:RefreshList();
	elseif name == NotifyConsts.QuestRefreshList then
		self:RefreshList();
	end
end