require "Core.Module.Common.UISubPanel";
require "Core.Module.Rank.View.Item.RankListSimpleItem"

RankPanelSimpleCtrl = class("RankPanelSimpleCtrl", UISubPanel)
RankPanelSimpleCtrl.fn = 10;
RankPanelSimpleCtrl.MaxPage = 20;

function RankPanelSimpleCtrl:_InitReference()
	
	self._trsTitle = UIUtil.GetChildByName(self._transform, "Transform", "trsTitle");
	--self._txtTitle1 = UIUtil.GetChildByName(self._trsTitle, "UILabel", "txtTitle1");
	self._txtTitle2 = UIUtil.GetChildByName(self._trsTitle, "UILabel", "txtTitle2");
	self._txtTitle3 = UIUtil.GetChildByName(self._trsTitle, "UILabel", "txtTitle3");
	
	self._trsList = UIUtil.GetChildByName(self._transform, "Transform", "trsList");
	self._scrollView = UIUtil.GetComponent(self._trsList, "UIScrollView");
	self._scrollPanel = UIUtil.GetComponent(self._trsList, "UIPanel");
	self._phalanxInfo = UIUtil.GetChildByName(self._trsList, "LuaAsynPhalanx", "phalanx");
	self._phalanx = Phalanx:New();
	self._phalanx:Init(self._phalanxInfo, RankListSimpleItem);
	
	self._trsMyRankSimple = UIUtil.GetChildByName(self._transform, "Transform", "trsMySimple");
	self._myRankSimple = RankListSimpleItem:New();
	self._myRankSimple:Init(self._trsMyRankSimple);
	
	self._trsOpt = UIUtil.GetChildByName(self._transform, "Transform", "trsOpt");
	self._btnSend = UIUtil.GetChildByName(self._trsOpt, "UIButton", "btnSend");
	self._txtNum = UIUtil.GetChildByName(self._trsOpt, "UILabel", "titileNum/txtNum");
	self._txtDesc = UIUtil.GetChildByName(self._trsOpt, "UILabel", "titileNum/txtDesc");
	self._txtCount = UIUtil.GetChildByName(self._trsOpt, "UILabel", "titileCount/txtCount");
	self._trsRoleParent = UIUtil.GetChildByName(self._trsOpt, "Transform", "imgRole/heroCamera/trsRoleParent");
	self._trsPetParent = UIUtil.GetChildByName(self._trsOpt, "Transform", "imgRole/heroCamera/trsPetParent");
	
	self._trsOptLeader = UIUtil.GetChildByName(self._trsOpt, "Transform", "trsLeader");
	self._txtLeader = UIUtil.GetChildByName(self._trsOptLeader, "UILabel", "txtLeader");
	self._icoLeader = UIUtil.GetChildByName(self._trsOptLeader, "UISprite", "icoLeader");
	self._icoLeaderVip = UIUtil.GetChildByName(self._trsOptLeader, "UISprite", "icoLeaderVip");
	
	self._onClickBtnSend = function(go) self:_OnClickBtnSend() end
	UIUtil.GetComponent(self._btnSend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnSend);
	
	self.callBack = function() self:_onDragScrollView() end;
	self._scrollView.onDragFinished = self.callBack;
	
	self._type = nil;
end

function RankPanelSimpleCtrl:_DisposeReference()
	
	self._phalanx:Dispose();
	self._myRankSimple:Dispose();
	
	if self._uiAnimationModel then
		self._uiAnimationModel:Dispose();
	end
	
	NGUITools.DestroyChildren(self._trsRoleParent);
	NGUITools.DestroyChildren(self._trsPetParent);
	
	UIUtil.GetComponent(self._btnSend, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnSend = nil;
	
	self._scrollView.onDragFinished:Destroy();
	self.callBack = nil;
end

function RankPanelSimpleCtrl:_InitListener()
	MessageManager.AddListener(RankNotes, RankNotes.ENV_ITEM_SIMPLE_SELECT, RankPanelSimpleCtrl._OnSelectItem, self);
	MessageManager.AddListener(RankNotes, RankNotes.RSP_LIST, RankPanelSimpleCtrl._OnList, self);
	MessageManager.AddListener(RankNotes, RankNotes.RSP_ITEM, RankPanelSimpleCtrl._OnItemInfo, self);
	MessageManager.AddListener(RankNotes, RankNotes.RSP_SEND_FLOWER, RankPanelSimpleCtrl.SetFlowerInfo, self);
	
end

function RankPanelSimpleCtrl:_DisposeListener()
	MessageManager.RemoveListener(RankNotes, RankNotes.ENV_ITEM_SIMPLE_SELECT, RankPanelSimpleCtrl._OnSelectItem);
	MessageManager.RemoveListener(RankNotes, RankNotes.RSP_LIST, RankPanelSimpleCtrl._OnList);
	MessageManager.RemoveListener(RankNotes, RankNotes.RSP_ITEM, RankPanelSimpleCtrl._OnItemInfo);
	MessageManager.RemoveListener(RankNotes, RankNotes.RSP_SEND_FLOWER, RankPanelSimpleCtrl.SetFlowerInfo);
	
end

function RankPanelSimpleCtrl:_OnEnable()
	self._selectId = nil;
	self._scrollView:ResetPosition();
	RankProxy.ReqList(self._type, self._page);
end

function RankPanelSimpleCtrl:_OnDisable()
	
end

function RankPanelSimpleCtrl:_onDragScrollView()
	local offset = 0;
	local b = self._scrollView.bounds;
	local c = self._scrollPanel:CalculateConstrainOffset(b:GetMin(), b:GetMin());
	offset = c.y;
	
	if math.abs(offset) <= 1 then
		local tmpPage = self._page + 1;
		if tmpPage > RankPanelSimpleCtrl.MaxPage then
			return;
		end
		RankProxy.ReqList(self._type, tmpPage);
	end
end

function RankPanelSimpleCtrl:_OnClickBtnSend()
	if self.detail then
		RankProxy.ReqSendFlower(self.detail.id);
	end
end

function RankPanelSimpleCtrl:Setup(type)
	if self._type ~= type then
		--跟宠物类型有关的切换时释放模型.
		if self._type == RankConst.Type.PET or type == RankConst.Type.PET then
			if self._uiAnimationModel then
				self._uiAnimationModel:Dispose();
				self._uiAnimationModel = nil;	
			end
		end
		self._type = type;
		self:UpdateType();
		self._scrollView:ResetPosition();
	end
	self._page = 1;
	self._list = nil;
	self._phalanx:Build(1, 1, {});
	self._myRankSimple:UpdateItem(nil);
end

--更新类型
function RankPanelSimpleCtrl:UpdateType()
	if self._type == RankConst.Type.PET then
		self._txtTitle2.text = LanguageMgr.Get("rank/title2/" .. self._type);	
	else
		self._txtTitle2.text = LanguageMgr.Get("rank/title2");
	end
	
	self._txtTitle3.text = LanguageMgr.Get("rank/title3/" .. self._type);
end

function RankPanelSimpleCtrl:_OnList(data)
	if self._type == data.t then
		self._page = data.p;
	
		local list = data.list;
		if self._list == nil then
			self._list = list;
		else
			for i, v in ipairs(list) do
				table.insert(self._list, v)
			end
		end
		
		local count = #self._list;
		self._phalanx:Build(count, 1, self._list);
		
		self._myRankSimple:UpdateItem(data.my);
		
		if self._selectId == nil and count > 0 then
			self:_OnSelectItem(self._list[1]);
		end
	end
	
end
--选择列表项
function RankPanelSimpleCtrl:_OnSelectItem(data)
	if self._selectId ~= data.id then
		self._selectId = data.id;
		self._selectData = data;
		local items = self._phalanx:GetItems();
		for k, v in pairs(items) do
			v.itemLogic:UpdateSelected(data);
		end
		self:UpdateSelectItem(data);
	else
		if data.playerId ~= PlayerManager.playerId then
			ModuleManager.SendNotification(MainUINotes.OPEN_PLAYER_MSG_PANEL, {pid = data.playerId});
		end
	end
end

function RankPanelSimpleCtrl:UpdateSelectItem(data)
	--清空
	self.detail = nil;
	--self:UpdateItemInfo();
	RankProxy.ReqRoleInfo(data.playerId);
end
--操作明细
function RankPanelSimpleCtrl:_OnItemInfo(data)
	self.detail = data;
	self:UpdateItemInfo();
end
--更新操作明细
function RankPanelSimpleCtrl:UpdateItemInfo()
	if self.detail then
		self:UpdateRoleInfo();
		self:UpdateFlowerInfo();
	else
		self._txtNum.text = "";
		self._txtCount.text = "";
	end
end

function RankPanelSimpleCtrl:SetFlowerInfo(data)
	self.detail.rfn = data.rfn;
	self.detail.gfn = data.gfn;
	self:UpdateFlowerInfo();
end

function RankPanelSimpleCtrl:UpdateFlowerInfo()
	self._txtNum.text = self.detail.rfn;
	self._txtCount.text = LanguageMgr.Get("common/numMax", {num = RankPanelSimpleCtrl.fn -(self.detail.gfn or 0), max = RankPanelSimpleCtrl.fn});
	
	if self._type == RankConst.Type.PET then
		self._trsOptLeader.gameObject:SetActive(true);
		self._txtLeader.text = self._selectData.playerName;
		self._icoLeader.spriteName = "c" .. self._selectData.playerKind;
		
		--self._icoLeaderVip.spriteName = VIPManager.GetVipIconByVip(self._selectData.vip);
        self._icoLeaderVip.spriteName = ''
        local vc = ColorDataManager.Get_Vip(self._selectData.vip)
	    self._txtLeader.text = vc .. self._txtLeader.text
	else
		self._trsOptLeader.gameObject:SetActive(false);
	end
end

function RankPanelSimpleCtrl:UpdateRoleInfo()
	--local roleId = self.detail.id;
	local modelData = self:_GetModelData(self._selectData, self.detail);
	if(self._uiAnimationModel == nil) then
		if self._type == RankConst.Type.PET then
			self._uiAnimationModel = UIAnimationModel:New(modelData, self._trsPetParent, PetModelCreater);
		else
			self._uiAnimationModel = UIAnimationModel:New(modelData, self._trsRoleParent, UIRoleModelCreater);
		end
	else
		if self._type == RankConst.Type.PET then
			self._uiAnimationModel:ChangeModel(modelData, self._trsPetParent);
		else
			self._uiAnimationModel:ChangeModel(modelData, self._trsRoleParent);	
		end
		
	end
	
end

function RankPanelSimpleCtrl:_GetModelData(data, detail)
	if self._type == RankConst.Type.PET then
		local p = {use_id = data.use_id, id = 1, s = 1};
		return PetInfo:New(p, true);
	else
		local role = {};
		role.kind = data.playerKind;
		role.dress = detail.dress;
		return role;
	end
	return nil;
end
