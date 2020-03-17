
--[[
套装激活
wangshuai
]]

_G.UIEquipGroupActivation = BaseUI:new("UIEquipGroupActivation")

UIEquipGroupActivation.curPos = 1;
UIEquipGroupActivation.curGroupPos = 1;

function UIEquipGroupActivation:Create()
	self:AddSWF("equipGroupActivation.swf",true,'center')
end;

function UIEquipGroupActivation:OnLoaded(objSwf)
	--装备位置
	objSwf.rolelist.itemClick = function (e) self:RoleItemClick(e) end;
	-- objSwf.rolelist.itemRollOver = function (e) self:OnShowGemList(e)end;
	-- objSwf.rolelist.itemRollOut = function () UIEquipGemTips:Hide();end;

	objSwf.equipGroupPosList.itemClick = function(e) self:OnEquipGroupPosIte(e) end;
	objSwf.equipGroupPosList.itemRollOver = function(e) self:OnGroupPosItemOver(e) end;
	objSwf.equipGroupPosList.itemRollOut = function() TipsManager:Hide() end;

	objSwf.okBtn.click = function() self:OnSureClick()end;
	objSwf.okBtn3.click = function() self:OnSureClick()end;
	objSwf.okBtn2.click = function() self:OnSureClick()end;

	objSwf.nextLvl_item.rollOver = function() self:NextLvlTips() end;
	objSwf.nextLvl_item.rollOut = function() TipsManager:Hide() end;

	for i=1,3 do 
		objSwf['fangjuItem_'..i].icon.rollOver = function() self:OnFangjuItem(objSwf['fangjuItem_'..i].icon) end;
		objSwf['fangjuItem_'..i].icon.rollOut = function()  TipsManager:Hide() end;


		objSwf['peishiItem_'..i].icon.rollOver = function() self:OnPieshiItem(objSwf['peishiItem_'..i].icon) end;
		objSwf['peishiItem_'..i].icon.rollOut = function()  TipsManager:Hide() end;
		for c=1,2 do 

			objSwf['fangjuItem_'..i]['skil_'..c].rollOver = function() self:OnSkilFangjuItem(objSwf['fangjuItem_'..i]['skil_'..c],c) end;
			objSwf['fangjuItem_'..i]['skil_'..c].rollOut = function()  TipsManager:Hide() end;

			objSwf['peishiItem_'..i]['skil_'..c].rollOver = function() self:OnSkilPeishiItem(objSwf['peishiItem_'..i]['skil_'..c],c) end;
			objSwf['peishiItem_'..i]['skil_'..c].rollOut = function()  TipsManager:Hide() end;

		end;
	end;
	--
	for ix=1,2 do 
		objSwf['xiaohao'..ix..'_txt'].rollOver = function() self:OnRollOver(ix)end;
		objSwf['xiaohao'..ix..'_txt'].rollOut = function() TipsManager:Hide() end;
	end;

	--套装
	objSwf.setLeft_btn.click = function() self:OnBtnPreClick() end;
	objSwf.setRight_btn.click = function()self:OnBtnNextClick() end;
	--预览防具
	objSwf.look1Left_btn.click = function() end;
	objSwf.look1Right_btn.click = function() end;
	--预览饰品
	objSwf.look2Left_btn.click = function() end;
	objSwf.look2Right_btn.click = function() end;

	--临时
	-- objSwf.setLeft_btn.disabled = true;
	-- objSwf.setRight_btn.disabled = true;
	--预览防具
	objSwf.look1Left_btn.disabled = true;
	objSwf.look1Right_btn.disabled = true;
	--预览饰品
	objSwf.look2Left_btn.disabled = true;
	objSwf.look2Right_btn.disabled = true;

	objSwf.equipPosJIhuo_fpx.playOver = function() self:OnPlayOver()end;
	objSwf.equipPosShengji_fpx.playOver = function() self:OnPlayOver()end;
	objSwf.equipPosJiesuo_fpx.playOver = function() self:OnPlayOver()end;

end;

--[[激活特效位置 
	470,  
 	585,
	697,
	810,
	925,
	--升级位置
]]

function UIEquipGroupActivation:OnPlayOver()
	local objSwf = self.objSwf
	if not objSwf then return end;
	objSwf.equipPosJIhuo_fpx:gotoAndStop(1);
	objSwf.equipPosShengji_fpx:gotoAndStop(1);
	objSwf.equipPosJiesuo_fpx:gotoAndStop(1);
	objSwf.equipPosJIhuo_fpx._visible = false;
	objSwf.equipPosShengji_fpx._visible = false;
	objSwf.equipPosJiesuo_fpx._visible = false;
end;
 
UIEquipGroupActivation.fpxXY = {470,585,697,810,925}
function UIEquipGroupActivation:UpdataFpxShow(type,index)
	index = index + 1;
	local objSwf =self.objSwf;
	if not objSwf then return end;
	if not self:IsShow() then return end;
	if type == 1 then  --解锁
		objSwf.equipPosJiesuo_fpx._visible = true;
		objSwf.equipPosJiesuo_fpx:gotoAndPlay(1);
		objSwf.equipPosJiesuo_fpx._x = self.fpxXY[index];
	elseif type == 2 then  -- 激活
		objSwf.equipPosJIhuo_fpx._visible = true;
		objSwf.equipPosJIhuo_fpx:gotoAndPlay(1);
		objSwf.equipPosJIhuo_fpx._x = self.fpxXY[index];
	elseif type == 3 then  -- 升级
		objSwf.equipPosShengji_fpx._visible = true;
		objSwf.equipPosShengji_fpx:gotoAndPlay(1);
		objSwf.equipPosShengji_fpx._x = self.fpxXY[index];
	end;
end;

--预览按钮
function UIEquipGroupActivation:UpdatePreNextBtn()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.equipGroupPosList
	local numLianTi = list.dataProvider.length
	local selectedIndex = list.selectedIndex
	local scrollPosition = list.scrollPosition
	objSwf.setLeft_btn.disabled = (selectedIndex == 0) and (scrollPosition == 0)
	objSwf.setRight_btn.disabled = selectedIndex == numLianTi - 1
	self:UpdataUIShow();
end

function UIEquipGroupActivation:OnBtnPreClick()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.equipGroupPosList
	local numLianTi = list.dataProvider.length
	if list.scrollPosition > 0 then
		list.scrollPosition = list.scrollPosition - 1
		list.selectedIndex = math.min( list.selectedIndex, list.scrollPosition + list.rowCount - 1 )
	elseif list.selectedIndex > 0 then
		list.selectedIndex = list.selectedIndex - 1
	end
	self:UpdatePreNextBtn();
end

function UIEquipGroupActivation:OnBtnNextClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local list = objSwf.equipGroupPosList
	local numLianTi = list.dataProvider.length
	if list.scrollPosition < numLianTi - list.rowCount then
		list.scrollPosition = list.scrollPosition + 1
		list.selectedIndex = math.max( list.selectedIndex, list.scrollPosition )
	elseif list.selectedIndex < numLianTi - 1 then
		list.selectedIndex = list.selectedIndex + 1
	end
	self:UpdatePreNextBtn();
end


function UIEquipGroupActivation:OnShow()
	self:UpdataUIShow();
	self:UpdatalookGroupShow()
end;

function UIEquipGroupActivation:UpdataUIShow()
	--设置装备位
	self:SetRoleEquipPosData()
	--刷新选中装备
	self:SetCurEquipData();
	--刷新选中装备套装list
	self:ShowPosGroupDate();
	--升级需求
	self:ShowGroupPosData();
	--下级预览
	self:OnSetNextLvlData()
	--刷新pos开启属性
	self:SetOpenPosNum();
	--关闭显示
	self:OnPlayOver();
end;

function UIEquipGroupActivation:OnHide()
	self.curPos = 1;
	self.curGroupPos = 1;
end;

function UIEquipGroupActivation:OnSureClick()
	if not self.curPos then return end;
	if not self.curGroupPos then return end;
	local lvl = EquipModel:GetCuePosIsHaveGroup(self.curPos,self.curGroupPos);
	if lvl == -2 then  --开孔
		local posNum = EquipModel:GetCurPosGroupPosNum(self.curPos);
		local cfg = t_equipgroupextra[self.curPos];
		local color = "#00ff00"
		if cfg then 
			if posNum >= cfg.num then 
				FloatManager:AddNormal(StrConfig["equip2008"])
				return 
			end;
		end;
		EquipController:ReqOpenPos(self.curPos,self.curGroupPos) 
	elseif lvl == -1 then  --镶嵌
		EquipController:ReqSetPosData(self.curPos,self.curGroupPos)
	elseif lvl >= 0 then  --升级
		local gdata,grid = self:GetGroupData();
		local id = grid * 100 + lvl + 1
		local cfg = t_equipgrouphuizhang[id];
		if not cfg then 
				FloatManager:AddNormal(StrConfig["equip2010"])
			return
		end;
		EquipController:ReqLvlUpGroup(self.curPos,self.curGroupPos) 
	end;
end;


function UIEquipGroupActivation:SetOpenPosNum()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local posNum = EquipModel:GetCurPosGroupPosNum(self.curPos);
	local cfg = t_equipgroupextra[self.curPos];
	local color = "#00ff00"
	if cfg then 
		if posNum >= cfg.num then 
			color = "#ff0000"
		end;
	end;
	objSwf.openNum_txt.htmlText = string.format(StrConfig["equip2007"],cfg.num - posNum)
end;

function UIEquipGroupActivation:OnRollOver(index)
	--print(index,'----------------------')
	local lvl = EquipModel:GetCuePosIsHaveGroup(self.curPos,self.curGroupPos);
	local gdata,grid = self:GetGroupData();
	if lvl == -2 then 
		local kongNum = EquipModel:GetcurPosKongNum(self.curPos) + 1;
		local xiaohaoCfg = t_equipgroupexpand[kongNum];
		if not xiaohaoCfg then 
			print(kongNum,debug.traceback())
			return 
		end;
		local dlist = split(xiaohaoCfg.item,'#')
		if dlist[index] then 
		local data = split(dlist[index],',')
		local id = toint(data[1])

		TipsManager:ShowItemTips(id);
		end;
	elseif lvl == -1 then 
		if index == 2 then return end;
		local gcfg = t_equipgroup[grid];
		if not gcfg then
			print(grid,debug.traceback());
			return
		end;
		local data = split(gcfg.itemId,',')
		local id = toint(data[1]);
		TipsManager:ShowItemTips(id);

	elseif lvl >= 0 then 
		if index == 2 then return end;
		lvl = lvl + 1
		local gLvlid = grid * 100 + lvl;
		local glvlcfg = t_equipgrouphuizhang[gLvlid];
		if not glvlcfg then 
			--print(gLvlid,debug.traceback());
			return 
		end;
		local data = split(glvlcfg.item,',');
		local id = toint(data[1]);
		TipsManager:ShowItemTips(id);
	end;

end

--升级需求，等
function UIEquipGroupActivation:ShowGroupPosData()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local index = self.curGroupPos;

	objSwf.equipGroupPosList.selectedIndex = self.curGroupPos - 1;

	--得到当前装备位下，套装位置，是否有东西，是否开启
	-- 找不到 -2 未开孔，
	-- 找到 -1 开孔未镶嵌
	-- 找到 0 镶嵌，未升级
	-- 找到等级，已生效

	local lvl = EquipModel:GetCuePosIsHaveGroup(self.curPos,self.curGroupPos);
	local gdata,grid = self:GetGroupData();

	if lvl == -2 then 
		local kongNum = EquipModel:GetcurPosKongNum(self.curPos) + 1;
		local xiaohaoCfg = t_equipgroupexpand[kongNum];
		if not xiaohaoCfg then 
			print(kongNum,debug.traceback())
			return 
		end;
		local dlist = split(xiaohaoCfg.item,'#')
		for i=1,2 do 
			if dlist[i] then 
				local data = split(dlist[i],',')
				local id = toint(data[1])
				local num = toint(data[2]) ;
				local bagNum = BagModel:GetItemNumInBag(id);
				local name = t_item[id] and t_item[id].name or "";
				objSwf["xiaohao"..i.."_txt"]._visible = true;
				local color = "#ff0000"
				if bagNum >= num then 
					--00ff00
					color = "#00ff00"
				end;
				objSwf["xiaohao"..i.."_txt"].htmlLabel = "<u><font color ='"..color.."''>"..name.. num .. StrConfig["equip2006"] .. "</font></u>"
			else
				objSwf["xiaohao"..i.."_txt"]._visible = false;
			end;
		end;
		objSwf.okBtn._visible = false;
		objSwf.okBtn2._visible = false;
		objSwf.okBtn3._visible = true;
	elseif lvl == -1 then 
		local gcfg = t_equipgroup[grid];
		if not gcfg then
			print(grid,debug.traceback());
			return
		end;
		local data = split(gcfg.itemId,',')
		local id = toint(data[1]);
		local num = toint(data[2]);
		local bagNum = BagModel:GetItemNumInBag(id)
		local color = "#ff0000";
		if bagNum >= num then 
			--00ff00
			color = "#00ff00"
		end;
		--
		local name = t_item[id] and t_item[id].name or "";
		objSwf.xiaohao1_txt.htmlLabel = "<u><font color ='"..color.."''>"..name .. "X".. num .. StrConfig["equip2006"] .."</font></u>"
		objSwf.xiaohao2_txt._visible = false;
	
		objSwf.okBtn._visible = false;
		objSwf.okBtn2._visible = true;
		objSwf.okBtn3._visible = false;

	elseif lvl >= 0 then 
		lvl = lvl + 1
		local gLvlid = grid * 100 + lvl;
		local glvlcfg = t_equipgrouphuizhang[gLvlid];
		if not glvlcfg then 
			--print(gLvlid,debug.traceback());
			objSwf.xiaohao1_txt.htmlLabel = StrConfig["equip2009"];
			objSwf.xiaohao2_txt._visible = false;
			return 
		end;
		--trace(glvlcfg)
		local data = split(glvlcfg.item,',');
		local id = toint(data[1]);
		local num = toint(data[2]);
		local bagNum = BagModel:GetItemNumInBag(id)
		local color = "#ff0000";
		if bagNum >= num then 
			--00ff00
			color = "#00ff00"
		end;
		--
		local name = t_item[id] and t_item[id].name or "";
		objSwf.xiaohao1_txt.htmlLabel = "<u><font color ='"..color.."''>"..name .. "X".. num .. StrConfig["equip2006"] .."</font></u>"
		objSwf.xiaohao2_txt._visible = false;

		objSwf.okBtn._visible = true;
		objSwf.okBtn2._visible = false;
		objSwf.okBtn3._visible = false;
	end;
end;

function UIEquipGroupActivation:GetGroupData()
	local cfg = t_equipgroupextra[self.curPos];
	if not cfg then return end;
	local groupList = split(cfg.groupId,',');
	local grid = toint(groupList[self.curGroupPos]);
	if not grid then return end;
	local gdata = t_equipgroup[grid];
	if not gdata then return end;
	return gdata,grid
end;

--下级预览tips
function UIEquipGroupActivation:NextLvlTips()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local lvl = EquipModel:GetCuePosIsHaveGroup(self.curPos,self.curGroupPos)
	local gdata,grid = self:GetGroupData()
	if not gdata then return end;
	if not grid then return end;
	if lvl >= 0 then 
		lvl = lvl + 1;

		local vo = {};
		vo.groupId2 = grid;
		vo.pos =  self.curPos;
		vo.lvl = lvl;
		--
		local cfg = t_equipgroup[grid];
		if not cfg then return end;
		local posCfg = split(cfg.groupPos,'#');
		local listVo = {};
		if posCfg then 
			for i,info in ipairs(posCfg) do
				local vo = {};
				vo.pos = toint(info)
				local lvl = EquipModel:GetCuePosIsHaveGroup(toint(info),self.curGroupPos);
				if lvl >= 0 then 
					local cfg = t_equipgroupextra[toint(info)];
					if not cfg then return end;
					local groupList = split(cfg.groupId,',');
					local grid = toint(groupList[self.curGroupPos]);
					if not grid then return end;
					local gdata = t_equipgroup[grid];
					if not gdata then return end;

					vo.groupId2 = gdata.id
					vo.lvl = lvl or 0;
				else
					vo.groupId2 = 0;
				end;
				table.push(listVo,vo)
			end;
		end;
		--trace(listVo)
		vo.groupEList = listVo
		TipsManager:ShowTips( TipsConsts.Type_EquipGroup,vo, TipsConsts.ShowType_Normal,
			TipsConsts.Dir_RightDown );

	end;
end;

--下级预览 
function UIEquipGroupActivation:OnSetNextLvlData()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local lvl = EquipModel:GetCuePosIsHaveGroup(self.curPos,self.curGroupPos)
	local gdata,grid = self:GetGroupData()
	if not gdata then return end;
	if not grid then return end;
	if lvl >= 0 then 
		objSwf.nextLvl_item._visible = true;
		lvl = lvl + 1;
		local ccid = grid * 100 + lvl;
		local ccfg = t_equipgrouphuizhang[ccid]
		if ccfg then 
			local vo = {};
			vo.pos = self.curPos;
			vo.index = self.curGroupPos;
			vo.id = grid;
			vo.iconUrl =  ResUtil:GetNewEquipGrouNameIconYangcheng(gdata.image)
			vo.lvl = lvl;
			objSwf.nextLvl_item:setData(UIData.encode(vo));
		else
			objSwf.nextLvl_item._visible = false;
		end;
	else
		objSwf.nextLvl_item._visible = false;
	end;
end;

function UIEquipGroupActivation:OnGroupPosItemOver(e)
	local pos = e.item.pos;
	local id = e.item.id;
	local index = e.item.index
	local lvl = EquipModel:GetCuePosIsHaveGroup(pos,index);
	--print(lvl,'的萨达十大是打算打算打算打扫打扫打扫的是')
	if lvl >=0 then 
		local vo = {};
		vo.groupId2 = id;
		vo.pos = pos;
		vo.lvl = lvl;
		--
		local cfg = t_equipgroup[id];
		local posCfg = split(cfg.groupPos,'#');
		local listVo = {};
		if posCfg then 
			for i,info in ipairs(posCfg) do
				local vo = {};
				vo.pos = toint(info)
				local lvl = EquipModel:GetCuePosIsHaveGroup(toint(info),index);
				if lvl >= 0 then 
					local cfg = t_equipgroupextra[toint(info)];
					if not cfg then return end;
					local groupList = split(cfg.groupId,',');
					local grid = toint(groupList[index]);
					if not grid then return end;
					local gdata = t_equipgroup[grid];
					if not gdata then return end;

					vo.groupId2 = gdata.id
					vo.lvl = lvl or 0;
				else
					vo.groupId2 = 0;
				end;
				table.push(listVo,vo)
			end;
		end;
		--trace(listVo)
		vo.groupEList = listVo
		TipsManager:ShowTips( TipsConsts.Type_EquipGroup,vo, TipsConsts.ShowType_Normal,
			TipsConsts.Dir_RightDown );
	elseif lvl == -1 then 
		TipsManager:ShowBtnTips(StrConfig["equip2005"],TipsConsts.Dir_RightDown);
		return 
	elseif lvl == -2 then 
		TipsManager:ShowBtnTips(StrConfig["equip2004"],TipsConsts.Dir_RightDown);
		return 
	end;
end;

function UIEquipGroupActivation:OnEquipGroupPosIte(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	self.curGroupPos = e.index + 1;

	--升级需求
	self:ShowGroupPosData();
	--下级预览
	self:OnSetNextLvlData()
end;

--刷新显示套装list
function UIEquipGroupActivation:ShowPosGroupDate()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local cfg = t_equipgroupextra[self.curPos];
	if not cfg then return end;
	local groupList = split(cfg.groupId,',');
	local glist = {};
	for i,info in ipairs(groupList) do 
		local grid = toint(info);
		local gdata = t_equipgroup[grid];
		local vo = {};
		vo.pos = self.curPos;
		vo.id = grid;
		vo.iconUrl =  ResUtil:GetNewEquipGrouNameIconYangcheng(gdata.image)
		local lvl = EquipModel:GetCuePosIsHaveGroup(self.curPos,i)
		vo.index = i;
		vo.lvl = lvl;
		table.push(glist,UIData.encode(vo))
	end
	objSwf.equipGroupPosList.dataProvider:cleanUp();
	objSwf.equipGroupPosList.dataProvider:push(unpack(glist));
	objSwf.equipGroupPosList:invalidateData();

	--更新按钮
	--self:UpdatePreNextBtn();
end;

--装备位点击
function UIEquipGroupActivation:RoleItemClick(e)
	if not e.item then return end;
	if not e.item.pos then return end;
	local pos = e.item.pos
	self.curPos = pos;
	--
	self:UpdataUIShow();
end;

--设置装备位
function UIEquipGroupActivation:SetCurEquipData()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local pos = self.curPos;
	objSwf.rolelist.selectedIndex = pos;
	local vo = {};
	local curCfg = EquipModel:GetRefinInfo(pos); -- 当前
	vo.iconUrl = ResUtil:GetEquipPosUrl(pos,"64")
	vo.pos = pos;
	if not curCfg then 
		curCfg = {}
		curCfg.lvl = 0;
	end;
	vo.desc = curCfg.lvl;
	vo.posName = BagConsts:GetEquipName(pos);
	objSwf.equipPos:setData(UIData.encode(vo));  --显示 
end;

function UIEquipGroupActivation:SetRoleEquipPosData()
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local list = {}
	for i=1,11 do
		local vo = {};
		vo.iconUrl = ResUtil:GetEquipPosUrl(i-1,"64")
		vo.pos = i - 1;
		local currVo = EquipModel:GetRefinInfo(vo.pos); -- 当前
		if not currVo then 
			currVo = {}
			currVo.lvl = 0;
		end; 
		vo.desc = currVo.lvl;
		vo.posName = BagConsts:GetEquipName(i);
		table.push(list,UIData.encode(vo));

		local txt = objSwf["txt_num"..i+ 1]
		--print(vo.pos,'--------------------------')
		local num = EquipModel:GetCurPosGroupNum(i);
		if txt then 
			txt.htmlText = num;
		end;
	end;
	objSwf.rolelist.dataProvider:cleanUp();
	objSwf.rolelist.dataProvider:push(unpack(list));
	objSwf.rolelist:invalidateData();
end;



---	-- notifaction
function UIEquipGroupActivation:ListNotificationInterests()
	return {
		NotifyConsts.EquipGroupActivation,
		NotifyConsts.BagAdd,
		NotifyConsts.BagRemove,
		NotifyConsts.BagUpdate,
		NotifyConsts.SkillAdd,
		NotifyConsts.SkillRemove
		}
end;
function UIEquipGroupActivation:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.EquipGroupActivation then
		self:UpdataUIShow();
		self:UpdatalookGroupShow();

	elseif name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name == NotifyConsts.BagUpdate then
		self:UpdataUIShow();
		self:UpdatalookGroupShow();
	elseif name == NotifyConsts.SkillAdd then
		self:ShowGroupLook();
	elseif name == NotifyConsts.SkillRemove then
		self:ShowGroupLook();
	end
end;


--计算套装总属性加成
function UIEquipGroupActivation:ShowGroupAllAtb()
	local list = EquipModel.Grouplist
	--trace(list)
	local atbAl = {}
	local glist = {};
	--trace(list)
	--print('------------------------------')
	for i,info in pairs(list) do
		--print(info.pos)
		local poscfg = t_equipgroupextra[info.pos];
		local groupList = split(poscfg.groupId,",");
		local id = toint(groupList[info.index]);
		local atbid = id * 100000 + info.pos;
		--当前套装等级
		local lvl = EquipModel:GetCuePosIsHaveGroup(info.pos,info.index);
		--计算套装升级属性
		local curDanAtb = 0;
		if lvl >= 0 then 		
			local lvlId = id * 100 + lvl;
			local lvlCfg = t_equipgrouphuizhang[lvlId];
			if lvlCfg then 
				curDanAtb = lvlCfg.poseattr / 100;
			end;
			--print(atbid)
			local cfg = t_equipgrouppos[atbid];
			if cfg then 
				local atb= AttrParseUtil:Parse(cfg.attr);
				--trace(atb)
				for ca,pa in pairs(atb) do
					if not atbAl[pa.type] then 
						atbAl[pa.type] = toint(pa.val) + toint(pa.val) * curDanAtb;
					else
						atbAl[pa.type] = atbAl[pa.type] + (toint(pa.val) + toint(pa.val) * curDanAtb);
					end;
				end
			end;


			if not glist[id] then 
				glist[id] = {}
				glist[id].id = id;
				glist[id].num = 1;
				glist[id].lvl = lvl;
			else
				glist[id].num = glist[id].num + 1;
				if glist[id].lvl > lvl then 
					glist[id].lvl = lvl;
				end;
			end;

		end;

	end;

	for gs,gm in pairs(glist) do 
		local groupCfg = t_equipgroup[gm.id]
		for i=2,11 do
			local attrCfg = groupCfg["attr"..i];
			if attrCfg ~= "" then 
				-- print('------------哈哈哈')
				-- print(attrCfg)
				if gm.num >= i then 
					--atbAl = atbAl .. "," .. attrCfg;
					local addId = gm.id * 100 + gm.lvl;
					local addCfg = t_equipgrouphuizhang[addId];
					local addVal = 0;
					if addCfg then 
						addVal = addCfg.gruopattr / 100;
					end;
					local atb = AttrParseUtil:Parse(attrCfg);
					--trace(atb)
					for ca,pa in pairs(atb) do
						if not atbAl[pa.type] then 
							atbAl[pa.type] = toint(pa.val) + toint(pa.val) * addVal;
						else
							atbAl[pa.type] = atbAl[pa.type] + (toint(pa.val) + toint(pa.val) * addVal );
						end;
					end
				end;
			end;
		end;
	end;

	--trace(atbAl)
	local list = {};
	for cac,ap in pairs(atbAl) do 
		if attrIsPercent(cac) then 
			list[cac] =  string.format("%.2f",tonumber(ap) * 100).."%";
		else
			list[cac] =  ap;
		end;
	end;
	--trace(list)

	local html = "";
	for i,info in pairs(list) do 
		if info then 
			local name = enAttrTypeName[i];
			local val = info
			html = html .. "<font color='#d5b772'>"..name..": </font><font color='#00ff00'>"..toint(val).."<br/></font>"
		end
	end;
	local objSwf = self.objSwf;
	if not objSwf then return end;
	objSwf.allAtb_txt.htmlText = html;
end;

-------------------------------------------------设置套装属性


function UIEquipGroupActivation:UpdatalookGroupShow()
	--刷新防具套装显示
	self:ShowGroupLook();
	--刷新总属性
	self:ShowGroupAllAtb();
end;

UIEquipGroupActivation.fangjuIndex = 1;
UIEquipGroupActivation.shipinIndex = 1;

UIEquipGroupActivation.equipposList = {1,2,3,4,5,6,7,8,9,10}
UIEquipGroupActivation.fangjuPos = {1,2,3,4,5,6};
UIEquipGroupActivation.ShipinPos = {7,8,9,10};

function UIEquipGroupActivation:ShowGroupLook()
	local objSwf = self.objSwf;
	if not objSwf then return end;

	local allGroupList = {};
	for fj,da in ipairs(self.equipposList) do 
		local pos = da;
		local cfg = t_equipgroupextra[pos];
		local glist = split(cfg.groupId,",");
		for gc,gs in ipairs(glist) do 
			local id = toint(gs);
			local lvl = EquipModel:GetCuePosIsHaveGroup(pos,gc);
			if lvl >= 0 then  --显示已镶嵌，的
				--trace(allGroupList)
				if not allGroupList[id] then 
					allGroupList[id] = {};
					allGroupList[id].num = 1;
					allGroupList[id].id = id;
					allGroupList[id].pos = pos;
					allGroupList[id].lvl = lvl;
					allGroupList[id].atbList = {};
				elseif allGroupList[id] then 
					allGroupList[id].num = allGroupList[id].num + 1;
					if allGroupList[id].lvl > lvl then 
						allGroupList[id].lvl = lvl;
					end;
				end;
				local num = 0;
				for i=2,11 do
					local groupCfg = t_equipgroup[id]
					local attrCfg = groupCfg["attr"..i];
					if attrCfg ~= "" then 
						if allGroupList[id].num >= i then 
							num = num + 1;
							table.push(allGroupList[id].atbList,attrCfg)
						end;
					end;
					allGroupList[id].skNum = num;
				end;
			end;
		end;
	end;

	local uilistdata = {}
	for da,gdata in pairs(allGroupList) do 
		local id = gdata.id;
		local gcfg = t_equipgroup[id];
		local vo = {};
		vo.iconUrl = ResUtil:GetNewEquipGrouNameIconYangcheng(gcfg.image)
		local gnumlist = split(gcfg.groupPos,'#');
		vo.allGnum = #gnumlist;
		vo.curnum = gdata.num;
		vo.skList = {}
		vo.id = gdata.id;
		vo.pos = gdata.pos;
		vo.skNum = gdata.skNum
		vo.lvl = gdata.lvl
		for sk=1,2 do  -- 
			if gcfg["skill"..sk] then 
				table.push(vo.skList,gcfg["skill"..sk])
			end;
		end;
		table.push(uilistdata,vo)
	end;

	local listfangju = {};
	for fa,ju in pairs(uilistdata) do
		for _,pos in pairs(self.fangjuPos) do 
			if pos == ju.pos then 
				table.push(listfangju,ju)
				break;
			end;
		end;
	end;

	local shipinglist = {};
	for sh,pin in pairs(uilistdata) do 
		for _,pos in pairs(self.ShipinPos) do 
			if pos == pin.pos then 
				table.push(shipinglist,pin)
			end;
		end;
	end;

	if #listfangju <= 0 then 
		objSwf.fangjuImg._visible = true;
	else
		objSwf.fangjuImg._visible = false;
	end;
	if #shipinglist <= 0 then 
		objSwf.shipinImg._visible = true;
	else
		objSwf.shipinImg._visible = false;
	end;

	for idnex=1,2 do
		local num = 0;
		for i=self.fangjuIndex ,3 do 
			num = num + 1
			local item = nil;
			local data = nil;
			if idnex == 1 then 
				data = listfangju[i];
				item = objSwf["fangjuItem_"..num];
			elseif idnex == 2 then 
				data = shipinglist[i]
				item = objSwf["peishiItem_"..num];
			end;
			if item and data then 
				item.icon.iconLoader.source = data.iconUrl;
				item.num.htmlText = "(".. data.curnum .. "/" .. data.allGnum .. ")"
				item.icon.id = data.id
				item.icon.pos = data.pos;
				item.icon.lvl = data.lvl;
				for sk=1,2 do 
					local skIcon = item["skil_"..sk];
					local skid = data.skList[sk];
					if skIcon then 
						local cfg = t_passiveskill[toint(skid)];
						if cfg then
							if SkillModel:GetSkillInGroup(cfg.group_id) then
								skIcon.iconLoader.source = ResUtil:GetSkillIconUrl(cfg.icon,"");
							else
								local url = ResUtil:GetSkillIconUrl(cfg.icon,"");
								skIcon.iconLoader.source = ImgUtil:GetGrayImgUrl(url);
							end
							skIcon.id = cfg.id;
							skIcon.lvl = data.lvl;
							
							skIcon.groupId = data.id;
							skIcon.groupNum = data.curnum;
							skIcon.groupLvl = data.lvl;
						end;
					end;
				end;
				item._visible = true;
			elseif item then 
				item._visible = false;
			end;
		end;
	end;	

	----------------------技能
	local sklist = {}
	for da,gdata in pairs(uilistdata) do 
		local gcfg = t_equipgroup[gdata.id];
		if gcfg then 
			for sk=1,gdata.skNum do 
				if gcfg["skill"..sk] then 
					if t_passiveskill[toint(gcfg["skill"..sk])] then
						local vo = {};
						vo.id = gcfg["skill"..sk]
						vo.groupName = gcfg.name;
						vo.desc = t_passiveskill[toint(gcfg["skill"..sk])].name;
						vo.groupQuality = gcfg.quality;
						-- vo.cfg = gcfg;
						-- vo.skcfg = t_passiveskill[gcfg["skill"..sk]]
						table.push(sklist,vo)
					end;
				end;
			end;
		end;
	end;
	local attrStr = "";
	--技能描述
	for sk,sdata in pairs(sklist) do 
		attrStr = attrStr .."<textformat leading='-13' leftmargin='0'><p>";
		attrStr = attrStr .. "<img width='15' height='15' src='" .. ResUtil:GetTipsPointURL() .. "'/>";
		attrStr = attrStr .. "</p></textformat>";
		local quaColor = TipsConsts:GetItemQualityColor(sdata.groupQuality)
		local name = "<font color='"..quaColor.."'>" .. sdata.groupName .. " - " .. sdata.desc .. "</font><br/>" ;
		attrStr = attrStr .. "<textformat leading='7' leftmargin='18'><p>"
		attrStr = attrStr .. name  .. SkillTipsUtil:GetSkillEffectStr(toint(sdata.id))
		attrStr = attrStr .. "</p></textformat>";
	end;
	objSwf.skillDesc.htmlText = attrStr;
end;

---list tips
function UIEquipGroupActivation:OnFangjuItem(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local id = e.id;
	local pos = e.pos;
	local grlvl = e.lvl;
	if not id then return end;
	local vo = {};
	vo.groupId2 = id;
	vo.pos = pos;
	vo.lvl = 0 ;
	--
	local cfg = t_equipgroup[id];
	local posCfg = split(cfg.groupPos,'#');
	local listVo = {};
	if posCfg then 
		for i,info in ipairs(posCfg) do
			local vo = {};
			vo.pos = toint(info)
			local cfg = t_equipgroupextra[toint(info)];
			if not cfg then return end;
			local groupList = split(cfg.groupId,',');
			local index = 0;
			for cc,pp in pairs(groupList) do 
				if toint(pp) == id  then 
					index = cc;
				end;
			end;
			local lvl = EquipModel:GetCuePosIsHaveGroup(vo.pos,index);

			if lvl >= 0 then 
				vo.groupId2 = id;
				vo.lvl = lvl or 0;
			end;
			table.push(listVo,vo)
		end;
	end;
	vo.hideLvl = true;
	vo.groupEList = listVo

	TipsManager:ShowTips( TipsConsts.Type_EquipGroup,vo, TipsConsts.ShowType_Normal,
		TipsConsts.Dir_RightDown );

end

function UIEquipGroupActivation:OnPieshiItem(e)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local id = e.id;
	local pos = e.pos;
	--local grlvl = e.lvl;
	if not id then return end;
	local vo = {};
	vo.groupId2 = id;
	vo.pos = pos;
	vo.lvl = 0;
	--
	local cfg = t_equipgroup[id];
	local posCfg = split(cfg.groupPos,'#');
	local listVo = {};
	if posCfg then 
		for i,info in ipairs(posCfg) do
			local vo = {};
			vo.pos = toint(info)
			local cfg = t_equipgroupextra[toint(info)];
			if not cfg then return end;
			local groupList = split(cfg.groupId,',');
			local index = 0;
			for cc,pp in pairs(groupList) do 
				if toint(pp) == id  then 
					index = cc;
				end;
			end;
			local lvl = EquipModel:GetCuePosIsHaveGroup(vo.pos,index);
			if lvl >= 0 then 
				vo.groupId2 = id;
				vo.lvl = lvl or 0;
			end;
			table.push(listVo,vo)
		end;
	end;
	vo.groupEList = listVo
	vo.hideLvl = true;
	TipsManager:ShowTips( TipsConsts.Type_EquipGroup,vo, TipsConsts.ShowType_Normal,
		TipsConsts.Dir_RightDown );
end

function UIEquipGroupActivation:OnSkilFangjuItem(target,index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local id = target.id
	if not id then return; end
	local groupId = target.groupId;
	local groupNum = target.groupNum;
	local groupLvl = target.groupLvl;
	local cfg = t_equipgrouphuizhang[groupId*100+groupLvl];
	if not cfg then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
		return;
	end
	if groupLvl<cfg.level or groupNum<cfg.posenum then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
		return;
	end
	local t = split(cfg.skill,"#");
	if #t <= 0 then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
		return;
	end
	local skillId = t[index];
	if not skillId or skillId=="" then 
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
	return; end
	skillId = toint(skillId)
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
end

function UIEquipGroupActivation:OnSkilPeishiItem(target,index)
	local objSwf = self.objSwf;
	if not objSwf then return end;
	local id = target.id
	if not id then return; end
	local groupId = target.groupId;
	local groupNum = target.groupNum;
	local groupLvl = target.groupLvl;
	local cfg = t_equipgrouphuizhang[groupId*100+groupLvl];
	if not cfg then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
		return;
	end
	if groupLvl<cfg.level or groupNum<cfg.posenum then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
		return;
	end
	local t = split(cfg.skill,"#");
	if #t <= 0 then
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
		return;
	end
	local skillId = t[index];
	if not skillId or skillId=="" then 
		TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=id,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
	return; end
	skillId = toint(skillId)
	TipsManager:ShowTips(TipsConsts.Type_Skill,{skillId=skillId,condition=false,get=false,unShowLvlUpPrompt = true},TipsConsts.ShowType_Normal,
						TipsConsts.Dir_RightDown);
end