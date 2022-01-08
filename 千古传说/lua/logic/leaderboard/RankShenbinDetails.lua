
local RankShenbinDetails = class("RankShenbinDetails")


local GameAttributeData = require('lua.gamedata.base.GameAttributeData')

function RankShenbinDetails:ctor(data)

end

function RankShenbinDetails:initUI( ui )

    --神兵榜个人信息
    self.myBgShenbingbang = TFDirector:getChildByPath(ui, "bgShenbingbang")
    self.myTxt_shenbingpaiming_word = TFDirector:getChildByPath(self.mybgShenbingbang, "txt_shenbingpaiming_word")
    self.myTxtXKZhandouli = TFDirector:getChildByPath(self.mybgShenbingbang, "txtXKZhandouli")
    self.myImg_quality = TFDirector:getChildByPath(self.myBgShenbingbang, "img_quality")
    self.myImg_icon = TFDirector:getChildByPath(self.myBgShenbingbang, "img_icon")
    self.myTxt_intensify_lv = TFDirector:getChildByPath(self.myBgShenbingbang, "txt_intensify_lv")
    self.myPanel_star = TFDirector:getChildByPath(self.myBgShenbingbang, "panel_star")
    self.myImg_star = {}
    for i=1,5 do
    	self.myImg_star[i] = TFDirector:getChildByPath(self.myBgShenbingbang, "img_star_"..i)
    end
    self.myimg_gembg = TFDirector:getChildByPath(self.myBgShenbingbang, "img_gembg")
    self.myimg_gem = TFDirector:getChildByPath(self.myBgShenbingbang, "img_gem")

    --神兵详细信息
    self.bgLeft2 = TFDirector:getChildByPath(ui, "bgLeft2")
    self.img_quality = TFDirector:getChildByPath(self.bgLeft2, "img_quality")
    self.img_icon = TFDirector:getChildByPath(self.bgLeft2, "img_icon")
    self.txt_intensify_lv = TFDirector:getChildByPath(self.bgLeft2, "txt_intensify_lv")
    self.panel_star = TFDirector:getChildByPath(self.bgLeft2, "panel_star")
    self.img_star = {}
    for i=1,5 do
    	self.img_star[i] = TFDirector:getChildByPath(self.bgLeft2, "img_star_"..i)
    end

    self.img_gembg = TFDirector:getChildByPath(self.bgLeft2, "img_gembg")
    self.img_gem = TFDirector:getChildByPath(self.bgLeft2, "img_gem")
    self.txt_attr_base      = TFDirector:getChildByPath(self.bgLeft2, "txt_attr_base")
    self.txt_attr_base_val  = TFDirector:getChildByPath(self.bgLeft2, "txt_attr_base_val")
    self.txt_attr_extra     = {}
    self.txt_attr_extra_val = {}
    for i = 1,EquipmentManager.kMaxExtraAttributeSize do
        self.txt_attr_extra[i]          = TFDirector:getChildByPath(self.bgLeft2, "txt_attr_extra_" .. i)
        self.txt_attr_extra_val[i]      = TFDirector:getChildByPath(self.bgLeft2, "txt_attr_extra_val_" .. i)
    end
    self.txt_gem_name = TFDirector:getChildByPath(self.bgLeft2, "txt_gem_name")

    self.txt_attr_gem = TFDirector:getChildByPath(self.bgLeft2, "txt_attr_gem") 
    self.txt_attr_gem_val = TFDirector:getChildByPath(self.bgLeft2, "txt_attr_gem_val") 
    self.txt_power = TFDirector:getChildByPath(self.bgLeft2, "txt_power")
    self.txt_name = TFDirector:getChildByPath(self.bgLeft2, "txt_name")    
end

function RankShenbinDetails:showDetails(item)

--[[
    local itemData = ItemData:objectByID(item.goodsId)
        self.img_quality:setTexture(GetColorIconByQuality(itemData.quality))
        self.img_icon:setTexture(itemData:GetPath())
        self.txt_intensify_lv:setText("+"..item.intensifyLevel)
]]

    self.txt_power:setText(item.value)
    self.txt_intensify_lv:setText("+"..item.intensifyLevel)


    local itemData = ItemData:objectByID(item.goodsId)
    self.img_quality:setTexture(GetColorIconByQuality(itemData.quality))
    self.img_icon:setTexture(itemData:GetPath())
    self.txt_name:setString(itemData.name)

    --装备属性 基本属性
    local equipData = item.baseAttribute
    local equipAttr = GameAttributeData:new()          
    equipAttr:init(equipData)
    local baseAttr = equipAttr.attribute 
    for i=1,(EnumAttributeType.Max-1) do
        if baseAttr[i] then

            self.txt_attr_base:setText(AttributeTypeStr[i])
            self.txt_attr_base_val:setText("+ " .. covertToDisplayValue(i,baseAttr[i]))

            break

        end
    end
    --装备属性 附加属性
    local equipDataExtra = item.extraAttribute
    local equipAttrExtra = GameAttributeData:new()    
    equipAttrExtra:init(equipDataExtra)
    local baseAttrExtra = equipAttrExtra.attribute 
    local attrExtraNum = 1
    for i=1,(EnumAttributeType.Max-1) do
        if baseAttrExtra[i] then

            self.txt_attr_extra[attrExtraNum]:setVisible(true)
            self.txt_attr_extra_val[attrExtraNum]:setVisible(true)

            self.txt_attr_extra[attrExtraNum]:setText(AttributeTypeStr[i])
            self.txt_attr_extra_val[attrExtraNum]:setText("+ " .. covertToDisplayValue(i,baseAttrExtra[i]))
            attrExtraNum = attrExtraNum + 1
        end
    end

    for i=attrExtraNum,(EquipmentManager.kMaxExtraAttributeSize) do
        self.txt_attr_extra[i]:setVisible(false)
        self.txt_attr_extra_val[i]:setVisible(false)
    end

    for i=1,item.starLevel do
    	self.img_star[i]:setVisible(true)
    end
    for i=item.starLevel+1,5 do
    	self.img_star[i]:setVisible(false)
    end

    local gemData = ItemData:objectByID(item.gemId)
    local gem = GemData:objectByID(item.gemId)
    if gemData and gem then
        self.img_gembg:setVisible(true)
        self.txt_gem_name:setVisible(true)

        self.img_gem:setTexture(gemData:GetPath())        
        local attr_index,attr_num = gem:getAttribute()
        self.txt_gem_name:setString(gemData.name)
        self.txt_attr_gem_val:setString(attr_num)
        self.txt_attr_gem:setString(AttributeTypeStr[attr_index])
    else
        self.img_gembg:setVisible(false)
        self.txt_gem_name:setVisible(false)
    end
 end

function RankShenbinDetails:showMyDetails(item)

    --self.myTxt_shenbingpaiming_word:setText(item.myRanking)
    --self.myTxtXKZhandouli:setString(item.myBestValue)
    -- self.myImg_quality = TFDirector:getChildByPath(self.myBgShenbingbang, "img_quality")
    -- self.myImg_icon = TFDirector:getChildByPath(self.myBgShenbingbang, "img_icon")
    -- self.myTxt_intensify_lv = TFDirector:getChildByPath(self.myBgShenbingbang, "txt_intensify_lv")
    -- self.myPanel_star = TFDirector:getChildByPath(self.myBgShenbingbang, "panel_star")
    -- self.myImg_star = {}
    -- for i=1,5 do
    -- 	self.myImg_star[i] = TFDirector:getChildByPath(self.myBgShenbingbang, "img_star_"..i)
    -- end
    -- self.myimg_gembg = TFDirector:getChildByPath(self.myBgShenbingbang, "img_gembg")
    -- self.myimg_gem = TFDirector:getChildByPath(self.myBgShenbingbang, "img_gem")
end

function RankShenbinDetails:setVisible(enable)
	self.myBgShenbingbang:setVisible(enable)
	self.bgLeft2:setVisible(enable)
end

return RankShenbinDetails