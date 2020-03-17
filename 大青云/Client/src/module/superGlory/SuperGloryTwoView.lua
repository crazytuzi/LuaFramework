--[[
至尊王城二级面板
wangshuai
]]
_G.UISuperGloryTwo = BaseUI:new("UISuperGloryTwo")

UISuperGloryTwo.showType = 1; 
UISuperGloryTwo.curPage = 0;
UISuperGloryTwo.allList = {};
function UISuperGloryTwo:Create()
	self:AddSWF("superGloryTwoPanel.swf",true,nil)
end;

function UISuperGloryTwo:OnLoaded(objSwf)
	objSwf.panel1.closebtn.click = function() self:Closepanel() end;
	objSwf.panel2.closebtn.click = function() self:Closepanel() end;
	objSwf.panel1.SendReward.click = function() self:GoSendReward()end;

	for i=1,10 do
		objSwf.panel2["item"..i].inputtxt.textChange = function() self:InputTxtOver(i,objSwf.panel2["item"..i].inputtxt.text) end;
	end;

	objSwf.panel2.bothBtn.click = function() self:SetBothReward()end;

	--bjSwf.panel2.btnPre1.click = function() self:PagePre1()end; -- 前
	-- objSwf.panel2.btnNext1.click = function() self:PageNext1()end; -- 后
	objSwf.panel2.btnPre.click = function() self:PagePre()end; -- 上一个
	objSwf.panel2.btnNext.click = function() self:PageNext()end; -- 下一个

	objSwf.panel2.upRewardNum.click = function() self:UpRewardNumClick() end;
end;
function UISuperGloryTwo:UpRewardNumClick()
	if #self.allList <= 0 then
		return 
	end;
	local list = {};
	for i,info in ipairs(self.allList) do 
		local vo = {};
		vo.roleID = info.roleID;
		vo.num    = info.rewardnum;
		table.push(list,vo)
	end;
	-- trace(list)
	SuperGloryController:ReqSuperGlorySendBagUp(list)
--	FloatManager:AddNormal(StrConfig['SuperGlory803']);
	local objSwf = self.objSwf;
	objSwf.panel2.rewardnum.text = self:GetCurRewardNum();
end;
-- 均分礼包
function UISuperGloryTwo:SetBothReward()
	for i,info in ipairs(self.allList) do 
		info.rewardnum = 0;
	end;
	local rewardnum = SuperGloryModel:GetRewardNum();
	local unionRoleNum = #self.allList;

	local num = toint(rewardnum / unionRoleNum);
	for i=1,num do 
		for i,info in ipairs(self.allList) do 
			info.rewardnum = info.rewardnum + 1;
		end;
	end;
	local yushu = rewardnum - ( num * #self.allList);
	for i=1,yushu do 
		self.allList[i].rewardnum = self.allList[i].rewardnum + 1;
	end;

	self:SetUnionList();

end;
function UISuperGloryTwo:InputTxtOver(i,txt) 
	local objSwf = self.objSwf;
	local inttxt = tonumber(txt);
	if not inttxt then 
		inttxt = 0;
	 end;
	local index = 0;
	if i == 10 then 
		index = tonumber((self.curPage+1).."0")
	elseif i < 10 and i >= 0 then
		index = tonumber(self.curPage..i);
	end;
	if self.allList[index] then 
		self.allList[index].rewardnum = 0;
	end;

	local curNum = self:GetCurRewardNum();
	if inttxt > curNum then 
		inttxt = curNum;
	end;

	self.allList[index].rewardnum = inttxt;
	objSwf.panel2["item"..i].inputtxt.text = tostring(inttxt);

end;

function UISuperGloryTwo:OnShow()
	local objSwf = self.objSwf;
	if not self.showType then 
		self:Hide();
		return 
	end;
	if self.showType == 1 then 
		-- panelOne
		self:ShowPanelOne()
	elseif self.showType == 2 then 
		-- panelTwo 
		self:ShowPanelTwo();
	end;
	
end;

-- 得到当前设置总数量
function UISuperGloryTwo:GetCurRewardNum()
	local maxRewardnum = SuperGloryModel:GetRewardNum();
	local num = 0;
	for i,info in ipairs(self.allList) do 
		if info.rewardnum then 
			num = num + info.rewardnum;
		end;
	end;
	return maxRewardnum;
end;

function UISuperGloryTwo:OnHide()

end;

function UISuperGloryTwo:ShowPanel(type)
	self.showType = type;
end;
 --显示发放礼包界面
function UISuperGloryTwo:ShowPanelOne()
	local objSwf = self.objSwf
	objSwf.panel1._visible = true;
	objSwf.panel2._visible = false;

	objSwf.panel1.libaoNum.num =  SuperGloryModel:GetRewardNum();--self:GetCurRewardNum();
end;
-- 设置礼包数据界面
function UISuperGloryTwo:ShowPanelTwo()
	local objSwf = self.objSwf;
	objSwf.panel1._visible = false;
	objSwf.panel2._visible = true;
	self:SetUnionList();
	
	local curNum = self:GetCurRewardNum();
	objSwf.panel2.rewardnum.text = curNum;

end;

function UISuperGloryTwo:SetUnionList()
	self.allList = SuperGloryModel:GetSuperGloryUnionRoleinfo();
	local rolelist = SuperGloryModel:GetListPage(self.allList,self.curPage)
	local objSwf = self.objSwf;
	for i=1,10 do 
		local item = objSwf.panel2["item"..i];
		item:setData({});
	end;
	for i=1,#rolelist do 
		local item = objSwf.panel2["item"..i];
		local vo = {};
		vo.name = rolelist[i].roleName;
		vo.pos = t_guildtitle[rolelist[i].pos].posname;
		vo.lvl = rolelist[i].lvl;
		vo.roleid = rolelist[i].roleID;
		vo.rewardnum = rolelist[i].rewardnum;
		item:setData(UIData.encode(vo));
	end;

	self:SetPagebtn();
end;

function UISuperGloryTwo:Closepanel()
	self:Hide()
end;

-- 发放奖励
function UISuperGloryTwo:GoSendReward()
	local isSuperman = SuperGloryModel:GetIsDuke();
	if isSuperman ~= 1 then 
		FloatManager:AddNormal(StrConfig['SuperGlory801']);
		return 
	end;
	SuperGloryController:ReqSuperGlorySendBag()
	self:ShowPanelTwo();
end;

-- 最前
function UISuperGloryTwo:PagePre1()
	local objSwf = self.objSwf;
	self.curPage = 0;
	self:SetUnionList()
end;
-- 前
function UISuperGloryTwo:PagePre()
	local objSwf = self.objSwf;
	self.curPage = self.curPage-1;
	self:SetUnionList()
end;
-- 最后
function UISuperGloryTwo:PageNext1()
	local objSwf = self.objSwf;
	local len = SuperGloryModel:GetListLenght(self.allList)
	self.curPage = len;
	self:SetUnionList()
end;
-- 后
function UISuperGloryTwo:PageNext()
	local objSwf =self.objSwf;
	self.curPage = self.curPage+1;
	local len = SuperGloryModel:GetListLenght(self.allList)
	self:SetUnionList()
end;

function UISuperGloryTwo:SetPagebtn()
	local objSwf = self.objSwf;
	local len = SuperGloryModel:GetListLenght(self.allList) + 1
	local curPage = self.curPage+1;
	local curTotal = SuperGloryModel:GetListLenght(self.allList)+1;
	objSwf.panel2.txtPage.text = string.format(StrConfig["SuperGlory802"],curPage,curTotal)
	if curPage == 1 then 
		objSwf.panel2.btnPre.disabled = true;
		objSwf.panel2.btnNext.disabled = false;
	elseif curPage >= tonumber(len) then 
		objSwf.panel2.btnPre.disabled = false;
		objSwf.panel2.btnNext.disabled = true;
	elseif curPage ~= 0 and curPage ~= len then 
		objSwf.panel2.btnPre.disabled = false;
		objSwf.panel2.btnNext.disabled = false;
	end;
	if len <= 1 then 
		objSwf.panel2.btnPre.disabled = true;
		objSwf.panel2.btnNext.disabled = true;
	end;
end;

	-- notifaction
function UISuperGloryTwo:ListNotificationInterests()
	return {
		NotifyConsts.SuperGloryUnionRoleList,
		NotifyConsts.SuperGloryAllInfo,
		}
end;
function UISuperGloryTwo:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.SuperGloryUnionRoleList then
			self:SetUnionList()
	elseif name == NotifyConsts.SuperGloryAllInfo then 
		self:ShowPanelTwo();
	end;
end;
