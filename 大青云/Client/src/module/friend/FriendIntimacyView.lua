--[[
好友亲密度面板
lizhuangzhuang
2014年12月2日15:43:24
]]

_G.UIFriendIntimacy = BaseUI:new("UIFriendIntimacy");

function UIFriendIntimacy:Create()
	self:AddSWF("friendIntimacy.swf",true,"center");
end

function UIFriendIntimacy:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.labelInfo.htmlText = StrConfig["friend203"];
	self:InitShow();
end

function UIFriendIntimacy:InitShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,cfg in ipairs(t_intimacy) do
		local item = objSwf["item"..i];
		if item then
			item.tfName.text = string.format(StrConfig['friend204'],cfg.name);
			item.tfShow.text = cfg.show;
			item.btn.rollOver = function() self:OnItemBtnRollOver(i,item.btn); end
			item.btn.rollOut = function() self:OnItemBtnRollOut(i); end
		end
	end
end

function UIFriendIntimacy:OnItemBtnRollOver(id,button)
	local cfg = t_intimacy[id];
	if not cfg then return; end
	local str = string.format(StrConfig["friend202"],cfg.exp,cfg.gold);
	TipsManager:ShowBtnTips(str,TipsConsts.Dir_RightDown);
end

function UIFriendIntimacy:OnItemBtnRollOut(id)
	TipsManager:Hide();
end

function UIFriendIntimacy:OnBtnCloseClick()
	self:Hide();
end
