require "Core.Module.Common.UISubPanel";
require "Core.Module.Common.Phalanx";
require "Core.Module.Common.PropsItem";
require "Core.Module.Mail.View.Item.MailListItem";

MailPanel = class("MailPanel", UISubPanel)

function MailPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end

function MailPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._transform, "UILabel");
	--self._txtMailName = UIUtil.GetChildInComponents(txts, "txtMailName");
	--self._txtMailType = UIUtil.GetChildInComponents(txts, "txtMailType");

    self._txtMailCount = UIUtil.GetChildInComponents(txts, "txtMailCount");
    self._txtNoMail = UIUtil.GetChildInComponents(txts, "txtNoMail");
    self._txtMailTitle = UIUtil.GetChildInComponents(txts, "txtMailTitle");
	self._txtMailContent = UIUtil.GetChildInComponents(txts, "txtMailContent");
	self._txtAnnexTitle = UIUtil.GetChildInComponents(txts, "txtAnnexTitle");
	self._btnAllDel = UIUtil.GetChildByName(self._transform, "UIButton", "btnAllDel");
	self._btnAllPick = UIUtil.GetChildByName(self._transform, "UIButton", "btnAllPick");
	
	local trss = UIUtil.GetComponentsInChildren(self._transform, "Transform");
    self._trsDetailView = UIUtil.GetChildInComponents(trss, "trsDetailView");
    self._btnDel = UIUtil.GetChildByName(self._trsDetailView, "UIButton", "btnDel");
	self._btnPick = UIUtil.GetChildByName(self._trsDetailView, "UIButton", "btnPick");
    self._trsDetailView.gameObject:SetActive(false);

	self._trsAnnex = UIUtil.GetChildInComponents(trss, "trsAnnex");
    self:_InitView();

    self._onClickBtnAllDel = function(go) self:_OnClickBtnAllDel(self) end
    UIUtil.GetComponent(self._btnAllDel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAllDel);
    self._onClickBtnAllPick = function(go) self:_OnClickBtnAllPick(self) end
    UIUtil.GetComponent(self._btnAllPick, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAllPick);
    self._onClickBtnDel = function(go) self:_OnClickBtnDel(self) end
    UIUtil.GetComponent(self._btnDel, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDel);
    self._onClickBtnPick = function(go) self:_OnClickBtnPick(self) end
    UIUtil.GetComponent(self._btnPick, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnPick);
end

function MailPanel:_InitListener()
    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_NEW, MailPanel.OnNewMail, self);
    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_LIST, MailPanel.UpdateMailList, self);
    MessageManager.AddListener(MailManager, MailNotes.MAIL_UPDATE_DETAIL, MailPanel.OnRspMailDetail, self);
    MessageManager.AddListener(MailManager, MailNotes.MAIL_SELECTID_CHANGE, MailPanel.SelectMail, self);
    MessageManager.AddListener(MailManager, MailNotes.RSP_MAIL_PICK, MailPanel.OnRspPick, self);
end

function MailPanel:_OnClickBtnAllDel()
    if MailManager.GetMailCount() > 0 then
        MailProxy.ReqMailAllDel();
    end
end

function MailPanel:_OnClickBtnAllPick()
    if MailManager.GetMailCount() > 0 then
        MailProxy.ReqMailAllPick();
    end
end

function MailPanel:_OnClickBtnDel()
	if self._currentDetail then
        local annexCount = table.getn(self._currentDetail.ah);
        if (annexCount > 0 and self._currentDetail.st ~= 2) then
            MsgUtils.PopPanel("mail/error/delAnnex");
        else
            MailProxy.ReqMailDel(self._currentDetail.id);
        end
    end
end

function MailPanel:_OnClickBtnPick()
	if self._currentDetail then
        MailProxy.ReqMailPick(self._currentDetail.id);
    end
end

function MailPanel:_DisposeListener()
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_NEW, MailPanel.OnNewMail);
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_LIST, MailPanel.UpdateMailList);
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_UPDATE_DETAIL, MailPanel.OnRspMailDetail);
    MessageManager.RemoveListener(MailManager, MailNotes.MAIL_SELECTID_CHANGE, MailPanel.SelectMail);
    MessageManager.RemoveListener(MailManager, MailNotes.RSP_MAIL_PICK, MailPanel.OnRspPick);
    
end

function MailPanel:_DisposeReference()

    UIUtil.GetComponent(self._btnAllDel, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAllDel = nil;
    UIUtil.GetComponent(self._btnAllPick, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAllPick = nil;
    UIUtil.GetComponent(self._btnDel, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnDel = nil;
    UIUtil.GetComponent(self._btnPick, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnPick = nil;

	self._btnAllDel = nil;
	self._btnAllPick = nil;
	self._btnDel = nil;
	self._btnPick = nil;

    self._mailPhalanx:Dispose();
    self._mailPhalanx = nil;

    self._annexPhalanx:Dispose();
    self._annexPhalanx = nil;
end

function MailPanel:SetEnable(v)
    if v then
        self:Enable();
    else
        self:Disable();
    end
end

function MailPanel:_InitView()
    self._mailPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "mail_phalanx", true);
    self._mailPhalanx = Phalanx:New();
    self._mailPhalanx:Init(self._mailPhalanxInfo, MailListItem);
    self._annexPhalanxInfo = UIUtil.GetChildByName(self._transform, "LuaAsynPhalanx", "annex_phalanx", true);
    self._annexPhalanx = Phalanx:New();
    self._annexPhalanx:Init(self._annexPhalanxInfo, PropsItem);

end

function MailPanel:_OnEnable()
    MailProxy.ReqMailList();

    --local mailListData = {};
    --self._mailPhalanx:Build(table.getn(mailListData), 1, mailListData);
end

function MailPanel:OnNewMail()
    MailProxy.ReqMailList();
end

function MailPanel:UpdateMailList()
    
    local data = MailManager.GetMailList();
    local count = #data;
    if (data and count > 0) then
        self._txtNoMail.gameObject:SetActive(false);
        self._trsDetailView.gameObject:SetActive(true);
        self._mailPhalanx:Build(count, 1, data);
        
        local inList = false;
        if self._currentDetail then
            for i, v in ipairs(data) do
                if v.id == self._currentDetail.id then
                    inList = true;
                    break;
                end
            end
        end
        if self._currentDetail == nil or inList == false then
            self:SelectMail(data[1]);
        else
            self:UpdateMailSelected(self._currentDetail);
        end
    else
        self._mailPhalanx:Build(count, 1, {});
        self:UpdateMailDetail(nil);
        self._txtNoMail.gameObject:SetActive(true);
        self._trsDetailView.gameObject:SetActive(false);
    end

    self._txtMailCount.text = count .. " / 300";
end

function MailPanel:SelectMail(data)
    if self.reqMailId ~= data.id then
        local b = MailProxy.ReqMailRead(data.id);
        if b then
            self.reqMailId = data.id
        end
    end
end

--等待回包以后再更新选择.
function MailPanel:OnRspMailDetail(detail)
    self:UpdateMailSelected(detail);
    self:UpdateMailDetail(detail)
end

function MailPanel:UpdateMailSelected(data)
    local items = self._mailPhalanx:GetItems();
    for i,v in ipairs(items) do
        local item = v.itemLogic;
        item:UpdateSelected(data);
    end
end

function MailPanel:UpdateMailDetail(detail)
    if detail then
        self._currentDetail = detail;
        self._txtMailTitle.text = detail.ti;
        self._txtMailContent.text = detail.ct;
        self._btnDel.isEnabled = true;
        self:UpdateMailAnnex();
    else 
        self._btnPick.isEnabled = false;
        self._btnDel.isEnabled = false;
    end
end

function MailPanel:UpdateMailAnnex()
    local detail = self._currentDetail;
    local annexCount = table.getn(detail.ah);
    if (annexCount > 0 and detail.st ~= 2) then
        self._trsAnnex.gameObject:SetActive(true);
        self._annexPhalanx:Build(1, annexCount, detail.ah);
        self._btnPick.isEnabled = true;
        --self._btnDel.isEnabled = false;
    else
        self._trsAnnex.gameObject:SetActive(false);
        self._btnPick.isEnabled = false;
        --self._btnDel.isEnabled = true;
    end
end

function MailPanel:OnRspPick(ids)
    if self._currentDetail then
        for i, v in ipairs(ids) do
            if v == self._currentDetail.id then
                self._currentDetail.ah = {};
                self:UpdateMailAnnex();
            end
        end
    end
end


