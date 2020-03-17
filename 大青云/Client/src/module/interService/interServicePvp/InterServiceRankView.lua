--[[
排行界面
]]

_G.UIInterServiceRanking = BaseUI:new("UIInterServiceRanking");

UIInterServiceRanking.curPage = 0;
UIInterServiceRanking.curList = {};
UIInterServiceRanking.onePage = 10;
function UIInterServiceRanking:Create()
	self:AddSWF("interServerRanklistPanel.swf", true, "top");
end;
function UIInterServiceRanking:OnLoaded(objSwf)	
	objSwf.btnClose.click = function() self:CloseClick() end
	objSwf.btnPre1.click = function() self:PagePre1() end
	objSwf.btnPre.click = function() self:PagePre() end
	objSwf.btnNext.click = function() self:PageNext() end
	objSwf.btnNext1.click = function() self:PageNext1() end
	objSwf.mcNonPanel._visible = false;
	objSwf.mcNonPanel.textField.htmlText = StrConfig["interServiceDungeon11"];
	objSwf.txtPage.text = '1/1'
end;
function UIInterServiceRanking:OnShow()
	self:JumpTabe()
end;

function UIInterServiceRanking:OnHide()
	
end;

function UIInterServiceRanking:CloseClick()
	self:Hide();
end;

-- 跳转到需要显示的界面
function UIInterServiceRanking:JumpTabe()
	local objSwf = self.objSwf;	
	if not objSwf then 
		return 
	end;

	self.curPage = 0;	
	if self:IsShow() then 			
		InterServicePvpController:ReqKuafuRankDuanweiList(1);
	end;
end;

-- 显示初始化list
function UIInterServiceRanking:ShowInitList()
	local objSwf = self.objSwf;	if not objSwf then return end
	-- 清空数据
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack({}));
	objSwf.listtxt:invalidateData();

	self.curList = InterServicePvpModel:GetInterServiceRankList()
	local lisc = self:GetListPage(self.curList,self.curPage);
	-- FTrace(lisc)
	if not lisc then return end;
	local voc = {}
	for i,info in ipairs(lisc) do
		local vo = self:GetRoleItemUIdata(info,10)
		if not vo then break end;
		table.push(voc,vo)
	end;
	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(voc));
	objSwf.listtxt:invalidateData();
	-- 设置当前已经是最前
	self:SetPagebtn();
	--
	if #lisc == 0 then
		objSwf.mcNonPanel._visible = true;
	else
		objSwf.mcNonPanel._visible = false;
	end
end;

---翻页控制
-- 最前
function UIInterServiceRanking:PagePre1()
	local objSwf = self.objSwf;	if not objSwf then return end
	self.curPage = 0;
	UIInterServiceRanking:ShowInitList()
end;
-- 前
function UIInterServiceRanking:PagePre()
	local objSwf = self.objSwf;	if not objSwf then return end
	self.curPage = self.curPage-1;
	UIInterServiceRanking:ShowInitList()
end;
-- 最后
function UIInterServiceRanking:PageNext1()
	local objSwf = self.objSwf;	if not objSwf then return end
	local len = RankListUtils:GetListLenght(self.curList)
	self.curPage = len;
	UIInterServiceRanking:ShowInitList()
end;
-- 后
function UIInterServiceRanking:PageNext()
	local objSwf = self.objSwf;	if not objSwf then return end
	self.curPage = self.curPage+1;
	local len = RankListUtils:GetListLenght(self.curList)
	UIInterServiceRanking:ShowInitList()
end;

-- 得到当前页数下的itemlist
function UIInterServiceRanking:GetListPage(list,page)
	local vo = {};
	page = page + 1;
	for i=(self.onePage*page)-self.onePage+1,(self.onePage*page) do 
		table.push(vo,list[i])
	end;
	return vo
end;

function UIInterServiceRanking:GetRoleItemUIdata(info)
	if not info then return end;
	
	local vo = {};
	vo.roleid = info.roleid;
	vo.prof = info.role;
	vo.roleName = info.roleName;
	vo.roleLvl = info.lvl;
	vo.vipLvl  = info.vipLvl;
	local vipStr = ResUtil:GetVIPIcon(info.vipLvl);
	if vipStr and vipStr ~= "" then 
		vipStr = "<img src='"..vipStr.."'/>";
		vo.roleName = vipStr .. vo.roleName;
	end;
	-- local vflagStr = ResUtil:GetVIcon(info.vflag);
	-- if vflagStr and vflagStr ~= "" then 
		-- vflagStr = "<img src='"..vflagStr.."'/>";
		-- vo.roleName = vflagStr..vo.roleName;
	-- end;
	vo.isFirst = false;
	if info.rank == 3 then 
		vo.rank = "c";
		vo.isFirst = true;
	elseif info.rank == 2 then 
		vo.rank = "b";
		vo.isFirst = true;
	elseif info.rank == 1 then 
		vo.rank = "a";
		vo.isFirst = true;
	else 
		vo.rank = info.rank;
		vo.isFirst = false;
	end;
	vo.head = ResUtil:GetHeadIcon60(info.role)	
	FPrint(vo.head)
	vo.rankvlue = InterServicePvpModel:GetMyDuanwei(info.rankvlue)
	vo.fight = '积分:'..info.fight
	
	if info.role <= 0 or info.role > 4 then 
		print("*******Error********：abot roleType is nil . No ShowList   AT  ranklistSuitview  '119' line")
		return 
	end;	
	return UIData.encode(vo)
end;

function UIInterServiceRanking:SetPagebtn()
	local objSwf = self.objSwf;	if not objSwf then return end
	local curpage = self.curPage+1;
	local curTotal = RankListUtils:GetListLenght(self.curList)+1;
	if curTotal < 1 then curTotal = 1 end
	objSwf.txtPage.text = string.format(StrConfig["rankstr004"],curpage,curTotal)
	if curpage == 1 then 
		objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = false;
		objSwf.btnNext1.disabled = false;
	elseif curpage >= curTotal then 
		objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = true;
		objSwf.btnNext1.disabled = true;
	elseif curpage ~= 0 and curpage ~= curTotal then 
		objSwf.btnPre1.disabled = false;
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = false;
		objSwf.btnNext1.disabled = false;
	end;
	if curTotal <= 1 then 
		objSwf.btnPre1.disabled = true;
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = true;
		objSwf.btnNext1.disabled = true;
	end;
end;

------ 消息处理 ---- 
function UIInterServiceRanking:ListNotificationInterests()
	return {
		NotifyConsts.InterServerPvpListUpdata,
		}
end;
function UIInterServiceRanking:HandleNotification(name,body)
	if not self.bShowState then return; end  -- 关闭等于False
	if name == NotifyConsts.InterServerPvpListUpdata then 
		self:ShowInitList();
	end;

end;