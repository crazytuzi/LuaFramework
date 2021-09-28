require "Core.Module.Common.Panel"

ConvenientUsePanel = class("ConvenientUsePanel", Panel);
function ConvenientUsePanel:New()
    self = { };
    setmetatable(self, { __index = ConvenientUsePanel });
    return self
end


function ConvenientUsePanel:_Init()
    self._luaBehaviour.canPool = true
    -- 这个设置 true 是不回收预设 ，因为这个预设经常用， 所以不需要回收
    self:_InitReference();
    self:_InitListener();
end

function ConvenientUsePanel:GetUIOpenSoundName()
    return ""
end

function ConvenientUsePanel:_InitReference()
    local txts = UIUtil.GetComponentsInChildren(self._trsContent, "UILabel");
    self._txtAction = UIUtil.GetChildInComponents(txts, "txtAction");
    self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
    local btns = UIUtil.GetComponentsInChildren(self._trsContent, "UIButton");
    self._btnAction = UIUtil.GetChildInComponents(btns, "btnAction");

    self.upTip = UIUtil.GetChildByName(self._trsContent.transform, "trsTips/Product/uptip").gameObject;

    local product = UIUtil.GetChildByName(self._trsContent.transform, "trsTips/Product").gameObject;

    self._productCtrl = ProductCtrl:New();
    self._productCtrl:Init(product, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle });
    self._productCtrl:SetOnClickBtnHandler(ProductCtrl.TYPE_FROM_OTHER);


    MessageManager.AddListener(ConvenientUseControll, ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_PAUSH, ConvenientUsePanel.TryPaush, self);
    MessageManager.AddListener(ConvenientUseControll, ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_RESTART, ConvenientUsePanel.TryReStart, self);

    MessageManager.AddListener(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA, ConvenientUsePanel.UpData, self);

    self.autoCkicl = false;

end


function ConvenientUsePanel:IsFixDepth()
    return true;
end


function ConvenientUsePanel:_InitListener()
    self._onClickBtnAction = function(go) self:_OnClickBtnAction(self) end
    UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAction);
end

function ConvenientUsePanel:_OnClickBtnAction()

    -- 需要判断是否还存在背包中

    local bag_info = BackpackDataManager.GetProductById(self.info_id);

    if bag_info ~= nil then

        -- 使用 或者穿戴
        local ty = self.info:GetType();
        self.kind = self.info:GetKind();
        if ty == ProductManager.type_1 then

            if self.kind == EquipDataManager.KIND_XIANBING or self.kind == EquipDataManager.KIND_XUANBING then
                self.jiandingHanldr = function(info)
                    if info ~= nil then
                        ProductCtrl.ShowProductTipByInfo(info, ProductCtrl.TYPE_FROM_BACKPACK)
                    end
                end
                WiseEquipPanelProxy.TryWiseEquip_jianding(self.info.id, self.jiandingHanldr, self.info:GetQuality());

            else
                ProductTipProxy.TryDress(self.info);
            end

        else


            if self.ty == ProductManager.type_5 and self.kind == 9 then
                --  http://192.168.0.8:3000/issues/10191
                if not self.autoCkicl then
                    local fun_para = self.info.configData.fun_para;
                    local am =  self.info:GetAm();
                    ModuleManager.SendNotification(ConfirmNotes.OPEN_CONFIRM1PANEL, {
                        title = LanguageMgr.Get("common/notice"),
                        msg = LanguageMgr.Get("ProducTipsManager/label1",{ n = fun_para[1]*am }),
                        ok_Label = LanguageMgr.Get("common/ok"),
                        cance_lLabel = LanguageMgr.Get("common/cancle"),
                        hander = function(data)
                            local am = data:GetAm();
                            ProductTipProxy.TryUseProduct(data, am);
                        end,
                        data = self.info,
                        target = nil
                    } );

                end

            else

                if not self.autoCkicl then
                    local am = self.info:GetAm();
                    ProductTipProxy.TryUseProduct(self.info, am)
                end

            end




        end

    else
        MsgUtils.ShowTips(nil, nil, nil, LanguageMgr.Get("ConvenientUsePanel/label3"));
    end

    self:TryGetNextTip();


end

function ConvenientUsePanel:StopTime()
    if self._sec_timer ~= nil then
        self._sec_timer:Stop();
        self._sec_timer = nil;
    end
end

function ConvenientUsePanel:UpTimeStr()

    local ty = self.info:GetType();
    self.kind = self.info:GetKind();
    if ty == ProductManager.type_1 then

        if self.kind == EquipDataManager.KIND_XIANBING or self.kind == EquipDataManager.KIND_XUANBING then
            self._txtAction.text = LanguageMgr.Get("ConvenientUsePanel/label5") .. "(" .. self.elseTime .. ")";
        else
            self._txtAction.text = LanguageMgr.Get("ConvenientUsePanel/label1") .. "(" .. self.elseTime .. ")";
        end
    else
        self._txtAction.text = LanguageMgr.Get("ConvenientUsePanel/label2") .. "(" .. self.elseTime .. ")";
    end

end



function ConvenientUsePanel:UpData(data)

    if data ~= nil then

        if self.info_id == data.id then
            -- 需要提示鉴定的已经鉴定
            self:TryGetNextTip();
        end
    end

end 


function ConvenientUsePanel:SetData(info)

    self.info = info:Clone();
    self.info_id = self.info:GetId();
    -- log("---ConvenientUsePanel:SetData----");

    -- PrintTable(self.info);

    self._productCtrl:SetData(info);

    self.ty = self.info:GetType();
    self.kind = self.info:GetKind();

    if self.ty == ProductManager.type_1 then

        if self.kind ~= EquipDataManager.KIND_XIANBING and self.kind ~= EquipDataManager.KIND_XUANBING then
            self.upTip:SetActive(true);
        else
            self.upTip:SetActive(false);
        end

    else
        self.upTip:SetActive(false);
    end

    local quality = info:GetQuality();

    self._txtName.text = ColorDataManager.GetColorTextByQuality(quality, info:GetName());

    self:StopTime()

    self.elseTime = 30;
    self:UpTimeStr();

    -- 判断正在打开的时候。 任务采集 是否 正在打开， 如果是的话， 就暂停显示
    local ct = ConvenientUseControll.GetIns();

    if ct.taskActPaneShowing then

        -- 暂停显示
        self:TryPaush();

    else

        self._sec_timer = Timer.New( function()

            self.elseTime = self.elseTime - 1;
            self:UpTimeStr();

            if self.elseTime < 0 then
                self:StopTime();

                -- 如果 是 等级  <60 的装备， 那么就自动 穿戴
                if self.ty == ProductManager.type_1 then
                    local eq_lv = self.info:GetLevel();
                    if eq_lv < 200 then
                        -- 自己穿戴
                        self.autoCkicl = true;
                        self:_OnClickBtnAction();
                        self.autoCkicl = false;
                    else
                        self:TryGetNextTip();
                    end

                else
                    self:TryGetNextTip();
                end


            end

        end , 1, self.elseTime + 1, false);

        self._sec_timer:Start();


    end


end


--[[
暂停
]]
function ConvenientUsePanel:TryPaush()

    self:StopTime();
    self._trsContent.gameObject:SetActive(false);

end

--[[
 恢复
]]
function ConvenientUsePanel:TryReStart()

    self:StopTime();

    self._sec_timer = Timer.New( function()

        self.elseTime = self.elseTime - 1;
        self:UpTimeStr();

        if self.elseTime < 0 then
            self:StopTime();
            self:TryGetNextTip();
        end

    end , 1, self.elseTime + 1, false);

    self._sec_timer:Start();

    self._trsContent.gameObject:SetActive(true);

end

function ConvenientUsePanel:TryGetNextTip()


    -- 尝试 获取下一个 提示 物品数据
    local hasProNeedShow = ConvenientUseControll.GetIns():TryGetNextTip(self);

    if not hasProNeedShow then
        ModuleManager.SendNotification(ConvenientUseNotes.CLOSE_CONVENIENTUSEPANEL);
    end

end

function ConvenientUsePanel:_Dispose()



    self:_DisposeListener();
    self:_DisposeReference();
end

function ConvenientUsePanel:_DisposeListener()
    UIUtil.GetComponent(self._btnAction, "LuaUIEventListener"):RemoveDelegate("OnClick");
    self._onClickBtnAction = nil;
end

function ConvenientUsePanel:_DisposeReference()

    self:StopTime();

    MessageManager.RemoveListener(ConvenientUseControll, ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_PAUSH, ConvenientUsePanel.TryPaush);
    MessageManager.RemoveListener(ConvenientUseControll, ConvenientUseControll.MESSAGE_CONVENIENTUSE_TRY_RESTART, ConvenientUsePanel.TryReStart);

    MessageManager.RemoveListener(EquipTipPanel, EquipTipPanel.MESSAGE_EQUIPTIPPANEL_UPDATA, ConvenientUsePanel.UpData);

    self._productCtrl:Dispose();

    ConvenientUseControll.GetIns().tg_panel = nil;

    self.upTip = nil;
    self._btnAction = nil;
    self._txtAction = nil;
    self._txtName = nil;

end
