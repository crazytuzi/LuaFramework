--[[
QQ群礼包
lizhuangzhuang
2015年7月6日10:36:08
]]

_G.UIQQReward = BaseUI:new("UIQQReward");

UIQQReward.lastSendTime = 0;
function UIQQReward:Create()
	self:AddSWF("qqReward.swf",true,"center");
end
function UIQQReward:OnLoaded(objSwf)
	-- objSwf.btnClose.click=function() self:Hide();end
	objSwf.btnGet.click = function() self:OnBtnGetClick(); end
--	objSwf.btnAdd.click = function() self:OnBtnAddClick(); end
	objSwf.inputCode.textChange = function() self:OnCodeChange(); end

	objSwf.rewardList.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.rewardList.itemRollOut = function () TipsManager:Hide(); end
end

function UIQQReward:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	self:DrawReward()
	objSwf.inputCode.text = "";
	--objSwf.tfQQ.text = Version:GetQQNum();
end
function UIQQReward:OnCodeChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = objSwf.inputCode.text;
	text = string.gsub(text,"\r",function()
							return "";
						end);
	objSwf.inputCode.text = text;
end

function UIQQReward:OnBtnAddClick()
	Version:QQRewardBrowse();
end
function UIQQReward:DrawReward()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local cfg = t_jihuoma[2]
	if not cfg then return; end
	
	local randomList = RewardManager:Parse(cfg.reward);
	objSwf.rewardList.dataProvider:cleanUp();
	objSwf.rewardList.dataProvider:push(unpack(randomList));
	objSwf.rewardList:invalidateData();
end
function UIQQReward:OnBtnGetClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if objSwf.inputCode.text == "" then
		return;
	end
	if GetCurTime() - self.lastSendTime < 1000 then
		return;
	end
	self.lastSendTime = GetCurTime();
	RegisterAwardController:ReqActivatyCode(objSwf.inputCode.text);
end

function UIQQReward:OnGetReward(id)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.inputCode.text = "";
	local vo = t_jihuoma[id];
	if vo then
		UIRewardGetPanel:Open("礼包",vo.reward)
	end
end

function UIQQReward:HandleNotification(name,body)
	if name == NotifyConsts.GetCodeReward then
		self:OnGetReward(body.id);
	end
end

function UIQQReward:ListNotificationInterests()
	return {NotifyConsts.GetCodeReward};
end