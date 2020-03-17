--[[
寄售行工具
wangsuai
]]

_G.ConsignmentUtils = {}

ConsignmentUtils.onePage = 7;
-- 得到当前页数下的itemlist
function ConsignmentUtils:GetListPage(list,page)
	local vo = {};
	page = page + 1;
	for i=(self.onePage*page)-self.onePage+1,(self.onePage*page) do 
		table.push(vo,list[i])
	end;
	return vo
end;

function ConsignmentUtils:GetListLenght(list)
	local lenght = #list/self.onePage;
	return math.ceil(lenght)-1;
end;


function ConsignmentUtils:GetCurIdCfg(id)
	if t_equip[id] then 
		return t_equip[id]
	elseif t_item[id] then 
		return t_item[id]
	end;
	return 
end;

function ConsignmentUtils:GetMoneyTypeNum(type)
	if enAttrType.eaUnBindGold == type then 
		return MainPlayerModel.humanDetailInfo.eaUnBindGold;
	elseif enAttrType.eaUnBindMoney == type then 
		return MainPlayerModel.humanDetailInfo.eaUnBindMoney;
	end;
end;

function ConsignmentUtils:GetCreateInfo()
	local onelist = {};
	local twolist = {};
	local threelist = {};
	local fourlist = {};
	local fivelist = {};
	local sixlist = {};
	local sevenlist = {};
	local eightlist = {};
	local oneLen = ConsignmentConsts.layerOnelengh;
	for one=1,oneLen do 
		local vo = {};
		vo.name = StrConfig["consignment" .. (100 + one)]
		vo.id = one
		onelist[one] = vo;
	end;


	local fourLen = ConsignmentConsts.layerDaoJulengh;
	for four=1,fourLen do 
		local fourvo = {};
		fourvo.name = StrConfig["consignment20"..four];
		fourvo.id = 200 + four;
		fourlist[four] = fourvo
	end;

	local sevenLen = ConsignmentConsts.layerFabaolengh;
	for seven=1,sevenLen do 
		local sevenvo = {};
		sevenvo.name = StrConfig["consignment50"..seven];
		sevenvo.id = 200 + seven;
		sevenlist[seven] = sevenvo
	end;
	
	local eightLen = ConsignmentConsts.layerEquiplengh;
	for eight=1,eightLen do 
		local eightvo = {};
		eightvo.name = StrConfig["consignment"..(300+eight)];
		eightvo.id = 200 + eight;
		eightlist[eight] = eightvo
	end;
	return onelist,fourlist,sevenlist,eightlist;
end;

function ConsignmentUtils:GetBuyItemUIdata(info,bo)
	local str = "";
	local cfg = ConsignmentUtils:GetCurIdCfg(info.id)
	if not cfg then 
		print(debug.traceback(),info.id);
		return 
	end;
	-- local num = math.random(5)
	-- if num % 2 == 0 then 
	-- 	info.id = 110600100
	-- end;
	local isBig = false;
	local voc = {};
	voc.hasItem = true;
	voc.iconUrl = BagUtil:GetItemIcon(info.id,isBig);
	if t_equip[info.id] then 
		voc.qualityUrl = ResUtil:GetSlotQuality(t_equip[info.id].quality);
		voc.quality = t_equip[info.id].quality;
		voc.strenLvl = info.strenLvl
		voc.super = 0;
		if voc.quality == BagConsts.Quality_Green2 then
			voc.super = 2;
		elseif voc.quality == BagConsts.Quality_Green3 then
			voc.super = 3;
		end
	elseif t_item[info.id] then 
		voc.qualityUrl = ResUtil:GetSlotQuality(t_item[info.id].quality);
		voc.quality = t_item[info.id].quality;
		voc.count = info.num;
	end;
	if bo then 
		return UIData.encode(voc)
	end;

	local vo ={};
	local nameColor = TipsConsts:GetItemQualityColor(cfg.quality)
	-- vo.itemName =  "<font color='"..nameColor.. "'>"..cfg.name.. "</font>";
	vo.itemName =  cfg.name;
	vo.itemLvl = cfg.level;
	vo.itemNum = info.num;
	vo.roleName = info.roleName;
	vo.price = math.floor(info.price/info.num);
	vo.allPrice = getNumShow(info.price);
	vo.uid = info.uid;
	vo.id = cfg.id;
	vo.moneyImg = ResUtil:GetMoneyIconURL(12)
	local t,s,f,m = CTimeFormat:sec2formatEx(info.lastTime)	
	vo.lasttime = string.format(StrConfig['consignment002'],t,s,f) 
	return UIData.encode(voc) .."*".. UIData.encode(vo);

end;

-- get 收益 UIData
function ConsignmentUtils:GetEarnUIData(info)
	if not info then return end;
	local cfg = ConsignmentUtils:GetCurIdCfg(info.id)
	if not cfg then return end;
	local vo = {};
	local nameColor = TipsConsts:GetItemQualityColor(cfg.quality)
	-- vo.itemName =  "<font color='"..nameColor.. "'>"..cfg.name.. "</font>";
	vo.itemName =  cfg.name;
	vo.itemNum = info.num;
	vo.endTrad = CTimeFormat:todate(info.lastTime);
	vo.buyRole = info.roleName;
	vo.price = getNumShow(info.monet);
	vo.moneyImg = ResUtil:GetMoneyIconURL(12);
	return UIData.encode(vo);
end;

-- 排序
function ConsignmentUtils:SetListSort(boolean)
	local list = ConsignmentModel:GetBuyItenInfo();
	if boolean then 
		table.sort(list,function(A,B)
			if A.price > B.price then
				return true;
			else
				return false;
			end
		end);
	else
		table.sort(list,function(A,B)
			if A.price < B.price then
				return true;
			else
				return false;
			end
		end);
	end;
	ConsignmentModel.BuyItemlist = list
end;

--获取格子VO
function ConsignmentUtils:GetSlotVO(item,isBig,index)
	local vo = {};
	vo.hasItem = true;
	vo.myindex = index or 0;
	vo.pos = item:GetPos();
	vo.isBig = isBig and true or false;
	if t_equip[item:GetTid()] then 
		EquipUtil:GetDataToEquipUIVO(vo,item,isBig);
	elseif t_item[item:GetTid()] then 
		vo.qualityUrl = ResUtil:GetSlotQuality(t_item[item:GetTid()].quality);
		vo.quality = t_item[item:GetTid()].quality;
		vo.count = item:GetCount();
		vo.iconUrl = BagUtil:GetItemIcon(item:GetTid());
	end;
	return vo;
end
