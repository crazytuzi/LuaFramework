--[[永久时装
zhangshuhui
2015年1月22日16:57:20
]]

_G.UIFashionsForeverView = BaseSlotPanel:new("UIFashionsForeverView")

--时装列表
UIFashionsForeverView.fashionslists = {};
--列表一页list数量
UIFashionsForeverView.pagelistnum = 4;
--套装的具体部件数量
UIFashionsForeverView.totalsize = 3;
--套装最高等级
UIFashionsForeverView.lvlMax = 5;
--当前显示页数
UIFashionsForeverView.curpageIndex = 0;
--套装总页数
UIFashionsForeverView.pagecount = 0;

function UIFashionsForeverView:Create()
	self:AddSWF("fashionsForeverPanel.swf", true, nil)
end

function UIFashionsForeverView:OnLoaded(objSwf,name)
	--时装列表
	for i=1,self.pagelistnum do
		self.fashionslists[i] = objSwf["listbg"..i];
		self.fashionslists[i].btnPreview.click = function() self:OnBtnPreviewClick(i); end
	end
	
	self:AddSlotItem(BaseItemSlot:new(objSwf.item11),1);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item12),2);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item13),3);
	
	self:AddSlotItem(BaseItemSlot:new(objSwf.item21),4);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item22),5);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item23),6);
	
	self:AddSlotItem(BaseItemSlot:new(objSwf.item31),7);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item32),8);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item33),9);
	
	self:AddSlotItem(BaseItemSlot:new(objSwf.item41),10);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item42),11);
	self:AddSlotItem(BaseItemSlot:new(objSwf.item43),12);
	
	--滚轮事件
	objSwf.scrollBar.scroll = function() self:OnScrollBarscrollClick(); end;
	
	objSwf.listscrollBar.scroll = function() self:OnListScrollBarscrollClick(); end;
	objSwf.listscrollBar._visible = false;
end

function UIFashionsForeverView:OnDelete()
	self:RemoveAllSlotItem();
end

function UIFashionsForeverView:OnShow(name)
	--初始化数据
	self:InitData();
	--显示
	self:ShowForeverList();
   -- 按钮 状态
	self:OnShowStateButton()
end

function UIFashionsForeverView:OnHide()
end

-------------------事件------------------
--点击关闭按钮
function UIFashionsForeverView:OnBtnCloseClick()
	self:Hide();
end

--预览
function UIFashionsForeverView:OnBtnPreviewClick(i)
	local objSwf = self.objSwf;
	if not objSwf then return; end

    local isfashion=FashionsUtil:GetIsCurFashions(i) and 0 or 1;
    if FashionsUtil:GetFashionsGroup(i) then 
        for id,cfg in pairs(t_fashions) do
    	    if cfg.suit==i then
                FashionsController:ReqDressFashion(cfg.id, isfashion);
            end	
    	end
    	return 
    end 
	if UIFashionsMainView and UIFashionsMainView.bShowState then
		local list = FashionsUtil:GetSortFashionsGroupList();
		local listvo = list[i + self.curpageIndex];
		if listvo then
			if FashionsUtil:GetIsCurFashions(listvo.id) == false then
				UIFashionsMainView:PreviewFashions(listvo.id);
			end
		end
	end
end
function UIFashionsForeverView:OnShowStateButton()
	local objSwf = self.objSwf;
	if not objSwf then return; end
    
    for i=1,self.pagelistnum do
		local btn = objSwf["listbg"..i];
		if FashionsUtil:GetFashionsGroup(i) then 
		    btn.btnPreview.htmlLabel=StrConfig["fashions8"]
		else
		    btn.btnPreview.htmlLabel=StrConfig["fashions7"]
		end
	end
end
function UIFashionsForeverView:OnScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.scrollBar.position then
		return;
	end
	if not objSwf.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.scrollBar.position < 0 then
		objSwf.scrollBar.position = 0;
		objSwf.listscrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.scrollBar.position > self.pagecount then
		objSwf.scrollBar.position = self.pagecount;
		objSwf.listscrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.scrollBar.position then
		return;
	end
	
	objSwf.listscrollBar.position = objSwf.scrollBar.position;

	self.curpageIndex = objSwf.scrollBar.position;
	
	self:ShowForeverList();
end

function UIFashionsForeverView:OnListScrollBarscrollClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if not objSwf.scrollBar.position then
		return;
	end
	if not objSwf.listscrollBar.position then
		return;
	end
	
	--下限
	if objSwf.listscrollBar.position < 0 then
		objSwf.scrollBar.position = 0;
		objSwf.listscrollBar.position = 0;
		return;
	end
	
	--上限
	if objSwf.listscrollBar.position > self.pagecount then
		objSwf.scrollBar.position = self.pagecount;
		objSwf.listscrollBar.position = self.pagecount;
		return;
	end
	
	--未变
	if self.curpageIndex == objSwf.listscrollBar.position then
		return;
	end
	objSwf.scrollBar.position = objSwf.listscrollBar.position;

	self.curpageIndex = objSwf.listscrollBar.position;
	
	self:ShowForeverList();
end

function UIFashionsForeverView:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if name == NotifyConsts.FashionsDressInfo then
		self:DoUpdateItem(body);
		
	elseif name == NotifyConsts.FashionsDressAdd then
		self:UpdateItemHaveState(body);
		self:OnShowStateButton()
	end
end

function UIFashionsForeverView:ListNotificationInterests()
	return {NotifyConsts.FashionsDressInfo, NotifyConsts.FashionsDressAdd};
end

function UIFashionsForeverView:InitData()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	local list = FashionsUtil:GetSortFashionsGroupList();
	
	local PageCount = 0;
	for i,vo in pairs(list) do
		if vo then
			PageCount = PageCount + 1;
		end
	end
	
	self.curpageIndex = 0;
	self.pagecount = PageCount - self.pagelistnum;
	if self.pagecount < 0 then
		self.pagecount = 0;
	end
	objSwf.scrollBar.position = 0;
	objSwf.scrollBar.maxPosition = self.pagecount;
	objSwf.scrollBar.minPosition = 0;
	objSwf.scrollBar.pageSize = self.pagelistnum;
	
	--listscroll
	objSwf.listscrollBar.position = 0;
	objSwf.listscrollBar.maxPosition = self.pagecount;
	objSwf.listscrollBar.minPosition = 0;
	objSwf.listscrollBar.pageSize = self.pagelistnum;
end

function UIFashionsForeverView:InitUI()
end

function UIFashionsForeverView:ClearUI()
	for i=1,self.pagelistnum do
		self.fashionslists[i]._visible = false;
		self.fashionslists[i].tfname.htmlLabel = "";
		for lvl=1,self.lvlMax do
			self.fashionslists[i].xingpanel["xing"..lvl].visible = false;
		end
	end
end

--显示列表
function UIFashionsForeverView:ShowForeverList()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	self:ClearUI();
	
	for i=1,self.pagelistnum do
		local index = 0;
		local list = FashionsUtil:GetSortFashionsGroupList();
		for j,vo in pairs(list) do
			if vo then
				index = index + 1;
				
				if i + self.curpageIndex == index then
					self.fashionslists[i]._visible = true;
					--套装名称
					self.fashionslists[i].tfname.htmlText = string.format( StrConfig['fashions1'], vo.name);
					
					local datalist = FashionsUtil:GetForeverlistByGroup(vo.id);
				
					objSwf["fashionslist"..i].dataProvider:cleanUp();
					objSwf["fashionslist"..i].dataProvider:push(unpack(datalist));
					objSwf["fashionslist"..i]:invalidateData();
					--星级
					self:ShowLvl(i,vo.id);
					break;
				end
			end
		end
	end
end

function UIFashionsForeverView:ShowLvl(index,groupid)
	if t_fashiongroup[groupid] then
		local lvl = t_fashiongroup[groupid].lvl;
		if lvl then
			for i=1,lvl do
				self.fashionslists[index].xingpanel["xing"..i].visible = true;
			end
		end
	end
end

function UIFashionsForeverView:DoUpdateItem(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	for i=1,self.pagelistnum do
		local index = 0;
		local list = FashionsUtil:GetSortFashionsGroupList();
		for j,vo in pairs(list) do
			if vo then
				index = index + 1;
				if i + self.curpageIndex == index then
					local id = FashionsUtil:GettidByGroupId(vo.id, body.pos);
					if id == body.tid or id == body.oldId then
						objSwf["fashionslist"..i].dataProvider[body.pos - 1] = FashionsUtil:GetUIData(id, body.pos);
						local uiSlot = objSwf["fashionslist"..i]:getRendererAt(body.pos - 1);
						if uiSlot then
							uiSlot:setData(FashionsUtil:GetUIData(id, body.pos));
						end
					end
					break;
				end
			end
		end
	end
end

function UIFashionsForeverView:UpdateItemHaveState(body)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	
	if body.time ~= -1 then
		return;
	end
	
	--得到装备位
	local pos = 0;
	if t_fashions[body.tid] then
		pos = t_fashions[body.tid].pos;
	end
	
	for i=1,self.pagelistnum do
		local index = 0;
		local list = FashionsUtil:GetSortFashionsGroupList();
		for j,vo in pairs(list) do
			if vo then
				index = index + 1;
				if i + self.curpageIndex == index then
					local id = FashionsUtil:GettidByGroupId(vo.id, pos);
					if id == body.tid then
						objSwf["fashionslist"..i].dataProvider[pos - 1] = FashionsUtil:GetUIData(id, pos);
						local uiSlot = objSwf["fashionslist"..i]:getRendererAt(pos - 1);
						if uiSlot then
							uiSlot:setData(FashionsUtil:GetUIData(id, pos));
						end
					end
					break;
				end
			end
		end
	end
end

function UIFashionsForeverView:OnItemRollOver(item)
	local data = item:GetData();
	if not data then
		return;
	end
	if not data.hasItem then
		return;
	end
	local cfg = t_fashions[data.tid];
	if not cfg then return; end
	cfg.lastTime = -1;
	TipsManager:ShowTips(TipsConsts.Type_Fanshion,{cfg=cfg},TipsConsts.ShowType_Normal,TipsConsts.Dir_RightDown);
end

function UIFashionsForeverView:OnItemRollOut(item)
	TipsManager:Hide();
end

function UIFashionsForeverView:OnItemDragBegin(item)
	
end

function UIFashionsForeverView:OnItemDragin(item)
	
end

function UIFashionsForeverView:OnItemClick(item)
	
end

function UIFashionsForeverView:OnItemDoubleClick(item)
	local data = item:GetData();
	if not data then
		return;
	end
	if not data.hasItem  then
		return;
	end
	if not data.lightState  then
		FloatManager:AddNormal( StrConfig["fashions2"] );
		return;
	end
	if data.zhuangbanState == true then
		FashionsController:ReqDressFashion(data.tid, 0);
	else
		FashionsController:ReqDressFashion(data.tid, 1);
	end
end

function UIFashionsForeverView:OnItemRClick(item)
	local data = item:GetData();
	if not data then
		return;
	end
	if not data.hasItem  then
		return;
	end
	if not data.lightState  then
		FloatManager:AddNormal( StrConfig["fashions2"] );
		return;
	end
	if data.zhuangbanState == true then
		FashionsController:ReqDressFashion(data.tid, 0);
	else
		FashionsController:ReqDressFashion(data.tid, 1);
	end
end

