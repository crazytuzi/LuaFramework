--[[
******预览武学*******
    -- by Chikui Peng
    -- 2016/2/20
]]

local RoleBook_Preview = class("RoleBook_Preview", BaseLayer)

CREATE_PANEL_FUN(RoleBook_Preview)

function RoleBook_Preview:ctor(data)
    self.super.ctor(self,data)
    self.roleGmid = data[1]            -- {roleGmid}
    self:init("lua.uiconfig_mango_new.role_new.bookpreview")
end

function RoleBook_Preview:onShow()
    self.super.onShow(self)
    self:refreshUI()
end

function RoleBook_Preview:refreshUI()
    self:showBookList(1)
    self:showBookList(2)
end

function RoleBook_Preview:initUI(ui)
	self.super.initUI(self,ui)

    self.cardRole  = CardRoleManager:getRoleByGmid(self.roleGmid)

    self.txt_chongshu1 = TFDirector:getChildByPath(ui, "txt_chongshu1")
    self.txt_chongshu2 = TFDirector:getChildByPath(ui, "txt_chongshu2")

    self.panel_miji1 = TFDirector:getChildByPath(ui, "panel_miji1")
    self.panel_miji2 = TFDirector:getChildByPath(ui, "panel_miji2")
    self.node_mijiList  = {{},{}}
    self.img_bgList     = {{},{}}
    self.img_BookList   = {{},{}}
    self.img_desc       = {{},{}}
    for j=1,2 do
        for i=1,6 do
            self.node_mijiList[j][i]    =  TFDirector:getChildByPath(self["panel_miji"..j], "panel_book_" .. i)
            self.img_bgList[j][i]       =  TFDirector:getChildByPath(self.node_mijiList[j][i],"img_quality")
            self.img_BookList[j][i]     =  TFDirector:getChildByPath(self.node_mijiList[j][i],"img_equip")
            self.img_desc[j][i]         =  TFDirector:getChildByPath(self.node_mijiList[j][i],"img_desc")
            self.img_desc[j][i]:setTextureNormal("ui_new/role/icon_miji_s0.png")
            self.img_desc[j][i]:setTouchEnabled(false)
            self.img_BookList[j][i]:setScale(0.7)
            self.img_bgList[j][i]:setTag(i)
        end
    end
end

function RoleBook_Preview:showBookList(nIdx)
    if nil == self.cardRole then
        self:showPanel(nIdx,false)
        print("#####################cardRole == nil###################")
        return
    end
    local martialLevel = self.cardRole.martialLevel+nIdx
    local bookListData     = MartialRoleConfigure:findByRoleIdAndMartialLevel(self.cardRole.id, martialLevel)
    if nil == bookListData then
        self:showPanel(nIdx,false)
        return
    end
    local bookList     = bookListData:getMartialTable()
    if nil == bookList then
        self:showPanel(nIdx,false)
        return
    end
    --self["txt_chongshu"..nIdx]:setText(EnumWuxueLevelType[martialLevel].."重")
    self["txt_chongshu"..nIdx]:setText(stringUtils.format(localizable.Tianshu_chong_text, EnumWuxueLevelType[martialLevel]))
    for i=1,6 do 
        local bookid   = bookList[i]
        local bookInfo = MartialData:objectByID(bookid)
        local bookStatus = self:getBookStatus(bookInfo)
        local bgPic    = "ui_new/role/bg_book_empty.png"
        if nil == bookInfo then
            self.node_mijiList[nIdx][i]:setVisible(false)
        else
            self.node_mijiList[nIdx][i]:setVisible(true)
            local quality = bookInfo.goodsTemplate.quality
            
            self.img_BookList[nIdx][i]:setTexture(bookInfo.goodsTemplate:GetPath())

            if bookStatus == 0 then
                self.img_bgList[nIdx][i]:setTextureNormal(bgPic)
                self.img_desc[nIdx][i]:setVisible(true)
                self.img_BookList[nIdx][i]:setOpacity(100)
            else
                self.img_bgList[nIdx][i]:setTextureNormal(getBookBackgroud(quality))
                self.img_desc[nIdx][i]:setVisible(false)
                self.img_BookList[nIdx][i]:setOpacity(255)
            end
        end
    end
    self:showPanel(nIdx,true)
end

function RoleBook_Preview:getBookStatus(bookInfo)
    -- 0 不存在
    -- 1 背包存在
    local bookStatus = 0
    local id        = bookInfo.goodsTemplate.id
    local bag       = BagManager:getItemById(id)
    if bag then
        bookStatus = 1
    end
    return bookStatus
end

function RoleBook_Preview:showPanel(nIdx,bVisible)
    self["panel_miji"..nIdx]:setVisible(bVisible)
    self["txt_chongshu"..nIdx]:setVisible(bVisible)
end

function RoleBook_Preview.onBookClickHandle(sender)
    local index  = sender:getTag()
    local self   = sender.logic
    local nIdx   = sender.nIdx
    local showType = 1
    local layer  = require("lua.logic.rolebook.RoleBook_OnEquip"):new(id)
    layer:loadData(self.cardRole, index,showType,nIdx)
    AlertManager:addLayer(layer, AlertManager.BLOCK_AND_GRAY_CLOSE, AlertManager.TWEEN_1)
    AlertManager:show() 
end

function RoleBook_Preview:registerEvents(ui)
    self.super.registerEvents(self)
    for i = 1,2 do
        for j = 1,6 do
            self.img_bgList[i][j].logic = self
            self.img_bgList[i][j].nIdx = i
            self.img_bgList[i][j]:addMEListener(TFWIDGET_CLICK, audioClickfun(RoleBook_Preview.onBookClickHandle))
        end
    end
end

function RoleBook_Preview:removeEvents()
    self.super.removeEvents(self)
end

return RoleBook_Preview
 