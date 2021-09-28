require "Core.Module.Common.Panel"

require "Core.Module.XMBoss.View.item.XMHuoDongJinDuRankItem"

XMHuoDongJinDuRankPanel = class("XMHuoDongJinDuRankPanel", Panel);
function XMHuoDongJinDuRankPanel:New()
    self = { };
    setmetatable(self, { __index = XMHuoDongJinDuRankPanel });
    return self
end


function XMHuoDongJinDuRankPanel:_Init()
    self:_InitReference();
    self:_InitListener();
end

function XMHuoDongJinDuRankPanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtTitle1 = UIUtil.GetChildInComponents(txts, "txtTitle1");
    self._txtTitle2 = UIUtil.GetChildInComponents(txts, "txtTitle2");
    self._txtTitle3 = UIUtil.GetChildInComponents(txts, "txtTitle3");
    self._txtTitle4 = UIUtil.GetChildInComponents(txts, "txtTitle4");
    self._txtTitle5 = UIUtil.GetChildInComponents(txts, "txtTitle5");
    self.myXMRankTxt = UIUtil.GetChildInComponents(txts, "myXMRankTxt");

    self._btnClose = UIUtil.GetChildByName(self._trsContent, "UIButton", "btnClose");
    local trss = UIUtil.GetComponentsInChildren(self._trsContent, "Transform");
    self._trsTitle = UIUtil.GetChildInComponents(trss, "trsTitle");
    self._trsList = UIUtil.GetChildInComponents(trss, "trsList");


    self.mainView = UIUtil.GetChildByName(self._trsContent, "Transform", "mainView");

    self._item_phalanx = UIUtil.GetChildByName(self.mainView, "LuaAsynPhalanx", "trsList/phalanx");


    XMBossProxy.GetXMBossRank();

    MessageManager.AddListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSRANK, XMHuoDongJinDuRankPanel.GetRankDataHandler, self);


    -- 测试数据
    --[[
     local dataArr={};
     dataArr.l = {}
      for i = 1, 10 do
      dataArr.l[i]={idx=i,tn="dddddd"..i,h=506,t=25645,item={{spid=1,num=2}}};
      end

      self:GetRankDataHandler(dataArr)
      ]]
end

function XMHuoDongJinDuRankPanel:_InitListener()
    self._onClickBtnClose = function(go) self:_OnClickBtnClose(self) end
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnClose);
end

--[[
02 详细排行
输出：
l:{[idx:排名，tn：帮会呢称，h:累计伤害值，t:累计时间，item：[spid：道具id，num：道具数量]]


function XMHuoDongJinDuRankPanel:GetRankDataHandler(data)

    self.data_s = data.s;
    self:InitData(data.l)
end

function XMHuoDongJinDuRankPanel:InitData(dataArr)


    local len = table.getn(dataArr);

    if self.product_phalanx == nil then
        self.product_phalanx = Phalanx:New();
        self.product_phalanx:Init(self._item_phalanx, XMHuoDongJinDuRankItem);
        self.product_phalanx:Build(len, 1, dataArr);
    end

    if GuildDataManager.gId == "" or GuildDataManager.gId == nil then
        self.myXMRankTxt.text = LanguageMgr.Get("XMBoss/XMHuoDongJinDuRankPanel/label1");
    else
        self.myXMRankTxt.text = LanguageMgr.Get("XMBoss/XMHuoDongJinDuRankPanel/label2");
    end

    for i = 1, len do
        local obj = dataArr[i];
        if obj.id == GuildDataManager.gId then
            self.myXMRankTxt.text = LanguageMgr.Get("XMBoss/XMHuoDongJinDuRankPanel/label3", { n = obj.idx });
            return;
        end
    end

    --   这里判断是否 参加这个活动
    if self.data_s == 1 then
        self.myXMRankTxt.text = LanguageMgr.Get("XMBoss/XMHuoDongJinDuRankPanel/label4");
    end

end


function XMHuoDongJinDuRankPanel:_OnClickBtnClose()
    ModuleManager.SendNotification(XMBossNotes.CLOSE_XMHUODONGJINDURANKPANEL);
end

function XMHuoDongJinDuRankPanel:_Dispose()
    self:_DisposeListener();
    self:_DisposeReference();
end

function XMHuoDongJinDuRankPanel:_DisposeListener()
    UIUtil.GetComponent(self._btnClose, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnClose = nil;
end

function XMHuoDongJinDuRankPanel:_DisposeReference()

    if self.product_phalanx ~= nil then
        self.product_phalanx:Dispose()
        self.product_phalanx = nil;
    end


    MessageManager.RemoveListener(XMBossProxy, XMBossProxy.MESSAGE_XMBOSS_GETXMBOSSRANK, XMHuoDongJinDuRankPanel.GetRankDataHandler);

    self._btnClose = nil;
    self._txtTitle1 = nil;
    self._txtTitle2 = nil;
    self._txtTitle3 = nil;
    self._txtTitle4 = nil;
    self._txtTitle5 = nil;
    self._trsTitle  = nil;
    self._trsList   = nil;

    self.myXMRankTxt = nil;
    self.mainView = nil;
    self._item_phalanx = nil;


end
