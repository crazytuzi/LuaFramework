--[[
主界面快捷任务 通过新手期后的上方主任务栏显示 通过主线任务表中的主线剧情是否存在判断是否显示这个
lizhuangzhuang
2014年7月25日10:16:17
]]

_G.UIMainQuestAll = BaseUI:new("UIMainQuestAll");

function UIMainQuestAll:Create()
	self:AddSWF( "mainPageTaskAll.swf", true, nil );
end

function UIMainQuestAll:OnLoaded(objSwf)
	objSwf.mcArrow._visible = false;
	objSwf.mcArrow.hitTestDisable = true;
	objSwf.mcTxt._visible = false;
	objSwf.mcTxt.hitTestDisable = true;
	objSwf.mcTxt1._visible = false;
	objSwf.mcTxt1.hitTestDisable = true;
	objSwf.mcTxt2._visible = false;
	objSwf.mcTxt2.hitTestDisable = true;
	objSwf.mcGirl._visible = false;
	objSwf.mcGirl.hitTestDisable = true;
	--
	QuestNodeUtil:RegisterQuestTreeList( objSwf.list, self ) -- 对应handleNodeEvent方法
end

function UIMainQuestAll:NeverDeleteWhenHide()
	return true;
end

function UIMainQuestAll:GetWidth()
	return 236;
end

function UIMainQuestAll:OnShow()
	self:RefreshList()
	QuestGuideManager:OnEnterGame();
end

-- 刷新列表
function UIMainQuestAll:RefreshList()
	local objSwf = self.objSwf
	if not objSwf then return end
	local treeData = QuestNodeUtil:GenerateQuestTree()
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
	--todo 免得在做历练的时候 任务栏总是回到最上方
	--[[for _, quest in pairs(QuestModel.questList) do
		if quest:GetPlayRewardEffect() then
			list:scrollToIndex(0);
			break;
		end
	end]]
end

function UIMainQuestAll:HandleNodeEvent(e, nodeAction)
	local nodeUID = e.item and e.item.uid
	if not nodeUID then return end
	local node = QuestNodeUtil:FindNode( nodeUID )
	if node then
		local func = node[nodeAction]
		func( node, e )
	end
end

function UIMainQuestAll:HandleRedraw(e)
end

--播放任务完成特效
function UIMainQuestAll:PlayFinishEffect()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not objSwf._visible then return; end
	local effPos = UIManager:PosLtoG( objSwf, -122, 20 );
	UIEffectManager:PlayEffect( ResUtil:GetQuestFinishEff(), effPos );
end

--主线任务引导
function UIMainQuestAll:ShowTrunkGuide(visible)
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	if visible then
		objSwf.list:scrollToIndex(0);
		local showFunc = function()
			objSwf.mcGirl._visible = true;
			objSwf.mcGirl:gotoAndPlay(1);
		end
		local unshowFunc = function()
			objSwf.mcGirl._visible = false;
			objSwf.mcGirl:gotoAndStop(1);
		end
		local updateFunc = function()
			local button = self:FindContentRenderer(QuestConsts.Type_Trunk);
			if button then
				objSwf.mcGirl._visible = true;
				objSwf.mcGirl._y = button._y + 8;
			else
				objSwf.mcGirl._visible = false;
			end
		end
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_Quest,
			showtype = UIFuncGuide.ST_Private,
			showFunc = showFunc,
			unshowFunc = unshowFunc,
			updateFunc = updateFunc
		});
	else
		UIFuncGuide:Close(UIFuncGuide.Type_Quest);
	end
end

--日环引导
function UIMainQuestAll:ShowDayGuide(visible)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if visible then
		local showFunc = function()
			objSwf.mcArrow._visible = true;
			objSwf.mcTxt1._visible = true;
		end
		local unshowFunc = function()
			objSwf.mcArrow._visible = false;
			objSwf.mcTxt1._visible = false;
		end
		local updateFunc = function()
			local button = self:FindContentRenderer(QuestConsts.Type_Day);
			if button then
				objSwf.mcArrow._visible = true;
				objSwf.mcTxt1._visible = true;
				objSwf.mcArrow._y = button._y +8;
				objSwf.mcTxt1._y = button._y + 8;
			else
				objSwf.mcArrow._visible = false;
				objSwf.mcTxt1._visible = false;
			end
		end
		UIFuncGuide:Open({
			type = UIFuncGuide.Type_DailyQuest,
			showtype = UIFuncGuide.ST_Private,
			showFunc = showFunc,
			unshowFunc = unshowFunc,
			updateFunc = updateFunc
		});
	else
		UIFuncGuide:Close(UIFuncGuide.Type_DailyQuest);
	end
end

--显示任务引导(通用)
function UIMainQuestAll:ShowQuestGuide(questType,guideType,text)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	--
	local node = QuestNodeUtil:FindContentNodeByQuestType(questType);
	if not node then return; end
	local index = QuestNodeUtil:FindNodeIndex(node:ToString());
	objSwf.list:scrollToIndex(index+5);
	--
	local textField = objSwf.mcTxt2.textField;
	textField._width = 300;
	textField.htmlText = text;
	textField._width = textField.textWidth+5 > 300 and 300 or toint(textField.textWidth+5);
	textField._height = toint(textField.textHeight+5);
	textField._x = toint(-textField._width/2);
	local mcBg = objSwf.mcTxt2.mcBg;
	mcBg._width = toint(textField._width + 16);
	mcBg._x = toint(-mcBg._width/2);
	mcBg._height = toint(textField._height + 24);
	mcBg._y = toint(-mcBg._height/2);
	textField._y = mcBg._y + 12;
	objSwf.mcTxt2._x = objSwf.mcArrow._x -  objSwf.mcTxt2._width/2 - 20;
	--
	local showFunc = function()
		objSwf.mcArrow._visible = true;
		objSwf.mcTxt2._visible = true;
	end
	local unshowFunc = function()
		objSwf.mcArrow._visible = false;
		objSwf.mcTxt2._visible = false;
	end
	local updateFunc = function()
		local button = self:FindContentRenderer(questType);
		if button then
			objSwf.mcArrow._visible = true;
			objSwf.mcTxt2._visible = true;
			objSwf.mcArrow._y = button._y + 8;
			objSwf.mcTxt2._y = button._y + 8;
		else
			objSwf.mcArrow._visible = false;
			objSwf.mcTxt2._visible = false;
		end
	end
	UIFuncGuide:Open({
		type = guideType,
		showtype = UIFuncGuide.ST_Private,
		showFunc = showFunc,
		unshowFunc = unshowFunc,
		updateFunc = updateFunc
	});
end

--显示任务引导(小女孩)
function UIMainQuestAll:ShowQuestGuideGirl(questType,guideType)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local node = QuestNodeUtil:FindContentNodeByQuestType(questType);
	if not node then return; end
	local index = QuestNodeUtil:FindNodeIndex(node:ToString());
	objSwf.list:scrollToIndex(index+5);
	--
	local showFunc = function()
		objSwf.mcGirl._visible = true;
		objSwf.mcGirl:gotoAndPlay(1);
	end
	local unshowFunc = function()
		objSwf.mcGirl._visible = false;
		objSwf.mcGirl:gotoAndStop(1);
	end
	
	local updateFunc = function()
		local button = self:FindContentRenderer(questType);
		if button then
			objSwf.mcGirl._visible = true;
			objSwf.mcGirl._y = button._y + 8;
		else
			objSwf.mcGirl._visible = false;
		end
	end
	UIFuncGuide:Open({
		type = guideType,
		showtype = UIFuncGuide.ST_Private,
		showFunc = showFunc,
		unshowFunc = unshowFunc,
		updateFunc = updateFunc
	});
end

--关闭任务引导(通用)
function UIMainQuestAll:CloseQuestGuide(guideType)
	UIFuncGuide:Close(guideType);
end

-- 获取日环星级条目
function UIMainQuestAll:GetDQStarRenderer()
	local objSwf = self.objSwf
	if not objSwf then return end
	local node = QuestNodeUtil:FindNodeByType( QuestNodeConst.Node_DQStar )
	if not node then return end
	return objSwf.list:findRendererByUID( node:ToString() )
end

-- 根据任务类型获取tree内容条目
function UIMainQuestAll:FindContentRenderer(questType)
	local objSwf = self.objSwf
	if not objSwf then return end
	local node = QuestNodeUtil:FindContentNodeByQuestType( questType )
	if not node then return end
	return objSwf.list:findRendererByUID( node:ToString() )
end

function UIMainQuestAll:ListNotificationInterests()
	return {
		NotifyConsts.QuestAdd,
		NotifyConsts.QuestRemove,
		NotifyConsts.QuestUpdate,
		NotifyConsts.QuestDailyFullStar,
		NotifyConsts.QuestDailyStateChange,
		NotifyConsts.QuestRefreshList,
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.QuestBreakRecommendChange,
	};
end

--消息处理
function UIMainQuestAll:HandleNotification( name, body )
	if name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel then
			--挂机显示相关
			QuestModel:CheckHangQuest();
			self:RefreshList();
		end
	elseif name == NotifyConsts.QuestUpdate or name == NotifyConsts.QuestAdd then
		local quest = QuestModel:GetQuest(body.id)
		if quest and quest:GetType() ~= QuestConsts.Type_Level then
			self:RefreshList();
		end
	elseif name == NotifyConsts.QuestRemove then
		self:RefreshList();	
	elseif name == NotifyConsts.QuestDailyFullStar then
		self:RefreshList();
	elseif name == NotifyConsts.QuestDailyStateChange then
		self:RefreshList();
	elseif name == NotifyConsts.QuestRefreshList then
		self:RefreshList();
	elseif name == NotifyConsts.QuestBreakRecommendChange then
		self:RefreshList();
	end
end