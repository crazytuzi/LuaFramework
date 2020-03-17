--[[
奖励Manager,统一处理奖励
lizhuangzhuang
2014年8月26日18:14:35
]]

_G.RewardManager = {}

--解析奖励
--参数,字符串 物品id,数量,绑定状态#物品id,数量,绑定状态
--返回list,RewardSlotVO
function RewardManager:Parse(...)
	local list = self:ParseToVO(...);
	local rewardlist = {};
	for i,vo in ipairs(list) do
		for k,v in pairs(RewardSlotVO) do
			if type(v) == "function" then
				vo[k] = v;
			end
		end
		table.push(rewardlist,vo:GetUIData());
	end
	return rewardlist;
end

function RewardManager:ParseBlack(...)
	local list = self:ParseToVO(...);
	local rewardlist = {};
	for i,vo in ipairs(list) do
		for k,v in pairs(RewardSlotVO) do
			if type(v) == "function" then
				vo[k] = v;
			end
		end
		vo.isBlack = true;
		table.push(rewardlist,vo:GetUIData());
	end
	return rewardlist;
end

--将奖励解析成VO
--参数,字符串 物品id,数量#物品id,数量
--返回list,VO{id,num}
function RewardManager:ParseToVO(...)
	local list = {}
	for i,str in pairs{...} do
		if str ~= "" then
			local itemList = split(str,"#");
			for i,itemStr in ipairs(itemList) do
				local item = split(itemStr,",");
				local vo = {};
				vo.id = tonumber(item[1]);
				vo.count = tonumber(item[2]) or 1;
				if #item >= 3 then
					local bind = tonumber(item[3]);
					if bind == BagConsts.Bind_GetBind then
						vo.bind = bind;
					else
						local cfg = t_equip[vo.id] or t_item[vo.id];
						if cfg then
							vo.bind = cfg.bind;
						else
							vo.bind = BagConsts.Bind_GetBind;
						end
					end
				else
					vo.bind = BagConsts.Bind_GetBind;--默认获取绑定
				end
				table.push(list,vo);
			end
		end
	end
	return list;
end

--注册奖励列表的Tips
function RewardManager:RegisterListTips(uiList)
	if not uiList then return; end
	uiList.itemRollOver = function(e) self:OnRewardItemOver(e); end
	uiList.itemRollOut  = function(e) self:OnRewardItemOut(e); end
end

--鼠标移入奖励Item
function RewardManager:OnRewardItemOver(e)
	-- print('--------------e.item.id',e.item.id)
	if e.item.id==10 and UIEquipDecomp.IsDecompRewardlist then--装备分解预览：银两不需要tips
		return;
	end
	local slotVO = RewardSlotVO:new();
	slotVO.id = e.item.id;
	slotVO.count = e.item.count;
	slotVO.bind = e.item.bind;
	local tipsInfo = slotVO:GetTipsInfo();
	if not tipsInfo then return; end
	TipsManager:ShowTips(tipsInfo.tipsType,tipsInfo.info,tipsInfo.tipsShowType, TipsConsts.Dir_RightDown, tipsInfo.itemID);
end

--鼠标移出奖励Item
function RewardManager:OnRewardItemOut(e)
	TipsManager:Hide();
end

--奖励飞图标
--@param list 奖励列表
--@param startPos 开始位置
--@param rowCount 每行的个数 
--@param bigSize 是否是大图标
--@param itemWidth Item宽度
--@param itemHeight Item高度
function RewardManager:FlyIcon(list,startPos,rowCount,bigSize,itemWidth,itemHeight)
	if not itemHeight then
		itemHeight = itemWidth;
	end
	if #list < 0 then return; end
	local func = FuncManager:GetFunc(FuncConsts.Bag);
	if not func then return; end
	local bagPos = func:GetBtnGlobalPos();
	bagPos.x = bagPos.x + 13;
	bagPos.y = bagPos.y + 13;
	local flylist = {};
	for i=1, #list do
		local vo = list[i];
		local flyVO = {};
		flyVO.objName = 'FlyVO'
		flyVO.url = BagUtil:GetItemIcon(vo.id,bigSize);
		flyVO.startPos = {};
		if i%rowCount == 0 then
			flyVO.startPos.x = startPos.x + (rowCount-1)*itemWidth;
		else
			flyVO.startPos.x = startPos.x + (i%rowCount-1)*itemWidth;
		end
		local row = toint(i/rowCount,1);
		flyVO.startPos.y = startPos.y + (row-1)*itemHeight;	
		flyVO.endPos = bagPos;
		flyVO.time = 2;
		flyVO.tweenParam = {};
		flyVO.tweenParam._width = 25;
		flyVO.tweenParam._height = 25;
		table.push(flylist,flyVO);
	end
	FlyManager:FlyIconList(flylist);
end
