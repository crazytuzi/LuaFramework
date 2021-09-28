require "Core.Module.Common.UIComponent"
local FestivalLoginItem = require "Core.Module.Festival.View.FestivalLoginItem"
local FestivalLoginPanel = class("FestivalLoginPanel", UIComponent)

function FestivalLoginPanel:New(trs)
    self = { }
    setmetatable(self, { __index = FestivalLoginPanel })
    if (trs) then
        self:Init(trs)
    end
    return self
end
function FestivalLoginPanel:_Init()
    self._isInit = false
    self:_InitReference()
    self:_InitListener()
    --self:UpdatePanel()
end

function FestivalLoginPanel:_InitReference()
    FestivalLoginItem.currselect = nil
    self._phalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "scrollView/phalanx")
    self._phalanx = Phalanx:New()
    self._phalanx:Init(self._phalanxInfo, FestivalLoginItem)
    self._scollview = UIUtil.GetChildByName(self._transform, "UIScrollView", "scrollView")

    self.bottomPanel = UIUtil.GetChildByName(self._transform, "Transform", "bottomPanel")
    self.btnGetLogin7Award = UIUtil.GetChildByName(self.bottomPanel, "UIButton", "btnGetLogin7Award")
    self.hasGetTip = UIUtil.GetChildByName(self.bottomPanel, "Transform", "hasGetTip")
    self.tipTxt = UIUtil.GetChildByName(self.bottomPanel, "UILabel", "tipTxt")

    self.selecttitleTxt = UIUtil.GetChildByName(self.bottomPanel, "UILabel", "selecttitleTxt")


    local listData = FestivalMgr.GetConfigs()
    local list_num = table.getn(listData)

    self._phalanx:Build(1, list_num, listData)

    self.productTfs = { }
    self.productCtrs = { }

    self.productMaxNum = 4
    for i = 1, self.productMaxNum do
        self.productTfs[i] = UIUtil.GetChildByName(self.bottomPanel, "Transform", "product" .. i)
        self.productCtrs[i] = ProductCtrl:New()
        self.productCtrs[i]:Init(self.productTfs[i], { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle }, true)
        self.productCtrs[i]:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER)
    end


    self.btnGetLogin7Award.gameObject:SetActive(false)
    self.hasGetTip.gameObject:SetActive(false)
    self.tipTxt.gameObject:SetActive(false)

    MessageManager.AddListener(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE, FestivalLoginPanel.ServerDataChange, self)

    local item = self._phalanx:GetItems()
    local l_num = table.getn(item)
    local res = FestivalMgr.GetDefSelect()
    for i = 1, l_num do
        local obj = item[i].itemLogic
        obj:SetPanel(self)
        if i == res then obj:_OnClick() end
    end

    self.hasInit = true
    self:UpdatePanel(true)
    self.hasInit = false
end



function FestivalLoginPanel:_InitListener()

    self._onClickGetLogin7Award = function(go) self:_OnClickGetLogin7Award() end
    UIUtil.GetComponent(self.btnGetLogin7Award, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickGetLogin7Award)

end


function FestivalLoginPanel:SelectChange(data)

    self.currSelectData = data

    if self.currSelectData ~= nil then
        local reward = data.reward
        local reward_num = table.getn(reward)

        for i = 1, self.productMaxNum do

            if reward[i] then
                local info = ProductInfo.GetProductInfo(reward[i])
                self.productCtrs[i]:SetData(info)
            else
                self.productCtrs[i]:SetData(nil)
            end
        end

        self.selecttitleTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardPanel/label3", { n = self.currSelectData.id })


        local canGetAward = self.currSelectData.st ~= 0
        local hasGetAward = self.currSelectData.st == 2

        if canGetAward and not hasGetAward then
            self.btnGetLogin7Award.gameObject:SetActive(true)
            self.hasGetTip.gameObject:SetActive(false)
            self.tipTxt.gameObject:SetActive(false)
        elseif canGetAward and hasGetAward then
            self.btnGetLogin7Award.gameObject:SetActive(false)
            self.hasGetTip.gameObject:SetActive(true)
            self.tipTxt.gameObject:SetActive(false)

        elseif not canGetAward then
            self.btnGetLogin7Award.gameObject:SetActive(false)
            self.hasGetTip.gameObject:SetActive(false)
            self.tipTxt.gameObject:SetActive(true)

            local dnum = self.currSelectData.id
            local dx = dnum - FestivalMgr.GetLoginDay()

            if dx == 1 then
                self.tipTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardPanel/label1")
            else
                self.tipTxt.text = LanguageMgr.Get("SignIn/SubLogin7RewardPanel/label2", { n = dnum })
            end

        end

    end


end


function FestivalLoginPanel:ServerDataChange()
    self:UpdatePanel(true)
end

function FestivalLoginPanel:_OnClickGetLogin7Award()
    FestivalProxy.SendYYLoginGet(self.currSelectData.id)
end


function FestivalLoginPanel:_Dispose()


    UIUtil.GetComponent(self.btnGetLogin7Award, "LuaUIEventListener"):RemoveDelegate("OnClick")
    self._onClickGetLogin7Award = nil

    MessageManager.RemoveListener(FestivalNotes, FestivalNotes.FESTIVAL_CHANGE, FestivalLoginPanel.ServerDataChange)

    for i = 1, self.productMaxNum do

        self.productCtrs[i]:Dispose()
        self.productCtrs[i] = nil
        self.productTfs[i] = nil
    end

    self._phalanx:Dispose()
    self._phalanx = nil


    self._phalanxInfo = nil


    self._scollview = nil

    self.bottomPanel = nil

    self.btnGetLogin7Award = nil
    self.hasGetTip = nil
    self.tipTxt = nil

    self.selecttitleTxt = nil

end

function FestivalLoginPanel:_DisposeReference()


end

function FestivalLoginPanel:UpdatePanel(notcheck)

    local item = self._phalanx:GetItems()
    local l_num = table.getn(item)

    for i = 1, l_num do
        local obj = item[i].itemLogic
        obj:UpInfo()
    end

    self:SelectChange(self.currSelectData)

    if not self.hasInit and notcheck == nil then

        local scv = FestivalMgr.GetScollviewV()
        self._scollview:SetDragAmount(scv, 0, false)
        self.hasInit = true
    end


end

return FestivalLoginPanel
