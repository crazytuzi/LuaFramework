PetModel = PetModel or BaseClass(BaseModel)

function PetModel:__init()
    self.window = nil
    self.quickshowwindow = nil
    self.gemwashwindow = nil
    self.gemreceivewindow = nil
    self.petSelectView = nil
    self.recommendSkillView = nil
    self.newPetWashSkillView = nil
    self.petStoneMarkWin = nil
    self.petArtificeWindow = nil
    self.petBreakSkillView = nil
    self.petBreakWindow = nil
    self.petWashWindow = nil
    self.petSkinhWindow = nil
    self.childSkinWindow = nil
    self.getPetSkin = nil
    self.getChildSkin = nil
    self.petFuseView = nil
    self.petSkinPreviewWindow = nil
    self.petSpiritWindow = nil
    self.petSpiritSpiritWindow = nil
    self.petSpiritSuccessPanel = nil
    self.gemSelectWindow = nil
    self.petChangeSkillPanel = nil

    self.petlist = {}
    self.pet_nums = 5
    self.cur_petdata = nil
    self.battle_petdata = nil
    self.quickshow_petdata = nil
    self.isnotify_watch = false
    self.isnotify_watch_baobao = false
    self.canGuideThree = false
    self.select_gem = 1
    self.headbarToggleOn = false
    self.headbarTabIndex = 1

    self.petShopBuyList = {}
    self.petShopList = {}
    self.petGrowthList = {"", TI18N("资质平平"), TI18N("出类拔萃"), TI18N("千里挑一"), TI18N("天下无双")}
    self.petGrowthColorList = {"", "#c7f9ff", "#c7f9ff", "#c7f9ff", "#c7f9ff"}
    self.petSellNum = 0
    self.petshoplevel = 0
    self.fresh_id = 0
    self.fresh_id_temp = 0
    self.today_wash_num = 0
    self.nextGetTime = 0

    self.cache_battle_id = nil

    self.petquickshowdata = nil

    self.petStoneMarkData = nil
    self.curPetStoneMarkData = nil

    self.pettalkpanel = nil

    EventMgr.Instance:AddListener(event_name.role_level_change, function() self:update_rolelevelup() end)
    EventMgr.Instance:AddListener(event_name.server_end_fight, function() self:on_end_fight() end)
    self.newPetIconObj = nil
    self.isMyPet = false

    self.sure_useskillbook = false

    self.currChild = nil

    self.transLev = 65

    self.artificeAttrData = {}

    self.petdata =nil


    self.On10526ButtonState = false
    self.lastSkinIndex = 2
end

function PetModel:__delete()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end

end

function PetModel:OpenPetWindow(args)
    if self.window == nil then
        self.window = PetView.New(self)
    end

    self.window:Open(args)
end

function PetModel:ClosePetWindow()
    if self.window ~= nil then
        self.window:DeleteMe()
        self.window = nil
    end
end

function PetModel:OpenPetSkillWindow(args)
    if self.skillWindow == nil then
        self.skillWindow = PetSkillView.New(self)
    end
    self.skillWindow:Show(args)
end

function PetModel:ClosePetSkillWindow()
    if self.skillWindow ~= nil then
        self.skillWindow:DeleteMe()
        self.skillWindow = nil
    end
end

function PetModel:OpenPetFeedWindow(args)
    if self.feedWindow == nil then
        self.feedWindow = PetFeedView.New(self)
    end
    self.feedWindow:Open(args)
end

function PetModel:ClosePetFeedWindow()
    if self.feedWindow ~= nil then
        self.feedWindow:DeleteMe()
        self.feedWindow = nil
    end
end

function PetModel:OpenPetGemWindow(args)
    if self.gemWindow == nil then
        self.gemWindow = PetGemView.New(self)
    end
    self.gemWindow:Open(args)
end

function PetModel:ClosePetGemWindow()
    if self.gemWindow ~= nil then
        self.gemWindow:DeleteMe()
        self.gemWindow = nil
    end
end

function PetModel:OpenPetGemSelectWindow(args)
    if self.gemSelectWindow == nil then
        self.gemSelectWindow = PetGemSelect.New(self)
    end
    self.gemSelectWindow:Open(args)
end

function PetModel:ClosePetGemSelectWindow()
    if self.gemSelectWindow ~= nil then
        self.gemSelectWindow:DeleteMe()
        self.gemSelectWindow = nil
    end
end

function PetModel:OpenPetUpgradeWindow(args)
    if self.upgradeWindow == nil then
        self.upgradeWindow = PetUpgradeView.New(self)
    end
    self.upgradeWindow:Open(args)
end

function PetModel:ClosePetUpgradeWindow()
    if self.upgradeWindow ~= nil then
        self.upgradeWindow:DeleteMe()
        self.upgradeWindow = nil
    end
end

function PetModel:OpenPetQuickShowWindow(args)
    if self.quickshowwindow == nil then
        self.quickshowwindow = PetQuickShowView.New(self)
    end
    self.quickshowwindow:Open(args)
end

function PetModel:ClosePetQuickShowWindow()
    if self.quickshowwindow ~= nil then
        self.quickshowwindow:DeleteMe()
        self.quickshowwindow = nil
    end
end

function PetModel:OpenPetGemWashWindow(args)
    if self.gemwashwindow == nil then
        self.gemwashwindow = PetGemWashView.New(self)
    end
    self.gemwashwindow:Open(args)
end

function PetModel:ClosePetGemWashWindow()
    if self.gemwashwindow ~= nil then
        self.gemwashwindow:DeleteMe()
        self.gemwashwindow = nil
    end
end

function PetModel:OpenPetReceiveWindow(args)
    if self.guide ~= nil then
        self.guide:DeleteMe()
        self.guide = nil
    end
    if self.gemreceivewindow == nil then
        self.gemreceivewindow = PetReceiveView.New(self)
    end
    self.gemreceivewindow:Open(args)
end

function PetModel:ClosePetReceiveWindow()
    if self.gemreceivewindow ~= nil then
        self.gemreceivewindow:DeleteMe()
        self.gemreceivewindow = nil
    end
end

function PetModel:OpenPetSelectWindow(args)
    if self.petSelectView == nil then
        self.petSelectView = PetSelectView.New(self)
    end
    self.petSelectView:Show(args)
end

function PetModel:ClosePetSelectWindow()
    if self.petSelectView ~= nil then
        self.petSelectView:DeleteMe()
        self.petSelectView = nil
    end
end

function PetModel:OpenRecommendSkillWindow(args)
    if self.recommendSkillView == nil then
        self.recommendSkillView = PetRecommendSkillView.New(self)
    end
    self.recommendSkillView:Show(args)
end

function PetModel:CloseRecommendSkillWindow()
    if self.recommendSkillView ~= nil then
        self.recommendSkillView:DeleteMe()
        self.recommendSkillView = nil
    end
end

function PetModel:OpenPetSetTalkPanel(data)
    self.pettalk_data = data
    if self.pettalkpanel == nil then
        self.pettalkpanel = PetTalkPanel.New(self)
    else
        self.pettalkpanel:Refresh()
    end
    self.pettalkpanel:Show()
end

function PetModel:ClosePetTalkPanel()
    if self.pettalkpanel ~= nil then
        self.pettalkpanel:DeleteMe()
        self.pettalkpanel = nil
    end
end

function PetModel:UpdatePetTalkPanel()
    if self.pettalkpanel ~= nil then
        self.pettalkpanel:InitTalkSetting()
    end
end


function PetModel:OpenChildSetTalkPanel(data)
    if PetManager.Instance.model.currChild.status == ChildrenEumn.Status.Follow then
        if BaseUtils.get_unique_roleid(PetManager.Instance.model.currChild.follow_id, PetManager.Instance.model.currChild.f_zone_id, PetManager.Instance.model.currChild.f_platform) == BaseUtils.get_self_id() then
            -- PetManager.Instance.model:OpenChildLearnSkill()
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    else
        if not self:CheckChildCanFollow() then
            NoticeManager.Instance:FloatTipsByString(TI18N("携带后才能进一步操作哦{face_1,2}"))
        end
    end
    self.childtalk_data = data
    if self.childtalkpanel == nil then
        self.childtalkpanel = PetChildTalkPanel.New(self)
    else
        self.childtalkpanel:Refresh()
    end
    self.childtalkpanel:Show()
end

function PetModel:CloseChildTalkPanel()
    if self.childtalkpanel ~= nil then
        self.childtalkpanel:DeleteMe()
        self.childtalkpanel = nil
    end
end

function PetModel:UpdateChildTalkPanel()
    if self.childtalkpanel ~= nil then
        self.childtalkpanel:InitTalkSetting()
    end
end

function PetModel:OpenNewPetWashSkillWindow(args)
    if self.newPetWashSkillView == nil then
        self.newPetWashSkillView = NewPetWashSkillView.New(self)
    end
    self.newPetWashSkillView:Show(args)
end

function PetModel:CloseNewPetWashSkillWindow()
    if self.newPetWashSkillView ~= nil then
        self.newPetWashSkillView:DeleteMe()
        self.newPetWashSkillView = nil
    end
end

function PetModel:OpenPetArtificeWindow(args)
    if self.petArtificeWindow == nil then
        self.petArtificeWindow = PetArtificeWindow.New(self)
    end
    self.petArtificeWindow:Open(args)
end

function PetModel:ClosePetArtificeWindow()
    if self.petArtificeWindow ~= nil then
        self.petArtificeWindow:DeleteMe()
        self.petArtificeWindow = nil
    end
end

function PetModel:OpenPetBreakSkillView(args)
    if self.petBreakSkillView == nil then
        self.petBreakSkillView = PetBreakSkillView.New(self)
    end
    self.petBreakSkillView:Show(args)
end

function PetModel:ClosePetBreakSkillView()
    if self.petBreakSkillView ~= nil then
        self.petBreakSkillView:DeleteMe()
        self.petBreakSkillView = nil
    end
end

function PetModel:OpenPetBreakWindow(args)
    if self.petBreakWindow == nil then
        self.petBreakWindow = PetBreakWindow.New(self)
    end
    self.petBreakWindow:Open(args)
end

function PetModel:ClosePetBreakWindow()
    if self.petBreakWindow ~= nil then
        self.petBreakWindow:DeleteMe()
        self.petBreakWindow = nil
    end
end

--打开宠物洗髓界面
function PetModel:OpenPetWashWindow(args)
    if self.petWashWindow == nil then
        self.petWashWindow = PetWashWindow.New(self)
    end
    self.petWashWindow:Open(args)
end

--关闭宠物洗髓界面
function PetModel:ClosepetWashWindow()
    if self.petWashWindow ~= nil then
         WindowManager.Instance:CloseWindow(self.petWashWindow)
        self.petWashWindow = nil
    end
end

--打开宠物皮肤界面
function PetModel:OpenPetSkinWindow(args)
    if self.petSkinhWindow == nil then
        self.petSkinhWindow = PetSkinWindow.New(self)
    end
    self.petSkinhWindow:Open(args)
end

--关闭宠物皮肤界面
function PetModel:ClosePetSkinWindow()
    if self.petSkinhWindow ~= nil then
         WindowManager.Instance:CloseWindow(self.petSkinhWindow)
        self.petSkinhWindow = nil
    end
end

--打开子女皮肤界面
function PetModel:OpenChildSkinWindow(args)
    if self.childSkinWindow == nil then
        self.childSkinWindow = ChildSkinWindow.New(self)
    end
    self.childSkinWindow:Open(args)
end

--关闭子女皮肤界面
function PetModel:CloseChildSkinWindow()
    if self.childSkinWindow ~= nil then
         WindowManager.Instance:CloseWindow(self.childSkinWindow)
        self.childSkinWindow = nil
    end
end

--打开宠物合成界面
function PetModel:OpenPetFuseWindow(args)
    if self.petFuseView == nil then
        self.petFuseView = PetFuseView.New(self)
    end
    self.petFuseView:Open(args)
end

--关闭宠物合成界面
function PetModel:ClosePetFuseWindow()
    if self.petFuseView ~= nil then 
         WindowManager.Instance:CloseWindow(self.petFuseView)
        self.petFuseView = nil
    end
end

--打开宠物内丹界面
function PetModel:OpenPetRunePanel(assetwrapper, parent, args)
    if self.petRunePanel == nil then
        self.petRunePanel = PetRunePanel.New(self, parent, assetwrapper)
    end
    self.petRunePanel:Show(args)
end

--关闭宠物内丹界面
function PetModel:ClosePetRunePanel()
    if self.petRunePanel ~= nil then
        self.petRunePanel:DeleteMe()
        self.petRunePanel = nil
    end
end

--打开宠物内丹学习界面
function PetModel:OpenPetRuneStudyPanel(args)
    if self.petRuneStudyPanel == nil then
        self.petRuneStudyPanel = PetRuneStudyPanel.New(self)
    end
    self.petRuneStudyPanel:Show(args)
end

--关闭宠物内丹学习界面
function PetModel:ClosePetRuneStudyPanel()
    if self.petRuneStudyPanel ~= nil then
        self.petRuneStudyPanel:DeleteMe()
        self.petRuneStudyPanel = nil
    end
end

--打开宠物内丹领悟界面
function PetModel:OpenPetSavvyRunePanel(args)
    if self.petSavvyRunePanel == nil then
        self.petSavvyRunePanel = PetSavvyRunePanel.New(self)
    end
    self.petSavvyRunePanel:Show(args)
end

--关闭宠物内丹领悟界面
function PetModel:ClosePetSavvyRunePanel()
    if self.petSavvyRunePanel ~= nil then
        self.petSavvyRunePanel:DeleteMe()
        self.petSavvyRunePanel = nil
    end
end

--打开宠物内丹共鸣界面
function PetModel:OpenPetResonanceRunePanel(args)
    if self.petResonanceRunePanel == nil then
        self.petResonanceRunePanel = PetResonancesRunePanel.New(self)
    end
    self.petResonanceRunePanel:Show(args)
end

--关闭宠物内丹共鸣界面
function PetModel:ClosePetResonanceRunePanel()
    if self.petResonanceRunePanel ~= nil then
        self.petResonanceRunePanel:DeleteMe()
        self.petResonanceRunePanel = nil
    end
end


--打开宠物图鉴皮肤预览界面
function PetModel:OpenPetSkinPreviewWindow(args)
    if self.petSkinPreviewWindow == nil then
        self.petSkinPreviewWindow = PetSkinPreviewWindow.New(self)
    end
    self.petSkinPreviewWindow:Show(args)
end

--关闭宠物合成界面
function PetModel:ClosePetSkinPreviewWindow()
    if self.petSkinPreviewWindow ~= nil then
        self.petSkinPreviewWindow:DeleteMe()
        self.petSkinPreviewWindow = nil
    end
end

--打开宠物附灵界面
function PetModel:OpenPetSpirtWindow(args)
    if self.petSpiritWindow == nil then
        self.petSpiritWindow = PetSpirtWindow.New(self)
    end
    self.petSpiritWindow:Open(args)
end

function PetModel:OpenChildSpirtWindow(args)
    if self.childSpiritWindow == nil then
        self.childSpiritWindow = ChildSpirtWindow.New(self)
    end
    self.childSpiritWindow:Open(args)
end

--关闭宠物附灵界面
function PetModel:ClosePetSpirtWindow()
    if self.petSpiritWindow ~= nil then
         WindowManager.Instance:CloseWindow(self.petSpiritWindow)
        self.petSpiritWindow = nil
    end
end

--打开宠物附灵选择界面
function PetModel:OpenPetSelecttSpirtWindow(args)
    if self.petSpiritSpiritWindow == nil then
        self.petSpiritSpiritWindow = PetSelecttSpirtWindow.New(self)
    end
    self.petSpiritSpiritWindow:Show(args)
end

--打开子女附灵选择界面
function PetModel:OpenChildSelectSpirtWindow(args)
    if self.childSelectSpiritWindow == nil then
        self.childSelectSpiritWindow = ChildSelectSpirtWindow.New(self)
    end
    self.childSelectSpiritWindow:Show(args)
end

--关闭宠物附灵选择界面
function PetModel:ClosePetSelecttSpirtWindow()
    if self.petSpiritSpiritWindow ~= nil then
        self.petSpiritSpiritWindow:DeleteMe()
        self.petSpiritSpiritWindow = nil
    end
end

function PetModel:CloseChildSelectSpirtWindow()
    if self.childSelectSpiritWindow ~= nil then
        self.childSelectSpiritWindow:DeleteMe()
        self.childSelectSpiritWindow = nil
    end
end

function PetModel:OpenPetSpiritSuccessPanel(args)
    if self.petSpiritSuccessPanel == nil then
        self.petSpiritSuccessPanel = PetSpiritSuccessPanel.New(self)
    end
    self.petSpiritSuccessPanel:Show(args)
end

function PetModel:OpenChildSpiritSuccessPanel(args)
    if self.childSpiritSuccessPanel == nil then
        self.childSpiritSuccessPanel = ChildSpiritSuccessPanel.New(self)
    end
    self.childSpiritSuccessPanel:Show(args)
end

function PetModel:ClosePetSpiritSuccessPanel()
    if self.petSpiritSuccessPanel ~= nil then
        self.petSpiritSuccessPanel:DeleteMe()
    end
    self.petSpiritSuccessPanel = nil
end

function PetModel:CloseChildSpiritSuccessPanel()
    if self.childSpiritSuccessPanel ~= nil then
        self.childSpiritSuccessPanel:DeleteMe()
    end
    self.childSpiritSuccessPanel = nil

end

function PetModel:OpenPetStoneMarkWindow(data)
    self.petStoneMarkData = data
    if self.petStoneMarkWin == nil then
        self.petStoneMarkWin = PetStoneMarkWindow.New(self)
    end
    self.petStoneMarkWin:Show(args)
end

function PetModel:ClosePetStoneMarkWindow()
    if self.petStoneMarkWin ~= nil then
        self.petStoneMarkWin:DeleteMe()
        self.petStoneMarkWin = nil
    end
end

function PetModel:OnPlayStoneMarkEffect()
    if self.petStoneMarkWin ~= nil then
        self.petStoneMarkWin:OnPlayStoneMarkEffect()
    end
end

function PetModel:OpenPetChangeSkillPanel(args)
    if self.petChangeSkillPanel == nil then
        self.petChangeSkillPanel = PetChangeSkillPanel.New(self)
    end
    self.petChangeSkillPanel:Show(args)
end

function PetModel:ClosePetChangeSkillPanel()
    if self.petChangeSkillPanel ~= nil then
        self.petChangeSkillPanel:DeleteMe()
        self.petChangeSkillPanel = nil
    end
end

--宠物符石洗炼窗口
function PetModel:OpenPetStoneWashPanel(bo,slotItemData,isShowBtn)
    if bo == true then
        if self.pswPanel == nil then
            self.pswPanel = PetStoneWash.New(self)
        end
        self.pswPanel:Show({slotItemData,isShowBtn})
    else
        if self.pswPanel ~= nil then
            self.pswPanel:Hiden()
            -- self.pswPanel:DeleteMe()
            -- self.pswPanel = nil
        end
    end
end

function PetModel:OpenGetPetWindow(args)
    if self.getPetSkin == nil then
        self.getPetSkin = GetPetSkin.New(self)
        self.getPetSkin.callback = function()
                self:CloseGetPetWindow()
                if args == nil then self:OpenPetSkinWindow() end
            end
    end
    self.getPetSkin:Show(args)
end

function PetModel:CloseGetPetWindow()
    if self.getPetSkin ~= nil then
        -- WindowManager.Instance:CloseWindow(self.getPetSkin)
        self.getPetSkin:DeleteMe()
        self.getPetSkin = nil
    end
end

function PetModel:OpenGetChildWindow(args)
    if self.getChildSkin == nil then
        self.getChildSkin = GetChildSkin.New(self)
        self.getChildSkin.callback = function()
                self:CloseGetChildWindow()
                if args == nil then self:OpenChildSkinWindow() end
            end
    end
    self.getChildSkin:Show(args)
end

function PetModel:CloseGetChildWindow()
    if self.getChildSkin ~= nil then
        self.getChildSkin:DeleteMe()
        self.getChildSkin = nil
    end
end


function PetModel:GetNextTime()
    return math.max(0, self.nextGetTime - BaseUtils.BASE_TIME)
end

function PetModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function PetModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end

function PetModel:ShowUpdateEffect()     --领取
    if self.godPet1 ~= nil then
        return
    end
    local data = {typeid = 1,goodid = 20013}
    self.godPet1 = GetGodPet.New()
    self.godPet1.callback = function ()
        self.godPet1:DeleteMe()
        self.godPet1 = nil
        self:OpenPetWindow({1,1,20013})
    end
    self.godPet1:Show(data)

end

function PetModel:ShowUpdateEffect2()     --进化
    if self.godPet2 ~= nil then
        return
    end
    local data = {typeid = 2,goodid = 20014}
    self.godPet2 = GetGodPet.New()
    self.godPet2.callback = function ()
        self.godPet2:DeleteMe()
        self.godPet2 = nil
    end
    self.godPet2:Show(data)
end

function PetModel:ShowUpdateEffect3()     --孵化成功
    if self.godPet3 ~= nil then
        return
    end
    self.data_Eff_two = {}
    local data = {typeid = 3}
    self.godPet3 = GetGodPet.New()
    self.godPet3.callback = function ()
        self.godPet3:DeleteMe()
        self.godPet3 = nil
        if self.petdata ~= nil then
            self.data_Eff_two.item_list = self.petdata.reward   ---道具列表
            if self.data_Eff_two.item_list ~= nil then
                self:OpenGiftShow(self.data_Eff_two)
            end
        end
    end
    self.godPet3:Show(data)
end





-------------------------------------------
-------------------------------------------
------------- 数据处理 -----------------
-------------------------------------------
-------------------------------------------
function PetModel:On10500(data)
    self.pet_nums = data.pet_nums
    self.petlist = data.pet_list
    self.fresh_id = data.fresh_id
    -- self.nextGetTime = math.max(0, data.time - BaseUtils.BASE_TIME)
    self.nextGetTime = data.time
    self:update_receivepet()
    for i = 1, #self.petlist do
        self.petlist[i] = self:updatepetbasedata(self.petlist[i])
        -- self.petlist[i] = self:pet_grade_attr(self.petlist[i])

        self:PetSpirtData(self.petlist[i])
        self:ProcessingSkillData(self.petlist[i])
    end

    if #self.petlist > 0 then
        self:sort_petlist()
        if self.cur_petdata == nil then
            self.cur_petdata = self.petlist[1]
        else
            self.cur_petdata = self:getpet_byid(self.cur_petdata.id)
        end
    end


    PetManager.Instance.OnUpdatePetList:Fire()
    EventMgr.Instance:Fire(event_name.pet_update)
    self:update_battlepet()
    WarriorManager.Instance:CheckBattlePet()
end

function PetModel:On10501(data)

end

function PetModel:On10502(data)
    local petdata = self:getpet_byid(data.id)
    if petdata ~= nil then
        petdata.name = data.name
        petdata.exp = data.exp
        petdata.max_exp = data.max_exp
        petdata.lev = data.lev
        petdata.happy = data.happy
        petdata.status = data.status
        petdata.possess_pos = data.possess_pos
        PetManager.Instance.OnUpdatePetList:Fire()
        self:update_battlepet()  --更新主角面头像
        EventMgr.Instance:Fire(event_name.pet_update)
    end
    WarriorManager.Instance:CheckBattlePet()
end

function PetModel:On10503(data)
    local petdata = self:getpet_byid(data.id)

    if petdata ~= nil then
        if petdata.master_pet_id ~= 0 and petdata.talent >= 3600 and data.talent < 3600 then
            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Sure
            data.content = TI18N("当前附灵宠物评分<color='#ffff00'>低于3600分</color>，附灵加成属性和激活技能将<color='#00ff00'>无效</color>")
            data.sureLabel = TI18N("确认")
            NoticeManager.Instance:ConfirmTips(data)
        end

        for k,v in pairs(data) do
            petdata[k] = v
        end

        -- petdata = self:pet_grade_attr(petdata)
        self:PetSpirtData(petdata)
        self:ProcessingSkillData(petdata)

        self:update_battlepet()

        if self.cur_petdata == nil then
            self.cur_petdata = self.petlist[1]
        else
            self.cur_petdata = self:getpet_byid(self.cur_petdata.id)
        end
        PetManager.Instance.OnPetUpdate:Fire({"info", "attrs", "quality"})
        EventMgr.Instance:Fire(event_name.pet_update)
    end
end

function PetModel:On10504(data)
    local petlist = data.pet_list
    for i = 1, #petlist do
        petlist[i] = self:updatepetbasedata(petlist[i])
        -- petlist[i] = self:pet_grade_attr(petlist[i])
        petlist[i].possess_pos = 0
        table.insert(self.petlist, petlist[i])

        self:PetSpirtData(petlist[i])
        self:ProcessingSkillData(petlist[i])
    end
    PetManager.Instance.OnUpdatePetList:Fire()
    self:update_battlepet()
    EventMgr.Instance:Fire(event_name.pet_update)
end

function PetModel:On10505(data)
    if data.flag == 1 then
        if data.genre == 1 then
            PetManager.Instance.OnPetUpdate:Fire({"genre"})
            -- sound_player:PlayOption(226)
        else
            -- sound_player:PlayOption(225)
        end

        local petData = self:getpet_byid(data.id)
        if petData ~= nil then
            local petBaseData = DataPet.data_pet[petData.base.id]
            if data.wash_time >= petBaseData.max_wash_time then
                self:OpenNewPetWashSkillWindow({data.id})
            end
        end
    end
end

function PetModel:On10507(data)

end

function PetModel:On10508(data)

end

function PetModel:On10509(data)
    if data.flag == 1 then
        PetManager.Instance.OnPetUpdate:Fire({"upgrade"})
        -- sound_player:PlayOption(223)
        SoundManager.Instance:Play(223)
    end
end

function PetModel:On10510(data)
    if data.flag == 1 then
        -- sound_player:PlayOption(224)
        SoundManager.Instance:Play(224)
    end
end

function PetModel:On10511(data)
    local petdata = self:getpet_byid(data.id)
    if petdata ~= nil then
        petdata.skills = data.skills
        self:ProcessingSkillData(petdata)
        PetManager.Instance.OnPetUpdate:Fire({"skills"})
    end
end

function PetModel:On10512(data)
    local petdata = self:getpet_byid(data.id)
    if petdata ~= nil then
        petdata.grade = data.grade
        petdata.stones = data.stones
        PetManager.Instance.OnPetUpdate:Fire({"grade", "stones"})
        self:update_battlepet()
    end
    EventMgr.Instance:Fire(event_name.pet_stone_update)
end

function PetModel:On10513(data)
end

function PetModel:On10514(data)
    if data.flag == 1 then
        -- sound_player:PlayOption(222)
    end
end

function PetModel:On10519(data)
    if data.flag == 1 then
        local petdata = self:getpet_byid(data.id)
        if petdata ~= nil then
            petdata.name = data.name
            PetManager.Instance.OnUpdatePetList:Fire()
            self:update_battlepet()
        end
    end
end

function PetModel:On10520(data)
    if data.result == 1 then
        local petdata = self:getpet_byid(data.id)
        if petdata ~= nil then
            petdata.pre_str = data.pre_str
            petdata.pre_con = data.pre_con
            petdata.pre_mag = data.pre_mag
            petdata.pre_agi = data.pre_agi
            petdata.pre_end = data.pre_end
        end
        PetManager.Instance.OnPetUpdate:Fire({"point_setting"})
    end
end

function PetModel:On10521(data)
    local petdata = self:getpet_byid(data.id)
    if petdata ~= nil then
        petdata.pre_str = data.pre_str
        petdata.pre_con = data.pre_con
        petdata.pre_mag = data.pre_mag
        petdata.pre_agi = data.pre_agi
        petdata.pre_end = data.pre_end

    end
    PetManager.Instance.OnPetUpdate:Fire({"point_setting"})
end

function PetModel:On10525(data)
    local petdata = self:getpet_byid(data.id)
    if petdata ~= nil then
        petdata.hp = data.hp
        petdata.mp = data.mp
        petdata.hp_max = data.hp_max
        petdata.mp_max = data.mp_max
        self:update_battlepet()
    end
end

function PetModel:On10550(data)
    if data.flag == 1 then
        PetManager.Instance.OnPetUpdate:Fire({"upgrade"})
        -- sound_player:PlayOption(223)
        self:showBreakSkill(data.id)
        SoundManager.Instance:Play(223)
    end
end

function PetModel:On10569(data)
    if data.flag == 1 then
        self:ShowUpdateEffect()
    end
end


function PetModel:On10570(data)
    self.petdata = nil
    if data.flag == 1 then
        self.petdata = data
    elseif data.flag == 0 then
        self.petdata = nil
    end
    PetManager.Instance.onReceiveValue:Fire()
end

function PetModel:On10571(data)
    if data.flag == 1 then    --成功进化
        --self:ShowUpdateEffect2()
    end
end

--宠物内丹（符文）更新
function PetModel:On10579(data)
    BaseUtils.dump(data, "On10579")
    local petdata = self:getpet_byid(data.id)
    if petdata ~= nil then
        petdata.pet_rune = data.pet_rune
        PetManager.Instance.OnPetUpdate:Fire({"rune"})
    end
    -- EventMgr.Instance:Fire(event_name.pet_stone_update)
end



-------------------------------------------
-------------------------------------------
------------- 数据处理 -----------------
-------------------------------------------
-------------------------------------------
function PetModel:GetMasterPetList()
    local list = {}
    for key, value in pairs(self.petlist) do
        if value.master_pet_id == 0 and value.spirit_child_flag ~= 1 then
            table.insert(list, value)
        end
    end
    return list
end

function PetModel:GetAttachPetList()
    local list = {}
    for key, value in pairs(self.petlist) do
        if value.master_pet_id ~= 0 or value.spirit_child_flag == 1 then
            table.insert(list, value)
        end
    end
    return list
end

function PetModel:updatepetbasedata(data)
    local basedata = DataPet.data_pet[data.base_id]
    if basedata ~= nil then
        data.base = basedata
    end
    return data
end

function PetModel:get_petname(petdata)
    -- if petdata.grade == 0 then
    --     return string.format("%s(一阶)", petdata.name)
    -- elseif petdata.grade == 1 then
    --     return string.format("%s(二阶)", petdata.name)
    -- elseif petdata.grade == 2 then
    --     return string.format("%s(三阶)", petdata.name)
    -- end

    return petdata.name
end

function PetModel:sort_petlist()
    local function sortfun(a,b)
        return a.status == 1
            or (a.status ~= 1 and b.status ~= 1 and a.lev > b.lev)
            or (a.status ~= 1 and b.status ~= 1 and a.lev == b.lev and a.base_id > b.base_id)
            or (a.status ~= 1 and b.status ~= 1 and a.lev == b.lev and a.base_id == b.base_id and a.id > b.id)
    end

    table.sort(self.petlist, sortfun)
end

function PetModel:getpetid_bybaseid(baseid)
    for i = 1, #self.petlist do
        if self.petlist[i].base.id == baseid then
            return self.petlist[i].id
        end
    end
    return 0
end

function PetModel:getpet_byid(id)
    id = tonumber(id)
    for i=1, #self.petlist do
        if self.petlist[i].id == id then
            return self.petlist[i] , i
        end
    end
    return nil , 0
end

-- 只处理外部关心的数据
-- name lv hp mp
function PetModel:update_battlepet()
    for k, v in pairs(self.petlist) do
        if v.status == 1 then
            if self.battle_petdata == nil then
                self.battle_petdata = BaseUtils.copytab(v)
                EventMgr.Instance:Fire(event_name.battlepet_update)
                return
            else
                local data = self.battle_petdata
                local valueKey = { "id", "name", "lev", "exp", "max_exp", "base_id", "hp", "mp", "hp_max", "mp_max", "genre", "grade", "use_skin", "unreal"}
                local change_list = {}
                for i=1, #valueKey do
                    if data[valueKey[i]] ~= v[valueKey[i]] then
                        table.insert(change_list, valueKey[i])
                    end
                end

                self.battle_petdata = BaseUtils.copytab(v)
                EventMgr.Instance:Fire(event_name.battlepet_update, change_list)
                -- BaseUtils.dump(change_list, "change_list")
                return
            end
        end
    end
    self.battle_petdata = nil
    EventMgr.Instance:Fire(event_name.battlepet_update)
end

function PetModel:update_receivepet()
    MainUIManager.Instance:DelAtiveIcon2(200)
    MainUIManager.Instance:DelAtiveIcon2(201)
    MainUIManager.Instance:DelAtiveIcon2(203)
    MainUIManager.Instance:DelAtiveIcon2(205)
    MainUIManager.Instance:ShowWorldLev(true)

    if self.fresh_id ~= 0 then
        local icon_id = 200
        if self.fresh_id == 1 then
            icon_id = 200
        elseif self.fresh_id == 2 then
            icon_id = 201
        elseif self.fresh_id == 3 then
            icon_id = 203
        elseif self.fresh_id == 4 or self.fresh_id == 5 then
            icon_id = 205
        end
        local base_data = DataPet.data_pet_fresh[self.fresh_id]
        local roleLev = RoleManager.Instance.RoleData.lev
        if base_data == nil then
            return
        elseif roleLev < base_data.show_lev then
            return
        end

        if self.fresh_id_temp ~= 0 and ((self.fresh_id_temp ~= 4 and self.fresh_id == 4) or (self.fresh_id_temp ~= 5 and self.fresh_id == 5)) then
            self:OpenGuideHatShow()
        end
        self.fresh_id_temp = self.fresh_id

        local cfg_data = DataSystem.data_daily_icon[icon_id]
        local data = AtiveIconData.New()
        data.id = cfg_data.id
        data.iconPath = cfg_data.res_name
        if self.fresh_id == 4 or self.fresh_id == 5 then
            data.clickCallBack = function() self:OpenGuideGetHat() end
        else
            data.clickCallBack = function() self:OpenPetReceiveWindow() end
        end
        data.sort = cfg_data.sort
        data.lev = cfg_data.lev
        if roleLev < base_data.need_lev then
            data.text = string.format(TI18N("<color='#ff4343'>%s级领取</color>"), base_data.need_lev)
        else
            data.createCallBack = function(gameObject)
                self.newPetIconObj = gameObject
                if RoleManager.Instance.RoleData.lev >= 30 and self:GetNextTime() <= 0 then
                    if self.guide ~= nil then
                        self.guide:DeleteMe()
                    end
                    if self.fresh_id ~= 4 and self.fresh_id ~= 5 then
                        self.guide = GuideNewPet.New()
                        self.guide:Show(gameObject)
                    end
                end

                if self:GetNextTime() <= 0 then
                    local fun = function(effectView)
                        if BaseUtils.isnull(gameObject) then
                            if not BaseUtils.isnull(effectView.gameObject) then
                                GameObject.Destroy(effectView.gameObject)
                            end
                            return
                        end
                        if BaseUtils.isnull(effectView.gameObject) then
                            return
                        end
                        local effectObject = effectView.gameObject
                        effectObject.transform:SetParent(gameObject.transform)
                        effectObject.transform.localScale = Vector3(0.9, 0.9, 0.9)
                        effectObject.transform.localPosition = Vector3(-1.6, 30, -400)
                        effectObject.transform.localRotation = Quaternion.identity

                        Utils.ChangeLayersRecursively(effectObject.transform, "UI")
                    end
                    BaseEffectView.New({effectId = 20256, time = nil, callback = fun})
                end
            end

            if self:GetNextTime() <= 0 then
                data.text = TI18N("<color='#ffff00'>可领取</color>")
            else
                data.timestamp = self:GetNextTime() + Time.time
                data.timeoutCallBack = function() self:update_receivepet() end
            end
        end
        MainUIManager.Instance:AddAtiveIcon2(data)
        MainUIManager.Instance:ShowWorldLev(false)
    end
end

function PetModel:update_rolelevelup()
    if self.fresh_id ~= 0 then self:update_receivepet() end
end

function PetModel:get_petheadbg(data)
    if data.grade == 0 then
        return "ItemDefault"
    elseif data.grade == 1 then
        return "4"
    elseif data.grade == 2 then
        return "5"
    elseif data.grade == 3 then
        return "5"
    else
        return "ItemDefault"
    end
end

-- 天赋评分转化天赋等级
function PetModel:gettalentclass(talentPoint)
    if talentPoint >= 3333 then
        return "SS"
    elseif talentPoint >= 2666 then
        return "S"
    elseif talentPoint >= 2333 then
        return "A"
    elseif talentPoint >= 2000 then
        return "B"
    else
        return "C"
    end
end

-- 计算宠物的附身属性
function PetModel:get_possession_attrs(pos, petdata)
    local multiple = 1
    if pos == 1 then multiple = 1.5 end

    local total = petdata.p_str + petdata.p_con + petdata.p_mag + petdata.p_agi
    local attrs = {0,0,0,0}
    if total == 0 then return attrs end
    attrs[1] = multiple * (petdata.p_str / total * self:get_possession_totalattr(petdata))
    attrs[2] = multiple * (petdata.p_mag / total * self:get_possession_totalattr(petdata))
    attrs[3] = multiple * (petdata.p_con / total * self:get_possession_totalattr(petdata))
    attrs[4] = multiple * (petdata.p_agi / total * self:get_possession_totalattr(petdata))
    return attrs
end

-- 计算宠物的附身总属性点
function PetModel:get_possession_totalattr(petdata)
    return petdata.talent / 10000 * petdata.lev * 5 * 0.8
end

-- 计算宠物的价格
function PetModel:petshop_money(def_buy_price, stock)
    local newPrice = def_buy_price
    if stock < 5 then
        newPrice = math.ceil(def_buy_price * 1.35)
    elseif stock <= 50 then
        newPrice = math.ceil(def_buy_price * (1.1 - (stock - 5) / 225))
    else
        newPrice = math.ceil(def_buy_price * 0.75)
    end
    return newPrice
end

-- 获取宠物的资质丹数据
function PetModel:pet_aptitude_data(id, percent)
    percent = percent * 100
    for k,v in pairs(DataPet.data_pet_aptitude) do
        if id == v.base_id and percent >= v.min_ratio and percent <= v.max_ratio then
            return v
        end
    end
    return nil
end

-- 计算宠物的属性值(基础属性加上符石属性和进阶属性)
function PetModel:pet_grade_attr(petData)
    local grade_attr = petData.grade_attr
    if grade_attr ~= nil then
        for _,value in pairs(grade_attr) do
            if value.name == 101 then
                petData.p_str = petData.p_str + value.val
            elseif value.name == 102 then
                petData.p_con = petData.p_con + value.val
            elseif value.name == 103 then
                petData.p_mag = petData.p_mag + value.val
            elseif value.name == 104 then
                petData.p_agi = petData.p_agi + value.val
            elseif value.name == 105 then
                petData.p_end = petData.p_end + value.val
            end
        end
        -- petData.grade_attr = {}
    end

    local stones = petData.stones
    if stones ~= nil then
        for _,stone in pairs(stones) do
            for __,value in pairs(stone.attr) do
                if value.name == 101 then
                    petData.p_str = petData.p_str + value.val
                elseif value.name == 102 then
                    petData.p_con = petData.p_con + value.val
                elseif value.name == 103 then
                    petData.p_mag = petData.p_mag + value.val
                elseif value.name == 104 then
                    petData.p_agi = petData.p_agi + value.val
                elseif value.name == 105 then
                    petData.p_end = petData.p_end + value.val
                end
            end
        end
    end

    return petData
end

function PetModel:GetPetGradeAttr(petData)
    local attr = {0, 0, 0, 0, 0}
    local grade_attr = petData.grade_attr
    if grade_attr ~= nil then
        for _,value in pairs(grade_attr) do
            if value.name == 101 then
                attr[2] = attr[2] + value.val
            elseif value.name == 102 then
                attr[1] = attr[1] + value.val
            elseif value.name == 103 then
                attr[3] = attr[3] + value.val
            elseif value.name == 104 then
                attr[4] = attr[4] + value.val
            elseif value.name == 105 then
                attr[5] = attr[5] + value.val
            end
        end
        -- petData.grade_attr = {}
    end

    local stones = petData.stones
    if stones ~= nil then
        for _,stone in pairs(stones) do
            for __,value in pairs(stone.attr) do
                if value.name == 101 then
                    attr[2] = attr[2] + value.val
                elseif value.name == 102 then
                    attr[1] = attr[1] + value.val
                elseif value.name == 103 then
                    attr[3] = attr[3] + value.val
                elseif value.name == 104 then
                    attr[4] = attr[4] + value.val
                elseif value.name == 105 then
                    attr[5] = attr[5] + value.val
                end
            end
        end
    end

    return attr
end

function PetModel:selectPetObjByBaseId(baseid)
    self.window:selectPetObjByBaseId(baseid)
end

function PetModel:on_end_fight()
    local pet = self:getpet_byid(self.cache_battle_id)
    if pet ~= nil then
        if pet.status == 0 then
            PetManager.Instance:Send10501(pet.id, 1)
        elseif pet.status == 1 then
            PetManager.Instance:Send10501(pet.id, 0)
        end
    end
    self.cache_battle_id = nil
end

function PetModel:show_pet_egg(item_baseid)
    local data = BaseUtils.copytab(DataPet.data_pet_egg[item_baseid])
    if data ~= nil then
        self.quickshow_petdata = self:updatepetbasedata(data)
        for i=1,#self.quickshow_petdata.skills do
            local skilldata = self.quickshow_petdata.skills[i]
            self.quickshow_petdata.skills[i] = {id = skilldata[1], source = skilldata[2] }
        end
        self:OpenPetQuickShowWindow()
    end
end

function PetModel:getPetModel(petData, original)
    local modelId = petData.base.model_id
    local skin = petData.base.skin_id_0
    local effects = petData.base.effects_0
    if petData.genre ~= 1 then
        if petData.grade == 0 then
            modelId = petData.base.model_id
            skin = petData.base.skin_id_0
            effects = petData.base.effects_0
        elseif petData.grade == 1 then
            modelId = petData.base.model_id1
            skin = petData.base.skin_id_1
            effects = petData.base.effects_1
        elseif petData.grade == 2 then
            modelId = petData.base.model_id2
            skin = petData.base.skin_id_2
            effects = petData.base.effects_2
        elseif petData.grade == 3 then
            modelId = petData.base.model_id3
            skin = petData.base.skin_id_3
            effects = petData.base.effects_3
        end
    else
        if petData.grade == 0 then
            modelId = petData.base.model_id
            skin = petData.base.skin_id_s0
            effects = petData.base.effects_s0
        elseif petData.grade == 1 then
            modelId = petData.base.model_id1
            skin = petData.base.skin_id_s1
            effects = petData.base.effects_s1
        elseif petData.grade == 2 then
            modelId = petData.base.model_id2
            skin = petData.base.skin_id_s2
            effects = petData.base.effects_s2
        elseif petData.grade == 3 then
            modelId = petData.base.model_id3
            skin = petData.base.skin_id_s3
            effects = petData.base.effects_s3
        end
    end

    if not original and petData.use_skin ~= nil and petData.use_skin ~= 0 then
        skin = petData.use_skin
        for key, value in pairs(DataPet.data_pet_skin) do
            if petData.base.id == value.id and petData.use_skin == value.skin_id then
                modelId = value.model_id
                effects = value.effects
            end
        end
    end
    return { modelId = modelId, skin = skin, effects = effects }
end

--传入符石data，判断下该符石是否可以洗练,zzl
function PetModel:checkPetStoneCanWash(stoneData)
    local canWash = true
    for k, v in pairs(stoneData.extra) do
        if v.name == 8 and v.value == 1 then
            canWash = false
        end
    end
    return canWash
end

function PetModel:GetChildBookSkill(id, skillList)
    local list = {}
    for _, value in ipairs(skillList) do
        if value.source == 1 then
            table.insert(list, {id = value.id, source = value.source, is_lock = value.is_lock, isBreak = false})
        end
    end
    return list
end

--处理宠物突破技能
function PetModel:makeBreakSkill(id, skillList)
    local list = {}
    local hasBreak = false
    for _, value in ipairs(skillList) do
        table.insert(list, { id = value.id, source = value.source, is_lock = value.is_lock, isBreak = false })
        if value.source == 4 then
            hasBreak = true
        end
    end

    if not hasBreak then
        local petData = DataPet.data_pet[id]
        for _, value in ipairs(petData.lev_break_skills) do
            table.insert(list, { id = value, source = 1, is_lock = 0, isBreak = true })
        end
    end

    local sort_list = {}
    for _, value in ipairs(list) do
        if value.isBreak or value.source == 4 then
            table.insert(sort_list, value)
        end
    end
    for _, value in ipairs(list) do
        if not value.isBreak and value.source ~= 4 then
            table.insert(sort_list, value)
        end
    end

    return sort_list
end

function PetModel:makeBreakSkill_Manual(id, skillList)
    local list = {}
    local petData = DataPet.data_pet[id]
    for _, value in ipairs(skillList) do
        local mark = false
        for __, break_skill in ipairs(petData.lev_break_skills) do
            if break_skill == value.id then
                mark = true
            end
        end
        if mark then
            table.insert(list, { id = value.id, source = 1, isBreak = true })
        else
            table.insert(list, { id = value.id, source = value.source, isBreak = false })
        end
    end

    return list
end

--显示宠物突破技能
function PetModel:showBreakSkill(id)
    local baseId = self:getpet_byid(id).base.id
    local petData = DataPet.data_pet[baseId]
    local list = {}
    for _, value in ipairs(petData.lev_break_skills) do
        table.insert(list, value)
    end
    if #list > 0 then
        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.petbreakskillview, { list })
    end
end

function PetModel:GetHandBookAttr(petData)
    local attrs = {}
    attrs[4] = 0
    attrs[6] = 0
    attrs[5] = 0
    attrs[7] = 0
    attrs[1] = 0
    attrs[3] = 0
    attrs[54] = 0
    attrs[55] = 0
    attrs[51] = 0
    if petData ~= nil then
        for _, data in pairs(petData.handbook_attr) do
            if attrs[data.attr_name] == nil then
                attrs[data.attr_name] = data.attr_val
            else
                attrs[data.attr_name] = data.attr_val + attrs[data.attr_name]
            end
        end
    end
    -- local handbook_attr = {}
    -- for key, value in pairs(attrs) do
    --     if KvData.attr_name[key] ~= nil then
    --         table.insert(handbook_attr, { key = key, value = value })
    --     else
    --         table.insert(handbook_attr, { key = key, value = value })
    --     end
    -- end
    -- for _, data in ipairs(handbook_attr) do
    --     if KvData.prop_percent[data.key] ~= nil then
    --         data.value = data.value / 10
    --     end
    -- end
    -- local function sortfun(a,b)
    --     return a.key < b.key
    -- end
    -- table.sort(handbook_attr, sortfun)
    return attrs
end

function PetModel:HasLockSkill(petData)
    for i = 1, #petData.skills do
        if petData.skills[i].is_lock == 1 then
            return true
        end
    end
    return false
end

function PetModel:GetNormalSkill(petData)
    local num = 0
    for _, data in ipairs(petData.skills) do
        if data.source == 1 then
            num =  num + 1
        end
    end
    return num
end

function PetModel:GetCanChangeSkin(petData)
    if petData.genre == 2 or petData.genre == 4 then
        -- local pet_grade_data = DataPet.data_pet_grade[string.format("%s_%s", petData.base.id, petData.grade+1)]
        -- if pet_grade_data == nil then
        --     return true
        -- else
        --     return false
        -- end
        if petData.grade >= 2 then
            return true
        else
            return false
        end
    end

    if petData.base.manual_level < 65 then
        return false
    else
        local pet_grade_data = DataPet.data_pet_grade[string.format("%s_%s", petData.base.id, petData.grade+1)]
        if petData.genre == 1 and pet_grade_data == nil then
            return true
        else
            return false
        end
    end
end

function PetModel:EnoughItemToChangeSkin(petData)
    local id = petData.base.id
    for key, value in pairs(DataPet.data_pet_skin) do
        if id == value.id then
            local enough = true
            for i=1, #value.cost do
                if BackpackManager.Instance:GetItemCount(value.cost[i][1]) < value.cost[i][2] then
                    enough = false
                end
            end
            if enough then
                for i=1, #petData.has_skin do
                    if petData.has_skin[i].skin_id == value.skin_id then -- 如果已经激活了，就当作材料不足吧
                        enough = false
                    end
                end
            end
            if enough then
                return true
            end
        end
    end
    return false
end

function PetModel:CheckSkinActive(index, petData)
    local id = petData.base.id
    for key, value in pairs(DataPet.data_pet_skin) do
        if id == value.id and index == value.skin_lev then
            for i=1, #petData.has_skin do
                if petData.has_skin[i].skin_id == value.skin_id then
                    return true
                end
            end
            break
        end
    end
    return false
end

function PetModel:OpenGuideGetHat()
    if self.guideGetHat == nil then
        self.guideGetHat = GuideGetHatPanel.New(self)
    end
    self.guideGetHat:Show()
end

function PetModel:CloseGuideGetHat()
    if self.guideGetHat ~= nil then
        self.guideGetHat:DeleteMe()
    end
    self.guideGetHat = nil
end

function PetModel:OpenGuideHatShow()
    if self.hatShow == nil then
        self.hatShow = GuideHatShow.New(self)
    end
    self.hatShow:Show()
end

function PetModel:CloseGuideHatShow()
    if self.hatShow ~= nil then
        self.hatShow:DeleteMe()
        self.hatShow = nil
    end
end

function PetModel:OpenChildTelentChange(args)
    if self.childTelentChange == nil then
        self.childTelentChange = PetChildTelnetChangePanel.New(self)
    end
    self.childTelentChange:Open(args)
end

function PetModel:CloseChildTelentChange()
    if self.childTelentChange ~= nil then
        self.childTelentChange:DeleteMe()
        self.childTelentChange = nil
    end
end

function PetModel:OpenChildUpgrade(args)
    if self.childUpgrade == nil then
        self.childUpgrade = PetChildUpgradeView.New(self)
    end
    self.childUpgrade:Open(args)
end

function PetModel:OpenChildGemWindow(args)
    if self.childGem == nil then
        self.childGem = PetChildGemView.New(self)
    end
    self.childGem:Open(args)
end

function PetModel:OpenChildLearnSkill(args)
    if self.childLearn == nil then
        self.childLearn = PetChildLearnSkillView.New(self)
    end
    self.childLearn:Show(args)
end

function PetModel:CloseChildLearnSkill()
    if self.childLearn ~= nil then
        self.childLearn:DeleteMe()
        self.childLearn = nil
    end
end

function PetModel:OpenChildFeed(args)
    if self.childFeed == nil then
        self.childFeed = PetChildFeedView.New(self)
    end
    self.childFeed:Open(args)
end

function PetModel:CloseChildFeed()
    if self.childFeed ~= nil then
        self.childFeed:DeleteMe()
        self.childFeed = nil
    end
end

function PetModel:OpenChildTelentPreview(args)
    if self.childTelentPreview == nil then
        self.childTelentPreview = PetChildTelentPreview.New(self)
    end
    self.childTelentPreview:Show(args)
end

function PetModel:CloseChildPreview()
    if self.childTelentPreview ~= nil then
        self.childTelentPreview:DeleteMe()
        self.childTelentPreview = nil
    end
end

function PetModel:GetPetSpirtScoreByTalent(base_id, talent)
    local data = nil
    for index, value in ipairs(DataPet.data_pet_spirt_score) do
        if value.base_id == base_id and value.talent_min <= talent then
            data = value
        end
    end
    return data
end

function PetModel:GetChildSpirtScoreByTalent(base_id, talent)
    local data = nil
    for index, value in ipairs(DataPet.data_child_spirt_score) do
        if value.base_id == base_id and value.talent_min <= talent then
            data = value
        end
    end
    return data
end

function PetModel:GetPetSpirtScoreBySkillLevel(base_id, skillLevel)
    for key, value in ipairs(DataPet.data_pet_spirt_score) do
        if value.base_id == base_id and value.skills[1] ~= nil and value.skill_lev > skillLevel then
            return value
        end
    end
    return nil
end

function PetModel:GetChildSpirtScoreBySkillLevel(base_id, skillLevel)
    for key, value in ipairs(DataPet.data_child_spirt_score) do
        if value.base_id == base_id and value.skills[1] ~= nil and value.skill_lev > skillLevel then
            return value
        end
    end
    return nil
end

function PetModel:PetSpirtData(petData)
    if petData.spirit_attached == 0 then
        petData.master_pet_id = petData.spirit_attached_id
        petData.attach_pet_ids = {}
    else
        petData.master_pet_id = 0
        petData.attach_pet_ids = {}
        for index, value in pairs(self.petlist) do
            if petData.id == value.spirit_attached_id then
                table.insert(petData.attach_pet_ids, value.id)
            end
        end
    end
end

function PetModel:CheckChildSpirtUp(petData, mainChildData)


    local minTable = {}
     for k,v in pairs(DataPet.data_pet_spirt_score) do
        if v.base_id == petData.base_id and v.skill_lev == 1 then
            table.insert(minTable,v)
        end
    end

    table.sort(minTable,function(a,b)
               if a.id ~= b.id then
                    return a.talent_min < b.talent_min
                else
                    return false
                end
            end)


    if petData.lev < petData.base.manual_level + 5 then
        -- return string.format(TI18N("附灵宠物等级不足<color='#00ff00'>%s级</color>，无法附灵"), petData.base.manual_level + 5)
        return TI18N("该宠物等级<携带等级+5，无法附灵")
    end
    if petData.talent < minTable[1].talent_min then
        return TI18N("附灵宠物评分不足<color='#00ff00'>" .. minTable[1].talent_min .. "</color>，无法附灵")
    end

    if petData.status == 1 then
        return TI18N("<color='#00ff00'>出战</color>宠物不能进行附灵")
    end
    if #petData.attach_pet_ids > 0 then
        return TI18N("该宠物有其他宠物<color='#ffff00'>附灵</color>，无法作为附灵宠")
    end

end

function PetModel:CheckPetSpirtUp(petData, mainPetData)


    local minTable = {}
     for k,v in pairs(DataPet.data_pet_spirt_score) do
        if v.base_id == petData.base_id and v.skill_lev == 1 then
            table.insert(minTable,v)
        end
    end

    table.sort(minTable,function(a,b)
               if a.id ~= b.id then
                    return a.talent_min < b.talent_min
                else
                    return false
                end
            end)
    if (mainPetData.genre == 2 or mainPetData.genre == 4) and (petData.genre ~= 2 and petData.genre ~= 4) then
        return TI18N("普通宠物不能作为<color='#ffff00'>神兽/珍兽</color>的附灵宠")
    end

    if petData.lev < petData.base.manual_level + 5 then
        -- return string.format(TI18N("附灵宠物等级不足<color='#00ff00'>%s级</color>，无法附灵"), petData.base.manual_level + 5)
        return TI18N("该宠物等级<携带等级+5，无法附灵")
    end
    if petData.talent < minTable[1].talent_min then
        return TI18N("附灵宠物评分不足<color='#00ff00'>" .. minTable[1].talent_min .. "</color>，无法附灵")
    end
    if petData.base.manual_level < mainPetData.base.manual_level -20 and (petData.genre ~= 2 and petData.genre ~= 4) then
        return TI18N("附灵宠物携带等级<color='#ffff00'>低于</color>主宠<color='#00ff00'>20级</color>，无法附灵")
    end
    if petData.status == 1 then
        return TI18N("<color='#00ff00'>出战</color>宠物不能进行附灵")
    end
    if #petData.attach_pet_ids > 0 then
        return TI18N("该宠物有其他宠物<color='#ffff00'>附灵</color>，无法作为附灵宠")
    end
    if petData.genre == 2 and (mainPetData.genre ~= 2 and mainPetData.genre ~= 4) and (mainPetData.base.need_lev_break > 1 or (mainPetData.base.need_lev_break == 1 and mainPetData.base.manual_level > 105)) then
        return TI18N("<color='#ffff00'>神兽</color>不能附灵到携带等级＞突破105的普通宠物")
    end
    if petData.genre == 4 and (mainPetData.genre ~= 2 and mainPetData.genre ~= 4) and (mainPetData.base.need_lev_break > 0 or (mainPetData.base.need_lev_break == 0 and mainPetData.base.manual_level > 95)) then
        return TI18N("<color='#ffff00'>珍兽</color>不能附灵到携带等级＞95的普通宠物")
    end
end

function PetModel:SendPetSpirtUp(petData, mainPetData)
    if petData.lev >= petData.base.manual_level + 5
        and petData.talent >= 3600
        and petData.base.manual_level >= mainPetData.base.manual_level -20
        and petData.status ~= 1
        and petData.master_pet_id == 0
        and #petData.attach_pet_ids == 0 then

            local data = NoticeConfirmData.New()
            data.type = ConfirmData.Style.Normal
            data.content = string.format(TI18N("确定将[%s]附灵到[%s]吗？"), petData.name, mainPetData.name)
            data.sureLabel = TI18N("确认")
            data.cancelLabel = TI18N("取消")
            data.sureCallback = function()
                    PetManager.Instance:Send10561(mainPetData.id, petData.id)
                end
            NoticeManager.Instance:ConfirmTips(data)
    end
end

function PetModel:ProcessingSkillData(petData)
    local specialSkillData = DataPet.data_pet_special_skills[petData.base_id]
    if specialSkillData ~= nil and petData.skills ~= nil then
        for index, value in ipairs(specialSkillData.skills) do
            local skillId = value[1]
            local mark = true
            for index2, value2 in ipairs(petData.skills) do
                if skillId == value2.id then
                    mark = false
                end
            end

            if mark then
                table.insert(petData.skills, 1, { id = skillId, source = 0, is_lock = 0 })
            end
        end
    end

    return petData
end

function PetModel:OpenTransGemView()
    if self.transgenview == nil then
        self.transgenview = PetTransGemView.New(self, self.petSkinhWindow)
    end
    self.transgenview:Show();
end

function PetModel:CloseTransGemView()
    if self.transgenview ~= nil then
        self.transgenview:DeleteMe()
        self.transgenview = nil
    end
end

-- 检查该子女是能能携带
function PetModel:CheckChildCanFollow()
    local child = PetManager.Instance.model.currChild
    if child.status == ChildrenEumn.Status.Idel or child.status == ChildrenEumn.Status.Offline then
        local count = 0
        for _, data in ipairs(ChildrenManager.Instance.childData) do
            if data.status == ChildrenEumn.Status.Follow and BaseUtils.get_unique_roleid(data.follow_id, data.f_zone_id, data.f_platform) == BaseUtils.get_self_id() then
                count = count + 1
            end
        end
        if count < 2 then
            -- ChildrenManager.Instance:Require18624(child.child_id, child.platform, child.zone_id, ChildrenEumn.Status.Follow)
            return true
        end
    end

    return false
end

--宠物顶部页签开放条件
function PetModel:CheckTabOpen(tabGroup)
    local openTab = {
        true
        ,self.cur_petdata ~= nil and self.cur_petdata.genre ~= 6 
        ,self.cur_petdata ~= nil and RoleManager.Instance.RoleData.lev >= 85 and self.cur_petdata.genre ~= 6                                           --内丹
        ,self.cur_petdata ~= nil and self.cur_petdata.genre ~= 6                                                                                       --皮肤
        ,self.cur_petdata ~= nil and self.headbarTabIndex == 1 and RoleManager.Instance.RoleData.lev >= 75 and self.cur_petdata.genre ~= 6             --附灵
    }

    for i,v in pairs(openTab) do
        if v == true then
            tabGroup.openLevel[i] = 0
        else
            tabGroup.openLevel[i] = unreachableLev or 255
        end
    end
end

--获取相应品质和等级的所有内丹数据
function PetModel:GetQualityRuneData(quality, lev)
    local tmp = {}
    lev = lev or 1
    for _, v in pairs(DataRune.data_rune) do
        if v.quality == quality and v.lev == lev then 
            table.insert(tmp, v)
        end
    end
    return tmp
end

--获取宠物内丹推荐数据
function PetModel:GetRecommendRuneDataByPet(pet_id)
    pet_id = pet_id or self.cur_petdata.id
    return {}
end

--判断是否已学习该内丹
function PetModel:JudgeStudyStatus(rune_id)
    if self.cur_petdata == nil then return false end
    local study_rune_data = BaseUtils.copytab(self.cur_petdata.pet_rune)
    for _,v in ipairs(study_rune_data) do
        if rune_id == v.rune_id then 
            return true
        end
    end
    return false
end

--判断是否已学习高级内丹
function PetModel:JudgeStudySmartStatus()
    if self.cur_petdata == nil then return false end
    local study_rune_data = BaseUtils.copytab(self.cur_petdata.pet_rune)
    for _,v in ipairs(study_rune_data) do
        if v.rune_type == 2 then 
            return true
        end
    end
    return false
end

--判断内丹与当前已学习高级内丹共鸣状态
function PetModel:JudgeRuneResonancesStatus(rune_id)
    if self.cur_petdata == nil then return false end
    local rune_data = BaseUtils.copytab(self.cur_petdata.pet_rune)

    local tab = {}
    for _,v in ipairs(rune_data) do
        if v.rune_type == 2 then 
            tab = v
        end
    end

    if tab and tab.resonances then      
        for _,v in ipairs(tab.resonances) do
            if rune_id == v.resonance_id then 
                return true
            end
        end
    end
    return false
end



function PetModel:GetPetItemPriceFromGoldMarket(id)
    if MarketManager.Instance.model.goldItemList == nil or MarketManager.Instance.model.goldItemList[3] == nil then return end
    local list = MarketManager.Instance.model.goldItemList[3][7]
    for key, value in pairs(list) do
        if value.base_id == id then
            return value
        end
    end
    list = MarketManager.Instance.model.goldItemList[3][8]
    for key, value in pairs(list) do
        if value.base_id == id then
            return value
        end
    end
    list = MarketManager.Instance.model.goldItemList[3][9]
    for key, value in pairs(list) do
        if value.base_id == id then
            return value
        end
    end
    return nil
end
