--[[
掉落查看面板
2014年12月17日15:46:55
郝户
]]

_G.UITargetDropInfoDetail = BaseUI:new("UITargetDropInfoDetail");

function UITargetDropInfoDetail:Create()
	self:AddSWF("targetDropInfoDetail.swf", true, "highTop");
end

function UITargetDropInfoDetail:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:Hide(); end
	RewardManager:RegisterListTips( objSwf.list );

	objSwf.txtPrompt.text = StrConfig["mainmenuDropInfo001"];
end

function UITargetDropInfoDetail:OnShow()
	-- self:UpdateShow();
	self:UpdatePos();
end

function UITargetDropInfoDetail:OnResize(nWidth,nHeight)
	self:UpdatePos();
end

-- function UITargetDropInfoDetail:UpdateShow()
-- 	local objSwf = self.objSwf;
-- 	if not objSwf then return; end
-- 	local monsterId = self.monsterId;
-- 	if not monsterId then return end
-- 	local monsterCfg = t_monster[monsterId];
-- 	if not monsterCfg then return end
-- 	-- 判断境界是否足够查看
-- 	local realmEnough = TargetUtils:GetRealmEnough( monsterId )
-- 	local list = objSwf.list;
-- 	list.dataProvider:cleanUp();
-- 	if realmEnough then
-- 		local dropItemStr = monsterCfg.drop_items;
-- 		local dropItemList = RewardManager:Parse( dropItemStr );
-- 		list.dataProvider:push( unpack(dropItemList) );
-- 	end
-- 	list:invalidateData();
-- 	objSwf.txtPrompt._visible = not realmEnough;
-- end

function UITargetDropInfoDetail:UpdatePos()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local target = self.target;
	if not target then return end
	local pos = UIManager:PosLtoG( target );
	objSwf._x = pos.x + 60;
	objSwf._y = pos.y;
end


----------------------------------------------处理消息------------------------------------------

function UITargetDropInfoDetail:Open( monsterId, target )
	if self:IsShow() then
		if self.monsterId ~= monsterId then
			self.monsterId = monsterId;
			self.target = target;
			-- self:UpdateShow();
			self:UpdatePos();
			return
		end
	end
	self.monsterId = monsterId;
	self.target = target;
	UITargetDropInfoDetail:Show();
end