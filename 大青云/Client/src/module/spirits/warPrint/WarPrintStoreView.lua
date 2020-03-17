--[[
战印商店
wangshuai
]]

_G.UIWarPrintStore = BaseUI:new("UIWarPrintStore")

UIWarPrintStore.curpage = 0;
function UIWarPrintStore:Create()
	self:AddSWF("spiritWarPrintStore.swf",true,"center")
end;

function UIWarPrintStore:OnLoaded(objSwf)
	objSwf.closepanel.click = function() self:OnClosePanel() end;
	objSwf.storelist.iconRollOver = function(e) self:OnItemOver(e) end;
	objSwf.storelist.iconRollOut  = function() TipsManager:Hide(); end;
	objSwf.storelist.itemClick    = function(e) self:OnItemGomai(e) end;

	objSwf.btnPre.click = function() self:OnPagePre()end; -- 上一个
	objSwf.btnNext.click = function() self:OnPageNext()end; -- 下一个

end;


function UIWarPrintStore:OnShow()
	self:OnShowList();
end;
function UIWarPrintStore:OnItemOver(e)
	local item = e.item;
	if not item then return end;
	local tipsvo = WarPrintUtils:OnGetStoreItemTipsVO(item.tid)
	tipsvo.type = "store";
	TipsManager:ShowTips(TipsConsts.Type_SpiritWarPrint,tipsvo,TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end;

function UIWarPrintStore:OnItemGomai(e)
	local item = e.item;
	if not item then return end;
	--print("购买这个玩意1个。操，item.tid")
	WarPrintController:OnReqStoreItem(item.tid,1)
end;
--  x显示list
function UIWarPrintStore:OnShowList()
	local objSwf = self.objSwf;
	self.allist = WarPrintUtils:OnGetStoreItem();
	local list = WarPrintUtils:GetListPage(self.allist,self.curpage)
	--trace(list)
	objSwf.storelist.dataProvider:cleanUp();
	objSwf.storelist.dataProvider:push(unpack(list));
	objSwf.storelist:invalidateData();
	self:OnSetPageText();
end;


-- ----- ----  翻页符--- --- ---
function UIWarPrintStore:OnSetPageText()
	local objSwf = self.objSwf;
	local curTotal = WarPrintUtils:GetListLenght(self.allist)+1;
	local curpage = self.curpage+1;
	if curpage == 1 then 
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = false;
	elseif curpage >= curTotal then 
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = true;
	elseif curpage ~= 0 and curpage ~= curTotal then 
		objSwf.btnPre.disabled = false;
		objSwf.btnNext.disabled = false;
	end;
	if curTotal <= 1 then 
		objSwf.btnPre.disabled = true;
		objSwf.btnNext.disabled = true;
	end;
	objSwf.txtPage.text = string.format(StrConfig['warprintstore002'],curpage,curTotal)
end;
function UIWarPrintStore:OnPagePre()
	self.curpage = self.curpage - 1;
	self:OnShowList();
end;

function UIWarPrintStore:OnPageNext()
	self.curpage = self.curpage + 1
	self:OnShowList();
end;


function UIWarPrintStore:OnClosePanel()
	self:Hide();
end;

function UIWarPrintStore:OnHide()

end;