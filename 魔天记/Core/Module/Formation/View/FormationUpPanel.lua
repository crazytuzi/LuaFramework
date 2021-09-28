require "Core.Module.Common.UIComponent"

local FormationUpPanel = class("FormationUpPanel",UIComponent);
function FormationUpPanel:New()
	self = { };
	setmetatable(self, { __index =FormationUpPanel });
	return self
end
local Mlev

function FormationUpPanel:_Init()
    Mlev = FormationManager.GetMaxLev()
	self:_InitReference();
	self:_InitListener();
    self:UpdateTips()
    self.initGo = true
end

function FormationUpPanel:_InitReference()
	local txts = UIUtil.GetComponentsInChildren(self._gameObject, "UILabel");
	self._txtLev = UIUtil.GetChildInComponents(txts, "txtLev");
	self._txtName = UIUtil.GetChildInComponents(txts, "txtName");
	self._txtAtt = UIUtil.GetChildInComponents(txts, "txtAtt");
	self._txtAtt2 = UIUtil.GetChildInComponents(txts, "txtAtt2");
	self._txtAttAdd = UIUtil.GetChildInComponents(txts, "txtAttAdd");
	self._txtPress = UIUtil.GetChildInComponents(txts, "txtPress");
	--self._imgIcon = UIUtil.GetChildByName(self._gameObject, "UITexture", "imgIcon");
	local btns = UIUtil.GetComponentsInChildren(self._gameObject, "UITexture");
	self._btnIcon1 = UIUtil.GetChildInComponents(btns, "btnIcon1");
	self._btnIcon2 = UIUtil.GetChildInComponents(btns, "btnIcon2");
	self._btnIcon3 = UIUtil.GetChildInComponents(btns, "btnIcon3");
	self._btnIcon4 = UIUtil.GetChildInComponents(btns, "btnIcon4");
	local sprs = UIUtil.GetComponentsInChildren(self._gameObject, "UISprite");
	self._imgTip1 = UIUtil.GetChildInComponents(sprs, "imgTip1");
	self._imgTip2 = UIUtil.GetChildInComponents(sprs, "imgTip2");
	self._imgTip3 = UIUtil.GetChildInComponents(sprs, "imgTip3");
	self._imgTip4 = UIUtil.GetChildInComponents(sprs, "imgTip4");
 	self._trsGrade = UIUtil.GetChildByName(self._gameObject, "Transform", "trsGrade");
 	self._slider = UIUtil.GetChildByName(self._trsGrade, "UISlider", "slider_load");
	self._sliderSpr = UIUtil.GetComponent(self._slider, "UISprite")
 	self._trsMaxLev = UIUtil.GetChildByName(self._gameObject, "Transform", "trsMaxLev");

	self._roleParent = UIUtil.GetChildByName(self._transform, "imgRole/heroCamera/trsRoleParent");

    self.maxAwardNum = 3
    for i = 1, self.maxAwardNum do
        local trs = UIUtil.GetChildByName(self._trsGrade, "Transform", "product" .. i)
        self["product" .. i] = trs
        local ctr = ProductCtrl:New()
        self["productCtr" .. i] = ctr
        ctr:Init(trs, { hasLocke = false, use_sprite = true, iconType = ProductCtrl.IconType_rectangle })
        ctr:SetOnClickBtnHandler(ProductCtrl.TYPE_NONE)
        ctr.fShowNumTxt = true
        ctr:SetOnClickCallBack(self.OnClick, self)
        ctr:SetOnPressCallBack(self.OnPress, self)
        ctr:SetNotProductClickHander(self.OnClickNot, self)
    end
	self._iconParent1 = UIUtil.GetChildByName(self._btnIcon1, "heroCamera/trsRoleParent")
	self._iconParent2 = UIUtil.GetChildByName(self._btnIcon2, "heroCamera/trsRoleParent")
	self._iconParent3 = UIUtil.GetChildByName(self._btnIcon3, "heroCamera/trsRoleParent")
	self._iconParent4 = UIUtil.GetChildByName(self._btnIcon4, "heroCamera/trsRoleParent")
	--self._iconModel = UIHeroAnimationModel:New(data, self._iconParent1)
    self:UpdateEnable()
    self:InitSkill()
    self.timer = Timer.New(function() self:_SelectAim() end, 0, -1, true):Start()
end
function FormationUpPanel:_SelectAim()
    if not self.selectTrs then return end
    self.selectTrs.transform:Rotate(Vector3.up * 3)
end
function FormationUpPanel:InitSkill()
	self.skillNum = 4
    self.skills = {}
    self._trsSkills = UIUtil.GetChildByName(self._gameObject, "Transform", "skills/")
    for i = 1, self.skillNum do
        local skill = {}
        skill.icon = UIUtil.GetChildByName(self._trsSkills, "UISprite", "imgSkill" .. i)
        skill.icon.name = i
        skill.txt = UIUtil.GetChildByName(skill.icon, "UILabel", "openLev")
        skill.idx = i
	    self._onClickSkill = function(go) self:_OnClickSkill(go) end
        --新手要调z轴,而_btnIcon1上有动画会改z轴
	    UIUtil.GetComponent(skill.icon, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickSkill)
        table.insert(self.skills, skill)
    end
end
function FormationUpPanel:_OnClickSkill(go)
	local idx = tonumber(go.name)
    local skill = self.skills[idx]--{ icon_id, name, desc, getDes}
    ModuleManager.SendNotification(MainUINotes.OPEN_SKILL_TIP_PANEL ,skill)
end

function FormationUpPanel:UpdatePanel(spId)
	self:UseProduct(spId)
end

function FormationUpPanel:SetEnable(enable, panel)
    if enable and not self._transform then
        self.panel = panel
        local go = self.panel:AddSubPanel(ResID.UI_ARTIFACT_PANEL)
        self:Init(go.transform)
        self.initGo = true
    end
    if self._transform then SetUIEnable(self._transform, enable) end
end

function FormationUpPanel:_InitListener()
	self._onClickBtnIcon1 = function(go) self:_OnClickBtnIcon1(self) end
    --新手要调z轴,而_btnIcon1上有动画会改z轴
	UIUtil.GetComponent(self._btnIcon1.transform.parent, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIcon1);
	self._onClickBtnIcon2 = function(go) self:_OnClickBtnIcon2(self) end
	UIUtil.GetComponent(self._btnIcon2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIcon2);
	self._onClickBtnIcon3 = function(go) self:_OnClickBtnIcon3(self) end
	UIUtil.GetComponent(self._btnIcon3, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIcon3);
	self._onClickBtnIcon4 = function(go) self:_OnClickBtnIcon4(self) end
	UIUtil.GetComponent(self._btnIcon4, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnIcon4);
	MessageManager.AddListener(FormationNotes, FormationNotes.FORMATION_CHANGE, FormationUpPanel.Update, self)
end

function FormationUpPanel:UseProduct(sid)
    local fid = nil
    if sid then fid = FormationManager.GetFidByPid(sid) end
    if not fid then fid = Util.GetInt("FormationUpPanel_Last", -1) end
    if not fid or fid == -1 then fid = 1 end
    self:SetAtts(fid, true)
end


function FormationUpPanel:_OnClickBtnIcon1()
	self:SetAtts(1)
end

function FormationUpPanel:_OnClickBtnIcon2()
	self:SetAtts(2)
end

function FormationUpPanel:_OnClickBtnIcon3()
	self:SetAtts(3)
end

function FormationUpPanel:_OnClickBtnIcon4()
	self:SetAtts(4)
end
function FormationUpPanel:_SetAnimatorPlay(spr, f, trs)
	local animator = UIUtil.GetComponent(spr, "Animator")
    --Warning(spr.name .. '---' .. tostring(f))
    if not animator then
        local ats = UIUtil.GetComponentsInChildren(spr, "Animator")
        if ats and ats.Length > 0 then animator = ats[0] end
    end
    if animator then animator.enabled = f end
    trs:GetChild(0):GetChild(0).gameObject:SetActive(f)

--    if f then
--        animator:Play("selected")
--	else
--        animator:Play("stand")
--	end
end

function FormationUpPanel:SetAtts(id, auto)
    local btnIcon = self['_btnIcon' .. id]
    local trs = self['_iconParent' .. id]
    if id ~= self.cid then
        if self.cid then
            self.selectTrs.transform.localRotation = Vector3.zero
            self:_SetAnimatorPlay(self['_btnIcon' .. self.cid], false, self.selectTrs)
        end
	    self:_SetAnimatorPlay(btnIcon, true, trs)
        self.selectTrs = trs
    end
	self.cid = id
    local c = FormationManager.GetConfigById(id)
    self._txtName.text = c.name
    local d = FormationManager.GetDataById(id, true)
    local lev = d.lev
    self:SetLev(lev, d.exp)
--    self._imgIcon.mainTexture = btnIcon.mainTexture
--    if lev < 1 then ColorDataManager.SetGray(self._imgIcon)
--    else ColorDataManager.UnSetGray(self._imgIcon) end
    if not self._selectEffect then
        self._selectEffect = UIEffect:New()
        self._selectEffect:Init(btnIcon.transform.parent, btnIcon , 0, "ui_graphic", 3)
        self._selectEffect:Play()
    else
        self._selectEffect:SetParent(btnIcon.transform.parent)
    end
    self._selectEffect:SetPos(0, -111)

    local c2 = FormationManager.GetAttForLev(lev)
    local at = FormationManager.GetAttForConfig(c)

    local s = self:GetAttText(at, c2)
    if s == '' then
        local c3 = FormationManager.GetAttForLev(lev + 1)
        s = LanguageMgr.Get('FormationUpPanel/open') .. self:GetAttText(at, c3)
    end
    self._txtAtt.text = s
    self._txtAtt2.text = s

    self._txtAttAdd.text = self:GetAttAddText(at)

    local maxflg = lev <= Mlev
    if maxflg then
        self._trsGrade.gameObject:SetActive(true)
        self._trsMaxLev.gameObject:SetActive(false)
        self:SetProduct(c)
        local maxExp = c2.exp
        local exp = d.exp
        if exp > maxExp then exp = maxExp end
        self._slider.value = exp / maxExp
        self._txtPress.text = exp .. '/' .. maxExp
    else
        self._trsMaxLev.gameObject:SetActive(true)
        self._trsGrade.gameObject:SetActive(false)
    end
    self:UpdateSkills(id, lev)
    Util.SetInt("FormationUpPanel_Last", id)
    if not auto then SequenceManager.TriggerEvent(SequenceEventType.Guide.ZHENTU_SELECT) end
end
function FormationUpPanel:SetLev(lev, exp)
    self._txtLev.text = lev < 1 and LanguageMgr.Get("FormationUpPanel/noLev")
        or LanguageMgr.Get("FormationUpPanel/lev", { n = lev })
    self.clev = lev
    self.cexp = exp
end
function FormationUpPanel:UpdateSkills(id, lev)
    local sds = FormationManager.GetSkillForId(id)
    --PrintTable(sds,'',Warning) Warning(id .. '----' .. lev)
    if #sds == 0 then
        self._trsSkills.gameObject:SetActive(false)
        self._txtAtt.gameObject:SetActive(false)
        self._txtAtt2.gameObject:SetActive(true)
        return 
    end
    self._txtAtt.gameObject:SetActive(true)
    self._txtAtt2.gameObject:SetActive(false)
    self._trsSkills.gameObject:SetActive(true)
    for i = 1, self.skillNum do
        local skill = self.skills[i]
        local sd = sds[i]
        --Warning(i .. '----' .. sd.skill_id)
        local sc = SkillManager:GetSkillById(sd.skill_id)
        local icon = skill.icon
        local txt = skill.txt
        icon.spriteName = sc.icon_id
        local openDes = ''
        if sd.level > lev then
            ColorDataManager.SetGray(icon)
            openDes = LanguageMgr.Get("role/artifact/unLock",{n = sd.level})
            txt.text = openDes
        else
            ColorDataManager.UnSetGray(icon)
            txt.text = ''
        end
        skill.icon_id = sc.icon_id
        skill.name = sc.name
        skill.desc = sc.skill_desc
        skill.getDes = LanguageMgr.Get("role/artifact/unLockDes"
            ,{n = sd.level, s = sd.name })
    end
end

function FormationUpPanel:SetProduct(c)
    local ps = c.need_item
    local awards = {}
    for i = 1, #ps do
        local p = ps[i]
        local n = BackpackDataManager.GetProductTotalNumBySpid(p)
        local pd = ProductInfo:New()
        pd:Init( { spId = p, am = n })
        table.insert(awards, pd)
    end
    for i = 1, self.maxAwardNum do
        local ctr = self["productCtr" .. i]
        ctr:SetData(awards[i]);
        ctr:UpdateSelect(ctr:GetProductInfo():GetAm() > 0)
    end    
end
function FormationUpPanel:GetAttText(at, c2)
    local attr = FormationManager.GetAttAdd(at, c2)
    return FormationUpPanel:GetAttStr(attr, '\n')
end
function FormationUpPanel:GetAttAddText(at)
    local attr = FormationManager.GetAttGap(at)
	local s = FormationUpPanel:GetAttStr(attr, ' ')
    return LanguageMgr.Get("FormationUpPanel/upAdd",{s = s})
end
function FormationUpPanel:GetAttStr(attr, gap)
	local s = ''
    local propertyData = attr:GetPropertyAndDes()
    if (propertyData[1]) then
        s = propertyData[1].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(),
             "+" .. propertyData[1].property .. propertyData[1].sign)
    end
    if (propertyData[2]) then
        s = s .. gap .. propertyData[2].des .. ColorDataManager.GetColorText(ColorDataManager.Get_green(),
             "+" .. propertyData[2].property .. propertyData[2].sign)
    end
    return s
end
function FormationUpPanel:Update(d)
	if self.cid  == d.id then
        self:UpdateEnable(self.cid)
        self:SetAtts(self.cid, true)
        if self._expEffect == nil then
            self._expEffect = UIEffect:New();
            self._expEffect:Init(self._slider.transform, self._sliderSpr, 1, "ui_refining_1", 3)
        end
        self._expEffect:Play()
    end
    if d.upgrade then
        UISoundManager.PlayUISound(UISoundManager.ui_enhance1)
        if not self._upgradeEffect then
            self._upgradeEffect = UIEffect:New()
            self._upgradeEffect:Init(self._transform, self._btnIcon4 , 2, "ui_suit", 3)
        end
        self._upgradeEffect:Play()
    end
    self:UpdateTips()
end
function FormationUpPanel:UpdateTips()
    local res = FormationManager.GetHasTips()
    for i = 1, 4 do 
        self['_imgTip' .. i].enabled = table.contains(res, i)
    end
end
function FormationUpPanel:UpdateEnable(id)
    for i = 1, 4 do
        local d = FormationManager.GetDataById(i)
        local img = self['_btnIcon' .. i]
        if not d or d.lev < 1 then ColorDataManager.SetGray(img)
        else ColorDataManager.UnSetGray(img) end
        if id ~= i then
            self:_SetAnimatorPlay(img, false, self['_iconParent' .. i])
        end
    end
end

function FormationUpPanel:OnClick(pf)
    --Warning('OnClick---' .. tostring(pf))
    self:_SendUse(pf, 1)
end
function FormationUpPanel:OnClickNot(pc)
    --Warning('OnClickNot---' .. tostring(pc))
    if self.cid == 3 then
        --ModuleManager.SendNotification(MallNotes.OPEN_MALLPANEL, { val = 3, other = 13 })
        ModuleManager.SendNotification(ActivityGiftsNotes.OPEN_ACTIVITYGIFTSPANEL,{code_id=3, other = 13 });
        return
    end
    local pf = pc:GetProductInfo()
	ModuleManager.SendNotification(ProductGetNotes.SHOW_EQUIP_GET_PANEL
        , {id = pf:GetSpId(), msg= FormationNotes.CLOSE_FORMATION_PANEL})
    SequenceManager.TriggerEvent(SequenceEventType.Guide.ZHENTU_TISHENG)
end
function FormationUpPanel:OnPress(f, pf, pc)
    --Warning('OnPress---' .. tostring(f))
	if f then
        self.cNum = pf:GetAm()
        if self.cNum > 0 then
            self.addNum = 1
            if self._timer then self._timer:Stop() self._timer = nil end
            self._timer = Timer.New(function() self:_AddNum(pc, pf) end, 0.1, -1, false)
            self._timer:Start()
        end
    else
        self:_SendUse(pf)
    end
end
function FormationUpPanel:_AddNum(pc, pf)
    --Warning(self.cNum .. '-' .. self.addNum)
    local limit = self.cNum - self.addNum
    pc:UpAm(limit)
    if limit == 0 then
        self:_SendUse(pf)
        return
    end
    self.addNum = self.addNum + 1
    self.cexp = self.cexp + pf:GetFunPara()[1]
    while(true) do
        local mexp = FormationManager.GetAttForLev(self.clev).exp
        local gexp = self.cexp - mexp
        if gexp >= 0 then 
            local nlev = self.clev + 1 --Warning(nlev .. '----' .. Mlev)
            if nlev > Mlev then
                self:_SendUse(pf)
                break
            end
            self:SetLev(nlev, gexp)
        else
            break
        end
    end
end
function FormationUpPanel:_SendUse(pf, n)
    --Warning(tostring(self.addNum))
    if not self.addNum then return end
	FormationProxy.SendFormationUpdate(self.cid, pf:GetSpId(), n and n or self.addNum)
    self.addNum = nil
    if self._timer then self._timer:Stop() self._timer = nil end
    SequenceManager.TriggerEvent(SequenceEventType.Guide.ZHENTU_TISHENG)
end

function FormationUpPanel:_Dispose()
    if not self.initGo then return end
	self:_DisposeListener();
	self:_DisposeReference();
    for i = 1, self.maxAwardNum do
        self["product" .. i] = nil;
        self["productCtr" .. i]:Dispose()
        self["productCtr" .. i] = nil;
    end
    if self._timer then self._timer:Stop() self._timer = nil end
    if self._upgradeEffect then self._upgradeEffect:Dispose() self._upgradeEffect = nil end
    if self._expEffect then self._expEffect:Dispose() self._expEffect = nil end
    if self._selectEffect then self._selectEffect:Dispose() self._selectEffect = nil end
	if(self._uiHeroAnimationModel) then
		self._uiHeroAnimationModel:Dispose()
		self._uiHeroAnimationModel = nil
	end
    if self.timer then self.timer:Stop() self.timer = nil end
end

function FormationUpPanel:_DisposeListener()
	UIUtil.GetComponent(self._btnIcon1.transform.parent, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnIcon1 = nil;
	UIUtil.GetComponent(self._btnIcon2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnIcon2 = nil;
	UIUtil.GetComponent(self._btnIcon3, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnIcon3 = nil;
	UIUtil.GetComponent(self._btnIcon4, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnIcon4 = nil;
    MessageManager.RemoveListener(FormationNotes, FormationNotes.FORMATION_CHANGE, FormationUpPanel.Update, self)
end

function FormationUpPanel:_DisposeReference()
	self._btnIcon1 = nil;
	self._btnIcon2 = nil;
	self._btnIcon3 = nil;
	self._btnIcon4 = nil;
	self._txtLev = nil;
	self._txtName = nil;
	self._txtAtt = nil;
	self._txtAttAdd = nil;
	self._txtPress = nil;
	self._imgIcon = nil;
end
return FormationUpPanel