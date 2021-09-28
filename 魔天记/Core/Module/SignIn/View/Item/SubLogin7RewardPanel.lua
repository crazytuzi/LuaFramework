require "Core.Module.Common.UIComponent"

require "Core.Module.SignIn.View.Item.SubLogin7RewardItem"

require "Core.Manager.Item.Login7RewardManager"

SubLogin7RewardPanel = class("SubLogin7RewardPanel", UIComponent);


function SubLogin7RewardPanel:New(trs)
    self = { };
    setmetatable(self, { __index = SubLogin7RewardPanel });
    if (trs) then
        self:Init(trs);
    end
    return self
end




function SubLogin7RewardPanel:_Init()
    self._isInit = false

    self:_InitReference();
    self:_InitListener();

end

function SubLogin7RewardPanel:_InitReference()

    SubLogin7RewardItem.currselect = nil;

    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")

    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, SubLogin7RewardItem)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView");

    self.bottomPanel = UIUtil.GetChildByName(self._transform, "Transform", "bottomPanel");

    self.btnGetLogin7Award = UIUtil.GetChildByName(self.bottomPanel, "UIButton", "btnGetLogin7Award");
    self.hasGetTip = UIUtil.GetChildByName(self.bottomPanel, "Transform", "hasGetTip");
    self.tipTxt = UIUtil.GetChildByName(self.bottomPanel, "UILabel", "tipTxt");

    self.selecttitleTxt = UIUtil.GetChildByName(self.bottomPanel, "UILabel", "selecttitleTxt");


    local listData = Login7RewardManager.GetListDatas();
    local list_num = table.getn(listData);

    self._phalanx:Build(1, list_num, listData);


    self.productTfs = { };
    self.productCtrs = { };

    self.productMaxNum = 4;
    for i = 1, self.productMaxNum do
        self.productTfs[i] = UIUtil.GetChildByName(self.bottomPanel, "Transform", "product" .. i);
        self.productCtrs[i] = ProductCtrl:New();
        self.productCtrs[i]:Init(self.productTfs[i], { hasLocke = true, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
        self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);
    end


    self.btnGetLogin7Award.gameObject:SetActive(false);
    self.hasGetTip.gameObject:SetActive(false);
    self.tipTxt.gameObject:SetActive(false);

    MessageManager.AddListener(SubLogin7RewardItem, SubLogin7RewardItem.MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE, SubLogin7RewardPanel.SelectChange, self);

    MessageManager.AddListener(Login7RewardManager, Login7RewardManager.MESSAGE_LOGIN7REWARDDATA_CHANGE, SubLogin7RewardPanel.ServerDataChange, self);

    local res = Login7RewardManager.GetScollviewV();

    self._phalanx._items[res.defSelect].itemLogic:_OnClick();

    self.hasInit = true;
    self:UpdatePanel(true);

     self.hasInit = false;
   
   

    SignInProxy.GetLogin7AwardInfos()
end



function SubLogin7RewardPanel:_InitListener()

    self._onClickGetLogin7Award = function(go) self:_OnClickGetLogin7Award() end
    UIUtil.GetComponent(self.btnGetLogin7Award, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickGetLogin7Award);

end


function SubLogin7RewardPanel:SelectChange(data)

    self.currSelectData = data;

    if self.currSelectData ~= nil then
        local reward = data.reward;
        local reward_num = table.getn(reward);

        for i = 1, self.productMaxNum do
           
           if reward_num <=self.productMaxNum then
           self.productCtrs[i]:SetData(reward[i]);
           else
           self.productCtrs[i]:SetData(nil);
           end 
        end

        self.selecttitleTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardPanel/label3", { n = self.currSelectData.id });


        local canGetAward = self.currSelectData.canGetAward;
        local hasGetAward = self.currSelectData.hasGetAward;

        if canGetAward and not hasGetAward then
            self.btnGetLogin7Award.gameObject:SetActive(true);
            self.hasGetTip.gameObject:SetActive(false);
            self.tipTxt.gameObject:SetActive(false);
        elseif canGetAward and hasGetAward then
            self.btnGetLogin7Award.gameObject:SetActive(false);
            self.hasGetTip.gameObject:SetActive(true);
            self.tipTxt.gameObject:SetActive(false);

        elseif not canGetAward then
            self.btnGetLogin7Award.gameObject:SetActive(false);
            self.hasGetTip.gameObject:SetActive(false);
            self.tipTxt.gameObject:SetActive(true);

            local dnum = self.currSelectData.id;
            local dx = dnum - Login7RewardManager.hasLogin;

            if dx == 1 then
                self.tipTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardPanel/label1");
            else
                self.tipTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardPanel/label2", { n = dnum });
            end

        end

    end


end


function SubLogin7RewardPanel:ServerDataChange()
    self:UpdatePanel(true);

end

function SubLogin7RewardPanel:_OnClickGetLogin7Award()

    SignInProxy.GetLogin7Award(self.currSelectData.id);
    SequenceManager.TriggerEvent(SequenceEventType.Guide.SIGNIN_SEVENDAY_GETAWARD);
    
end


function SubLogin7RewardPanel:_Dispose()


    UIUtil.GetComponent(self.btnGetLogin7Award, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickGetLogin7Award = nil;
    MessageManager.RemoveListener(SubLogin7RewardItem, SubLogin7RewardItem.MESSAGE_SUBLOGIN7REWARDITEM_SELECT_CHANGE, SubLogin7RewardPanel.SelectChange);

    MessageManager.RemoveListener(Login7RewardManager, Login7RewardManager.MESSAGE_LOGIN7REWARDDATA_CHANGE, SubLogin7RewardPanel.ServerDataChange);

    for i = 1, self.productMaxNum do

        self.productCtrs[i]:Dispose();
        self.productCtrs[i] = nil;
        self.productTfs[i] = nil;
    end

    self._phalanx:Dispose();
    self._phalanx = nil;


     self._phalanxInfo = nil;

  
    self._scollview = nil;

    self.bottomPanel = nil;

    self.btnGetLogin7Award = nil;
    self.hasGetTip = nil;
    self.tipTxt = nil;

    self.selecttitleTxt = nil;

end

function SubLogin7RewardPanel:_DisposeReference()


end

function SubLogin7RewardPanel:UpdatePanel(notcheck)

    local item = self._phalanx._items;
    local l_num = table.getn(item);

    for i = 1, l_num do
        local obj = item[i].itemLogic;
        obj:UpInfo();
    end

    -- 更新 点击
    self:SelectChange(self.currSelectData);

    if not self.hasInit and notcheck==nil then
      
      local res = Login7RewardManager.GetScollviewV();
      -- 因为 预设部件隐藏的时候， 调用SetDragAmount 无效， 所以需要在显示的时候设置
     self._scollview:SetDragAmount(res.scv, 0, false);
    self.hasInit = true;
    end
    

end

