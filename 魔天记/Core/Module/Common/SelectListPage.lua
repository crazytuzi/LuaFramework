SelectListPage = class("SelectListPage");

function SelectListPage:Init(transform)
    self._transform = transform;
    self._icoAct = UIUtil.GetChildByName(self._transform, "UISprite", "icoAct");
    self._icoAct.gameObject:SetActive(false);
end

function SelectListPage:SetSelect(v)
    self._icoAct.gameObject:SetActive(v);
end

function SelectListPage:Dispose(v)

end



