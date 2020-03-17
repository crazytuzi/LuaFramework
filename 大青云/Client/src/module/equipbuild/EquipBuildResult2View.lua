--[[
装备打造单间装备展示
wangshuai
]]

_G.UIEquipBuildResultTwo = BaseUI:new("UIEquipBuildResultTwo")
UIEquipBuildResultTwo.curItemdata = nil;
UIEquipBuildResultTwo.tipsVO = nil;
function UIEquipBuildResultTwo:Create()
	self:AddSWF("equipBuildResultPanel2.swf",true,"center")
end;

function UIEquipBuildResultTwo:OnLoaded(objSwf)
	objSwf.closeBtn.click = function () self:Hide()end;
	objSwf.zhuangbei.click = function() self:OnZhuangBeiClick()end;
	objSwf.close.click =function() self:Hide()end;

	objSwf.item.rollOver = function() self:OnitemOver()end;
	objSwf.item.rollOut  = function() TipsManager:Hide()end;
end;

function UIEquipBuildResultTwo:OnShow()
	self:SetCurItemData()
end;

function UIEquipBuildResultTwo:OnHide()

end;

function UIEquipBuildResultTwo:SetData()
	self.curItemdata = EquipBuildModel.ResultDataList[1]
	self:Show()
end;


function UIEquipBuildResultTwo:SetCurItemData()
	local objSwf = self.objSwf;
	local itemdata = self.curItemdata
	local cfg = t_equip[itemdata.cid]
	if not cfg then 
		print("ERROR: cur item ID is error",itemdata.cid)
	return end;

	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(itemdata.cid,1,1);
	itemTipsVO.superVO = {};
	itemTipsVO.superVO.superList = itemdata.superList;
	itemTipsVO.superVO.superNum = itemdata.superNum;
	itemTipsVO.newSuperList = itemdata.newSuperList;
	itemTipsVO.extraLvl = itemdata.extraLvl
	itemTipsVO.groupId = itemdata.groupId;
	itemTipsVO.groupId2 = itemdata.groupId2;
	itemTipsVO.groupId2Level = itemdata.groupId2Level;
	itemTipsVO.bindState = itemdata.bind == 1 and  BagConsts.Bind_Bind or BagConsts.Bind_None;
	self.tipsVO = itemTipsVO;
	--  装备评分
	objSwf.fightNum.num = itemTipsVO:GetFight();

	-- trace(itemTipsVO:GetNewSuperAttr())

	-- trace(itemTipsVO:GetSuperAttr())

	-- setitem
	local itemvo = RewardSlotVO:new();
	itemvo.id = itemdata.cid;
	itemvo.bind = itemdata.bind == 1 and  BagConsts.Bind_Bind or BagConsts.Bind_None;
	objSwf.item:setData(itemvo:GetUIData())

	-- set atb
	local jichuatb = AttrParseUtil:Parse(cfg.baseAttr)
	local jichuatbtxt = '';
	for i,info in pairs(jichuatb) do 
		local name = enAttrTypeName[info.type];
		jichuatbtxt = jichuatbtxt .. "<font color='#29cc00'>"..name.."  </font><font color='#29cc00'>+"..info.val.."</font>";
	end;
	objSwf.jichu.htmlText = jichuatbtxt;

	-- set卓越
	local vipstr = self:GetNewSuperAttr();
	if vipstr and vipstr == "" then 
		objSwf.zhuoyue._visible = false;
		objSwf.vip_mc._visible = true;
	elseif vipstr then 
		objSwf.zhuoyue.htmlText = vipstr
		objSwf.vip_mc._visible = false;
		objSwf.zhuoyue._visible = true
	end;

	objSwf.fujia.htmlText = self:GetSuperAttr();

end;

function UIEquipBuildResultTwo:OnitemOver()
	local cfg = self.curItemdata
	local objSwf = self.objSwf;
	local itemTipsVO = ItemTipsUtil:GetItemTipsVO(cfg.cid,1,1);
	if not itemTipsVO then return; end
	itemTipsVO.superVO = {};
	itemTipsVO.superVO.superList = cfg.superList;
	itemTipsVO.superVO.superNum = cfg.superNum;
	itemTipsVO.newSuperList = cfg.newSuperList;
	itemTipsVO.extraLvl = cfg.extraLvl
	itemTipsVO.groupId = cfg.groupId;
	itemTipsVO.groupId2 = cfg.groupId2;
	itemTipsVO.groupId2Level = cfg.groupId2Level;
	itemTipsVO.bindState = cfg.bind == 1 and  BagConsts.Bind_Bind or BagConsts.Bind_UseUnBind;
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end;


function UIEquipBuildResultTwo:OnZhuangBeiClick()
	FuncManager:OpenFunc(FuncConsts.Bag)
	self:Hide();
end;


--新卓越属性
function UIEquipBuildResultTwo:GetNewSuperAttr()
	-- --显示随机新卓越属性
	-- if not self.tipsVO.newSuperList then
	-- 	if not self.tipsVO.newSuperDefStr or self.tipsVO.newSuperDefStr=="" then
	-- 		return "";
	-- 	end
	-- 	local defStr = string.format("随机获得%s条卓越属性",self.tipsVO.newSuperDefStr);
	-- 	local str = "";
	-- 	str = str .. "<textformat leading='-16' leftmargin='6'><p>";
	-- 	str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	-- 	str = str .. "</p></textformat>";
	-- 	str = str .. "<textformat leftmargin='28'><p>";
	-- 	str = str .. self:GetHtmlText(defStr,TipsConsts.NewSuperColor,TipsConsts.Default_Size,false);
	-- 	str = str .. "</p></textformat>";
	-- 	if self.tipsVO.newSuperDetailStr and self.tipsVO.newSuperDetailStr~="" then
	-- 		str = str .. self:GetVGap(5);
	-- 		str = str .. "<textformat leftmargin='28'><p>";
	-- 		str = str .. self:GetHtmlText(self.tipsVO.newSuperDetailStr,TipsConsts.NewSuperColor,TipsConsts.Default_Size,false);
	-- 		str = str .. "</p></textformat>";
	-- 	end
	-- 	return str;
	-- end
	-- --
	local hasNewSuper = false;
	if self.tipsVO.newSuperList then
		for i,vo in ipairs(self.tipsVO.newSuperList) do
			if vo.id > 0 then
				hasNewSuper = true;
				break;
			end
		end
	end
	if not hasNewSuper then
		return "";
	end
	--
	local str = "";
	for i,vo in ipairs(self.tipsVO.newSuperList) do
		if vo.id > 0 then
			local cfg = t_zhuoyueshuxing[vo.id];
			local attrStr = "";
			attrStr = attrStr .. "<textformat leading='4' leftmargin='0'><p>";
			attrStr = attrStr .. "卓越 （";
			attrStr = attrStr .. formatAttrStr(cfg.attrType,cfg.val);
			attrStr = attrStr .. "）";
			attrStr = attrStr .. "</p></textformat>";
			str = str .. self:GetHtmlText(attrStr,"#29cc00",TipsConsts.Default_Size,false);
		end
	end
	return str;
end

function UIEquipBuildResultTwo:GetHtmlText(text,color,size,withBr,bold)
	if not color then color = TipsConsts.Default_Color; end
	if not size then size = TipsConsts.Default_Size; end
	if withBr==nil then withBr = true; end
	if bold==nil then bold = false; end
	local str = "<font color='" .. color .."' size='" .. size .. "'>";
	if bold then
		str = str .. "<b>" .. text .. "</b>";
	else
		str = str .. text;
	end
	str = str .. "</font>";
	if withBr then
		str = str .. "<br/>";
	end
	return str;
end



--卓越属性
function UIEquipBuildResultTwo:GetSuperAttr()
	-- --显示随机卓越属性
	-- if not self.tipsVO.superVO then
	-- 	if not self.tipsVO.superDefStr or self.tipsVO.superDefStr=="" then
	-- 		return "";
	-- 	end
	-- 	local defSuperStr = string.format("随机获得%s条附加属性",self.tipsVO.superDefStr);
	-- 	local str = "";
	-- 	str = str .. "<textformat leading='-16' leftmargin='6'><p>";
	-- 	str = str .. "<img width='13' height='16' src='" .. ResUtil:GetTipsFlagUrl() .. "'/>";
	-- 	str = str .. "</p></textformat>";
	-- 	str = str .. "<textformat leftmargin='28'><p>"; 
	-- 	str = str .. self:GetHtmlText(defSuperStr,TipsConsts.SuperColor,TipsConsts.Default_Size,false) .. "</p></textformat>";
	-- 	if self.tipsVO.superDetailStr and self.tipsVO.superDetailStr~="" then
	-- 		str = str .. self:GetVGap(5);
	-- 		str = str .. "<textformat leftmargin='28'><p>";
	-- 		str = str .. self:GetHtmlText(self.tipsVO.superDetailStr,TipsConsts.SuperColor,TipsConsts.Default_Size,false);
	-- 		str = str .. "</p></textformat>";
	-- 	end
	-- 	return str;
	-- end
	-- --
	if self.tipsVO.superVO.superNum == 0 then
		return "";
	end
	--
	local str = "";
	for i=1,self.tipsVO.superVO.superNum do
		local vo = self.tipsVO.superVO.superList[i];
		if vo.id == 0 then
			str = str .. "<textformat leading='7' leftmargin='0'><p>";
			str = str .. self:GetHtmlText("「空槽」 可附加 （通过打造-附加进行操作）","#5a5a5a",TipsConsts.Default_Size,false);
			str = str .. "</p></textformat>"; 
		else
			local cfg = t_fujiashuxing[vo.id];
			local attrStr = "";
			attrStr = attrStr .. "<textformat leading='4' leftmargin='0'><p>";
			attrStr = attrStr .. string.format("「%s」",cfg.name);
			attrStr = attrStr .. formatAttrStr(cfg.attrType,vo.val1);
			attrStr = attrStr .. "</p></textformat>";
			str = str .. self:GetHtmlText(attrStr,TipsConsts.SuperColor,TipsConsts.Default_Size,false);
		end
	end
	return str;
end



