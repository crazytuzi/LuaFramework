--[[帮派祈福面板
zhangshuhui
2015年5月15日14:16:16
]]

_G.UIUnionPrayView = BaseUI:new("UIUnionPrayView")

UIUnionPrayView.praytypelist = {};

function UIUnionPrayView:Create()
	self:AddSWF("unionPrayPanel.swf", true, "center")
end

function UIUnionPrayView:OnLoaded(objSwf,name)
	--关闭
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end;
	
	objSwf.btnputong.click     	= function() self:OnBtnPuTongClick(); end;
	objSwf.btngaoji.click     	= function() self:OnBtnGaoJiClick(); end;
	objSwf.btnzhizun.click  = function() self:OnBtnZhiZunClick(); end;
end

function UIUnionPrayView:IsShowLoading()
	return true;
end

function UIUnionPrayView:GetPanelType()
	return 0;
end

function UIUnionPrayView:IsShowSound()
	return true;
end
function UIUnionPrayView:ESCHide()
	return true;
end
function UIUnionPrayView:GetWidth()
	return 767;
end

function UIUnionPrayView:GetHeight()
	return 552;
end

--function UIUnionPrayView:BeforeTween()
	-- local func = FuncManager:GetFunc(FuncConsts.Role);
	-- if not func then return; end
	-- self.tweenStartPos = func:GetBtnGlobalPos();
--end

function UIUnionPrayView:OnShow(name)
	--请求获得帮派祈福
	UnionController:ReqGetUnionPray();
	--初始化数据
	self:InitData();
	--初始化UI
	self:InitUI();
	--显示
	self:ShowPrayList();
	--显示按钮
	self:UpdatePrayBtn();
	--祈福类型信息
	self:ShowPrayTypeInfo();
	self:DisposeDummy();
	for i = 1, 3 do
		self:DrawDummy(i)
	end
end

--打开面板
function UIUnionPrayView:OpenPanel()
	if self:IsShow() then
		self:Hide();
	end
	self:Show();
end

local viewPort = nil;
local t = {
"v_ui_bangpai_jiangziya.sen",
"v_ui_bangpai_wuwang.sen",
"v_ui_bangpai_taiyizhenren.sen"
}
function UIUnionPrayView:DrawDummy(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if not self.drawList then self.drawList = {} end
	if not self.drawList[i] then self.drawList[i] = {} end
	local drawList = self.drawList[i]
	if not drawList.objUIDraw then
		if not viewPort then viewPort = _Vector2.new(500, 500); end
		drawList.objUIDraw = UISceneDraw:new( "UIUnionPrayViewDummy"..i, objSwf["avatarLoader"..i], viewPort );
	end
	drawList.objUIDraw:SetUILoader(objSwf["avatarLoader"..i]);

	drawList.objUIDraw:SetScene(t[i]);
	drawList.objUIDraw:SetDraw( true );
end
function UIUnionPrayView:DisposeDummy()
	if self.drawList then
		for i = 1, 3 do
			if self.drawList[i] then
				if self.drawList[i].objUIDraw then
					self.drawList[i].objUIDraw:SetDraw(false);
				end
			end
		end
	end
end
function UIUnionPrayView:OnHide()
	self:DisposeDummy()
end

--点击关闭按钮
function UIUnionPrayView:OnBtnCloseClick()
	self:Hide();
end

function UIUnionPrayView:OnBtnPuTongClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local praycfg = t_guildpray[1];
	if praycfg then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaBindGold + playerinfo.eaUnBindGold < praycfg.cost_count then
			FloatManager:AddNormal( StrConfig["unionPray002"], objSwf.btnputong);
			return;
		end
		
		UnionController:ReqUnionPray(1);
	end
end
function UIUnionPrayView:OnBtnGaoJiClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local praycfg = t_guildpray[2];
	if praycfg then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaUnBindMoney < praycfg.cost_count then
			FloatManager:AddNormal( StrConfig["unionPray003"], objSwf.btngaoji);
			return;
		end
		
		UnionController:ReqUnionPray(2);
	end
end
function UIUnionPrayView:OnBtnZhiZunClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local praycfg = t_guildpray[3];
	if praycfg then
		local playerinfo = MainPlayerModel.humanDetailInfo;
		if playerinfo.eaUnBindMoney < praycfg.cost_count then
			FloatManager:AddNormal( StrConfig["unionPray003"], objSwf.btnzhizun);
			return;
		end
		
		UnionController:ReqUnionPray(3);
	end
end
	
-------------------事件------------------

function UIUnionPrayView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.UnionPrayRefresh then
		--显示
		self:ShowPrayList();
		--显示按钮
		self:UpdatePrayBtn();
	end
end

function UIUnionPrayView:ListNotificationInterests()
	return {NotifyConsts.UnionPrayRefresh};
end

function UIUnionPrayView:InitData()
	self.praytypelist = {};
	for i,vo in ipairs(t_guildpray) do
		table.push(self.praytypelist,vo);
	end
	
	table.sort(self.praytypelist,function(A,B)
		if A.id < B.id then
			return true;
		else
			return false;
		end
	end);
end

function UIUnionPrayView:InitUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

function UIUnionPrayView:ClearUI()
	local objSwf = self.objSwf;
	if not objSwf then return; end
end

--显示列表
function UIUnionPrayView:ShowPrayList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local strtime = "";
	local strinfo = "";
	
	local list = UnionModel:GetPrayList();
	
	local isfirst = true;
	for i,vo in ipairs(list) do
		if isfirst == true then
			isfirst = false;
			strtime = self:GetTimeFormat(vo.time);
			strinfo = self:GetRoleProyInfo(vo.roleName, vo.prayid);
		else
			strtime = strtime.."<br/>"..self:GetTimeFormat(vo.time);
			strinfo = strinfo.."<br/>"..self:GetRoleProyInfo(vo.roleName, vo.prayid);
		end
	end
	
	objSwf.tftime.htmlText = strtime;
	objSwf.tfcontent.htmlText = strinfo;
end

--得到时间
function UIUnionPrayView:GetTimeFormat(_time)
	local nowTime = GetServerTime();
	if not _time then _time = 0 end
	local day,hour,min = CTimeFormat:sec2formatEx(nowTime - _time);
	if day > 0 then 
		return day .. "天前";
	elseif hour > 0 then 
		return hour .. "小时前";
	elseif min > 0 then
		return min .. "分钟前";
	else
		return "刚刚";
	end
end

--祈福文本信息
function UIUnionPrayView:GetRoleProyInfo(roleName, prayid)
	local praycfg = t_guildpray[prayid];
	if praycfg then
		return string.format(StrConfig["unionPray001"],roleName,praycfg.name,praycfg.banggong,praycfg.huoyuedu);
	end
	
	return "";
end

--显示按钮
function UIUnionPrayView:UpdatePrayBtn()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	objSwf.btnputong.disabled = true;
	objSwf.btngaoji.disabled = true;
	objSwf.btnzhizun.disabled = true;
	if UnionModel:GetIsPray1() == 0 then
		objSwf.btnputong.disabled = false;
	end
	if UnionModel:GetIsPray2() == 0 then
		objSwf.btngaoji.disabled = false;
	end
	if UnionModel:GetIsPray3() == 0 then
		objSwf.btnzhizun.disabled = false;
	end
end

--显示祈福类型
function UIUnionPrayView:ShowPrayTypeInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i,vo in ipairs(self.praytypelist) do
		objSwf["tfbanggong"..vo.id].text = "+ "..vo.banggong;
		objSwf["tfhuoyue"..vo.id].text = "+ "..vo.huoyuedu;
		objSwf["tfcost"..vo.id].text = vo.cost_count;
	end
end