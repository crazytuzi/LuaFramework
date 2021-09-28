local _M = { }
_M.__index = _M

local PetModel = require 'Zeus.Model.Pet'
local Util = require 'Zeus.Logic.Util'
local cjson = require "cjson" 
local ItemModel = require 'Zeus.Model.Item'

function _M:onExit()
    
    if self.root ~= nil then
        self.root:RemoveFromParent(true)
        self.root = nil
    end

    for _, v in pairs(self.itemFilter) do
        DataMgr.Instance.UserData.RoleBag:RemoveFilter(v)
    end

    self.itemFilter = nil
end

local ui_names = {
    "cvs_upgrade_detail",
    "lb_attributename",
    "lb_attributename1",
    "lb_attributename2",
    "lb_attributename3",
    "lb_attributenum",
    "lb_attributenum1",
    "lb_attributenum2",
    "lb_attributenum3",
    "lb_attributebonus1",
    "lb_attributebonus2",
    "lb_attributebonus3",
    "lb_attributebonus4",
    "lb_additionnum1",
    "lb_additionnum2",
    "lb_additionnum3",
    "lb_additionnum4",
    "cvs_unlockedskill",
    "lb_demandnum",
    "ib_demandicon",
    "cvs_demandicon",
    "tb_demandall",
    "btn_gradeup",

    "lb_skillname",
    "cvs_skill",
    "ib_unlockedicon",
    "ib_chongwutupo",
    "lb_maxtip",
}

local useItemName = ''
local useItemNum_before = 0
local useItemNum_after = 0
local gradeupLv_before = 0
local gradeupLv_after = 0

local function setAddAttr(node, type, before, after)
    local lb_type = node:FindChildByEditName('lb_type', false)
    local lb_beforenum = node:FindChildByEditName('lb_beforenum', false)
    local lb_afternum = node:FindChildByEditName('lb_afternum', false)
    local lb_to = node:FindChildByEditName('lb_to', false)
    if type ~= nil then
        lb_type.Text = type .. ":"
        lb_beforenum.Text = before / 100 .. "%"
        lb_afternum.Text = after / 100 .. "%"
    else
        lb_beforenum.Text = before
        lb_afternum.Text = after
    end

    if tonumber(after) == 0 then
        lb_to.Visible = false
        lb_afternum.Visible = false
    end
end 

local function InitItemUI(ui, uinames, node)
    
    for i = 1, #uinames do
        ui[uinames[i]] = node:FindChildByEditName(uinames[i], true)
    end

end

function _M.CreateUpgradeUI(parent, effPar)
    local ret = { }
    setmetatable(ret, _M)
    ret.root = XmdsUISystem.CreateFromFile("xmds_ui/pet/upgrade.gui.xml")
    InitItemUI(ret, ui_names, ret.root)
    if (parent) then
        parent:AddChild(ret.root)
    end

    ret.btn_gradeup.TouchClick = function(sender)       

        local serverData = PetModel.getPetData(ret.petData.PetID)
        local curData = GlobalHooks.DB.Find('PetUpgrade', { PetID = ret.petData.PetID, TargetUpLevel = serverData.upLevel })
        local nextData = GlobalHooks.DB.Find('PetUpgrade', { PetID = ret.petData.PetID, TargetUpLevel = serverData.upLevel + 1 })

        local maxUpLv = tonumber(GlobalHooks.DB.Find("PetConfig", { ParamName = "Upgrade.LevelLimit" })[1].ParamValue)
        if serverData.upLevel >= maxUpLv then
            GameAlertManager.Instance:ShowNotify(Util.GetText(TextConfig.Type.PET, "maxLevel"))
            return
        end

        if #curData == 0 then
            
            local data = nextData[1]
            local bag_data = DataMgr.Instance.UserData.RoleBag
            local vItem = bag_data:MergerTemplateItem(data.MateCode)
            local num =(vItem and vItem.Num) or 0
            useItemNum_before = num
        else
            if #nextData == 0 then
                local data = curData[1]
                local bag_data = DataMgr.Instance.UserData.RoleBag
                local vItem = bag_data:MergerTemplateItem(data.MateCode)
                local num =(vItem and vItem.Num) or 0
                useItemNum_before = num

            else
                local data1 = curData[1]
                local data2 = nextData[1]
                local bag_data = DataMgr.Instance.UserData.RoleBag
                local vItem = bag_data:MergerTemplateItem(data1.MateCode)
                local num =(vItem and vItem.Num) or 0
                useItemNum_before = num

            end
        end
        
        PetModel.upGradeUpLevelRequest(ret.petData.PetID, function()
            EventManager.Fire("Event.UI.PetUIMain.Refresh", { })
            ret:setPetInfo(ret.petData)
            if effPar ~= nil then
                effPar.Visible = true
                Util.showUIEffect(effPar, 54)
                Util.showUIEffect(ret.ib_chongwutupo, 31)
            end
            XmdsSoundManager.GetXmdsInstance():PlaySoundByKey("petbreak")

            
            
            
            
            
            
            
            
            

        end )
    end

    ret.root.Visible = false



    return ret
end

function _M:setPetInfo(petData)
    
    self.petData = petData
    self.root.Visible = true
    local serverData = PetModel.getPetData(self.petData.PetID)
    local maxUpLv = tonumber(GlobalHooks.DB.Find("PetConfig", { ParamName = "Upgrade.LevelLimit" })[1].ParamValue)


    local  lv = 1
    if serverData == nil then
        self.lb_attributenum.Text = petData.BasePhyDamage or ""
        self.lb_attributenum1.Text = petData.BaseMagDamage or ""
        self.lb_attributenum2.Text = petData.initHit or ""
        self.lb_attributenum3.Text = petData.initCrit or ""
        serverData = {upLevel = 0}
    else
        lv = serverData.level
        if serverData.upLevel < maxUpLv and serverData.next_attrs_final then
            local attrs = {}
            for _,v in ipairs(serverData.next_attrs_final) do
                attrs[v.id] = v.value
            end

            self.lb_attributenum.Text = attrs[5] or ""
            self.lb_attributenum1.Text = attrs[7] or ""
            self.lb_attributenum2.Text = attrs[9] or ""
            self.lb_attributenum3.Text = attrs[15] or ""
        end
    end

    
    local masterdata = GlobalHooks.DB.Find('MasterProp',{PropID = petData.PetID})[1]
    local masterdataEx = GlobalHooks.DB.Find('MasterUpgradeProp',{PetID = petData.PetID, UpLevel = serverData.upLevel+1})[1]
    local nextData = GlobalHooks.DB.Find('PetUpgrade', { PetID = petData.PetID, TargetUpLevel = serverData.upLevel + 1 })
    
    if serverData.upLevel < maxUpLv then
        if masterdata ~= nil then
        for i=1,4 do
            self['lb_attributebonus' .. i].Text = masterdata['Prop' .. i] .. ':'
            local value = math.floor( math.pow(masterdata['Grow' ..i ],lv - 1)*masterdata['Min' .. i] + 0.5)
            if masterdataEx then
                value = value + masterdataEx['PetMin' ..i ]
            end
            self['lb_additionnum' .. i].Text = value
        end
        else
            for i=1,4 do
                self['lb_attributebonus' .. i].Visible = false
                self['lb_additionnum' .. i].Visible = false
            end
        end
        self.lb_maxtip.Visible = false
        self.cvs_upgrade_detail.Visible = true
    else
        self.lb_maxtip.Visible = true
        self.cvs_upgrade_detail.Visible = false
    end

    self.cvs_unlockedskill.Visible = false
    if #nextData ~= 0 then
        local data = nextData[1]
        
        
        
        
        
        

        local item = GlobalHooks.DB.Find("Items", data.MateCode)
        local itemShow = Util.ShowItemShow(self.cvs_demandicon, item.Icon, item.Qcolor)
        itemShow.EnableTouch = true
        Util.NormalItemShowTouchClick(itemShow, data.MateCode, true)

        self.itemFilter = self.itemFilter or { }
        local filter = self.itemFilter[data.MateCode]
        if filter then
            DataMgr.Instance.UserData.RoleBag:RemoveFilter(filter)
        end
        filter = ItemPack.FilterInfo.New()
        self.itemFilter[data.MateCode] = filter

        filter.MergerSameTemplateID = true
        filter.CheckHandle = function(item)
            return item.TemplateId == data.MateCode
        end
        filter.NofityCB = function(pack, type, index)

            if type ~= ItemPack.NotiFyStatus.ALLSHOWITEM then
                local bag_data = DataMgr.Instance.UserData.RoleBag
                local vItem = bag_data:MergerTemplateItem(data.MateCode)
                local num =(vItem and vItem.Num) or 0

                if vItem and vItem.TemplateId then
                    useItemName = ItemModel.GetItemStaticDataByCode(data.MateCode).Name .. "(" .. data.MateCode .. ")"
                end
                useItemNum_after = num
                local text = num .. "/" .. data.MateCount
                if num < data.MateCount then
                    text = string.format("<f color='%s'>%s</f>", Util.GetQualityColorARGBStr(GameUtil.Quality_Red), text)
                    self.tb_demandall.UnityRichText = text
                else
                    self.tb_demandall.UnityRichText = text
                end

                if serverData.level < data.ReqLevel or num < data.MateCount then
                    self.btn_gradeup.Enable = false
                    self.btn_gradeup.IsGray = true
                else
                    self.btn_gradeup.Enable = true
                    self.btn_gradeup.IsGray = false
                end
            end
        end
        DataMgr.Instance.UserData.RoleBag:AddFilter(filter)



        if nextData[1].OpenSkillID ~= 0 then
            local ret = GlobalHooks.DB.Find('PetSkill', { SkillID = nextData[1].OpenSkillID })
            if #ret ~= 0 then

                self.cvs_unlockedskill.Visible = true
                self.lb_skillname.Text = ret[1].SkillName
                MenuBaseU.SetImageBoxFroXmlKey(self.ib_unlockedicon.Parent, "ib_unlockedicon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..ret[1].SkillIcon, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
                self.cvs_skill.Enable = true
                self.cvs_skill.event_PointerDown = function(sender)
                    local cdata = { }
                    cdata.id = tonumber(ret[1].SkillID)
                    cdata.lv = 1
                    local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetSkillInfo, 0)
                    ui.SetPetInfo(cdata)
                    ui.SetPetPos(self.cvs_skill:LocalToGlobal())
                end

                self.cvs_skill.event_PointerUp = function(sender)
                    GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIPetSkillInfo)
                end
            end
        end
    end
end

return _M
