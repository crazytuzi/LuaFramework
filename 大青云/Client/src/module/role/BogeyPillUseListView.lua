--[[
	func: 丹药系统显示丹药预览
	author:houxudong
	date:2016年12月7日 00:54:26
--]]

_G.UIBogeyPilluseListView = BaseUI:new("UIBogeyPilluseListView")

UIBogeyPilluseListView.list = {}
UIBogeyPilluseListView.textInfoList = {}
UIBogeyPilluseListView.fightNum = 0
function UIBogeyPilluseListView:Create( )
	self:AddSWF("bogeyPilluseListView.swf", true, "center");
end

function UIBogeyPilluseListView:OnLoaded(objSwf )
	objSwf.btnClose.click = function() self:CloseClick() end
	objSwf.btnOk.click = function() self:CloseClick() end
	objSwf.scrollbar.scroll = function () self:OnScrollBar()end;
	for i=1,6 do
		local item = objSwf["item"..i];
	end
end

function UIBogeyPilluseListView:OnShow( )
	local objSwf = self.objSwf
	if not objSwf then return end
	self:GetItemData(self.list)
	objSwf.scrollbar:setScrollProperties(6,0,#self.textInfoList-6);
	objSwf.scrollbar.trackScrollPageSize = 6;
	objSwf.scrollbar.position = 0;
	self:ShowList(1);
	self:ShowFight();
	local isShowBar = false
	if #self.textInfoList >= 6 then
		isShowBar = true
	end
	objSwf.scrollbar.upArrow._visible   = isShowBar
	objSwf.scrollbar.thumb._visible     = isShowBar
	objSwf.scrollbar.downArrow._visible = isShowBar
	objSwf.scrollbar.track._visible     = isShowBar
end

function UIBogeyPilluseListView:OnOpen( pillList,num)
	self.list = {}
	for k,v in pairs(pillList) do
		local vo = {}
		vo.id    = v.item_tid;
		vo.num   = v.item_count;
		table.push(self.list,vo)
	end
	self.fightNum = num
	if self:IsShow() then
		self:OnShow()
	else
		self:Show()
	end
end

function UIBogeyPilluseListView:GetItemData(pillList)
	if not pillList then 
		Debug("not find data")
		self:Hide()
		return
	end
	self.textInfoList = {}
	for k,v in pairs(pillList) do
		local vo = {}
		local cfg = t_item[v.id]
		if cfg then
			vo.id   = v.id
			vo.text = string.format("使用<font color = '#00ff00'>%s </font>*%s",cfg.name,v.num)
			local yaoDanCfg = t_yaodan[v.id]
			vo.order = yaoDanCfg and yaoDanCfg.order
			vo.type = yaoDanCfg and yaoDanCfg.type
		end
		table.push(self.textInfoList,vo)
	end
	table.sort( self.textInfoList, function(A,B)
		 local r
		 local order1 = toint(A.order)
		 local order2 = toint(B.order)
		 local type1  = toint(A.type)
		 local type2  = toint(B.type)
		 if order1 == order2 then
		 	r = type1 < type2
		 else
		 	r = order1 < order2
		 end
		 return r
	end )
end


function UIBogeyPilluseListView:CloseClick()
	self:Hide()
end

-- 滑动列表事件
function UIBogeyPilluseListView:OnScrollBar( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local value = objSwf.scrollbar.position
	self:ShowList(value + 1)
end

function UIBogeyPilluseListView:ShowFight( )
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.text_fight.htmlText = string.format("本次提升<font color= '#00ff00' size = '16'>%s</font>战力",self.fightNum)
end

-- 初始化list数据
function UIBogeyPilluseListView:ShowList(value)
	local objSwf = self.objSwf
	if not objSwf then return end
	local index = 1
	index = value + 5
	local  curlist = {}
	if value == 0 then
		value = 1
	end
	for i = value,index do 
		local cvo = {};
		local vo = self.textInfoList[i]
		if vo then
			cvo.text = self.textInfoList[i].text
			table.push(curlist,cvo)
		end
	end
	for i,info in ipairs(curlist) do 
		local item = objSwf["item"..i];
		item.textInfo.htmlText = info.text
	end
end

function UIBogeyPilluseListView:OnHide( )
	self.list = {}
	self.textInfoList = {}
end