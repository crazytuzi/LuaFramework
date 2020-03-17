--[[
 顺网vip专属礼包
 wangshuai
 2015年11月12日18:31:20
]]

_G.ShunwangReward = BaseUI:new("ShunwangReward")

ShunwangReward.cuepage = 0;

function ShunwangReward:Create()
	self:AddSWF("shunwangRewardPanle.swf",true,"center")
end;

function ShunwangReward:OnLoaded(objSwf)
	objSwf.closebtn.click = function() self:Hide() end;
	objSwf.goVipa.click = function() self:GoShunWangVip()end;
	objSwf.scrollbar.scroll = function() self:OnVplanScrollBar() end;
	for i=1,4 do
		local item = objSwf["item"..i];
		item.btn.click = function() self:ItemClick(i) end;
		RewardManager:RegisterListTips(item.list);
	end

	objSwf.btn_openWeb.click = function() Version:LiaojieVip() end;
end;

function ShunwangReward:OnShow()
	local objSwf = self.objSwf;
	self:OnShowData();
	objSwf.scrollbar:setScrollProperties(4,0,#self.dataList-4);
	objSwf.scrollbar.trackScrollPageSize = 1;
	objSwf.scrollbar.position = 0;
	self.cuepage = 0;
end;

function ShunwangReward:OnHide()

end;

function ShunwangReward:GoShunWangVip()
	Version:UpViplvl()
end;

function ShunwangReward:OnVplanScrollBar()
	local objSwf = self.objSwf;
	local value = objSwf.scrollbar.position;
	self.cuepage = value
	self:OnShowList(value);
end;

function ShunwangReward:ItemClick(index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local page = self.cuepage+index;
	local data = self.dataList[page]
	if not data then return end;
	ShunwangContrller:GetShunwangReward(data.lvl)
end;

function ShunwangReward:OnShowData()
	local objSwf = self.objSwf;
	self.dataList = self:OnListData();
	if not self.dataList then self.dataList = {};end;
	self:OnShowList(self.cuepage);
	--self:SetBtnState()
end;

function ShunwangReward:OnShowList(val)
	local listvo = {};
	for i=1,4 do 
		table.push(listvo,self.dataList[val+i])
	end;
	local mylvl = MainPlayerModel.humanDetailInfo.eaLevel -- 人物等级
	local objSwf = self.objSwf;
	for i,info in ipairs(listvo) do 
		local item = objSwf["item"..i];
		if item then 
			item.btn.disabled = info.isReward;
			item.btn.label = info.label;
			local rewardList = RewardManager:Parse(info.reward);
			item.levelNum.num = info.lvl;
			item.list.dataProvider:cleanUp();
			item.list.dataProvider:push(unpack(rewardList));
			item.list:invalidateData();
		end;
	end;

end;

function ShunwangReward:OnListData()
	local objSwf = self.objSwf
	local cfg = t_shunwangvip;
	local listvo = {};

	for i,info in ipairs(cfg) do
		local state = ShunwangModel:GetRewardState(info.id)
		local vo = {};
		vo.lvl    = info.id;
		if state then -- 没领取
			vo.isReward = false;
			vo.label = '领取奖励'
		else -- 已有领取过
			vo.isReward = true;
			vo.label = '已领取'
		end;
		vo.reward = info.reward;
		table.push(listvo,vo)
	end;
	return listvo
end;

-- 是否缓动
function ShunwangReward:IsTween()
	return true;
end

--面板类型
function ShunwangReward:GetPanelType()
	return 1;
end
--是否播放开启音效
function ShunwangReward:IsShowSound()
	return true;
end

function ShunwangReward:IsShowLoading()
	return true;
end