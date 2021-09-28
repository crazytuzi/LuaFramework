require "Core.Module.Common.UIComponent"

local StarExChangeItem = class("StarExChangeItem",UIItem);
function StarExChangeItem:New()
	self = { };
	setmetatable(self, { __index =StarExChangeItem });
	return self
end


function StarExChangeItem:_Init()
	self:_InitReference();
	self:_InitListener();
    self:UpdateItem(self.data)
end

function StarExChangeItem:_InitReference()
	self._txtlev = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtlev");
	self._txtAtts = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtAtts");
	self._txtAerlt = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtAerlt");
	self._txtPrice = UIUtil.GetChildByName(self.gameObject, "UILabel", "txtPrice");
	self._imgQuality = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgQuality");
	self._imgIcon = UIUtil.GetChildByName(self.gameObject, "UISprite", "imgIcon");
	self._btnExChange = UIUtil.GetChildByName(self.gameObject, "UIButton", "btnExChange");
end

function StarExChangeItem:UpdateItem(data)
    if not data then return end
	self.data = data
	local eq = data
    local pinfo = ProductManager.GetProductById(eq.product_id)
    local lev = pinfo.lev
    local quality = pinfo.quality
    self._txtlev.text = ColorDataManager.GetColorText(ColorDataManager.GetColorByQuality(quality),
         LanguageMgr.Get("StarPanel/upgrade/lev",  { n = pinfo.name, l = lev }))
--    local ac =  StarManager.GetAttConfig(quality, lev)
--    local as = StarManager.GetAttForConfig(pinfo.kind, ac, true)
--    local propertyData = as:GetPropertyAndDes()
--    local ps1 = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[1].property .. propertyData[1].sign)
--    local ps2 = ''
--    if propertyData[2] then
--        ps2 = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[2].property .. propertyData[2].sign)
--    end
    local ps1 = ''
    local ps2 = ''
    if pinfo.kind ~= StarManager.STAR_ELITE_TYPE then 
        local ac = StarManager.GetAttConfig(quality, lev)
        local as = ac and StarManager.GetAttForConfig(pinfo.kind, ac, true) or nil
        local propertyData = as and as:GetPropertyAndDes() or nil
        if propertyData and propertyData[1] then 
            ps1 = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[1].property .. propertyData[1].sign)
        end
        if propertyData and propertyData[2] then
            ps2 = propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(), " +" .. propertyData[2].property .. propertyData[2].sign)
        end
    else
        ps1 = LanguageMgr.Get("StarPanel/item/elite", { n = tonumber(pinfo.fun_para[1]) })
    end
    self._txtAtts.text = ps1 .. '   ' ..ps2
    self._imgQuality.color = ColorDataManager.GetColorByQuality(quality)
    ProductManager.SetIconSprite(self._imgIcon, pinfo.icon_id)
    local cost = eq.price
    local costed = StarManager.GetDebris() >= cost
    self._txtPrice.text = (costed and '[00ff00]' or '[ff0000]') .. eq.price
	local ceng = StarManager.GetStarCeng()
    local openNum = StarManager.GetUnlockNumByType(pinfo.kind)
    local open = openNum <= ceng
    self._txtAerlt.gameObject:SetActive(not open)
    if not open then
        self._txtAerlt.text = LanguageMgr.Get("StarPanel/exchange/tip",  { n = openNum })
    end
    self._btnExChange.gameObject:SetActive(costed and open)
end

function StarExChangeItem:_InitListener()
	self:_AddBtnListen(self._btnExChange.gameObject)
end

function StarExChangeItem:_OnBtnsClick(go)
	if go == self._btnExChange.gameObject  then
		self:_OnClickBtnExChange()
	end
end

function StarExChangeItem:_OnClickBtnExChange()
	StarProxy.SendExChange(self.data.product_id)
end

function StarExChangeItem:_Dispose()
	self:_DisposeReference();
end

function StarExChangeItem:_DisposeReference()
	self._btnExChange = nil;
	self._txtlev = nil;
	self._txtAtts = nil;
	self._txtAerlt = nil;
	self._txtPrice = nil;
	self._imgQuality = nil;
	self._imgIcon = nil;
end
return StarExChangeItem