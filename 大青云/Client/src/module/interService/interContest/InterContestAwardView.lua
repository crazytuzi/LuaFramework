--[[
跨服擂台预选赛奖励查询
liyuan
]]

_G.UIInterContestAward = BaseUI:new("UIInterContestAward");
UIInterContestAward.awardType = 1

function UIInterContestAward:Create()
	self:AddSWF("interContestAwardView.swf", true, "highTop");
end

function UIInterContestAward:OnLoaded(objSwf)
	objSwf.listtxt.rewardItemRollOver = function(e) 
		local reward = e.item.reward
		FPrint(reward)
		local rewardArr = split(reward, '#')
		local tipsStr = StrConfig['interServiceDungeon64']
		for k,v in pairs(rewardArr) do
			local itemArr = split(v, ',')
			local itemId = toint(itemArr[1])
			local itemCfg = t_item[itemId]
			if not itemCfg then
				itemCfg = t_equip[itemId]
			end
			
			if itemCfg then
				tipsStr = tipsStr .. itemCfg.name ..'*'.. itemArr[2] .. '<br/>'
			end
		end
		TipsManager:ShowBtnTips(tipsStr)
	end
	
	objSwf.btnClose.click = function()
		self:Hide()
	end
	
	objSwf.listtxt.rewardItemRollOut = function(e) TipsManager:Hide(); end	
end

-----------------------------------------------------------------------
function UIInterContestAward:IsTween()
	return false;
end

function UIInterContestAward:GetPanelType()
	return 0;
end

function UIInterContestAward:IsShowSound()
	return false;
end

function UIInterContestAward:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	if self.args and self.args[1] then
		self.awardType = self.args[1]
	end
	self:UpdateInfo()	
end

function UIInterContestAward:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	local voc = {}
	if self.awardType == 1 then
		local list = t_kuafuarenareward
		if not list then return end
		table.sort(list,function(A,B)
			if A.rank > B.rank then
				return true;
			else
				return false;
			end
		end);
		
		for k,v in ipairs(list) do
			local vo = self:GetAwardVO1(v)
			if vo then 
				table.push(voc,UIData.encode(vo))
			end
		end	
	else
		local list = t_kuafusaireward
		if not list then return end
		for k,v in ipairs(list) do
			local vo = self:GetAwardVO(v)
			if vo then 
				table.push(voc,UIData.encode(vo))
			end
		end	
	end
	FTrace(voc)
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(voc));
	objSwf.listtxt:invalidateData();
end

function UIInterContestAward:GetAwardVO1(rankCfg)
	local rankVO = {}
	rankVO.id = rankCfg.id
	rankVO.reward = rankCfg.reward1	
	rankVO.roleName = rankCfg.rewardinfo or ''	
	return rankVO
end

function UIInterContestAward:GetAwardVO(rankCfg)
	local rankVO = {}
	rankVO.id = rankCfg.id
	rankVO.reward = rankCfg.reward
	local rankList = split(rankCfg.rank, ',')
	if toint(rankList[2]) >= 1000000 then
		rankVO.roleName = string.format(StrConfig['interServiceDungeon60'], rankList[1])
	else
		rankVO.roleName = string.format(StrConfig['interServiceDungeon59'], rankList[1], rankList[2])
	end
	
	return rankVO
end

function UIInterContestAward:OnHide()
end

function UIInterContestAward:GetWidth()
	return 403;
end

function UIInterContestAward:GetHeight()
	return 498;
end

function UIInterContestAward:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestAward:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestAward:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestAward:HandleNotification(name, body)
	
end

