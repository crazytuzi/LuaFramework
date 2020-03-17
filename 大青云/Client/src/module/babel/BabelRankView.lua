--[[
	2015年1月23日, PM 04:53:03
	通天塔排行榜
	wangyanwei 
]]

_G.UIBabelRank = BaseUI:new('UIBabelRank');

function UIBabelRank:Create()
	self:AddSWF("babelRanking.swf",true,nil);
end

function UIBabelRank:OnLoaded(objSwf,name)
	objSwf.btn_close.click = function() self:Hide(); end
end

function UIBabelRank:OnShow()
	self:OnChangeRankList();
end

function UIBabelRank:OnChangeRankList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.listPlayer.dataProvider:cleanUp();
	local list = BabelModel.rankListInfo;
	for i = 1 , 3 do
		objSwf['txt_name' .. i].htmlText = list[i].name;
		objSwf['txt_layer' .. i].htmlText = string.format(StrConfig['babel008'],list[i].tier);
		objSwf['txt_name' .. i]._visible = (list[i].tier ~= 0);
		objSwf['txt_layer' .. i]._visible = (list[i].tier ~= 0);
	end
	if list == {} then return end
	for i , v in ipairs(list)  do
		if i > 3 then
			local vo = {};
			vo.rank = i;
			
			vo.playerLevel = v.level;
			-- vo.layer = string.format(StrConfig['babel008'],v.tier);
			vo.playerName = v.name..' '..string.format(StrConfig['babel008'],v.tier);
			objSwf.listPlayer.dataProvider:push(UIData.encode(vo));
		end
	end
	objSwf.listPlayer:invalidateData();
end

function UIBabelRank:OnHide()
	
end
