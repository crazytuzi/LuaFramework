--[[
跨服擂台鼓舞
liyuan
]]

_G.UIInterContestGuwu = BaseUI:new("UIInterContestGuwu");
UIInterContestGuwu.showNum = 10
UIInterContestGuwu.currentPage = 1
UIInterContestGuwu.totalPage = 1

UIInterContestGuwu.xiazhuId = '0_0'

function UIInterContestGuwu:Create()
	self:AddSWF("interContestXiazhu.swf", true, "center");
end

function UIInterContestGuwu:OnLoaded(objSwf)
	objSwf.btnClose.click = function()
		self:Hide()
	end
	objSwf.listtxt.xiazhuItemClick = function(e) 
		if InterContestModel.xiazhuID ~= '0_0' then
			FloatManager:AddNormal( StrConfig['interServiceDungeon204'] )
			return
		end
		UIInterContestGuwu.xiazhuId = e.item.id
		FPrint('下注的id:'..e.item.id)
		if UIInterContestXiazhuDialog:IsShow() then
			UIInterContestXiazhuDialog:UpdateInfo()
		else
			UIInterContestXiazhuDialog:Show()
		end
		-- if UIInterContestGuwuDialog:IsShow() then
			-- UIInterContestGuwuDialog:Hide()
		-- end
	end
	-- objSwf.listtxt.guwuItemClick = function(e) 
		-- UIInterContestGuwu.guwuId = e.item.id
		-- FPrint('鼓舞的id:'..e.item.id)
		-- if UIInterContestGuwuDialog:IsShow() then
			-- UIInterContestGuwuDialog:UpdateInfo()
		-- else
			-- UIInterContestGuwuDialog:Show()
		-- end
		-- if UIInterContestXiazhuDialog:IsShow() then
			-- UIInterContestXiazhuDialog:Hide()
		-- end
	-- end
	
	objSwf.btnPre.click = function()
		local objSwf = self.objSwf;
		if not objSwf then return; end	
		self.currentPage = self.currentPage - 1
		self:UpdatePageState()
		self:UpdateInfo()
	end
	objSwf.btnPre1.click = function()
		self.currentPage = 1
		self:UpdatePageState()
		self:UpdateInfo()
	end
	objSwf.btnNext.click = function()
		self.currentPage = self.currentPage + 1
		self:UpdatePageState()
		self:UpdateInfo()
	end
	objSwf.btnNext1.click = function()
		self.currentPage = UIInterContestGuwu.totalPage
		self:UpdatePageState()
		self:UpdateInfo()
	end
end

-----------------------------------------------------------------------
function UIInterContestGuwu:IsTween()
	return false;
end

function UIInterContestGuwu:GetPanelType()
	return 0;
end

function UIInterContestGuwu:IsShowSound()
	return false;
end

function UIInterContestGuwu:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	self.currentPage = 1
	self:UpdateInfo()	
end

function UIInterContestGuwu:UpdateInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	local list = InterContestModel.xiazhuRankList
	if not list then return end
	
	local voc = {}
	local startIndex = (self.currentPage - 1)*UIInterContestGuwu.showNum + 1	
	local endIndex = startIndex + UIInterContestGuwu.showNum - 1
	if endIndex > #InterContestModel.xiazhuRankList then
		endIndex = #InterContestModel.xiazhuRankList
	end
	print(startIndex, endIndex)
	local allxiazhucnt = 0;
	for i = startIndex, endIndex do
		local item = self:GetItem(i)
		FPrint('取item'..i)
		if item then
			FPrint('获得item'..item.roleName)
			if item.xiazhucnt > 10000 then
				local showcunt = math.floor(item.xiazhucnt/10000)
				item.showcunt = string.format(StrConfig['interServiceDungeon69'], showcunt)..StrConfig['interServiceDungeon71']
			else
				item.showcunt = string.format(StrConfig['interServiceDungeon69'], item.xiazhucnt)
			end
			if InterContestModel.xiazhuID ~= '0_0' then
				item.xiazhu = InterContestModel.xiazhuID == item.id ;
			else
				item.xiazhu = false;
			end
			item.showguwu = string.format(StrConfig['interServiceDungeon70'], item.guwucnt)
			table.push(voc, UIData.encode(item))
			
		end
	end
	
	for k,v in pairs(list) do
		allxiazhucnt = allxiazhucnt + v.xiazhucnt;
	end

	objSwf.listtxt.dataProvider:cleanUp();
	objSwf.listtxt.dataProvider:push(unpack(voc));
	objSwf.listtxt:invalidateData();
	self:UpdatePageState()
	objSwf.txt_allxiazhu.htmlText = string.format(StrConfig['interServiceDungeon303'],getNumShow(allxiazhucnt));
end

function UIInterContestGuwu:UpdatePageState()
	local objSwf = self.objSwf;
	if not objSwf then return; end	
	
	objSwf.btnPre.disabled = false
	objSwf.btnPre1.disabled = false
	objSwf.btnNext.disabled = false
	objSwf.btnNext1.disabled = false
	if self.currentPage <= 1 then		
		objSwf.btnPre.disabled = true
		objSwf.btnPre1.disabled = true
		self.currentPage = 1
	end	
	if self.currentPage >= UIInterContestGuwu.totalPage then
		objSwf.btnNext.disabled = true
		objSwf.btnNext1.disabled = true
		self.currentPage = UIInterContestGuwu.totalPage
	end
	
	objSwf.txtPage.text = self.currentPage ..'/'..UIInterContestGuwu.totalPage
end

function UIInterContestGuwu:GetItem(index)
	if index and index > 0 and index <= #InterContestModel.xiazhuRankList then
		local item = InterContestModel.xiazhuRankList[index]
		if item and item.id ~= '0_0' then
			return InterContestModel.xiazhuRankList[index]
		end
	end
	
	return nil	
end

function UIInterContestGuwu:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	InterContestModel.xiazhuID = '0_0';
	if UIInterContestXiazhuDialog:IsShow() then
		UIInterContestXiazhuDialog:Hide()	
	end
	objSwf.txt_allxiazhu.text = '';
end

function UIInterContestGuwu:GetWidth()
	return 969;
end

function UIInterContestGuwu:GetHeight()
	return 675;
end

function UIInterContestGuwu:OnBtnCloseClick()
	self:Hide();
end

function UIInterContestGuwu:OnDelete()
	
end

---------------------------------消息处理------------------------------------
--监听消息列表
function UIInterContestGuwu:ListNotificationInterests()
	return {
		
	};
end

--处理消息
function UIInterContestGuwu:HandleNotification(name, body)
	
end

