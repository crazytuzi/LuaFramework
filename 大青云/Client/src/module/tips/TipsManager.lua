--[[
Tips入口
lizhuangzhuang
2014年7月23日21:48:19
]]

_G.TipsManager = {};

--解析类
TipsManager.listParseClass = {}

--显示tips
function TipsManager:ShowTips(tipsType,tipsInfo,tipsShowType,tipsDir, itemId)
	if tipsType == TipsConsts.Type_Normal then
		UITipsTool:Hide();
		UITipsBtn:ShowTips(tipsInfo,tipsDir,itemId);
		return;
	end
	if tipsType == TipsConsts.Type_Fabao then
		UIFabaoTips:Hide();
		UIFabaoTips:ShowTips(tipsInfo,tipsDir);
		return;
	end
	if tipsType == TipsConsts.Type_Goal then
		UIGoalTips:Hide();
		UIGoalTips:ShowTips(tipsInfo,tipsDir);
		return;
	end
	if tipsType==TipsConsts.Type_Transfor then
	    UITransforTips:Hide();
        UITransforTips:ShowTips(tipsInfo,tipsDir)
        return;
	end
	local parseObj = self.listParseClass[tipsType];
	if not parseObj then
		Debug("error:cannot find tips parse class. type:"..tipsType);
		return;
	end
	parseObj:Parse(tipsInfo);
	local infoVO = TipsToolInfoVO:new();
	infoVO:CopyDataFromTips(parseObj);
	UITipsBtn:Hide();
	UIFabaoTips:Hide();
	UIGoalTips:Hide();
	if tipsType == TipsConsts.Type_StrenLink or tipsType == TipsConsts.Type_GemLink  or 
		tipsType == TipsConsts.Type_NewEquipGroup or tipsType == TipsConsts.Type_WashLink then
		TipsManager:ShowTips(TipsConsts.Type_Normal, infoVO.tipsStr, tipsShowType, tipsDir)
		return
	end
	if tipsShowType == TipsConsts.ShowType_Compare then
		parseObj:Parse(tipsInfo.compareTipsVO);
		local compareInfoVO = TipsToolInfoVO:new();
		compareInfoVO:CopyDataFromTips(parseObj);
		UITipsTool:ShowTips(infoVO,tipsDir,compareInfoVO);
	else
		UITipsTool:ShowTips(infoVO,tipsDir);
	end
end
--快捷入口,显示按钮tips
function TipsManager:ShowBtnTips(tipsStr,tipsDir)
	if not tipsDir then tipsDir=TipsConsts.Dir_RightUp; end
	self:ShowTips(TipsConsts.Type_Normal, tipsStr, TipsConsts.ShowType_Normal, tipsDir);
end

--快捷入口,显示背包内物品Tips
function TipsManager:ShowBagTips(bag,pos, tipsDir)
	if not tipsDir then tipsDir=TipsConsts.Dir_RightDown; end
	local itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(bag,pos);
	if not itemTipsVO then return; end
	self:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, tipsDir);
end

--快捷入口,显示物品装备
function TipsManager:ShowItemTips(itemId,count,tipsDir,bind)
	if not count then count=1; end
	if not tipsDir then tipsDir=TipsConsts.Dir_RightDown; end
	if not bind then bind=BagConsts.Bind_None; end
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(itemId,count,bind);
	if not itemTipsVO then return; end
	self:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, tipsDir);
end

--快捷入口,显示法宝
function TipsManager:ShowFabaoTips(fabao, tipsDir)
	if not fabao then
		return;
	end
	if not tipsDir then tipsDir=TipsConsts.Dir_RightDown; end
	self:ShowTips(TipsConsts.Type_Fabao,fabao,TipsConsts.ShowType_Normal,tipsDir);
end

--快捷入口，显示天神tips
function TipsManager:ShowNewTianshenTips(tianshen, tipsDir)
	local tipsVO = ItemTipsVO:new();
	tipsVO.isInBag = false;
	tipsVO.isTianshen = true
	tipsVO.param1 = nil
	tipsVO.param2 = nil
	tipsVO.param4 = nil
	tipsVO.tianshen = tianshen
	self:ShowTips(TipsConsts.Type_NewTianshen,tipsVO,TipsConsts.ShowType_Normal,tipsDir)
end
--快捷入口,显示目标奖励
function TipsManager:ShowGoalTips(goal,tipsDir)
	if not goal then
		return;
	end
	if not tipsDir then tipsDir=TipsConsts.Dir_RightDown; end
	self:ShowTips(TipsConsts.Type_Goal,goal,TipsConsts.ShowType_Normal,tipsDir);
end
--快捷入口,显示天神
function TipsManager:ShowTranforTips(tianshen,tipsDir)
	if not tianshen then
		return;
	end
	if not tipsDir then tipsDir=TipsConsts.Dir_RightDown; end
	self:ShowTips(TipsConsts.Type_Transfor,tianshen,TipsConsts.ShowType_Normal,tipsDir);
end
--快捷入口,显示法宝融合预览
function TipsManager:ShowFabaoReviewTips(fabao,fabao1,tipsDir)
	UIFabaoTips:Hide();
	UIFabaoTips:ShowTips(fabao,tipsDir,true,fabao1);
end

--装备传承预览TIPS
function TipsManager:ShowRespTips(itemTipsVO)
	self:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown)
end

--快捷入口,显示法宝合成预览
-- function TipsManager:ShowFabaoHechengTips(fabao,tipsDir)
	-- UIFabaoTips:Hide();
	-- UIFabaoTips:ShowTips(fabao,tipsDir,false,true);
-- end

--关闭Tips
function TipsManager:Hide()
	UITipsBtn:Hide();
	UITipsTool:Hide();
	UIFabaoTips:Hide();
	UIGoalTips:Hide();
	UITransforTips:Hide();
end

--添加一个解析类
function TipsManager:AddParseClass(tipsType,class)
	self.listParseClass[tipsType] = class;
end