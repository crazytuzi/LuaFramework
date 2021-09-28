require "Core.Module.Common.Panel"

require "Core.Module.XMBoss.View.item.XMBossFuLiItem"
require "Core.Module.XMBoss.controlls.XMBossFuLiRightPanelControll"

XMBossFuLiPanel = class("XMBossFuLiPanel", Panel);
local _sortfunc = table.sort

function XMBossFuLiPanel:New()
	self = {};
	setmetatable(self, {__index = XMBossFuLiPanel});
	return self
end


function XMBossFuLiPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function XMBossFuLiPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
	self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
	self._txtTitle2 = UIUtil.GetChildInComponents(txts, "txtTitle2");
	self._txtTitle3 = UIUtil.GetChildInComponents(txts, "txtTitle3");
	self._txtTitle5 = UIUtil.GetChildInComponents(txts, "txtTitle5");
	local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btn_close = UIUtil.GetChildInComponents(btns, "btn_close");
	self._btnTog1 = UIUtil.GetChildInComponents(btns, "btnTog1");
	self._btnTog2 = UIUtil.GetChildInComponents(btns, "btnTog2");
	self._btnTog3 = UIUtil.GetChildInComponents(btns, "btnTog3");
	self._btnTog4 = UIUtil.GetChildInComponents(btns, "btnTog4");
	
	local togs = UIUtil.GetComponentsInChildren(self._trsContent, "UIToggle");
	
	self._Tog1 = UIUtil.GetChildInComponents(togs, "btnTog1");
	self._Tog2 = UIUtil.GetChildInComponents(togs, "btnTog2");
	self._Tog3 = UIUtil.GetChildInComponents(togs, "btnTog3");
	self._Tog4 = UIUtil.GetChildInComponents(togs, "btnTog4");
	
	
	local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
	self._trsToggle = UIUtil.GetChildInComponents(trss, "trsToggle");
	self._trsTitle = UIUtil.GetChildInComponents(trss, "trsTitle");
	
	
	self.listPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView/listPanel");
	self.subPanel = UIUtil.GetChildByName(self.listPanel, "Transform", "subPanel");
	self._item_phalanx = UIUtil.GetChildByName(self.subPanel, "LuaAsynPhalanx", "table");
	
	self.rightPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView/rightPanel");
	self.rightPanelCtr = XMBossFuLiRightPanelControll:New();
	self.rightPanelCtr:Init(self.rightPanel);
	
	
	XMBossFuLiPanel.listMaxNum = 70;
	local dataArr = {};
	for i = 1, XMBossFuLiPanel.listMaxNum do
		dataArr[i] = {};
	end
	
	self.product_phalanx = Phalanx:New();
	self.product_phalanx:Init(self._item_phalanx, XMBossFuLiItem);
	self.product_phalanx:Build(XMBossFuLiPanel.listMaxNum, 1, dataArr);
	
	MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GET_FULI_COMPLETE, XMBossFuLiPanel.GetFULICompleteHandler, self);
	MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_FENPEI_COMPLETE, XMBossFuLiPanel.FenPeiCompleteHandler, self);
	
	
	XMBossProxy.GetXMBossFBFuLiInfo();
	
-- 测试数据
--[[0B 获取仙盟仓库信息
输入：
输出：
l1：太清门伤害列表[id：玩家排名,n:玩家呢称，s:伤害比例,r:[spId:道具id，num:数量 ] ]
l2：魔玄宗伤害列表[id：玩家排名,n:玩家呢称，s:伤害比例,r:[spId:道具id，num:数量] ]
l3：天工宗治疗列表[id：玩家排名,n:玩家呢称，s:治疗比例,r:[spId:道具id，num:数量] ]
l4：天妖谷承受伤害列表[id：玩家排名,n:玩家呢称，s:承受伤比例,r:[spId:道具id，num:数量] ]
l:{[spId：道具ID，num：数量]...} 仓库物品

]]
--[[
    local res = { };
    res.l = {
    [1] = { spId = 303210, num = 20 },
    [2] = { spId = 303211, num = 10 } };

    res.l1 = {
        [1] = { id = 10001,idx=1, n = "asdfefadf1", v = 215 , l={[1]={spId=303210,num=2}}},
        [2] = { id = 10001,idx=2, n = "asdfefadf2", v = 2115, l={[1]={spId=303210,num=2}}},
        [3] = { id = 10001,idx=3, n = "asdfefadf3", v = 2155 , l={[1]={spId=303210,num=2}}},
        [4] = { id = 10001,idx=4, n = "asdfefadf4", v = 2175 , l={[1]={spId=303210,num=2}}},
        [5] = { id = 10001,idx=5, n = "asdfefadf5", v = 21485, l={[1]={spId=303210,num=2}}},

    };

    res.l2 = {
         [1] = { id = 10001,idx=1, n = "asdfefadf1", v = 215 , l={[1]={spId=303210,num=2}}},
        [2] = { id = 10001,idx=2, n = "asdfefadf2", v = 2115, l={[1]={spId=303210,num=2}}},
        [3] = { id = 10001,idx=3, n = "asdfefadf3", v = 2155 , l={[1]={spId=303210,num=2}}},
        [4] = { id = 10001,idx=4, n = "asdfefadf4", v = 2175 , l={[1]={spId=303210,num=2}}},
        [5] = { id = 10001,idx=5, n = "asdfefadf5", v = 21485, l={[1]={spId=303210,num=2}}},
    };


    res.l3 = {
          [1] = { id = 10001,idx=1, n = "asdfefadf1", v = 215 , l={[1]={spId=303210,num=2}}},
        [2] = { id = 10001,idx=2, n = "asdfefadf2", v = 2115, l={[1]={spId=303210,num=2}}},
        [3] = { id = 10001,idx=3, n = "asdfefadf3", v = 2155 , l={[1]={spId=303210,num=2}}},
        [4] = { id = 10001,idx=4, n = "asdfefadf4", v = 2175 , l={[1]={spId=303210,num=2}}},
        [5] = { id = 10001,idx=5, n = "asdfefadf5", v = 21485, l={[1]={spId=303210,num=2}}},


    };

    res.l4 = {
         [1] = { id = 10001,idx=1, n = "asdfefadf1", v = 215 , l={[1]={spId=303210,num=2}}},
        [2] = { id = 10001,idx=2, n = "asdfefadf2", v = 2115, l={[1]={spId=303210,num=2}}},
        [3] = { id = 10001,idx=3, n = "asdfefadf3", v = 2155 , l={[1]={spId=303210,num=2}}},
        [4] = { id = 10001,idx=4, n = "asdfefadf4", v = 2175 , l={[1]={spId=303210,num=2}}},
        [5] = { id = 10001,idx=5, n = "asdfefadf5", v = 21485, l={[1]={spId=303210,num=2}}},

    };


    self:GetFULICompleteHandler(res);
   ]]
end


function XMBossFuLiPanel:_Opened()
	--self._trsContent.gameObject:SetActive(false);
	--self._trsContent.gameObject:SetActive(true);
end


function XMBossFuLiPanel:_InitListener()
	self._onClickBtn_close = function(go) self:_OnClickBtn_close(self) end
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn_close);
	self._onClickBtnTog1 = function(go) self:_OnClickBtnTog1(self) end
	UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog1);
	self._onClickBtnTog2 = function(go) self:_OnClickBtnTog2(self) end
	UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog2);
	self._onClickBtnTog3 = function(go) self:_OnClickBtnTog3(self) end
	UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog3);
	self._onClickBtnTog4 = function(go) self:_OnClickBtnTog4(self) end
	UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnTog4);
	self._onClickBtn_sub = function(go) self:_OnClickBtn_sub(self) end
	
	
	
end

function XMBossFuLiPanel:_OnClickBtn_close()
	ModuleManager.SendNotification(XMBossNotes.CLOSE_XMBOSSFULIPANEL);
end

function XMBossFuLiPanel:_OnClickBtnTog1()
	self:SetList(self.data.l1, 1);
	self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossFuLiPanel:_OnClickBtnTog2()
	self:SetList(self.data.l2, 2);
	self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossFuLiPanel:_OnClickBtnTog3()
	self:SetList(self.data.l4, 4);
	--self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label3");
    self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossFuLiPanel:_OnClickBtnTog4()
	self:SetList(self.data.l3, 3);
	--self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label2");
    self._txtTitle3.text = LanguageMgr.Get("XMBoss/XMBossFuLiPanel/label1");
end

function XMBossFuLiPanel:SetList(list, type)
	
	local items = self.product_phalanx._items;
	
	for i = 1, XMBossFuLiPanel.listMaxNum do
		local obj = items[i].itemLogic;
		obj:SetData(list[i], type);
	end
	
end


--[[S <-- 20:03:19.029, 0x1609, 21, {"pid":"20100452","l":[{"num":4,"spId":501201}],"pl":[]}
]]
function XMBossFuLiPanel:FenPeiCompleteHandler(data)
	
	local l = data.l;
	local pl = data.pl;
	local pid = data.pid;
	
	--  pl = {[1]={spId=303210,num=2}};

	self.rightPanelCtr:UpData(l);
	
	
	local items = self.product_phalanx._items;
	
	for i = 1, XMBossFuLiPanel.listMaxNum do
		local obj = items[i].itemLogic;
		obj:UpAward(pid, pl);
	end
	
	
end

function XMBossFuLiPanel:Trysort(list)
	
	local t_num = table.getn(list);
	if t_num > 1 then
		_sortfunc(list, function(a, b) return a.idx < b.idx end);
	end
end

function XMBossFuLiPanel:GetFULICompleteHandler(data)
	
	self.data = data;
	
	-- 切换到 自己 职业的 列表


	self:Trysort(self.data.l1)
	self:Trysort(self.data.l2)
	self:Trysort(self.data.l3)
	self:Trysort(self.data.l4)
	
	
	local me = HeroController:GetInstance();
	local heroInfo = me.info;
	local k = heroInfo.kind;
	
	-- self._Tog1:Set(false);
	-- self._Tog2:Set(false);
	-- self._Tog3:Set(false);
	-- self._Tog4:Set(false);



	if 101000 == k then
		-- 太清门
		self._Tog1.value =(true);
		self:_OnClickBtnTog1()
	elseif 102000 == k then
		-- 天妖谷
		self._Tog3.value =(true);
		self:_OnClickBtnTog3()
	elseif 103000 == k then
		-- 魔玄宗
		self._Tog2.value =(true);
		self:_OnClickBtnTog2()
	elseif 104000 == k then
		-- 天工宗
		self._Tog4.value =(true);
		self:_OnClickBtnTog4()
	end
	
	-- up rightPanel
	self.rightPanelCtr:SetData(self.data.l);
	
	
	-- 设置默认选择
	local items = self.product_phalanx._items;
	
	items[1].itemLogic:_OnClickBtn();
	
	
	
end


function XMBossFuLiPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function XMBossFuLiPanel:_DisposeListener()
	UIUtil.GetComponent(self._btn_close, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn_close = nil;
	UIUtil.GetComponent(self._btnTog1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog1 = nil;
	UIUtil.GetComponent(self._btnTog2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog2 = nil;
	UIUtil.GetComponent(self._btnTog3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog3 = nil;
	UIUtil.GetComponent(self._btnTog4, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnTog4 = nil;
	
	
end

function XMBossFuLiPanel:_DisposeReference()
	
	
	MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GET_FULI_COMPLETE, XMBossFuLiPanel.GetFULICompleteHandler);
	MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_FENPEI_COMPLETE, XMBossFuLiPanel.FenPeiCompleteHandler);
	
	self.product_phalanx:Dispose()
	self.rightPanelCtr:Dispose();
	
	self.product_phalanx = nil;
	self.rightPanelCtr = nil;
	
	XMBossFuLiItem.currSelected = nil;
	self._btn_close = nil;
	self._btnTog1 = nil;
	self._btnTog2 = nil;
	self._btnTog3 = nil;
	self._btnTog4 = nil;
	self._btn_sub = nil;
	self._btn_add = nil;
	self._btn_sub = nil;
	self._btn_add = nil;
	self._btn_sub = nil;
	self._btn_add = nil;
	self._btnFenPei = nil;
	self._txtTitle1 = nil;
	self._txtTitle2 = nil;
	self._txtTitle3 = nil;
	self._txtTitle5 = nil;
	self._trsToggle = nil;
	self._trsTitle = nil;
end
