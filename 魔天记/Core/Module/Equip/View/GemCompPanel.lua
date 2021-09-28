require "Core.Module.Common.Panel";
require "Core.Module.Equip.Item.GemClsItem";

GemCompPanel = Panel:New()
GemCompPanel.Mode = {
    COMPOSE = 1;
    ALL = 2;
}

local types = {1, 2};

function GemCompPanel:_Init()
	self:_InitReference();
	self:_InitListener();

    self:UpdateList();
end

function GemCompPanel:_InitReference()
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
	self._btnClose = UIUtil.GetChildInComponents(btns, "btn_close");
	self._btnComp = UIUtil.GetChildInComponents(btns, "btnCompose");
    self._btnAllComp = UIUtil.GetChildInComponents(btns, "btnAllCompose");
    
    self._mainPanel = UIUtil.GetChildByName(self._trsContent, "Transform", "panel");
    self._toGem = UIUtil.GetChildByName(self._mainPanel, "Transform", "toGem");
    self._gem1 = UIUtil.GetChildByName(self._mainPanel, "Transform", "gem1");

    self._toGemItem = PropsItem:New();
    self._toGemItem:Init(self._toGem, nil);
    self._gemItem1 = PropsItem:New();
    self._gemItem1:Init(self._gem1, nil);
    
    self._txtNeed1 = UIUtil.GetChildByName(self._mainPanel, "UILabel", "txtNeed1");
    self._txtGemName = UIUtil.GetChildByName(self._mainPanel, "UILabel", "txtGemName");
    self._txtToGemName = UIUtil.GetChildByName(self._mainPanel, "UILabel", "txtToGemName");

    self._txtToGemNum = UIUtil.GetChildByName(self._mainPanel, "UILabel", "txtToGemNum");
    self._txtGemAttr = UIUtil.GetChildByName(self._mainPanel, "UILabel", "txtGemAttr");
    
    self._trsCtrl = UIUtil.GetChildByName(self._mainPanel, "Transform", "trsCtrl");
    self._txtNum = UIUtil.GetChildByName(self._trsCtrl, "UILabel", "txtNum");
    self._btnA1 = UIUtil.GetChildInComponents(btns, "btnA1");
    self._btnA2 = UIUtil.GetChildInComponents(btns, "btnA2");
    self._btnB1 = UIUtil.GetChildInComponents(btns, "btnB1");
    self._btnB2 = UIUtil.GetChildInComponents(btns, "btnB2");

    self._showToggle = UIUtil.GetChildByName(self._trsContent, "UIToggle", "selectAllGem");
    
    self.gemCfg = nil;
    --gemClsList
    self._clsView = UIUtil.GetChildByName(self._trsContent, "UIScrollView", "clsView");
    self._clsTable = UIUtil.GetChildByName(self._trsContent, "UITable", "Table", true);
    self._clsTableTr = self._clsTable.transform;
    self._clsList = {};
    self._clsListGo = {};

    for i = 1, #types do
        local item = GemClsItem:New();
        local itemGo = UIUtil.GetUIGameObject(ResID.UI_GEMCOMPCLS);
        itemGo.name = types[i];
        UIUtil.AddChild(self._clsTableTr, itemGo.transform);
        item:Init(itemGo);
        self._clsList[i] = item;
        self._clsListGo[i] = itemGo;
    end

    self.mode = GemCompPanel.Mode.ALL;
    self._showToggle.value = self.mode == GemCompPanel.Mode.COMPOSE;

    self.compNum = 1;           --合成数量
    self.compMaxNum = 1;        --最大合成数量

    self._flag = 1;
    self._refreshNow = false;

    self.allCfgs = GemDataManager.GetAllComposeGems();
 
end

function GemCompPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
	UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
	self._onClickBtnComp = function(go) self:_OnClickBtnComp(self) end
	UIUtil.GetComponent(self._btnComp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnComp);
    self._onClickBtnAllComp = function(go) self:_OnClickBtnAllComp(self) end
	UIUtil.GetComponent(self._btnAllComp, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAllComp);
    
    self._onClickBtnA = function(go) self:_OnClickBtnMin(self) end
	UIUtil.GetComponent(self._btnA2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnA);
    self._onClickBtnB = function(go) self:_OnClickBtnReduce(self) end
	UIUtil.GetComponent(self._btnA1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnB);
    self._onClickBtnC = function(go) self:_OnClickBtnAdd(self) end
	UIUtil.GetComponent(self._btnB1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnC);
    self._onClickBtnD = function(go) self:_OnClickBtnMax(self) end
	UIUtil.GetComponent(self._btnB2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnD);

    self._onToggleShowMode = function(go) self:_OnToggleShowMode(self) end
    UIUtil.GetComponent(self._showToggle, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onToggleShowMode);
    
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_GEM_COMP_CLS, GemCompPanel.OnGemClsClick, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_GEM_COMP_ITEM, GemCompPanel.OnGemItemClick, self);
    MessageManager.AddListener(EquipNotes, EquipNotes.MESSAGE_GEM_CHG, GemCompPanel._OnGemChg, self);

    UpdateBeat:Add(self.OnUpdate, self);
end


function GemCompPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end

function GemCompPanel:_DisposeListener()
    UpdateBeat:Remove(self.OnUpdate, self);
    
    self._toGemItem:Dispose();
    self._gemItem1:Dispose();

    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnClose = nil;
	UIUtil.GetComponent(self._btnComp, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnComp = nil;
    UIUtil.GetComponent(self._btnAllComp, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAllComp = nil;
    UIUtil.GetComponent(self._btnA2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnA1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnB1, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self._btnB2, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnA = nil;
    self._onClickBtnB = nil;
    self._onClickBtnC = nil;
    self._onClickBtnD = nil;

    UIUtil.GetComponent(self._showToggle, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onToggleShowMode = nil;

    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_GEM_COMP_CLS, GemCompPanel.OnGemClsClick);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_GEM_COMP_ITEM, GemCompPanel.OnGemItemClick);
    MessageManager.RemoveListener(EquipNotes, EquipNotes.MESSAGE_GEM_CHG, GemCompPanel._OnGemChg);
end

function GemCompPanel:_DisposeReference()
    for i,v in ipairs(self._clsList) do
        v:Dispose();
        Resourcer.Recycle(self._clsListGo[i], false);
    end
end

function GemCompPanel:SetOpenParam(gemId)
    self.openGemId = gemId;
end

function GemCompPanel:_Opened()

    local defCls = 0;
    local defItem = nil;
    if self.openGemId then
        for i, v in ipairs(self._vList) do
            if defCls > 0 then
                break;
            end
            for n, m in ipairs(v) do
                if m.id - 1 == self.openGemId then
                    defCls = i;
                    defItem = m;
                    break;
                end
            end
        end
        self.initScrollPos = true;
        self.initScrollItem = defItem;
    else
        defCls = 1;
        defItem = self._vList[1][1];
    end
    self:OnGemClsClick(defCls > 0 and defCls or 1);
    self:OnGemItemClick(defItem);

end

function GemCompPanel:OnUpdate()
    if self._refreshNow then
        self._flag = self._flag + 1;
        --多刷一帧.防止异步删除gameobject的延迟
        if(self._flag > 0) then
            self._flag = 1;
            self._clsTable:Reposition();
            self._refreshNow = false;    
        end
    end
	--[[
    if self.initScrollPos then
        --self.initScrollItem
        local go = nil;

        for i,clsItem in ipairs(self._clsList) do
            local items = clsItem:GetItems();
            for i, v in ipairs(items) do
                if v.itemLogic.data == self.initScrollItem then
                    go = v.gameObject;
                    break;
                end
            end
        end
        
        if go then
            Warning(go);
        end
    end
	]]
end

local insert = table.insert
function GemCompPanel:UpdateList()

    local list = {};
    local showNum = {};

    for k, arr in pairs(self.allCfgs) do 
        list[k] = {};
        showNum[k] = 0;
        for i, v in ipairs(arr) do
            --计算宝石数量
            local needGem = GemDataManager.GetGemsByTypeAndLev(v.kind, v.lev - 1);
            local isEnough = needGem and needGem.am >= 3;
            if isEnough then
                showNum[k] = showNum[k] + 1;
            end

            if self.mode == GemCompPanel.Mode.ALL or isEnough then
                insert(list[k], v);
            end
        end
    end

    local count = 0
    for i = 1, #types do
        local item = self._clsList[i];
        item:UpdateItem(list[i], types[i], showNum[i]);
        
        count = count + #list[i];
    end

    if (count < 1) then
        MsgUtils.ShowTips("error/gem/comp/noGem");
    end

    self._vList = list;
    self._refreshNow = true;

    self:UpdateDisplay();
end

function GemCompPanel:UpdateDisplay()
    local gemCfg = self.gemCfg;  --product config
    local toItem = nil;
    local needItem = nil;

    self:SetNum(0);
    if( gemCfg ~= nil) then
         toItem = ProductInfo:New();
         toItem:Init({spId = gemCfg.id, am = 1});
         if gemCfg.lev > 1 then
             local needId = GemDataManager.GetGemsId(gemCfg.kind, gemCfg.lev - 1)
             needItem = ProductInfo:New();
             needItem:Init({spId = needId, am = 1});

             self.needGemId = needId;
             local gemCount = GemDataManager.GetGemNumById(needId);
             self.compMaxNum = math.floor(gemCount / 3);
             self:SetNum(1);
             self._txtGemName.text = LanguageMgr.GetColor(needItem:GetQuality(), needItem:GetName());
         else
             self._txtGemName.text = "";
         end

         local attrStr = "";
         local attr = GemDataManager.GetGemAttr(gemCfg.id);
         for k,v  in pairs(attr) do
             attrStr = attrStr .. LanguageMgr.Get("attr/" .. k) .. " +" .. v .. " ";
         end
         
         self._txtToGemName.text = LanguageMgr.GetColor(toItem:GetQuality(), toItem:GetName());
         self._txtGemAttr.text = attrStr;
    else
        self._txtGemName.text = "";
        self._txtToGemName.text = "";
        self._txtGemAttr.text = "";
    end
    self._toGemItem:UpdateItem(toItem);
    self._gemItem1:UpdateItem(needItem);
    
end

function GemCompPanel:_OnToggleShowMode()
    --self.gemCfg = nil;
    self.mode = self._showToggle.value and GemCompPanel.Mode.COMPOSE or GemCompPanel.Mode.ALL;
    self:UpdateList();
    self:OnGemItemClick(self.gemCfg);
end

function GemCompPanel:OnGemClsClick(data)

    for i,clsItem in ipairs(self._clsList) do
        clsItem:UpdateToggle(data);
    end

    self._refreshNow = true;
end

function GemCompPanel:OnGemItemClick(data)
    self.gemCfg = data;

    for i,clsItem in ipairs(self._clsList) do
        clsItem:UpdateSelected(data);
    end

    self:UpdateDisplay();
end

function GemCompPanel:_OnGemChg()
    self:UpdateList();
end

function GemCompPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(EquipNotes.CLOSE_GEMCOMPOSEPANEL);
end

function GemCompPanel:_OnClickBtnComp()
    if self.needGemId and self.needGemId > 0 then
        --local enough = GemDataManager.CanCompose(self.needGemId, self.compNum);
        --if(enough) then
        local count = GemDataManager.GetGemNumById(self.needGemId);
        if(count >= self.compNum * 3) then
            EquipProxy.ReqGemCompose(self.needGemId, self.compNum);
        else
            MsgUtils.ShowTips("error/gem/comp/noNum");
        end
    end
end

function GemCompPanel:_OnClickBtnAllComp()
    EquipProxy.ReqGemAllCompose();
end

function GemCompPanel:SetNum(val)
    local gemCount = GemDataManager.GetGemNumById(self.needGemId);
    if (val > 0) then
        local showNum = val * 3;
        self.compNum = val;

        if (gemCount >= showNum) then
            self._txtNeed1.text = LanguageMgr.GetColor(1, gemCount .. "/" .. showNum);
        else
            self._txtNeed1.text =  LanguageMgr.GetColor(6, gemCount .. "/" .. showNum);
        end
        
        --self.["_txtNeed"..i].text = val .. "/" .. val;
        self._txtToGemNum.text = LanguageMgr.Get("equip/gem/comp/toNum", {n = val});
        self._txtNum.text = val;
    else
        self.compNum = 1;
        self._txtNeed1.text = "";
        self._txtToGemNum.text = "";
        self._txtNum.text = LanguageMgr.Get("equip/gem/comp/toNum", {n = 1});
    end
end

function GemCompPanel:_OnClickBtnMin() 
    self:SetNum(1);
end

function GemCompPanel:_OnClickBtnReduce()
    local val = math.max(self.compNum - 1, 1);
    self:SetNum(val);
end 

function GemCompPanel:_OnClickBtnAdd()
    if(self.compNum + 1 > self.compMaxNum) then
        return;
    end
    local val = math.max(self.compNum + 1);
    self:SetNum(val);
end

function GemCompPanel:_OnClickBtnMax()
    self:SetNum(math.max(self.compMaxNum, 1));
end
