require "Core.Module.Common.UIComponent"

local StarSubDivinatio = class("StarSubDivinatio",UIComponent);
function StarSubDivinatio:New(trs)
	self = { };
	setmetatable(self, { __index =StarSubDivinatio });
    if trs then self:Init(trs) end
	return self
end


function StarSubDivinatio:_Init()
	self:_InitReference();
	self:_InitListener();
end

function StarSubDivinatio:_InitReference()
	self._txtDiv = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtDiv");
	self._txtDivTen = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtDivTen");
	self._txtTime = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTime");
	self._txtProduct1 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtProduct1");
	self._txtProduct2 = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtProduct2");
	self._imgIcon1 = UIUtil.GetChildByName(self._txtProduct1, "UISprite", "imgIcon1");
	self._imgIcon2 = UIUtil.GetChildByName(self._txtProduct2, "UISprite", "imgIcon2");
	self._btnDiv = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnDiv");
	self._btnDivTen = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnDivTen");
	self._btnBag = UIUtil.GetChildByName(self._gameObject, "UIButton", "btnBag");
	self._txtBtnDivOne = UIUtil.GetChildByName(self._btnDiv, "UILabel", "txtBtnDivOne");
	self._txtBtnDivTen = UIUtil.GetChildByName(self._btnDivTen, "UILabel", "txtBtnDivTen");
	self._imgTips = UIUtil.GetChildByName(self._btnDiv, "UISprite", "imgTips");
	self._txtTenAward = UIUtil.GetChildByName(self._gameObject, "UILabel", "txtTenAward");
    self._txtTenAward.text = LanguageMgr.Get("StarPanel/txtTenAward")
    self._phalanxInfo = UIUtil.GetChildByName(self._gameObject, "LuaAsynPhalanx", "scrollView/phalanx");
	self._phalanx = Phalanx:New();
    local Item = require "Core.Module.Star.View.StarItem2"
	self._phalanx:Init(self._phalanxInfo, Item)
    MessageManager.AddListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubDivinatio.UpdatePanel, self)
end

function StarSubDivinatio:_InitListener()
	self:_AddBtnListen(self._btnDiv.gameObject)
	self:_AddBtnListen(self._btnDivTen.gameObject)
	self:_AddBtnListen(self._btnBag.gameObject)
end

function StarSubDivinatio:_OnBtnsClick(go)
	if go == self._btnDiv.gameObject  then
		self:_OnClickBtnDiv()
	elseif go == self._btnDivTen.gameObject then
		self:_OnClickBtnDivTen()
	elseif go == self._btnBag.gameObject then
		self:_OnClickBtnBag()
	end
end

function StarSubDivinatio:_OnClickBtnDiv()
    local c1 = StarManager.GetExpendConfigById(1)
    StarManager.currentDivinationConfig = c1
	StarProxy.SendDivination(0, StarManager.GetDivinationDt() <= 0)
end

function StarSubDivinatio:_OnClickBtnDivTen()
    local c2 = StarManager.GetExpendConfigById(2)
    StarManager.currentDivinationConfig = c2
	StarProxy.SendDivination(1)
end

function StarSubDivinatio:_OnClickBtnBag()
	ModuleManager.SendNotification(StarNotes.OPEN_STAR_BAG_PANEL)
end

function StarSubDivinatio:UpdatePanel()
    local c1 = StarManager.GetExpendConfigById(1)
    self._txtDiv.text = c1.req_num * c1.item_price
    local c2 = StarManager.GetExpendConfigById(2)
    self._txtDivTen.text = c2.req_num * c2.item_price
    self._txtBtnDivOne.text = LanguageMgr.Get("StarPanel/div/btn", { n = c1.req_num})
    self._txtBtnDivTen.text = LanguageMgr.Get("StarPanel/div/btn", { n = c2.req_num})

    self:UpdateFree(c1.req_num)

	local pid = c1.req_item
    local pc = ProductManager.GetProductById(pid)
    ProductManager.SetIconSprite(self._imgIcon1, pc.icon_id)
    ProductManager.SetIconSprite(self._imgIcon2, pc.icon_id)
    local pn = BackpackDataManager.GetProductTotalNumBySpid(pid)
    
    self._txtProduct1.text = pn .. '/' .. c1.req_num
    self._txtProduct2.text = pn .. '/' .. c2.req_num

    local ceng = StarManager.GetStarCeng()
    local d = StarManager.GetUnlockStars(ceng)
	self._phalanx:Build(40, 5, d)
end

function StarSubDivinatio:UpdateFree(num)
    local dt = StarManager.GetDivinationDt()
    local free = dt <= 0
    self._imgTips.enabled = free
    self._txtProduct1.gameObject:SetActive(not free)
    self._txtDiv.gameObject:SetActive(not free)
    if free then
        self._txtTime.text = ''
        self._txtBtnDivOne.text = LanguageMgr.Get("StarPanel/div/freetime2")         
        if self._timer then self._timer:Stop() self._timer = nil  end
    else
        self._txtBtnDivOne.text = LanguageMgr.Get("StarPanel/div/btn", { n = num})
        self._txtTime.text = LanguageMgr.Get("StarPanel/div/freetime", { t = TimeTranslateSecond(dt, 10)}) 
        if not self._timer then
            self._timer = Timer.New(function() self:UpdateFree(num) end, 1, dt)
            self._timer:Start()
        end
    end
end

function StarSubDivinatio:_Dispose()
	self:_DisposeReference();
    self._phalanx:Dispose()
	self._phalanx = nil
    if self._timer then self._timer:Stop() self._timer = nil  end
    MessageManager.RemoveListener(StarNotes, StarNotes.STAR_DATA_CHANGE, StarSubDivinatio.UpdatePanel, self)
end

function StarSubDivinatio:_DisposeReference()
	self._btnDiv = nil;
	self._btnDivTen = nil;
	self._btnBag = nil;
	self._txtDiv = nil;
	self._txtDivTen = nil;
	self._txtTime = nil;
end
return StarSubDivinatio