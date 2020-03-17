--[[
	奇遇抽奖界面
	2015年10月15日, PM 10:25:46
	wangyanwei
]]

_G.RandomDungeonRaffle = BaseUI:new('RandomDungeonRaffle');

function RandomDungeonRaffle:Create()
	self:AddSWF('randomDungeonRaffle.swf',true,'center');
end

RandomDungeonRaffle.selecIndex = 0;
function RandomDungeonRaffle:OnLoaded(objSwf)
	objSwf.btn_close.click = function () self:Hide(); end
	objSwf.btn_getReward.click = function () self:onGetRewardClick(); end
	for i = 1 , 3 do
		objSwf['raffle' .. i].rollOver = function(e) TipsManager:ShowItemTips(e.target.data.id); end
		objSwf['raffle' .. i].rollOut = function(e) TipsManager:Hide(); end
		objSwf['btn_mask' .. i].click = function() self.selecIndex = i; self:DisabledBtn(); self.func(); end;
	end
	objSwf.load_npc.hitTestDisable = true;
	objSwf.btn_mask1.selected = true;
end

function RandomDungeonRaffle:onGetRewardClick()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self:DisabledBtn();
	self.func();
end

function RandomDungeonRaffle:onAutoGetRewardClick()
	if t_consts[90].val2 then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaLevel >= t_consts[90].val2 then
			self.selecIndex = 1; self:DisabledBtn(); self.func();
		end
	end
end

function RandomDungeonRaffle:DisabledBtn()
	local objSwf = self.objSwf;
	if not objSwf then return end
	for i = 1 , 3 do
		if self.selecIndex ~= i then
			objSwf['btn_mask' .. i].disabled = true;
		end
	end
end

function RandomDungeonRaffle:GetWidth()
	return 789
end

function RandomDungeonRaffle:GetHeight()
	return 269
end

function RandomDungeonRaffle:OnShow()
	self.selecIndex = 1;
	self:ShowReward();
	self:InItEffectDate();
	self:DrawNpcRole();
	self:onAutoGetRewardClick();
end

function RandomDungeonRaffle:ShowReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_qiyuzu[self.curRandomID];
	if not cfg then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local rewardCfg = t_qiyulevel[level];
	if not rewardCfg then return end
	local rewardStr = rewardCfg['reward_item' .. cfg.groupid];
	local reward = split(rewardStr,',')
	for i = 1 , 3 do
		local rewardSlotVO = RewardSlotVO:new();
		rewardSlotVO.id = t_item[toint(reward[1])].id;
		rewardSlotVO.count = toint(reward[2]);
		objSwf['raffle' .. i]:setData(rewardSlotVO:GetUIData());
		objSwf['raffle' .. i].visible = false;
	end
	
	local str = cfg.npctalk;
	objSwf.txt_chat.text = str;
end

function RandomDungeonRaffle:InItEffectDate()
	local objSwf = self.objSwf;
	if not objSwf then return end
	-- objSwf.btn_getReward.disabled = true;
	for i = 1 , 3 do
		objSwf['raffle' .. i].visible = false;
		objSwf['btn_mask' .. i].disabled = false;
		objSwf['btn_mask' .. i].visible = true;
		objSwf['effect_' .. i]:stopEffect();
	end
	objSwf.effect_kuang._visible = true;
end

RandomDungeonRaffle.curRandomID = 0;
RandomDungeonRaffle.func = nil;
function RandomDungeonRaffle:Open(id,func)
	if not id then return end
	if not func then return end
	if self:IsShow() then return end
	self.curRandomID = id;
	self.func = func;
	self:Show();
end

function RandomDungeonRaffle:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	self.curRandomID = 0;
	self.selecIndex = 0;
	self.func = nil;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	objSwf.btn_mask1.selected = true;
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
end

function RandomDungeonRaffle:DrawNpcRole()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_qiyuzu[self.curRandomID];
	if not cfg then return end
	local npcId = cfg.modelid;
	local loader = objSwf.load_npc;
	
	local npcAvatar = NpcAvatar:NewNpcAvatar(npcId);

	npcAvatar:InitAvatar();
	local drawCfg = UIDrawRandomNpcCfg[npcId];
	if not drawCfg then
		drawCfg = self:GetDefaultCfg();
		UIDrawRandomNpcCfg[npcId] = drawCfg;
	end
	if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("RandomDungeonRaffle",npcAvatar, loader,
							drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos,
							0x00000000,"UINpc");
	else
		self.objUIDraw:SetUILoader(loader);
		self.objUIDraw:SetCamera(drawCfg.VPort,drawCfg.EyePos,drawCfg.LookPos);
		self.objUIDraw:SetMesh(npcAvatar);
	end
	local rotation = drawCfg.Rotation or 0;
	npcAvatar.objMesh.transform:setRotation( 0, 0, 1, rotation );
	self.objUIDraw:SetDraw(true);
	
end

RandomDungeonRaffle.defaultCfg = {
	EyePos = _Vector3.new(0,-40,20),
	LookPos = _Vector3.new(0,0,10),
	VPort = _Vector2.new(1800,1200),
	Rotation = 0
};

function RandomDungeonRaffle:GetDefaultCfg()
	local cfg = {};
	cfg.EyePos = self.defaultCfg.EyePos:clone();
	cfg.LookPos = self.defaultCfg.LookPos:clone();
	cfg.VPort = self.defaultCfg.VPort:clone();
	cfg.Rotation = 0;
	return cfg;
end

function RandomDungeonRaffle:PlayEffect(id)
	local objSwf = self.objSwf;
	if not objSwf then return end
	if id ~= self.curRandomID then
		return
	end
	local index = self.selecIndex;
	local mc = objSwf['btn_mask' .. index];
	local effEctMc = objSwf['effect_' .. index];
	if not mc or not effEctMc then return end
	mc.visible = false;
	effEctMc:playEffect(1);
	effEctMc.complete = function () objSwf['raffle' .. index].visible = true; self:OnFlyIcon(); end --objSwf.btn_getReward.disabled = false;
	objSwf.effect_kuang._visible = false;
end

function RandomDungeonRaffle:OnFlyIcon()
	local objSwf = self.objSwf;
	if not objSwf then return end
	
	local cfg = t_qiyuzu[self.curRandomID];
	if not cfg then return end
	local level = MainPlayerModel.humanDetailInfo.eaLevel;
	local rewardCfg = t_qiyulevel[level];
	if not rewardCfg then return end
	local rewardStr = rewardCfg['reward_item' .. cfg.groupid];
	local reward = split(rewardStr,',')
	
	
	local rewardList = RewardManager:ParseToVO(toint(reward[1]));
	local startPos = UIManager:PosLtoG(objSwf['raffle' .. self.selecIndex]);
	RewardManager:FlyIcon(rewardList,startPos,5,true,60);
	if self.timeKey then
		TimerManager:UnRegisterTimer(self.timeKey);
		self.timeKey = nil;
	end
	local func = function()
		self:Hide();
	end
	self.timeKey = TimerManager:RegisterTimer(func,2000);
end

function RandomDungeonRaffle:HandleNotification(name, body)
	if name == NotifyConsts.RandomDungeonReward then	--奇遇奖励返回
		self:PlayEffect(body.id);
	end
end

--监听消息列表
function RandomDungeonRaffle:ListNotificationInterests()
	return { 
		NotifyConsts.RandomDungeonReward,
	};
end