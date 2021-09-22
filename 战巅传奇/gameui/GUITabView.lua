--页签控件
GUITabView = class("GUITabView",function()
	return ccui.Widget:create()
end)

local defStyle = {
    horizon={
        normal = "new_main_tab_h1.png",
        select = "new_main_tab_h2.png",
        ncolor = GameBaseLogic.getColor(0xf1e8d0),
        scolor = GameBaseLogic.getColor(0xf1e8d0),
        startX = 4,
        itemsMargin = 3,
        fontSize = 12,
        scale = false,
        action = false,
        labelStyle = "horizon", --竖向文字，横向文字
    },
    vertical={
        normal = "common_big_tab_v2.png",
        select = "common_big_tab_v1.png",
        ncolor = GameBaseLogic.getColor(0xad8850),
        scolor = GameBaseLogic.getColor(0xebb86d),
        startY = 0,
        itemsMargin = 10,
        fontSize = 20,
        scale = true,
        offx=1,
        offy=0,
        labelStyle = "vertical", --竖向文字，横向文字
    }
}

function GUITabView:ctor(params)
	self._items = {};
	self._tabEventListener = nil;
	self._listTab = nil;
    self._curIndex = params.defaultTab or 1;

	self._ntcolor = nil;
	self._stcolor = nil;

	self.style = params.style or "horizon"
	self.titles = params.titles or {}
    local con = defStyle[params.style] or defStyle["horizon"]
	self._conf = clone(con);
    if params.normal then
        self._conf.normal = params.normal
    end
    if params.select then
        self._conf.select = params.select
    end
    if params.itemsMargin then
        self._conf.itemsMargin = params.itemsMargin
    end
    self:setAnchorPoint(0, 0)
    self:setContentSize(params.size)
	self:initTab(self._conf)
end

function GUITabView:initTab( conf )
	
    local item, lblTitle, normalRes = conf.normal
    local selectedRes = conf.select;
    self._nres = conf.normal;
    self._sres = conf.select;
    self._ntcolor = conf.ncolor;
    self._stcolor = conf.scolor;
    self._fontSize = conf.fontSize;
    self._labelStyle = conf.labelStyle
    for i,v in ipairs(self.titles) do
        item = ccui.Button:create();
		item:loadTextureNormal(self._nres,ccui.TextureResType.plistType)
		item:loadTexturePressed(self._sres,ccui.TextureResType.plistType)
		print("self._nres",self._nres)
		print("self._sres",self._sres)
        item:setTouchEnabled(true);
        item:setTag(i);
        item:setName("tab"..i);
        -- if math.ceil(#v/3)>=4 then
        --     self._fontSize = 16
        -- end
        local itemsize = item:getContentSize()
        local params = {text= v, fontSize= self._fontSize,anchor = cc.p(0.5,0.5),outlineColor = cc.c3b(0,0,0),outlineStrength = 1}
        if self.style == "horizon" then
        	item:setAnchorPoint(0, 0);
        	item:setPosition(conf.startX + (item:getContentSize().width + conf.itemsMargin) * (i-1),0);
        else
            if itemsize.width<itemsize.height then
                params.contentSize = cc.size(self._fontSize,math.ceil(#v/3)*(self._fontSize+4))
            end
        	item:setAnchorPoint(1, 0.5);
        	item:setPosition(self:getContentSize().width, conf.startY - 0.5 * item:getContentSize().height - (item:getContentSize().height + conf.itemsMargin) * (i-1));
        end
		--item:setOpacity(255 * 0.7)
        self:addChild(item);
        lblTitle = GameUtilSenior.newUILabel(params);
        lblTitle:setPosition(itemsize.width/2+(conf.offx or 0), itemsize.height/2+(conf.offy or 0));
        lblTitle:setName("lblTitle");
        lblTitle:setColor(self._ntcolor);
        item:addChild(lblTitle);

        table.insert(self._items,item);
        item:addClickEventListener(handler(self,self.onTabButtonClicked))
        if self._conf.action then
            item:setPressedActionEnabled(true)
            item:setZoomScale(-0.12)
        end
    end
end

function GUITabView:onTabButtonClicked(sender, noCb)
    local lblTitle;
    for i,v in ipairs(self._items) do
        lblTitle = v:getChildByName("lblTitle")
        if i ~= sender:getTag() then
            v:setBrightStyle(ccui.BrightStyle.normal);
            v:setTouchEnabled(true);
            lblTitle:setColor(self._ntcolor);
            v:setScale(1.0)
        else
            self._curIndex = i
            v:setBrightStyle(ccui.BrightStyle.highlight);
            v:setTouchEnabled(false)
            lblTitle:setColor(self._stcolor);
            if self._conf.scale then
                v:setScale(1.0)
            end
        end
    end
    if not noCb then
        if self._tabEventListener then
            self._tabEventListener(sender);
        end
    end
end

function GUITabView:addTabEventListener( callBack )
    self._tabEventListener = callBack;
    return self
end

function GUITabView:setSelectedTab( index )
	if self._items[index] then
		self:onTabButtonClicked(self._items[index]);
	end
    return self
end
--仅仅设置状态
function GUITabView:setTabSelected(index)
    if self._items[index] then
        self:onTabButtonClicked(self._items[index], true)
    end
    return self
end

function GUITabView:getCurIndex()
    return self._curIndex
end

function GUITabView:hideTab( indexList )
    if GameUtilSenior.isNumber(indexList) then
        indexList = {indexList}
    end
    local conf = self._conf
    local showi = 0
    for i,v in ipairs(self._items) do
        if table.indexof(indexList, i) then
            v:hide()
        else
            v:show()
            showi = showi + 1
        end
        if self.style == "horizon" then
            v:setAnchorPoint(0, 0);
            v:setPosition(conf.startX + (v:getContentSize().width + conf.itemsMargin) * (showi-1),0);
        else
            v:setAnchorPoint(1, 0.5);
            v:setPosition(self:getContentSize().width, conf.startY - 0.5 * v:getContentSize().height - (v:getContentSize().height + conf.itemsMargin) * (showi-1));
        end
    end
    return self
end

function GUITabView:setTabVisible(index,visible)
    for i,v in ipairs(self._items) do
        if i==index then
            v:setVisible(visible);
        end
    end
    return self
end

function GUITabView:getDescription()
    return self.__cname;
end

function GUITabView:setTabRes(normal,selected,textureType)
    self._nres = normal;
    self._sres = selected;
    textureType = textureType or ccui.TextureResType.plistType
    local conf = self._conf
    for i,v in ipairs(self._items) do
        v:loadTextureNormal(self._nres,textureType)
        v:loadTexturePressed(self._sres,textureType)
        if self.style == "horizon" then
            v:setAnchorPoint(0, 0);
            v:setPosition(conf.startX + (v:getContentSize().width + conf.itemsMargin) * (i-1),0);
        else
            v:setAnchorPoint(1, 0.5);
            v:setPosition(self:getContentSize().width, conf.startY - 0.5 * v:getContentSize().height - (v:getContentSize().height + conf.itemsMargin) * (i-1));
        end
        v:getWidgetByName("lblTitle"):setPosition(v:getContentSize().width/2,v:getContentSize().height/2)
    end
    self:setFontSize(self._fontSize)
    return self
end

function GUITabView:setTabColor(ncolor,scolor)
    self._ntcolor = ncolor
    self._stcolor = scolor
    for i,v in ipairs(self._items) do
        lblTitle = v:getChildByName("lblTitle")
        if i ~= self._curIndex then
            lblTitle:setColor(self._ntcolor);
        else
            lblTitle:setColor(self._stcolor);
        end
    end
    return self
end

function GUITabView:setFontSize(size)
    -- if self._fontSize ~= size then
        self._fontSize = size
        local lblTitle,string,itemsize,contentSize
        for i,v in ipairs(self._items) do
            lblTitle = v:getWidgetByName("lblTitle")
            if self.style == "vertical" then
                string = lblTitle:getString()
                itemsize = v:getContentSize()
                if itemsize.width<itemsize.height then
                    local contentSize = cc.size(self._fontSize,math.ceil(#string/3)*(self._fontSize+4))
                    lblTitle:setContentSize(contentSize):setTextAreaSize(contentSize)
                else
                    local contentSize = cc.size(math.ceil(#string/3)*(self._fontSize+2),self._fontSize+2)  --+2的原因是因为不加文字显示不完整
                    lblTitle:setContentSize(contentSize):setTextAreaSize(contentSize)
                end
            end
            lblTitle:setFontSize(size):setPosition(v:getContentSize().width/2,v:getContentSize().height/2)
        end
    -- end
    return self
end
function GUITabView:setOffsetPosition(pos)
    if pos then
         for i,v in ipairs(self._items) do
            lblTitle = v:getWidgetByName("lblTitle")
            if lblTitle then
                lblTitle:setFontSize(size):setPosition(v:getContentSize().width/2 + pos.x,v:getContentSize().height/2 + pos.y)
            end
        end
    end
end
function GUITabView:setScaleEnabled(value)
    if GameUtilSenior.isBool(value) then
        self._conf.scale = value
        for i,v in ipairs(self._items) do
            if self._curIndex == i and value then
                v:setScale(1.0)
            else
                v:setScale(1)
            end
        end
    end
    return self
end

function GUITabView:setItemMargin(value)
    if self._conf.itemsMargin ~= value then
        self._conf.itemsMargin = value
        for i,v in ipairs(self._items) do
            if self.style == "horizon" then
                v:setAnchorPoint(0, 0);
                v:setPosition(self._conf.startX + (v:getContentSize().width + self._conf.itemsMargin) * (i-1),0);
            else
                v:setAnchorPoint(1, 0.5);
                v:setPosition(self:getContentSize().width, self._conf.startY - 0.5 * v:getContentSize().height - (v:getContentSize().height + self._conf.itemsMargin) * (i-1));
            end
        end
    end
    return self
end

function GUITabView:getItemByIndex(index)
    return self._items[index]
end
function GUITabView:setTouchEnabled(enable)
    for k,v in pairs(self._items) do
        v:setTouchEnabled(enable)
    end
    getmetatable(self).setTouchEnabled(self,enable)
    return self
end
return GUITabView;