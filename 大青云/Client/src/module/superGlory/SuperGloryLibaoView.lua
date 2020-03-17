--[[
 守城礼包展示
 wangshuai
]]

_G.UISuperGloryLibao = BaseUI:new("UISuperGloryLibao")


function UISuperGloryLibao:Create()
	self:AddSWF("superGloryLibaoPanel.swf",true,nil)
end;

function UISuperGloryLibao:OnLoaded(objSwf)
	objSwf.close_btn.click = function() self:Hide()end;

	objSwf.list.itemRollOver = function(e) self:OnItemOver(e)end;
	objSwf.list.itemRollOut  = function() TipsManager:Hide()end;
end;

function UISuperGloryLibao:OnShow()
	self:SetUIData();
end;

function UISuperGloryLibao:OnHide()

end;

function UISuperGloryLibao:OnItemOver(e)
	local vo = RewardSlotVO:new();
	vo.id = e.item.id;
	local tips = vo:GetTipsInfo();
	TipsManager:ShowTips(tips.tipsType,tips.info,tips.tipsShowType,TipsConsts.Dir_RightDown)
end;

function UISuperGloryLibao:SetUIData()
	local objSwf = self.objSwf;
	objSwf.scrollbar.position  = 0;
	local voc = SuperGloryModel:GetAllSuperInfo();
	if voc.cont then 
		objSwf.lianzhan.num = voc.cont .."d";--
	end;

	local tabl = t_guildwangchengextra;
	local list = {};
	for i,info in ipairs(tabl) do 
		local vo = RewardSlotVO:new();
		local desc = split(info.reward,",");
		vo.id = toint(desc[1]);
		vo.cont = toint(desc[2]);
		local data = {};   
		data.desc = string.format(StrConfig["SuperGlory828"],i) ;
		data.num = toint(desc[2])
		local uidata = vo:GetUIData() .."*"..UIData.encode(data);
		table.push(list,uidata)
	end;

	objSwf.list.dataProvider:cleanUp();
	objSwf.list.dataProvider:push(unpack(list));
	objSwf.list:invalidateData();
end;