--[[
UI:怪物掉落信息
郝户
2014年10月31日11:42:31
]]

_G.UITargetDropInfo = BaseUI:new("UITargetDropInfo");

UITargetDropInfo.target = nil;

function UITargetDropInfo:Create()
	self:AddSWF( "targetDropInfo.swf", true, "float" );
end

function UITargetDropInfo:OnLoaded(objSwf)
	objSwf.txtTitle.text = StrConfig["mainmenuDropInfo002"];
	objSwf.txtPrompt.text = StrConfig["mainmenuDropInfo003"];
end

function UITargetDropInfo:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end;
	local monsterId = TargetModel:GetId();
	local monsterCfg = t_monster[monsterId];
	if not monsterCfg then return; end
	--掉落类型文本
	local dropTypeStrList = split( monsterCfg.drop_type, "#" );
	local dropTypeList = {};
	for _, dropTypeStr in pairs(dropTypeStrList) do
		local dropType = tonumber(dropTypeStr);
		table.push( dropTypeList, TargetUtils:GetDropTypeName(dropType) );
	end
	objSwf.txtDropType.text = table.concat( dropTypeList, "、" );
	--掉落物品
	local list = objSwf.list;
	list.dataProvider:cleanUp();
	-- if TargetUtils:GetRealmEnough( monsterId ) then -- 判断境界是否足够查看怪物掉落
	-- 	local dropItemStr = monsterCfg.drop_items;
	-- 	local dropItemList = RewardManager:Parse( dropItemStr );
	-- 	list.dataProvider:push( unpack(dropItemList) );
	-- end
	list:invalidateData();
	-- 更新位置
	local tipsX, tipsY = TipsUtils:GetTipsPos( self:GetWidth(), self:GetHeight(), TipsConsts.Dir_RightDown, self.target );
	objSwf._x = tipsX;
	objSwf._y = tipsY;
end

function UITargetDropInfo:Open( target )
	self.target = target;
	self:Show();
end