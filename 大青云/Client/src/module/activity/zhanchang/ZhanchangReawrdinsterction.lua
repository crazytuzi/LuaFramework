--[[
战场奖励物品介绍面板
wangshuai
]]
_G.UIZhchRewardInsterction = BaseUI:new("UIZhchRewardInsterction")

UIZhchRewardInsterction.reawrd = {1,1,{1,2},{1,2}}

function UIZhchRewardInsterction:Create()
	self:AddSWF("zhanchangRewardInsterction.swf",true,"center")
end;

function UIZhchRewardInsterction:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:OnClosePanel()end;
	RewardManager:RegisterListTips(objSwf.list);
end;

function UIZhchRewardInsterction:OnClosePanel()
	self:Hide();
end;

function UIZhchRewardInsterction:Setlist()
	local serverLvl = MainPlayerController:GetServerLvl();
	local cfg = t_campAward[serverLvl];
	local list = {};
	for i,info in ipairs(self.reawrd) do 
		if i == 1 then --胜利奖励
			table.push(list,cfg.win)
		elseif i == 2 then -- 参与奖励
			table.push(list,cfg.join)
		elseif i == 3 then  --  贡献奖励
			for i,info in ipairs(info) do 
				table.push(list,cfg.contri[info])
			end;
		elseif i == 4 then -- 累杀奖励
			for i,info in ipairs(info) do 
				table.push(list,cfg.kill[info])
			end;
		end;
	end;
	return list
end

function UIZhchRewardInsterction:OnShow()
	self:Showlist()
end;

function UIZhchRewardInsterction:Showlist()
	local objSwf = self.objSwf;
	local list = self:Setlist();
	local listvo = {};
	for i,info in ipairs(list) do 
		local item = RewardSlotVO:new();
		item.id = info;
		item.count = 1;
		table.push(listvo,item:GetUIData())
	end;
	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(listvo));
	objSwf.list:invalidateData();

end;

function UIZhchRewardInsterction:OnHide()

end;