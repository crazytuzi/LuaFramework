--[[
宝石系统
WangShuai
2014年12月1日14:31:30
]]

_G.UIEquipGem = BaseUI:new("UIEquipGem");

UIEquipGem.autoBuyItems = false; -- 是否自动购买物品
UIEquipGem.curEquipPos = 0;  -- 当前装备位pos
UIEquipGem.curItmeVo = nil; -- 当前点击宝石
UIEquipGem.curRenderIndex = -1; -- 当前下标
UIEquipGem.linkBtns = {};

function UIEquipGem : Create ()
	self:AddSWF("equipgemPanell.swf",true,nil);
end;

function UIEquipGem : OnLoaded(objSwf)

	--设置模型不接受事件
	objSwf.roleLoaderGem.hitTestDisable = true;

	-- 规则提示
	--objSwf.rulesbtn.txt.textField.htmlText = string.format(UIStrConfig['euipgem106']);
	objSwf.rulesbtn.rollOver = function () TipsManager:ShowBtnTips(StrConfig['equip301'],TipsConsts.Dir_RightDown);end;
	objSwf.rulesbtn.rollOut = function () TipsManager:Hide() end;
	-- levelupBtn
	objSwf.btnGoUp.click = function () self:OnGoUpClick()end;
	objSwf.btnGoUp.rollOver = function ()self:OnGoUpOver()end;
	objSwf.btnGoUp.rollOut = function () self:OnGoUpOut()end;
	-- list
	objSwf.gemlist.itemClick = function (e) self:GemItemClick(e) end;
	objSwf.gemlist.itemRollOver = function (e) self:OnGemListOver(e)end;
	objSwf.gemlist.itemRollOut = function () TipsManager:Hide() end;

	objSwf.rolelist.itemClick = function (e) self:RoleItemClick(e) end;
	objSwf.rolelist.itemRollOver = function (e) self:OnShowGemList(e)end;
	objSwf.rolelist.itemRollOut = function () UIEquipGemTips:Hide();end;
	-- AutoBuy
	objSwf.selectAutoBuy.click = function () self:AutoBuyClick() end;
	
	-- gemAttributeClick 
	objSwf.gemAtBtn.rollOver = function () self:GemAttrBtnClick() end;
	objSwf.gemAtBtn.rollOut = function () TipsManager:Hide() end;

	-- tips 
	objSwf.curProps.click = function() self:CurPropsClick()end;
	objSwf.curProps_btn.rollOver = function() self:TipsCurProps()end;
	objSwf.curProps_btn.rollOut = function() TipsManager:Hide()end;
 

	objSwf.money_btn.rollOver = function() 
										TipsManager:ShowBtnTips(StrConfig['tips50'],TipsConsts.Dir_RightDown);
										end
	objSwf.money_btn.rollOut = function() TipsManager:Hide(); end
end;

function UIEquipGem:OnDelete()
	for k,_ in pairs(self.linkBtns) do
		if self.linkBtns[k] then self.linkBtns[k]:removeMovieClip(); end
		self.linkBtns[k] = nil;
	end
	if self.objUIDraw then 
		self.objUIDraw:SetUILoader(nil);
	end;
end

function UIEquipGem:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	if self.objUIDraw then
		self.objUIDraw:SetDraw(false);
		self.objUIDraw:SetMesh(nil);
	end
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;
	end
	for k,_ in pairs(self.linkBtns) do
		if self.linkBtns[k] then self.linkBtns[k]:removeMovieClip(); end
		self.linkBtns[k] = nil;
	end
end;

function UIEquipGem : CurPropsClick()
	if not self.curItemVo then return end;
	local lvl = self.curItemVo.leveltxt;
	local cfg = t_gemcost[lvl+1];
	if not cfg then return end;
	local itemNum = BagModel:GetItemNumInBag(cfg.item) 
	-- UIShopQuickBuy:Open( cfg.item, UIEquip,UIEquip:GetShopContainer(),cfg.num-itemNum);
end;
--tips
function UIEquipGem : TipsCurProps()
	if not self.curItemVo then return end;
	local lvl = self.curItemVo.leveltxt;
	local cfg = t_gemcost[lvl+1];
	if not cfg then return; end

	if cfg.direct_item > 0 then 
		local NbItemNum = BagModel:GetItemNumInBag(cfg.direct_item);
		if NbItemNum >= cfg.direct_num then 
			TipsManager:ShowItemTips(cfg.direct_item);
			return 
		end;
	end;
	TipsManager:ShowItemTips(cfg.item);
end;
--装备位宝石总Tips 预览
function UIEquipGem : OnShowGemList(e)
	UIEquipGemTips : Setdata(e.item.pos)
end;
function UIEquipGem : OnShow()
	self:Init();
	self:GemRoleItemList();
	self:Setcuritem()
	self:SetGemInfo()  --宝石info@
	self:SetCueIndex()
	self:ShowGemLink(); -- 宝石星级
	self:DrawRole();

end
function UIEquipGem : Init()
	local objSwf = self.objSwf
	self.autoBuyItems = false;
	objSwf.selectAutoBuy.selected = self.autoBuyItems;
	self.curRenderIndex = -1;
	self.curEquipPos = 0
	self.objSwf.rolelist.selectedIndex = 0;
	objSwf.MaxLvltip._visible = false;
	objSwf.gemlist.selectedIndex = self.curRenderIndex;
	objSwf.gemlist.dataProvider:cleanUp();
	objSwf.gemlist.dataProvider:push(unpack({}));
	objSwf.gemlist:invalidateData();
end;
function UIEquipGem : GemRoleItemList()
	local objSwf = self.objSwf;
	local list = {}

	for i,info in pairs(t_equipgem) do
		local vo = {};
		vo.iconUrl = ResUtil:GetEquipPosUrl(info.pos)
		vo.pos = i;
		vo.desc = 0;
		local currlist = EquipModel:GetGemAtPos(info.pos); -- 当前
		for ca,ou in pairs(currlist) do 
			vo.desc = vo.desc + ou.lvl;
		end;	
		--print(vo.desc)
		vo.posName = BagConsts:GetEquipName(i);
		table.push(list,UIData.encode(vo));
	end;
	objSwf.rolelist.dataProvider:cleanUp();
	objSwf.rolelist.dataProvider:push(unpack(list));
	objSwf.rolelist:invalidateData();

end;

-- 预览下一等级加成 -- - 
function UIEquipGem : OnGemListOver(e)
	local id = e.item.id;
	local sinfo = EquipModel:GetGemServerinfo(id)
	if not self.curEquipPos then return end;

	--- 当前有宝石
	if sinfo then  
		if sinfo.lvl+1 >= 10 then return end;
		local nextlvl = sinfo.lvl + 1;
		local cof = self:GetGemConfig(id);
		local atbname = self:GetAtbName(cof.atr);
		local val = cof["atr"..nextlvl];
		local vipAdd = VipController:GetBaoshishuxingUp() / 100;
		local a = toint(val + (val * vipAdd),-1)
		TipsManager:ShowBtnTips(string.format(StrConfig["equip306"],atbname,a),TipsConsts.Dir_RightDown);
	end;

	--  当前可以升级
	if e.item.open then 
		local nextlvl = e.item.leveltxt+1;
		local cof = self:GetGemConfig(id);
		local atbname = self:GetAtbName(cof.atr);
		local val = cof["atr"..nextlvl];	
		local vipAdd = VipController:GetBaoshishuxingUp() / 100;
		local a = toint(val + (val * vipAdd),-1)
		TipsManager:ShowBtnTips(string.format(StrConfig["equip306"],atbname,a),TipsConsts.Dir_RightDown);
	end;
end;
function UIEquipGem : OnGoUpOver()
	local objSwf = self.objSwf;
	local item = self.curItemVo; -- 得到当前点击的Item
	if not item then return end; 
	local cfg = self:GetGemConfig(item.id);
	local nextlvl = item.leveltxt + 1;
	if nextlvl > 10 then return end;
	if item.leveltxt <= 0 then return end;

	--local lastvoc = EquipModel:GetGemServerinfo(lastvo.id);
	--lastvo.atbtxt = string.format(StrConfig["equip302"],enAttrTypeName[lastvoc.atbname],lastvoc.atbval);


	local vipAdd = VipController:GetBaoshishuxingUp() / 100;
	local atbcc = ((cfg["atr"..nextlvl]-cfg["atr"..item.leveltxt]) * vipAdd) + (cfg["atr"..nextlvl]-cfg["atr"..item.leveltxt])
	local atb = cfg["atr"..item.leveltxt] * vipAdd + cfg["atr"..item.leveltxt];
	local a = math.floor(atbcc)
	local c = math.floor(atb)
	local vo = {};
	vo.id = item.id;
	vo.leveltxt = item.leveltxt;
	vo.atbtxtccc = string.format(StrConfig["equip302"],enAttrTypeName[AttrParseUtil.AttMap[cfg.atr]],a) --  达到多少级开启， 
	vo.atbtxt = string.format(StrConfig["equip302"],enAttrTypeName[AttrParseUtil.AttMap[cfg.atr]],c) --  达到多少级开启， 
	vo.gstate = false;
	vo.iconUrl = ResUtil:GetEquipGemIconUrl(cfg.icon,item.leveltxt,"54")  --  得到当前等级宝石的路径

	local uiData = UIData.encode(vo);
	objSwf.gemlist.dataProvider[self.curRenderIndex] = uiData;
	local uiItem = objSwf.gemlist:getRendererAt(self.curRenderIndex)
	if uiItem then 
		uiItem:setData(uiData);
	end;
end;
function UIEquipGem : OnGoUpOut()
	local objSwf = self.objSwf;
	local lastvo = self.curItemVo;
	
	if not lastvo then return end;
	local cfg = self:GetGemConfig(lastvo.id);
	local lastvoc = EquipModel:GetGemServerinfo(lastvo.id);
	if lastvoc then 
		local vipAdd = VipController:GetBaoshishuxingUp() / 100;
		local atb = cfg["atr"..lastvoc.lvl] * vipAdd + cfg["atr"..lastvoc.lvl];
		local c = math.floor(atb)
		lastvo.atbtxt = string.format(StrConfig["equip302"],enAttrTypeName[lastvoc.atbname],c);
	end;
	local vo = {};
	vo.id = lastvo.id;
	vo.open = lastvo.open;
	vo.leveltxt = lastvo.leveltxt
	vo.atbtxt = lastvo.atbtxt
	vo.gstate = lastvo.gstate;
	if lastvo.leveltxt == 0 then 
		vo.iconUrl = "";
	else
		vo.iconUrl =  ResUtil:GetEquipGemIconUrl(cfg.icon,lastvo.leveltxt,"54")  --  得到当前等级宝石的路径 lastvo.iconUrl
	end;
	

	local uiData = UIData.encode(vo);
	objSwf.gemlist.dataProvider[self.curRenderIndex] = uiData;
	local uiItem = objSwf.gemlist:getRendererAt(self.curRenderIndex)
	if uiItem then 
		uiItem:setData(uiData);
	end;

end;
---------------------click-----------------
-- 升级Click
function UIEquipGem : OnGoUpClick()
	if not self.curItemVo then 
		FloatManager:AddNormal(string.format(StrConfig['equip308']));
	return end;
 	local money = MainPlayerModel.humanDetailInfo.eeaBindGold
	local reallyMoney = MainPlayerModel.humanDetailInfo.eeaUnBindMoney
	local item = self.curItemVo;
	-- 需要金币 。元宝
	local curCons = self:GetCurMoney(item.leveltxt);
	EquipController:OnGemGoUpLevel(item.id,self.autoBuyItems)
end;
-- 宝石itemclick 
function UIEquipGem : GemItemClick(e)
	local objSwf = self.objSwf;
	if not self.curEquipPos then
		FloatManager:AddNormal(string.format(StrConfig['equip228']));
		objSwf.gemlist.selectedIndex = -1;
		return 
	end;
	
	self:SetCueIndex(e)
end;

function UIEquipGem : SetCueIndex(e)
	local objSwf = self.objSwf
	local item = nil;
	local num = 0;

	if not e then
		local uiItem = self.objSwf.gemlist:getRendererAt(num);
		if uiItem.data.open == false then 
			num = 0;
			uiItem = self.objSwf.gemlist:getRendererAt(num);
		end;
		if uiItem.data.leveltxt == 10 then 
			num = num+ 1;
			local a = self.objSwf.gemlist:getRendererAt(num);
			if a.data.open == false then 
				num = 0;
				uiItem = self.objSwf.gemlist:getRendererAt(num);
			end;
			if a.data.leveltxt == 10 then 
				 num = num +1 ;
				 local  b = self.objSwf.gemlist:getRendererAt(num);
				 if b.data.open == false then 
					num = 0;
					uiItem = self.objSwf.gemlist:getRendererAt(num);
				end;
				if b.data.leveltxt == 10 then 
				 	num = 0
				 	uiItem = self.objSwf.gemlist:getRendererAt(num);
				 elseif b.data.leveltxt > 0 then
				 	uiItem = b;
				 end;
			elseif a.data.leveltxt > 0 then 
				 uiItem = a;
			end;

		end;

		uiItem =  self.objSwf.gemlist:getRendererAt(num);
		item = uiItem.data
		objSwf.gemlist.selectedIndex = num;
		self.curRenderIndex = num;
	else
		item = e.item;
	end;

	if item.gstate == true then 
		if item.open and item.open == true then	
			-- 坑位打开判断
			objSwf.btnGoUp.textField.text = string.format(StrConfig["equip317"])
		else
			-- print("没宝石判断,坑位也没打开")
			-- 如果当前item未开启，不可点击
			objSwf.gemlist.selectedIndex = self.curRenderIndex;
			return ;
		end;
	else
		objSwf.btnGoUp.textField.text = string.format(StrConfig["equip316"])
	end;

	if tonumber(item.leveltxt) >= 10 then  
		-- print('大于10级')
		objSwf.btnGoUp.disabled = true;
		objSwf.MaxLvltip._visible = true;
		objSwf.txt1._visible = false;
		objSwf.txt2._visible = false;
		objSwf.curProps._visible = false;
		objSwf.money._visible = false;
		return 
		else
		objSwf.btnGoUp.disabled = false;
		objSwf.MaxLvltip._visible = false;
		objSwf.txt1._visible = true;
		objSwf.txt2._visible = true;
		objSwf.curProps._visible = true;
		objSwf.money._visible = true;
	end;
	if item.open  and item.open == true then 
		-- print("坑位打开判断")
		local cof = self:GetCurMoney(item.leveltxt+1)
		self:Settext(cof) 
		local inc = 0;
		if not e then
			--inc = 0;
			inc = self.curRenderIndex
		else
			inc = e.index;
		end;
		self.curRenderIndex = inc;
		local vo = {};
		vo.id = item.id;
		vo.open = item.open;
		vo.leveltxt = item.leveltxt;
		vo.atbtxt = item.atbtxt;
		vo.gstate = item.gstate;
		vo.iconUrl = item.iconUrl;

		self.curItemVo = vo;
		self.curRenderIndex = inc;
		return ;
	end;
	

	local vo = {};
	vo.id = item.id;
	vo.leveltxt = item.leveltxt;
	vo.atbtxt = item.atbtxt;
	vo.gstate = item.gstate;
	vo.iconUrl = item.iconUrl;

	self.curItemVo = vo;
	local inc = 0;
	if not e then 
		--inc = 0;
		inc = self.curRenderIndex
	else
		inc = e.index;
	end;
	self.curRenderIndex = inc

	-- 文本赋值；
	if item.leveltxt+1 > 10 then return end;
	local cof = self:GetCurMoney(item.leveltxt+1)
	self:Settext(cof)
end;

function UIEquipGem : Settext(cof)
	if not cof then return end;
	local objSwf = self.objSwf;
	local name = t_item[cof.item].name
	local itemNum = BagModel:GetItemNumInBag(cof.item)

	local mon =  MainPlayerModel.humanDetailInfo.eaBindGold + MainPlayerModel.humanDetailInfo.eaUnBindGold;
	if cof.money > mon then 
		-- 金币不足
		self.objSwf.money.htmlText = string.format(StrConfig["equip312"],"960000",cof.money);
	else
		self.objSwf.money.htmlText = string.format(StrConfig["equip312"],"00ff00",cof.money);
	end;


	--优先消耗道具
	if cof.direct_item > 0 then 
		local Nbname = t_item[cof.direct_item].name
		local NbItemNum = BagModel:GetItemNumInBag(cof.direct_item);
		if NbItemNum >= cof.direct_num then 
			objSwf.curProps.htmlText = string.format(StrConfig["equip307"],"00ff00",Nbname,cof.direct_num);
			return 
		end;
	end;
	if cof.num > itemNum  then 
		--物品数量不足
		self.objSwf.curProps.htmlText = string.format(StrConfig["equip307"],"960000",name,cof.num);
	else
		self.objSwf.curProps.htmlText = string.format(StrConfig["equip307"],"00ff00",name,cof.num);
	end;
end;
-- 装备itemclick 
function UIEquipGem : RoleItemClick(e)
	self.curRenderIndex = -1;
	self.curEquipPos = e.item.pos;

	self:Setcuritem()
	self:SetGemInfo()  --宝石info
	self:SetCueIndex()
end;
function UIEquipGem : Setcuritem()
	local pos = self.curEquipPos;
	local objSwf = self.objSwf;	
	local info = t_equipgem[pos]
	local vo = {};
	vo.desc = 0;
	local currlist = EquipModel:GetGemAtPos(self.curEquipPos); -- 当前
	for ca,ou in pairs(currlist) do 
		vo.desc = vo.desc + ou.lvl;
	end;	
	vo.pos = info.pos
	vo.iconUrl = ResUtil:GetItemIconUrl(info.icon,"64")
	--vo.posName = e.item.posName;
	--self.objSwf.rolelist.selectedIndex = self.curEquipPos;
	self.objSwf.curEquipItem:setData(UIData.encode(vo));

end;
-- 购买物品  autobuy
function UIEquipGem : AutoBuyClick()
	self.autoBuyItems = not self.autoBuyItems;
end;
-- 宝石属性总加成
function UIEquipGem : GemAttrBtnClick()
	local list = EquipModel:GetCurGemAtbAll()
	local  html = "";

	for i,vo in pairs(list) do 
		if vo > 0 then 
		local  name = enAttrTypeName[i]
		html =  html.."<font color='#d5b772'>"..name.."<font/><font color='#00ff00'>   "..vo.."<br/>";
		end;
	end;
	if EquipUtil:GetLenght(list) <= 0 then 
		TipsManager:ShowBtnTips(string.format(StrConfig["equip314"]),TipsConsts.Dir_RightDown);
	else
		TipsManager:ShowBtnTips(string.format(StrConfig["equip304"],html),TipsConsts.Dir_RightDown);
	end;
	
end;	

------------------------info ----------------------
function UIEquipGem : SetGemInfo()
	self:GetGemInfo();
	self.objSwf.gemlist.selectedIndex = -1;
	self.curItemVo = nil;
end;

function UIEquipGem : GetGemInfo(bo)
	--Debug("得到宝石信息")
	local glist = {};
	for i=1,3,1 do 
		local vo = {};
		vo.lv = "lv"..i;
		vo.str = "slot"..i
		glist[i] = vo;
	end;


	local objSwf = self.objSwf
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
	local currlist = EquipModel:GetGemAtPos(self.curEquipPos); -- 当前数据
	local curCfgInfo = t_equipgem[self.curEquipPos]; -- 得到当前装备位的宝石
	local list = {};
	for i,pc in ipairs(glist) do
		local lv = curCfgInfo[pc.lv]
		local gemid = curCfgInfo[pc.str];
		local cfg = t_gemgroup[gemid];
		local curcfg = nil;
		for i,gemVo in ipairs(currlist) do
			if gemVo.id == cfg.id then
				curcfg = gemVo;
				break;
			end
		end
		if not curcfg then 
				-- 不可激活状态
			if  lv > curRoleLvl then 
				local vo = {};
				vo.id = gemid;
				vo.open = false;
				vo.leveltxt = 0;
				vo.atbtxt = string.format(StrConfig["equip303"],lv) --  达到多少级开启， 
				vo.gstate = true;
				vo.iconUrl = nil--ResUtil:GetEquipGemIconUrl(cfg.icon,curcfg.lvl)  --  得到当前等级宝石的路径
				table.push(list,UIData.encode(vo));
			else
				-- 可激活状态
				local vo = {};
			    vo.id = gemid--- 当前需要id 
				vo.open = true;
				vo.leveltxt = 0;
				vo.atbtxt = string.format(StrConfig["equip305"],lv) --  空
				vo.gstate = true;
				vo.iconUrl = nil--ResUtil:GetEquipGemIconUrl(cfg.icon,curcfg.lvl)  --  得到当前等级宝石的路径
				table.push(list,UIData.encode(vo));
			end;
		end;
		if curcfg then 
				--  有宝石，可升级状态
				local abtname = enAttrTypeName[curcfg.atbname]
				local vo = {};
				vo.id = curcfg.id
				vo.leveltxt = curcfg.lvl;
				local vipAdd = VipController:GetBaoshishuxingUp() / 100;
				local atb = cfg["atr"..curcfg.lvl] * vipAdd + cfg["atr"..curcfg.lvl];
				local c = math.floor(atb)
				vo.atbtxt = string.format(StrConfig["equip302"],abtname,c) --  当前属性名字和加成
				vo.gstate = false;
				vo.iconUrl = ResUtil:GetEquipGemIconUrl(cfg.icon,curcfg.lvl,"54")  --  得到当前等级宝石的路径
				table.push(list,UIData.encode(vo));
		end;
	end;
	objSwf.gemlist.dataProvider:cleanUp();
	objSwf.gemlist.dataProvider:push(unpack(list));
	objSwf.gemlist:invalidateData();
	--  初始化
	self.objSwf.gemlist.selectedIndex = self.curRenderIndex;
	if bo then 
		local vo = self.curItemVo;
		local cfg = t_gemgroup[vo.id];
		local atbname = cfg["atr"];
		local atblvl = cfg["atr"..vo.leveltxt+1];

		vo.id = vo.id;
		vo.open = false
		vo.leveltxt = vo.leveltxt+1;
		vo.atbtxt = string.format(StrConfig["equip302"],enAttrTypeName[AttrParseUtil.AttMap[atbname]],atblvl);
		vo.gstate = false;
		vo.iconUrl = ResUtil:GetEquipGemIconUrl(cfg.icon, vo.leveltxt);


	if vo.leveltxt == 10 then 
	-- 再次走一次辨别当前宝石信息
	local num = 0;
	local uiItem = self.objSwf.gemlist:getRendererAt(num);
		if uiItem.data.open == false then 
			num = num - 1;
			uiItem = self.objSwf.gemlist:getRendererAt(num);
			return;
		end;
		if uiItem.data.leveltxt == 10 then 
			num = num+ 1;
			local a = self.objSwf.gemlist:getRendererAt(num);
			if a.data.open == false then 
				num = num - 1;
				uiItem = self.objSwf.gemlist:getRendererAt(num);
				return;
			end;
			if a.data.leveltxt == 10 then 
				 num = num +1 ;
				 local  b = self.objSwf.gemlist:getRendererAt(num);
				 if b.data.open == false then 
					num = num - 1;
					uiItem = self.objSwf.gemlist:getRendererAt(num);
					return;
				end;
				 if b.data.leveltxt == 10 then 
				 	num = 0
				 	uiItem = self.objSwf.gemlist:getRendererAt(num);
				 else
					 uiItem = b;
				 end;
			else
				 uiItem = a;
			end;
		end;

		uiItem =  self.objSwf.gemlist:getRendererAt(num);
		local itemc = uiItem.data
		objSwf.gemlist.selectedIndex = num;
		--self.curRenderIndex = num;

		local voc = {};
		voc.id = itemc.id;
		voc.open = itemc.open;
		voc.leveltxt = itemc.leveltxt;
		voc.atbtxt = itemc.atbtxt;
		voc.gstate = itemc.gstate;
		voc.iconUrl = itemc.iconUrl;
		self.curItemVo = voc;
		self.curRenderIndex = num;
		--print(num,"辨别结果")
		end;
		local pns = t_gemcost[self.curItemVo.leveltxt+1]
		if  self.curItemVo.leveltxt+1 > 10 then return end;
		self:Settext(pns)
	end;
end;


--- 得到当前宝石idlist 
function UIEquipGem : GetGemConfig(id)
	if not id then Debug("请填写Id")return end;
	if not t_gemgroup[id] then Debug("配置表里无此属性",id) return end;
	return t_gemgroup[id];
end;
-- 得到当前属性名字
function UIEquipGem : GetAtbName(str)
	if not str then return end;
	if not AttrParseUtil.AttMap[str] then return end;
	if not enAttrTypeName[AttrParseUtil.AttMap[str]] then return end;
	return enAttrTypeName[AttrParseUtil.AttMap[str]];
end;
--- 得到当前等级所需物品Cfg
function UIEquipGem : GetCurMoney(lvl)
	if not t_gemcost[lvl] then return end;
	return t_gemcost[lvl]
end;
-- ----- ---- ----  notifaction
function UIEquipGem : ListNotificationInterests()
	return {
			NotifyConsts.PlayerAttrChange,
			NotifyConsts.EquipGemUpdata,
			NotifyConsts.BagItemNumChange
		}
end;
function UIEquipGem : HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.PlayerAttrChange then 
		if body.type == enAttrType.eaLevel then 
			self:SetGemInfo()
			self:SetCueIndex(e)
		elseif body.type == enAttrType.eaBindGold or body.type == enAttrType.eaUnBindGold  then 
			local item = self.curItemVo
			if not item then return end;
			local cof = self:GetCurMoney(item.leveltxt+1)
			self:Settext(cof)
		end;
	elseif name == NotifyConsts.EquipGemUpdata then 
		self : GetGemInfo(body);
		--self : SetCueIndex()
		-- 设置星级
		self:ShowGemLink();
		self : setCurUplvlbtn();
		self : Setcuritem()
		self:GemRoleItemList();
	elseif name == NotifyConsts.BagItemNumChange then 
		if not self.curItemVo then return end;
		if not self.curItemVo.leveltxt then return end;
		local item = self.curItemVo
		local cof = self:GetCurMoney(item.leveltxt+1)
		self:Settext(cof)

	end;
end;

function UIEquipGem : setCurUplvlbtn()
	local objSwf = self.objSwf;
	local vo = self.curItemVo;

	if vo.gstate == true then 
		objSwf.btnGoUp.textField.text = string.format(StrConfig["equip317"])
	else
		objSwf.btnGoUp.textField.text = string.format(StrConfig["equip316"])
	end;

	if tonumber(vo.leveltxt) >= 10 then
		objSwf.btnGoUp.disabled = true;
		objSwf.MaxLvltip._visible = true;
		objSwf.txt1._visible = false;
		objSwf.txt2._visible = false;
		objSwf.curProps._visible = false;
		objSwf.money._visible = false;
	else
		objSwf.btnGoUp.disabled = false;
		objSwf.MaxLvltip._visible = false;
		objSwf.txt1._visible = true;
		objSwf.txt2._visible = true;
		objSwf.curProps._visible = true;
		objSwf.money._visible = true;
	end; 
end;


--显示连锁按钮

function UIEquipGem:ShowGemLink()
	local curlist = EquipModel:GetGemList();
	local curlinkid = EquipUtil:GetGemLinkId(curlist);
	for i,btn in ipairs(self.linkBtns) do 
		btn.visible = false;
	end;

	for i,cfg in ipairs(t_gemlock) do 
		if curlinkid >= cfg.id then 
			self:ShowStrenLinkBtn(i,true);
		else
			self:ShowStrenLinkBtn(i,false);
			break;
		end;
	end;
end;

--显示连锁按钮
function UIEquipGem:ShowStrenLinkBtn(index,active)
	if self.linkBtns[index] then
		self.linkBtns[index].visible = true;
		self.linkBtns[index].disabled = not active;
		return;
	end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local depth = objSwf:getNextHighestDepth();
	local button = objSwf:attachMovie("GemLinkButton"..index,"linkBtn"..index,depth);
	self.linkBtns[index] = button;
	button._x = 18 + (index-1)*36;
	button._y = 20;
	button.alwaysRollEvent = true;
	button.visible = true;
	button.disabled = not active;
	button.rollOut = function() TipsManager:Hide(); end
	button.rollOver = function() self:OnStrenLinkRollOver(index,button); end
end
--连锁tips
function UIEquipGem:OnStrenLinkRollOver(index,button)
	local num = 0;
	local linkCfg = t_gemlock[index];
	local gemlistc = EquipModel:GetGemList(); 

	local curlinkid = EquipUtil:GetGemLinkId(gemlistc);
	if not linkCfg then return; end
	local alllvl = 0;
	for i,info in pairs(gemlistc) do 
		alllvl = alllvl + info.lvl;
	end;

	local lvlc = 0;
	if curlinkid < 6 then 
		lvlc = t_gemlock[curlinkid+1].lvl
	else
		lvlc = t_gemlock[curlinkid].lvl
	end;

	local tipsVO = {};
	tipsVO.activeNum = alllvl
	tipsVO.linkId = index;
	TipsManager:ShowTips(TipsConsts.Type_GemLink,tipsVO,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end



--画模型
function UIEquipGem:DrawRole()
	local uiLoader = self.objSwf.roleLoaderGem;

	
	local vo = {};
	local info = MainPlayerModel.sMeShowInfo;
	vo.prof = MainPlayerModel.humanDetailInfo.eaProf
	vo.arms = info.dwArms
	vo.dress = info.dwDress
	vo.fashionsHead = info.dwFashionsHead
	vo.fashionsArms = info.dwFashionsArms
	vo.fashionsDress = info.dwFashionsDress
	vo.shoulder = info.dwShoulder;
	vo.wuhunId = 0;--SpiritsModel:GetFushenWuhunId()
	vo.wing = info.dwWing
	vo.suitflag = info.suitflag
	if self.objAvatar then
		self.objAvatar:ExitMap();
		self.objAvatar = nil;	
	end
	self.objAvatar = CPlayerAvatar:new();
	self.objAvatar:CreateByVO(vo);
	--
	local prof = MainPlayerModel.humanDetailInfo.eaProf; --取玩家职业
    if not self.objUIDraw then
		self.objUIDraw = UIDraw:new("rolePanelPlayerGem", self.objAvatar, uiLoader,
							UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos,
							0x00000000,"UIRole", prof);
	else
		self.objUIDraw:SetUILoader(uiLoader);
		self.objUIDraw:SetCamera(UIDrawRoleCfg[prof].VPort,UIDrawRoleCfg[prof].EyePos,UIDrawRoleCfg[prof].LookPos);
		self.objUIDraw:SetMesh(self.objAvatar);
	end
	self.meshDir = 0;
	self.objAvatar.objMesh.transform:setRotation(0,0,1,self.meshDir);
	self.objUIDraw:SetDraw(true);
	self.objAvatar:PlayLianhualuAction()
	-- --播放特效
	-- local sex = MainPlayerModel.humanDetailInfo.eaSex;
	-- local pfxName = "ui_role_sex" ..sex.. ".pfx";
	-- local name,pfx = self.objUIDraw:PlayPfx(pfxName);
	-- 微调参数
	--pfx.transform:setRotationX(UIDrawRoleCfg[prof].pfxRotationX);
end

function UIEquipGem:GetLvlUpBtn()
	if not self:IsShow() then 
		return 
	end;
	return self.objSwf.btnGoUp;
end;

function UIEquipGem:SetCurMiniLvlGem()
	if not self:IsShow() then return end;
	local objSwf = self.objSwf;
	local curRoleLvl = MainPlayerModel.humanDetailInfo.eaLevel -- 当前人物等级
	local gemlist = {}
	local gemid = 0;
	for i,info in pairs(t_equipgem) do
		for i=1,3 do 
			local lvl = info["lv"..i];
			if lvl  <= curRoleLvl then 
				table.push(gemlist,info["slot"..i]);
			end;
		end;
	end;
	for i,info in ipairs(gemlist) do 
		local cfg = t_gemgroup[info];
		local gem = EquipModel:GetGemServerinfo(info)
		if gem then -- 当前状态有宝石
			if gemid == 0 then gemid = gem.id end;
			local curgem = EquipModel:GetGemServerinfo(gemid)
			if curgem.lvl > gem.lvl then 
				gemid = gem.id;
			end;
		else -- 没宝石
			gemid = info;
			break;
		end;
	end;
	local endcfg = EquipModel:GetGemServerinfo(gemid)
	if not endcfg then 
		endcfg = t_gemgroup[gemid];
		endcfg.lvl = 1;
	end;
	local pos = endcfg.pos;
	local currlist = EquipModel:GetGemAtPos(pos); -- 当前数据
	local gemindex = -1;
	for wo,qu in ipairs(currlist) do 
		if qu.id == endcfg.id then 
			gemindex = wo - 1;
		end;
	end
	if gemindex == -1 then 
		gemindex = #currlist;
	end;
	self.autoBuyItems = false;
	objSwf.selectAutoBuy.selected = self.autoBuyItems;
	self.curRenderIndex = gemindex;
	self.curEquipPos = pos
	

	self:Setcuritem()
	self:SetGemInfo(true)  --宝石info
	--self:SetCueIndex()


	objSwf.rolelist.selectedIndex = self.curEquipPos;
	objSwf.gemlist.selectedIndex = self.curRenderIndex;
	local uiItem = self.objSwf.gemlist:getRendererAt(gemindex);
	local itemc = uiItem.data;
	local voc = {};
	voc.id = itemc.id;
	voc.open = itemc.open;
	voc.leveltxt = itemc.leveltxt;
	voc.atbtxt = itemc.atbtxt;
	voc.gstate = itemc.gstate;
	voc.iconUrl = itemc.iconUrl;
	self.curItemVo = voc;
	local cof = self:GetCurMoney(self.curItemVo.leveltxt+1)
	self:Settext(cof)

	-- objSwf.gemlist.dataProvider:cleanUp();
	-- objSwf.gemlist.dataProvider:push(unpack({}));
	-- objSwf.gemlist:invalidateData();

end;