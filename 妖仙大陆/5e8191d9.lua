local _M = { }
_M.__index = _M


local creater = require "Zeus.UI.FormatUI"
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local EventItemDetail = require "Zeus.UI.XmasterBag.EventItemDetail"
local IS_SHOW_MIN_MAX = false
local FONT_MIDDLE = 22
local FONT_LARGE = 28
local FONT_SMALL = 20

local TXT_COLOR =
{
    WHITE = Util.GetQualityColorRGBA(GameUtil.Quality_Default),
    GREEN = Util.GetQualityColorRGBA(GameUtil.Quality_Green),
    BLUE = Util.GetQualityColorRGBA(GameUtil.Quality_Blue),
    PURPLE = Util.GetQualityColorRGBA(GameUtil.Quality_Purple),
    ORANGE = Util.GetQualityColorRGBA(GameUtil.Quality_Orange),
    RED = Util.GetQualityColorRGBA(GameUtil.Quality_Red),
    YELLOW = 0xffff00ff,
    GRAY = 0x5e5e5eff,
}

local Text = {
    Txt_needLv = Util.GetText(TextConfig.Type.ITEM,'needLv'),
    Txt_sell = Util.GetText(TextConfig.Type.ITEM,'sellPrice'),
    Txt_durability = Util.GetText(TextConfig.Type.ITEM,'durability'),
    Txt_score = Util.GetText(TextConfig.Type.ITEM,'score'),
    Txt_attrRandom = Util.GetText(TextConfig.Type.ITEM,'attrRandom'),
    Txt_magic = Util.GetText(TextConfig.Type.ITEM,'attrMagic'),
    Txt_gemSlot = Util.GetText(TextConfig.Type.ITEM,'gemSlot'),
    Txt_emptySlot = Util.GetText(TextConfig.Type.ITEM,'emptySlot'),
    Txt_inlay = Util.GetText(TextConfig.Type.ITEM,'inlay'),
    Txt_or = Util.GetText(TextConfig.Type.ITEM,'or'),
    Txt_cantSell = Util.GetText(TextConfig.Type.ITEM,'cantSell'),
    Txt_maxLimit = Util.GetText(TextConfig.Type.ITEM,'maxLimit'),
    Txt_unidentified = Util.GetText(TextConfig.Type.ITEM,'unidentified'),
    Txt_levelDesc = Util.GetText(TextConfig.Type.ITEM,'levelDesc'),
    Txt_upLevelDesc = Util.GetText(TextConfig.Type.ITEM,'upLevelDesc'),
    Txt_proDesc = Util.GetText(TextConfig.Type.ITEM,'proDesc'),
    Txt_maxCount = Util.GetText(TextConfig.Type.ITEM,'maxCount'),
    Txt_count = Util.GetText(TextConfig.Type.ITEM,'count'),
    Txt_useLevel = Util.GetText(TextConfig.Type.ITEM,'useLevel'),
    Txt_enLevelDesc = Util.GetText(TextConfig.Type.ITEM,'enLevelDesc'),
    Txt_starAttrDesc = Util.GetText(TextConfig.Type.ITEM,'starAttrDesc'),
    Txt_magicDes = Util.GetText(TextConfig.Type.ITEM,'attrMagic'),
    Txt_unkownScore = Util.GetText(TextConfig.Type.ITEM,'unkownScore'),
    Txt_identify1 = Util.GetText(TextConfig.Type.ITEM,'identify1'),
    Txt_identify2 = Util.GetText(TextConfig.Type.ITEM,'identify2'),
    Txt_amuletSpace = Util.GetText(TextConfig.Type.ITEM,'amuletSpace'),
    Txt_both_hands = Util.GetText(TextConfig.Type.ITEM,'both_hands'),
    Txt_bind0 = Util.GetText(TextConfig.Type.ITEM,'noBind'),
    Txt_bind1 = Util.GetText(TextConfig.Type.ITEM,'binded'),
    Txt_bind2 = Util.GetText(TextConfig.Type.ITEM,'equipBind'),
    Txt_bind3 = Util.GetText(TextConfig.Type.ITEM,'pickBind'),
    Txt_bind4 = Util.GetText(TextConfig.Type.ITEM,'buyBind'),
    Text_magicEffect = Util.GetText(TextConfig.Type.ITEM,'enchantedTitle1'),
    noRefine = Util.GetText(TextConfig.Type.ITEM,'noRefine'),
    advanceSuffix = Util.GetText(TextConfig.Type.ITEM,'advanceSuffix'),
}


local function DescFormat(str, numColor, ...)
    local r = { '{A}', '{B}', '{C}', '{D}', '{E}', '{F}', '{G}', '{H}', '{I}', '{J}', '{K}', '{L}' }
    local params = { ...}
    for i = 1, #params do
        local subText = params[i]
        if numColor then
            subText = string.format('<color=#%s>%s</color>', numColor, subText)
        end
        str = string.gsub(str, r[i], subText)
    end
    return str
end






local function GetAttrDesc(attr, numColor)
    local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)


    
    if attrdata.attParamCount == 1 then
        local v =(attrdata.isFormat == 1 and attr.value / 100) or attr.value
        return DescFormat(attrdata.attDesc, numColor, v or 0)
    elseif attrdata.attParamCount > 1 then
        local params = { }
        for i = 1, attrdata.attParamCount do
            
            if i == 1 and string.find(attrdata.attKey, 'Skill') then
                
                local sd = GlobalHooks.DB.Find('SkillData', attr.param1)
                if sd then
                    table.insert(params, sd.SkillName)
                else
                    table.insert(params, attr['param' .. i] or 0)
                end
            else
                local v =(attrdata.isFormat == 1 and attr['param' .. i] / 100) or attr['param' .. i]
                
                table.insert(params, v or 0)
            end
        end
        return DescFormat(attrdata.attDesc, numColor, unpack(params))
    else
        return attrdata.attDesc
    end
end


local function get_attr_color(min, max, value)
    local A = value - min
    local B = max - min
    local X = tonumber((A / B + 0.005) * 100)
    if X < 33 then
        return TXT_COLOR.GREEN
    elseif X < 66 then
        return TXT_COLOR.BLUE
    elseif X < 90 then
        return TXT_COLOR.PURPLE
    else
        return TXT_COLOR.ORANGE
    end
end


local function get_gem_icon(code)
    return "static_n/item/" .. code .. ".png";
end



function _M:Close()
    if self.eventItemDetail then
        self.eventItemDetail:Close();
    end
    self.menu:Close()
end

function _M:SetItem(data, isEquip)
    local detail = data.detail
    self.data = data
    if (isEquip) then
        self.equip.Visible = true
        self.material.Visible = false
        self:setEquip(detail)
    else
        self.equip.Visible = false
        self.material.Visible = true
        self:setMaterial(detail,data)
    end
    
    if self.eventItemDetail == nil then
        self.eventItemDetail = EventItemDetail.Create(3)
    end
    self.eventItemDetail:SetItem(data)
    GameGlobal.WaitForSeconds(0.05,function()
        self:LookAtTop(isEquip)
    end)
end

function _M:SetItemDetail(detail)
    self.content_node = self.menu:GetComponent('cvs_detailed')
    local isEquip = ItemData.CheckIsEquip(detail.itemType)
    if (isEquip) then
        self.equip.Visible = true
        self.material.Visible = false
        self:setEquip(detail)
    else
        self.equip.Visible = false
        self.material.Visible = true
        self:setMaterial(detail,nil)
    end
end

local function IsEquipOnBody(code, othersMap)
    if othersMap == nil then
        local bag_data = DataMgr.Instance.UserData.RoleEquipBag
        local vItem = bag_data:GetTemplateItem(code)
        return (vItem ~= nil)
    else
        for i,v in ipairs(othersMap) do
            if v.static.Code == code then
                return true
            end
        end 
        return false
    end
end

local function setMaterial(self, detail,data)
    self.materialCtrl.lb_materialname.Text = detail.static.Name
    self.materialCtrl.lb_materialname.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)
    Util.SetBoxLayout(self.materialCtrl.ib_bg, detail.static.Qcolor)
    if data == nil then
        self.materialCtrl.lb_num.Visible = false
    else
        self.materialCtrl.lb_num.Visible = true
        self.materialCtrl.lb_num.Text = Util.GetText(TextConfig.Type.ITEM, "yongyou") .. data.Num
    end   
    self.materialCtrl.lb_pilenum.Text = Util.GetText(TextConfig.Type.ITEM, "duidiemax") .. detail.static.GroupCount
    local bindType = detail.bindType or detail.static.BindType 
    self.materialCtrl.lb_bunding2.Text = Text['Txt_bind' ..bindType]
    if bindType == 1 then 
        self.materialCtrl.lb_bunding2.FontColorRGBA = 0x00f012ff
    else
        self.materialCtrl.lb_bunding2.FontColorRGBA = 0xffffffff
    end

    if detail.canAuction == 0 then 
            self.materialCtrl.lb_jishou.Visible = true
    else
            self.materialCtrl.lb_jishou.Visible = false
    end

    local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    local txtLv = ""
    if detail.static.LevelReq > lv then
        txtLv = "<color='#ed2a0aff'>"..detail.static.LevelReq.."</color>"
    else
        txtLv = detail.static.LevelReq
    end
    self.materialCtrl.lb_uselevel.Text = string.format(Text.Txt_useLevel, txtLv)

    
    self.materialCtrl.descText.UnityRichText = detail.static.Desc
    local h = self.materialCtrl.descText.TextComponent.RichTextLayer.ContentHeight
    self.materialCtrl.descText.Size2D = Vector2.New(self.materialCtrl.sp_content.Width - 30, h)
    self.materialCtrl.descText.X = 15
    self.materialCtrl.descText.Y = 15
    if (h < self.materialCtrl.sp_content.Height) then
        self.materialCtrl.sp_content.Scrollable.Scroll.vertical = false
    else
        self.materialCtrl.sp_content.Scrollable.Scroll.vertical = true
    end
    
    self.itemShow = Util.ShowItemShow(self.materialCtrl.svc_matirialicon, detail.static.Icon, detail.static.Qcolor)
end

local function createLine(width)
    local imgBox = HZImageBox.New()
    imgBox.Size2D = Vector2.New(width, 1)
    local style = LayoutStyle.IMAGE_STYLE_H_012
    local clipSize = 19
    local v = "#static_n/func/common1.xml|common1|23"
    Util.HZSetImage(imgBox, v, false, style, clipSize)
    return imgBox
end

local ui_names_jewel = {
    { name = "cvs_1" },
    { name = "cvs_2" },
    { name = "cvs_3" },
    { name = "cvs_4" },
    { name = "cvs_5" },
    { name = "ib_1" },
    { name = "ib_2" },
    { name = "ib_3" },
    { name = "ib_4" },
    { name = "ib_5" },
}

local function createJewel(self, strength_Pos)
    local node = self.equipCtrl.jewelNode
    local jewelAttrs = { }
    for _, v in ipairs(strength_Pos.jewelAtts or { }) do
        jewelAttrs[v.index] = v
    end
    for i = 1, 5, 1 do
        self.equipCtrl.jewelCtrl["ib_" .. i].Visible = false
        self.equipCtrl.jewelCtrl["cvs_" .. i].Visible = false
    end
    
    
    
    
    
    
    
    
    
    
    
    

    

    
            
    
    
    

    local value
    local valueNum=0 
    local valueTemp
    local txt = ''
    for i = 1, strength_Pos.socks do
        self.equipCtrl.jewelCtrl["ib_" .. i].Visible = true
        local jewelAttr = jewelAttrs[i]
        if (jewelAttr) then
            value = GetAttrDesc(jewelAttr)
            self.equipCtrl.jewelCtrl["cvs_" .. i].Visible = true
            Util.HZSetImage(self.equipCtrl.jewelCtrl["cvs_" .. i], get_gem_icon(jewelAttr.gem.icon), false, LayoutStyle.IMAGE_STYLE_BACK_4, 0)
            valueTemp = string.split(value,'+')
            valueNum = valueNum + valueTemp[2]  
        end      
    end
    if (value) then
        value = valueTemp[1].."+"..valueNum
        local addproperty =  Util.GetText(TextConfig.Type.ITEM, "addProperty",value)
        txt = string.format("<color=#e565f2ff>    %s</color> ",addproperty)
    else
        local addproperty1 =  Util.GetText(TextConfig.Type.ITEM, "addProperty",Util.GetText(TextConfig.Type.ITEM, "wu"))
        txt = string.format("<color=#e565f2ff>    %s</color> ",addproperty1)
    end
    return { node = node, txt = txt }
end

local function createSuitAttr(self,static_data, othersMap)
    local suit_data = GlobalHooks.DB.Find('SuitList',static_data.SuitID)  
    local suit_list = string.split(suit_data.PartCodeList,',')
    
    local txt = "    ".. suit_data.SuitName.."(<color='ff00f012'>%d/%d</color> )"
    local have_equip_num = 0   
    local strSuitOtherName = '' 
    local strComstr = '' 
     for i = 1,#(suit_list), 1 do  
        local suit_other_part_item = ItemModel.GetItemStaticDataByCode(suit_list[i])
        
        local strSuitFormat = "<color='ff9aa9b5'>   ·%s</color>" 
        if suit_other_part_item ~= nil then 
            if IsEquipOnBody(suit_other_part_item.Code, othersMap) then
                if i%2 == 0 then
                    strSuitFormat = "<color='ff00f012'> ·%s</color>"
                else
                    strSuitFormat = "<color='ff00f012'>   ·%s</color>"
                end
                have_equip_num = have_equip_num +1
            else
                if i%2 == 0 then
                    strSuitFormat = "<color='ff9aa9b5'> ·%s</color>"
                else
                    strSuitFormat = "<color='ff9aa9b5'>   ·%s</color>"
                end
            end  
            if i%2 == 0 then 
                strSuitOtherName = string.format(strSuitFormat,suit_other_part_item.Name.."\n" )  
            else
                strSuitOtherName = string.format(strSuitFormat,suit_other_part_item.Name)    
            end                      
        end    
        strComstr = strComstr .. strSuitOtherName
     end
     
     
     txt = string.format(txt .." \n",have_equip_num,suit_data.PartCount)
     txt = txt..strComstr 


    local suit_atts = ""
    local suit_config_table = GlobalHooks.DB.Find('SuitConfig',{SuitID = static_data.SuitID})
    local suit_atts_map = {}
    for i = 1,#(suit_config_table) do
        
        if suit_atts_map[suit_config_table[i].PartReqCount] == nil then 
            suit_atts_map[suit_config_table[i].PartReqCount] = {suit_config_table[i]}  
        else
            table.insert(suit_atts_map[suit_config_table[i].PartReqCount],suit_config_table[i])     
        end        
    end    
    
    local one = true
    for k,v in pairs(suit_atts_map) do
        local color = 'ff9aa9b5' 
        local attr = ""
        local bFrist = false  
        if have_equip_num >= k then
            color = 'ff00f012'
        end
        for i = 1,#(v) do
            local attrdata = nil
            local attrTemps = GlobalHooks.DB.Find('Attribute', {})
            for _,vv in pairs(attrTemps) do
                if v[i].Prop == vv.attName then
                    attrdata = vv
                    break
                end
            end

            local value = v[i].Min
            if attrdata.isFormat == 1 then
                value = value / 100
                local s = string.gsub(attrdata.attDesc,'{A}',string.format("%.2f",value))
                attr = attr .. string.format("\t%s",s) 
            else
                value = Mathf.Round(value)
                local s = string.gsub(attrdata.attDesc,'{A}',tostring(value))
                attr = attr .. string.format("\t%s",s) 
            end
            if i ~= #v then 
                attr = attr.."\n\t\t\t\t "
            end
        end  
        local paramsValue = Util.GetText(TextConfig.Type.ITEM,"haveEquip",k)
        if one then 
            suit_atts = suit_atts..string.format(" <f size='22' color='%s'>%s<f size='8' color='ff696969'>\n.\n</f>%s:%s</f> ",color,(bFrist and "" or "\n"),paramsValue,attr)
            one=false
        else
            
             suit_atts = suit_atts..string.format(" <f size='22' color='%s'>%s%s:%s</f> ",color,(bFrist and "" or "\n"),paramsValue,attr)
        end
    end    
    suit_atts = suit_atts
    txt = txt..suit_atts

    return txt
end


local function scoresAtts (atts)
    table.sort(atts,function (a,b) return a.id<b.id end)
end

local function createXMEquipProps(self, width, detail,strength_Pos, othersMap)
    
    
    
    
    
    
    
    local h = 0
    local format1 = '%s:%s'
    local format2 = '%s:%s-%s'
    local format3 = '(<color=#00f012ff>+%s</color>)'
    local mainText = ""
    
    if strength_Pos.enSection== nil then
        strength_Pos.enSection = 0
    end
    if strength_Pos.enLevel == nil then
        strength_Pos.enLevel = 0
    end
    local enchantKey = strength_Pos.enSection*100 + strength_Pos.enLevel 
    local enchant_data = GlobalHooks.DB.Find('Enchant', enchantKey)
    scoresAtts(detail.equip.baseAtts)
    
    for _, attr in ipairs(detail.equip.baseAtts or { }) do
        local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
        if attrdata ~= nil  then
            local value = attr.value
            if enchant_data ~= nil then
                value = value *(1 + enchant_data.PropPer/10000)
            end
            
            local tmpStr1 = ""
            local tmpStr2 = ""
            local diff = attr.value - attr.minValue
            local diffMax = attr.maxValue - attr.minValue
            if attr.value == attr.maxValue then
                tmpStr1 = Util.GetText(TextConfig.Type.ITEM, "gao")
                tmpStr2 = Util.GetText(TextConfig.Type.ITEM, "man")
            elseif diffMax > 0 and diff >= diffMax*0.7 then
                tmpStr1 = Util.GetText(TextConfig.Type.ITEM, "gao")
            end

            local v = 0
            if attrdata.isFormat == 1 then
                v = value / 100
                mainText = mainText .. "    ".. tmpStr1 .. string.gsub(attrdata.attDesc,'+{A}',": "..string.format("%.2f",v)) .. tmpStr2
            else
                v = Mathf.Round(value)
                mainText = mainText .. "    ".. tmpStr1 .. string.gsub(attrdata.attDesc,'+{A}',": "..tostring(v)) .. tmpStr2
            end
            
            





        end
        mainText = mainText .. "\n"
    end
    
    mainText = mainText .. string.format(Text.Txt_enLevelDesc, "e565f2ff", strength_Pos.enSection*10+strength_Pos.enLevel)
    self.equipCtrl.mainAttsText.Visible = true
    self.equipCtrl.mainAttsText.UnityRichText = mainText
    local txtH = self.equipCtrl.mainAttsText.TextComponent.RichTextLayer.ContentHeight
    self.equipCtrl.mainAttsText.Size2D = Vector2.New(width, txtH)
    local lElement = self.equipCtrl.mainAttsText.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = self.equipCtrl.mainAttsText.Height
    h = h + self.equipCtrl.mainAttsText.Height
    
    h = h + 2
    self.equipCtrl.imgLine1.Visible = true
    h = h + 15
    local hasExpand = false
    if (detail.equip.randomAtts) then
        hasExpand = true
        local randomText = ""
        
        scoresAtts(detail.equip.randomAtts)
        for _, attr in ipairs(detail.equip.randomAtts or { }) do
            local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
            if attrdata ~= nil  then
                local v = Mathf.Round((attrdata.isFormat == 1 and attr.value / 100) or attr.value)
                local txt = ""
                if attr.param3 and attr.param3 > 0 then
                    local pv = Mathf.Round((attrdata.PFormat == 1 and attr.param3 / 100) or attr.param3)
                    local s = string.gsub(attrdata.attDesc,'{P}',tostring(pv))
                    txt = string.gsub(s,'{A}',tostring(v))
                else
                    txt = string.gsub(attrdata.attDesc,'{A}',tostring(v))
                end

                local diff = attr.value - attr.minValue
                local diffMax = attr.maxValue - attr.minValue
                if attr.value == attr.maxValue then
                    txt =Util.GetText(TextConfig.Type.ITEM, "gao") .. txt .. Util.GetText(TextConfig.Type.ITEM, "man")
                elseif diffMax > 0 and diff >= diffMax*0.7 then
                    txt = Util.GetText(TextConfig.Type.ITEM, "gao") .. txt
                end
                
                randomText = randomText .. "    ".. txt .. '\n'
            end
            randomText = string.format('<color=#00a0ffff>%s</color>',randomText)
        end
        self.equipCtrl.randomAttsText.Visible = true
        self.equipCtrl.imgLine1.Visible = true
        self.equipCtrl.randomAttsText.UnityRichText = randomText
        local txtH = self.equipCtrl.randomAttsText.TextComponent.RichTextLayer.ContentHeight
        self.equipCtrl.randomAttsText.Size2D = Vector2.New(width, txtH)
        local lElement = self.equipCtrl.randomAttsText.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
        lElement.preferredHeight = self.equipCtrl.randomAttsText.Height
        
        h = h + self.equipCtrl.randomAttsText.Height
    end
    if (hasExpand == false) then
        self.equipCtrl.randomAttsText.Visible = false
        self.equipCtrl.imgLine1.Visible = false
    end
    
    hasExpand = false
    if (detail.equip.uniqueAtts) and #detail.equip.uniqueAtts > 0 then
        hasExpand = true
        local randomText = "<a img='#static_n/func/common2.xml,common2,174'>s</a> <f size='8' color='ff696969'>.</f> "
        local has = false
        for _, attr in ipairs(detail.equip.uniqueAtts or { }) do
            has = true
            local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
            if attrdata ~= nil then
                local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
                local txt = ""
                if attr.param3 and attr.param3 > 0 then
                    local pv = (attrdata.PFormat == 1 and string.format("%.2f", attr.param3 / 100)) or attr.param3
                    local s = string.gsub(attrdata.attDesc, '{P}', tostring(pv))
                    
                    txt = string.gsub(s, '{A}', tostring(v))
                else
                    
                    txt = string.gsub(attrdata.attDesc, '{A}', tostring(v))
                end

                randomText = randomText .. txt .. '\n'
            end
            randomText = string.format('<color=#ddac00ff>%s</color>', randomText)
            
        end
        if has then
            hasExpand = true
            self.equipCtrl.specialAttsText.Visible = true
            self.equipCtrl.imgLine3.Visible = true
            self.equipCtrl.specialAttsText.UnityRichText = randomText
            local txtH = self.equipCtrl.specialAttsText.TextComponent.RichTextLayer.ContentHeight
            self.equipCtrl.specialAttsText.Size2D = Vector2.New(width, txtH)
            local lElement = self.equipCtrl.specialAttsText.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
            lElement.preferredHeight = self.equipCtrl.specialAttsText.Height
            
            h = h + self.equipCtrl.specialAttsText.Height
        else
            hasExpand = false
        end
    end
    if (hasExpand == false) then
        self.equipCtrl.specialAttsText.Visible = false
        self.equipCtrl.imgLine3.Visible = false
    end
    
    
    
    
    
    
    
    
    

    
    if (detail.equip.starAttr) and #detail.equip.starAttr > 0 then
        local attr = detail.equip.starAttr[1]
        if attr then
            local str = ""
            local attrdata = GlobalHooks.DB.Find('Attribute', attr.id)
            if attrdata ~= nil  then
                local v = (attrdata.isFormat == 1 and string.format("%.2f", attr.value / 100)) or attr.value
                str = string.format(Text.Txt_starAttrDesc, "e565f2ff", string.gsub(attrdata.attDesc,'{A}',tostring(v)))
            end 
            
            self.equipCtrl.starsAttsText.UnityRichText = str
            local txtH = self.equipCtrl.starsAttsText.TextComponent.RichTextLayer.ContentHeight
            self.equipCtrl.starsAttsText.Size2D = Vector2.New(width, txtH)
            local lElement = self.equipCtrl.starsAttsText.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
            lElement.preferredHeight = self.equipCtrl.starsAttsText.Height
            h = h + self.equipCtrl.starsAttsText.Height + 2
            self.equipCtrl.starsAttsText.Visible = true
            
            h = h + 17
        end
    else
        self.equipCtrl.starsAttsText.Visible = false
        
    end

     
    if detail.static.SuitID ~= nil and detail.static.SuitID > 0 then
        local suitText = ""
        suitText = createSuitAttr(self,detail.static, othersMap)
        self.equipCtrl.suitAttsText.Visible = true
        self.equipCtrl.suitAttsText.UnityRichText = suitText
        local txtH = self.equipCtrl.suitAttsText.TextComponent.RichTextLayer.ContentHeight
        self.equipCtrl.suitAttsText.Size2D = Vector2.New(width, txtH)
        local lElement = self.equipCtrl.suitAttsText.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
        lElement.preferredHeight = self.equipCtrl.suitAttsText.Height
        h = h + 2
        h = h + self.equipCtrl.suitAttsText.Height
        
        self.equipCtrl.imgLine4.Visible = true
        h = h + 2
        h = h + 15

    else
        self.equipCtrl.suitAttsText.Visible = false
        self.equipCtrl.imgLine4.Visible = false
    end

    
    if strength_Pos.socks ~= nil and strength_Pos.socks > 0 then
        self.equipCtrl.jewelNode.Visible = true
        self.equipCtrl.imgLine5.Visible = true
        h = h + 2
        h = h + 35
        local jNode = createJewel(self, strength_Pos)
        local txt = jNode.txt
        if (txt) then
            self.equipCtrl.jewelAttrText.Visible = true
            self.equipCtrl.jewelAttrText.UnityRichText = txt
            local txtH = self.equipCtrl.jewelAttrText.TextComponent.RichTextLayer.ContentHeight
            self.equipCtrl.jewelAttrText.Size2D = Vector2.New(width, txtH)
            local lElement = self.equipCtrl.jewelAttrText.UnityObject:GetComponent(typeof(UnityEngine.UI.LayoutElement))
            lElement.preferredHeight = self.equipCtrl.jewelAttrText.Height
            h = h + 2
            h = h + self.equipCtrl.jewelAttrText.Height
            
            h = h + 12
        else
            self.equipCtrl.jewelAttrText.Visible = false
        end
    else
        self.equipCtrl.jewelNode.Visible = false
        self.equipCtrl.imgLine5.Visible = false
    end

    if self.autoSide then
        
        local oldHeight = 444
        local oldBtnY = 359
        local detail_max_height = 404
        local addHeight = 404 - 255
        local size = self.cvs_information_detailed.Size2D
        if h < detail_max_height then
            detail_max_height = h
            addHeight = h - 255
        end
        local height = oldHeight + addHeight
        
        self.cvs_information_detailed.Size2D = Vector2.New(size.x, height)
        self.cvs_information_detailed.X = 0
        self.cvs_information_detailed.Y = - addHeight/2
        self.equipCtrl.ib_bg2.Size2D = Vector2.New(size.x, height)
        
        self.equipCtrl.sp_content.Size2D = Vector2.New(size.x, detail_max_height)
        self.cvs_btn.Y = height - self.cvs_btn.Size2D.y
        
        self.cvs_btn.Y = self.cvs_btn.Y - 5
    end
    self.equipCtrl.canvas.Size2D = Vector2.New(width, h)
end

local function setEquip(self, detail, strength_Pos, othersMap)
    
    
    self.itemShow = Util.ShowItemShow(self.equipCtrl.svc_equipicon, detail.static.Icon, detail.static.Qcolor)
    self.equipCtrl.lb_name.Text = detail.static.Name
    self.equipCtrl.lb_name.FontColorRGBA = Util.GetQualityColorRGBA(detail.static.Qcolor)
    Util.SetBoxLayout(self.equipCtrl.ib_bg, detail.static.Qcolor)

    self.equipCtrl.lb_type.Text = detail.static.Type
    local bindType = detail.bindType or detail.static.BindType  
    self.equipCtrl.lb_bunding.Text = Text['Txt_bind' .. bindType]
    if bindType == 1 then 
        
        self.equipCtrl.lb_bunding.FontColorRGBA = 0xed2a0aff
    else
        self.equipCtrl.lb_bunding.FontColorRGBA = 0xffffffff
    end

    
    
    
    
    

    local ProName = GlobalHooks.DB.Find('Character',DataMgr.Instance.UserData.Pro).ProName
    if ProName == detail.static.Pro then
        self.equipCtrl.lb_profession.Text = "<color='#e7e5d1ff'>"..detail.static.Pro.."</color>"
    else
        self.equipCtrl.lb_profession.Text  = "<color='#ed2a0aff'>"..detail.static.Pro.."</color>"
    end
    self.equipCtrl.lb_score.Text = Util.GetText(TextConfig.Type.ITEM, "score") .. detail.equip.score
    
    
    local lv = DataMgr.Instance.UserData:TryToGetLongAttribute(UserData.NotiFyStatus.LEVEL,0)
    local txtLv = ""
    
    
    
    
    
    
 
    txtLv=Util.GetText(TextConfig.Type.ITEM, "ji",detail.static.LevelReq)
    if detail.static.LevelReq > lv then
        txtLv = "<color='#ed2a0aff'>"..txtLv.."</color>"
    end
    self.equipCtrl.lb_level.Text = txtLv

    if strength_Pos == nil then
        local itemIdConfigTypeId = ItemModel.GetSecondType(detail.static.Type)
        strength_Pos = ItemModel.GetEquipStrgData(itemIdConfigTypeId) 
    end
    createXMEquipProps(self, self.equipCtrl.sp_content.Width - 30, detail,strength_Pos, othersMap)
    if (self.equipCtrl.canvas.Height < self.equipCtrl.sp_content.Height) then
        self.equipCtrl.sp_content.Scrollable.Scroll.vertical = false
    else
        self.equipCtrl.sp_content.Scrollable.Scroll.vertical = true
    end
end

local function initControls(view, names, tbl)
    for i = 1, #names, 1 do
        local ui = names[i]
        local ctrl = view:FindChildByEditName(ui.name, true)
        if (ctrl) then
            tbl[ui.name] = ctrl
            if (ui.click) then
                ctrl.TouchClick = function()
                    ui.click(self)
                end
            end
        end
    end
end

function _M:LookAtTop(isEquip)
    if isEquip and self.equipCtrl.canvas then
        self.equipCtrl.sp_content.Scrollable.Scroll:LookAt(Vector2.New(0,0),false)
    elseif self.materialCtrl.canvas then
        self.materialCtrl.sp_content.Scrollable.Scroll:LookAt(Vector2.New(0,0),false)
    end
end

local function initEquipInfo(self, width)
    local canvas = HZCanvas.New()
    canvas.UnityObject.name = "createXMEquipProps"
    local layout = canvas.UnityObject:AddComponent(typeof(UnityEngine.UI.VerticalLayoutGroup))
    layout.childForceExpandHeight = false
    layout.spacing = 2
    local sizeFill = canvas.UnityObject:AddComponent(typeof(UnityEngine.UI.ContentSizeFitter))
    local FitMode = UnityEngine.UI.ContentSizeFitter.FitMode.PreferredSize
    sizeFill.verticalFit = FitMode
    
    
    self.equipCtrl.mainAttsText = Util.CreateRichTextWithContext(width, 22, "")
    local lElement = self.equipCtrl.mainAttsText.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    self.equipCtrl.mainAttsText.UnityObject.name = "mainAttsText"
    lElement.preferredHeight = self.equipCtrl.mainAttsText.Height
    canvas:AddChild(self.equipCtrl.mainAttsText)
    self.equipCtrl.mainAttsText.Visible = false

    
    self.equipCtrl.imgLine1 = createLine(width)
    self.equipCtrl.imgLine1.UnityObject.name = "imgLine1"
    local lElement = self.equipCtrl.imgLine1.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = 15
    canvas:AddChild(self.equipCtrl.imgLine1)
    self.equipCtrl.imgLine1.Visible = false
    
    local randomAttsText = Util.CreateRichTextWithContext(width, 22, "")
    local lElement = randomAttsText.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = randomAttsText.Height
    canvas:AddChild(randomAttsText)
    self.equipCtrl.randomAttsText = randomAttsText
    self.equipCtrl.randomAttsText.UnityObject.name = "randomAttsText"
    randomAttsText.Visible = false

    
    
    
    
    
    
    
    
    local starsAttsText = Util.CreateRichTextWithContext(width, 22, "")
    local lElement = starsAttsText.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = starsAttsText.Height
    canvas:AddChild(starsAttsText)
    self.equipCtrl.starsAttsText = starsAttsText
    self.equipCtrl.starsAttsText.UnityObject.name = "starsAttsText"
    starsAttsText.Visible = false

    
    self.equipCtrl.imgLine3 = createLine(width)
    self.equipCtrl.imgLine3.UnityObject.name = "imgLine3"
    local lElement = self.equipCtrl.imgLine3.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = 15
    canvas:AddChild(self.equipCtrl.imgLine3)
    self.equipCtrl.imgLine3.Visible = false
    
    local specialAttsText = Util.CreateRichTextWithContext(width, 22, "")
    local lElement = specialAttsText.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = specialAttsText.Height
    canvas:AddChild(specialAttsText)
    self.equipCtrl.specialAttsText = specialAttsText
    self.equipCtrl.specialAttsText.UnityObject.name = "specialAttsText"
    specialAttsText.Visible = false


    
    self.equipCtrl.imgLine4 = createLine(width)
    self.equipCtrl.imgLine4.UnityObject.name = "imgLine4"
    local lElement = self.equipCtrl.imgLine4.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = 15
    canvas:AddChild(self.equipCtrl.imgLine4)
    self.equipCtrl.imgLine4.Visible = false
    
    self.equipCtrl.suitAttsText = Util.CreateRichTextWithContext(width, 22, "")
    local lElement = self.equipCtrl.suitAttsText.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = self.equipCtrl.suitAttsText.Height
    canvas:AddChild(self.equipCtrl.suitAttsText)
    self.equipCtrl.suitAttsText.Visible = false

     
    self.equipCtrl.imgLine5 = createLine(width)
    self.equipCtrl.imgLine5.UnityObject.name = "imgLine5"
    local lElement = self.equipCtrl.imgLine5.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = 15
    canvas:AddChild(self.equipCtrl.imgLine5)
    self.equipCtrl.imgLine5.Visible = false
    
    self.equipCtrl.jewelCtrl = { }
    local node = XmdsUISystem.CreateFromFile("xmds_ui/bag/gem.gui.xml")
    initControls(node, ui_names_jewel, self.equipCtrl.jewelCtrl)

    local lElement = node.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = 35
    local jewelNodeText = node:FindChildByEditName("lb_gem",true)
    
    jewelNodeText.Text="    "..Util.GetText(TextConfig.Type.ITEM, "buweixiangqian")
    canvas:AddChild(node)
    self.equipCtrl.jewelNode = node
    self.equipCtrl.jewelNode.Visible = false

    
    local jewelAttrText = Util.CreateRichTextWithContext(width, 22, "")
    local lElement = jewelAttrText.UnityObject:AddComponent(typeof(UnityEngine.UI.LayoutElement))
    lElement.preferredHeight = jewelAttrText.Height
    canvas:AddChild(jewelAttrText)
    self.equipCtrl.jewelAttrText = jewelAttrText
    self.equipCtrl.jewelAttrText.Visible = false
    

    return canvas
end

local function Set(self, data)
    self:SetItem(data)
    self.content_node = self.menu:GetComponent('cvs_detailed')
end

local function AddExtraNode(self, node)
    local cvs_bag = self.menu:GetComponent('cvs_details')
    cvs_bag:AddChild(node)
    node.Y = cvs_bag.Height
    cvs_bag.Height = cvs_bag.Height + node.Height
end

local ui_names = {
    { name = "cvs_information_detailed" },
    { name = "cvs_btn" },
    { name = "cvs_detailed" },
}

local ui_names_material = {
    { name = "lb_materialname" },
    { name = "lb_num" },
    { name = "lb_pilenum" },
    { name = "lb_bunding2" },
    { name = "lb_uselevel" },
    { name = "sp_content" },
    { name = "svc_matirialicon" },
    
    
    { name = "ib_bg"},
    { name = "lb_jishou" }, 
}

local ui_names_equip = {
    { name = "lb_name" },
    { name = "lb_type" },
    { name = "lb_bunding" },
    { name = "lb_profession" },
    { name = "lb_level" },
    { name = "svc_equipicon" },
    { name = "lb_score" },
    
    
    { name = "sp_content" },
    { name = "ib_bg"},
    { name = "ib_bg2"},
   
}

function _M:Visible(visible)
    if visible == false then
        self.material.Visible = false
        self.equip.Visible = false
    end
end

local function initXmlMaterial(self,root)
    if root == nil then
        self.material = XmdsUISystem.CreateFromFile("xmds_ui/bag/information_material.gui.xml")
    else
        self.material = root
    end
    self.materialCtrl = { }
    initControls(self.material, ui_names_material, self.materialCtrl)
    self.material.Visible = false
    self.materialCtrl.descText = HZTextBox.New()
    self.materialCtrl.descText.Size2D = Vector2.New(self.materialCtrl.sp_content.Width - 30, 80)
    self.materialCtrl.descText.FontSize = 22
    self.materialCtrl.sp_content:AddNormalChild(self.materialCtrl.descText)
end

local function initXmlEquipment(self,root)
    if root == nil then
        self.equip = XmdsUISystem.CreateFromFile("xmds_ui/bag/information_equip.gui.xml")
    else
        self.equip = root
    end
    self.equipCtrl = { }
    initControls(self.equip, ui_names_equip, self.equipCtrl)
    local canvas = initEquipInfo(self, self.equipCtrl.sp_content.Width - 30)
    self.equipCtrl.canvas = canvas
    canvas.X = 14
    self.equipCtrl.sp_content:AddNormalChild(canvas)
    self.equip.Visible = false

end

local function initMiniMaterial(self)
    self.material = XmdsUISystem.CreateFromFile("xmds_ui/bag/miniMaterial_info.gui.xml")
    self.materialCtrl = { }
    initControls(self.material, ui_names_material, self.materialCtrl)
    self.material.Visible = false
    self.materialCtrl.descText = HZTextBox.New()
    self.materialCtrl.descText.Size2D = Vector2.New(self.materialCtrl.sp_content.Width - 30, 80)
    self.materialCtrl.descText.FontSize = 22
    self.materialCtrl.sp_content:AddNormalChild(self.materialCtrl.descText)
end

local function initMiniEquipment(self)
    self.equip = XmdsUISystem.CreateFromFile("xmds_ui/bag/miniEquip_info.gui.xml")
    self.equipCtrl = { }
    initControls(self.equip, ui_names_equip, self.equipCtrl)
    local canvas = initEquipInfo(self, self.equipCtrl.sp_content.Width - 30)
    self.equipCtrl.canvas = canvas
    canvas.X = 14
    self.equipCtrl.sp_content:AddNormalChild(canvas)
    self.equip.Visible = false
end

local ui_btns_name = {
    { name = "cvs_btn1" },
    { name = "cvs_btn2" },
    { name = "cvs_btn3" },
}


function _M:setButtons(buttons,callback)
    if buttons and #buttons > 0 then
        local size = #buttons
        if self.btnView == nil then
            self.btnView = XmdsUISystem.CreateFromFile("xmds_ui/bag/miniEquip_info_btn.gui.xml")
            self.cvs_btn:AddChild(self.btnView)
            self.btnViewCtrl = { }
            initControls(self.btnView, ui_btns_name, self.btnViewCtrl)
        end
        for i = 1, 3, 1 do
            self.btnViewCtrl["cvs_btn" .. i].Visible = false
        end
        self.btnViewCtrl["cvs_btn" .. size].Visible = true
        for i = 1, size, 1 do
            local btn = self.btnViewCtrl["cvs_btn" .. size]:FindChildByEditName("btn_" .. i, true)
            if (btn) then
                btn.Text = buttons[i].title
                self.eventItemDetail:bindBtnEvent(btn, buttons[i].eventName,buttons[i].clickFunc)
            end
        end
        self.cvs_btn.Visible = true
        self:setCloseCallback(callback)














    else
        self.cvs_btn.Visible = false
    end
end

function _M:setCloseCallback(callback)
    local function closeCallBack(sender, name, param)
        
        if (name == "Event.OnSellItemClean") then
            if (callback) then
                callback(sender, name, "itemNull")
            end
        elseif (name == "Event.OnUseItemClean") then
            if (callback) then
                callback(sender, name, "itemNull")
            end
        else
            callback(sender, name, param)
        end
    end
    self.eventItemDetail:SubscribCallBack(closeCallBack)
end

function _M:setXmlPos(pos)
    self.cvs_detailed.X = pos.x
    self.cvs_detailed.Y = pos.y
end

local function InitComponent(self, tag,param)
    if param == 0 then
        self.menu = LuaMenuU.Create("xmds_ui/bag/info_detailed2.gui.xml", tag)
    else
        self.menu = LuaMenuU.Create("xmds_ui/bag/miniitem_info_detailed2.gui.xml", tag)
    end
    Util.CreateHZUICompsTable(self.menu, ui_names, self)
    self.menu.CacheLevel = -1
    self.menu.ShowType = UIShowType.Cover
    self.menu.Enable = true
    self.menu.event_PointerClick = function(sender)
        self:Close()
    end
    if param == 0 then
        initXmlMaterial(self)
        self.cvs_information_detailed:AddChild(self.material)
        initXmlEquipment(self)
        self.cvs_information_detailed:AddChild(self.equip)
    else
        initMiniMaterial(self)
        self.cvs_information_detailed:AddChild(self.material)
        initMiniEquipment(self)
        self.cvs_information_detailed:AddChild(self.equip)
    end
    self.eventItemDetail = EventItemDetail.Create(3)
end


local function CreateWithMiniXml(tag,param)
    local ret = { }
    setmetatable(ret, _M)
    if param == nil then
        param = "0"
    end
    param = tonumber(param)
    InitComponent(ret, tag,param)
    return ret
end

function _M.CreateWithMiniXmlInside(tag, parent, buttons, callback)
    local ret = { }
    setmetatable(ret, _M)
    ret.menu = XmdsUISystem.CreateFromFile("xmds_ui/bag/miniitem_info_detailed.gui.xml")
    ret.autoSide = true
    initControls(ret.menu, ui_names, ret)
    initMiniMaterial(ret)
    ret.cvs_information_detailed:AddChild(ret.material)
    initMiniEquipment(ret)
    ret.cvs_information_detailed:AddChild(ret.equip)
    ret.eventItemDetail = EventItemDetail.Create(3)
    if(buttons) then
        ret:setButtons(buttons,callback)
    end







    if (parent) then
        parent:AddChild(ret.menu)
    end
    return ret
end

function _M:CloseMenu()
    self.menu.Visible = false
end

function _M:ResetWithBagUI()
    self:SetItem(self.data,self.data.IsEquip)
end


function _M.CreateWithBagUI(tag, parent, buttons, callback)
    local ret = { }
    setmetatable(ret, _M)
    ret.menu =  XmdsUISystem.CreateFromFile("xmds_ui/bag/information_detailed.gui.xml")
    ret.menu.Tag = tag
    ret.bagUI = true
    initControls(ret.menu,ui_names,ret)
    initXmlMaterial(ret)
    ret.cvs_information_detailed:AddChild(ret.material)
    initXmlEquipment(ret)
    ret.cvs_information_detailed:AddChild(ret.equip)
    ret.menu.Enable = false





    if (parent) then
        parent:AddChild(ret.menu)
    end
    ret.eventItemDetail = EventItemDetail.Create(3)
    if(buttons) then
        ret:setButtons(buttons,callback)
    end
































    return ret
end

function _M.SetConsignmentItemUI(self,parent,data)
    local detail = data.detail
    
    local ret
    if self == nil then
        ret = { }
        setmetatable(ret, _M)
    else 
        ret = self
        if self.materialCtrl and self.materialCtrl.descText then
            self.materialCtrl.descText:RemoveFromParent(true)
            self.materialCtrl.descText = nil
        end

        if self.equipCtrl and self.equipCtrl.canvas then
            self.equipCtrl.canvas:RemoveFromParent(true)
            self.equipCtrl.canvas = nil
        end
    end
    if detail.equip == nil then
        initXmlMaterial(ret,parent)
        setMaterial(ret,detail,data)
        ret.material.Visible = true
    else
        initXmlEquipment(ret,parent)
        setEquip(ret,detail)
        ret.equip.Visible = true
    end
    return ret
end

function _M.SetGuildWareHouseItemUI(self,parent,detail)
    
    local ret
    if self == nil then
        ret = { }
        setmetatable(ret, _M)
    else 
        ret = self
        if self.equipCtrl and self.equipCtrl.canvas then
            self.equipCtrl.canvas:RemoveFromParent(true)
            self.equipCtrl.canvas = nil
        end
    end
    if detail.equip ~= nil then
        initXmlEquipment(ret,parent)
        setEquip(ret,detail)
        ret.equip.Visible = true
    end
    return ret
end

_M.Set = Set
_M.AddExtraNode = AddExtraNode


_M.CreateWithMiniXml = CreateWithMiniXml

_M.TXT_COLOR = TXT_COLOR
_M.Text = Text

_M.setMaterial = setMaterial
_M.setEquip = setEquip
return _M
