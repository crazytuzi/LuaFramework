require "Core.Module.Common.UIItem"

SubItem5Item = class("SubItem5Item", UIItem);



function SubItem5Item:New()
	self = {};
	setmetatable(self, {__index = SubItem5Item});
	return self
end


function SubItem5Item:_Init()
	
	self.hasdoIcon = UIUtil.GetChildByName(self.transform, "UISprite", "hasdoIcon");
	self.awardBt = UIUtil.GetChildByName(self.transform, "UIButton", "awardBt");
	self.titleTxt = UIUtil.GetChildByName(self.transform, "UILabel", "titleTxt");
	self.productMaxNum = 5;
	self._txtRewardCount = UIUtil.GetChildByName(self.transform, "UILabel", "rewardtxt");
	-- self.productCtrs = { };
	-- self.productExtProFats = { };
	-- for i = 1, self.productMaxNum do
	--     self.productTfs[i] = UIUtil.GetChildByName(self.transform, "Transform", "product" .. i);
	--     self.productExtProFats[i] = UIUtil.GetChildByName(self.productTfs[i], "Transform", "extFatLabel");
	--     self.productCtrs[i] = ProductCtrl:New();
	--     self.productCtrs[i]:Init(self.productTfs[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
	--     self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
	--     self.productCtrs[i]:SetActive(false);
	--     self.productExtProFats[i].gameObject:SetActive(false);
	-- end
	self._onClickAwardBt = function(go) self:_OnClickAwardBt() end
	UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickAwardBt);
	
	
	self.hasdoIcon.gameObject:SetActive(false);
	self.awardBt.gameObject:SetActive(false);
	
	
	self:UpdateItem(self.data)
end

--[[['id'] = 2,
		['kind'] = 2,
		['totalcountlimit'] = 1,
		['reward_level'] = 30,
		['reward'] = {'370003_2','504000_2','500092_2','500002_2'},
		['extra_reward'] = '350003_2'
]]
function SubItem5Item:UpdateItem(data)
	self.data = data;
	
	self.titleTxt.text = LanguageMgr.Get("ActivityGifts/SubItem5Item/label1", {n = self.data.reward_level});
	local rewards = self.data.reward;
	local rewardCount = tonumber(ConfigSplit(rewards[1]) [2])
	self._txtRewardCount.text = "X" .. rewardCount
	-- local reward_num = table.getn(rewards);
	-- for i = 1, reward_num do
	--     local arr = ConfigSplit(rewards[i]);
	--     local id = tonumber(arr[1]);
	--     local num = tonumber(arr[2]);
	--     local info = ProductInfo:New();
	--     info:Init( { spId = id, am = num });
	-- self.productCtrs[i]:SetData(info);
	-- self.productCtrs[i]:SetActive(true);
	-- self.productExtProFats[i].gameObject:SetActive(false);
	-- end
	-------------extra_reward----------------------
	-- local extra_reward = self.data.extra_reward;
	-- local arr = ConfigSplit(extra_reward);
	-- local id = tonumber(arr[1]);
	-- local num = tonumber(arr[2]);
	-- local info = ProductInfo:New();
	-- info:Init( { spId = id, am = num });
	-- self.extProIndex = reward_num + 1;
	-- self.productCtrs[self.extProIndex]:SetData(info);
	-- self.productCtrs[self.extProIndex]:SetActive(true);
	-- self.productExtProFats[self.extProIndex].gameObject:SetActive(true);
	--------------------------------------------------------------
	local canGetAward = self.data.canGetAward;
	local hasGetAward = self.data.hasGetAward;
	local isShowExtAward = self.data.isShowExtAward;
	
	if canGetAward and not hasGetAward then
		-- 可以领取奖励但还没领取
		self.hasdoIcon.gameObject:SetActive(false);
		self.awardBt.gameObject:SetActive(true);
	elseif canGetAward and hasGetAward then
		-- 可以领取奖励但已经领取
		self.hasdoIcon.gameObject:SetActive(true);
		self.awardBt.gameObject:SetActive(false);
	elseif not canGetAward then
		-- 不能领取
	end
	
	
	if isShowExtAward then
		-- 是否显示额外奖励显示
	else
		
		
	end
	
end

function SubItem5Item:GetInfo(list, id)
	local list_num = table.getn(list);
	
	for i = 1, list_num do
		if list[i].id == id then
			return list[i];
		end
	end
	
	return nil;
end




--[[08 玩家是否购买成长基金
输入：
输出：
l:[(id(配表id) :Int,f：Int 领取状态（(0：不可领取 1：可领取但未领取 2：已领取)]
s : Int 0 ：表示未购买 1 ：已购买
]]
function SubItem5Item:SetState(list)
	
	self.info = self:GetInfo(list, self.data.id);
	
	if self.info ~= nil then
		local f = self.info.f;
		-- 0：不可领取 1：可领取但未领取 2：已领取)]
		if f == 0 then
			self.hasdoIcon.gameObject:SetActive(false);
			self.awardBt.gameObject:SetActive(false);
			
		elseif f == 1 then
			self.hasdoIcon.gameObject:SetActive(false);
			self.awardBt.gameObject:SetActive(true);

		elseif f == 2 then
			self.hasdoIcon.gameObject:SetActive(true);
			self.awardBt.gameObject:SetActive(false);
		end
		
	else
		self.hasdoIcon.gameObject:SetActive(false);
		self.awardBt.gameObject:SetActive(false);
	end
	
	-- if ActivityGiftsProxy._0x1a08Data ~= nil then
	--     local s = ActivityGiftsProxy._0x1a08Data.s;
	--     local me = HeroController:GetInstance();
	--     local heroInfo = me.info;
	--     local my_lv = heroInfo.level;
--[[        s : Int 0 ：表示未购买 1 ：已购买
         http://192.168.0.8:3000/issues/2052

        成长基金有2个点：
1、角色在40级之前购买的成长基金不显示额外奖励，也不会获得额外奖励
2、角色在40级及之后购买的成长基金会显示额外奖励，也会获得额外奖励

显示相关的
1、角色在40级之前没有购买成长基金时，不显示额外奖励
2、角色在40级及之后没有购买成长基金时，显示额外奖励

        ]]
	-- local buy_lv = ActivityGiftsProxy._0x1a08Data.buy_lv;
	-- local llv = 40;
	-- if buy_lv == nil then
	--     buy_lv = 1;
	-- end
	-- if s == 1 then
	--     -- 已购买
	--     if buy_lv <= llv then
	--         self:SetExtProV(true);
	--     else
	--         self:SetExtProV(false);
	--     end
	-- else
	--     -- 未购买
	--     if my_lv <= llv then
	--         self:SetExtProV(true);
	--     else
	--         self:SetExtProV(false);
	--     end
	-- end
	-- end
end

function SubItem5Item:SetExtProV(v)
	-- self.productCtrs[self.extProIndex]:SetActive(v);
	-- self.productExtProFats[self.extProIndex].gameObject:SetActive(v);
end

function SubItem5Item:DataChange()
	if(self.data) then
		
		
	end
	
end

function SubItem5Item:_OnClickAwardBt()
	
	ActivityGiftsProxy.GetChengZhangJiJingAwards(self.data.id)
end

function SubItem5Item:_Dispose()
	
	
	UIUtil.GetComponent(self.awardBt, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickAwardBt = nil;
	
	-- for i = 1, self.productMaxNum do
	--     self.productCtrs[i]:Dispose();
	--     self.productCtrs[i] = nil;
	-- end
	self.hasdoIcon = nil;
	
	self.awardBt = nil;
	self.titleTxt = nil;
	
	
	self.productTfs = nil;
	-- self.productCtrs = nil;
	self._onClickAwardBt = nil;
	self._txtRewardCount = nil
end



