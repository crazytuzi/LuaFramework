local MoShenFeatRankItem = class("MoShenFeatRankItem",function()
    --记得修改json
    return CCSItemCellBase:create("ui_layout/moshen_MoShenFeatRankItem.json")
--    return CCSItemCellBase:create("ui_layout/shop_ShopPropItem.json")
end)
require("app.cfg.knight_info")

function MoShenFeatRankItem:ctor(...)
    self._checkPubFuc = nil 
    self._checkHeadFunc = nil 
    self._labelName = self:getLabelByName("Label_name")   --名字
    self._labelLevel = self:getLabelByName("Label_level")  --等级
    self._gongxunLabel = self:getLabelByName("Label_gongxun")    --功勋
    self._zhanliLabel = self:getLabelByName("Label_zhanli")  --战力
    self._headImage = self:getImageViewByName("ImageView_head")   --头像
    self._rankImageView = self:getImageViewByName("Image_rank")
    self._headButton = self:getButtonByName("Button_head")
    self._rankBMFont = self:getLabelBMFontByName("BitmapLabel_rank")
    self._bgImage = self:getImageViewByName("ImageView_bg") --背景图
    self._infoPanel = self:getPanelByName("Panel_10") -- 数值信息背景小框
    self._checkPubButton = self:getButtonByName("Button_checkpub")
    self:registerBtnClickEvent("Button_checkpub",function()
        if self._checkPubFuc ~= nil then
            self._checkPubFuc()
        end
    end)
    
    self:registerBtnClickEvent("Button_head",function()
        if self._checkHeadFunc ~= nil then
            self._checkHeadFunc()
        end
    end)
    self._labelName:createStroke(Colors.strokeBrown,1)
    -- self._gongxunLabel:createStroke(Colors.strokeBrown,1)
    -- self._zhanliLabel:createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_gongxunTag"):createStroke(Colors.strokeBrown,1)
    -- self:getLabelByName("Label_zhanliTag"):createStroke(Colors.strokeBrown,1)

end
function MoShenFeatRankItem:checkZhenrong(func)
    self._checkPubFuc = func
end

function MoShenFeatRankItem:update(rebel)
    if rebel == nil then
        return
    end
    if rebel.user_id == G_Me.userData.id then
        self._bgImage:loadTexture("board_red.png",UI_TEX_TYPE_PLIST)
        self._infoPanel:setBackGroundImage("list_board_red.png", UI_TEX_TYPE_PLIST)
    else
        self._bgImage:loadTexture("board_normal.png",UI_TEX_TYPE_PLIST)
        self._infoPanel:setBackGroundImage("list_board.png", UI_TEX_TYPE_PLIST)
    end

    local knight = knight_info.get(rebel.id)
    self._headImage:loadTexture(G_Path.getKnightIcon(
        G_Me.dressData:getDressedResidWithClidAndCltm(rebel.id,rebel.dress_id,rebel.clid,rebel.cltm,rebel.clop)
        ))
    
    self._headButton:loadTextureNormal(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
    self._headButton:loadTexturePressed(G_Path.getEquipColorImage(knight.quality,G_Goods.TYPE_KNIGHT))
    self._labelLevel:setText(rebel.level .. G_lang:get("LANG_FIGHTEND_GONGXI_AFTER"))
    self._zhanliLabel:setText(rebel.attack_value)
    self._labelName:setColor(Colors.qualityColors[knight.quality])
    self._labelName:setText(rebel.name)
    self._rankImageView:setVisible(rebel.rank<=3)
    self._rankBMFont:setVisible(rebel.rank>3)
    self._gongxunLabel:setText(rebel.value)
    if rebel.rank <= 3 then
        self._rankImageView:loadTexture(G_Path.getPHBImage(rebel.rank))
    else
        self._rankBMFont:setText(rebel.rank)
    end
end



return MoShenFeatRankItem

