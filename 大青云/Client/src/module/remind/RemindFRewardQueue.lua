--[[
好友升级礼包提醒
lizhuangzhuang
2015年6月1日16:31:21
]]

_G.RemindFRewardQueue = setmetatable({},{__index=RemindQueue});

function RemindFRewardQueue:GetType()
	return RemindConsts.Type_FReward;
end

function RemindFRewardQueue:GetLibraryLink()
	return "RemindFReward";
end

function RemindFRewardQueue:GetPos()
	return 2;
end

function RemindFRewardQueue:GetShowIndex()
	return 11;
end

function RemindFRewardQueue:GetBtnWidth()
	return 60;
end

function RemindFRewardQueue:AddData(data)
	table.push(self.datalist,data);
	self:ShowInfo();
end

function RemindFRewardQueue:OnBtnShow()
	if self.button.eff then
		if self.button.eff.initialized then
			self.button.eff:playEffect(0);
		else
			self.button.eff.init = function()
				self.button.eff:playEffect(0);
			end
		end
	end
	self:ShowInfo();
end

function RemindFRewardQueue:ShowInfo()
	if not self.button then return; end
	if #self.datalist == 0 then return; end
	local vo = self.datalist[#self.datalist];
	self.button.tf.htmlText  = string.format(StrConfig['remind009'],vo.roleName,vo.level);
	self.button.mcNum.textField.text = #self.datalist;
end


function RemindFRewardQueue:DoClick()
	if #self.datalist == 0 then return; end
	UIFriendReward:Open(self.datalist);
	self.datalist = {};
	self:RefreshData();
end

function RemindFRewardQueue:DoRollOver()
	TipsManager:ShowBtnTips(StrConfig["remind008"]);
end

function RemindFRewardQueue:DoRollOut()
	TipsManager:Hide();
end